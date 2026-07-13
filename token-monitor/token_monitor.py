"""mitmproxy addon that captures token usage into SQLite."""

from __future__ import annotations

import argparse
import json
import logging
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable, Mapping

import storage

DEFAULT_DB_PATH = Path("~/.token-monitor/usage.db").expanduser()
LOGGER = logging.getLogger("token-monitor")


def _truncate(value: str | None, max_len: int = 256) -> str | None:
    if value is None:
        return None
    return value[:max_len]


def _header_get(headers: Mapping[str, Any] | None, name: str) -> str | None:
    if not headers:
        return None

    getter = getattr(headers, "get", None)
    if callable(getter):
        value = getter(name)
        if value is None:
            value = getter(name.lower())
        if value is not None:
            return str(value)

    lowered_name = name.lower()
    for key, value in headers.items():
        if str(key).lower() == lowered_name:
            return str(value)
    return None


def extract_usage(body: bytes | str | Mapping[str, Any]) -> dict[str, int] | None:
    """Extract token usage from a non-streaming JSON payload."""
    payload: Any
    if isinstance(body, Mapping):
        payload = dict(body)
    else:
        try:
            text = body.decode("utf-8", errors="replace") if isinstance(body, bytes) else body
            payload = json.loads(text)
        except json.JSONDecodeError:
            return None

    if not isinstance(payload, Mapping):
        return None

    usage = payload.get("usage")
    if not isinstance(usage, Mapping):
        return None

    return {
        "prompt_tokens": int(usage.get("prompt_tokens", 0)),
        "completion_tokens": int(usage.get("completion_tokens", 0)),
        "total_tokens": int(usage.get("total_tokens", 0)),
    }


def extract_sse_usage(chunks: Iterable[bytes | str]) -> dict[str, int] | None:
    """Extract usage from SSE chunks, preferring usage found in the final data chunks."""
    last_usage: Mapping[str, Any] | None = None

    for chunk in chunks:
        text = chunk.decode("utf-8", errors="replace") if isinstance(chunk, bytes) else chunk
        for raw_line in text.splitlines():
            line = raw_line.strip()
            if not line.startswith("data:"):
                continue
            data = line[5:].strip()
            if data == "[DONE]" or not data:
                continue
            try:
                payload = json.loads(data)
            except json.JSONDecodeError:
                continue
            if isinstance(payload, Mapping) and isinstance(payload.get("usage"), Mapping):
                last_usage = payload["usage"]

    if not last_usage:
        LOGGER.warning("SSE stream completed without usage metadata")
        return None

    return {
        "prompt_tokens": int(last_usage.get("prompt_tokens", 0)),
        "completion_tokens": int(last_usage.get("completion_tokens", 0)),
        "total_tokens": int(last_usage.get("total_tokens", 0)),
    }


def detect_agent(headers: Mapping[str, Any] | None) -> str:
    explicit = _header_get(headers, "X-Agent-Name")
    if explicit and explicit.strip():
        return _truncate(explicit.strip()) or "unknown"

    user_agent = (_header_get(headers, "User-Agent") or "").lower()
    if "opencode" in user_agent:
        return "opencode"
    if "claude" in user_agent:
        return "claude-code"
    if "github-copilot" in user_agent or "copilot" in user_agent:
        return "copilot-chat"
    return "unknown"


def extract_headers(headers: Mapping[str, Any] | None) -> dict[str, str | None]:
    return {
        "project": _truncate(_header_get(headers, "X-Project")),
        "phase": _truncate(_header_get(headers, "X-Phase")),
        "session_id": _truncate(_header_get(headers, "X-Session-ID")),
        "request_id": _truncate(_header_get(headers, "X-Request-Id")),
    }


def _safe_response_json(flow: Any) -> Mapping[str, Any] | None:
    response = getattr(flow, "response", None)
    if response is None:
        return None
    parser = getattr(response, "json", None)
    if not callable(parser):
        return None
    try:
        data = parser()
    except Exception:  # noqa: BLE001
        return None
    return data if isinstance(data, Mapping) else None


def _calculate_duration_ms(flow: Any) -> int | None:
    request = getattr(flow, "request", None)
    response = getattr(flow, "response", None)
    start = getattr(request, "timestamp_start", None)
    end = getattr(response, "timestamp_end", None)
    if start is None or end is None:
        return None
    return max(0, int((float(end) - float(start)) * 1000))


class TokenMonitorAddon:
    def __init__(self, db_path: str | Path = DEFAULT_DB_PATH, filter_hosts: list[str] | None = None):
        self.db_path = Path(db_path).expanduser()
        self.filter_hosts = [h.lower() for h in (filter_hosts or []) if h]
        self.conn = storage.init_db(self.db_path)
        self.sse_buffers: dict[str, list[bytes]] = {}

    def _host_matches(self, flow: Any) -> bool:
        if not self.filter_hosts:
            return True
        request = getattr(flow, "request", None)
        host = (
            getattr(request, "pretty_host", None)
            or getattr(request, "host", None)
            or ""
        )
        host_lower = str(host).lower()
        return any(pattern in host_lower for pattern in self.filter_hosts)

    def responseheaders(self, flow: Any) -> None:
        if not self._host_matches(flow):
            return

        content_type = (_header_get(getattr(flow.response, "headers", {}), "Content-Type") or "").lower()
        if "text/event-stream" in content_type:
            self.sse_buffers.setdefault(str(flow.id), [])

    def response(self, flow: Any) -> None:
        if not self._host_matches(flow):
            return

        response_headers = getattr(flow.response, "headers", {})
        content_type = (_header_get(response_headers, "Content-Type") or "").lower()
        flow_id = str(getattr(flow, "id", ""))

        usage: dict[str, int] | None = None
        if flow_id in self.sse_buffers or "text/event-stream" in content_type:
            body = getattr(flow.response, "content", b"") or b""
            if isinstance(body, str):
                body = body.encode("utf-8")
            self.sse_buffers.setdefault(flow_id, []).append(body)
            chunks = self.sse_buffers.pop(flow_id, [])
            usage = extract_sse_usage(chunks)
        else:
            usage = extract_usage(_safe_response_json(flow) or getattr(flow.response, "content", b""))

        if not usage:
            return

        request_headers = getattr(flow.request, "headers", {})
        req_meta = extract_headers(request_headers)
        res_meta = extract_headers(response_headers)
        model_raw = (_safe_response_json(flow) or {}).get("model")
        model = _truncate(str(model_raw)) if model_raw is not None else None
        endpoint = _truncate(
            getattr(flow.request, "pretty_host", None) or getattr(flow.request, "host", None)
        )

        event = {
            "ts": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
            "agent": _truncate(detect_agent(request_headers)),
            "model": model,
            "endpoint": endpoint,
            "prompt_tokens": usage["prompt_tokens"],
            "completion_tokens": usage["completion_tokens"],
            "total_tokens": usage["total_tokens"],
            "session_id": req_meta["session_id"] or res_meta["session_id"],
            "request_id": res_meta["request_id"] or req_meta["request_id"],
            "duration_ms": _calculate_duration_ms(flow),
            "status_code": getattr(flow.response, "status_code", None),
            "project": req_meta["project"] or res_meta["project"],
            "phase": req_meta["phase"] or res_meta["phase"],
        }

        try:
            storage.insert_event(self.conn, event)
        except Exception:  # noqa: BLE001
            LOGGER.exception("Failed to persist token event")

    def done(self) -> None:
        try:
            self.conn.close()
        except Exception:  # noqa: BLE001
            LOGGER.exception("Failed to close database connection")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Token monitor mitmproxy addon")
    parser.add_argument("--port", type=int, default=8080, help="Proxy listen port (for mitmdump invocation)")
    parser.add_argument("--db-path", type=Path, default=DEFAULT_DB_PATH, help="SQLite database path")
    parser.add_argument(
        "--filter-host",
        action="append",
        default=[],
        help="Repeatable host substring filter. If omitted, all hosts are inspected.",
    )
    return parser


def _parse_script_args(argv: list[str] | None = None) -> argparse.Namespace:
    return build_parser().parse_args(argv)


def create_addon_from_argv(argv: list[str] | None = None) -> TokenMonitorAddon:
    args = _parse_script_args(argv)
    return TokenMonitorAddon(db_path=args.db_path, filter_hosts=args.filter_host)


addons: list[TokenMonitorAddon] = []


def main(argv: list[str] | None = None) -> int:
    parsed = _parse_script_args(argv)
    if "--" in sys.argv and "mitmdump" in Path(sys.argv[0]).name.lower():
        passthrough_args = sys.argv[sys.argv.index("--") + 1 :]
        addons.clear()
        addons.append(create_addon_from_argv(passthrough_args))
        return 0

    print(
        "Run with: mitmdump -s token_monitor.py -- "
        f"--port {parsed.port} --db-path {Path(parsed.db_path).expanduser()}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
