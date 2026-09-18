extends Control


const MAX_JOGADORES := 4


var jogadores_conectados: Array[int] = []
var jogadores_prontos: Dictionary = {}
var numero_jogador_por_id: Dictionary = {}

var sou_host := false
var estou_pronto := false


@onready var botao_pronto = $BotaoPronto
@onready var status_lobby = $StatusLobby
@onready var voltar = $voltar


@onready var jogadores = [
	$Jogador1,
	$Jogador2,
	$Jogador3,
	$Jogador4
]


func _ready():

	# =====================================================
	# CONEXÕES DOS BOTÕES
	# =====================================================

	botao_pronto.pressed.connect(alternar_pronto)
	voltar.pressed.connect(sair_da_partida)


	# =====================================================
	# VERIFICA SE É O HOST
	# =====================================================

	sou_host = multiplayer.is_server()


	# =====================================================
	# CONECTA OS SINAIS DO MULTIPLAYER
	# =====================================================

	if not multiplayer.peer_connected.is_connected(jogador_conectou):
		multiplayer.peer_connected.connect(jogador_conectou)

	if not multiplayer.peer_disconnected.is_connected(jogador_desconectou):
		multiplayer.peer_disconnected.connect(jogador_desconectou)


	# =====================================================
	# ADICIONA O PRÓPRIO JOGADOR
	# =====================================================

	if multiplayer.multiplayer_peer != null:

		var meu_id = multiplayer.get_unique_id()

		if meu_id not in jogadores_conectados:
			jogadores_conectados.append(meu_id)

		# O Host é sempre o Jogador 1
		if sou_host:
			numero_jogador_por_id[meu_id] = 1


	# =====================================================
	# ATUALIZA A TELA
	# =====================================================

	atualizar_lobby()


	# =====================================================
	# SE FOR CLIENTE, PEDE A LISTA AO HOST
	# =====================================================

	if not sou_host:

		pedir_lista_jogadores.rpc_id(1)


# =========================================================
# JOGADOR CONECTOU
# =========================================================

func jogador_conectou(id: int):

	print("Jogador entrou no lobby: ", id)

	if id not in jogadores_conectados:
		jogadores_conectados.append(id)


	# =====================================================
	# HOST DEFINE O NÚMERO DO JOGADOR
	# =====================================================

	if multiplayer.is_server():

		var numero := 1

		while numero_jogador_por_id.values().has(numero):
			numero += 1

		numero_jogador_por_id[id] = numero

		print(
			"ID ",
			id,
			" recebeu o número de JOGADOR ",
			numero
		)


	# =====================================================
	# ATUALIZA A TELA
	# =====================================================

	atualizar_lobby()


	# =====================================================
	# HOST ENVIA AS INFORMAÇÕES AO NOVO JOGADOR
	# =====================================================

	if multiplayer.is_server():

		sincronizar_lista_jogadores.rpc_id(
			id,
			jogadores_conectados
		)

		sincronizar_configuracao.rpc_id(
			id,
			DadosJogo.max_jogadores
		)

		sincronizar_numeros_jogadores.rpc_id(
			id,
			numero_jogador_por_id
		)


# =========================================================
# SINCRONIZA NÚMEROS DOS JOGADORES
# =========================================================

@rpc("authority", "call_local", "reliable")
func sincronizar_numeros_jogadores(mapa: Dictionary):

	numero_jogador_por_id.clear()

	for id in mapa:

		numero_jogador_por_id[int(id)] = int(mapa[id])


	# =====================================================
	# DESCOBRE O NÚMERO DESTA MÁQUINA
	# =====================================================

	var meu_id = multiplayer.get_unique_id()

	if numero_jogador_por_id.has(meu_id):

		DadosJogo.numero_jogador = numero_jogador_por_id[meu_id]


	atualizar_lobby()


# =========================================================
# JOGADOR DESCONECTOU
# =========================================================

func jogador_desconectou(id: int):

	print("Jogador saiu do lobby: ", id)

	jogadores_conectados.erase(id)
	jogadores_prontos.erase(id)
	numero_jogador_por_id.erase(id)


	atualizar_lobby()


	# =====================================================
	# HOST AVISA TODOS SOBRE A NOVA LISTA
	# =====================================================

	if sou_host:

		sincronizar_lista_jogadores.rpc(
			jogadores_conectados
		)

		sincronizar_numeros_jogadores.rpc(
			numero_jogador_por_id
		)


# =========================================================
# CLIENTE PEDE A LISTA AO HOST
# =========================================================

@rpc("any_peer", "reliable")
func pedir_lista_jogadores():

	if not multiplayer.is_server():
		return


	var id_quem_pediu = multiplayer.get_remote_sender_id()


	sincronizar_lista_jogadores.rpc_id(
		id_quem_pediu,
		jogadores_conectados
	)


	sincronizar_configuracao.rpc_id(
		id_quem_pediu,
		DadosJogo.max_jogadores
	)


	sincronizar_numeros_jogadores.rpc_id(
		id_quem_pediu,
		numero_jogador_por_id
	)


# =========================================================
# SINCRONIZA A LISTA DE JOGADORES
# =========================================================

@rpc("authority", "call_local", "reliable")
func sincronizar_lista_jogadores(lista: Array):

	jogadores_conectados.clear()

	for id in lista:

		jogadores_conectados.append(int(id))


	print("Lista sincronizada: ", jogadores_conectados)


	atualizar_lobby()


# =========================================================
# SINCRONIZA CONFIGURAÇÃO DO LOBBY
# =========================================================

@rpc("authority", "call_local", "reliable")
func sincronizar_configuracao(max_jogadores: int):

	DadosJogo.max_jogadores = max_jogadores

	atualizar_lobby()


# =========================================================
# ATUALIZA TODO O LOBBY
# =========================================================

func atualizar_lobby():

	# -----------------------------------------------------
	# MOSTRA OS 4 SLOTS
	# -----------------------------------------------------

	for i in range(MAX_JOGADORES):

		var jogador = jogadores[i]

		jogador.visible = true


	# -----------------------------------------------------
	# ATUALIZA OS JOGADORES
	# -----------------------------------------------------

	for i in range(MAX_JOGADORES):

		if i < jogadores_conectados.size():

			var id = jogadores_conectados[i]

			mostrar_jogador(
				i,
				id
			)

		else:

			mostrar_slot_vazio(i)


	# -----------------------------------------------------
	# STATUS DO LOBBY
	# -----------------------------------------------------

	status_lobby.text = (
		"VOCÊ É O JOGADOR "
		+ str(DadosJogo.numero_jogador)
		+ "\n"
		+ "JOGADORES: "
		+ str(jogadores_conectados.size())
		+ "/"
		+ str(DadosJogo.max_jogadores)
	)


	# -----------------------------------------------------
	# BOTÃO PRONTO
	# -----------------------------------------------------

	if jogadores_conectados.size() >= 2:

		botao_pronto.disabled = false

	else:

		botao_pronto.disabled = true


	# -----------------------------------------------------
	# TEXTO DO BOTÃO
	# -----------------------------------------------------

	if estou_pronto:

		botao_pronto.text = "PRONTO ✓"

	else:

		botao_pronto.text = "PRONTO"


# =========================================================
# MOSTRA JOGADOR
# =========================================================

func mostrar_jogador(indice: int, id: int):

	var jogador = jogadores[indice]


	# -----------------------------------------------------
	# NOME
	# -----------------------------------------------------

	var label_nome = jogador.get_node_or_null(
		"labelJ" + str(indice + 1)
	)


	if label_nome != null:

		if id == 1:

			label_nome.text = "HOST"

		else:

			label_nome.text = "Jogador " + str(indice + 1)


	# -----------------------------------------------------
	# CONECTANDO
	# -----------------------------------------------------

	var conectando = jogador.get_node_or_null(
		"conectando"
	+ ("" if indice == 0 else str(indice + 1))
	)


	if conectando != null:

		conectando.visible = false


	# -----------------------------------------------------
	# CONECTADO
	# -----------------------------------------------------

	var conectado = jogador.get_node_or_null(
		"conectado"
	+ ("" if indice == 0 else str(indice + 1))
	)


	if conectado != null:

		conectado.visible = true


	# -----------------------------------------------------
	# PRONTO
	# -----------------------------------------------------

	var pronto = jogador.get_node_or_null(
		"pronto"
	+ ("" if indice == 0 else str(indice + 1))
	)


	if pronto != null:

		pronto.visible = jogadores_prontos.get(
			id,
			false
		)


	# -----------------------------------------------------
	# BOTÃO/INDICADOR PRONTO
	# -----------------------------------------------------

	var botao_individual = jogador.get_node_or_null(
		"Pronto"
	+ ("" if indice == 0 else str(indice + 1))
	)


	if botao_individual != null:

		botao_individual.visible = true


# =========================================================
# MOSTRA SLOT VAZIO
# =========================================================

func mostrar_slot_vazio(indice: int):

	var jogador = jogadores[indice]


	# -----------------------------------------------------
	# NOME
	# -----------------------------------------------------

	var label_nome = jogador.get_node_or_null(
		"labelJ" + str(indice + 1)
	)


	if label_nome != null:

		label_nome.text = ""


	# -----------------------------------------------------
	# CONECTANDO
	# -----------------------------------------------------

	var conectando = jogador.get_node_or_null(
		"conectando"
	+ ("" if indice == 0 else str(indice + 1))
	)


	if conectando != null:

		conectando.visible = true


	# -----------------------------------------------------
	# CONECTADO
	# -----------------------------------------------------

	var conectado = jogador.get_node_or_null(
		"conectado"
	+ ("" if indice == 0 else str(indice + 1))
	)


	if conectado != null:

		conectado.visible = false


	# -----------------------------------------------------
	# PRONTO
	# -----------------------------------------------------

	var pronto = jogador.get_node_or_null(
		"pronto"
	+ ("" if indice == 0 else str(indice + 1))
	)


	if pronto != null:

		pronto.visible = false


# =========================================================
# BOTÃO PRONTO
# =========================================================

func alternar_pronto():

	if jogadores_conectados.size() < 2:

		return


	estou_pronto = not estou_pronto

	var meu_id = multiplayer.get_unique_id()

	jogadores_prontos[meu_id] = estou_pronto


	sincronizar_pronto.rpc(
		meu_id,
		estou_pronto
	)


	atualizar_lobby()


# =========================================================
# SINCRONIZAR PRONTO
# =========================================================

@rpc("any_peer", "call_local", "reliable")
func sincronizar_pronto(id: int, estado: bool):

	jogadores_prontos[id] = estado

	atualizar_lobby()


	# =====================================================
	# SOMENTE O HOST VERIFICA
	# =====================================================

	if multiplayer.is_server():

		for jogador_id in jogadores_conectados:

			if not jogadores_prontos.get(
				jogador_id,
				false
			):

				return


		# =================================================
		# TODOS ESTÃO PRONTOS
		# =================================================

		iniciar_partida.rpc()


# =========================================================
# INICIAR PARTIDA
# =========================================================

@rpc("authority", "call_local", "reliable")
func iniciar_partida():

	# =====================================================
	# GARANTE QUE CADA MÁQUINA TENHA SEU NÚMERO
	# =====================================================

	var meu_id = multiplayer.get_unique_id()

	if numero_jogador_por_id.has(meu_id):

		DadosJogo.numero_jogador = numero_jogador_por_id[meu_id]


	print("================================")
	print("INICIANDO SELEÇÃO DE PERSONAGEM")
	print("JOGADOR: ", DadosJogo.numero_jogador)
	print("================================")


	get_tree().change_scene_to_file(
		"res://Cenas/SelecaoPersonagem.tscn"
	)


# =========================================================
# SAIR DA PARTIDA
# =========================================================

func sair_da_partida():

	if multiplayer.multiplayer_peer != null:

		multiplayer.multiplayer_peer.close()

		multiplayer.multiplayer_peer = null


	get_tree().change_scene_to_file(
		"res://Cenas/Multiplayer.tscn"
	)
