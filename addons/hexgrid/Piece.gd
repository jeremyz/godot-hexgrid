@icon('res://addons/hexgrid/Piece.png')
extends Node2D

class_name Piece

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

# the maximum range of fire with a given category of weapon
func max_range_of_fire(category : int, from : Tile) -> int:
	print("Piece#max_range_of_fire() must be overriden in a subclass")
	return 0

# the projected volume of fire with a given category of weapon at a given distance,
# out of a given Tile with a given orientation, into a given Tile with a given orientation
func volume_of_fire(category : int, distance : int, src : Tile, src_o : int, dst : Tile, dst_o : int) -> int:
	print("Piece#volume_of_fire() must be overriden in a subclass")
	return -1 # out of range
