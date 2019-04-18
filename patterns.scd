Pdef(\silent,
	Pbind(
		\dur, Pseq([1],1),
		\amp, 0,
));

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

