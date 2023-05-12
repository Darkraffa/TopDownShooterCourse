extends Node2D


const BULLET_IMPACT = preload("res://weapons/bullet_impact.tscn")


func _ready():
	GlobalSignals.connect("bullet_impacted", handle_bullet_impacted)


func handle_bullet_impacted(position: Vector2, direction: Vector2):
	var impact = BULLET_IMPACT.instantiate()
	add_child(impact)
	impact.global_position = position
	impact.global_rotation = direction.angle()
	impact.start_emitting()
