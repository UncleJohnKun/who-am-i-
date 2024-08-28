extends RigidBody3D

var mouse_sensitivity := 0.001
var twist_input := 0.0
var pitch_input := 0.0
var zoom_speed := 0.1
var min_fov := 10.0
var max_fov := 90.0
@onready var twist_pivot := $TwistPivot
@onready var pitch_pivot := $TwistPivot/PitchPivot
@onready var camera := $TwistPivot/PitchPivot/Camera

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)  

func _process(delta: float) -> void:
	var input := Vector3.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_back")
	
	apply_central_force(twist_pivot.basis * input * 1200.0 * delta)
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if twist_input != 0.0 or pitch_input != 0.0:
		twist_pivot.rotate_y(twist_input)
		pitch_pivot.rotate_x(pitch_input)
		pitch_pivot.rotation.x = clamp(
			$TwistPivot/PitchPivot.rotation.x,
			deg_to_rad(-30),
			deg_to_rad(30)
		)
	# Reset inputs
	twist_input = 0.0
	pitch_input = 0.0 
	
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  
		if event is InputEventMouseMotion:
			if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				twist_input = -event.relative.x * mouse_sensitivity
				pitch_input = -event.relative.y * mouse_sensitivity
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 
	

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_in()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_out()

func zoom_in() -> void:
	camera.fov = clamp(camera.fov - zoom_speed, min_fov, max_fov)

func zoom_out() -> void:
	camera.fov = clamp(camera.fov + zoom_speed, min_fov, max_fov)
