@tool extends Node2D

const slot_scene: PackedScene = preload("res://Scenes/LevelGeneration/slot.tscn")
const citizen_scene = preload("res://Scenes/citizen.tscn")

const min_citizen: int = 20
const max_citizen: int = 50
const tiles_in_block: int = 8
const tile_size: int = 16
const block_pixel_size: int = tile_size * tiles_in_block
const block_grid_width: int = 20
const block_grid_height: int = 15

@export_tool_button("Generate") var generate_action = regenerate
@export_tool_button("Clear") var clear_action = clear
@export var nav_region: NavigationRegion2D

# 2d array with rows first
var slots: Array[Slot]
var citizens: Array[Citizen]

@onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	regenerate()
	
func clear() -> void:
	for slot in slots:
		slot.queue_free()
		remove_child(slot)
	
	slots.clear()
	
	for citizen in citizens:
		citizen.queue_free()
	
	citizens.clear()
	
	
func setup() -> void:
	clear()
	
	for y in block_grid_height:
		for x in block_grid_width:
			var slot: Slot = slot_scene.instantiate()
			add_child(slot)
			if Engine.is_editor_hint():
				slot.owner = self
			slot.global_position = Vector2(x * block_pixel_size, y * block_pixel_size)
			#slot.collapse_me.connect(collapse.bind(Vector2i(x,y)))
			slots.append(slot)
	
	
func get_slot(pos: Vector2i) -> Slot:
	return slots[pos.y * block_grid_width + pos.x]


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		regenerate()

func regenerate() -> void:
	setup()
	#await get_tree().create_timer(0.1).timeout
	generate()


func generate() -> void:
	# place blocks
	place_border()
	
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
		
		# check for failure and restart if so
		if min_slot_options < 1:
			regenerate()
			return
	
		# collapse it

		collapse(index_to_coord(slots.find(min_slot)))
		#await get_tree().create_timer(0.1).timeout
		
		# remove from array
		to_process.remove_at(to_process.find(min_slot))

	# clean up and prep
	if Engine.is_editor_hint():
		return
	
	update_navigation()
	
	place_citizens()
	
func place_citizens() -> void:
	var citizen_count := randi_range(min_citizen, max_citizen)
	for c in citizen_count:
		var citizen := citizen_scene.instantiate()
		add_sibling.call_deferred(citizen)
		citizen.global_position = Vector2(randf_range(0, block_grid_width * block_pixel_size), randf_range(0, block_grid_height * block_pixel_size))
		citizens.append(citizen)
	
func update_navigation() -> void:
	# wait a few seconds for unused modules to get deleted
	# TODO: this is a hacky way to wait for deletion
	await get_tree().create_timer(0.1).timeout
	nav_region.bake_navigation_polygon()
	

# Ignores corners
func get_border_coords() -> Array[Vector2i]:
	# create array of rotating coordinates
	var border_coords: Array[Vector2i]
	
	# top left to top right
	for x in range(1, block_grid_width - 1):
		border_coords.append(Vector2i(x, 0))
	
	# top right to bot right
	for y in range(1, block_grid_height - 1):
		border_coords.append(Vector2i(block_grid_width - 1, y))
	
	# bot right to bot left
	for x in range(block_grid_width - 2, 0, -1):
		border_coords.append(Vector2i(x, block_grid_height - 1))
	
	# bot left to top left
	for y in range(block_grid_height - 2, 0, -1):
		border_coords.append(Vector2i(0, y))
		
	return border_coords

	
func place_border() -> void:
	# calculate indices for edge 
	var border_coords := get_border_coords()
	var border_block_count := border_coords.size()
	
	# start in middle of list
	@warning_ignore("integer_division")
	var start_block_idx: int = border_block_count / 2
	
	# radiate away from the start
	@warning_ignore("integer_division")
	var end_block_idx: int = start_block_idx + randi_range(border_block_count / 3, border_block_count / 2)
	
	# add a random offset
	@warning_ignore("integer_division")
	var offset: int = randi_range(0, border_block_count)
	start_block_idx += offset
	end_block_idx += offset
	end_block_idx %= border_block_count
	start_block_idx %= border_block_count
	
	# now force the block module for the two slots
	# NOTE: optimize by only accessing the start and end index not looping
	var start_coords := border_coords[start_block_idx]
	var end_coords := border_coords[end_block_idx]
	
	if start_coords.x == 0 or start_coords.x == block_grid_width - 1:
		force_block(start_coords, "Horizontal")
	else:
		force_block(start_coords, "Vertical")
	get_slot(start_coords).modulate = Color.RED
	
	force_block(end_coords, "FourWay")
	get_slot(end_coords).modulate = Color.RED
	
	var player: Player = get_node("../Player")
	player.global_position = get_slot(start_coords).global_position + Vector2(block_pixel_size, block_pixel_size) / 2


func index_to_coord(idx: int) -> Vector2i:
	@warning_ignore("integer_division")
	return Vector2i(idx % block_grid_width, idx / block_grid_width)
		

func is_valid_slot(pos: Vector2i) -> bool:
	return pos.x > -1 && pos.y > -1 && pos.x < block_grid_width && pos.y < block_grid_height


func force_block(pos: Vector2i, block: String) -> void:
	# randomly picks a pos for the slot at pos and then
	var slot: Slot = get_slot(pos)
	var modules: Array[Node] = slot.modules.get_children()
	var selected_module: Module = slot.modules.find_child(block)
	
	# now remove the other modules
	for module in modules:
		if module != selected_module:
			slot.remove_module(module)

func collapse(pos: Vector2i) -> void:
	# randomly picks a pos for the slot at pos and then
	var slot: Slot = get_slot(pos)
	var modules: Array[Node] = slot.modules.get_children()
	var module_weights: Array[float]
	for mod in modules:
		module_weights.append(mod.weight)
	var selected_module: Module = modules[rng.rand_weighted(module_weights)]
	
	# now remove the other modules
	for module in modules:
		if module != selected_module:
			slot.remove_module(module)
	
	selected_module.show()
			
	# propagate changes
	update(pos + Vector2i.UP)
	update(pos + Vector2i.DOWN)
	update(pos + Vector2i.LEFT)
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
				# Only sidewalks should end the map
				#if module.paths[path] != 0:
					#module_valid = false
				continue
			
			var path_valid: bool = false
			
			# get the neighbor for this path
			var nei: Slot = get_slot(pos + Module.path_to_dir(path))
			var path_to_check: Module.Path = Module.corresponding_path(path)
			
			# check for a module that has matching socket number in the correct socket
			for nei_module in nei.modules.get_children():
				# if both are intersection then we stop
				if module.is_intersection and nei_module.is_intersection:
					continue
				#if module.is_straightaway and nei_module.is_straightaway:
					#continue
					
				# parallel road check, if both are roads, but are connecting through sidewalk
				# then we cancel
				var is_sidewalk_connection: bool = module.paths[path] == 0 and nei_module.paths[path_to_check] == 0
				var both_roads: bool = nei_module.paths.values().has(1) and module.paths.values().has(1)
				if is_sidewalk_connection and both_roads:
					continue
				
				# if corresponding, then this path is valid
				if module.paths[path] == nei_module.paths[path_to_check]:
					path_valid = true
					break
			
			# if path is not valid then the module is not valid
			if !path_valid:
				module_valid = false
				break
		
		if !module_valid:
			slot.remove_module(module)
			changed = true
		
	# if changed then update neighbors
	if changed:
		#print("changed: " + str(pos))
		# propagate changes
		#await get_tree().create_timer(0.1).timeout
		update(pos + Vector2i.UP)
		#await get_tree().create_timer(0.5).timeout
		update(pos + Vector2i.DOWN)
		#await get_tree().create_timer(0.5).timeout
		update(pos + Vector2i.LEFT)
		#await get_tree().create_timer(0.5).timeout
		update(pos + Vector2i.RIGHT)
