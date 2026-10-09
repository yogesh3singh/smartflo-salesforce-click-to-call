/**
 * One shared API token for the whole org, kept in Platform Cache just under its 1-hour lifetime.
 * If the cache partition is missing the code still works: callers simply log in again.
 */
public with sharing class TokenCache {
    private static final String PARTITION = 'local.TelephonyToken';
    private static final String KEY = 'accessToken';
    public static final Integer TTL_SECS = 3300;

    public static String read() {
        try {
            Object v = Cache.Org.getPartition(PARTITION).get(KEY);
            return v == null ? null : String.valueOf(v);
        } catch (Exception e) {
            return null;
        }
    }

    public static void write(String token) {
        try {
            Cache.Org.getPartition(PARTITION).put(KEY, token, TTL_SECS, Cache.Visibility.ALL, false);
        } catch (Exception e) {
            // cache unavailable: next call logs in again
        }
    }

    public static void clear() {
        try {
            Cache.Org.getPartition(PARTITION).remove(KEY);
        } catch (Exception e) {
            // nothing to clear
        }
    }
}
