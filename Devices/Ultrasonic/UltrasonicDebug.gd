extends Control

var device;

var debugColors = Gradient.new();

func on_init(ultrasonic):
	device = ultrasonic;
	debugColors.set_color(0, Color(0, 0, 0));
	debugColors.set_color(1, Color(0.8, 0, 0));

func update():
	$Label.text = str(int(device.cur_dist));
	$Label.modulate = debugColors.sample(device.cur_dist / device.MAX_DISTANCE);
