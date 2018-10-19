//A player for players
//By default, ~player is an environment with functions
//Player functions can be redefined by using ~playerFunc
//to define actions.
//As a shortcut, you can also set ~player to be a function, like this:
/*
p.player_({
	var synth, buf;

	//All objects attached to environment variables will be freed after stop
	~buf = Buffer.read(s, "/Users/johannes/lovestory.wav");

	//We run the function on load, in a routine, so we can use sync etc
	s.sync;

	//The above can also be put in a ~load function.

	//Redefined play action. The player itself will take care of all complex
	//player logic, so we just write what we want to do. It's run in a private environment,
	//but you can reach the player controller as an function argument:
	~play = { |player|
		synth = {
			PlayBuf.ar(2, ~buf)
		}.play;
		~buf.postln;
		player.stop;
	};

	//Stop action. if you want to
	~stop = { |player|
		player.waitFor(~synth.release(10).onFree(_).inEnvir)
	};

}).play

*/

var proto = Proto {

	~cond = Condition(false);
	~playerCond = Condition(false);

	~playAfterLoad = false;

	~stateNum = 64;
	~states = IdentityDictionary[
		\stopped -> 1,
		\loading -> 2,
		\ready -> 4,
		\playing -> 8,
		\paused -> 16,
		\stopping -> 32,
		\free -> 64,
		\error -> 128
	];

	~player = Environment();

	//A-P-I + sensible defaults
	~playerFunc = {

		~duration = inf;

		~load = nil;
		~beforePlay = nil;
		~play = nil;
		~afterPlay = nil;
		~beforeStop = nil;
		~stop = nil;
		~afterStop = nil;
		~pause = nil;
		~resume = nil;

	};

	//Default
	~player.make(~playerFunc);


	~playerWaitFor = { |...keys|
		keys.do { |key|
			~playerCond.test = false;
			// "into %".format(key).debug;
			fork {
				(~player[key] !? (_.inEnvir(~player))).value(currentEnvironment);
				// "out of %".format(key).debug;
				~playerCond.test = true;
				~playerCond.signal;
			};
			~playerCond.wait;
			// "truly out of %".format(key).debug;

		}

	};

	~waitFor = { |func|
		var cond = Condition();
		fork {
			func.value({ cond.unhang });
		};
		cond.hang;
	};

	~makePlayer = {
		if (~player.isFunction) {
			~playerFunc = ~player;
			~player = ();
		};
		~playerFunc !? {
			~player.make(~playerFunc);
		};
	};

	~get = { |what|
		if (~player.isEmpty) {
			~makePlayer.value;
		};
		~player[what];
	};

	~set = { |what, val|
		if (~player.isFunction) {
			~player = { currentEnvironment[what] = val } <> ~player;
		}
	};

	~load = {
		~cond.test = false;
		CmdPeriod.add(currentEnvironment);
		forkIfNeeded {
			if (~prCheckState.(\stopped, \error, \free)) {
				~prChangeState.(\loading);
				~makePlayer.value;
				~playerWaitFor.(\load);
				if (~prCheckState.(\stopping).not) {
					~prChangeState.(\ready);
					if (~playAfterLoad) {
						~playAfterLoad = false;
						~play.value;
					};
				}
			};
			~cond.test = true;
			~cond.signal;
		};
		currentEnvironment
	};

	~play = {
		~cond.test = false;
		forkIfNeeded {
			switch(~stateNum,
				~states[\stopped], { ~playAfterLoad = true; ~load.value; },
				~states[\free], { ~playAfterLoad = true; ~load.value; },
				~states[\loading], { ~playAfterLoad = true; },
				~states[\ready], {
					~playerWaitFor.(\beforePlay, \play);
					if (~prCheckState.(\stopping).not) {
						~prChangeState.(\playing);
						~playerWaitFor.(\afterPlay);
					};
				},
				~states[\paused], { ~resume.value }
			);
			~cond.test = true;
			~cond.signal;
		};
		currentEnvironment
	};

	~stop = {
		CmdPeriod.remove(currentEnvironment);
		forkIfNeeded {
			var name = ~player[\name];
			if (~prCheckState.(\stopped, \stopping).not) {
				~prChangeState.(\stopping);
				~playerCond.wait;
				~playerWaitFor.(\beforeStop);
				~playerWaitFor.(\stop);
				~prChangeState.(\stopped);
				~playerWaitFor.(\afterStop);
				~freeAll.value;
				~playAfterLoad = false;
			};
			~cond.test = true;
			~cond.signal;
		};
		currentEnvironment
	};

	~pause = {
		currentEnvironment
	};

	~resume = {
		currentEnvironment
	};

	//Hack: leave proto alone, and deepDo on player instead
	~deepDo = { |depth, function, index=0, rank=0|
		~player.deepDo(depth, function, index, rank);
	};

	~freeAll = { |completely=false|
		var ev = ~player;
		var func = {
			if (~prCheckState.(\stopped).not) {
				~stop.value;
			} {
				if (~prCheckState.(\free).not) {
					//If player has a freeAll function, use that.
					//Otherwise just brutally free everything player has, recursively.
					ev[\freeAll] !? { |func| func.inEnvir(ev).value(completely)
					} ?? {
						ev.tryPerform(\deepDo, 99, { |x|
							x.free
						})
					};
					~prChangeState.(\free);
				};
				currentEnvironment
			}
		};
		if (completely) {
			//Need to remove this before forking, to avoid race conditions
			CmdPeriod.remove(currentEnvironment);
			forkIfNeeded {
				func.value;
				currentEnvironment.free;
			}
		} {
			func.value;
		}
	};

	~then = { |func|
		forkIfNeeded {
			~cond.wait;
			func.value(currentEnvironment);
		}
	};

	~wait = {
		~cond.wait
	};

	~state = { ~states.findKeyForValue(~stateNum) };

    ~isStopped = { ~prCheckState.(\stopped) };
    ~isLoading = { ~prCheckState.(\loading) };
    ~isReady = { ~prCheckState.(\ready) };
    ~isPlaying = { ~prCheckState.(\playing) };
    ~isPaused = { ~prCheckState.(\paused) };

    ~prChangeState = { arg st;
	    ~stateNum = ~states[st];
		currentEnvironment.changed(\state, st);
		currentEnvironment.changed(st);
    };

    ~prCheckState = { arg ... st;
		(st.collect(~states[_]).sum & ~stateNum) == ~stateNum;
    };


	~cmdPeriod = {
		fork {
			if (~prCheckState.(\stopped, \free).not) {
				~prChangeState.(\stopped);
				~playerWaitFor.(\afterStop);
				~freeAll.value;
			}
		}
	};

	~free = {
		~stop.value;
		"FREEING PROTO".warn;
	};
	currentEnvironment['<>'] = { |func|
		if (func.isFunction or: func.isKindOf(FunctionList)) {
			currentEnvironment.make {
				if (~player.isFunction) {
					~player = func <> ~player;
				} {
					~playerFunc = ~playerFunc.addFunc(func);
				}
			};
		} {
			//Ignore nil
			func !? {
				"Not a function".warn;
			}
		};
		currentEnvironment

	}

};

Fdef(\makeCue, { |obj, modFunc|
	case
	{obj.isKindOf(Pattern)} {
		obj = "{ ~pattern = EventPatternProxy(%) }".format(obj.asCompileString).interpret.addFunc({
			~play = {
				~pattern.play;
			};

			~stop = {
				~pattern.stop;
			};
		});
	};

	//Add modFunc if not nil,
	proto.clone <> (modFunc !? obj.addFunc(_) ? obj).postln;
});

//Trigger cue without stop
Fdef(\makeTriggerCue, { |func, modFunc|
	proto.clone <> { ~play = func } <> modFunc;
});

z = Fdef(\makeCue).value(Pbind(\dur, 0.5), { ~note = 2; });
//z.play

