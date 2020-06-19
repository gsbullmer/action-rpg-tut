extends KinematicBody2D


export var ACCELERATION = 300
export var MAX_SPEED = 50
export var WANDER_SPEED = 25
export var FRICTION = 200
export var PUSH_VALUE = 100

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

enum {
	IDLE,
	WANDER,
	CHASE
}

var knockback = Vector2.ZERO
var state = IDLE
var velocity = Vector2.ZERO

onready var stats = $Stats
onready var player_detection_zone = $PlayerDetectionZone
onready var sprite = $AnimatedSprite
onready var hurtbox = $Hurtbox
onready var soft_collision = $SoftCollision
onready var wander_controller = $WanderController


func _ready():
	set_wander()


func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			
		WANDER:
			seek_player()
			accelerate_toward_point(wander_controller.target_position, delta)
			if global_position.distance_to(wander_controller.target_position) <= 1:
				set_wander()
			
		CHASE:
			var player = player_detection_zone.player
			if player != null:
				accelerate_toward_point(player.global_position, delta)
			else:
				state = IDLE
	
	sprite.flip_h = velocity.x < 0
	
	if soft_collision.is_colliding():
		velocity += soft_collision.get_push_vector() * delta * PUSH_VALUE
	
	velocity = move_and_slide(velocity)


func accelerate_toward_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * WANDER_SPEED, ACCELERATION * delta)


func seek_player():
	if wander_controller.get_time_left() == 0:
		set_wander()
	
	if player_detection_zone.can_see_player():
		state = CHASE


func set_wander():
	state = pick_random_state([IDLE, WANDER])
	wander_controller.start_wander_timer(rand_range(1, 3))


func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()


func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 125
	hurtbox.create_hit_effect()


func _on_Stats_no_health():
	queue_free()
	var enemy_death_effect = EnemyDeathEffect.instance()
	get_parent().add_child(enemy_death_effect)
	enemy_death_effect.position = position
