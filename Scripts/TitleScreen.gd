extends ColorRect

@export var musicFader : AnimationPlayer
@export var Fader : AnimationPlayer
@export var TitleAnimator : AnimationPlayer
@export var buttonSound : AudioStreamPlayer
@export var ChapterButtons : Array[Button]
@export var BackToTitle : Button
@export var maxLvl : int = 3

var waiting : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(ChapterButtons.size()):
		if (i > Singleton.unlockedLevel-1):
			ChapterButtons[i].hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func playButtonPressed():
	if !waiting:
		waiting = true
		buttonSound.play()
		musicFader.play("fadeMusicOut")
		Fader.play("FadeOut")
		await Fader.animation_finished
		get_tree().change_scene_to_file("res://Scenes/Levels/level"+str(Singleton.currentLevel)+".tscn")


func _on_chapter_select_button_pressed():
	buttonSound.play()
	TitleAnimator.play("select")


func _on_chapter_return_pressed():
	buttonSound.play()
	TitleAnimator.play("deselect")


func _on_chapter_pressed(arg):
	if !waiting:
		waiting = true
		buttonSound.play()
		musicFader.play("fadeMusicOut")
		Fader.play("FadeOut")
		await Fader.animation_finished
		get_tree().change_scene_to_file("res://Scenes/Levels/level"+str(arg)+".tscn")


func _on_skip_levels_toggled(toggled_on):
	if (toggled_on):
		for i in range(ChapterButtons.size()):
			if (i < maxLvl):
				ChapterButtons[i].show()
	else:
		for i in range(ChapterButtons.size()):
			if (i >= Singleton.unlockedLevel):
				ChapterButtons[i].hide()
