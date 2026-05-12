extends StaticBody2D

@onready var sprite: Sprite2D = $Sprite2D

func _on_player_detector_body_entered(body: Node2D) -> void:
	sprite.modulate.a = 0.1


func _on_player_detector_body_exited(body: Node2D) -> void:
	sprite.modulate.a = 1
