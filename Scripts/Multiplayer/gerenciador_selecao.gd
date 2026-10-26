class_name GerenciadorSelecao
extends Node

signal todos_escolheram()
signal erro_desconexao(mensagem: String)

var _meu_personagem := ""

func _ready() -> void:
	# Conecta aos sinais globais da Steam para monitorar mudanças no lobby e quedas de conexão
	if GerenciadorSteam.has_signal("lobby_data_update"):
		GerenciadorSteam.lobby_data_update.connect(_on_lobby_data_update)
	
	if GerenciadorSteam.has_signal("lobby_chat_update"):
		GerenciadorSteam.lobby_chat_update.connect(_on_lobby_chat_update)

# Chamado pela UI quando o jogador clica e confirma o personagem
func registrar_escolha(personagem: String) -> void:
	_meu_personagem = personagem
	
	# Usa o SteamMatchmaking para salvar o personagem escolhido nos metadados do lobby
	var lobby_id = GerenciadorSteam.lobby_id_atual
	var my_steam_id = Steam.getSteamID()
	
	# Define uma chave única para este membro, ex: "personagem_123456789"
	Steam.setLobbyData(lobby_id, "personagem_" + str(my_steam_id), personagem)
	print("Enviando escolha para a Steam: %s" % personagem)

# Monitora se os dados do lobby mudaram (alguém escolheu ou atualizou algo)
func _on_lobby_data_update(success: int, lobby_id: int, member_id: int) -> void:
	if success != 1:
		return
		
	verificar_se_todos_escolheram(lobby_id)

# Monitora se alguém entrou ou saiu do lobby (desconexões)
func _on_lobby_chat_update(lobby_id: int, change_id: int, making_change_id: int, chat_state: int) -> void:
	# Estados da Steam para saída ou desconexão de membros
	if chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_LEFT or \
	   chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_DISCONNECTED or \
	   chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_KICKED:
		
		# Se alguém saiu durante a seleção, dispara o aviso de segurança
		emit_signal("erro_desconexao", "Um jogador se desconectou. Retornando...")

func verificar_se_todos_escolheram(lobby_id: int) -> void:
	var num_membros = Steam.getNumLobbyMembers(lobby_id)
	var todos_prontos = true
	var escolhas_dos_jogadores := {}
	
	# Percorre todos os membros atuais do lobby
	for i in range(num_membros):
		var member_steam_id = Steam.getLobbyMemberByIndex(lobby_id, i)
		var personagem_escolhido = Steam.getLobbyMemberData(lobby_id, member_steam_id, "personagem_" + str(member_steam_id))
		
		# Se algum membro ainda não tiver a chave de personagem preenchida, nem todos escolheram
		if personagem_escolhido == "":
			todos_prontos = false
			break
		else:
			escolhas_dos_jogadores[member_steam_id] = personagem_escolhido
			
	# Se todo mundo na sala já escolheu, salvamos no DadosJogo e avisamos a UI
	if todos_prontos and num_membros > 0:
		print("Todos os jogadores escolheram seus personagens!")
		
		# Salva as informações coletadas no DadosJogo global
		# DadosJogo.salvar_escolhas_partida(escolhas_dos_jogadores)
		
		emit_signal("todos_escolheram()")
