extends Control

onready var menu = $VBoxContainer/MenuBar/MenuButton
onready var t_input = $VBoxContainer/TextInput/MarginContainer/TextEdit
onready var o_menu = $OptionsMenu
onready var a_menu = $AboutMenu

# Window Dragging and Resize Variables
var dragging := false
var drag_start_position := Vector2()
var resizing := false
var old_mouse_position := Vector2()

var m_popup = null
var o_popup = null
var a_popup = null

var note = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	m_popup = menu.get_popup()
	m_popup.connect("id_pressed", self, "_on_menu_pressed")
	populate_menu()
	
	note = Sys.load_data()
	t_input.text = note
	
	set_editor_color(Sys.data["Settings"]["App_Color"])
	$OptionsMenu/AlwaysOnTopButton.pressed = Sys.data["Settings"]["Always_on_Top"]
	
	$OptionsMenu/ColorPickerButton.get_picker().add_preset(Sys.default_app_color)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if dragging:
		OS.set_window_position(OS.get_window_position() + get_global_mouse_position() - drag_start_position)

func populate_menu():
	for i in Sys.MENU_OPTIONS:
		m_popup.add_item(i)
	
	for j in Sys.MENU_OPTIONS.size():
		if m_popup.get_item_text(j) == "":
			m_popup.set_item_as_separator(j, true)
		
		if m_popup.get_item_text(j) == "Line Numbers":
			m_popup.set_item_as_checkable(j, true)
			pass
	
	m_popup.rect_min_size = Vector2(150, 30)

func set_editor_color(color) -> void:
	var t_style = StyleBoxFlat.new()
	t_style.bg_color = color
	t_input.set('custom_styles/normal', t_style)
	
	var n_style = StyleBoxFlat.new()
	n_style.bg_color = color.lightened(0.5)
	$Panel.set("custom_styles/panel", n_style)
	$VBoxContainer/MenuBar/Background.set("custom_styles/panel", n_style)
	
	Sys.data["Settings"]["App_Color"] = color
	Sys.save_config_data(Sys.data)

func _on_TopContainer_gui_input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == 1:
			dragging = !dragging
			drag_start_position = get_local_mouse_position()
			Sys.data["Settings"]["App_Position"] = OS.get_window_position()
			Sys.save_config_data(Sys.data)

func _on_menu_pressed(id):
	match id:
		0:
			Sys.save_data(note)
		2:
			o_menu.popup()
		3:
			a_menu.popup()
		5:
			get_tree().quit()

func _on_CloseButton_pressed():
	get_tree().quit()

func _on_MinimizeButton_pressed():
	OS.window_minimized = true

func _on_TextEdit_text_changed():
	note = t_input.text
	Sys.save_data(note)

func _on_AlwaysOnTopButton_toggled(button_pressed):
	Sys.data["Settings"]["Always_on_Top"] = button_pressed
	Sys.save_config_data(Sys.data)
	Sys.load_config_data()

func _on_ColorPickerButton_color_changed(color):
	set_editor_color(color)

func _on_DeleteDataButton_pressed():
	Sys.delete_data()

func _on_ResizeButton_button_down():
	resizing = true
	old_mouse_position = get_global_mouse_position()

func _on_ResizeButton_button_up():
	resizing = false
	Sys.app_size = OS.get_window_size() + get_global_mouse_position() - old_mouse_position
	OS.set_window_size(Sys.app_size)
	
	if OS.get_window_size() < rect_min_size:
		OS.set_window_size(get_custom_minimum_size())
