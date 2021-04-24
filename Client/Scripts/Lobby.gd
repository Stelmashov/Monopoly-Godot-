extends Node2D

func _ready():#Функция срабатывает при старте скрипта
	Server.connect("player_list_changed",self,"refresh_lobby")


func _on_Join_pressed():#Функция, срабатывает при нажатие на конопку джоин в лобби
	if $Connect/Name.text == "":#Проверка на корректность имени
		$Connect/ErrorLabel.text = "Invalid name!"
		return

	$Connect/ErrorLabel.text = ""
	$Connect/Join.disabled = true
		
	Server.ConnectToServer($Connect/Name.text)#Попытка присоедениться к серверу
	
	$Connect.hide()
	$Enviroment/Wires_2.hide()
	$Enviroment/Wires_4.show()
	$Players.show()

func refresh_lobby(player_list):
	var players = player_list
	players.sort()
	$Players/List.clear()
	#print(players.size())
	#$Players/List.add_item(Server.get_player_name() + " (You)")
	for p in players:
		$Players/List.add_item(p)

func _on_start_pressed():
	Server.start_game()
