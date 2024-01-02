module Dartsass
  module Runner
    EXEC_PATH      = "#{Pathname.new(__dir__).to_s}/../../exe/dartsass"
    CSS_LOAD_PATH  = Rails.root.join("app/assets/stylesheets")
    CSS_BUILD_PATH = Rails.root.join("app/assets/builds")

    module_function

    def dartsass_build_mapping
      Rails.application.config.dartsass.builds.map { |input, output|
        "#{CSS_LOAD_PATH.join(input)}:#{CSS_BUILD_PATH.join(output)}"
      }
    end

    def dartsass_build_options
      Rails.application.config.dartsass.build_options.flat_map(&:split)
    end

    def dartsass_load_paths
      [ CSS_LOAD_PATH ].concat(Rails.application.config.assets.paths).flat_map { |path| ["--load-path", path.to_s] }
    end

    def dartsass_compile_command
      [ RbConfig.ruby, EXEC_PATH ].concat(dartsass_build_options).concat(dartsass_load_paths).concat(dartsass_build_mapping)
    end
  end
end
