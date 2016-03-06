#!/usr/bin/env coffee

# server = require('../../../../../src/server/server.coffee') # for dev
server = require('../../bower_components/coffee-engine/src/server/server.coffee')

config =
  guid: server.Utils.guid()
  dirname: __dirname
  version: 1
  port: 1337

class GameServer
  IO_METHODS: ['join', 'move']
  TICK: 1000 / 5
  TPF: @.TICK / 1000

  game: {}
  inputs: []
  meta:
    time: 0

  constructor: ->
    setInterval @tick, @.TICK

  tick: ->
    game = pod.gameServer.game
    inputs = pod.gameServer.inputs
    meta = pod.gameServer.meta

    for input in inputs
      continue unless game[input.id]?
      game[input.id].direction.x = input.direction.x
      game[input.id].position.x += input.direction.x * input.tpf
      game[input.id].lastAckInputId = input.inputId

    for key of game
      pod.socket(key).emit('gameTick', game: game, inputs: inputs, meta: meta)
    inputs.clear()

    meta.time += GameServer::TICK

  move: (socket, data) ->
    data.id = socket.id
    data.time = @meta.time
    @inputs.push data

  join: (socket, data) ->
    data.id = socket.id
    data.position =
      x: 0
    data.direction =
      x: 0
    @game[socket.id] = data
    pod.broadcast('join', data)
    for key in pod.keys()
      pod.socket(key).emit('join', data)
      if key != socket.id
        socket.emit('join', @game[key])

  connect: (socket) ->
    socket.emit('self', id: socket.id)

  disconnect: (socket) ->
    delete @game[socket.id]
    pod.broadcast('disconnect', id: socket.id)

gameServer = new GameServer()
pod = new server.Pod(config, gameServer)
pod.listen()
