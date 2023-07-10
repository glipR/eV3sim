extends Device
class_name ColorSensor

# TODO: Other modes
const MODE_COL_REFLECT = "COL-REFLECT";
const MODE_COL_AMBIENT = "COL-AMBIENT";
const MODE_COL_COLOR = "COL-COLOR";
const MODE_REF_RAW = "REF-RAW";
const MODE_RGB_RAW = "RGB-RAW";

const PREDICTION_VECTORS = [
	Vector3(0, 0, 0),       # Black
	Vector3(0, 0, 255),     # Blue
	Vector3(30, 140, 40),   # Green
	Vector3(255, 255, 0),   # Yellow
	Vector3(255, 40, 40),   # Red
	Vector3(255, 255, 255), # White
	Vector3(165, 42, 42),   # Brown
]
const PREDICTION_INCREASE_REQUIREMENT = 60
const PREDICTION_LARGEST_DIFFERENCE = 110

# Tracked variables
var mode = MODE_RGB_RAW;
@onready
var sensor_source = $SensorSource;

var debug_path = preload("res://Devices/Color/ColorDebug.tscn");
var cur_color;

func device_class():
	return "lego-sensor"

func device_name():
	return "sensor-" + port;

func defaults():
	return {
		"address": port,
		"driver_name": "lego-ev3-color",
		"mode": MODE_RGB_RAW,
		"value0": "0",
		"value1": "0",
		"value2": "0",
	};

func handle_updates(delta):
	mode = read_attribute("mode");
	
	# TODO: Do multiple raycasts to interpolate
	var space_state = get_world_3d().direct_space_state
	var search_vector = 0.1*Vector3.DOWN\
		.rotated(Vector3.RIGHT, global_rotation.x)\
		.rotated(Vector3.UP, global_rotation.y)\
		.rotated(Vector3.BACK, global_rotation.z);
	var query = PhysicsRayQueryParameters3D.create(sensor_source.global_position, sensor_source.global_position+search_vector, 1<<8);
	var result = space_state.intersect_ray(query);
	
	var color = [1, 1, 1];
	if result:
		# Logic for single color material
		if result["collider"].has_node("Mesh"):
			var collider_mesh = result["collider"].get_node("Mesh");
			if collider_mesh.mesh and collider_mesh.mesh.material:
				color = collider_mesh.mesh.material.albedo_color;
		# TODO: Logic for sprite
	
	cur_color = color;
	
	if mode == MODE_RGB_RAW or mode == MODE_REF_RAW:
		write_attribute("value0", str(int(color[0]*255)));
		write_attribute("value1", str(int(color[1]*255)));
		write_attribute("value2", str(int(color[2]*255)));
	elif mode == MODE_COL_REFLECT:
		# TODO: See what this should actually be.
		var reflected = (color[0] + color[1] + color[2]) * 100/3;
		write_attribute("value0", str(int(reflected)));
	elif mode == MODE_COL_AMBIENT:
		# TODO: See what this should actually be.
		var ambient = (color[0] + color[1] + color[2]) * 100/3;
		write_attribute("value0", str(int(ambient)));
	elif mode == MODE_COL_COLOR:
		var diffs = [];
		var i=0;
		for prediction in PREDICTION_VECTORS:
			diffs.push_back([
				abs(color[0]*255 - prediction[0]) + 
				abs(color[1]*255 - prediction[1]) + 
				abs(color[2]*255 - prediction[2]),
				i
			]);
			i += 1;
		diffs.sort();
		if diffs[0][0] > PREDICTION_LARGEST_DIFFERENCE:
			write_attribute("value0", "0");
		elif diffs[1][0] - diffs[0][0] < PREDICTION_INCREASE_REQUIREMENT:
			write_attribute("value0", "0");
		else:
			write_attribute("value0", str(diffs[0][1]+1));
		

func get_debugger_representation():
	var repr = debug_path.instantiate();
	repr.on_init(self);
	return repr;
