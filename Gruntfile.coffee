module.exports = ( grunt ) ->

  grunt.initConfig
    pkg : grunt.file.readJSON "package.json"

    coffeelint :
      app: ['lib/**/*.coffee', "*.coffee"]

    clean :
      dist : [ "dist", "*.{js,map}", "lib/**/*.{map,js}" ]

    coffee :
      options :
        sourceMap : false
        bare : true
        force : true

      dist :
        expand : true
        src : [ "lib/**/*.coffee", "*.coffee", "!Gruntfile.coffee" ]
        dest : "dist"
        ext : '.js'

  for t in [ "contrib-coffee", "contrib-clean", "coffeelint" ]
    grunt.loadNpmTasks "grunt-#{t}"

  grunt.registerTask "default", [ "coffeelint", "clean:dist", "coffee:dist" ]

