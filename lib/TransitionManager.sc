TransitionManager {

	var <prev_event, <event;

	*new {
		^super.new.init()
	}

	init {
	}

	transition {

		arg previous, next;

		var instruments = [	\bass, \kick, \snare, \clap, \hat, \loop, \hit, \aux ],
		seq = instruments.scramble;

		prev_event = previous;
		event = next;

		if (prev_event.notNil, {

			"WORKING: Initiating New Transition".postln;

			seq.do({

				arg inst;
				var intvl = 2.pow(rrand(1,5));

				("WORKING: Will Halt" + inst + "in" + intvl.asString + "Measures").postln;

				Q.uant(((60/~tempo) * (4 * intvl)), {
					if(prev_event.streaming.at(inst).notNil, {
						prev_event.streaming.at(inst).patterns[1].stop;
						prev_event.streaming.at(inst).patterns[1].free;
					});
					prev_event.streaming.at(inst).stop;
					prev_event.streaming.at(inst).free;
					prev_event.streaming.removeAt(inst);
					prev_event.offramping.remove(inst);
					("OK: Stopped" + inst.asString).postln;
					if (event.notNil, { this.onramp(inst, event); } , { "WARN: Offramp Without Reset".postln; });
				});

				prev_event.offramping.add(inst);

			});
		},
		{
			"WORKING: Starting New Piece".postln;
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

		("WORKING: Will Play" + inst + "in" + intvl.asString + "Measures").postln;

		event.streaming.putAll(
			Dictionary[
				inst -> Pchain(
					~reTime,
					event.schemas.at(inst,
						(swingBase: 0.25,
						swingAmount: event.swing_,
						swingThreshold: 0.05)
				).play(quant:qval);
			)
			]);

		event.onramping.add(inst);

		Q.uant(qval, {
			event.onramping.remove(inst);
				("OK: Playing" + inst.asString).postln;
			});

	}

}