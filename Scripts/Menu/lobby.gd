extends Control

@onready var status_lobby: Label = $"Interface/StatusLobby"

@onready var jogadores: Array = [
	$"Interface/Jogador1",
	$"Interface/Jogador2",
	$"Interface/Jogador3",
	$"Interface/Jogador4"
]

@onready var botao_voltar: Button = $"Botões/Voltar"
@onready var botao_pronto: Button = $"Botões/BotaoPronto"
@onready var gerenciador_lobby: Node = $"GerenciadorLobby"

var lobby_id_atual: int = 0

func _ready() -> void:
	botao_voltar.pressed.connect(_ao_clicar_voltar)
	botao_pronto.pressed.connect(_ao_clicar_pronto)
	
	if "lobby_id_atual" in GerenciadorSteam:
		lobby_id_atual = GerenciadorSteam.lobby_id_atual
	
	# Conecta a atualização reativa de membros vinda do GerenciadorLobby
	if gerenciador_lobby:
		gerenciador_lobby.lista_membros_atualizada.connect(atualizar_lista_jogadores_ui)
		
		# GARANTIA PARA O CLIENTE: Força a leitura inicial dos membros assim que a UI estiver pronta
		gerenciador_lobby.atualizar_e_notificar_membros()
	
	inicializar_interface_lobby()

func inicializar_interface_lobby() -> void:
	if lobby_id_atual == 0:
		status_lobby.text = "Erro: ID do lobby inválido."
		return
		
	var nome_sala: String = Steam.getLobbyData(lobby_id_atual, "name")
	var max_jogadores: int = Steam.getLobbyMemberLimit(lobby_id_atual)
	
	status_lobby.text = "Sala: %s (Máx: %d)" % [nome_sala, max_jogadores]

# Função visual que recebe a lista de jogadores conectados e atualiza os slots na tela
func atualizar_lista_jogadores_ui(membros: Array) -> void:
	var max_jogadores: int = Steam.getLobbyMemberLimit(lobby_id_atual)
	
	for i in range(jogadores.size()):
		var slot_nodo = jogadores[i]
		
		if i < max_jogadores:
			slot_nodo.visible = true # Exibe slot se estiver dentro da capacidade
			
			if i < membros.size():
				# Jogador conectado real
				var info_membro = membros[i]
				var nome_membro: String = info_membro["nome"]
				var esta_pronto: bool = info_membro["pronto"]
				
				_atualizar_estado_jogador(i, true, esta_pronto, nome_membro)
			else:
				# Vaga aberta no lobby
				_atualizar_estado_jogador(i, false, false, "Aguardando...")
		else:
			# Oculta slots acima do limite da sala
			slot_nodo.visible = false

func _atualizar_estado_jogador(indice: int, conectado: bool, pronto: bool, nome_jogador: String) -> void:
	var nodo_jogador = jogadores[indice]
	
	var lbl_aguardando: Label = nodo_jogador.get_node("Aguardando")
	var lbl_nome: Label = nodo_jogador.get_node("LabelJ%d" % (indice + 1))
	var lbl_conectando: Label = nodo_jogador.get_node("Conectando")
	var spr_pronto2: Sprite2D = nodo_jogador.get_node("Pronto2")
	var spr_conectado: Sprite2D = nodo_jogador.get_node("Conectado")
	
	if lbl_nome:
		lbl_nome.text = nome_jogador
		
	if lbl_aguardando:
		lbl_aguardando.visible = true
	
	# Controle visual do Sprite 'Conectado' vs Label 'Conectando'
	if conectado:
		if spr_conectado: spr_conectado.visible = true
		if lbl_conectando: lbl_conectando.visible = false
	else:
		if spr_conectado: spr_conectado.visible = false
		if lbl_conectando: lbl_conectando.visible = true
		
	# Controle do Sprite de Pronto
	if spr_pronto2:
		spr_pronto2.visible = pronto

func _ao_clicar_pronto() -> void:
	if gerenciador_lobby:
		gerenciador_lobby.alternar_meu_status_pronto()

func _ao_clicar_voltar() -> void:
	if gerenciador_lobby:
		gerenciador_lobby.sair_ou_deletar_lobby()
		
	get_tree().change_scene_to_file("res://Cenas/Menu/MenuMultiplayer.tscn")
