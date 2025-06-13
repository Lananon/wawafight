extends character_root


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	move_dictionary = {
		[Vector2i(0, 0), "A"]: "5A",
		[Vector2i(0, 1), "A"]: "5A"
	}
	
	duration_dictionary = {
		"5A": 16
	}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_anims():
	if state == "neutral":
		if get_input_vector().y == 1:
			animation_player.play("crouch")
		else:
			animation_player.play("idle")
	if state == "attack":
		animation_player.play(current_move)
