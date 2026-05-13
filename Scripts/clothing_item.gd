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


func calculate_difference_score(other: ClothingItem) -> float:
	var color_bonus: float = 0.0
	var style_bonus: float = 0.0

	if color != other.color:
		color_bonus = 50
	if style != other.style:
		style_bonus = 50
	
	var length_diff: float = abs(length - other.length)
	var thickness_diff: float = abs(thickness - other.thickness)
	
	var score: float = length_diff + thickness_diff + color_bonus + style_bonus
	
	return score
