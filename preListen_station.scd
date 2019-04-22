/*
This is the main supercollider script to run for the Train installation at LaPetiteFabrique.

This script waits for an OSC /start message to play a sequence of patterns.
The sequence is controlled with OSC messages from the reacTiVision software, according to the "tuio" protocol (see pdf focument in this folder).

Execute this from a cmd window, with
sclang <pathToThisScript.scd>


NB: the terms "slot" and "step" mean the same thing in the code, ie a pattern's position index in time.

*/

s.waitForBoot({

	~currentPattern = nil;
	~prevPattern = nil;
	~slotCount = 6;

	// since the two cameras' fields might overlap, we define each camera's allocated region
	// dimension ranges for the two different cameras
	// this needs to be calibrated manually

	~laptopXmin = 0.0;
	~laptopXmax = 1.0;
	~laptopYmin = 0.0;
	~laptopYmax = 1.0;

	// Parse OSC from reactivision on laptop, and update the sequence to play.
	OSCdef(\vision).free;
	OSCdef(\vision, {
		| msg, time, addr, port |

		var sessionID, classID, posX, posY;
		/*
		"________________________________".postln;
		msg.postln;*/


		// The alive message is sent periodically. We reset the sequence and
		// make the previous one available to the sequencer.
		if (msg[1].asString == "alive", {

		});

		// all "set" messages are received in between successive "alive" messages.
		if (msg[1].asString == "set", {
			var selectedPattern = nil;

			~currentPattern = nil;

			">>>> SET ".postln;
			msg.postln;

			classID = msg[3]; // this is the detected fiducial index
			posX = msg[4];
			posY = msg[5];

			"-------------------------------------------".postln;
			classID.postln;


			if (selectedPattern.isNil, {
				selectedPattern = ~harmoPatterns.findKeyForValue(classID);
			});

			if (selectedPattern.isNil, {
				selectedPattern = ~percPatterns.findKeyForValue(classID);
			});

			if (selectedPattern.isNil, {
				selectedPattern = ~leadPatterns.findKeyForValue(classID);
			});

			~currentPattern = selectedPattern;

			if (~currentPattern.isNil, {}, {
				t.start;

			};
			);


		});

	}, '/tuio/2Dobj',  recvPort:3333);


	//////////////////////////////// SYNTHS

	"synthDefs.scd".loadRelative(true, {"synthDefs loaded".postln});

	s.sync;

	/////////////////// GLOBAL MUSIC PARAMETERS

	~trackDuration = 20; // measured in seconds
	~beatPerSlot = 4;
	~beatDuration = ~trackDuration / (~slotCount * ~beatPerSlot); // in seconds
	~bpm  = 60 / ~beatDuration;
	TempoClock.tempo = ~bpm/60;
	~beatPerSlot = 4;
	~scale = Scale.chromatic;



	/////////////////// PATTERNS FOR EACH STEP

	"patterns.scd".loadRelative(true, {"patterns loaded".postln});


	//////////////////////////// SEQUENCER

	~playStep = {|pattern|

		Pdef(pattern.asSymbol).play(quant:0);
		~beatPerSlot.wait;
		Pdef(pattern.asSymbol).stop;
	};


	t = Task({
		~playStep.value(~currentPattern);
	});

});

/*
Play the sequence start:

t.start

*/