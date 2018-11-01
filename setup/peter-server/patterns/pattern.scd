Pdef(\peterAmpWarp, Pbind(
    \latency, [nil],
    \instrument, \bufPlayerWarp,
    \startPos, Prand([0.0, 0.35], inf),
    \clump, 1,
    //\freqshift, [0, -50, 100, -2000],
    \amp, Pkey(\clump).reciprocal * p{ var x=0; loop { x = (x * 0.8) + (q.buses.ampBus.getSynchronous * 20); x.yield; }  } ,
    //\amp, 0.5,
    // \bufnum, ~buffers[0],
    \strum, 0.125,
    \bufrate, Pwhite(0.1, 2),
    \rate, Pwhite(0.5, 2), //pitch
    \rate, Phprand(0.8, 1),
    // \bufrate, 1,
    \dur, 0.5,
    \dur, Pkey(\amp).linlin(0, 0.5, 0.4, 0.05),
    // \dur, 1,
    \legato, Plprand(0.01, 0.8)
).trace
<> Plazy { q.buffers.rand(\peter) }
//TODO: Play on all servers except box
<> Plazy { Pbind(\server, q.servers.seq) }
);

(
Pdef(\intermission,
	Plazy({
		Pchain(
			Pbind(
				\instrument, \bufPlayerWarp,
				\dur, Pkey(\bufdur) * 0.5,
                \latency, [nil],
				\legato, 2,
				//set rate so we play entire file
				\rate, 1,//Pkey(\bufdur) / (Pkey(\dur) * Pkey(\legato)),
				\ffreq, 20000,
				\hpfreq, 80,
				\winsize, 1,
                \amp, 1,
			),
			Ppatlace([q.buffers.rand(\wovels, \pe), q.buffers.rand(\wovels, \ter)], inf),
			Pbind(\server, q.servers.seq)
		)
	}).trace
)
);


//Pattern for single onsets
Pdef(\singlePeters, (Pbind(
    \latency, [nil],
	\instrument, \bufPlayer,
) <> Plazy { q.buffers.seq(\peter) }
<> Plazy { Pbind(\server, q.servers.asPattern) }
))
