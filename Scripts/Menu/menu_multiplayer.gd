extends Control

@onready var criar_partida: Button = $"Botões/CriarPartida"
@onready var entrar_partida: Button = $"Botões/EntrarPartida"
@onready var voltar: Button = $"Botões/Voltar"
@onready var label_mensagem: Label = $"Interface/Mensagem"
func _ready():
	# BOTÕES
	criar_partida.pressed.connect(ir_para_criar_lobby)
	entrar_partida.pressed.connect(ir_procurar_lobbies)
	voltar.pressed.connect(voltar_ao_menu)
	# Verifica se há alguma mensagem de aviso pendente vinda de uma queda de lobby
	if "mensagem_aviso_menu" in GerenciadorSteam and GerenciadorSteam.mensagem_aviso_menu != "":
		label_mensagem.text = GerenciadorSteam.mensagem_aviso_menu
		# Limpa a mensagem para não ficar repetindo caso o jogador saia e volte para o menu de novo
		GerenciadorSteam.mensagem_aviso_menu = ""
	else:
		label_mensagem.text = "" # Limpa se não houver avisos

# Ir para a cena de Criar Lobby
func ir_para_criar_lobby():
	get_tree().change_scene_to_file("res://Cenas/Menu/MenuCriarLobby.tscn")

# Ir para a cena de Procurar Lobbies
func ir_procurar_lobbies():
	get_tree().change_scene_to_file("res://Cenas/Menu/MenuProcurarLobby.tscn")

# VOLTAR
func voltar_ao_menu():
	get_tree().change_scene_to_file("res://Cenas/Menu/MenuInicial.tscn")
