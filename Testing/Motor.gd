extends VehicleWheel3D

# Think work on this is blocked until https://github.com/godotengine/godot/issues/68193 gets fixed.

const POLLING_FREQUENCY = 0.1;
const FORCE_MULTIPLIER = 0.03;
const MAX_RPM = 0.01;
const LIMIT = MAX_RPM;

@export
var motorName: String;
@export
var port: String;

var curTime = 0;

# Motor attributes
var time_sp = 0;
var speed_sp = 0;
var position_sp = 0;
var stop_action = "hold";
var wait_time = 0;

var target_rpm = 0;
var kp = 2;
var ki = 0;
var kd = 0;

var _proportional = 0;
var _integral = 0;
var _derivative = 0;

var _last_in = 0;
var _last_error = 0;

var _iter = 0;

func data_path():
	return "res://device-data/tacho-motor/" + motorName + "/";

func defaults():
	return {
		"address": port,
		"command": "",
		"count_per_rot": "3",
		"driver_name": "lego-ev3-l-motor",
		"max_speed": "100",
		"speed_sp": "0",
		"state": "holding",
		"stop_action": "hold",
		"time_sp": "0",
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
	set_engine(do_pid(delta));
	curTime -= delta;
	if curTime < 0:
		curTime += POLLING_FREQUENCY;
		handle_updates();
	if wait_time > 0:
		wait_time -= delta;
		if wait_time <= 0:
			stop();

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
	var com = read_attribute("command");
	if com:
		if com == "run-forever":
			on();
		elif com == "run-timed":
			on_for_seconds();
		elif com == "run-to-rel-pos":
			on_for_rotations();
		elif com == "stop":
			stop();
		elif com == "reset":
			reset();
		write_attribute("command", "");

func set_engine(speed):
	speed = clamp(speed, -100, 100);
	engine_force = speed * FORCE_MULTIPLIER;
	brake = 0;

func on():
	var speed = float(read_attribute("speed_sp"));
	target_rpm = clamp(speed / 100.0 * MAX_RPM, -MAX_RPM, MAX_RPM);
	write_attribute("state", "running");
	wait_time = -1;

func on_for_seconds():
	var speed = float(read_attribute("speed_sp"));
	target_rpm = clamp(speed / 100.0 * MAX_RPM, -MAX_RPM, MAX_RPM);
	wait_time = float(read_attribute("time_sp")) / 1000.0;
	write_attribute("state", "running");

func on_for_rotations():
	# ACTUALLY TEST ME
	var speed = float(read_attribute("speed_sp"));
	var position_sp = float(read_attribute("position_sp"));
	var per_rot = float(read_attribute("counts_per_rot"));

	var rotations = position_sp / per_rot;
	if rotations < 0:
		rotations *= -1;
		speed *= -1;

	target_rpm = clamp(speed / 100.0 * MAX_RPM, -MAX_RPM, MAX_RPM);
	wait_time = rotations / 10 * speed / 100;

	write_attribute("state", "running");

func stop():
	target_rpm = 0;
	# TODO: stop-action
	brake = 0.03;
	wait_time = -1;
	write_attribute("state", "holding");

func reset():
	stop();
	write_attribute("time_sp", "0");
	write_attribute("speed_sp", "0");
	write_attribute("position_sp", "0");

func do_pid(delta):
	return target_rpm * 100 / MAX_RPM;
	var error = target_rpm - get_rpm();
	_proportional = kp * error;
	_integral += ki * error * delta;
	_integral = clamp(_integral, -LIMIT, LIMIT);
	_derivative = kd * (error - _last_error) / delta;
	var output = _proportional + _integral + _derivative;
	output = clamp(output, -LIMIT, LIMIT);
	# Small clamp.
	if abs(output) < 0.001:
		output = 0;
	
	_last_error = error;
	
	_iter += 1;
	
	if motorName == "FrontRight":
		print(error, " ", get_rpm(), " ", get_skidinfo(), "", is_in_contact());
		# print("P: %.1f I: %.1f D: %.1f" % [_proportional * 100, _integral * 100, _derivative * 100]);
	
	return output / MAX_RPM * 100;
	
