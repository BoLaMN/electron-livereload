# electron-livereload

## electron main.js  
```
app     = require 'app'
window  = require 'browser-window'

livereload = require 'electron-livereload'

app.on 'ready', ->
  win = new window
    title: 'My App'
    'min-width': 520
    'min-height': 520
    frame: false
    resizable: true
    icon: 'assets/images/icon.png'
    transparent: true
    center: true

  win.loadUrl 'file://' + path.join __dirname, 'index.html'
  
  livereload.client win
```
## grunt example
```
livereload = require 'electron-livereload'

electron = livereload.server()

module.exports = (grunt) ->

  grunt.initConfig

    watch: 
      options: 
        nospawn: true # !IMPORTANT!
      client: 
        files: ['src/client/**/*.coffee'], tasks: ['coffee', 'reload-electron']
      server: 
        files: ['src/server/**/*.coffee'], tasks: ['coffee', 'restart-electron']
    
    grunt.registerTask 'start', (env) ->
      electron.start()
      grunt.task.run 'watch'
      
    grunt.registerTask 'restart-electron', ->
      electron.restart()
    
    grunt.registerTask 'reload-electron', ->
      electron.reload()
  ```

License: ISC 
