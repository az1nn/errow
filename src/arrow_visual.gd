class_name ArrowVisual
extends Control

const DIRECTIONS := {
	"U": Vector2(0.0, -1.0),
	"R": Vector2(1.0, 0.0),
	"D": Vector2(0.0, 1.0),
	"L": Vector2(-1.0, 0.0),
}

var _direction_code := "U"
var arrow_color := Color("#111820")


func configure(direction_code: String) -> void:
	_direction_code = direction_code if DIRECTIONS.has(direction_code) else "U"
	queue_redraw()


func get_direction() -> String:
	return _direction_code


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return

	var direction: Vector2 = DIRECTIONS[_direction_code]
	var perpendicular := Vector2(-direction.y, direction.x)
	var extent := minf(size.x, size.y)
	var center := size * 0.5

	var tail := center - direction * extent * 0.25
	var head_base := center + direction * extent * 0.08
	var tip := center + direction * extent * 0.32
	var shaft_half_width := extent * 0.055
	var head_half_width := extent * 0.19

	var points := PackedVector2Array([
		tail + perpendicular * shaft_half_width,
		head_base + perpendicular * shaft_half_width,
		head_base + perpendicular * head_half_width,
		tip,
		head_base - perpendicular * head_half_width,
		head_base - perpendicular * shaft_half_width,
		tail - perpendicular * shaft_half_width,
	])

	draw_colored_polygon(points, arrow_color)
