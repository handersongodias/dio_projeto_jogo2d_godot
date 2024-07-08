extends Node
@export var game_ui: CanvasLayer
@export var game_over_ui:PackedScene
@export var game_start_ui:PackedScene

@export var start_game:bool=false

func _ready():
	GameManager.game_over.connect(trigger_game_over)

func trigger_game_over():
	if game_ui:
		game_ui.queue_free()
		game_ui = null
	var game_overui:GameOverUI = game_over_ui.instantiate()
	add_child(game_overui)
	
