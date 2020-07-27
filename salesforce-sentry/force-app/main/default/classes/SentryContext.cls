public abstract class SentryContext {
    public static Map<String, Object> create() {
        return new Map<String, Object>();
    }

    public static Map<String, Object> Breadcrumbs() {
        Map<String, Object> data = create();
        data.put('values', create());
        return data;
    }

    public static Map<String, Object> OsSystem() {
        return new Map<String, Object> {
                'os' => Server(),
                'runtime' => Runtime(),
                'org' => Org()
        };
    }

    public static Map<String, String> Org() {
        return new Map<String, String> {
                'name' => SentrySharedUtils.getInstanceLabel(),
                'type' => SentrySharedUtils.getInstanceTypeAsString()
        };
    }

    public static Map<String, String> Server() {
        return new Map<String, String> {
                'name' => 'Salesforce',
                'version' => '1'
        };
    }

    public static Map<String, String> Runtime() {
        return new Map<String, String> {
                'name' => 'Apex',
                'version' => '1'
        };
    }

    public static Map<String, String> User() {
        return new Map<String, String> {
                'id' => UserInfo.getUserId(),
                'username' => UserInfo.getUserName(),
                'email' => UserInfo.getUserEmail()
        };
    }
}