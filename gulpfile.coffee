require('dotenv').load()

gulp            = require('gulp')
gutil           = require('gulp-util')
browserify      = require('browserify')
coffeeReactify  = require('coffee-reactify')
source          = require('vinyl-source-stream')
uglify          = require('gulp-uglify') # thanks Terin!
streamify       = require('gulp-streamify') # awww c'mon Terin :(
less            = require('gulp-less')
minifyCSS       = require('gulp-minify-css')
sourcemaps      = require('gulp-sourcemaps')
livereload      = require('tiny-lr')
path            = require('path')
spawn           = require('child_process').spawn
mocha           = require('gulp-mocha')

compileJS = (production) ->
  gutil.log 'Compiling js (production: '+production+')'
  bundleStream = browserify()
    .add('./frontend/js/app.cjsx')
    .transform(coffeeReactify)
    .bundle(debug: !production)
    .on 'error', (err) ->
      gutil.log 'Error compiling js!'
      gutil.log err
      this.end()

  bundleStream
    .pipe(source('app.js'))
    .pipe(if production then streamify(uglify()) else gutil.noop())
    .pipe(gulp.dest('./public/compiled'))


compileCSS = (production) ->
  gutil.log 'Compiling css (production: '+production+')'

  onError = (err) ->
    gutil.log 'Error compiling css!'
    gutil.log err.message

  if production
    gulp.src('./frontend/css/app.less')
      .pipe(less().on 'error', onError)
      .pipe(minifyCSS())
      .pipe(gulp.dest('./public/compiled'))
  else
    gulp.src('./frontend/css/app.less')
      .pipe(sourcemaps.init())
      .pipe(less().on 'error', onError)
      .pipe(sourcemaps.write())
      .pipe(gulp.dest('./public/compiled'))

compile = ->
  compileJS(true)
  compileCSS(true)

gulp.task 'compile', compile
gulp.task 'heroku:production', compile

# For development: starts web server and JS/CSS watch + compile + livereload
gulp.task 'default', ->
  compileJS(false)
  compileCSS(false)

  lr = livereload()
  lr.listen(35729)

  runServer()

  gulp.watch ['./frontend/css/**/*'], (evt) ->
    compileCSS(false)

  gulp.watch ['./frontend/js/**/*', './shared/**/*'], (evt) ->
    compileJS(false)

  gulp.watch ['./public/**/*'], (evt) ->
    relPath = path.relative(path.join(__dirname,'public'), evt.path)
    gutil.log 'Live-reloading ('+relPath+' modified)'
    lr.changed(body: {files: [relPath]})

node = null

# Starts the web server, stopping it if already running first
runServer = ->
  gutil.log 'Starting web server...'
  node.kill() if node
  node = spawn('coffee', ['web.coffee'], stdio: 'inherit')
  node.on 'close', (code) ->
    gutil.log 'Error detected, waiting for changes...' if code == 8

# Clean up if an error goes unhandled.
process.on 'exit', ->
  node.kill() if node

gulp.task 'test', ->
  runTests = ->
      lines = process.stdout.getWindowSize()[1]
      console.log('') for i in [1..lines]
      gulp.src('./test/**/*', read: false)
        .pipe(mocha())

  runTests()
  gulp.watch [
    './frontend/js/**/*',
    './shared/**/*',
    './backend/**/*',
    './test/**/*'
  ], (evt) ->
    runTests()