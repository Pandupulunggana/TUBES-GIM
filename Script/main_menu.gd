extends Control


@onready var start_button: Button = $VBoxContainer/start
@onready var save_button: Button = $VBoxContainer/save
@onready var load_button: Button = $VBoxContainer/load
@onready var exit_button: Button =$VBoxContainer/exit 

# false = game belum pernah dimulai (menu awal), true = menu sebagai pause menu
var game_started: bool = false


func _ready() -> void:
	# Menu tetap jalan walaupun tree di-pause
	process_mode = Node.PROCESS_MODE_ALWAYS

	start_button.pressed.connect(_on_start_pressed)
	save_button.pressed.connect(_on_save_pressed)
	load_button.pressed.connect(_on_load_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

	# Deferred supaya jalan setelah _ready Player (yang meng-capture mouse)
	open_menu.call_deferred()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if visible:
			# Di menu awal, ESC tidak menutup menu karena game belum mulai
			if game_started:
				close_menu()
		else:
			open_menu()
		get_viewport().set_input_as_handled()


func open_menu() -> void:
	show()
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	start_button.text = "Resume" if game_started else "Start"
	_refresh_load_button()
	start_button.grab_focus()


func close_menu() -> void:
	hide()
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _refresh_load_button() -> void:
	# Tombol Load mati kalau belum ada file save
	load_button.disabled = not FileAccess.file_exists(SaveManager.SAVE_PATH)


# ===== Tombol =====

func _on_start_pressed() -> void:
	game_started = true
	close_menu()


func _on_save_pressed() -> void:
	SaveManager.save_game()
	_refresh_load_button()

	# Feedback singkat. Argumen kedua true = timer tetap jalan saat pause
	save_button.text = "Saving"
	await get_tree().create_timer(1.0, true).timeout
	save_button.text = "Save"


func _on_load_pressed() -> void:
	SaveManager.load_game()
	game_started = true
	close_menu()


func _on_exit_pressed() -> void:
	get_tree().quit()
