class_name Citizen extends CharacterBody2D

const maxSpeed: int = 100

enum State {
	IDLE,
	WANDERING,
	SUSPICIOUS,
	CHASING,
}

var state: State = State.IDLE
var time_in_state: float = 0.0
#var target: Vector2

@onready var sprite: Sprite2D = $Sprite2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var vision_detector: Area2D = $VisionDetector
@onready var far_vision_detector: Area2D = $FarVisionDetector
@onready var label: Label = $Label


func _physics_process(delta: float) -> void:
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
			if time_in_state > 1.0:
				enter_state(State.WANDERING)
			if vision_detector.get_overlapping_bodies().has(%Player):
				enter_state(State.SUSPICIOUS)
			# detect noise
		State.WANDERING:
			if nav_agent.is_navigation_finished():
				enter_state(State.IDLE)
			if vision_detector.get_overlapping_bodies().has(%Player):
				enter_state(State.SUSPICIOUS)
			# detect noise
		State.SUSPICIOUS:
			# can't see player
			if !vision_detector.get_overlapping_bodies().has(%Player):
				enter_state(State.IDLE)
			elif time_in_state > 2.0:
				enter_state(State.CHASING)
		State.CHASING:
			var player_visible := far_vision_detector.get_overlapping_bodies().has(%Player)
			var path_finished := nav_agent.is_navigation_finished()
			if !player_visible and path_finished:
				enter_state(State.IDLE)
			if player_visible:
				nav_agent.target_position = %Player.global_position


func enter_state(new_state: State) -> void:
	# Exit code
	match state:
		State.IDLE:
			pass
		State.WANDERING:
			pass
		State.SUSPICIOUS:
			pass
			
	# Enter code
	time_in_state = 0
	state = new_state
	match state:
		State.IDLE:
			nav_agent.target_position = global_position
		State.WANDERING:
			# find random place to navigate to
			var rand_offset := randf_range(50, 100) * Vector2.from_angle(randf_range(0, 2 * PI))
			nav_agent.target_position = global_position + rand_offset
		State.SUSPICIOUS:
			nav_agent.target_position = global_position
		State.CHASING:
			nav_agent.target_position = %Player.global_position
	
func move(_delta: float) -> void:
	if nav_agent.is_navigation_finished():
		return
	# Get a normalized vector of the input
	var target := nav_agent.get_next_path_position()
	var input: Vector2 = global_position.direction_to(target)
	
	nav_agent.set_velocity(maxSpeed * input)
	

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()
