extends Node2D

@export var size := 512
@export var color := Color(0.948, 0.948, 0.648)


func _draw():
	for i in range(10):
		var c = color
		c.a = 0.2 + (i * 0.05)
		draw_circle(position, size * (1.0 - (i * 0.05)), c)
	draw_circle(position, size * 0.5, color)
