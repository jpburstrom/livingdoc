SynthDef(\bufPlayer, { |outbus=0, amp=1, bufnum=0, pan=0, sustain=1, startPos=0|
    var snd = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), startPos: startPos * BufFrames.kr(bufnum));
    //snd = FreqShiftAA.ar(snd, \freqshift.kr(0));
    snd = BBandPass.ar(snd, ExpRand(1000, 10000), 2, 5);
    snd = snd * Env.linen(0.002, (sustain - 0.004).max(0.01), 0.002).ar(2);
    snd = HPF.ar(snd, 100);
    Out.ar(outbus, Pan2.ar(snd, pan, amp));
}).add;
SynthDef(\bufPlayerWarp, { |outbus=0, amp=1, bufnum=0, bufrate=1, rate=1, pan=0, sustain=1, startPos=0|
    var pointer = Phasor.ar(0, SampleDur.ir / BufDur.ir(bufnum) * rate, startPos, 1);
	var snd = Warp1.ar(1, bufnum, pointer, bufrate, \winsize.kr(0.01), overlaps:2, windowRandRatio:0.15);

    //snd = FreqShiftAA.ar(snd, \freqshift.kr(0));
	// snd = BBandPass.ar(snd, ExpRand(1000, 8000), 2, 5);
	snd = RLPF.ar(snd, \ffreq.kr(8000), \rq.kr(0.1));
	snd = HPF.ar(snd, \hpfreq.kr(400));
    snd = snd * Env.linen(0.002, (sustain - 0.004).max(0.01), 0.002).ar(2);
    OffsetOut.ar(outbus, Pan2.ar(snd, pan, amp));
}).add;

