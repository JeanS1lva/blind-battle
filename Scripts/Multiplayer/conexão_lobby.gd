extends Node

signal jogador_conectado(id: int)
signal jogador_desconectado(id: int)

func _ready() -> void:
	multiplayer.peer_connected.connect(_ao_peer_conectado)
	multiplayer.peer_disconnected.connect(_ao_peer_desconectado)

func _ao_peer_conectado(id: int) -> void:
	jogador_conectado.emit(id)

func _ao_peer_desconectado(id: int) -> void:
	jogador_desconectado.emit(id)
