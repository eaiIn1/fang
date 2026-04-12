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
const DEBUG_PANEL_SIZE := Vector2(320, 560)
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
@onready var debug_title_label: Label = $DebugPanel/MarginContainer/ScrollContainer/DebugContent/DebugHeader/DebugTitle
@onready var debug_close_button: Button = $DebugPanel/MarginContainer/ScrollContainer/DebugContent/DebugHeader/DebugCloseButton
@onready var debug_note_label: Label = $DebugPanel/MarginContainer/ScrollContainer/DebugContent/DebugNote
@onready var board_width_label: Label = $DebugPanel/MarginContainer/ScrollContainer/DebugContent/BoardHeader/BoardWidthSection/BoardWidthLabel
@onready var board_width_spinbox: SpinBox = $DebugPanel/MarginContainer/ScrollContainer/DebugContent/BoardHeader/BoardWidthSection/BoardWidthSpinBox
@onready var board_width_decrease_button: Button = $DebugPanel/MarginContainer/ScrollContainer/DebugContent/BoardHeader/BoardWidthSection/BoardWidthDecreaseButton
@onready var board_width_increase_button: Button = $DebugPanel/MarginContainer/ScrollContainer/DebugContent/BoardHeader/BoardWidthSection/BoardWidthIncreaseButton
@onready var board_height_label: Label = $DebugPanel/MarginContainer/ScrollContainer/DebugContent/BoardHeader/BoardHeightSection/BoardHeightLabel
@onready var board_height_spinbox: SpinBox = $DebugPanel/MarginContainer/ScrollContainer/DebugContent/BoardHeader/BoardHeightSection/BoardHeightSpinBox
@onready var board_height_decrease_button: Button = $DebugPanel/MarginContainer/ScrollContainer/DebugContent/BoardHeader/BoardHeightSection/BoardHeightDecreaseButton
@onready var board_height_increase_button: Button = $DebugPanel/MarginContainer/ScrollContainer/DebugContent/BoardHeader/BoardHeightSection/BoardHeightIncreaseButton
@onready var pieces_title_label: Label = $DebugPanel/MarginContainer/ScrollContainer/DebugContent/PiecesTitle
@onready var piece_scroll: ScrollContainer = $DebugPanel/MarginContainer/ScrollContainer/DebugContent/PieceScroll
@onready var piece_grid: GridContainer = $DebugPanel/MarginContainer/ScrollContainer/DebugContent/PieceScroll/PieceList
@onready var audio_title_label: Label = $DebugPanel/MarginContainer/ScrollContainer/DebugContent/AudioTitle
@onready var audio_volume_label: Label = $DebugPanel/MarginContainer/ScrollContainer/DebugContent/AudioHeader/AudioVolumeLabel
@onready var audio_volume_value_label: Label = $DebugPanel/MarginContainer/ScrollContainer/DebugContent/AudioHeader/AudioVolumeValue
@onready var audio_volume_slider: HSlider = $DebugPanel/MarginContainer/ScrollContainer/DebugContent/AudioVolumeSlider
@onready var audio_mute_checkbox: CheckBox = $DebugPanel/MarginContainer/ScrollContainer/DebugContent/AudioMuteCheckBox
@onready var ui_scale_title_label: Label = $DebugPanel/MarginContainer/ScrollContainer/DebugContent/UiTitle
@onready var ui_scale_label: Label = $DebugPanel/MarginContainer/ScrollContainer/DebugContent/UiScaleHeader/UiScaleLabel
@onready var ui_scale_value_label: Label = $DebugPanel/MarginContainer/ScrollContainer/DebugContent/UiScaleHeader/UiScaleValue
@onready var ui_scale_slider: HSlider = $DebugPanel/MarginContainer/ScrollContainer/DebugContent/UiScaleSlider
@onready var retry_title_label: Label = $DebugPanel/MarginContainer/ScrollContainer/DebugContent/RetryTitle
@onready var retry_label: Label = $DebugPanel/MarginContainer/ScrollContainer/DebugContent/RetryHeader/RetryLabel
@onready var retry_spinbox: SpinBox = $DebugPanel/MarginContainer/ScrollContainer/DebugContent/RetryHeader/RetrySpinBox
@onready var debug_status_label: Label = $DebugPanel/MarginContainer/ScrollContainer/DebugContent/DebugStatusLabel

@onready var debug_select_all_button: Button = $DebugPanel/MarginContainer/ScrollContainer/DebugContent/DebugButtons/DebugSelectAllButton
@onready var debug_apply_button: Button = $DebugPanel/MarginContainer/ScrollContainer/DebugContent/DebugButtons/DebugApplyButton
@onready var game_over_overlay: Control = $GameOverOverlay
@onready var game_over_label: Label = $GameOverOverlay/OverlayCenter/OverlayPanel/MarginContainer/OverlayContent/GameOverTitle
@onready var overlay_panel: PanelContainer = $GameOverOverlay/OverlayCenter/OverlayPanel
@onready var retry_button: Button = $GameOverOverlay/OverlayCenter/OverlayPanel/MarginContainer/OverlayContent/ButtonsContainer/RetryButton
@onready var restore_button: Button = $GameOverOverlay/OverlayCenter/OverlayPanel/MarginContainer/OverlayContent/ButtonsContainer/RestoreButton
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

# 用于保存本回合初始状态的变量
var round_start_board_state: Dictionary = {}
var round_start_pieces: Array[Dictionary] = []
var round_start_score: int = 0
var restore_count: int = 0  # 本回合复原次数
const MAX_RESTORE_COUNT: int = 3  # 每回合最大复原次数
var retry_count: int = 0  # 当前游戏重试次数
var max_retry_count: int = 5  # 一局游戏最大重试次数（每3次复原记为1次重试）


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
	if not restore_button.pressed.is_connected(_on_restore_button_pressed):
		restore_button.pressed.connect(_on_restore_button_pressed)
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
	if not board_width_decrease_button.pressed.is_connected(_on_board_width_decrease_pressed):
		board_width_decrease_button.pressed.connect(_on_board_width_decrease_pressed)
	if not board_width_increase_button.pressed.is_connected(_on_board_width_increase_pressed):
		board_width_increase_button.pressed.connect(_on_board_width_increase_pressed)
	if not board_height_decrease_button.pressed.is_connected(_on_board_height_decrease_pressed):
		board_height_decrease_button.pressed.connect(_on_board_height_decrease_pressed)
	if not board_height_increase_button.pressed.is_connected(_on_board_height_increase_pressed):
		board_height_increase_button.pressed.connect(_on_board_height_increase_pressed)
	if not audio_volume_slider.value_changed.is_connected(_on_audio_volume_changed):
		audio_volume_slider.value_changed.connect(_on_audio_volume_changed)
	if not audio_mute_checkbox.toggled.is_connected(_on_audio_mute_toggled):
		audio_mute_checkbox.toggled.connect(_on_audio_mute_toggled)
	if not retry_spinbox.value_changed.is_connected(_on_retry_spinbox_changed):
		retry_spinbox.value_changed.connect(_on_retry_spinbox_changed)
	if not ui_scale_slider.value_changed.is_connected(_on_ui_scale_slider_changed):
		ui_scale_slider.value_changed.connect(_on_ui_scale_slider_changed)
	debug_panel_open = Engine.is_editor_hint()
	retry_button.text = "\u518d\u6765\u4e00\u6b21"
	retry_spinbox.value = max_retry_count
	_update_restore_button()
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
		score_hint_label.text = "\u9884\u89c8\uff1a\u6d88\u9664\u884c\u548c\u5217"
		return

	if is_game_over:
		score_hint_label.text = "\u6ca1\u6709\u53ef\u7528\u7684\u79fb\u52a8"
		return

	if cleared_units <= 0:
		score_hint_label.text = "\u653e\u7f6e\u65b9\u5757\u4ee5\u586b\u6ee1\u884c\u6216\u5217"
		return

	score_hint_label.text = "+%d \u5206  |  \u6d88\u9664\u4e86 %d \u884c" % [
		gained_score,
		cleared_units
	]


func _fill_all_slots() -> void:
	# 尝试生成一组方块，确保至少有两个能一起被放入棋盘
	var max_attempts := 20
	for attempt in range(max_attempts):
		# 先填充所有方块
		for slot in slots:
			_refill_slot(slot)

		# 检查是否至少有两个方块能一起被放入棋盘
		if _can_place_two_pieces():
			_save_round_state()  # 保存本回合初始状态
			_play_sfx("refill")
			return

	# 如果多次尝试都无法满足条件，至少确保有两个方块可以单独放入
	for slot in slots:
		if not board.can_place_piece_anywhere(slot.get_piece()):
			# 尝试替换为可以放入的方块
			var available_pieces := TetrominoLibraryScript.PIECES.filter(
				func(p): return board.can_place_piece_anywhere(TetrominoLibraryScript._build_piece_dictionary(p))
			)
			if not available_pieces.is_empty():
				slot.set_piece(TetrominoLibraryScript._build_piece_dictionary(available_pieces[randi() % available_pieces.size()]))

	_save_round_state()  # 保存本回合初始状态
	_play_sfx("refill")


# 检查是否至少有两个方块能一起被放入棋盘
func _can_place_two_pieces() -> bool:
	var pieces: Array[Dictionary] = []
	for slot in slots:
		if slot.has_piece():
			pieces.append(slot.get_piece())

	if pieces.size() < 2:
		return false

	# 获取棋盘的空闲位置
	var empty_positions: Array[Vector2i] = []
	for x in range(board.columns):
		for y in range(board.rows):
			if not board.occupied_cells.has(Vector2i(x, y)):
				empty_positions.append(Vector2i(x, y))

	# 尝试所有可能的方块组合
	for i in range(pieces.size()):
		for j in range(i + 1, pieces.size()):
			var piece1 := pieces[i]
			var piece2 := pieces[j]

			# 尝试所有可能的放置位置组合
			for pos1 in empty_positions:
				if board.can_place_piece(piece1, pos1):
					# 模拟放置第一个方块
					var piece1_cells: Array[Vector2i] = piece1.get("cells", [])
					var occupied_copy := board.occupied_cells.duplicate()
					for cell in piece1_cells:
						occupied_copy[pos1 + cell] = true

					# 检查第二个方块是否能放入
					for pos2 in empty_positions:
						if not occupied_copy.has(pos2):
							var can_place := true
							var piece2_cells: Array[Vector2i] = piece2.get("cells", [])
							for cell in piece2_cells:
								if occupied_copy.has(pos2 + cell):
									can_place = false
									break
							if can_place and _is_within_bounds(piece2, pos2):
								return true

	return false


# 检查方块是否在棋盘边界内
func _is_within_bounds(piece: Dictionary, origin: Vector2i) -> bool:
	var piece_size: Vector2i = TetrominoLibraryScript.get_piece_size(piece)
	return origin.x >= 0 and origin.y >= 0 and origin.x + piece_size.x <= board.columns and origin.y + piece_size.y <= board.rows 
 

# 保存本回合初始状态
func _save_round_state() -> void:
	# 保存棋盘状态
	round_start_board_state = board.occupied_cells.duplicate()

	# 保存当前方块
	round_start_pieces.clear()
	for slot in slots:
		if slot.has_piece():
			round_start_pieces.append(slot.get_piece())
		else:
			round_start_pieces.append({})

	# 保存当前分数
	round_start_score = score


# 恢复到本回合初始状态
func _restore_round_state() -> void:
	# 恢复棋盘状态
	board.occupied_cells = round_start_board_state.duplicate()
	board.queue_redraw()

	# 恢复方块
	for i in range(min(slots.size(), round_start_pieces.size())):
		if not round_start_pieces[i].is_empty():
			slots[i].set_piece(round_start_pieces[i])
		else:
			slots[i].clear_piece()

	# 恢复分数
	score = round_start_score
	_update_score_ui(0)

	# 取消游戏结束状态
	_set_game_over(false)


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
		restore_button.scale = Vector2.ONE * 0.96
		game_over_label.text = "\u6e38\u620f\u7ed3\u675f"
		score_hint_label.text = "\u6ca1\u6709\u53ef\u7528\u7684\u79fb\u52a8"
		_play_sfx("game_over")
		_update_restore_button()

		overlay_tween = create_tween().set_parallel(true)
		overlay_tween.tween_property(game_over_overlay, "modulate", Color.WHITE, 0.24).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		overlay_tween.tween_property(overlay_panel, "scale", Vector2.ONE, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		overlay_tween.tween_property(retry_button, "scale", Vector2.ONE, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		overlay_tween.tween_property(restore_button, "scale", Vector2.ONE, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		game_over_overlay.visible = false
		game_over_overlay.modulate = Color.WHITE
		overlay_panel.scale = Vector2.ONE
		retry_button.scale = Vector2.ONE
		restore_button.scale = Vector2.ONE


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
	restore_count = 0  # 重置本回合复原次数
	_update_restore_button()  # 更新复原按钮显示


func _on_retry_button_pressed() -> void:
	_play_sfx("ui")
	_start_new_round()


func _on_restore_button_pressed() -> void:
	if restore_count >= MAX_RESTORE_COUNT:
		return

	_play_sfx("ui")
	_restore_round_state()
	restore_count += 1

	# 每完成3次复原，重试次数加1
	if restore_count >= MAX_RESTORE_COUNT:
		retry_count += 1
		# 检查是否超过最大重试次数
		if retry_count >= max_retry_count:
			# 禁用复原按钮
			restore_button.disabled = true
			restore_button.modulate = Color(0.5, 0.5, 0.5, 1.0)

	# 更新复原按钮的显示
	_update_restore_button()


func _update_restore_button() -> void:
	var remaining = MAX_RESTORE_COUNT - restore_count
	var remaining_retries = max_retry_count - retry_count

	if remaining > 0 and remaining_retries > 0:
		restore_button.text = "复原 (%d/%d)" % [remaining, max_retry_count - retry_count]
		restore_button.disabled = false
		restore_button.modulate = Color.WHITE
	else:
		restore_button.text = "复原 (0/%d)" % (max_retry_count - retry_count)
		restore_button.disabled = true
		restore_button.modulate = Color(0.5, 0.5, 0.5, 1.0)


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

	audio_volume_slider.set_value_no_signal(master_audio_level * 100.0)
	audio_mute_checkbox.set_pressed_no_signal(audio_muted)
	debug_toggle_button.visible = true
	debug_title_label.text = "设置"
	# debug_note_label.text 已移除
	board_width_label.text = "\u5bbd"
	board_height_label.text = "\u9ad8"
	pieces_title_label.text = "\u65b9\u5757\u6c60"
	audio_title_label.text = "\u97f3\u9891"
	audio_volume_label.text = "\u97f3\u91cf"
	audio_mute_checkbox.text = "\u9759\u97f3"
	ui_scale_title_label.text = "\u754c\u9762"
	ui_scale_label.text = "\u754c\u9762\u7f29\u653e"
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
	_layout_scene()
	_layout_scene()


func _on_debug_select_all_pressed() -> void:
	_play_sfx("ui")
	var _selected_count := 0
	var pending_columns := _get_pending_board_columns()
	var pending_rows := _get_pending_board_rows()
	for piece_id in TetrominoLibraryScript.get_piece_ids():
		var piece_card: Variant = debug_piece_cards.get(piece_id)
		if piece_card == null:
			continue
		var fits := TetrominoLibraryScript.can_piece_fit_board(piece_id, pending_columns, pending_rows)
		piece_card.set_selected(fits)
		if fits:
			_selected_count += 1



func _on_debug_apply_pressed() -> void:
	_update_piece_pool_constraints(true)
	var selected_piece_ids := _get_selected_piece_ids_from_pool()

	if selected_piece_ids.is_empty():

		return

	_play_sfx("ui")
	allowed_piece_ids = selected_piece_ids

	_start_new_round()


func _on_piece_catalog_card_pressed(piece_id: String) -> void:
	var piece_card: Variant = debug_piece_cards.get(piece_id)
	if piece_card == null:
		return
	piece_card.set_selected(not piece_card.is_selected())
	_play_sfx("ui")


func _on_debug_board_size_changed(_value: float) -> void:
	_update_piece_pool_constraints(true)


func _on_board_width_decrease_pressed() -> void:
	board_width_spinbox.set_value(maxf(board_width_spinbox.min_value, board_width_spinbox.value - 1))
	_update_piece_pool_constraints(true)


func _on_board_width_increase_pressed() -> void:
	board_width_spinbox.set_value(minf(board_width_spinbox.max_value, board_width_spinbox.value + 1))
	_update_piece_pool_constraints(true)


func _on_board_height_decrease_pressed() -> void:
	board_height_spinbox.set_value(maxf(board_height_spinbox.min_value, board_height_spinbox.value - 1))
	_update_piece_pool_constraints(true)


func _on_board_height_increase_pressed() -> void:
	board_height_spinbox.set_value(minf(board_height_spinbox.max_value, board_height_spinbox.value + 1))
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

	var columns := 4
	var actual_card_width := 0.0
	while true:
		actual_card_width = floorf(
			(available_width - PIECE_POOL_GRID_GAP * float(columns - 1)) / float(columns)
		)
		if columns <= 2 or actual_card_width >= PIECE_POOL_CARD_FIT_MIN_WIDTH:
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
		# 处理移除和回退标签的情况
		pass
	elif removed_count > 0:
		# 处理仅移除的情况
		pass
	elif fallback_piece_label != "":
		# 处理仅回退标签的情况
		pass



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
	if debug_panel.visible:
		call_deferred("_refresh_debug_panel")


func _set_debug_panel_open(value: bool, play_sfx: bool = true) -> void:
	debug_panel_open = value
	_update_debug_toggle_button()
	_apply_debug_panel_visibility()
	if play_sfx:
		_play_sfx("ui")


func _refresh_debug_panel() -> void:
	_layout_scene()
	_update_piece_pool_layout()


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
		debug_status_label.text = "\u754c\u9762\u5df2\u8c03\u6574\u5230 %d%%\uff08\u5f53\u524d\u5c4f\u5e55\u5b89\u5168\u4e0a\u9650\uff09" % int(round(next_scale * 100.0))
	else:
		debug_status_label.text = "\u754c\u9762\u5df2\u8c03\u6574\u5230 %d%%" % int(round(next_scale * 100.0))
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


func _on_retry_spinbox_changed(value: float) -> void:
	max_retry_count = int(value)
	_update_restore_button()
