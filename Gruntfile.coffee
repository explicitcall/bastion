# Globbing
# for performance reasons we're only matching one level down:
# 'test/spec/{,*/}*.js'
# use this if you want to match all subfolders:
# 'test/spec/**/*.js'

module.exports = (grunt) ->
  # load all grunt tasks
  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks);

  debugConfigJs =
    'async/lib': 'async.js'
    'backbone-amd': 'backbone.js'
    'backbone-validation/dist': 'backbone-validation-amd.js'
    'backbone.babysitter/lib/amd': 'backbone.babysitter.js'
    'backbone.marionette/lib/core/amd': 'backbone.marionette.js'
    'backbone.paginator/dist': 'backbone.paginator.js'
    'backbone.wreqr/lib/amd': 'backbone.wreqr.js'
    'bootstrap/bootstrap/js': 'bootstrap.js'
    'jquery': 'jquery.js'
    'requirejs': 'require.js'
    'underscore-amd': 'underscore.js'
    'jade': 'runtime.js'

  debugConfigCss =
    'bootstrap/bootstrap/css': 'bootstrap.css'
    'font-awesome/css': 'font-awesome.css'

  debugFiles =
    for lib, file of debugConfigJs
      expand: true
      cwd: 'bower_components/' + lib
      dest: 'dist/public/scripts'
      src: file
  for lib, file of debugConfigCss
    debugFiles.push
      expand: true
      cwd: 'bower_components/' + lib
      dest: 'dist/public/stylesheets'
      src: file
  debugFiles.push
    expand: true
    cwd: 'bower_components/font-awesome/'
    src: 'font/*'
    dest: 'dist/public/'

  viewsConfig =
    'header/*.jade': 'header.js'
    'users/*.jade': 'users.js'

  viewsFiles = {}
  for source, destination of viewsConfig
    viewsFiles['dist/public/views/' + destination] = 'src/public/views/' + source

  grunt.initConfig
    watch:
      stylus:
        files: ['src/**/*.styl']
        tasks: ['stylus']
      server:
        files: ['src/**/*.coffee']
        tasks: ['coffee']
      jade:
        files: ['src/**/*.jade']
        tasks: ['copy:jade']

    clean:
      dist: ['dist']
      components: ['bower_components']

    bower:
      install:
        options:
          copy: false

    bower_postinst:
      dist:
        options:
          components:
            'bootstrap': ['npm', {'make': 'bootstrap' }]

    stylus:
      app:
        files:
          'dist/public/stylesheets/style.css': 'src/public/stylesheets/style.styl'

    coffee:
      all:
        expand: true
        cwd: 'src'
        src: ['**/*.coffee']
        dest: 'dist'
        ext: '.js'
        sourceMap: true

    copy:
      debug:
        files: debugFiles

      jade:
        files: [{
          expand: true
          dot: true
          cwd: 'src'
          dest: 'dist'
          src: ['app/views/**/*.jade']
        }]

    rename:
      jadeRuntime:
        src: 'dist/public/scripts/runtime.js'
        dest: 'dist/public/scripts/jade.js'

    jade:
      client:
        options:
          client: true
          amd: true
          processName: (name) ->
            newName = name.replace(/.*\/([A-Za-z]+)\.jade/, '$1')
            return newName
        files: viewsFiles

    nodemon:
      lcm:
        options:
          cwd: 'dist'
          file: '../node_modules/.bin/lcm'
          args: ['server']

    concurrent:
      local:
        tasks: ['nodemon', 'watch']
        options:
          logConcurrentOutput: true

  grunt.registerTask 'components', [
    'clean:components',
    'bower',
    'bower_postinst'
  ]

  grunt.registerTask 'dist', [
    'clean:dist',
    'coffee',
    'stylus',
    'jade',
    'copy',
    'rename'
  ]

  grunt.registerTask 'default', [
    'dist',
    'concurrent'
  ]
