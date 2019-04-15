s.waitForBoot({

	// The number of slots in the sequence
	~slotCount = 6;

	// The sequences to build. "-1" means no fiducial at the slot.
	//~harmoSeq = (-1!~slotCount);

	// test seq
	~harmoSeq = [1,2,2,3,2,1];
	~leadSeq = [11,12,-1,14,12,13];
	~percSeq = [21,22,23,21,22,22];

	// test seq
	~harmoSeq = [-1,4,4,3,2,1];
	~leadSeq = [11,17,-1,16,14,13];
	~percSeq = [-1,22,23,24,27,28];

	// test seq
	~harmoSeq = [-1,4,-1,3,-1,4];
	~leadSeq = [-1,14,17,11,15,-1];
	~percSeq = [21,21,22,-1,29,29];


	// a local version of the sequence
	~tmpSeq = (-1!~slotCount);
	// Parse OSC from reactivision, and update the sequence to play.
	OSCdef(\vision).free;
	OSCdef(\vision, {
		| msg, time, addr, port |

		var sessionID, classID, posX, posY;

		// msg.postln;

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


	//////////////////////////////// SYNTHS



	SynthDef(\wind, {|amp=0.2, out=0, modFreq=0.1, freq = 1348, fRq = 0.5, atk=0.01, rel=0.1, gate=1|
		var src, mod, env;

		env = EnvGen.kr(Env.asr(atk, 1, rel), gate, doneAction: 2);

		mod = {LFNoise2.ar(modFreq).range(0, 1)}!6;
		src = WhiteNoise.ar(mod.lagud(1, 4));
		src = RLPF.ar(src, freq.lag(1), fRq);
		src = src * env;
		Out.ar(out, Splay.ar(src*amp););
	}).add;

	SynthDef("hat", {arg out = 0, amp = 0.5, att = 0.01, rel = 0.2, ffreq = 6000, pan = 0;
		var snd = WhiteNoise.ar(amp);
		var env = Env.perc(att, rel).kr(doneAction: 2);
		snd = HPF.ar(snd * env, ffreq);
		Out.ar(out, Pan2.ar(snd, pan));
	}).add;

	SynthDef("snare", {arg out = 0, amp = 0.1, sinfreq = 180, att = 0.01, rel = 0.2, ffreq = 2000, pan = 0;
		var snd1 = WhiteNoise.ar(amp);
		var snd2 = SinOsc.ar(sinfreq,0,amp);
		var env = EnvGen.kr(Env.perc(att, rel), doneAction: 2);
		var sum = HPF.ar(snd1 * env, ffreq)+(snd2*env);
		Out.ar(out, Pan2.ar(sum, pan));
	}).add;

	SynthDef(\kick, {
		|out=0, amp=0.4|
		var snd;
		snd = DC.ar(0);
		snd = snd + (SinOsc.ar(XLine.ar(1500, 800, 0.01)) * Env.perc(0.0005, 0.01, curve: \lin).ar);
		snd = snd + (BPF.ar(Impulse.ar(0) * SampleRate.ir / 48000, 6100, 1.0) * 3.dbamp);
		snd = snd + (BPF.ar(Hasher.ar(Sweep.ar), 300, 0.9) * Env.perc(0.001, 0.02).ar);
		snd = snd + (SinOsc.ar(XLine.ar(472, 60, 0.045)) * Env.perc(0.0001, 0.3, curve: \lin).delay(0.005).ar(2));
		snd = snd * amp;
		snd = snd.tanh * 0.2;
		Out.ar(out, Pan2.ar(snd, 0));
	}).add;


	/////////////////////// SAMPLER
	Buffer.freeAll;
	~samplesDir = thisProcess.nowExecutingPath.dirname +/+"samples";
	~bellsSampleEntries = PathName.new(~samplesDir+/+"bells").entries;
	~bellSamplesCount = ~bellsSampleEntries.size;
	~bellsBuffers = Array.new;
	~bellSamplesCount.do{|i|
		~bellsBuffers = ~bellsBuffers.add(Buffer.read(s, ~bellsSampleEntries[i].fullPath));
	};

	~whistleSampleEntries = PathName.new(~samplesDir+/+"whistles").entries;
	~whistleBuffers = Array.new;
	~whistleSamplesCount = ~whistleSampleEntries.size;
	~whistleSamplesCount.do{|i|
		~whistleBuffers = ~whistleBuffers.add(Buffer.read(s, ~whistleSampleEntries[i].fullPath));
	};

	~percSampleEntries = PathName.new(~samplesDir+/+"perc").entries;
	~percBuffers = Array.new;
	~percSamplesCount = ~percSampleEntries.size;
	~percSamplesCount.do{|i|
		~percBuffers = ~percBuffers.add(Buffer.read(s, ~percSampleEntries[i].fullPath));
	};


	// stereo sampler
	SynthDef(\sampler, {
		|out=0, bufnum=0, amp=0.3, rate=1, pan=0.5, meterOut=0|
		var sig1, sig2, sigfilt;
		sig1 = PlayBuf.ar(2, bufnum, rate * BufRateScale.kr(bufnum), doneAction:2);
		sig2 = Pan2.ar(sig1*amp, pan.linlin(0.0, 1.0, -1.0, 1.0));
		Out.ar(out, sig2);
	}).add;


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

	/////// HARMONY LAYER
	Pdef(\harmo_1,
		Pbind(
			\instrument, \sampler,
			\bufnum, ~bellsBuffers[0],
			\dur, 1,
			\rate, Pseq( [1], inf).midiratio,
			\scale, ~scale,
			\amp, 1,
			\out, 0 ,
	));



	/////// 2

	Pdef(\harmo_2,
		Pbind(
			\instrument, \sampler,
			\bufnum, ~bellsBuffers[0],
			\dur, 1,
			\rate, Pseq( [1, 5,  8, 13 ], inf).midiratio,
			\scale, ~scale,
			\amp, 1,
			\out, 0 ,
	));

	////// 3

	Pdef(\harmo_3,
		Ppar([
			Pbind(
				\instrument, \sampler,
				\bufnum, ~bellsBuffers[0],
				\dur, 1/4,
				\rate, Pseq( [[1, 5,  8], [1,  8, 13] ], inf).midiratio,
				\scale, ~scale,
				\amp, 0.4,
				\out, 0 ,
			),
			Pbind(
				\instrument, \sampler,
				\bufnum, ~bellsBuffers[3],
				\dur, 4,
				\rate, TempoClock.tempo,
				\scale, ~scale,
				\amp, 1,
				\out, 0 ,
			),
		])
	);


	////// 4

	Pdef(\harmo_4,
		Pbind(
			\instrument, \sampler,
			\bufnum, ~bellsBuffers[0],
			\dur, Pseq([ 1,2]/4, inf),
			\rate, Pseq( [[1, 5,  8], 1, [1,  8, 13], 8 ], inf).midiratio,
			\scale, ~scale,
			\amp, 0.5,
			\out, 0 ,
	));




	////////////////////////////// LEAD LAYER

	///////////////// 1

	Pdef(\lead_1,
		Ppar([
			Pbind(\instrument, \sampler,
				\dur, Pseq([Rest(2), 2], inf),
				\bufnum, ~whistleBuffers[1],
				\rate, Pseq( [[-7,1, 5]], inf).midiratio,
				\legato, Pseq([1, 0.4], inf),
				\scale, ~scale,
				\amp, 0.2,
				\out, 0,
			),
			Pbind(\instrument, \sampler,
				\dur, Pseq([2, Rest(2)], inf),
				\bufnum, ~whistleBuffers[5],
				\rate, TempoClock.tempo,
				\legato, Pseq([1, 0.4], inf),
				\scale, ~scale,
				\amp, 0.7,
				\out, 0,
			)
		]
	));



	///////////////// 2

	Pdef(\lead_2,
		Pbind(\instrument, \sampler,
			\dur, 2,
			\bufnum, ~whistleBuffers[1],
			\rate, Pseq( [[1, 5], [3, 8]], inf).midiratio,
			\legato, Pseq([1, 0.4], inf),
			\scale, ~scale,
			\amp, 0.2,
			\out, 0,
	));


	///////////////// 3

	Pdef(\lead_3,
		Pbind(\instrument, \sampler,
			\bufnum, ~whistleBuffers[1],
			\dur, Pseq([1/2, 1/2]*2, inf),
			\rate, Pseq( [5, 3, 5, 8], inf).midiratio,
			\scale, ~scale,
			\amp, 0.2,
			\out, 0,
	));


	///////////////// 4

	Pdef(\lead_4,
		Pbind(\instrument, \sampler,
			\dur, Pseq( [1/4, 1/4, 1/4, 1/4, 1]*2  , inf),
			\bufnum, ~whistleBuffers[1],
			\rate, Pseq( [1, 5, 8, 1, 1], inf).midiratio,
			\legato, Pseq([0.9, 0.9, 0.7, 1], inf),
			\scale, ~scale,
			\amp, 0.2,
			\out, 0,
	));

	///////////////// 5

	Pdef(\lead_5,
		Pbind(\instrument, \sampler,
			\dur, Pseq([1/4, 1/2, 1/4]*2, inf),
			\bufnum, ~whistleBuffers[1],
			\rate, Pseq( [10, 5, 3], inf).midiratio,
			\scale, ~scale,
			\amp, 0.2,
			\out, 0,
	));

	///////////////// 6
	Pdef(\lead_6,
		Ppar([
			Pbind(\instrument, \sampler,
				\dur, Pseq([1/4, 1/4, 1/4, 5/4]*2 , inf),
				\bufnum, ~whistleBuffers[1],
				\rate, Pseq( [10, 8, 10, 13], inf).midiratio,
				\scale, ~scale,
				\amp, 0.2,
				\out, 0,
			),
			Pbind(\instrument, \sampler,
				\dur, 2,
				\bufnum, ~whistleBuffers[1],
				\rate, Pseq( [[1, 5], [3, 8]], inf).midiratio,
				\legato, Pseq([1, 0.4], inf),
				\scale, ~scale,
				\amp, 0.2,
				\out, 0,
			),
			Pbind(\instrument, \sampler,
				\dur, 2,
				\bufnum, ~whistleBuffers[4],
				\rate, TempoBusClock.tempo,
				\legato, Pseq([1, 0.4], inf),
				\scale, ~scale,
				\amp, 0.2,
				\out, 0,
			)
		]
	));

	///////////////// 7

	Pdef(\lead_7,
		Ppar([
			Pbind(\instrument, \sampler,
				\dur, Pseq([1], inf),
				\bufnum, ~whistleBuffers[0],
				\rate, Pseq( [[1, 5], [3, 8]], inf).midiratio,
				\scale, ~scale,
				\amp, 0.2,
				\out, 0,
			),
			Pbind(\instrument, \sampler,
				\dur, 2,
				\bufnum, ~whistleBuffers[4],
				\rate, Pseq( [[1, 5], [3, 8]], inf).midiratio,
				\legato, Pseq([1, 0.4], inf),
				\scale, ~scale,
				\amp, 0.2,
				\out, 0,
		)]
	));

	////////////////////////////// PERC LAYER

	Pdef(\perc_1,
		Ppar([
			// krakebs
			Pbind(
				\instrument, \sampler,
				\bufnum, ~percBuffers[1],
				\dur, Pseq([1/4, 3/4, Rest(1)], inf),
				\rate, Pseq([1,2, 2]*TempoClock.tempo, inf),
				\amp, 0.3
			),
			// maracas 16th
			Pbind(
				\instrument, \sampler,
				\bufnum, ~percBuffers[2],
				\rate, TempoClock.tempo,
				\dur, Pseq([4],inf),
				\amp, 1
			),
			// tiroir
			Pbind(
				\instrument, \sampler,
				\dur, Pseq([4], inf),
				\rate, TempoClock.tempo,
				\bufnum, ~percBuffers[4],
				\amp, 0.4
			),
			Pbind(\instrument, \wind,
				\amp, 0.2,
				\rel, 1,
				\dur, Pseq([4], inf),
				\freq, Pseq([70], inf).midicps,
			),
	]));

	///////////// 2

	Pdef(\perc_2,
		Ppar([
			// krakebs
			Pbind(
				\instrument, \sampler,
				\bufnum, ~percBuffers[1],
				\dur, Pseq([1], inf),
				\rate, TempoClock.tempo,
				\amp, 0.5
			),
			// maracas 16th
			Pbind(
				\instrument, \sampler,
				\bufnum, ~percBuffers[2],
				\rate, TempoClock.tempo,
				\dur, Pseq([4],inf),
				\amp, 1
			),
			// tiroir
			Pbind(
				\instrument, \sampler,
				\dur, Pseq([4], inf),
				\rate, TempoClock.tempo,
				\bufnum, ~percBuffers[4],
				\amp, 0.6
			),
			Pbind(\instrument, \wind,
				\amp, 0.5,
				\rel, 1,
				\dur, Pseq([6/4, 2/4], inf),
				\freq, Pseq([70, 80], inf).midicps,
			),
			// box
			Pbind(
				\instrument, \sampler,
				\bufnum, ~percBuffers[0],
				\dur, Pseq([Rest(1), 1], inf),
				\rate, TempoClock.tempo,
				\amp, 0.5
			),
			Pbind(
				\instrument, "kick",
				\dur, Pseq([1, Rest(2.5), 1/2],inf),
				\amp, 0.6,
				\rel, 0.12,
				\glissf, 0.99
			),
		])
	);

	///////////// 3

	Pdef(\perc_3,
		Ppar([
			// krakebs
			Pbind(
				\instrument, \sampler,
				\bufnum, ~percBuffers[1],
				\dur, Pseq([1], inf),
				\rate, TempoClock.tempo,
				\amp, 0.5
			),
			// maracas 16th
			Pbind(
				\instrument, \sampler,
				\bufnum, ~percBuffers[2],
				\rate, TempoClock.tempo,
				\dur, Pseq([4],inf),
				\amp, 1
			),
			// tiroir
			Pbind(
				\instrument, \sampler,
				\dur, Pseq([4], inf),
				\rate, TempoClock.tempo,
				\bufnum, ~percBuffers[4],
				\amp, 0.3
			),
			Pbind(\instrument, \wind,
				\amp, 0.5,
				\rel, 0.3,
				\dur, Pseq([1/4, 1/2, 1/4, 1], inf),
				\freq, Pseq([70, 80], inf).midicps,
			),
			// box
			Pbind(
				\instrument, \sampler,
				\bufnum, ~percBuffers[0],
				\dur, Pseq([Rest(1), 1], inf),
				\rate, TempoClock.tempo,
				\amp, 0.5
			),
			Pbind(
				\instrument, "kick",
				\dur, Pseq([1, Rest(2.5), 1/2],inf),
				\amp, 0.6,
				\rel, 0.12,
				\glissf, 0.99
			),
	]));


	///////////// 4

	Pdef(\perc_4,
		Ppar([
			// krakebs
			Pbind(
				\instrument, \sampler,
				\bufnum, ~percBuffers[1],
				\dur, Pseq([1], inf),
				\rate, TempoClock.tempo,
				\amp, 0.5
			),
			// maracas triplets
			Pbind(
				\instrument, \sampler,
				\bufnum, ~percBuffers[3],
				\rate, TempoClock.tempo,
				\dur, Pseq([2],inf),
				\amp, 1
			),
			// tiroir
			Pbind(
				\instrument, \sampler,
				\dur, Pseq([4], inf),
				\rate, TempoClock.tempo,
				\bufnum, ~percBuffers[4],
				\amp, 0.3
			),
			Pbind(\instrument, \wind,
				\amp, 0.5,
				\rel, 0.3,
				\dur, Pseq([1/4, 1/2, 1/4, 1], inf),
				\freq, Pseq([70, 80], inf).midicps,
			),
			// box
			Pbind(
				\instrument, \sampler,
				\bufnum, ~percBuffers[0],
				\dur, Pseq([Rest(1), 1], inf),
				\rate, TempoClock.tempo,
				\amp, 0.5
			),
			Pbind(
				\instrument, "kick",
				\dur, Pseq([6/8, 6/8, 1/2, 1/2, Rest(1), 0.5],inf),
				\amp, 0.6,
				\rel, 0.12,
				\glissf, 0.99
			),
		])
	);

	//////////// 5
	Pdef(\perc_5,
		Ppar([
			// krakebs
			Pbind(
				\instrument, \sampler,
				\bufnum, ~percBuffers[1],
				\dur, Pseq([1], inf),
				\rate, TempoClock.tempo,
				\amp, 0.5
			),
			// maracas 16th
			Pbind(
				\instrument, \sampler,
				\bufnum, ~percBuffers[2],
				\rate, TempoClock.tempo,
				\dur, Pseq([4],inf),
				\amp, 1
			),
			// tiroir
			Pbind(
				\instrument, \sampler,
				\dur, Pseq([4], inf),
				\rate, TempoClock.tempo,
				\bufnum, ~percBuffers[4],
				\amp, 1
			),
			Pbind(\instrument, \wind,
				\amp, 0.5,
				\rel, TempoClock.tempo*2,
				\dur, Pseq([2, 2], inf),
				\freq, Pseq([70, 80], inf).midicps,
			),
			// box
			Pbind(
				\instrument, \sampler,
				\bufnum, ~percBuffers[0],
				\dur, Pseq([Rest(1), 1], inf),
				\rate, TempoClock.tempo,
				\amp, 0.5
			)
	]));


	Pdef(\perc_6,
		Ppar([
			// krakebs
			Pbind(
				\instrument, \sampler,
				\bufnum, ~percBuffers[1],
				\dur, Pseq([1/3], inf),
				\rate, Pseq([1,2]*TempoClock.tempo, inf),
				\amp, 0.4
			),
			// maracas 16th
			Pbind(
				\instrument, \sampler,
				\bufnum, ~percBuffers[2],
				\rate, TempoClock.tempo,
				\dur, Pseq([4],inf),
				\amp, 1
			),
			// tiroir
			Pbind(
				\instrument, \sampler,
				\dur, Pseq([4], inf),
				\rate, TempoClock.tempo,
				\bufnum, ~percBuffers[4],
				\amp, 1
			),
			Pbind(\instrument, \wind,
				\amp, 0.5,
				\rel, TempoClock.tempo*2,
				\dur, Pseq([2, 2], inf),
				\freq, Pseq([70, 80], inf).midicps,
			),
			// box
			Pbind(
				\instrument, \sampler,
				\bufnum, ~percBuffers[0],
				\dur, Pseq([Rest(1), 1], inf),
				\rate, TempoClock.tempo,
				\amp, 0.5
			)
	]));

	Pdef(\perc_7,
		Ppar([
			// krakebs
			Pbind(
				\instrument, \sampler,
				\bufnum, ~percBuffers[1],
				\dur, Pseq([1/4], inf),
				\rate, Pseq([1,2]*TempoClock.tempo, inf),
				\amp, 0.4
			),
			// maracas 16th
			Pbind(
				\instrument, \sampler,
				\bufnum, ~percBuffers[2],
				\rate, TempoClock.tempo,
				\dur, Pseq([4],inf),
				\amp, 1
			),
			// tiroir
			Pbind(
				\instrument, \sampler,
				\dur, Pseq([4], inf),
				\rate, TempoClock.tempo,
				\bufnum, ~percBuffers[4],
				\amp, 1
			),
			Pbind(\instrument, \wind,
				\amp, 0.5,
				\rel, TempoClock.tempo*2,
				\dur, Pseq([2, 2], inf),
				\freq, Pseq([70, 80], inf).midicps,
			),
			// box
			Pbind(
				\instrument, \sampler,
				\bufnum, ~percBuffers[0],
				\dur, Pseq([Rest(1), 1], inf),
				\rate, TempoClock.tempo,
				\amp, 0.5
			),
			Pbind(
				\instrument, "kick",
				\dur, Pseq([3/4, 1/4, Rest(1/2), 1, 1/2 , 1],inf),
				\amp, 1,
				\rel, 0.12,
				\glissf, 0.99
			),
			Pbind(
				\instrument, "snare",
				\dur, Pseq([Rest(3), 1], inf),
				\amp, 0.6,
				\rel, 0.2
			)
	]));

	Pdef(\perc_8,
		Ppar([
			// krakebs
			Pbind(
				\instrument, \sampler,
				\bufnum, ~percBuffers[1],
				\dur, Pseq([Pseq([1/4], 4), Pseq([1/8], 8), Pseq([1/4], 4), Pseq([1/12], 6), Pseq([1/24], 12)],inf),
				\rate, Pseq([1]*TempoClock.tempo, inf),
				\amp, 0.4
			),
			// maracas 16th
			Pbind(
				\instrument, \sampler,
				\bufnum, ~percBuffers[2],
				\rate, TempoClock.tempo,
				\dur, Pseq([4],inf),
				\amp, 1
			),
			// tiroir
			Pbind(
				\instrument, \sampler,
				\dur, Pseq([4], inf),
				\rate, TempoClock.tempo,
				\bufnum, ~percBuffers[4],
				\amp, 1
			),
			Pbind(\instrument, \wind,
				\amp, 0.5,
				\rel, TempoClock.tempo*2,
				\dur, Pseq([2, 2], inf),
				\freq, Pseq([70, 80], inf).midicps,
			),
			// box
			Pbind(
				\instrument, \sampler,
				\bufnum, ~percBuffers[0],
				\dur, Pseq([Rest(1), 1], inf),
				\rate, TempoClock.tempo,
				\amp, 0.5
			),
			Pbind(
				\instrument, "kick",
				\dur, Pseq([3/4, 1/4, Rest(1/2), 1, 1/2 , 1],inf),
				\amp, 1,
				\rel, 0.12,
				\glissf, 0.99
			),
			Pbind(
				\instrument, "snare",
				\dur, Pseq([Rest(3), 1], inf),
				\amp, 0.6,
				\rel, 0.2
			)
	]));


	Pdef(\perc_9,
		Ppar([
			// krakebs
			Pbind(
				\instrument, \sampler,
				\bufnum, ~percBuffers[1],
				\dur, Pseq([Pseq([1/8], 8)],inf),
				\rate, Pseq([1, 1, 2]*TempoClock.tempo, inf),
				\amp, 0.4
			),
			// maracas 16th
			Pbind(
				\instrument, \sampler,
				\bufnum, ~percBuffers[2],
				\rate, TempoClock.tempo,
				\dur, Pseq([4],inf),
				\amp, 1
			),
			// tiroir
			Pbind(
				\instrument, \sampler,
				\dur, Pseq([4], inf),
				\rate, TempoClock.tempo,
				\bufnum, ~percBuffers[4],
				\amp, 1
			),
			Pbind(\instrument, \wind,
				\amp, 0.7,
				\rel, TempoClock.tempo/8,
				\dur, Pseq([1/2, 1, Rest(0.5)], inf),
				\freq, Pseq([70, 80, 80], inf).midicps,
			),
			// box
			Pbind(
				\instrument, \sampler,
				\bufnum, ~percBuffers[0],
				\dur, Pseq([1/2], inf),
				\rate, TempoClock.tempo,
				\amp, 0.3
			),
			Pbind(
				\instrument, "kick",
				\dur, Pseq([3/4, 1/4, Rest(1/2), 1, 1/2 , 1],inf),
				\amp, 1,
				\rel, 0.12,
				\glissf, 0.99
			),
			Pbind(
				\instrument, "snare",
				\dur, Pseq([Rest(1), 1], inf),
				\amp, 0.6,
				\rel, 0.2
			)
	]));



	Pdef(\silent,
		Pbind(
			\dur, Pseq([1],1),
			\amp, 0,
	));


	// map patterns to fiducial indices
	// caution: use each key only once per dict
	~harmoPatterns= Dictionary.newFrom(List[
		\silent, -1,
		\harmo_1, 1,
		\harmo_2, 2,
		\harmo_3, 3,
		\harmo_4, 4,
	]);
	~leadPatterns= Dictionary.newFrom(List[
		\silent, -1,
		\lead_1, 11,
		\lead_2, 12,
		\lead_3, 13,
		\lead_4, 14,
		\lead_5, 15,
		\lead_6, 16,
		\lead_7, 17,
	]);
	~percPatterns= Dictionary.newFrom(List[
		\silent, -1,
		\perc_1, 21,
		\perc_2, 22,
		\perc_3, 23,
		\perc_4, 24,
		\perc_5, 25,
		\perc_6, 26,
		\perc_7, 27,
		\perc_8, 28,
		\perc_9, 29,
	]);



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

		"END".postln;
	});


	t.start;

});


/*
t.start;
t.pause;
t.resume;
t.reset;
t.stop;
*/