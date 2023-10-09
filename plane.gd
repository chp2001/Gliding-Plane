extends Sprite2D


@export var god_mode:= true

# acceleration when SPACE is pressed
@export var acceleration: float= 100

@export var boost_factor: float= 3.0
@export var boost_duration: float= 4.0
@export var boost_cooldown_duration: float= 10.0

# how fast the plane rotates
@export var pitch_factor: float= 1.0
@export var hard_pitch_factor: float= 2.0
@export var hard_pitch_min_velocity: float= 150
@export var hard_pitch_damage_per_second: float= 30

# how long it takes to do a full roll
@export var roll_duration: float= 1.5
# number of sprite sheet frames for the roll
@export var min_roll_velocity: float= 100
@export var num_roll_frames:= 12

@export var gravity: float= 10

# like drag, slows the plane down eventually when not accelerating
@export var horizontal_drag: float= 1

# the lower the more velocity is needed to keep the plane from falling
@export var uplift_factor: float= 0.001

# thruster sprite
@onready var thruster = $Thruster
@onready var boost_timer = $"Boost Timer"
@onready var boost_cooldown = $"Boost Cooldown"

# planes velocity
var velocity: Vector2

# is the plane currently rolling
var is_rolling:= false
var roll_time: float

var health: float= 100: set= set_health

func _ready():
	boost_timer.wait_time= boost_duration
	boost_cooldown.wait_time= boost_cooldown_duration


func _physics_process(delta):
	
	# the direction the plane is pointing
	var forward: Vector2= global_transform.x
	
	# SPACE to accelerate
	if Input.is_action_pressed("ui_select"):
		var total_acceleration: float= acceleration
		if is_boosting():
			total_acceleration*= boost_factor

		# add acceleration in forward direction 
		velocity+= forward * total_acceleration * delta
		thruster.show()
	else:
		thruster.hide()

	if not is_rolling:
		# LEFT to pitch up
		if Input.is_action_pressed("ui_left"):
			var total_pitch_factor: float= pitch_factor
			if Input.is_key_pressed(KEY_SHIFT) and get_forward_velocity() > hard_pitch_min_velocity:
				total_pitch_factor*= hard_pitch_factor
				take_damage(hard_pitch_damage_per_second * delta)
				
			rotation-= total_pitch_factor * delta
		# RIGHT to pitch down
		if Input.is_action_pressed("ui_right"):
			rotation+= pitch_factor * delta
		
		if Input.is_action_pressed("ui_up") and get_forward_velocity() > min_roll_velocity:
			is_rolling= true
		
	if Input.is_key_pressed(KEY_CTRL) and not is_boosting() and can_boost():
		thruster.modulate= Color.AQUA
		boost_timer.start()
	
	
	if is_rolling:
		roll_time+= delta
		if roll_time > roll_duration:
			is_rolling= false
			roll_time= 0.0
			frame= 0
		else:
			frame= int(roll_time / roll_duration * num_roll_frames)
		

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
	var forward_velocity: float= get_forward_velocity()

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


func _on_boost_timer_timeout():
	thruster.modulate= Color.WHITE

func is_boosting()-> bool:
	return not boost_timer.is_stopped()

func can_boost()-> bool:
	return boost_cooldown.is_stopped()

func get_forward_velocity()-> float:
	return global_transform.x.dot(velocity)

func take_damage(dmg: float):
	health-= dmg

func set_health(h: float):
	
	if h <= 0:
		if god_mode:
			return
		get_parent().game_over()
		return
		
	health= h
	%"Health Bar".value= health
