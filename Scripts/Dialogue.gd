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
@export var humanPlayer : AnimatedSprite2D
@export var humanthere : bool = true

@export_multiline var dialogue : Array[String]

var textCurrentlyDisplayed : float
var loadingIn : bool
var speaking : bool = false

var currCubeFont = true
var cubeFont : Font = load("res://Art/Fonts/born2bsporty-fs.regular.otf")
var humanFont : Font = load("res://Art/Fonts/hasting-dee-quickest.regular.otf")

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

func toCubeFont():
	currCubeFont = true
	text.add_theme_font_override("font", cubeFont)
	text.add_theme_font_size_override("font_size", 48)
	text.add_theme_constant_override("line_spacing", -4)
	text.position.y = -21
	if (humanthere && humanPlayer.is_playing() && humanPlayer.animation == "talking"):
		humanPlayer.play("stopTalking")

func toHumanFont():
	currCubeFont = false
	text.remove_theme_font_size_override("bigger")
	text.add_theme_font_override("font", humanFont)
	text.add_theme_font_size_override("font_size", 34)
	text.add_theme_constant_override("line_spacing", 20)
	text.position.y = -6

func setSpeaker(speaker):
	match(speaker.to_lower()):
		'r':
			if (!currCubeFont):
				toCubeFont()
			SpeakerImage.texture = load("res://Art/Cubes/dialogueImages/RedCube.png")
			dialogueSounds.set_stream(load("res://Sounds/UI/red.wav"))
			dialogueSounds.play()
		'g':
			if (!currCubeFont):
				toCubeFont()
			SpeakerImage.texture = load("res://Art/Cubes/dialogueImages/GreenCube.png")
			dialogueSounds.set_stream(load("res://Sounds/UI/Green.wav"))
			dialogueSounds.play()
		'b':
			if (!currCubeFont):
				toCubeFont()
			SpeakerImage.texture = load("res://Art/Cubes/dialogueImages/BlueCube.png")
			dialogueSounds.set_stream(load("res://Sounds/UI/Blue.wav"))
			dialogueSounds.play()
		'i':
			if (!currCubeFont):
				toCubeFont()
			SpeakerImage.texture = load("res://Art/Cubes/dialogueImages/BlueCube.png")
			dialogueSounds.set_stream(load("res://Sounds/UI/impostorBlue.wav"))
			dialogueSounds.play()
		'n':
			if (!currCubeFont):
				toCubeFont()
			SpeakerImage.texture = load("res://Art/Cubes/dialogueImages/NMECube.png")
			dialogueSounds.set_stream(load("res://Sounds/UI/impostorBlue.wav"))
			dialogueSounds.play()
		't','h','u','m','s','e':
			if (currCubeFont):
				toHumanFont()
			if (humanthere && speaker != speaker.to_lower()):
				humanPlayer.play("talking")
			match(speaker.to_lower()):
				't':SpeakerImage.texture = load("res://Art/Cubes/dialogueImages/huthinky.png")
				'h':SpeakerImage.texture = load("res://Art/Cubes/dialogueImages/husurp.png")
				'u':SpeakerImage.texture = load("res://Art/Cubes/dialogueImages/husad.png")
				'm':SpeakerImage.texture = load("res://Art/Cubes/dialogueImages/humad.png")
				's':SpeakerImage.texture = load("res://Art/Cubes/dialogueImages/huserious.png")
				'e':SpeakerImage.texture = load("res://Art/Cubes/dialogueImages/huhapp.png")
			#the 7 human emotions: thinky, humanFirstAppearance(surprised), upset, mad, serious, ecstatuc
			dialogueSounds.set_stream(load("res://Sounds/UI/human.wav"))
			dialogueSounds.play()
		_:
			if (!currCubeFont):
				toCubeFont()
			SpeakerImage.texture = load("res://Art/Cubes/HoloCube1.png")
	if (speaker == speaker.to_lower()):
		if (currentDialogue > 61):
			CutsceneAnimator.play(str(currentDialogue))
		else:
			print_debug(str(currentDialogue)+": "+String.chr(currentDialogue+65))
			#I thought this system was clever until i ran out of chars lol
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
		if ((event is InputEventKey and event.is_action_released("ui_accept")) or (event is InputEventMouseButton and event.is_action_released("clicky") and (event.position.x < 1144 or event.position.y > 136))):
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

func _on_area_entered(area, index):
	if (!speaking):
		if (area.is_in_group("player")):
			player.disable_children()
			show()
			currentDialogue = index
			start_dialogue()

func toNextLevel():
	if (!Fader.is_playing()):
		if (Singleton.unlockedLevel <= LevelNumber):
			Singleton.unlockedLevel = LevelNumber+1
			Singleton.give_free_cookies()
		Singleton.currentLevel = LevelNumber+1
		Fader.play("FadeOut")
		MusicFader.play("FadeOut")
		await Fader.animation_finished
		get_tree().change_scene_to_file("res://Scenes/Levels/"+NextLevel)


func _on_cutscene_area_entered(body):
	if (!speaking):
		if (body.is_in_group("player")):
			player.disable_children()
			CutsceneAnimator.play("Bossy")
