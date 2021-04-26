extends Node

var port = 10567                              #дефолтный порт
var max_players = 10                          #кол-во игроков на сервере
var network = NetworkedMultiplayerENet.new()  #Создание подключения

var queue = 1
var roll = 0

#Словари в которых хранятся все данные про игрока
var player1_info = {
	"budget": 15000,
	"curentCell": 1,
	"color": "f93232"
}
var player2_info = {
	"budget": 15000,
	"curentCell": 1,
	"color": "8cdc4f"
}
var player3_info = {
	"budget": 15000,
	"curentCell": 1,
	"color": "3832f9"
}
var player4_info = {
	"budget": 15000,
	"curentCell": 1,
	"color": "f6f754"
}
var colors = {}

var cellPosition = {
	1: Vector2(380.339,95.635),
	2: Vector2(442,75),
	3: Vector2(499,75),
	4: Vector2(556,75),
	5: Vector2(614,75),
	6: Vector2(671,75),
	7: Vector2(728,75),
	8: Vector2(785,75),
	9: Vector2(842,75),
	10: Vector2(928,72),
	11: Vector2(927,157),
	12: Vector2(927,214),
	13: Vector2(927,271),
	14: Vector2(927,328),
	15: Vector2(927,385),
	16: Vector2(927,442),
	17: Vector2(927,499),
	18: Vector2(927,557),
	19: Vector2(927,643),
	20: Vector2(841,643),
	21: Vector2(784,643),
	22: Vector2(728,643),
	23: Vector2(671,643),
	24: Vector2(614,643),
	25: Vector2(556,643),
	26: Vector2(499,643),
	27: Vector2(442,643),
	28: Vector2(357,643),
	29: Vector2(357,557),
	30: Vector2(357,499),
	31: Vector2(357,442),
	32: Vector2(357,385),
	33: Vector2(357,328),
	34: Vector2(357,271),
	35: Vector2(357,214),
	36: Vector2(357,157),
}

var players = {}                              #словарь игроков в формате id:name
var player_ready = []
var players_queue = {}

func _ready():    #Функция которая запускается при старте скрипта
	StartServer() #Функция старта сервера

func StartServer():
	network.create_server(port, max_players)#Создание сервера
	get_tree().set_network_peer(network)#Подключения сервера
	print("Server started")

	network.connect("peer_connected", self, "_Peer_Connected")#Сигнал на коннект игрока
	network.connect("peer_disconnected", self, "_Peer_Disconnected")#Сигнал на дсиконект

func _Peer_Connected(player_id):#Функция для регистрации соеденения игрока
	print("User " + str(player_id) + " Connected")
	rpc_id(0, "refresh_lobby", players.values())#Вызов обновления лобби

func _Peer_Disconnected(player_id):#Функция на регистрацию дисконетка игрока
	print("User " + str(player_id) + " Disconnected")
	players.erase(player_id)#Удаляет ушедшего игрока
	player_ready.erase(player_id)
	print(players.values())
	rpc_id(0, "refresh_lobby", players.values())#Вызов обновления лобби
	print(player_ready)

remote func register_player(new_player_name):#Удаленная функция которая вызывается с клента
	var id = get_tree().get_rpc_sender_id()
	players[id] = new_player_name#Регистрация в словаре нового игрока
	players_queue[new_player_name] = id
	
remote func player_list(requester):#
	var player_id = get_tree().get_rpc_sender_id()
	print(players.values())
	rpc_id(0, "refresh_lobby", players.values())#Вызов обновления лобби

remote func player_ready(player_id):#Функция для принимания игроков которые готовы к игре
	print("Player № " + str(player_id) + "ready for game")
	player_ready.insert(player_ready.size(),player_id)#Ввод ид готовых игроков в массив
	if player_ready.size() == players.size():#Проверка на готовность всех игроков
		rpc_id(0,"all_ready")
		print("All players ready, game will be started...")
		var mas = {}
		var mas2 = {}
		mas = players.values()
		mas.sort()
		for p in players.size():
			mas2[p+1] = players_queue[mas[p]]#Составления очереди ходов для игроков
			colors[players_queue[mas[p]]] = p + 1
		players_queue = mas2.duplicate()
		queue_button_unlock()

remote func get_players_names(player_id):#Функция для возврата имен всех игроков
	rpc_id(0,"return_players_names",players.values())

remote func roll_dice(player_id):#Функция для рандомизации броска костей
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	roll = rng.randi_range(0,12)
	rpc_id(0,"rolled",roll,players[player_id])
	Player_move()
	queue += 1
	if players_queue.size() == 2:
		if queue > 2:
			queue = 1
	elif players_queue.size() == 3:
		if queue > 3:
			queue = 1
	elif players_queue.size() == 4:
		if queue > 4:
			queue = 1
	queue_button_unlock()

remote func queue_button_unlock():#Функция для по очередного хода всех игроков
	if players_queue.size() == 2:
		if queue == 1:
			rpc_id(players_queue[queue],"unlock_button")
		elif queue == 2:
			rpc_id(players_queue[queue],"unlock_button")
	elif players_queue.size() == 3:
		if queue == 1:
			rpc_id(players_queue[queue],"unlock_button")
		elif queue == 2:
			rpc_id(players_queue[queue],"unlock_button")
		elif queue == 3:
			rpc_id(players_queue[queue],"unlock_button")
	elif players_queue.size() == 4:
		if queue == 1:
			rpc_id(players_queue[queue],"unlock_button")
		elif queue == 2:
			rpc_id(players_queue[queue],"unlock_button")
		elif queue == 3:
			rpc_id(players_queue[queue],"unlock_button")
		elif queue == 4:
			rpc_id(players_queue[queue],"unlock_button")

func Player_move():
	if queue == 1:
		if player1_info["curentCell"] + roll > 36:
			player1_info["curentCell"] = (player1_info["curentCell"] + roll) - 36
		else:
			player1_info["curentCell"] = player1_info["curentCell"] + roll
		rpc_id(0,"Player_move",1,cellPosition[player1_info["curentCell"]])
	elif queue == 2:
		if player2_info["curentCell"] + roll > 36:
			player2_info["curentCell"] = (player2_info["curentCell"] + roll) - 36
		else:
			player2_info["curentCell"] = player2_info["curentCell"] + roll
		rpc_id(0,"Player_move",2,cellPosition[player2_info["curentCell"]])
	elif queue == 3:
		if player3_info["curentCell"] + roll > 36:
			player3_info["curentCell"] = (player3_info["curentCell"] + roll) - 36
		else:
			player3_info["curentCell"] = player3_info["curentCell"] + roll
		rpc_id(0,"Player_move",3,cellPosition[player3_info["curentCell"]])
	elif queue == 4:
		if player4_info["curentCell"] + roll > 36:
			player4_info["curentCell"] = (player4_info["curentCell"] + roll) - 36
		else:
			player4_info["curentCell"] = player4_info["curentCell"] + roll
		rpc_id(0,"Player_move",4,cellPosition[player4_info["curentCell"]])

remote func message(text,player_id):
	rpc_id(0,"message",text,players[player_id],colors[player_id])
