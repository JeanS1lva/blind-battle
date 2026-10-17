extends Control

@onready var criar_partida: Button = $"Botões/CriarPartida"
@onready var entrar_partida: Button = $"Botões/EntrarPartida"
@onready var voltar: Button = $"Botões/Voltar"

func _ready():
	# BOTÕES
	criar_partida.pressed.connect(ir_para_criar_lobby)
	entrar_partida.pressed.connect(ir_procurar_lobbies)
	voltar.pressed.connect(voltar_ao_menu)

# Ir para a cena de Criar Lobby
func ir_para_criar_lobby():
	get_tree().change_scene_to_file("res://Cenas/Menu/CriarLobby.tscn")

# Ir para a cena de Procurar Lobbies
func ir_procurar_lobbies():
	pass

# VOLTAR
func voltar_ao_menu():
	get_tree().change_scene_to_file("res://Cenas/Menu/MenuInicial.tscn")
