DARTSASS_COMPILE_COMMAND = "#{Pathname.new(__dir__).to_s}/../../exe/dartsass #{Rails.root.join("app/assets/stylesheets/application.scss")} #{Rails.root.join("app/assets/builds/application.scss")}"

namespace :dartsass do
  desc "Build your Dart Sass CSS"
  task :build do
    system DARTSASS_COMPILE_COMMAND
  end

  desc "Watch and build your Dart Sass CSS on file changes"
  task :watch do
    system "#{DARTSASS_COMPILE_COMMAND} -w"
  end
end

Rake::Task["assets:precompile"].enhance(["dartsass:build"])

if Rake::Task.task_defined?("test:prepare")
  Rake::Task["test:prepare"].enhance(["dartsass:build"])
elsif Rake::Task.task_defined?("db:test:prepare")
  Rake::Task["db:test:prepare"].enhance(["dartsass:build"])
end
