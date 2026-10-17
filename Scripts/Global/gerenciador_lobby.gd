extends Node

signal lobby_criado_sucesso
signal lobby_criado_falha(mensagem: String)

signal lobby_atualizado
signal iniciar_partida_recebido
signal voltar_menu_recebido

const MAX_JOGADORES_PADRAO := 4

var jogadores_conectados: Array[int] = []
var jogadores_prontos: Dictionary = {}
var numero_jogador_por_id: Dictionary = {}

var estou_pronto := false

var nome_sala: String = ""
var senha_sala: String = ""
var sala_privada: bool = false
var max_jogadores: int = 4
var id_lobby: int = 0

var multiplayer_peer = SteamMultiplayerPeer.new()

func _ready():
	# Conecta aos sinais da Steam
	Steam.lobby_created.connect(_on_lobby_created)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
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

func inicializar_novo_lobby():
	jogadores_conectados.clear()
	jogadores_prontos.clear()
	numero_jogador_por_id.clear()
	estou_pronto = false

	var meu_id = multiplayer.get_unique_id()
	if meu_id not in jogadores_conectados:
		jogadores_conectados.append(meu_id)

	# O Host é sempre o Jogador 1
	if multiplayer.is_server():
		numero_jogador_por_id[meu_id] = 1
	else:
		# Cliente pede a lista atualizada direto para o Host
		_pedir_lista_ao_host.rpc_id(1)

	emit_signal("lobby_atualizado")

func _on_peer_connected(id: int):
	print("Jogador entrou no lobby: ", id)
	if id not in jogadores_conectados:
		jogadores_conectados.append(id)

	# Host define o número do novo jogador e sincroniza com todos
	if multiplayer.is_server():
		var numero := 1
		while numero_jogador_por_id.values().has(numero):
			numero += 1
		numero_jogador_por_id[id] = numero

		_sincronizar_dados_lobby.rpc(jogadores_conectados, numero_jogador_por_id, DadosJogo.max_jogadores)
	
	emit_signal("lobby_atualizado")

func _on_peer_disconnected(id: int):
	print("Jogador saiu do lobby: ", id)
	jogadores_conectados.erase(id)
	jogadores_prontos.erase(id)
	numero_jogador_por_id.erase(id)

	if multiplayer.is_server():
		_sincronizar_dados_lobby.rpc(jogadores_conectados, numero_jogador_por_id, DadosJogo.max_jogadores)

	emit_signal("lobby_atualizado")

@rpc("any_peer", "reliable")
func _pedir_lista_ao_host():
	# Apenas o servidor processa o pedido do cliente
	if not multiplayer.is_server():
		return
		
	var id_quem_pediu = multiplayer.get_remote_sender_id()
	_sincronizar_dados_lobby.rpc_id(id_quem_pediu, jogadores_conectados, numero_jogador_por_id, DadosJogo.max_jogadores)

@rpc("authority", "call_local", "reliable")
func _sincronizar_dados_lobby(nova_lista: Array, novo_mapa_numeros: Dictionary, novo_max: int):
	jogadores_conectados.clear()
	for id in nova_lista:
		jogadores_conectados.append(int(id))

	numero_jogador_por_id.clear()
	for id in novo_mapa_numeros:
		numero_jogador_por_id[int(id)] = int(novo_mapa_numeros[id])

	DadosJogo.max_jogadores = novo_max

	# Descobre o número desta máquina localmente
	var meu_id = multiplayer.get_unique_id()
	if numero_jogador_por_id.has(meu_id):
		DadosJogo.numero_jogador = numero_jogador_por_id[meu_id]

	emit_signal("lobby_atualizado")

func alternar_pronto():
	if jogadores_conectados.size() < 2:
		return

	estou_pronto = not estou_pronto
	var meu_id = multiplayer.get_unique_id()
	jogadores_prontos[meu_id] = estou_pronto

	_sincronizar_pronto.rpc(meu_id, estou_pronto)
	emit_signal("lobby_atualizado")

@rpc("any_peer", "call_local", "reliable")
func _sincronizar_pronto(id: int, estado: bool):
	jogadores_prontos[id] = estado
	emit_signal("lobby_atualizado")

	# Somente o Host verifica se todos estão prontos para iniciar
	if multiplayer.is_server():
		for jogador_id in jogadores_conectados:
			if not jogadores_prontos.get(jogador_id, false):
				return
		
		_iniciar_partida_rpc.rpc()

@rpc("authority", "call_local", "reliable")
func _iniciar_partida_rpc():
	var meu_id = multiplayer.get_unique_id()
	if numero_jogador_por_id.has(meu_id):
		DadosJogo.numero_jogador = numero_jogador_por_id[meu_id]

	emit_signal("iniciar_partida_recebido")

func sair_do_lobby():
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	
	emit_signal("voltar_menu_recebido")
