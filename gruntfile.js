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
        copy: {
            dist: {
                files: [{
                    expand: true,
                    cwd: 'src/',
                    src: ['**/*.php'],
                    dest: 'www/wp-content/themes/angular/'
                }]
            }
        },

        less: {
            dist: {
                files: {
                    "www/wp-content/themes/angular/css/custom.css": "src/less/custom.less"
                }
            }
        },   

        watch: {
            less: {
                files: 'src/**/*.less',
                tasks: ['less']                
            },
            copy: {
                files: 'src/**/*.php',
                tasks: ['copy']                
            }
        },

    });
    grunt.registerTask('default', ['watch']);
    grunt.registerTask('build', ['copy', 'less']);
}