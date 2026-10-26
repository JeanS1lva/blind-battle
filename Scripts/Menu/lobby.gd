extends Control

@onready var status_lobby: Label = $"Interface/StatusLobby"
@onready var gerenciador_lobby: Node = $"GerenciadorLobby"

@onready var jogadores_ui: Array = [
	$"Interface/Jogador1",
	$"Interface/Jogador2",
	$"Interface/Jogador3",
	$"Interface/Jogador4"
]

# Variável de controle local para a capacidade máxima de jogadores nesta sala
var max_jogadores_sala: int = 4

func _ready() -> void:
	# 1. Define o limite máximo da sala
	max_jogadores_sala = GerenciadorSteam.max_jogadores_atual
	
	# 2. Configura a visibilidade dos slots uma única vez no início
	_inicializar_visibilidade_slots_ocupaveis()
	
	# 3. Conecta o sinal para receber as alterações dinâmicas da rede/gerenciador
	if gerenciador_lobby:
		gerenciador_lobby.dados_atualizados.connect(_atualizar_interface_jogadores)

# Executado APENAS uma vez na inicialização da cena
func _inicializar_visibilidade_slots_ocupaveis() -> void:
	for i in range(jogadores_ui.size()):
		var slot = jogadores_ui[i]
		slot.visible = (i < max_jogadores_sala)

# Maestro dinâmico: distribui os dados conforme os jogadores entram/saem
func _atualizar_interface_jogadores(jogadores: Dictionary) -> void:
	print("DEBUG [LobbyUI]: Sinal 'dados_atualizados' RECEBIDO! Dicionário recebido: ", jogadores)
	var indices = jogadores.keys()
	print("DEBUG [LobbyUI]: Chaves (IDs) no dicionário: ", indices, " | Tamanho: ", indices.size())
	print("DEBUG [LobbyUI]: max_jogadores_sala atual: ", max_jogadores_sala)
	
	for i in range(max_jogadores_sala):
		var slot = jogadores_ui[i]
		print("DEBUG [LobbyUI]: Analisando slot índice ", i, " -> Caminho/Nome do slot: ", slot.name)
		
		if i < indices.size():
			var id_jogador = indices[i]
			var dados = jogadores[id_jogador]
			print("DEBUG [LobbyUI]: -> Slot ", i, " OCUPADO por ID ", id_jogador, " (Nome: ", dados["nome"], ")")
			_configurar_slot_ocupado(slot, dados["nome"], dados["pronto"])
		else:
			print("DEBUG [LobbyUI]: -> Slot ", i, " VAZIO.")
			_configurar_slot_vazio(slot)

# Configura visualmente um slot OCUPADO
func _configurar_slot_ocupado(slot: Node, nome_jogador: String, esta_pronto: bool) -> void:
	_definir_label(slot, "Nick", true, nome_jogador)
	_definir_label(slot, "StatusOnline", true, "online")
	_definir_sprite(slot, "IconeOnline", true)
	_definir_sprite(slot, "SpritePronto", esta_pronto)

# Configura visualmente um slot VAZIO / DISPONÍVEL
func _configurar_slot_vazio(slot: Node) -> void:
	_definir_label(slot, "Nick", false, "")
	_definir_label(slot, "StatusOnline", true, "conectando")
	_definir_sprite(slot, "IconeOnline", false)
	_definir_sprite(slot, "SpritePronto", false)

# ==============================================================================
# FUNÇÕES MODULARES ATÔMICAS (AUXILIARES)
# ==============================================================================

# Funções auxiliares com aviso caso o nó filho não exista
func _definir_label(slot: Node, nome_no: String, mostrar: bool, texto: String) -> void:
	var lbl: Label = slot.get_node_or_null(nome_no)
	if lbl == null:
		print("⚠️ AVISO DE DEBUG [LobbyUI]: Nó Label '", nome_no, "' NÃO FOI ENCONTRADO dentro de ", slot.name)
	else:
		print("-> Sucesso: Label '", nome_no, "' encontrado em ", slot.name, " | Texto configurado para: '", texto, "'")
	
	if lbl:
		lbl.text = texto
		lbl.visible = mostrar

func _definir_sprite(slot: Node, nome_no: String, mostrar: bool) -> void:
	var spr: Sprite2D = slot.get_node_or_null(nome_no)
	if spr == null:
		print("⚠️ AVISO DE DEBUG [LobbyUI]: Nó Sprite2D '", nome_no, "' NÃO FOI ENCONTRADO dentro de ", slot.name)
	
	if spr:
		spr.visible = mostrar

func _on_button_pressed() -> void:
	print("--- TESTE MANUAL DE CLIENTE ---")
	print("Meu ID local: ", multiplayer.get_unique_id())
	print("Sou server?: ", multiplayer.is_server())
	print("Meu nick: ", GerenciadorSteam.meu_nick_steam)
	
	# Tenta chamar o RPC manualmente para o Host
	if not GerenciadorSteam.sou_host:
		gerenciador_lobby.rpc_solicitar_entrada.rpc_id(1, multiplayer.get_unique_id(), GerenciadorSteam.meu_nick_steam)
