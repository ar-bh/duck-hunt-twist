extends AnimatedSprite2D

const FALL_SPEED := 120.0

var random_ceiling_point := randf_range(0, get_viewport_rect().size.y)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
