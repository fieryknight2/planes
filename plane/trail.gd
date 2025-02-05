extends Line2D

@export var max_points: int = 2000
@export var point: Node2D
@onready var curve := Curve2D.new()


func _process(_delta: float) -> void:
	global_position = Vector2(0, 0)
	curve.add_point(point.global_position)
	if curve.get_baked_points().size() > max_points:
		curve.remove_point(0)
	points = curve.get_baked_points()
