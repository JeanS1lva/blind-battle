extends Control

@onready var botao_criar: Button = $"Botões/Criar"
@onready var botao_voltar: Button = $"Botões/Voltar"
@onready var nome_sala: LineEdit = $"Formulário/NomeSala"
@onready var senha: LineEdit = $"Formulário/Senha"
@onready var tipo_de_sala: OptionButton = $"Formulário/TipodeSala"
@onready var quantidade_jogador: OptionButton = $"Formulário/QuantidadeJogadores"
@onready var mensagem: Label = $"Interface/Mensagem"

@onready var criar_lobby_logica: Node = $"CriarLobby"

func _ready() -> void:
	botao_criar.pressed.connect(_ao_clicar_criar)
	botao_voltar.pressed.connect(_ao_clicar_voltar)
	
	criar_lobby_logica.erro_criacao.connect(_mostrar_erro_mensagem)
	
	mensagem.text = ""

func _ao_clicar_criar() -> void:
	mensagem.text = ""
	
	var nome: String = nome_sala.text
	var senha_texto: String = senha.text
	var tipo_idx: int = tipo_de_sala.selected # 0 = Público, 1 = Privado
	
	# Mapeamento da quantidade com base nos IDs (0 -> 1, 1 -> 2, 2 -> 3, 3 -> 4)
	var max_jogadores: int = quantidade_jogador.get_item_id(quantidade_jogador.selected) + 1
	
	# Transmite todos os dados para o nó de lógica de criação
	criar_lobby_logica.tentar_criar_lobby(nome, senha_texto, tipo_idx, max_jogadores)

func _ao_clicar_voltar() -> void:
	get_tree().change_scene_to_file("res://Cenas/Menu/MenuMultiplayer.tscn")

func _mostrar_erro_mensagem(texto_erro: String) -> void:
	mensagem.text = texto_erro
