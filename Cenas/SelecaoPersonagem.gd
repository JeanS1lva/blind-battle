extends Control


# =========================================================
# SELEÇÃO LOCAL
# =========================================================

var personagem_selecionado := 0

var personagem_escolhido := ""
var escolha_enviada := false
var aguardando_jogadores := false


# =========================================================
# PERSONAGENS RECEBIDOS PELO HOST
# =========================================================

var personagens_recebidos: Dictionary = {}


# =========================================================
# NÓS
# =========================================================

@onready var personagens = [
	$guerreiro,
	$mago,
	$assassino,
	$arqueiro
]

@onready var escolhas = $Escolhas


# =========================================================
# READY
# =========================================================

func _ready():

	atualizar_selecao()

	escolhas.text = ""

	print("==============================")
	print("SELEÇÃO DE PERSONAGEM")
	print("==============================")
	print("Meu ID: ", multiplayer.get_unique_id())


# =========================================================
# PROCESS
# =========================================================

func _process(_delta):

	# -----------------------------------------------------
	# Se já escolheu, não permite mais alterar a seleção
	# -----------------------------------------------------

	if aguardando_jogadores:
		return


	processar_mouse()


	# -----------------------------------------------------
	# CLIQUE DO MOUSE
	# -----------------------------------------------------

	if Input.is_mouse_button_pressed(
		MOUSE_BUTTON_LEFT
	):

		selecionar_por_clique()


	# -----------------------------------------------------
	# SETA DIREITA
	# -----------------------------------------------------

	if Input.is_action_just_pressed("ui_right"):

		personagem_selecionado += 1

		if personagem_selecionado >= personagens.size():

			personagem_selecionado = 0

		atualizar_selecao()


	# -----------------------------------------------------
	# SETA ESQUERDA
	# -----------------------------------------------------

	if Input.is_action_just_pressed("ui_left"):

		personagem_selecionado -= 1

		if personagem_selecionado < 0:

			personagem_selecionado = personagens.size() - 1

		atualizar_selecao()


	# -----------------------------------------------------
	# ENTER
	# -----------------------------------------------------

	if Input.is_action_just_pressed("ui_accept"):

		confirmar_personagem()


# =========================================================
# MOUSE - PASSAR SOBRE PERSONAGEM
# =========================================================

func processar_mouse():

	var mouse = get_global_mouse_position()


	for i in range(personagens.size()):

		var personagem = personagens[i]


		if personagem.texture == null:

			continue


		var tamanho = (
			personagem.texture.get_size()
			* personagem.scale
		)


		var retangulo = Rect2(
			personagem.global_position - tamanho / 2.0,
			tamanho
		)


		if retangulo.has_point(mouse):

			if personagem_selecionado != i:

				personagem_selecionado = i

				atualizar_selecao()

			return


# =========================================================
# CLIQUE NO PERSONAGEM
# =========================================================

func selecionar_por_clique():

	var mouse = get_global_mouse_position()


	for i in range(personagens.size()):

		var personagem = personagens[i]


		if personagem.texture == null:

			continue


		var tamanho = (
			personagem.texture.get_size()
			* personagem.scale
		)


		var retangulo = Rect2(
			personagem.global_position - tamanho / 2.0,
			tamanho
		)


		if retangulo.has_point(mouse):

			personagem_selecionado = i

			atualizar_selecao()

			confirmar_personagem()

			return


# =========================================================
# ATUALIZAR DESTAQUE
# =========================================================

func atualizar_selecao():

	for i in range(personagens.size()):

		if i == personagem_selecionado:

			personagens[i].modulate = Color.WHITE

		else:

			personagens[i].modulate = Color(
				0.3,
				0.3,
				0.3,
				1
			)


# =========================================================
# NOME DO PERSONAGEM
# =========================================================

func nome_personagem(indice: int) -> String:

	match indice:

		0:
			return "GUERREIRO"

		1:
			return "MAGO"

		2:
			return "ASSASSINO"

		3:
			return "ARQUEIRO"

	return ""


# =========================================================
# CONFIRMAR PERSONAGEM
# =========================================================

func confirmar_personagem():

	# -----------------------------------------------------
	# Impede escolher novamente
	# -----------------------------------------------------

	if aguardando_jogadores:

		return


	# -----------------------------------------------------
	# Descobre personagem escolhido
	# -----------------------------------------------------

	match personagem_selecionado:

		0:
			personagem_escolhido = "guerreiro"

		1:
			personagem_escolhido = "mago"

		2:
			personagem_escolhido = "assassino"

		3:
			personagem_escolhido = "arqueiro"


	var meu_id = multiplayer.get_unique_id()


	print("==============================")
	print("PERSONAGEM ESCOLHIDO")
	print("==============================")
	print("ID: ", meu_id)
	print("Personagem: ", personagem_escolhido)


	# -----------------------------------------------------
	# MOSTRA NO LABEL
	# -----------------------------------------------------

	escolhas.text = (
		"PERSONAGEM: "
		+ nome_personagem(personagem_selecionado)
		+ "\n"
		+ "AGUARDANDO OUTROS JOGADORES..."
	)


	# -----------------------------------------------------
	# BLOQUEIA A SELEÇÃO LOCAL
	# -----------------------------------------------------

	aguardando_jogadores = true
	escolha_enviada = true


	# =====================================================
	# HOST
	# =====================================================

	if multiplayer.is_server():

		DadosJogo.personagem_jogador_1 = personagem_escolhido

		personagens_recebidos[1] = personagem_escolhido

		print("HOST registrou Jogador 1.")

		verificar_selecoes()

		return


	# =====================================================
	# CLIENTE
	# =====================================================

	print("Enviando personagem para o HOST...")

	enviar_personagem_ao_host.rpc_id(
		1,
		meu_id,
		personagem_escolhido
	)

	print("Aguardando o HOST sincronizar os personagens...")


# =========================================================
# CLIENTE ENVIA ESCOLHA AO HOST
# =========================================================

@rpc("any_peer", "reliable")
func enviar_personagem_ao_host(
	id: int,
	personagem: String
):

	if not multiplayer.is_server():

		return


	print("==============================")
	print("HOST RECEBEU PERSONAGEM")
	print("==============================")
	print("ID: ", id)
	print("Personagem: ", personagem)


	personagens_recebidos[id] = personagem


	# -----------------------------------------------------
	# Guarda no DadosJogo
	# -----------------------------------------------------

	if id != 1:

		DadosJogo.personagem_jogador_2 = personagem


	verificar_selecoes()


# =========================================================
# VERIFICAR SE TODOS ESCOLHERAM
# =========================================================

func verificar_selecoes():

	if not multiplayer.is_server():

		return


	var jogadores_conectados = (
		multiplayer.get_peers().size() + 1
	)


	print("==============================")
	print("VERIFICANDO SELEÇÕES")
	print("Jogadores conectados: ", jogadores_conectados)
	print("Personagens recebidos: ", personagens_recebidos)


	# -----------------------------------------------------
	# Ainda falta jogador
	# -----------------------------------------------------

	if personagens_recebidos.size() < jogadores_conectados:

		print("Aguardando jogadores escolherem...")

		return


	# -----------------------------------------------------
	# TODOS ESCOLHERAM
	# -----------------------------------------------------

	print("TODOS OS JOGADORES ESCOLHERAM!")


	sincronizar_personagens.rpc(
		personagens_recebidos
	)


# =========================================================
# SINCRONIZAR PERSONAGENS
# =========================================================

@rpc("authority", "call_local", "reliable")
func sincronizar_personagens(lista: Dictionary):

	print("==============================")
	print("PERSONAGENS SINCRONIZADOS")
	print("==============================")
	print(lista)


	# -----------------------------------------------------
	# Limpa dados anteriores
	# -----------------------------------------------------

	DadosJogo.personagem_jogador_1 = ""
	DadosJogo.personagem_jogador_2 = ""
	DadosJogo.personagem_jogador_3 = ""
	DadosJogo.personagem_jogador_4 = ""


	# -----------------------------------------------------
	# Jogador 1
	# -----------------------------------------------------

	if lista.has(1):

		DadosJogo.personagem_jogador_1 = lista[1]


	# -----------------------------------------------------
	# Ordena IDs
	# -----------------------------------------------------

	var ids = lista.keys()

	ids.sort()


	# -----------------------------------------------------
	# Jogador 2
	# -----------------------------------------------------

	if ids.size() > 1:

		var id_jogador_2 = ids[1]

		DadosJogo.personagem_jogador_2 = (
			lista[id_jogador_2]
		)


	# -----------------------------------------------------
	# Jogador 3
	# -----------------------------------------------------

	if ids.size() > 2:

		var id_jogador_3 = ids[2]

		DadosJogo.personagem_jogador_3 = (
			lista[id_jogador_3]
		)


	# -----------------------------------------------------
	# Jogador 4
	# -----------------------------------------------------

	if ids.size() > 3:

		var id_jogador_4 = ids[3]

		DadosJogo.personagem_jogador_4 = (
			lista[id_jogador_4]
		)


	print(
		"Jogador 1: ",
		DadosJogo.personagem_jogador_1
	)

	print(
		"Jogador 2: ",
		DadosJogo.personagem_jogador_2
	)

	print(
		"Jogador 3: ",
		DadosJogo.personagem_jogador_3
	)

	print(
		"Jogador 4: ",
		DadosJogo.personagem_jogador_4
	)


	# -----------------------------------------------------
	# TODOS VÃO PARA O TABULEIRO
	# -----------------------------------------------------

	get_tree().change_scene_to_file(
		"res://Cenas/tabuleiro.tscn"
	)


# =========================================================
# VOLTAR
# =========================================================

func voltar():

	get_tree().change_scene_to_file(
		"res://Cenas/MenuInicial.tscn"
	)
