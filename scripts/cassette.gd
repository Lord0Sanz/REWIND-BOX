extends Node2D

@onready var ui: Label = $UI/BackPanel/MarginContainer/ui
@onready var audio_player: AudioStreamPlayer = $AUDIO_PLAYER
@onready var click: AudioStreamPlayer = $click
@onready var cassette_ring_a: Sprite2D = $CassetteRingA
@onready var cassette_ring_b: Sprite2D = $CassetteRingB

var vol_up_original_pos: Vector2
var vol_down_original_pos: Vector2
var bttn_a_original_pos: Vector2
var bttn_b_original_pos: Vector2
var bttn_c_original_pos: Vector2
var bttn_d_original_pos: Vector2

var current_volume: float = 70
var is_playing: bool = false
var is_looping: bool = false
var current_song_name: String = ""
var song_duration: float = 0.0
var playback_timer: float = 0.0

var playlist: Array = []
var current_song_index: int = 0
var valid_playlist: Array = []

var scroll_offset: int = 0
var scroll_timer: float = 0.0
var scroll_delay: float = 0.3
var displayed_song_name: String = ""

var display_chars: int = 20

var volume_display_timer: float = 0.0
var show_volume: bool = false
var volume_display_duration: float = 2.0

var dragging: bool = false
var drag_start_pos: Vector2 = Vector2.ZERO

var target_size: int = 512
var current_size: int = 512
var min_size: int = 128
var max_size: int = 512
var original_design_size: int = 512

var ring_rotation_speed: float = 15.0
var ring_a_rotation: float = 0.0
var ring_b_rotation: float = 0.0

var is_loading: bool = true

func _ready() -> void:
	var window = get_window()
	window.always_on_top = true
	window.borderless = true
	window.transparent = true
	
	window.size = Vector2i(current_size, current_size)
	Engine.max_fps = 60
	
	show_loading_screen()
	setup_input_actions()
	
	vol_up_original_pos = $CassetteVolUp/CassetteVolUp.position
	vol_down_original_pos = $CassetteVolDown/CassetteVolDown.position
	bttn_a_original_pos = $CassetteBttnA/CassetteBttnA.position
	bttn_b_original_pos = $CassetteBttnB/CassetteBttnB.position
	bttn_c_original_pos = $CassetteBttnC/CassetteBttnC.position
	bttn_d_original_pos = $CassetteBttnD/CassetteBttnD.position
	
	await load_playlist()
	
	if valid_playlist.size() > 0:
		load_song(current_song_index)
		set_volume(current_volume)
		update_button_states()
		update_viewport_scale()
		show_music_display()
	else:
		show_no_music_error()

func show_loading_screen() -> void:
	is_loading = true
	var loading_text = "REWINDBOX\nLOADING..."
	ui.text = loading_text

func show_music_display() -> void:
	is_loading = false
	update_display()

func show_no_music_error() -> void:
	is_loading = true
	var error_text = "REWINDBOX\nNO MUSIC FOUND"
	ui.text = error_text

func setup_input_actions() -> void:
	if not InputMap.has_action("play_pause"):
		InputMap.add_action("play_pause")
		var space_event = InputEventKey.new()
		space_event.keycode = KEY_SPACE
		InputMap.action_add_event("play_pause", space_event)
	
	if not InputMap.has_action("loop"):
		InputMap.add_action("loop")
		var enter_event = InputEventKey.new()
		enter_event.keycode = KEY_ENTER
		InputMap.action_add_event("loop", enter_event)
	
	if not InputMap.has_action("next"):
		InputMap.add_action("next")
		var right_event = InputEventKey.new()
		right_event.keycode = KEY_RIGHT
		InputMap.action_add_event("next", right_event)
	
	if not InputMap.has_action("prev"):
		InputMap.add_action("prev")
		var left_event = InputEventKey.new()
		left_event.keycode = KEY_LEFT
		InputMap.action_add_event("prev", left_event)
	
	if not InputMap.has_action("vol_up"):
		InputMap.add_action("vol_up")
		var up_event = InputEventKey.new()
		up_event.keycode = KEY_UP
		InputMap.action_add_event("vol_up", up_event)
	
	if not InputMap.has_action("vol_down"):
		InputMap.add_action("vol_down")
		var down_event = InputEventKey.new()
		down_event.keycode = KEY_DOWN
		InputMap.action_add_event("vol_down", down_event)

func update_viewport_scale() -> void:
	var window = get_window()
	var current_width = window.size.x
	var scale_factor = float(current_width) / float(original_design_size)
	scale = Vector2(scale_factor, scale_factor)

func _input(event: InputEvent) -> void:
	if is_loading and not (event is InputEventKey and event.keycode == KEY_ESCAPE):
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			dragging = true
			drag_start_pos = get_global_mouse_position()
			get_viewport().set_input_as_handled()
		else:
			dragging = false
			get_viewport().set_input_as_handled()
	
	if event is InputEventMouseMotion and dragging:
		var delta_pos = get_global_mouse_position() - drag_start_pos
		var new_pos = get_window().position + Vector2i(delta_pos)
		get_window().position = new_pos
		drag_start_pos = get_global_mouse_position()
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("play_pause"):
		toggle_play_pause()
	
	if event.is_action_pressed("loop"):
		toggle_loop()
	
	if event.is_action_pressed("next"):
		play_next_song()
	
	if event.is_action_pressed("prev"):
		play_previous_song()
	
	if event.is_action_pressed("vol_up"):
		increase_volume()
	
	if event.is_action_pressed("vol_down"):
		decrease_volume()
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().quit()
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_EQUAL and event.ctrl_pressed:
		zoom_in()
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_MINUS and event.ctrl_pressed:
		zoom_out()

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
		else:
			if valid_playlist.size() > 0 and audio_player.stream:
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
	press_button($CassetteVolUp/CassetteVolUp, Vector2(30, 0), vol_up_original_pos)
	current_volume = min(current_volume + 2, 100)
	set_volume(current_volume)
	show_volume = true
	volume_display_timer = 0.0
	update_display()

func decrease_volume() -> void:
	if is_loading:
		return
	click.play()
	press_button($CassetteVolDown/CassetteVolDown, Vector2(30, 0), vol_down_original_pos)
	current_volume = max(current_volume - 2, 0)
	set_volume(current_volume)
	show_volume = true
	volume_display_timer = 0.0
	update_display()

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
	var window = get_window()
	var size_int = int(new_size)
	window.size = Vector2i(size_int, size_int)
	update_viewport_scale()

func get_music_folder_path() -> String:
	var os_name = OS.get_name()
	
	if os_name == "Windows":
		var home_dir = OS.get_environment("USERPROFILE")
		return home_dir + "\\Music"
	elif os_name == "macOS":
		var home_dir = OS.get_environment("HOME")
		return home_dir + "/Music"
	elif os_name == "Linux":
		var home_dir = OS.get_environment("HOME")
		return home_dir + "/Music"
	else:
		return "res://playlist"

func scan_directory_for_audio(dir_path: String) -> void:
	var dir = DirAccess.open(dir_path)
	if dir:
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

func is_valid_mp3(file_path: String) -> bool:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return false
	
	var data = file.get_buffer(1024)
	file.close()
	
	if data.size() < 4:
		return false
	
	for i in range(data.size() - 4):
		if data[i] == 0xFF:
			var second_byte = data[i + 1]
			if (second_byte & 0xE0) == 0xE0:
				return true
	
	return false

func load_playlist() -> void:
	playlist.clear()
	valid_playlist.clear()
	var music_folder = get_music_folder_path()
	
	await get_tree().create_timer(0.5).timeout
	
	var dir_check = DirAccess.open(music_folder)
	if dir_check:
		scan_directory_for_audio(music_folder)
		
		if playlist.size() > 0:
			for song_path in playlist:
				var extension = song_path.get_extension().to_lower()
				if extension == "mp3":
					if is_valid_mp3(song_path):
						valid_playlist.append(song_path)
				else:
					valid_playlist.append(song_path)
			
			valid_playlist.sort()
	else:
		var fallback_dir = DirAccess.open("res://playlist")
		if fallback_dir:
			scan_directory_for_audio("res://playlist")
			if playlist.size() > 0:
				for song_path in playlist:
					var extension = song_path.get_extension().to_lower()
					if extension == "mp3":
						if is_valid_mp3(song_path):
							valid_playlist.append(song_path)
					else:
						valid_playlist.append(song_path)
				valid_playlist.sort()

func load_mp3_file(file_path: String) -> AudioStreamMP3:
	var mp3_stream = AudioStreamMP3.new()
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var data = file.get_buffer(file.get_length())
		if data.size() > 0:
			mp3_stream.data = data
			if mp3_stream.data.size() > 0:
				return mp3_stream
	return null

func load_song(index: int) -> void:
	if index >= 0 and index < valid_playlist.size():
		var song_path = valid_playlist[index]
		var extension = song_path.get_extension().to_lower()
		var song_stream: AudioStream = null
		
		match extension:
			"mp3":
				song_stream = load_mp3_file(song_path)
			"ogg":
				song_stream = load(song_path)
			"wav":
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

func skip_corrupted_song() -> void:
	current_song_index += 1
	if current_song_index >= valid_playlist.size():
		current_song_index = 0
	
	if valid_playlist.size() > 0:
		load_song(current_song_index)

func _process(delta: float) -> void:
	if is_loading:
		return
	
	if is_playing and audio_player.playing:
		playback_timer = audio_player.get_playback_position()
		update_display()
		spin_cassette_rings(delta)
	
	if show_volume:
		volume_display_timer += delta
		if volume_display_timer >= volume_display_duration:
			show_volume = false
			update_display()
	
	if is_playing and not audio_player.playing and playback_timer > 0:
		if is_looping:
			audio_player.play()
			playback_timer = 0.0
		else:
			play_next_song()
	
	if current_song_name != "" and not current_song_name.begins_with("Error:") and not current_song_name.begins_with("Skipping:"):
		scroll_timer += delta
		if scroll_timer >= scroll_delay:
			scroll_timer = 0.0
			scroll_offset += 1
			if scroll_offset > len(current_song_name):
				scroll_offset = 0
			update_display()

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
		press_button($CassetteBttnB/CassetteBttnB, Vector2(0, 40), bttn_b_original_pos)
		play_previous_song()

func _on_cassette_bttn_c_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		click.play()
		press_button($CassetteBttnC/CassetteBttnC, Vector2(0, 40), bttn_c_original_pos)
		play_next_song()

func _on_cassette_bttn_d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		toggle_loop()

func update_button_states() -> void:
	if is_playing:
		$CassetteBttnA/CassetteBttnA.position = bttn_a_original_pos + Vector2(0, 40)
	else:
		$CassetteBttnA/CassetteBttnA.position = bttn_a_original_pos
		reset_cassette_rings()
	
	if is_looping:
		$CassetteBttnD/CassetteBttnD.position = bttn_d_original_pos + Vector2(0, 40)
	else:
		$CassetteBttnD/CassetteBttnD.position = bttn_d_original_pos

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

func format_time(seconds: float) -> String:
	var total_seconds = int(seconds)
	@warning_ignore("integer_division")
	var hours = total_seconds / 3600
	@warning_ignore("integer_division")
	var minutes = (total_seconds % 3600) / 60
	var secs = total_seconds % 60
	
	if hours > 0:
		return "%02d:%02d:%02d" % [hours, minutes, secs]
	else:
		return "%02d:%02d" % [minutes, secs]

func pad_string(text: String, length: int) -> String:
	var result = text
	while len(result) < length:
		result += " "
	return result

func update_display() -> void:
	if is_loading:
		return
	
	var song_display = current_song_name
	var line1 = ""
	
	if song_display != "" and not song_display.begins_with("Error:") and not song_display.begins_with("Skipping:"):
		var extended_name = song_display + "   " + song_display + "   " + song_display
		var start_pos = scroll_offset % len(song_display)
		var display_text = extended_name.substr(start_pos, display_chars)
		line1 = display_text
	elif song_display.begins_with("Error:") or song_display.begins_with("Skipping:"):
		line1 = pad_string(song_display.substr(0, display_chars), display_chars)
	else:
		line1 = pad_string("No songs found", display_chars)
	
	var time_display = "%s/%s" % [format_time(playback_timer), format_time(song_duration)]
	var track_display = "%d/%d" % [current_song_index + 1, valid_playlist.size()]
	
	var info_line = ""
	
	if show_volume:
		var volume_display = "VOL:%3d%%" % current_volume
		info_line = volume_display
	else:
		if valid_playlist.size() > 0 and audio_player.stream:
			info_line = "%s %s" % [time_display, track_display]
		elif valid_playlist.size() == 0:
			info_line = "No music found"
		else:
			info_line = "Loading..."
	
	if len(info_line) > display_chars:
		info_line = info_line.substr(0, display_chars)
	else:
		info_line = pad_string(info_line, display_chars)
	
	ui.text = line1 + "\n" + info_line

func press_button(button: Node2D, press_offset: Vector2, original_pos: Vector2) -> void:
	var new_tween = create_tween()
	new_tween.tween_property(button, "position", original_pos + press_offset, 0.05)
	new_tween.tween_property(button, "position", original_pos, 0.1).set_delay(0.05)
