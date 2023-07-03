extends Device
class_name InfraredSensor

const MODE_AC_ALL = "AC-ALL"
const MODE_DC_ALL = "DC-ALL"
const MODE_AC = "AC"
const MODE_DC = "DC"

# Tracked variables
var mode = MODE_AC_ALL;
@onready
var sensor_source = $SensorSource;
# TODO: Identify all children of some set parent
@onready
var ir_node = $/root/Node3D/IRBall1;

const SENSOR_BEARING_DROPOFF_MAX = PI / 4.0;
const MAX_SENSOR_RANGE = 3;
const MAX_STRENGTH = 9.0;

const SENSOR_ANGLES_DEGREES = [
	-60,
	-30,
	0,
	30,
	60 
]

func device_class():
	return "lego-sensor"

func device_name():
	return "sensor-" + port;

func defaults():
	return {
		"address": port,
		"driver_name": "ht-nxt-ir-seek-v2",
		"mode": mode,
		"value0": "0",
		"value1": "0",
		"value2": "0",
		"value3": "0",
		"value4": "0",
		"value5": "0",
		"value6": "0",
	};

func get_sensor_strength(angle, distance):
	if abs(angle) > SENSOR_BEARING_DROPOFF_MAX:
		return 0;
	var sq_dist = pow(distance / MAX_SENSOR_RANGE, 2);
	var exclude_bearing = (1 - sq_dist) * MAX_STRENGTH;
	var bearing_mult = 1 - abs(angle) / SENSOR_BEARING_DROPOFF_MAX
	return floor(exclude_bearing * bearing_mult + 0.5)

func handle_updates(delta):
	mode = read_attribute("mode");

	var space_state = get_world_3d().direct_space_state;
	var query = PhysicsRayQueryParameters3D.create(sensor_source.global_position, ir_node.global_position, 1, [ir_node]);
	var result = space_state.intersect_ray(query);

	if result:
		write_attribute("value0", "0");
		write_attribute("value1", "0");
		write_attribute("value2", "0");
		write_attribute("value3", "0");
		write_attribute("value4", "0");
		write_attribute("value5", "0");
		write_attribute("value6", "0");
		return;

	var diff = ir_node.global_position - sensor_source.global_position;
	var plane_normal = Vector3.UP\
		.rotated(Vector3.RIGHT, global_rotation.x)\
		.rotated(Vector3.UP, global_rotation.y)\
		.rotated(Vector3.BACK, global_rotation.z);
	
	var front_device = Vector3.LEFT\
		.rotated(Vector3.RIGHT, global_rotation.x)\
		.rotated(Vector3.UP, global_rotation.y)\
		.rotated(Vector3.BACK, global_rotation.z);

	var idx = 0;
	var distance = diff.length();
	var total_strength = 0;
	var weight_strength = 0;
	for angle in SENSOR_ANGLES_DEGREES:
		var vector = Vector3.LEFT\
			.rotated(Vector3.UP, angle / 180.0 * PI)\
			.rotated(Vector3.RIGHT, global_rotation.x)\
			.rotated(Vector3.UP, global_rotation.y)\
			.rotated(Vector3.BACK, global_rotation.z);
		var result_angle = diff.normalized().signed_angle_to(vector, plane_normal);
		var strength = get_sensor_strength(result_angle, distance);
		total_strength += strength;
		weight_strength += idx * strength;
		write_attribute("value" + str(idx+1), str(int(strength)));
		idx += 1;

	# Predict direction
	var direction;
	if total_strength <= 4:
		direction = 0;
	else:
		direction = max(min(
			1 + floor(weight_strength / total_strength / (5.0 - 1.0) * 9)
		, 9), 1);
	write_attribute("value0", str(int(direction)));
	
	# Strength
	write_attribute("value6", str(int(total_strength / 5.0)));
