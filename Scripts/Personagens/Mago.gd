class_name Mago
extends Personagem

# =========================================================
# ROTAÇÃO DO ATAQUE
# =========================================================

var rotacao_ataque: int = 0


# =========================================================
# ATRIBUTOS
# =========================================================

func _init():

	nome_classe = "Mago"

	vida_inicial = 8
	vida = 8
	som_ataque = preload("res://Audios/Fahhh.mp3")
	movimento = 4

	dano_ataque = 2

	largura_ataque = 2
	altura_ataque = 2


# =========================================================
# CALCULAR ATAQUE
# =========================================================

func calcular_ataque(
	casa_personagem: Vector2i,
	casa_escolhida: Vector2i
) -> Array[Vector2i]:

	var casas: Array[Vector2i] = []

	match rotacao_ataque:

		# =================================================
		# 0 - SUPERIOR DIREITO
		# =================================================

		0:

			casas.append(Vector2i(
				casa_escolhida.x,
				casa_escolhida.y
			))

			casas.append(Vector2i(
				casa_escolhida.x - 1,
				casa_escolhida.y
			))

			casas.append(Vector2i(
				casa_escolhida.x,
				casa_escolhida.y + 1
			))

			casas.append(Vector2i(
				casa_escolhida.x - 1,
				casa_escolhida.y + 1
			))


		# =================================================
		# 1 - INFERIOR DIREITO
		# =================================================

		1:

			casas.append(Vector2i(
				casa_escolhida.x,
				casa_escolhida.y
			))

			casas.append(Vector2i(
				casa_escolhida.x + 1,
				casa_escolhida.y
			))

			casas.append(Vector2i(
				casa_escolhida.x,
				casa_escolhida.y + 1
			))

			casas.append(Vector2i(
				casa_escolhida.x + 1,
				casa_escolhida.y + 1
			))


		# =================================================
		# 2 - INFERIOR ESQUERDO
		# =================================================

		2:

			casas.append(Vector2i(
				casa_escolhida.x,
				casa_escolhida.y
			))

			casas.append(Vector2i(
				casa_escolhida.x + 1,
				casa_escolhida.y
			))

			casas.append(Vector2i(
				casa_escolhida.x,
				casa_escolhida.y - 1
			))

			casas.append(Vector2i(
				casa_escolhida.x + 1,
				casa_escolhida.y - 1
			))


		# =================================================
		# 3 - SUPERIOR ESQUERDO
		# =================================================

		3:

			casas.append(Vector2i(
				casa_escolhida.x,
				casa_escolhida.y
			))

			casas.append(Vector2i(
				casa_escolhida.x - 1,
				casa_escolhida.y
			))

			casas.append(Vector2i(
				casa_escolhida.x,
				casa_escolhida.y - 1
			))

			casas.append(Vector2i(
				casa_escolhida.x - 1,
				casa_escolhida.y - 1
			))

	return casas


# =========================================================
# GIRAR ATAQUE
# =========================================================

func girar_ataque():

	rotacao_ataque += 1

	if rotacao_ataque >= 4:
		rotacao_ataque = 0
