extends Node

const PORTA = 9999
const MAX_JOGADORES = 2

var peer = ENetMultiplayerPeer.new()


func _ready():
	print("Servidor iniciado.")

	var erro = peer.create_server(PORTA, MAX_JOGADORES)

	if erro != OK:
		print("Erro ao criar servidor: ", erro)
		return

	multiplayer.multiplayer_peer = peer

	multiplayer.peer_connected.connect(jogador_conectou)
	multiplayer.peer_disconnected.connect(jogador_desconectou)

	print("Servidor aguardando jogadores na porta ", PORTA)


func jogador_conectou(id):
	print("Jogador conectado: ", id)


func jogador_desconectou(id):
	print("Jogador desconectado: ", id)
