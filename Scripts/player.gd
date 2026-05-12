extends CharacterBody2D


const moveAcceleration: int = 10000
const maxSpeed: int = 200
const moveFriction: int = 5000
@onready var interaction_detector: Area2D = $InteractionDetector

func _physics_process(delta: float) -> void:
	move(delta)
	
func move(delta: float) -> void:
	# Get a normalized vector of the input
	var input := Input.get_vector("InputLeft", "InputRight", "InputUp", "InputDown")
	
	# Friction (in opposite direction of velocity)
	velocity = velocity.move_toward(Vector2.ZERO, moveFriction * delta)

	# Apply input acceleration
	velocity += moveAcceleration * input * delta
	
	# Limits the maximum speed the player can go at. 
	velocity = velocity.limit_length(maxSpeed)
	
	move_and_slide()
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact") and !interaction_detector.get_overlapping_areas().is_empty():
		interaction_detector.get_overlapping_areas()[0].interact()
