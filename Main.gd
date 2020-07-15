#warning-ignore-all:return_value_discarded
extends Node2D

var drag_map : bool = false

onready var UI : CanvasLayer = $UI
onready var Map : Sprite = $ViewportContainer/Viewport/Map
onready var Camera : Camera2D = $ViewportContainer/Viewport/Camera

func _ready():
	UI.get_node("rotate").connect("pressed", self, "on_rotate")
	UI.get_node("LOS").connect("pressed", self, "on_toggle")
	UI.get_node("Move").connect("pressed", self, "on_toggle")
	Map.connect("hex_touched", self, "on_hex_touched")
	$ViewportContainer.connect("resized", self, "on_viewport_resized")
	on_toggle()
	on_viewport_resized()

func on_viewport_resized() -> void:
	Camera.configure($ViewportContainer/Viewport.size, Map.center(), Map.texture_size())

func on_rotate() -> void:
	Map.rotate_map()

func on_toggle() -> void:
	Map.set_mode(UI.get_node("LOS").pressed, UI.get_node("Move").pressed)

func on_hex_touched(pos : Vector2, hex : Hex, key : int) -> void:
	var s : String = ("offmap" if key == -1 else hex.inspect())
	UI.get_node("Info").set_text("\n(%d;%d)\n -> %s\n -> %d" % [int(pos.x), int(pos.y), s, key])

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
			Map.on_click(event.pressed)
	elif event is InputEventKey:
		if event.scancode == KEY_ESCAPE:
			get_tree().quit()
