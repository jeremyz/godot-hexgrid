extends Sprite

signal configure(center, texture_size)
signal hex_touched(pos, hex, key)

const MAPH : String = "res://assets/map-h.png"
const MAPV : String = "res://assets/map-v.png"
const BLOCK : String = "res://assets/block.png"
const BLACK : String = "res://assets/black.png"
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

func _ready():
	board = HexBoard.new()
	board.tile_factory_fct = funcref(self, "get_tile")
	board.v = false
	drag = null
	hexes = {}
	los = []

func reset() -> void:
	hexes.clear()
	hexes[-1] = Hex.new()	# off map

func get_tile(coords : Vector2, k : int) -> Tile:
	if hexes.has(k): return hexes[k]
	var hex : Hex = Hex.new()
	hex.rotation_degrees = hex_rotation
	hex.configure(board.center_of(coords), coords, [GREEN, BLACK, CITY, TREE, MOUNT])
	hexes[k] = hex
	$Hexes.add_child(hex)
	return hex

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
	update_los()

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
				update_los()
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
		update_los()

func notify(hex : Hex, pos : Vector2, coords : Vector2) -> void:
	if board.is_on_map(coords): emit_signal("hex_touched",pos, hex, board.key(coords))
	else: emit_signal("hex_touched", pos, hex, -1)

func update_los() -> void:
	for hex in los:
		hex.show_los(false)
	var ct : Vector2 = board.line_of_sight(p0, p1, los)
	$Los.setup($Tank.position, $Target.position, ct)
	for hex in los:
		hex.show_los(true)
