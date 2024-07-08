class_name GameStartUI
extends CanvasLayer
@onready var animation_player:AnimationPlayer = $Menu/Panel/BtnStart/AnimationPlayer
@onready var btn_start: Button = $Menu/Panel/BtnStart

func _ready():
	btn_start.pressed.connect(_button_pressed)

func _button_pressed():
	animation_player.play("default")

func start_game():
	GameManager.start_game(self)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	start_game()
