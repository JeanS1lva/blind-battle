class_name Assassino
extends Personagem


# =========================================================
# ATRIBUTOS
# =========================================================

func _init():

	nome_classe = "Assassino"

	vida_inicial = 6
	vida = 6

	movimento = 6

	dano_ataque = 3

	largura_ataque = 1
	altura_ataque = 1


# =========================================================
# ATAQUE
# =========================================================

func calcular_ataque(
	casa_personagem: Vector2i,
	casa_escolhida: Vector2i
) -> Array[Vector2i]:

	var casas: Array[Vector2i] = []

	casas.append(casa_escolhida)

	return casas
