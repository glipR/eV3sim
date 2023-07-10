extends Control

var device;

func on_init(color):
	device = color;

func update():
	var panel = get_node("Color").get_theme_stylebox("panel");
	panel.set_bg_color(Color(device.cur_color[0], device.cur_color[1], device.cur_color[2]));
	add_theme_stylebox_override("panel", panel);
