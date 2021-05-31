extends Control


func _ready():
	pass


func _on_Buy_pressed():
	Server.buy_click()


func _on_Auction_pressed():
	Server.CanselClick()
