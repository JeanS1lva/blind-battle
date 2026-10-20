extends Node

# Sinal emitido para a interface quando os lobbies são encontrados ou a busca falha
signal lobbies_atualizados(lista_lobbies: Array)
signal status_busca_alterado(mensagem: String)

# Defina uma chave única para o seu jogo para filtrar apenas as suas salas
const CHAVE_FILTRO_JOGO: String = "meu_jogo_unique_id"
const VALOR_FILTRO_JOGO: String = "Versao1"

func _ready() -> void:
	Steam.lobby_match_list.connect(_ao_receber_lista_lobbies)
	
	# Inicia a busca logo ao carregar
	iniciar_busca()

func iniciar_busca() -> void:
	status_busca_alterado.emit("Buscando salas...")
	print("Solicitando lista filtrada de lobbies à Steam...")
	
	# ADICIONA O FILTRO: Pede à Steam para trazer apenas lobbies que tenham o nosso identificador de jogo
	Steam.addRequestLobbyListStringFilter(CHAVE_FILTRO_JOGO, VALOR_FILTRO_JOGO, Steam.LOBBY_COMPARISON_EQUAL)
	
	# Dispara a requisição
	Steam.requestLobbyList()

func _ao_receber_lista_lobbies(lobby_ids: Array) -> void:
	var dados_lobbies: Array = []
	
	print("Lobbies brutos encontrados pela Steam: %d" % lobby_ids.size())
	
	for lobby_id in lobby_ids:
		# Extrai as informações de cada lobby válido
		var nome_sala: String = Steam.getLobbyData(lobby_id, "name")
		var max_jogadores: int = Steam.getLobbyMemberLimit(lobby_id)
		var num_membros: int = Steam.getNumLobbyMembers(lobby_id)
		
		# Empacota as informações em um dicionário para enviar à UI
		var info_lobby = {
			"id": lobby_id,
			"nome": nome_sala,
			"atual": num_membros,
			"max": max_jogadores
		}
		dados_lobbies.append(info_lobby)
	
	# Emite o sinal para a interface lidar com a exibição visual
	lobbies_atualizados.emit(dados_lobbies)
