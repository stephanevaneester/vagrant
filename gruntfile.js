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
                files: {
                    "www/index.html": "src/index.jade"
                }
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
                tasks: ['less']                
            },
            jade: {
                files: 'src/**/*.jade',
                tasks: ['jade']                
            },
            copy: {
                files: 'src/**/*.*',
                tasks: ['newer:copy']
            },
            bower: {
                files: 'bower_components/**/*.*',
                tasks: ['bower_concat']
            }
        },

        // BROWSERSYNC
        browserSync: {
            www: {
                bsFiles: {
                    src: [
                        'www/index.html',
                        'www/main.css',
                        'www/app.js'
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
                    'Skeleton-Less'
                ]
            }
        },
        
    });
    grunt.registerTask('start', ['browserSync', 'watch']);
    grunt.registerTask('build', ['jade', 'less', 'newer:copy', 'bower_concat']);
}