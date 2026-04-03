extends Node2D
# ABOUT:
# Rewind Box - Music Player
# Created by Shubhayu15 for PROJEKTSANSSTUDIOS
# Shubhayu15 : https://github.com/Shubhayu15
# PROJEKTSANSSTUDIOS :https://github.com/Lord0Sanz
# MIT Licensed - Custom themes welcome!

# SPRITE REFERENCES
# Button Backgrounds
@onready var btn_vol_up_bg: Sprite2D = $CassetteVolUp/CassetteVolUp
@onready var btn_vol_down_bg: Sprite2D = $CassetteVolDown/CassetteVolDown
@onready var btn_play_bg: Sprite2D = $CassetteBttnA/CassetteBttnA
@onready var btn_prev_bg: Sprite2D = $CassetteBttnB/CassetteBttnB
@onready var btn_next_bg: Sprite2D = $CassetteBttnC/CassetteBttnC
@onready var btn_loop_bg: Sprite2D = $CassetteBttnD/CassetteBttnD

# Button Icons
@onready var btn_vol_up_icon: Sprite2D = $CassetteVolUp/CassetteVolUp/IconVolumeUp
@onready var btn_vol_down_icon: Sprite2D = $CassetteVolDown/CassetteVolDown/IconVolumeDown
@onready var btn_play_icon: Sprite2D = $CassetteBttnA/CassetteBttnA/IconPausePlay
@onready var btn_prev_icon: Sprite2D = $CassetteBttnB/CassetteBttnB/IconPrev
@onready var btn_next_icon: Sprite2D = $CassetteBttnC/CassetteBttnC/IconNext
@onready var btn_loop_icon: Sprite2D = $CassetteBttnD/CassetteBttnD/IconLoop

# Cassette Parts
@onready var cassette_bg: Sprite2D = $CassetteTape_0
@onready var cassette_mid: Sprite2D = $CassetteTape_1
@onready var cassette_inner: Sprite2D = $CassetteTape_2
@onready var ring_a: Sprite2D = $CassetteRingA
@onready var ring_b: Sprite2D = $CassetteRingB

# Main Elements
@onready var body: Sprite2D = $CassetteBody
@onready var logo: Sprite2D = $LOGO
@onready var ui_back_panel: Panel = $UI/BackPanel

# UI Elements
@onready var ui: Label = $UI/BackPanel/MarginContainer/ui
@onready var audio_player: AudioStreamPlayer = $AUDIO_PLAYER
@onready var click: AudioStreamPlayer = $click
@onready var cassette_ring_a: Sprite2D = $CassetteRingA
@onready var cassette_ring_b: Sprite2D = $CassetteRingB


# BUTTON ORIGINAL POSITIONS
var vol_up_original_pos: Vector2
var vol_down_original_pos: Vector2
var bttn_a_original_pos: Vector2
var bttn_b_original_pos: Vector2
var bttn_c_original_pos: Vector2
var bttn_d_original_pos: Vector2


# AUDIO VARIABLES
var current_volume: float = 70          # 0-100 scale
var is_playing: bool = false
var is_looping: bool = false
var current_song_name: String = ""
var song_duration: float = 0.0
var playback_timer: float = 0.0


# PLAYLIST VARIABLES
var playlist: Array = []
var current_song_index: int = 0
var valid_playlist: Array = []           # Only valid/loadable songs


# SCROLLING TITLE VARIABLES
var scroll_offset: int = 0
var scroll_timer: float = 0.0
var scroll_delay: float = 0.3
var displayed_song_name: String = ""


# DISPLAY SETTINGS
var display_chars: int = 20
var volume_display_timer: float = 0.0
var show_volume: bool = false
var volume_display_duration: float = 2.0


# WINDOW DRAGGING
var dragging: bool = false
var drag_start_pos: Vector2 = Vector2.ZERO


# ZOOM SETTINGS
var target_size: int = 512
var current_size: int = 512
var min_size: int = 128
var max_size: int = 512
var original_design_size: int = 512


# CASSETTE RING SPINNING
var ring_rotation_speed: float = 15.0
var ring_a_rotation: float = 0.0
var ring_b_rotation: float = 0.0


# LOADING STATE
var is_loading: bool = true


# INITIALIZATION
func _ready() -> void:
	# Setup window properties
	var window = get_window()
	window.always_on_top = true
	window.borderless = true
	window.transparent = true
	window.size = Vector2i(current_size, current_size)
	Engine.max_fps = 60
	
	# Load UI assets and themes
	load_ui_textures()
	
	# Show loading screen
	show_loading_screen()
	
	# Setup keyboard shortcuts
	setup_input_actions()
	
	# Store button original positions for animation
	store_button_positions()
	
	# Load music library
	await load_playlist()
	
	# Initialize player if songs found
	if valid_playlist.size() > 0:
		load_song(current_song_index)
		set_volume(current_volume)
		update_button_states()
		update_viewport_scale()
		show_music_display()
	else:
		show_no_music_error()


# UI TEXTURE & THEME LOADING
# Get UI folder path (external first, then embedded)
func get_ui_path() -> String:
	var external_path = OS.get_executable_path().get_base_dir() + "/ui/"
	if DirAccess.open(external_path):
		return external_path
	return "res://ui/"

# Load all textures from UI folder
func load_ui_textures() -> void:
	var ui_path = get_ui_path()
	
	# Load main body
	body.texture = load_texture_from_file(ui_path + "body.png")
	
	# Logo uses scene texture - only color modulation from JSON
	# cassette_bg.texture = load_texture_from_file(ui_path + "cassette_bg.png")
	# cassette_mid.texture = load_texture_from_file(ui_path + "cassette_mid.png")
	# cassette_inner.texture = load_texture_from_file(ui_path + "cassette_inner.png")
	
	# Load cassette parts
	cassette_bg.texture = load_texture_from_file(ui_path + "cassette_bg.png")
	cassette_mid.texture = load_texture_from_file(ui_path + "cassette_mid.png")
	cassette_inner.texture = load_texture_from_file(ui_path + "cassette_inner.png")
	
	# Load rings
	ring_a.texture = load_texture_from_file(ui_path + "ring_a.png")
	ring_b.texture = load_texture_from_file(ui_path + "ring_b.png")
	
	# Load button backgrounds
	btn_play_bg.texture = load_texture_from_file(ui_path + "btn_play_bg.png")
	btn_loop_bg.texture = load_texture_from_file(ui_path + "btn_loop_bg.png")
	btn_next_bg.texture = load_texture_from_file(ui_path + "btn_next_bg.png")
	btn_prev_bg.texture = load_texture_from_file(ui_path + "btn_prev_bg.png")
	btn_vol_up_bg.texture = load_texture_from_file(ui_path + "btn_vol_up_bg.png")
	btn_vol_down_bg.texture = load_texture_from_file(ui_path + "btn_vol_down_bg.png")
	
	# Load button icons
	btn_play_icon.texture = load_texture_from_file(ui_path + "btn_play_icon.png")
	btn_loop_icon.texture = load_texture_from_file(ui_path + "btn_loop_icon.png")
	btn_next_icon.texture = load_texture_from_file(ui_path + "btn_next_icon.png")
	btn_prev_icon.texture = load_texture_from_file(ui_path + "btn_prev_icon.png")
	btn_vol_up_icon.texture = load_texture_from_file(ui_path + "btn_vol_up_icon.png")
	btn_vol_down_icon.texture = load_texture_from_file(ui_path + "btn_vol_down_icon.png")
	
	# Load and apply theme colors
	var theme_data = load_theme_json(ui_path + "theme.json")
	if theme_data and theme_data.size() > 0:
		apply_color_modulations(theme_data)

# Load PNG texture directly (bypasses .import cache)
func load_texture_from_file(path: String) -> Texture2D:
	if not FileAccess.file_exists(path):
		return null
	
	var image = Image.new()
	var error = image.load(path)
	if error != OK:
		return null
	
	# Convert to RGBA8 if needed for compatibility
	if image.get_format() != Image.FORMAT_RGBA8:
		image.convert(Image.FORMAT_RGBA8)
	
	return ImageTexture.create_from_image(image)

# Load and parse theme.json
func load_theme_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}
	
	var json_text = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_text)
	
	if error != OK:
		return {}
	
	return json.data

# Apply color modulations from theme.json to all sprites
func apply_color_modulations(theme: Dictionary) -> void:
	# UI Back Panel
	if theme.has("ui_back_panel"):
		var c = theme["ui_back_panel"]
		ui_back_panel.self_modulate = Color(c.r, c.g, c.b, c.a)
	
	# Main body
	if theme.has("body"):
		var c = theme["body"]
		body.self_modulate = Color(c.r, c.g, c.b, c.a)
	
	# Logo
	if theme.has("logo"):
		var c = theme["logo"]
		logo.self_modulate = Color(c.r, c.g, c.b, c.a)
	
	# Cassette parts
	if theme.has("cassette_bg"):
		var c = theme["cassette_bg"]
		cassette_bg.self_modulate = Color(c.r, c.g, c.b, c.a)
	if theme.has("cassette_mid"):
		var c = theme["cassette_mid"]
		cassette_mid.self_modulate = Color(c.r, c.g, c.b, c.a)
	if theme.has("cassette_inner"):
		var c = theme["cassette_inner"]
		cassette_inner.self_modulate = Color(c.r, c.g, c.b, c.a)
	
	# Rings
	if theme.has("ring_a"):
		var c = theme["ring_a"]
		ring_a.self_modulate = Color(c.r, c.g, c.b, c.a)
	if theme.has("ring_b"):
		var c = theme["ring_b"]
		ring_b.self_modulate = Color(c.r, c.g, c.b, c.a)
	
	# Button backgrounds (use self_modulate to not affect children icons)
	var bg_buttons = [
		"btn_play_bg", "btn_loop_bg", "btn_next_bg", "btn_prev_bg",
		"btn_vol_up_bg", "btn_vol_down_bg"
	]
	for btn in bg_buttons:
		if theme.has(btn):
			var c = theme[btn]
			get(btn).self_modulate = Color(c.r, c.g, c.b, c.a)
	
	# Button icons (use modulate)
	var icon_buttons = [
		"btn_play_icon", "btn_loop_icon", "btn_next_icon", "btn_prev_icon",
		"btn_vol_up_icon", "btn_vol_down_icon"
	]
	for btn in icon_buttons:
		if theme.has(btn):
			var c = theme[btn]
			get(btn).modulate = Color(c.r, c.g, c.b, c.a)
	
	# UI text color
	if theme.has("ui_color"):
		var c = theme["ui_color"]
		ui.add_theme_color_override("font_color", Color(c.r, c.g, c.b, c.a))


# BUTTON POSITION STORAGE
func store_button_positions() -> void:
	vol_up_original_pos = $CassetteVolUp/CassetteVolUp.position
	vol_down_original_pos = $CassetteVolDown/CassetteVolDown.position
	bttn_a_original_pos = $CassetteBttnA/CassetteBttnA.position
	bttn_b_original_pos = $CassetteBttnB/CassetteBttnB.position
	bttn_c_original_pos = $CassetteBttnC/CassetteBttnC.position
	bttn_d_original_pos = $CassetteBttnD/CassetteBttnD.position


# DISPLAY FUNCTIONS
func show_loading_screen() -> void:
	is_loading = true
	ui.text = "REWINDBOX\nLOADING..."

func show_music_display() -> void:
	is_loading = false
	update_display()

func show_no_music_error() -> void:
	is_loading = true
	ui.text = "REWINDBOX\nNO MUSIC FOUND"


# INPUT ACTION SETUP
func setup_input_actions() -> void:
	var actions = {
		"play_pause": KEY_SPACE,
		"loop": KEY_ENTER,
		"next": KEY_RIGHT,
		"prev": KEY_LEFT,
		"vol_up": KEY_UP,
		"vol_down": KEY_DOWN
	}
	
	for action_name in actions:
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
			var key_event = InputEventKey.new()
			key_event.keycode = actions[action_name]
			InputMap.action_add_event(action_name, key_event)


# VIEWPORT SCALING
func update_viewport_scale() -> void:
	var current_width = get_window().size.x
	var scale_factor = float(current_width) / float(original_design_size)
	scale = Vector2(scale_factor, scale_factor)


# INPUT HANDLING
func _input(event: InputEvent) -> void:
	# Ignore inputs while loading (except ESC)
	if is_loading and not (event is InputEventKey and event.keycode == KEY_ESCAPE):
		return
	
	# Right-click window dragging
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			dragging = true
			drag_start_pos = get_global_mouse_position()
			get_viewport().set_input_as_handled()
		else:
			dragging = false
			get_viewport().set_input_as_handled()
	
	# Drag window movement
	if event is InputEventMouseMotion and dragging:
		var delta_pos = get_global_mouse_position() - drag_start_pos
		var new_pos = get_window().position + Vector2i(delta_pos)
		get_window().position = new_pos
		drag_start_pos = get_global_mouse_position()
		get_viewport().set_input_as_handled()
	
	# Action-based inputs
	if event.is_action_pressed("play_pause"):
		toggle_play_pause()
	elif event.is_action_pressed("loop"):
		toggle_loop()
	elif event.is_action_pressed("next"):
		click.play()
		momentary_press($CassetteBttnC/CassetteBttnC, Vector2(0, 40), bttn_c_original_pos)
		play_next_song()
	elif event.is_action_pressed("prev"):
		click.play()
		momentary_press($CassetteBttnB/CassetteBttnB, Vector2(0, 40), bttn_b_original_pos)
		play_previous_song()
	elif event.is_action_pressed("vol_up"):
		increase_volume()
	elif event.is_action_pressed("vol_down"):
		decrease_volume()
	elif event.is_action_pressed("quit"):
		get_tree().quit()
	
	# Direct key inputs
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				get_tree().quit()
			KEY_EQUAL:
				if event.ctrl_pressed:
					zoom_in()
			KEY_MINUS:
				if event.ctrl_pressed:
					zoom_out()


# AUDIO CONTROL FUNCTIONS
func toggle_play_pause() -> void:
	if is_loading:
		return
	click.play()
	
	if is_playing:
		audio_player.stream_paused = true
		is_playing = false
	else:
		if audio_player.stream_paused:
			audio_player.stream_paused = false
		elif valid_playlist.size() > 0 and audio_player.stream:
			audio_player.play()
		is_playing = true
	
	update_button_states()
	update_display()

func toggle_loop() -> void:
	if is_loading:
		return
	click.play()
	is_looping = !is_looping
	update_button_states()
	update_display()

func increase_volume() -> void:
	if is_loading:
		return
	click.play()
	momentary_press($CassetteVolUp/CassetteVolUp, Vector2(30, 0), vol_up_original_pos)
	current_volume = min(current_volume + 2, 100)
	set_volume(current_volume)
	show_volume = true
	volume_display_timer = 0.0
	update_display()

func decrease_volume() -> void:
	if is_loading:
		return
	click.play()
	momentary_press($CassetteVolDown/CassetteVolDown, Vector2(30, 0), vol_down_original_pos)
	current_volume = max(current_volume - 2, 0)
	set_volume(current_volume)
	show_volume = true
	volume_display_timer = 0.0
	update_display()

func set_volume(volume_percent: float) -> void:
	var volume_db: float
	if volume_percent >= 70:
		volume_db = (volume_percent - 70) / 30.0 * 6.0
	elif volume_percent > 0:
		var normalized = volume_percent / 70.0
		volume_db = -80.0 + (normalized * 80.0)
	else:
		volume_db = -80.0
	
	audio_player.volume_db = volume_db


# BUTTON ANIMATION
# Momentary button press animation (presses in, springs back)
func momentary_press(button: Node2D, press_offset: Vector2, original_pos: Vector2) -> void:
	var tween = create_tween()
	tween.tween_property(button, "position", original_pos + press_offset, 0.05)
	tween.tween_property(button, "position", original_pos, 0.1).set_delay(0.05)

# Update toggle button states (stays pressed when active)
func update_button_states() -> void:
	# Play/Pause button
	if is_playing:
		$CassetteBttnA/CassetteBttnA.position = bttn_a_original_pos + Vector2(0, 40)
	else:
		$CassetteBttnA/CassetteBttnA.position = bttn_a_original_pos
		reset_cassette_rings()
	
	# Loop button
	if is_looping:
		$CassetteBttnD/CassetteBttnD.position = bttn_d_original_pos + Vector2(0, 40)
	else:
		$CassetteBttnD/CassetteBttnD.position = bttn_d_original_pos


# ZOOM FUNCTIONS
func zoom_in() -> void:
	target_size = min(target_size + 16, max_size)
	apply_smooth_zoom()

func zoom_out() -> void:
	target_size = max(target_size - 16, min_size)
	apply_smooth_zoom()

func apply_smooth_zoom() -> void:
	var tween = create_tween()
	tween.tween_method(update_zoom, current_size, target_size, 0.2)
	await tween.finished
	current_size = target_size

func update_zoom(new_size: float) -> void:
	get_window().size = Vector2i(int(new_size), int(new_size))
	update_viewport_scale()


# MUSIC LIBRARY FUNCTIONS
# Get user's Music folder path (cross-platform)
func get_music_folder_path() -> String:
	var os_name = OS.get_name()
	var home_dir = ""
	
	match os_name:
		"Windows":
			home_dir = OS.get_environment("USERPROFILE")
			return home_dir + "\\Music"
		"macOS", "Linux":
			home_dir = OS.get_environment("HOME")
			return home_dir + "/Music"
		_:
			return "res://playlist"

# Recursively scan folder for audio files
func scan_directory_for_audio(dir_path: String) -> void:
	var dir = DirAccess.open(dir_path)
	if not dir:
		return
	
	dir.list_dir_begin()
	var item = dir.get_next()
	while item != "":
		if item != "." and item != "..":
			var full_path = dir_path + "/" + item
			if dir.current_is_dir():
				scan_directory_for_audio(full_path)
			else:
				var extension = item.get_extension().to_lower()
				if extension in ["mp3", "ogg", "wav"]:
					playlist.append(full_path)
		item = dir.get_next()
	dir.list_dir_end()

# Validate MP3 file by checking frame sync pattern
func is_valid_mp3(file_path: String) -> bool:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return false
	
	var data = file.get_buffer(1024)
	file.close()
	
	if data.size() < 4:
		return false
	
	for i in range(data.size() - 4):
		if data[i] == 0xFF and (data[i + 1] & 0xE0) == 0xE0:
			return true
	
	return false

# Load all valid audio files from Music folder
func load_playlist() -> void:
	playlist.clear()
	valid_playlist.clear()
	var music_folder = get_music_folder_path()
	
	await get_tree().create_timer(0.5).timeout
	
	var dir_check = DirAccess.open(music_folder)
	if dir_check:
		scan_directory_for_audio(music_folder)
		
		for song_path in playlist:
			var extension = song_path.get_extension().to_lower()
			if extension == "mp3":
				if is_valid_mp3(song_path):
					valid_playlist.append(song_path)
			else:
				valid_playlist.append(song_path)
		
		valid_playlist.sort()
	else:
		# Fallback to project playlist folder
		var fallback_dir = DirAccess.open("res://playlist")
		if fallback_dir:
			scan_directory_for_audio("res://playlist")
			for song_path in playlist:
				var extension = song_path.get_extension().to_lower()
				if extension == "mp3":
					if is_valid_mp3(song_path):
						valid_playlist.append(song_path)
				else:
					valid_playlist.append(song_path)
			valid_playlist.sort()

# Load MP3 file as AudioStreamMP3
func load_mp3_file(file_path: String) -> AudioStreamMP3:
	var mp3_stream = AudioStreamMP3.new()
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return null
	
	var data = file.get_buffer(file.get_length())
	if data.size() == 0:
		return null
	
	mp3_stream.data = data
	return mp3_stream if mp3_stream.data.size() > 0 else null

# Load song by index
func load_song(index: int) -> void:
	if index < 0 or index >= valid_playlist.size():
		return
	
	var song_path = valid_playlist[index]
	var extension = song_path.get_extension().to_lower()
	var song_stream: AudioStream = null
	
	match extension:
		"mp3":
			song_stream = load_mp3_file(song_path)
		"ogg", "wav":
			song_stream = load(song_path)
		_:
			song_stream = load(song_path)
	
	if song_stream:
		audio_player.stream = song_stream
		current_song_name = song_path.get_file().get_basename()
		song_duration = audio_player.stream.get_length()
		playback_timer = 0.0
		scroll_offset = 0
		scroll_timer = 0.0
	else:
		current_song_name = "Skipping: " + song_path.get_file()
		skip_corrupted_song()

# Skip corrupted song and move to next
func skip_corrupted_song() -> void:
	current_song_index += 1
	if current_song_index >= valid_playlist.size():
		current_song_index = 0
	
	if valid_playlist.size() > 0:
		load_song(current_song_index)


# PLAYBACK CONTROL


func play_next_song() -> void:
	if is_loading or valid_playlist.size() == 0:
		return
	
	current_song_index += 1
	if current_song_index >= valid_playlist.size():
		current_song_index = 0
	
	load_song(current_song_index)
	if audio_player.stream:
		audio_player.play()
		is_playing = true
	else:
		is_playing = false
	update_button_states()
	update_display()

func play_previous_song() -> void:
	if is_loading or valid_playlist.size() == 0:
		return
	
	current_song_index -= 1
	if current_song_index < 0:
		current_song_index = valid_playlist.size() - 1
	
	load_song(current_song_index)
	if audio_player.stream:
		audio_player.play()
		is_playing = true
	else:
		is_playing = false
	update_button_states()
	update_display()


# CASSETTE RING SPINNING


func spin_cassette_rings(delta: float) -> void:
	ring_a_rotation += ring_rotation_speed * delta
	ring_b_rotation -= ring_rotation_speed * delta
	
	cassette_ring_a.rotation = fmod(ring_a_rotation, 360.0)
	cassette_ring_b.rotation = fmod(ring_b_rotation, 360.0)

func reset_cassette_rings() -> void:
	ring_a_rotation = 0.0
	ring_b_rotation = 0.0
	cassette_ring_a.rotation = 0.0
	cassette_ring_b.rotation = 0.0


# MOUSE INPUT HANDLERS (BUTTONS)
func _on_cassette_vol_up_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		increase_volume()

func _on_cassette_vol_down_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		decrease_volume()

func _on_cassette_bttn_a_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		toggle_play_pause()

func _on_cassette_bttn_b_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		click.play()
		momentary_press($CassetteBttnB/CassetteBttnB, Vector2(0, 40), bttn_b_original_pos)
		play_previous_song()

func _on_cassette_bttn_c_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		click.play()
		momentary_press($CassetteBttnC/CassetteBttnC, Vector2(0, 40), bttn_c_original_pos)
		play_next_song()

func _on_cassette_bttn_d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		toggle_loop()

# MAIN GAME LOOP
func _process(delta: float) -> void:
	if is_loading:
		return
	
	# Update playback time and display
	if is_playing and audio_player.playing:
		playback_timer = audio_player.get_playback_position()
		update_display()
		spin_cassette_rings(delta)
	
	# Handle volume display timeout
	if show_volume:
		volume_display_timer += delta
		if volume_display_timer >= volume_display_duration:
			show_volume = false
			update_display()
	
	# Handle song end (loop or next)
	if is_playing and not audio_player.playing and playback_timer > 0:
		if is_looping:
			audio_player.play()
			playback_timer = 0.0
		else:
			play_next_song()
	
	# Update scrolling title animation
	if current_song_name != "" and not current_song_name.begins_with("Error:") and not current_song_name.begins_with("Skipping:"):
		scroll_timer += delta
		if scroll_timer >= scroll_delay:
			scroll_timer = 0.0
			scroll_offset += 1
			if scroll_offset > len(current_song_name):
				scroll_offset = 0
			update_display()


# UI DISPLAY UPDATE
# Format time as MM:SS or HH:MM:SS
func format_time(seconds: float) -> String:
	var total_seconds = int(seconds)
	@warning_ignore("integer_division")
	var hours = total_seconds / 3600
	@warning_ignore("integer_division")
	var minutes = (total_seconds % 3600) / 60
	var secs = total_seconds % 60
	
	if hours > 0:
		return "%02d:%02d:%02d" % [hours, minutes, secs]
	return "%02d:%02d" % [minutes, secs]

# Pad string to exact length with spaces
func pad_string(text: String, length: int) -> String:
	var result = text
	while len(result) < length:
		result += " "
	return result

# Update the LCD display
func update_display() -> void:
	if is_loading:
		return
	
	# Line 1: Scrolling song title
	var song_display = current_song_name
	var line1 = ""
	
	if song_display != "" and not song_display.begins_with("Error:") and not song_display.begins_with("Skipping:"):
		var extended_name = song_display + "   " + song_display + "   " + song_display
		var start_pos = scroll_offset % len(song_display)
		line1 = extended_name.substr(start_pos, display_chars)
	elif song_display.begins_with("Error:") or song_display.begins_with("Skipping:"):
		line1 = pad_string(song_display.substr(0, display_chars), display_chars)
	else:
		line1 = pad_string("No songs found", display_chars)
	
	# Line 2: Time, track info, or volume
	var time_display = "%s/%s" % [format_time(playback_timer), format_time(song_duration)]
	var track_display = "%d/%d" % [current_song_index + 1, valid_playlist.size()]
	
	var info_line = ""
	
	if show_volume:
		info_line = "VOL:%3d%%" % current_volume
	elif valid_playlist.size() > 0 and audio_player.stream:
		info_line = "%s %s" % [time_display, track_display]
	elif valid_playlist.size() == 0:
		info_line = "No music found"
	else:
		info_line = "Loading..."
	
	# Pad to exact width
	if len(info_line) > display_chars:
		info_line = info_line.substr(0, display_chars)
	else:
		info_line = pad_string(info_line, display_chars)
	
	ui.text = line1 + "\n" + info_line
	
#                  rrrj       rrrr                 
#               rrrrrrr1     :rrrrrrr              
#               rrrrrrrrrrrrrrrrrrrrr              
#               rrrrrrrrrrrrrrrrrrrrr              
#       r     rrrrrrrrrrrrrrrrrrrrrrrrx     r      
#     rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr    
#    rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr   
#    rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr   
#     rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr    
#      rrrrrrrrrCrrrrrrrrrrrrrrrrrrrCrrrrrrrrr     
#      rrrrrr$$$_a$$rrrrrrrrrrrrr$$*_$$$rrrrrr     
#      rrrrr$$_____$@rrrr$$$rrrr@$_____$$rrrrr     
#      rrrrr$$_____$Crrrr$$$rrrrC$_____$$rrrrr     
#      rrrrrr$$a__$hrrrrr$$$rrrrrb$__k$$rrrrrr     
#      rrrrrrrrrrrrrrrrrrr#rrrrrrrrrrrrrrrrrrr     
#      rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr     
#      $$$$$$$$rrrrrrrrrrrrrrrrrrrrrrr$$$$$$$$     
#      rrrrrrr$rrrrrrr$rrrrrrr$rrrrrrr$rrrrrrr     
#      rrrrrrr$$$$$$W0$rrrrrrr$Z#$$$$$$rrrrrrr     
#       rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr      
#        rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr       
#           rrrrrrrrrrrrrrrrrrrrrrrrrrrrr          
#                rrrrrrrrrrrrrrrrrrr
