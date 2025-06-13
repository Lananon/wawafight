extends Node2D

@onready var sprite = get_parent().get_node("Sprite2D")

var current_animation: String = "idle"
var current_frame: int

@onready var current_step = get_node("idle/1")
@onready var previous_step = get_node("idle/1")

func animate():
	

	
	for child in get_node(str(current_animation)).get_children():
		if child.frame == current_frame:
			sprite.frame = child.animation_frame
			current_step = child
			if child.name == "LOOP":
				current_frame = 0
			if previous_step != current_step:
				if current_step.is_new_attack:
					get_parent().is_hitbox_active = true
			
			
			previous_step = current_step
	current_frame += 1
	

func play(animation: String):
	if animation != current_animation:
		current_animation = animation
		current_frame = 0
