Gem::Specification.new do |spec|
  spec.name = 'hubrise_initializer'
  spec.version = '0.1.3'
  spec.files = ["lib/hubrise_initializer.rb"]

  spec.authors = ["Antoine Monnier"]
  spec.summary = "Rails app initializers optimized for HubRise"
  spec.homepage = "https://github.com/hubrise/rails-initializer.git"
  spec.license = "MIT"

  spec.add_runtime_dependency 'lograge', '~> 0.11'
  spec.add_runtime_dependency 'act-fluent-logger-rails', '~> 0.5'
  spec.add_runtime_dependency 'logstash-event', '~> 1.2'
end
