extends Device
class_name Debugger

const MAX_TEXT_BUFFER = 4000;

@onready
var text_box = $Debugger/SharedPanel/Label;
@onready
var tracker_container = $Debugger/TrackerPanel/ItemContainer;

@export
var message_prefix = "rob-1: ";
@export
var tracker_label = preload("res://Devices/Debugger/TrackerLabel.tscn");

var value_mapper = {};
var position_mapper = {};
var _cur_position = 0;

var _cur_file_position = 0;
var file_reader;

func on_init():
	file_reader = FileAccess.open(data_path() + "free_text", FileAccess.READ);
	if file_reader == null:
		print(FileAccess.get_open_error());
		return "";

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
	# TODO: This should be different depending on whether \r is between lines
	text = "\r\n".join(text);
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
