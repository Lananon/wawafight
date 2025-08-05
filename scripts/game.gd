extends Node

@onready var player1 = get_node("player1")
@onready var player2 = get_node("player2")
@onready var camera = get_node("Camera2D")

@onready var player1_character = get_node("player1").get_child(0)
@onready var player2_character = get_node("player2").get_child(0)

@export var stage_size = Vector2i(640, 180)

@onready var screen_size = get_viewport().size.x

var fbf_mode = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player1_character.upscaled_position = player1_character.global_position * player1_character.upscaling_factor
	player2_character.upscaled_position = player2_character.global_position * player2_character.upscaling_factor


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not fbf_mode:
		frame_tick()
	
	player1_character.process_inputs()
	player2_character.process_inputs()
	
	if Input.is_action_just_pressed("toggle_fbf"):
		if fbf_mode:
			fbf_mode = false
		if fbf_mode == false:
			fbf_mode = true
	
	if Input.is_action_just_pressed("frame_step"):
		frame_tick()

func frame_tick() -> void:
	camera.global_position.x = clamp((player1_character.global_position.x + player2_character.global_position.x) / 2, screen_size / 2, stage_size.x - screen_size / 2)
	
	
	player1_character.movement()
	player2_character.movement()
	if player1_character.freeze_timer <= 0:
		player1_character.calculate_physics()
	if player2_character.freeze_timer <= 0:
		player2_character.calculate_physics()
	if player1_character.freeze_timer <= 0:
		player1_character.end_of_frame()
	if player2_character.freeze_timer <= 0:
		player2_character.end_of_frame()
	if player2_character.freeze_timer <= 0:
		player1_character.execute_inputs()
	if player2_character.freeze_timer <= 0:
		player2_character.execute_inputs()
	if player1_character.freeze_timer <= 0:
		player1_character.anim_update()
	if player2_character.freeze_timer <= 0:
		player2_character.anim_update()
	player1_character.check_for_hit()
	player2_character.check_for_hit()
	if player1_character.freeze_timer <= 0:
		player1_character.anim_update()
	if player2_character.freeze_timer <= 0:
		player2_character.anim_update()
	if player1_character.freeze_timer <= 0:
		player1_character.animation_player.current_frame += 1
	if player2_character.freeze_timer <= 0:
		player2_character.animation_player.current_frame += 1
	player1_character.freeze_update()
	player2_character.freeze_update()
