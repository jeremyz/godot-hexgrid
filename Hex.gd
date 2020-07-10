#warning-ignore-all:unused_argument
extends Tile

class_name Hex, "res://godot/Tile.png"

var type : int = -1

func _ready() -> void:
	type = -1

func inspect() -> String:
	var s : String = 'plain'
	if type == 0: s = 'city'
	elif type == 1: s = 'wood'
	elif type == 2: s = 'mountain'
	return "%s e:%d h:%d c:%d\n -> [%d;%d]\n -> (%d;%d)" % [s, elevation(), height(), cost(), coords.x, coords.y, position.x, position.y]

func change() -> void:
	type = (type + 2) % 4 - 1
	for i in range(3):
		enable_overlay(i + 2, i == type)

func cost() -> int:
	if type == -1: return 1
	return type + 1

func height() -> int:
	if type == 0: return 2
	elif type == 1: return 1
	elif type == 2: return 0
	return 0

func elevation() -> int:
	if type == 2: return 2
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
	if b: enable_overlay((1 if blocked else 0), true)
	else:
		enable_overlay(0, false)
		enable_overlay(1, false)

func show_move(b) -> void:
	if 5 < get_child_count():
		enable_overlay(5, b)
