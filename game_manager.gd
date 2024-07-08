extends Node

signal game_over
signal sg_start_game

var ic_start_game:bool = false

var player_position:Vector2
var player:Player
var is_game_over:bool=false

var time_elapsed: float = 0.0
var time_elapsed_string:String
var meat_counter:int = 0
var monsters_defeated_counter:int=0

func _process(delta: float) -> void:
	if not ic_start_game: return
	sg_start_game.emit()	
	time_elapsed+=delta
	var time_elapsed_in_seconds: int = floori(time_elapsed)
	var seconds:int = time_elapsed_in_seconds % 60
	var minutes:int = time_elapsed_in_seconds / 60	
	time_elapsed_string = "%02d:%02d" %[minutes,seconds]
	
func start_game(gameuimenuinicial:CanvasLayer):
	gameuimenuinicial.hide()
	ic_start_game = true
	
func end_game():
	if is_game_over:
		ic_start_game = false
		return
	is_game_over = true
	game_over.emit()

func reset():
	player =null
	player_position = Vector2.ZERO
	is_game_over = false
	ic_start_game = false
	for connection in game_over.get_connections():
		game_over.disconnect(connection.callable)
	for connection2 in sg_start_game.get_connections():
		sg_start_game.disconnect(connection2.callable)
	time_elapsed= 0.0
	time_elapsed_string = ""
	meat_counter = 0
	monsters_defeated_counter = 0
