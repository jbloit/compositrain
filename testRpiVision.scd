OSCdef(\rpiVision, {|msg, time, addr, port|
	"________________________________".postln;

	msg.postln;

}, '/tuio/2Dobj', recvPort:12345);


OSCdef(\rpiSensor, {|msg, time, addr, port|

	msg.postln;

}, '/start', recvPort:12346);

