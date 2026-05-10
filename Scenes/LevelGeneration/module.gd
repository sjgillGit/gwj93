class_name Module extends Node2D

enum Path {
	UP,
	DOWN,
	RIGHT,
	LEFT
}

@export var paths: Dictionary[Path, int] = {
	Path.UP: 1, 
	Path.DOWN: 1, 
	Path.LEFT: 1, 
	Path.RIGHT: 1
}


static func path_to_dir(path: Path) -> Vector2i:
	var res: Vector2i
	match path:
		Path.UP:
			res = Vector2i.UP
		Path.DOWN:
			res = Vector2i.DOWN
		Path.LEFT:
			res = Vector2i.LEFT
		Path.RIGHT:
			res = Vector2i.RIGHT
	
	return res

static func corresponding_path(path: Path) -> Path:
	var res: Path
	match path:
		Path.UP:
			return Path.DOWN
		Path.DOWN:
			return Path.UP
		Path.LEFT:
			return Path.RIGHT
		Path.RIGHT:
			return Path.LEFT
	
	return res
