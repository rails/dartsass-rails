namespace :dartsass do
  desc "Install Dart Sass into the app"
  task :install do
    system RbConfig.ruby, "./bin/rails", "app:template", "LOCATION=#{File.expand_path("../install/dartsass.rb", __dir__)}", exception: true
  end
end
