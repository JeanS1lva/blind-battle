extends Node

var steam_inicializada: bool = false

func inicializar_steam() -> bool:
	if steam_inicializada:
		return true
		
	var resposta = Steam.steamInitEx()
	if resposta["status"] > 0:
		print("Erro ao iniciar a Steam: %s" % resposta["verbal"])
		return false

	steam_inicializada = true
	return true
