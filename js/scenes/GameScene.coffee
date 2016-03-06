class GameScene extends BaseScene
  inputId: 0
  game: {}
  players: []
  inputs: []
  queue: [] # for enemey inputs

  init: ->
    @scene.add Helper.ambientLight()

    nm.emit(type: 'join', name: 'kiki')

  discardAcknowledgedInputs: (lastAckInputId) ->
    @inputs = (input for input in @inputs when input.inputId > lastAckInputId)

  gameTick: (data) ->
    @game = data.game
    player = @getPlayer(@key)
    if player?
      player.mesh.position.x = data.game[@key].position.x
      @discardAcknowledgedInputs(data.game[@key].lastAckInputId)
      player.move(@inputs)

  join: (data) ->
    @game[data.id] = data
    player = new Player()
    player.id = data.id
    @scene.add player.mesh
    @scene.add player.ghost
    @players.push player
    player.mesh.position.x = @game[player.id].position.x

  disconnect: (data) ->
    player = @getPlayer(data.id)
    if player?
      @scene.remove player.mesh
      @scene.remove player.ghost
      @players.remove player

  getPlayer: (key) ->
    for player in @players
      if key == player.id
        return player

  tick: (tpf) ->
    hash =
      inputId: @inputId
      type: 'move'
      tpf: tpf
      direction:
        x: 0

    if @keyboard.pressed('a')
      hash.direction.x = -5
    if @keyboard.pressed('d')
      hash.direction.x = 5

    nm.emit(hash)
    @inputs.push hash

    for player in @players
      player.ghost.position.x = @game[player.id].position.x

      if player.id == @key
        player.move(hash)
      else
        player.interpolate(tpf)

    @inputId += 1

  doMouseEvent: (event, raycaster) ->

  doKeyboardEvent: (event) ->
