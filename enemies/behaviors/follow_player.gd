extends Node

@export var speed:float = 1.0

var enemy:Enemy
var sprite:AnimatedSprite2D
var input_vector

func _ready() -> void:
	enemy = get_parent()
	sprite = enemy.get_node("AnimatedSprite2D")
	
func _physics_process(delta: float) -> void:
	if not GameManager.ic_start_game:return
	# Verificar Game Over
	if GameManager.is_game_over:return
	
	var player_position = GameManager.player_position
	var difference = player_position - enemy.position
	input_vector = difference.normalized()	
	enemy.velocity = input_vector * speed * 100.0
	enemy.move_and_slide()
	rotate_sprite()

func rotate_sprite()-> void:
	#Girar Sprite
	if input_vector.x > 0:
		#desmarcar Flip_H
		sprite.flip_h = false
	elif input_vector.x < 0:
		#marcar Flip_H
		sprite.flip_h =true
