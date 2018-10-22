Proto {

	//Dummy server to fall back to, if no remotes are available
	~fallbackServer = Server.internal;

	//Timeout after server is removed from pool
	~timeout = 4;

	//serverKey->expiryTime
	~expires = ();
	//serverKey->server
	~servers = ();

	~initOSC = {
		~responder = OSCFunc({ |msg, time, addr|
			var name = addr.ip;
			~updateServer.(name.asSymbol, name);

		}.inEnvir, '/ping').fix;
	};

	~stopUpdates = {
		"stopping updates".postln;
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
					currentEnvironment.changed(\remove, ~servers.removeAt(k));
				}
			};

		}, ~timeout);
	};

	~updateServer = { |key, hostname|
		if (~servers[key].isNil) {
			~servers[key] = Server.remote(key, NetAddr(hostname, 57110));
			~servers[key].initTree;
			currentEnvironment.changed(\add, ~servers[key]);
		};
		~expires.put(key, SystemClock.seconds + ~timeout);
	};

	~free = {
		~servers.do(_.remove);
		~stopUpdates.value;
	};

	~asPattern = {
		//Fallback to internal server
		Pprotect( //Doesn't catch host down error
			Pfunc({ ~servers.choose ?? { ~fallbackServer } })
			, { "There was an error".postln });
	};

	~asStream = {
		~asPattern.value.asStream;
	};

};
p.startUpdates
)
p.free
p.servers.do(_.freeAll)
p.servers['192.168.0.11'].queryAllNodes

x.free
(
SynthDef(\ping, {
	Out.ar(0, SinOsc.ar(\freq.kr) * \amp.kr * Env.perc.ar(2));
}).add;
Pbind(
	\instrument, \ping,
	\latency, [nil],
	\server, p,
	\degree, Pwhite(0,11),
	\dur, 0.125
).play
)
SynthDescLib.default.send(p.servers.values[0])

Pbind(\server, Server.local).play
s.boot