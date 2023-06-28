extends Device
class_name UltrasonicSensor

# TODO: Other modes
const MODE_CM = "US-DIST-CM";

# Tracked variables
var mode = MODE_CM;
@onready
var sensor_source = $SensorSource;

func device_class():
	return "lego-sensor"

func device_name():
	return "sensor-" + port;

func defaults():
	return {
		"address": port,
		"driver_name": "lego-ev3-us",
		"mode": "US-DIST-CM",
		"value0": "0",
		"decimals": "0",
	};

func handle_updates(delta):
	mode = read_attribute("mode");
	
	var space_state = get_world_3d().direct_space_state
	var search_vector = 5*Vector3.RIGHT\
		.rotated(Vector3.RIGHT, global_rotation.x)\
		.rotated(Vector3.UP, global_rotation.y)\
		.rotated(Vector3.BACK, global_rotation.z);
	# TODO: Ignore own vehicle so we can move this back a bit.
	var query = PhysicsRayQueryParameters3D.create(sensor_source.global_position, sensor_source.global_position+ search_vector, 1);
	var result = space_state.intersect_ray(query);
	
	if result:
		var dist_cm = int(global_position.distance_to(result["position"]) * 100); # cm
		write_attribute("value0", str(dist_cm));
	else:
		write_attribute("value0", str(300));
