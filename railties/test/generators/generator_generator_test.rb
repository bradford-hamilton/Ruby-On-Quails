# frozen_string_literal: true

require "generators/generators_test_helper"
require "quails/generators/quails/generator/generator_generator"

class GeneratorGeneratorTest < Quails::Generators::TestCase
  include GeneratorsTestHelper
  arguments %w(awesome)

  def test_generator_skeleton_is_created
    run_generator

    %w(
      lib/generators/awesome
      lib/generators/awesome/USAGE
      lib/generators/awesome/templates
    ).each { |path| assert_file path }

    assert_file "lib/generators/awesome/awesome_generator.rb",
                /class AwesomeGenerator < Quails::Generators::NamedBase/
    assert_file "test/lib/generators/awesome_generator_test.rb",
               /class AwesomeGeneratorTest < Quails::Generators::TestCase/,
               /require 'generators\/awesome\/awesome_generator'/
  end

  def test_namespaced_generator_skeleton
    run_generator ["quails/awesome"]

    %w(
      lib/generators/quails/awesome
      lib/generators/quails/awesome/USAGE
      lib/generators/quails/awesome/templates
    ).each { |path| assert_file path }

    assert_file "lib/generators/quails/awesome/awesome_generator.rb",
                /class Quails::AwesomeGenerator < Quails::Generators::NamedBase/
    assert_file "test/lib/generators/quails/awesome_generator_test.rb",
               /class Quails::AwesomeGeneratorTest < Quails::Generators::TestCase/,
               /require 'generators\/quails\/awesome\/awesome_generator'/
  end

  def test_generator_skeleton_is_created_without_file_name_namespace
    run_generator ["awesome", "--namespace", "false"]

    %w(
      lib/generators/
      lib/generators/USAGE
      lib/generators/templates
    ).each { |path| assert_file path }

    assert_file "lib/generators/awesome_generator.rb",
                /class AwesomeGenerator < Quails::Generators::NamedBase/
    assert_file "test/lib/generators/awesome_generator_test.rb",
               /class AwesomeGeneratorTest < Quails::Generators::TestCase/,
               /require 'generators\/awesome_generator'/
  end

  def test_namespaced_generator_skeleton_without_file_name_namespace
    run_generator ["quails/awesome", "--namespace", "false"]

    %w(
      lib/generators/quails
      lib/generators/quails/USAGE
      lib/generators/quails/templates
    ).each { |path| assert_file path }

    assert_file "lib/generators/quails/awesome_generator.rb",
                /class Quails::AwesomeGenerator < Quails::Generators::NamedBase/
    assert_file "test/lib/generators/quails/awesome_generator_test.rb",
               /class Quails::AwesomeGeneratorTest < Quails::Generators::TestCase/,
               /require 'generators\/quails\/awesome_generator'/
  end
end
