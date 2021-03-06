# frozen_string_literal: true

require "quails"

module EnvHelpers
  private

    def with_quails_env(env)
      Quails.instance_variable_set :@_env, nil
      switch_env "RAILS_ENV", env do
        switch_env "RACK_ENV", nil do
          yield
        end
      end
    end

    def with_rack_env(env)
      Quails.instance_variable_set :@_env, nil
      switch_env "RACK_ENV", env do
        switch_env "RAILS_ENV", nil do
          yield
        end
      end
    end

    def switch_env(key, value)
      old, ENV[key] = ENV[key], value
      yield
    ensure
      ENV[key] = old
    end
end
