/**
 * Turns a webhook payload into a call status plus a rank.
 * A stored record only accepts an event whose rank is equal or higher, so duplicates are harmless
 * and a late, older event can never move a finished call backwards.
 */
public with sharing class CallEventRanker {

    public class Outcome {
        public String status;
        public Integer rank;
    }

    public static Outcome classify(Map<String, Object> rawPayload) {
        Map<String, Object> p = PayloadUtil.normalize(rawPayload);
        String callStatus = PayloadUtil.lower(p.get('call_status'));
        Outcome o = new Outcome();

        if (p.containsKey('end_stamp')) {                      // hangup event
            Integer billable = PayloadUtil.toInt(p.get('billsec'));
            Boolean connected = billable != null && billable > 0 && !callStatus.contains('miss');
            o.status = connected ? 'Completed'
                : (isPresent(p.get('answered_agent')) ? 'Missed by Customer' : 'Missed by Agent');
            o.rank = 95;
        } else if (callStatus.contains('miss')) {
            o.status = 'Missed by Customer';
            o.rank = 90;
        } else if (callStatus.contains('customer')) {
            o.status = 'Customer Answered';
            o.rank = 50;
        } else if (callStatus.contains('agent')) {
            o.status = 'Agent Answered';
            o.rank = 30;
        } else if (p.containsKey('answer_agent_number')) {
            o.status = 'Customer Answered';
            o.rank = 50;
        } else {
            o.status = 'Agent Answered';
            o.rank = 30;
        }
        return o;
    }

    public static Boolean shouldApply(Integer storedRank, Integer incomingRank) {
        return storedRank == null || incomingRank >= storedRank;
    }

    private static Boolean isPresent(Object o) {
        if (o == null) {
            return false;
        }
        return o instanceof String ? !String.isBlank((String) o) : true;
    }
}
