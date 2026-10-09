/** Server-side masking. The browser only ever receives the masked value. */
public with sharing class PhoneMask {

    public static String digits(String s) {
        return s == null ? '' : s.replaceAll('[^0-9]', '');
    }

    /** Shows only the last two digits, for example XXXXXXXX10. */
    public static String mask(String raw) {
        String d = digits(raw);
        if (String.isBlank(d)) {
            return '';
        }
        if (d.length() <= 2) {
            return 'X'.repeat(d.length());
        }
        return 'X'.repeat(d.length() - 2) + d.right(2);
    }

    /** The telephony API accepts 10 to 13 digits. Drops symbols and one leading 0 on 11-digit numbers. */
    public static String normalizeDestination(String raw) {
        String d = digits(raw);
        if (d.length() == 11 && d.startsWith('0')) {
            d = d.substring(1);
        }
        return d;
    }
}
