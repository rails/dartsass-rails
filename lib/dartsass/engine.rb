require "rails"

module Dartsass
  class Engine < ::Rails::Engine
    config.dartsass = ActiveSupport::OrderedOptions.new
    config.dartsass.builds = { "application.scss" => "application.css" }
    config.dartsass.build_options = ["--style=compressed", "--no-source-map"]
  end
end
