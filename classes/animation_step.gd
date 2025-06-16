extends Node2D

class_name animation_step

#add an animation_step called LOOP at the end of your animation if you want it to loop

@export var frame: int = 1
@export var animation_frame: int

@export var is_new_attack: bool

@export var hitstun: int
@export var blockstun: int
@export var block_type: Array = ["HIGH", "LOW", "AIR"]
@export var knockback: Vector2i
@export var pushback: int
@export var hitstop: int
@export var self_hitstop: int
@export var cancel_options: Array = ["5A"]
