extends Node

signal lista_membros_atualizada(membros: Array)

var lobby_id_atual: int = 0
var max_jogadores: int = 0
var jogadores_conectados: Array = []
var jogadores_prontos: Dictionary = {}

func _ready() -> void:
	if "lobby_id_atual" in GerenciadorSteam:
		lobby_id_atual = GerenciadorSteam.lobby_id_atual
		
	if lobby_id_atual > 0:
		max_jogadores = Steam.getLobbyMemberLimit(lobby_id_atual)
		_conectar_sinais_steam()
		atualizar_e_notificar_membros()

func _conectar_sinais_steam() -> void:
	Steam.lobby_chat_update.connect(_ao_atualizar_chat_lobby)
	# Conecta o sinal de atualização de dados do lobby da Steam
	Steam.lobby_data_update.connect(_ao_atualizar_dados_lobby)

func sair_ou_deletar_lobby() -> void:
	if lobby_id_atual > 0:
		print("Saindo/Deletando o lobby ID: %s" % lobby_id_atual)
		
		# SE FOR O HOST: Avisa os clientes alterando um dado na Steam antes de sair
		if GerenciadorSteam.sou_host:
			Steam.setLobbyData(lobby_id_atual, "status_sala", "fechada")
		
		Steam.leaveLobby(lobby_id_atual)
		
		GerenciadorSteam.lobby_id_atual = 0
		GerenciadorSteam.sou_host = false
		lobby_id_atual = 0

func atualizar_e_notificar_membros() -> void:
	jogadores_conectados.clear()
	var total_membros: int = Steam.getNumLobbyMembers(lobby_id_atual)
	var lista_para_ui: Array = []
	
	for i in range(total_membros):
		var steam_id: int = Steam.getLobbyMemberByIndex(lobby_id_atual, i)
		var nome_steam: String = Steam.getFriendPersonaName(steam_id)
		
		# Lê o status "pronto" que cada jogador definiu na Steam
		var status_pronto_str: String = Steam.getLobbyMemberData(lobby_id_atual, steam_id, "pronto")
		var esta_pronto: bool = (status_pronto_str == "true")
		
		jogadores_conectados.append(steam_id)
		jogadores_prontos[steam_id] = esta_pronto
			
		lista_para_ui.append({
			"steam_id": steam_id,
			"nome": nome_steam,
			"pronto": esta_pronto
		})
	
	lista_membros_atualizada.emit(lista_para_ui)

func _ao_atualizar_chat_lobby(this_lobby_id: int, changed_id: int, making_change_id: int, chat_state: int) -> void:
	if this_lobby_id != lobby_id_atual:
		return
	atualizar_e_notificar_membros()

# Callback disparado quando qualquer dado do lobby muda na Steam
# 3. No callback _ao_atualizar_dados_lobby, adicione a escuta para o início da partida
func _ao_atualizar_dados_lobby(success: int, this_lobby_id: int, member_id: int) -> void:
	if this_lobby_id != lobby_id_atual:
		return
		
	# Checagem de fechamento da sala
	var status_sala: String = Steam.getLobbyData(lobby_id_atual, "status_sala")
	if status_sala == "fechada" and not GerenciadorSteam.sou_host:
		GerenciadorSteam.mensagem_aviso_menu = "O host deletou o lobby\nFavor tentar outro lobby"
		Steam.leaveLobby(lobby_id_atual)
		GerenciadorSteam.lobby_id_atual = 0
		GerenciadorSteam.sou_host = false
		get_tree().change_scene_to_file("res://Cenas/Menu/MenuMultiplayer.tscn")
		return

	# NOVO: Verifica se a partida foi iniciada por todos estarem prontos
	var partida_iniciada: String = Steam.getLobbyData(lobby_id_atual, "partida_iniciada")
	if partida_iniciada == "true":
		print("Partida iniciada! Indo para a Seleção de Personagem...")
		get_tree().change_scene_to_file("res://Cenas/Menu/SelecaoPersonagem.tscn")
		return

	atualizar_e_notificar_membros()

func alternar_meu_status_pronto() -> void:
	var status_atual: String = Steam.getLobbyMemberData(lobby_id_atual, Steam.getSteamID(), "pronto")
	var novo_status: String = "true" if status_atual != "true" else "false"
	
	Steam.setLobbyMemberData(lobby_id_atual, "pronto", novo_status)
	atualizar_e_notificar_membros()
	
	# Se acabamos de ficar prontos, verificamos se TODOS estão prontos
	if novo_status == "true":
		_verificar_se_todos_estao_prontos()

# 2. Nova função para checar se todos os jogadores estão prontos
func _verificar_se_todos_estao_prontos() -> void:
	var total_membros: int = Steam.getNumLobbyMembers(lobby_id_atual)
	
	# Se houver apenas 1 jogador, regra opcional: se quiser testar sozinho, pode iniciar, 
	# mas o padrão multiplayer exige pelo menos 2 ou todos estarem prontos. Vamos verificar todos:
	if total_membros < 1:
		return
		
	var todos_prontos: bool = true
	
	for i in range(total_membros):
		var steam_id: int = Steam.getLobbyMemberByIndex(lobby_id_atual, i)
		var status_pronto_str: String = Steam.getLobbyMemberData(lobby_id_atual, steam_id, "pronto")
		
		# Se algum membro não estiver pronto, a bandeira vai para false
		if status_pronto_str != "true":
			todos_prontos = false
			break
			
	if todos_prontos:
		print("Todos os jogadores estão prontos! Iniciando transição...")
		
		# Define um dado global no lobby da Steam informando que a partida começou
		# Isso vai disparar o callback em todos os clientes conectados na sala
		Steam.setLobbyData(lobby_id_atual, "partida_iniciada", "true")
