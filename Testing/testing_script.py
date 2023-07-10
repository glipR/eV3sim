import sys
import time
from unittest import mock

# ev3dev2 changes made:
# wait
# _scale reimplementation

from ev3dev2 import Device
class MockedDevice(Device):

    # For testing purposes.
    DEVICE_ROOT_PATH = "C:/Users/jgoer/OneDrive/Desktop/Github/eV3sim/device-data"

    __slots__ = [
        '_path',
        '_device_index',
        '_attr_cache',
        '_safe_cache',
        'kwargs',
    ]

    def __init__(self, class_name, name_pattern='*', name_exact=False, **kwargs):
        super().__init__(class_name, name_pattern, name_exact, **kwargs)
        self._safe_cache = {}

    def _get_attribute(self, attribute, name, use_safe_cache=True):
        """Device attribute getter"""
        try:
            if attribute is None:
                attribute = self._attribute_file_open(name)
            else:
                attribute.seek(0)
            value = attribute.read().strip().decode()
            if value != "":
                self._safe_cache[name] = value
            elif use_safe_cache:
                value = self._safe_cache.get(name, value)
            return attribute, value
        except Exception as ex:
            self._raise_friendly_access_error(ex, name, None)

    def get_attr_string(self, attribute, name):
        # Strings may be empty
        return self._get_attribute(attribute, name, use_safe_cache=False)

def mocked_scale(self, mode):
    # Don't cache per-mode decimals.
    return 10**(-self.decimals)

def mocked_wait(self, cond, timeout=None):
    tic = time.time()
    while True:
        if cond(self.state):
            return True
        if timeout is not None and time.time() >= tic + timeout / 1000:
            return cond(self.state)
        time.sleep(0.05)

@mock.patch("ev3dev2.Device", MockedDevice)
@mock.patch("ev3dev2.sensor.Sensor._scale", mocked_scale)
@mock.patch("ev3dev2.motor.Motor.wait", mocked_wait)
def run_func():
    import time
    from ev3dev2.motor import LargeMotor
    from ev3dev2.sensor.lego import ColorSensor, UltrasonicSensor
    from ev3dev2.sensor import Sensor

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
        if cs.color == cs.COLOR_GREEN:
            speed = 10
        elif cs.color == cs.COLOR_BLUE:
            speed = 20
        elif cs.color == cs.COLOR_RED:
            speed = 50
        else:
            speed = 0
        print("SPEED = ", speed, flush=True)
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
