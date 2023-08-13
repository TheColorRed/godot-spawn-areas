extends Camera3D


@onready var parent := get_parent()

var rotation_speed := 0.5:
	set(value):
		rotation_speed = clampf(value, 0, 5)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			rotation_speed += 0.05
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			rotation_speed -= 0.05

func _process(delta: float) -> void:
	parent.rotation.y += rotation_speed * delta
