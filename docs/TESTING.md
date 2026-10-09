# Testing

## Layers
1. **Unit tests (Apex).** Masking, payload normalization, IST conversion, event classification, the rank guard, webhook authentication and cache resilience. See [apex-patterns/](../apex-patterns/). The full solution also tests the dial service with mocked callouts, access checks, error translation, and the webhook handler against sample payloads.
2. **API tests (Postman).** The [collection](../postman/) has three folders:

| Folder | Proves | Places a real call? |
|---|---|---|
| 1. Smartflo auth | Login and refresh work, token is captured | No |
| 2. Smartflo click-to-call | Request accepted, `ref_id` returned, bad input rejected | **Yes, use your own phones** |
| 3. Salesforce webhook receiver | 401 without or with wrong token, 400 for bad JSON, event ranking, duplicate replay, stale event ignored, unknown call ignored | No |

3. **End-to-end in a sandbox** with real calls as a non-admin user: masked display, call placed, activity created on the correct record, statuses progress, and raw numbers are invisible.

## Run Postman from the command line
```bash
npm install -g newman
newman run postman/Smartflo-Salesforce.postman_collection.json -e my-environment.json
```
Fill your own copy of the environment template. Real values never go in git. Do not run the wrong-password request repeatedly, since failed logins can lock the vendor account.

## Run the Apex pattern tests
```bash
sf project deploy start -d apex-patterns/force-app -o <sandbox-alias>
sf apex run test --class-names PatternsTest --result-format human --wait 10 -o <sandbox-alias>
```

## Manual checklist
- [ ] A non-admin rep sees only a masked number
- [ ] Click Call: the agent's phone rings, then the customer's
- [ ] One call log is created on the clicked record, even when sibling records share phone and owner
- [ ] Status moves Initiated, Agent Answered, Customer Answered, Completed
- [ ] Replaying a webhook creates no duplicate
- [ ] A customer who does not answer and an agent who does not answer give the right statuses
- [ ] Reports, exports, list views and related formulas show no raw number
- [ ] A partner user repeats the above on the Experience Cloud site
