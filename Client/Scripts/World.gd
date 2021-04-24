extends Node2D

func _ready():
	Server.connect("players_name",self,"players_name")
	Server.connect("rolled",self,"rolled")
	Server.connect("queue", self, "button_unlock")

	Server.get_players_names()

func players_name(players_list):
	var players = players_list
	var count = 0
	players.sort()
	if players.size() == 2:
		$Players_Bar/Player1.set_position(Vector2(262.224,3.61))
		$Players_Bar/Player1.text = players[count]
		count = count + 1
		$Players_Bar/Player2.set_position(Vector2(466.495,3.61))
		$Players_Bar/Player2.text = players[count]
		count = count + 1
		$Players_Bar/Player3.hide()
		$Players_Bar/Player4.hide()
	elif players.size() == 3:
		$Players_Bar/Player1.set_position(Vector2(126.033,3.61))
		$Players_Bar/Player1.text = players[count]
		count = count + 1
		$Players_Bar/Player2.set_position(Vector2(373.016,3.61))
		$Players_Bar/Player2.text = players[count]
		count = count + 1
		$Players_Bar/Player3.set_position(Vector2(614.663,3.61))
		$Players_Bar/Player3.text = players[count]
		count = count + 1
		$Players_Bar/Player4.hide()
	elif players.size() == 4:
		$Players_Bar/Player1.text = players[count]
		count = count + 1
		$Players_Bar/Player2.text = players[count]
		count = count + 1
		$Players_Bar/Player3.text = players[count]
		count = count + 1
		$Players_Bar/Player4.text = players[count]
		count = count + 1
	count = 0

func _on_Roll_pressed():
	$Roll.disabled = true
	Server.roll_dice()
	Server.queue_button_unlock()

func rolled(roll, player):
	$Label.text = str(player) + " rolled number " + str(roll)

func button_unlock():
	$Roll.disabled = false
