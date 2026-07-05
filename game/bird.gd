extends AnimatedSprite2D

signal clicked

@onready var area_2d: Area2D = $Area2D

@onready var whoosh_player: AudioStreamPlayer = $WhooshPlayer
const WHOOSH := preload("res://assets/sounds/Whoosh Sounds effects No copyright.mp3")
const WHOOSH_END := 0.35


const GRAVITY := 300.0
var velocity := Vector2.ZERO
const CLICK_POWER := 2*GRAVITY


func _ready() -> void:
	play("fall")
	add_to_group("bird")
	area_2d.add_to_group("bird")
	area_2d.area_entered.connect(_on_area_entered)
	area_2d.input_event.connect(_on_area_input_event)
	z_index = 2
	
	whoosh_player.stream = WHOOSH


func _process(delta: float) -> void:
	velocity.y += GRAVITY * delta
	position += velocity * delta


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("danger_zone"):
		queue_free()


func _on_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_clicked()
		
		
func _on_clicked() -> void:
	clicked.emit()
	_play_first_whoosh()

	velocity.y -= CLICK_POWER
	play("hit")
	await get_tree().create_timer(0.5).timeout
	play("fall")
	
	
func _play_first_whoosh() -> void:
	whoosh_player.stop()
	whoosh_player.play(0.0)
	#whoosh_player.volume = randf_range(-20.0, -13.0)
	get_tree().create_timer(WHOOSH_END).timeout.connect(whoosh_player.stop)
