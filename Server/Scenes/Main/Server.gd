extends Node

var port = 10567                              #дефолтный порт
var max_players = 10                          #кол-во игроков на сервере
var network = NetworkedMultiplayerENet.new()  #Создание подключения

var queue = 1

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
	
remote func player_list(requester):#
	var player_id = get_tree().get_rpc_sender_id()
	print(players.values())
	rpc_id(0, "refresh_lobby", players.values())#Вызов обновления лобби

remote func player_ready(player_id):
	print("Player № " + str(player_id) + "ready for game")
	player_ready.insert(player_ready.size(),player_id)
	if player_ready.size() == players.size():
		rpc_id(0,"all_ready")
		print("All players ready, game will be started...")

remote func get_players_names(player_id):
	rpc_id(0,"return_players_names",players.values())

remote func roll_dice(player_id):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var roll = rng.randi_range(0,12)
	rpc_id(0,"rolled",roll,players[player_id],queue)

remote func queue(player_id):
	#print(players[player_id])
	players_queue[queue] = players[player_id]
	queue += 1
	if players_queue.size() == players.size():
		queue = 1;
		print(queue)

remote func queue_button_unlock():
	if queue == 1:
		rpc_id(players[players_queue[queue]],"unlock_button")
		queue = 2
	elif queue == 2:
		rpc_id(players[players_queue[queue]],"unlock_button")
		queue = 1
		pass
