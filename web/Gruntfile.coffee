"use strict"

LIVERELOAD_PORT = 35729
lrSnippet = require('connect-livereload')(port: LIVERELOAD_PORT)


mountFolder = (connect, dir) ->
    connect.static require('path').resolve(dir)


module.exports = (grunt) ->
    # load all grunt tasks
    require('matchdep').filterDev('grunt-*').forEach grunt.loadNpmTasks
    
    appConfig =
        date: "2015-06-08T11:06:46+0200"
        paths:
            app: "./app"
            dist: "./dist"
            tmp: "./.tmp"
            templates: "_templates"
            data: "_data"
            css: "styles"
            images: "images"
            scripts: "scripts"
            bower: "bower_components"
        supported_browsers: "last 3 versions"
        remotePath: 'http://jujujulian.com/mds/'
        
    if grunt.cli.tasks[0] == "server"
        appConfig.templateData =
            imagePath: "images"
            scriptPath: "scripts"
            stylePath: "styles"
            environment: "dev"
    else if grunt.cli.tasks[0] == "staticbuild"
        appConfig.templateData =
            imagePath: "images"
            scriptPath: "scripts"
            stylePath: "styles"
            environment: "dev"
        
    
    createPages = (obj) ->
        template = grunt.file.read('_templates/layouts/cardpage.hbs')
        pages = []
        for key, value of obj.cards
            #value.filename = key
            pages.push(
                data:
                    value
                content: template
                filename: "#{key}.json"
            )
        pages
    
    cardPages = []#createPages grunt.file.readYAML("_data/cards.yml")

        
    grunt.initConfig
        pkg: grunt.file.readJSON('package.json')
        appConfig: appConfig
        watch:
            html:
                files: [ '<%= appConfig.paths.app %>/**/*.html' ]
                tasks: [
                    'copy:html'
                ]
            hbs:
                files: [
                        '<%= appConfig.paths.app %>/**/*.hbs'
                        '!<%= appConfig.paths.app %>/scripts/**/*'
                        '!<%= appConfig.paths.app %>/bower_components/**/*'
                    ]
                tasks: [
                    'assemble:yo'
                ]
            coffee:
                files: [ '<%= appConfig.paths.app %>/scripts/**/*.coffee' ]
                tasks: [ 'coffee:dist' ]
            compass:
                files: [ '<%= appConfig.paths.app %>/styles/**/*.{scss,sass}' ]
                tasks: [ 'compass:server', "postcss:server"  ]
            styles:
                files: [ '<%= appConfig.paths.app %>/styles/**/*.css' ]
                tasks: [ 'copy:styles', "postcss:server" ]
            livereload:
                options: livereload: LIVERELOAD_PORT
                files: [
                    '.tmp/styles/**/*.css'
                    '.tmp/**/*.html'
                    '!.tmp/bower_components/**/*.html'
                    '{.tmp,<%= appConfig.paths.app %>}/scripts/**/*.js'
                    '<%= appConfig.paths.app %>/images/**/*.{png,jpg,jpeg,gif,webp,svg}'
                ]
        'string-replace':
            onerequirejsfile:
                files: [ {
                    expand: true
                    cwd: '<%= appConfig.paths.dist %>/'
                    src: [
                        '**/*.html'
                        '!scripts/**/*.html'
                    ]
                    dest: '<%= appConfig.paths.dist %>/'
                } ]
                options: replacements: [ {
                    pattern: new RegExp("<script\\s+data-main=(?:\"|')(.*?)(?:\"|')\\s+src=(?:\"|')(.*?)(?:\"|')><\\/script>", "ig")
                    replacement: '<script src="$1.js"></script>'
                } ]
            staticserver:
                files: [ {
                    expand: true
                    cwd: '<%= appConfig.paths.dist %>/'
                    src: [
                        '**/*.html'
                        '!bower_components/**/*.html'
                        '!scripts/**/*.html'
                    ]
                    dest: '<%= appConfig.paths.dist %>/'
                } ]
                options: replacements: [
                    {
                        pattern: new RegExp('="images/(.*?)"', 'g')
                        replacement: '="<%= appConfig.remotePath %>images/$1"'
                    }
                    {
                        pattern: new RegExp('="styles/(.*?)"', 'g')
                        replacement: '="<%= appConfig.remotePath %>styles/$1"'
                    }
                    {
                        pattern: new RegExp('="scripts/(.*?)"', 'g')
                        replacement: '="<%= appConfig.remotePath %>scripts/$1"'
                    }
                ]
        connect:
            options:
                port: 9000
                hostname: '0.0.0.0'
            livereload: options: middleware: (connect) ->
                [
                    lrSnippet
                    mountFolder(connect, '.tmp')
                    mountFolder(connect, appConfig.paths.app)
                    mountFolder(connect, '.')
                ]
            dist: options: middleware: (connect) ->
                [ mountFolder(connect, appConfig.paths.dist) ]
        open: server: path: 'http://localhost:<%= connect.options.port %>'
        clean:
            dist: files: [ {
                dot: true
                src: [
                    './.tmp'
                    '<%= appConfig.paths.dist %>/*'
                    '!<%= appConfig.paths.dist %>/.git*'
                ]
            } ]
            requirejsonefile: src: '<%= appConfig.paths.dist %>/bower_components/requirejs'
            emptyfolders:
                src: '<%= appConfig.paths.dist %>/*'
                filter: (filepath) ->
                    grunt.file.isDir(filepath) and require('fs').readdirSync(filepath).length == 0
            server: '.tmp'
        assemble:
            options:
                assets: 'assets'
                partials: ['_templates/includes/**/*.hbs']
                layout: ['_templates/layouts/default.hbs']
                data: [
                    "_data/**/*.{json,yml}"
                    "_data/site.yml"
                ]
                remotePath: "<%= appConfig.remotePath %>"
                datemodified: "<%= grunt.template.today('yyyy-mm-dd') %>T<%= grunt.template.today('HH:MM:sso') %>"
                datepublished: "<%= appConfig.date %>"
            dev:
                files: [{
                    expand: true
                    dot: true
                    cwd: '<%= appConfig.paths.app %>'
                    src: [
                        '**/*.hbs'
                        '!scripts/**/*'
                        '!bower_components/**/*'
                    ]
                    dest: '.tmp'
                }]
                options:
                    imagePath: "images"
                    scriptPath: "scripts"
                    stylePath: "styles"
                    environment: "dev"
            production:
                files: [{
                    expand: true
                    dot: true
                    cwd: '<%= appConfig.paths.app %>'
                    src: [
                        '**/*.hbs'
                        '!scripts/**/*'
                        '!bower_components/**/*'
                    ]
                    dest: '.tmp'
                }]
                options:
                    imagePath: "#{appConfig.remotePath}images"
                    scriptPath: "#{appConfig.remotePath}scripts"
                    stylePath: "#{appConfig.remotePath}styles"
                    environment: "production"
            cardpages:
                options:
                    pages: cardPages
                    layout: false
                files: [{
                    dest: '.tmp/'
                    src: '!*'
                }]
        jshint:
            options: jshintrc: '.jshintrc'
            all: [
                'Gruntfile.js'
                '<%= appConfig.paths.app %>/scripts/**/*.{js,json}'
                '!<%= appConfig.paths.app %>/scripts/vendor/**/*'
                '!<%= appConfig.paths.app %>/scripts/data/*'
            ]
        coffee: dist:
            options: sourceMap: true
            files: [ {
                expand: true
                cwd: '<%= appConfig.paths.app %>/scripts'
                src: '**/*.coffee'
                dest: '.tmp/scripts'
                rename: (dest, src) ->
                    filename = src.replace(/\.coffee$/gi, '.js')
                    dest + '/' + filename

            } ]
        postcss:
            server:
                files: [{
                    expand: true
                    dot: true
                    cwd: '<%= appConfig.paths.tmp %>/styles'
                    src: '**/*.css'
                    dest: '.tmp/styles'
                }]
                options:
                    map: true
                    processors: [
                        require('autoprefixer-core')({browsers: appConfig.supported_browsers})
                        require('csswring')
                    ]
            dist:
                files: [{
                    expand: true
                    dot: true
                    cwd: '<%= appConfig.paths.tmp %>/styles'
                    src: '**/*.css'
                    dest: '.tmp/styles'
                }]
                options:
                    map: false
                    processors: [
                        require('autoprefixer-core')({browsers: appConfig.supported_browsers})
                        require('csswring')
                    ]
        compass:
            options:
                sassDir: '<%= appConfig.paths.app %>/styles'
                cssDir: '.tmp/styles'
                generatedImagesDir: '.tmp/images/generated'
                imagesDir: '<%= appConfig.paths.app %>/images'
                javascriptsDir: '<%= appConfig.paths.app %>/scripts'
                fontsDir: '<%= appConfig.paths.app %>/styles/fonts'
                importPath: '<%= appConfig.paths.app %>/bower_components'
                httpImagesPath: '/images'
                httpGeneratedImagesPath: '/images/generated'
                httpFontsPath: '/styles/fonts'
                relativeAssets: false
                sourcemap: true
                assetCacheBuster: false
                raw: 'asset_cache_buster :none\n'
            dist:
                options:
                    generatedImagesDir: '<%= appConfig.paths.dist %>/images/generated'
            staticdist:
                options:
                    httpImagesPath: '<%= appConfig.remotePath %>images'
                    generatedImagesDir: '<%= appConfig.paths.dist %>/images/generated'
            server: options: debugInfo: false
        requirejs:
            dist:
                options:
                    baseUrl: '.tmp/scripts'
                    optimize: 'none'
                    preserveLicenseComments: false
                    useStrict: true
                    wrap: true
                    stubModules: [
                        'text'
                        'hbs'
                    ]
                    paths:
                        'requireLib': '../bower_components/requirejs/require'
                        'Handlebars': '../bower_components/handlebars/handlebars.runtime'
                    include: [ 'requireLib' ]
        rev:
            dist:
                files:
                    src: [
                        '<%= appConfig.paths.dist %>/scripts/**/*.js'
                        '<%= appConfig.paths.dist %>/styles/**/*.css'
                        '<%= appConfig.paths.dist %>/styles/fonts/*'
                    ]
        useminPrepare:
            options: dest: '<%= appConfig.paths.dist %>'
            html: '<%= appConfig.paths.tmp %>/*.html'
        usemin:
            options: dirs: [ '<%= appConfig.paths.dist %>' ]
            html: [ '<%= appConfig.paths.dist %>/**/*.html' ]
            css: [ '<%= appConfig.paths.dist %>/styles/**/*.css' ]
        imagemin: dist: files: [ {
            expand: true
            cwd: '<%= appConfig.paths.app %>/images'
            src: '**/*.{png,jpg,jpeg}'
            dest: '<%= appConfig.paths.dist %>/images'
        } ]
        svgmin: dist: files: [ {
            expand: true
            cwd: '<%= appConfig.paths.app %>/images'
            src: '**/*.svg'
            dest: '<%= appConfig.paths.dist %>/images'
        } ]
        cssmin: {}
        htmlmin: dist:
            options: {}
            files: [ {
                expand: true
                cwd: '<%= appConfig.paths.tmp %>'
                src: '*.html'
                dest: '<%= appConfig.paths.dist %>'
            } ]
        copy:
            html: files: [ {
                expand: true
                cwd: '<%= appConfig.paths.app %>/'
                src: [
                    '**/*.html'
                    '!scripts/**/*.html'
                ]
                dest: '<%= appConfig.paths.tmp %>/'
            } ]
            tmp: files: [
                {
                    expand: true
                    dot: true
                    cwd: '<%= appConfig.paths.app %>'
                    dest: '.tmp'
                    src: [ 'bower_components/**' ]
                }
                {
                    expand: true
                    dot: true
                    cwd: '<%= appConfig.paths.app %>'
                    dest: '.tmp'
                    src: [ 'scripts/templates/**/*' ]
                }
                {
                    expand: true
                    dot: true
                    cwd: '<%= appConfig.paths.app %>/scripts/'
                    dest: '.tmp/scripts/'
                    src: [
                        '**/*.js'
                        '**/*.json'
                        '**/*.html'
                    ]
                }
                {
                    expand: true
                    dot: true
                    cwd: '<%= appConfig.paths.app %>/static/'
                    dest: 'dist/static/'
                    src: [ '**/*' ]
                }
            ]
            dist: files: [
                {
                    expand: true
                    dot: true
                    cwd: '<%= appConfig.paths.app %>'
                    dest: '<%= appConfig.paths.dist %>'
                    src: [
                        '*.{ico,png,txt}'
                        '.htaccess'
                        'images/**/*.{webp,gif}'
                        'styles/fonts/*'
                        'assets/**/*'
                    ]
                }
                {
                    expand: true
                    cwd: '<%= appConfig.paths.tmp %>'
                    src: '*.html'
                    dest: '<%= appConfig.paths.dist %>'
                }
            ]
            styles:
                expand: true
                dot: true
                cwd: '<%= appConfig.paths.app %>/styles'
                dest: '.tmp/styles/'
                src: '**/*.css'
        concurrent:
            server: [
                'copy:html'
                #"assemble:dev"
                'compass:server'
                'coffee:dist'
                'copy:styles'
            ]
            dist: [
                'coffee'
                #"assemble:dev"
                #"assemble:cardpages"
                'compass:dist'
                'copy:styles'
                'imagemin'
                'svgmin'
            ]
            staticdist: [
                'coffee'
                'compass:staticdist'
                #"assemble:production"
                #"assemble:cardpages"
                'copy:styles'
                'imagemin'
                'svgmin'
            ]
        compress: dist:
            options: archive: 'dist-zips/<%= pkg.name %>-<%= pkg.version %>.zip'
            files: [ {
                cwd: 'dist/'
                src: [ '**' ]
                dest: ''
                expand: true
            } ]
    grunt.registerTask 'server', (target) ->
        if target == 'dist'
            return grunt.task.run([
                'build'
                'open'
                'connect:dist:keepalive'
            ])
        
        grunt.task.run [
            'clean:server'
            'concurrent:server'
            'postcss:server'
            'connect:livereload'
            'watch'
        ]
    buildTask = [
        'clean:dist'
        'copy:html'
        'useminPrepare'
        'copy:tmp'
        'concurrent:dist'
        'postcss:dist'
        'requirejs'
        'concat'
        'copy:dist'
        'usemin'
        'string-replace:onerequirejsfile'
        'clean:requirejsonefile'
        'clean:emptyfolders'
    ]
    staticbuildTask = [
        'clean:dist'
        'copy:html'
        'useminPrepare'
        'copy:tmp'
        'concurrent:staticdist'
        'postcss:dist'
        'requirejs'
        'concat'
        'cssmin'
        'uglify'
        'copy:dist'
        'usemin'
        'string-replace:onerequirejsfile'
        'string-replace:staticserver'
        'clean:requirejsonefile'
        'clean:emptyfolders'
    ]
    
    grunt.registerTask "default", () ->
        grunt.task.run buildTask
        
    grunt.registerTask "staticbuild", () ->
        grunt.task.run staticbuildTask