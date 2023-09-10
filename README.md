# Dart Sass for Rails

[Sass](https://sass-lang.com) is a stylesheet language that’s compiled to CSS. It allows you to use variables, nested rules, mixins, functions, and more, all with a fully CSS-compatible syntax.

This gem wraps [the standalone executable version](https://github.com/sass/dart-sass/releases) of the Dart version of Sass. The platform specific Dart Sass executables are distributed by [sass-embedded](https://rubygems.org/gems/sass-embedded) gem.

The installer will create your default Sass input file in `app/assets/stylesheets/application.scss`. This is where you should import all the style files to be compiled [using the @use rule](https://sass-lang.com/documentation/at-rules/use). When you run `rails dartsass:build`, this input file will be used to generate the output in `app/assets/builds/application.css`. That's the output CSS that you'll include in your app. The load path for Sass is automatically configured to be `app/assets/stylesheets`.

If you need to configure the build process – beyond configuring the build files – you can run `bundle exec dartsass` to access the platform-specific executable, and give it your own build options.

When you're developing your application, you want to run Dart Sass in watch mode, so changes are automatically reflected in the generated CSS output. You can do this either by running `rails dartsass:watch` as a separate process, or by running `./bin/dev` which uses [foreman](https://github.com/ddollar/foreman) to start both the Dart Sass watch process and the rails server in development mode.


## Installation

1. Run `./bin/bundle add dartsass-rails`
2. Run `./bin/rails dartsass:install`

## Building in production

The `dartsass:build` is automatically attached to `assets:precompile`, so before the asset pipeline digests the files, the Dart Sass output will be generated.

## Configuring builds

By default, only `app/assets/stylesheets/application.scss` will be built. If you'd like to change the path of this stylesheet, add additional entry points, or customize the name of the built file, use the `Rails.application.config.dartsass.builds` configuration hash.


```ruby
# config/initializers/dartsass.rb
Rails.application.config.dartsass.builds = {
  "app/index.sass"  => "app.css",
  "site.scss"       => "site.css"
}
```

The hash key is the relative path to a Sass file in `app/assets/stylesheets/` and the hash value will be the name of the file output to `app/assets/builds/`.

If both the hash key and the hash value are directories instead of files, it configures a directory to directory compliation, which compiles all public Sass files whose filenames do not start with underscore (`_`).

```ruby
# config/initializers/dartsass.rb
Rails.application.config.dartsass.builds = {
  "." => "."
}
```

## Configuring build options

By default, sass is invoked with `["--style=compressed", "--no-source-map"]`. You can adjust these options by overwriting `Rails.application.config.dartsass.build_options`.

```ruby
# config/initializers/dartsass.rb
Rails.application.config.dartsass.build_options << "--no-charset" << "--quiet-deps"
```

## Importing assets from gems
`dartsass:build` includes application [assets paths](https://guides.rubyonrails.org/asset_pipeline.html#search-paths) as Sass [load paths](https://sass-lang.com/documentation/at-rules/use#load-paths). Assuming the gem has made assets visible to the Rails application, no additional configuration is required to use them.

## Migrating from sass-rails

If you're migrating from [sass-rails](https://github.com/rails/sass-rails)
(applies to [sassc-rails](https://github.com/sass/sassc-rails) as well)
and want to switch to dartsass-rails, follow these instructions below:

1. Remove the sass-rails gem from the Gemfile by running

    ```
    ./bin/bundle remove sass-rails
    ```

1. Install dartsass-rails by following the
    [Installation](#installation) instructions above

1. Remove any references to Sass files from the Sprockets manifest file:
    `app/assets/config/manifest.js`

1. In your continuous integration pipeline, before running any tests that
    interact with the browser, make sure to build the Sass files by running:

    ```
    bundle exec rails dartsass:build
    ```

## Troubleshooting

Some common problems experienced by users:

### LoadError: cannot load such file -- sassc

The reason for the above error is that Sprockets is trying to build Sass files
but the sass-rails or sassc-rails gems are not installed. This is expected,
since Dart Sass is used instead to build Sass files, and the solution is
to make sure that Sprockets is not building any Sass files.

There are three reasons why this error can occur:

#### Sass files are referenced in the Sprockets manifest file

If any Sass files are referenced in the Sprockets manifest file
(`app/assets/config/manifest.js`) Sprockets will try to build the Sass files and
fail.

##### Solution

Remove any references to Sass files from the Sprockets manifest file. These are
now handled by Dart Sass. If you have more Sass files than `application.scss`,
make sure these are compiled by Dart Sass
(see [Configuring builds](#configuring-builds) above).

#### Running locally

If you receive this error when running the Rails server locally and have
already removed any references to Sass files from the Sprockets manifest file,
the Dart Sass process is most likely not running.

##### Solution

Make sure the Dart Sass process is running by starting the Rails server by
running: `./bin/dev`.

#### Running continuous integration pipelines

If you receive this error when running tests that interact with the browser in
a continuous integration pipeline and have removed any references to Sass files
from the Sprockets manifest file, the Sass files have most likely not been
built.

#####  Solution

Add a step to the continuous integration pipeline to build the Sass files with
the following command: `bundle exec rails dartsass:build`.

## Version

``` sh
bundle exec dartsass --version
```

## License

Dart Sass for Rails is released under the [MIT License](https://opensource.org/licenses/MIT).
Sass is released under the [MIT License](https://opensource.org/licenses/MIT).
