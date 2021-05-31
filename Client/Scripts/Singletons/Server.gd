extends Node

var timer

signal player_list_changed()
signal players_name()
signal rolled()
signal queue()
signal Player_move()
signal message()
signal buyPanelShow()
signal cellColorChange()
signal budgetFix()
signal buyPressed()
signal swap()
signal swapCatch()
signal update()
signal priceSet()
signal cellUpdated()
signal unlock_P_bar()
signal casion()
signal rollback()
signal DepositReturn()
signal ItemReturn()

var network = NetworkedMultiplayerENet.new()#Создание пира
var port = 10567#Дефолтный порт
#var ip = "127.0.0.1"#Дефолтный ип
var ip = "192.168.0.124"

var UPP
var FP
var SP = -1
var DP
var pSwap
var PlayerQueue
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
	rpc_id(1,"roll_dice",get_tree().get_network_unique_id(),PlayerQueue,0)

remote func rolled(roll,player):
	emit_signal("rolled", roll, player)

remote func unlock_button():
		emit_signal("queue")

remote func Player_move(Player,position):
	emit_signal("Player_move",Player,position)
	
remote func showBuyPanel(state):
	emit_signal("buyPanelShow",state)

func chat(text):
	rpc_id(1,"message",text,get_tree().get_network_unique_id())

remote func message(text,name,color):
	emit_signal("message",text,name,color)

remote func playerQueue(p):
	PlayerQueue = p

func buy_click():
	rpc_id(1,"playerBuyPressed", PlayerQueue)
	emit_signal("buyPressed")

remote func colorChange(player,cell):
	emit_signal("cellColorChange",player,cell)

remote func budgetFix(budget,player):
	emit_signal("budgetFix",budget,player)

remote func Timer(state):
	timer = state

func Skip(state):
	rpc_id(1,"queue_button_unlock",state)

func get_swap(player):
	rpc_id(1,"get_swap",get_tree().get_network_unique_id(),player)

remote func return_swap(Player1,Player2):
	emit_signal("swap",Player1,Player2)

func swapSubmit(money):
	rpc_id(1,"swapSubmit",FP,SP,pSwap,PlayerQueue,money)

remote func swapCatch(pSubmit,FP,SP,money):
	var label
	if int(SP) != -1:
		if money == 0:
			label = "Player "+str(pSubmit)+" want to swap your " + FP + " on his " + SP
		else:
			label = "Player "+str(pSubmit)+" want to swap your " + FP + " on his " + SP + " and " + str(money) + "$"
	else:
		label = "Player "+str(pSubmit)+" want to swap your " + FP + " on his " + str(money) + "$"
	emit_signal("swapCatch",label)

func swapAccepted(ans):
	rpc_id(1,"swapAccepted",ans)

func upgradePress():
	rpc_id(1,"upgradePress",get_tree().get_network_unique_id(),PlayerQueue)

remote func upgradeReturn(UpgradeArrName):
	emit_signal("update",UpgradeArrName)

func priceGet(i):
	rpc_id(1,"priceGet",i,get_tree().get_network_unique_id(),PlayerQueue)

remote func priceSet(name,price):
	var lable = "Upgrade wood be coust = " +str(price) + "$"
	emit_signal("priceSet",lable)

func upgradePressed():
	rpc_id(1,"upgradePressed",get_tree().get_network_unique_id(),PlayerQueue,UPP)

remote func cellUpdated(card):
	emit_signal("cellUpdated",card)

remote func unlock_P_bar():
	emit_signal("unlock_P_bar")

func doubletPressed():
	rpc_id(1,"roll_dice",get_tree().get_network_unique_id(),PlayerQueue,0)

func buyOffPressed():
	rpc_id(1,"buyOffPressed",get_tree().get_network_unique_id(),PlayerQueue)

remote func Casion():
	emit_signal("casion")

func spinPressed():
	rpc_id(1,"roll_dice",get_tree().get_network_unique_id(),PlayerQueue,1)

remote func CasionRollBack(roll1,roll2):
	emit_signal("rollback",roll1,roll2)

func casionCansel():
	rpc_id(1,"casionCansel")

func depositPressed():
	rpc_id(1,"depositPressed",get_tree().get_network_unique_id(),PlayerQueue)

remote func DepositReturn(arr):
	emit_signal("DepositReturn",arr)

func Deposit():
	rpc_id(1,"Deposit",DP,get_tree().get_network_unique_id(),PlayerQueue)

func UnDeposit():
	rpc_id(1,"UnDeposit",DP,get_tree().get_network_unique_id(),PlayerQueue)

func dItemCheck():
	rpc_id(1,"dItemCheck",DP,get_tree().get_network_unique_id(),PlayerQueue)

remote func dItemReturn(state):
	emit_signal("ItemReturn",state)

func CanselClick():
	rpc_id(1,"CanselClick",PlayerQueue)
