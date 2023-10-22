extends Sprite2D

# acceleration when SPACE is pressed
@export var acceleration: float= 100
# how fast the plane rotates
@export var pitch_factor: float= 1.0

@export var gravity: float= 10

# like drag, slows the plane down eventually when not accelerating
@export var horizontal_drag: float= 0.2
@export var wing_drag: float= 1

# the lower the more velocity is needed to keep the plane from falling
@export var uplift_factor: float= 0.001

# thruster sprite
@onready var thruster = $Thruster
@onready var startScale = thruster.scale
# planes velocity
var velocity: Vector2
var accelerationVec: Vector2
var gravityVec: Vector2
var dragVec: Vector2
var upliftVec: Vector2
# Label
@onready var label = $Label

func _draw():
	var center = Vector2(0,0)
	var velocityPos = center + velocity
	var accelerationPos = center + accelerationVec
	var gravityPos = center + gravityVec
	var dragPos = center + dragVec
	
	draw_set_transform(center, -rotation)
	draw_line(center,velocityPos,Color.RED)
	draw_line(center,accelerationPos,Color.PURPLE)
	draw_line(center,gravityPos,Color.ORANGE)
	draw_line(center,dragPos,Color.GRAY)
	draw_line(center,upliftVec,Color.AQUA)
	
	pass

func _physics_process(delta):
	
	# the direction the plane is pointing
	var forward: Vector2= global_transform.x
	
	# SPACE to accelerate
	if Input.is_action_pressed("ui_select"):
		# add acceleration in forward direction 
		accelerationVec = forward * acceleration
		velocity+= forward * acceleration * delta
		thruster.show()
	else:
		accelerationVec *= 0
		thruster.hide()

	var spinPower = 3 * clamp(forward.dot(velocity) * 0.01 * uplift_factor, 0, 1) + 1

	# LEFT to pitch up
	if Input.is_action_pressed("ui_left"):
		rotation-= pitch_factor * delta * spinPower
	# RIGHT to pitch down
	if Input.is_action_pressed("ui_right"):
		rotation+= pitch_factor * delta * spinPower
	label.rotation = -rotation
	label.text = str(velocity.length()) + "\n" + str(startScale)

	# horizontal counterforce against flying direction
	# to slow the plane down horizontally
	# vertically gravity will do that
	# CHP: Don't like the way this was done. Going to try to do it via cross product
	var upwards_dir = global_transform.y
	var time_to_stop = 5
	var wingdrag = upwards_dir * upwards_dir.dot(velocity) * wing_drag / time_to_stop
	var horiz_drag = forward * forward.dot(velocity) * horizontal_drag / time_to_stop
	dragVec = -wingdrag - horiz_drag
	velocity -= delta * (wingdrag + horiz_drag)
	

	
	# how much of the velocity is going in the forward 
	# direction 
	# flying in the same direction we are 
	# looking in means all velocity is forward velocity
	# so forward_velocity= velocity.length()
	#
	# falling straight down while looking to the right
	# means none of the velocity is forward velocity
	# so forward_velocity= 0
	#
	# this will help to determine the impact our wings
	# will have. If there isnt any forward velocity there
	# will be no effect from the wings and the plane
	# should handle like a rocket
	# But with a high forward velocity our wings will
	# have a huge impact and the plane will handle more
	# arcade-like
	var forward_velocity: float= forward.dot(velocity)

	# this is the velocity we would use if our plane
	# should handle like rocket, basically just like
	# a default physics object
	var rocket_velocity: Vector2= velocity

	# i call this arcade velocity because its unrealistic
	# it means all the velocity is going in direction of our
	# plane. So if you turn it, it will go instantly in that
	# direction 
	var arcade_velocity: Vector2= velocity.length() * forward
	
	# use the forward_velocity and the uplift factor to determine
	# the interpolation between rocket physics and arcade physics
	# for low speeds (and/or low uplift) we want the plane to handle
	# more like a rocket
	# for higher speeds (and/or high uplift) we want the plane to
	# handle arcade like and fly exactly in the direction we are
	# pointing
	var oldvelocity = Vector2(velocity.x,velocity.y)
	velocity= lerp(rocket_velocity, arcade_velocity, clamp(forward_velocity * 0.01 * uplift_factor, 0, 1))
	upliftVec = velocity - oldvelocity
	
	# add gravity
	velocity+= Vector2.DOWN * gravity * delta
	gravityVec = Vector2.DOWN * gravity
	
	# move the plane
	position+= velocity * delta
	
func _process(delta):
	queue_redraw()
