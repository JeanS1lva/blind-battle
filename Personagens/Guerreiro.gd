class_name Guerreiro
extends Personagem


func _init():

	nome_classe = "Guerreiro"

	vida_inicial = 12
	vida = 12

	movimento = 2

	dano_ataque = 2

	largura_ataque = 3
	altura_ataque = 1


func calcular_ataque(
	casa_personagem: Vector2i,
	casa_escolhida: Vector2i
) -> Array[Vector2i]:

	var casas: Array[Vector2i] = []

	var diferenca_linha = casa_escolhida.x - casa_personagem.x
	var diferenca_coluna = casa_escolhida.y - casa_personagem.y

	var direcao_linha: int = int(sign(diferenca_linha))
	var direcao_coluna: int = int(sign(diferenca_coluna))


	# ==========================================
	# ALVO NA VERTICAL
	# Ataque fica horizontal
	# ==========================================

	if direcao_coluna == 0:

		casas.append(
			Vector2i(
				casa_escolhida.x,
				casa_escolhida.y - 1
			)
		)

		casas.append(casa_escolhida)

		casas.append(
			Vector2i(
				casa_escolhida.x,
				casa_escolhida.y + 1
			)
		)


	# ==========================================
	# ALVO NA HORIZONTAL
	# Ataque fica vertical
	# ==========================================

	elif direcao_linha == 0:

		casas.append(
			Vector2i(
				casa_escolhida.x - 1,
				casa_escolhida.y
			)
		)

		casas.append(casa_escolhida)

		casas.append(
			Vector2i(
				casa_escolhida.x + 1,
				casa_escolhida.y
			)
		)


	# ==========================================
	# ALVO NA DIAGONAL
	# Formato em L
	# ==========================================

	else:

		casas.append(casa_escolhida)

		casas.append(
			Vector2i(
				casa_escolhida.x - direcao_linha,
				casa_escolhida.y
			)
		)

		casas.append(
			Vector2i(
				casa_escolhida.x,
				casa_escolhida.y - direcao_coluna
			)
		)

	return casas
