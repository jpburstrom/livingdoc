//Recording script
//2 minutes
//Standalone supercollider

//Waltz
//Cover
(
//Quarks.install("ddwPrototype");
s.waitForBoot {
    q !? { q.do(_.free) };
    q = ();
    q.cond = Condition();
    q.recorder = "recorder.scd".loadRelative[0];
    q.trig = {
        "trig".postln;
        q.cond.unhang;
    };

    SynthDef("pb1", { | out, amp = 1, bufnum, sustain, ar = 0, dr = 0.01 gate = 1 |
        var snd = VDiskIn.ar(1, bufnum, BufRateScale.kr(bufnum));
        FreeSelf.kr(Done.kr(snd));
        Out.ar(out, snd * Linen.kr(gate, ar, 1, dr, 2) * amp)
    }).add;
    SynthDef("trigSound", { |out|
        var snd = SinOsc.ar(1000) * Env.perc(0, 0.1).ar(2) * 0.1;
        Out.ar(out, snd);
    }).add;
    //
    s.freeAll;
    OSCdef(\trig, {
        Synth(\trigSound, [\out, 0]);
        q.cond.unhang
    }, "/trig");

    q.playSound = { |q, filename, delay=0|
        var path = "media".resolveRelative +/+ filename;
        var ev = (out:1, amp:1);
        var p = Buffer.cueSoundFile(s, path, 0, 1, 32768*2).postln;
        q.players.add(p);
        fork {
            delay.wait;
            q.players.add(Synth(\pb1, [\bufnum, p, \out, 1]));
        }
    };


    q.players = List();


    q.updater = Updater(q.recorder, { |obj, changed, count|
        if (changed == \loop) {
            [
                {
                    q.playSound("0.flac");
                },
                nil,
                {
                    var delay = (q.recorder.duration * 2) - 197;
                    delay = delay.max(0);
                    q.playSound("3-102.flac", delay)
                },
                nil,
                {
                    q.playSound("4.flac")
                }
            ][count].value
        }
    });

    Routine({
        2.wait;
        q.recorder.prep;
        3.do {
            Synth(\trigSound, [\out, 0]);
            0.1.wait;
            Synth(\trigSound, [\out, 1]);
            0.1.wait;
        };
        q.cond.hang;
        inf.do {
            "start recording".postln;
            q.recorder.record;
            "press to stop recording".postln;
            q.cond.hang;
            q.recorder.play;

            (q.recorder.duration * 5).wait;
            q.recorder.stop;
            q.players.do(_.free);
            q.players.clear;
            "end of loop".postln;
        }

    }).play;
}

)

