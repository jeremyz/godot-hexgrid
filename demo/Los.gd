extends Node2D

var p0 : Vector2
var p1 : Vector2
var p2 : Vector2

func _ready():
	pass

func _draw() -> void:
	if p2.x == -1:
		draw_line(p0, p1, Color(0, 255, 0))
	else:
		draw_line(p0, p2, Color(0, 255, 0))
		draw_line(p2, p1, Color(255, 0, 0))

func setup(v0 :Vector2, v1 : Vector2, v2 : Vector2) -> void:
	p0 = v0
	p1 = v1
	p2 = v2
	queue_redraw()
