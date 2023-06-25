extends Node3D
class_name Device

const POLLING_FREQUENCY = 0.02;

@export
var port: String;


var _curTime = 0;

# TODO for testing. Once everything is orchestrated not required.
func _ready():
	init(port);

func data_path():
	return "res://device-data/%s/%s/" % [device_class(), port];

# Abstract. The top-level folder name for this type of device.
func device_class():
	return ""

# Abstract. Defines all fields the device exposes/reads from.
func defaults():
	return {
		"address": port,
	}

# Abstract. Called every time the device should poll and update.
func handle_updates(delta):
	pass;

func init(portName):
	port = portName;
	_curTime = POLLING_FREQUENCY;
	if not DirAccess.dir_exists_absolute(data_path()):
		DirAccess.make_dir_recursive_absolute(data_path());
	var d = defaults();
	for k in d:
		write_attribute(k, d[k]);

func _physics_process(delta):
	_curTime -= delta;
	if _curTime < 0:
		_curTime += POLLING_FREQUENCY;
		handle_updates(delta);

# USE THESE METHODS TO CHANGE AND READ ATTRIBUTES
func read_attribute(attribute):
	var res = FileAccess.open(data_path() + attribute, FileAccess.READ);
	if res == null:
		print(FileAccess.get_open_error());
		return "";
	else:
		return res.get_as_text();

func write_attribute(attribute, value):
	var res = FileAccess.open(data_path() + attribute, FileAccess.WRITE);
	if res == null:
		print(FileAccess.get_open_error());
		print(data_path() + attribute);
	else:
		res.store_string(value);
