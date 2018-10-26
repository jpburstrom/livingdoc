SynthDef(\droneyFM, {
	var snd = LocalIn.ar(1);
	var trig = Dust.ar(10);
	var freq = \freq.kr(110).lag3(\portamento.kr(0.0));
	var car = freq * Demand.ar(trig, 0, Diwhite(1, 8));
	var mod = freq * Demand.ar(trig, 0, Diwhite(1, 8)) * 2.5;
	snd = GrainFM.ar(1, Dust.ar(LFNoise0.kr(0.2).range(3.0,10)), 10, car, mod) + snd;
	snd = SinOsc.ar(freq, snd * 0.1);
	snd = snd + AllpassC.ar(snd, 0.2, LFNoise2.ar(0.1).range(0.1, 0.2),
		4 * (1 - Trig.kr(Changed.kr(freq), 1)).lag2(0.5), 0.3);
	LocalOut.ar(snd);
	snd = snd * Env.linen(\atk.kr(4), \sustain.kr(10), \release.kr(10), [4, -4]).ar(Done.freeSelf);
	Out.ar(\out.kr(0), snd  * \amp.kr(0.2));
}).add;
SynthDef(\droneyFMLight, {
	var snd = LocalIn.ar(1);
	var trig = Dust.ar(5);
	var freq = \freq.kr(110).lag3(\portamento.kr(0.0));
	var car = freq * Demand.ar(trig, 0, Diwhite(1, 8));
	var mod = freq * Demand.ar(trig, 0, Diwhite(1, 8)) * 2.5;
	snd = GrainFM.ar(1, trig, 3, car, mod) + snd;
		snd = SinOsc.ar(freq * SinOsc.ar(Rand(2,5), 0, Line.kr(0.01, 0, \sustain.kr(10)), 1), snd * 0.1);
	snd = snd * Env.linen(\atk.kr(4), \sustain.kr(10), \release.kr(10), [4, -4]).ar(Done.freeSelf);
	Out.ar(\out.kr(0), snd  * \amp.kr(0.2));
}).add;