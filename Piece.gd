#warning-ignore-all:unused_argument
extends Node2D

class_name Piece, "res://godot/Piece.png"

# movement points
func get_mp() -> int:
	print("Piece#get_mp() must be overriden in a subclass")
	return 0

# movement point bonus if you start your movement on a road and follow it
func road_march_bonus() -> int:
	print("Piece#road_march_bonus() must be overriden in a subclass")
	return 0

# movement cost from a Tile to another adjacent Tile
func move_cost(src : Tile, dst : Tile, orientation : int) -> int:
	print("Piece#move_cost() must be overriden in a subclass")
	return -1 # impracticable

# are you allowed to move into that Tile as only move even if you don't have enough movement points
func at_least_one_tile(dst : Tile) -> bool:
	print("Piece#at_least_one_tile() must be overriden in a subclass")
	return true
