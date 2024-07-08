extends Node


var time:float =0.0

@export_category("Time Spawner")
@export var initial_spawn_rate:float = 60.0
@export var mob_spawner:MobSpawner
@export var spawn_rate_per_minute:float = 30.0
@export var wave_duration:float = 20.0
@export var break_intensity: float = 0.5

func _process(delta: float) -> void:
	# Verificar Game Over
	if not GameManager.ic_start_game:return
	if GameManager.is_game_over:return
	
	time+=delta
	#Dificuldade lienar
	var spawn_rate = initial_spawn_rate + spawn_rate_per_minute * (time/60.0)
	
	#Sistema de ondas
	var sin_wave = sin((time * TAU / wave_duration)) # 0 ~ 2PI ou TAU
	var wave_factor = remap(sin_wave,-1.0,1.0,break_intensity,1)	
	spawn_rate*=wave_factor	
	#print("time: %.2f, Wave: %.2f" %[time,sin_wave])
	#Aplicar dificuldade
	mob_spawner.mobs_per_minute =  spawn_rate
