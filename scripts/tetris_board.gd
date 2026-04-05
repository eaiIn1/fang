@tool
extends Control
class_name TetrisBoard

const TetrominoLibraryScript := preload("res://scripts/tetromino_library.gd")

signal piece_placed(slot_path: NodePath, cleared_units: int)
signal valid_hover_entered(origin: Vector2i)

@export var columns: int = 8
@export var rows: int = 8
@export var cell_size: float = 48.0
@export var background_color: Color = Color(0.047, 0.078, 0.165, 1.0)
@export var cell_color_a: Color = Color(0.078, 0.173, 0.306, 1.0)
@export var cell_color_b: Color = Color(0.047, 0.122, 0.247, 1.0)
@export var inactive_cell_color_a: Color = Color(0.168, 0.184, 0.231, 0.98)
@export var inactive_cell_color_b: Color = Color(0.129, 0.145, 0.192, 0.98)
@export var grid_color: Color = Color(0.086, 0.886, 1.0, 0.72)
@export var inactive_grid_color: Color = Color(0.596, 0.639, 0.725, 0.32)
@export var border_color: Color = Color(0.945, 0.973, 1.0, 1.0)
@export var glow_color: Color = Color(0.086, 0.886, 1.0, 0.14)
@export var border_width: float = 3.0
@export var placed_cell_outline_color: Color = Color(1.0, 1.0, 1.0, 0.38)
@export var inactive_cell_outline_color: Color = Color(0.733, 0.765, 0.835, 0.16)
@export var preview_valid_tint: Color = Color(0.898, 0.988, 1.0, 0.75)
@export var preview_invalid_tint: Color = Color(1.0, 0.329, 0.337, 0.68)
@export var clear_flash_color: Color = Color(1.0, 0.945, 0.62, 1.0)
@export var place_effect_duration: float = 0.18
@export var clear_effect_duration: float = 0.26
@export var mobile_drop_position_offset_in_cells: Vector2 = Vector2(0.0, -1.65)
@export var mobile_drop_hit_side_margin_in_cells: float = 0.65
@export var mobile_drop_hit_top_margin_in_cells: float = 0.55
@export var mobile_drop_hit_bottom_margin_in_cells: float = 2.15

var occupied_cells: Dictionary = {}
var preview_piece: Dictionary = {}
var preview_origin := Vector2i.ZERO
var preview_valid := false
var transient_effects: Array[Dictionary] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	if custom_minimum_size == Vector2.ZERO:
		_update_minimum_size()
	set_process(not Engine.is_editor_hint())
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()
	elif what == NOTIFICATION_DRAG_END:
		_clear_preview()


func _process(delta: float) -> void:
	var needs_redraw := false
	for index in range(transient_effects.size() - 1, -1, -1):
		var effect := transient_effects[index]
		effect["time_left"] = effect.get("time_left", 0.0) - delta
		if effect["time_left"] <= 0.0:
			transient_effects.remove_at(index)
		else:
			transient_effects[index] = effect
		needs_redraw = true

	if needs_redraw:
		queue_redraw()


func _has_point(point: Vector2) -> bool:
	return _get_drop_interaction_rect().has_point(point)


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if not (data is Dictionary) or not data.has("piece"):
		_clear_preview()
		return false

	var piece: Dictionary = data["piece"]
	var previous_valid := preview_valid and not preview_piece.is_empty()
	var previous_origin := preview_origin
	preview_piece = TetrominoLibraryScript.duplicate_piece(piece)
	preview_origin = _get_drop_origin(preview_piece, at_position)
	preview_valid = can_place_piece(preview_piece, preview_origin)
	if preview_valid and (not previous_valid or previous_origin != preview_origin):
		valid_hover_entered.emit(preview_origin)
	queue_redraw()
	return preview_valid


func _drop_data(at_position: Vector2, data: Variant) -> void:
	if not _can_drop_data(at_position, data):
		_clear_preview()
		return

	var piece: Dictionary = data["piece"]
	var slot_path: NodePath = data.get("slot_path", NodePath())
	place_piece(piece, preview_origin)
	var cleared_units := clear_completed_units()
	piece_placed.emit(slot_path, cleared_units)
	_clear_preview()


func can_place_piece(piece: Dictionary, origin: Vector2i) -> bool:
	var cells: Array[Vector2i] = piece.get("cells", [])
	for cell in cells:
		var board_cell := origin + cell
		if board_cell.x < 0 or board_cell.x >= columns:
			return false
		if board_cell.y < 0 or board_cell.y >= rows:
			return false
		if occupied_cells.has(board_cell):
			return false
	return true


func place_piece(piece: Dictionary, origin: Vector2i) -> void:
	var cells: Array[Vector2i] = piece.get("cells", [])
	var piece_color: Color = piece.get("color", Color.WHITE)
	for cell in cells:
		occupied_cells[origin + cell] = piece_color
	if not Engine.is_editor_hint():
		_spawn_relative_effect(cells, origin, piece_color, "place")
	queue_redraw()


func clear_completed_units() -> int:
	var completed_rows: Array[int] = []
	var completed_columns: Array[int] = []
	var cleared_cell_map: Dictionary = {}

	for row in range(rows):
		var row_complete := true
		for column in range(columns):
			if not occupied_cells.has(Vector2i(column, row)):
				row_complete = false
				break
		if row_complete:
			completed_rows.append(row)

	for column in range(columns):
		var column_complete := true
		for row in range(rows):
			if not occupied_cells.has(Vector2i(column, row)):
				column_complete = false
				break
		if column_complete:
			completed_columns.append(column)

	if completed_rows.is_empty() and completed_columns.is_empty():
		return 0

	for row in completed_rows:
		for column in range(columns):
			var board_cell := Vector2i(column, row)
			if occupied_cells.has(board_cell):
				cleared_cell_map[board_cell] = true
			occupied_cells.erase(board_cell)

	for column in completed_columns:
		for row in range(rows):
			var board_cell := Vector2i(column, row)
			if occupied_cells.has(board_cell):
				cleared_cell_map[board_cell] = true
			occupied_cells.erase(board_cell)

	if not Engine.is_editor_hint():
		var cleared_cells: Array[Vector2i] = []
		for board_cell in cleared_cell_map.keys():
			cleared_cells.append(board_cell)
		_spawn_absolute_effect(cleared_cells, clear_flash_color, "clear")
	queue_redraw()
	return completed_rows.size() + completed_columns.size()


func can_place_piece_anywhere(piece: Dictionary) -> bool:
	if piece.is_empty():
		return false

	var piece_size: Vector2i = TetrominoLibraryScript.get_piece_size(piece)
	for row in range(rows - piece_size.y + 1):
		for column in range(columns - piece_size.x + 1):
			if can_place_piece(piece, Vector2i(column, row)):
				return true
	return false


func reset_board() -> void:
	occupied_cells.clear()
	preview_piece.clear()
	preview_origin = Vector2i.ZERO
	preview_valid = false
	transient_effects.clear()
	queue_redraw()


func configure_grid(new_columns: int, new_rows: int) -> void:
	columns = maxi(1, new_columns)
	rows = maxi(1, new_rows)
	_update_minimum_size()
	reset_board()


func _draw() -> void:
	if columns <= 0 or rows <= 0:
		return

	var board_rect := _get_visual_board_rect()
	if board_rect.size.x <= 0.0 or board_rect.size.y <= 0.0:
		return

	var visual_cell_count := _get_visual_cell_count()
	var active_rect := _get_active_board_rect()
	draw_rect(board_rect.grow(14.0), glow_color, true)
	draw_rect(board_rect.grow(6.0), Color(1.0, 1.0, 1.0, 0.03), false, 2.0)
	draw_rect(board_rect, background_color, true)

	for row in range(visual_cell_count):
		for column in range(visual_cell_count):
			var visual_cell := Vector2i(column, row)
			var board_cell := _visual_to_board_cell(visual_cell)
			var cell_rect := _get_visual_cell_rect(visual_cell)
			var is_active_cell := _is_board_cell_in_bounds(board_cell)
			var fill := inactive_cell_color_a if (row + column) % 2 == 0 else inactive_cell_color_b
			if is_active_cell:
				fill = cell_color_a if (board_cell.y + board_cell.x) % 2 == 0 else cell_color_b
			if is_active_cell and occupied_cells.has(board_cell):
				fill = occupied_cells[board_cell]
			draw_rect(cell_rect, fill, true)
			if is_active_cell and occupied_cells.has(board_cell):
				draw_rect(cell_rect, placed_cell_outline_color, false, 2.0)
			elif not is_active_cell:
				draw_rect(cell_rect, inactive_cell_outline_color, false, 1.0)

	_draw_transient_effects()
	_draw_preview()

	var cell_width := _get_cell_width()
	var cell_height := _get_cell_height()
	for x in range(visual_cell_count + 1):
		var x_pos := x * cell_width
		draw_line(
			board_rect.position + Vector2(x_pos, 0.0),
			board_rect.position + Vector2(x_pos, board_rect.size.y),
			inactive_grid_color,
			1.0,
			true
		)

	for y in range(visual_cell_count + 1):
		var y_pos := y * cell_height
		draw_line(
			board_rect.position + Vector2(0.0, y_pos),
			board_rect.position + Vector2(board_rect.size.x, y_pos),
			inactive_grid_color,
			1.0,
			true
		)

	for x in range(columns + 1):
		var x_pos := active_rect.position.x + x * cell_width
		draw_line(
			Vector2(x_pos, active_rect.position.y),
			Vector2(x_pos, active_rect.position.y + active_rect.size.y),
			grid_color,
			1.0,
			true
		)

	for y in range(rows + 1):
		var y_pos := active_rect.position.y + y * cell_height
		draw_line(
			Vector2(active_rect.position.x, y_pos),
			Vector2(active_rect.position.x + active_rect.size.x, y_pos),
			grid_color,
			1.0,
			true
		)

	var outer_border_color := border_color if columns == rows else border_color.lerp(inactive_cell_color_b, 0.42)
	draw_rect(board_rect, outer_border_color, false, border_width)
	if columns != rows:
		draw_rect(active_rect, border_color, false, maxf(1.0, border_width - 0.75))


func _draw_preview() -> void:
	if preview_piece.is_empty():
		return

	var cells: Array[Vector2i] = preview_piece.get("cells", [])
	var piece_color: Color = preview_piece.get("color", Color.WHITE)
	var overlay_color := piece_color.lerp(
		preview_invalid_tint if not preview_valid else preview_valid_tint,
		0.45
	)
	overlay_color.a = 0.6 if preview_valid else 0.45

	for cell in cells:
		var board_cell := preview_origin + cell
		if board_cell.x < 0 or board_cell.x >= columns:
			continue
		if board_cell.y < 0 or board_cell.y >= rows:
			continue
		var cell_rect := _get_cell_rect(board_cell)
		draw_rect(cell_rect, overlay_color, true)
		draw_rect(
			cell_rect,
			border_color if preview_valid else preview_invalid_tint,
			false,
			2.0
		)


func _draw_transient_effects() -> void:
	for effect in transient_effects:
		var duration: float = maxf(effect.get("duration", 0.001), 0.001)
		var time_left: float = effect.get("time_left", 0.0)
		var progress := clampf(1.0 - time_left / duration, 0.0, 1.0)
		var cells: Array[Vector2i] = effect.get("cells", [])
		var color: Color = effect.get("color", Color.WHITE)
		var mode: String = effect.get("mode", "place")

		for board_cell in cells:
			if board_cell.x < 0 or board_cell.x >= columns:
				continue
			if board_cell.y < 0 or board_cell.y >= rows:
				continue

			var base_rect := _get_cell_rect(board_cell)
			if mode == "clear":
				var flash_fill := color
				flash_fill.a = (1.0 - progress) * 0.34
				draw_rect(base_rect.grow(lerpf(8.0, 2.0, progress)), flash_fill, true)

				var flash_outline := Color.WHITE
				flash_outline.a = (1.0 - progress) * 0.92
				draw_rect(base_rect.grow(lerpf(3.0, 0.5, progress)), flash_outline, false, 3.0)
			else:
				var pulse_fill := color
				pulse_fill.a = (1.0 - progress) * 0.22
				draw_rect(base_rect.grow(lerpf(12.0, 3.0, progress)), pulse_fill, true)

				var pulse_outline := color.lightened(0.25)
				pulse_outline.a = (1.0 - progress) * 0.8
				draw_rect(base_rect.grow(lerpf(4.0, 1.0, progress)), pulse_outline, false, 2.0)


func _spawn_relative_effect(cells: Array[Vector2i], origin: Vector2i, color: Color, mode: String) -> void:
	var absolute_cells: Array[Vector2i] = []
	for cell in cells:
		absolute_cells.append(origin + cell)
	_spawn_absolute_effect(absolute_cells, color, mode)


func _spawn_absolute_effect(cells: Array[Vector2i], color: Color, mode: String) -> void:
	if cells.is_empty():
		return

	var duration := place_effect_duration if mode == "place" else clear_effect_duration
	transient_effects.append({
		"cells": cells,
		"color": color,
		"mode": mode,
		"duration": duration,
		"time_left": duration
	})
	queue_redraw()


func _get_drop_origin(piece: Dictionary, at_position: Vector2) -> Vector2i:
	var effective_position := _get_effective_drop_position(at_position) - _get_visual_board_rect().position
	var hovered_cell := Vector2i(
		int(floor(effective_position.x / _get_cell_width())),
		int(floor(effective_position.y / _get_cell_height()))
	)
	var board_hovered_cell := _visual_to_board_cell(hovered_cell)
	var piece_size: Vector2i = TetrominoLibraryScript.get_piece_size(piece)
	return board_hovered_cell - Vector2i(piece_size.x / 2, piece_size.y / 2)


func _get_cell_rect(board_cell: Vector2i) -> Rect2:
	return _get_visual_cell_rect(_board_to_visual_cell(board_cell))


func _get_cell_width() -> float:
	var visual_cell_count := _get_visual_cell_count()
	if visual_cell_count <= 0:
		return 0.0
	return _get_visual_board_rect().size.x / float(visual_cell_count)


func _get_cell_height() -> float:
	return _get_cell_width()


func _get_effective_drop_position(at_position: Vector2) -> Vector2:
	if not _uses_mobile_drop_offset():
		return at_position

	return at_position + Vector2(
		_get_cell_width() * mobile_drop_position_offset_in_cells.x,
		_get_cell_height() * mobile_drop_position_offset_in_cells.y
	)


func _get_drop_interaction_rect() -> Rect2:
	var interaction_rect := _get_active_board_rect()
	if not _uses_mobile_drop_offset():
		return interaction_rect

	var side_margin := _get_cell_width() * mobile_drop_hit_side_margin_in_cells
	var top_margin := _get_cell_height() * mobile_drop_hit_top_margin_in_cells
	var bottom_margin := _get_cell_height() * mobile_drop_hit_bottom_margin_in_cells
	return Rect2(
		interaction_rect.position - Vector2(side_margin, top_margin),
		interaction_rect.size + Vector2(side_margin * 2.0, top_margin + bottom_margin)
	)


func _uses_mobile_drop_offset() -> bool:
	return not Engine.is_editor_hint() and OS.has_feature("mobile")


func _update_minimum_size() -> void:
	var visual_cell_count := _get_visual_cell_count()
	custom_minimum_size = Vector2.ONE * float(visual_cell_count) * cell_size


func _get_visual_cell_count() -> int:
	return maxi(columns, rows)


func _get_visual_board_rect() -> Rect2:
	var board_side := minf(size.x, size.y)
	return Rect2(
		Vector2((size.x - board_side) * 0.5, (size.y - board_side) * 0.5),
		Vector2.ONE * board_side
	)


func _get_board_visual_offset() -> Vector2i:
	var visual_cell_count := _get_visual_cell_count()
	return Vector2i(
		(visual_cell_count - columns) / 2,
		(visual_cell_count - rows) / 2
	)


func _get_active_board_rect() -> Rect2:
	var board_rect := _get_visual_board_rect()
	var offset := _get_board_visual_offset()
	var cell_width := _get_cell_width()
	var cell_height := _get_cell_height()
	return Rect2(
		board_rect.position + Vector2(offset.x * cell_width, offset.y * cell_height),
		Vector2(columns * cell_width, rows * cell_height)
	)


func _get_visual_cell_rect(visual_cell: Vector2i) -> Rect2:
	var board_rect := _get_visual_board_rect()
	return Rect2(
		board_rect.position + Vector2(visual_cell.x * _get_cell_width(), visual_cell.y * _get_cell_height()),
		Vector2(_get_cell_width(), _get_cell_height())
	).grow(-2.0)


func _board_to_visual_cell(board_cell: Vector2i) -> Vector2i:
	return board_cell + _get_board_visual_offset()


func _visual_to_board_cell(visual_cell: Vector2i) -> Vector2i:
	return visual_cell - _get_board_visual_offset()


func _is_board_cell_in_bounds(board_cell: Vector2i) -> bool:
	return (
		board_cell.x >= 0
		and board_cell.x < columns
		and board_cell.y >= 0
		and board_cell.y < rows
	)


func _clear_preview() -> void:
	var had_preview := not preview_piece.is_empty() or preview_valid or preview_origin != Vector2i.ZERO
	if not had_preview:
		return
	preview_piece.clear()
	preview_origin = Vector2i.ZERO
	preview_valid = false
	queue_redraw()
