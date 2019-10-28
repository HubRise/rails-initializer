# HubriseInitializer

Default initializations common to HubRise projects.

## Installation

Add this line to your application's `Gemfile`:
```
gem 'hubrise_initializer'
```

Add this line to `config/application.rb`:
```
HubriseInitializer.configure(:logger, :delayed_job_logger, :web_console)
```

## Configuration

The following environment variables can be used:

- `RAILS_LOGGER` - possible values:
    - _not defined_: use Rails default logger (a file in the logs folder)
    - `fluentd`: send logs to Fluentd, with a single JSON log per request  
    - `stdout`: send logs to stdout  

- `FLUENTD_URL`: must be defined when `RAILS_LOGGER == fluentd` 

- `RAILS_LOG_LEVEL` - possible values:
    - _not defined_: do nothing
    - `debug`, `info`, etc.: override Rails log level

- `RAILS_LOGRAGE_SQL` - possible values:
    - _not defined_: do nothing
    - `true`: log SQL queries

## Publish changes to this gem

To upload the latest version to RubyGems.org:

1. Increase version

2. Build & publish:

```bash
rm hubrise_initializer-*.gem
gem build hubrise_initializer
gem push hubrise_initializer-*.gem
``` 
