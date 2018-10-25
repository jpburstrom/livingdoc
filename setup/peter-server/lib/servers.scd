Proto {

	//Dummy server to fall back to, if no remotes are available
	~fallbackServer = Server.internal;

	//Timeout after server is removed from pool
	~timeout = 4;

	//serverKey->expiryTime
	~expires = ();
	//serverKey->server
	~servers = ();
	~serverList = List();

	~initOSC = {
		~responder = OSCFunc({ |msg, time, addr|
			var name = addr.ip;
			~updateServer.(name.asSymbol, name);

		}.inEnvir, '/ping').fix;
	};

	~addPermanent = { |server|
		var key = server.name.asSymbol;
		~expires[key] = inf;
		~prAddServer.(key, server);
	};

	~removePermanent = { |server|
		~prRemoveServer.(server.name.asSymbol);
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
					~prRemoveServer.(~servers[k]);
				}
			};

		}, ~timeout);
	};

	~updateServer = { |key, hostname|
		if (~servers[key].isNil) {
			~prAddServer.(key, Server.remote(key, NetAddr(hostname, 57110)));
			~servers[key].initTree;
		};
		~expires.put(key, SystemClock.seconds + ~timeout);
	};

	~prAddServer = { |key, server|
		~servers[key] = server;
		if (~serverList.includes(server).not) {
			~serverList.add(server);
		};
		currentEnvironment.changed(\add, server);
	};

	~prRemoveServer = { |key|
		var server = ~servers.removeAt(key);
		~expires[k] = nil;
		~serverList.removeAllSuchThat(_==server);
		currentEnvironment.changed(\remove, server);
	};

	~free = {
		currentEnvironment.releaseDependants;
		//Remove all temporary servers
		~servers.do { |server|
			if (~expires[server.name] != inf) {
				server.remove;
			};
		};
		~stopUpdates.value;
	};

	~asPattern = {
		//Fallback to internal server
		Pprotect( //Doesn't catch host down error
			Pfunc({ ~servers.choose ?? { ~fallbackServer } }.inEnvir)
			, { "There was an error".postln });
	};

	~seq = {
		Prout({
			var index = 0;
			loop {
				index = (index + 1) % ~serverList.size;
				~serverList[index].yield;
			};
		}.inEnvir);

	};

	~asStream = {
		~asPattern.value.asStream;
	};

};
