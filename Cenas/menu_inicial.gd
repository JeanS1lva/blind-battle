extends Control

func _on_iniciar_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/SelecaoPersonagem.tscn")

func multiplayer():
	get_tree().change_scene_to_file("res://Cenas/Multiplayer.tscn")
