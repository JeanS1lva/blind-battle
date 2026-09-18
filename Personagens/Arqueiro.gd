class_name Arqueiro
extends Personagem


func _init():

	nome_classe = "Arqueiro"
	som_ataque = preload("res://Audios/Fahhh.mp3")
	vida_inicial = 8
	vida = 8

	movimento = 4

	dano_ataque = 1

	largura_ataque = 1
	altura_ataque = 4


func calcular_ataque(
	casa_personagem: Vector2i,
	casa_escolhida: Vector2i
) -> Array[Vector2i]:

	var casas: Array[Vector2i] = []


	# =====================================================
	# DIREÇÃO
	# =====================================================

	var direcao_linha = int(
		sign(
			casa_escolhida.x - casa_personagem.x
		)
	)

	var direcao_coluna = int(
		sign(
			casa_escolhida.y - casa_personagem.y
		)
	)


	# =====================================================
	# 4 CASAS NA DIREÇÃO ESCOLHIDA
	# =====================================================

	for i in range(4):

		var linha = casa_escolhida.x + (
			direcao_linha * i
		)

		var coluna = casa_escolhida.y + (
			direcao_coluna * i
		)


		# Não deixa sair do tabuleiro

		if linha < 0 or linha >= 10:

			break

		if coluna < 0 or coluna >= 10:

			break


		casas.append(
			Vector2i(
				linha,
				coluna
			)
		)


	return casas
