extends Node2D

@export var damage_amount: int =1
@onready var aread2d: Area2D = $Area2D

func deal_damage()->void:
	var bodies = aread2d.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			enemy.damage(damage_amount)
