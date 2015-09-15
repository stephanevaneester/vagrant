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
        jade: {
            www: {
                files: {
                    "www/index.html": "src/index.jade"
                }
            }
        },

        less: {
            www: {
                files: {
                    "www/main.css": "src/main.less"
                }
            }
        },

        copy: {
            www: {
                files: [{
                    expand: true,
                    cwd: 'src/',
                    src: ['app.js', 'f3/**/*.*', 'api/**/*.*'],
                    dest: 'www/'
                    }]
            }
        },

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
            }
        },

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
                    port: 58080
                }
            }
        }

    });
    grunt.registerTask('start', ['browserSync', 'watch']);
    grunt.registerTask('build', ['jade', 'less', 'newer:copy']);
}