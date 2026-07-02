# SDD Review Control Catalog

Stable 96-control corporate code-review checklist used by `sdd-review`. The matrix in `review-report.md` uses the `Item ID` as its `Item` value. The `Source Item` column preserves one-to-one mapping to the user's checklist items 1 through 96 and must not be added as an extra report matrix column.

## Manual Catalog Evidence

| Evidence | Result |
| --- | --- |
| Catalog source | User-provided 96-item corporate code-review checklist source items `1` through `96`. |
| Total controls | 96 rows. |
| Unique Item IDs | 96 unique IDs: `REV-CORP-001..REV-CORP-096`. |
| Source mapping | Each `REV-CORP-NNN` maps one-to-one to source item `N`. |
| Report compatibility | Catalog fields map to the required report matrix columns without adding extra report columns. |
| Security authority | `Standard` may cite secure-coding sources, but this catalog does not replace security applicability/design authority. |

## Catalog

| Item ID | Source Item | Artifact/Deliverable | Requirement | Reviewer | Standard | Severity | Default Complies | Evidence Hint | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| REV-CORP-001 | 1 | Estándares de Nomenclatura | naming standards | Joel Salazar Acosta; Genaro Cacique Peña | Estándar de Diseño y Código WEB | Media | Si | Evidencia 1 |  |
| REV-CORP-002 | 2 | Folder structure | folder structure per platform standard | Joel Salazar Acosta; Genaro Cacique Peña | WEB | Media | Si | Evidencia 5 |  |
| REV-CORP-003 | 3 | Service names | service names comply with area naming standards | Joel Salazar Acosta; Genaro Cacique Peña | WEB | Media | Si | Evidencia 8 |  |
| REV-CORP-004 | 4 | Developer testing | developer tested code/unit use cases | Joel Salazar Acosta; Genaro Cacique Peña | WEB | Mayor | Si | Evidencia 6 |  |
| REV-CORP-005 | 5 | Variable declarations | variable declarations adequately commented; descriptive names may make comments unnecessary | Joel Salazar Acosta; Genaro Cacique Peña | WEB | Mayor | Si | Evidencia 9 | Los nombres de las variables son muy descriptivas, no se ocupan comentar |
| REV-CORP-006 | 6 | Functions, methods, classes | functions, methods, classes documented | Joel Salazar Acosta; Genaro Cacique Peña | WEB | Mayor | Si |  |  |
| REV-CORP-007 | 7 | Complex algorithms and optimizations | complex algorithms and optimizations commented | Joel Salazar Acosta; Genaro Cacique Peña | WEB | Media | N/A |  |  |
| REV-CORP-008 | 8 | Commented-out code | commented-out code has explanation; dead code removed | Joel Salazar Acosta; Genaro Cacique Peña | WEB | Menor | N/A |  |  |
| REV-CORP-009 | 9 | Resources and memory | resources and memory released on all error paths | Joel Salazar Acosta; Genaro Cacique Peña | WEB | Media | N/A |  |  |
| REV-CORP-010 | 10 | Exceptions | exceptions handled appropriately | Joel Salazar Acosta; Genaro Cacique Peña | WEB | Menor | Si | Evidencia 2 | common exception handler |
| REV-CORP-011 | 11 | Error handling tests | error handling tested and includes non-happy-path cases in test script | Joel Salazar Acosta; Genaro Cacique Peña | WEB | Media | Si | Evidencia 7 |  |
| REV-CORP-012 | 12 | DB connections/sockets/files | DB connections/sockets/files released even on error | Joel Salazar Acosta; Genaro Cacique Peña | WEB | Mayor | Si |  | note Spring transactions, only SP modified |
| REV-CORP-013 | 13 | Cache/session result storage | cache/session result storage used appropriately | Joel Salazar Acosta; Genaro Cacique Peña | WEB | Media | N/A |  |  |
| REV-CORP-014 | 14 | Code optimization | code can be optimized | Joel Salazar Acosta; Genaro Cacique Peña | WEB | Menor | Si |  |  |
| REV-CORP-015 | 15 | Error logging | standard error logging used | Joel Salazar Acosta; Genaro Cacique Peña | WEB | Media | Si |  |  |
| REV-CORP-016 | 16 | Common functionality | common functionality encapsulated | Joel Salazar Acosta; Genaro Cacique Peña | WEB | Menor | N/A |  |  |
| REV-CORP-017 | 17 | Reusable component libraries | latest reusable component libraries used (AccessControl, email, employee lookup, etc.) | Joel Salazar Acosta; Genaro Cacique Peña | WEB | Mayor | N/A |  |  |
| REV-CORP-018 | 18 | Portal usability standard | portal usability standard implemented | Joel Salazar Acosta; Genaro Cacique Peña | WEB | Media | Si |  |  |
| REV-CORP-019 | 19 | Code simplicity | code kept simple | Joel Salazar Acosta; Genaro Cacique Peña | Estándar de Codificación Segura | Mayor | Si |  |  |
| REV-CORP-020 | 20 | API design | API designed securely | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  | no new API created |
| REV-CORP-021 | 21 | Duplication | duplication avoided | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | Si |  |  |
| REV-CORP-022 | 22 | Privileges | privileges restricted | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | Si | Evidencia 4 | existing role privileges |
| REV-CORP-023 | 23 | Permission checks | number of permission checks minimized | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-024 | 24 | Encapsulation | encapsulation used | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-025 | 25 | Third-party code | third-party code security validated | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-026 | 26 | Security-related information | security-related information documented | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-027 | 27 | Disproportionate resources | activities that can use disproportionate resources handled carefully | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-028 | 28 | Resources | resources released in all cases | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-029 | 29 | Direct buffers | avoid direct buffers for short-lived/infrequently used objects | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-030 | 30 | Service error/exception handling | robust error/exception handling for services | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | Si | Evidencia 2 | common exception handler |
| REV-CORP-031 | 31 | Resource limit checks | resource limit checks avoid overflow | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-032 | 32 | Exception content | sensitive information removed from exceptions | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-033 | 33 | Logging | highly confidential information not logged | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-034 | 34 | Memory | sensitive information removed from memory | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-035 | 35 | Hardcoded information | confidential information not hardcoded | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-036 | 36 | Format generation | valid format generated | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-037 | 37 | Dynamic SQL | dynamic SQL avoided | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-038 | 38 | XML and HTML generation | XML and HTML generation handled carefully | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-039 | 39 | XML inclusion | XML inclusion restricted | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-040 | 40 | Untrusted code interpretation | untrusted code interpretation handled carefully | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-041 | 41 | Floating-point values | exceptional floating-point value injection avoided | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-042 | 42 | Accessibility and extensibility | accessibility and extensibility standard met | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | Si |  |  |
| REV-CORP-043 | 43 | Package accessibility | package accessibility limited | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | Si |  |  |
| REV-CORP-044 | 44 | Modules | modules used to hide internal packages | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-045 | 45 | ClassLoader exposure | ClassLoader instance exposure limited | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-046 | 46 | Class and method extensibility | class and method extensibility limited | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-047 | 47 | Superclass/subclass behavior | superclass impact on subclass behavior understood | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-048 | 48 | Strings | strings normalized before validation | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-049 | 49 | Path names | path names canonicalized before validation | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-050 | 50 | User input logging | user input not logged without sanitizing first | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-051 | 51 | ZipInputStream extraction | files extracted safely from ZipInputStream | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-052 | 52 | String modifications | string modifications performed before validation | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-053 | 53 | Native methods | wrappers defined around native methods | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-054 | 54 | Hidden form fields | hidden form fields not trusted | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-055 | 55 | Value types | immutability preferred for value types | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-056 | 56 | Mutable output values | copies created for mutable output values | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-057 | 57 | Mutable input values and subclasses | safe copies created for mutable input values and subclasses | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-058 | 58 | Mutable class copy functionality | copy functionality supported for mutable class | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-059 | 59 | Identity equality | identity equality not trusted when input reference objects can override equality | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-060 | 60 | Input to untrusted object | input passed to untrusted object treated as output | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-061 | 61 | Output from untrusted object | output from untrusted object treated as input | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-062 | 62 | Mutable internal state | wrapper methods around mutable internal state defined | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-063 | 63 | Public static fields | public static fields made final | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-064 | 64 | Public static final fields | public static final field values ensured constant | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-065 | 65 | Mutable collections | mutable collections not exposed | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-066 | 66 | Sensitive class constructors | constructors of sensitive classes not exposed | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-067 | 67 | Nested class exposure | private members of outer class not exposed from nested class | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-068 | 68 | Partially initialized instances | defend against partially initialized instances of non-final classes | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-069 | 69 | Constructors | constructors avoid calling overridable methods | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-070 | 70 | Sensitive class copying | sensitive classes cannot be copied | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-071 | 71 | Security-sensitive serialization | serialization avoided for security-sensitive classes | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-072 | 72 | Deserialization | deserialization treated like object construction | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-073 | 73 | Serialization method signatures | do not deviate proper serialization method signatures | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-074 | 74 | Serialization compatibility | serialization compatibility enabled during class evolution | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-075 | 75 | Inner class serialization | instances of inner classes not serialized | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-076 | 76 | Privileged deserialization | privileges minimized before deserializing from privileged context | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-077 | 77 | Serialized data filtering | untrusted serialized data filtered | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-078 | 78 | Permission verification | permission verification understood | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-079 | 79 | Callback methods | callback methods handled carefully | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-080 | 80 | AccessController.doPrivileged | java.security.AccessController.doPrivileged invoked safely | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-081 | 81 | doPrivileged restrictions | privileges restricted through doPrivileged | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-082 | 82 | Cached privileged-operation results | cached results of potentially privileged operations handled carefully | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-083 | 83 | Context transfer | context transfer understood | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-084 | 84 | Thread construction context transfer | thread construction context transfer understood | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-085 | 85 | Caller classloader SecurityManager checks | standard APIs that skip SecurityManager checks based on immediate caller classloader invoked safely | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-086 | 86 | Immediate caller classloader APIs | standard APIs that use immediate caller classloader invoked safely | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-087 | 87 | Immediate caller Java access checks | standard APIs with Java language access checks against immediate caller considered | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-088 | 88 | Method.invoke immediate-call checks | java.lang.reflect.Method.invoke immediate-call check behavior considered | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-089 | 89 | Caller-sensitive interface methods | caller-sensitive method names avoided in interface classes | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-090 | 90 | Privileged operation results | returning privileged operation results avoided | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-091 | 91 | Immediate caller module APIs | standard APIs that perform tasks using immediate caller module invoked safely | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-092 | 92 | InvocationHandlers | InvocationHandlers designed and used conservatively | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-093 | 93 | Tainted variables | tainted variables not allowed in privileged blocks | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-094 | 94 | Reflection accessibility | reflection not used to increase accessibility of classes, methods, or fields | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | N/A |  |  |
| REV-CORP-095 | 95 | log4j versions | secure log4j versions used | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | Si |  | No se modificó, se usa la misma versión ya aprobada. |
| REV-CORP-096 | 96 | Security controls | security controls not based on untrusted sources | Joel Salazar Acosta; Genaro Cacique Peña | Secure Coding | Mayor | Si |  |  |
