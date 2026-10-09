# Architecture

## Components
| Component | Responsibility |
|---|---|
| Record-page LWC and list LWC | Show the masked number and call Apex on click. Work on Lightning and Experience Cloud. |
| Apex controller | The only class the LWCs call. Returns masked values, never a raw number. |
| Dial service | Access check, double-click guard, callout, then DML (a callout cannot follow uncommitted DML). |
| Token service | Logs in through the External Credential, caches the token for 3300 s, retries once if the vendor rejects it. |
| Agent lookup | Finds the current user's telephony agent number. Runs without sharing so reps need no access to the source records. |
| Webhook receiver | Public REST endpoint. Checks the secret header, parses JSON, answers fast. |
| Event handler | Classifies the event, applies the rank guard, upserts the call log. |
| Activity view | Writes an event name and an escaped HTML summary that omits phone number and recording link. |

## Matching a call to a record
1. The call request carries `custom_identifier` with the record Id and the user Id (alphanumeric, so it is valid).
2. The vendor returns a unique `ref_id`. It is stored on the call log immediately.
3. Each webhook is matched on `ref_id`. If the log does not exist yet (the webhook won the race), the record Id from `custom_identifier` finds the record.
4. Anything else is ignored with HTTP 200 (calls made outside Salesforce), so the vendor does not retry.

Phone and owner are never used, because they are identical across a lead's records.

## Event ranking
| Event | Status | Rank |
|---|---|---|
| Call accepted | Initiated | 10 |
| Agent answered | Agent Answered | 30 |
| Customer answered | Customer Answered | 50 |
| Missed trigger | Missed by Customer | 90 |
| Hangup | Completed / Missed by Agent / Missed by Customer | 95 |

An event is applied only if its rank is equal to or higher than the stored one. Replays rewrite identical values; a late older event is ignored. Concurrent inserts for one `ref_id` hit a unique external-id constraint and retry once as an update.

## Data model (generalized)
- **Call log** (activity object): unique external id for `ref_id`, vendor call id, status, last event rank, start/answer/end times, duration and talk time, agent number, hangup reason, restricted recording link, initiating user, event name and HTML summary.
- **Opportunity**: raw phone (hidden by field-level security) and a masked formula field.
- **Agent mapping record per user**: the telephony agent number. Maintained by the dialer team. It holds no passwords.
- **Config metadata record**: webhook secret, default caller id, optional call length limit. Created by hand in each org and never deployed.

## Time and data quirks handled
- Timestamps arrive in India Standard Time with no zone; they are converted to UTC in Apex.
- Numbers arrive as strings in some triggers and numbers in others.
- One payload key arrives with a trailing space; keys are normalized.
