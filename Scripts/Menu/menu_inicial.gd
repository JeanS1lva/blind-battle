extends Control

@onready var mensagem:Label = $Interface/Mensagem
 
func _on_iniciar_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/Menu/FuncionalidadePendente.tscn")

func multiplayer():
	if GerenciadorSteam.inicializar_steam():
		get_tree().change_scene_to_file("res://Cenas/Menu/MenuMultiplayer.tscn")
	else: 
		mensagem.add_theme_color_override("font_color", Color.RED)
		mensagem.text = "Erro: Steam não está aberta ou fora do ar"
		mensagem.show()
		
func _on_configuracoes_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/Menu/FuncionalidadePendente.tscn")

func _on_sobre_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/Menu/FuncionalidadePendente.tscn")

func _on_sair_pressed() -> void:
	get_tree().quit()
