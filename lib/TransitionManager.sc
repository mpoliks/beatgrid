TransitionManager {

	*new {
		^super.new.init()
	}

	init {
	}

	transition {

		arg prev_event, event;

		var seq = event.instruments.scramble;

		if (prev_event.notNil, {

			seq.do({

				arg inst;
				var intvl = 2.pow(rrand(1,5));

				Q.uant((60/(~tempo) * (4 * intvl)), {
					prev_event.streaming.at(inst).stop;
					prev_event.streaming.removeAt(inst);
					prev_event.offramping.remove(inst);
					("stopped" + inst.asString).postln;
					this.onramp(inst, event);
				});

				prev_event.offramping.add(inst);

			});
		},
		{
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
		qval = 60/(~tempo) * (4 * intvl);

		event.streaming.putAll(
			Dictionary[
				inst -> Pchain(
					~reTime,
					event.schemas.at(inst,
						(swingBase: 0.25, swingAmount: event.swing_, swingThreshold: 0.05)
				).play(quant:qval);
			)
			]);

		event.onramping.add(inst);

		Q.uant(qval, {
			event.onramping.remove(inst);
				("starting" + inst.asString).postln;
			});

	}

}