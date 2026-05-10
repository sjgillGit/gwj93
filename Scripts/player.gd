extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var moveSpeed = 50
var maxSpeed = 500
var moveFriction = 15

func _physics_process(delta: float) -> void:
	
	#MOVEMENT
	#Apply friction in each component of the velocity vector. Reduces velocity to 0 over time
	if velocity.y < 0:
		velocity.y += moveFriction
	if velocity.y > 0:
		velocity.y -= moveFriction
	if velocity.x < 0:
		velocity.x += moveFriction
	if velocity.x > 0:
		velocity.x -= moveFriction
	
	#Add velocity over time, simulating acceleration. 
	if Input.is_action_pressed("InputUp"):
		velocity.y -= moveSpeed
	if Input.is_action_pressed("InputDown"):
		velocity.y += moveSpeed
	if Input.is_action_pressed("InputLeft"):
		velocity.x -= moveSpeed
	if Input.is_action_pressed("InputRight"):
		velocity.x += moveSpeed
	
	#Limits the maximum speed the player can go at. 
	if velocity.y > maxSpeed:
		velocity.y = maxSpeed
	if velocity.y < -1 * maxSpeed:
		velocity.y = -1 * maxSpeed
	if velocity.x > maxSpeed:
		velocity.x = maxSpeed
	if velocity.x < -1 * maxSpeed:
		velocity.x = -1 * maxSpeed
	
	#print(velocity.y)
	#print(velocity.x)
	
	#OLD SYSTEM: Uses linear velocity and nomalized vectors
	#velocity = velocity.normalized() * moveSpeed
	#if velocity.length() > maxSpeed:
		#velocity = velocity.normalized() * maxSpeed
	move_and_slide()
