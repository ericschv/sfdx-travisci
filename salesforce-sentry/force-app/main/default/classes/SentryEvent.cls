public without sharing class SentryEvent {
    // uuid
    public String event_id;

    public String timestamp;

    public String level = 'error';

    public String platform = 'salesforce';

    public Map<String, String> sdk = new Map<String, String> { 'name' => 'sentry.apex', 'version' => '1' };

    public String logger;

    public String server_name;

    public String release;

    public String message = '';

    public String environment;

    public String[] modules;

    public Map<String, Object> request = SentryContext.create();

    public Map<String, Object> extra = SentryContext.create();

    public Map<String, Object> user = SentryContext.User();

    public Map<String, Object> contexts = SentryContext.OsSystem();

    public Map<String, Object> tags = SentryContext.create();

    public String[] fingerprint;

    public Map<String, Object> breadcrumbs = SentryContext.Breadcrumbs();

    public Map<String, Object> exceptionValues = new Map<String, Object> { 'values' => new List<Map<String, Object>>() };

    public String messageFormatted;

    public String[] messageParams;

    public String stacktrace;

    public SentryEvent() {
        initialize();
    }

    public SentryEvent(Exception salesforceException) {
        initialize();

        Map<String, Object> exceptionData = SentryContext.create();
        Map<String, Object> exceptionDataStack = SentryContext.create();

        List<Map<String, Object>> frames = constructStackTrace(salesforceException);

        exceptionDataStack.put('frames', frames);

        exceptionData.put('type', salesforceException.getTypeName());
        exceptionData.put('message', JSON.serialize(salesforceException.getMessage()));
        exceptionData.put('stacktrace', exceptionDataStack);

        extra.put('cause', salesforceException.getCause());
        extra.put('line_number', salesforceException.getLineNumber());

        addException(exceptionData);

        message = salesforceException.getMessage();
    }

    private static List<Map<String, Object>> constructStackTrace(Exception salesforceException) {
        List<Map<String, Object>> frames = new List<Map<String, Object>>();

        List<String> lines = salesforceException.getStackTraceString().split('\n');

        for (Integer i = lines.size() - 1; i >= 0; i--) {
            String line = lines[i];
            Pattern p = Pattern.compile('Class\\.([^\\.]+)\\.([^:]+): line ([0-9]+), column ([0-9]+)');
            Matcher m = p.matcher(line);
            if (m.find()) {
                frames.add(new Map<String, Object> {
                        'class' => m.group(1),
                        'file' => m.group(1) + '.cls',
                        'function' => m.group(1) + '.' + m.group(2) + ', line ' + m.group(3),
                        'line' => m.group(3),
                        'column' => m.group(4)
                });
            }
        }

        return frames;
    }

    private void addException(Map<String, Object> exceptionData) {
        ((List<Map<String, Object>>)exceptionValues.get('values')).add(exceptionData);
    }

    private void initialize() {
        event_id = SentrySharedUtils.generateUuid();

        timestamp = SentrySharedUtils.generateTimestamp();

        environment = SentryConfig.getEnvironmentName();
    }

    public Map<String, Object> toMessage() {
        Map<String, Object> msg = SentryContext.create();
        msg.put('event_id', event_id);
        msg.put('environment', environment);
        msg.put('user', user);
        msg.put('timestamp', timestamp);
        msg.put('sdk', sdk);
        msg.put('platform', platform);
        msg.put('level', level);
        msg.put('exception', exceptionValues);
        msg.put('message', message);
        return msg;
    }
}