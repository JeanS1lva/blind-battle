extends Node

var lobby_id_atual: int = 0
var sou_host: bool = false
var steam_inicializada: bool = false
var mensagem_aviso_menu: String = ""

func inicializar_steam() -> bool:
	if steam_inicializada:
		return true
		
	var resposta = Steam.steamInitEx()
	if resposta["status"] > 0:
		print("Erro ao iniciar a Steam: %s" % resposta["verbal"])
		return false

	steam_inicializada = true
	return true

func _process(_delta: float) -> void:
	Steam.run_callbacks()
