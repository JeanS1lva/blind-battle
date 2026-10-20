extends Node2D

@onready var botao_voltar: Button = $"Voltar"
@onready var label_mensagem: Label = $"Mensagem"
@onready var vbox_container: VBoxContainer = $"ScrollContainer/VBoxContainer"
@onready var procurar_lobby_logica: Node = $"ProcurarLobby"

func _ready() -> void:
	botao_voltar.pressed.connect(_ao_clicar_voltar)
	
	# Conecta os sinais vindos do script de lógica do multiplayer
	procurar_lobby_logica.lobbies_atualizados.connect(_atualizar_lista_visual)
	procurar_lobby_logica.status_busca_alterado.connect(_atualizar_mensagem_status)

func _atualizar_mensagem_status(texto: String) -> void:
	label_mensagem.text = texto

func _atualizar_lista_visual(lista_lobbies: Array) -> void:
	# Limpa os elementos visuais anteriores do ScrollContainer
	for filho in vbox_container.get_children():
		filho.queue_free()
		
	if lista_lobbies.is_empty():
		label_mensagem.text = "Nenhum lobby encontrado."
		return
		
	label_mensagem.text = "%d lobbies encontrados" % lista_lobbies.size()
	
	# Instancia visualmente cada lobby recebido da lógica
	for lobby in lista_lobbies:
		var hbox = HBoxContainer.new()
		hbox.custom_minimum_size = Vector2(0, 40) # Altura mínima de 40 pixels em Y
		
		var label = Label.new()
		label.text = "%s (%d/%d)" % [lobby["nome"], lobby["atual"], lobby["max"]]
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL # Expande horizontalmente
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		var botao = Button.new()
		botao.text = "Entrar"
		
		# Ação do botão de entrar (futuramente chamará a função de entrar no lobby com o ID 'lobby["id"]')
		# botao.pressed.connect(func(): _tentar_entrar(lobby["id"]))
		
		hbox.add_child(label)
		hbox.add_child(botao)
		vbox_container.add_child(hbox)

func _ao_clicar_voltar() -> void:
	get_tree().change_scene_to_file("res://Cenas/Menu/MenuMultiplayer.tscn")
