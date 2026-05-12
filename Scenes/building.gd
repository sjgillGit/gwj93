extends StaticBody2D

func _on_player_detector_body_entered(body: Node2D) -> void:
	modulate.a = 0.5


func _on_player_detector_body_exited(body: Node2D) -> void:
	modulate.a = 1
