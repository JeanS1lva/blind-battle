extends Node

var lobby_id_atual: int = 0
var sou_host: bool = false
var steam_inicializada: bool = false
var mensagem_aviso_menu: String = ""
var max_jogadores_atual: int = 4

# Variável global para guardar o nick da Steam do jogador local
var meu_nick_steam: String = "Player"

# Referência para o peer do multiplayer da Steam
var multiplayer_peer: SteamMultiplayerPeer = null

func inicializar_steam() -> bool:
	if steam_inicializada:
		return true
		
	var resposta = Steam.steamInitEx()
	if resposta["status"] > 0:
		print("Erro ao iniciar a Steam: %s" % resposta["verbal"])
		return false

	steam_inicializada = true
	
	# Salva o nickname assim que a Steam inicializa com sucesso!
	meu_nick_steam = Steam.getPersonaName()
	print("Steam inicializada com sucesso. Nick local: ", meu_nick_steam)
	
	return true

func _process(_delta: float) -> void:
	Steam.run_callbacks()

# ==============================================================================
# NOVAS MÉTODOS DE REDE P2P (STEAM MULTIPLAYER PEER)
# ==============================================================================

# Chamado pelo Host assim que o lobby é criado com sucesso na Steam
func iniciar_host_steam(_max_jogadores: int) -> bool:
	multiplayer_peer = SteamMultiplayerPeer.new()
	
	# Inicializa como servidor/host usando os lobbies da Steam
	var erro = multiplayer_peer.create_host(0) # 0 usa o canal padrão de lobby
	if erro != OK:
		print("Erro ao criar o SteamMultiplayerPeer como Host: %s" % erro)
		return false
		
	# Atribui o peer ao multiplayer do Godot
	get_tree().get_multiplayer().multiplayer_peer = multiplayer_peer
	sou_host = true
	print("SteamMultiplayerPeer iniciado como HOST com sucesso!")
	return true

# Chamado pelo Cliente assim que ele entra em um lobby existente
func iniciar_cliente_steam(lobby_id: int) -> bool:
	multiplayer_peer = SteamMultiplayerPeer.new()
	
	# Inicializa como cliente conectando-se ao ID do Host dono do lobby
	# No GodotSteam, o host do lobby é obtido via Steam.getLobbyOwner(lobby_id)
	var steam_id_host = Steam.getLobbyOwner(lobby_id)
	
	var erro = multiplayer_peer.create_client(steam_id_host, 0)
	if erro != OK:
		print("Erro ao criar o SteamMultiplayerPeer como Cliente: %s" % erro)
		return false
		
	# Atribui o peer ao multiplayer do Godot
	get_tree().get_multiplayer().multiplayer_peer = multiplayer_peer
	sou_host = false
	print("SteamMultiplayerPeer iniciado como CLIENTE conectado ao Host: %s" % steam_id_host)
	return true

# Desconectar / Fechar sessão
func fechar_conexao() -> void:
	if multiplayer_peer:
		multiplayer_peer.close()
		get_tree().get_multiplayer().multiplayer_peer = null
		multiplayer_peer = null
	if lobby_id_atual > 0:
		Steam.leaveLobby(lobby_id_atual)
		lobby_id_atual = 0
	sou_host = false
