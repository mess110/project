class Fighter extends BaseModel
  constructor: ->
    @mesh = Helper.cube()
    @ghost = Helper.cube()
    @ghost.material.wireframe = true
    @ghost.position.y += 1

class GameScene extends BaseScene
  inputId: 0
  game: {}
  players: []
  inputs: []
  queue: [] # for enemey inputs

  init: ->
    @scene.add Helper.ambientLight()

    nm.emit(type: 'join', name: 'kiki')

  gameTick: (data) ->
    for key of data.game
      cube = @getCube(key)
      if cube?
        if key == @key
          cube.mesh.position.x = data.game[key].position.x
          # reconcile the player position with unacknowledged inputs
          @inputs = (input for input in @inputs when input.inputId > data.game[key].lastAckInputId)
          for input in @inputs
            cube.mesh.position.x += input.direction.x * input.tpf

    @game = data.game

  join: (data) ->
    @game[data.id] = data
    cube = new Fighter()
    cube.id = data.id
    @scene.add cube.mesh
    @scene.add cube.ghost
    @players.push cube
    cube.mesh.position.x = @game[cube.id].position.x

  disconnect: (data) ->
    cube = @getCube(data.id)
    if cube?
      @scene.remove cube.mesh
      @scene.remove cube.ghost
      @players.remove cube

  getCube: (key) ->
    for cube in @players
      if key == cube.id
        return cube

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

    for cube in @players
      if cube.ghost?
        cube.ghost.position.x = @game[cube.id].position.x

      if cube.id == @key
        cube.mesh.position.x += hash.direction.x * tpf
      else
        # TODO: find a nice way to interpolate
        if cube.mesh.position.x < cube.ghost.position.x
          cube.mesh.position.x += 5 * tpf
        if cube.mesh.position.x > cube.ghost.position.x
          cube.mesh.position.x -= 5 * tpf

    @inputId += 1

  doMouseEvent: (event, raycaster) ->

  doKeyboardEvent: (event) ->
