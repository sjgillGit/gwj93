extends Node

#top, bottom, headwear, accessory1, accessory2, shoes, hair
#length, thickness, size, color, style
var outfit = [
	[30, 30, 70, "Blue", "Casual"],
	[30, 30, 70, "Blue", "Casual"],
	[30, 30, 70, "Blue", "Casual"],
	[30, 30, 70, "Blue", "Casual"],
	[30, 30, 70, "Blue", "Casual"],
	[30, 30, 70, "Blue", "Casual"],
	[30, 30, 70, "Blue", "Casual"]
]


var last_outfit = [
	[30, 30, 70, "Blue", "Casual"],
	[30, 30, 70, "Blue", "Casual"],
	[30, 30, 70, "Blue", "Casual"],
	[30, 30, 70, "Blue", "Casual"],
	[30, 30, 70, "Blue", "Casual"],
	[30, 30, 70, "Blue", "Casual"],
	[30, 30, 70, "Blue", "Casual"]
]
#var top = [30, 30, 70, "Blue", "Casual"]
#var bottom = [30, 30, 70, "Blue", "Casual"]
#var headwear = [30, 30, 70, "Blue", "Casual"]
#var accessory1 = [30, 30, 70, "Blue", "Casual"]
#var accessory2 = [30, 30, 70, "Blue", "Casual"]
#var shoes = [30, 30, 70, "Blue", "Casual"]
#var hair = [30, 30, 70, "Blue", "Casual"]

#var last_top = [30, 30, 70, "Blue", "Casual"]
#var last_bottom = [30, 30, 70, "Blue", "Casual"]
#var last_headwear = [30, 30, 70, "Blue", "Casual"]
#var last_accessory1 = [30, 30, 70, "Blue", "Casual"]
#var last_accessory2 = [30, 30, 70, "Blue", "Casual"]
#var last_shoes = [30, 30, 70, "Blue", "Casual"]
#var last_hair = [30, 30, 70, "Blue", "Casual"]

var color_list = [
	[],
	[],
	[],
	[],
	[],
	[],
	[]
]
var style_list = [
	[],
	[],
	[],
	[],
	[],
	[],
	[]
]

static func outfit_calc(length, thickness, size, color, color_list, style, style_list):
	var color_bonus = 0
	var style_bonus = 0

	if not color in color_list:
		color_bonus = 50
	if not style in style_list:
		style_bonus = 50
		
	var score = (length + thickness + color_bonus + style_bonus) * (size / 100)
	return score
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

#triggers at the beginning of each level and at the start of the game.
func list_update():
	for i in range (outfit.size()):
		var item  = outfit[i]
		color_list[i].append(item[3])
		style_list[i].append(item[4])
	last_outfit = outfit
	

#type will be some value between 0-6 depending on what type of clothing it is, 
#hopefully this will make it easier to generate random clothes and assign them.
func swap_outfit(type, new_item_stats):
	outfit[type] = new_item_stats
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
