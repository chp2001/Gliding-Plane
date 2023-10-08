extends Node2D

@onready var camera_2d = $Camera2D
@onready var plane = $Plane

func _process(delta):
	camera_2d.global_position= plane.global_position
