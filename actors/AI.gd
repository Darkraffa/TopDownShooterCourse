extends Node2D
class_name AI


signal state_changed(new_state)


enum State{
	PATROL,
	ENGAGE,
	ADVANCE
}


@export var should_draw_line: bool = false

@onready var patrol_timer = $PatrolTimer
@onready var path_line = $PathLine


var current_state: int = -1 : set = set_state
var actor: Actor = null
var target: CharacterBody2D = null
var weapon: Weapon = null
var team: int = -1

# PATROL STATE
var origin: Vector2 = Vector2.ZERO
var patrol_location: Vector2 = Vector2.ZERO
var patrol_location_reached: bool = false
var actor_velocity: Vector2 = Vector2.ZERO

# ADVANCE STATE
var next_base: Vector2 = Vector2.ZERO

var pathfinding: Pathfinding


func _ready():
	set_state(State.PATROL)
	path_line.visible = should_draw_line


func _physics_process(delta):
	path_line.global_rotation = 0
	match current_state:
		State.PATROL:
			if not patrol_location_reached:
				var path = pathfinding.get_new_path(global_position, patrol_location)
				if path.size() > 1:
					actor.velocity = actor.velocity_toward(path[1])
					actor.rotate_toward(path[1])
					actor.move_and_slide()
					set_path_line(path)
				else:
					patrol_location_reached = true
					actor_velocity = Vector2.ZERO
					patrol_timer.start()
					path_line.clear_points()
		State.ENGAGE:
			if target != null and weapon != null:
				actor.rotate_toward(target.global_position)
				var angle_to_player = actor.global_position.direction_to(target.global_position).angle()
				if abs(actor.rotation - angle_to_player) < 0.1:
					weapon.shoot()
			else:
				pass
		State.ADVANCE:
			var path = pathfinding.get_new_path(global_position, next_base)
			if path.size() > 1:
				actor.velocity = actor.velocity_toward(path[1])
				actor.rotate_toward(path[1])
				actor.move_and_slide()
				set_path_line(path)
			else:
				set_state(State.PATROL)
				path_line.clear_points()
		_:
			print("Error State")


func inizialize(actor: CharacterBody2D, weapon: Weapon, team: int):
	self.actor = actor
	self.weapon = weapon
	self.team = team
	weapon.connect("weapon_out_of_ammo", handle_reload)


func set_path_line(points: Array):
	if not should_draw_line:
		return
	var local_points := []
	for point in points:
		if point == points[0]:
			local_points.append(Vector2.ZERO)
		else:
			local_points.append(point - global_position)

	path_line.points = local_points


func set_state(new_state: int):
	if new_state == current_state:
		return

	if new_state == State.PATROL:
		origin = global_position
		patrol_timer.start()
		patrol_location_reached = true
		
	elif new_state == State.ADVANCE:
		if actor.has_reached_position(next_base):
			set_state(State.PATROL)

	current_state = new_state
	emit_signal("state_changed", current_state)


func handle_reload():
	weapon.start_reload()


func _on_patrol_timer_timeout():
	var patrol_range = 150.0
	var random_x = randf_range(-patrol_range, patrol_range)
	var random_y = randf_range(-patrol_range, patrol_range)
	patrol_location = Vector2(random_x, random_y) + origin
	patrol_location_reached = false


func _on_detection_zone_body_entered(body):
	if body.has_method("get_team") and body.get_team() != team:
		set_state(State.ENGAGE)
		target = body


func _on_detection_zone_body_exited(body):
	if target and body == target:
		set_state(State.ADVANCE)
		target = null
