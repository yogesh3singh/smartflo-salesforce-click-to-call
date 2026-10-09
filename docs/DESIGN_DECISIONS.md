# Design decisions

Each entry: context, decision, consequence.

**1. The browser never talks to the telephony API.**
Calling from the browser would expose credentials, cause CORS and CSP trouble, and move masking into client code. *Decision:* LWC calls Apex only. *Consequence:* raw numbers and tokens never leave the server.

**2. One integration login, per-user agent number.**
The API call runs on one account; the `agent_number` field decides whose phone rings. *Decision:* store only agent numbers per user, never personal passwords. *Consequence:* nothing sensitive is stored per user, and rotating the login is one edit in the External Credential.

**3. Token cached in Platform Cache, with a retry.**
Tokens last an hour and every call needs one. *Decision:* cache a single org-wide token for 3300 s and retry once on an auth failure. *Consequence:* far fewer logins; if the cache is missing it still works. The vendor does not invalidate older tokens on a new login, so concurrent logins are safe.

**4. Correlate by record Id sent plus `ref_id` returned.**
Phone and owner are identical across a lead's opportunities. *Decision:* send the record Id in `custom_identifier`, store `ref_id` as a unique external id, match on it. *Consequence:* a call can only land on the record it was started from. I did not rely on an undocumented echo of an extra top-level field, even though it worked in testing.

**5. Rank-guarded idempotent upserts.**
Webhooks can arrive twice, late, or before the API response is saved. *Decision:* every event gets a rank; apply only equal or higher. *Consequence:* safe replays and no status moving backwards.

**6. Authenticated, fail-closed webhook.**
The endpoint has to be public. *Decision:* require a shared-secret header, compare hashes, refuse everything if no secret is configured, give the guest user no object permissions, and do the writes in system mode. *Consequence:* a stranger who finds the URL cannot create or change records.

**7. Masking is server-side, in layers.**
Hiding a value with CSS is not security. *Decision:* remove field-level read access to the raw number, show a masked formula in lists and reports, and read the raw number in Apex only after a user-mode access check. *Consequence:* reports, exports, API access and the UI all show only the mask. Formula fields ignore field-level security on their inputs, so any formula that reads the raw number had to be changed too.

**8. Permission sets per persona.**
*Decision:* caller, partner caller, dialer team, and admin sets, none on a profile. *Consequence:* partners and internal users are managed separately; admins alone see raw numbers and recording links.

**9. Recording link kept out of the display.**
The vendor link embeds an access token. *Decision:* store it in an admin-only field; keep it out of the HTML summary. *Consequence:* no accidental sharing of an authenticated link.

**10. Callout before DML, plus a double-click guard.**
Salesforce blocks a callout after uncommitted DML, and impatient clicks cause duplicate calls. *Decision:* check access, call the API, then write; ignore a repeat click on the same record for 15 seconds. *Consequence:* no duplicate billable calls and no transaction errors.
