(
//Hiphop
//Enjoyment
Pdef(\dance1, Pbind(
	\totalDur, Pdefn(\totalDur, 30),
	\progress, Pwhite(
		Pseg([1, 1, 0], 	Pseq([0.3, 0.7]) * Pkey(\totalDur)),
		Pseg([1, 1, 0.4], 	Pseq([0.2, 0.8]) * Pkey(\totalDur))
	),
    \amp, 1,
	\instrument, \bufPlayerWarp,
    // \startPos, Pseg([0, 1, 0], 5, repeats:inf),
    \startPos, Pseg([0, 1], Prand([0.75, 0.5, 1.5, 0.125], inf), repeats:inf),
    \startPos, Prand([0.0, 0.35], inf),
	    // \startPos, 0.2,
	\clump, Prout({ |ev|
		var e = Env([1, 2, 3, 4, 6, 8, 12, 16, 24, 32, 48, 64], (1!12).normalizeSum, [8, 0]);
		loop {
			ev = e.at(ev.progress).yield
		}
	}.inEnvir),
	\rq, 1,
	\ffreq, Pexprand(Pkey(\progress).linexp(0, 1, 8000, 400), 10000),
    //\freqshift, [0, -50, 100, -2000],
   // \amp, Pkey(\clump).reciprocal * p{ var x=0; loop { x = (x * 0.8) + (q.buses.ampBus.getSynchronous * 20); x.yield; }  } ,
	\amp, 0.5,
// \bufnum, ~buffers[0],
	\bufrate, Pfunc { |ev| 1 ! ev.clump },
	\hpfreq, Pkey(\progress).linexp(0, 1, 100, 800),
	\rate, Pif(Pfunc { 0.1.coin }, Pwhite(1.0, 4), 1), //pitch
	// \rate, 1,
    // \bufrate, 1,
	\dur, Pseq([
		Pn(Plazy { Pshuf([0.5, 0.25, 0.5, 0.25, 0.75, 0.25]) }, 8),
		Pn(0.25, 32),
	], inf),
	\sustain, Pkey(\progress).linexp(0, 1, 0.4, 2) / Pkey(\clump),
	\strum, Pfunc { |ev| ev.dur / ev.clump },
	\pan, Prand([-0.75, -0.25, 0.25, 0.75], inf),
    \latency, [nil]
	// \dur, Pkey(\amp).linlin(0, 0.5, 0.4, 0.05),
    // \dur, 1,
)
<> Plazy { q.buffers.rand(\peter) }
<> Pbind(\server, q.servers.asPattern)
);
);
(
Pdef(\dance2, { |dur=30|
	Pbind(
		// \progress, Plazy({ ~progress }.inEnvir),
		\amp, 1,
		\instrument, \bufPlayerWarp,
		// \startPos, Pseg([0, 1, 0], 5, repeats:inf),
		\startPos, Pseq([0.0, 0.33], inf),
		// \startPos, Pbrown(0.33, 0.37) * Pkey(\peter),
		// \startPos, 0.2,
		\rq, 0.1,
		\ffreq, Pseq([3200, 12000], inf) * Pwhite(0.9, 1.1),
		\hpfreq, 100,
		//\freqshift, [0, -50, 100, -2000],
		// \amp, Pkey(\clump).reciprocal * p{ var x=0; loop { x = (x * 0.8) + (q.buses.ampBus.getSynchronous * 20); x.yield; }  } ,
		// \bufnum, ~buffers[0],
		\bufrate, 1,
		\rate, Pif(Pfunc { 0.1.coin }, Pwhite(1.0, 4), 1), //pitch
		\dur, 0.5,
		\clump, Pwrand([1, 2], [0.1, 0.9], inf),
		\sustain, Pfunc { |ev| 0.1.dup(ev.clump) },
		\amp, Pfunc { |ev| Array.geom(ev.clump, 1, 0.67) },
		\strum, Pkey(\dur) * 1.5,
		\pan, Prand([-0.75, -0.25, 0.25, 0.75], inf),
		// \dur, Pkey(\amp).linlin(0, 0.5, 0.4, 0.05),
		// \dur, 1,
        \latency, [nil]
	)
	<> Plazy { q.buffers.seq(\peter) }
	<> Pbind(\server, q.servers.asPattern)
});

);

(
//SMall is this it
Pdef(\dance3, Pbind(
	// \progress, Plazy({ ~progress }.inEnvir),
	\totalDur, Pdefn(\totalDur, 30),
	\progress, Plprand(0, 1) * Pseg([0.01, 1], Pkey(\totalDur)),
    \amp, 2,
	\instrument, \bufPlayerWarp,
    // \startPos, Pseg([0, 1, 0], 5, repeats:inf),
	\startPos, Pseq([0, 0.34, 0, 0.34], inf),
	// \startPos, Pbrown(0.33, 0.37) * Pkey(\peter),
	    // \startPos, 0.2,
	\rq, 1,
	\ffreq, 10000,
	\hpfreq, 100,
    \bufrate, 1,
	\rate, Pseg([0.03, 1, 0.03], [6,2], Pseq([Pwhite(2,4), Pwhite(-4, -2)]), inf) ,
	\dur, Pn(Plazy { Pshuf([[0.5], [0.25, 0.25], [0.5], [0.27, 0.23]]) }, inf).flatten * 0.5,
	\lag, Pwhite(-0.05, 0.05) * Pkey(\progress),
	\sustain, Pkey(\progress).linexp(0, 1, 0.01, 0.4),
    \latency, [nil]
	// \sustain, Pseq([0.01, 0.03], inf) * Pwhite(0.999, 1.001)
	// \dur, Pkey(\amp).linlin(0, 0.5, 0.4, 0.05),
    // \dur, 1,
)
<> Plazy { q.buffers.seq(\peter) }
<> Pbind(\server, q.servers.asPattern)
)
);

(
//Drone for box
//needs server
Pdef(\droneyFM, Pbind(
	\instrument, \droneyFMLight,
	\octave, 3,
	\ctranspose, 3,
	\degree, Pwhite(0,7),
	\scale, Scale.minorPentatonic,
	\dur, Pwhite(10, 20),
	\atk, Pwhite(2, 8.0),
	\release, Pwhite(5, 10.0),
	\legato, 1
))
);
(
//drone for zero clients
//Needs servers -- outputs on 1 by default because of
//pi zero weirdness
Pdef(\droneyFM_zero, Pbind(
	\instrument, \droneyFMLight,
	\server, Plazy({ q.servers.seq({ |server|
		#[rpi3, localhost].includes(server.name) }) }),
	\latency, [nil],
	\octave, Pwrand([4, 5], [0.1, 0.9], inf),
	\ctranspose, -2,
	\degree, Pwhite(0,7),
	\scale, Scale.minorPentatonic,
	\dur, Pwhite(5, 10),
	\atk, 0,
	\release, Pwhite(5, 10.0),
	\legato, 1,
	\out, 1
));
);


(
//Peter samples for drone 2
Pdef(\peterScattered, (Pbind(
    \latency, [nil],
	\instrument, \bufPlayer,
	\totalDur, Pdefn(\totalDur, 30),
	\dur, Pbrown(1.0, 5) * Pseg([1, 0.1, 0.3], Pkey(\totalDur) / 2),
	\sustain, 0.5,
	\amp, 1
) <> Plazy { q.buffers.seq(\peter) }
<> Plazy { Pbind(\server, q.servers.asPattern) }
).trace)
)
