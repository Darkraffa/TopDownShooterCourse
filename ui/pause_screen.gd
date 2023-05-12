extends CanvasLayer


func _ready():
	get_tree().paused = true


func _on_resume_button_pressed():
	get_tree().paused = false
	queue_free()


func _on_quit_button_pressed():
	get_tree().change_scene_to_file("res://ui/main_menu_screen.tscn")
	get_tree().paused = false
