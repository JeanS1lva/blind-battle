extends Control

func _ready():
	# Conecta os botões usando a sua hierarquia
	$Botões/Criar.pressed.connect(_ao_clicar_criar)
	$Botões/Voltar.pressed.connect(voltar)

	# Configurações visuais dos campos do formulário
	$Formulário/NomeSala.placeholder_text = "Nome da sala"
	$Formulário/Senha.placeholder_text = "Senha"
	$Formulário/Senha.secret = true

	$Interface/Mensagem.text = ""

	# Conecta aos sinais do gerenciador de lobbies
	GerenciadorLobby.lobby_criado_sucesso.connect(_on_lobby_sucesso)
	GerenciadorLobby.lobby_criado_falha.connect(_on_lobby_falha)

func _ao_clicar_criar():
	var nome_sala = $Formulário/NomeSala.text.strip_edges()
	var senha = $Formulário/Senha.text

	var tipo_sala_idx = $Formulário/TipodeSala.selected
	var tipo_sala = ""
	if tipo_sala_idx != -1:
		tipo_sala = $Formulário/TipodeSala.get_item_text(tipo_sala_idx)

	var qtd_idx = $Formulário/QuantidadeJogadores.selected
	var quantidade_jogadores = 4
	if qtd_idx != -1:
		quantidade_jogadores = int($Formulário/QuantidadeJogadores.get_item_text(qtd_idx))

	# Validação básica
	if nome_sala == "":
		$Interface/Mensagem.text = "Digite um nome para a sala."
		return

	var sala_privada = (tipo_sala == "Privado")

	# Desativa o botão temporariamente para evitar cliques duplos enquanto a Steam processa
	$Botões/Criar.disabled = true
	$Interface/Mensagem.text = "Criando lobby na Steam..."

	# Envia para o gerenciador da Steam
	GerenciadorLobby.criar_lobby_steam(nome_sala, senha, sala_privada, quantidade_jogadores)

func _on_lobby_sucesso():
	$Interface/Mensagem.text = "Lobby criado com sucesso!"
	# Vai para a cena do Lobby
	get_tree().change_scene_to_file("res://Cenas/Lobby.tscn")

func _on_lobby_falha(mensagem: String):
	# Reativa o botão e mostra o erro no Label Mensagem
	$Botões/Criar.disabled = false
	$Interface/Mensagem.text = mensagem

func voltar():
	get_tree().change_scene_to_file("res://Cenas/Menu/MenuMultiplayer.tscn")
