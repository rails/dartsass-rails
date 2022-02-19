APPLICATION_LAYOUT_PATH             = Rails.root.join("app/views/layouts/application.html.erb")
CENTERING_CONTAINER_INSERTION_POINT = /^\s*<%= yield %>/.freeze

say "Build into app/assets/builds"
empty_directory "app/assets/builds"
keep_file "app/assets/builds"

if (sprockets_manifest_path = Rails.root.join("app/assets/config/manifest.js")).exist?
  append_to_file sprockets_manifest_path, %(//= link_tree ../builds\n)

  say "Stop linking stylesheets automatically"
  gsub_file "app/assets/config/manifest.js", "//= link_directory ../stylesheets .css\n", ""
end

if Rails.root.join(".gitignore").exist?
  append_to_file(".gitignore", %(\n/app/assets/builds/*\n!/app/assets/builds/.keep\n))
end

unless Rails.root.join("app/assets/stylesheets/application.scss").exist?
  say "Add default app/assets/stylesheets/application.scss"
  copy_file "#{__dir__}/application.scss", "app/assets/stylesheets/application.scss"
end

if Rails.root.join("Procfile.dev").exist?
  append_to_file "Procfile.dev", "css: bin/rails dartsass:watch\n"
else
  say "Add default Procfile.dev"
  copy_file "#{__dir__}/Procfile.dev", "Procfile.dev"

  say "Ensure foreman is installed"
  run "gem install foreman"
end

say "Add bin/dev to start foreman"
copy_file "#{__dir__}/dev", "bin/dev"
chmod "bin/dev", 0755, verbose: false

say "Compile initial Dart Sass build"
run "rails dartsass:build"
