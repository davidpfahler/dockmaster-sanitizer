"use strict"

module.exports = (grunt) ->

  require("load-grunt-tasks") grunt
  require("time-grunt") grunt

  grunt.initConfig
    yeoman:
      app: 'src'
      dist: 'lib'
      test: 'test'
      testTmp: 'test-tmp'

    nodeunit:
      files: ['<%= yeoman.testTmp %>/{,*/}*.js']

    watch:
      coffee:
        files: ['<%= yeoman.app %>/{,*/}*.coffee']
        tasks: ['coffee:dist']

    clean:
      dist: src: ['<%= yeoman.dist %>/*']
      test: src: ['<%= yeoman.testTmp %>/*']

    coffeelint:
      options:
        no_empty_param_list:
          level: 'error'
        no_stand_alone_at:
          level: 'error'
      src:
        files: src: ['<%= yeoman.app %>/{,*/}*.coffee']
        max_line_length:
          value: 79
          level: 'error'
      test:
        files: src: ['<%= yeoman.test %>/{,*/}*.coffee']
        max_line_length:
          value: 79
          level: 'error'
      gruntfile:
        files: src: ['Gruntfile.coffee']

    coffee:
      options:
        sourceMap: yes
        sourceRoot: '../src/'

      dist:
        files: [
          expand: yes
          cwd: '<%= yeoman.app %>'
          src: '{,*/}*.coffee'
          dest: '<%= yeoman.dist %>'
          ext: '.js'
        ]

      test:
        files: [
          expand: yes
          cwd: '<%= yeoman.test %>'
          src: '{,*/}*.coffee'
          dest: '<%= yeoman.testTmp %>'
          ext: '.js'
        ]

    shell:
      options:
        stderr : yes
        stdout : yes
        failOnError : yes
      semver:
        command: './node_modules/semver-sync/bin/semver-sync -v'
      hooks:
        command: 'cp -R ./hooks ./.git/'

  grunt.registerTask 'precommit', ['shell:semver', 'coffeelint']
  grunt.registerTask '_build', [
    'coffeelint'
    'clean'
    'coffee'
    'nodeunit'
  ]
  grunt.registerTask 'default', ['shell:hooks', '_build', 'watch']
  grunt.registerTask 'test', ['coffee', 'nodeunit']
