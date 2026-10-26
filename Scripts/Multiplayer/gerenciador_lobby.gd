extends Node

signal dados_atualizados(jogadores: Dictionary)

@onready var conexao_lobby: Node = $"ConexãoLobby"

var jogadores_sala: Dictionary = {}

func _ready() -> void:
	if conexao_lobby:
		conexao_lobby.jogador_conectado.connect(_ao_jogador_conectado)
		conexao_lobby.jogador_desconectado.connect(_ao_jogador_desconectado)
	
	await get_tree().process_frame
	
	if GerenciadorSteam.sou_host:
		_registrar_host_local()

# Quando qualquer peer se conecta na rede (Dispara tanto no Host quanto no Cliente)
# Quando qualquer peer se conecta na rede
func _ao_jogador_conectado(id: int) -> void:
	print("--------------------------------------------------")
	print("SINAL CONECTADO DISPARADO! ID do peer: ", id)
	print("Meu ID único local: ", multiplayer.get_unique_id())
	print("Sou Host?: ", multiplayer.is_server())
	print("Conexões ativas no multiplayer: ", multiplayer.get_peers())
	print("--------------------------------------------------")
	
	# Se EU sou o cliente recém-conectado, chamamos a solicitação ao Host (ID 1)
	if not GerenciadorSteam.sou_host and id == 1:
		var meu_id = multiplayer.get_unique_id()
		var nick = GerenciadorSteam.meu_nick_steam
		print("DEBUG [Cliente]: Disparando rpc_solicitar_entrada para o Host (ID 1)...")
		rpc_solicitar_entrada.rpc_id(1, meu_id, nick)
	

func _ao_jogador_desconectado(id: int) -> void:
	print("GerenciadorLobby: Jogador desconectado, ID: ", id)
	if multiplayer.is_server():
		rpc_remover_jogador.rpc(id)

# ==============================================================================
# MÉTODOS RPC (Sincronização de Rede)
# ==============================================================================

# Executado APENAS no Host quando um cliente bate à porta
# Função modificada para aceitar a chamada do cliente no Host
@rpc("any_peer", "call_local", "reliable")
func rpc_solicitar_entrada(id: int, nome: String) -> void:
	print("🔥 [RPC RECEBIDO NO HOST!] ID: ", id, " | Nome: ", nome)
	print("Sou servidor neste momento?: ", multiplayer.is_server())
	
	if not multiplayer.is_server():
		return
		
	# Adiciona o cliente na lista do host
	jogadores_sala[id] = {
		"nome": nome,
		"pronto": false
	}
	
	# Propaga a sala inteira atualizada para todos
	propagar_sala_inteira.rpc(jogadores_sala)
	
# Sincroniza o dicionário em todos os computadores da sala
@rpc("authority", "call_local", "reliable")
func propagar_sala_inteira(nova_lista: Dictionary) -> void:
	jogadores_sala = nova_lista
	print("DEBUG [GerenciadorLobby]: Sala propagada recebida. Total de players: ", jogadores_sala.size())
	dados_atualizados.emit(jogadores_sala)

@rpc("any_peer", "call_local", "reliable")
func rpc_remover_jogador(id: int) -> void:
	if jogadores_sala.has(id):
		jogadores_sala.erase(id)
		if multiplayer.is_server():
			propagar_sala_inteira.rpc(jogadores_sala)
		else:
			dados_atualizados.emit(jogadores_sala)

func _registrar_host_local() -> void:
	var id_local = multiplayer.get_unique_id()
	var nick = GerenciadorSteam.meu_nick_steam
	
	jogadores_sala[id_local] = {
		"nome": nick,
		"pronto": false
	}
	dados_atualizados.emit(jogadores_sala)
