#warning-ignore-all:unused_argument
extends Piece

class_name Unit, "res://godot/Piece.png"

func get_mp() -> int:
	return 2

func road_march_bonus() -> int:
	return 2

func move_cost(src : Tile, dst : Tile, o : int) -> int:
	return (1 if (src.has_road(o) and dst.type != 3) else dst.cost())
