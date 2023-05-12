extends CanvasLayer


@onready var title = $PanelContainer/MarginContainer/Rows/Title
@onready var animation_player = $AnimationPlayer


func _ready():
	animation_player.play("fade")


func set_title(win: bool):
	if win:
		title.text = "YOU WIN!"
		title.modulate = Color.GREEN
	else:
		title.text = "YOU LOSE!"
		title.modulate = Color.RED


func _on_restart_button_pressed():
	get_tree().change_scene_to_file("res://main.tscn")
	get_tree().paused = false


func _on_quit_button_pressed():
	get_tree().quit()


func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://ui/main_menu_screen.tscn")
	get_tree().paused = false
