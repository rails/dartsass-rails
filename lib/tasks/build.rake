CSS_LOAD_PATH  = Rails.root.join("app/assets/stylesheets")
CSS_BUILD_PATH = Rails.root.join("app/assets/builds")

def dartsass_build_mapping
  Rails.application.config.dartsass.builds.map { |input, output|
    "#{Shellwords.escape(CSS_LOAD_PATH.join(input))}:#{Shellwords.escape(CSS_BUILD_PATH.join(output))}"
  }.join(" ")
end

def dartsass_build_options
  Rails.application.config.dartsass.build_options
end

def dartsass_load_paths
  [ CSS_LOAD_PATH ].concat(Rails.application.config.assets.paths).map { |path| "--load-path #{Shellwords.escape(path)}" }.join(" ")
end

def dartsass_exec_path
  Rails.application.config.dartsass.exec_path
end

def dartsass_compile_command
  "#{dartsass_exec_path} #{dartsass_build_options} #{dartsass_load_paths} #{dartsass_build_mapping}"
end

namespace :dartsass do
  desc "Build your Dart Sass CSS"
  task build: :environment do
    system dartsass_compile_command, exception: true
  end

  desc "Watch and build your Dart Sass CSS on file changes"
  task watch: :environment do
    system "#{dartsass_compile_command} -w", exception: true
  end
end

Rake::Task["assets:precompile"].enhance(["dartsass:build"])

if Rake::Task.task_defined?("test:prepare")
  Rake::Task["test:prepare"].enhance(["dartsass:build"])
elsif Rake::Task.task_defined?("db:test:prepare")
  Rake::Task["db:test:prepare"].enhance(["dartsass:build"])
end
