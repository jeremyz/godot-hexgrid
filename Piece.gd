#warning-ignore-all:unused_argument
extends Node2D

class_name Piece, "res://godot/Piece.png"

func get_mp() -> int:
	print("Piece#get_mp() must be overriden in a subclass")
	return 0

func road_march_bonus() -> int:
	print("Piece#road_march_bonus() must be overriden in a subclass")
	return 0

func move_cost(src : Tile, dst : Tile, a : int) -> int:
	print("Piece#move_cost() must be overriden in a subclass")
	return 1

func at_least_one_tile() -> bool:
	print("Piece#at_least_one_tile() must be overriden in a subclass")
	return true
