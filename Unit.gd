#warning-ignore-all:unused_argument
extends Piece

class_name Unit, "res://godot/Piece.png"

func get_mp() -> int:
	return 3

func road_march_bonus() -> int:
	return 3

func move_cost(src : Tile, dst : Tile, a : int) -> int:
	print("from %d %d -> %d %d : %d" % [src.coords.x,src.coords.y,dst.coords.x,dst.coords.y,a])
	return dst.cost()
