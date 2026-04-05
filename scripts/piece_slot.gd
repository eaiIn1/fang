@tool
extends Control
class_name PieceSlot

const PieceViewScript := preload("res://scripts/piece_view.gd")
const TetrominoLibraryScript := preload("res://scripts/tetromino_library.gd")

@export var slot_background_color: Color = Color(0.125, 0.086, 0.239, 0.96)
@export var slot_border_color: Color = Color(1.0, 0.514, 0.439, 0.9)
@export var slot_glow_color: Color = Color(1.0, 0.514, 0.439, 0.12)
@export var empty_hint_color: Color = Color(1.0, 0.914, 0.765, 0.22)
@export var corner_radius: float = 16.0

var piece_data: Dictionary = {}
var preview: Control
var drag_enabled := true
var appearance_tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_DRAG
	custom_minimum_size = Vector2(150, 150)
	preview = PieceViewScript.new()
	preview.name = "Preview"
	preview.set_anchors_preset(Control.PRESET_FULL_RECT)
	preview.offset_left = 12.0
	preview.offset_top = 12.0
	preview.offset_right = -12.0
	preview.offset_bottom = -12.0
	add_child(preview)
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		pivot_offset = size * 0.5


func set_piece(piece: Dictionary) -> void:
	piece_data = TetrominoLibraryScript.duplicate_piece(piece)
	preview.set_piece(piece_data)
	if not Engine.is_editor_hint():
		_play_spawn_tween()
	queue_redraw()


func clear_piece() -> void:
	piece_data.clear()
	preview.clear_piece()
	queue_redraw()


func has_piece() -> bool:
	return not piece_data.is_empty()


func get_piece() -> Dictionary:
	return TetrominoLibraryScript.duplicate_piece(piece_data)


func set_interactable(enabled: bool) -> void:
	drag_enabled = enabled
	mouse_default_cursor_shape = Control.CURSOR_DRAG if enabled else Control.CURSOR_ARROW


func _get_drag_data(_at_position: Vector2) -> Variant:
	if piece_data.is_empty() or not drag_enabled:
		return null

	var drag_preview := PieceViewScript.new()
	drag_preview.custom_minimum_size = Vector2(120, 120)
	drag_preview.size = Vector2(120, 120)
	drag_preview.set_piece(piece_data)
	drag_preview.modulate = Color(1.0, 1.0, 1.0, 0.94)
	set_drag_preview(drag_preview)

	return {
		"piece": TetrominoLibraryScript.duplicate_piece(piece_data),
		"slot_path": get_path()
	}


func _draw() -> void:
	var slot_rect := Rect2(Vector2.ZERO, size)
	draw_rect(slot_rect.grow(8.0), slot_glow_color, true)
	draw_rect(slot_rect, slot_background_color, true)
	draw_rect(slot_rect.grow(-6.0), Color(1.0, 1.0, 1.0, 0.04), false, 2.0)
	draw_rect(slot_rect, slot_border_color, false, 3.0)

	if piece_data.is_empty():
		var hint_rect := slot_rect.grow(-size.x * 0.3)
		draw_rect(hint_rect, empty_hint_color, false, 2.0)


func _play_spawn_tween() -> void:
	if appearance_tween != null:
		appearance_tween.kill()

	scale = Vector2.ONE * 0.94
	modulate = Color(1.0, 1.0, 1.0, 0.82)
	appearance_tween = create_tween().set_parallel(true)
	appearance_tween.tween_property(self, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	appearance_tween.tween_property(self, "modulate", Color.WHITE, 0.16).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
