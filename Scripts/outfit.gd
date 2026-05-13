class_name Outfit extends Resource


enum ItemType {
	PANTS,
	HAT,
	TOP
}

var pieces: Dictionary[ItemType, ClothingItem]


func calculate_difference(other: Outfit) -> float:
	var total_difference := 0
	for piece in pieces:
		total_difference += pieces[piece].calculate_difference_score(other.pieces[piece]) * pieces[piece].size / 100
	
	return total_difference
		
