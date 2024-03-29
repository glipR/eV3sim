from unittest import mock

# ev3dev2 changes made:
# printing
# wait
# attribute file caching
# _scale reimplementation

@mock.patch("ev3dev2.Device.DEVICE_ROOT_PATH", "C:/Users/jgoer/OneDrive/Desktop/Github/eV3sim/device-data")
@mock.patch("ev3dev2.motor.Motor.wait", lambda s, cond, t: True)
def run_func():
    import time
    from ev3dev2.motor import LargeMotor
    from ev3dev2.sensor.lego import ColorSensor, UltrasonicSensor
    from ev3dev2.sensor import Sensor

    lm1 = LargeMotor(address="outA")
    lm2 = LargeMotor(address="outB")
    lm3 = LargeMotor(address="outC")
    lm4 = LargeMotor(address="outD")

    us = UltrasonicSensor(address="in1")
    cs = ColorSensor(address="in2")
    ir = Sensor(address="in3", driver_name="ht-nxt-ir-seek-v2")

    speed = 10
    while True:
        print(cs.color, ir.value(0))
        if cs.color == cs.COLOR_GREEN:
            speed = 10
        elif cs.color == cs.COLOR_BLUE:
            speed = 20
        elif cs.color == cs.COLOR_RED:
            speed = 50
        else:
            speed = 0
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
