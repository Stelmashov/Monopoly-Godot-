extends Node

const time = 60

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
	"color": "f93232",
	"state": "free"
}
var player2_info = {
	"budget": 15000,
	"curentCell": 1,
	"color": "8cdc4f",
	"state": "free"
}
var player3_info = {
	"budget": 15000,
	"curentCell": 1,
	"color": "3832f9",
	"state": "free"
}
var player4_info = {
	"budget": 15000,
	"curentCell": 1,
	"color": "f6f754",
	"state": "free"
}

var players_up = {}

var colors = {}

var deal = {}

var money = {
	0: 500,
	1: 1500,
	2: 2000,
	3: 2500,
	4: 3000,
	5: 3500,
}

var phraseAdd = {
	0: "is lucky! he found money on the floor.",
	1: "is lucky! he won the lottery.",
	2: "is lucky! Friends gave him",
	3: "is lucky! he won at the casino.",
	4: "is lucky! he received dividends.",
	5: "is lucky! The money fell on his head.",
}

var phraseSub = {
	0: "is out of luck! The tax office cleaned out his pockets.",
	1: "is out of luck! He was robbed.",
	2: "is out of luck! His partners betrayed him.",
	3: "is out of luck! He lost his wallet in a taxi.",
	4: "is out of luck! Employees asked for an increase in salary.",
	5: "is out of luck! The money just disappeared from his pocket.",
}

var cellGroup = {
	"Purple": [2, 4],
	"dirtyGreen": [6, 8, 9],
	"Aqua": [11, 13, 14],
	"Orange": [17, 18],
	"Red": [20, 22] ,
	"darkPink": [24, 25, 27],
	"Blue": [29, 30, 32],
	"Gold": [34, 36],
	"Green": [5, 16, 23, 33],
	"Pink": [12, 26]
}

var cellNames = {
	2: "Chanel",
	3: "Chance",
	4: "Hugo Boss",
	5: "Mercedes",
	6: "Adidas",
	7: "Chance",
	8: "Puma",
	9: "Lacoste",
	11: "Instagram",
	12: "Rockstar",
	13: "Facebook",
	14: "Twitter",
	15: "Audi",
	16: "Chance",
	17: "Pepsi",
	18: "Fanta",
	20: "Nvidia",
	21: "Chance",
	22: "Radeon",
	23: "Ford",
	24: "McDonald’s",
	25: "Pyzata Hata",
	26: "Rovio",
	27: "KFS",
	29: "Varus",
	30: "Ashan",
	31: "Chance",
	32: "ATB",
	33: "Land Rover",
	34: "Apple",
	35: "Chance",
	36: "Samsung",
}

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
	1: -1,
	2: 0,
	3: -1,
	4: 0,
	5: 0,
	6: 0,
	7: -1,
	8: 0,
	9: 0,
	10: -1,
	11: 0,
	12: 0,
	13: 0,
	14: 0,
	15: 0,
	16: -1,
	17: 0,
	18: 0,
	19: -1,
	20: 0,
	21: -1,
	22: 0,
	23: 0,
	24: 0,
	25: 0,
	26: 0,
	27: 0,
	28: -1,
	29: 0,
	30: 0,
	31: -1,
	32: 0,
	33: 0,
	34: 0,
	35: -1,
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
var players_ready = []
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
	players_ready.erase(player_id)
	print(players.values())
	rpc_id(0, "refresh_lobby", players.values())#Вызов обновления лобби
	print(players_ready)

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
	players_ready.insert(players_ready.size(),player_id)#Ввод ид готовых игроков в массив
	if players_ready.size() == players.size():#Проверка на готовность всех игроков
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
		for p in players.size():
			rpc_id(players_queue[p+1],"playerQueue",p+1)
		queue_button_unlock(0)

remote func get_players_names(player_id):#Функция для возврата имен всех игроков
		rpc_id(player_id,"return_players_names",players.values())

remote func roll_dice(player_id,player,casino):#Функция для рандомизации броска костей
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	roll1 = rng.randi_range(1,6)
	roll2 = rng.randi_range(1,6)
	if player == 1:
		if player1_info["state"] == "Prisoner":
			if roll1 == roll2:
				player1_info["state"] = "free"
				queue += 1
				queue_button_unlock(0)
				rpc_id(0,"message","threw out the doublet and gets out of jail",players[player_id],colors[player_id])
				return
			else:
				queue += 1
				queue_button_unlock(0)
				rpc_id(0,"message","failed and remains in jail",players[player_id],colors[player_id])
				return
	if player == 2:
		if player2_info["state"] == "Prisoner":
			if roll1 == roll2:
				player2_info["state"] = "free"
				queue += 1
				queue_button_unlock(0)
				rpc_id(0,"message","threw out the doublet and gets out of jail",players[player_id],colors[player_id])
				return
			else:
				queue += 1
				queue_button_unlock(0)
				rpc_id(0,"message","failed and remains in jail",players[player_id],colors[player_id])
				return
	if player == 3:
		if player3_info["state"] == "Prisoner":
			if roll1 == roll2:
				player3_info["state"] = "free"
				queue += 1
				queue_button_unlock(0)
				rpc_id(0,"message","threw out the doublet and gets out of jail",players[player_id],colors[player_id])
				return
			else:
				queue += 1
				queue_button_unlock(0)
				rpc_id(0,"message","failed and remains in jail",players[player_id],colors[player_id])
				return
	if player == 4:
		if player4_info["state"] == "Prisoner":
			if roll1 == roll2:
				player4_info["state"] = "free"
				queue += 1
				queue_button_unlock(0)
				rpc_id(0,"message","threw out the doublet and gets out of jail",players[player_id],colors[player_id])
				return
			else:
				queue += 1
				queue_button_unlock(0)
				rpc_id(0,"message","failed and remains in jail",players[player_id],colors[player_id])
				return
	if casino == 1:
		if roll1 == roll2:
			if player == 1:
				player1_info["budget"] += 10000
				rpc_id(0,"budgetFix",player1_info["budget"],1)
				rpc_id(0,"message","WON THE CASINO!",players[player_id],colors[player_id])
				rpc_id(player_id,"CasionRollBack",roll1,roll2)
				queue += 1
				queue_button_unlock(0)
				return
			if player == 2:
				player2_info["budget"] += 10000
				rpc_id(0,"budgetFix",player2_info["budget"],2)
				rpc_id(0,"message","WON THE CASINO!",players[player_id],colors[player_id])
				rpc_id(player_id,"CasionRollBack",roll1,roll2)
				queue += 1
				queue_button_unlock(0)
				return
			if player == 3:
				player3_info["budget"] += 10000
				rpc_id(0,"budgetFix",player3_info["budget"],3)
				rpc_id(0,"message","WON THE CASINO!",players[player_id],colors[player_id])
				rpc_id(player_id,"CasionRollBack",roll1,roll2)
				queue += 1
				queue_button_unlock(0)
				return
			if player == 4:
				player4_info["budget"] += 10000
				rpc_id(0,"budgetFix",player4_info["budget"],4)
				rpc_id(0,"message","WON THE CASINO!",players[player_id],colors[player_id])
				rpc_id(player_id,"CasionRollBack",roll1,roll2)
				queue += 1
				queue_button_unlock(0)
				return
		else:
			if player == 1:
				player1_info["budget"] -= 3000
				rpc_id(0,"budgetFix",player1_info["budget"],1)
				rpc_id(player_id,"CasionRollBack",roll1,roll2)
				queue += 1
				queue_button_unlock(0)
				return
			if player == 2:
				player2_info["budget"] -= 3000
				rpc_id(0,"budgetFix",player2_info["budget"],2)
				rpc_id(player_id,"CasionRollBack",roll1,roll2)
				queue += 1
				queue_button_unlock(0)
				return
			if player == 3:
				player3_info["budget"] -= 3000
				rpc_id(0,"budgetFix",player3_info["budget"],3)
				rpc_id(player_id,"CasionRollBack",roll1,roll2)
				queue += 1
				queue_button_unlock(0)
				return
			if player == 4:
				player4_info["budget"] -= 3000
				rpc_id(0,"budgetFix",player4_info["budget"],4)
				rpc_id(player_id,"CasionRollBack",roll1,roll2)
				queue += 1
				queue_button_unlock(0)
				return
	rpc_id(0,"rolled",roll1+roll2,players[player_id])
	Player_move()

remote func queue_button_unlock(skip):#Функция для по очередного хода всех игроков
	if skip == 1:
		rpc_id(0," fell asleep while playing.",players[players_queue[queue]],colors[players_queue[queue]])
		queue += 1
		rpc_id(0,"Timer",time)
	if skip == 2:
		queue += 1

	if queue > players_queue.size():
		queue = 1
		if players_queue[queue] == 0:
			queue += 1

	if players_queue[queue] == 0:
		queue += 1
		if players_queue[queue] == 0:
			queue += 1

	print("Очередь игрока " + str(queue))
	if queue == 1:
		if player1_info["state"] == "Prisoner":
			rpc_id(players_queue[queue],"unlock_P_bar")
			rpc_id(0,"Timer",time)
			return
	elif queue == 2:
		if player2_info["state"] == "Prisoner":
			rpc_id(players_queue[queue],"unlock_P_bar")
			rpc_id(0,"Timer",time)
			return
	elif queue == 3:
		if player3_info["state"] == "Prisoner":
			rpc_id(players_queue[queue],"unlock_P_bar")
			rpc_id(0,"Timer",time)
			return
	elif queue == 4:
		if player4_info["state"] == "Prisoner":
			rpc_id(players_queue[queue],"unlock_P_bar")
			rpc_id(0,"Timer",time)
			return
	rpc_id(players_queue[queue],"unlock_button")
	rpc_id(0,"turn_color",queue)
	rpc_id(0,"Timer",time+1)
	rpc_id(players_queue[queue],"Timer",time)

func Player_move():
	if queue == 1:
		print("Игрок 1 сделал ход")
		if player1_info["curentCell"] + (roll1+roll2) > 36:
			player1_info["curentCell"] = (player1_info["curentCell"] + (roll1+roll2)) - 36
			player1_info["budget"] += 5000
			rpc_id(0,"budgetFix",player1_info["budget"],1)
		else:
			player1_info["curentCell"] = player1_info["curentCell"] + (roll1+roll2)
		rpc_id(0,"Player_move",1,cellPosition[player1_info["curentCell"]])
		if player1_info["curentCell"] == 1:
			queue += 1
			queue_button_unlock(0)
			return
		elif player1_info["curentCell"] == 10:
			queue += 1
			player1_info["state"] = "Prisoner"
			rpc_id(0,"message","went to jail.",players[players_queue[1]],colors[players_queue[1]])
			queue_button_unlock(0)
			return
		elif player1_info["curentCell"] == 19:
			rpc_id(players_queue[1],"Casion")
			return
		elif player1_info["curentCell"] == 28:
			queue += 1
			player1_info["state"] = "Prisoner"
			rpc_id(0,"message","went to jail.",players[players_queue[1]],colors[players_queue[1]])
			rpc_id(0,"Player_move",1,cellPosition[10])
			player1_info["curentCell"] = 10
			queue_button_unlock(0)
			return
		elif player1_info["curentCell"] == 3:
			queue += 1
			queue_button_unlock(0)
			Chance(1)
			return
		elif player1_info["curentCell"] == 7:
			queue += 1
			queue_button_unlock(0)
			Chance(1)
			return
		elif player1_info["curentCell"] == 16:
			queue += 1
			queue_button_unlock(0)
			Chance(1)
			return
		elif player1_info["curentCell"] == 21:
			queue += 1
			queue_button_unlock(0)
			Chance(1)
			return
		elif player1_info["curentCell"] == 31:
			queue += 1
			queue_button_unlock(0)
			Chance(1)
			return
		elif player1_info["curentCell"] == 35:
			queue += 1
			queue_button_unlock(0)
			Chance(1)
			return
		else:
			if cellOwner[player1_info["curentCell"]] == 0:
				rpc_id(players_queue[queue],"showBuyPanel",1)
			elif cellOwner[player1_info["curentCell"]] == 1 or cellOwner[player1_info["curentCell"]] == 11 or cellOwner[player1_info["curentCell"]] == 12 or cellOwner[player1_info["curentCell"]] == 13 or cellOwner[player1_info["curentCell"]] == 14:
				queue += 1
				queue_button_unlock(0)
				return
			else:
				player1_info["budget"] = player1_info["budget"] - cellPrice[player1_info["curentCell"]]
				rpc_id(0,"budgetFix",player1_info["budget"],1)
				var text = str(players[players_queue[1]])+" paid " + str(players[players_queue[cellOwner[player1_info["curentCell"]]]]) + " for the rent "+str(cellPrice[player1_info["curentCell"]])+"$"#Поменять цену клетки на его оренду позже
				rpc_id(0,"message",text,players[players_queue[1]],1)
				queue += 1
				queue_button_unlock(0)
		

	elif queue == 2:
		print("Игрок 2 сделал ход")
		if player2_info["curentCell"] + (roll1+roll2) > 36:
			player2_info["curentCell"] = (player2_info["curentCell"] + (roll1+roll2)) - 36
			player2_info["budget"] += 5000
			rpc_id(0,"budgetFix",player2_info["budget"],2)
		else:
			player2_info["curentCell"] = player2_info["curentCell"] + (roll1+roll2)
		rpc_id(0,"Player_move",2,cellPosition[player2_info["curentCell"]])
		if player2_info["curentCell"] == 1:
			queue += 1
			queue_button_unlock(0)
			return
		elif player2_info["curentCell"] == 10:
			queue += 1
			player2_info["state"] = "Prisoner"
			rpc_id(0,"message","went to jail.",players[players_queue[2]],colors[players_queue[2]])
			queue_button_unlock(0)
			return
		elif player2_info["curentCell"] == 19:
			rpc_id(players_queue[2],"Casion")
			return
		elif player2_info["curentCell"] == 28:
			queue += 1
			player2_info["state"] = "Prisoner"
			rpc_id(0,"message","went to jail.",players[players_queue[2]],colors[players_queue[2]])
			rpc_id(0,"Player_move",2,cellPosition[10])
			player2_info["curentCell"] = 10
			queue_button_unlock(0)
			return
		elif player2_info["curentCell"] == 3:
			queue += 1
			queue_button_unlock(0)
			Chance(2)
			return
		elif player2_info["curentCell"] == 7:
			queue += 1
			queue_button_unlock(0)
			Chance(2)
			return
		elif player2_info["curentCell"] == 16:
			queue += 1
			queue_button_unlock(0)
			Chance(2)
			return
		elif player2_info["curentCell"] == 21:
			queue += 1
			queue_button_unlock(0)
			Chance(2)
			return
		elif player2_info["curentCell"] == 31:
			queue += 1
			queue_button_unlock(0)
			Chance(2)
			return
		elif player2_info["curentCell"] == 35:
			queue += 1
			queue_button_unlock(0)
			Chance(2)
			return
		else:
			if cellOwner[player2_info["curentCell"]] == 0:
				rpc_id(players_queue[queue],"showBuyPanel",1)
			elif cellOwner[player2_info["curentCell"]] == 2 or cellOwner[player2_info["curentCell"]] == 11 or cellOwner[player2_info["curentCell"]] == 12 or cellOwner[player2_info["curentCell"]] == 13 or cellOwner[player2_info["curentCell"]] == 14:
				queue += 1
				queue_button_unlock(0)
				return
			else:
				player2_info["budget"] = player2_info["budget"] - cellPrice[player2_info["curentCell"]]
				rpc_id(0,"budgetFix",player2_info["budget"],2)
				var text = str(players[players_queue[2]])+" paid " + str(players[players_queue[cellOwner[player2_info["curentCell"]]]]) + " for the rent "+str(cellPrice[player2_info["curentCell"]])+"$"#Поменять цену клетки на его оренду позже
				rpc_id(0,"message",text,players[players_queue[2]],2)
				queue += 1
				queue_button_unlock(0)

	elif queue == 3:
		print("Игрок 3 сделал ход")
		if player3_info["curentCell"] + (roll1+roll2) > 36:
			player3_info["curentCell"] = (player3_info["curentCell"] + (roll1+roll2)) - 36
			player3_info["budget"] += 5000
			rpc_id(0,"budgetFix",player2_info["budget"],3)
		else:
			player3_info["curentCell"] = player3_info["curentCell"] + (roll1+roll2)
		rpc_id(0,"Player_move",3,cellPosition[player3_info["curentCell"]])
		if player3_info["curentCell"] == 1:
			queue += 1
			queue_button_unlock(0)
			return
		elif player3_info["curentCell"] == 10:
			queue += 1
			player3_info["state"] = "Prisoner"
			rpc_id(0,"message","went to jail.",players[players_queue[3]],colors[players_queue[3]])
			queue_button_unlock(0)
			return
		elif player3_info["curentCell"] == 19:
			rpc_id(players_queue[3],"Casion")
			return
		elif player3_info["curentCell"] == 28:
			queue += 1
			player3_info["state"] = "Prisoner"
			rpc_id(0,"message","went to jail.",players[players_queue[3]],colors[players_queue[3]])
			rpc_id(0,"Player_move",3,cellPosition[10])
			player3_info["curentCell"] = 10
			queue_button_unlock(0)
			return
		elif player3_info["curentCell"] == 3:
			queue += 1
			queue_button_unlock(0)
			Chance(3)
			return
		elif player3_info["curentCell"] == 7:
			queue += 1
			queue_button_unlock(0)
			Chance(3)
			return
		elif player3_info["curentCell"] == 16:
			queue += 1
			queue_button_unlock(0)
			Chance(3)
			return
		elif player3_info["curentCell"] == 21:
			queue += 1
			queue_button_unlock(0)
			Chance(3)
			return
		elif player3_info["curentCell"] == 31:
			queue += 1
			queue_button_unlock(0)
			Chance(3)
			return
		elif player3_info["curentCell"] == 35:
			queue += 1
			queue_button_unlock(0)
			Chance(3)
			return
		else:
			if cellOwner[player3_info["curentCell"]] == 0:
				rpc_id(players_queue[queue],"showBuyPanel",1)
			elif cellOwner[player3_info["curentCell"]] == 3 or cellOwner[player3_info["curentCell"]] == 11 or cellOwner[player3_info["curentCell"]] == 12 or cellOwner[player3_info["curentCell"]] == 13 or cellOwner[player3_info["curentCell"]] == 14:
				queue += 1
				queue_button_unlock(0)
				return
			else:
				player3_info["budget"] = player3_info["budget"] - cellPrice[player3_info["curentCell"]]
				rpc_id(0,"budgetFix",player3_info["budget"],3)
				var text = str(players[players_queue[3]])+" paid " + str(players[players_queue[cellOwner[player3_info["curentCell"]]]]) + " for the rent "+str(cellPrice[player3_info["curentCell"]])+"$"#Поменять цену клетки на его оренду позже
				rpc_id(0,"message",text,players[players_queue[3]],3)
				queue += 1
				queue_button_unlock(0)
				
	elif queue == 4:
		print("Игрок 4 сделал ход")
		if player4_info["curentCell"] + (roll1+roll2) > 36:
			player4_info["curentCell"] = (player4_info["curentCell"] + (roll1+roll2)) - 36
			player4_info["budget"] += 5000
			rpc_id(0,"budgetFix",player4_info["budget"],4)
		else:
			player4_info["curentCell"] = player4_info["curentCell"] + (roll1+roll2)
		rpc_id(0,"Player_move",4,cellPosition[player4_info["curentCell"]])
		if player4_info["curentCell"] == 1:
			queue += 1
			queue_button_unlock(0)
			return
		elif player4_info["curentCell"] == 10:
			queue += 1
			player4_info["state"] = "Prisoner"
			rpc_id(0,"message","went to jail.",players[players_queue[4]],colors[players_queue[4]])
			queue_button_unlock(0)
			return
		elif player4_info["curentCell"] == 19:
			rpc_id(players_queue[4],"Casion")
			return
		elif player4_info["curentCell"] == 28:
			queue += 1
			player4_info["state"] = "Prisoner"
			rpc_id(0,"message","went to jail.",players[players_queue[4]],colors[players_queue[4]])
			rpc_id(0,"Player_move",4,cellPosition[10])
			player4_info["curentCell"] = 10
			queue_button_unlock(0)
			return
		elif player4_info["curentCell"] == 4:
			queue += 1
			queue_button_unlock(0)
			Chance(4)
			return
		elif player4_info["curentCell"] == 7:
			queue += 1
			queue_button_unlock(0)
			Chance(4)
			return
		elif player4_info["curentCell"] == 16:
			queue += 1
			queue_button_unlock(0)
			Chance(4)
			return
		elif player4_info["curentCell"] == 21:
			queue += 1
			queue_button_unlock(0)
			Chance(4)
			return
		elif player4_info["curentCell"] == 31:
			queue += 1
			queue_button_unlock(0)
			Chance(4)
			return
		elif player4_info["curentCell"] == 35:
			queue += 1
			queue_button_unlock(0)
			Chance(4)
			return
		else:
			if cellOwner[player4_info["curentCell"]] == 0:
				rpc_id(players_queue[queue],"showBuyPanel",1)
			elif cellOwner[player4_info["curentCell"]] == 4 or cellOwner[player4_info["curentCell"]] == 11 or cellOwner[player4_info["curentCell"]] == 12 or cellOwner[player4_info["curentCell"]] == 13 or cellOwner[player4_info["curentCell"]] == 14:
				queue += 1
				queue_button_unlock(0)
				return
			else:
				player4_info["budget"] = player4_info["budget"] - cellPrice[player4_info["curentCell"]]
				rpc_id(0,"budgetFix",player4_info["budget"],4)
				var text = str(players[players_queue[4]])+" paid " + str(players[players_queue[cellOwner[player4_info["curentCell"]]]]) + " for the rent "+str(cellPrice[player4_info["curentCell"]])+"$"#Поменять цену клетки на его оренду позже
				rpc_id(0,"message",text,players[players_queue[4]],4)
				queue += 1
				queue_button_unlock(0)

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
	queue += 1
	queue_button_unlock(0)

remote func get_swap(player2,player1):
	var player
	for n in players_queue:
		if players_queue[n] == player2:
			player = n
	var Players1 = {}
	var Players2 = {}
	var count1 = 0
	var count2 = 0
	for p in cellOwner:
		if cellOwner[p] == player:
			Players2[count2] = cellNames[p]
			count2 += 1
		if cellOwner[p] == player1:
			Players1[count1] = cellNames[p]
			count1 += 1
	rpc_id(player2,"return_swap",Players1,Players2)

remote func swapSubmit(FP,SP,pSwap,pSubmit,money):
	var pSwapArr = {}
	var pSubmitArr = {}
	var arr1 = 0
	var arr2 = 0
	for n in cellOwner:
		if cellOwner[n] == pSwap:
			pSwapArr[arr1] = n
			arr1 += 1
		if cellOwner[n] == pSubmit:
			pSubmitArr[arr2] = n
			arr2 += 1
	#print("Player #"+str(pSubmit)+" want to swap card " + cellNames[pSwapArr[FP]] + " on his " + str(cellNames[pSubmitArr[SP]]))
	#print(money)
	deal[0] = pSwap
	deal[1] = pSubmit
	deal[2] = FP
	deal[3] = SP
	deal[5] = money
	if SP != -1:
		rpc_id(players_queue[pSwap],"swapCatch",players[players_queue[pSubmit]],cellNames[pSwapArr[FP]],cellNames[pSubmitArr[SP]],money)
	else:
		print(SP)
		rpc_id(players_queue[pSwap],"swapCatch",players[players_queue[pSubmit]],cellNames[pSwapArr[FP]],-1,money)

remote func swapAccepted(ans):
	if ans == 1:
		var pSwapArr = {}
		var pSubmitArr = {}
		var arr1 = 0
		var arr2 = 0
		for n in cellOwner:
			if cellOwner[n] == deal[0]:
				pSwapArr[arr1] = n
				arr1 += 1
			if cellOwner[n] == deal[1]:
				pSubmitArr[arr2] = n
				arr2 += 1
		rpc_id(0,"colorChange", deal[1],pSwapArr[deal[2]])
		cellOwner[pSwapArr[deal[2]]] = deal[1]
		if deal[3] != -1:
			rpc_id(0,"colorChange", deal[0],pSubmitArr[deal[3]])
			cellOwner[pSubmitArr[deal[3]]] = deal[0]
		if deal[5] != 0:
			if deal[0] == 1:
				player1_info["budget"] += deal[5]
				rpc_id(0,"budgetFix",player1_info["budget"],deal[0])
			if deal[0] == 2:
				player2_info["budget"] += deal[5]
				rpc_id(0,"budgetFix",player2_info["budget"],deal[0])
			if deal[0] == 3:
				player3_info["budget"] += deal[5]
				rpc_id(0,"budgetFix",player3_info["budget"],deal[0])
			if deal[0] == 4:
				player4_info["budget"] += deal[5]
				rpc_id(0,"budgetFix",player4_info["budget"],deal[0])

			if deal[1] == 1:
				player1_info["budget"] -= deal[5]
				rpc_id(0,"budgetFix",player1_info["budget"],deal[1])
			if deal[1] == 2:
				player2_info["budget"] -= deal[5]
				rpc_id(0,"budgetFix",player2_info["budget"],deal[1])
			if deal[1] == 3:
				player3_info["budget"] -= deal[5]
				rpc_id(0,"budgetFix",player3_info["budget"],deal[1])
			if deal[1] == 4:
				player4_info["budget"] -= deal[5]
				rpc_id(0,"budgetFix",player4_info["budget"],deal[1])
			
	else:
		pass

remote func upgradePress(requster,player):
	var UpgradeArrNum = {}
	var UpgradeArrName = {}
	var arr = {}
	var Purple
	var dirtyGreen
	var Aqua
	var Orange
	var Red
	var darkPink
	var Blue
	var Gold
	var Green
	var Pink
	var arr1 = 0
	for n in cellOwner:
		if cellOwner[n] == player or cellOwner[n] == (player + 10):
			UpgradeArrNum[arr1] = n
			arr1 += 1
	
	for a in cellGroup["Purple"].size():
		for i in UpgradeArrNum:
			if UpgradeArrNum[i] == cellGroup["Purple"][a]:
				arr[a] = UpgradeArrNum[i]
	if arr.size() == 2:
		Purple = true
	arr.clear()

	for a in cellGroup["dirtyGreen"].size():
		for i in UpgradeArrNum:
			if UpgradeArrNum[i] == cellGroup["dirtyGreen"][a]:
				arr[a] = UpgradeArrNum[i]
	if arr.size() == 3:
		dirtyGreen = true
	arr.clear()

	for a in cellGroup["Aqua"].size():
		for i in UpgradeArrNum:
			if UpgradeArrNum[i] == cellGroup["Aqua"][a]:
				arr[a] = UpgradeArrNum[i]
	if arr.size() == 3:
		Aqua = true
	arr.clear()

	for a in cellGroup["Orange"].size():
		for i in UpgradeArrNum:
			if UpgradeArrNum[i] == cellGroup["Orange"][a]:
				arr[a] = UpgradeArrNum[i]
	if arr.size() == 2:
		Orange = true
	arr.clear()

	for a in cellGroup["Red"].size():
		for i in UpgradeArrNum:
			if UpgradeArrNum[i] == cellGroup["Red"][a]:
				arr[a] = UpgradeArrNum[i]
	if arr.size() == 2:
		Red = true
	arr.clear()

	for a in cellGroup["darkPink"].size():
		for i in UpgradeArrNum:
			if UpgradeArrNum[i] == cellGroup["darkPink"][a]:
				arr[a] = UpgradeArrNum[i]
	if arr.size() == 3:
		darkPink = true
	arr.clear()

	for a in cellGroup["Blue"].size():
		for i in UpgradeArrNum:
			if UpgradeArrNum[i] == cellGroup["Blue"][a]:
				arr[a] = UpgradeArrNum[i]
	if arr.size() == 3:
		Blue = true
	arr.clear()

	for a in cellGroup["Gold"].size():
		for i in UpgradeArrNum:
			if UpgradeArrNum[i] == cellGroup["Gold"][a]:
				arr[a] = UpgradeArrNum[i]
	if arr.size() == 2:
		Gold = true
	arr.clear()

	for a in cellGroup["Green"].size():
		for i in UpgradeArrNum:
			if UpgradeArrNum[i] == cellGroup["Green"][a]:
				arr[a] = UpgradeArrNum[i]
	if arr.size() == 4:
		Green = true
	arr.clear()

	for a in cellGroup["Pink"].size():
		for i in UpgradeArrNum:
			if UpgradeArrNum[i] == cellGroup["Pink"][a]:
				arr[a] = UpgradeArrNum[i]
	if arr.size() == 2:
		Pink = true
	arr.clear()

	UpgradeArrNum.clear()
	var count = 0
	if Purple == true:
		for i in cellGroup["Purple"].size():
			UpgradeArrNum[count] = cellGroup["Purple"][i]
			count += 1
	if dirtyGreen == true:
		for i in cellGroup["dirtyGreen"].size():
			UpgradeArrNum[count] = cellGroup["dirtyGreen"][i]
			count += 1
	if Aqua == true:
		for i in cellGroup["Aqua"].size():
			UpgradeArrNum[count] = cellGroup["Aqua"][i]
			count += 1
	if Orange == true:
		for i in cellGroup["Orange"].size():
			UpgradeArrNum[count] = cellGroup["Orange"][i]
			count += 1
	if Red == true:
		for i in cellGroup["Red"].size():
			UpgradeArrNum[count] = cellGroup["Red"][i]
			count += 1
	if darkPink == true:
		for i in cellGroup["darkPink"].size():
			UpgradeArrNum[count] = cellGroup["darkPink"][i]
			count += 1
	if Blue == true:
		for i in cellGroup["Blue"].size():
			UpgradeArrNum[count] = cellGroup["Blue"][i]
			count += 1
	if Gold == true:
		for i in cellGroup["Gold"].size():
			UpgradeArrNum[count] = cellGroup["Gold"][i]
			count += 1
	if Green == true:
		for i in cellGroup["Green"].size():
			UpgradeArrNum[count] = cellGroup["Green"][i]
			count += 1
	if Pink == true:
		for i in cellGroup["Pink"].size():
			UpgradeArrNum[count] = cellGroup["Pink"][i]
			count += 1
	players_up[str(player)] = UpgradeArrNum
	for n in UpgradeArrNum:
		UpgradeArrName[n] = cellNames[UpgradeArrNum[n]]
	rpc_id(requster,"upgradeReturn",UpgradeArrName)

remote func priceGet(i,requster,player):
	var card
	var cellP
	for n in players_up[str(player)]:
		if n == i:
			card = players_up[str(player)][n]
	cellP = cellPrice[card] + ((cellPrice[card] * 40)/100)
	rpc_id(requster,"priceSet",cellNames[card],cellP)

remote func upgradePressed(requster,player,i):
	var card
	var cellP
	for n in players_up[str(player)]:
		if n == i:
			card = players_up[str(player)][n]
	cellP = cellPrice[card] + ((cellPrice[card] * 40)/100)
	cellPrice[card] = cellP
	if player == 1:
		player1_info["budget"] -= cellP
		rpc_id(0,"budgetFix",player1_info["budget"],player)
	elif player == 2:
		player2_info["budget"] -= cellP
		rpc_id(0,"budgetFix",player2_info["budget"],player)
	elif player == 3:
		player3_info["budget"] -= cellP
		rpc_id(0,"budgetFix",player3_info["budget"],player)
	elif player == 4:
		player4_info["budget"] -= cellP
		rpc_id(0,"budgetFix",player4_info["budget"],player)
	rpc_id(0,"cellUpdated",card)

func Chance(player):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var moneys = rng.randi_range(0,5)
	var Phrase = rng.randi_range(0,5)
	var Operation = rng.randi_range(0,1)
	var text
	if Operation == 0:
		text = phraseSub[Phrase] + " - " + str(money[moneys]) + "$."
		if player == 1:
			player1_info["budget"] -= money[moneys]
			rpc_id(0,"budgetFix",player1_info["budget"],player)
			rpc_id(0,"message",text,players[players_queue[player]],colors[players_queue[player]])
		if player == 2:
			player2_info["budget"] -= money[moneys]
			rpc_id(0,"budgetFix",player2_info["budget"],player)
			rpc_id(0,"message",text,players[players_queue[player]],colors[players_queue[player]])
		if player == 3:
			player3_info["budget"] -= money[moneys]
			rpc_id(0,"budgetFix",player3_info["budget"],player)
			rpc_id(0,"message",text,players[players_queue[player]],colors[players_queue[player]])
		if player == 4:
			player4_info["budget"] -= money[moneys]
			rpc_id(0,"budgetFix",player4_info["budget"],player)
			rpc_id(0,"message",text,players[players_queue[player]],colors[players_queue[player]])
	else:
		text = phraseAdd[Phrase] + " + " + str(money[moneys]) + "$."
		if player == 1:
			player1_info["budget"] += money[moneys]
			rpc_id(0,"budgetFix",player1_info["budget"],player)
			rpc_id(0,"message",text,players[players_queue[player]],colors[players_queue[player]])
		if player == 2:
			player2_info["budget"] += money[moneys]
			rpc_id(0,"budgetFix",player2_info["budget"],player)
			rpc_id(0,"message",text,players[players_queue[player]],colors[players_queue[player]])
		if player == 3:
			player3_info["budget"] += money[moneys]
			rpc_id(0,"budgetFix",player3_info["budget"],player)
			rpc_id(0,"message",text,players[players_queue[player]],colors[players_queue[player]])
		if player == 4:
			player4_info["budget"] += money[moneys]
			rpc_id(0,"budgetFix",player4_info["budget"],player)
			rpc_id(0,"message",text,players[players_queue[player]],colors[players_queue[player]])

remote func buyOffPressed(requster,player):
	if player == 1:
		player1_info["budget"] -= 1000
		rpc_id(0,"budgetFix",player1_info["budget"],player)
		queue += 1
		player1_info["state"] = "free"
		queue_button_unlock(0)
		return
	if player == 2:
		player2_info["budget"] -= 1000
		rpc_id(0,"budgetFix",player2_info["budget"],player)
		queue += 1
		player2_info["state"] = "free"
		queue_button_unlock(0)
		return
	if player == 3:
		player3_info["budget"] -= 1000
		rpc_id(0,"budgetFix",player3_info["budget"],player)
		queue += 1
		player3_info["state"] = "free"
		queue_button_unlock(0)
		return
	if player == 4:
		player4_info["budget"] -= 1000
		rpc_id(0,"budgetFix",player4_info["budget"],player)
		queue += 1
		player4_info["state"] = "free"
		queue_button_unlock(0)
		return
	pass

remote func casionCansel():
	queue += 1
	queue_button_unlock(0)

remote func depositPressed(requster,player):
	var PlayerArr = {}
	var NamesArr = {}
	var count = 0
	for i in cellOwner:
		if cellOwner[i] == player or cellOwner[i] == player + 10:
			PlayerArr[count] = i
			count += 1
	for n in PlayerArr:
		NamesArr[n] = cellNames[PlayerArr[n]]
	rpc_id(requster,"DepositReturn",NamesArr)

remote func Deposit(DP,requster,player):
	var UpgradeArrNum = {}
	var arr1 = 0
	for i in cellOwner:
		if cellOwner[i] == player or cellOwner[i] == player + 10:
			UpgradeArrNum[arr1] = i
			arr1 += 1
	cellOwner[UpgradeArrNum[DP]] += 10
	rpc_id(0,"colorChange", 5,UpgradeArrNum[DP])
	if player == 1:
		player1_info["budget"] += cellPrice[UpgradeArrNum[DP]]
		rpc_id(0,"budgetFix",player1_info["budget"],player)
	if player == 2:
		player2_info["budget"] += cellPrice[UpgradeArrNum[DP]]
		rpc_id(0,"budgetFix",player2_info["budget"],player)
	if player == 3:
		player3_info["budget"] += cellPrice[UpgradeArrNum[DP]]
		rpc_id(0,"budgetFix",player3_info["budget"],player)
	if player == 4:
		player4_info["budget"] += cellPrice[UpgradeArrNum[DP]]
		rpc_id(0,"budgetFix",player4_info["budget"],player)
	pass

remote func UnDeposit(DP,requster,player):
	var UpgradeArrNum = {}
	var arr1 = 0
	for i in cellOwner:
		if cellOwner[i] == player or cellOwner[i] == player + 10:
			UpgradeArrNum[arr1] = i
			arr1 += 1
	cellOwner[UpgradeArrNum[DP]] -= 10
	rpc_id(0,"colorChange", player,UpgradeArrNum[DP])
	if player == 1:
		player1_info["budget"] -= cellPrice[UpgradeArrNum[DP]]
		rpc_id(0,"budgetFix",player1_info["budget"],player)
	if player == 2:
		player2_info["budget"] -= cellPrice[UpgradeArrNum[DP]]
		rpc_id(0,"budgetFix",player2_info["budget"],player)
	if player == 3:
		player3_info["budget"] -= cellPrice[UpgradeArrNum[DP]]
		rpc_id(0,"budgetFix",player3_info["budget"],player)
	if player == 4:
		player4_info["budget"] -= cellPrice[UpgradeArrNum[DP]]
		rpc_id(0,"budgetFix",player4_info["budget"],player)
	pass

remote func dItemCheck(DP,requster,player):
	var UpgradeArrNum = {}
	var arr1 = 0
	for i in cellOwner:
		if cellOwner[i] == player or cellOwner[i] == player + 10:
			UpgradeArrNum[arr1] = i
			arr1 += 1
	if cellOwner[UpgradeArrNum[DP]] == player + 10:
		rpc_id(requster,"dItemReturn",1)
		pass
	elif cellOwner[UpgradeArrNum[DP]] == player:
		rpc_id(requster,"dItemReturn",0)
		pass

remote func CanselClick(Player):
	queue += 1
	queue_button_unlock(0)
	rpc_id(players_queue[Player],"showBuyPanel",0)

remote func get_info(card,requster,player):
	rpc_id(requster,"set_info",cellNames[card],cellPrice[card],((cellPrice[card] * 40)/100))

remote func cansede(requster,player):
	queue_button_unlock(2)
	
	players_queue[player] = 0
	
#	players_queue.erase(player)
#	var temp = players_queue.duplicate()
#	players_queue.clear()
	
#	var arr = temp.keys()
	
#	for i in arr.size():
#		players_queue[i+1] = temp[arr[i]]

