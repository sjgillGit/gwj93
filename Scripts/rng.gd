## Global singleton for random number generation.
## 
## This script provides a centralized RandomNumberGenerator instance
## so scripts can use rng-related functions that are only possible
## via a RandomNumberGenerator instance like RandomNumberGenerator.rand_weighted
## 
## Used by: Defender (for weighted placement), BaseEnemy (direction variations),
## and other systems that need random values.
extends Node

## Shared RandomNumberGenerator instance used by the entire game
var rng: RandomNumberGenerator

## Initialize a new RandomNumberGenerator.
func _ready() -> void:
	rng = RandomNumberGenerator.new()
