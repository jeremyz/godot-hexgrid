extends Sprite2D

signal hex_touched(pos, hex, key)

const MAPH : String = "res://demo/assets/map-h.png"
const MAPV : String = "res://demo/assets/map-v.png"
const BLOCK : String = "res://demo/assets/block.png"
const BLACK : String = "res://demo/assets/black.png"
const MOVE : String = "res://demo/assets/move.png"
const SHORT : String = "res://demo/assets/short.png"
const RED : String = "res://demo/assets/red.png"
const GREEN : String = "res://demo/assets/green.png"
const TREE : String = "res://demo/assets/tree.png"
const CITY : String = "res://demo/assets/city.png"
const MOUNT : String = "res://demo/assets/mountain.png"

var drag : Sprite2D

var board : HexMap
var prev : Vector2
var hexes : Dictionary
var hex_rotation : int
var p0 : Vector2
var p1 : Vector2
var los : Array
var move : Array
var short : Array
var influence : Array
var unit : Unit
var show_los : bool
var show_move : bool
var show_influence : bool

func _ready():
	drag = null
	unit = Unit.new()
	rotate_map()

func reset() -> void:
	los.clear()
	move.clear()
	short.clear()
	influence.clear()
	hexes.clear()
	hexes[-1] = Hex.new()	# off map
	p0 = Vector2(0, 0)
	p1 = Vector2(3, 3)
	$Tank.position = board.center_of(p0)
	$Target.position = board.center_of(p1)
	for hex in $Hexes.get_children():
		$Hexes.remove_child(hex)
		hex.queue_free()
	compute()

func rotate_map() -> void:
	texture = load(MAPH if is_instance_valid(board) and board.v else MAPV)
	configure()
	reset()

func set_mode(l : bool, m : bool, i : bool) -> void:
	show_los = l
	show_move = m
	show_influence = i
	compute()

func configure() -> void:
	var v : bool = (is_instance_valid(board) and board.v)
	var v0 : Vector2 = Vector2(50, 100)
	if centered:
		var ts : Vector2 = texture.get_size()
		if v:
			v0.x -= ts.y / 2
			v0.y -= ts.x / 2
		else:
			v0 -= ts / 2
	if v:
		hex_rotation = 30
		board = HexMap.new(10, 4, 100, v0, false, get_tile)
	else:
		hex_rotation = 0
		board = HexMap.new(10, 7, 100, v0, true, get_tile)

func texture_size() -> Vector2:
	return texture.get_size()

func center() -> Vector2:
	return Vector2(0, 0) if centered else texture.get_size() / 2

func on_mouse_move() -> void:
	if drag != null:
		drag.position = get_local_mouse_position()

func on_click(pressed : bool) -> bool:
	var pos : Vector2 = get_local_mouse_position()
	var coords : Vector2 = board.to_map(pos)
	if pressed:
		notify(pos, coords)
		prev = coords
		if board.to_map($Tank.position) == coords:
			drag = $Tank
		elif board.to_map($Target.position) == coords:
			drag = $Target
		else:
			return true
	else:
		if drag:
			if board.is_on_map(coords):
				drag.position = board.center_of(coords)
				if drag == $Tank: p0 = coords
				else: p1 = coords
				notify(pos, coords)
				compute()
			else:
				drag.position = board.center_of(prev)
			drag = null
		else:
			if coords == prev and board.is_on_map(coords):
				change_tile(coords, pos)
	return false

func change_tile(coords : Vector2, pos : Vector2) -> void:
	var hex : Hex = board.get_tile(coords)
	hex.change()
	notify(pos, coords)
	compute()

func get_tile(coords : Vector2, k : int) -> Tile:
	if hexes.has(k): return hexes[k]
	var hex : Hex = Hex.new()
	hex.roads = get_road(k)
	hex.rotation_degrees = hex_rotation
	hex.configure(board.center_of(coords), coords, [RED, GREEN, BLACK, CITY, TREE, MOUNT, BLOCK, MOVE, SHORT])
	hexes[k] = hex
	$Hexes.add_child(hex)
	return hex

func get_road(k : int) -> int:
	if not board.v: return 0
	var v : int = 0
	v += (HexMap.Orientation.E if k in [19,20,21,23,24,42,43,44,45,46,47] else 0)
	v += (HexMap.Orientation.W if k in [19,20,21,22,24,25,43,44,45,46,47] else 0)
	v += (HexMap.Orientation.SE if k in [22,32,42,52,62] else 0)
	v += (HexMap.Orientation.NW if k in [32,42,52,62] else 0)
	v += (HexMap.Orientation.NE if k in [7,16,25,32] else 0)
	v += (HexMap.Orientation.SW if k in [7,16,23] else 0)
	return v

func notify(pos : Vector2, coords : Vector2) -> void:
	emit_signal("hex_touched", pos, board.get_tile(coords), (board.key(coords) if board.is_on_map(coords) else -1))

func compute() -> void:
	$Los.visible = false
	for hex in los: hex.show_los(false)
	if show_los:
		$Los.visible = true
		var ct : Vector2 = board.line_of_sight(p0, p1, los)
		$Los.setup($Tank.position, $Target.position, ct)
		for hex in los: hex.show_los(true)
	for hex in move: hex.show_move(false)
	for hex in short: hex.show_short(false)
	if show_move:
		# warning-ignore:return_value_discarded
		board.possible_moves(unit, board.get_tile(p0), move)
		# warning-ignore:return_value_discarded
		board.shortest_path(unit, board.get_tile(p0), board.get_tile(p1), short)
		for hex in move: hex.show_move(true)
		for i in range(1, short.size() -1): short[i].show_short(true)
	for hex in influence: hex.show_influence(false)
	if show_influence:
		# warning-ignore:return_value_discarded
		board.range_of_influence(unit, board.get_tile(p0), 0, influence)
		for hex in influence: hex.show_influence(true)
