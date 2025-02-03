extends MultiplayerSynchronizer

@export var rotation_dir : int = 0

@rpc("call_local")
func rotating(direction):
	rotation_dir = direction

func _ready():
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var input_dir = Input.get_axis("ui_left", "ui_right")
	rotating(input_dir)
