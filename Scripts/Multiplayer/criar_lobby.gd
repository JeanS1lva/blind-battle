extends Node

signal erro_criacao(mensagem: String)

# Variáveis temporárias para guardar os dados enquanto a Steam processa a criação
var _nome_temp: String = ""
var _senha_temp: String = ""
var _tipo_temp: int = 0

func _ready() -> void:
	Steam.lobby_created.connect(_ao_receber_resposta_lobby)

func tentar_criar_lobby(nome: String, senha: String, tipo_idx: int, max_jogadores: int) -> void:
	if nome.strip_edges() == "":
		erro_criacao.emit("O nome da sala não pode estar vazio!")
		return
	
	# Guarda temporariamente para aplicar assim que a Steam confirmar a criação do ID
	_nome_temp = nome
	_senha_temp = senha
	_tipo_temp = tipo_idx
	
	# Mapeia o tipo da sala para os enums da GodotSteam
	var steam_lobby_type = Steam.LOBBY_TYPE_PUBLIC
	if tipo_idx == 1:
		steam_lobby_type = Steam.LOBBY_TYPE_PRIVATE
		
	print("Solicitando criação do lobby na Steam para %d jogadores..." % max_jogadores)
	Steam.createLobby(steam_lobby_type, max_jogadores)

func _ao_receber_resposta_lobby(result: int, lobby_id: int) -> void:
	if result == 1:
		print("Lobby criado com sucesso! ID do Lobby: %s" % lobby_id)
		
		# Define os metadados do Lobby na Steam para busca e exibição futura
		Steam.setLobbyData(lobby_id, "name", _nome_temp)
		Steam.setLobbyData(lobby_id, "requires_password", "true" if _senha_temp != "" else "false")
		if _senha_temp != "":
			Steam.setLobbyData(lobby_id, "password", _senha_temp)
			
		# ADICIONE ESTA LINHA: Chave de filtro para o seu jogo aparecer apenas nas buscas dele
		Steam.setLobbyData(lobby_id, "meu_jogo_unique_id", "Versao1")
			
		# Salva o ID do lobby e dados no Autoload (GerenciadorSteam)
		GerenciadorSteam.lobby_id_atual = lobby_id
		GerenciadorSteam.sou_host = true
		
		# Transição para a cena do Lobby
		get_tree().change_scene_to_file("res://Cenas/Menu/Lobby.tscn")
	else:
		print("Falha ao criar o lobby na Steam. Código: %s" % result)
		erro_criacao.emit("Erro ao criar a sala nos servidores da Steam.")
