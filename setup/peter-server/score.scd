(
q.make {

	~verbose = true;

	~dbg = { |self, what, desc|
		if (self.verbose) {
			what.debug(desc);
		};
	};

	//Play reset signal
	~playSignal = { |self, num=5|
		fork {
			num.do {
				{ SinOsc.ar * Env.perc.ar(2) }.play;
				1.wait;
			}
		}
	};

	//Init clock
	~initClock = { |self|
		self.clk.free;
		self.clk = TempoClock.new;
	};

	//Reset time so that self.startTime (beginning of loop) is now
	~resetTime = { |self|

		self.totalTime = 15 * 60;
		self.remainingTime = self.totalTime;
		self.startTime = self.clk.beats;
		self.clk.tempo = 1;
	};

	//Run a routine posting current time every 5 beats
	~postTime = { |self|

		var time;
		self.spawner.par(p {
			loop {
				time = self.clk.beats -  self.startTime;
				"Time: %:%".format(
					time.div(60).asString.padLeft(2, "0"),
					(time % 60).asInteger.asString.padLeft(2, "0")
				).postln;
				5.wait;
			}
		})

	};

	//Calculate and return remaing time of loop
	~calcRemainingTime = { |self|
		self.remainingTime = self.totalTime - (self.clk.beats - self.startTime);
		self.remainingTime;
	};

	//Wait for a trigger until continuing
	~triggerWait =  { |self, min, sec|
		var test = false;
		var timeout = self.calcTime(min, sec);
		var win;
		{
			Button(win = Window.new("Please trig me").front.layout_(HLayout()))
			.states_([["Please trig me"]])
			.action_({
				win.close;
				test = true;
				thisThread.stop;
			});
		}.fork(AppClock);
		{

			timeout.wait;
			{ win.close }.fork(AppClock);

			test = true;

		}.fork(self.clk);
		while { test == false } {
			self.spawner.wait(0.5);
		};
	};

	~remainingDo = { |self, main|
		main = main.clump(2).flop;
		main[1] = main[1].normalizeSum * self.calcRemainingTime;
		main = main.flop.flat;
		main.pairsDo { |part, time|
			self.cue(part, 0, time)
		};
	};



	~cue = { |self ...args|
		var cues;
		"Cueing %".format(args).postln;
		while { args[0].isSymbol } {
			cues = cues.add(args.removeAt(0));
		};
		self.currentDuration = self.calcTime(*args);
		cues.do { |cue|
			self.parts[cue].value(self.currentDuration);
		};
		self.spawner.wait(self.currentDuration);
	};

	~calcTime = { |self, m, s|
		((m ? 0) * 60) + (s ? 0)
	};


	//------PART DEFINITIONS GO HERE-------

	~parts = (
		startReset: {
			q.playSignal(5);
			Pdef(\intermission).play;
		},

		endReset: {
			q.playSignal(3);
			Pdef(\intermission).stop;
		},

		startBox: {
			q.vibro = (instrument: \vibroBox, ampBus: q.buses.ampBus, dur:inf).play;
		},

		endBox: {
			q.vibro.release;
		},

		dance: { |self, dur|
			///XXX a bit verbose
			var stream = Routine({
				var dances = (
					//Placeholder
					truthPractice: Pdef(\drone1, Pbind(\octave, 3)),
					hiphop: Pdef(\dance1),
					ritual: Pdef(\dance2),
					smallIsThis: Pdef(\dance3),
					bigIsThis: Pdef(\drone2, Pbind(\octave, 3))
				);
				loop {
					dances.keys.asArray.scramble.do { |dance|

						q.dbg(dance, "Now playing");
						dances[dance].yield;
					}
				};
			});
			{ |dur|
				var ptn = stream.next;
				q.dbg(ptn, "pattern");
				q.dbg(dur, "Setting duration");
				Pdefn(\totalDur, dur);
				//TODO pass on total duration to pattern
				//TODO fix hardcoded tempo
				PatternConductor(Pfindur(dur, ptn)).tempo_(68/60).play
			}

		}.value;
	);
	//------------END OF PART DEFINITIONS!!!-----------
};
);
(
q.initClock;
Pspawner({ |sp|

	q.spawner = sp;
	q.postTime;

	loop {

		var numDances = 7; //FIXME
		var totalDanceDuration = 120;
		var endDuration = 0.rrand(45);

		//durations
		var dances;
		var pauses;


		q.resetTime;

		/*
		q.cue(\startReset, );
		q.cue(\endReset, \startBox);
		q.cue(\waitForTrigger);
		q.triggerWait(0, 30);
		q.cue(\startBoxPattern);
		q.cue(\waitForFirstDance, 0, 30);
		*/
		//Ar
		dances = q.func.divideSensibly2(
			totalDanceDuration, numDances, 15.0);
		pauses = q.func.divideSensibly2(
			q.calcRemainingTime - endDuration - totalDanceDuration, numDances, 30).debug("pauses");
		numDances.do { |i|
			q.cue(\pause, 0, pauses[i]);
			q.cue(\dance, 0, dances[i]);
		};
		q.cue(\waitForEnd, 0, endDuration);
		q.cue(\endBox);
		q.dbg(q.calcRemainingTime, "REMAINING SHOULD BE 0 AND IS::");
	}

}).play(q.clk)
);