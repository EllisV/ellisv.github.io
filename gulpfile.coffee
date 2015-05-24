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

gulp.task 'clean', del.bind(null, ['_site'])

gulp.task 'jekyll:dev', $.shell.task('bundle exec jekyll build --config _config.yml,_config.dev.yml')
gulp.task 'jekyll-rebuild', ['jekyll:dev'], ->
  reload()

gulp.task 'jekyll:prod', $.shell.task('bundle exec jekyll build')

gulp.task 'serve', ['jekyll:dev'], ->
  browserSync.init server: './_site'

# These tasks will look for files that change while serving and will auto-regenerate or
# reload the website accordingly. Update or add other files you need to be watched.
gulp.task 'watch', ->
  gulp.watch ['./**/*.md', './**/*.html', './**/*.xml', './**/*.txt'], ['jekyll-rebuild']

# Default task, run when just writing "gulp" in the terminal
gulp.task 'default', ['serve', 'watch']
