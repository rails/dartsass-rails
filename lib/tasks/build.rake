EXEC_PATH      = "#{Pathname.new(__dir__).to_s}/../../exe/dartsass"
CSS_LOAD_PATH  = Rails.root.join("app/assets/stylesheets")
CSS_BUILD_PATH = Rails.root.join("app/assets/builds")
CSS_LOAD_FROM_RAILS_ROOT_PATH = Rails.root

def dartsass_build_mapping
  builds_map = Rails.application.config.dartsass.builds.map { |input, output|
    input_file_path = "#{CSS_LOAD_PATH.join(input)}"
    input_file_path = "#{CSS_LOAD_FROM_RAILS_ROOT_PATH.join(input)}" unless File.exist?(input_file_path)
    "#{input_file_path}:#{CSS_BUILD_PATH.join(output)}"
  }
  builds_map.uniq.join(" ")
end

def dartsass_build_options
  "--style=compressed --no-source-map"
end

def dartsass_load_paths
  [ CSS_LOAD_PATH ].concat(Rails.application.config.assets.paths).map { |path| "--load-path #{path}" }.join(" ")
end

def dartsass_compile_command
   "#{EXEC_PATH} #{dartsass_build_options} #{dartsass_load_paths} #{dartsass_build_mapping}"
end

namespace :dartsass do
  desc "Build your Dart Sass CSS"
  task build: :environment do
    system dartsass_compile_command
  end

  desc "Watch and build your Dart Sass CSS on file changes"
  task watch: :environment do
    system "#{dartsass_compile_command} -w"
  end
end

Rake::Task["assets:precompile"].enhance(["dartsass:build"])

if Rake::Task.task_defined?("test:prepare")
  Rake::Task["test:prepare"].enhance(["dartsass:build"])
elsif Rake::Task.task_defined?("db:test:prepare")
  Rake::Task["db:test:prepare"].enhance(["dartsass:build"])
end
