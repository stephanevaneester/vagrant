//  ___ _____ ___ _  ___  _____ 
// / __|_   _| __| |/ / |/ / __|
// \__ \ | | | _|| ' <| ' <| _| 
// |___/ |_| |___|_|\_\_|\_\___|
//
// BEST GRUNTFILE EVER

module.exports = function (grunt) {
    // Autoload grunt tasks
    require('load-grunt-tasks')(grunt);
    grunt.initConfig({

        // JADE
        jade: {
            www: {
                files: [{
                    cwd: 'src/',
                    src: '**/*.jade',
                    dest: 'www/',
                    expand: true,
                    ext: '.html'
                    }]
            }
        },

        // LESS
        less: {
            www: {
                files: {
                    "www/main.css": "src/main.less"
                }
            }
        },

        // COPY
        copy: {
            www: {
                files: [{
                    expand: true,
                    cwd: 'src/',
                    src: ['app.js', 'f3/**/*.*', 'api/**/*.*', 'img/**/*.svg'],
                    dest: 'www/'
                    }]
            },
            fonts: {
                files: [{
                    expand: true,
                    flatten: true,
                    src: ['bower_components/bootstrap/fonts/*.*'],
                    dest: 'www/fonts/'
                    }]
            }
        },

        //WATCH
        watch: {
            less: {
                files: 'src/**/*.less',
                tasks: ['less', 'autoprefixer'],
                options: {
                    spawn: false,
                },              
            },
            jade: {
                files: 'src/**/*.jade',
                tasks: ['jade']   ,
                options: {
                    spawn: false,
                },             
            },
            copy: {
                files: 'src/**/*.*',
                tasks: ['newer:copy'],
                options: {
                    spawn: false,
                },
            },
            bower: {
                files: 'bower_components/**/*.*',
                tasks: ['bower_concat'],
                options: {
                    spawn: false,
                },
            }
        },

        // BROWSERSYNC
        browserSync: {
            www: {
                bsFiles: {
                    src: [
                        'www/index.html',
                        'www/main.css',
                        'www/app.js',
                        'www/pages/*.html'
                    ]
                },
                options: {
                    watchTask: true,
                    proxy: 'http://localhost:58080/',
                    port: 58080,
                    open: false
                }
            }
        },

        // BOWER CONCAT
        bower_concat: {
            www: {
                dest: 'www/_bower.js',
                cssDest: 'www/_bower.css',
                mainFiles: {
                    'bootstrap' : 'dist/css/bootstrap.css'
                },
                exclude: [
                    'Skeleton-Less',
                    'normalize.less'
                ]
            }
        },

        // AUTOPREFIX CSS
        autoprefixer: {
            www: {
                files: {
                    'www/main.css': 'www/main.css'
                }
            }
        }
        
    });
    grunt.registerTask('start', ['browserSync', 'watch']);
    grunt.registerTask('build', ['jade', 'less', 'autoprefixer', 'newer:copy', 'bower_concat']);
}