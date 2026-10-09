/** Shared-secret check for a public webhook endpoint. Fails closed when no secret is configured. */
public with sharing class WebhookAuth {
    public static final String HEADER = 'x-webhook-token';

    public static Boolean isAuthorized(Map<String, String> requestHeaders, String expectedToken) {
        if (String.isBlank(expectedToken) || requestHeaders == null) {
            return false;
        }
        String received = null;
        for (String name : requestHeaders.keySet()) {            // header names are not case-stable
            if (name.toLowerCase() == HEADER) {
                received = requestHeaders.get(name);
            }
        }
        if (received == null) {
            return false;
        }
        // Compare digests so timing does not reveal how many leading characters matched
        return digest(expectedToken) == digest(received);
    }

    private static String digest(String s) {
        return EncodingUtil.base64Encode(Crypto.generateDigest('SHA-256', Blob.valueOf(s)));
    }
}
