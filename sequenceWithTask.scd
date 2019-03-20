s.latency=0.05
s.reboot
(
// The number of slots in the sequence
~slotCount = 6;

// The sequence to build. "-1" means no fiducial at the slot.
//~harmoSeq = (-1!~slotCount);
~harmoSeq = [1,2,3,4,3,2];
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
SynthDef(\bell, {
	|freq=1, t60=1, pitchy=1, amp=0.25, gate=1, out=0|
	var sig, exciter, bass, env;
	//exciter = Impulse.ar(0);
	env = EnvGen.ar(Env.perc(0.001, 0.05), gate);
	exciter = WhiteNoise.ar() * env * 0.25;
	sig = Klank.ar(
		`[
			[1, 2, 2.803, 3.871, 5.074, 7.81, 10.948, 14.421],   // freqs
			[1, 0.044, 0.891, 0.0891, 0.794, 0.1, 0.281, 0.079], // amplitudes
			[1, 0.205, 1, 0.196, 0.339, 0.047, 0.058, 0.047]*t60     // ring times
		],
		exciter,
		freqscale:freq*pitchy);
	bass = EnvGen.ar(Env.perc(0.001, 0.5), gate) * LFPar.ar(freq) ;
	sig = (sig + (bass / 1) ) * amp;

	DetectSilence.ar(sig, 0.001, 0.5, doneAction:2);
	Out.ar(out, sig!2);
}).add;


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
    snd = snd.tanh;
    Out.ar(out, Pan2.ar(snd, 0));
}).add;


/*Synth(\kick, [amp: 0.9]);*/


// from https://sccode.org/1-522
SynthDef(\rhodes, {
	|
	// standard meanings
	out = 0, freq = 440, gate = 1, pan = 0, amp = 0.1,
	// all of these range from 0 to 1
	vel = 0.8, modIndex = 0.2, mix = 0.2, lfoSpeed = 0.4, lfoDepth = 0.0
	|
	var env1, env2, env3, env4;
	var osc1, osc2, osc3, osc4, snd;

	lfoSpeed = lfoSpeed * 12;

	freq = freq * 2;

	env1 = EnvGen.ar(Env.adsr(0.001, 1.25, 0.0, 0.04, curve: \lin));
	env2 = EnvGen.ar(Env.adsr(0.001, 1.00, 0.0, 0.04, curve: \lin));
	env3 = EnvGen.ar(Env.adsr(0.001, 1.50, 0.0, 0.04, curve: \lin));
	env4 = EnvGen.ar(Env.adsr(0.001, 1.50, 0.0, 0.04, curve: \lin));

	osc4 = SinOsc.ar(freq * 0.5) * 2pi * 2 * 0.535887 * modIndex * env4 * vel;
	osc3 = SinOsc.ar(freq, osc4) * env3 * vel;
	osc2 = SinOsc.ar(freq * 15) * 2pi * 0.108819 * env2 * vel;
	osc1 = SinOsc.ar(freq, osc2) * env1 * vel;
	snd = Mix((osc3 * (1 - mix)) + (osc1 * mix));
	snd = snd * (SinOsc.ar(lfoSpeed) * lfoDepth + 1);

	// using the doneAction: 2 on the other envs can create clicks (bc of the linear curve maybe?)
	snd = snd * EnvGen.ar(Env.asr(0, 1, 0.1), gate, doneAction: 2);
	snd = Pan2.ar(snd, pan, amp);

	Out.ar(out, snd);
}).add;



/////////////////// GLOBAL MUSIC PARAMETERS

~trackDuration = 20; // measured in seconds
~beatPerSlot = 4;
~beatDuration = ~trackDuration / (~slotCount * ~beatPerSlot); // in seconds
~bpm  = 60 / ~beatDuration;
TempoClock.tempo = ~bpm/60;
~beatPerSlot = 4;
~scale = Scale.chromatic;



/////////////////// PATTERNS FOR EACH STEP
Pdef(\bell_1,
	Pbind(
		\instrument, \bell,
		\dur, 1,
		\degree, Pseq( [1], inf),
		\octave, 4,
		\scale, ~scale,
		\t60, 0.9,
		\pitchy, 3,
		\amp, 0.07,
		\out, 0 ,
));



/////// 2

Pdef(\bell_2,
	Pbind(
		\instrument, \bell,
		\dur, 1/2,
		\degree, Pseq( [1, 5,  8, 13 ], inf),
		\octave, 4,
		\scale, ~scale,
		\t60, 0.9,
		\pitchy, 3,
		\amp, 0.07,
		\out, 0 ,
));

////// 3

Pdef(\bell_3,
	Pbind(
		\instrument, \bell,
		\dur, 1/4,
		\degree, Pseq( [[1, 5,  8], [1,  8, 13] ], inf),
		\octave, 4,
		\scale, ~scale,
		\t60, 0.9,
		\pitchy, 3,
		\amp, 0.07,
		\out, 0 ,
));


////// 4

Pdef(\bell_4,
	Pbind(
		\instrument, \bell,
		\dur, Pseq([ 1]/8, inf),
		\degree, Pseq( [[1, 5,  8], 1, [1,  8, 13], 8 ], inf),
		\octave, 4,
		\scale, ~scale,
		\t60, 2,
		\pitchy, 3,
		\amp, 0.07,
		\out, 0 ,
));




Pdef(\silent,
	Pbind(
		\dur, Pseq([1],1),
		\amp, 0,
));



// caution: use each key only once
~harmoPatterns= Dictionary.newFrom(List[
	\silent, -1,
	\bell_1, 1,
	\bell_2, 2,
	\bell_3, 3,
	\bell_4, 4,
]);



//////////////////////////// SEQUENCER
~prev = 0;
t = Task({

	var step = 0;

	///////
	"step 1".postln;
	~harmoSeq.postln;
	Pdef(~harmoPatterns.findKeyForValue(~harmoSeq[step])).play(quant:0);
	~prev = ~harmoSeq[step];
	~beatPerSlot.wait;
	Pdef((~harmoPatterns.findKeyForValue(~prev)).asSymbol).stop;

	///////
	step = 1;
	"step 2".postln;
	~harmoSeq.postln;
	Pdef(~harmoPatterns.findKeyForValue(~harmoSeq[step])).play(quant:0);
	~prev = ~harmoSeq[step];
	~beatPerSlot.wait;
	Pdef((~harmoPatterns.findKeyForValue(~prev)).asSymbol).stop;


	///////
	step = 2;
	"step 3".postln;
	~harmoSeq.postln;
	Pdef(~harmoPatterns.findKeyForValue(~harmoSeq[step])).play(quant:0);
	~prev = ~harmoSeq[step];
	~beatPerSlot.wait;
	Pdef((~harmoPatterns.findKeyForValue(~prev)).asSymbol).stop;

	///////
	step = 3;
	"step 4".postln;
	~harmoSeq.postln;
	Pdef(~harmoPatterns.findKeyForValue(~harmoSeq[step])).play(quant:0);
	~prev = ~harmoSeq[step];
	~beatPerSlot.wait;
	Pdef((~harmoPatterns.findKeyForValue(~prev)).asSymbol).stop;

	///////
	step = 4;
	"step 5".postln;
	~harmoSeq.postln;
	Pdef(~harmoPatterns.findKeyForValue(~harmoSeq[step])).play(quant:0);
	~prev = ~harmoSeq[step];
	~beatPerSlot.wait;
	Pdef((~harmoPatterns.findKeyForValue(~prev)).asSymbol).stop;

	///////
	step = 5;
	"step 6".postln;
	~harmoSeq.postln;
	Pdef(~harmoPatterns.findKeyForValue(~harmoSeq[step])).play(quant:0);
	~prev = ~harmoSeq[step];
	~beatPerSlot.wait;
	Pdef((~harmoPatterns.findKeyForValue(~prev)).asSymbol).stop;

	"END".postln;
});

MIDIClient.init;
MIDIIn.connectAll;
MIDIdef.noteOn(\test4, {arg ...args;
	args.postln;

	t.start;
}); // match any noteOn

)

t.start;
t.pause;
t.resume;
t.reset;
t.stop;