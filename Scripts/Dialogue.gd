extends CanvasLayer

@export var LevelNumber : int
@export var dialogueSounds : AudioStreamPlayer
@export var text : Label
@export var lettersPerSecond : float
@export var currentDialogue : int
@export var SpeakerImage : TextureRect
@export var player : CharacterBody2D
@export var dialogueAnimator : AnimationPlayer
@export var CutsceneAnimator : AnimationPlayer
@export var CutsceneThings : Node2D
@export var properCamera : Camera2D
@export var NextLevel : String
@export var Fader : AnimationPlayer
@export var MusicFader : AnimationPlayer

@export_multiline var dialogue : Array[String]

var textCurrentlyDisplayed : float
var loadingIn : bool
var speaking : bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# if still loading in, then make the visible characters go up
	if (loadingIn):
		textCurrentlyDisplayed += delta
		text.set_visible_characters(round(textCurrentlyDisplayed*lettersPerSecond))
		if (text.visible_characters >= text.get_total_character_count()):
			loadingIn = false

func setSpeaker(speaker):
	match(speaker.to_lower()):
		'r':
			SpeakerImage.texture = load("res://Art/Cubes/RedCube.png")
			dialogueSounds.set_stream(load("res://Sounds/UI/red.wav"))
			dialogueSounds.play()
		'g':
			SpeakerImage.texture = load("res://Art/Cubes/GreenCube.png")
			dialogueSounds.set_stream(load("res://Sounds/UI/Green.wav"))
			dialogueSounds.play()
		'b':
			SpeakerImage.texture = load("res://Art/Cubes/BlueCube.png")
			dialogueSounds.set_stream(load("res://Sounds/UI/Blue.wav"))
			dialogueSounds.play()
		_:
			SpeakerImage.texture = load("res://Art/Cubes/HoloCube1.png")
	if (speaker == speaker.to_lower()):
		CutsceneAnimator.play(String.chr(currentDialogue+65))

func changeCurrentDialogue(index):
	if (index < dialogue.size() and dialogue[index] != "/"):
		#tell process that it's loading in
		loadingIn = true
		#reset the visibility
		text.visible_characters = 0
		textCurrentlyDisplayed = 0
		text.text = dialogue[index].substr(1)
		setSpeaker(dialogue[index].substr(0,1))
	else:
		if (index == dialogue.size()-1 and dialogue[index] == "/"):
			toNextLevel()
		speaking = false
		SpeakerImage.hide()
		dialogueAnimator.play("CloseDialogue")
		await dialogueAnimator.animation_finished
		player.process_mode = Node.PROCESS_MODE_INHERIT
		player.enable_children()
		properCamera.make_current()
		player.visible = true
		CutsceneThings.visible = false


func _input(event : InputEvent):
	if (speaking):
		if ((event is InputEventKey and event.is_action_released("ui_accept")) or (event is InputEventMouseButton and event.is_action_pressed("clicky"))):
			if (loadingIn):
				if (Singleton.enabledTextSkip):
					textCurrentlyDisplayed = text.visible_characters * 0.4
			else:
				changeCurrentDialogue(currentDialogue)
				currentDialogue += 1

func start_dialogue():
	loadingIn = true
	dialogueAnimator.play("LoadDialogue")
	await dialogueAnimator.animation_finished
	speaking = true
	SpeakerImage.show()
	changeCurrentDialogue(currentDialogue)
	currentDialogue += 1


func _on_end_area_entered(area):
	player.disable_children()
	show()
	if (!speaking):
		if (area.is_in_group("player")):
			start_dialogue()

func toNextLevel():
	if (Singleton.unlockedLevel <= LevelNumber):
		Singleton.unlockedLevel = LevelNumber+1
		Singleton.give_free_cookies()
	Singleton.currentLevel = LevelNumber+1
	Fader.play("FadeOut")
	MusicFader.play("FadeOut")
	await Fader.animation_finished
	get_tree().change_scene_to_file("res://Scenes/Levels/"+NextLevel)
