#warning-ignore-all:unused_argument
extends Tile

class_name Hex, "res://godot/Tile.png"

func inspect() -> String:
	return "[%d;%d] %s" % [coords.x,coords.y,not blocked] 

func block(b : bool) -> void:
	enable_overlay(0, b)

func is_blocked() -> bool:
	return is_overlay_on(0)

func block_los(from : Tile, to : Tile, d : float, dt : float) -> bool:
	return is_blocked()

func show_los(b) -> void:
	if not b:
		enable_overlay(1, false)
		enable_overlay(2, false)
	else:
		if blocked: enable_overlay(2, true)
		else: enable_overlay(1, true)
