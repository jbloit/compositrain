# Train Sequencer

Control a short music sequence with a toy train acting as the playbar, and landscape bricks acting as the patterns to be sequenced on 3 tracks.

## System

- Master: laptop running reactivion and supercollider. Detects fiducials on half the track, and plays the patterns.
- Slave: RaspberryPi for reactivion and half the track, and sensor aquisition.


# Setup @LaPetiteFabrique

## Master
- Lenovo T431s
- windows7
- in reactivision settings: invert x axis (saved in reactivion.xml)


## Slave
- RaspberryPi 3B+
- fisheye pi camera
- [hall sensor](https://fr.aliexpress.com/store/product/10pcs-speed-measurement-Hall-sensor-module-Hall-switch-motor-tachometer-module-DIY/1240331_1997125381.html)


### installation:

- OS: raspbian
- python3

with an internet connection, run:
```
sudo pip3 install python-osc
```


