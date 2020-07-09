#warning-ignore-all:return_value_discarded
extends Node2D

var drag_map : bool = false

onready var UI : CanvasLayer = $UI
onready var Map : Sprite = $ViewportContainer/Viewport/Map
onready var Camera : Camera2D = $ViewportContainer/Viewport/Camera

func _ready():
	UI.get_node("rotate").connect("pressed", Map, "on_rotate")
	Map.connect("configure", Camera, "on_configure")
	Map.connect("touched", self, "on_touched")
	Camera.window = $ViewportContainer/Viewport.size
	Map.on_rotate()

func on_touched(s : String) -> void:
	UI.get_node("Label").set_text(s)

func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventMouseMotion:
		if drag_map:
			var dv : Vector2 = event.relative * Camera.zoom
			Camera.update_camera(-dv.x, -dv.y, 0)
		else:
			Map.on_mouse_move()
	elif event is InputEventMouseButton:
		if event.button_index == 4:
			Camera.update_camera(0, 0, -0.05)
		elif event.button_index == 5:
			Camera.update_camera(0, 0, +0.05)
		elif event.button_index == 3:
			drag_map = event.pressed
		elif event.button_index == 1:
			Map.on_mouse_1(event.pressed)
		elif event.button_index == 2:
			Map.on_mouse_2(event.pressed)
	elif event is InputEventKey:
		if event.scancode == KEY_ESCAPE:
			get_tree().quit()
