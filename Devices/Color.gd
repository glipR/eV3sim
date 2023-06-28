extends Device
class_name ColorSensor

# TODO: Other modes
const MODE_RGB = "RGB-RAW";

# Tracked variables
var mode = MODE_RGB;
@onready
var sensor_source = $SensorSource;

func device_class():
	return "lego-sensor"

func device_name():
	return "sensor-" + port;

func defaults():
	return {
		"address": port,
		"driver_name": "lego-ev3-color",
		"mode": MODE_RGB,
		"value0": "0",
		"value1": "0",
		"value2": "0",
	};

func handle_updates(delta):
	mode = read_attribute("mode");
	
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
	
	if mode == MODE_RGB:
		write_attribute("value0", str(int(color[0]*255)));
		write_attribute("value1", str(int(color[1]*255)));
		write_attribute("value2", str(int(color[2]*255)));
	# TODO: Support more modes.
