extends Node2D

@onready var sprite = get_parent().get_node("Sprite2D")

var current_animation: String = "idle"
var current_step: int
var current_frame: int

var current_step_node

func animate():
	
	
	for child in get_node(str(current_animation)).get_children():
		if child.frame == current_frame:
			sprite.frame = child.animation_frame
			current_step_node = child
			if child.name == "LOOP":
				current_frame = 0
	
	current_frame += 1
	
