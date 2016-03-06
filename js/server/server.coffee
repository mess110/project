#!/usr/bin/env coffee

server = require('../../../../../src/server/server.coffee') # for dev
# server = require('../../bower_components/coffee-engine/src/server/server.coffee')
common = require('../common.coffee').common

config =
  pod:
    guid: server.Utils.guid()
    dirname: __dirname
    version: 1
    port: 1337
  gameServer:
    ticksPerSecond: 5
    ioMethods: ['join', 'move']

class GameServer extends server.GameServer
  game: {}
  inputs: []

  gameTick: =>
    for input in @inputs
      continue unless @game[input.id]?
      common.move(@game[input.id], input)
      @game[input.id].lastAckInputId = input.inputId
    @inputs.clear()

    for key of @game
      pod.socket(key).emit('gameTick', game: @game)

  move: (socket, data) ->
    data.id = socket.id
    @inputs.push data

  join: (socket, data) ->
    data.id = socket.id
    data.position = { x: 0 }
    @game[socket.id] = data

    for key in pod.keys()
      pod.socket(key).emit('join', data)
      if key != socket.id
        socket.emit('join', @game[key])

  disconnect: (socket) ->
    delete @game[socket.id]
    pod.broadcast('disconnect', id: socket.id)

gameServer = new GameServer(config.gameServer)
pod = new server.Pod(config.pod, gameServer)
pod.listen()
