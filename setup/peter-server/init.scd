(
var mainServer = Server.local;

s.options.maxLogins = 8;
s.waitForBoot {
    "/usr/local/bin/jack_connect alsa_in:capture_1 SuperCollider:in_1".unixCmd;

	q = q !? {
		q.servers.free;
		q.buffers !? _.freeAll;
		q.buses.do(_.free);
		q.synths.free;
		q
	} ?? ();
	q.make {

		~basePath = "".resolveRelative;
		~mainServer = Server.local;
		~samplePath = {
			if (~mainServer == Server.local) {
				~basePath +/+ "samples";
			} {
				"Falling back to hardcoded sample directory".warn;
				"/home/pi/livingdoc/setup/peter-server/samples"
			}
		}.value;


		~func = "lib/functions.scd".resolveRelative.load;
		~servers = "lib/servers.scd".resolveRelative.load;
		~buffers = "lib/buffers.scd".resolveRelative.load;
		~servers.addDependant(~buffers);
		~servers.addPermanent(mainServer);
		(~basePath +/+ "synthdefs/*").loadPaths;
		(~basePath +/+ "patterns/*").loadPaths;

		~buffers.readDirectory(~samplePath);
		~servers.startUpdates;

		~buses = (
			ampBus: Bus.control;
		);

		///XXX currently unused stuff
		~synths = List();
		~makeSynth = { |key, def, args|
			~synths.add(Synth(def, args));
		}.inEnvir;

	};

	//Get trigger from box, play peter in speaker
	OSCdef(\onset, { //closure
		var stream = Pdef(\singlePeters).asStream;
		{ |args|
			stream.next((amp: args[3].linexp(0.01, 0.1, 0.6, 1))).play;
		}
	}.value, '/onset');

	"score.scd".resolveRelative.load;
}
)
