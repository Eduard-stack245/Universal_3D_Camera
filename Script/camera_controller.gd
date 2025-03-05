extends Camera3D

## Universal Camera Controller for Godot 4
## Features:
## - Multiple camera modes (Free, Orbit, Strategy, First Person, Third Person)
## - Full keyboard and mouse support
## - Smooth transitions between modes
## - Configurable parameters for all modes
## - Clean and well-documented code
## 
## Универсальный контроллер камеры для Godot 4
## Особенности:
## - Несколько режимов камеры (Свободная, Орбитальная, Стратегическая, От первого лица, От третьего лица)
## - Полная поддержка клавиатуры и мыши
## - Плавные переходы между режимами
## - Настраиваемые параметры для всех режимов
## - Чистый и хорошо документированный код

# Camera modes enum (using class_name for better autocompletion)
class_name UniversalCameraController

enum CameraMode {
	FREE,         # Free flying camera / Свободная летающая камера
	ORBIT,        # Orbit around target point / Вращение вокруг целевой точки
	STRATEGY,     # Top-down strategy camera / Стратегическая камера сверху-вниз
	FIRST_PERSON, # First person camera / Камера от первого лица
	THIRD_PERSON  # Third person camera / Камера от третьего лица
}

# Signal definitions / Определения сигналов
signal camera_moved(position: Vector3)        # Emitted when camera position changes / Вызывается при изменении позиции камеры
signal camera_rotated(rotation: Vector3)      # Emitted when camera rotation changes / Вызывается при изменении вращения камеры
signal camera_zoomed(zoom_level: float)       # Emitted when zoom level changes / Вызывается при изменении уровня приближения
signal camera_mode_changed(mode: CameraMode)  # Emitted when camera mode changes / Вызывается при изменении режима камеры
signal transition_completed(new_mode: CameraMode) # Emitted when mode transition completes / Вызывается при завершении перехода между режимами

### CAMERA MODE SETTINGS ###
@export_group("Camera Mode")
@export var camera_mode: CameraMode = CameraMode.FREE
@export var target_node_path: NodePath = NodePath("")
@export var orbit_distance: float = 10.0

### FIRST PERSON CAMERA SETTINGS ###
@export_group("First Person Camera")
@export var first_person_offset: Vector3 = Vector3(0, 1.3, -0.3)
@export var first_person_rotation_offset: Vector3 = Vector3(0, 3.14159, 0)
@export var first_person_smoothing: float = 10.0

### THIRD PERSON CAMERA SETTINGS ###
@export_group("Third Person Camera")
@export var third_person_distance: float = 3.0
@export var third_person_height: float = 1.5
@export var third_person_offset: Vector3 = Vector3(0, 0, 0)
@export var third_person_smoothing: float = 5.0

### MOUSE CONTROL SETTINGS ###
@export_group("Mouse Control")
@export var mouse_control_enabled: bool = true
@export var mouse_sensitivity: float = 0.05
@export var mouse_drag_enabled: bool = true
@export var mouse_drag_sensitivity: float = 0.01
@export var mouse_middle_button_action: int = 1  # 0=Disabled, 1=Drag, 2=Move
@export var mouse_scroll_speed_factor: float = 0.5
@export var key_toggle_mouse_control: int = KEY_M

# Additional mouse settings
@export var orbit_mouse_vertical_movement_enabled: bool = true
@export var orbit_mouse_vertical_sensitivity: float = 0.02
@export var orbit_mouse_horizontal_movement_enabled: bool = true
@export var orbit_mouse_horizontal_sensitivity: float = 0.02
@export var free_mouse_movement_enabled: bool = true
@export var free_mouse_movement_sensitivity: float = 0.05
@export var mouse_invert_vertical_movement: bool = false
@export var key_toggle_mouse_inversion: int = KEY_V

### MOVEMENT SETTINGS ###
@export_group("Movement")
@export var move_speed: float = 10.0
@export var acceleration: float = 5.0
@export var enable_vertical_movement: bool = true
@export var movement_bounds: AABB = AABB(Vector3(-100, 0, -100), Vector3(200, 50, 200))
@export var use_bounds: bool = true
@export var velocity_deadzone: float = 0.01
@export var key_toggle_lock: int = KEY_L

### STRATEGY CAMERA SETTINGS ###
@export_group("Strategy Camera")
@export var strategy_height: float = 15.0
@export var strategy_pitch: float = -1.4
@export var strategy_min_height: float = 5.0
@export var strategy_max_height: float = 30.0
@export var strategy_edge_scroll: bool = true
@export var strategy_edge_scroll_margin: int = 20
@export var strategy_edge_scroll_speed: float = 10.0
@export var strategy_rotation_enabled: bool = true
@export var strategy_fixed_angle: bool = false
@export var strategy_angle_presets: Array = [
	Vector3(-80, 0, 0),   # Top-down view
	Vector3(-60, 0, 0),   # Isometric view
	Vector3(-45, 45, 0),  # Diagonal view
	Vector3(-45, 90, 0)   # Side view
]
@export var strategy_current_preset: int = 0
@export var strategy_invert_x: bool = false
@export var strategy_invert_y: bool = false
@export var key_toggle_rotation: int = KEY_R
@export var key_next_preset: int = KEY_F
@export var key_reset_camera: int = KEY_HOME
@export var key_toggle_strategy_invert_x: int = KEY_I
@export var key_toggle_strategy_invert_y: int = KEY_O

# Additional strategy settings
@export var strategy_follow_target: bool = false
@export var strategy_target_offset: Vector3 = Vector3(0, 0, 0)

### ZOOM SETTINGS ###
@export_group("Zoom")
@export var enable_zoom: bool = true
@export var zoom_speed: float = 1.0
@export var min_zoom: float = 1.0
@export var max_zoom: float = 50.0
@export var initial_zoom_level: float = 10.0
@export var zoom_smoothing: float = 5.0

### INITIAL SETTINGS ###
@export_group("Initial Settings")
@export var initial_position: Vector3 = Vector3(0, 5, 10)
@export var initial_rotation_degrees: Vector3 = Vector3(-30, 0, 0)

### CONTROL KEYS ###
@export_group("Control Keys")
@export var key_forward: int = KEY_W
@export var key_backward: int = KEY_S
@export var key_left: int = KEY_A
@export var key_right: int = KEY_D
@export var key_up: int = KEY_E
@export var key_down: int = KEY_Q
@export var key_alt_forward: int = KEY_UP
@export var key_alt_backward: int = KEY_DOWN
@export var key_alt_left: int = KEY_LEFT
@export var key_alt_right: int = KEY_RIGHT
@export var key_auto_rotate: int = KEY_SPACE
@export var mouse_button_rotate: int = MOUSE_BUTTON_LEFT
@export var mouse_button_pan: int = MOUSE_BUTTON_RIGHT

### ROTATION SETTINGS ###
@export_group("Rotation")
@export var rotation_sensitivity: float = 0.005
@export var min_pitch: float = -1.4  # -80 degrees
@export var max_pitch: float = 1.4   # 80 degrees
@export var invert_y: bool = false
@export var invert_x: bool = true
@export var invert_y_key: int = KEY_R
@export var invert_x_key: int = KEY_T
@export var auto_rotation_speed: float = 0.5

### ORBIT CAMERA ADVANCED SETTINGS ###
@export_group("Orbit Camera Advanced")
# Добавить в секцию orbit_camera_advanced_settings
@export var orbit_invert_auto_rotation: bool = false
@export var key_toggle_orbit_auto_rotation_inversion: int = KEY_ALT
@export var orbit_invert_x_rotation: bool = false
@export var orbit_invert_y_rotation: bool = false
@export var orbit_auto_rotation_enabled: bool = false
@export var orbit_auto_rotation_speed: float = 0.2
@export var orbit_auto_rotation_axis: Vector3 = Vector3(0, 1, 0)
@export var orbit_follow_smoothing: float = 0.5
@export var orbit_rotation_constraints: bool = false
@export var orbit_min_angle: float = -90.0
@export var orbit_max_angle: float = 90.0
@export var orbit_allow_mouse_zoom: bool = true
# Important: This is the Node3D reference, while orbit_follow_enabled is the toggle flag
@export var orbit_follow_target: Node3D = null
@export var orbit_follow_enabled: bool = false
@export var key_toggle_orbit_x_inversion: int = KEY_X
@export var key_toggle_orbit_y_inversion: int = KEY_Y
@export var key_toggle_auto_rotation: int = KEY_B

# Mode toggle keys
@export_group("Mode Toggle Keys")
@export var use_mode_toggle_keys: bool = true
@export var key_mode_free: int = KEY_1
@export var key_mode_orbit: int = KEY_2
@export var key_mode_strategy: int = KEY_3
@export var key_mode_first_person: int = KEY_4
@export var key_mode_third_person: int = KEY_5

# Mouse handling
var is_horizontal_pan: bool = false
var is_vertical_pan: bool = false
var last_drag_position: Vector2 = Vector2.ZERO

# Transition variables
var transitioning: bool = false
var transition_t: float = 0.0
var transition_duration: float = 1.0
var transition_from_mode: CameraMode
var transition_to_mode: CameraMode
var transition_from_position: Vector3
var transition_to_position: Vector3
var transition_from_rotation: Vector3
var transition_to_rotation: Vector3

# Internal variables
var zoom_level: float
var target_zoom_level: float
var zoom_target: Vector3
var is_mouse_pressed: bool = false
var is_right_mouse_pressed: bool = false
var is_middle_mouse_pressed: bool = false
var last_mouse_position: Vector2 = Vector2.ZERO
var target_node = null
var velocity: Vector3 = Vector3.ZERO
var auto_rotating: bool = false
var is_camera_locked: bool = false

### CORE FUNCTIONALITY / ОСНОВНОЙ ФУНКЦИОНАЛ ###

func _ready() -> void:
	# Initialize camera
	position = initial_position
	rotation_degrees = initial_rotation_degrees
	zoom_level = initial_zoom_level
	target_zoom_level = zoom_level
	zoom_target = get_zoom_target()
	
	# Get target node if specified
	_initialize_target_node()

func _process(delta: float) -> void:
	# Process transition first
	if transitioning:
		process_transition(delta)
		return
	
	# Skip if camera is locked (except for first/third person modes)
	if is_camera_locked and (camera_mode != CameraMode.FIRST_PERSON and camera_mode != CameraMode.THIRD_PERSON):
		return
	
	# Process current camera mode
	match camera_mode:
		CameraMode.FREE:
			handle_keyboard_movement(delta)
			smooth_zoom(delta)
		CameraMode.ORBIT:
			if orbit_auto_rotation_enabled:
				handle_orbit_auto_rotation(delta)
			handle_orbit_movement(delta)
			handle_orbit_zoom(delta)
		CameraMode.STRATEGY:
			handle_strategy_movement(delta)
			smooth_zoom(delta)
		CameraMode.FIRST_PERSON:
			handle_first_person_movement(delta)
		CameraMode.THIRD_PERSON:
			handle_third_person_movement(delta)

func _input(event: InputEvent) -> void:
	# Handle global key presses first (regardless of camera mode)
	if event is InputEventKey and event.pressed and not event.echo:
		_handle_global_keys(event)
		
		# Camera mode switching should always work regardless of mode
		if use_mode_toggle_keys:
			_handle_mode_toggle_keys(event)
	
	# If camera is locked and in a mode that restricts movement, skip remaining handling
	if is_camera_locked and (camera_mode != CameraMode.FIRST_PERSON and camera_mode != CameraMode.THIRD_PERSON):
		return
	
	# Strategy mode has special input handling
	if camera_mode == CameraMode.STRATEGY:
		handle_strategy_input(event)
		if event is InputEventMouseButton:
			handle_mouse_buttons(event)
		return
	
	# Skip mouse/keyboard movement for first/third person modes
	if _is_fixed_camera_mode() and _is_movement_input(event):
		return
	
	# Handle orbit mode's horizontal movement
	if camera_mode == CameraMode.ORBIT and !is_camera_locked:
		if event is InputEventMouseMotion:
			_handle_orbit_mouse_motion(event)
	
	# Handle standard mouse input
	if event is InputEventMouseButton:
		handle_mouse_buttons(event)
	elif event is InputEventMouseMotion and !is_camera_locked:
		_handle_camera_mouse_motion(event)
	
	# Handle key presses for toggles
	if event is InputEventKey and event.pressed and not event.echo:
		_handle_toggle_keys(event)

### HELPER FUNCTIONS ###

# Initialize target node from path
func _initialize_target_node() -> void:
	if target_node_path:
		target_node = get_node_or_null(target_node_path)
		if target_node and camera_mode == CameraMode.THIRD_PERSON:
			print("Third Person Camera: Target node initialized to ", target_node.name)
		elif camera_mode == CameraMode.THIRD_PERSON:
			push_error("Third Person Camera: Failed to get target node at path: " + str(target_node_path))
	elif camera_mode == CameraMode.THIRD_PERSON:
		push_warning("Third Person Camera: No target node path specified, camera will use FPS mode")

# Check if current mode is a fixed camera (first person or third person)
func _is_fixed_camera_mode() -> bool:
	return camera_mode == CameraMode.FIRST_PERSON or camera_mode == CameraMode.THIRD_PERSON

# Check if the event is a movement input that should be blocked in certain modes
func _is_movement_input(event: InputEvent) -> bool:
	if event is InputEventMouseMotion and (is_mouse_pressed or is_right_mouse_pressed):
		return true
	
	if event is InputEventKey:
		var movement_keys = [
			key_forward, key_backward, key_left, key_right, key_up, key_down,
			key_alt_forward, key_alt_backward, key_alt_left, key_alt_right
		]
		return event.keycode in movement_keys
	
	return false

# Handle global key toggles
func _handle_global_keys(event: InputEventKey) -> void:
	match event.keycode:
		key_toggle_lock:
			is_camera_locked = !is_camera_locked
			print("Camera movement " + ("LOCKED" if is_camera_locked else "UNLOCKED"))
		key_toggle_mouse_control:
			mouse_control_enabled = !mouse_control_enabled
			print("Mouse control " + ("ENABLED" if mouse_control_enabled else "DISABLED"))
		key_toggle_mouse_inversion:
			toggle_mouse_vertical_inversion()
		key_auto_rotate:
			if camera_mode == CameraMode.ORBIT:
				toggle_orbit_auto_rotation()

func _handle_orbit_mouse_motion(event: InputEventMouseMotion) -> void:
	if is_middle_mouse_pressed and mouse_middle_button_action == 2:
		handle_orbit_horizontal_motion(event)
	elif is_right_mouse_pressed and Input.is_key_pressed(KEY_ALT):
		handle_orbit_horizontal_motion(event)
	
	if Input.is_key_pressed(key_auto_rotate) and !transitioning:
		orbit_auto_rotation_enabled = !orbit_auto_rotation_enabled
		print("Orbit auto-rotation: " + ("ON" if orbit_auto_rotation_enabled else "OFF"))

# Handle camera mouse motion based on current mode
func _handle_camera_mouse_motion(event: InputEventMouseMotion) -> void:
	if camera_mode == CameraMode.FREE:
		if mouse_control_enabled and is_right_mouse_pressed and !Input.is_key_pressed(KEY_SHIFT):
			handle_free_mouse_motion(event)
		else:
			handle_mouse_motion(event)
	elif camera_mode == CameraMode.ORBIT:
		handle_orbit_mouse_control(event)
		if mouse_control_enabled and is_right_mouse_pressed and !Input.is_key_pressed(KEY_SHIFT):
			handle_orbit_vertical_motion(event)
	else:
		handle_mouse_motion(event)

# В функцию _handle_toggle_keys добавить обработку инверсии автовращения
func _handle_toggle_keys(event: InputEventKey) -> void:
	match event.keycode:
		invert_y_key:
			toggle_invert_y()
		invert_x_key:
			toggle_invert_x()
		key_toggle_orbit_x_inversion:
			toggle_orbit_x_inversion()
		key_toggle_orbit_y_inversion:
			toggle_orbit_y_inversion()
		key_toggle_auto_rotation:
			if camera_mode == CameraMode.ORBIT:
				toggle_orbit_auto_rotation()
		key_toggle_orbit_auto_rotation_inversion:
			if camera_mode == CameraMode.ORBIT:
				toggle_orbit_auto_rotation_inversion()

# Handle mode toggle keys
func _handle_mode_toggle_keys(event: InputEventKey) -> void:
	# Print debug info to help identify key press detection
	print("Checking mode toggle key: ", event.keycode)
	
	match event.keycode:
		key_mode_free:
			print("Switching to FREE mode")
			set_camera_mode(CameraMode.FREE, true)
		key_mode_orbit:
			print("Switching to ORBIT mode")
			set_camera_mode(CameraMode.ORBIT, true)
		key_mode_strategy:
			print("Switching to STRATEGY mode")
			set_camera_mode(CameraMode.STRATEGY, true)
		key_mode_first_person:
			print("Switching to FIRST_PERSON mode")
			set_camera_mode(CameraMode.FIRST_PERSON, true)
		key_mode_third_person:
			print("Switching to THIRD_PERSON mode")
			set_camera_mode(CameraMode.THIRD_PERSON, true)

### TRANSITIONS ###

# Process smooth transition between camera modes
func process_transition(delta: float) -> void:
	if !transitioning:
		return
	
	# Update transition progress
	transition_t += delta / transition_duration
	
	# Complete transition if finished
	if transition_t >= 1.0:
		transition_t = 1.0
		transitioning = false
		
		# Set final position and rotation directly to avoid floating-point imprecision
		global_position = transition_to_position
		global_transform.basis = Basis.from_euler(transition_to_rotation)
		
		# Perform any post-transition actions
		if transition_to_mode == CameraMode.STRATEGY:
			reset_strategy_camera()
		
		# Make sure camera_mode is properly set after transition
		camera_mode = transition_to_mode
		
		emit_signal("transition_completed", camera_mode)
		return
	
	# Calculate smooth interpolation (use quadratic easing for natural movement)
	var t = ease(transition_t, 2.0)
	
	# Interpolate position
	global_position = transition_from_position.lerp(transition_to_position, t)
	
	# Interpolate rotation using quaternions for smoother rotation
	var from_quat = Quaternion.from_euler(transition_from_rotation)
	var to_quat = Quaternion.from_euler(transition_to_rotation)
	global_transform.basis = Basis(from_quat.slerp(to_quat, t))
	
	# Emit signals
	emit_signal("camera_moved", global_position)
	emit_signal("camera_rotated", global_rotation)

### CAMERA MODES ###

# Strategy camera input handling
# Handle strategy input without blocking mode toggle keys
func handle_strategy_input(event: InputEvent) -> void:
	if camera_mode != CameraMode.STRATEGY:
		return
	
	if event is InputEventKey and event.pressed and not event.echo:
		_handle_strategy_keys(event)
	
	# Handle mouse rotation if enabled
	if strategy_rotation_enabled and !strategy_fixed_angle and !is_camera_locked:
		if event is InputEventMouseMotion and is_mouse_pressed:
			# Create a modified event to apply strategy-specific inversion
			var modified_event = event.duplicate()
			
			# Apply strategy-specific inversions
			if strategy_invert_x:
				modified_event.relative.x = -modified_event.relative.x
			if strategy_invert_y:
				modified_event.relative.y = -modified_event.relative.y
			
			handle_strategy_mouse_motion(modified_event)

# Handle strategy mode key presses
func _handle_strategy_keys(event: InputEventKey) -> void:
	match event.keycode:
		key_toggle_rotation:
			strategy_fixed_angle = !strategy_fixed_angle
			print("Strategy fixed angle: " + ("ON" if strategy_fixed_angle else "OFF"))
		key_next_preset:
			if strategy_fixed_angle:
				strategy_current_preset = (strategy_current_preset + 1) % strategy_angle_presets.size()
				print("Strategy angle preset: " + str(strategy_current_preset))
		key_reset_camera:
			reset_strategy_camera()
			print("Strategy camera reset")
		key_toggle_strategy_invert_x:
			strategy_invert_x = !strategy_invert_x
			print("Strategy X-axis inversion: " + ("ON" if strategy_invert_x else "OFF"))
		key_toggle_strategy_invert_y:
			strategy_invert_y = !strategy_invert_y
			print("Strategy Y-axis inversion: " + ("ON" if strategy_invert_y else "OFF"))

# Reset strategy camera to initial position with current settings
func reset_strategy_camera() -> void:
	position.x = initial_position.x
	position.z = initial_position.z
	position.y = strategy_height
	
	if strategy_fixed_angle:
		var target_angles_deg = strategy_angle_presets[strategy_current_preset]
		rotation_degrees = target_angles_deg
	else:
		rotation_degrees.x = rad_to_deg(strategy_pitch)
		rotation_degrees.y = 0
		rotation_degrees.z = 0
	
	velocity = Vector3.ZERO
	target_zoom_level = (max_zoom - min_zoom) / 2 + min_zoom  # Middle zoom level
	
	emit_signal("camera_moved", position)

# Strategy mouse motion handling
func handle_strategy_mouse_motion(event: InputEventMouseMotion) -> void:
	if is_mouse_pressed:
		last_mouse_position = event.position
		
		# Horizontal rotation
		rotate_y(event.relative.x * rotation_sensitivity)
		
		# Vertical rotation with constraints
		var new_rotation_x = rotation.x - event.relative.y * rotation_sensitivity
		rotation.x = clamp(new_rotation_x, min_pitch, max_pitch)
		
		emit_signal("camera_rotated", rotation)

# Strategy movement handling
func handle_strategy_movement(delta: float) -> void:
	if is_camera_locked:
		return
	
	# Follow target if enabled
	if strategy_follow_target and target_node:
		_handle_strategy_target_following(delta)
	
	# Handle keyboard and edge scrolling input
	var input_dir = _get_strategy_input_direction()
	
	# Apply movement based on input
	if input_dir != Vector3.ZERO:
		_apply_strategy_movement(input_dir, delta)
	else:
		velocity = velocity.lerp(Vector3.ZERO, acceleration * delta)
	
	# Apply deadzone to prevent drift
	if velocity.length() < velocity_deadzone:
		velocity = Vector3.ZERO
	
	position += velocity * delta
	
	# Handle height (zoom)
	_update_strategy_height(delta)
	
	# Handle camera angle
	_update_strategy_angle(delta)
	
	# Apply position constraints
	if use_bounds:
		clamp_position()
		
	emit_signal("camera_moved", position)

# Handle strategy target following
func _handle_strategy_target_following(delta: float) -> void:
	var target_position = target_node.global_position + strategy_target_offset
	var target_camera_position = Vector3(
		target_position.x,
		position.y,
		target_position.z
	)
	
	position = position.lerp(target_camera_position, delta * orbit_follow_smoothing)

# Get input direction for strategy mode
func _get_strategy_input_direction() -> Vector3:
	var input_dir = Vector3.ZERO
	
	# Keyboard input
	if Input.is_key_pressed(key_forward) or Input.is_key_pressed(key_alt_forward):
		input_dir.z -= 1
	if Input.is_key_pressed(key_backward) or Input.is_key_pressed(key_alt_backward):
		input_dir.z += 1
	if Input.is_key_pressed(key_left) or Input.is_key_pressed(key_alt_left):
		input_dir.x -= 1
	if Input.is_key_pressed(key_right) or Input.is_key_pressed(key_alt_right):
		input_dir.x += 1
	
	# Edge scrolling
	if strategy_edge_scroll:
		var mouse_pos = get_viewport().get_mouse_position()
		var screen_size = get_viewport().size
		
		if mouse_pos.y < strategy_edge_scroll_margin:
			input_dir.z -= 1
		elif mouse_pos.y > screen_size.y - strategy_edge_scroll_margin:
			input_dir.z += 1
		
		if mouse_pos.x < strategy_edge_scroll_margin:
			input_dir.x -= 1
		elif mouse_pos.x > screen_size.x - strategy_edge_scroll_margin:
			input_dir.x += 1
	
	return input_dir

# Apply movement for strategy mode
func _apply_strategy_movement(input_dir: Vector3, delta: float) -> void:
	input_dir = input_dir.normalized()
	
	# Movement relative to camera orientation
	var forward = global_transform.basis.z
	forward.y = 0
	forward = forward.normalized()
	
	var right = global_transform.basis.x
	right.y = 0
	right = right.normalized()
	
	var target_velocity = (forward * -input_dir.z + right * input_dir.x) * move_speed
	velocity = velocity.lerp(target_velocity, acceleration * delta)

# Update strategy camera height based on zoom
func _update_strategy_height(delta: float) -> void:
	if enable_zoom:
		var target_height = strategy_min_height + (strategy_max_height - strategy_min_height) * (target_zoom_level - min_zoom) / (max_zoom - min_zoom)
		position.y = lerp(position.y, target_height, zoom_smoothing * delta)
	else:
		position.y = lerp(position.y, strategy_height, acceleration * delta)

# Update strategy camera angle
func _update_strategy_angle(delta: float) -> void:
	if strategy_fixed_angle:
		var target_angles_deg = strategy_angle_presets[strategy_current_preset]
		var target_angles_rad = Vector3(
			deg_to_rad(target_angles_deg.x),
			deg_to_rad(target_angles_deg.y),
			deg_to_rad(target_angles_deg.z)
		)
		
		var current_angles = global_transform.basis.get_euler()
		var new_angles = current_angles.lerp(target_angles_rad, acceleration * delta)
		global_transform.basis = Basis.from_euler(new_angles)
	elif !strategy_rotation_enabled:
		var new_basis = Basis()
		new_basis = new_basis.rotated(Vector3.RIGHT, strategy_pitch)
		global_transform.basis = new_basis

### MOUSE HANDLING ###

# Standard mouse motion handling
func handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if is_mouse_pressed:
		var mouse_delta = event.position - last_mouse_position
		last_mouse_position = event.position
		
		# Save zoom target before rotation
		if enable_zoom and camera_mode != CameraMode.ORBIT:
			zoom_target = get_zoom_target()
		
		# Apply input inversion
		var x_factor = -1.0 if invert_x else 1.0
		var y_factor = -1.0 if invert_y else 1.0
		
		# Horizontal rotation
		rotate_y(mouse_delta.x * rotation_sensitivity * x_factor)
		
		# Vertical rotation with constraints
		var new_rotation_x = rotation.x - mouse_delta.y * rotation_sensitivity * y_factor
		rotation.x = clamp(new_rotation_x, min_pitch, max_pitch)
		
		# Restore focus on same point after rotation
		if enable_zoom and camera_mode != CameraMode.ORBIT:
			apply_zoom()
		
		emit_signal("camera_rotated", rotation)

# Orbit camera mouse control
func handle_orbit_mouse_control(event: InputEventMouseMotion) -> void:
	if !target_node or !mouse_control_enabled:
		return
	
	var orbit_center = target_node.global_position
	
	# Handle rotation around model when left mouse button is pressed
	if is_mouse_pressed:
		var mouse_delta = event.relative
		
		# Apply sensitivity and inversion
		var x_factor = 1.0
		var y_factor = 1.0
		
		# Apply global inversion
		if invert_x:
			x_factor *= -1.0
		if invert_y:
			y_factor *= -1.0
		
		# Apply orbit-specific inversion
		if orbit_invert_x_rotation:
			x_factor *= -1.0
		if orbit_invert_y_rotation:
			y_factor *= -1.0
		
		# Calculate rotation angles
		var horizontal_angle = mouse_delta.x * rotation_sensitivity * x_factor
		var vertical_angle = mouse_delta.y * rotation_sensitivity * y_factor
		
		# Get current camera-to-target vector
		var cam_to_target = global_position - orbit_center
		var distance = cam_to_target.length()
		
		# Calculate current spherical coordinates
		var current_polar = acos(cam_to_target.y / distance)  # Polar angle (from Y axis)
		var current_azimuth = atan2(cam_to_target.x, cam_to_target.z)  # Azimuth (in XZ plane)
		
		# Update angles
		var new_polar = clamp(current_polar + vertical_angle, 0.1, PI - 0.1)  # Constrain to avoid issues at poles
		var new_azimuth = current_azimuth + horizontal_angle
		
		# Convert back to Cartesian coordinates
		var new_pos = Vector3(
			sin(new_polar) * sin(new_azimuth),
			cos(new_polar),
			sin(new_polar) * cos(new_azimuth)
		) * distance
		
		# Set new position relative to target
		global_position = orbit_center + new_pos
		
		# Look at the target
		look_at(orbit_center, Vector3.UP)
		
		# Update zoom target
		zoom_target = orbit_center
		zoom_level = distance
		
		emit_signal("camera_moved", global_position)
		emit_signal("camera_rotated", rotation)

# Orbit zoom handling
func handle_orbit_zoom(delta: float) -> void:
	if !target_node or !enable_zoom:
		return
		
	var orbit_center = target_node.global_position
	
	# Smoothly adjust current zoom level to target
	if abs(zoom_level - target_zoom_level) > 0.01:
		zoom_level = lerp(zoom_level, target_zoom_level, zoom_smoothing * delta)
		
		# Get direction from target to camera
		var dir = (global_position - orbit_center).normalized()
		
		# Set new camera position based on updated zoom level
		global_position = orbit_center + dir * zoom_level
		
		emit_signal("camera_zoomed", zoom_level)

# Orbit mouse wheel handling for zooming
func handle_orbit_mouse_wheel(event: InputEventMouseButton) -> bool:
	if camera_mode != CameraMode.ORBIT or !target_node or !enable_zoom or !orbit_allow_mouse_zoom:
		return false
		
	var orbit_center = target_node.global_position
	
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		# Zoom in
		target_zoom_level = max(min_zoom, target_zoom_level - zoom_speed)
		emit_signal("camera_zoomed", target_zoom_level)
		return true
		
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		# Zoom out
		target_zoom_level = min(max_zoom, target_zoom_level + zoom_speed)
		emit_signal("camera_zoomed", target_zoom_level)
		return true
		
	return false

# Orbit vertical motion handling
func handle_orbit_vertical_motion(event: InputEventMouseMotion) -> void:
	if !orbit_mouse_vertical_movement_enabled or !target_node:
		return
		
	var orbit_center = target_node.global_position
	var mouse_delta = event.relative
	
	# Apply vertical movement inversion if needed
	if mouse_invert_vertical_movement:
		mouse_delta.y = -mouse_delta.y
	
	# Calculate vertical and horizontal offsets
	var dy = -mouse_delta.y * orbit_mouse_vertical_sensitivity
	var dx = -mouse_delta.x * orbit_mouse_horizontal_sensitivity
	
	# Get movement vectors
	var right = global_transform.basis.x
	right.y = 0
	right = right.normalized()
	
	var forward = -global_transform.basis.z
	forward.y = 0
	forward = forward.normalized()
	
	# Choose movement type based on modifiers
	if Input.is_key_pressed(KEY_SHIFT) and orbit_mouse_horizontal_movement_enabled:
		# Horizontal movement (left/right)
		target_node.global_position += right * dx
		
		# If Alt is pressed, also move forward/back
		if Input.is_key_pressed(KEY_ALT):
			target_node.global_position += forward * (-mouse_delta.y * orbit_mouse_vertical_sensitivity)
	else:
		# Vertical movement
		target_node.global_position.y += dy
	
	# Update camera to look at the new orbit point
	look_at_point(target_node.global_position)
	
	emit_signal("camera_rotated", rotation)

# Orbit horizontal motion handling
func handle_orbit_horizontal_motion(event: InputEventMouseMotion) -> void:
	if !orbit_mouse_horizontal_movement_enabled or !target_node:
		return
		
	var orbit_center = target_node.global_position
	var mouse_delta = event.relative
	
	# Get movement vectors
	var right = global_transform.basis.x
	right.y = 0
	right = right.normalized()
	
	var forward = -global_transform.basis.z
	forward.y = 0
	forward = forward.normalized()
	
	# Calculate offsets
	var dx = -mouse_delta.x * orbit_mouse_horizontal_sensitivity
	var dz = -mouse_delta.y * orbit_mouse_horizontal_sensitivity
	
	# Move orbit point in XZ plane
	target_node.global_position += right * dx + forward * dz
	
	# Update camera position
	look_at_point(target_node.global_position)
	
	emit_signal("camera_moved", position)

# Mouse vertical inversion toggle
func toggle_mouse_vertical_inversion() -> void:
	mouse_invert_vertical_movement = !mouse_invert_vertical_movement
	print("Mouse vertical movement inversion: " + ("ON" if mouse_invert_vertical_movement else "OFF"))

# Free camera mouse motion handling
func handle_free_mouse_motion(event: InputEventMouseMotion) -> void:
	if !free_mouse_movement_enabled:
		return
		
	var mouse_delta = event.relative
	
	# Apply vertical inversion if needed
	if mouse_invert_vertical_movement:
		mouse_delta.y = -mouse_delta.y
		
	# Get camera orientation vectors
	var forward = -global_transform.basis.z
	forward.y = 0
	forward = forward.normalized()
	
	var right = global_transform.basis.x
	right.y = 0
	right = right.normalized()
	
	var up = Vector3.UP  # Add up vector for full 3D control
	
	# Calculate movement with sensitivity
	var dx = -mouse_delta.x * free_mouse_movement_sensitivity
	var dz = -mouse_delta.y * free_mouse_movement_sensitivity
	
	# If Shift is held, move up/down instead of forward/back
	if Input.is_key_pressed(KEY_SHIFT):
		position += right * dx + up * (-dz)  # Invert dz for more intuitive control
	else:
		# Standard forward/back and left/right movement
		position += right * dx + forward * dz
	
	# Apply position constraints
	if use_bounds:
		clamp_position()
	
	emit_signal("camera_moved", position)

# Keyboard movement handling
func handle_keyboard_movement(delta: float) -> void:
	# Skip if camera is locked
	if is_camera_locked:
		return
		
	var input_dir = Vector3.ZERO
	
	# Check direct key presses for movement
	# Horizontal movement
	if Input.is_key_pressed(key_forward) or Input.is_key_pressed(key_alt_forward):
		input_dir.z -= 1
	if Input.is_key_pressed(key_backward) or Input.is_key_pressed(key_alt_backward):
		input_dir.z += 1
	if Input.is_key_pressed(key_left) or Input.is_key_pressed(key_alt_left):
		input_dir.x -= 1
	if Input.is_key_pressed(key_right) or Input.is_key_pressed(key_alt_right):
		input_dir.x += 1
	
	# Apply smoothed horizontal movement
	if input_dir != Vector3.ZERO:
		input_dir = input_dir.normalized()
		var target_velocity = global_transform.basis * input_dir * move_speed
		target_velocity.y = 0  # Zero Y-component for horizontal movement only
		velocity = velocity.lerp(target_velocity, acceleration * delta)
	else:
		velocity = velocity.lerp(Vector3.ZERO, acceleration * delta)
	
	# Apply deadzone to prevent drift
	if velocity.length() < velocity_deadzone:
		velocity = Vector3.ZERO
	
	# Mouse-based movement (with middle button)
	if mouse_control_enabled and is_middle_mouse_pressed and mouse_middle_button_action == 1 and !is_camera_locked:
		var mouse_pos = get_viewport().get_mouse_position()
		var dx = (mouse_pos.x - last_mouse_position.x) * mouse_drag_sensitivity
		var dz = (mouse_pos.y - last_mouse_position.y) * mouse_drag_sensitivity
		
		# Calculate movement in XZ plane based on current direction
		var forward = -global_transform.basis.z
		forward.y = 0
		forward = forward.normalized()
		
		var right = global_transform.basis.x
		right.y = 0
		right = right.normalized()
		
		position -= right * dx + forward * dz
		last_mouse_position = mouse_pos
	else:
		position += velocity * delta
	
	# Vertical movement
	if enable_vertical_movement:
		var vertical_movement = 0.0
		
		if Input.is_key_pressed(key_up):
			vertical_movement += 1.0
		if Input.is_key_pressed(key_down):
			vertical_movement -= 1.0
		
		# Vertical camera movement with right mouse button (holding Shift)
		if mouse_control_enabled and is_right_mouse_pressed and Input.is_key_pressed(KEY_SHIFT) and !is_camera_locked:
			var mouse_pos = get_viewport().get_mouse_position()
			vertical_movement += (last_mouse_position.y - mouse_pos.y) * mouse_sensitivity * 0.1
			last_mouse_position = mouse_pos
			
		if vertical_movement != 0:
			position.y += vertical_movement * move_speed * delta
	
	# Apply position constraints
	if use_bounds:
		clamp_position()
		
	emit_signal("camera_moved", position)

# Handle orbit mode movement
func handle_orbit_movement(delta: float) -> void:
	var orbit_center = Vector3.ZERO
	
	# Determine orbit center
	if target_node:
		orbit_center = target_node.global_position
		
		# Initialize zoom_level with current distance if not set or very different
		if zoom_level <= 0 or (camera_mode == CameraMode.ORBIT and abs(zoom_level - global_position.distance_to(orbit_center)) > 5.0):
			zoom_level = global_position.distance_to(orbit_center)
			target_zoom_level = zoom_level
		
		# If following target is enabled
		if orbit_follow_enabled:
			# Smoothly update target point with offset
			# (e.g., if target is moving)
			var target_position = target_node.global_position
			var current_look_position = zoom_target
			zoom_target = current_look_position.lerp(target_position, orbit_follow_smoothing * delta)
		
		# Only rotate if left mouse button is pressed
		if is_mouse_pressed:
			# Apply rotation constraints if enabled
			if orbit_rotation_constraints:
				# Limit vertical rotation angle
				rotation.x = clamp(rotation.x, orbit_min_angle, orbit_max_angle)
			
			# Update target point
			zoom_target = orbit_center
		
		# Handle right mouse button panning
		if is_right_mouse_pressed and !is_camera_locked:
			# Handle keyboard movement of orbit point
			var input_dir = Vector3.ZERO
			if Input.is_key_pressed(key_forward) or Input.is_key_pressed(key_alt_forward):
				input_dir.z -= 1
			if Input.is_key_pressed(key_backward) or Input.is_key_pressed(key_alt_backward):
				input_dir.z += 1
			if Input.is_key_pressed(key_left) or Input.is_key_pressed(key_alt_left):
				input_dir.x -= 1
			if Input.is_key_pressed(key_right) or Input.is_key_pressed(key_alt_right):
				input_dir.x += 1
			
			if input_dir != Vector3.ZERO:
				input_dir = input_dir.normalized()
				var movement = global_transform.basis * input_dir
				movement.y = 0  # Keep movement horizontal
				target_node.global_position += movement * move_speed * delta
				
				# Update target point
				zoom_target = target_node.global_position
		
		# Handle middle mouse button for orbit point movement
		elif mouse_drag_enabled and is_middle_mouse_pressed and mouse_middle_button_action == 1 and !is_camera_locked:
			var screen_size = get_viewport().size
			var mouse_pos = get_viewport().get_mouse_position()
			
			# Create a plane at target object's level
			var plane = Plane(Vector3.UP, orbit_center.y)
			
			# Project current and previous mouse positions to plane
			var from = project_ray_origin(last_mouse_position)
			var to = from + project_ray_normal(last_mouse_position) * 1000
			var from2 = project_ray_origin(mouse_pos)
			var to2 = from2 + project_ray_normal(mouse_pos) * 1000
			
			var hit_point1 = plane.intersects_ray(from, to - from)
			var hit_point2 = plane.intersects_ray(from2, to2 - from2)
			
			if hit_point1 and hit_point2:
				var offset = hit_point1 - hit_point2
				target_node.global_position += offset
				
				# Update target point
				zoom_target = target_node.global_position
			
			last_mouse_position = mouse_pos
		
		# Look at the target
		look_at_point(orbit_center)
		
# Переписать функцию автовращения
# Handles orbit auto-rotation / Обрабатывает автоматическое вращение в орбитальном режиме
func handle_orbit_auto_rotation(delta: float) -> void:
	if !orbit_auto_rotation_enabled or !target_node:
		return
		
	var orbit_center = target_node.global_position
	
	# Get current vector from target to camera / Получаем текущий вектор от цели до камеры
	var center_to_cam = global_position - orbit_center
	var distance = center_to_cam.length()
	
	# Create quaternion for rotation around axis / Создаем кватернион для вращения вокруг оси
	var rotation_speed = orbit_auto_rotation_speed * (1.0 if !orbit_invert_auto_rotation else -1.0)
	var rotation_quat = Quaternion(orbit_auto_rotation_axis.normalized(), rotation_speed * delta)
	
	# Rotate camera position / Вращаем позицию камеры
	var rotated_position = rotation_quat * center_to_cam
	
	# Set new camera position / Устанавливаем новую позицию камеры
	global_position = orbit_center + rotated_position
	
	# Look at target / Смотрим на цель
	look_at(orbit_center, Vector3.UP)
	
	emit_signal("camera_moved", global_position)
	emit_signal("camera_rotated", rotation)

# Toggle orbit X-rotation inversion
func toggle_orbit_x_inversion() -> void:
	orbit_invert_x_rotation = !orbit_invert_x_rotation
	print("Orbit X rotation inversion: " + ("ON" if orbit_invert_x_rotation else "OFF"))

# Toggle orbit Y-rotation inversion
func toggle_orbit_y_inversion() -> void:
	orbit_invert_y_rotation = !orbit_invert_y_rotation
	print("Orbit Y rotation inversion: " + ("ON" if orbit_invert_y_rotation else "OFF"))

# Toggle orbit auto-rotation / Переключение автовращения в орбитальном режиме
func toggle_orbit_auto_rotation() -> void:
	orbit_auto_rotation_enabled = !orbit_auto_rotation_enabled
	print("Orbit auto-rotation: " + ("ON" if orbit_auto_rotation_enabled else "OFF"))
	emit_signal("auto_rotation_toggled", orbit_auto_rotation_enabled)

# Toggle auto-rotation inversion / Переключение инверсии автовращения
func toggle_orbit_auto_rotation_inversion() -> void:
	orbit_invert_auto_rotation = !orbit_invert_auto_rotation
	print("Orbit auto-rotation inversion: " + ("ON" if orbit_invert_auto_rotation else "OFF"))

### STANDARD CAMERA FUNCTIONS ###

# Apply smooth zoom
func smooth_zoom(delta: float) -> void:
	if abs(zoom_level - target_zoom_level) > 0.01:
		zoom_level = lerp(zoom_level, target_zoom_level, zoom_smoothing * delta)
		apply_zoom()

# Constrain camera position within bounds
func clamp_position() -> void:
	position = position.clamp(movement_bounds.position, movement_bounds.end)

# Get zoom focus point
func get_zoom_target() -> Vector3:
	var forward = -global_transform.basis.z.normalized()
	return global_position + forward * zoom_level

# Apply zoom
func apply_zoom() -> void:
	var direction = (zoom_target - global_position).normalized()
	global_position = zoom_target - direction * zoom_level

# Handle mouse button input
func handle_mouse_buttons(event: InputEventMouseButton) -> void:
	# First handle orbit mode zoom
	if handle_orbit_mouse_wheel(event):
		return
	
	# Zoom handling for other modes
	if enable_zoom:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_target = get_zoom_target()
			target_zoom_level = max(min_zoom, target_zoom_level - zoom_speed)
			emit_signal("camera_zoomed", target_zoom_level)
			
			# Optionally change movement speed with mouse wheel + Shift
			if mouse_control_enabled and Input.is_key_pressed(KEY_SHIFT):
				move_speed = max(0.1, move_speed + mouse_scroll_speed_factor)
				print("Camera speed: ", move_speed)
				
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_target = get_zoom_target()
			target_zoom_level = min(max_zoom, target_zoom_level + zoom_speed)
			emit_signal("camera_zoomed", target_zoom_level)
			
			# Optionally change movement speed with mouse wheel + Shift
			if mouse_control_enabled and Input.is_key_pressed(KEY_SHIFT):
				move_speed = max(0.1, move_speed - mouse_scroll_speed_factor)
				print("Camera speed: ", move_speed)
	
	# Camera rotation - start capturing on left mouse press
	if event.button_index == mouse_button_rotate:
		is_mouse_pressed = event.pressed
		if is_mouse_pressed:
			last_mouse_position = event.position
			
	# Right mouse button for panning in orbit mode
	if event.button_index == mouse_button_pan:
		is_right_mouse_pressed = event.pressed
		if is_right_mouse_pressed:
			last_mouse_position = event.position
			
			# Determine panning mode based on modifiers
			if Input.is_key_pressed(KEY_SHIFT):
				is_vertical_pan = true
			elif Input.is_key_pressed(KEY_ALT):
				is_horizontal_pan = true
		else:
			is_vertical_pan = false
			is_horizontal_pan = false
			
	# Middle mouse button for additional control
	if event.button_index == MOUSE_BUTTON_MIDDLE:
		is_middle_mouse_pressed = event.pressed
		if is_middle_mouse_pressed:
			last_mouse_position = event.position

### FIRST/THIRD PERSON CAMERA MODES ###

# First person camera movement
func handle_first_person_movement(delta: float) -> void:
	# Check if we have a target for the camera
	if target_node == null and target_node_path != NodePath(""):
		# Try to get the node at the specified path
		target_node = get_node_or_null(target_node_path)
		if target_node:
			print("First Person Camera: Target node found at path: ", target_node_path)
		else:
			print("First Person Camera: ERROR - Target node not found at path: ", target_node_path)
			return
	
	if target_node:
		# Get target's transform
		var target_transform = target_node.global_transform
		
		# Calculate camera position in first person
		# Start with the target's position
		var camera_pos = target_transform.origin
		
		# Apply the offset in target's local space
		var local_offset = first_person_offset
		camera_pos += target_transform.basis.x * local_offset.x  # Left/Right offset
		camera_pos.y += local_offset.y  # Height offset (in world space)
		camera_pos += target_transform.basis.z * local_offset.z  # Forward/Back offset
		
		# For locked camera, directly set the position without smoothing
		global_position = camera_pos
		
		# Set rotation to match target rotation (plus any offset)
		var target_rotation = target_transform.basis.get_euler()
		
		# Add rotation offset
		target_rotation += first_person_rotation_offset
		
		# Directly set rotation without smoothing
		global_transform.basis = Basis.from_euler(target_rotation)
		
		emit_signal("camera_moved", global_position)
		emit_signal("camera_rotated", target_rotation)
	else:
		print("First Person Camera: No target node assigned.")

# Third person camera movement
func handle_third_person_movement(delta: float) -> void:
	# Check if we have a target for the camera
	if target_node == null and target_node_path != NodePath(""):
		# Try to get the node at the specified path
		target_node = get_node_or_null(target_node_path)
		if target_node:
			print("Third Person Camera: Target node found at path: ", target_node_path)
		else:
			print("Third Person Camera: ERROR - Target node not found at path: ", target_node_path)
			return
	
	if target_node:
		# Get target's transform
		var target_transform = target_node.global_transform
		
		# Calculate first person rotation (identical to first person mode)
		var target_rotation = target_transform.basis.get_euler()
		target_rotation += first_person_rotation_offset
		
		# Apply rotation first (same as first person mode)
		global_transform.basis = Basis.from_euler(target_rotation)
		
		# Now calculate position based on the current rotation
		var camera_direction = -global_transform.basis.z  # Direction camera is looking
		
		# Position the camera behind the player (opposite to look direction)
		var camera_pos = target_transform.origin - (camera_direction * third_person_distance)
		
		# Add height
		camera_pos.y = target_transform.origin.y + third_person_height
		
		# Add side offset if needed
		if third_person_offset.x != 0:
			var right_vector = global_transform.basis.x
			camera_pos += right_vector * third_person_offset.x
		
		# Apply additional vertical offset if needed
		if third_person_offset.y != 0:
			camera_pos.y += third_person_offset.y
		
		# For locked camera, directly set the position without smoothing
		global_position = camera_pos
		
		emit_signal("camera_moved", global_position)
		emit_signal("camera_rotated", target_rotation)
	else:
		print("Third Person Camera: No target node assigned.")

### UTILITY FUNCTIONS ###

# Set camera position
func set_camera_position(new_position: Vector3) -> void:
	position = new_position
	if use_bounds:
		clamp_position()
	emit_signal("camera_moved", position)

# Point camera at a target
func look_at_point(target_point: Vector3, up_vector: Vector3 = Vector3.UP) -> void:
	look_at(target_point, up_vector)
	if enable_zoom:
		zoom_target = target_point
		zoom_level = global_position.distance_to(target_point)
	emit_signal("camera_rotated", rotation)

# Reset camera to initial position
func reset_camera() -> void:
	position = initial_position
	rotation_degrees = initial_rotation_degrees
	zoom_level = initial_zoom_level
	target_zoom_level = zoom_level
	if enable_zoom:
		zoom_target = get_zoom_target()
	velocity = Vector3.ZERO
	emit_signal("camera_moved", position)
	emit_signal("camera_rotated", rotation)
	emit_signal("camera_zoomed", zoom_level)

# Set movement keys
func set_movement_keys(forward: int, backward: int, left: int, right: int, up: int, down: int) -> void:
	key_forward = forward
	key_backward = backward
	key_left = left
	key_right = right
	key_up = up
	key_down = down

# Set default WASD/arrow control scheme
func set_default_controls() -> void:
	key_forward = KEY_W
	key_backward = KEY_S
	key_left = KEY_A
	key_right = KEY_D
	key_up = KEY_E
	key_down = KEY_Q
	key_alt_forward = KEY_UP
	key_alt_backward = KEY_DOWN
	key_alt_left = KEY_LEFT
	key_alt_right = KEY_RIGHT
	key_auto_rotate = KEY_SPACE

# Toggle axis inversion
func toggle_invert_y() -> void:
	invert_y = !invert_y
	print("Y-axis inversion: " + ("ON" if invert_y else "OFF"))
	emit_signal("invert_y_changed", invert_y)

func toggle_invert_x() -> void:
	invert_x = !invert_x
	print("X-axis inversion: " + ("ON" if invert_x else "OFF"))
	emit_signal("invert_x_changed", invert_x)

# Set target node
func set_target_node(node: Node3D) -> void:
	target_node = node
	if target_node:
		match camera_mode:
			CameraMode.THIRD_PERSON:
				print("Third Person Camera: Target node set to ", node.name)
			CameraMode.FIRST_PERSON:
				print("First Person Camera: Target node set to ", node.name)
			CameraMode.ORBIT:
				print("Orbit Camera: Target node set to ", node.name)

# Change camera mode with optional smooth transition
func set_camera_mode(mode: CameraMode, smooth_transition: bool = false, custom_duration: float = -1.0) -> void:
	# If already in this mode, do nothing
	if camera_mode == mode and !transitioning:
		return
	
	# Don't allow changing mode during a transition
	if transitioning:
		print("Cannot change camera mode during transition")
		return
		
	# Save previous mode
	var previous_mode = camera_mode
	
	# If smooth transition is requested
	if smooth_transition:
		# Save transition data
		transition_from_mode = camera_mode
		transition_to_mode = mode
		transition_from_position = global_position
		transition_from_rotation = global_rotation
		
		# Calculate target position and rotation based on mode
		match mode:
			CameraMode.FREE:
				# For free mode, use current parameters
				transition_to_position = global_position
				transition_to_rotation = global_rotation
			
			CameraMode.ORBIT:
				# For orbit mode, look at target point
				if target_node == null and target_node_path != NodePath(""):
					target_node = get_node_or_null(target_node_path)
				
				if target_node:
					var orbit_center = target_node.global_position
					var dir = global_position - orbit_center
					dir = dir.normalized() * orbit_distance
					transition_to_position = orbit_center + dir
					# Calculate rotation to look at orbit point
					var look_at_transform = global_transform.looking_at(orbit_center, Vector3.UP)
					transition_to_rotation = look_at_transform.basis.get_euler()
				else:
					# If no target point, use current position
					transition_to_position = global_position
					transition_to_rotation = global_rotation
			
			CameraMode.STRATEGY:
				# For strategy mode, raise camera upward
				transition_to_position = Vector3(global_position.x, strategy_height, global_position.z)
				transition_to_rotation = Vector3(strategy_pitch, global_rotation.y, 0)
			
			CameraMode.FIRST_PERSON, CameraMode.THIRD_PERSON:
				# For first and third person modes, calculate position and rotation
				if target_node == null and target_node_path != NodePath(""):
					target_node = get_node_or_null(target_node_path)
				
				if target_node:
					var target_transform = target_node.global_transform
					
					if mode == CameraMode.FIRST_PERSON:
						# Camera position for first person mode
						var camera_pos = target_transform.origin
						camera_pos += target_transform.basis.x * first_person_offset.x
						camera_pos.y += first_person_offset.y
						camera_pos += target_transform.basis.z * first_person_offset.z
						
						transition_to_position = camera_pos
						transition_to_rotation = target_transform.basis.get_euler() + first_person_rotation_offset
					else:
						# Camera position for third person mode
						var target_rotation = target_transform.basis.get_euler() + first_person_rotation_offset
						var camera_dir = -Basis.from_euler(target_rotation).z
						var camera_pos = target_transform.origin - (camera_dir * third_person_distance)
						camera_pos.y = target_transform.origin.y + third_person_height
						
						transition_to_position = camera_pos
						transition_to_rotation = target_rotation
				else:
					# If no target point, use current position
					transition_to_position = global_position
					transition_to_rotation = global_rotation
		
		# Setup transition parameters
		transition_t = 0.0
		transition_duration = custom_duration if custom_duration > 0 else 1.0
		transitioning = true
	
	# Set new mode
	camera_mode = mode
	
	# Manage auto-rotation
	if mode != CameraMode.ORBIT:
		auto_rotating = false
	
	emit_signal("camera_mode_changed", mode)
	print("Camera Mode changed from %s to %s" % [CameraMode.keys()[previous_mode], CameraMode.keys()[mode]])

### SETTINGS MANAGEMENT ###

# Save camera settings to file
func save_camera_settings(file_path: String = "user://camera_settings.cfg") -> bool:
	var config = ConfigFile.new()
	
	# Save basic settings
	config.set_value("General", "camera_mode", camera_mode)
	config.set_value("General", "move_speed", move_speed)
	config.set_value("General", "acceleration", acceleration)
	config.set_value("General", "enable_vertical_movement", enable_vertical_movement)
	config.set_value("General", "use_bounds", use_bounds)
	config.set_value("General", "velocity_deadzone", velocity_deadzone)
	
	# Save mouse settings
	config.set_value("Mouse", "mouse_control_enabled", mouse_control_enabled)
	config.set_value("Mouse", "mouse_sensitivity", mouse_sensitivity)
	config.set_value("Mouse", "mouse_drag_enabled", mouse_drag_enabled)
	config.set_value("Mouse", "mouse_drag_sensitivity", mouse_drag_sensitivity)
	config.set_value("Mouse", "invert_y", invert_y)
	config.set_value("Mouse", "invert_x", invert_x)
	config.set_value("Mouse", "orbit_mouse_vertical_movement_enabled", orbit_mouse_vertical_movement_enabled)
	config.set_value("Mouse", "orbit_mouse_horizontal_movement_enabled", orbit_mouse_horizontal_movement_enabled)
	config.set_value("Mouse", "free_mouse_movement_enabled", free_mouse_movement_enabled)
	config.set_value("Mouse", "free_mouse_movement_sensitivity", free_mouse_movement_sensitivity)
	config.set_value("Mouse", "mouse_invert_vertical_movement", mouse_invert_vertical_movement)
	
	# Save zoom settings
	config.set_value("Zoom", "enable_zoom", enable_zoom)
	config.set_value("Zoom", "zoom_speed", zoom_speed)
	config.set_value("Zoom", "min_zoom", min_zoom)
	config.set_value("Zoom", "max_zoom", max_zoom)
	config.set_value("Zoom", "initial_zoom_level", initial_zoom_level)
	config.set_value("Zoom", "zoom_smoothing", zoom_smoothing)
	
	# Save orbit camera settings
	config.set_value("Orbit", "orbit_distance", orbit_distance)
	config.set_value("Orbit", "orbit_follow_enabled", orbit_follow_enabled)
	if orbit_follow_target:
		config.set_value("Orbit", "orbit_follow_target", orbit_follow_target.get_path())
	else:
		config.set_value("Orbit", "orbit_follow_target", "")
	config.set_value("Orbit", "orbit_follow_smoothing", orbit_follow_smoothing)
	config.set_value("Orbit", "orbit_rotation_constraints", orbit_rotation_constraints)
	config.set_value("Orbit", "orbit_min_angle", orbit_min_angle)
	config.set_value("Orbit", "orbit_max_angle", orbit_max_angle)
	config.set_value("Orbit", "orbit_allow_mouse_zoom", orbit_allow_mouse_zoom)
	
	# Save strategy camera settings
	config.set_value("Strategy", "strategy_height", strategy_height)
	config.set_value("Strategy", "strategy_pitch", strategy_pitch)
	config.set_value("Strategy", "strategy_min_height", strategy_min_height)
	config.set_value("Strategy", "strategy_max_height", strategy_max_height)
	config.set_value("Strategy", "strategy_edge_scroll", strategy_edge_scroll)
	config.set_value("Strategy", "strategy_edge_scroll_margin", strategy_edge_scroll_margin)
	config.set_value("Strategy", "strategy_edge_scroll_speed", strategy_edge_scroll_speed)
	config.set_value("Strategy", "strategy_rotation_enabled", strategy_rotation_enabled)
	config.set_value("Strategy", "strategy_fixed_angle", strategy_fixed_angle)
	config.set_value("Strategy", "strategy_current_preset", strategy_current_preset)
	config.set_value("Strategy", "strategy_follow_target", strategy_follow_target) # Now this is handled correctly as bool
	config.set_value("Strategy", "strategy_target_offset", strategy_target_offset)
	
	# Save first person camera settings
	config.set_value("FirstPerson", "first_person_offset", first_person_offset)
	config.set_value("FirstPerson", "first_person_rotation_offset", first_person_rotation_offset)
	config.set_value("FirstPerson", "first_person_smoothing", first_person_smoothing)
	
	# Save third person camera settings
	config.set_value("ThirdPerson", "third_person_distance", third_person_distance)
	config.set_value("ThirdPerson", "third_person_height", third_person_height)
	config.set_value("ThirdPerson", "third_person_offset", third_person_offset)
	config.set_value("ThirdPerson", "third_person_smoothing", third_person_smoothing)
	
	# Save rotation settings
	config.set_value("Rotation", "rotation_sensitivity", rotation_sensitivity)
	config.set_value("Rotation", "min_pitch", min_pitch)
	config.set_value("Rotation", "max_pitch", max_pitch)
	config.set_value("Rotation", "auto_rotation_speed", auto_rotation_speed)
	
	# Save key bindings
	config.set_value("Keys", "key_forward", key_forward)
	config.set_value("Keys", "key_backward", key_backward)
	config.set_value("Keys", "key_left", key_left)
	config.set_value("Keys", "key_right", key_right)
	config.set_value("Keys", "key_up", key_up)
	config.set_value("Keys", "key_down", key_down)
	config.set_value("Keys", "key_alt_forward", key_alt_forward)
	config.set_value("Keys", "key_alt_backward", key_alt_backward)
	config.set_value("Keys", "key_alt_left", key_alt_left)
	config.set_value("Keys", "key_alt_right", key_alt_right)
	config.set_value("Keys", "key_auto_rotate", key_auto_rotate)
	config.set_value("Keys", "key_toggle_lock", key_toggle_lock)
	config.set_value("Keys", "key_toggle_mouse_control", key_toggle_mouse_control)
	config.set_value("Keys", "key_toggle_rotation", key_toggle_rotation)
	config.set_value("Keys", "key_next_preset", key_next_preset)
	config.set_value("Keys", "key_reset_camera", key_reset_camera)
	
	# Write config file
	var error = config.save(file_path)
	if error == OK:
		print("Camera settings saved to: " + file_path)
		return true
	else:
		push_error("Failed to save camera settings to: " + file_path)
		return false

# Load camera settings from file
func load_camera_settings(file_path: String = "user://camera_settings.cfg") -> bool:
	var config = ConfigFile.new()
	var error = config.load(file_path)
	
	if error != OK:
		push_error("Failed to load camera settings from: " + file_path)
		return false
		
	# Load basic settings
	if config.has_section_key("General", "camera_mode"):
		camera_mode = config.get_value("General", "camera_mode")
	if config.has_section_key("General", "move_speed"):
		move_speed = config.get_value("General", "move_speed")
	if config.has_section_key("General", "acceleration"):
		acceleration = config.get_value("General", "acceleration")
	if config.has_section_key("General", "enable_vertical_movement"):
		enable_vertical_movement = config.get_value("General", "enable_vertical_movement")
	if config.has_section_key("General", "use_bounds"):
		use_bounds = config.get_value("General", "use_bounds")
	if config.has_section_key("General", "velocity_deadzone"):
		velocity_deadzone = config.get_value("General", "velocity_deadzone")
	
	# Load mouse settings
	if config.has_section_key("Mouse", "mouse_control_enabled"):
		mouse_control_enabled = config.get_value("Mouse", "mouse_control_enabled")
	if config.has_section_key("Mouse", "mouse_sensitivity"):
		mouse_sensitivity = config.get_value("Mouse", "mouse_sensitivity")
	if config.has_section_key("Mouse", "mouse_drag_enabled"):
		mouse_drag_enabled = config.get_value("Mouse", "mouse_drag_enabled")
	if config.has_section_key("Mouse", "mouse_drag_sensitivity"):
		mouse_drag_sensitivity = config.get_value("Mouse", "mouse_drag_sensitivity")
	if config.has_section_key("Mouse", "invert_y"):
		invert_y = config.get_value("Mouse", "invert_y")
	if config.has_section_key("Mouse", "invert_x"):
		invert_x = config.get_value("Mouse", "invert_x")
	if config.has_section_key("Mouse", "orbit_mouse_vertical_movement_enabled"):
		orbit_mouse_vertical_movement_enabled = config.get_value("Mouse", "orbit_mouse_vertical_movement_enabled")
	if config.has_section_key("Mouse", "orbit_mouse_horizontal_movement_enabled"):
		orbit_mouse_horizontal_movement_enabled = config.get_value("Mouse", "orbit_mouse_horizontal_movement_enabled")
	if config.has_section_key("Mouse", "free_mouse_movement_enabled"):
		free_mouse_movement_enabled = config.get_value("Mouse", "free_mouse_movement_enabled")
	if config.has_section_key("Mouse", "free_mouse_movement_sensitivity"):
		free_mouse_movement_sensitivity = config.get_value("Mouse", "free_mouse_movement_sensitivity")
	if config.has_section_key("Mouse", "mouse_invert_vertical_movement"):
		mouse_invert_vertical_movement = config.get_value("Mouse", "mouse_invert_vertical_movement")
	
	# Load zoom settings
	if config.has_section_key("Zoom", "enable_zoom"):
		enable_zoom = config.get_value("Zoom", "enable_zoom")
	if config.has_section_key("Zoom", "zoom_speed"):
		zoom_speed = config.get_value("Zoom", "zoom_speed")
	if config.has_section_key("Zoom", "min_zoom"):
		min_zoom = config.get_value("Zoom", "min_zoom")
	if config.has_section_key("Zoom", "max_zoom"):
		max_zoom = config.get_value("Zoom", "max_zoom")
	if config.has_section_key("Zoom", "initial_zoom_level"):
		initial_zoom_level = config.get_value("Zoom", "initial_zoom_level")
	if config.has_section_key("Zoom", "zoom_smoothing"):
		zoom_smoothing = config.get_value("Zoom", "zoom_smoothing")
	
	# Load orbit camera settings
	if config.has_section_key("Orbit", "orbit_distance"):
		orbit_distance = config.get_value("Orbit", "orbit_distance")
	if config.has_section_key("Orbit", "orbit_follow_enabled"):
		orbit_follow_enabled = config.get_value("Orbit", "orbit_follow_enabled")
	if config.has_section_key("Orbit", "orbit_follow_target"):
		var target_path = config.get_value("Orbit", "orbit_follow_target")
		if target_path is String and target_path != "":
			orbit_follow_target = get_node_or_null(target_path)
		else:
			orbit_follow_target = null
	if config.has_section_key("Orbit", "orbit_follow_smoothing"):
		orbit_follow_smoothing = config.get_value("Orbit", "orbit_follow_smoothing")
	if config.has_section_key("Orbit", "orbit_rotation_constraints"):
		orbit_rotation_constraints = config.get_value("Orbit", "orbit_rotation_constraints")
	if config.has_section_key("Orbit", "orbit_min_angle"):
		orbit_min_angle = config.get_value("Orbit", "orbit_min_angle")
	if config.has_section_key("Orbit", "orbit_max_angle"):
		orbit_max_angle = config.get_value("Orbit", "orbit_max_angle")
	if config.has_section_key("Orbit", "orbit_allow_mouse_zoom"):
		orbit_allow_mouse_zoom = config.get_value("Orbit", "orbit_allow_mouse_zoom")
	
	# Load strategy camera settings
	if config.has_section_key("Strategy", "strategy_height"):
		strategy_height = config.get_value("Strategy", "strategy_height")
	if config.has_section_key("Strategy", "strategy_pitch"):
		strategy_pitch = config.get_value("Strategy", "strategy_pitch")
	if config.has_section_key("Strategy", "strategy_min_height"):
		strategy_min_height = config.get_value("Strategy", "strategy_min_height")
	if config.has_section_key("Strategy", "strategy_max_height"):
		strategy_max_height = config.get_value("Strategy", "strategy_max_height")
	if config.has_section_key("Strategy", "strategy_edge_scroll"):
		strategy_edge_scroll = config.get_value("Strategy", "strategy_edge_scroll")
	if config.has_section_key("Strategy", "strategy_edge_scroll_margin"):
		strategy_edge_scroll_margin = config.get_value("Strategy", "strategy_edge_scroll_margin")
	if config.has_section_key("Strategy", "strategy_edge_scroll_speed"):
		strategy_edge_scroll_speed = config.get_value("Strategy", "strategy_edge_scroll_speed")
	if config.has_section_key("Strategy", "strategy_rotation_enabled"):
		strategy_rotation_enabled = config.get_value("Strategy", "strategy_rotation_enabled")
	if config.has_section_key("Strategy", "strategy_fixed_angle"):
		strategy_fixed_angle = config.get_value("Strategy", "strategy_fixed_angle")
	if config.has_section_key("Strategy", "strategy_current_preset"):
		strategy_current_preset = config.get_value("Strategy", "strategy_current_preset")
	if config.has_section_key("Strategy", "strategy_follow_target"):
		strategy_follow_target = config.get_value("Strategy", "strategy_follow_target") as bool # Cast to bool
	if config.has_section_key("Strategy", "strategy_target_offset"):
		strategy_target_offset = config.get_value("Strategy", "strategy_target_offset")
	
	# Load first-person camera settings
	if config.has_section_key("FirstPerson", "first_person_offset"):
		first_person_offset = config.get_value("FirstPerson", "first_person_offset")
	if config.has_section_key("FirstPerson", "first_person_rotation_offset"):
		first_person_rotation_offset = config.get_value("FirstPerson", "first_person_rotation_offset")
	if config.has_section_key("FirstPerson", "first_person_smoothing"):
		first_person_smoothing = config.get_value("FirstPerson", "first_person_smoothing")
	
	# Load third-person camera settings
	if config.has_section_key("ThirdPerson", "third_person_distance"):
		third_person_distance = config.get_value("ThirdPerson", "third_person_distance")
	if config.has_section_key("ThirdPerson", "third_person_height"):
		third_person_height = config.get_value("ThirdPerson", "third_person_height")
	if config.has_section_key("ThirdPerson", "third_person_offset"):
		third_person_offset = config.get_value("ThirdPerson", "third_person_offset")
	if config.has_section_key("ThirdPerson", "third_person_smoothing"):
		third_person_smoothing = config.get_value("ThirdPerson", "third_person_smoothing")
	
	# Load rotation settings
	if config.has_section_key("Rotation", "rotation_sensitivity"):
		rotation_sensitivity = config.get_value("Rotation", "rotation_sensitivity")
	if config.has_section_key("Rotation", "min_pitch"):
		min_pitch = config.get_value("Rotation", "min_pitch")
	if config.has_section_key("Rotation", "max_pitch"):
		max_pitch = config.get_value("Rotation", "max_pitch")
	if config.has_section_key("Rotation", "auto_rotation_speed"):
		auto_rotation_speed = config.get_value("Rotation", "auto_rotation_speed")
	
	# Load key bindings
	if config.has_section_key("Keys", "key_forward"):
		key_forward = config.get_value("Keys", "key_forward")
	if config.has_section_key("Keys", "key_backward"):
		key_backward = config.get_value("Keys", "key_backward")
	if config.has_section_key("Keys", "key_left"):
		key_left = config.get_value("Keys", "key_left")
	if config.has_section_key("Keys", "key_right"):
		key_right = config.get_value("Keys", "key_right")
	if config.has_section_key("Keys", "key_up"):
		key_up = config.get_value("Keys", "key_up")
	if config.has_section_key("Keys", "key_down"):
		key_down = config.get_value("Keys", "key_down")
	
	# Initialize internal variables
	zoom_level = initial_zoom_level
	target_zoom_level = zoom_level
	if enable_zoom:
		zoom_target = get_zoom_target()
	
	print("Camera settings loaded from: " + file_path)
	return true

# Reset all camera settings to defaults
func reset_all_camera_settings() -> void:
	# Basic settings
	camera_mode = CameraMode.FREE
	move_speed = 10.0
	acceleration = 5.0
	enable_vertical_movement = true
	use_bounds = true
	velocity_deadzone = 0.01
	
	# Mouse settings
	mouse_control_enabled = true
	mouse_sensitivity = 0.05
	mouse_drag_enabled = true
	mouse_drag_sensitivity = 0.01
	invert_y = false
	invert_x = true
	orbit_mouse_vertical_movement_enabled = true
	orbit_mouse_horizontal_movement_enabled = true
	free_mouse_movement_enabled = true
	free_mouse_movement_sensitivity = 0.05
	mouse_invert_vertical_movement = false
	
	# Zoom settings
	enable_zoom = true
	zoom_speed = 1.0
	min_zoom = 1.0
	max_zoom = 50.0
	initial_zoom_level = 10.0
	zoom_smoothing = 5.0
	
	# Orbit camera settings
	orbit_distance = 10.0
	orbit_follow_enabled = true
	orbit_follow_smoothing = 5.0
	orbit_rotation_constraints = false
	orbit_min_angle = -0.5
	orbit_max_angle = 1.4
	orbit_allow_mouse_zoom = true
	
	# Strategy camera settings
	strategy_height = 15.0
	strategy_pitch = -1.4
	strategy_min_height = 5.0
	strategy_max_height = 30.0
	strategy_edge_scroll = true
	strategy_edge_scroll_margin = 20
	strategy_edge_scroll_speed = 10.0
	strategy_rotation_enabled = true
	strategy_fixed_angle = false
	strategy_current_preset = 0
	strategy_follow_target = false
	strategy_target_offset = Vector3(0, 0, 0)
	
	# First-person camera settings
	first_person_offset = Vector3(0, 1.3, -0.3)
	first_person_rotation_offset = Vector3(0, 3.14159, 0)
	first_person_smoothing = 10.0
	
	# Third-person camera settings
	third_person_distance = 3.0
	third_person_height = 1.5
	third_person_offset = Vector3(0, 0, 0)
	third_person_smoothing = 5.0
	
	# Rotation settings
	rotation_sensitivity = 0.005
	min_pitch = -1.4
	max_pitch = 1.4
	auto_rotation_speed = 0.5
	
	# Reset control keys
	set_default_controls()
	
	# Reset position and rotation
	position = initial_position
	rotation_degrees = initial_rotation_degrees
	zoom_level = initial_zoom_level
	target_zoom_level = zoom_level
	velocity = Vector3.ZERO
	
	# Update zoom target
	if enable_zoom:
		zoom_target = get_zoom_target()
	
	print("All camera settings reset to defaults")

### ADVANCED CONVENIENCE FUNCTIONS ###

# Helper function to determine direction from a target
func get_forward_direction(target_node: Node3D) -> Vector3:
	# For most 3D models, -Z is forward
	# This can be adjusted based on your specific model orientation
	return target_node.global_transform.basis.z.normalized()

# Smooth animated move to point
func smooth_move_to_point_with_rotation(target_pos: Vector3, look_at_pos: Vector3, duration: float = 1.0) -> void:
	# Calculate target rotation to look at the point
	var look_dir = look_at_pos - target_pos
	var target_basis = Basis.looking_at(look_dir, Vector3.UP)
	var target_rotation = target_basis.get_euler()
	
	# Create tween for position
	var pos_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	pos_tween.tween_property(self, "position", target_pos, duration)
	
	# Create tween for rotation
	var rot_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	rot_tween.tween_property(self, "rotation", target_rotation, duration)
	
	# After movement is complete
	pos_tween.tween_callback(func():
		if use_bounds:
			clamp_position()
		emit_signal("camera_moved", position)
		emit_signal("camera_rotated", rotation)
	)

# Get current camera settings as dictionary
func get_current_settings() -> Dictionary:
	var settings = {
		"camera_mode": CameraMode.keys()[camera_mode],
		"position": position,
		"rotation": rotation_degrees,
		"zoom_level": zoom_level,
		"move_speed": move_speed,
		"mouse_sensitivity": mouse_sensitivity,
		"invert_x": invert_x,
		"invert_y": invert_y
	}
	return settings

# Function to toggle various features by name
func toggle_feature(feature: String, value: bool) -> void:
	match feature:
		"free_mouse_movement":
			free_mouse_movement_enabled = value
		"orbit_vertical_movement":
			orbit_mouse_vertical_movement_enabled = value
		"orbit_horizontal_movement":
			orbit_mouse_horizontal_movement_enabled = value
		"strategy_edge_scroll":
			strategy_edge_scroll = value
		"strategy_rotation":
			strategy_rotation_enabled = value
		"strategy_fixed_angle":
			strategy_fixed_angle = value
		"orbit_follow_enabled":
			orbit_follow_enabled = value
		"strategy_follow_target":
			strategy_follow_target = value
		"orbit_rotation_constraints":
			orbit_rotation_constraints = value
		"orbit_allow_mouse_zoom":
			orbit_allow_mouse_zoom = value
		"mouse_control":
			mouse_control_enabled = value
		"mouse_drag":
			mouse_drag_enabled = value
		"auto_rotate":
			if camera_mode == CameraMode.ORBIT:
				auto_rotating = value
			else:
				push_warning("Auto-rotation is only available in ORBIT mode")
		_:
			push_warning("Unknown feature: " + feature)
	
	print("Feature '" + feature + "' set to: " + str(value))

# Print information about current mode and capabilities
func print_current_mode_info() -> void:
	var mode_name = CameraMode.keys()[camera_mode]
	var capabilities = ""
	
	match camera_mode:
		CameraMode.FREE:
			capabilities = "Free movement, rotation, zoom. Use mouse to look around, keyboard to move."
		CameraMode.ORBIT:
			capabilities = "Orbit around a target point. Left click to rotate, right click to adjust vertically, middle click to pan."
		CameraMode.STRATEGY:
			capabilities = "Top-down view with edge scrolling. Keyboard or mouse edge to move, mouse wheel to zoom."
		CameraMode.FIRST_PERSON:
			capabilities = "View from character's perspective. Camera follows target node."
		CameraMode.THIRD_PERSON:
			capabilities = "View from behind character. Camera follows target node at distance."
	
	print("Current camera mode: " + mode_name)
	print("Capabilities: " + capabilities)
	print("Press number keys 1-5 to switch between modes.")

# Get a human-readable description of the camera's current state
func get_state_description() -> String:
	var description = "Camera Mode: " + CameraMode.keys()[camera_mode] + "\n"
	description += "Position: " + str(position) + "\n"
	description += "Rotation: " + str(rotation_degrees) + "\n"
	description += "Zoom Level: " + str(zoom_level) + "\n"
	
	# Add mode-specific info
	match camera_mode:
		CameraMode.ORBIT:
			description += "Orbit Target: " + (target_node.name if target_node else "None") + "\n"
			description += "Orbit Distance: " + str(orbit_distance) + "\n"
		CameraMode.STRATEGY:
			description += "Strategy Height: " + str(strategy_height) + "\n"
			description += "Edge Scrolling: " + str(strategy_edge_scroll) + "\n"
		CameraMode.FIRST_PERSON, CameraMode.THIRD_PERSON:
			description += "Target: " + (target_node.name if target_node else "None") + "\n"
	
	return description
