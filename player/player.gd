class_name Player
extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer =$AnimationPlayer
@onready var sword_area:Area2D = $SwordArea
@onready var hitbox_area:Area2D = $HitboxArea
@onready var health_progress_bar: ProgressBar = $HealthProgressBar

@export_category("HP")
@export var max_health:int = 100
@export var health:int = 100
@export var death_prefab: PackedScene
@export_category("Movement")
@export var speed:float = 3.0
@export_category("Sword")
@export var sword_damage:int = 2
@export_category("Ritual")
@export var ritual_damage:int = 1
@export var ritual_interval:float = 30.0
@export var ritual_scene: PackedScene


var input_vector:Vector2 = Vector2(0,0)
var is_running:bool = false
var was_running:bool = false
var is_attacking:bool = false
var attack_cooldown:float = 0.0
var hitbox_cooldown:float = 0.0
var ritual_cooldown:float = 0.0

signal meat_collected(value:int)

func _ready() -> void:
	GameManager.player = self
	meat_collected.connect(func(value:int): 
		GameManager.meat_counter+=1
		)# função anonima

func _process(delta: float) -> void:
	if not GameManager.ic_start_game: return
	GameManager.player_position = position
	#Ler Input
	read_input()
	# Processar Attack
	update_attack_cooldown(delta)
	if Input.is_action_just_pressed("attack"):
		attack()
	# Processar animação e rotação de sprite
	play_run_idle_animation()
	if not is_attacking:
		rotate_sprite()
	
#processar dando
	update_hitbox_detection(delta)
	
	update_ritual(delta)
	
	health_progress_bar.max_value = max_health
	health_progress_bar.value=health

func update_attack_cooldown(delta: float)-> void:
	if is_attacking:
		attack_cooldown -= delta
		if attack_cooldown <= 0.0:
			is_attacking=false
			is_running = false
			animation_player.play("idle")

func update_ritual(delta:float)->void:
	ritual_cooldown -=delta
	if ritual_cooldown > 0: return
	ritual_cooldown = ritual_interval
	var ritual = ritual_scene.instantiate()
	ritual.damage_amount = ritual_damage
	add_child(ritual)
	
func play_run_idle_animation()-> void:
	#Tocar animação
	#Atualizar o is_running
	if not is_attacking:
		if was_running != is_running:
			if is_running:
				animation_player.play("run")
			else:
				animation_player.play("idle")
				
func rotate_sprite()-> void:
	#Girar Sprite
	if input_vector.x > 0:
		#desmarcar Flip_H
		sprite.flip_h = false
	elif input_vector.x < 0:
		#marcar Flip_H
		sprite.flip_h =true
	
func read_input()->void:
	#Obter o input vector
	input_vector = Input.get_vector("move_left","move_right","move_up","move_down")	
	#apagar deadzone do joystic
	var deadzone = 0.15
	if abs(input_vector.x) < deadzone:
		input_vector.x = 0.0
	if abs(input_vector.y) < deadzone:
		input_vector.y = 0.0
	was_running = is_running
	is_running = not input_vector.is_zero_approx() #se for diferente de zero, esta correndo
	
#o physics é mais estavel
func _physics_process(delta: float) -> void:
	if not GameManager.ic_start_game:return
#Modificar a velocidade
	var target_velocity = input_vector * speed * 100
	if is_attacking:
		target_velocity *= 0.25
	velocity = lerp(velocity,target_velocity,0.05)
	move_and_slide()

func attack() -> void:
	if is_attacking:
		return
		
	#attack_side_1	
	#attack_side_2
	#Tocar animation
	animation_player.play("attack_side_1")
	#configurar temporizador
	attack_cooldown = 0.6
	
	#Marcar ataque
	is_attacking = true
	
	#aplicar damage no enemy
	
func deal_damage_to_enemies()->void:
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var direction_to_enemy = (enemy.position - position).normalized()
			var attack_direction:Vector2
			if sprite.flip_h:
				attack_direction = Vector2.LEFT
			else :
				attack_direction = Vector2.RIGHT
			var dot_product =  direction_to_enemy.dot(attack_direction)
			print("Dot: ", dot_product)
			if dot_product >= 0.3:
				enemy.damage(sword_damage)

func update_hitbox_detection(delta:float)->void:
	hitbox_cooldown -= delta
	if hitbox_cooldown >0: return
	
	#frequencia
	hitbox_cooldown = 0.5
	#detectar inimigos
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy:Enemy = body
			var damage_amount = 1 # lembra de configurar dano dos personagens
			damage(damage_amount)
			
func damage(amount:int)->void:
	if health <= 0: return
	health -= amount
	print("Player recebeu dano de ", amount, ". a vida total é de ", health, "/", max_health)
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(tween.TRANS_QUINT)
	tween.tween_property(self,"modulate",Color.WHITE,0.3)
	if health <=0:
		die()

func die()->void:
	GameManager.end_game()
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
	print("Player morreu")
	queue_free()
	
func heal(amount:int)->int:
	health += amount
	if health > max_health:
		health = max_health
	print("Player recebeu cura de ", amount, ". a vida total é de ", health, "/", max_health)
	return health
