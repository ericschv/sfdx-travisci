public with sharing class SentryDsn {
    public String privateKey { get; private set; }
    public String publicKey { get; private set; }
    public String projectId { get; private set; }
    public String sentryEndpoint { get; private set; }
    public Url url { get; private set; }
    public Url sentryUrl { get; private set; }
    
    public SentryDsn(String dsn) {
        this.url = new Url(dsn);
        this.publicKey = getPublicKey(url);
        this.privateKey = getPrivateKey(url);
        this.projectId = getProjectId(url);
        this.sentryEndpoint = 'https://sentry.io/api/' + projectId + '/store/';
        this.sentryUrl = new Url(sentryEndpoint);
    }

    private String getProjectId(Url url) {
        String[] pieces = url.getPath().split('/');

        if (pieces.size() == 0) {
            return null;
        }

        return pieces[pieces.size() - 1];
    }

    private String getPublicKey(Url url) {
        String userInfo = url.getUserInfo();

        if (String.isBlank(userInfo)) {
            return null;
        }

        if (userInfo.contains(':')) {
            return url.getUserInfo().split(':')[0];
        }

        return userInfo;
    }

    private String getPrivateKey(Url url) {
        String[] pieces = url.getUserInfo().split(':');

        if (pieces.size() == 2) {
            return pieces[1];
        }

        return null;
    }
}