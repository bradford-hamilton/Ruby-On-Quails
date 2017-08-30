# frozen_string_literal: true

if ENV["AJ_ADAPTER"] == "delayed_job"
  generate "delayed_job:active_record", "--quiet"
end

quails_command("db:migrate")

initializer "activejob.rb", <<-CODE
require "#{File.expand_path("jobs_manager.rb",  __dir__)}"
JobsManager.current_manager.setup
CODE

initializer "i18n.rb", <<-CODE
I18n.available_locales = [:en, :de]
CODE

file "app/jobs/test_job.rb", <<-CODE
class TestJob < ActiveJob::Base
  queue_as :integration_tests

  def perform(x)
    File.open(Quails.root.join("tmp/\#{x}.new"), "wb+") do |f|
      f.write Marshal.dump({
        "locale" => I18n.locale.to_s || "en",
        "executed_at" => Time.now.to_r
      })
    end
    File.rename(Quails.root.join("tmp/\#{x}.new"), Quails.root.join("tmp/\#{x}"))
  end
end
CODE
