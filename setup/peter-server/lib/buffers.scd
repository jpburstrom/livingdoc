//Central location for buffers
(
~buffers !? (_.freeAll);
~buffers = Proto({

	~servers = Set();
	~bufs = MultiLevelIdentityDictionary();
	~cache = IdentityDictionary();

	~methods = (
	);

	~addServer = { |server|
		if (server.serverRunning.not) {
			"Buffer monster says server % not running".format(server).warn;
		};
		~servers.add(server);
		server.newBufferAllocators;
	};

	~removeServer = { |server|
		~servers.remove(server.postln);
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
					server = ev.server ?? { Server.default };
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


});

~buffers.addServer(Server.default);
// ~buffers.removeServer(Server.default);
// ~buffers.clearServers
// ~buffers.read([\foo, \fum], "/Users/johannes/lovestory.wav")

~buffers.readDirectory("/Users/johannes/kod/livingdoc-pi/setup/peter-server/samples/");
)
SynthDef(\bufPlayer, {
	var snd = PlayBuf.ar(1, \bufnum.kr(0), BufRateScale.kr(\bufnum.kr), doneAction:2);
	Out.ar(0, snd);
}).add

Pchain(~buffers.seq(\test, \audio), (instrument: \bufPlayer, amp:1)).trace.play

~buffers.dictAt(\test)
~buffers.bufs[\test, \audio]
~buffers.listAt(\test, \audio)[Server.local]
~buffers.choose(\test).play
BufEnvir
Pbind

~buffers.random.asStream.nextN(5)

PathName("/Users/johannes/kod/livingdoc-pi/setup/peter-server/samples/").endNumberIndex
