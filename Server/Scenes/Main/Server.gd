extends Node

var port = 10567                              #дефолтный порт
var max_players = 10                          #кол-во игроков на сервере
var network = NetworkedMultiplayerENet.new()  #Создание подключения

var queue = 1
var roll1 = 0
var roll2 = 0

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

var cellPrice = {
	2: 1000,
	3: 1000,
	4: 1000,
	5: 1000,
	6: 1000,
	7: 1000,
	8: 1000,
	9: 1000,
	11: 1000,
	12: 1000,
	13: 1000,
	14: 1000,
	15: 1000,
	16: 1000,
	17: 1000,
	18: 1000,
	20: 1000,
	21: 1000,
	22: 1000,
	23: 1000,
	24: 1000,
	25: 1000,
	26: 1000,
	27: 1000,
	29: 1000,
	30: 1000,
	31: 1000,
	32: 1000,
	33: 1000,
	34: 1000,
	35: 1000,
	36: 1000,
}

var cellOwner = {
	1: 0,
	2: 0,
	3: 0,
	4: 0,
	5: 0,
	6: 0,
	7: 0,
	8: 0,
	9: 0,
	10: 0,
	11: 0,
	12: 0,
	13: 0,
	14: 0,
	15: 0,
	16: 0,
	17: 0,
	18: 0,
	19: 0,
	20: 0,
	21: 0,
	22: 0,
	23: 0,
	24: 0,
	25: 0,
	26: 0,
	27: 0,
	28: 0,
	29: 0,
	30: 0,
	31: 0,
	32: 0,
	33: 0,
	34: 0,
	35: 0,
	36: 0,
}

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
			colors[players_queue[mas[p]]] = p + 1#Nahuya eto?
		players_queue = mas2.duplicate()
		for p in players.size():
			rpc_id(players_queue[p+1],"playerQueue",p+1)
		queue_button_unlock()

remote func get_players_names(player_id):#Функция для возврата имен всех игроков
		rpc_id(player_id,"return_players_names",players.values())

remote func roll_dice(player_id):#Функция для рандомизации броска костей
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	roll1 = rng.randi_range(1,6)
	roll2 = rng.randi_range(1,6)
	rpc_id(0,"rolled",roll1+roll2,players[player_id])
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
		if player1_info["curentCell"] + (roll1+roll2) > 36:
			player1_info["curentCell"] = (player1_info["curentCell"] + (roll1+roll2)) - 36
		else:
			player1_info["curentCell"] = player1_info["curentCell"] + (roll1+roll2)
		rpc_id(0,"Player_move",1,cellPosition[player1_info["curentCell"]])
		if player1_info["curentCell"] + (roll1+roll2) != 1 || player1_info["curentCell"] + (roll1+roll2) != 10 || player1_info["curentCell"] + (roll1+roll2) != 19 || player1_info["curentCell"] + (roll1+roll2) != 28:
			if cellOwner[player1_info["curentCell"]] == 0:
				rpc_id(players_queue[queue],"showBuyPanel",1)
			else:
				rpc_id(0,"budgetFix",(player1_info["budget"]-cellPrice[player1_info["curentCell"]]),1)
	elif queue == 2:
		if player2_info["curentCell"] + (roll1+roll2) > 36:
			player2_info["curentCell"] = (player2_info["curentCell"] + (roll1+roll2)) - 36
		else:
			player2_info["curentCell"] = player2_info["curentCell"] + (roll1+roll2)
		rpc_id(0,"Player_move",2,cellPosition[player2_info["curentCell"]])
		if player2_info["curentCell"] + (roll1+roll2) != 1 || player2_info["curentCell"] + (roll1+roll2) != 10 || player2_info["curentCell"] + (roll1+roll2) != 19 || player2_info["curentCell"] + (roll1+roll2) != 28:
			if cellOwner[player2_info["curentCell"]] == 0:
				rpc_id(players_queue[queue],"showBuyPanel",1)
			else:
				rpc_id(0,"budgetFix",(player2_info["budget"]-cellPrice[player2_info["curentCell"]]),2)
	elif queue == 3:
		if player3_info["curentCell"] + (roll1+roll2) > 36:
			player3_info["curentCell"] = (player3_info["curentCell"] + (roll1+roll2)) - 36
		else:
			player3_info["curentCell"] = player3_info["curentCell"] + (roll1+roll2)
		rpc_id(0,"Player_move",3,cellPosition[player3_info["curentCell"]])
		if player3_info["curentCell"] + (roll1+roll2) != 1 || player3_info["curentCell"] + (roll1+roll2) != 10 || player3_info["curentCell"] + (roll1+roll2) != 19 || player3_info["curentCell"] + (roll1+roll2) != 28:
			if cellOwner[player3_info["curentCell"]] == 0:
				rpc_id(players_queue[queue],"showBuyPanel",1)
			else:
				rpc_id(0,"budgetFix",(player3_info["budget"]-cellPrice[player3_info["curentCell"]]),3)
	elif queue == 4:
		if player4_info["curentCell"] + (roll1+roll2) > 36:
			player4_info["curentCell"] = (player4_info["curentCell"] + (roll1+roll2)) - 36
		else:
			player4_info["curentCell"] = player4_info["curentCell"] + (roll1+roll2)
		rpc_id(0,"Player_move",4,cellPosition[player4_info["curentCell"]])
		if player4_info["curentCell"] + (roll1+roll2) != 1 || player4_info["curentCell"] + (roll1+roll2) != 10 || player4_info["curentCell"] + (roll1+roll2) != 19 || player4_info["curentCell"] + (roll1+roll2) != 28:
			if cellOwner[player4_info["curentCell"]] == 0:
				rpc_id(players_queue[queue],"showBuyPanel",1)
			else:
				rpc_id(0,"budgetFix",(player4_info["budget"]-cellPrice[player4_info["curentCell"]]),4)

remote func message(text,player_id):
	rpc_id(0,"message",text,players[player_id],colors[player_id])

remote func playerBuyPressed(Player):
	if Player == 1:
		if player1_info["budget"] - cellPrice[player1_info["curentCell"]] > 0:
			cellOwner[player1_info["curentCell"]] = Player
			rpc_id(0,"colorChange", Player,player1_info["curentCell"])
			player1_info["budget"] = player1_info["budget"] - cellPrice[player1_info["curentCell"]]
			rpc_id(0,"budgetFix",player1_info["budget"],Player)
			rpc_id(players_queue[Player],"showBuyPanel",0)
		else:
			rpc_id(players_queue[Player],"showBuyPanel",3)
	elif Player == 2:
		if player2_info["budget"] - cellPrice[player2_info["curentCell"]] > 0:
			cellOwner[player2_info["curentCell"]] = Player
			rpc_id(0,"colorChange", Player,player2_info["curentCell"])
			player2_info["budget"] = player2_info["budget"] - cellPrice[player2_info["curentCell"]]
			rpc_id(0,"budgetFix",player2_info["budget"],Player)
			rpc_id(players_queue[Player],"showBuyPanel",0)
		else:
			rpc_id(players_queue[Player],"showBuyPanel",3)
	elif Player == 3:
		if player3_info["budget"] - cellPrice[player3_info["curentCell"]] > 0:
			cellOwner[player3_info["curentCell"]] = Player
			rpc_id(0,"colorChange", Player,player3_info["curentCell"])
			player3_info["budget"] = player3_info["budget"] - cellPrice[player3_info["curentCell"]]
			rpc_id(0,"budgetFix",player3_info["budget"],Player)
			rpc_id(players_queue[Player],"showBuyPanel",0)
		else:
			rpc_id(players_queue[Player],"showBuyPanel",3)
	elif Player == 4:
		if player4_info["budget"] - cellPrice[player4_info["curentCell"]] > 0:
			cellOwner[player4_info["curentCell"]] = Player
			rpc_id(0,"colorChange", Player,player4_info["curentCell"])
			player4_info["budget"] = player4_info["budget"] - cellPrice[player4_info["curentCell"]]
			rpc_id(0,"budgetFix",player4_info["budget"],Player)
			rpc_id(players_queue[Player],"showBuyPanel",0)
		else:
			rpc_id(players_queue[Player],"showBuyPanel",3)
