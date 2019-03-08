s.latency=0.05
s.reboot
(
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

SynthDef("kick", {arg out = 0, amp = 0.3, sinfreq = 60, glissf = 0.9, att = 0.01, rel = 0.45, pan = 0;
	var gliss = XLine.kr(sinfreq, sinfreq*glissf, rel);
	var snd = SinOsc.ar(gliss);
	var env = EnvGen.kr(Env.perc(att, rel), doneAction: 2);
	snd = snd * env * amp;
	Out.ar(out, Pan2.ar(snd, pan));
}).add;


~bpm  = 90;
TempoClock.tempo = ~bpm/60;
~beatPerSlot = 4;


~scale = Scale.chromatic;
)

(

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

)

~seq = ([1, 2 , 3 , 4, 3, 2]);
~seq = ([1, 1 , 1 , 1, 1, 1]);
(


t = Task({


	///////
	"step 1".postln;
	Pdef((\bell_++~seq[0]).asSymbol).play(quant:0);
	~prev = ~seq[0];
	~beatPerSlot.wait;
	Pdef((\bell_++~prev).asSymbol).stop;

	///////
	"step 2".postln;
	Pdef((\bell_++~seq[1]).asSymbol).play(quant:0);
	~prev = ~seq[1];
	~beatPerSlot.wait;
	Pdef((\bell_++~prev).asSymbol).stop;

	///////
	"step 3".postln;
	Pdef((\bell_++~seq[2]).asSymbol).play(quant:0);
	~prev = ~seq[2];
	~beatPerSlot.wait;
	Pdef((\bell_++~prev).asSymbol).stop;

	///////
	Pdef((\bell_++~seq[3]).asSymbol).play(quant:0);
	~prev = ~seq[3];
	~beatPerSlot.wait;
	Pdef((\bell_++~prev).asSymbol).stop;

	///////
	"step 5".postln;
	Pdef((\bell_++~seq[4]).asSymbol).play(quant:0);
	~prev = ~seq[4];
	~beatPerSlot.wait;
	Pdef((\bell_++~prev).asSymbol).stop;

	///////
	"step 6".postln;
	Pdef((\bell_++~seq[5]).asSymbol).play(quant:0);
	~prev = ~seq[5];
	~beatPerSlot.wait;
	Pdef((\bell_++~prev).asSymbol).stop;

	"END".postln;
});
)


~seq = ([1, 2 , 3 , 4, 3, 2]);
~seq = ([1, 1 , 1 , 1, 1, 1]);

t.start;
t.pause;
t.resume;
t.reset;
t.stop;