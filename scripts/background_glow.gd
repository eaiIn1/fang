@tool
extends Control
class_name BackgroundGlow

@export var base_glow_color: Color = Color(0.067, 0.816, 0.965, 0.12)
@export var warm_glow_color: Color = Color(1.0, 0.439, 0.388, 0.1)
@export var accent_glow_color: Color = Color(1.0, 0.847, 0.298, 0.09)
@export var stripe_color: Color = Color(0.459, 0.337, 1.0, 0.08)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	var viewport_rect := Rect2(Vector2.ZERO, size)
	var left_glow_center := Vector2(size.x * 0.2, size.y * 0.28)
	var right_glow_center := Vector2(size.x * 0.84, size.y * 0.72)
	var top_glow_center := Vector2(size.x * 0.7, size.y * 0.16)

	draw_circle(left_glow_center, minf(size.x, size.y) * 0.28, base_glow_color)
	draw_circle(right_glow_center, minf(size.x, size.y) * 0.24, warm_glow_color)
	draw_circle(top_glow_center, minf(size.x, size.y) * 0.16, accent_glow_color)

	var stripe_rect := Rect2(
		Vector2(size.x * 0.08, size.y * 0.1),
		Vector2(size.x * 0.72, size.y * 0.08)
	)
	draw_rect(stripe_rect, stripe_color, true)

	var lower_band := Rect2(
		Vector2(size.x * 0.34, size.y * 0.82),
		Vector2(size.x * 0.42, size.y * 0.06)
	)
	draw_rect(lower_band, base_glow_color.darkened(0.2), true)
	draw_rect(viewport_rect, Color(1.0, 1.0, 1.0, 0.015), false, 2.0)
