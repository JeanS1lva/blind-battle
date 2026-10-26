extends Node

signal erro_criacao(mensagem: String)

# Variáveis temporárias para guardar os dados enquanto a Steam processa a criação
var _nome_temp: String = ""
var _senha_temp: String = ""
var _tipo_temp: int = 0
var _max_jogadores_temp: int = 4

func _ready() -> void:
	Steam.lobby_created.connect(_ao_receber_resposta_lobby)

func tentar_criar_lobby(nome: String, senha: String, tipo_idx: int, max_jogadores: int) -> void:
	if nome.strip_edges() == "":
		erro_criacao.emit("O nome da sala não pode estar vazio!")
		return
	
	_nome_temp = nome
	_senha_temp = senha
	_tipo_temp = tipo_idx
	
	# Salva a quantidade máxima de jogadores no Autoload
	GerenciadorSteam.max_jogadores_atual = max_jogadores
	
	var steam_lobby_type = Steam.LOBBY_TYPE_PUBLIC
	if tipo_idx == 1:
		steam_lobby_type = Steam.LOBBY_TYPE_PRIVATE
		
	print("Solicitando criação do lobby na Steam para %d jogadores..." % max_jogadores)
	Steam.createLobby(steam_lobby_type, max_jogadores)	

func _ao_receber_resposta_lobby(result: int, lobby_id: int) -> void:
	if result == 1:
		print("Lobby criado com sucesso! ID do Lobby: %s" % lobby_id)
		
		# Define os metadados do Lobby na Steam
		Steam.setLobbyData(lobby_id, "name", _nome_temp)
		Steam.setLobbyData(lobby_id, "requires_password", "true" if _senha_temp != "" else "false")
		if _senha_temp != "":
			Steam.setLobbyData(lobby_id, "password", _senha_temp)
			
		Steam.setLobbyData(lobby_id, "meu_jogo_unique_id", "Versao1")
			
		# Salva o ID do lobby e dados no Autoload (GerenciadorSteam)
		GerenciadorSteam.lobby_id_atual = lobby_id
		
		# --- INICIALIZA A REDE P2P COMO HOST ---
		var sucesso_rede = GerenciadorSteam.iniciar_host_steam(_max_jogadores_temp)
		
		if not sucesso_rede:
			erro_criacao.emit("Falha ao iniciar a camada de rede P2P da Steam.")
			return
		
		# Transição para a cena do Lobby
		get_tree().change_scene_to_file("res://Cenas/Menu/Lobby.tscn")
	else:
		print("Falha ao criar o lobby na Steam. Código: %s" % result)
		erro_criacao.emit("Erro ao criar a sala nos servidores da Steam.")
