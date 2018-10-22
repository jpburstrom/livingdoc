//Central location for buffers
Proto({

	~defaultServer = Server.internal;

	~servers = Set();
	~bufs = MultiLevelIdentityDictionary();
	~cache = IdentityDictionary();
	~history = List(); // history of buffer alloc/read commands

	~methods = (
	);

	~addServer = { |server|
		if (server.serverRunning.not) {
			"Buffer monster says server % not running".format(server).warn;
		};
		~servers.add(server);
		if (~bufs.size > 0) {
			~validateBuffers.(server, ~mirrorBuffersToServer)
		};
	};

	//Validate buffers for server.
	//Calls ~mirrorBuffersToServer if
	~validateBuffers = { |server, reallocFunc|
		var cond = Condition();
		var continue = true;
		var validate = { |buf|
			OSCFunc({ |msg|
				if (msg[3] == 0) {
					continue = false;
				} {
				};
				cond.unhang;
			}.inEnvir, \b_info, server.addr).oneShot;
			server.sendMsg(\b_query, buf.bufnum);
		};
		var bufCache = ~listAt.(server);

		//First test if server has same buffer count

		if (bufCache.isNil or: { bufCache.size != ~history.size }) {
			reallocFunc.(server);
		} {
			//If buffer count is same, check if any buffers are invalid
			//(which can happen after server reboot)
			fork {
				~bufs.leafDo { |path, buf|
					if (path.last == server) {
						validate.value(buf);
						cond.hang;
					};
					if (continue.not) {
						reallocFunc.(server);
						thisThread.stop;
					}
				};
			}
		}
	};

	~mirrorBuffersToServer = { |server|
		var key, what, args, buffer;
		Buffer.freeAll(server);
		server.bind({
			~history.do { |line|
				#key, what = line;
				args = line[2..];
				buffer = ~prBufAtCreate.(server, key);
				buffer.perform(what, *args);
				server.sync;
				buffer.updateInfo;
			}
		}.inEnvir);

	};

	~removeServer = { |server|
		~servers.remove(server);
	};

	~clearServers = {
		~servers.copy.do { |x| ~removeServer.(x) };
		~servers
	};

	~read = { |key, path, startFrame=0, numFrames=(-1), action|
		//TODO: add action , check for successful loading?
		~prBufferPerform.(key, \allocRead, path, startFrame, numFrames, action);
	};

	~alloc = { |key ...args|
		~prBufferPerform.(key, \alloc, *args);
	};

	~prBufAtCreate = { | server, keys|
		keys = keys ++ server;
		~bufs.at(*keys) ?? {
			var buf = Buffer(server, 0, 1);
			~bufs.put(*(keys ++ buf));
			buf
		};
	};

	~prBufferPerform = { |key, what ...args|
		var buffer;
		~history.add([key, what].addAll(args));
		~servers.do { |server|
			server.bind {
				buffer = ~prBufAtCreate.(server, key);
				buffer.perform(what, *args);
				server.sync;
				buffer.updateInfo;
			};
			buffer
		};
	};


	~freeAll = {
		~history.clear;
		~bufs.leafDo({ |path, buf|
			buf.free;
		});
	};

	//Read directory tree
	~readDirectory = { |dir, keys|
		if (dir.isKindOf(String)) {
			dir = PathName(dir.withTrailingSlash)
		};
		if (keys.isArray) {
			keys = keys.add(dir.folderName.asSymbol);
		} {
			keys = keys.asArray;
		};
		if (dir.folders.do({ |subdir|
			~readDirectory.(subdir, keys);
		}).isEmpty) {
			dir.files.do({ |file|
				var name = file.fileNameWithoutExtension.asSymbol;
				file = file.fullPath;
				SoundFile.openRead(file) !? {
					~read.(keys ++ name, file);
				};
			});
		};
		keys.pop;
		dir
	};

	//Accessing

	//Weird name, returns either list
	//or dictionary of lists, sorted by server
	//FIXME sort list?
	~listAt = { |...keys|
		var server, out = IdentityDictionary();
		if (keys.last.respondsTo(\name)) {
			server = keys.pop;
		};
		~bufs.leafDoFrom(keys, { |path, buf|
			if (server.isNil or: { path.last == server }) {

				out[path.last] = out[path.last].add(buf);
			}
		});
		if (server.notNil) {
			out[server]
		} {
			out
		}
	};

	~choose = { |...keys|

		~bufs.choose(*keys);
	};

	//Patterns

	~rand = { |...keys|
		var data = ~bufs.at(*keys);
		data !? {
			Prout({ |ev|
				var server;
				loop {
					server = ev.server ?? { Server.default };
					ev.bufnum = ~prChooseServerDict.(data)[server];
					ev.bufdur = ev.bufnum.duration.max(0.001);
					ev = ev.yield;
				};
			}.inEnvir);
		}
	};

	~seq = { |...keys|
		var data = ~listAt.(*keys);
		data !? {
			var size = data.values[0].size;
			Prout({ |ev|
				var server, index=0;
				loop {
					server = ev.server ?? { ~defaultServer };
					ev.bufnum = data[server][index];
					ev.bufdur = ev.bufnum.duration.max(0.001);
					ev = ev.yield;
					index = (index + 1) % size
				};
			}.inEnvir);
		}
	};

	~prChooseServerDict = { |dict|
		var item;
		item = dict.choose;
		if (item.isKindOf(IdentityDictionary)) {
			thisFunction.(item);
		} {
			//Don't return item, but enclosing dictionary
			dict
		}
	};

	~update = { |obj, what, server|
		switch(what,
			\add, {
				~addServer.(server)
			},
			\remove, {
				~removeServer.(server)
			}
		);
	}
});
