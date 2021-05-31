extends Node2D

func _ready():
	Server.connect("players_name",self,"players_name")
	Server.connect("queue", self, "button_unlock")
	Server.connect("Player_move",self,"Player_move")
	Server.connect("buyPanelShow",self,"buyPanel")
	Server.connect("cellColorChange",self,"cellColorChange")
	Server.connect("budgetFix",self,"budgetFix")
	Server.connect("swap",self,"swap")
	Server.connect("swapCatch",self,"swapCatch")
	Server.connect("update",self,"Update")
	Server.connect("priceSet",self,"priceSet")
	Server.connect("cellUpdated",self,"cellUpdated")
	Server.connect("unlock_P_bar",self,"unlock_P_bar")
	Server.connect("casion",self,"casion")
	Server.connect("rollback",self,"rollback")
	Server.connect("DepositReturn",self,"DepositReturn")
	Server.connect("ItemReturn",self,"ItemReturn")
	
	$Panel/Players_Bar/Player_hud/P1_swap.disabled = true
	$Panel/callUp.disabled = true
	$Deposit_bar/Panel/deposit.disabled = true
	$Deposit_bar/Panel/UNdeposit.disabled = true
	$Panel/callDep.disabled = true
	
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
		$Panel/Players_Bar/Budjet3.hide()
		$Panel/Players_Bar/Budjet4.hide()
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
		$Panel/Players_Bar/Budjet4.hide()
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

func _process(delta):
	if int(Server.timer) == 0:
		if $Panel/Roll.disabled == true:
			Server.Skip(2)
		else:
			Server.Skip(1)
		$Panel/Roll.disabled = true
		$Panel/Players_Bar/Player_hud/P1_swap.disabled = true
		$Panel/callUp.disabled = true
		$Deposit_bar/Panel/deposit.disabled = true
		$Deposit_bar/Panel/UNdeposit.disabled = true
		#Server.chat(" fell asleep while playing")#Фиксить можно только через новый метод
	elif int(Server.timer) > 0:
		Server.timer = Server.timer - delta
		$Timer.value = int(Server.timer)
		$Time.set_text(str(int(Server.timer)))

func _on_Roll_pressed():
	$Panel/Roll.disabled = true
	$Panel/Players_Bar/Player_hud/P1_swap.disabled = true
	$Panel/callUp.disabled = true
	$Deposit_bar/Panel/deposit.disabled = true
	$Deposit_bar/Panel/UNdeposit.disabled = true
	Server.roll_dice()

func button_unlock():
	$Panel/Players_Bar/Player_hud/P1_swap.disabled = false
	$Panel/Roll.disabled = false
	$Panel/callUp.disabled = false
	$Panel/callDep.disabled = false

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
		#Server.timer = -1
		$BuyPanel.hide()
	elif state == 3:
		$BuyPanel/Panel/Buy.modulate = Color.red#Perepist' pozze

func cellColorChange(player,cell):
	var string = NodePath("Panel/Deck/c" + str(cell) + "/color")
	if player == 1:
		get_node(string).modulate = Color.red
	elif player == 2:
		get_node(string).modulate = Color.green
	elif player == 3:
		get_node(string).modulate = Color.blue
	elif player == 4:
		get_node(string).modulate = Color.yellow
	elif player == 5:
		get_node(string).modulate = Color.black

func budgetFix(budget,player):
	#print(budget)
	#print(player)
	var string = NodePath("Panel/Players_Bar/Budjet"+str(player))
	#print(get_node(string))
	get_node(string).text = str(budget)


func _on_P1_swap_pressed():
	$Swap.show()
	Server.get_swap(1)
	Server.pSwap = 1

func _on_Cansel_pressed():
	$Swap.hide()

func swap(Player1,Player2):
	$Swap/Panel/A_Cards.clear()
	$Swap/Panel/B_Cards.clear()
	if Player1.size() == 0:
		$Swap/Panel/A_Cards.focus_mode = Control.FOCUS_NONE
		$Swap/Panel/A_Cards.add_item("Empty")
	if Player2.size() == 0:
		$Swap/Panel/B_Cards.focus_mode = Control.FOCUS_NONE
		$Swap/Panel/B_Cards.add_item("Empty")
	for n in Player1:
		$Swap/Panel/A_Cards.add_item(str(Player1[n]))
	for n in Player2:
		$Swap/Panel/B_Cards.add_item(str(Player2[n]))

func _on_A_Cards_item_selected(index):
	Server.FP = index

func _on_B_Cards_item_selected(index):
	Server.SP = index

func _on_Submit_pressed():
	var money
	if $Swap/Panel/Money.text == "":
		money = 0
	else:
		money = int($Swap/Panel/Money.text)
	Server.swapSubmit(money)
	$Swap.hide()

func swapCatch(label):
	$SwapAccept.show()
	$SwapAccept/Panel/Label.text = label

func _on_Accept_pressed():
	Server.swapAccepted(1)
	$SwapAccept.hide()

func _on_B_Cards_nothing_selected():
	$Swap/Panel/B_Cards.unselect_all()
	Server.SP = -1

func _on_B_Cansel_pressed():
	Server.swapAccepted(0)
	$SwapAccept.hide()


func _on_callUp_pressed():
	$Upgrade_panel.show()
	Server.upgradePress()
	$Upgrade_panel/Panel/ItemList.clear()

func Update(arr):
	for n in arr:
		$Upgrade_panel/Panel/ItemList.add_item(arr[n])

func _on_exit_pressed():
	$Upgrade_panel.hide()


func _on_ItemList_item_selected(index):
	Server.priceGet(index)
	Server.UPP = index

func priceSet(lable):
	$Upgrade_panel/Panel/Label.text = lable


func _on_Upgrade_pressed():
	Server.upgradePressed()

func cellUpdated(card):
	var string = NodePath("Panel/Deck/c" + str(card) + "/Upgrade_ico")
	get_node(string).show()

func _on_doublet_pressed():
	Server.doubletPressed()
	$Prison_bar.hide()

func _on_buy_off_pressed():
	Server.buyOffPressed()
	$Prison_bar.hide()

func unlock_P_bar():
	$Prison_bar.show()


func _on_Spin_pressed():
	Server.spinPressed()
	$Casino/Panel/Spin.disabled = true

func casion():
	$Casino.show()
	$Casino/Panel/Spin.disabled = false

func rollback(roll1,roll2):
	$Casino/Panel/Label.text = str(roll1)
	$Casino/Panel/Label2.text = str(roll2)


func _on_Cansel_But_pressed():
	Server.casionCansel()


func _on_Exit_pressed():
	if $Casino/Panel/Spin.disabled == false:
		Server.casionCansel()
		$Casino.hide()
	else:
		$Casino.hide()


func _on_callDep_pressed():
	$Deposit_bar.show()
	Server.depositPressed()


func _on_deposit_exit_pressed():
	$Deposit_bar.hide()

func DepositReturn(arr):
	$Deposit_bar/Panel/ItemList.clear()
	for i in arr:
		$Deposit_bar/Panel/ItemList.add_item(arr[i])


func _on_DepositList_item_selected(index):
	Server.DP = index
	Server.dItemCheck()


func _on_deposit_pressed():
	Server.Deposit()
	Server.depositPressed()
	$Deposit_bar/Panel/deposit.disabled = true
	$Deposit_bar/Panel/UNdeposit.disabled = true


func _on_UNdeposit_pressed():
	Server.UnDeposit()
	Server.depositPressed()
	$Deposit_bar/Panel/deposit.disabled = true
	$Deposit_bar/Panel/UNdeposit.disabled = true

func ItemReturn(state):
	if state == 1:
		$Deposit_bar/Panel/UNdeposit.disabled = false
		$Deposit_bar/Panel/deposit.disabled = true
	else:
		$Deposit_bar/Panel/UNdeposit.disabled = true
		$Deposit_bar/Panel/deposit.disabled = false
