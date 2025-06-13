extends Node

@onready var player1 = get_node("player1")
@onready var player2 = get_node("player2")

@onready var player1_character = get_node("player1").get_child(0)
@onready var player2_character = get_node("player2").get_child(0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player1_character.upscaled_position = player1_character.global_position * player1_character.upscaling_factor
	player2_character.upscaled_position = player2_character.global_position * player2_character.upscaling_factor


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	frame_tick()

func frame_tick() -> void:
	player1_character.process_inputs()
	player2_character.process_inputs()
	player1_character.execute_inputs()
	player2_character.execute_inputs()
	player1_character.check_for_hit()
	player2_character.check_for_hit()
	player1_character.movement()
	player2_character.movement()
	player1_character.calculate_physics()
	player2_character.calculate_physics()
	player1_character.end_of_frame()
	player2_character.end_of_frame()
	player1_character.animation_player.animate()
	player2_character.animation_player.animate()
