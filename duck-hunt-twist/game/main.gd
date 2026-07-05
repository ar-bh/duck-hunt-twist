extends Node2D

#region node variables
@onready var intro_dog: AnimatedSprite2D = $Background/IntroDog

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

#endregion

const DOG_SPEED: float = 75.0
const DOG_TARGET_X: float = 620.0

var game_playing := false

#region dog walking
var _dog_walking := true
const DOG_Z_WALKING := 2
const DOG_Z_BEHIND_BUSH := 0
#endregion


func _ready() -> void:
	intro_dog.z_index = DOG_Z_WALKING
	intro_dog.play("walk")
	audio_stream_player.play()


func _process(delta: float) -> void:
	#region dog intro animation
	if not _dog_walking:
		return

	intro_dog.position.x += DOG_SPEED * delta
	if intro_dog.position.x >= DOG_TARGET_X:
		intro_dog.position.x = DOG_TARGET_X
		_dog_walking = false
		intro_dog.stop()
		_play_dog_animation()
	#endregion


func _play_dog_animation() -> void:
	await get_tree().create_timer(0.1).timeout
	
	intro_dog.play("happy")
	
	await get_tree().create_timer(0.5).timeout
	
	intro_dog.play("jump")
	var start_y := intro_dog.position.y
	var jump_height := 300.0
	var land_y := start_y + 20.0

	var jump := create_tween()
	jump.tween_property(intro_dog, "position:y", start_y - jump_height, 0.25) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	jump.tween_callback(func(): intro_dog.z_index = DOG_Z_BEHIND_BUSH)
	jump.tween_property(intro_dog, "position:y", land_y, 0.3) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)

	var x_move := create_tween()
	x_move.tween_property(intro_dog, "position:x", intro_dog.position.x + 30.0, 0.55)

	await jump.finished
	await x_move.finished
	intro_dog.visible = false
	
	game_playing = true
