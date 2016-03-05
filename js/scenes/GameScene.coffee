class Fighter extends BaseModel
  constructor: ->
    @mesh = Helper.cube()

class GameScene extends BaseScene
  game: {}
  players: []
  inputs: []
  inputId: 0

  init: ->
    @scene.add Helper.ambientLight()

    @client = Helper.cube()
    @client.material.wireframe = true
    @scene.add @client

    nm.emit(type: 'join', name: 'kiki')

  gameTick: (data) ->
    for key of data.game
      @game[key] = data.game[key]
      cube = @getCube(key)
      if cube?
        cube.mesh.position.x = data.game[key].position.x

      inputs = (input for input in @inputs when input.inputId > data.game[key].lastAckInputId)
      for input in inputs
        mesh.position.x += input.direction.x * input.tpf

  join: (data) ->
    @game[data.id] = data
    cube = new Fighter()
    cube.id = data.id
    @scene.add cube.mesh
    @players.push cube
    cube.mesh.position.x = @game[cube.id].position.x

  disconnect: (data) ->
    cube = @getCube(data.id)
    if cube?
      @scene.remove cube.mesh
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

    if @key?
      asd = @getCube(@key)
      if asd?
        asd.mesh.position.x += hash.direction.x * tpf

        @client.position.x = @game[@key].position.x
    # for cube in @players
      # cube.mesh.position.x += @game[cube.id].direction.x * tpf
    @inputId += 1

  doMouseEvent: (event, raycaster) ->

  doKeyboardEvent: (event) ->
