/*
Language based n x n step sequencer.

Without a UI it's easy to create and transform arbitrary matrixes.
You can also map x/x coordinates to whatever you wish.
*/

(
// Factory method for creating loopr object
~createLoopr = {arg dur;

	var obj = (

		grid: [],

		dur: 1,

		setDur: {arg self, dur;
			self.dur = dur;
			self.seq = self.dur.asStream;
		},

		getDur: {arg self;
			self.dur;
		},

		seq: 1.asStream,

		func: {},

		player: {arg self;

			var me = self;

			var pattern = Pspawner({arg sp;
				inf.do({arg i;
					var time = me.seq.next;
					var evt = me.process(i.asInt, time);
					sp.par(evt);
					sp.wait(time);
				});
			});

			EventPatternProxy.new(pattern);
		},

		process: {arg self, count, time;

			var me = self;

			Plazy({

				var rows = me.grid;
				var evts = rows.collect({arg item, row;

					var val;
					var event;
					var x = (count % item.size).asInt;
					val = item.wrapAt(count).value;

					event = (isRest:true);
					if (val > 0) {
						var myEvent = me.func(x, row, val, time, count);
						if (myEvent.isKindOf(Event) or: myEvent.isKindOf(Pattern)) {
							event = myEvent;
						};
					};

					Pn(event, 1);
				});

				Ppar(evts);
			});
		}
	);

	obj.setDur(dur);
	obj;
};
)

// Create a synth to play
(
SynthDef(\blip, {arg freq, time = 1, out = 0;
	var rel = TRand.kr(0.1,4,1);
	var sig = SinOsc.ar(freq*[0.9,0.99,1,1.01,1.1], mul:[0.05,0.2,1,0.2,0.05]).mean;
	var env = EnvGen.ar(Env.perc(1e-4,rel,0.75), 1, timeScale:time, doneAction:2);
	sig = Splay.ar(sig) * env * \amp.kr(0.1) * AmpCompA.kr(freq);
	Out.ar(out, sig);
}).add;
)

// Grid values greater than zero will invoke the func handler in order to do something.
// You can map the x, y coordinates however you wish.
// Plus the value at each point can be used for additional parameterization.
(~grid = [
	[7 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0],
	[0 , 6 , 0 , 0 , 0 , 0 , 0 , 0 , 4 , 0 , 0 , 0 , 0 , 0 , 0 , 0],
	[0 , 0 , 5 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0],
	[0 , 0 , 0 , 4 , 0 , 0 , 0 , 0 , 5 , 5 , 5 , 5 , 0 , 0 , 0 , 0],
	[0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 6 , 0 , 0 , 0],
	[0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 6 , 0 , 0 , 0 , 0 , 7 , 0 , 0],
	// can handle asymetrical arrays
	[0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0, 5],
	[6 , {[5,6].choose}, 4 , 0]
]);

// Create a new instance specifying the initial dur value
~loopr1 = ~createLoopr.value(0.25);
// Set the grid.
~loopr1.grid = ~grid;

// Set up the handler.
// This is the function that will be called
// for each non zero point in the grid.
// Return an Event or Pattern to be played.
(
var fx = NodeProxy.new(s, \audio, 2);
fx[1] = \filter -> {arg in; GVerb.ar(in, 100); };
fx.play;

~loopr1.func = {arg self, x, y, val, time;

	// the value of each point maps to an octave
	// time is the event duration, i.e. the dur value
	(instrument: \blip,
		\amp: 0.5,
		\degree: y,
		\octave: val,
		\scale: Scale.ritusen,
		\time: time,
		\group: fx.group,
		\out: fx.bus
	);
}
);

//Play the sequencer
~loopr1.player.play(quant:1.0);

// Apply transformations to the grid
~loopr1.grid = ~grid.reverse;
~loopr1.grid = ~grid.flop;
~loopr1.grid = ~grid.stutter;
~loopr1.grid = ~grid.mirror;
~loopr1.grid = ~grid;

// You can change the rhythm duration to a pattern
(
~loopr1.setDur(
	Pseg(
		Pwhite().linexp(0, 1, 1/32, 1),
		Pbrown(0,1,0.05).linexp(0, 1, 1/8, 8),
		\sin
	)
)
)

// Reset
~loopr1.setDur(0.25);