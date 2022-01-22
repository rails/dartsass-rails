require "rails"

module Dartsass
  class Engine < ::Rails::Engine
    config.dartsass = ActiveSupport::OrderedOptions.new
    config.dartsass.builds = { "application.scss" => "application.css" }
  end
end
