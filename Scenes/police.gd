class_name Police extends CharacterBody2D

const maxSpeed: int = 150

enum State {
	IDLE,
	WANDERING,
	SUSPICIOUS_MOVING,
	SUSPICIOUS_WATCHING,
	CHASING,
}

var state: State = State.IDLE
var time_in_state: float = 0.0
var total_sus_time: float = 0.0
var player: Player
var speed: float = maxSpeed

var sees_player_close: bool = false
var sees_player_mid: bool = false
var sees_player_far: bool = false

var sees_citizen_chasing_mid: bool = false
#var target: Vector2

@onready var sprite: Sprite2D = $Sprite2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var close_vision_detector: Area2D = $CloseVisionDetector
@onready var mid_vision_detector: Area2D = $VisionDetector
@onready var far_vision_detector: Area2D = $FarVisionDetector
@onready var label: Label = $Label

func _ready() -> void:
	randomize_sprite()
	player = get_parent().get_node("Player")


func _physics_process(delta: float) -> void:
	sees_player_close = close_vision_detector.get_overlapping_bodies().has(player)
	sees_player_mid = mid_vision_detector.get_overlapping_bodies().has(player)
	sees_player_far = far_vision_detector.get_overlapping_bodies().has(player)
	
	sees_citizen_chasing_mid = false
	for body in mid_vision_detector.get_overlapping_bodies():
		if body is Citizen and body.state == Citizen.State.CHASING:
			sees_citizen_chasing_mid = true
		elif body is Police and body.state == Police.State.CHASING:
			sees_citizen_chasing_mid = true
	
	update_state(delta)
	move(delta)
	
	# sprite flipping
	if velocity.x > 0:
		sprite.flip_h = true
	elif velocity.x < 0:
		sprite.flip_h = false
	
	# animation
	if velocity.length() > 10:
		animation_player.play("walk")
	else:
		animation_player.play("idle")
		
	# display state
	label.text = State.keys()[state] + ": %.2f" % time_in_state


func update_state(delta: float) -> void:
	time_in_state += delta
	match state:
		State.IDLE:
			if sees_citizen_chasing_mid:
				enter_state(State.CHASING)
			elif sees_player_mid:
				enter_state(State.SUSPICIOUS_MOVING)
			elif time_in_state > 1.0:
				enter_state(State.WANDERING)
		State.WANDERING:
			if sees_citizen_chasing_mid:
				enter_state(State.CHASING)
			elif sees_player_mid:
				enter_state(State.SUSPICIOUS_MOVING)
			elif nav_agent.is_navigation_finished():
				enter_state(State.IDLE)
		State.SUSPICIOUS_MOVING:
			if sees_citizen_chasing_mid:
				enter_state(State.CHASING)
			elif total_sus_time > 7.0:
				enter_state(State.CHASING)
			elif sees_player_close:
				enter_state(State.SUSPICIOUS_WATCHING)
			# update player location when we can see them
			elif sees_player_far:
				total_sus_time += delta
				nav_agent.target_position = player.global_position
			# enter idle once player is out of range and no more path
			elif nav_agent.is_navigation_finished():
				enter_state(State.IDLE)
		State.SUSPICIOUS_WATCHING:
			if sees_citizen_chasing_mid:
				enter_state(State.CHASING)
			elif time_in_state > 1.5:
				enter_state(State.CHASING)
			elif !sees_player_close:
				enter_state(State.SUSPICIOUS_MOVING)
			else:
				total_sus_time += delta
		State.CHASING:
			var player_visible := far_vision_detector.get_overlapping_bodies().has(player)
			var path_finished := nav_agent.is_navigation_finished()
			if !player_visible and path_finished and !sees_citizen_chasing_mid:
				enter_state(State.IDLE)
			if player_visible:
				nav_agent.target_position = player.global_position


func enter_state(new_state: State) -> void:
	# Exit code
	match state:
		State.IDLE:
			pass
		State.WANDERING:
			pass
		State.SUSPICIOUS_MOVING:
			if new_state != State.SUSPICIOUS_WATCHING:
				total_sus_time = 0.0
		State.SUSPICIOUS_WATCHING:
			pass
	# Enter code
	time_in_state = 0
	state = new_state
	match state:
		State.IDLE:
			nav_agent.target_position = global_position
		State.WANDERING:
			speed = 120.0
			# find random place to navigate to
			var rand_offset := randf_range(100, 200) * Vector2.from_angle(randf_range(0, 2 * PI))
			nav_agent.target_position = global_position + rand_offset
		State.SUSPICIOUS_MOVING:
			speed = 140.0
			nav_agent.target_position = player.global_position
		State.SUSPICIOUS_WATCHING:
			pass
		State.CHASING:
			nav_agent.target_position = player.global_position
			speed = 180.0
	
func move(_delta: float) -> void:
	if nav_agent.is_navigation_finished():
		return
	# Get a normalized vector of the input
	var target := nav_agent.get_next_path_position()
	var input: Vector2 = global_position.direction_to(target)
		
	nav_agent.set_velocity(speed * input)
	

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()


func randomize_sprite() -> void:
	sprite.region_rect.position.x = 16 * randi_range(0, 1)
	sprite.region_rect.position.y = 32 * randi_range(0, 4)
	
