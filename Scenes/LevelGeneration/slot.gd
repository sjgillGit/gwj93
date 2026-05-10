class_name Slot extends Node2D

signal collapse_me


@onready var modules: Node = $Modules


func _on_button_pressed() -> void:
	collapse_me.emit()
	
	
func _process(delta: float) -> void:
	if modules.get_child_count() == 1:
		$Button.hide()
		modules.get_child(0).show()
