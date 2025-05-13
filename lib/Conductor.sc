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
		var intensity_level = 0,
		minute = event_time.minute % 13, swing = 0.2, set_kit,
		next = rrand(1,2), next_kit = rrand(0, 2);

		~appendLog.value("\nCONDUCTOR: Starting new event generation");
		~appendLog.value("STATE: Current time: " ++ event_time.asString);
		~appendLog.value("STATE: Time interval: " ++ next.asString ++ " minutes");
		~appendLog.value("STATE: Current minute in cycle: " ++ minute.asString);
		~appendLog.value("STATE: Next kit probability: " ++ next_kit.asString);

		if (((event_time.hour < 11) || (event_time.hour >= 20)), { 
			intensity_level = 0;
			~appendLog.value("TIME: Night/early morning hours (before 11am or after 8pm) - setting base intensity to 0");
		});
		if (((event_time.hour >= 11) && (event_time.hour < 12)), { 
			intensity_level = 0;
			~appendLog.value("TIME: Late morning (11am-12pm) - setting base intensity to 0");
		});
		if (((event_time.hour >= 12) && (event_time.hour < 14)), { 
			intensity_level = 0;
			~appendLog.value("TIME: Early afternoon (12pm-2pm) - setting base intensity to 0");
		});
		if (((event_time.hour >= 14) && (event_time.hour < 17)), { 
			intensity_level = 0;
			~appendLog.value("TIME: Mid afternoon (2pm-5pm) - setting base intensity to 0");
		});
		if (((event_time.hour >= 17) && (event_time.hour < 18)), { 
			intensity_level = 0;
			~appendLog.value("TIME: Early evening (5pm-6pm) - setting base intensity to 0");
		});
		if (((event_time.hour >= 18) && (event_time.hour < 20)), { 
			intensity_level = 0;
			~appendLog.value("TIME: Evening (6pm-8pm) - setting base intensity to 0");
		});

		if (((minute >= 0) && (minute < 4)), { 
			intensity_level = intensity_level + 0;
			~appendLog.value("INTENSITY: Minute cycle 0-3: No intensity addition");
		});
		if (((minute >= 7) && (minute < 11)), { 
			intensity_level = intensity_level + 1;
			~appendLog.value("INTENSITY: Minute cycle 7-10: Adding +1 to intensity (new level: " ++ intensity_level ++ ")");
		});
		if (((minute >= 11) && (minute <= 13)), { 
			intensity_level = intensity_level + 2;
			~appendLog.value("INTENSITY: Minute cycle 11-13: Adding +2 to intensity (new level: " ++ intensity_level ++ ")");
		});

		if (~intensityOverride == true, {
			intensity_level = intensity;
			~appendLog.value("OVERRIDE: Manual intensity override to " ++ intensity.asString);
			~intensityOverride = false;
		}, {
			intensity = intensity_level;
			~appendLog.value("INTENSITY: Using calculated intensity level: " ++ intensity_level.asString);
		});


		if (~kitOverride == true,
			{
				~appendLog.value("OVERRIDE: Manual kit override to " ++ kit.asString);
				set_kit = kit;
				~kitOverride = false;
			}, {
				if (next_kit != 0, {
					set_kit = rrand(0, (~buffers.size - 1));
					~appendLog.value("KIT: Changing from kit " ++ kit.asString ++ " to kit " ++ set_kit.asString);
					kit = set_kit;
				},
				{
					if (kit.notNil == true, {
						set_kit = kit;
						~appendLog.value("KIT: Maintaining current kit: " ++ kit.asString);
					});
				});
				if (set_kit == nil, {
					set_kit = rrand(0, (~buffers.size - 1));
					~appendLog.value("KIT: Initializing first kit to: " ++ set_kit.asString);
					kit = set_kit });
		});

		swing = rrand(0.01, 0.55);
		~appendLog.value("SWING: Initial swing value set to: " ++ swing.asString);
		
		if (next == 2, {
			swing = 0.01;
			~appendLog.value("SWING: Two-minute interval detected - resetting swing to minimal value");
		});

		if (intensity_level == 4, { 
			next = rrand(1,3);
			~appendLog.value("TIMING: Maximum intensity detected - adjusting next interval to: " ++ next.asString);
		});

		if (flag, {
			~appendLog.value("EVENT: Generating new event with EventManager");
			~appendLog.value("PARAMS: Seed=" ++ seed ++ ", Intensity=" ++ intensity_level ++ ", Kit=" ++ set_kit ++ ", Swing=" ++ swing);
			next_event = EventManager.new(seed, intensity_level, set_kit, swing);
		},
		{
			~appendLog.value("EVENT: Flag is false - skipping event generation");
			next_event = nil;
		});

		~appendLog.value("TRANSITION: Initializing new TransitionManager");
		transition = TransitionManager.new();
		~appendLog.value("TRANSITION: Starting transition from current to next event");
		transition.transition(current_event, next_event);

		current_event = next_event;

		event_time.minute = event_time.minute + next;
		if(event_time.minute >= 60, {
			event_time.minute = event_time.minute % 60;
			event_time.hour = event_time.hour + 1;
			~appendLog.value("TIME: Hour rollover - new hour: " ++ event_time.hour.asString);
			if (event_time.hour > 23, {
				event_time.hour = 0;
				dayFlag = true;
				~appendLog.value("TIME: Day complete - setting dayFlag to end patch");
			})
		});

		kit_fixed = kit;
		intensity_fixed = intensity_level;
		swing_fixed = swing;

		~appendLog.value("SCHEDULE: Next event will play at: " ++ event_time.asString);
		~appendLog.value("STATE: Final parameters - Kit:" ++ kit_fixed ++ " Intensity:" ++ intensity_fixed ++ " Swing:" ++ swing_fixed);
	}



	conduct {

		arg seed, server;

		SystemClock.sched(0.0, {

			current_time = Date.getDate;
			~appendLog.value("INFO: Conductor tick - Current time:" + current_time.asString);

			if (~timeOverride == true, {
				hour_lock = current_time.hour;
				event_time.hour = (time_override + ((current_time.hour - hour_lock) % 24)) % 24;
				~appendLog.value("INFO: Time override active - Adjusting to hour:" + event_time.hour.asString);
				~timeOverride = false;
			});

			if (time_override.notNil == true, {
				current_time.hour = (time_override + ((current_time.hour - hour_lock) % 24)) % 24;
				~appendLog.value("INFO: Using overridden time:" + current_time.hour.asString);
			});

			if (current_time.second % 30 == 0, {

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
						{ ~appendLog.value("TRANSITION IN PROGRESS - Active streams:" + transition.prev_event.streaming.keys.asString) },
						{ ~appendLog.value("FULLY TRANSITIONED - All streams complete"); });
				});

			});

			if (dayFlag == true, {
				~appendLog.value("WARN: ENDING PATCH - Day cycle complete");
				Server.killAll;
			},
			{

				if(
					((current_time.hour * 60 + current_time.minute) >=
						(event_time.hour * 60 + event_time.minute)) ||
					(~transitionOverride == true), {

						~transitionOverride = false;

						if (transition.prev_event.notNil, {
							if (((transition.prev_event.streaming == Dictionary[]) &&
								(transition.prev_event.onramping == List[]) &&
								(transition.prev_event.offramping == List[])), {
								~appendLog.value("WORKING: Moving to Next Event - All transitions complete");
								this.eventPlayer(seed);
							},
							{
								~appendLog.value("WARN: Waiting for active transitions -" + (transition.prev_event.streaming.keys).asString);
							});
						},
						{
							~appendLog.value("WORKING: Moving to First Event - No previous event");
							this.eventPlayer(seed);
						});

				});

				1;
			});
		});

	}




}
