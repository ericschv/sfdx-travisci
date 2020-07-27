# zen [![master](https://travis-ci.com/zensurance/zen.svg?token=DDoJ2FFmSQy7sJTjMVEY&branch=master)](https://travis-ci.com/zensurance/dashboard)

&nbsp;
<p align="center">
  <img src ="https://www.zensurance.com/wp-content/uploads/2019/06/logo_zensurance.svg">
</p>

# Zen Salesforce
- ### Welcome to Salesforce service! This is a small package used for logging salesforce errors to sentry, which is a third party service we use for error reporting.

# Salesforce Sentry Exception Library

Fork of [SentryForSalesforce](https://github.com/jmather/SentryForSalesforce) by [jmather](https://github.com/jmather)

## Usage

```
try {
    doSomethingExceptional();
} catch (Exception e) {
    Sentry.record(e);
    throw e;
}
```

To send an exception to either `sentry-sandbox` or `sentry-sandbox` depending on the environment where `Sentry.record` is invoked.

# Useful Documentation
* [API Documentation](./docs/api/api.md)
* [Technical Documentation](./docs/tech/tech.md)
* See `./docs/tech/` for other misc tech docs.
