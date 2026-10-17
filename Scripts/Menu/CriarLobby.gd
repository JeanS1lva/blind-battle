extends Control


const PORTA := 9999


var peer := ENetMultiplayerPeer.new()


func _ready():
	$Criar.pressed.connect(criar_lobby)
	$voltar.pressed.connect(voltar)

	$nomeSala.placeholder_text = "Nome da sala"
	$LineEdit2.placeholder_text = "Senha"

	# Esconde os caracteres da senha
	$LineEdit2.secret = true


func criar_lobby():

	var nome_sala = $nomeSala.text.strip_edges()
	var senha = $LineEdit2.text

	var privacidade = $privacidade.get_item_text(
		$privacidade.selected
	)

	var quantidade_jogadores = int(
		$quantidadeJogadores.get_item_text(
			$quantidadeJogadores.selected
		)
	)


	# Verifica se foi colocado um nome
	if nome_sala == "":
		print("Digite um nome para a sala.")
		return


	# Verifica se o lobby é privado
	var sala_privada = false

	if privacidade == "Privado":
		sala_privada = true


	# Guarda as informações da sala
	DadosJogo.nome_sala = nome_sala
	DadosJogo.senha_sala = senha
	DadosJogo.sala_privada = sala_privada
	DadosJogo.max_jogadores = quantidade_jogadores


	print("========== CRIANDO LOBBY ==========")
	print("Nome: ", DadosJogo.nome_sala)
	print("Senha: ", DadosJogo.senha_sala)
	print("Privado: ", DadosJogo.sala_privada)
	print("Máximo: ", DadosJogo.max_jogadores)


	# Cria o servidor
	var erro = peer.create_server(
		PORTA,
		DadosJogo.max_jogadores
	)


	if erro != OK:
		print("ERRO AO CRIAR SERVIDOR: ", erro)
		return


	# Define este jogo como servidor
	multiplayer.multiplayer_peer = peer


	print("Servidor criado com sucesso!")
	print("Você é o HOST.")
	print("Porta: ", PORTA)


	# Vai para o Lobby
	get_tree().change_scene_to_file(
		"res://Cenas/Lobby.tscn"
	)


func voltar():

	get_tree().change_scene_to_file(
		"res://Cenas/Multiplayer.tscn"
	)
