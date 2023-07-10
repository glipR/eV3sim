extends Device
class_name Debugger

const MAX_TEXT_BUFFER = 4000;

@onready
var text_box = $Debugger/SharedPanel/Label;
@onready
var tracker_container = $Debugger/TrackerPanel/ItemContainer;
@onready
var static_container = $Debugger/TrackerPanel/ItemContainer/FixedVehicleIndicator;

@export
var message_prefix = "rob-1: ";
@export
var tracker_label = preload("res://Devices/Debugger/TrackerLabel.tscn");

var value_mapper = {};
var position_mapper = {};
var _cur_position = 1;

var _cur_file_position = 0;
var file_reader;

var known_carriage = null;
var device_debuggers = [];

func on_init():
	file_reader = FileAccess.open(data_path() + "free_text", FileAccess.READ);
	if file_reader == null:
		print(FileAccess.get_open_error());
		return "";

	var robot = self;
	while not robot.is_in_group("ROBOTS"):
		robot = robot.get_parent();

	# Required or robot.devices is empty.
	await robot.fully_loaded;

	var res = robot.devices;
	var max_x = 0;
	var max_z = 0;
	# Relative positioning calculation
	for device in res:
		var diff = device.global_position - global_position;
		max_x = max(max_x, abs(diff.x));
		max_z = max(max_z, abs(diff.z));

	# Wait a frame for the size of the enclosing container to be correct.
	await get_tree().process_frame;

	device_debuggers = [];

	for device in res:
		var diff = device.global_position - global_position;
		var scaled = Vector2(diff.x / max_x, diff.z / max_z);
		
		if device.has_method("get_debugger_representation"):
			var repr = device.get_debugger_representation();
			static_container.add_child(repr);
			repr.position = Vector2(scaled.x * static_container.size.x, scaled.y * static_container.size.y) / 4.0 + static_container.size / 2.0;
			repr.rotation = device.global_rotation.y - robot.global_rotation.y;
			device_debuggers.push_back(repr);

func device_class():
	return "debug"

func device_name():
	return "debug-" + port;

func defaults():
	return {
		"address": port,
		"free_text": "",
	};

func update_tracked_value(key, value):
	value_mapper[key] = value;
	if key not in position_mapper:
		position_mapper[key] = _cur_position;
		tracker_container.add_child(tracker_label.instantiate());
		_cur_position += 1;
	tracker_container.get_child(position_mapper[key]).text = key + ": " + value;

func handle_updates(delta):
	file_reader.seek(_cur_file_position);
	var text = [];
	while true:
		var line = file_reader.get_line();
		if line == "":
			break;
		text.push_back(line);
	if len(text) > 1 and known_carriage == null:
		known_carriage = "\r" in file_reader.get_as_text(false);
	text = ("\r\n" if known_carriage else "\n").join(text);
	# For some reason seeking to EOF blocks all future reads silently, even if more text is now available (Checked with get_position vs. get_length)
	# Therefore, just always be one behind on reading.
	if _cur_file_position != 0:
		text = text.substr(1);
	if text:
		if _cur_file_position == 0:
			# Fix above for one behind on reading.
			_cur_file_position -= 1;
		_cur_file_position += len(text.to_utf8_buffer());
		text = text.strip_edges();
		var separated_lines = text.split("\n");
		var new_lines = [];
		for i in range(len(separated_lines)):
			if separated_lines[i].count("=") == 1:
				var spl = separated_lines[i].split("=");
				update_tracked_value(spl[0].strip_edges(), spl[1].strip_edges());
			else:
				new_lines.push_back(separated_lines[i]);
		if len(new_lines) > 0:
			text_box.text = text_box.text + "\n" + message_prefix + ("\n" + message_prefix).join(new_lines);
			if len(text_box.text) > MAX_TEXT_BUFFER:
				text_box.text = text_box.text.substr(len(text_box.text) - MAX_TEXT_BUFFER, len(text_box.text) - 1)
	# Pin the tracker UI to the bot position
	$Debugger/TrackerPanel.position = get_viewport().get_camera_3d().unproject_position(get_parent().global_position);
	
	for repr in device_debuggers:
		if repr.has_method("update"):
			repr.update();
