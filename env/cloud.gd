extends Sprite2D

@export var speed : float = 5
@export var cloud : int

@export var clouds : Array[Texture2D]

func _ready():
	texture = clouds[cloud]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	texture = clouds[cloud]
	position.x -= speed * delta
	
	if position.x < -4500 and is_multiplayer_authority():
		queue_free()
