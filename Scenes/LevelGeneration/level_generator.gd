extends Node2D

const slot_scene: PackedScene = preload("res://Scenes/LevelGeneration/slot.tscn")

const tiles_in_block: int = 8
const tile_size: int = 16
const block_pixel_size: int = tile_size * tiles_in_block
const block_grid_width: int = 8
const block_grid_height: int = 5

# 2d array with rows first
var slots: Array[Slot]

func _ready() -> void:
	setup()
	
func setup() -> void:
	for slot in slots:
		slot.queue_free()
	slots.clear()
	
	for y in block_grid_height:
		for x in block_grid_width:
			var slot: Slot = slot_scene.instantiate()
			add_child(slot)
			slot.global_position = Vector2(x * block_pixel_size, y * block_pixel_size)
			slot.collapse_me.connect(collapse.bind(Vector2i(x,y)))
			slots.append(slot)
	
	
func get_slot(pos: Vector2i) -> Slot:
	return slots[pos.y * block_grid_width + pos.x]


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		setup()
		generate()
		

func generate() -> void:
	var to_process := slots.duplicate()
	to_process.shuffle()
	
	while !to_process.is_empty():
		# find minimum option slot
		var min_slot: Slot = null
		var min_slot_options: int
		for slot in to_process:
			# find one with minimum slots
			if min_slot == null or slot.modules.get_child_count() < min_slot_options:
				min_slot_options = slot.modules.get_child_count()
				min_slot = slot
	
		# collapse it
		await collapse(index_to_coord(slots.find(min_slot)))
		await get_tree().create_timer(0.1).timeout
		
		# remove from array
		to_process.remove_at(to_process.find(min_slot))
	print("done!")
	
		
func index_to_coord(idx: int) -> Vector2i:
	return Vector2i(idx % block_grid_width, idx / block_grid_width)
		

func is_valid_slot(pos: Vector2i) -> bool:
	return pos.x > -1 && pos.y > -1 && pos.x < block_grid_width && pos.y < block_grid_height


func collapse(pos: Vector2i) -> void:
	# randomly picks a pos for the slot at pos and then
	var slot: Slot = get_slot(pos)
	var modules: Array[Node] = slot.modules.get_children()
	var selected_module: Module = modules.pick_random()
	
	# now remove the other modules
	for module in modules:
		if module != selected_module:
			module.queue_free()
			
	# propagate changes
	await get_tree().create_timer(0.1).timeout
	update(pos + Vector2i.UP)
	#await get_tree().create_timer(0.5).timeout
	update(pos + Vector2i.DOWN)
	#await get_tree().create_timer(0.5).timeout
	update(pos + Vector2i.LEFT)
	#await get_tree().create_timer(0.5).timeout
	update(pos + Vector2i.RIGHT)
	

func update(pos: Vector2i) -> void:
	if !is_valid_slot(pos):
		#print(pos)
		#print("invalid stoppping propagation")
		return
	
	#print("TESTING: " + str(pos))
	
	# for each module, check paths,
	var slot: Slot = get_slot(pos)
	var modules: Array[Node] = slot.modules.get_children()
	var changed: bool = false
	
	for module in modules:
		var module_valid := true
		for path in module.paths:
			# This path doesn't need to be checked if out of bounds
			if !is_valid_slot(pos + Module.path_to_dir(path)):
				continue
			
			var path_valid: bool = false
			
			# get the neighbor for this path
			var nei: Slot = get_slot(pos + Module.path_to_dir(path))
			var path_to_check: Module.Path = Module.corresponding_path(path)
			
			# check for a module that has matching socket number in the correct socket
			for nei_module in nei.modules.get_children():
				# if corresponding, then this path is valid
				if module.paths[path] == nei_module.paths[path_to_check]:
					path_valid = true
					break
			
			# if path is not valid then the module is not valid
			if !path_valid:
				module_valid = false
				break
		
		if !module_valid:
			module.queue_free()
			changed = true
		
	# if changed then update neighbors
	if changed:
		#print("changed: " + str(pos))
		# propagate changes
		await get_tree().create_timer(0.1).timeout
		update(pos + Vector2i.UP)
		#await get_tree().create_timer(0.5).timeout
		update(pos + Vector2i.DOWN)
		#await get_tree().create_timer(0.5).timeout
		update(pos + Vector2i.LEFT)
		#await get_tree().create_timer(0.5).timeout
		update(pos + Vector2i.RIGHT)
	
	
