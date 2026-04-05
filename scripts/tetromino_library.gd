extends RefCounted
class_name TetrominoLibrary

const PIECES := [
	{
		"id": "DOT",
		"label": "1x1",
		"color": Color(1.0, 0.973, 0.655, 1.0),
		"cells": [Vector2i(0, 0)]
	},
	{
		"id": "BAR2",
		"label": "2x1",
		"color": Color(1.0, 0.722, 0.294, 1.0),
		"cells": [Vector2i(0, 0), Vector2i(1, 0)]
	},
	{
		"id": "BAR3",
		"label": "3x1",
		"color": Color(1.0, 0.482, 0.345, 1.0),
		"cells": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]
	},
	{
		"id": "I",
		"label": "4x1",
		"color": Color(0.149, 0.93, 1.0, 1.0),
		"cells": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]
	},
	{
		"id": "BAR5",
		"label": "5x1",
		"color": Color(0.208, 0.898, 0.808, 1.0),
		"cells": [
			Vector2i(0, 0),
			Vector2i(1, 0),
			Vector2i(2, 0),
			Vector2i(3, 0),
			Vector2i(4, 0)
		]
	},
	{
		"id": "BAR6",
		"label": "6x1",
		"color": Color(0.251, 0.773, 1.0, 1.0),
		"cells": [
			Vector2i(0, 0),
			Vector2i(1, 0),
			Vector2i(2, 0),
			Vector2i(3, 0),
			Vector2i(4, 0),
			Vector2i(5, 0)
		]
	},
	{
		"id": "O",
		"label": "2x2",
		"color": Color(1.0, 0.886, 0.212, 1.0),
		"cells": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
	},
	{
		"id": "RECT23",
		"label": "2x3",
		"color": Color(0.573, 1.0, 0.447, 1.0),
		"cells": [
			Vector2i(0, 0),
			Vector2i(1, 0),
			Vector2i(0, 1),
			Vector2i(1, 1),
			Vector2i(0, 2),
			Vector2i(1, 2)
		]
	},
	{
		"id": "BLOCK3",
		"label": "3x3",
		"color": Color(0.533, 0.882, 1.0, 1.0),
		"cells": [
			Vector2i(0, 0),
			Vector2i(1, 0),
			Vector2i(2, 0),
			Vector2i(0, 1),
			Vector2i(1, 1),
			Vector2i(2, 1),
			Vector2i(0, 2),
			Vector2i(1, 2),
			Vector2i(2, 2)
		]
	},
	{
		"id": "T",
		"label": "T",
		"color": Color(0.769, 0.486, 1.0, 1.0),
		"cells": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1)]
	},
	{
		"id": "S",
		"label": "S",
		"color": Color(0.42, 0.965, 0.365, 1.0),
		"cells": [Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)]
	},
	{
		"id": "Z",
		"label": "Z",
		"color": Color(1.0, 0.302, 0.322, 1.0),
		"cells": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)]
	},
	{
		"id": "J",
		"label": "J",
		"color": Color(0.278, 0.514, 1.0, 1.0),
		"cells": [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
	},
	{
		"id": "L",
		"label": "L",
		"color": Color(1.0, 0.612, 0.169, 1.0),
		"cells": [Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
	},
	{
		"id": "L1",
		"label": "L(1)",
		"color": Color(1.0, 0.851, 0.38, 1.0),
		"cells": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1)]
	},
	{
		"id": "L2",
		"label": "L(2)",
		"color": Color(1.0, 0.565, 0.627, 1.0),
		"cells": [
			Vector2i(0, 0),
			Vector2i(1, 0),
			Vector2i(2, 0),
			Vector2i(0, 1),
			Vector2i(0, 2)
		]
	},
	{
		"id": "L3",
		"label": "L(3)",
		"color": Color(0.757, 0.529, 1.0, 1.0),
		"cells": [
			Vector2i(0, 0),
			Vector2i(1, 0),
			Vector2i(2, 0),
			Vector2i(3, 0),
			Vector2i(0, 1),
			Vector2i(0, 2),
			Vector2i(0, 3)
		]
	}
]


static func get_random_piece() -> Dictionary:
	var piece_definition: Dictionary = PIECES[randi() % PIECES.size()]
	return _build_random_piece_dictionary(piece_definition)


static func get_random_piece_from_ids(piece_ids: Array[String]) -> Dictionary:
	if piece_ids.is_empty():
		return get_random_piece()

	var available_definitions: Array[Dictionary] = []
	for piece_definition in PIECES:
		if piece_ids.has(piece_definition["id"]):
			available_definitions.append(piece_definition)

	if available_definitions.is_empty():
		return get_random_piece()

	return _build_random_piece_dictionary(available_definitions[randi() % available_definitions.size()])


static func get_piece_by_id(piece_id: String) -> Dictionary:
	for piece_definition in PIECES:
		if piece_definition["id"] == piece_id:
			return _build_piece_dictionary(piece_definition)
	return get_random_piece()


static func duplicate_piece(piece: Dictionary) -> Dictionary:
	return {
		"id": piece.get("id", ""),
		"label": piece.get("label", piece.get("id", "")),
		"color": piece.get("color", Color.WHITE),
		"cells": _copy_cells(piece.get("cells", []))
	}


static func get_piece_catalog() -> Array[Dictionary]:
	var catalog: Array[Dictionary] = []
	for piece_definition in PIECES:
		var preview_piece := _build_piece_dictionary(piece_definition)
		catalog.append({
			"id": piece_definition["id"],
			"label": piece_definition.get("label", piece_definition["id"]),
			"size": get_piece_size(preview_piece),
			"piece": preview_piece
		})
	return catalog


static func get_piece_ids() -> Array[String]:
	var piece_ids: Array[String] = []
	for piece_definition in PIECES:
		piece_ids.append(piece_definition["id"])
	return piece_ids


static func get_piece_size(piece: Dictionary) -> Vector2i:
	var cells: Array[Vector2i] = _copy_cells(piece.get("cells", []))
	return _get_cells_size(cells)


static func can_piece_fit_board(piece_id: String, board_columns: int, board_rows: int) -> bool:
	var piece_definition: Dictionary = _find_piece_definition(piece_id)
	if piece_definition.is_empty():
		return false

	var rotations: Array = _get_unique_rotations(piece_definition["cells"])
	for rotation_cells_variant in rotations:
		var rotation_cells: Array[Vector2i] = _copy_cells(rotation_cells_variant)
		var rotation_size := _get_cells_size(rotation_cells)
		if rotation_size.x <= board_columns and rotation_size.y <= board_rows:
			return true
	return false


static func _get_cells_size(cells: Array[Vector2i]) -> Vector2i:
	if cells.is_empty():
		return Vector2i.ONE

	var max_x := 0
	var max_y := 0
	for cell in cells:
		max_x = maxi(max_x, cell.x)
		max_y = maxi(max_y, cell.y)

	return Vector2i(max_x + 1, max_y + 1)


static func _find_piece_definition(piece_id: String) -> Dictionary:
	for piece_definition in PIECES:
		if piece_definition["id"] == piece_id:
			return piece_definition
	return {}


static func _copy_cells(source: Array) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for cell in source:
		result.append(cell)
	return result


static func _build_piece_dictionary(piece_definition: Dictionary) -> Dictionary:
	return {
		"id": piece_definition["id"],
		"label": piece_definition.get("label", piece_definition["id"]),
		"color": piece_definition["color"],
		"cells": _copy_cells(piece_definition["cells"])
	}


static func _build_random_piece_dictionary(piece_definition: Dictionary) -> Dictionary:
	var piece := _build_piece_dictionary(piece_definition)
	piece["cells"] = _get_random_rotated_cells(piece_definition["cells"])
	piece["color"] = _get_random_palette_color()
	return piece


static func _get_random_rotated_cells(source: Array) -> Array[Vector2i]:
	var variants := _get_unique_rotations(source)
	return _copy_cells(variants[randi() % variants.size()])


static func _get_unique_rotations(source: Array) -> Array:
	var variants: Array = []
	var seen: Dictionary = {}
	var current := _normalize_cells(_copy_cells(source))

	for _rotation in range(4):
		var key := _cells_key(current)
		if not seen.has(key):
			seen[key] = true
			variants.append(_copy_cells(current))
		current = _normalize_cells(_rotate_cells_90(current))

	return variants


static func _rotate_cells_90(source: Array[Vector2i]) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for cell in source:
		result.append(Vector2i(-cell.y, cell.x))
	return result


static func _normalize_cells(source: Array[Vector2i]) -> Array[Vector2i]:
	if source.is_empty():
		return []

	var min_x := source[0].x
	var min_y := source[0].y
	for cell in source:
		min_x = mini(min_x, cell.x)
		min_y = mini(min_y, cell.y)

	var normalized: Array[Vector2i] = []
	for cell in source:
		normalized.append(Vector2i(cell.x - min_x, cell.y - min_y))
	normalized.sort_custom(_sort_cells_lexicographic)
	return normalized


static func _sort_cells_lexicographic(a: Vector2i, b: Vector2i) -> bool:
	if a.y == b.y:
		return a.x < b.x
	return a.y < b.y


static func _cells_key(cells: Array[Vector2i]) -> String:
	var parts := PackedStringArray()
	for cell in cells:
		parts.append("%d:%d" % [cell.x, cell.y])
	return "|".join(parts)


static func _get_random_palette_color() -> Color:
	var color_source: Dictionary = PIECES[randi() % PIECES.size()]
	return color_source["color"]
