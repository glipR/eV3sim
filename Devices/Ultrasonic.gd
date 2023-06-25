extends Device
class_name Ultrasonic

const MODE_CM = "US-DIST-CM";

# Tracked variables
var mode = MODE_CM;

func device_class():
	return "lego-sensor"

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
	# 0.01 is used to avoid the bounding box of the vehicle.
	var query = PhysicsRayQueryParameters3D.create(global_position + Vector3(0.01, 0, 0), global_position+Vector3(5, 0, 0));
	var result = space_state.intersect_ray(query);
	
	if result:
		var dist_cm = int(global_position.distance_to(result["position"]) * 100); # cm
		# print(dist_cm);
		write_attribute("value0", str(dist_cm));
	else:
		write_attribute("value0", str(300));
