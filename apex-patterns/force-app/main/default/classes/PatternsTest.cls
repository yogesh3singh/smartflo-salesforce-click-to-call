@IsTest
private class PatternsTest {

    @IsTest static void masksAllButLastTwoDigits() {
        System.assertEquals('XXXXXXXX90', PhoneMask.mask('1234567890'));
        System.assertEquals('XXXXXXXXXX04', PhoneMask.mask('+91 12345-67804'));
        System.assertEquals('', PhoneMask.mask(null));
        System.assertEquals('1234567890', PhoneMask.normalizeDestination('01234567890'));
    }

    @IsTest static void normalizesMessyPayloads() {
        Map<String, Object> n = PayloadUtil.normalize(new Map<String, Object>{ 'Customer_No ' => '1', '$Ref_Id' => 'x' });
        System.assert(n.containsKey('customer_no'));
        System.assert(n.containsKey('ref_id'));
        System.assertEquals(16, PayloadUtil.toInt('16'));
        System.assertEquals(16, PayloadUtil.toInt(16));
        System.assertEquals(null, PayloadUtil.toInt('abc'));
    }

    @IsTest static void convertsIstAndUtc() {
        System.assertEquals(Datetime.newInstanceGmt(2026, 10, 7, 4, 56, 48), PayloadUtil.parseIst('2026-10-07 10:26:48'));
        System.assertEquals(Datetime.newInstanceGmt(2026, 10, 7, 10, 26, 48), PayloadUtil.parseIst('2026-10-07T10:26:48Z'));
        System.assertEquals(null, PayloadUtil.parseIst('garbage'));
    }

    @IsTest static void classifiesEvents() {
        CallEventRanker.Outcome a = CallEventRanker.classify(new Map<String, Object>{ 'call_status' => 'Answered by agent' });
        System.assertEquals('Agent Answered', a.status);
        System.assertEquals(30, a.rank);

        CallEventRanker.Outcome c = CallEventRanker.classify(new Map<String, Object>{ 'call_status' => 'Answered by customer' });
        System.assertEquals('Customer Answered', c.status);

        CallEventRanker.Outcome done = CallEventRanker.classify(new Map<String, Object>{
            'End_Stamp ' => '2026-10-08 10:51:27', 'call_status' => 'answered', 'billsec' => '23',
            'answered_agent' => new Map<String, Object>{ 'id' => '1' }
        });
        System.assertEquals('Completed', done.status);
        System.assertEquals(95, done.rank);

        CallEventRanker.Outcome noAgent = CallEventRanker.classify(new Map<String, Object>{
            'end_stamp' => 'x', 'call_status' => 'missed', 'billsec' => '0', 'answered_agent' => ''
        });
        System.assertEquals('Missed by Agent', noAgent.status);

        CallEventRanker.Outcome noCustomer = CallEventRanker.classify(new Map<String, Object>{
            'end_stamp' => 'x', 'billsec' => '0', 'answered_agent' => new Map<String, Object>{ 'id' => '1' }
        });
        System.assertEquals('Missed by Customer', noCustomer.status);
    }

    @IsTest static void lateOlderEventsAreRejected() {
        System.assert(CallEventRanker.shouldApply(null, 10));
        System.assert(CallEventRanker.shouldApply(30, 50));
        System.assert(CallEventRanker.shouldApply(95, 95), 'a replayed event is harmless');
        System.assert(!CallEventRanker.shouldApply(95, 30), 'late older event must be ignored');
    }

    @IsTest static void webhookAuthFailsClosed() {
        System.assert(!WebhookAuth.isAuthorized(new Map<String, String>{ 'X-Webhook-Token' => 'abc' }, null), 'no secret configured');
        System.assert(!WebhookAuth.isAuthorized(new Map<String, String>(), 'abc'), 'header missing');
        System.assert(!WebhookAuth.isAuthorized(new Map<String, String>{ 'X-Webhook-Token' => 'wrong' }, 'abc'));
        System.assert(WebhookAuth.isAuthorized(new Map<String, String>{ 'X-WEBHOOK-TOKEN' => 'abc' }, 'abc'));
    }

    @IsTest static void tokenCacheNeverThrowsWithoutPartition() {
        TokenCache.write('t');
        String v = TokenCache.read();
        System.assert(v == null || v == 't');
        TokenCache.clear();
    }
}
