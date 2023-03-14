extends Node2D

var moved : int = 0
var drag_map : bool = false

@onready var UI : Control = $CanvasLayer/HBOX/UI
@onready var Map : Sprite2D = $CanvasLayer/HBOX/ViewportContainer/Viewport/Map
@onready var Camera : Camera2D = $CanvasLayer/HBOX/ViewportContainer/Viewport/Camera

func _ready():
	UI.get_node("rotate").connect("pressed", on_rotate)
	UI.get_node("zin").connect("pressed", func(): on_zoom(true))
	UI.get_node("zout").connect("pressed", func(): on_zoom(false))
	UI.get_node("LOS").connect("pressed", on_toggle)
	UI.get_node("Move").connect("pressed", on_toggle)
	UI.get_node("Influence").connect("pressed", on_toggle)
	Map.connect("hex_touched", on_hex_touched)
	$CanvasLayer/HBOX/ViewportContainer.connect("resized", on_viewport_resized)
	on_toggle()
	await get_tree().create_timer(.2).timeout
	on_viewport_resized()
	UI.get_node("OSInfo").text = "screen\n%s\ndpi %d" % [DisplayServer.screen_get_size(), DisplayServer.screen_get_dpi()]

func on_viewport_resized() -> void:
	Camera.configure($CanvasLayer/HBOX/ViewportContainer/Viewport.size, Map.center(), Map.texture_size())

func on_rotate() -> void:
	Map.rotate_map()
	on_viewport_resized()

func on_zoom(b : bool) -> void:
	Camera.update_camera(0, 0, -0.05 if b else 0.05)

func on_toggle() -> void:
	Map.set_mode(UI.get_node("LOS").is_pressed(), UI.get_node("Move").is_pressed(), UI.get_node("Influence").is_pressed())

func on_hex_touched(pos : Vector2, hex : Hex, key : int) -> void:
	var s : String = ("offmap" if key == -1 else hex.inspect())
	UI.get_node("Info").set_text("\n(%d;%d)\n -> %s\n -> %d" % [int(pos.x), int(pos.y), s, key])

func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventMouseMotion:
		if drag_map:
			var dv : Vector2 = event.relative * Camera.zoom
			Camera.update_camera(-dv.x, -dv.y, 0)
			moved += 1
		else:
			Map.on_mouse_move()
	elif event is InputEventMouseButton:
		if event.button_index == 1:
			if moved < 5:
				drag_map = Map.on_click(event.pressed)
			else:
				drag_map = false
			moved = 0
		elif event.button_index == 3:
			drag_map = event.pressed
		elif event.button_index == 4:
			on_zoom(true)
		elif event.button_index == 5:
			on_zoom(false)
	elif event is InputEventKey:
		if event.scancode == KEY_ESCAPE:
			get_tree().quit()
