#warning-ignore-all:unused_argument
extends Node2D

class_name Tile, "res://godot/Tile.png"

var coords : Vector2
var blocked : bool
var on_board : bool = false

var acc : int
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

func has_road(a) -> bool:
	print("Tile#has_road() must be overriden in a subclass")
	return false

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
