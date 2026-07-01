# Security Guideline Catalog

Initial compact catalog for SDD security applicability and security design phases.

## Snapshot Metadata

| Field | Value |
| --- | --- |
| Snapshot ID | `security-guidelines-initial-user-snapshot-2026-06-30` |
| Source | Initial in-repo snapshot from user-provided corporate security guideline text |
| Status | Bootstrap catalog for SDD workflow automation |
| Scope | Security-impact classification, control mapping, evidence planning, verification, and archive gates |
| Migration note | This file can later migrate to an official external versioned source. Preserve this snapshot ID and guideline IDs in archived evidence for audit continuity. |

## Taxonomy

Use these compact category IDs in `security-applicability.md`, `security-design.md`, task evidence, verification reports, and archive blockers.

| Category ID | Category | Applies when a change touches |
| --- | --- | --- |
| `authentication` | Authentication | Login, identity proofing, credential validation, MFA, impersonation, account recovery |
| `sessions` | Sessions | Cookies, tokens, refresh flows, session lifetime, revocation, fixation prevention |
| `sensitive-data-pan` | Sensitive data or PAN | PAN, PCI data, PII, confidential data, masking, retention, transmission, storage |
| `secrets` | Secrets | API keys, passwords, certificates, tokens, encryption keys, secret rotation |
| `permissions-access-control` | Permissions or access control | Roles, ownership checks, authorization decisions, privilege boundaries |
| `files` | Files | Uploads, downloads, generated files, path handling, file metadata, content validation |
| `database-access` | Database access | Queries, migrations, persistence, tenant isolation, data access paths |
| `sensitive-logging` | Sensitive logging | Logs, traces, metrics, analytics, error reporting, audit trails containing sensitive context |

## Guideline Records

Each guideline has a stable ID. Do not rename IDs after archive evidence exists; add a replacement guideline and mark the old one superseded in audit notes instead.

| ID | Category | Mandatory when applicable | Source summary | Expected evidence | Audit notes |
| --- | --- | --- | --- | --- | --- |
| `SEC-AUTH-001` | `authentication` | Yes | Authentication changes must preserve trustworthy identity verification and protect credential-handling boundaries. | Design control for auth flow; implementation refs; negative/abuse test or manual review evidence; verification note. | Map all login, recovery, MFA, impersonation, and credential validation changes. |
| `SEC-SESS-001` | `sessions` | Yes | Session and token changes must define secure lifetime, revocation, renewal, storage, and fixation protections. | Design control for session lifecycle; cookie/token attribute evidence; test-design coverage or justified static/manual check. | Applies to browser cookies, bearer tokens, refresh tokens, and server-side sessions. |
| `SEC-DATA-001` | `sensitive-data-pan` | Yes | Sensitive data, including PAN, must be minimized, protected in transit/storage, masked when displayed, and retained only as required. | Data-flow summary; masking/encryption control; implementation refs; verification or manual review evidence. | Treat unknown data sensitivity as a design-changing unknown during applicability. |
| `SEC-SECRET-001` | `secrets` | Yes | Secrets must not be hardcoded, logged, committed, or exposed to clients; storage and rotation expectations must be explicit. | Secret source/config reference; no-hardcode evidence; redaction/logging check; rotation or owner note. | Applies to credentials, API keys, certificates, tokens, and cryptographic keys. |
| `SEC-ACCESS-001` | `permissions-access-control` | Yes | Authorization must enforce least privilege, ownership boundaries, and denial-by-default behavior for protected resources. | Access-control design matrix; implementation refs; positive and negative permission checks or manual evidence. | Applies to role changes, ownership checks, tenant boundaries, and admin operations. |
| `SEC-FILE-001` | `files` | Yes | File handling must validate type, size, names/paths, storage location, malware-risk controls, and download authorization. | File-flow design; validation controls; path traversal/authorization evidence; manual or automated check. | Applies to uploads, downloads, generated exports, and filesystem paths. |
| `SEC-DB-001` | `database-access` | Yes | Database access must use safe query patterns, preserve tenant/ownership isolation, and avoid unintended data exposure. | Query/access design; implementation refs; injection/isolation check evidence; migration review when relevant. | Applies to raw SQL, ORM filters, migrations, reporting, and background jobs. |
| `SEC-LOG-001` | `sensitive-logging` | Yes | Logs, traces, metrics, and error reports must not expose secrets, PAN, credentials, or unnecessary sensitive data. | Logging inventory; redaction/masking control; implementation refs; verification or manual review evidence. | Applies to new logs and changed observability/error handling paths. |

## Expected Evidence Model

Security design should turn each applicable guideline into one or more evidence obligations:

- `design-control`: architecture or data-flow decision that satisfies the guideline.
- `implementation-reference`: file, function, config, or prompt change where the control is implemented.
- `test-design-check`: planned automated, static, or manual check in `test-design.md`.
- `verification-evidence`: result recorded by `sdd-verify`.
- `approved-exception`: explicit risk acceptance when mandatory evidence cannot be produced.

Mandatory applicable guidelines block archive unless evidence is complete or an approved exception follows `skills/_shared/sdd-security-contract.md`.
