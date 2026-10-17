extends Node

signal lobby_criado_sucesso
signal lobby_criado_falha(mensagem: String)

var nome_sala: String = ""
var senha_sala: String = ""
var sala_privada: bool = false
var max_jogadores: int = 4
var id_lobby: int = 0

var multiplayer_peer = SteamMultiplayerPeer.new()

func _ready():
	# Conecta aos sinais da Steam
	Steam.lobby_created.connect(_on_lobby_created)

func _process(_delta):
	# Processa os callbacks da Steam a cada frame
	Steam.run_callbacks()

func criar_lobby_steam(p_nome: String, p_senha: String, p_privada: bool, p_max: int):
	nome_sala = p_nome
	senha_sala = p_senha
	sala_privada = p_privada
	max_jogadores = p_max

	print("========== CRIANDO LOBBY NA STEAM ==========")
	print("Nome: ", nome_sala)
	print("Máximo: ", max_jogadores)

	var tipo_visibilidade = 2 if p_privada else 0
	Steam.createLobby(tipo_visibilidade, p_max)

func _on_lobby_created(result: int, steam_id: int):
	if result == 1:
		id_lobby = steam_id
		print("Lobby criado na Steam com ID: %d" % id_lobby)

		# Salva os dados no lobby da Steam
		Steam.setLobbyData(id_lobby, "name", nome_sala)
		Steam.setLobbyData(id_lobby, "password", senha_sala)
		Steam.setLobbyJoinable(id_lobby, true)

		# CORREÇÃO: Chamar create_host() sem parâmetros para o peer da Steam se acoplar ao lobby ativo
		var erro = multiplayer_peer.create_host()
		
		if erro != OK:
			var msg = "Erro ao iniciar o peer da Steam: %d" % erro
			print(msg)
			emit_signal("lobby_criado_falha", msg)
			return

		multiplayer.multiplayer_peer = multiplayer_peer
		emit_signal("lobby_criado_sucesso")
	else:
		var msg = "Falha ao criar lobby na Steam. Código: %d" % result
		print(msg)
		emit_signal("lobby_criado_falha", msg)
