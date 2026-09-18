func atualizar_mira_ataque():

	var mouse = get_local_mouse_position()


	var coluna = int(
		mouse.x / tamanho_casa.x
	)


	var linha = int(
		mouse.y / tamanho_casa.y
	)


	# Fora do tabuleiro
	if linha < 0 or linha >= linhas:

		personagem1.esconder_ataque()

		return


	if coluna < 0 or coluna >= colunas:

		personagem1.esconder_ataque()

		return


	var distancia = max(
		abs(linha - jogador1_linha),
		abs(coluna - jogador1_coluna)
	)


	# Ataque somente na casa vizinha
	if distancia != 1:

		personagem1.esconder_ataque()

		return


	var posicao = centro_da_casa(
		linha,
		coluna
	)


	# Direção entre o Mago e a casa mirada
	var direcao = Vector2(
		coluna - jogador1_coluna,
		linha - jogador1_linha
	).normalized()


	# Como o ataque ocupa 2x2 casas,
	# deslocamos apenas metade de uma casa
	# a partir do centro da casa mirada.
	var offset = Vector2(
		direcao.x * (tamanho_casa.x / 1.5),
		direcao.y * (tamanho_casa.y / 1.5)
	)


	# Ajuste para ataques não diagonais
	if direcao.x == 0 and direcao.y < 0:

		offset.x += tamanho_casa.x * 0.5
		offset.y += tamanho_casa.y * 0.2


	# ATAQUE PARA BAIXO
	if direcao.x == 0 and direcao.y > 0:

		offset.x += tamanho_casa.x * 0.5
		offset.y += (tamanho_casa.y * 0.8) - 50


	# ATAQUE PARA A DIREITA
	if direcao.x > 0 and direcao.y == 0:

		offset.x += (tamanho_casa.x * 0.8) - 50
		offset.y += tamanho_casa.y * 0.5


	# ATAQUE PARA A ESQUERDA
	if direcao.x < 0 and direcao.y == 0:

		offset.x += tamanho_casa.x * 0.2
		offset.y += tamanho_casa.y * 0.5


	posicao += offset


	var posicao_global = to_global(posicao)


	personagem1.mostrar_ataque(
		posicao_global
	)


# =========================================================
# INPUT
# =========================================================
