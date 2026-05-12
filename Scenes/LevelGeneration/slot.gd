@tool
class_name Slot extends Node2D

#signal collapse_me

@warning_ignore("onready_with_export")
@export @onready var modules: Node = $Modules
@onready var inactive: Node = $Inactive
@onready var label: Label = $Label

#func _on_button_pressed() -> void:
	#collapse_me.emit()
	

# TODO: MAKE THIS BETTER :DSDMKJFNAKJFNJKASN
#func _process(_delta: float) -> void:
	#$Button.text = str(modules.get_child_count())
	#if modules.get_child_count() == 1:
		#$Button.hide()


func _on_inactive_child_order_changed() -> void:
	for child in inactive.get_children():
		child.queue_free()
