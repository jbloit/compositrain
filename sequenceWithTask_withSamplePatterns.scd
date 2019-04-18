/*
This is the main supercollider script to run for the Train installation at LaPetiteFabrique.

This script waits for an OSC /start message to play a sequence of patterns.
The sequence is controlled with OSC messages from the reacTiVision software, according to the "tuio" protocol (see pdf focument in this folder).

Execute this from a cmd window, with
sclang <pathToThisScript.scd>

*/

s.waitForBoot({

	// The number of slots in the sequence
	~slotCountPi = 2;
	~slotCountLaptop = 4;
	~slotCount = ~slotCountPi + ~slotCountLaptop;

	// The sequences to build. "-1" means no fiducial at the slot.
	//~harmoSeq = (-1!~slotCount);

	// test seq
	~harmoSeq = (-1!~slotCount);
	~harmoPi = [0,1];
	~harmoLaptop = [0,1,2,3];

	~leadSeq = (-1!~slotCount);
	~leadSeqPi = [4,5];
	~leadSeqLaptop = [4,5,6,7];

	~percSeq = (-1!~slotCount);
	~percSeqPi = [8,9];
	~percSeqLaptop = [8,9,10,11];

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

	// a local version of the sequence
	~tmpSeq = (-1!~slotCount);

	// OSC data from rpi camera
	OSCdef(\rpiVision).free;
	OSCdef(\rpiVision, {|msg, time, addr, port|
		//	"________________________________".postln;
		//		msg.postln;

		var sessionID, classID, posX, posY;
		var trackIndex; // 0, 1, 2

		// The alive message is sent periodically. We reset the sequence and
		// make the previous one available to the sequencer.

		if (msg[1].asString == "alive", {
			~harmoSeq = ~tmpSeq;
			// ~harmoSeq.postln;
			~tmpSeq = (-1!~slotCount);
		});

		// all "set" messages are received in between successive "alive" messages.
		// we build the sequence
		if (msg[1].asString == "set", {
			var index;
			classID = msg[3];
			posX = msg[4];
			posY = msg[5];

			index =(posX.linlin(0, 1, 0, ~slotCount).ceil - 1);
			~tmpSeq[index] = classID;
		});


	}, '/tuio/2Dobj', recvPort:12345);

	// Parse OSC from reactivision, and update the sequence to play.
	OSCdef(\vision).free;
	OSCdef(\vision, {
		| msg, time, addr, port |

		var sessionID, classID, posX, posY;

		msg.postln;

		// The alive message is sent periodically. We reset the sequence and
		// make the previous one available to the sequencer.
		if (msg[1].asString == "alive", {
			~harmoSeq = ~tmpSeq;
			// ~harmoSeq.postln;
			~tmpSeq= (-1!~slotCount);
		});

		// all "set" messages are received in between successive "alive" messages.
		// we build the sequence
		if (msg[1].asString == "set", {
			var index;
			classID = msg[3];
			posX = msg[4];
			posY = msg[5];

			index =(posX.linlin(0, 1, 0, ~slotCount).ceil - 1);
			~tmpSeq[index] = classID;
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

	t = Task({

		var step = 0;

		///////
		"step 1".postln;
		~harmoSeq.postln;
		Pdef(~harmoPatterns.findKeyForValue(~harmoSeq[step])).play(quant:0);
		~harmoPrev = ~harmoSeq[step];
		Pdef(~leadPatterns.findKeyForValue(~leadSeq[step])).play(quant:0);
		~leadPrev = ~leadSeq[step];
		Pdef(~percPatterns.findKeyForValue(~percSeq[step])).play(quant:0);
		~percPrev = ~percSeq[step];

		~beatPerSlot.wait;

		Pdef((~harmoPatterns.findKeyForValue(~harmoPrev)).asSymbol).stop;
		Pdef((~leadPatterns.findKeyForValue(~leadPrev)).asSymbol).stop;
		Pdef((~percPatterns.findKeyForValue(~percPrev)).asSymbol).stop;

		///////
		step = 1;
		"step 2".postln;
		~harmoSeq.postln;
		Pdef(~harmoPatterns.findKeyForValue(~harmoSeq[step])).play(quant:0);
		~harmoPrev = ~harmoSeq[step];
		Pdef(~leadPatterns.findKeyForValue(~leadSeq[step])).play(quant:0);
		~leadPrev = ~leadSeq[step];
		Pdef(~percPatterns.findKeyForValue(~percSeq[step])).play(quant:0);
		~percPrev = ~percSeq[step];

		~beatPerSlot.wait;

		Pdef((~harmoPatterns.findKeyForValue(~harmoPrev)).asSymbol).stop;
		Pdef((~leadPatterns.findKeyForValue(~leadPrev)).asSymbol).stop;
		Pdef((~percPatterns.findKeyForValue(~percPrev)).asSymbol).stop;

		///////
		step = 2;
		"step 3".postln;
		~harmoSeq.postln;
		Pdef(~harmoPatterns.findKeyForValue(~harmoSeq[step])).play(quant:0);
		~harmoPrev = ~harmoSeq[step];
		Pdef(~leadPatterns.findKeyForValue(~leadSeq[step])).play(quant:0);
		~leadPrev = ~leadSeq[step];
		Pdef(~percPatterns.findKeyForValue(~percSeq[step])).play(quant:0);
		~percPrev = ~percSeq[step];

		~beatPerSlot.wait;

		Pdef((~harmoPatterns.findKeyForValue(~harmoPrev)).asSymbol).stop;
		Pdef((~leadPatterns.findKeyForValue(~leadPrev)).asSymbol).stop;
		Pdef((~percPatterns.findKeyForValue(~percPrev)).asSymbol).stop;

		///////
		step = 3;
		"step 4".postln;
		~harmoSeq.postln;
		Pdef(~harmoPatterns.findKeyForValue(~harmoSeq[step])).play(quant:0);
		~harmoPrev = ~harmoSeq[step];
		Pdef(~leadPatterns.findKeyForValue(~leadSeq[step])).play(quant:0);
		~leadPrev = ~leadSeq[step];
		Pdef(~percPatterns.findKeyForValue(~percSeq[step])).play(quant:0);
		~percPrev = ~percSeq[step];

		~beatPerSlot.wait;

		Pdef((~harmoPatterns.findKeyForValue(~harmoPrev)).asSymbol).stop;
		Pdef((~leadPatterns.findKeyForValue(~leadPrev)).asSymbol).stop;
		Pdef((~percPatterns.findKeyForValue(~percPrev)).asSymbol).stop;


		///////
		step = 4;
		"step 5".postln;
		~harmoSeq.postln;
		Pdef(~harmoPatterns.findKeyForValue(~harmoSeq[step])).play(quant:0);
		~harmoPrev = ~harmoSeq[step];
		Pdef(~leadPatterns.findKeyForValue(~leadSeq[step])).play(quant:0);
		~leadPrev = ~leadSeq[step];
		Pdef(~percPatterns.findKeyForValue(~percSeq[step])).play(quant:0);
		~percPrev = ~percSeq[step];

		~beatPerSlot.wait;

		Pdef((~harmoPatterns.findKeyForValue(~harmoPrev)).asSymbol).stop;
		Pdef((~leadPatterns.findKeyForValue(~leadPrev)).asSymbol).stop;
		Pdef((~percPatterns.findKeyForValue(~percPrev)).asSymbol).stop;

		///////
		step = 5;
		"step 6".postln;
		~harmoSeq.postln;
		Pdef(~harmoPatterns.findKeyForValue(~harmoSeq[step])).play(quant:0);
		~harmoPrev = ~harmoSeq[step];
		Pdef(~leadPatterns.findKeyForValue(~leadSeq[step])).play(quant:0);
		~leadPrev = ~leadSeq[step];
		Pdef(~percPatterns.findKeyForValue(~percSeq[step])).play(quant:0);
		~percPrev = ~percSeq[step];

		~beatPerSlot.wait;

		Pdef((~harmoPatterns.findKeyForValue(~harmoPrev)).asSymbol).stop;
		Pdef((~leadPatterns.findKeyForValue(~leadPrev)).asSymbol).stop;
		Pdef((~percPatterns.findKeyForValue(~percPrev)).asSymbol).stop;

	});
});

/*
Play the sequence start:

t.start

*/