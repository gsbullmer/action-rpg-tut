extends KinematicBody2D


const ACCELERATION = 500
const FRICTION = 500
const MAX_SPEED = 80
const ROLL_SPEED = 120

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
var stats = PlayerStats

onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")
onready var sword_hitbox = $HitboxPivot/SwordHitbox
onready var hurtbox = $Hurtbox


func _ready():
	randomize()
	stats.connect("no_health", self, "queue_free")
	animation_tree.active = true
	sword_hitbox.knockback_vector = roll_vector


func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
			
		ROLL:
			roll_state()
			
		ATTACK:
			attack_state(delta)


func move_state(delta):
	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		animation_tree.set("parameters/Idle/blend_position", input_vector)
		animation_tree.set("parameters/Run/blend_position", input_vector)
		animation_tree.set("parameters/Attack/blend_position", input_vector)
		animation_tree.set("parameters/Roll/blend_position", input_vector)
		
		animation_state.travel("Run")
		
		roll_vector = input_vector
		sword_hitbox.knockback_vector = input_vector
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animation_state.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
		
	if Input.is_action_just_pressed("roll"):
		state = ROLL
	
	move()


func move():
	velocity = move_and_slide(velocity)


func attack_state(delta):
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	animation_state.travel("Attack")
	move()


func attack_animation_finished():
	state = MOVE


func roll_state():
	velocity = roll_vector * ROLL_SPEED
	animation_state.travel("Roll")
	move()


func roll_animation_finished():
	velocity *= 0.8
	state = MOVE


func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	hurtbox.start_invincibilty(0.5)
	hurtbox.create_hit_effect()
