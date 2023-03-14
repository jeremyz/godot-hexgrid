@icon('res://addons/hexgrid/Tile.png')
extends Node2D

class_name Tile

var coords : Vector2
var blocked : bool
var on_map : bool = false

var acc : int
var f : float
var parent : Tile
var road_march : bool
var search_count : int

func configure(p : Vector2, c: Vector2, o :Array) -> void:
	position = p
	coords = c
	on_map = true
	for t in o:
		var s :Sprite2D = Sprite2D.new()
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
