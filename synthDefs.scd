

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