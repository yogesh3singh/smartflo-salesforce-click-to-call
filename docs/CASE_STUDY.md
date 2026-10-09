# Case study: masked click-to-call for a sales CRM

## Context
A sales team worked leads in Salesforce and called customers through a cloud telephony provider. Reps saw raw phone numbers and dialed them manually. Management wanted numbers hidden, calling to be one click, and every call recorded against the right opportunity. External partner users, who log in through an Experience Cloud site, needed the same.

## Goals
1. Reps cannot see or export customer phone numbers.
2. One click starts a call from a record or from a list.
3. Each call is logged on the exact opportunity it was started from.
4. Internal and partner users share one solution.
5. No secrets in code, in the browser, or in source control.

## Constraints I had to design around
- The telephony API is **asynchronous**: "accepted" does not mean "answered". Call progress arrives later by webhook.
- The webhook endpoint must be **public**, so it needs its own authentication.
- A lead can have several opportunities with the **same phone and owner**, so neither can identify the right record.
- The vendor's custom data field accepts **alphanumeric values only**, and the internal business id contained spaces and hyphens.
- The vendor's tokens last one hour.
- Partner users have narrower access than internal users.

## Approach
1. **Prove the vendor APIs first, in Postman.** Login, refresh, click-to-call, error cases, and real webhook payloads captured with a throwaway receiver. This turned guesses into facts (key names, types, time zones, where custom data comes back).
2. **Design the correlation key.** Send the record Id with the call, store the vendor's returned `ref_id` immediately, and match every later webhook on it.
3. **Build the server side:** token service, dial service (access check, then callout, then DML), and a controller that returns masked values only.
4. **Build the UI:** one LWC for a record page and one list component with a call button per row, both usable on Lightning and Experience Cloud.
5. **Build the webhook receiver:** authenticated, tolerant of messy payloads, idempotent, order-safe.
6. **Make calls readable:** each call writes an event name and a short HTML summary so it looks like every other activity on the timeline, without the phone number or the recording link.
7. **Test in layers:** unit tests, Postman for contracts and the webhook, then real calls in a sandbox as a non-admin user.

## Outcome
In a sandbox, a non-admin rep clicks Call on a masked record, the agent's phone rings, then the customer's, and a call log is created on that exact opportunity and updated as events arrive. Numbers are masked in the UI paths I built. Remaining work (listed in the README) is the partner-user test, real missed-call payloads, and an automated deployment pipeline.

## What I would do next
- Run the missed-call scenarios and replace assumed status rules with observed ones.
- Add a controlled "play recording" action for team leads, because the vendor link embeds an access token.
- Add a pipeline that validates each pull request against a sandbox.
- Add a scheduled job that closes calls stuck in "Initiated" if a webhook never arrives.

## Skills demonstrated
Salesforce integration architecture, Apex (callouts, REST, caching, DML ordering), Lightning Web Components, Experience Cloud, security design (FLS, sharing, guest users, secrets), defensive API integration, API testing with Postman, unit testing, and technical documentation.
