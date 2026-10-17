extends Node

@onready var grade = get_parent().get_node("Grade")

var cenas_personagens = {
	"mago": preload("res://Personagens/Mago.tscn"),
	"guerreiro": preload("res://Personagens/Guerreiro.tscn"),
	"assassino": preload("res://Personagens/Assassino.tscn"),
	"arqueiro": preload("res://Personagens/Arqueiro.tscn")
}

var meu_id: int = 0
var meu_jogador: int = 0

func _ready():

	print("==============================")
	print("GAMEPLAY MULTIPLAYER")
	print("==============================")

	if multiplayer.multiplayer_peer == null:

		print(
			"ERRO: multiplayer não está conectado."
		)

		return

	meu_id = multiplayer.get_unique_id()

	meu_jogador = DadosJogo.numero_jogador

	print(
		"ID desta máquina: ",
		meu_id
	)

	print(
		"VOCÊ É O JOGADOR: ",
		meu_jogador
	)

	criar_jogadores()


# =========================================================
# CRIAR JOGADORES
# =========================================================

func criar_jogadores():

	print(
		"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	)

	print(
		"GAMEPLAY.GD ESTÁ CRIANDO JOGADORES"
	)

	print(
		"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	)

	var escolhas = [
		DadosJogo.personagem_jogador_1,
		DadosJogo.personagem_jogador_2,
		DadosJogo.personagem_jogador_3,
		DadosJogo.personagem_jogador_4
	]

	print(
		"=============================="
	)

	print(
		"CRIANDO JOGADORES"
	)

	print(
		"=============================="
	)

	for i in range(DadosJogo.max_jogadores):

		var escolha = escolhas[i]

		print(
			"Jogador ",
			i + 1,
			": ",
			escolha
		)

		if escolha == "":

			print(
				"Jogador ",
				i + 1,
				" ainda não escolheu personagem."
			)

			continue

		if not cenas_personagens.has(escolha):

			print(
				"ERRO: personagem do Jogador ",
				i + 1,
				" inválido: ",
				escolha
			)

			continue

		var jogador = cenas_personagens[
			escolha
		].instantiate()

		grade.add_child(jogador)

		jogador.z_index = 10

		var posicao = obter_posicao_inicial(i)

		jogador.position = grade.centro_da_casa(
			posicao.x,
			posicao.y
		)

		if i == 0:

			grade.jogador1 = jogador

			grade.personagem1 = encontrar_personagem(
				jogador
			)

		elif i == 1:

			grade.jogador2 = jogador

			grade.personagem2 = encontrar_personagem(
				jogador
			)

		elif i == 2:

			grade.jogador3 = jogador

			grade.personagem3 = encontrar_personagem(
				jogador
			)

		elif i == 3:

			grade.jogador4 = jogador

			grade.personagem4 = encontrar_personagem(
				jogador
			)

		print(
			"Jogador ",
			i + 1,
			" criado: ",
			escolha
		)

	print(
		"ENVIANDO PARA GRADE: ",
		meu_jogador
	)

	grade.configurar_jogador_local(
		meu_jogador
	)


# =========================================================
# POSIÇÃO INICIAL
# =========================================================

func obter_posicao_inicial(
	indice: int
) -> Vector2i:

	var posicoes = [

		Vector2i(
			0,
			0
		),

		Vector2i(
			9,
			9
		),

		Vector2i(
			0,
			9
		),

		Vector2i(
			9,
			0
		)
	]

	return posicoes[indice]


# =========================================================
# ENCONTRAR PERSONAGEM
# =========================================================

func encontrar_personagem(
	no: Node
) -> Personagem:

	if no is Personagem:

		return no

	for filho in no.get_children():

		var resultado = encontrar_personagem(
			filho
		)

		if resultado != null:

			return resultado

	return null
