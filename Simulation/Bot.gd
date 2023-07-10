extends Node3D
class_name Bot

var devices = [];

signal fully_loaded;

func _find_devices(root, result):
	if root.is_in_group("DEVICES"):
		result.push_back(root);
	for child in root.get_children():
		# Check if is a device.
		_find_devices(child, result);

func _ready():
	_find_devices(self, devices);
	emit_signal("fully_loaded");
