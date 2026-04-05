@tool
extends Control

const ElectroSfxScript := preload("res://scripts/electro_sfx.gd")
const PieceCatalogCardScript: GDScript = preload("res://scripts/piece_catalog_card.gd")
const TetrominoLibraryScript := preload("res://scripts/tetromino_library.gd")
const BOARD_HEIGHT_RATIO := 0.8
const SCORE_PANEL_SIZE := Vector2(252, 108)
const SLOT_SIZE := Vector2(160, 160)
const SLOT_GAP := 18.0
const BOARD_TO_PANEL_GAP := 40.0
const SCREEN_MARGIN := 24.0
const SCORE_TO_TOGGLE_GAP := 16.0
const MIN_BOARD_UI_CLEARANCE := 12.0
const EDITOR_PREVIEW_PIECES := ["T", "L", "O"]
const SCORE_BASE := 100
const DEBUG_PANEL_SIZE := Vector2(252, 560)
const DEBUG_TOGGLE_SIZE := Vector2(120, 44)
const DEBUG_TOGGLE_GAP := 12.0
const DEFAULT_AUDIO_LEVEL := 0.82
const UI_SCALE_DEFAULT := 1.0
const UI_SCALE_MIN := 0.75
const UI_SCALE_HARD_MIN := 0.65
const UI_SCALE_MAX := 1.35
const UI_SCALE_STEP := 0.1
const PIECE_POOL_GRID_GAP := 8.0
const PIECE_POOL_CARD_MIN_WIDTH := 68.0
const PIECE_POOL_CARD_MAX_WIDTH := 112.0
const PIECE_POOL_CARD_MIN_HEIGHT := 100.0
const PIECE_POOL_CARD_FIT_MIN_WIDTH := 52.0
const PIECE_POOL_CARD_HEIGHT_RATIO := 1.14

@onready var board: TetrisBoard = $Board
@onready var right_panel: VBoxContainer = $RightPanel
@onready var score_panel: PanelContainer = $ScorePanel
@onready var score_value_label: Label = $ScorePanel/MarginContainer/ScoreContent/ScoreValue
@onready var score_hint_label: Label = $ScorePanel/MarginContainer/ScoreContent/ScoreHint
@onready var debug_toggle_button: Button = $DebugToggleButton
@onready var debug_panel: PanelContainer = $DebugPanel
@onready var debug_margin_container: MarginContainer = $DebugPanel/MarginContainer
@onready var debug_title_label: Label = $DebugPanel/MarginContainer/DebugContent/DebugHeader/DebugTitle
@onready var debug_close_button: Button = $DebugPanel/MarginContainer/DebugContent/DebugHeader/DebugCloseButton
@onready var debug_note_label: Label = $DebugPanel/MarginContainer/DebugContent/DebugNote
@onready var board_width_label: Label = $DebugPanel/MarginContainer/DebugContent/BoardHeader/BoardWidthLabel
@onready var board_width_spinbox: SpinBox = $DebugPanel/MarginContainer/DebugContent/BoardHeader/BoardWidthSpinBox
@onready var board_height_label: Label = $DebugPanel/MarginContainer/DebugContent/BoardHeader/BoardHeightLabel
@onready var board_height_spinbox: SpinBox = $DebugPanel/MarginContainer/DebugContent/BoardHeader/BoardHeightSpinBox
@onready var pieces_title_label: Label = $DebugPanel/MarginContainer/DebugContent/PiecesTitle
@onready var piece_scroll: ScrollContainer = $DebugPanel/MarginContainer/DebugContent/PieceScroll
@onready var piece_grid: GridContainer = $DebugPanel/MarginContainer/DebugContent/PieceScroll/PieceList
@onready var audio_title_label: Label = $DebugPanel/MarginContainer/DebugContent/AudioTitle
@onready var audio_volume_label: Label = $DebugPanel/MarginContainer/DebugContent/AudioHeader/AudioVolumeLabel
@onready var audio_volume_value_label: Label = $DebugPanel/MarginContainer/DebugContent/AudioHeader/AudioVolumeValue
@onready var audio_volume_slider: HSlider = $DebugPanel/MarginContainer/DebugContent/AudioVolumeSlider
@onready var audio_mute_checkbox: CheckBox = $DebugPanel/MarginContainer/DebugContent/AudioMuteCheckBox
@onready var ui_scale_title_label: Label = $DebugPanel/MarginContainer/DebugContent/UiTitle
@onready var ui_scale_label: Label = $DebugPanel/MarginContainer/DebugContent/UiScaleHeader/UiScaleLabel
@onready var ui_scale_value_label: Label = $DebugPanel/MarginContainer/DebugContent/UiScaleHeader/UiScaleValue
@onready var ui_scale_slider: HSlider = $DebugPanel/MarginContainer/DebugContent/UiScaleSlider
@onready var debug_status_label: Label = $DebugPanel/MarginContainer/DebugContent/DebugStatus
@onready var debug_select_all_button: Button = $DebugPanel/MarginContainer/DebugContent/DebugButtons/DebugSelectAllButton
@onready var debug_apply_button: Button = $DebugPanel/MarginContainer/DebugContent/DebugButtons/DebugApplyButton
@onready var game_over_overlay: Control = $GameOverOverlay
@onready var game_over_label: Label = $GameOverOverlay/OverlayCenter/OverlayPanel/MarginContainer/OverlayContent/GameOverTitle
@onready var overlay_panel: PanelContainer = $GameOverOverlay/OverlayCenter/OverlayPanel
@onready var retry_button: Button = $GameOverOverlay/OverlayCenter/OverlayPanel/MarginContainer/OverlayContent/RetryButton
@onready var slots: Array[PieceSlot] = [
	$RightPanel/SlotTop,
	$RightPanel/SlotMiddle,
	$RightPanel/SlotBottom
]

var score := 0
var is_game_over := false
var score_tween: Tween
var overlay_tween: Tween
var allowed_piece_ids: Array[String] = []
var debug_piece_cards: Dictionary = {}
var audio_players: Dictionary = {}
var audio_base_volumes: Dictionary = {}
var master_audio_level := DEFAULT_AUDIO_LEVEL
var audio_muted := false
var debug_panel_open := false
var ui_scale_setting := UI_SCALE_DEFAULT
var ui_scale_applied := UI_SCALE_DEFAULT


func _ready() -> void:
	allowed_piece_ids = TetrominoLibraryScript.get_piece_ids()
	if Engine.is_editor_hint():
		_setup_editor_preview()
	else:
		randomize()
		_setup_audio()
	if not board.piece_placed.is_connected(_on_board_piece_placed):
		board.piece_placed.connect(_on_board_piece_placed)
	if not board.valid_hover_entered.is_connected(_on_board_valid_hover_entered):
		board.valid_hover_entered.connect(_on_board_valid_hover_entered)
	if not retry_button.pressed.is_connected(_on_retry_button_pressed):
		retry_button.pressed.connect(_on_retry_button_pressed)
	if not debug_toggle_button.pressed.is_connected(_on_debug_toggle_button_pressed):
		debug_toggle_button.pressed.connect(_on_debug_toggle_button_pressed)
	if not debug_close_button.pressed.is_connected(_on_debug_close_button_pressed):
		debug_close_button.pressed.connect(_on_debug_close_button_pressed)
	if not debug_apply_button.pressed.is_connected(_on_debug_apply_pressed):
		debug_apply_button.pressed.connect(_on_debug_apply_pressed)
	if not debug_select_all_button.pressed.is_connected(_on_debug_select_all_pressed):
		debug_select_all_button.pressed.connect(_on_debug_select_all_pressed)
	if not board_width_spinbox.value_changed.is_connected(_on_debug_board_size_changed):
		board_width_spinbox.value_changed.connect(_on_debug_board_size_changed)
	if not board_height_spinbox.value_changed.is_connected(_on_debug_board_size_changed):
		board_height_spinbox.value_changed.connect(_on_debug_board_size_changed)
	if not audio_volume_slider.value_changed.is_connected(_on_audio_volume_changed):
		audio_volume_slider.value_changed.connect(_on_audio_volume_changed)
	if not audio_mute_checkbox.toggled.is_connected(_on_audio_mute_toggled):
		audio_mute_checkbox.toggled.connect(_on_audio_mute_toggled)
	if not ui_scale_slider.value_changed.is_connected(_on_ui_scale_slider_changed):
		ui_scale_slider.value_changed.connect(_on_ui_scale_slider_changed)
	debug_panel_open = Engine.is_editor_hint()
	retry_button.text = "\u518d\u6765\u4e00\u6b21"
	game_over_label.text = "\u6e38\u620f\u7ed3\u675f"
	_build_debug_piece_controls()
	_sync_debug_controls()
	for index in range(slots.size()):
		var slot := slots[index]
		slot.custom_minimum_size = SLOT_SIZE
		if Engine.is_editor_hint():
			slot.set_piece(TetrominoLibraryScript.get_piece_by_id(EDITOR_PREVIEW_PIECES[index % EDITOR_PREVIEW_PIECES.size()]))
		else:
			slot.clear_piece()
	_layout_scene()
	if Engine.is_editor_hint():
		_update_score_ui(0)
		_set_game_over(false)
	else:
		_start_new_round()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout_scene()


func _layout_scene() -> void:
	if not is_node_ready():
		return

	var board_side: float = floorf(size.y * BOARD_HEIGHT_RATIO)
	board.size = Vector2.ONE * board_side
	board.position = Vector2(
		floorf((size.x - board_side) * 0.5),
		floorf((size.y - board_side) * 0.5)
	)
	var ui_scale_limit := _get_current_ui_scale_limit()
	ui_scale_setting = minf(ui_scale_setting, ui_scale_limit)
	ui_scale_applied = clampf(ui_scale_setting, UI_SCALE_HARD_MIN, ui_scale_limit)
	var scaled_ui := Vector2.ONE * ui_scale_applied

	var panel_height := SLOT_SIZE.y * slots.size() + SLOT_GAP * (slots.size() - 1)
	right_panel.size = Vector2(SLOT_SIZE.x, panel_height)
	right_panel.scale = scaled_ui
	right_panel.pivot_offset = Vector2.ZERO
	var desired_x: float = board.position.x + board.size.x + BOARD_TO_PANEL_GAP * ui_scale_applied
	var max_x: float = size.x - right_panel.size.x * ui_scale_applied - SCREEN_MARGIN
	right_panel.position.x = minf(desired_x, max_x)
	right_panel.position.x = maxf(right_panel.position.x, SCREEN_MARGIN)
	right_panel.position.y = clampf(
		board.position.y + (board.size.y - right_panel.size.y * ui_scale_applied) * 0.5,
		SCREEN_MARGIN,
		maxf(SCREEN_MARGIN, size.y - right_panel.size.y * ui_scale_applied - SCREEN_MARGIN)
	)
	score_panel.size = SCORE_PANEL_SIZE
	score_panel.scale = scaled_ui
	score_panel.pivot_offset = Vector2.ZERO
	score_panel.position = Vector2(SCREEN_MARGIN, SCREEN_MARGIN)
	debug_toggle_button.custom_minimum_size = DEBUG_TOGGLE_SIZE
	debug_toggle_button.size = DEBUG_TOGGLE_SIZE
	debug_toggle_button.scale = scaled_ui
	debug_toggle_button.pivot_offset = Vector2.ZERO
	debug_toggle_button.position = Vector2(
		SCREEN_MARGIN,
		score_panel.position.y + score_panel.size.y * ui_scale_applied + SCORE_TO_TOGGLE_GAP * ui_scale_applied
	)
	debug_panel.size = DEBUG_PANEL_SIZE
	debug_panel.scale = Vector2.ONE
	debug_panel.pivot_offset = Vector2.ZERO
	var debug_y := debug_toggle_button.position.y + debug_toggle_button.size.y * ui_scale_applied + DEBUG_TOGGLE_GAP
	debug_panel.position = Vector2(
		SCREEN_MARGIN,
		clampf(debug_y, SCREEN_MARGIN, maxf(SCREEN_MARGIN, size.y - debug_panel.size.y - SCREEN_MARGIN))
	)
	overlay_panel.pivot_offset = overlay_panel.size * 0.5
	retry_button.pivot_offset = retry_button.size * 0.5
	_update_piece_pool_layout()
	_update_ui_scale_controls()


func _refill_slot(slot: PieceSlot) -> void:
	slot.set_piece(TetrominoLibraryScript.get_random_piece_from_ids(allowed_piece_ids))


func _on_board_piece_placed(slot_path: NodePath, cleared_units: int) -> void:
	if is_game_over:
		return

	var slot := get_node_or_null(slot_path) as PieceSlot
	if slot != null:
		slot.clear_piece()
	_play_sfx("place")
	if cleared_units > 0:
		_play_clear_sfx(cleared_units)
	var gained_score := _calculate_score(cleared_units)
	score += gained_score
	_update_score_ui(gained_score, cleared_units)
	_play_score_pulse(gained_score)
	if _are_all_slots_empty():
		_fill_all_slots()
	_evaluate_available_moves()


func _setup_editor_preview() -> void:
	if not board.occupied_cells.is_empty():
		return

	board.place_piece(TetrominoLibraryScript.get_piece_by_id("J"), Vector2i(1, 4))
	board.place_piece(TetrominoLibraryScript.get_piece_by_id("S"), Vector2i(4, 2))
	board.place_piece(TetrominoLibraryScript.get_piece_by_id("I"), Vector2i(2, 6))


func _calculate_score(cleared_units: int) -> int:
	if cleared_units <= 0:
		return 0
	return SCORE_BASE * cleared_units * cleared_units


func _update_score_ui(gained_score: int, cleared_units: int = 0) -> void:
	score_value_label.text = str(score)
	if Engine.is_editor_hint():
		score_value_label.text = "1280"
		score_hint_label.text = "Preview: clear rows and columns"
		return

	if is_game_over:
		score_hint_label.text = "No more valid moves"
		return

	if cleared_units <= 0:
		score_hint_label.text = "Place blocks to fill a row or column"
		return

	score_hint_label.text = "+%d score  |  Cleared %d line%s" % [
		gained_score,
		cleared_units,
		"" if cleared_units == 1 else "s"
	]


func _fill_all_slots() -> void:
	for slot in slots:
		_refill_slot(slot)
	_play_sfx("refill")


func _are_all_slots_empty() -> bool:
	for slot in slots:
		if slot.has_piece():
			return false
	return true


func _evaluate_available_moves() -> void:
	if Engine.is_editor_hint():
		return

	for slot in slots:
		if slot.has_piece() and board.can_place_piece_anywhere(slot.get_piece()):
			_set_game_over(false)
			return

	_set_game_over(true)


func _set_game_over(value: bool) -> void:
	is_game_over = value
	for slot in slots:
		slot.set_interactable(not value)
	if Engine.is_editor_hint():
		game_over_overlay.visible = false
		return

	if overlay_tween != null:
		overlay_tween.kill()

	if value:
		game_over_overlay.visible = true
		game_over_overlay.modulate = Color(1.0, 1.0, 1.0, 0.0)
		overlay_panel.scale = Vector2.ONE * 0.92
		retry_button.scale = Vector2.ONE * 0.96
		game_over_label.text = "\u6e38\u620f\u7ed3\u675f"
		score_hint_label.text = "No more valid moves"
		_play_sfx("game_over")

		overlay_tween = create_tween().set_parallel(true)
		overlay_tween.tween_property(game_over_overlay, "modulate", Color.WHITE, 0.24).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		overlay_tween.tween_property(overlay_panel, "scale", Vector2.ONE, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		overlay_tween.tween_property(retry_button, "scale", Vector2.ONE, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		game_over_overlay.visible = false
		game_over_overlay.modulate = Color.WHITE
		overlay_panel.scale = Vector2.ONE
		retry_button.scale = Vector2.ONE


func _start_new_round() -> void:
	score = 0
	board.configure_grid(int(board_width_spinbox.value), int(board_height_spinbox.value))
	_set_game_over(false)
	for slot in slots:
		slot.clear_piece()
	_fill_all_slots()
	_update_score_ui(0)
	_evaluate_available_moves()
	_sync_debug_controls()
	_layout_scene()


func _on_retry_button_pressed() -> void:
	_play_sfx("ui")
	_start_new_round()


func _play_score_pulse(gained_score: int) -> void:
	if gained_score <= 0 or Engine.is_editor_hint():
		return

	if score_tween != null:
		score_tween.kill()

	var base_scale := Vector2.ONE * ui_scale_applied
	score_panel.scale = base_scale
	score_value_label.modulate = Color.WHITE
	score_hint_label.modulate = Color.WHITE

	score_tween = create_tween()
	score_tween.set_parallel(true)
	score_tween.tween_property(score_panel, "scale", base_scale * 1.08, 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	score_tween.tween_property(score_value_label, "modulate", Color(1.0, 0.945, 0.72, 1.0), 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	score_tween.tween_property(score_hint_label, "modulate", Color(0.996, 0.902, 0.73, 1.0), 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	score_tween.chain().set_parallel(true)
	score_tween.tween_property(score_panel, "scale", base_scale, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
	score_tween.tween_property(score_value_label, "modulate", Color.WHITE, 0.16).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	score_tween.tween_property(score_hint_label, "modulate", Color.WHITE, 0.16).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _build_debug_piece_controls() -> void:
	for child in piece_grid.get_children():
		child.queue_free()
	debug_piece_cards.clear()
	piece_grid.mouse_filter = Control.MOUSE_FILTER_PASS

	for piece_entry in TetrominoLibraryScript.get_piece_catalog():
		var piece_id: String = piece_entry["id"]
		var piece_label: String = piece_entry["label"]
		var piece_size: Vector2i = piece_entry["size"]
		var preview_piece: Dictionary = piece_entry["piece"]
		var piece_card: Variant = PieceCatalogCardScript.new()
		piece_grid.add_child(piece_card)
		piece_card.setup(
			preview_piece,
			piece_id,
			piece_label,
			"%dx%d" % [piece_size.x, piece_size.y],
			allowed_piece_ids.has(piece_id)
		)
		if not piece_card.card_pressed.is_connected(_on_piece_catalog_card_pressed):
			piece_card.card_pressed.connect(_on_piece_catalog_card_pressed)
		debug_piece_cards[piece_id] = piece_card

	_update_piece_pool_layout()
	_update_piece_pool_constraints(false)


func _sync_debug_controls() -> void:
	board_width_spinbox.set_value_no_signal(board.columns)
	board_height_spinbox.set_value_no_signal(board.rows)
	for piece_id in debug_piece_cards.keys():
		var piece_card: Variant = debug_piece_cards[piece_id]
		if piece_card != null:
			piece_card.set_selected(allowed_piece_ids.has(piece_id))
	debug_status_label.text = "Applied: %dx%d, %d pieces" % [
		board.columns,
		board.rows,
		allowed_piece_ids.size()
	]
	audio_volume_slider.set_value_no_signal(master_audio_level * 100.0)
	audio_mute_checkbox.set_pressed_no_signal(audio_muted)
	debug_toggle_button.visible = true
	debug_title_label.text = "DEBUG"
	debug_note_label.text = "\u70b9\u6309\u7f29\u7565\u56fe\u52fe\u9009\uff0c\u79fb\u52a8\u7aef\u53ef\u76f4\u63a5\u6ed1\u52a8\uff0c\u8fc7\u5927\u65b9\u5757\u4f1a\u81ea\u52a8\u53d6\u6d88"
	board_width_label.text = "\u5bbd"
	board_height_label.text = "\u9ad8"
	pieces_title_label.text = "\u65b9\u5757\u6c60"
	audio_title_label.text = "\u97f3\u9891"
	audio_volume_label.text = "\u97f3\u91cf"
	audio_mute_checkbox.text = "\u9759\u97f3"
	ui_scale_title_label.text = "\u754c\u9762"
	ui_scale_label.text = "UI \u7f29\u653e"
	ui_scale_slider.set_value_no_signal(ui_scale_setting * 100.0)
	debug_close_button.text = "\u5173\u95ed"
	debug_select_all_button.text = "\u5168\u9009\u53ef\u7528"
	debug_apply_button.text = "\u5e94\u7528"
	_update_piece_pool_constraints(false)
	_update_piece_pool_layout()
	_update_debug_toggle_button()
	_apply_debug_panel_visibility()
	_update_audio_controls_ui()
	_update_ui_scale_controls()


func _on_debug_select_all_pressed() -> void:
	_play_sfx("ui")
	var selected_count := 0
	var pending_columns := _get_pending_board_columns()
	var pending_rows := _get_pending_board_rows()
	for piece_id in TetrominoLibraryScript.get_piece_ids():
		var piece_card: Variant = debug_piece_cards.get(piece_id)
		if piece_card == null:
			continue
		var fits := TetrominoLibraryScript.can_piece_fit_board(piece_id, pending_columns, pending_rows)
		piece_card.set_selected(fits)
		if fits:
			selected_count += 1
	debug_status_label.text = "\u5df2\u9009\u62e9 %d \u4e2a\u53ef\u7528\u65b9\u5757" % selected_count


func _on_debug_apply_pressed() -> void:
	_update_piece_pool_constraints(true)
	var selected_piece_ids := _get_selected_piece_ids_from_pool()

	if selected_piece_ids.is_empty():
		debug_status_label.text = "\u81f3\u5c11\u4fdd\u7559 1 \u79cd\u65b9\u5757"
		return

	_play_sfx("ui")
	allowed_piece_ids = selected_piece_ids
	debug_status_label.text = "\u5e94\u7528\u6210\u529f\uff0c\u6b63\u5728\u91cd\u5f00"
	_start_new_round()


func _on_piece_catalog_card_pressed(piece_id: String) -> void:
	var piece_card: Variant = debug_piece_cards.get(piece_id)
	if piece_card == null:
		return
	piece_card.set_selected(not piece_card.is_selected())
	_play_sfx("ui")


func _on_debug_board_size_changed(_value: float) -> void:
	_update_piece_pool_constraints(true)


func _get_selected_piece_ids_from_pool() -> Array[String]:
	var selected_piece_ids: Array[String] = []
	for piece_id in TetrominoLibraryScript.get_piece_ids():
		var piece_card: Variant = debug_piece_cards.get(piece_id)
		if piece_card != null and piece_card.is_selected():
			selected_piece_ids.append(piece_id)
	return selected_piece_ids


func _update_piece_pool_layout() -> void:
	if piece_grid == null or piece_scroll == null:
		return

	var panel_content_width := _get_debug_panel_content_width()
	var visible_width: float = minf(piece_scroll.size.x, panel_content_width)
	if visible_width <= 1.0:
		visible_width = panel_content_width
	var scrollbar_reserve := 0.0
	var vertical_scroll_bar: VScrollBar = piece_scroll.get_v_scroll_bar()
	if vertical_scroll_bar != null:
		scrollbar_reserve = ceilf(vertical_scroll_bar.get_combined_minimum_size().x)
	var available_width := maxf(1.0, visible_width - scrollbar_reserve)

	var scale_span := maxf(0.001, UI_SCALE_MAX - UI_SCALE_HARD_MIN)
	var scale_t := clampf((ui_scale_applied - UI_SCALE_HARD_MIN) / scale_span, 0.0, 1.0)
	var target_card_width := lerpf(PIECE_POOL_CARD_MAX_WIDTH, PIECE_POOL_CARD_MIN_WIDTH, scale_t)
	var columns := maxi(1, int(floor((available_width + PIECE_POOL_GRID_GAP) / (target_card_width + PIECE_POOL_GRID_GAP))))
	var actual_card_width := 0.0
	while true:
		actual_card_width = floorf(
			(available_width - PIECE_POOL_GRID_GAP * float(columns - 1)) / float(columns)
		)
		if columns <= 1 or actual_card_width >= PIECE_POOL_CARD_FIT_MIN_WIDTH:
			break
		columns -= 1
	var card_size := Vector2(
		maxf(PIECE_POOL_CARD_FIT_MIN_WIDTH, actual_card_width),
		maxf(PIECE_POOL_CARD_MIN_HEIGHT, actual_card_width * PIECE_POOL_CARD_HEIGHT_RATIO)
	)

	piece_grid.columns = columns
	piece_grid.custom_minimum_size = Vector2(available_width, 0.0)

	for piece_card_variant in debug_piece_cards.values():
		var piece_card: Variant = piece_card_variant
		if piece_card != null:
			piece_card.set_card_size(card_size)


func _get_debug_panel_content_width() -> float:
	if debug_margin_container == null:
		return DEBUG_PANEL_SIZE.x - 32.0
	var margin_left := float(debug_margin_container.get_theme_constant("margin_left"))
	var margin_right := float(debug_margin_container.get_theme_constant("margin_right"))
	return maxf(1.0, DEBUG_PANEL_SIZE.x - margin_left - margin_right)


func _update_piece_pool_constraints(show_feedback: bool) -> void:
	if debug_piece_cards.is_empty():
		return

	var pending_columns := _get_pending_board_columns()
	var pending_rows := _get_pending_board_rows()
	var removed_count := 0

	for piece_id in TetrominoLibraryScript.get_piece_ids():
		var piece_card: Variant = debug_piece_cards.get(piece_id)
		if piece_card == null:
			continue
		var fits := TetrominoLibraryScript.can_piece_fit_board(piece_id, pending_columns, pending_rows)
		piece_card.set_board_compatible(
			fits,
			"" if fits else "\u8d85\u51fa %dx%d \u68cb\u76d8" % [pending_columns, pending_rows]
		)
		if not fits and piece_card.is_selected():
			piece_card.set_selected(false)
			removed_count += 1

	var fallback_piece_label := ""
	if removed_count > 0 and _get_selected_piece_ids_from_pool().is_empty():
		fallback_piece_label = _select_piece_pool_fallback(pending_columns, pending_rows)

	if not show_feedback:
		return
	if removed_count > 0 and fallback_piece_label != "":
		debug_status_label.text = "\u5df2\u53d6\u6d88 %d \u4e2a\u8fc7\u5927\u65b9\u5757\uff0c\u4fdd\u7559 %s" % [
			removed_count,
			fallback_piece_label
		]
	elif removed_count > 0:
		debug_status_label.text = "\u5df2\u53d6\u6d88 %d \u4e2a\u8fc7\u5927\u65b9\u5757" % removed_count
	elif fallback_piece_label != "":
		debug_status_label.text = "\u5df2\u4fdd\u7559 %s \u4f5c\u4e3a\u53ef\u7528\u65b9\u5757" % fallback_piece_label


func _select_piece_pool_fallback(board_columns: int, board_rows: int) -> String:
	var candidate_ids := PackedStringArray(["DOT"])
	for piece_id in TetrominoLibraryScript.get_piece_ids():
		if not candidate_ids.has(piece_id):
			candidate_ids.append(piece_id)

	for candidate_id in candidate_ids:
		if not TetrominoLibraryScript.can_piece_fit_board(candidate_id, board_columns, board_rows):
			continue
		var piece_card: Variant = debug_piece_cards.get(candidate_id)
		if piece_card == null:
			continue
		piece_card.set_selected(true)
		return _get_piece_label(candidate_id)
	return ""


func _get_pending_board_columns() -> int:
	return maxi(1, int(round(board_width_spinbox.value)))


func _get_pending_board_rows() -> int:
	return maxi(1, int(round(board_height_spinbox.value)))


func _get_piece_label(piece_id: String) -> String:
	var piece: Dictionary = TetrominoLibraryScript.get_piece_by_id(piece_id)
	return piece.get("label", piece_id)


func _on_debug_toggle_button_pressed() -> void:
	_set_debug_panel_open(not debug_panel_open)


func _on_debug_close_button_pressed() -> void:
	_set_debug_panel_open(false)


func _on_ui_scale_slider_changed(value: float) -> void:
	_set_ui_scale(value / 100.0)


func _setup_audio() -> void:
	if not audio_players.is_empty():
		return

	_create_audio_player("ambient", "SfxAmbient", ElectroSfxScript.create_ambient_sound(), -27.5, 1)
	_create_audio_player("place", "SfxPlace", ElectroSfxScript.create_place_sound(), -12.0)
	_create_audio_player("clear", "SfxClear", ElectroSfxScript.create_clear_sound(), -9.5)
	_create_audio_player("refill", "SfxRefill", ElectroSfxScript.create_refill_sound(), -13.0)
	_create_audio_player("hover", "SfxHover", ElectroSfxScript.create_hover_sound(), -18.0, 1)
	_create_audio_player("game_over", "SfxGameOver", ElectroSfxScript.create_game_over_sound(), -10.0)
	_create_audio_player("ui", "SfxUi", ElectroSfxScript.create_ui_sound(), -15.0)
	_apply_audio_settings()
	var ambient_player := audio_players.get("ambient") as AudioStreamPlayer
	if ambient_player != null and not ambient_player.playing:
		ambient_player.play()


func _create_audio_player(
	key: String,
	player_name: String,
	stream: AudioStream,
	base_volume_db: float,
	max_polyphony: int = 2
) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = player_name
	player.stream = stream
	player.volume_db = base_volume_db
	player.max_polyphony = max_polyphony
	add_child(player)
	audio_players[key] = player
	audio_base_volumes[key] = base_volume_db
	return player


func _play_sfx(sfx_name: String) -> void:
	if Engine.is_editor_hint():
		return
	var player := audio_players.get(sfx_name) as AudioStreamPlayer
	if player == null:
		return
	player.pitch_scale = 1.0
	player.play()


func _apply_audio_settings() -> void:
	var master_volume_db := _get_master_volume_db()
	for key in audio_players.keys():
		var player := audio_players.get(key) as AudioStreamPlayer
		if player == null:
			continue
		var base_volume_db: float = audio_base_volumes.get(key, 0.0)
		player.volume_db = -80.0 if master_volume_db <= -79.0 else base_volume_db + master_volume_db
	_update_audio_controls_ui()


func _get_master_volume_db() -> float:
	if audio_muted or master_audio_level <= 0.001:
		return -80.0
	return linear_to_db(master_audio_level)


func _update_audio_controls_ui() -> void:
	audio_volume_value_label.text = "\u9759\u97f3" if audio_muted else "%d%%" % int(round(master_audio_level * 100.0))


func _update_ui_scale_controls() -> void:
	ui_scale_value_label.text = "%d%%" % int(round(ui_scale_applied * 100.0))


func _update_debug_toggle_button() -> void:
	debug_toggle_button.text = "\u6536\u8d77\u8bbe\u7f6e" if debug_panel_open else "\u8bbe\u7f6e"


func _apply_debug_panel_visibility() -> void:
	debug_panel.visible = debug_panel_open or Engine.is_editor_hint()


func _set_debug_panel_open(value: bool, play_sfx: bool = true) -> void:
	debug_panel_open = value
	_update_debug_toggle_button()
	_apply_debug_panel_visibility()
	if play_sfx:
		_play_sfx("ui")


func _adjust_ui_scale(delta: float) -> void:
	_set_ui_scale(ui_scale_setting + delta)


func _set_ui_scale(value: float) -> void:
	var limited_max := _get_current_ui_scale_limit()
	var user_max := limited_max if limited_max < UI_SCALE_MIN else maxf(UI_SCALE_MIN, limited_max)
	var min_scale := limited_max if limited_max < UI_SCALE_MIN else UI_SCALE_MIN
	var next_scale := clampf(snappedf(value, UI_SCALE_STEP), min_scale, user_max)
	if is_equal_approx(ui_scale_setting, next_scale):
		return
	ui_scale_setting = next_scale
	if next_scale >= user_max - 0.001 and user_max < UI_SCALE_MAX - 0.001 and value > next_scale:
		debug_status_label.text = "UI \u5df2\u8c03\u6574\u5230 %d%%\uff08\u5f53\u524d\u5c4f\u5e55\u5b89\u5168\u4e0a\u9650\uff09" % int(round(next_scale * 100.0))
	else:
		debug_status_label.text = "UI \u5df2\u8c03\u6574\u5230 %d%%" % int(round(next_scale * 100.0))
	ui_scale_value_label.text = "%d%%" % int(round(next_scale * 100.0))
	ui_scale_slider.set_value_no_signal(next_scale * 100.0)
	_layout_scene()
	_play_sfx("ui")


func _get_current_ui_scale_limit() -> float:
	if size.x <= 0.0 or size.y <= 0.0:
		return UI_SCALE_DEFAULT

	var board_side: float = floorf(size.y * BOARD_HEIGHT_RATIO)
	var board_left: float = floorf((size.x - board_side) * 0.5)
	var board_right: float = board_left + board_side
	var left_available_width := board_left - SCREEN_MARGIN - MIN_BOARD_UI_CLEARANCE
	var right_available_width := size.x - board_right - SCREEN_MARGIN - MIN_BOARD_UI_CLEARANCE
	var available_height := size.y - SCREEN_MARGIN * 2.0
	var right_panel_base_height := SLOT_SIZE.y * slots.size() + SLOT_GAP * maxf(0.0, slots.size() - 1.0)
	var left_stack_height := SCORE_PANEL_SIZE.y + SCORE_TO_TOGGLE_GAP + DEBUG_TOGGLE_SIZE.y
	var safe_limit := UI_SCALE_MAX

	if left_available_width > 0.0:
		safe_limit = minf(safe_limit, left_available_width / SCORE_PANEL_SIZE.x)
	if right_available_width > 0.0:
		safe_limit = minf(safe_limit, right_available_width / SLOT_SIZE.x)
	if available_height > 0.0:
		safe_limit = minf(safe_limit, available_height / right_panel_base_height)
		safe_limit = minf(safe_limit, available_height / left_stack_height)

	return clampf(safe_limit, UI_SCALE_HARD_MIN, UI_SCALE_MAX)


func _play_clear_sfx(cleared_units: int) -> void:
	if Engine.is_editor_hint():
		return
	var player := audio_players.get("clear") as AudioStreamPlayer
	if player == null:
		return
	player.pitch_scale = 1.0 + minf(0.24, 0.08 * maxf(0.0, cleared_units - 1.0))
	player.play()


func _on_board_valid_hover_entered(_origin: Vector2i) -> void:
	if is_game_over:
		return
	_play_sfx("hover")


func _on_audio_volume_changed(value: float) -> void:
	master_audio_level = clampf(value / 100.0, 0.0, 1.0)
	_apply_audio_settings()


func _on_audio_mute_toggled(button_pressed: bool) -> void:
	audio_muted = button_pressed
	_apply_audio_settings()
	if not audio_muted:
		_play_sfx("ui")
