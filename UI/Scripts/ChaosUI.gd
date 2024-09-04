extends Node2D


var inputField: LineEdit 
var outputLabel: Label
var chatbot = load("res://Objects/Chaos/Scripts/ChatBot.cs").new()

# Called when the node enters the scene tree for the first time.
func _ready():
	inputField = $LineEdit
	outputLabel = $Label


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("Accept"):
		on_text_submitted(inputField.text)
	
func on_text_submitted(text):
	inputField.clear()
	var responce = chatbot.GetBotResponse((String)(text))
	print(responce)
	outputLabel.text = responce
