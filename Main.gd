## tutorial 26 iniziare

extends Node2D


const Player = preload("res://actors/player.tscn")
const GameOverScreen = preload("res://ui/game_over_screen.tscn")
const PauseScreen = preload("res://ui/pause_screen.tscn")


@onready var bullet_manager = $BulletManager
@onready var capturable_base_manager = $CapturableBaseManager
@onready var ally_ai = $AllyMapAI
@onready var enemy_ai = $EnemyMapAI
@onready var camera = $Camera2D
@onready var gui = $GUI
@onready var tilemap = $TileMap
@onready var pathfinding = $Pathfinding


func _ready():
	randomize()
	GlobalSignals.bullet_fired.connect(bullet_manager.handle_bullet_spawned)

	var ally_respawn = $AllyRespawnPoint
	var enemy_respawn = $EnemyRespawnPoint

	pathfinding.create_navigation_map(tilemap)

	var bases = capturable_base_manager.get_capturable_bases()
	ally_ai.inizialize(bases, ally_respawn.get_children(), pathfinding)
	enemy_ai.inizialize(bases, enemy_respawn.get_children(), pathfinding)

	capturable_base_manager.connect("player_captured_all_bases", player_handle_win)
	capturable_base_manager.connect("player_lost_all_bases", player_handle_lost)

	spawn_player()


func spawn_player():
	var player = Player.instantiate()
	add_child(player)
	player.position = Vector2(-32, 0)
	player.set_camera_transform(camera.get_path())
	player.connect("died", spawn_player)
	gui.set_player(player)


func player_handle_win():
	var game_over = GameOverScreen.instantiate()
	add_child(game_over)
	game_over.set_title(true)
	get_tree().paused = true


func player_handle_lost():
	var game_over = GameOverScreen.instantiate()
	add_child(game_over)
	game_over.set_title(false)
	get_tree().paused = true


func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		var pause_menu = PauseScreen.instantiate()
		add_child(pause_menu)
