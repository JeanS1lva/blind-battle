class_name RetratoPersonagem
extends TextureRect

# Permite definir o nome do personagem diretamente no Inspetor da Godot
@export var nome_personagem: String = "guerreiro"

# Sinal para avisar o nó principal que o mouse entrou ou foi clicado
signal mouse_entrou(personagem: String)
signal mouse_saiu()
signal clicado(personagem: String)

func _ready() -> void:
	# Conecta os sinais nativos do Control automaticamente
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	emit_signal("mouse_entrou", nome_personagem)

func _on_mouse_exited() -> void:
	emit_signal("mouse_saiu")

# Detecta o clique do mouse dentro deste Control específico
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			emit_signal("clicado", nome_personagem)
