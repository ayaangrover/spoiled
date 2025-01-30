extends CharacterBody2D


@export var speed : float = 300.0
@export var jump_force : float = -250.0
@export var jump_time : float = 0.25
@export var coyote_time : float = 0.075
@export var gravity_multiplier : float = 3.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_jumping : bool = false
var jump_timer : float = 0
var coyote_timer : float = 0

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _physics_process(delta):
	if not is_on_floor() and not is_jumping:
		velocity.y += gravity * delta
		coyote_timer += delta
	else:
		coyote_timer = 0
	
	if Input.is_action_just_pressed("jump") and (is_on_floor() or coyote_timer < coyote_time):
		velocity.y = jump_force
		is_jumping = true
	elif Input.is_action_just_pressed("jump") and is_jumping:
		velocity.y = jump_force
	
	if is_jumping and Input.is_action_pressed("jump") and jump_timer < jump_time:
		jump_timer += delta
	else:
		is_jumping = false
		jump_timer = 0
	
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		
	if direction != 0:
		sprite_2d.flip_h = direction > 0
	
	handle_animations(direction)
	
	move_and_slide()
	
func handle_animations(direction : float) -> void:
	if abs(direction) > 0.1 and is_on_floor():
		animation_player.play("running")
	elif not is_on_floor():
		animation_player.play("jumping")
	else:
		animation_player.play("Idle")
