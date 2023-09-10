EXEC_PATH      = "#{Pathname.new(__dir__).to_s}/../../exe/dartsass"
CSS_LOAD_PATH  = Rails.root.join("app/assets/stylesheets")
CSS_BUILD_PATH = Rails.root.join("app/assets/builds")

def dartsass_build_mapping
  Rails.application.config.dartsass.builds.map { |input, output|
    "#{CSS_LOAD_PATH.join(input)}:#{CSS_BUILD_PATH.join(output)}"
  }
end

def dartsass_build_options
  Rails.application.config.dartsass.build_options.map(&:strip)
end

def dartsass_load_paths
  [ CSS_LOAD_PATH ].concat(Rails.application.config.assets.paths).flat_map { |path| ["--load-path", path.to_s] }
end

def dartsass_compile_command
  [ RbConfig.ruby, EXEC_PATH ].concat(dartsass_build_options).concat(dartsass_load_paths).concat(dartsass_build_mapping)
end

namespace :dartsass do
  desc "Build your Dart Sass CSS"
  task build: :environment do
    system(*dartsass_compile_command, exception: true)
  end

  desc "Watch and build your Dart Sass CSS on file changes"
  task watch: :environment do
    system(*dartsass_compile_command, "--watch", exception: true)
  end
end

Rake::Task["assets:precompile"].enhance(["dartsass:build"])

if Rake::Task.task_defined?("test:prepare")
  Rake::Task["test:prepare"].enhance(["dartsass:build"])
elsif Rake::Task.task_defined?("db:test:prepare")
  Rake::Task["db:test:prepare"].enhance(["dartsass:build"])
end
