extends Node

signal lobbies_atualizados(lista_lobbies: Array)
signal status_busca_alterado(mensagem: String)
signal erro_ao_entrar(mensagem: String) # Novo sinal para enviar erros para a UI

const CHAVE_FILTRO_JOGO: String = "meu_jogo_unique_id"
const VALOR_FILTRO_JOGO: String = "Versao1"

func _ready() -> void:
	Steam.lobby_match_list.connect(_ao_receber_lista_lobbies)
	Steam.lobby_joined.connect(_ao_receber_resposta_entrada) # Correção para o sinal correto da Steam
	
	iniciar_busca()

func iniciar_busca() -> void:
	status_busca_alterado.emit("Buscando salas...")
	Steam.addRequestLobbyListStringFilter(CHAVE_FILTRO_JOGO, VALOR_FILTRO_JOGO, Steam.LOBBY_COMPARISON_EQUAL)
	Steam.requestLobbyList()

func _ao_receber_lista_lobbies(lobby_ids: Array) -> void:
	var dados_lobbies: Array = []
	
	for lobby_id in lobby_ids:
		var nome_sala: String = Steam.getLobbyData(lobby_id, "name")
		var max_jogadores: int = Steam.getLobbyMemberLimit(lobby_id)
		var num_membros: int = Steam.getNumLobbyMembers(lobby_id)
		
		var info_lobby = {
			"id": lobby_id,
			"nome": nome_sala,
			"atual": num_membros,
			"max": max_jogadores
		}
		dados_lobbies.append(info_lobby)
	
	lobbies_atualizados.emit(dados_lobbies)

# --- FUNÇÃO DE ENTRAR NO LOBBY ---
func tentar_entrar_no_lobby(lobby_id: int) -> void:
	# 1. Checagem: Verificar se o lobby já está lotado
	var num_membros: int = Steam.getNumLobbyMembers(lobby_id)
	var max_jogadores: int = Steam.getLobbyMemberLimit(lobby_id)
	
	if num_membros >= max_jogadores:
		erro_ao_entrar.emit("Este lobby está lotado!")
		return
		
	# 2. Checagem: Verificar se o lobby requer senha (e se o usuário tem / por enquanto bloqueia ou valida)
	var exige_senha: String = Steam.getLobbyData(lobby_id, "requires_password")
	if exige_senha == "true":
		# Nota: Se você tiver um campo de senha na tela de procurar, pode passá-lo aqui.
		# Por enquanto, se exigir senha e não tivermos tratado a digitação, avisamos o usuário:
		print("Este lobby exige senha.")
		# Exemplo simples de validação (se quiser pedir senha depois, podemos criar um Pop-up)
	
	print("Tentando entrar no lobby ID: %s..." % lobby_id)
	status_busca_alterado.emit("Entrando no lobby...")
	
	# Comando oficial da GodotSteam para entrar no lobby
	Steam.joinLobby(lobby_id)

# --- CALLBACK DE RESPOSTA DA STEAM AO TENTAR ENTRAR ---
func _ao_receber_resposta_entrada(lobby_id: int, permissions: int, locked: bool, response: int) -> void:
	# O 'response' com valor 1 (CHAT_ROOM_ENTER_RESPONSE_SUCCESS) indica sucesso
	if response == 1:
		print("Entrada no lobby realizada com sucesso!")
		
		# Salva os dados no Autoload do GerenciadorSteam
		GerenciadorSteam.lobby_id_atual = lobby_id
		GerenciadorSteam.sou_host = false # Como entramos na sala de outro, não somos o host
		
		# Muda para a cena do Lobby
		get_tree().change_scene_to_file("res://Cenas/Menu/Lobby.tscn")
	else:
		print("Falha ao entrar no lobby. Código de resposta: %s" % response)
		erro_ao_entrar.emit("Não foi possível entrar no lobby (Erro: %d)." % response)
		status_busca_alterado.emit("Erro ao entrar.")
