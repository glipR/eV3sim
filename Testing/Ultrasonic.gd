extends Node3D

const POLLING_FREQUENCY = 0.02;

@export
var deviceName: String;
@export
var port: String;

var curTime = 0;

# Device attributes
var mode = "US-DIST-CM";

func data_path():
	return "res://device-data/lego-sensor/" + deviceName + "/";

func defaults():
	return {
		"address": port,
		"driver_name": "lego-ev3-us",
		"mode": "US-DIST-CM",
		"value0": "0",
		"decimals": "0",
	};

func _ready():
	curTime = POLLING_FREQUENCY;
	if not DirAccess.dir_exists_absolute(data_path()):
		# Create the file.
		DirAccess.make_dir_absolute(data_path());
	var d = defaults();
	for k in d:
		write_attribute(k, d[k]);

func _physics_process(delta):
	curTime -= delta;
	if curTime < 0:
		curTime += POLLING_FREQUENCY;
		handle_updates();

func read_attribute(attribute):
	var res = FileAccess.open(data_path() + attribute, FileAccess.READ);
	if res == null:
		print(FileAccess.get_open_error());
		return "";
	else:
		return res.get_as_text();

func write_attribute(attribute, value):
	var res = FileAccess.open(data_path() + attribute, FileAccess.WRITE);
	res.store_string(value);

func handle_updates():
	mode = read_attribute("mode");
	
	var space_state = get_world_3d().direct_space_state
	# 0.01 is used to avoid the bounding box of the vehicle.
	var query = PhysicsRayQueryParameters3D.create(global_position + Vector3(0.01, 0, 0), global_position+Vector3(5, 0, 0));
	var result = space_state.intersect_ray(query);
	
	if result:
		var dist_cm = int(global_position.distance_to(result["position"]) * 100); # cm
		# print(dist_cm);
		write_attribute("value0", str(dist_cm));
