extends Node2D


onready var animatedSprite = $AnimatedSpirte

func _ready():
	animatedSprite.frame = 0
	animatedSprite.play("Animate")


func _on_AnimatedSpirte_animation_finished():
	queue_free()
