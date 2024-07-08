class_name Enemy
extends Node2D
@export_category("HP")
@export var health:int = 10
@export var death_prefab: PackedScene

@export_category("Drops")
@export var drop_chance:float = 0.1
@export var drop_items:Array[PackedScene]
@export var drop_chances:Array[float]
#display damage in enemies
var damage_digit_prefab:PackedScene

@onready var damage_digit_marker = $DamageDigitMarker

func _ready() -> void:
	damage_digit_prefab =preload("res://misc/damage_digit.tscn")

func damage(amount:int)->void:
	health -= amount
	print("inimigo recebeu dano de ", amount, ". a vida total é de ", health)
	modulate = Color.RED
	#var tween = create_tween().tween_property(self,"modulate",Color.WHITE,0.3)
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(tween.TRANS_QUINT)
	tween.tween_property(self,"modulate",Color.WHITE,0.3)
	if health <=0:
		die()
	var damage_digit = damage_digit_prefab.instantiate()
	damage_digit.value = amount
	if damage_digit_marker:
		damage_digit.global_position = damage_digit_marker.global_position
	else:
		damage_digit.global_position = global_position
	get_parent().add_child(damage_digit)
	
func die()->void:
	#Caveira
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
	#Drop
	if randf()<= drop_chance:
		drop_item()
	#incrementar contador
	GameManager.monsters_defeated_counter+=1
	#Deletar node
	queue_free()
func drop_item()->void:
	var drop = get_random_drop_item().instantiate()
	drop.position = position
	get_parent().add_child(drop)
	
func get_random_drop_item()->PackedScene:
	#Lista com um item
	if drop_items.size() ==1:
		return drop_items[0]
	#Calcular chance
	var max_chance:float=0.0
	for dorp_chance in drop_chances:
		max_chance += drop_chance
	#Jogar dado
	var random_value = randf() * max_chance
	
	#Girar a roleta
	var needle:float= 0.0 # agulha
	for i in drop_items.size():
		var drop_item = drop_items[i]
		var drop_chance = drop_chances[i] if i < drop_chances.size() else 1 # condição IF
		# verifica se o valor do random_value é menor que o drop_chance + needle
		if random_value <= drop_chance + needle:
			return drop_item
		needle += drop_chance
	return drop_items[0]
