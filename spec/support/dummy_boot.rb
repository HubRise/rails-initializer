# frozen_string_literal: true
module DummyBoot
  DUMMY_ENV_PATH = File.expand_path("./dummy/config/environment", __dir__)

  def with_dummy(env_hash = {})
    backup = setup_env(env_hash)
    unload_dummy!

    # Boot Dummy::Application
    require DUMMY_ENV_PATH

    yield

  ensure
    unload_dummy!
    restore_env(backup)
  end

  private

  def setup_env(env_hash)
    backup = {}
    env_hash.each do |k, v|
      backup[k] = ENV.key?(k) ? ENV[k] : :__undefined__
      ENV[k] = v
    end
    backup
  end

  def restore_env(backup)
    backup.each do |k, v|
      v == :__undefined__ ? ENV.delete(k) : ENV[k] = v
    end
  end

  def unload_dummy!
    return unless defined?(Dummy)

    Object.send(:remove_const, "Dummy")
    Rails.application = nil
  end
end

RSpec.configure { |c| c.include(DummyBoot) }
