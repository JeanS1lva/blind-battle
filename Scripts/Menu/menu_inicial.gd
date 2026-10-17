extends Control

func _on_iniciar_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/Menu/FuncionalidadePendente.tscn")

func multiplayer():
	get_tree().change_scene_to_file("res://Cenas/Menu/Multiplayer.tscn")

func _on_configuracoes_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/Menu/FuncionalidadePendente.tscn")

func _on_sobre_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/Menu/FuncionalidadePendente.tscn")

func _on_sair_pressed() -> void:
	get_tree().quit()
