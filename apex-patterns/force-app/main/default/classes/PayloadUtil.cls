/** Defensive helpers for third-party webhook payloads: odd key names, mixed types, local-time stamps. */
public with sharing class PayloadUtil {

    /** Lower-cases keys, trims spaces (one vendor key arrives with a trailing space) and strips a leading $. */
    public static Map<String, Object> normalize(Map<String, Object> raw) {
        Map<String, Object> n = new Map<String, Object>();
        for (String k : raw.keySet()) {
            String key = k.trim().toLowerCase();
            if (key.startsWith('$')) {
                key = key.substring(1);
            }
            n.put(key, raw.get(k));
        }
        return n;
    }

    public static String str(Object o) {
        return o == null ? null : String.valueOf(o).trim();
    }

    public static String lower(Object o) {
        String s = str(o);
        return s == null ? '' : s.toLowerCase();
    }

    /** Numbers arrive as strings ("16") or numbers depending on the trigger. */
    public static Integer toInt(Object o) {
        if (o == null) {
            return null;
        }
        String s = String.valueOf(o).trim();
        return Pattern.matches('^-?\\d+$', s) ? Integer.valueOf(s) : null;
    }

    /** "2026-10-07 10:26:48" is India Standard Time (UTC+5:30) unless it ends with Z. */
    public static Datetime parseIst(String s) {
        if (String.isBlank(s)) {
            return null;
        }
        String t = s.trim();
        Matcher m = Pattern.compile('^(\\d{4})-(\\d{2})-(\\d{2})[ T](\\d{2}):(\\d{2}):(\\d{2}).*$').matcher(t);
        if (!m.matches()) {
            return null;
        }
        Datetime g = Datetime.newInstanceGmt(
            Integer.valueOf(m.group(1)), Integer.valueOf(m.group(2)), Integer.valueOf(m.group(3)),
            Integer.valueOf(m.group(4)), Integer.valueOf(m.group(5)), Integer.valueOf(m.group(6))
        );
        return t.endsWith('Z') ? g : g.addSeconds(-19800);
    }
}
