SynthDef(\vibroBox, { |ampBus|
    var onset, amp, snd = SoundIn.ar(0);
    // snd = HPF.ar(snd, 100);
    snd = BBandPass.ar(snd, 5000, 0.05) * 10;

    //Amplitude with noise floor
    // amp = Amplitude.kr(snd, 0.01, 0.5).linlin(0.0009,0.1, 0, 1).poll;

    amp = RunningSum.rms(snd).linlin(0.001, 0.03, 0, 1);

    onset = Coyote.kr(snd);
    SendReply.kr(TDelay.kr(onset, 0.01), '/onset', Amplitude.ar(snd, 0.01, 0.01));

    // RunningMax.ar(amp).poll;

    /*
    snd = Mix(~buffers[..3].collect { |b, i|
        var a = amp.lagud(0, LFNoise1.ar(1).range(1, 5));
        var w = Warp1.ar(1, b, ((i * 0.01) + Integrator.ar(a * 0.0001, 1)).fold(0, 1), 1, 0.2) * a;
        // FreqShiftAA.ar(w, Rand(-1000, -100));

        BBandPass.ar(w, (i * 200) + 200, 0.1);

    });
    */

    snd = snd + (0.1* SinOsc.ar(0, snd));

    Out.kr(ampBus, amp);

    //Play vibration in box
    // amp.lag(10).poll;
    snd = (10 * amp).min(0.45).max(0.01).lagud(1, 10) * SinOsc.ar(LFNoise2.kr(1).exprange(65, 70)).dup * 2;

    Out.ar(0, snd);

}).add
