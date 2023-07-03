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
	};

func handle_updates(delta):
	mode = read_attribute("mode");

	var space_state = get_world_3d().direct_space_state;
	var query = PhysicsRayQueryParameters3D.create(sensor_source.global_position, ir_node.global_position, 1, [ir_node]);
	var result = space_state.intersect_ray(query);

	var diff = ir_node.global_position - sensor_source.global_position;
	var plane_normal = Vector3.UP\
		.rotated(Vector3.RIGHT, global_rotation.x)\
		.rotated(Vector3.UP, global_rotation.y)\
		.rotated(Vector3.BACK, global_rotation.z);
	
	var front_device = Vector3.LEFT\
		.rotated(Vector3.RIGHT, global_rotation.x)\
		.rotated(Vector3.UP, global_rotation.y)\
		.rotated(Vector3.BACK, global_rotation.z);

	# Project onto vector on device plane
	var projection = diff - plane_normal.dot(diff) * plane_normal;
	# Project onto vector on vertical plane
	var vert_projection = diff - front_device.dot(diff) * front_device;
	
	# TODO: Signal strength should drop off as vert_projection length beats out projection.
	
	var angle = projection.signed_angle_to(front_device, plane_normal);
	# Degrees
	# print(angle * 180 / PI);


