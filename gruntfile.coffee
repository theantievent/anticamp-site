module.exports = (grunt) ->

  grunt.initConfig
    pkg: grunt.file.readJSON "package.json"

    meta:
      package: "package",
      banner : """
        /* <%= pkg.name %> v<%= pkg.version %> - <%= grunt.template.today("m/d/yyyy") %>
           <%= pkg.homepage %>
           Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %> - Licensed <%= _.pluck(pkg.license, "type").join(", ") %> */

        """
    # =========================================================================

    source:
      coffee: [
        "src/*.coffee",
        "src/models/*.coffee",
        "src/views/*.coffee",
        "src/controllers/*.coffee"]
      sass: [
        "src/stylesheets/site.*.scss"]
      sass_files: [
        "src/stylesheets/sass/*.scss"]
      jade: [
        "src/jades/base.jade"]
      jade_files: [
        "src/jades/*.jade"]

    components:
      js: [
        "components/jquery/jquery.js",
        "components/jquery.stellar/jquery.stellar.min.js",
        "components/sidr/jquery.sidr.min.js",
        "components/monocle/monocle.js",
        "components/appnima.js/appnima.js",
        "components/hope/hope.js",
        "components/device.js/device.js",
        "components/tuktuk/tuktuk.js"]
      css: [
        # "components/tuktuk/tuktuk.css",
         "components/sidr/stylesheets/jquery.sidr.light.css",
        "components/tuktuk/tuktuk.icons.css"]

    # =========================================================================
    coffee:
      core: files: "build/<%=pkg.name%>.<%=pkg.version%>.debug.js": "<%= source.coffee %>"

    uglify:
      options: compress: false, banner: "<%= meta.banner %>"
      core: files: "<%=meta.package%>/javascripts/<%=pkg.name%>.<%=pkg.version%>.js": "build/<%=pkg.name%>.<%=pkg.version%>.debug.js"

    sass:
      dist:
        options: style: "expanded"
        files:
          "<%=meta.package%>/stylesheets/<%=pkg.name%>.<%=pkg.version%>.css": "<%=source.sass%>"

    jade:
      compile:
        options: data: debug: true
        files:   "<%=meta.package%>/index.html": "<%= source.jade %>"

    concat:
      js:
        src: "<%= components.js %>", dest: "<%=meta.package%>/javascripts/<%=pkg.name%>.components.js"
      css:
        src: "<%= components.css %>", dest: "<%=meta.package%>/stylesheets/<%=pkg.name%>.components.css"

    watch:
      coffee:
        files: ["<%= source.coffee %>"]
        tasks: ["coffee", "uglify"]
      sass:
        files: ["<%= source.sass_files %>"]
        tasks: ["sass"]
      jade:
        files: ["<%= source.jade_files %>"]
        tasks: ["jade"]
      components:
        files: ["<%= components.js %>", "<%= components.css %>"]
        tasks: ["concat"]

  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.loadNpmTasks "grunt-contrib-sass"
  grunt.loadNpmTasks "grunt-contrib-jade"
  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-contrib-watch"

  grunt.registerTask "default", [ "concat", "coffee", "uglify", "sass", "jade"]
