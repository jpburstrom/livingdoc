(
var mainServer = Server.local;

s.options.maxLogins = 8;
s.waitForBoot {
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
		~servers.startUpdates;
		(~basePath +/+ "synthdefs/*").loadPaths;
		(~basePath +/+ "patterns/*").loadPaths;

		~buffers.readDirectory(~samplePath);

		~buses = (
			ampBus: Bus.control;
		);

		///XXX currently unused stuff
		~synths = List();
		~makeSynth = { |key, def, args|
			~synths.add(Synth(def, args));
		}.inEnvir;

	};

	s.sync;

	"score.scd".resolveRelative.load;
}
)
