extends CharacterBody2D
class_name Player


signal died
signal player_health_changed(new_health)


@export var speed : int = 150


@onready var weapon_manager = $WeaponManager
@onready var health_stat = $Health
@onready var team = $Team
@onready var camera_transform = $CameraTransform
@onready var collision_shape = $CollisionShape2D


func _ready():
	weapon_manager.inizialize(team.team)


func _physics_process(delta: float) -> void:
	var movement_direction := Vector2.ZERO

	if Input.is_action_pressed("up"):
		movement_direction.y = -1
	if Input.is_action_pressed("down"):
		movement_direction.y = 1
	if Input.is_action_pressed("left"):
		movement_direction.x = -1
	if Input.is_action_pressed("right"):
		movement_direction.x = 1

	velocity = movement_direction.normalized() * speed
	move_and_slide()

	look_at(get_global_mouse_position())





func set_camera_transform(camera_path: NodePath):
	camera_transform.remote_path = camera_path



func get_team() -> int:
	return team.team 


func handle_hit():
	health_stat.health -= 10
	emit_signal("player_health_changed", health_stat.health)
	if health_stat.health <= 0:
		die()


func die():
	emit_signal("died")
	queue_free()
