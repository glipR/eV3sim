extends Control

var device;

var debugColor = Gradient.new();

func on_init(infrared):
	device = infrared;
	debugColor.set_color(0, Color("393939"));
	debugColor.set_color(1, Color("c92e2e"));

func update():
	for x in range(1, len(device.all_strengths)+1):
		get_node("SubSensor" + str(x)).color = debugColor.sample(device.all_strengths[x-1] / device.MAX_STRENGTH);

