extends Node2D

func _ready():
	Server.connect("players_name",self,"players_name")
	Server.connect("queue", self, "button_unlock")
	Server.connect("Player_move",self,"Player_move")
	Server.connect("buyPanelShow",self,"buyPanel")
	Server.connect("cellColorChange",self,"cellColorChange")

	Server.get_players_names()

func players_name(players_list):
	var players = players_list
	var count = 0
	players.sort()
	if players.size() == 2:
		$Panel/Players_Bar/Player1.text = players[count]
		count = count + 1
		$Panel/Players_Bar/Player2.text = players[count]
		count = count + 1
		$Panel/Players_Bar/Player3.hide()
		$Panel/Players_Bar/Player4.hide()
		$Panel/Players_Bar/Player_hud3.hide()
		$Panel/Players_Bar/Player_hud4.hide()
		$PLayer3.hide()
		$PLayer4.hide()
	elif players.size() == 3:
		$Panel/Players_Bar/Player1.text = players[count]
		count = count + 1
		$Panel/Players_Bar/Player2.text = players[count]
		count = count + 1
		$Panel/Players_Bar/Player3.text = players[count]
		count = count + 1
		$Panel/Players_Bar/Player4.hide()
		$Panel/Players_Bar/Player_hud4.hide()
		$PLayer4.hide()
	elif players.size() == 4:
		$Panel/Players_Bar/Player1.text = players[count]
		count = count + 1
		$Panel/Players_Bar/Player2.text = players[count]
		count = count + 1
		$Panel/Players_Bar/Player3.text = players[count]
		count = count + 1
		$Panel/Players_Bar/Player4.text = players[count]
		count = count + 1
	count = 0

func _on_Roll_pressed():
	$Panel/Roll.disabled = true
	Server.roll_dice()

func button_unlock():
	$Panel/Roll.disabled = false

func Player_move(Player,position):
	if Player == 1:
		$PLayer.global_position = position
	elif Player == 2:
		$PLayer2.global_position = position
	elif Player == 3:
		$PLayer3.global_position = position
	elif Player == 4:
		$PLayer4.global_position = position

func buyPanel(state):
	if state == 1:
		$BuyPanel.show()
	elif state == 0:
		$BuyPanel.hide()

func cellColorChange(player,cell):
	var string = NodePath("Panel/Deck/c" + str(cell) + "/color")
	print(string)
	#print("$Panel/Deck/" + str(cell) + "/color")
	if player == 1:
		get_node(string).modulate = Color.red
	elif player == 2:
		get_node(string).modulate = Color.green
	elif player == 3:
		get_node(string).modulate = Color.blue
	elif player == 4:
		get_node(string).modulate = Color.yellow
