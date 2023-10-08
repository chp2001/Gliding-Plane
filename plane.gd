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
	# to slow the plane down
	velocity.x*= (1 - horizontal_drag * delta)

	
	# how much of the velocity is in forward direction
	# flying in the same direction we are looking means all
	# forward_velocity= velocity.length()
	# falling straight down while looking to the right
	# means forward_velocity= 0
	var forward_velocity: float= forward.dot(velocity)

	# lerp between current velocity and "full-velocity-forward" vectors
	# ("full-velocity-forward" means all the velocity follows the planes
	# pitch as if there was no gravity and no "sliding")
	#
	# use the forward_velocity and the upliftfactor to determine
	# how much the plane follows the previous velocity vs how much
	# it translates the velocity in the current direction
	velocity= lerp(velocity, velocity.length() * forward, clamp(forward_velocity * 0.01 * uplift_factor, 0, 1))
	
	# add gravity
	velocity+= Vector2.DOWN * gravity * delta
	
	# move the plane
	position+= velocity * delta
