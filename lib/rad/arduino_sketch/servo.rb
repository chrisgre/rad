# Arduino standard library servo
# http://arduino.cc/en/Reference/Servo

module Rad::ArduinoSketch::Servo

  def initialize #:nodoc:
    @servo_settings = []
    @servo_pins = []
  end

  def output_pin_servo(num, opts={})
    servo_setup(num, opts)
    return # don't use declarations, accessor, signatures below
  end

end
