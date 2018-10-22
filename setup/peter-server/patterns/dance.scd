(
~progress = NumericControlValue(0, \unipolar);
Knob(Window.new.front.layout_(HLayout())).mode_(\vert).mouseWheelAction_({ |kn, x, y, mod, xd, yd|
	kn.valueAction = kn.value + (yd * -0.005)
}).signal(\value).connectTo(~progress.valueSlot);
)
[1,2,3,4] *.x [2,4,8,16]
~progress.value
TempoClock.tempo = 6.8/6
Pdef.defaultQuant = 1
(
Pdef(\dance1, Pbind(
	\progress, Pfunc({ ~progress.value }.inEnvir),
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
	\server, Plazy { q.servers.asPattern },
	\rq, 1,
	\ffreq, Pexprand(Pfuncn({ ~progress.value}.inEnvir, inf).linexp(0, 1, 8000, 400), 10000),
    //\freqshift, [0, -50, 100, -2000],
   // \amp, Pkey(\clump).reciprocal * p{ var x=0; loop { x = (x * 0.8) + (q.buses.ampBus.getSynchronous * 20); x.yield; }  } ,
	\amp, 0.5,
    // \bufnum, ~buffers[0],
	\bufrate, Pfunc { |ev| 1 ! ev.clump },
	\hpfreq, Pkey(\progress).linexp(0, 1, 100, 800),
	\rate, Pif(Pfunc { 0.1.coin }, Pwhite(1.0, 4), 1), //pitch
	// \rate, 1,
    // \bufrate, 1,
	\dur, Pshufn([0.5, 0.25, 0.5, 0.25, 0.75, 0.25], inf),
	\sustain, Pkey(\progress).linexp(0, 1, 0.4, 2) / Pkey(\clump),
	\strum, Pfunc { |ev| ev.dur / ev.clump },
	\pan, Prand([-0.75, -0.25, 0.25, 0.75], inf),
	// \dur, Pkey(\amp).linlin(0, 0.5, 0.4, 0.05),
    // \dur, 1,
).trace(#[amp]) <> Plazy { q.buffers.rand(\peter) }).play(quant:2);
)
(

Pdef(\dance2, Pbind(
	// \progress, Plazy({ ~progress }.inEnvir),
    \amp, 1,
	\instrument, \bufPlayerWarp,
    // \startPos, Pseg([0, 1, 0], 5, repeats:inf),
	\startPos, Pseq([0.0, 0.33], inf),
	// \startPos, Pbrown(0.33, 0.37) * Pkey(\peter),
	    // \startPos, 0.2,
	\server, Plazy { q.servers.asPattern },
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
).trace(#[clump],) <> Plazy { q.buffers.rand(\peter) }).play(quant:2);
)

(

Pdef(\dance3, Pbind(
	// \progress, Plazy({ ~progress }.inEnvir),

    \amp, 2,
	\instrument, \bufPlayerWarp,
    // \startPos, Pseg([0, 1, 0], 5, repeats:inf),
	\startPos, Pseq([0, 0.34, 0, 0.34], inf),
	// \startPos, Pbrown(0.33, 0.37) * Pkey(\peter),
	    // \startPos, 0.2,
	\server, Plazy { q.servers.asPattern },
	\rq, 1,
	\ffreq, 10000,
	\hpfreq, 100,
    \bufrate, 1,
	\rate, Pseg([0.03, 1, 0.03], [6,2], Pseq([Pwhite(2,4), Pwhite(-4, -2)]), inf) ,
	\dur, Pshufn([[0.5], [0.25, 0.25], [0.5], [0.27, 0.23]], inf).flatten * 0.5,
	\sustain, Pfunc({ ~progress.value}.inEnvir).linexp(0, 1, 0.01, 0.4),
	// \sustain, Pseq([0.01, 0.03], inf) * Pwhite(0.999, 1.001)
	// \dur, Pkey(\amp).linlin(0, 0.5, 0.4, 0.05),
    // \dur, 1,
) <> Plazy { q.buffers.seq(\peter) }).play(quant:2);
)
