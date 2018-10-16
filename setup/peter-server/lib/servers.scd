(
p.free;
p = Proto {

	~timeout = 4;

	~expires = ();
	~servers = ();

	~initOSC = {
		~responder = OSCFunc({ |msg, time, addr|
			var name = addr.ip;
			~updateServer.(name.asSymbol, name);

		}.inEnvir, '/ping').fix;
	};

	~stopUpdates = {
		~responder.free;
		~task.stop;
	};

	~startUpdates = {
		~initOSC.value;
		~startTask.value;

	};

	~startTask = {
		~task = SkipJack({

			~expires.copy.keysValuesDo { |k, time|
				if (time < SystemClock.seconds) {
					~expires[k] = nil;
					~servers.removeAt(k).remove.debug("remove");
				}
			};

		}, ~timeout);
	};

	~updateServer = { |key, hostname|
		if (~servers[key].isNil) {
			~servers[key] = Server.remote(key, NetAddr(hostname, 57110));
			~servers[key].initTree;
		};
		~expires.put(key, SystemClock.seconds + ~timeout);
	};

	~free = {
		~servers.do(_.remove);
		~stopUpdates.value;
	};

	~asPattern = {
		//Fallback to internal server
		Pfunc({ ~servers.choose ?? { Server.internal } })
	};

	~asStream = {
		~asPattern.value.asStream;
	};

};
p.startUpdates
)
p.servers.do(_.freeAll)
p.servers['192.168.0.11'].queryAllNodes
x = Synth(\default, nil, p.servers['192.168.0.11'])
x.free
(
Pbind(
	\latency, [nil],
	\server, p,
	\note, Pwhite(0,11),
	\dur, 0.25
).play
)
SynthDescLib.default.send(p.servers.values[0])
