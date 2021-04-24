extends Node

signal player_list_changed()
signal players_name()
signal rolled()
signal queue()

var network = NetworkedMultiplayerENet.new()#Создание пира
var port = 10567#Дефолтный порт
#var ip = "127.0.0.1"#Дефолтный ип
var ip = "192.168.0.124"

var player_name = ""#Дефолтное имя игрока
var players = {}

func _ready():
	pass

func ConnectToServer(name):#Функция соеденения с сервером
	
	player_name = name
	network.create_client(ip,port)
	get_tree().network_peer = network
	
	network.connect("connection_succeeded",self,"_OnConnectionSucceeded")#При удачном соеденение
	network.connect("connection_failed",self,"_OnConnectionFailed")#При не удачном
	#print(network.get_unique_id())

func Register_Players():#Регистрация игроков при удачно входе на сервер
	rpc_id(1,"register_player",player_name)#Запрос регистрации на сервер
	rpc_id(1,"player_list",get_instance_id())

func _OnConnectionSucceeded():#Срабатывает при удачно входе на сервер
	print("Succesfully connected")
	Register_Players()#вызов функции на регистрации игровка в словаре

func _OnConnectionFailed():#При не удачном коннекте
	print("Failed to connect")

func get_player_name():#Функция на запрос имени игрока
	return player_name

remote func refresh_lobby(player_list):#Функция обновления списка игроков
	emit_signal("player_list_changed", player_list)

func start_game():
	rpc_id(1,"player_ready",get_tree().get_network_unique_id())

remote func all_ready():
	print("All players ready, game will be started...")
	# Change scene.
	var world = load("res://Scenes/World.tscn").instance()
	get_tree().get_root().add_child(world)
	get_tree().get_root().get_node("Lobby").hide()

func get_players_names():
	rpc_id(1,"get_players_names",get_tree().get_network_unique_id())

remote func return_players_names(player_list):
	emit_signal("players_name", player_list)

func roll_dice():
	rpc_id(1,"roll_dice",get_tree().get_network_unique_id())

remote func rolled(roll,player):
	emit_signal("rolled", roll, player)

func queue_button_unlock():
	rpc_id(1,"queue_button_unlock")

remote func unlock_button():
		emit_signal("queue")
