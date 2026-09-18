class_name Personagem
extends Sprite2D


# =========================================================
# ATRIBUTOS
# =========================================================

var vida: int = 0
var vida_inicial: int = 0

var movimento: int = 0
var dano_ataque: int = 0

var nome_classe: String = ""

var largura_ataque: int = 0
var altura_ataque: int = 0


# =========================================================
# ATAQUE VISUAL
# =========================================================

var ataque_visual: Node2D = null


# =========================================================
# CALCULAR ATAQUE
# =========================================================

func calcular_ataque(
	casa_personagem: Vector2i,
	casa_escolhida: Vector2i
) -> Array[Vector2i]:

	return []


# =========================================================
# MOSTRAR ATAQUE
# =========================================================

func mostrar_ataque(posicao: Vector2):

	if ataque_visual != null:

		ataque_visual.queue_free()


	ataque_visual = Node2D.new()

	ataque_visual.position = posicao

	ataque_visual.z_index = 20

	add_child(ataque_visual)


	var tamanho_casa = Vector2(
		50,
		50
	)


	var desenho = AtaqueDesenho.new()


	desenho.largura = largura_ataque

	desenho.altura = altura_ataque

	desenho.tamanho_casa = tamanho_casa


	ataque_visual.add_child(
		desenho
	)


# =========================================================
# MOSTRAR ATAQUE POR CASAS
# =========================================================

func mostrar_ataque_casas(
	casas: Array[Vector2i],
	casa_personagem: Vector2i,
	tamanho_casa: Vector2,
	origem_ataque: Vector2
):

	if ataque_visual != null:

		ataque_visual.queue_free()


	ataque_visual = Node2D.new()

	ataque_visual.z_index = 20

	add_child(
		ataque_visual
	)


	# IMPORTANTE:
	# primeiro adiciona o nó,
	# depois define a posição global.

	ataque_visual.global_position = origem_ataque


	var desenho = AtaqueDesenhoCasas.new()


	desenho.casas = casas

	desenho.casa_personagem = casa_personagem

	desenho.tamanho_casa = tamanho_casa


	ataque_visual.add_child(
		desenho
	)


# =========================================================
# ESCONDER ATAQUE
# =========================================================

func esconder_ataque():

	if ataque_visual != null:

		ataque_visual.queue_free()

		ataque_visual = null


# =========================================================
# DESENHO DO ATAQUE
# =========================================================

class AtaqueDesenho extends Node2D:

	var largura: int = 1

	var altura: int = 1

	var tamanho_casa: Vector2 = Vector2(
		50,
		50
	)


	func _draw():

		var inicio_x = -(
			largura *
			tamanho_casa.x
		) / 2.0


		var inicio_y = -(
			altura *
			tamanho_casa.y
		) / 2.0


		for linha in range(
			altura
		):

			for coluna in range(
				largura
			):

				var posicao = Vector2(

					inicio_x +
					coluna *
					tamanho_casa.x,

					inicio_y +
					linha *
					tamanho_casa.y
				)


				draw_rect(

					Rect2(
						posicao,
						tamanho_casa
					),

					Color(
						1.0,
						0.2,
						0.2,
						0.35
					),

					true
				)


				draw_rect(

					Rect2(
						posicao,
						tamanho_casa
					),

					Color(
						1.0,
						0.2,
						0.2,
						1.0
					),

					false,

					3.0
				)


# =========================================================
# DESENHO POR CASAS
# =========================================================

class AtaqueDesenhoCasas extends Node2D:

	var casas: Array[Vector2i] = []

	var casa_personagem: Vector2i

	var tamanho_casa: Vector2 = Vector2(
		50,
		50
	)


	func _draw():

		for casa in casas:

			var diferenca_linha = (
				casa.x -
				casa_personagem.x
			)


			var diferenca_coluna = (
				casa.y -
				casa_personagem.y
			)


			var posicao = Vector2(

				diferenca_coluna *
				tamanho_casa.x
				-
				tamanho_casa.x / 2.0,

				diferenca_linha *
				tamanho_casa.y
				-
				tamanho_casa.y / 2.0
			)


			draw_rect(

				Rect2(
					posicao,
					tamanho_casa
				),

				Color(
					1.0,
					0.2,
					0.2,
					0.35
				),

				true
			)


			draw_rect(

				Rect2(
					posicao,
					tamanho_casa
				),

				Color(
					1.0,
					0.2,
					0.2,
					1.0
				),

				false,

				3.0
			)
