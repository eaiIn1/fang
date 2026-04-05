@tool
extends Control
class_name PieceView

const TetrominoLibraryScript := preload("res://scripts/tetromino_library.gd")

@export var padding: float = 10.0
@export var outline_color: Color = Color(1.0, 0.992, 0.965, 0.68)
@export var highlight_color: Color = Color(1.0, 1.0, 1.0, 0.18)

var piece_data: Dictionary = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_piece(piece: Dictionary) -> void:
	piece_data = TetrominoLibraryScript.duplicate_piece(piece)
	queue_redraw()


func clear_piece() -> void:
	piece_data.clear()
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	if piece_data.is_empty():
		return

	var cells: Array[Vector2i] = piece_data.get("cells", [])
	var piece_size: Vector2i = TetrominoLibraryScript.get_piece_size(piece_data)
	var available_size := Vector2(
		maxf(8.0, size.x - padding * 2.0),
		maxf(8.0, size.y - padding * 2.0)
	)
	var draw_cell_size := floorf(minf(
		available_size.x / maxf(1.0, piece_size.x),
		available_size.y / maxf(1.0, piece_size.y)
	))
	draw_cell_size = maxf(draw_cell_size, 12.0)

	var piece_pixel_size := Vector2(piece_size) * draw_cell_size
	var origin := (size - piece_pixel_size) * 0.5
	var fill_color: Color = piece_data.get("color", Color.WHITE)

	for cell in cells:
		var cell_rect := Rect2(
			origin + Vector2(cell) * draw_cell_size,
			Vector2.ONE * draw_cell_size
		).grow(-2.0)
		# Draw shadow for depth
		var shadow_rect := Rect2(cell_rect.position + Vector2(2, 2), cell_rect.size)
		draw_rect(shadow_rect, Color(0, 0, 0, 0.3), true)
		# Draw fill
		draw_rect(cell_rect, fill_color, true)
		# Draw highlight for top-left
		var highlight_rect := Rect2(cell_rect.position, cell_rect.size * 0.4)
		draw_rect(highlight_rect, highlight_color, true)
		# Draw outline
		draw_rect(cell_rect, outline_color, false, 2.0)
