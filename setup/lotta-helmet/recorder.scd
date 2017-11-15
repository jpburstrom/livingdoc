(
~recorder = Proto({

    ~server = s;
    ~states = #[stopped, playing, recording, paused];
    ~state = 0;
    ~recSynth = nil;
    ~playSynth = nil;
    ~recStartTime = 0;
    ~duration = 0;
    ~clock = TempoClock();

    ~sendSynthDefs = {
        SynthDef(\ldrecorder, { |in=0, bufnum=0|
            EnvGate();
            RecordBuf.ar(SoundIn.ar(in, 1), bufnum, loop:0);
        }).add;

        SynthDef(\ldplayer, { |out=0, bufnum=0, amp=1, rate=1, t_trig=0|
            var snd = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum) * rate, Trig.kr(t_trig)) * EnvGate();
            Out.ar(out, snd);
        }).add;

    };

    ~prep = {
        ~buf = Buffer.alloc(~server, ~server.sampleRate * 180);
        ~sendSynthDefs.value;
    };

    ~calcDuration = {
        ~duration = SystemClock.seconds - ~recStartTime;
    };

    ~record = {
        switch(~state,
            0, { ~prRecord.value },
            1, { ~stop.value; ~prRecord.value; },
            3,  { ~stop.value; ~prRecord.value;  }
        );
        ~state = 2;
    };

    ~prRecord = {
        ~recStartTime = SystemClock.seconds;
        ~recSynth = (dur: inf, instrument: \ldrecorder, latency: [nil], bufnum: ~buf).play;
    };

    ~stop = {
        if (~state == 2 ) {
            ~calcDuration.value;
            ~recSynth.release;
        }  {
            ~playTask.stop;
            ~playSynth.release;
        };
        ~state = 0;
    };

    ~play = {
        switch(~state,
            0, { ~prPlay.value },
            2, { ~stop.value; ~prPlay.value; },
            3,  { ~resume.value }
        );

        ~state = 1;
    };

    ~prPlay = {
        ~playSynth = (dur: inf, instrument: \ldplayer, latency: [nil], bufnum: ~buf).play;
        ~playTask = Task({
            ~loops = 0;
            loop {
                currentEnvironment.changed(\loop, ~loops);
                ~duration.wait;
                "setting looping".postln;
                //TODO: send signal on loop
                ~loops = ~loops + 1;
                ~playSynth.set(\t_trig, 1);
            }
        }.inEnvir).play(~clock);

    };

    ~pause = {
        if (~state == 1) {
            ~playSynth.set(\rate, 0);
            ~clock.tempo = 1e-8;
            ~state = 3;
        }
    };

    ~resume = {
        if (~state == 3) {
            ~playSynth.set(\rate, 1);
            ~clock.tempo = 1;
            ~state = 1;
        }
    };




});
)
