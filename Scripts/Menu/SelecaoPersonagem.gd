extends Control

@onready var retratos_container = $Retratos
@onready var escolhas_label = $Escolhas

# Instancia ou referencia o nosso componente de rede da seleção
@onready var gerenciador_selecao: GerenciadorSelecao = $GerenciadorSelecao # Ou ajuste o caminho se ele estiver de outra forma na cena

var personagem_selecionado := ""
var escolha_enviada := false

func _ready() -> void:
	# Conecta os sinais do gerenciador de seleção
	if gerenciador_selecao:
		gerenciador_selecao.todos_escolheram.connect(_on_todos_escolheram)
		gerenciador_selecao.erro_desconexao.connect(_on_erro_desconexao)

	# Conecta os sinais de cada retrato filho automaticamente
	for filho in retratos_container.get_children():
		if filho is RetratoPersonagem:
			filho.mouse_entrou.connect(_on_retrato_mouse_entrou)
			filho.clicado.connect(_on_retrato_clicado)
			
	atualizar_destaque_visual()

func _on_retrato_mouse_entrou(personagem: String) -> void:
	if escolha_enviada:
		return
		
	personagem_selecionado = personagem
	atualizar_destaque_visual()

func _on_retrato_clicado(personagem: String) -> void:
	if escolha_enviada:
		return
		
	personagem_selecionado = personagem
	confirmar_personagem()

func atualizar_destaque_visual() -> void:
	for filho in retratos_container.get_children():
		if filho is RetratoPersonagem:
			if filho.nome_personagem == personagem_selecionado:
				filho.modulate = Color.WHITE
			else:
				filho.modulate = Color(0.3, 0.3, 0.3, 1)

func confirmar_personagem() -> void:
	escolha_enviada = true
	
	if escolhas_label:
		escolhas_label.text = "Personagem escolhido: %s\nAguardando outros jogadores..." % personagem_seguro_para_texto(personagem_selecionado)
	
	# Comunica a escolha ao gerenciador de rede para sincronizar via Steam
	if gerenciador_selecao:
		gerenciador_selecao.registrar_escolha(personagem_selecionado)

func _on_todos_escolheram() -> void:
	if escolhas_label:
		escolhas_label.text = "Todos escolheram! Entrando no tabuleiro..."
	
	# Aqui você faz a transição para a cena do tabuleiro/gameplay
	# get_tree().change_scene_to_file("res://Cenas/Gameplay/Tabuleiro.tscn")

func _on_erro_desconexao(mensagem: String) -> void:
	if escolhas_label:
		escolhas_label.text = mensagem
	
	# Opcional: retornar para o lobby ou menu principal após uma desconexão
	# get_tree().change_scene_to_file("res://Cenas/Menu/Lobby.tscn")

func personagem_seguro_para_texto(nome: String) -> String:
	return nome.capitalize()
