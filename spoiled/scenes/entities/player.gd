extends CharacterBody2D

@export var speed: float = 300.0
@export var jump_force: float = -250.0
@export var jump_time: float = 0.25
@export var coyote_time: float = 0.075
@export var gravity_multiplier: float = 3.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_jumping: bool = false
var jump_timer: float = 0
var coyote_timer: float = 0
var has_key: bool = false

var max_jumps := 2
var jumps_left := 2

var on_ladder: bool = false
var climb_speed: float = 200.0

var footstep_timer := 0.0
var footstep_interval := 0.08

var is_in_water := false

var start_time := 0.0
var elapsed_time := 0.0
var death_count := 0

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var footstep_player: AudioStreamPlayer2D = $FootstepPlayer
@onready var jump_player: AudioStreamPlayer2D = $JumpPlayer
@onready var water_player: AudioStreamPlayer2D = $WaterPlayer

func _ready():
	start_time = Time.get_ticks_msec() / 1000.0

func _physics_process(delta):
	var direction = Input.get_axis("move_left", "move_right")
	var vertical = Input.get_axis("jump", "fall")

	# Ladder and gravity
	if on_ladder:
		velocity.y = vertical * climb_speed
	else:
		if is_on_floor():
			jumps_left = max_jumps
			coyote_timer = 0
		else:
			velocity.y += gravity * delta
			coyote_timer += delta

	# Respawn key
	if Input.is_action_just_pressed("respawn"):
		var respawn_pos = global_position + Vector2(0, -30)
		die(respawn_pos)

	# Jumping
	if Input.is_action_just_pressed("jump") and (is_on_floor() or coyote_timer < coyote_time or jumps_left > 0):
		if not is_on_floor() and coyote_timer >= coyote_time:
			jumps_left -= 1
		velocity.y = jump_force
		is_jumping = true
		if jump_player:
			jump_player.play()

	if is_jumping and Input.is_action_pressed("jump") and jump_timer < jump_time:
		jump_timer += delta
	else:
		is_jumping = false
		jump_timer = 0

	# Horizontal movement
	if direction != 0:
		velocity.x = direction * speed
		sprite_2d.flip_h = direction > 0
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	# Footstep sound
	if abs(direction) > 0.1 and is_on_floor():
		footstep_timer -= delta
		if footstep_timer <= 0.0:
			if footstep_player and not footstep_player.playing:
				footstep_player.play()
			footstep_timer = footstep_interval
	else:
		if footstep_player:
			footstep_player.stop()
			footstep_timer = 0.0

	handle_animations(direction)
	move_and_slide()

func handle_animations(direction: float) -> void:
	if abs(direction) > 0.1 and is_on_floor():
		animation_player.play("running")
	elif not is_on_floor():
		animation_player.play("jumping")
	else:
		animation_player.play("Idle")

func die(respawn_position: Vector2) -> void:
	print("Player died")
	death_count += 1
	global_position = respawn_position
	velocity = Vector2.ZERO
	is_jumping = false
	jump_timer = 0
	coyote_timer = 0

# Ladder logic
func _on_ladder_1_body_entered(body: Node2D) -> void:
	if body == self:
		on_ladder = true
		velocity = Vector2.ZERO

func _on_ladder_1_body_exited(body: Node2D) -> void:
	if body == self:
		on_ladder = false

func _on_ladder_2_body_entered(body: Node2D) -> void:
	if body == self:
		on_ladder = true
		velocity = Vector2.ZERO

func _on_ladder_2_body_exited(body: Node2D) -> void:
	if body == self:
		on_ladder = false

# Water logic
func _on_Water_body_entered(body: Node2D) -> void:
	if body == self and not is_in_water:
		is_in_water = true
		if water_player:
			print("playing water sound")
			water_player.play()
		await get_tree().create_timer(0.4).timeout
		die(global_position + Vector2(0, -30))

func _on_Water_body_exited(body: Node2D) -> void:
	if body == self:
		is_in_water = false

# Win condition
func _on_EndZone_body_entered(body: Node2D) -> void:
	if body == self:
		elapsed_time = Time.get_ticks_msec() / 1000.0 - start_time
		show_win_screen()

func show_win_screen():
	get_tree().paused = true
	var win_scene = preload("res://scenes/ui/winscreen.tscn").instantiate()
	win_scene.time_taken = elapsed_time
	win_scene.death_count = death_count

	var ui_layer = get_tree().current_scene.get_node("UI")
	ui_layer.add_child(win_scene)


func _on_end_zone_body_entered(body: Node2D) -> void:
	if body == self:
		elapsed_time = Time.get_ticks_msec() / 1000.0 - start_time
		show_win_screen()
