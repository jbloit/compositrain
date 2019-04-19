/*
This is the main supercollider script to run for the Train installation at LaPetiteFabrique.

This script waits for an OSC /start message to play a sequence of patterns.
The sequence is controlled with OSC messages from the reacTiVision software, according to the "tuio" protocol (see pdf focument in this folder).

Execute this from a cmd window, with
sclang <pathToThisScript.scd>


NB: the terms "slot" and "step" mean the same thing in the code, ie a pattern's position index in time.

*/

s.waitForBoot({

	// The number of slots in the sequence
	~slotCountPi = 2;
	~slotCountLaptop = 4;
	~slotCount = ~slotCountPi + ~slotCountLaptop;

	~trackCount = 3; // this is a constant

	// The sequences to build. "-1" means no fiducial at the slot.
	//~harmoSeq = (-1!~slotCount);

	// Part sequences, and their buffers (
	// the buffers hold values during alive cycles of OSC data,
	// the sequences hold values at the end of alive cycles, and are passed to the sequencer.
	~harmoBuffer = (-1!~slotCount);
	~harmoSeq = (-1!~slotCount);

	~leadBuffer = (-1!~slotCount);
	~leadSeq = (-1!~slotCount);

	~percBuffer = (-1!~slotCount);
	~percSeq = (-1!~slotCount);

	// test seq
	// ~harmoSeq = [0,1,1,2,3,3];
	// ~leadSeq = [-1,4,5,6,7,7];
	// ~percSeq = [-1,9,10,11,8,-1];


	// since the two cameras' fields might overlap, we define each camera's allocated region
	// dimension ranges for the two different cameras
	// this needs to be calibrated manually
	~piXmin = 0.3;
	~piXmax = 0.7;
	~piYmin = 0.1;
	~piYmax = 0.9;

	~laptopXmin = 0.2;
	~laptopXmax = 0.9;
	~laptopYmin = 0.1;
	~laptopYmax = 0.9;

	// map patterns to fiducial indices
	// caution: use each key only once per dict
	~harmoPatterns= Dictionary.newFrom(List[
		\silent, -1,
		\harmo_1, 0,
		\harmo_2, 1,
		\harmo_3, 2,
		\harmo_4, 3,
	]);

	~leadPatterns= Dictionary.newFrom(List[
		\silent, -1,
		\lead_1, 4,
		\lead_2, 5,
		\lead_3, 6,
		\lead_4, 7,
	]);

	~percPatterns= Dictionary.newFrom(List[
		\silent, -1,
		\perc_1, 8,
		\perc_2, 9,
		\perc_3, 10,
		\perc_4, 11,
	]);


	// OSC data from rpi camera
	OSCdef(\rpiVision).free;
	OSCdef(\rpiVision, {|msg, time, addr, port|

		var sessionID, classID, posX, posY;

		"________________________________".postln;
		msg.postln;


		// The alive message is sent periodically. We reset the sequence and
		// make the previous one available to the sequencer.

		if (msg[1].asString == "alive", {
			~slotCountPi.do({|i|
				// write data to the sequencer
				~harmoSeq[i] = ~harmoBuffer[i];
				~leadSeq[i] = ~leadBuffer[i];
				~percSeq[i] = ~percBuffer[i];

				// and reinit buffers (so that it plays silence in case no brick is set on the next cycle)
				~harmoBuffer[i] = -1;
				~leadBuffer[i] = -1;
				~percBuffer[i] = -1
			});

		});

		// all "set" messages are received in between successive "alive" messages.
		// we build the sequence and store it as it comes into buffers
		if (msg[1].asString == "set", {
			// 3 tracks stack along the Y axis
			// ~slotCountPi slots stack along the X axis
			var trackIndex, slotIndex;

			// "--- Set rpi".postln;

			classID = msg[3]; // this is the detected fiducial index
			posX = msg[4];
			posY = msg[5];

			trackIndex = (posY.linlin(~piYmin, ~piYmax, 0, ~trackCount).ceil - 1);
 			slotIndex = (posX.linlin(~piXmin, ~piXmax, 0, ~slotCountPi).ceil - 1);


			// add offset and make sure indices dont go out of bounds
			trackIndex = trackIndex.clip(0, ~trackCount-1).asInt;
			slotIndex = slotIndex.clip(0, ~slotCountPi-1).asInt;

			trackIndex.asInt.postln;
			slotIndex.postln;
			classID.postln;
			switch(trackIndex,
				0, {~percBuffer[slotIndex] = classID},
				1, {~harmoBuffer[slotIndex] = classID},
				2, {~leadBuffer[slotIndex] = classID});

		});

//		~percBuffer.postln;

	}, '/tuio/2Dobj', recvPort:12345);

	// Parse OSC from reactivision on laptop, and update the sequence to play.
	OSCdef(\vision).free;
	OSCdef(\vision, {
		| msg, time, addr, port |

		var sessionID, classID, posX, posY;

		// "________________________________".postln;
		// msg.postln;


		// The alive message is sent periodically. We reset the sequence and
		// make the previous one available to the sequencer.
		if (msg[1].asString == "alive", {

			~slotCountLaptop.do({|i|
				// write data to the sequencer
				~harmoSeq[i + ~slotCountPi] = ~harmoBuffer[i + ~slotCountPi];
				~leadSeq[i + ~slotCountPi] = ~leadBuffer[i + ~slotCountPi];
				~percSeq[i + ~slotCountPi] = ~percBuffer[i + ~slotCountPi];

				// and reinit buffers (so that it plays silence in case no brick is set on the next cycle)
				~harmoBuffer[i + ~slotCountPi] = -1;
				~leadBuffer[i + ~slotCountPi] = -1;
				~percBuffer[i + ~slotCountPi] = -1

			});


			// DEBUG
			"---------------------- harmo lead seq, after laptop alive".postln;
			~harmoSeq.postln;
			~leadSeq.postln;
			~percSeq.postln;
		});

		// all "set" messages are received in between successive "alive" messages.
		// we build the sequence
		if (msg[1].asString == "set", {

			// 3 tracks stack along the Y axis
			// ~slotCountPi slots stack along the X axis
			var trackIndex, slotIndex;

			classID = msg[3]; // this is the detected fiducial index
			posX = msg[4];
			posY = msg[5];

			trackIndex = (posY.linlin(~laptopYmin, ~laptopYmax, 0, ~trackCount).ceil - 1);
			slotIndex = (posX.linlin(~laptopXmin, ~laptopXmax, 0, ~slotCountLaptop).ceil - 1);

			// add offset and make sure indices dont go out of bounds
			trackIndex = trackIndex.clip(0, ~trackCount-1).asInt;
			slotIndex = (slotIndex + ~slotCountPi).clip(0, ~slotCount-1).asInt;

			switch(trackIndex,
				0, {~percBuffer[slotIndex] = classID},
				1, {~harmoBuffer[slotIndex] = classID},
				2, {~leadBuffer[slotIndex] = classID});

		});



	}, '/tuio/2Dobj');



	// OSC data from rpi hall sensor
	OSCdef(\rpiSensor).free;
	OSCdef(\rpiSensor, {|msg, time, addr, port|

		msg.postln;

		t.start;

	}, '/start', recvPort:12346);

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
	~harmoPrev = 0;
	~leadPrev = 0;
	~percPrev = 0;

	~playStep = {|step|
		var harmoPdef, leadPdef, percPdef;


		postf("--- Step %\n", step);
		~harmoSeq.postln;
		~leadSeq.postln;
		~percSeq.postln;


		harmoPdef = ~harmoPatterns.findKeyForValue(~harmoSeq[step]);
		leadPdef = ~leadPatterns.findKeyForValue(~leadSeq[step]);
		percPdef = ~percPatterns.findKeyForValue(~percSeq[step]);

		if (harmoPdef != nil, {
			Pdef(harmoPdef).play(quant:0);}
		);
		~harmoPrev = ~harmoSeq[step];

		if (leadPdef != nil, {
			Pdef(leadPdef).play(quant:0);}
		);
		~leadPrev = ~leadSeq[step];

		if (percPdef != nil, {
			Pdef(percPdef).play(quant:0);}
		);
		~percPrev = ~percSeq[step];

		~beatPerSlot.wait;

		Pdef((~harmoPatterns.findKeyForValue(~harmoPrev)).asSymbol).stop;
		Pdef((~leadPatterns.findKeyForValue(~leadPrev)).asSymbol).stop;
		Pdef((~percPatterns.findKeyForValue(~percPrev)).asSymbol).stop;
	};


	t = Task({

		var step = 0;
		~playStep.value(step);

		step = 1;
		~playStep.value(step);

		step = 2;
		~playStep.value(step);

		step = 3;
		~playStep.value(step);

		step = 4;
		~playStep.value(step);

		step = 5;
		~playStep.value(step);

	});
});

/*
Play the sequence start:

t.start

*/