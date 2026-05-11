class_name Slot extends Node2D

signal collapse_me


@onready var modules: Node = $Modules
@onready var inactive: Node2D = $Inactive
@onready var label: Label = $Label

#func _on_button_pressed() -> void:
	#collapse_me.emit()
	

# TODO: MAKE THIS BETTER :DSDMKJFNAKJFNJKASN
func _process(_delta: float) -> void:
	$Button.text = str(modules.get_child_count())
	if modules.get_child_count() == 1:
		$Button.hide()
		modules.get_child(0).show()
