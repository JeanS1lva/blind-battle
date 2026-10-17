extends Node2D

# =========================================================
# CONFIGURAÇÕES DO TABULEIRO
# =========================================================

@export var linhas: int = 10
@export var colunas: int = 10
@export var tamanho_casa: Vector2 = Vector2(50, 50)

@onready var point_caminho = get_node("PointCaminho")

# =========================================================
# JOGADORES
# =========================================================

var jogador1: Node2D
var jogador2: Node2D
var jogador3: Node2D
var jogador4: Node2D

var personagem1: Personagem
var personagem2: Personagem
var personagem3: Personagem
var personagem4: Personagem

# =========================================================
# JOGADOR LOCAL
# =========================================================

var meu_id: int = 0
var meu_jogador: int = 0

var jogador_local: Node2D
var personagem_local: Personagem

var jogador_local_linha: int = 0
var jogador_local_coluna: int = 0

# =========================================================
# TURNOS
# =========================================================

var turno_atual: int = 1

var movimentos_usados: int = 0
var ataque_usado: bool = false
var item_usado: bool = false

# =========================================================
# CONTROLE DO ATAQUE VISUAL
# =========================================================

var ataque_confirmado_visual: bool = false

# =========================================================
# POSIÇÕES DOS JOGADORES
# =========================================================

var jogador1_linha: int = 0
var jogador1_coluna: int = 0

var jogador2_linha: int = 9
var jogador2_coluna: int = 9

var jogador3_linha: int = 0
var jogador3_coluna: int = 9

var jogador4_linha: int = 9
var jogador4_coluna: int = 0

# =========================================================
# CENAS DOS PERSONAGENS
# =========================================================

var cenas_personagens = {
	"mago": preload("res://Personagens/Mago.tscn"),
	"guerreiro": preload("res://Personagens/Guerreiro.tscn"),
	"assassino": preload("res://Personagens/Assassino.tscn"),
	"arqueiro": preload("res://Personagens/Arqueiro.tscn")
}

# =========================================================
# MOVIMENTO
# =========================================================

var sprites_caminho: Array[Sprite2D] = []
var caminho: Array[Vector2i] = []

var ultima_linha: int = -1
var ultima_coluna: int = -1

# =========================================================
# MODO ATAQUE
# =========================================================

var modo_ataque: bool = false
var botao_direito_pressionado := false

# =========================================================
# ATAQUE DO ASSASSINO
# =========================================================

var casas_ataque_assassino: Array[Vector2i] = []

# =========================================================
# X DE LIMITE
# =========================================================

var camada_x: Node2D

# =========================================================
# CASAS ESPECIAIS
# =========================================================

var quantidade_casas_especiais: int = 13

var sprites_itens: Dictionary = {}
var itens_escondidos: Dictionary = {}

var lista_itens: Array[String] = [
	"trofeu",
	"trofeu",
	"trofeu",
	"tinta",
	"espinho",
	"armadilha",
	"tropeco",
	"vida",
	"ataque_extra",
	"investida",
	"bomba"
]

var textura_fechada = preload(
	"res://imagens/itens/casa_fechada.jpg"
)

var texturas_itens = {
	"trofeu":
		preload("res://imagens/itens/trofeu.png"),

	"tinta":
		preload("res://imagens/itens/tinta.png"),

	"espinho":
		preload("res://imagens/itens/espinho.png"),

	"armadilha":
		preload("res://imagens/itens/armadilha.png"),

	"tropeco":
		preload("res://imagens/itens/tropeco.png"),

	"vida":
		preload("res://imagens/itens/vida.png"),

	"ataque_extra":
		preload("res://imagens/itens/ataque_extra.png"),

	"investida":
		preload("res://imagens/itens/investida.png"),

	"bomba":
		preload("res://imagens/itens/bomba.png")
}

# =========================================================
# READY
# =========================================================

func _ready():

	point_caminho.visible = false

	var botao_pular = get_parent().get_node("BotaoPular")
	botao_pular.pressed.connect(pular_turno)

	camada_x = Node2D.new()
	camada_x.z_index = 7
	add_child(camada_x)

	criar_casas_especiais()

	queue_redraw()

# =========================================================
# CONFIGURAR JOGADOR LOCAL
# =========================================================

func configurar_jogador_local(numero_jogador: int):

	meu_jogador = numero_jogador

	if has_node("log"):
		$log.text = "JOGADOR LOCAL: " + str(meu_jogador)

	if multiplayer.multiplayer_peer == null:
		print("ERRO: multiplayer não está conectado.")
		return

	meu_id = multiplayer.get_unique_id()

	match meu_jogador:

		1:
			jogador_local = jogador1
			personagem_local = personagem1

			jogador_local_linha = jogador1_linha
			jogador_local_coluna = jogador1_coluna

		2:
			jogador_local = jogador2
			personagem_local = personagem2

			jogador_local_linha = jogador2_linha
			jogador_local_coluna = jogador2_coluna

		3:
			jogador_local = jogador3
			personagem_local = personagem3

			jogador_local_linha = jogador3_linha
			jogador_local_coluna = jogador3_coluna

		4:
			jogador_local = jogador4
			personagem_local = personagem4

			jogador_local_linha = jogador4_linha
			jogador_local_coluna = jogador4_coluna

		_:
			print(
				"ERRO: número de jogador inválido: ",
				meu_jogador
			)
			return

	print(
		"GRADE: jogador local é o JOGADOR ",
		meu_jogador
	)

	atualizar_log_turno()

# =========================================================
# CRIAR JOGADOR 1
# =========================================================

func criar_jogador_1():

	var escolha = DadosJogo.personagem_jogador_1

	if not cenas_personagens.has(escolha):
		print(
			"ERRO: personagem inválido: ",
			escolha
		)
		return

	jogador1 = cenas_personagens[
		escolha
	].instantiate()

	add_child(jogador1)

	jogador1.z_index = 10

	jogador1.position = centro_da_casa(
		jogador1_linha,
		jogador1_coluna
	)

	personagem1 = encontrar_personagem(
		jogador1
	)

# =========================================================
# ENCONTRAR PERSONAGEM
# =========================================================

func encontrar_personagem(no: Node) -> Personagem:

	if no is Personagem:
		return no

	for filho in no.get_children():

		var resultado = encontrar_personagem(
			filho
		)

		if resultado != null:
			return resultado

	return null

# =========================================================
# DESENHAR TABULEIRO
# =========================================================

func _draw():

	for linha in range(linhas):

		for coluna in range(colunas):

			var posicao = Vector2(
				coluna * tamanho_casa.x,
				linha * tamanho_casa.y
			)

			draw_rect(
				Rect2(
					posicao,
					tamanho_casa
				),
				Color(1, 1, 1, 0.2),
				false,
				2
			)

# =========================================================
# CENTRO DA CASA
# =========================================================

func centro_da_casa(
	linha: int,
	coluna: int
) -> Vector2:

	return Vector2(
		coluna * tamanho_casa.x +
		tamanho_casa.x / 2,

		linha * tamanho_casa.y +
		tamanho_casa.y / 2
	)

# =========================================================
# POSIÇÃO DO JOGADOR LOCAL
# =========================================================

func atualizar_posicao_local(
	linha: int,
	coluna: int
):

	jogador_local_linha = linha
	jogador_local_coluna = coluna

	match meu_jogador:

		1:
			jogador1_linha = linha
			jogador1_coluna = coluna

		2:
			jogador2_linha = linha
			jogador2_coluna = coluna

		3:
			jogador3_linha = linha
			jogador3_coluna = coluna

		4:
			jogador4_linha = linha
			jogador4_coluna = coluna

# =========================================================
# CRIAR CASAS ESPECIAIS
# =========================================================

func criar_casas_especiais():

	var casas_disponiveis: Array[Vector2i] = []

	for linha in range(linhas):

		for coluna in range(colunas):

			var casa = Vector2i(
				linha,
				coluna
			)

			if casa == Vector2i(
				jogador1_linha,
				jogador1_coluna
			):
				continue

			casas_disponiveis.append(casa)

	casas_disponiveis.shuffle()

	var casas_especiais = casas_disponiveis.slice(
		0,
		quantidade_casas_especiais
	)

	lista_itens.shuffle()

	for i in range(
		casas_especiais.size()
	):

		var casa: Vector2i = casas_especiais[i]

		var sprite = Sprite2D.new()

		sprite.z_index = 5
		sprite.texture = textura_fechada

		sprite.position = centro_da_casa(
			casa.x,
			casa.y
		)

		sprite.scale = Vector2(
			tamanho_casa.x /
			textura_fechada.get_width(),

			tamanho_casa.y /
			textura_fechada.get_height()
		)

		add_child(sprite)

		sprites_itens[casa] = sprite

		if i < lista_itens.size():

			itens_escondidos[casa] = lista_itens[i]

		else:

			itens_escondidos[casa] = "vazio"

	print(
		"Casas especiais criadas: ",
		casas_especiais
	)

# =========================================================
# REVELAR ITEM
# =========================================================

func revelar_item():

	if meu_jogador != turno_atual:
		print("Não é o seu turno.")
		return

	if item_usado:
		print("Você já abriu um item neste turno.")
		return

	var casa_atual = Vector2i(
		jogador_local_linha,
		jogador_local_coluna
	)

	if not itens_escondidos.has(casa_atual):

		print(
			"Esta não é uma casa especial."
		)

		return

	var sprite: Sprite2D = sprites_itens[
		casa_atual
	]

	if sprite == null:
		return

	if sprite.texture != textura_fechada:

		print(
			"Esta casa já foi revelada."
		)

		return

	var item: String = itens_escondidos[
		casa_atual
	]

	item_usado = true

	if item == "vazio":

		sprite.visible = false

		print(
			"A casa estava vazia!"
		)

		return

	sprite.texture = texturas_itens[
		item
	]

	sprite.scale = Vector2(
		tamanho_casa.x /
		sprite.texture.get_width(),

		tamanho_casa.y /
		sprite.texture.get_height()
	)

	print(
		"ITEM REVELADO: ",
		item
	)

# =========================================================
# ESCONDER ITEM DA CASA ANTERIOR
# =========================================================

func esconder_item_da_casa_anterior():

	var casa_atual = Vector2i(
		jogador_local_linha,
		jogador_local_coluna
	)

	if not itens_escondidos.has(
		casa_atual
	):
		return

	var sprite: Sprite2D = sprites_itens[
		casa_atual
	]

	if sprite == null:
		return

	if sprite.texture != textura_fechada:

		sprite.visible = false

# =========================================================
# PASSAR TURNO
# =========================================================

func pular_turno():

	if meu_jogador != turno_atual:
		print("Não é o seu turno.")
		return

	if multiplayer.is_server():

		avancar_turno()

	else:

		solicitar_pular_turno.rpc_id(
			1,
			meu_jogador
		)

# =========================================================
# SOLICITAR AO HOST
# =========================================================

@rpc("any_peer", "reliable")
func solicitar_pular_turno(numero_jogador: int):

	if not multiplayer.is_server():
		return

	if numero_jogador != turno_atual:
		return

	avancar_turno()

# =========================================================
# AVANÇAR TURNO
# =========================================================

func avancar_turno():

	var proximo_turno = turno_atual + 1

	if proximo_turno > DadosJogo.max_jogadores:
		proximo_turno = 1

	mudar_turno.rpc(proximo_turno)

# =========================================================
# SINCRONIZAR TURNO
# =========================================================

@rpc("authority", "call_local", "reliable")
func mudar_turno(novo_turno: int):

	turno_atual = novo_turno

	movimentos_usados = 0
	ataque_usado = false
	item_usado = false

	modo_ataque = false
	ataque_confirmado_visual = false

	casas_ataque_assassino.clear()

	if personagem_local != null:
		personagem_local.esconder_ataque()

	limpar_caminho()
	esconder_x()

	atualizar_log_turno()

	print(
		"================================"
	)

	print(
		"AGORA É O TURNO DO JOGADOR ",
		turno_atual
	)

	print(
		"================================"
	)

# =========================================================
# LOG DO TURNO
# =========================================================

func atualizar_log_turno():

	if not has_node("log"):
		return

	if meu_jogador == turno_atual:

		$log.text = (
			"SEU TURNO\n"
			+ "JOGADOR "
			+ str(turno_atual)
		)

	else:

		$log.text = (
			"JOGADOR "
			+ str(turno_atual)
			+ " - AGUARDE"
		)

# =========================================================
# PROCESS
# =========================================================

func _process(_delta):

	if jogador_local == null:
		return

	# =====================================================
	# BOTÃO DIREITO
	# =====================================================

	if Input.is_mouse_button_pressed(
		MOUSE_BUTTON_RIGHT
	):

		if not botao_direito_pressionado:

			botao_direito_pressionado = true

			girar_ataque()

	else:

		botao_direito_pressionado = false

	# =====================================================
	# MODO ATAQUE
	# =====================================================

	if modo_ataque:

		# Depois de confirmar o ataque,
		# não recria mais a mira.
		if ataque_confirmado_visual:
			return

		if personagem_local is Assassino:

			atualizar_mira_assassino()

			return

		atualizar_mira_ataque()

		return

	# =====================================================
	# MODO MOVIMENTO
	# =====================================================

	if meu_jogador != turno_atual:
		return

	var mouse = get_local_mouse_position()

	var coluna = int(
		mouse.x / tamanho_casa.x
	)

	var linha = int(
		mouse.y / tamanho_casa.y
	)

	if linha < 0 or linha >= linhas:

		limpar_caminho()
		esconder_x()

		ultima_linha = -1
		ultima_coluna = -1

		return

	if coluna < 0 or coluna >= colunas:

		limpar_caminho()
		esconder_x()

		ultima_linha = -1
		ultima_coluna = -1

		return

	if linha == ultima_linha and coluna == ultima_coluna:
		return

	ultima_linha = linha
	ultima_coluna = coluna

	atualizar_caminho(
		Vector2i(
			linha,
			coluna
		)
	)

# =========================================================
# ATUALIZAR CAMINHO
# =========================================================

func atualizar_caminho(
	destino: Vector2i
):

	limpar_caminho()
	esconder_x()

	caminho.clear()

	var atual = Vector2i(
		jogador_local_linha,
		jogador_local_coluna
	)

	var diferenca_linha = destino.x - atual.x
	var diferenca_coluna = destino.y - atual.y

	var distancia = max(
		abs(diferenca_linha),
		abs(diferenca_coluna)
	)

	var limite = personagem_local.movimento - movimentos_usados

	var passo_linha = 0

	if diferenca_linha > 0:
		passo_linha = 1

	elif diferenca_linha < 0:
		passo_linha = -1

	var passo_coluna = 0

	if diferenca_coluna > 0:
		passo_coluna = 1

	elif diferenca_coluna < 0:
		passo_coluna = -1

	var linha = atual.x
	var coluna = atual.y

	for passo in range(distancia):

		var falta_linha = abs(
			destino.x - linha
		)

		var falta_coluna = abs(
			destino.y - coluna
		)

		if falta_linha > 0 and falta_coluna > 0:

			linha += passo_linha
			coluna += passo_coluna

		elif falta_linha > 0:

			linha += passo_linha

		elif falta_coluna > 0:

			coluna += passo_coluna

		else:

			break

		var proxima = Vector2i(
			linha,
			coluna
		)

		if proxima.x < 0 or proxima.x >= linhas:
			break

		if proxima.y < 0 or proxima.y >= colunas:
			break

		caminho.append(proxima)

	for i in range(caminho.size()):

		var casa = caminho[i]

		if i < limite:

			criar_sprite_caminho(
				casa.x,
				casa.y
			)

		else:

			mostrar_x(
				casa.x,
				casa.y
			)

# =========================================================
# EXECUTAR ATAQUE
# =========================================================

func executar_ataque():

	if meu_jogador != turno_atual:
		return

	if ataque_usado:
		print("Você já atacou neste turno.")
		return

	if personagem_local == null:
		return

	if personagem_local.ataque_visual == null:
		return

	var desenho = personagem_local.ataque_visual.get_child(0)

	desenho.ataque_confirmado = true
	desenho.queue_redraw()

	ataque_confirmado_visual = true
	ataque_usado = true

	if personagem_local.som_ataque != null:

		var audio = AudioStreamPlayer.new()

		audio.stream = personagem_local.som_ataque

		add_child(audio)

		audio.play()

	print(
		"ATAQUE EXECUTADO PELO JOGADOR ",
		meu_jogador
	)

# =========================================================
# SPRITE DO CAMINHO
# =========================================================

func criar_sprite_caminho(
	linha: int,
	coluna: int
):

	if point_caminho.texture == null:
		return

	var sprite = Sprite2D.new()

	sprite.texture = point_caminho.texture
	sprite.scale = point_caminho.scale

	sprite.position = centro_da_casa(
		linha,
		coluna
	)

	sprite.z_index = 6

	add_child(sprite)

	sprites_caminho.append(
		sprite
	)

# =========================================================
# LIMPAR CAMINHO
# =========================================================

func limpar_caminho():

	for sprite in sprites_caminho:

		if is_instance_valid(sprite):
			sprite.queue_free()

	sprites_caminho.clear()

# =========================================================
# MOSTRAR X
# =========================================================

func mostrar_x(
	linha: int,
	coluna: int
):

	var x = XDesenho.new()

	x.position = centro_da_casa(
		linha,
		coluna
	)

	x.tamanho = min(
		tamanho_casa.x,
		tamanho_casa.y
	) * 0.30

	camada_x.add_child(x)

# =========================================================
# ESCONDER X
# =========================================================

func esconder_x():

	for filho in camada_x.get_children():

		filho.queue_free()

# =========================================================
# ALTERNAR MODO ATAQUE
# =========================================================

func alternar_modo_ataque():

	if meu_jogador != turno_atual:
		return

	if ataque_usado:
		print("Você já atacou neste turno.")
		return

	modo_ataque = !modo_ataque

	ataque_confirmado_visual = false

	limpar_caminho()
	esconder_x()

	if personagem_local != null:

		personagem_local.esconder_ataque()

	if not modo_ataque:

		casas_ataque_assassino.clear()

	if modo_ataque:

		print("MODO ATAQUE")

	else:

		print("MODO MOVIMENTO")

# =========================================================
# GIRAR ATAQUE
# =========================================================

func girar_ataque():

	if personagem_local == null:
		return

	if personagem_local is Assassino:

		casas_ataque_assassino.clear()

		personagem_local.esconder_ataque()

		modo_ataque = false
		ataque_confirmado_visual = false

		print(
			"Seleção do Assassino cancelada."
		)

		return

	if personagem_local is Mago:

		personagem_local.girar_ataque()

		atualizar_mira_ataque()

# =========================================================
# MIRA DE ATAQUE
# =========================================================

func atualizar_mira_ataque():

	if personagem_local == null:
		return

	var mouse = get_local_mouse_position()

	var coluna = int(
		mouse.x / tamanho_casa.x
	)

	var linha = int(
		mouse.y / tamanho_casa.y
	)

	if linha < 0 or linha >= linhas:

		personagem_local.esconder_ataque()

		return

	if coluna < 0 or coluna >= colunas:

		personagem_local.esconder_ataque()

		return

	var casa_mirada = Vector2i(
		linha,
		coluna
	)

	var casa_personagem = Vector2i(
		jogador_local_linha,
		jogador_local_coluna
	)

	var distancia = max(
		abs(
			linha - jogador_local_linha
		),
		abs(
			coluna - jogador_local_coluna
		)
	)

	if personagem_local is Mago:

		if distancia != 1:

			personagem_local.esconder_ataque()

			return

	if personagem_local is Guerreiro:

		if distancia != 1:

			personagem_local.esconder_ataque()

			return

	if personagem_local is Arqueiro:

		if distancia != 1:

			personagem_local.esconder_ataque()

			return

	var casas_ataque = personagem_local.calcular_ataque(
		casa_personagem,
		casa_mirada
	)

	var origem_ataque = to_global(
		centro_da_casa(
			jogador_local_linha,
			jogador_local_coluna
		)
	)

	personagem_local.mostrar_ataque_casas(
		casas_ataque,
		casa_personagem,
		tamanho_casa,
		origem_ataque
	)

# =========================================================
# MIRA DO ASSASSINO
# =========================================================

func atualizar_mira_assassino():

	if personagem_local == null:
		return

	var mouse = get_local_mouse_position()

	var coluna = int(
		mouse.x / tamanho_casa.x
	)

	var linha = int(
		mouse.y / tamanho_casa.y
	)

	if linha < 0 or linha >= linhas:

		personagem_local.esconder_ataque()

		return

	if coluna < 0 or coluna >= colunas:

		personagem_local.esconder_ataque()

		return

	var casa_mouse = Vector2i(
		linha,
		coluna
	)

	var casa_personagem = Vector2i(
		jogador_local_linha,
		jogador_local_coluna
	)

	var origem_ataque = to_global(
		centro_da_casa(
			jogador_local_linha,
			jogador_local_coluna
		)
	)

	var diferenca_linha = abs(
		casa_mouse.x - casa_personagem.x
	)

	var diferenca_coluna = abs(
		casa_mouse.y - casa_personagem.y
	)

	if diferenca_linha == 0 and diferenca_coluna == 0:

		personagem_local.esconder_ataque()

		return

	if diferenca_linha > 1 or diferenca_coluna > 1:

		personagem_local.esconder_ataque()

		return

	if casas_ataque_assassino.is_empty():

		var preview: Array[Vector2i] = []

		preview.append(
			casa_mouse
		)

		personagem_local.mostrar_ataque_casas(
			preview,
			casa_personagem,
			tamanho_casa,
			origem_ataque
		)

		return

	if casas_ataque_assassino.size() == 1:

		var primeira_casa = casas_ataque_assassino[0]

		if casa_mouse == primeira_casa:

			var preview: Array[Vector2i] = []

			preview.append(
				primeira_casa
			)

			personagem_local.mostrar_ataque_casas(
				preview,
				casa_personagem,
				tamanho_casa,
				origem_ataque
			)

			return

		var preview: Array[Vector2i] = []

		preview.append(
			primeira_casa
		)

		preview.append(
			casa_mouse
		)

		personagem_local.mostrar_ataque_casas(
			preview,
			casa_personagem,
			tamanho_casa,
			origem_ataque
		)

# =========================================================
# ATAQUE DO ASSASSINO
# =========================================================

func executar_ataque_assassino():

	if casas_ataque_assassino.size() != 2:
		return

	print(
		"=============================="
	)

	print(
		"ATAQUE DO ASSASSINO"
	)

	print(
		"Primeira casa: ",
		nome_casa(
			casas_ataque_assassino[0].x,
			casas_ataque_assassino[0].y
		)
	)

	print(
		"Segunda casa: ",
		nome_casa(
			casas_ataque_assassino[1].x,
			casas_ataque_assassino[1].y
		)
	)

	casas_ataque_assassino.clear()

	personagem_local.esconder_ataque()

	modo_ataque = false

# =========================================================
# SOLICITAR MOVIMENTO AO HOST
# =========================================================

@rpc("any_peer", "reliable")
func solicitar_movimento(
	numero_jogador: int,
	linha: int,
	coluna: int
):

	if not multiplayer.is_server():
		return

	print(
		"HOST recebeu movimento do jogador ",
		numero_jogador,
		" -> ",
		nome_casa(linha, coluna)
	)

	receber_movimento.rpc(
		numero_jogador,
		linha,
		coluna
	)

# =========================================================
# RECEBER MOVIMENTO DOS JOGADORES
# =========================================================

@rpc("authority", "call_local", "reliable")
func receber_movimento(
	numero_jogador: int,
	linha: int,
	coluna: int
):

	var jogador: Node2D = null

	match numero_jogador:

		1:

			jogador1_linha = linha
			jogador1_coluna = coluna

			jogador = jogador1

		2:

			jogador2_linha = linha
			jogador2_coluna = coluna

			jogador = jogador2

		3:

			jogador3_linha = linha
			jogador3_coluna = coluna

			jogador = jogador3

		4:

			jogador4_linha = linha
			jogador4_coluna = coluna

			jogador = jogador4

		_:
			return

	if jogador == null:
		return

	var destino = centro_da_casa(
		linha,
		coluna
	)

	var tween = create_tween()

	tween.tween_property(
		jogador,
		"position",
		destino,
		0.5
	).set_trans(
		Tween.TRANS_QUAD
	).set_ease(
		Tween.EASE_IN_OUT
	)

# =========================================================
# INPUT
# =========================================================

func _unhandled_input(event):

	# =====================================================
	# BARRA DE ESPAÇO
	# =====================================================

	if event is InputEventKey and event.pressed:

		if event.keycode == KEY_SPACE:

			alternar_modo_ataque()

			return

	# =====================================================
	# TECLA E
	# =====================================================

		if event.keycode == KEY_E:

			revelar_item()

			return

	# =====================================================
	# MOUSE
	# =====================================================

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			# =============================================
			# ATAQUE DO ASSASSINO
			# =============================================

			if modo_ataque and personagem_local is Assassino:

				if meu_jogador != turno_atual:
					return

				var mouse = get_local_mouse_position()

				var coluna = int(
					mouse.x / tamanho_casa.x
				)

				var linha = int(
					mouse.y / tamanho_casa.y
				)

				if linha < 0 or linha >= linhas:
					return

				if coluna < 0 or coluna >= colunas:
					return

				var casa_clicada = Vector2i(
					linha,
					coluna
				)

				if casas_ataque_assassino.is_empty():

					casas_ataque_assassino.append(
						casa_clicada
					)

					print(
						"Primeira casa selecionada: ",
						nome_casa(
							linha,
							coluna
						)
					)

					return

				if casas_ataque_assassino.size() == 1:

					if casa_clicada == casas_ataque_assassino[0]:

						print(
							"Escolha outra casa."
						)

						return

					casas_ataque_assassino.append(
						casa_clicada
					)

					print(
						"Segunda casa selecionada: ",
						nome_casa(
							linha,
							coluna
						)
					)

					executar_ataque_assassino()

					return

			# =============================================
			# NÃO MOVIMENTA NO ATAQUE
			# =============================================

			if modo_ataque:

				if personagem_local is not Assassino:

					executar_ataque()

					return

			# =============================================
			# MOVIMENTO
			# =============================================

			if meu_jogador != turno_atual:
				return

			var mouse = get_local_mouse_position()

			var coluna = int(
				mouse.x / tamanho_casa.x
			)

			var linha = int(
				mouse.y / tamanho_casa.y
			)

			if linha < 0 or linha >= linhas:
				return

			if coluna < 0 or coluna >= colunas:
				return

			var distancia = max(
				abs(
					linha - jogador_local_linha
				),
				abs(
					coluna - jogador_local_coluna
				)
			)

			var movimento_maximo = personagem_local.movimento

			if movimentos_usados + distancia > movimento_maximo:

				print(
					"Movimento insuficiente. Usado: ",
					movimentos_usados,
					"/",
					movimento_maximo
				)

				return

			# =============================================
			# ESCONDER ITEM
			# =============================================

			esconder_item_da_casa_anterior()

			# =============================================
			# ATUALIZAR POSIÇÃO LOCAL
			# =============================================

			atualizar_posicao_local(
				linha,
				coluna
			)

			movimentos_usados += distancia

			print(
				"Movimento usado: ",
				movimentos_usados,
				"/",
				movimento_maximo
			)

			# =============================================
			# ENVIAR MOVIMENTO PARA O HOST
			# =============================================

			if multiplayer.is_server():

				receber_movimento.rpc(
					meu_jogador,
					linha,
					coluna
				)

			else:

				solicitar_movimento.rpc_id(
					1,
					meu_jogador,
					linha,
					coluna
				)

			# =============================================
			# LIMPAR CAMINHO
			# =============================================

			limpar_caminho()

			print(
				"Jogador ",
				meu_jogador,
				" foi para: ",
				nome_casa(
					linha,
					coluna
				)
			)

# =========================================================
# NOME DA CASA
# =========================================================

func nome_casa(
	linha: int,
	coluna: int
) -> String:

	var letra = char(
		65 + coluna
	)

	var numero = 10 - linha

	return letra + str(numero)

# =========================================================
# DESENHO DO X
# =========================================================

class XDesenho extends Node2D:

	var tamanho: float = 15.0

	func _draw():

		draw_line(
			Vector2(
				-tamanho,
				-tamanho
			),

			Vector2(
				tamanho,
				tamanho
			),

			Color.RED,
			4.0
		)

		draw_line(
			Vector2(
				tamanho,
				-tamanho
			),

			Vector2(
				-tamanho,
				tamanho
			),

			Color.RED,
			4.0
		)
