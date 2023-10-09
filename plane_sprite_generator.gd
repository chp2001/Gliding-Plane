extends Node3D

@export var file_name:= "res://textures/plane sprite sheet.png"
@export var sprite_sheet_columns:= 4
@export var sprite_size:= Vector2(256, 256)


@onready var plane = $Plane

func _ready():
	$Marker3D.hide()
	$WorldEnvironment.environment.background_color.a= 0
	await get_tree().process_frame
	
	var images: Array[Image]
	var resolution: Vector2= get_viewport().get_texture().get_size()
	var screen_center: Vector2= resolution / 2
	
	var step_size:= 30
	
	for deg in range(0, 360, step_size):
		await get_tree().process_frame
		var image: Image= get_viewport().get_texture().get_image()
		image= image.get_region(Rect2i(screen_center - sprite_size / 2, sprite_size))
		images.append(image)
		plane.rotate_z(deg_to_rad(step_size))
	

	var sheet= Image.create(sprite_size.x * sprite_sheet_columns, sprite_size.y * int(images.size() / sprite_sheet_columns), false, Image.FORMAT_RGBA8) 
	
	var src_rect:= Rect2i(Vector2i.ZERO, sprite_size)
	for i in images.size():
		var destination:= Vector2(i % sprite_sheet_columns * sprite_size.x, int(i / sprite_sheet_columns) * sprite_size.y)
		sheet.blit_rect(images[i], src_rect, destination)
		

	sheet.save_png(file_name)

	get_tree().quit()
