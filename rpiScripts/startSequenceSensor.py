import RPi.GPIO as GPIO
from pythonosc import osc_message_builder
from pythonosc import udp_client

INPUT_PIN = 10

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BOARD)
GPIO.setup(INPUT_PIN, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)

client = udp_client.SimpleUDPClient("169.254.212.145", 12346)

def buttonEvent(channel):
    print("ACTION ON PIN " + str(channel) )
    client.send_message("/start", channel)

GPIO.add_event_detect(INPUT_PIN, GPIO.FALLING, callback=buttonEvent)

    
while(True):
    if GPIO.input(INPUT_PIN) == GPIO.HIGH:
        print("GPIO HIGH")

"""message = input("press any key to quit")
"""
