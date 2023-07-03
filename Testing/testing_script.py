import sys
from unittest import mock

print(sys.argv)

# ev3dev2 changes made:
# printing
# wait
# attribute file caching
# _scale reimplementation

@mock.patch("ev3dev2.Device.DEVICE_ROOT_PATH", "C:/Users/jgoer/OneDrive/Desktop/Github/eV3sim/device-data")
@mock.patch("ev3dev2.motor.Motor.wait", lambda s, cond, t: True)
def run_func():
    import time
    import queue
    from ev3dev2.motor import LargeMotor
    from ev3dev2.sensor.lego import ColorSensor, UltrasonicSensor
    from ev3dev2.sensor import Sensor, Device

    # class Debugger(Device):

    #     SYSTEM_CLASS_NAME = "debug"
    #     SYSTEM_DEVICE_NAME_CONVENTION = "*"

    #     __slots__ = [
    #         '_path',
    #         '_device_index',
    #         '_attr_cache',
    #         '_safe_cache',
    #         'kwargs',
    #         '_msg_queue',
    #         '_free_text'
    #     ]

    #     def __init__(self, **kwargs):
    #         super().__init__(self.SYSTEM_CLASS_NAME, self.SYSTEM_DEVICE_NAME_CONVENTION, False, **kwargs)
    #         self._msg_queue = queue.Queue()
    #         self._free_text = None

    #     def post_message(self, *args):
    #         self._msg_queue.put(" ".join(map(str, args)))
    #         self._free_text, free_text = self.get_attr_string(self._free_text, "free_text")
    #         if free_text:
    #             return
    #         vals = []
    #         while not self._msg_queue.empty():
    #             vals.append(self._msg_queue.get())
    #         vals = "\n".join(vals)
    #         self._free_text = self.set_attr_string(self._free_text, "free_text", vals)


    # debug = Debugger(address="debug")
    print("Connecting Devices...")
    print(sys.argv[1:])

    lm1 = LargeMotor(address="outA")
    lm2 = LargeMotor(address="outB")
    lm3 = LargeMotor(address="outC")
    lm4 = LargeMotor(address="outD")

    us = UltrasonicSensor(address="in1")
    cs = ColorSensor(address="in2")
    ir = Sensor(address="in3", driver_name="ht-nxt-ir-seek-v2")

    print("Initialising Variables...", flush=True)



    speed = 10
    _iter = 0
    max_iterations = 1000
    while True:
        _iter += 1
        if _iter % 100 == 0:
            print(f"Iteration {_iter} / {max_iterations}")
        if _iter > max_iterations:
            return
        if cs.color < len(cs.COLORS):
            print("COLOR = ", cs.COLORS[cs.color])
        if cs.color == cs.COLOR_GREEN:
            speed = 10
        elif cs.color == cs.COLOR_BLUE:
            speed = 20
        elif cs.color == cs.COLOR_RED:
            speed = 50
        else:
            speed = 0
        print("SPEED = ", speed, flush=True)
        print("IR = ", [ir.value(x) for x in range(1, 6)])
        if us.distance_inches < 100 * 0.393701:
            lm1.on(-speed)
            lm2.on(-speed)
            lm3.on(-speed)
            lm4.on(-speed)
            time.sleep(0.02)
        else:
            lm1.on(speed)
            lm2.on(speed)
            lm3.on(speed)
            lm4.on(speed)
            time.sleep(0.02)

run_func()
