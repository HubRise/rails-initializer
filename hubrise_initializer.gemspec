$LOAD_PATH.push File.expand_path("lib", __dir__)

require "hubrise_initializer/version"

Gem::Specification.new do |spec|
  spec.name = 'hubrise_initializer'
  spec.version = HubriseInitializer::VERSION

  spec.require_paths = ['lib']
  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.authors = ["Antoine Monnier"]
  spec.summary = "Rails app initializers optimized for HubRise"
  spec.homepage = "https://github.com/hubrise/rails-initializer.git"
  spec.license = "MIT"

  spec.add_runtime_dependency 'lograge', '~> 0.11'
  spec.add_runtime_dependency 'lograge-sql'
  spec.add_runtime_dependency 'act-fluent-logger-rails', '~> 0.6'
  spec.add_runtime_dependency 'logstash-event', '~> 1.2'
end
