extends Sprite2D

# acceleration when SPACE is pressed
@export var acceleration: float= 100
# how fast the plane rotates
@export var pitch_factor: float= 1.0

@export var gravity: float= 10

# like drag, slows the plane down eventually when not accelerating
@export var horizontal_drag: float= 1

# the lower the more velocity is needed to keep the plane from falling
@export var uplift_factor: float= 0.001

# thruster sprite
@onready var thruster = $Thruster

# planes velocity
var velocity: Vector2


func _physics_process(delta):
	
	# the direction the plane is pointing
	var forward: Vector2= global_transform.x
	
	# SPACE to accelerate
	if Input.is_action_pressed("ui_select"):
		# add acceleration in forward direction 
		velocity+= forward * acceleration * delta
		thruster.show()
	else:
		thruster.hide()

	# LEFT to pitch up
	if Input.is_action_pressed("ui_left"):
		rotation-= pitch_factor * delta
	# RIGHT to pitch down
	if Input.is_action_pressed("ui_right"):
		rotation+= pitch_factor * delta
	

	# horizontal counterforce against flying direction
	# to slow the plane down horizontally
	# vertically gravity will do that
	velocity.x*= (1 - horizontal_drag * delta)

	
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
	velocity= lerp(rocket_velocity, arcade_velocity, clamp(forward_velocity * 0.01 * uplift_factor, 0, 1))
	
	# add gravity
	velocity+= Vector2.DOWN * gravity * delta
	
	# move the plane
	position+= velocity * delta
