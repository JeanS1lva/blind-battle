extends Control

@onready var status_lobby: Label = $"Interface/StatusLobby"

# Array com as referências para os nós dos Jogadores (1 ao 4)
@onready var jogadores: Array = [
	$"Interface/Jogador1",
	$"Interface/Jogador2",
	$"Interface/Jogador3",
	$"Interface/Jogador4"
]

@onready var botao_voltar: Button = $"Botões/Voltar"
@onready var botao_pronto: Button = $"Botões/BotaoPronto"

var lobby_id_atual: int = 0

func _ready() -> void:
	botao_voltar.pressed.connect(_ao_clicar_voltar)
	botao_pronto.pressed.connect(_ao_clicar_pronto)
	
	if "lobby_id_atual" in GerenciadorSteam:
		lobby_id_atual = GerenciadorSteam.lobby_id_atual
	
	inicializar_interface_lobby()

func inicializar_interface_lobby() -> void:
	if lobby_id_atual == 0:
		status_lobby.text = "Erro: ID do lobby inválido."
		return
		
	var nome_sala: String = Steam.getLobbyData(lobby_id_atual, "name")
	var max_jogadores: int = Steam.getLobbyMemberLimit(lobby_id_atual)
	var meu_nome_steam: String = Steam.getPersonaName()
	
	status_lobby.text = "Sala: %s (Máx: %d)" % [nome_sala, max_jogadores]
	
	for i in range(jogadores.size()):
		var slot_jogador = jogadores[i]
		
		if i < max_jogadores:
			slot_jogador.visible = true
			
			if i == 0:
				_atualizar_estado_jogador(i, true, false, meu_nome_steam)
			else:
				_atualizar_estado_jogador(i, false, false, "Aguardando...")
		else:
			slot_jogador.visible = false

func _atualizar_estado_jogador(indice: int, conectado: bool, pronto: bool, nome_jogador: String) -> void:
	var nodo_jogador = jogadores[indice]
	
	# Ajustado para o novo nome: 'Aguardando' (fica sempre visível)
	var lbl_aguardando: Label = nodo_jogador.get_node("Aguardando")
	var lbl_nome: Label = nodo_jogador.get_node("LabelJ%d" % (indice + 1))
	var lbl_conectando: Label = nodo_jogador.get_node("Conectando")
	var spr_pronto2: Sprite2D = nodo_jogador.get_node("Pronto2")
	var spr_conectado: Sprite2D = nodo_jogador.get_node("Conectado")
	
	if lbl_nome:
		lbl_nome.text = nome_jogador
		
	if lbl_aguardando:
		lbl_aguardando.visible = true # Deixa o label Aguardando sempre visível
	
	# Controle dos estados de conexão
	if conectado:
		if spr_conectado: spr_conectado.visible = true
		if lbl_conectando: lbl_conectando.visible = false
	else:
		if spr_conectado: spr_conectado.visible = false
		if lbl_conectando: lbl_conectando.visible = true
		
	# Controle do estado de Pronto (mostra ou oculta o Pronto2)
	if pronto:
		if spr_pronto2: spr_pronto2.visible = true
	else:
		if spr_pronto2: spr_pronto2.visible = false

func _ao_clicar_pronto() -> void:
	# Lógica futura para o botão de pronto do próprio jogador
	pass

func _ao_clicar_voltar() -> void:
	get_tree().change_scene_to_file("res://Cenas/Menu/MenuMultiplayer.tscn")
