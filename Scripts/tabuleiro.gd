extends Node2D

const TABULEIRO_INICIO = Vector2(130, 135)
const TAMANHO_CASA = 99.2
const LINHAS = 10
const COLUNAS = 10

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var mouse_pos = event.position

			var coluna = int((mouse_pos.x - TABULEIRO_INICIO.x) / TAMANHO_CASA)
			var linha = int((mouse_pos.y - TABULEIRO_INICIO.y) / TAMANHO_CASA)

			if coluna >= 0 and coluna < COLUNAS and linha >= 0 and linha < LINHAS:
				var letra = char(65 + coluna)
				var numero = 10 - linha

				print("Você clicou em: ", letra, numero)
