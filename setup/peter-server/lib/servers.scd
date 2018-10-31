Proto {

	//Dummy server to fall back to, if no remotes are available
	~fallbackServer = Server.internal;

	//Timeout after server is removed from pool
	~timeout = 8;

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
		~task !? { ~task.stop };
		~task = SkipJack({
			~expires.copy.keysValuesDo { |k, time|
				if (time < SystemClock.seconds) {
					~prRemoveServer.(k);
				}
			};

		}, ~timeout);
	};

	~updateServer = { |key, hostname|
		if (~servers[key].isNil) {
            if (~servers[key] != \pending) {
                var server, addr;
                ~servers[key] == \pending;
                "Adding remote server at %".format(key).postln;
                NetAddr(hostname, 57110).connect({
                    "Removing server %".postln;
                    ~prRemoveServer.(k);
                }.inEnvir);
                server = Server(key, addr);
                server.options.protocol = \tcp;
                server.startAliveThread(0);

                server.doWhenBooted({
                    ~prAddServer.(key, server);
                    ~servers[key].initTree;
                }.inEnvir, 30, { ~servers[key] = nil; }.inEnvir)
            };
		};
        ~expires.put(key, SystemClock.seconds + ~timeout);
	};

	~prAddServer = { |key, server|
        if (~servers.includes(server).not) {
            ~servers[key] = server;
            if (~serverList.includes(server).not) {
                ~serverList.add(server);
            };
            currentEnvironment.changed(\add, server);
        }
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
			Pfunc({ ~serverList.choose ?? { ~fallbackServer } }.inEnvir)
			, { "There was an error".postln });
	};

	~seq = { |exclude=false|
		Prout({
			var list, index = 0;
			loop {
				list = ~serverList.reject(exclude.value(_));
				index = (index + 1) % list.size;
				list[index].yield;
			};
		}.inEnvir);

	};

	~asStream = {
		~asPattern.value.asStream;
	};

};
