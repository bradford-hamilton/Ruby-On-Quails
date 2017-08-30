# frozen_string_literal: true

require "abstract_unit"
require "quails/command"
require "quails/commands/generate/generate_command"
require "quails/commands/secrets/secrets_command"

class Quails::Command::BaseTest < ActiveSupport::TestCase
  test "printing commands" do
    assert_equal %w(generate), Quails::Command::GenerateCommand.printing_commands
    assert_equal %w(secrets:setup secrets:edit secrets:show), Quails::Command::SecretsCommand.printing_commands
  end
end
