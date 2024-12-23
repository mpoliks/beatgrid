PlaybackSchema {

	*new { ^super.new.init() }

	init { }

	interlace_n_arrays {

		arg input_arrays;
		var return, null_size = input_arrays[0].size, err_flag = false;

		input_arrays.size.do {
			arg i;
			if (input_arrays[i].size != null_size,{
				~appendLog.value("ERR: Spatial Pattern Size Inconsistency");
				err_flag = true; }); };

		if (err_flag == false, {
			return = Array.fill(null_size, {
				arg patt_step; var temp = Array.newClear;
				input_arrays.size.do({
					arg array_step;
					temp = temp ++ input_arrays[array_step][patt_step];
				});
				temp;
			});
		});

		^return;
	}

	output_pattern_gen {
		arg speaker_array, pattern_length = 2, speakers_per_impulse = 2, add_some_random = true, velocity = 1;
		var array_size = speaker_array.size - 1, result;

		result = Array.fill(pattern_length, {
			var temp_speaker_array = speaker_array.scramble,
			temp_speakers_per_impulse = speakers_per_impulse;
			if (add_some_random == true, {
				temp_speakers_per_impulse = rrand(1, speakers_per_impulse) });

			Array.fill(temp_speakers_per_impulse, {
				arg c;
				temp_speaker_array[c];
			});

		});

		result = result.dupEach(velocity);

		^result;
	}

	bass {
		arg pattern, intensity, dir;
		var buffer_variation = rrand(1, ((intensity + 1) * 4)),
		buf = Array.fill(buffer_variation, {
			arg i;
			dir.scramble[0];
		}),
		modifier = rrand(1, 4),
		modifier2 = rrand(1, 4),
		modifier3 = rrand(1, 4),
		dur = 60 / (pattern * ~tempo),
		onbeat = rrand(0, 1),
		atk = 0.1,
		rel = (4 / (intensity + 1)),
		hcut = intensity.linlin(0, 4, 1250, 20000),
		lcut = intensity.linlin(0, 4, 40, 40),
		amps = Array.fill((pattern.size * modifier), {
			arg i;
			var amp = rrand(~bassLevel / 2, ~bassLevel);
			if (i % pattern.size == 0, { amp = amp * onbeat });
			amp;
		}),

		outs = switch (~mixdown,

			\stereo, {[[0, 1]]},
			\stem, {[0]},
			\false, {[~instrumentBuses[\bass][\dryBus].index]});

		~appendLog.value("OK: Bass Buffers: " ++ buf.asString);


		^Pbind(
			\instrument, \playback,
			\dur, Pseq(dur, inf),
			\buf, Pseq(buf, inf),
			\atk, Pwhite(atk / 2, atk * 2),
			\rel, Pwhite(rel / 2, rel),
			\hcut, Pwhite(hcut / 2, hcut),
			\lcut, Pwhite(lcut / 2, lcut),
			\amp, Pseq(amps, inf),
			\out, Pseq(outs, inf);
		);
	}

	kick {
		arg pattern, intensity, dir;
		var buffer_variation = rrand(1, (intensity + 1)),
		buf = Array.fill(buffer_variation, {
			arg i;
			dir.scramble[0];
		}),
		dur = 60 / (pattern * ~tempo),
		modifier = rrand(1, 4),
		modifier2 = rrand(1, 4),
		modifier3 = rrand(1, 4),
		hcut = rrand(
			intensity.linlin(0, 4, 2000, 10000),
			intensity.linlin(0, 4, 2000, 20000)),
		kick_altlevel = rrand(~kickLevel / 3, ~kickLevel / 1.5),
		amps = Array.fill((pattern.size), {
			var temp = [kick_altlevel, ~kickLevel],
			try = rrand(0, 1),
			result = temp[try];
			result;
		}),

		outs = switch (~mixdown,

			\stereo, {[[0, 1]]},
			\stem, {[1]},
			\false, {[~instrumentBuses[\kick][\dryBus]]});

		~appendLog.value("OK: Kick Buffers: " ++ buf.asString);

		^Pbind(
			\instrument, \playback,
			\dur, Pseq(dur, inf),
			\buf, Pseq(buf, inf),
			\hcut, Pwhite(hcut / 1.3, hcut),
			\atk, 0.06,
			\amp, Pseq(amps, inf),
			\out, Pseq(outs, inf)
		);
	}

	clap {
		arg pattern, intensity, dir;
		var buffer_variation = rrand(1, ((intensity + 3) * 4)),
		buf = Array.fill(buffer_variation, {
			arg i;
			dir.scramble[0];
		}),
		modifier = rrand(1, 4),
		modifier2 = rrand(1, 4),
		modifier3 = rrand(1, 4),
		dur = 60 / (pattern * ~tempo),
		onbeat = rrand(0, 1),
		hcut = rrand(
			intensity.linlin(0, 4, 800, 16000),
			intensity.linlin(0, 4, 2000, 20000)),
		lcut = rrand(
			intensity.linlin(0, 4, 90, 500),
			intensity.linlin(0, 4, 600, 200)),
		amps = Array.fill((pattern.size * modifier), {
			arg i;
			var amp = rrand(~clapLevel / 4, ~clapLevel);
			if (i % pattern.size == 0, { amp = amp * onbeat });
			amp;
		}),

		outs = switch (~mixdown,

			\stereo, {Array.fill(16, {rrand(0,1)})},
			\stem, {[2]},
			\false, {[~instrumentBuses[\clap][\dryBus]]});

		~appendLog.value("OK: Clap Buffers: " ++ buf.asString);

		^Pbind(
			\instrument, \playback,
			\dur, Pseq(dur, inf),
			\buf, Pseq(buf, inf),
			\hcut, Pwhite(hcut / 2, hcut),
			\lcut, Pwhite(lcut / 2, lcut),
			\amp, Pseq(amps, inf),
			\out, Pseq(outs, inf)
		);
	}

	snare {
		arg pattern, intensity, dir;
		var buffer_variation = rrand(1, ((intensity + 3))),
		buf = Array.fill(buffer_variation, {
			arg i;
			dir.scramble[0];
		}),
		modifier = rrand(1, 4),
		modifier2 = rrand(1, 4),
		modifier3 = rrand(1, 4),
		dur = 60 / (pattern * ~tempo),
		onbeat = rrand(0, 1),
		hcut = rrand(600, 1000),
		lcut = rrand(80, 200),
		amps = Array.fill((pattern.size * modifier), {
			arg i;
			var amp = rrand(~snareLevel / 4, ~snareLevel);
			if (i % pattern.size == 0, { amp = amp * onbeat });
			amp;
		}),

		outs = switch (~mixdown,

			\stereo, {Array.fill(8, {rrand(0,1)})},
			\stem, {[3]},
			\false, {[~instrumentBuses[\snare][\dryBus].index]});

		~appendLog.value("OK: Snare Buffers: " ++ buf.asString);

		^Pbind(
			\instrument, \playback,
			\dur, Pseq(dur, inf),
			\buf, Pseq(buf, inf),
			\hcut, Pwhite(hcut / 2, hcut),
			\lcut, Pwhite(lcut / 2, lcut),
			\amp, Pseq(amps, inf),
			\out, Pseq(outs, inf)
		);
	}

	hat {
		arg pattern, intensity, dir;
		var buffer_variation = rrand(1, ((intensity + 3) * 4)),
		buf = Array.fill(buffer_variation, {
			arg i;
			dir.scramble[0];
		}),
		modifier = rrand(1, 4),
		modifier2 = rrand(1, 4),
		modifier3 = rrand(1, 4),
		dur = 60 / (pattern * ~tempo),
		onbeat = rrand(0, 1),
		lcut = rrand(800, 1000),

		envScl = pattern.size * 32 * modifier2 * modifier3,
		env = (Array.series(envScl, 0.0, 1.0 / envScl)) ++
		(Array.series(envScl, 1.0, -1.0 / envScl)),

		amps = Array.fill((envScl * 2), {
			arg i;
			var amp = rrand(~hatLevel / 1.1, ~hatLevel);
			if (modifier <= 2, { amp = amp * env[i];  });
			if (i % pattern.size == 0, { amp = amp * onbeat });
			amp;
		}),

		envScl2 = 128 * modifier2 * modifier3,

		env2 = ((Array.series(envScl2, 0.0, 1.0 / envScl2)) ++
			(Array.series(envScl2, 1.0, -1.0 / envScl2)) * 16000),

		hcuts = Array.fill((envScl2 * 2), {
			arg i;
			var cut = 1000 + env2[i];
			cut;
		}),

		outs = switch (~mixdown,

			\stereo, {Array.fill(4, {[0, 1, [0, 1]].choose([0.2, 0.2, 0.6])})},
			\stem, {[4]},
			\false, {[~instrumentBuses[\hat][\dryBus]]});

		~appendLog.value("OK: Hat Buffers: " ++ buf.asString);

		^Pbind(
			\instrument, \playback,
			\dur, Pseq(dur, inf),
			\buf, Pseq(buf, inf),
			\hcut, Pseq(hcuts, inf),
			\lcut, Pwhite(lcut / 2, lcut),
			\amp, Pseq(amps, inf),
			\out, Pseq(outs, inf)
		);
	}

	loop {
		arg pattern, intensity, dir;
		var buffer_variation = rrand(1, ((intensity + 1) * 4)),
		buf = Array.fill(buffer_variation, {
			arg i;
			dir.scramble[0];
		}),
		dur = 60 / (pattern * ~tempo),
		atk = rrand(3, 10),
		rel = rrand(5, 10),
		loop_ratio = ((48!7) ++ (96!4)).scramble,
		env_atk = rrand(~loopLen / 8, ~loopLen / 2),
		env_rel = rrand(~loopLen / 8, ~loopLen / 2),
		out = switch (~mixdown,
			\stereo, {0},
			\stem, {7},
			\blackhole, {0},
			\false, {[~instrumentBuses[\loop][\dryBus]]});

		~appendLog.value("OK: Loop Buffers: " ++ buf.asString);

		^Pbind(
			\instrument, \playbackLoop,
			\dur, Pseq(loop_ratio, inf),
			\buf, Pseq(buf, inf),
			\atk, atk,
			\rel, rel,
			\env_atk, env_atk,
			\env_rel, env_rel,
			\amp, ~loopLevel,
			\out, out
		);
	}

	hit {
		arg pattern, intensity, dir;
		var buffer_variation = rrand(1, ((intensity + 1) * 4)),
		buf = Array.fill(buffer_variation, {
			arg i;
			dir.scramble[0];
		}),
		modifier = rrand(1, 4),
		modifier2 = rrand(1, 6),
		modifier3 = rrand(1, 4),
		dur = 60 / (pattern * ~tempo),
		onbeat = rrand(0, 1),
		hcut = rrand(800, 10000),
		lcut = rrand(40, 1000),
		/*pitch = Array.fill(modifier2 * modifier, {
			var temp = [1.0, 1.125, 1.25],
			try = [0.2, 0.2, 0.2].windex;
			temp[try];
		}),*/
		amps = Array.fill((pattern.size * modifier), {
			arg i;
			var amp = rrand(~hitLevel / 1.3, ~hitLevel);
			if (i % pattern.size == 0, { amp = amp * onbeat });
			amp;
		}),

		outs = switch (~mixdown,

			\stereo, {Array.fill(4, {[0, 1, [0, 1]].choose([0.2, 0.2, 0.6])})},
			\stem, {[5]},
			\false, {[~instrumentBuses[\hit][\dryBus]]});

		~appendLog.value("OK: Hit Buffers: " ++ buf.asString);

		^Pbind(
			\instrument, \playbackP,
			\dur, Pseq(dur, inf),
			\buf, Pseq(buf, inf),
			//\repitch, Pseq(pitch, inf),
			\hcut, Pwhite(hcut / 2, hcut),
			\lcut, Pwhite(lcut / 2, lcut),
			\atk, Pwhite(0.01, 1.0),
			\rel, Pwhite(1, 10),
			\amp, Pseq(amps, inf),
			\out, Pseq(outs, inf)
		);
	}

	misc {
		arg pattern, intensity, dir;
		var buffer_variation = rrand(2, ((intensity + 2) * 4)),
		buf = Array.fill(buffer_variation, {
			arg i;
			dir.scramble[0];
		}),
		modifier = rrand(1, 4),
		modifier2 = rrand(1, 4),
		modifier3 = rrand(1, 4),
		dur = 60 / (pattern * ~tempo),
		onbeat = rrand(0, 1),
		hcut = rrand(800, 14000),
		lcut = rrand(40, 4000),
		pitch = Array.fill(modifier2 * modifier, {
			var temp = [1.0, 1.0, 1.125, 1.25, 1.333, 1.5, 1.667, 1.875],
			try = [0.2, 0.6, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2].windex;
			temp[try];
		}),

		envScl = 128 * modifier2 * modifier3,

		env = ((Array.series(envScl, 0.0, 1.0 / envScl)) ++
			(Array.series(envScl, 1.0, -1.0 / envScl)) * 16000),

		hcuts = Array.fill((envScl * 2), {
			arg i;
			var cut = 1000 + env[i];
			cut;
		}),

		amps = Array.fill((pattern.size * modifier), {
			arg i;
			var amp = rrand(~miscLevel / 2.0, ~miscLevel);
			if (i % pattern.size == 0, { amp = amp * onbeat });
			amp;
		}),

		outs = switch (~mixdown,

			\stereo, {Array.fill(4, {[0, 1, [0, 1]].choose([0.2, 0.2, 0.6])})},
			\stem, {[6]},
			\false, {[~instrumentBuses[\misc][\dryBus]]});

		~appendLog.value("OK: Misc Buffers: " ++ buf.asString);

		^Pbind(
			\instrument, \playbackP,
			\dur, Pseq(dur, inf),
			\buf, Pseq(buf, inf),
			\repitch, Pseq(pitch, inf),
			\hcut, Pseq(hcuts, inf),
			\lcut, Pwhite(lcut / 2, lcut),
			\amp, Pseq(amps, inf),
			\out, Pseq(outs, inf)
		);
	}

	go {
		arg pattern, instrument, intensity, kit;
		var dir, pbind;

		~appendLog.value(("WORKING: Generating Schemas for" + instrument.asString));

		dir = ~buffers.at(kit.asString).at(instrument.asString);

		pbind = switch (instrument,
			\bass, {this.bass(pattern, intensity, dir)},
			\kick, {this.kick(pattern, intensity, dir)},
			\clap, {this.clap(pattern, intensity, dir)},
			\snare, {this.snare(pattern, intensity, dir)},
			\hat, {this.hat(pattern, intensity, dir)},
			\loop, {this.loop(pattern, intensity, dir)},
			\hit, {this.hit(pattern, intensity, dir)},
			\misc, {this.misc(pattern, intensity, dir)}
		);

		^pbind;

	}

}
