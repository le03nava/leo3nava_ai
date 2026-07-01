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

## Full Corporate Guideline Snapshot

This section preserves the initial user-provided corporate guideline text for audit fidelity. Keep the stable source IDs when mapping applicability, controls, evidence, verification, and archive blockers.

### 1. Authentication — aligned to PCI Req 6.5.8, 6.5.10

| Source ID | Lineamiento |
| --- | --- |
| `1.1` | La autenticación deberá realizarse a través del Directorio activo de Femsa Comercio como LDAP alineándose a las políticas ya establecidas. |
| `1.2` | Habilitar la sincronización de password o single sign on. |
| `1.3` | Si su aplicación gestiona un almacén de credenciales, se debe garantizar mecanismos de encriptación robustos. |
| `1.4` | Requerir autorización para todos los recursos y páginas excepto aquellas específicamente clasificadas como públicas. |
| `1.5` | Todos los controles de autenticación deben ser efectuados en un entorno confiable como el servidor. |
| `1.6` | Todos los controles de autenticación deben fallar de una forma segura. |
| `1.7` | Las respuestas a los fallos en la autenticación no deben indicar cual parte de la autenticación fue incorrecta, solo deberá proporcionar respuestas genéricas. |
| `1.8` | Utilizar únicamente peticiones del tipo HTTP(S) POST para la transmisión de credenciales de autenticación. |
| `1.9` | Re autenticar usuarios antes de la realización de operaciones críticas. |
| `1.10` | Verificar la aplicabilidad de implementación para los patrones de diseño seguro Secure Factory, Secure Strategy Factory, Secure Builder, Secure Chain of Responsibility, Secure State Machine, Single Sign On establecidos en el documento de patrones de diseño seguro en las secciones 2 y 4.1. |

### 2. Passwords — aligned to PCI Req 6.3.1

| Source ID | Lineamiento |
| --- | --- |
| `2.1` | No deberá haber contraseñas en el código de la aplicación en cuestión. |
| `2.2` | Habilitar la encripción de contraseñas. |
| `2.3` | La contraseña NO deberá ser derivada del id de usuario. |
| `2.4` | La configuración de la contraseña deberá alinearse a las políticas vigentes de OXXO. |
| `2.5` | Todas las contraseñas predeterminadas deberán ser cambiadas o deshabilitadas. |
| `2.6` | El hash de las contraseñas debe ser implementado en un entorno confiable como el servidor. |
| `2.7` | Utilizar únicamente conexiones encriptadas o datos encriptados para el envío de contraseñas que no sean temporales. |
| `2.8` | Hacer cumplir por medio de la política de Grupo FEMSA los requerimientos de complejidad y longitud de la contraseña. |
| `2.9` | No se debe desplegar en la pantalla la contraseña ingresada. |
| `2.10` | Notificar a los usuarios cada vez que se produce un cambio o solicitud de cambio de una contraseña. |
| `2.11` | Prevenir la reutilización de contraseñas. |
| `2.12` | Deshabilitar la funcionalidad de recordar campos de contraseñas. |
| `2.13` | Habilitar pantalla o ventana de registro del usuario. |
| `2.14` | La contraseña deberá generarse de manera aleatoria siguiendo el estándar de seguridad. |
| `2.15` | Habilitar que solo el usuario debe tener acceso a su contraseña. |
| `2.16` | Las contraseñas temporales deberán tener un tiempo de expiración corto, determinado por la política o estándar de contraseñas. |
| `2.17` | Cuando la contraseña haya sido generada por el administrador, el usuario deberá ser forzado a cambiar su contraseña al momento de autenticarse por primera vez al sistema. |
| `2.18` | Si es habilitado el cambio de contraseña para el usuario, esta deberá ser enviada a su correo electrónico, sin incluirse el nombre de usuario en el correo. |
| `2.19` | El cambio de contraseña deberá ser notificado al usuario vía correo electrónico. |
| `2.20` | La contraseña deberá estar enmascarada. |
| `2.21` | Incluir leyenda de responsabilidad del usuario para el buen manejo de su cuenta. |
| `2.22` | La cuenta deberá bloquearse después de 5 intentos fallidos de autentificarse en m cantidad de tiempo. |
| `2.23` | Si se restablece el uso basado de correo electrónico, solo se envía un correo electrónico a una dirección previamente registrada con un enlace / contraseña temporal. |

### 3. Access and Activity Logging

| Source ID | Lineamiento |
| --- | --- |
| `3.1` | Habilitar el registro de acceso de usuario, incluida fecha y hora de la autenticación. |
| `3.2` | Habilitar el registro de transacciones (actividades relevantes) efectuadas por el usuario. |
| `3.3` | Habilitar el registro de la IP desde la cual se registró la actividad. |
| `3.4` | Habilitar el registro de intentos fallidos de Login. |
| `3.5` | Habilitar el registro por cambio de contraseña. |
| `3.6` | Habilitar el registro de reenvío de contraseña. |
| `3.7` | Habilitar el registro de errores y excepciones. No necesariamente deben ser mostrados al usuario. |
| `3.8` | Habilitar el registro en caso de cambio de los mecanismos de identificación y autenticación incluidos la creación de cuentas y aumento de privilegios y de todos los cambios, incorporaciones y eliminaciones de las cuentas con privilegios administrativos o de root. |
| `3.9` | Utilizar una rutina o componente centralizada para todas las operaciones de logging. |
| `3.10` | No guardar información clasificada por OXXO como privilegiada, restringida o confidencial, en los registros, incluyendo detalles innecesarios del sistema. |
| `3.11` | Utilizar una función de hash para validar la integridad de los archivos de registro. |

### 4. Cryptography — aligned to PCI Req 6 - 6.5.3

| Source ID | Lineamiento |
| --- | --- |
| `4.1` | En caso de recopilar, almacenar, transferir información tipificada como sensible, deberá encriptarse y enmascararse. Entiéndase por información sensible: datos personales, patrimoniales o datos de tarjeta de débito y crédito. En los casos en que esta información sea de tarjetas de crédito deberán cumplirse con las medidas de seguridad que dicta la regulación PCI. |
| `4.2` | La información no debe guardarse en texto plano en los archivos de configuración del desarrollo. |
| `4.3` | La pantalla de autenticación siempre deberá estar encriptada. |
| `4.4` | En caso de aplicaciones publicadas a la red externa, estas deberán tener un certificado de seguridad. |
| `4.5` | Todas las funciones de criptografía de la aplicación deben ser implementadas en entornos confiables (servidor). |
| `4.6` | Los módulos de criptografía deberían, en caso de falla, fallar en forma segura. |
| `4.7` | Todos los números aleatorios, nombres aleatorios, GUIDs y frases aleatorias deberían generarse utilizando módulos aprobados para su generación. |
| `4.8` | Establecer y utilizar una política y un proceso de cómo manejar las claves criptográficas. |

### 5. Databases

| Source ID | Lineamiento |
| --- | --- |
| `5.1` | Establecer roles a fin de segregar acceso y funciones. |
| `5.2` | Habilitar Parametrized Stored Procedures para acceder a las bases de datos. |
| `5.3` | Restringir el ingreso directo a los objetos de las bases de datos habilitando listas de accesos, triggers o grants. |
| `5.4` | Deshabilitar consultas dinámicas a través de Parametrized Stored Procedures. |
| `5.5` | No debe existir información de conexión a la base de datos (“connection strings”) dentro del código de la aplicación. |
| `5.6` | Cerrar las conexiones a la base de datos tan pronto sea posible, con la función close del lenguaje utilizado. |
| `5.7` | Cambiar o deshabilitar las contraseñas predeterminadas. |
| `5.8` | Configurar contraseñas seguras para las bases de datos, con base en las mejores prácticas. |
| `5.9` | Deshabilitar todas las funcionalidades innecesarias de la base de datos. |
| `5.10` | La aplicación deberá conectarse a la base de datos con credenciales diferentes para cada nivel de confianza. |
| `5.11` | Eliminar el contenido innecesario incluido por el proveedor. |
| `5.12` | Utilizar validación de las entradas y codificación de las salidas y manejar caracteres especiales. Si esto falla, no ejecutar el comando de la base de datos. |

### 6. Coding — aligned to PCI Req 6.5.8, 6.5.9

| Source ID | Lineamiento |
| --- | --- |
| `6.1` | No deben usar parámetros de configuración expuestos dentro del código (servidores, usuarios, contraseñas). Es preferible usar archivos de configuración encriptados. |
| `6.2` | Deshabilitar conexiones directas al URL de la misma de manera anónima o con un usuario sin privilegios para su funcionalidad. |
| `6.3` | Las direcciones web no podrán ser llamadas de manera directa si no se ha comprobado que el usuario esté autenticado y tenga privilegios para acceder a esa página. |
| `6.4` | No se deben exponer referencias manipulables a objetos internos sin validar como parámetros de forma o URLs. |
| `6.5` | Verificar el cumplimiento del código con base en el estándar definido para la plataforma en la que fue desarrollado. |
| `6.6` | Todas las validaciones fallidas deberán ser rechazadas. |
| `6.7` | Habilitar la validación de datos desde redirects o redirecciones. |
| `6.8` | Establecer mecanismos que eviten la inyección de código no autorizado o malicioso. |
| `6.9` | Utilizar locks para evitar múltiples accesos simultáneos a los recursos o mecanismos de sincronización. |
| `6.10` | Proteger las variables y recursos compartidos de accesos concurrentes inadecuados. |
| `6.11` | Inicializar explícitamente todas las variables y mecanismos de almacenamiento de información durante su declaración o antes de usarlos por primera vez. |
| `6.12` | Las aplicaciones que requieran privilegios especiales deberán elevar privilegios solo cuando sea necesario y devolverlos lo antes posible. |
| `6.13` | Implementar mecanismos seguros para actualizaciones; si hay actualizaciones automáticas, utilizar firmas criptográficas y verificar dichas firmas. |
| `6.14` | Revisar por un agente externo al equipo de desarrollo el código, en busca de vulnerabilidades de seguridad. |

### 7. Session Management — aligned to PCI Req 6.5.9, 6.5.10

| Source ID | Lineamiento |
| --- | --- |
| `7.1` | Implementar controles de administración de sesiones y con AC. |
| `7.2` | Terminar la sesión o la conexión completamente al recibir una función de logout. |
| `7.3` | Establecer un timeout de sesión debido a inactividad en un tiempo razonablemente corto. |
| `7.4` | Generar un nuevo identificador de sesión con cada re-autenticación. |
| `7.5` | No permitir logins concurrentes con el mismo ID de usuario. |
| `7.6` | No exponer identificadores de sesión en URLs, mensajes de error o logs, ni pasarlos como parámetros en una petición GET. |
| `7.7` | Generar un nuevo identificador de sesión si la conexión cambia de HTTP a HTTPS durante la autenticación. |
| `7.8` | La creación de identificadores de sesión solo debe ser realizada en un entorno seguro como el servidor. |
| `7.9` | Los controles de administración de sesiones deben utilizar algoritmos que generen identificadores aleatorios. |
| `7.10` | La función de logout debe estar disponible en todas las páginas protegidas por autenticación. |
| `7.11` | Si una sesión fue establecida antes del login, cerrar dicha sesión y establecer una nueva luego de un login exitoso. |
| `7.12` | Configurar el atributo seguro para cookies transmitidas sobre una conexión TLS o SSL. |
| `7.13` | Configurar cookies con atributo HttpOnly, salvo que scripts del cliente requieran leer o configurar una cookie. |

### 8. Error Handling — aligned to PCI Req 6.3.c, 6.5.5

| Source ID | Lineamiento |
| --- | --- |
| `8.1` | Implementar pantallas/mensajes de error que brinden información genérica y no información del sistema. |
| `8.2` | Bloquear el almacenamiento de información privilegiada, restringida o confidencial en los registros. |
| `8.3` | La aplicación debería manejar los errores de la aplicación y basarse en la configuración del servidor. |
| `8.4` | Liberar espacio de memoria en cuanto una condición de error ocurra. |
| `8.5` | Verificar el cumplimiento del patrón de diseño seguro Secure Logger establecido en el documento de patrones de diseño sección 3.1. |

### 9. File Handling — aligned to PCI Req 6.5.8

| Source ID | Lineamiento |
| --- | --- |
| `9.1` | Considerar que los archivos deben ser autenticados antes de que sean tomados o cargados. |
| `9.2` | Los archivos deberán guardarse en un servidor/carpeta de contenidos o en la base de datos, no en la misma aplicación. |
| `9.3` | Restringir la carga de cualquier archivo que pueda ser interpretado por el servidor web. |
| `9.4` | Deshabilitar los permisos de ejecución en los directorios donde se guardarán los archivos cargados. |
| `9.5` | No pasar al usuario rutas absolutas o relativas de archivos o directorios. |
| `9.6` | Asegurar que los archivos y recursos a subir sean de solo lectura; rechazar ejecutables. |
| `9.7` | De ser posible, escanear archivos en busca de código malicioso. |
| `9.8` | No incluir en parámetros nombres de directorios o rutas de archivos; utilizar índices asociados internamente a rutas predefinidas. |
| `9.9` | Cuando se referencie a un archivo existente en el servidor, utilizar lista blanca de nombres y extensiones válidas. |
| `9.10` | No utilizar información provista por el usuario para redirecciones dinámicas; si se requiere, aceptar únicamente caminos relativos previamente establecidos. |
| `9.11` | Validar tipos de archivo verificando la estructura de encabezados; validar solo por extensión no es suficiente. |
| `9.12` | Verificar cumplimiento de los patrones Secure Directory y Pathname Canonicalization. |

### 10. Memory Management — aligned to PCI Req 6.5.1

| Source ID | Lineamiento |
| --- | --- |
| `10.1` | Al usar funciones que aceptan bytes a copiar como strncpy(), asegurar que el buffer destino es suficientemente largo. |
| `10.2` | Validar límites del buffer al llamar una función dentro de una iteración y evitar escribir más allá del espacio reservado. |
| `10.3` | Eliminar recursos explícitamente; no confiar únicamente en garbage collection. |
| `10.4` | Truncar el largo de todos los strings de entrada a un tamaño parametrizable antes de pasarlos a una función de copia o concatenación. |
| `10.5` | Liberar la memoria previa a la salida de una función y de todos los puntos de finalización de la aplicación. |
| `10.6` | Verificar cumplimiento de RAII y Clear Sensitive Information. |

### 11. Input Validation — aligned to PCI Req 6.5.1, 6.5.7, 6.5.8, 6.5.9

| Source ID | Lineamiento |
| --- | --- |
| `11.1` | Habilitar validación de datos de entrada: fuente, clasificación, longitud, características, caracteres especiales, etc. |
| `11.2` | Habilitar el redireccionamiento de datos considerando que un atacante puede eludir validaciones previas. |
| `11.3` | Deberá existir una función o componente de validación de datos de entrada centralizado para la aplicación. |
| `11.4` | Especificar sets de caracteres apropiados, tales como UTF-8, para todas las fuentes de entrada. |
| `11.5` | Codificar los datos a un set de caracteres común antes de validar (canonización). |
| `11.6` | Todas las fallas en la validación deben terminar en el rechazo del dato de entrada. |
| `11.7` | Determinar si el sistema soportará UTF-8 extendido y validarlo luego de la decodificación. |
| `11.8` | Validar todos los datos del cliente antes de procesarlos, incluyendo parámetros, URLs y cabeceras HTTP. |
| `11.9` | Verificar que los valores de cabecera en solicitudes y respuestas contengan solo caracteres ASCII. |
| `11.10` | Identificar todas las fuentes de datos y clasificarlas como confiables o no confiables; validar fuentes no confiables. |
| `11.11` | Validar toda entrada con una lista blanca de caracteres aceptados. |
| `11.12` | Si se permite un carácter peligroso, implementar controles adicionales como codificación de salida y registro de uso. |
| `11.13` | Comprobar bytes nulos (%00). |
| `11.14` | Comprobar caracteres de nueva línea (%0d, %0a, \r, \n). |
| `11.15` | Comprobar alteraciones de ruta como ../ o ..\ y representaciones UTF-8 alternativas mediante canonización. |
| `11.16` | Verificar cumplimiento del patrón Input Validation. |

### 12. Output Encoding — aligned to PCI Req 6.5.9

| Source ID | Lineamiento |
| --- | --- |
| `12.1` | Homologar y estandarizar datos de salida. |
| `12.2` | Habilitar sanitización de salidas no confiables a comandos del sistema operativo y consultas SQL, XML y LDAP. |
| `12.3` | Contextualizar la codificación de salida de todos los datos devueltos por el cliente que se originen fuera de la frontera de confianza. |
| `12.4` | Codificar todos los caracteres salvo que sean reconocidos como seguros por el interpretador al que están destinados. |
| `12.5` | Realizar toda la codificación en un ambiente seguro, por ejemplo el servidor. |

### 13. Data Protection — aligned to PCI Req 6.3.c, 6.5.4

| Source ID | Lineamiento |
| --- | --- |
| `13.1` | Implementar mínimo privilegio, restringiendo acceso a funcionalidad, datos y sistemas necesarios para las tareas del usuario. |
| `13.2` | Proteger almacenamientos temporales de datos sensibles y eliminar archivos/memoria temporal tan pronto como no sean requeridos. |
| `13.3` | Encriptar toda la información altamente sensible almacenada, como datos para verificación de autenticación. |
| `13.4` | Proteger el código fuente del servidor para que no pueda ser descargado por el usuario. |
| `13.5` | No almacenar contraseñas, cadenas de conexión u otra información privilegiada, restringida o confidencial en texto claro. |
| `13.6` | Remover comentarios en código de producción accesible por el usuario que puedan revelar información sensible o del servidor. |
| `13.7` | Remover aplicaciones y documentación innecesarias que puedan revelar información útil para atacantes. |
| `13.8` | No incluir información privilegiada, restringida o confidencial en parámetros HTTP GET. |
| `13.9` | Deshabilitar autocompletar en formularios con información privilegiada, restringida o confidencial, incluyendo autenticación. |

### 14. Access Control

| Source ID | Lineamiento |
| --- | --- |
| `14.1` | Utilizar únicamente objetos confiables del sistema para decisiones de autorización. |
| `14.2` | Utilizar un único componente para verificar autorizaciones en todo el sitio. |
| `14.3` | Los controles de acceso, en caso de falla, deben fallar en forma segura. |
| `14.4` | Denegar todos los accesos si la aplicación no puede acceder a la configuración de seguridad. |
| `14.5` | Requerir controles de autorización en cada solicitud o pedido, incluyendo scripts del servidor, includes y AJAX. |
| `14.6` | Separar lógica privilegiada de otro código de la aplicación. |
| `14.7` | Restringir acceso a ficheros u otros recursos únicamente a usuarios autorizados. |
| `14.8` | Restringir acceso a URLs protegidas solo a usuarios autorizados. |
| `14.9` | Restringir acceso a servicios solo a usuarios autorizados. |

### 15. PAN — Primary Account Number, aligned to PCI Req 6.4

| Source ID | Lineamiento |
| --- | --- |
| `15.1` | Los datos de producción (PAN activos) no se usan en pruebas ni desarrollo. |
| `15.2` | Los datos y las cuentas de prueba se eliminan antes de que se active el sistema de producción. |

## Expected Evidence Model

Security design should turn each applicable guideline into one or more evidence obligations:

- `design-control`: architecture or data-flow decision that satisfies the guideline.
- `implementation-reference`: file, function, config, or prompt change where the control is implemented.
- `test-design-check`: planned automated, static, or manual check in `test-design.md`.
- `verification-evidence`: result recorded by `sdd-verify`.
- `approved-exception`: explicit risk acceptance when mandatory evidence cannot be produced.

Mandatory applicable guidelines block archive unless evidence is complete or an approved exception follows `skills/_shared/sdd-security-contract.md`.
