class_name MobSpawner
extends Node2D

@onready var path_follow_2d:PathFollow2D = %PathFollow2D
@export var creatures:Array[PackedScene]
var mobs_per_minute:float = 60.0

var cooldown:float = 0.0

func _process(delta: float) -> void:
	if not GameManager.ic_start_game:return
		# Verificar Game Over
	if GameManager.is_game_over:return
	#Temporizador
	cooldown -=delta
	if cooldown > 0:return
	
	#Frequencia
	var interval = 60.0 / mobs_per_minute
	cooldown = interval
	
	# checar se o ponto é valido
	var point = get_point()
	# perguntar pro jogo se esse ponto tem colisão
	var world_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = point
	parameters.collision_mask = 0b1 #collision layer 1, 0b1101 collision layer 1 ,3 e 4  Mask 1, 3 e 4
	var result:Array = world_state.intersect_point(parameters,1)
	if not result.is_empty(): 
		#result.all(queue_free)
		return
	
	#instanciar
	var index = randi_range(0,creatures.size()-1)
	var creature_scene = creatures[index]
	var creature = creature_scene.instantiate()
	
	creature.global_position = get_point()
	get_parent().add_child(creature)
	
	
	
	
func get_point()->Vector2:
	path_follow_2d.progress_ratio = randf()
	return path_follow_2d.global_position
