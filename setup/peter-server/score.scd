(
q.make {

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
		self.clk.tempo = 20;
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
		"Cueing %".format(args).postln;
		while { args[0].isSymbol } {
			self.parts[args.removeAt(0)].value;
		};

		self.spawner.wait(self.calcTime(*args));
	};

	~calcTime = { |self, m, s|
		((m ? 0) * 60) + (s ? 0)
	};

	//------PART DEFINITIONS GO HERE-------

	~parts = (
		startReset: {
			q.playSignal(5);
		},

		endReset: {
			q.playSignal(3);
		},

		startBox: {
			q.vibro = (instrument: \vibroBox, ampBus: q.buses.ampBus, dur:inf).play;
		},

		endBox: {
			q.vibro.release;
		},
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


		q.resetTime;

		q.cue(\startReset, 2);
		q.cue(\endReset, \startBox);
		q.cue(\waitForTrigger);
		q.triggerWait(2);
		q.remainingDo([
			//part, duration factor
			\part1, 4,
			\part2, 3,
			\part3, 1,
			\part4, 2
		]);
		q.cue(\endBox);

	}

}).play(q.clk)
);
