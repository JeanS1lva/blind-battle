extends Control

@onready var botao_pronto = $Botões/BotaoPronto
@onready var botao_voltar = $Botões/Voltar
@onready var status_lobby = $Interface/StatusLobby

# Array com os nós visuais dos jogadores na nova estrutura
@onready var jogadores = [
	$Interface/Jogador1,
	$Interface/Jogador2,
	$Interface/Jogador3,
	$Interface/Jogador4
]

func _ready():
	# Conecta os botões da interface
	botao_pronto.pressed.connect(_on_botao_pronto_pressed)
	botao_voltar.pressed.connect(_on_botao_voltar_pressed)

	# Conecta aos sinais emitidos pelo GerenciadorLobby
	GerenciadorLobby.lobby_atualizado.connect(atualizar_interface_visual)
	GerenciadorLobby.iniciar_partida_recebido.connect(_ir_para_selecao_personagem)
	GerenciadorLobby.voltar_menu_recebido.connect(_ir_para_menu_multiplayer)

	# Inicializa os dados e desenha a tela pela primeira vez
	GerenciadorLobby.inicializar_novo_lobby()
	atualizar_interface_visual()

func _on_botao_pronto_pressed():
	GerenciadorLobby.alternar_pronto()

func _on_botao_voltar_pressed():
	GerenciadorLobby.sair_do_lobby()

func _ir_para_selecao_personagem():
	get_tree().change_scene_to_file("res://Cenas/Menu/SelecaoPersonagem.tscn")

func _ir_para_menu_multiplayer():
	get_tree().change_scene_to_file("res://Cenas/Menu/MenuMultiplayer.tscn")

func atualizar_interface_visual():
	var max_jogadores = DadosJogo.max_jogadores
	var conectados = GerenciadorLobby.jogadores_conectados
	var prontos = GerenciadorLobby.jogadores_prontos

	# Atualiza cada slot de jogador dinamicamente
	for i in range(jogadores.size()):
		var slot = jogadores[i]
		
		# Se o jogador estiver conectado, mostra o slot e preenche os dados
		if i < conectados.size():
			slot.visible = true
			var id_jogador = conectados[i]
			_preencher_slot_ocupado(i, id_jogador, prontos.get(id_jogador, false))
		else:
			# Se não houver jogador conectado, deixa o slot totalmente invisível
			slot.visible = false

	# Atualiza o texto de status do lobby
	var meu_numero = DadosJogo.numero_jogador
	status_lobby.text = "VOCÊ É O JOGADOR %d\nJOGADORES: %d/%d" % [meu_numero, conectados.size(), max_jogadores]

	# Habilita o botão pronto apenas se houver pelo menos 2 jogadores
	if conectados.size() >= 2:
		botao_pronto.disabled = false
	else:
		botao_pronto.disabled = true

	# Altera o texto do botão pronto local
	if GerenciadorLobby.estou_pronto:
		botao_pronto.text = "PRONTO ✓"
	else:
		botao_pronto.text = "PRONTO"

func _preencher_slot_ocupado(indice: int, id_jogador: int, esta_pronto: bool):
	var slot = jogadores[indice]

	var label_nome = slot.get_node_or_null("labelJ" + str(indice + 1))
	var sp_conectando = slot.get_node_or_null("conectando")
	var sp_conectado = slot.get_node_or_null("conectado")
	var sp_pronto = slot.get_node_or_null("pronto")

	if label_nome:
		if id_jogador == multiplayer.get_unique_id() and multiplayer.is_server():
			label_nome.text = "HOST (Você)"
		elif multiplayer.is_server() and indice == 0:
			label_nome.text = "HOST"
		else:
			label_nome.text = "Jogador " + str(indice + 1)

	if sp_conectando: sp_conectando.visible = false
	if sp_conectado: sp_conectado.visible = true
	if sp_pronto: sp_pronto.visible = esta_pronto
