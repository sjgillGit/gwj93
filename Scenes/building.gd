extends Node2D


@onready var player_detector: Area2D = $PlayerDetector
@onready var transparency_group: Array[Node2D] = [$Chimney, $Roof, $FrontWall, $FrontDoor]

func _ready() -> void:
	player_detector.body_entered.connect(_on_player_detector_body_entered)
	player_detector.body_exited.connect(_on_player_detector_body_exited)

func _on_player_detector_body_entered(body: Node2D) -> void:
	for node in transparency_group:
		node.modulate.a = 0.1


func _on_player_detector_body_exited(body: Node2D) -> void:
	for node in transparency_group:
		node.modulate.a = 1
