extends Control

onready var menu = $Control/MenuBar/MenuButton
onready var t_input = $Control/TextInput/TextEdit
onready var o_menu = $OptionsMenu

# Window Dragging and Resize Variables
var dragging = false
var drag_start_position = Vector2()

var resizing = false
var old_mouse_position = Vector2()

var m_popup = null
var o_popup = null

var note = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	m_popup = menu.get_popup()
	m_popup.connect("id_pressed", self, "_on_menu_pressed")
	populate_menu()
	
	note = Sys.load_data()
	t_input.text = note
	
	$OptionsMenu/AlwaysOnTopButton.pressed = Sys.data["Settings"]["Always_on_Top"]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if dragging:
		OS.set_window_position(OS.window_position + get_global_mouse_position() - drag_start_position)
	
	if resizing:
		pass

func populate_menu():
	for i in Sys.MENU_OPTIONS:
		m_popup.add_item(i)
	
	for j in Sys.MENU_OPTIONS.size():
		if m_popup.get_item_text(j) == "":
			m_popup.set_item_as_separator(j, true)
	
	m_popup.rect_min_size = Vector2(150, 30)

func _on_TopContainer_gui_input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == 1:
			dragging = !dragging
			drag_start_position = get_local_mouse_position()
		else:
			dragging = !dragging
			Sys.data["Settings"]["Position"] = OS.window_position
			Sys.save_config_data()

func _on_menu_pressed(id):
	match id:
		0:
			Sys.save_data(note)
		2:
			o_menu.popup()
		3:
			print("About")
		5:
			get_tree().quit()

func _on_CloseButton_pressed():
	get_tree().quit()

func _on_MinimizeButton_pressed():
	OS.window_minimized = true

func _on_TextEdit_text_changed():
	note = t_input.text

func _on_AlwaysOnTopButton_toggled(button_pressed):
	Sys.data["Settings"]["Always_on_Top"] = button_pressed
	Sys.save_config_data()
	Sys.load_config_data()

func _on_ColorPickerButton_color_changed(color):
	var new_flat = StyleBoxFlat.new()
	new_flat.bg_color = color
	t_input.set('custom_styles/normal', new_flat)

func _on_DeleteDataButton_pressed():
	Sys.delete_data()

func _on_ResizeButton_button_down():
	resizing = true
	old_mouse_position = get_global_mouse_position()

func _on_ResizeButton_button_up():
	resizing = false
	OS.set_window_size(OS.window_size + get_global_mouse_position() - old_mouse_position)
