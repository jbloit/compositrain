(
~bus = Bus.audio(s,2);

SynthDef(\reverb_ef, {
	arg		amp=1, lPos=0, mix=0.085, revTime=1.8, preDel=0.1, in, out;
	var		sig, verbSig, totalSig, outSig;

	//no wacky values please
	mix = mix.clip(0,1);

	sig = In.ar(in, 2);

	//pre-delay
	verbSig = DelayN.ar(sig, preDel, preDel);

	totalSig = 0;
	12.do{
		verbSig = AllpassN.ar(verbSig, 0.06, {Rand(0.001,0.06)}!2, revTime);
		verbSig = LPF.ar(verbSig, 4500);
		totalSig = totalSig + verbSig;
	};

	//dry/wet mix
	totalSig = XFade2.ar(sig, totalSig, mix.linlin(0,1,-1,1));

	outSig = totalSig * amp;
	Out.ar(out, outSig);
}).add;


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


SynthDef("sillyVoice", { arg
	freq = 220,
	amp = 0.5,
	vibratoSpeed = 6,
	vibratoDepth = 4,
	vowel = 0,
	att = 0.01,
	rel = 0.1,
	lag = 1,
	gate = 1,
	out = 0
	;

	var in, vibrato, env, va, ve, vi, vo, vu, snd;

	vibrato = SinOsc.kr(vibratoSpeed, mul: vibratoDepth);
	in = Saw.ar(Lag.kr(freq, lag) + vibrato);
	env = EnvGen.kr(Env.asr(att, 1, rel), gate, doneAction: 2);

	va = BBandPass.ar(
		in: in,
		freq: [ 600, 1040, 2250, 2450, 2750 ],
		bw: [ 0.1, 0.067307692307692, 0.048888888888889, 0.048979591836735, 0.047272727272727 ],
		mul: [ 1, 0.44668359215096, 0.35481338923358, 0.35481338923358, 0.1 ]);

	ve = BBandPass.ar(
		in: in,
		freq: [ 400, 1620, 2400, 2800, 3100 ] ,
		bw: [ 0.1, 0.049382716049383, 0.041666666666667, 0.042857142857143, 0.038709677419355 ],
		mul: [ 1, 0.25118864315096, 0.35481338923358, 0.25118864315096, 0.12589254117942 ]);

	vi = BBandPass.ar(
		in: in,
		freq: [ 250, 1750, 2600, 3050, 3340 ] ,
		bw: [ 0.24, 0.051428571428571, 0.038461538461538, 0.039344262295082, 0.035928143712575 ],
		mul: [ 1, 0.031622776601684, 0.15848931924611, 0.079432823472428, 0.03981071705535 ] );

	vo = BBandPass.ar(
		in: in,
		freq:[ 400, 750, 2400, 2600, 2900 ] ,
		bw: [ 0.1, 0.10666666666667, 0.041666666666667, 0.046153846153846, 0.041379310344828 ],
		mul: [ 1, 0.28183829312645, 0.089125093813375, 0.1, 0.01 ]);

	vu = BBandPass.ar(
		in: in,
		freq: [ 350, 600, 2400, 2675, 2950 ],
		bw: [ 0.11428571428571, 0.13333333333333, 0.041666666666667, 0.044859813084112, 0.040677966101695 ],
		mul: [ 1, 0.1, 0.025118864315096, 0.03981071705535, 0.015848931924611 ]);

	snd = SelectX.ar(Lag.kr(vowel, lag), [va, ve, vi, vo, vu]);
	snd = Mix.new(snd);
	Out.ar(out, snd!2 * env * amp);
}).add;



// Originally found at http://ecmc.rochester.edu/ecmc/docs/supercollider/scbook/Ch21_Interface_Investigations/ixi%20SC%20tutorial/ixi_SC_tutorial_10.html

SynthDef("flute", { arg scl = 0.2, freq = 440, ipress = 0.9, ibreath = 0.09, ifeedbk1 = 0.4, ifeedbk2 = 0.4, dur = 1, gate = 1, amp = 2, out=0;

	var kenv1, kenv2, kenvibr, kvibr, sr, cr, block;
	var poly, signalOut, ifqc;
	var aflow1, asum1, asum2, afqc, atemp1, ax, apoly, asum3, avalue, atemp2, aflute1;
	var fdbckArray;

	sr = SampleRate.ir;
	cr = ControlRate.ir;
	block = cr.reciprocal;

	ifqc = freq;

	// noise envelope
	kenv1 = EnvGen.kr(Env.new(
		[ 0.0, 1.1 * ipress, ipress, ipress, 0.0 ], [ 0.06, 0.2, dur - 0.46, 0.2 ], 'linear' )
	);
	// overall envelope
	kenv2 = EnvGen.kr(Env.new(
		[ 0.0, amp, amp, 0.0 ], [ 0.1, dur - 0.02, 0.1 ], 'linear' ), doneAction: 2
	);
	// vibrato envelope
	kenvibr = EnvGen.kr(Env.new( [ 0.0, 0.0, 1, 1, 0.0 ], [ 0.5, 0.5, dur - 1.5, 0.5 ], 'linear') );

	// create air flow and vibrato
	aflow1 = LFClipNoise.ar( sr, kenv1 );
	kvibr = SinOsc.ar( 5, 0, 0.1 * kenvibr );

	asum1 = ( ibreath * aflow1 ) + kenv1 + kvibr;
	afqc = ifqc.reciprocal - ( asum1/20000 ) - ( 9/sr ) + ( ifqc/12000000 ) - block;

	fdbckArray = LocalIn.ar( 1 );

	aflute1 = fdbckArray;
	asum2 = asum1 + ( aflute1 * ifeedbk1 );

	//ax = DelayL.ar( asum2, ifqc.reciprocal * 0.5, afqc * 0.5 );
	ax = DelayC.ar( asum2, ifqc.reciprocal - block * 0.5, afqc * 0.5 - ( asum1/ifqc/cr ) + 0.001 );

	apoly = ax - ( ax.cubed );
	asum3 = apoly + ( aflute1 * ifeedbk2 );
	avalue = LPF.ar( asum3, 2000 );

	aflute1 = DelayC.ar( avalue, ifqc.reciprocal - block, afqc );

	fdbckArray = [ aflute1 ];

	LocalOut.ar( fdbckArray );

	signalOut = avalue;

	OffsetOut.ar( out, (signalOut * kenv2)!2 );

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


)

(
//////////////////////// START REVERB
Synth(\reverb_ef, [\in, ~bus, \out, 0, \revTime, 1.8]);

)


(
TempoClock.tempo = 50/60;

~scale = Scale.chromatic;
~claves  = [
	[4, 4, 4, 4],
	[3, 3, 3, 3, 4],
	[3, 3, 2, 3, 3, 2],
	[2, 2, 3, 2, 2, 3, 2],
	[2, 2, 2, 2, 2, 2, 2, 2],
	[2, 2, 2, 1, 2, 2, 2, 1, 2],
	[2, 1, 2, 1, 2, 2, 1, 2, 1, 2],
	[1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1],
	[1, 1, 2, 1, 1, 2, 1, 1, 2, 1, 1, 2],
	[1, 1, 1, 2, 1, 1, 1, 2, 1, 1, 1, 2, 1],
	[1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2],
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2],
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
];

Pdef(\bell,
	Pbind(
		\instrument, \bell,
		\dur, 1/8,
		\degree, Pseq( [1, 5,  8], inf),
		\octave, 4,
		\scale, ~scale,
		\t60, 0.9,
		\pitchy, 3,
		\amp, 0.07,
		\out, 0 ,
)).play(quant:1);

)


///////////////////////////////// BELL PATTERNS


/////// 1
(
Pdef(\bell,
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
)).play(quant:1);
)


/////// 2
(
Pdef(\bell,
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
)).play(quant:1);
)


////// 3
(
Pdef(\bell,
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
)).play(quant:1);
)

////// 4
(
Pdef(\bell,
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
)).play(quant:1);
)



Pdef(\bell).stop;


//////// + TARD
(
Pdef(\bell,
	Pbind(
		\instrument, \bell,
		\dur, Pseq([1]/8, inf),
		\degree, Pseq( [[1, 5,  8], [1,  8, 12] ], inf),
		\octave, 4,
		\scale, ~scale,
		\t60, 0.9,
		\pitchy, 2,
		\amp, 0.07 * Pseq((1..8)/8, inf),
		\out, 0 ,
)).play(quant:1);
)


(
Pdef(\bell,
	Pbind(
		\instrument, \bell,
		\dur, 1/2,
		\degree, Pseq( [[1, 5,  8]], inf),
		\octave, 4,
		\scale, ~scale,
		\t60, 1,
		\pitchy, 3,
		\amp, 0.08,
		\out, 0,
)).play(quant:1);
)


(
Pdef(\bell,
	Pbind(
		\instrument, \bell,
		\dur, Pseq(~claves[5]/8, inf),
		\degree, Pseq( [[1, 5,  8], 1], inf),
		\octave, 4,
		\scale, ~scale,
		\t60, 1,
		\pitchy, 3,
		\amp, 0.1,
		\out, 0,
)).play(quant:1);
)
(
Pdef(\bell,
	Pbind(
		\instrument, \bell,
		\dur, Pseq(~claves[9]/8, inf),
		\degree, Pseq( [[1, 5,  8], 1], inf),
		\octave, 4,
		\scale, ~scale,
		\t60, 1,
		\pitchy, 3,
		\amp, 0.07,
		\out, 0,
)).play(quant:1);
)

///////////////////////////////// VOX + FLUTE PATTERNS


/////// 1
(
Pdef(\vox,
	PmonoArtic(\sillyVoice,
		\dur, Pseq([1/2, Rest(1/2)], inf),
		\degree, Pseq( [1], inf),
		\octave, 4,
		\scale, ~scale,

		\legato, 0.99,

		\vowel, Pseq([3,4], inf),
		\vibratoDepth, Prand((1..2), inf),
		\amp, 1,
		\out, 0,
)).play(quant:1);

)


/////// 2
(
Pdef(\vox,
	PmonoArtic(\sillyVoice,
		\dur, 1/2,
		\degree, Pseq( [1, 5,  8, 13 ], inf),
		\octave, 4,
		\scale, ~scale,

		\legato, 0.99,

		\vowel, Pseq([3,4], inf),
		\vibratoDepth, Prand((1..2), inf),
		\amp, 1,
		\out, 0,
)).play(quant:1);

)


/////// 3
(
Pdef(\vox,
	Pbind(\instrument, \sillyVoice,
		\dur, 1/4,
		\degree, Pseq( [[1, 5,  8], [1,  8, 13] ], inf),
		\octave, 4,
		\scale, ~scale,

		\legato, 0.99,

		\vowel, Pseq([3,4], inf),
		\vibratoDepth, Prand((1..2), inf),
		\amp, 1,
		\out, 0,
)).play(quant:1);

)


/////// 4
(
Pdef(\vox,
	Pbind(\instrument, \sillyVoice,
		\dur, Pseq([ 1]/8, inf),
		\degree, Pseq( [[1, 5,  8], 1, [1,  8, 13], 8 ], inf),
		\octave, 4,
		\scale, ~scale,
		\legato, 0.99,
		\vowel, Pseq([2], inf),
		\vibratoDepth, Prand((1..2), inf),
		\amp, 1,
		\out, 0,
)).play(quant:1);

)


Pdef(\vox).stop;

///////////// +TARD

(
Pdef(\vox,
	PmonoArtic(\sillyVoice,
		\dur, 1/4,
		\legato, 0.99,
		\degree, Pseq( [1, 4,  4], inf),
		\octave, 3,
		\scale, ~scale,
		\vowel, Pseq([3,4], inf),
		\vibratoDepth, Prand((1..2), inf),
		\amp, 3,
		\out, 0,
)).play(quant:1);
)


(
Pdef(\vox,
	PmonoArtic(\sillyVoice,
		\dur, 1/4,
		\legato, 0.99,
		\degree, Pseq( [1, 5, 5], inf),
		\octave, 3,
		\scale, ~scale,
		\vowel, Pseq([3,4], inf),
		\vibratoDepth, Prand((1..2), inf),
		\amp, 4,
		\out, 0,
)).play(quant:1);
)


(
Pdef(\vox,
	PmonoArtic(\sillyVoice,
		\dur, 1/2,
		\legato, 0.99,
		\degree, Pseq( [1, 5, 5], inf),
		\octave, 4,
		\scale, ~scale,
		\vowel, Pseq([1,3], inf),
		\vibratoDepth, Prand((1..2), inf),
		\amp, 4,
		\out, 0,
)).play(quant:1);
)

(
Pdef(\vox,
	PmonoArtic(\sillyVoice,
		\dur, 1/2,
		\legato, 1,
		\degree, Pseq( [1, 3, 6], inf),
		\octave, 4,
		\scale, ~scale,
		\vowel, Pseq([1,3], inf),
		\vibratoDepth, Prand((1..4), inf),
		\amp, 4,
		\out, 0,
)).play(quant:1);
)


(
Pdef(\vox,
	Pbind(\instrument, \sillyVoice,
		\dur, Pseq([1/2, 1/8, Rest(1/2)],inf),
		\legato, 1,
		\degree, Pseq( [[1, 5, 8], 1], inf),
		\octave, 4,
		\scale, ~scale,
		\vowel, Pseq([[4,1], [1]], inf),
		\vibratoDepth, Prand((1..4), inf),
		\amp, 4,
		\out, 0,
)).play(quant:1);
)

Pdef(\vox).stop

(
Pdef(\flute,
	Pbind(\instrument, \flute,
		\dur, Pseq([1/2, 1/4], inf),
		\degree, Pseq( [[1, 5, 40], 1], inf),
		\octave, 4,
		\scale, ~scale,
		\amp, 0.2,
		\out, 0,
)).play(quant:1);
)

(
Pdef(\flute,
	Pbind(\instrument, \flute,
		\dur, 1/2,
		\degree, Pseq( [[1, 8], 1], inf),
		\octave, 4,
		\scale, ~scale,
		\amp, 0.2,
		\out, 0,
)).play(quant:1);
)

(
Pdef(\flute,
	Pbind(\instrument, \flute,
		\dur, 1/8,
		\degree, Pseq( (1..8), inf),
		\octave, 4,
		\scale, ~scale,
		\amp, Pseq((1..8)/20, inf),
		\out, 0,
)).play(quant:1);
)

Pdef(\flute).stop;



//////////////////////////////// PERC


///////////// 1
(
Pdef(\drums,
	Ppar([
		Pbind(
			\instrument, "hat",
			\dur, Pseq([Rest(1/4), 1/4], inf),
			\ffreq, 9000,
			\rel, 0.1,
			\amp, 0.4,
		),
		Pbind(\instrument, \wind,
			\amp, 0.3,
			\dur, Pseq([Rest(1/4), 1/4], inf),
			\freq, Pseq([70], inf).midicps
		);
])).play(quant:1);
)


///////////// 2
(
Pdef(\drums,
	Ppar([
		Pbind(
			\instrument, "hat",
			\dur, Pseq([Rest(1/4), 1/4], inf),
			\ffreq, 9000,
			\rel, 0.1,
			\amp, 0.4,
		),
			Pbind(
			\instrument, "kick",
			\dur, Pseq([1/4, Rest(3/4)],inf),
			\amp, 1,
			\rel, 0.12,
			\glissf, 0.99
		),
		Pbind(
			\instrument, "snare",
			\dur, Pseq([Rest(1/2)], inf),
			\amp, 0.25,
			\rel, 0.1
		),
		Pbind(\instrument, \wind,
			\amp, 0.3,
			\dur, Pseq([Rest(1/4), 1/4], inf),
			\freq, Pseq([70], inf).midicps
		);
])).play(quant:1);
)

///////////// 3
(
Pdef(\drums,
	Ppar([
		Pbind(
			\instrument, "hat",
			\dur, Pseq([Rest(1/4), 1/4], inf),
			\ffreq, 9000,
			\rel, 0.1,
			\amp, 0.4,
		),
			Pbind(
			\instrument, "kick",
			\dur, Pseq([1/8, 1/4, 1/8, 1],inf),
			\amp, 1,
			\rel, 0.12,
			\glissf, 0.99
		),
		Pbind(
			\instrument, "snare",
			\dur, Pseq([Rest(1), 2], inf),
			\amp, 0.3,
			\rel, 0.1
		),
		Pbind(\instrument, \wind,
			\amp, 0.3,
			\dur, Pseq([Rest(1/4), 1/4], inf),
			\freq, Pseq([80, 70], inf).midicps,
		);
])).play(quant:1);
)



///////////// 4
(
Pdef(\drums,
	Ppar([
		Pbind(
			\instrument, "hat",
			\dur, Pseq([1/8], inf),
			\ffreq, Pseq([11000, 9000, 8000],inf),
			\rel, 0.1,
			\amp, Pseq([0.5, 0.3],inf),
		),
			Pbind(
			\instrument, "kick",
			\dur, Pseq([1/8, 1/4, 1/8, 1],inf),
			\amp, 1,
			\rel, 0.12,
			\glissf, 0.99
		),
		Pbind(
			\instrument, "snare",
			\dur, Pseq([1/2], inf),
			\amp, 0.25,
			\rel, 0.1
		),
		Pbind(\instrument, \wind,
			\amp, 0.3,
			\dur, Pseq([1/4, 1/8], inf),
			\freq, Pseq([70, 80, 90], inf).midicps,
		);
])).play(quant:1);
)

Pdef(\drums).stop

(
Pdef(\drums,
	Ppar([
		Pbind(
			\instrument, "hat",
			\dur, Pseq([Rest(1/4), 1/4], inf),
			\ffreq, 9000,
			\rel, 0.1,
			\amp, 0.5
		),
		Pbind(
			\instrument, "kick",
			\dur, Pseq([1/8, 1/4, 1/8, 1],inf),
			\amp, 1,
			\rel, 0.12,
			\glissf, 0.99
		),
		Pbind(
			\instrument, "snare",
			\dur, Pseq([Rest(1/2)], inf),
			\amp, 0.25,
			\rel, 0.1
		)
])).play(quant:1);
)

Pdef(\bell).stop
Pdef(\drums).stop;


(
Pdef(\wind, Pbind(\instrument, \wind, \amp, 0.3,\dur, Pseq([1/4, 1/8], inf), \freq, Pseq([70, 80], inf).midicps)).play(quant:1);
)

(
Pdef(\wind, Pbind(\instrument, \wind, \amp, 0.3,\dur, Pseq([1/4, 1/8], inf), \freq, Pseq([70, 80, 90], inf).midicps)).play(quant:1);

)



~postOSC  = false;
~tempoFactor = 1;

TempoClock.tempo = ~tempoFactor;

~barCount = 9;
~trackCount = 3;
~score0 = Array.fill(~barCount, {|i| i % 2});
~score1 = Array.fill(~barCount, {|i| i % 4});
~score2 = Array.fill(~barCount, {|i| i % 3});

