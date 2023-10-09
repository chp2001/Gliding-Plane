extends Node3D

@onready var plane = $Plane

func _ready():
	$Marker3D.hide()
	await get_tree().process_frame
	
	var resolution: Vector2= get_viewport().get_texture().get_size()
	var screen_center: Vector2= resolution / 2
	var sprite_size:= Vector2(256, 256)
	
	var step_size:= 30
	for deg in range(0, 360, step_size):
		await get_tree().process_frame
		var file_name:= str("res://plane sprite screenshots/plane_", deg, ".png")
		var image: Image= get_viewport().get_texture().get_image()
		image= image.get_region(Rect2i(screen_center - sprite_size / 2, sprite_size))
		image.save_png(file_name)
		plane.rotate_z(deg_to_rad(step_size))
	
