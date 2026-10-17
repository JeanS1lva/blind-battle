extends Control


const PORTA := 9999
const MAX_JOGADORES := 4

var peer := ENetMultiplayerPeer.new()


func _ready():
	
	# BOTÕES
	$CriarPartida.pressed.connect(ir_para_criar_lobby())
	$EntrarPartida.pressed.connect(ir_procurar_lobbies())
	$Voltar.pressed.connect(voltar)

	# SINAL DE CONEXÃO DO CLIENTE
	multiplayer.connected_to_server.connect(conectado_ao_servidor)

	multiplayer.connection_failed.connect(falha_na_conexao)


# Ir para a cena de Criar Lobby
func ir_para_criar_lobby():
	get_tree().change_scene_to_file("res://Cenas/CriarLobby.tscn")

# Procurar lobbies
func ir_procurar_lobbies():
	var endereco := "127.0.0.1"
	var erro = peer.create_client(endereco, PORTA)

	if erro != OK:
		print("Erro ao entrar na partida: ", erro)
		return
		
	# Define este jogo como CLIENTE
	multiplayer.multiplayer_peer = peer

# =========================================================
# CONECTADO AO SERVIDOR
# =========================================================

func conectado_ao_servidor():

	print("Conectado ao HOST!")

	ir_para_lobby()


# =========================================================
# FALHA NA CONEXÃO
# =========================================================

func falha_na_conexao():

	print("Não foi possível conectar ao HOST.")


# =========================================================
# IR PARA O LOBBY
# =========================================================

func ir_para_lobby():

	get_tree().change_scene_to_file(
		"res://Cenas/Lobby.tscn"
	)


# =========================================================
# VOLTAR
# =========================================================

func voltar():

	if multiplayer.multiplayer_peer != null:

		multiplayer.multiplayer_peer.close()

		multiplayer.multiplayer_peer = null


	get_tree().change_scene_to_file(
		"res://Cenas/MenuInicial.tscn"
	)
