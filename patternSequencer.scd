
// Create a synth to play
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


TempoClock.tempo = 50/60;

~scale = Scale.chromatic;
)

// Grid values greater than zero will invoke the func handler in order to do something.
// You can map the x, y coordinates however you wish.
// Plus the value at each point can be used for additional parameterization.
(~grid = [
	[1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0],
	[0 , 2 , 0 , 0 , 0 , 0 , 0 , 0 , 4 , 0 , 0 , 0 , 0 , 0 , 0 , 0],
	[0 , 0 , 1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0]
]);

(
~bellPatterns = Array.newClear(2);
/////// 1

~bellPatterns[0] =
Pbind(*[
	instrument: \bell,
	\dur: 1,
	\degree: Pseq( [1], 4),
	\octave: 4,
	\scale: ~scale,
	\t60: 0.9,
	\pitchy: 3,
	\amp: 0.07,
	\out, 0 ]
);



/////// 2

~bellPatterns[1] =
Pbind(*[
	instrument:\bell,
	\dur: 1/2,
	\degree: Pseq( [1, 5,  8, 13 ], 4),
	\octave: 4,
	\scale: ~scale,
	\t60: 0.9,
	\pitchy: 3,
	\amp: 0.07,
	\out: 0 ]
);
)

(
p = Pspawner({ | sp |


// scales in sequence with pauses
    sp.seq(
			~bellPatterns[0];
        );

    sp.seq(
			~bellPatterns[1];

    );

    sp.seq(
        Ppar([
            Pbind(*[ degree: Pseq((0..7).mirror), dur: 0.2, octave: 4]),
            Pbind(*[ degree: Pseq((0..7).reverse.mirror), dur: 0.2])
        ])

    );
    sp.wait(3);
    sp.seq(
        Pbind(*[ degree: Pseq((0..7).mirror), dur: 0.2, mtranspose: (0,2..14)])
    );

    sp.suspendAll;
});
p.play;
)


p.suspendAll




