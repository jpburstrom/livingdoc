(
s.options.maxLogins = 8;
s.waitForBoot {
    var playSignal = {
        fork {
            5.do {
                { SinOsc.ar * Env.perc.ar(2) }.play;
                1.wait;
            }
        }
    };
    q !? { q.do(_.free) };
    q = ();
    q.basePath = "/home/pi/livingdoc/setup/peter-server";
    playSignal.value;
    120.wait; // BAD STYLE
    playSignal.value;
   

    //Load synthdefs
    (q.basePath +/+ "synthdefs/*").loadPaths.postln;
    //Load patterns
    //(q.basePath +/+ "patterns/*").loadPaths.postln;

    q.ampBus = Bus.control;
    1.wait;
    loop {

        q.vibro = Synth(\vibroBox, [\ampBus, q.ampBus]);
        //Pdef(\peterAmpWarp).play;

        (60 * 13).wait;

        playSignal.value;
        q.vibro.free;
        //Pdef(\peterAmpWarp).stop;

        (60 * 2).wait;

        playSignal.value;
    }
}
)
