extends Sprite

signal configure(center, texture_size)
signal hex_touched(pos, hex, key)

const MAPH : String = "res://assets/map-h.png"
const MAPV : String = "res://assets/map-v.png"
const BLOCK : String = "res://assets/block.png"
const BLACK : String = "res://assets/black.png"
const MOVE : String = "res://assets/move.png"
const GREEN : String = "res://assets/green.png"
const TREE : String = "res://assets/tree.png"
const CITY : String = "res://assets/city.png"
const MOUNT : String = "res://assets/mountain.png"

var drag : Sprite

var board : HexBoard
var prev : Vector2
var hexes : Dictionary
var hex_rotation : int
var p0 : Vector2
var p1 : Vector2
var los : Array
var move : Array
var unit : Unit
var show_los : bool
var show_move : bool

func _ready():
	board = HexBoard.new()
	board.tile_factory_fct = funcref(self, "get_tile")
	board.v = false
	drag = null
	hexes = {}
	los = []
	unit = Unit.new()

func reset() -> void:
	hexes.clear()
	hexes[-1] = Hex.new()	# off map

func get_tile(coords : Vector2, k : int) -> Tile:
	if hexes.has(k): return hexes[k]
	var hex : Hex = Hex.new()
	hex.roads = get_road(k)
	hex.rotation_degrees = hex_rotation
	hex.configure(board.center_of(coords), coords, [GREEN, BLACK, CITY, TREE, MOUNT, BLOCK, MOVE])
	hexes[k] = hex
	$Hexes.add_child(hex)
	return hex

func get_road(k : int) -> int:
	if not board.v: return 0
	var v : int = 0
	v += (HexBoard.Orientation.E if k in [19,20,21,23,24,42,43,44,45,46,47] else 0)
	v += (HexBoard.Orientation.W if k in [19,20,21,22,24,25,43,44,45,46,47] else 0)
	v += (HexBoard.Orientation.SE if k in [22,32,42,52,62] else 0)
	v += (HexBoard.Orientation.NW if k in [32,42,52,62] else 0)
	v += (HexBoard.Orientation.NE if k in [7,16,25,32] else 0)
	v += (HexBoard.Orientation.SW if k in [7,16,23] else 0)
	return v

func config(l : bool, m : bool) -> void:
	show_los = l
	show_move = m

func on_rotate() -> void:
	texture = load(MAPH if board.v else MAPV)
	var ts : Vector2 = texture.get_size()
	var v0 : Vector2 = Vector2(50, 100)
	var c = ts / 2
	if centered:
		if board.v:	
			v0.x -= ts.y / 2
			v0.y -= ts.x / 2
		else:
			v0 -= ts / 2
		c = Vector2(0, 0)
	if board.v:
		hex_rotation = 30
		board.configure(10, 4, 100, v0, false)
	else:
		hex_rotation = 0
		board.configure(10, 7, 100, v0, true)
	emit_signal("configure", c, ts)
	p0 = Vector2(0, 0)
	p1 = Vector2(3, 3)
	$Tank.position = board.center_of(p0)
	$Target.position = board.center_of(p1)
	for hex in $Hexes.get_children():
		$Hexes.remove_child(hex)
		hex.queue_free()
	reset()
	update()

func on_mouse_move() -> void:
	if drag != null:
		drag.position = get_local_mouse_position()

func on_mouse_1(pressed : bool) -> void:
	var pos : Vector2 = get_local_mouse_position()
	var coords : Vector2 = board.to_map(pos)
	if pressed:
		notify(board.get_tile(coords), pos, coords)
		if drag == null:
			prev = coords
			if board.to_map($Tank.position) == coords:
				drag = $Tank
			elif board.to_map($Target.position) == coords:
				drag = $Target
	else:
		if drag:
			if board.is_on_map(coords):
				drag.position = board.center_of(coords)
				if drag == $Tank: p0 = coords
				else: p1 = coords
				update()
			else:
				drag.position = board.center_of(prev)
		drag = null

func on_mouse_2(pressed : bool) -> void:
	var pos : Vector2 = get_local_mouse_position()
	var coords : Vector2 = board.to_map(pos)
	if pressed:
		var hex : Hex = board.get_tile(coords)
		hex.change()
		notify(hex, pos, coords)
		update()

func notify(hex : Hex, pos : Vector2, coords : Vector2) -> void:
	if board.is_on_map(coords): emit_signal("hex_touched",pos, hex, board.key(coords))
	else: emit_signal("hex_touched", pos, hex, -1)

func update() -> void:
	$Los.visible = false
	for hex in los: hex.show_los(false)
	if show_los:
		$Los.visible = true
		var ct : Vector2 = board.line_of_sight(p0, p1, los)
		$Los.setup($Tank.position, $Target.position, ct)
		for hex in los: hex.show_los(true)
	for hex in move: hex.show_move(false)
	if show_move:
		# warning-ignore:return_value_discarded
		board.possible_moves(unit, board.get_tile(p0), move)
		for hex in move: hex.show_move(true)
