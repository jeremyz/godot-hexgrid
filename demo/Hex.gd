@icon('res://addons/hexgrid/Tile.png')
extends Tile

class_name Hex

var type : int = -1
var roads : int = 0

func _ready() -> void:
	type = -1

func inspect() -> String:
	var s : String = 'plain'
	if type == 0: s = 'city'
	elif type == 1: s = 'wood'
	elif type == 2: s = 'mountain'
	elif type == 3: s = 'blocked'
	return "[%d;%d]\n -> (%d;%d)\n -> %s\ne:%d h:%d c:%d r:%d" % [coords.x, coords.y, position.x, position.y, s, elevation(), height(), cost(), roads]

func has_road(o : int) -> bool:
	return (o & roads) > 0

func change() -> void:
	type = (type + 2) % 5 - 1
	for i in range(4):
		enable_overlay(i + 3, i == type)

func cost() -> int:
	if type == -1: return 1
	elif type == 3: return -1
	return type + 1

func height() -> int:
	if type == 0: return 2
	elif type == 1: return 1
	elif type == 2: return 0
	return 0

func elevation() -> int:
	if type == 2: return 3
	return 0

@warning_ignore("unused_parameter")
func range_modifier(category : int) -> int:
	return (1 if type == 2 else 0)

@warning_ignore("unused_parameter")
func attack_modifier(category : int, orientation : int) -> int:
	return (2 if type == 1 else 0)

@warning_ignore("unused_parameter")
func defense_value(category : int, orientation : int) -> int:
	if type == 0: return 2
	elif type == 1: return 1
	elif type == 2: return 1
	return 0

func block_los(from : Tile, to : Tile, d : float, dt : float) -> bool:
	var h : int = height() + elevation()
	if h == 0: return false
	var e : int = from.elevation()
	if e > h:
		if to.elevation() > h: return false
		return (h * dt / (e - h)) >= (d - dt)
	h -= e
	return ((h * d / dt) >= to.elevation() - e)

func show_los(b) -> void:
	if b: enable_overlay((2 if blocked else 1), true)
	else:
		enable_overlay(1, false)
		enable_overlay(2, false)

func show_move(b) -> void:
	enable_overlay(7, b)

func show_short(b) -> void:
	enable_overlay(8, b)

func show_influence(b) -> void:
	var s : Sprite2D = get_child(0)
	s.modulate = Color(f/10.0, 0, 0)
	enable_overlay(0, b)
