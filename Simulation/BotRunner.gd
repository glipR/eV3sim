extends Node

# An autoload script to manage running various scripts to integrate with the bots.

var pid;
var output = [];

# Testing function to invoke the start function.
func _ready():
	var t = Thread.new();
	# TODO: Tie this into some other process so multiple bots can be used.
	t.start(start.bind(
		ProjectSettings.globalize_path("res://Testing/testing_script.py"),
		ProjectSettings.globalize_path("res://device-data/")
	));

func start(script_path, bot_root):
	OS.execute("CMD.exe", [
		"/C",
		(
			"py " + 
			script_path + 
			" > " + 
			bot_root + "debug/debug-debug/free_text"
		)
	], output, true);
