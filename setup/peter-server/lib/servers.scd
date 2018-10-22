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

	~addPermanent = { |server|
		var key = server.name.asSymbol;
		~expires[key] = inf;
		~servers[key] = server;
		currentEnvironment.changed(\add, server);
	};

	~removePermanent = { |server|
		var key = server.name.asSymbol;
		~expires[key] = nil;
		currentEnvironment.changed(\remove, ~servers.removeAt(key));
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
		currentEnvironment.releaseDependants;
		~servers.do(_.remove);
		~stopUpdates.value;
	};

	~asPattern = {
		//Fallback to internal server
		Pprotect( //Doesn't catch host down error
			Pfunc({ ~servers.choose ?? { ~fallbackServer } }.inEnvir)
			, { "There was an error".postln });
	};

	~asStream = {
		~asPattern.value.asStream;
	};

};
