'use strict'

WebSocketServer = require('ws').Server
childProces = require 'child_process'

pid = null 

class Server
  constructor: (opts) ->
    @path = process.cwd()
    @port = 30080
    @spawnOpt = stdio: 'inherit'

    @sessions = []

    @storePid = (pid) -> 
      @electronPid = pid 

    if opts?.useGlobalElectron
      @electron = 'electron'
    else
      try
        @electron = require 'electron-prebuilt'
      catch e
        if e.code == 'MODULE_NOT_FOUND'
          @log 'electron-prebuilt not found, trying global electron'
          @electron = 'electron'

  log: (msg) ->
    console.log '[' + (new Date).toISOString() + '] [electron-livereload] [server]', msg
    return

  spawn: (args, spawnOpt, cb) ->
    electronProc = childProces.spawn(@electron, [ @path ].concat(args), spawnOpt)

    electronProc.on 'error', (err) =>
      @log 'unable to start electron from ' + @path + '/' + @electron

    @storePid electronProc.pid 

    return

  start: (args = []) ->

    @wss = new WebSocketServer { port: @port }, =>
      @spawn args, @spawnOpt

    @wss.on 'connection', (ws) =>

      ws.on 'message', (message) =>
        { type, data, id } = JSON.parse message

        @log 'receive message from client(window_id: ' + id + ') ' + message
        
        messageHandler type, data, ws

      ws.on 'close', =>
        @log 'client closed.'

    return

  sendMessage: (ws, type, data = null) ->
    ws.send JSON.stringify(type: type, data: data)
    return

  messageHandler: (type, data, ws) ->
    switch type 
      when 'changeBounds'
        ws.bounds = data.bounds
      when 'getBounds'
        @sendMessage ws, 'setBounds', bounds: ws.bounds

    return

  restart: (args, cb) ->
    @stop()
    @wss.close()
    
    process.nextTick =>
      @start()

    @log 'restart electron process'

    return

  stop: ->
    @log 'kill electron process'
    process.kill @electronPid, 'SIGHUP'

    return

  reload: ->
    @wss.clients.forEach (ws) =>
      @sendMessage ws, 'reload'

    return

module.exports = Server