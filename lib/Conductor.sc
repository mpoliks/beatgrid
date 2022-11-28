Conductor {

	var <current_time, <event_time, <current_event, <next_event, <transition;

	*new { ^super.new.init() }

	init {
		event_time = Date.getDate;
	}


	eventPlayer{
		arg seed;
		var intensity_level, minute = event_time.minute % 13, key = ["F#", "C#"], next = rrand(2,5);

		if (((event_time.hour < 11) || (event_time.hour > 17)), { intensity_level = 0; });
		if (((event_time.hour >= 11) && (event_time.hour < 14)), { intensity_level = 1; });
		if (((event_time.hour >= 14) && (event_time.hour < 16)), { intensity_level = 2; });

		if (((minute >= 0) && (minute < 4)), { intensity_level = intensity_level + 0; });
		if (((minute >= 4) && (minute < 8)), { intensity_level = intensity_level + 1; });
		if (((minute >= 8) && (minute < 13)), { intensity_level = intensity_level + 2; });

		next_event = EventManager.new(seed, intensity_level, key[rrand(0,1)], 0.1);

		transition = TransitionManager.new();

		transition.transition(current_event, next_event);

		current_event = next_event;

		("OK: New Event at Intensity" + intensity_level.asString).postln;

		event_time.minute = event_time.minute + next;
		if(event_time.minute >= 60, {
			event_time.minute = event_time.minute % 60;
			event_time.hour = event_time.hour + 1;
		});
	}



	conduct {

		arg seed;


		SystemClock.sched(0.0, {

			current_time = Date.getDate;

			if(
			(current_time.hour >= event_time.hour) &&
			(current_time.minute >= event_time.minute), {
				"WORKING: Moving to Next Event".postln;
				this.eventPlayer(seed);
			});

			1;
		});

	}




}
