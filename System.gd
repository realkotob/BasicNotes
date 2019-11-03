extends Node

const CONFIG_FILE = "user://config.cfg"
const DATA_FILE = "user://data.dat"

const MENU_OPTIONS = ["Save", "", "Options", "About", "", "Exit"]
const FILE_TYPES = PoolStringArray(["*.bnote ; Basic Note File"])

var app_name = "bNotes"
var app_version = "v0.1"
var app_color = Color(255,242,171)
var default_app_color = Color( 1, 0.94902, 0.670588, 1 )

var default_size = Vector2(400, 600)
var app_size = Vector2()

var screen_size = OS.get_screen_size(0)
var window_size = OS.get_window_size()

var data = {
	"Settings": {
		"App_Name": "bNotes",
		"App_Version": "0.1",
		"App_Color": Color(),
		"App_Size": Vector2(),
		"App_Position": Vector2(),
		"Always_on_Top": false
		}
	}

var default_data = {
	"Settings": {
		"App_Name": app_name,
		"App_Version": app_version,
		"App_Color": default_app_color,
		"App_Size": default_size,
		"App_Position": screen_size*0.5 - window_size*0.5,
		"Always_on_Top": false
		}
	}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var file2Check = File.new()
	if not file2Check.file_exists(CONFIG_FILE):
		save_config_data(default_data)
	if not file2Check.file_exists(DATA_FILE):
		save_data("")
	
	load_config_data()
	update_window_title()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func update_window_title() -> void:
	OS.set_window_title(app_name)

func delete_data() -> void:
	var dir = Directory.new()
	dir.remove(CONFIG_FILE)
	dir.remove(DATA_FILE)
	
	data.clear()
	data = default_data
	
	save_config_data(default_data)
	save_data("")

func save_config_data(what_to_save) -> void:
	var config_file = ConfigFile.new()
	for section in data.keys():
		for key in data[section].keys():
			config_file.set_value(section, key, data[section][key])
	
	config_file.save(CONFIG_FILE)

func save_data(content) -> void:
	var file = File.new()
	file.open(DATA_FILE, File.WRITE)
	file.store_string(content)
	file.close()

func load_data() -> String:
	var file = File.new()
	file.open(DATA_FILE, File.READ)
	
	var content = file.get_as_text()
	file.close()
	return content

func load_config_data():
	var config_file = ConfigFile.new()
	var error = config_file.load(CONFIG_FILE)
	if error != OK:
		print("Error loading the Config File...")
		save_config_data(default_data)
		print("Created new Config file.")
	
	for section in data.keys():
		for key in data[section].keys():
			data[section][key] = config_file.get_value(section, key)
	
	app_name = data["Settings"]["App_Name"]
	app_version = data["Settings"]["App_Version"]
	app_color = data["Settings"]["App_Color"]
	
	OS.set_window_position(data["Settings"]["App_Position"])
	OS.set_window_always_on_top(data["Settings"]["Always_on_Top"])
