extends Node2D

#region node variables
@onready var intro_dog: AnimatedSprite2D = $Background/IntroDog
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@onready var danger_zone: Area2D = $DangerZone
#endregion

const DOG_SPEED: float = 75.0
const DOG_TARGET_X: float = 600.0

const BIRD_SCENE := preload("res://game/bird.tscn")
const SPAWN_MIN_INTERVAL := 1.0
const SPAWN_MAX_INTERVAL := 3.0
const SPAWN_Y := -50.0

var game_playing := false
var _spawn_timer := 0.0
var _next_spawn := 1.0

#region dog walking
var _dog_walking := true
const DOG_Z_WALKING := 2
const DOG_Z_BEHIND_BUSH := 0
#endregion

const DOG_SCENE := preload("res://game/dog.tscn")
const TOTAL_DOG_POPUP_TIME: float = 0.3


func _ready() -> void:
	intro_dog.z_index = DOG_Z_WALKING
	intro_dog.play("walk")
	audio_stream_player.play()
	
	danger_zone.area_entered.connect(_on_danger_zone_area_entered)
	
	
func _process(delta: float) -> void:
	#region dog intro animation
	if _dog_walking:
		intro_dog.position.x += DOG_SPEED * delta
		if intro_dog.position.x >= DOG_TARGET_X:
			intro_dog.position.x = DOG_TARGET_X
			_dog_walking = false
			intro_dog.stop()
			_play_dog_animation()
		#endregion
		
	if game_playing:
		_handle_bird_spawning(delta)
		
		
func _play_dog_animation() -> void:
	await get_tree().create_timer(0.1).timeout
	
	var start_y := intro_dog.position.y
	var start_x := intro_dog.position.x
	var jump_height := 300.0
	var land_y := start_y + 20.0
	
	intro_dog.play("happy")
	await get_tree().create_timer(0.5).timeout
	
	intro_dog.play("jump")
	
	var jump := create_tween()
	jump.tween_property(intro_dog, "position:y", start_y - jump_height, 0.25)
	jump.set_ease(Tween.EASE_OUT)
	jump.set_trans(Tween.TRANS_QUAD)
	
	var x_move := create_tween()
	x_move.tween_property(intro_dog, "position:x", start_x + 30.0, 0.55)
	x_move.set_ease(Tween.EASE_IN)
	x_move.set_trans(Tween.TRANS_QUAD)
	
	await jump.finished
	
	intro_dog.z_index = DOG_Z_BEHIND_BUSH
	intro_dog.play("fall")
	
	var fall := create_tween()
	fall.tween_property(intro_dog, "position:y", land_y, 0.3)
	fall.set_ease(Tween.EASE_IN)
	fall.set_trans(Tween.TRANS_QUAD)
	
	await fall.finished
	await x_move.finished
	
	intro_dog.visible = false
	game_playing = true


func _handle_bird_spawning(delta: float) -> void:
	_spawn_timer += delta
	if _spawn_timer < _next_spawn:
		return
		
	_spawn_timer = 0.0
	_next_spawn = randf_range(SPAWN_MIN_INTERVAL, SPAWN_MAX_INTERVAL)
	_spawn_bird()
	
	
func _spawn_bird() -> void:
	var viewport_width := get_viewport().get_visible_rect().size.x
	var bird := BIRD_SCENE.instantiate()
	bird.position = Vector2(randf_range(0.0, viewport_width), SPAWN_Y)
	add_child(bird)


func _on_danger_zone_area_entered(area: Area2D) -> void:
	_popup_dog()
	
