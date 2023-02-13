Conductor {

	var <current_time, <>event_time, <current_event, <next_event, <transition, <>kit, <>intensity, <>swing = 0.2,
	intensity_fixed, swing_fixed, kit_fixed, <>time_override, hour_lock, dayFlag = false, <>flag = true;

	*new { ^super.new.init() }

	init {
		event_time = Date.getDate;
		transition = TransitionManager.new();
	}


	eventPlayer{
		arg seed;
		var intensity_level,
		minute = event_time.minute % 13, swing = 0.2, set_kit,
		next = rrand(1,4), next_kit = rrand(0, 2);

		if (((event_time.hour < 11) || (event_time.hour >= 20)), { intensity_level = 0; });
		if (((event_time.hour >= 11) && (event_time.hour < 12)), { intensity_level = 1; });
		if (((event_time.hour >= 12) && (event_time.hour < 14)), { intensity_level = 2; });
		if (((event_time.hour >= 14) && (event_time.hour < 17)), { intensity_level = 1; });
		if (((event_time.hour >= 17) && (event_time.hour < 18)), { intensity_level = 2; });
		if (((event_time.hour >= 18) && (event_time.hour < 20)), { intensity_level = 1; });

		if (((minute >= 0) && (minute < 4)), { intensity_level = intensity_level + 0; });
		if (((minute >= 4) && (minute < 11)), { intensity_level = intensity_level + 1; });
		if (((minute >= 11) && (minute <= 13)), { intensity_level = intensity_level + 2; });

		if (~intensityOverride == true, {
			intensity_level = intensity;
			~appendLog.value("OK: OVERRIDING INTENSITY");
			~intensityOverride = false;
		}, {
			intensity = intensity_level;
		});


		if (~kitOverride == true,
			{
				~appendLog.value("OK: Kit Override Engaged. Setting Kit to" + kit.asString);
				set_kit = kit;
				~kitOverride = false;
			}, {
				if (next_kit != 0, {
					set_kit = rrand(0, (~buffers.size - 1));
					~appendLog.value("OK: CHANGING KITS");
					kit = set_kit;
				},
				{
					if (kit.notNil == true, {
						set_kit = kit;
						~appendLog.value("OK: ELECTING NOT TO CHANGE KITS");
					});
				});
				if (set_kit == nil, {
					set_kit = rrand(0, (~buffers.size - 1));
					kit = set_kit });
		});

		~appendLog.value("OK: New Event at Intensity" + intensity_level.asString);
		~appendLog.value("OK: New Event using Kit" + set_kit.asString);

		swing = rrand(0.01, 0.55);
		if (next == 4, {swing = 0.01});
		if (next == 2, {swing = 0.01});

		if (intensity_level == 4, { next = rrand (1,3) });

		if (flag, {
			next_event = EventManager.new(seed, intensity_level, set_kit, swing);
		},
		{
			next_event = nil;
		});

		transition = TransitionManager.new();
		transition.transition(current_event, next_event);

		current_event = next_event;

		event_time.minute = event_time.minute + next;
		if(event_time.minute >= 60, {
			event_time.minute = event_time.minute % 60;
			event_time.hour = event_time.hour + 1;
			if (event_time.hour > 23, {
				event_time.hour = 0;
				dayFlag = true; })
		});

		kit_fixed = kit;
		intensity_fixed = intensity_level;
		swing_fixed = swing;

		~appendLog.value("OK: Next Event Will Play At:" + event_time.asString);
	}



	conduct {

		arg seed, server;

		SystemClock.sched(0.0, {

			current_time = Date.getDate;

			if (~timeOverride == true, {
				hour_lock = current_time.hour;
				event_time.hour = (time_override + ((current_time.hour - hour_lock) % 24)) % 24;
				~timeOverride = false;
			});

			if (time_override.notNil == true, {
				current_time.hour = (time_override + ((current_time.hour - hour_lock) % 24)) % 24;
			});

			if (current_time.second % 10 == 0, {

				~appendLog.value( "\n" ++
					"LOG: CURRENT STATUS ------------------ \n" ++
					"SERVER IS RUNNING " ++ server.serverRunning.asString ++ "\n" ++
					"AVG CPU: " ++ server.avgCPU.asString ++ "\n" ++
					"PEAK CPU: " ++ server.peakCPU.asString ++ "\n" ++
					"LATENCY: " ++ server.latency.asString ++ "\n" ++
					"NUMBER OF SYNTHS: " ++ server.numSynths.asString ++ "\n" ++
					"CURRENT MAX NODE: " ++ server.nextNodeID ++ "\n" ++
					"KIT: "  + kit_fixed ++ "\n" ++
					"INTENSITY: "  + intensity_fixed ++ "\n" ++
					"SWING: " + swing_fixed ++ "\n" ++
					"NEXT EVENT: " + event_time ++ "\n" ++
					"--------------------------------------" );
				if (transition.prev_event.notNil,{
					if( transition.prev_event.streaming != Dictionary[],
						{ ~appendLog.value("TRANSITION IN PROGRESS") },
						{ ~appendLog.value("FULLY TRANSITIONED"); });
				});

			});

			if (dayFlag == true, {
				~appendLog.value("WARN: ENDING PATCH");
				Server.killAll;
			},
			{

				if(
					((current_time.hour >= event_time.hour) &&
						(current_time.minute >= event_time.minute)) ||
					(~transitionOverride == true), {

						~transitionOverride = false;

						if (transition.prev_event.notNil, {
							if (((transition.prev_event.streaming == Dictionary[]) &&
								(transition.prev_event.onramping == List[]) &&
								(transition.prev_event.offramping == List[])), {
								~appendLog.value("WORKING: Moving to Next Event");
								this.eventPlayer(seed);
							},
							{
								~apprenLog.value(("WARN: WAITING FOR" + (transition.prev_event.streaming.keys).asString));
							});
						},
						{
							~appendLog.value("WORKING: Moving to First Event");
							this.eventPlayer(seed);
						});

				});

				1;
			});
		});

	}




}
