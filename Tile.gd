#warning-ignore-all:unused_argument
extends Node2D

class_name Tile, "res://godot/Tile.png"

var coords : Vector2
var blocked : bool
var on_board : bool = false

var acc : int
var f : float
var parent : Tile
var road_march : bool
var search_count : int

func configure(p : Vector2, c: Vector2, o :Array) -> void:
	position = p
	coords = c
	on_board = true
	for t in o:
		var s :Sprite = Sprite.new()
		s.texture = load(t)
		s.visible = false
		add_child(s)
	visible = false

# is there a road with given orientation that drives out of that Tile
func has_road(orientation : int) -> bool:
	print("Tile#has_road() must be overriden in a subclass")
	return false

# is the line of sight blocked from a Tile to another, d beeing the distance between from and to,
# dt beeing the distance between from and this Tile
func block_los(from : Tile, to : Tile, d : float, dt : float) -> bool:
	print("Tile#block_los() must be overriden in a subclass")
	return false

# range value modifier when firing out of this tile with a given category of weapon
func range_modifier(category : int) -> int:
	print("Tile#range_modifier() must be overriden in a subclass")
	return 0

# attack value modifier when firing out of this tile with a given category of weapon with a given orientation
func attack_modifier(category : int, orientation : int) -> int:
	print("Tile#attack_modifier() must be overriden in a subclass")
	return 0

# defense value provided by this tile against a given category of weapon incoming from a given orientation
func defense_value(category : int, orientation : int) -> int:
	print("Tile#defense_value() must be overriden in a subclass")
	return 0

func enable_overlay(i :int, v : bool) -> void:
	get_child(i).visible = v
	if v: visible = true
	else :
		visible = false
		for o in get_children():
			if o.visible:
				visible = true
				break

func is_overlay_on(i) -> bool:
	return get_child(i).visible
