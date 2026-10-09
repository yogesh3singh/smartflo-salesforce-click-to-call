# Lessons learned (real problems and fixes)

| Problem | Cause | Fix and takeaway |
|---|---|---|
| Postman failed with a DNS error naming `{{base_url}}` | The environment variable was missing, so the literal text was sent | Check resolved variables first; keep environment and collection separate |
| Docs said custom data values must be alphanumeric, but my business id had spaces and hyphens | An undocumented top-level echo happened to work in testing | Send the record Id (valid and stable); do not depend on undocumented behaviour |
| Webhook payloads differed from the docs | Keys had no `$`, one key had a trailing space, numbers were strings, time had no zone | Capture real payloads first; parse defensively; convert IST in Apex |
| Same call status text meant different triggers | The vendor labels do not always match the trigger | Classify with ranks and fallbacks; confirm with real payloads |
| Formula field deploy failed on a length element | Formula text fields cannot declare a length | Read the metadata rules; test deploys in layers |
| A test failed writing a field | The field was a formula or auto-number | Let the platform generate it; do not set it in test data |
| Tests failed with "uncommitted work pending" | Test data DML ran before a callout | Commit data in a setup method, wrap the callout between start and stop of the test |
| The list screen broke after a field rename, though it compiled | A dynamic query string is not checked by the compiler | Search all strings after a rename; test every screen |
| Orphan call records appeared with raw JSON | The webhook URL still pointed at an older generic endpoint | Verify the URL path; give each integration its own endpoint |
| Masked numbers were still visible on an activity | A formula field referenced the raw phone | Audit every formula, report and layout that touches a hidden field |
| Agent not found though data looked right | The method still read an older field | Redeploy after edits, and grep the deployed code for the method |
