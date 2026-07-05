extends AnimatedSprite2D


@onready var area_2d: Area2D = $Area2D



const GRAVITY := 300.0
var velocity := Vector2.ZERO
const CLICK_POWER := 2*GRAVITY


func _ready() -> void:
	play("fall")
	
	area_2d.area_entered.connect(_on_area_entered)
	area_2d.input_event.connect(_on_area_input_event)
	
	

func _process(delta: float) -> void:
	velocity.y += GRAVITY * delta
	position += velocity * delta
	
	
	
func _on_area_entered(area: Area2D):
	if area.is_in_group("danger_zone"):
		queue_free()
		

func _on_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_clicked()
		
		
func _on_clicked() -> void:
	velocity.y -= CLICK_POWER
	play("hit")
	await get_tree().create_timer(0.5).timeout
	play("fall")
