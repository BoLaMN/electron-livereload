'use strict'

WebSocket = require 'ws'

class Client
  @windowId: 0

  @getId: ->
    @windowId++

  constructor: (browserWindow, port, setBounds) ->
    @port = port or 30080
    @sendBounds = setBounds or true

    if browserWindow
      @browserWindow = browserWindow
    else if process.type is 'renderer' 
      @browserWindow =  require('remote').getCurrentWindow()

    @id = @browserWindow?.id or Client.getId()
    
    @socket = new WebSocket 'ws://localhost:' + @port + '/'
    
    @socket.on 'open', =>
      @log 'connected server'
      
      @socket.on 'message', (msg) =>
        { type, data } = JSON.parse(msg)

        if type 
          @log 'receive message: ' + msg

          @messageHandler type, data 

    return 

  log: (msg) ->
    console.log '[' + (new Date).toISOString() + '] [electron-livereload] [client: ' + @id + '] ' + msg
    return

  sendMessage: (type, data) ->
    @socket.send id: @id, type: type, data: data
    return

  messageHandler: (type, data) ->
    switch type 
      when 'reload'
        if @browserWindow
          currentUrl = @browserWindow.webContents.getUrl()
          @browserWindow.webContents.stop()      
          @browserWindow.webContents.destroy()
          @browserWindow.webContents._reloadIgnoringCache()
          @browserWindow.webContents.loadUrl currentUrl 

  close: ->
    @socket.terminate()
    return

module.exports = Client