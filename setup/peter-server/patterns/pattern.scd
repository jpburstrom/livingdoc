Pdef(\peterAmpWarp, Pbind(
    \amp, 1,
    \instrument, \bufPlayerWarp,
    // \startPos, Pseg([0, 1, 0], 5, repeats:inf),
    \startPos, Pseg([0, 1], Prand([0.75, 0.5, 1.5, 0.125], inf), repeats:inf),
    \startPos, Prand([0.0, 0.35], inf),
    // \startPos, 0.2,
    \clump, 4,
    \server, Plazy { Pxrand(q.servers, inf) },
    \bufnum, Pfunc { |ev| q.buffers[ev.server.name].choose },
    //\freqshift, [0, -50, 100, -2000],
    \amp, Pkey(\clump).reciprocal * p{ var x=0; loop { x = (x * 0.8) + (q.ampBus.getSynchronous * 20); x.yield; }  } ,
    //\amp, 0.5,
    // \bufnum, ~buffers[0],
    \strum, 0.125,
    \bufrate, Pwhite(0.1, 2),
    \rate, Pwhite(0.5, 2), //pitch
    \rate, 1,
    // \bufrate, 1,
    \dur, 0.5,
    \dur, Pkey(\amp).linlin(0, 0.5, 0.4, 0.05),
    // \dur, 1,
    \legato, Plprand(0.01, 0.8)
));