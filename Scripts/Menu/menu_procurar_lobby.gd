extends Node2D

@onready var botao_voltar: Button = $"Voltar"
@onready var label_mensagem: Label = $"Mensagem"
@onready var vbox_container: VBoxContainer = $"ScrollContainer/VBoxContainer"
@onready var procurar_lobby_logica: Node = $"ProcurarLobby"

func _ready() -> void:
	botao_voltar.pressed.connect(_ao_clicar_voltar)
	
	# Conecta os sinais vindos da lógica
	procurar_lobby_logica.lobbies_atualizados.connect(_atualizar_lista_visual)
	procurar_lobby_logica.status_busca_alterado.connect(_atualizar_mensagem_status)
	procurar_lobby_logica.erro_ao_entrar.connect(_exibir_erro_entrada) # Conexão do erro

func _atualizar_mensagem_status(texto: String) -> void:
	label_mensagem.text = texto

func _exibir_erro_entrada(mensagem_erro: String) -> void:
	label_mensagem.text = mensagem_erro

func _atualizar_lista_visual(lista_lobbies: Array) -> void:
	for filho in vbox_container.get_children():
		filho.queue_free()
		
	if lista_lobbies.is_empty():
		label_mensagem.text = "Nenhum lobby encontrado."
		return
		
	label_mensagem.text = "%d lobbies encontrados" % lista_lobbies.size()
	
	for lobby in lista_lobbies:
		var hbox = HBoxContainer.new()
		hbox.custom_minimum_size = Vector2(0, 40)
		
		var label = Label.new()
		label.text = "%s (%d/%d)" % [lobby["nome"], lobby["atual"], lobby["max"]]
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		var botao = Button.new()
		botao.text = "Entrar"
		
		# Faz o botão chamar diretamente a função de tentativa de entrada na lógica, passando o ID do lobby
		var id_do_lobby = lobby["id"]
		botao.pressed.connect(func(): procurar_lobby_logica.tentar_entrar_no_lobby(id_do_lobby))
		
		hbox.add_child(label)
		hbox.add_child(botao)
		vbox_container.add_child(hbox)

func _ao_clicar_voltar() -> void:
	get_tree().change_scene_to_file("res://Cenas/Menu/MenuMultiplayer.tscn")
