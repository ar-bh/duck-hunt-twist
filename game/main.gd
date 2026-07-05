extends Node2D

#region node variables
@onready var intro_dog: AnimatedSprite2D = $Background/IntroDog
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var danger_zone: Area2D = $DangerZone

@onready var menu: CanvasLayer = $Menu
@onready var start_button: Button = $Menu/MenuRoot/StartButton
@onready var quit_button: Button = $Menu/MenuRoot/QuitButton
@onready var gameplay_ui: CanvasLayer = $GameplayUI
@onready var score_label: RichTextLabel = $GameplayUI/ScoreLabel
@onready var high_score_label: RichTextLabel = $GameplayUI/HighScoreLabel
#endregion

const DOG_START_X: float = -100.0
const DOG_TARGET_X: float = 600.0
const DOG_SPEED: float = 87.5*1.5

const BIRD_SCENE := preload("res://game/bird.tscn")
const SPAWN_MIN_INTERVAL := 1.0
const SPAWN_MAX_INTERVAL := 3.0
const SPAWN_Y := -50.0

var game_playing := false
var _spawn_timer := 0.0
var _next_spawn := 1.0
var score := 0
var high_score := 0

#region dog walking
var _dog_walking := false
const DOG_Z_WALKING := 2
const DOG_Z_BEHIND_BUSH := 0
#endregion

const DOG_SCENE := preload("res://game/dog.tscn")
const TOTAL_DOG_POPUP_TIME: float = 0.8
const DOG_POP_HEIGHT: float = 50.0
const DOG_GRASS_Y: float = 420.0
const DOG_HIDDEN_BELOW: float = 120.0


func _ready() -> void:
	intro_dog.z_index = DOG_Z_WALKING
	intro_dog.position.x = DOG_START_X
	intro_dog.stop()

	gameplay_ui.visible = false
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	danger_zone.area_entered.connect(_on_danger_zone_area_entered)
	_update_score_labels()


func _process(delta: float) -> void:
	if _dog_walking:
		intro_dog.position.x += DOG_SPEED * delta
		if intro_dog.position.x >= DOG_TARGET_X:
			intro_dog.position.x = DOG_TARGET_X
			_dog_walking = false
			intro_dog.stop()
			_play_dog_animation()

	if game_playing:
		_handle_bird_spawning(delta)


func _on_start_pressed() -> void:
	menu.visible = false
	gameplay_ui.visible = true
	intro_dog.visible = true
	intro_dog.play("walk")
	audio_stream_player.play()
	_dog_walking = true


func _on_quit_pressed() -> void:
	get_tree().quit()


func _add_score(amount: int) -> void:
	score += amount
	if score > high_score:
		high_score = score
	_update_score_labels()


func _update_score_labels() -> void:
	score_label.text = "[center]%d[/center]" % score
	high_score_label.text = "[right]High: %d[/right]" % high_score


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
	jump.tween_property(intro_dog, "position:y", start_y - jump_height, 0.25) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	jump.tween_callback(func(): intro_dog.z_index = DOG_Z_BEHIND_BUSH)
	jump.tween_callback(func(): intro_dog.play("fall"))
	jump.tween_property(intro_dog, "position:y", land_y, 0.3) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)

	var x_move := create_tween()
	x_move.tween_property(intro_dog, "position:x", start_x + 30.0, 0.55) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)

	await jump.finished
	await x_move.finished

	intro_dog.visible = false
	game_playing = true
	_spawn_timer = _next_spawn


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
	bird.z_index = 2
	bird.clicked.connect(_on_bird_clicked)
	add_child(bird)


func _on_bird_clicked() -> void:
	_add_score(1)


func _on_danger_zone_area_entered(area: Area2D) -> void:
	if not area.is_in_group("bird"):
		return

	_add_score(-1)
	var entry_point := area.global_position
	_spawn_popup_dog_at(entry_point)


func _spawn_popup_dog_at(global_point: Vector2) -> void:
	var dog: Sprite2D = DOG_SCENE.instantiate()
	dog.z_index = DOG_Z_BEHIND_BUSH
	$Background.add_child(dog)
	dog.global_position = Vector2(global_point.x, DOG_GRASS_Y + DOG_HIDDEN_BELOW)

	await _popup_dog(dog)
	dog.queue_free()


func _popup_dog(dog: Sprite2D) -> void:
	var hidden_y := DOG_GRASS_Y + DOG_HIDDEN_BELOW
	var peak_y := DOG_GRASS_Y - DOG_POP_HEIGHT
	var half_time := TOTAL_DOG_POPUP_TIME * 0.5

	var popup := create_tween()
	popup.tween_property(dog, "position:y", peak_y, half_time) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	popup.tween_property(dog, "position:y", hidden_y, half_time) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)

	await popup.finished
