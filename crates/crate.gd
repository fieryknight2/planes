extends Area2D

@export var m_type : String

@export var health_tex : Texture2D
@export var multishot : Texture2D
@export var powershot : Texture2D

func _ready():
	if m_type == "health":
		$Crate/Crate/Symbol.texture = health_tex
	elif m_type == "multishot":
		$Crate/Crate/Symbol.texture = multishot
	elif m_type == "powershot":
		$Crate/Crate/Symbol.texture = powershot

func _process(delta):
	position.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta
	
	if position.y > 1300 and is_multiplayer_authority():
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Players"):
		area.pick_up_crate(m_type)
		if is_multiplayer_authority():
			queue_free()
