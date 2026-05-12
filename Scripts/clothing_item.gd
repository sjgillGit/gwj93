class_name ClothingItem extends Resource

# length, thickness, size, color, style

enum ClothColor {
	RED,
	BLUE,
	PINK,
	GREEN,
}

enum Style {
	FORMAL,
	CASUAL,
	FLASHY
}

@export var thickness: float
@export var length: float
@export var size: float
@export var style: Style
@export var color: ClothColor


func outfit_calc(length, thickness, size, color, color_list, style, style_list):
	var color_bonus = 0
	var style_bonus = 0

	if not color in color_list:
		color_bonus = 50
	if not style in style_list:
		style_bonus = 50
		
	var score = (length + thickness + color_bonus + style_bonus) * (size / 100)
	return score
