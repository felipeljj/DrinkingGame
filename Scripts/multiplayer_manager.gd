extends Node

# Sinais
signal player_connected(peer_id: int, player_info: Dictionary)
signal player_disconnected(peer_id: int)
signal server_disconnected
signal connection_failed
signal connection_succeeded
signal room_code_generated(code: String)
signal game_started
signal player_list_updated(players: Array)

# Constantes
const PORT = 7777
const MAX_PLAYERS = 15
const MIN_PLAYERS = 3
const BROADCAST_PORT = 7778
const CODE_LENGTH = 6

# Estado
var players: Dictionary = {}  # peer_id -> player_info
var room_code: String = ""
var is_host: bool = false
var player_name: String = "Jogador"
var game_settings: Dictionary = {
	"points_to_win": 5,
	"pack": "pesado"
}

# UDP para broadcast
var udp_server: UDPServer
var udp_client: PacketPeerUDP
var discovered_rooms: Dictionary = {}  # code -> ip

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func _process(_delta):
	_process_udp_server()
	_process_udp_client()

# ============================================
# FUNÇÕES DO HOST
# ============================================

func create_room(host_name: String) -> String:
	player_name = host_name
	is_host = true
	
	# Criar peer ENet
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_PLAYERS)
	
	if error != OK:
		push_error("Erro ao criar servidor: " + str(error))
		return ""
	
	multiplayer.multiplayer_peer = peer
	
	# Gerar código da sala
	room_code = _generate_room_code()
	
	# Adicionar host como primeiro jogador
	players[1] = {
		"name": host_name,
		"score": 0,
		"is_host": true
	}
	
	# Iniciar servidor UDP para broadcast
	_start_udp_server()
	
	room_code_generated.emit(room_code)
	player_list_updated.emit(get_player_list())
	
	return room_code

func start_game():
	if not is_host:
		return
	
	if players.size() < MIN_PLAYERS:
		push_error("Jogadores insuficientes: " + str(players.size()) + "/" + str(MIN_PLAYERS))
		return
	
	# Notificar todos os clientes
	_notify_game_start.rpc()

@rpc("authority", "call_local", "reliable")
func _notify_game_start():
	game_started.emit()

func set_game_settings(settings: Dictionary):
	game_settings = settings
	if is_host:
		_sync_settings.rpc(settings)

@rpc("authority", "reliable")
func _sync_settings(settings: Dictionary):
	game_settings = settings

# ============================================
# FUNÇÕES DO CLIENTE
# ============================================

func join_room(code: String, client_name: String) -> bool:
	player_name = client_name
	is_host = false
	room_code = code.to_upper()
	
	# Procurar sala via broadcast
	_start_udp_client()
	
	# Aguardar descoberta (com timeout)
	var timeout = 3.0
	var elapsed = 0.0
	while not discovered_rooms.has(room_code) and elapsed < timeout:
		await get_tree().create_timer(0.1).timeout
		elapsed += 0.1
	
	if not discovered_rooms.has(room_code):
		push_error("Sala não encontrada: " + room_code)
		connection_failed.emit()
		return false
	
	var host_ip = discovered_rooms[room_code]
	
	# Conectar ao host
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(host_ip, PORT)
	
	if error != OK:
		push_error("Erro ao conectar: " + str(error))
		connection_failed.emit()
		return false
	
	multiplayer.multiplayer_peer = peer
	return true

func leave_room():
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
	
	players.clear()
	room_code = ""
	is_host = false
	discovered_rooms.clear()
	
	_stop_udp()

# ============================================
# CALLBACKS DE CONEXÃO
# ============================================

func _on_peer_connected(peer_id: int):
	print("Peer conectado: ", peer_id)

func _on_peer_disconnected(peer_id: int):
	if players.has(peer_id):
		var player_info = players[peer_id]
		players.erase(peer_id)
		player_disconnected.emit(peer_id)
		player_list_updated.emit(get_player_list())
		
		if is_host:
			_sync_player_list.rpc(players)

func _on_connected_to_server():
	print("Conectado ao servidor!")
	connection_succeeded.emit()
	
	# Enviar informações do jogador ao host
	_register_player.rpc_id(1, player_name)

func _on_connection_failed():
	print("Falha na conexão!")
	connection_failed.emit()

func _on_server_disconnected():
	print("Servidor desconectado!")
	server_disconnected.emit()
	leave_room()

# ============================================
# RPCs - SINCRONIZAÇÃO
# ============================================

@rpc("any_peer", "reliable")
func _register_player(pname: String):
	var sender_id = multiplayer.get_remote_sender_id()
	
	players[sender_id] = {
		"name": pname,
		"score": 0,
		"is_host": false
	}
	
	player_connected.emit(sender_id, players[sender_id])
	player_list_updated.emit(get_player_list())
	
	# Sincronizar lista com todos
	_sync_player_list.rpc(players)

@rpc("authority", "reliable")
func _sync_player_list(player_dict: Dictionary):
	players = player_dict
	player_list_updated.emit(get_player_list())

# ============================================
# UDP BROADCAST (descoberta de salas)
# ============================================

func _start_udp_server():
	udp_server = UDPServer.new()
	udp_server.listen(BROADCAST_PORT)

func _start_udp_client():
	udp_client = PacketPeerUDP.new()
	udp_client.set_broadcast_enabled(true)
	udp_client.set_dest_address("255.255.255.255", BROADCAST_PORT)
	
	# Enviar pedido de descoberta
	var request = JSON.stringify({"type": "discover", "code": room_code})
	udp_client.put_packet(request.to_utf8_buffer())
	
	# Também escutar respostas
	udp_client.bind(BROADCAST_PORT + 1)

func _process_udp_server():
	if not udp_server:
		return
	
	udp_server.poll()
	if udp_server.is_connection_available():
		var peer = udp_server.take_connection()
		var packet = peer.get_packet()
		if packet.size() > 0:
			var data = JSON.parse_string(packet.get_string_from_utf8())
			if data and data.get("type") == "discover":
				# Responder com nosso código e IP
				var response = JSON.stringify({
					"type": "room_info",
					"code": room_code,
					"host_name": player_name,
					"players": players.size()
				})
				peer.put_packet(response.to_utf8_buffer())

func _process_udp_client():
	if not udp_client:
		return
	
	while udp_client.get_available_packet_count() > 0:
		var packet = udp_client.get_packet()
		var sender_ip = udp_client.get_packet_ip()
		
		if packet.size() > 0:
			var data = JSON.parse_string(packet.get_string_from_utf8())
			if data and data.get("type") == "room_info":
				var code = data.get("code", "")
				if code != "":
					discovered_rooms[code] = sender_ip

func _stop_udp():
	if udp_server:
		udp_server.stop()
		udp_server = null
	if udp_client:
		udp_client.close()
		udp_client = null

# ============================================
# UTILIDADES
# ============================================

func _generate_room_code() -> String:
	var chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"  # Sem I, O, 0, 1 para evitar confusão
	var code = ""
	for i in range(CODE_LENGTH):
		code += chars[randi() % chars.length()]
	return code

func get_player_list() -> Array:
	var list = []
	for peer_id in players:
		var info = players[peer_id].duplicate()
		info["peer_id"] = peer_id
		list.append(info)
	return list

func get_my_peer_id() -> int:
	return multiplayer.get_unique_id()

func is_server() -> bool:
	return multiplayer.is_server()
