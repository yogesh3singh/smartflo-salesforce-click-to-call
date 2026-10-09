# Security model

## Threats and controls
| Threat | Control |
|---|---|
| A rep reads or exports phone numbers | Field-level security removes the raw field; lists, reports and exports use a masked formula |
| A rep calls a record they cannot access | User-mode query on the record before anything else |
| Credentials leak | Stored in an External Credential, entered by hand per org, never in code or the repo |
| The token leaks | Cached server-side only, one-hour lifetime |
| A stranger posts fake call events | Public endpoint requires a secret header; hashes compared; fails closed |
| Guest user abuse | No object permissions; the handler writes in system mode and validates everything |
| Stored HTML injection from webhook text | Values are HTML-escaped before being written to a rich text field |
| A call recording link is shared | Link stored in an admin-only field, never in the summary |
| Duplicate paid calls | Server-side double-click guard |
| Phone number guessing through search | The phone is deliberately not searchable in the list component |

## Lessons about masking
- A formula field shows its value even if the user cannot read the field it references. Every formula, report, flow or layout that referenced the raw number had to be moved to the masked field.
- Stored raw webhook JSON can contain numbers and tokens. The call log does not store it.

## Access by persona
| Persona | Can |
|---|---|
| Caller (internal) | See the masked number, start a call |
| Partner caller | Same, on the Experience Cloud site |
| Dialer team | Maintain agent numbers only |
| Admin | See raw numbers and recording links, configure the integration |
