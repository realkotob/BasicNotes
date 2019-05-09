extends Node

const CONFIG_FILE = "user://config.cfg"
const DATA_FILE = "user://data.dat"

const MENU_OPTIONS = ["Save", "", "Options", "About", "", "Exit"]
const FILE_TYPES = PoolStringArray(["*.bnote ; Basic Note File"])

var app_name = "bNotes"
var app_version = "v0.1"

var data = {
	"Settings": {
		"App_Name": "bNotes",
		"App_Version": "0.1",
		"Always_on_Top": false,
		"Position": 0
		}
	}

var default_data = {
	"Settings": {
		"App_Name": "bNotes",
		"App_Version": "0.1",
		"Always_on_Top": false,
		"Position": 0
		}
	}

# Called when the node enters the scene tree for the first time.
func _ready():
	var file2Check = File.new()
	if not file2Check.file_exists(CONFIG_FILE):
		save_config_data()
	if not file2Check.file_exists(DATA_FILE):
		save_data("")
	
	load_config_data()
	update_window_title()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func merge_dict(dict_1, dict_2):
	for key in dict_2:
		dict_1[key] = dict_2[key]
	
	return dict_1

func update_window_title():
	OS.set_window_title(app_name + " | " + app_version)

func delete_data():
	var dir = Directory.new()
	dir.remove(CONFIG_FILE)
	dir.remove(DATA_FILE)
	
	data.clear()
	data = default_data
	
	save_config_data()
	save_data("")

func save_config_data():
	var config_file = ConfigFile.new()
	for section in data.keys():
		for key in data[section].keys():
			config_file.set_value(section, key, data[section][key])
	
	config_file.save(CONFIG_FILE)

func save_data(content):
	var file = File.new()
	file.open(DATA_FILE, File.WRITE)
	file.store_string(content)
	file.close()

func load_data():
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
		save_config_data()
		print("Created new Config file.")
	
	for section in data.keys():
		for key in data[section].keys():
			data[section][key] = config_file.get_value(section, key)
	
	app_name = data["Settings"]["App_Name"]
	app_version = data["Settings"]["App_Version"]
	
	OS.window_position = data["Settings"]["Position"]
	OS.set_window_always_on_top(data["Settings"]["Always_on_Top"])
