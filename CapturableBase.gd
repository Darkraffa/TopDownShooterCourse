extends Area2D
class_name CapturableBase


signal base_captured(new_team)


@export var player_color = Color.DARK_GREEN
@export var enemy_color = Color.DARK_BLUE
@export var neutral_color = Color.WHITE


@onready var team = $Team
@onready var capture_time = $CaptureTimer
@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D
@onready var player_label = $PlayerLabel
@onready var enemy_label = $EnemyLabel


var player_unit_count: int = 0
var enemy_unit_count: int = 0
var team_to_capture: int = Team.TeamName.NEUTRAL


func _ready():
	player_label.text = "0"
	enemy_label.text = "0"


func get_random_position_within_capture_radius() -> Vector2:
	var extens = collision_shape.shape.size
	var top_left = collision_shape.global_position - (extens / 2)
	var x = randf_range(top_left.x, top_left.x + extens.x)
	var y = randf_range(top_left.y, top_left.y + extens.y)
	return Vector2(x,y)


func _on_body_entered(body):
	if body.has_method("get_team"):
		var body_team = body.get_team()
		if body_team == Team.TeamName.ENEMY:
			enemy_unit_count += 1
			change_enemy_label()
		elif body_team == Team.TeamName.PLAYER:
			player_unit_count += 1
			change_player_label()

		check_whether_base_can_be_captured()


func _on_body_exited(body):
	if body.has_method("get_team"):
		var body_team = body.get_team()
		if body_team == Team.TeamName.ENEMY:
			enemy_unit_count -= 1
			change_enemy_label()
		elif body_team == Team.TeamName.PLAYER:
			player_unit_count -= 1
			change_player_label()

		check_whether_base_can_be_captured()


func change_player_label():
	player_label.text = str(player_unit_count)


func change_enemy_label():
	enemy_label.text = str(enemy_unit_count)


func check_whether_base_can_be_captured():
	var majority_team = get_team_with_majority()

	if majority_team == Team.TeamName.NEUTRAL:
		return
	elif majority_team == team.team:
		team_to_capture = Team.TeamName.NEUTRAL
		capture_time.stop()
	else:
		team_to_capture = majority_team
		capture_time.start()


func get_team_with_majority() -> int:
	if enemy_unit_count == player_unit_count:
		return Team.TeamName.NEUTRAL
	elif enemy_unit_count > player_unit_count:
		return Team.TeamName.ENEMY
	else:
		return Team.TeamName.PLAYER


func set_team(new_team: int):
	team.team = new_team
	emit_signal("base_captured", new_team)
	match new_team:
		Team.TeamName.NEUTRAL:
			sprite.modulate = neutral_color
			return
		Team.TeamName.PLAYER:
			sprite.modulate = player_color
			return
		Team.TeamName.ENEMY:
			sprite.modulate = enemy_color
			return


func _on_capture_timer_timeout():
	set_team(team_to_capture)
