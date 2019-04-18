#!/bin/sh

# Start reactivision without GUI
sudo modprobe bcm2835-v4l2 >> /home/pi/reactLog.txt
cd /home/pi/reacTIVision-master/linux
sleep 10
python3 /home/pi/philharmonie_grammaire_train/startSequenceSensor.py &
./reacTIVision -n >> /home/pi/reactLog.txt


