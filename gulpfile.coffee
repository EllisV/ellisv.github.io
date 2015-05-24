gulp = require 'gulp'
# Loads the plugins without having to list all of them, but you need
# to call them as $.pluginname
$ = require('gulp-load-plugins')()
# "del" is used to clean out directories and such
del = require 'del'
# BrowserSync isn't a gulp package, and needs to be loaded manually
browserSync = require('browser-sync').create()
# Need a command for reloading webpages using BrowserSync
reload = browserSync.reload

gulp.task 'clean', del.bind(null, ['_site', 'assets'])

gulp.task 'jekyll:dev', $.shell.task('bundle exec jekyll build --config _config.yml,_config.dev.yml')
gulp.task 'jekyll-rebuild', ['jekyll:dev'], ->
  reload()

gulp.task 'jekyll:prod', $.shell.task('bundle exec jekyll build')

gulp.task 'styles', ->
  gulp.src '_assets/styles/app.sass'
    .pipe $.sass(includePaths: ['_bower_components'])
    .pipe $.autoprefixer(['> 1%', 'last 2 versions', 'Firefox ESR', 'Opera 12.1'], cascade: true)
    .pipe $.minifyCss(compatibility: 'ie8')
    .pipe gulp.dest('assets/css/')
    .pipe gulp.dest('_site/assets/css/')
    .pipe $.size(title: 'styles')

gulp.task 'scripts', ->
  files = ((options) ->
    reformatted = {}
    reformatter = (value) ->
      "_assets/scripts/#{value}"

    for prop of options
      reformatted[prop] = options[prop].map reformatter

    reformatted
  )(require('./_assets/scripts/concat.json'))

  for file, scripts of files
    gulp.src scripts
      .pipe $.if(/[.]coffee$/, $.coffee(bare: true).on('error', $.util.log))
      .pipe $.concat(file)
      .pipe $.uglify()
      .pipe gulp.dest('assets/js/')
      .pipe gulp.dest('_site/assets/js/')
      .pipe $.size(title: file)

gulp.task 'serve', ['jekyll:dev'], ->
  browserSync.init server: './_site'

gulp.task 'doctor', $.shell.task('bundle exec jekyll doctor')

gulp.task 'jslint', ->
  gulp.src 'assets/scripts/**/*.js'
    .pipe $.jshint('.jshintrc')
    .pipe $.jshint.reporter()

gulp.task 'coffeelint', ->
  gulp.src 'assets/scripts/**/*.coffee'
    .pipe $.coffeelint()
    .pipe $.coffeelint.reporter()

# These tasks will look for files that change while serving and will auto-regenerate or
# reload the website accordingly. Update or add other files you need to be watched.
gulp.task 'watch', ->
  gulp.watch ['./**/*.md', './**/*.html', './**/*.xml', './**/*.txt'], ['jekyll-rebuild']
  gulp.watch ['_site/assets/css/*.css', '_assets/scripts/**/*.{js,coffee}', '_assets/scripts/concat.json'], reload
  gulp.watch ['_assets/styles/**/*.{sass,scss}'], ['styles']
  gulp.watch ['_assets/scripts/**/*.{js,coffee}', '_assets/scripts/concat.json'], ['scripts']

# Default task, run when just writing "gulp" in the terminal
gulp.task 'default', ['styles', 'scripts', 'serve', 'watch']

# Checks your JS and Jekyll for errors
gulp.task 'check', ['jslint', 'coffeelint', 'doctor']

# Builds the site but doesn't serve it to you
gulp.task 'build', ['jekyll:prod', 'styles', 'scripts']
