TransitionManager {

	var <prev_event, <event;

	*new {
		^super.new.init()
	}

	init {
	}

	transition {

		arg previous, next;

		var instruments = [	\bass, \kick, \snare, \clap, \hat, \loop, \hit, \misc],
		seq = instruments.scramble;

		prev_event = previous;
		event = next;

		if (prev_event.notNil, {

			~appendLog.value("WORKING: Initiating New Transition");

			seq.do({

				arg inst;
				var intvl = (2.pow(rrand(1,4))) + (4 * rrand(0,1));

				~appendLog.value("WORKING: Will Halt" + inst + "in" + intvl.asString + "Measures");

				if (inst != \loop, {

					Q.uant(((60/~tempo) * (4 * intvl)), {
						if(prev_event.streaming.at(inst).notNil, {
							prev_event.streaming.at(inst).patterns[1].stop;
							prev_event.streaming.at(inst).patterns[1].free;
						});
						prev_event.streaming.at(inst).stop;
						prev_event.streaming.at(inst).free;
						prev_event.streaming.removeAt(inst);
						prev_event.offramping.remove(inst);
						~appendLog.value("OK: Stopped" + inst.asString);
						if (event.notNil, { this.onramp(inst, event); } , { ~appendLog.value("WARN: Offramp Without Reset"); });
					});

					prev_event.offramping.add(inst);

				},
				{

					if(prev_event.streaming.at(inst).notNil, {
							prev_event.streaming.at(inst).patterns[1].stop;
							prev_event.streaming.at(inst).patterns[1].free;
						});
						prev_event.streaming.at(inst).stop;
						prev_event.streaming.at(inst).free;
						prev_event.streaming.removeAt(inst);
						prev_event.offramping.remove(inst);
						~appendLog.value("OK: Stopped" + inst.asString);
					if (event.notNil, { this.onramp(inst, event); } , { ~appendLog.value("WARN: Offramp Without Reset"); });

				});

			});
		},
		{
			~appendLog.value("WORKING: Starting New Piece");
			seq.do({

				arg inst;
				var intvl = 2.pow(rrand(1,5));

				this.onramp(inst, event);
			});
		});

	}


	onramp {
		arg inst, event;

		var intvl = 2.pow(rrand(1,4)),
		qval = (60/~tempo) * (4 * intvl);

		if (inst == \loop, { intvl = 64; });

		~appendLog.value("WORKING: Will Play" + inst + "in" + intvl.asString + "Measures");

		event.streaming.putAll(
			Dictionary[
				inst -> Pchain(
					~reTime,
					event.schemas.at(inst,
						(swingBase: 0.5, //changed from 0.25
						swingAmount: event.swing_,
						swingThreshold: 0.05)
				).play(quant:qval);
			)
			]);

		event.onramping.add(inst);

		Q.uant(qval, {
			event.onramping.remove(inst);
			~appendLog.value("OK: Playing" + inst.asString + "With Pattern: " ++ (1 / (event.patterns.at(inst) * 0.25)).asString);
			});

	}

}


