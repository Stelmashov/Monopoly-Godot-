extends Control

func _ready():
	Server.connect("message",self,"message")
	Server.connect("rolled",self,"rolled")

func _on_Send_pressed():
	Server.chat($Panel/LineEdit.text)

func message(mestext,name,color):
	var curent_mes_position = $Panel/ChatWindow.get_item_count()
	#$Panel/ChatWindow.set_item_custom_fg_color(0,Color.red)
	$Panel/ChatWindow.add_item(name + " : " + mestext)
	if color == 1:
		$Panel/ChatWindow.set_item_custom_fg_color(curent_mes_position,Color("e37474"))
	elif color == 2:
		$Panel/ChatWindow.set_item_custom_fg_color(curent_mes_position,Color("83fb82"))
	elif color == 3:
		$Panel/ChatWindow.set_item_custom_fg_color(curent_mes_position,Color("807fff"))
	elif color == 4:
		$Panel/ChatWindow.set_item_custom_fg_color(curent_mes_position,Color("fff33e"))

func rolled(roll, player):
	$Panel/ChatWindow.add_item(str(player) + " rolled number " + str(roll))
