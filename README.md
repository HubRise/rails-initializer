# Rails initializer

Default initializations common to HubRise projects.

## Installation

Add this line to your application's `Gemfile`:
```
gem 'hubrise_initializer'
```

In `config/application.rb`:
```
HubriseInitializer.configure(:logger, :delayed_job_logger, :web_console)
```

## Configuration

The following environment variables can be used:

- `RAILS_LOGGER` - possible values:
    - _not defined_: use Rails default logger (a file in the logs folder)
    - `fluentd`: send logs to Fluentd, with a single JSON log per request  
    - `stdout`: send logs to stdout  

- `RAILS_LOG_LEVEL` - possible values:
    - `debug`, `info`, etc.: override Rails log level

The following environment variables can be used only when`ENV['RAILS_LOGGER'] == 'fluentd'` 

- `FLUENTD_URL`: must be defined

- `RAILS_LOGRAGE_SQL` - possible values:
    - `true`: log SQL queries

- `RAILS_LOGRAGE_QUERY` - possible values:
   - `true`: log queries and reponses' bodies & headers

## Publish changes to this gem

To upload the latest version to RubyGems.org:

0. Make sure all local changes are committed.

1. Increase version in `lib/hubrise_initializer/version.rb`

2. Tag the repository:
```bash
VERSION=0.2.9
git add lib/hubrise_initializer/version.rb
git tag v$VERSION
git commit -m "Version $VERSION"
git push --tags
```

3. Build & publish - `cd` to the repository main folder then: 

```bash
rm -f hubrise_initializer-*.gem
gem build hubrise_initializer
gem push hubrise_initializer-*.gem
``` 
