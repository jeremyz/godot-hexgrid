extends Camera2D

const MAX_ZOOM = 1

var margin :Vector2
var window : Vector2
var map_center : Vector2
var texture_size : Vector2
var zoom_boundaries : Vector2

func _ready():
	margin = Vector2(50, 50)

func configure(w : Vector2, c : Vector2, ts : Vector2) -> void:
	window = w
	map_center = c
	texture_size = ts
	var zout : float = min(window.x / (texture_size.x + margin.x), window.y / (texture_size.y + margin.y))
	zoom_boundaries = Vector2(zout, zout + MAX_ZOOM)
	zoom = Vector2(zout, zout)
	position = map_center

func update_camera(x : float, y : float, z : float) -> void:
	if z != 0:
		zoom.x = clamp(zoom.x + z, zoom_boundaries.x, zoom_boundaries.y)
		zoom.y = zoom.x
	position.x += x
	position.y += y
	var delta = texture_size + margin - (window / zoom.x)
	if (delta.x <= 0):
		position.x = map_center.x
	else:
		var dx = int(delta.x / 2)
		position.x = clamp(position.x, map_center.x - dx, map_center.x + dx)
	if (delta.y <= 0):
		position.y = map_center.y
	else:
		var dy = int(delta.y / 2)
		position.y = clamp(position.y, map_center.y - dy, map_center.y + dy)
