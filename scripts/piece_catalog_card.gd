@tool
extends PanelContainer
class_name PieceCatalogCard

const PieceViewScript := preload("res://scripts/piece_view.gd")
const TAP_DRAG_THRESHOLD := 18.0

signal card_pressed(piece_id: String)

const TITLE_COLOR := Color(0.933, 0.968, 1.0, 1.0)
const TITLE_SELECTED_COLOR := Color(1.0, 0.925, 0.722, 1.0)
const TITLE_DISABLED_COLOR := Color(0.714, 0.741, 0.804, 0.82)
const DETAIL_COLOR := Color(0.647, 0.902, 1.0, 0.92)
const DETAIL_SELECTED_COLOR := Color(1.0, 0.804, 0.549, 0.96)
const DETAIL_DISABLED_COLOR := Color(0.596, 0.627, 0.71, 0.78)

var piece_id := ""
var title_text := ""
var detail_text := ""
var disabled_reason := ""
var selected := false
var board_compatible := true
var active_pointer_kind := ""
var active_pointer_index := -1
var pointer_origin := Vector2.ZERO
var pointer_drag_distance := 0.0

var preview: PieceView
var title_label: Label
var detail_label: Label
var style_normal: StyleBoxFlat
var style_selected: StyleBoxFlat
var style_disabled: StyleBoxFlat


func _init() -> void:
	style_normal = _build_style(
		Color(0.094, 0.125, 0.235, 0.98),
		Color(0.212, 0.839, 1.0, 0.32)
	)
	style_selected = _build_style(
		Color(0.145, 0.153, 0.294, 0.99),
		Color(1.0, 0.525, 0.349, 0.98)
	)
	style_disabled = _build_style(
		Color(0.114, 0.125, 0.173, 0.94),
		Color(0.561, 0.604, 0.686, 0.22)
	)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	focus_mode = Control.FOCUS_NONE
	clip_contents = true
	_ensure_ui()
	_update_visuals()


func setup(piece: Dictionary, new_piece_id: String, new_title: String, new_detail: String, initially_selected: bool) -> void:
	_ensure_ui()
	piece_id = new_piece_id
	title_text = new_title
	detail_text = new_detail
	selected = initially_selected
	preview.set_piece(piece)
	_update_visuals()


func set_selected(value: bool) -> void:
	if selected == value:
		return
	selected = value
	_update_visuals()


func is_selected() -> bool:
	return selected


func set_board_compatible(value: bool, reason: String = "") -> void:
	if board_compatible == value and disabled_reason == reason:
		return
	board_compatible = value
	disabled_reason = reason
	_update_visuals()


func set_card_size(card_size: Vector2) -> void:
	_ensure_ui()
	custom_minimum_size = card_size
	var preview_height := maxf(50.0, card_size.y - 48.0)
	preview.custom_minimum_size = Vector2(maxf(36.0, card_size.x - 18.0), preview_height)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_screen_touch(event)
	elif event is InputEventScreenDrag:
		_handle_screen_drag(event)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event)


func _ensure_ui() -> void:
	if preview != null:
		return

	var margin := MarginContainer.new()
	margin.name = "Margin"
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	add_child(margin)

	var box := VBoxContainer.new()
	box.name = "Content"
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 4)
	margin.add_child(box)

	preview = PieceViewScript.new()
	preview.name = "Preview"
	preview.custom_minimum_size = Vector2(72, 72)
	preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(preview)

	title_label = Label.new()
	title_label.name = "Title"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.add_theme_font_size_override("font_size", 13)
	box.add_child(title_label)

	detail_label = Label.new()
	detail_label.name = "Detail"
	detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_label.add_theme_font_size_override("font_size", 10)
	box.add_child(detail_label)


func _update_visuals() -> void:
	if preview == null or title_label == null or detail_label == null:
		return

	var active_style := style_disabled
	if board_compatible:
		active_style = style_selected if selected else style_normal
	add_theme_stylebox_override("panel", active_style)

	title_label.text = title_text
	if not board_compatible and disabled_reason != "":
		detail_label.text = disabled_reason
	else:
		detail_label.text = detail_text

	title_label.add_theme_color_override(
		"font_color",
		TITLE_DISABLED_COLOR if not board_compatible else (TITLE_SELECTED_COLOR if selected else TITLE_COLOR)
	)
	detail_label.add_theme_color_override(
		"font_color",
		DETAIL_DISABLED_COLOR if not board_compatible else (DETAIL_SELECTED_COLOR if selected else DETAIL_COLOR)
	)
	preview.modulate = Color(1.0, 1.0, 1.0, 0.45 if not board_compatible else 1.0)
	tooltip_text = _build_tooltip_text()


func _build_style(background: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = border
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_right = 16
	style.corner_radius_bottom_left = 16
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.18)
	style.shadow_size = 4
	return style


func _build_tooltip_text() -> String:
	var lines := PackedStringArray()
	lines.append("%s [%s]" % [title_text, piece_id])
	lines.append(detail_text)
	if not board_compatible and disabled_reason != "":
		lines.append(disabled_reason)
	return "\n".join(lines)


func _handle_screen_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		_begin_pointer_session("touch", event.index, event.position)
		return
	if active_pointer_kind != "touch" or active_pointer_index != event.index:
		return
	_finish_pointer_session(event.position)


func _handle_screen_drag(event: InputEventScreenDrag) -> void:
	if active_pointer_kind != "touch" or active_pointer_index != event.index:
		return
	pointer_drag_distance = maxf(pointer_drag_distance, event.position.distance_to(pointer_origin))


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.pressed:
		_begin_pointer_session("mouse", event.button_index, event.position)
		return
	if active_pointer_kind != "mouse" or active_pointer_index != event.button_index:
		return
	_finish_pointer_session(event.position)


func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if active_pointer_kind != "mouse":
		return
	if (event.button_mask & MOUSE_BUTTON_MASK_LEFT) == 0:
		return
	pointer_drag_distance = maxf(pointer_drag_distance, event.position.distance_to(pointer_origin))


func _begin_pointer_session(pointer_kind: String, pointer_index: int, pointer_position: Vector2) -> void:
	active_pointer_kind = pointer_kind
	active_pointer_index = pointer_index
	pointer_origin = pointer_position
	pointer_drag_distance = 0.0


func _finish_pointer_session(pointer_position: Vector2) -> void:
	var should_press := (
		board_compatible
		and pointer_drag_distance <= TAP_DRAG_THRESHOLD
		and Rect2(Vector2.ZERO, size).has_point(pointer_position)
	)
	active_pointer_kind = ""
	active_pointer_index = -1
	pointer_origin = Vector2.ZERO
	pointer_drag_distance = 0.0

	if should_press:
		card_pressed.emit(piece_id)
		accept_event()
