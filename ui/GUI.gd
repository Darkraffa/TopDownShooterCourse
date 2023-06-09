extends CanvasLayer
class_name GUI


@onready var health_bar = $MarginContainer/Rows/BottomRow/HealthSection/HealthBar
@onready var current_ammo = $MarginContainer/Rows/BottomRow/AmmoSection/CurrentAmmo
@onready var max_ammo = $MarginContainer/Rows/BottomRow/AmmoSection/MaxAmmo


var player: Player = null


func set_player(player: Player):
	self.player = player
	
	set_new_health_value(player.health_stat.health)
	player.connect("player_health_changed", set_new_health_value)
	
	set_weapon(player.weapon_manager.get_current_weapon())
	player.weapon_manager.connect("weapon_changed", set_weapon)


func set_weapon(weapon: Weapon):
	set_current_ammo(weapon.current_ammo)
	set_max_ammo(weapon.max_ammo)
	if not weapon.is_connected("weapon_fired", set_current_ammo):
		weapon.connect("weapon_fired", set_current_ammo)


func set_new_health_value(new_health: int):
	var original_color = Color("#6e0000")
	var new_color = Color("#ff7e7e")
	var bar_style = health_bar.get("theme_override_styles/fill")
	var health_tween: Tween = create_tween() 
	health_tween.tween_property(health_bar, "value", new_health, 0.4).from(health_bar.value).set_ease(Tween.EASE_IN)
	health_tween.tween_property(bar_style, "bg_color", new_color, 0.2).from(original_color).set_ease(Tween.EASE_IN)
	health_tween.tween_property(bar_style, "bg_color", original_color, 0.2).from(new_color).set_ease(Tween.EASE_OUT)
	health_bar.value = new_health


func set_current_ammo(new_ammo: int):
	current_ammo.text = str(new_ammo)


func set_max_ammo(new_max_ammo: int):
	max_ammo.text = str(new_max_ammo)
