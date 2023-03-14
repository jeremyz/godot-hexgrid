@icon('res://addons/hexgrid/Piece.png')
extends Piece

class_name Unit

func get_mp() -> int:
	return 2

func road_march_bonus() -> int:
	return 2

func move_cost(src : Tile, dst : Tile, orientation : int) -> int:
	return (1 if (src.has_road(orientation) and dst.type != 3) else dst.cost())

func max_range_of_fire(category : int, from : Tile) -> int:
	return 6 + from.range_modifier(category)

func volume_of_fire(category : int, distance : int, src : Tile, src_o : int, dst : Tile, dst_o : int) -> int:
	var fp : int = 10
	if distance > 6: return -1
	elif distance > 4: fp = 4
	elif distance > 2: fp = 7
	fp -= src.attack_modifier(category, src_o)
	fp -= dst.defense_value(category, dst_o)
	return fp
