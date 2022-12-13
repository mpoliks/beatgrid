PlaybackSchema {

	*new { ^super.new.init() }

	init { }

	interlace_n_arrays {

		arg input_arrays;
		var return, null_size = input_arrays[0].size, err_flag = false;

		input_arrays.size.do {
			arg i;
			if (input_arrays[i].size != null_size,{
				"ERR: Spatial Pattern Size Inconsistency".postln;
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
		arg speaker_array, pattern_length = 2, speakers_per_impulse = 2, add_some_random = true;
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
		atk = (4 / (intensity + 1)),
		rel = (4 / (intensity + 1)),
		hcut = intensity.linlin(0, 4, 400, 20000),
		lcut = intensity.linlin(0, 4, 40, 40),
		amps = Array.fill((pattern.size * modifier), {
			arg i;
			var amp = rrand(~bassLevel / 3, ~bassLevel);
			if (i % pattern.size == 0, { amp = amp * onbeat });
			amp;
		}),


		outs = this.interlace_n_arrays(

			switch(intensity,
			0, {[ this.output_pattern_gen(~atrCeiling_fxLBus, 2, 4, false),
				this.output_pattern_gen(~retAlcove_fxLBus, 2, 8, false) ]},
			1, {[ this.output_pattern_gen(~atrCeiling_fxMBus, 3, 4, false),
				this.output_pattern_gen(~retAlcove_fxLBus, 3, 8, false) ]},
			2, {[ this.output_pattern_gen(~atrCeiling_fxMBus, 3, 4, false),
				this.output_pattern_gen(~retAlcove_fxMBus, 3, 8, false) ]},
			3, {[ this.output_pattern_gen(~atrCeiling_fxSBus, 3, 4, false),
				this.output_pattern_gen(~retAlcove_fxMBus, 3, 8, false) ]},
			4, {[ this.output_pattern_gen(~atrCeiling_fxSBus, 4, 4, false),
				this.output_pattern_gen(~retAlcove_fxSBus, 4, 8, false) ]},
			)

		);

		outs.postln;

		^Pbind(
			\instrument, \playback,
			\dur, Pseq(dur, inf),
			\buf, Pseq(buf, inf),
			\atk, Pwhite(atk / 2, atk),
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
			intensity.linlin(0, 4, 800, 20000),
			intensity.linlin(0, 4, 2000, 20000)),
		kick_altlevel = rrand(~kickLevel / 3, ~kickLevel),
		amps = Array.fill((pattern.size), {
			var temp = [kick_altlevel, ~kickLevel],
			try = rrand(0, 1),
			result = temp[try];
			result;
		}),

		outs = this.interlace_n_arrays(

		switch(intensity,
			0, {[ this.output_pattern_gen(~atrCeiling_fxLBus, 1, 6, false),
				this.output_pattern_gen(~retAlcove_fxLBus, 1, 6, false) ]},
			1, {[ this.output_pattern_gen(~atrCeiling_fxMBus, 1, 6, false),
				this.output_pattern_gen(~retAlcove_fxLBus, 1, 6, false) ]},
			2, {[ this.output_pattern_gen(~atrCeiling_fxMBus, 1, 6, false),
				this.output_pattern_gen(~retAlcove_fxMBus, 1, 6, false) ]},
			3, {[ this.output_pattern_gen(~atrCeiling_fxSBus, 2, 6, false),
				this.output_pattern_gen(~retAlcove_fxMBus, 2, 6, false) ]},
			4, {[ this.output_pattern_gen(~atrCeiling_fxSBus, 2, 6, false),
				this.output_pattern_gen(~retAlcove_fxSBus, 2, 6, false) ]},
			)

		);

		^Pbind(
			\instrument, \playback,
			\dur, Pseq(dur, inf),
			\buf, Pseq(buf, inf),
			\hcut, Pwhite(hcut / 1.3, hcut),
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
			intensity.linlin(0, 4, 800, 20000),
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

		outs = this.interlace_n_arrays(

			switch(intensity,
			0, {[
				this.output_pattern_gen(~atrCeiling_fxLBus, 3, 2, false),
				this.output_pattern_gen(~atrWall_fxLBus, 3, 2, false),
				this.output_pattern_gen(~retCeiling_fxLBus, 3, 2, false),
				this.output_pattern_gen(~retAlcove_fxLBus, 3, 2, false),
				]},
			1, {[
				this.output_pattern_gen(~atrCeiling_fxLBus, 4, 2, false),
				this.output_pattern_gen(~atrWall_fxLBus, 4, 2, false),
				this.output_pattern_gen(~retCeiling_fxLBus, 4, 2, false),
				this.output_pattern_gen(~retAlcove_fxLBus, 4, 2, false),
				]},
			2, {[
				this.output_pattern_gen(~atrCeiling_fxLBus, 5, 2, false),
				this.output_pattern_gen(~atrWall_fxLBus, 5, 2, false),
				this.output_pattern_gen(~retCeiling_fxLBus, 5, 2, true),
				this.output_pattern_gen(~retAlcove_fxLBus, 5, 2, false),
				]},
			3, {[
				this.output_pattern_gen(~atrCeiling_fxLBus, 6, 2, true),
				this.output_pattern_gen(~atrWall_fxLBus, 6, 2, true),
				this.output_pattern_gen(~retCeiling_fxLBus, 6, 2, true),
				this.output_pattern_gen(~retAlcove_fxLBus, 6, 2, false),
				]},
			4, {[
				this.output_pattern_gen(~atrCeiling_fxLBus, 7, 2, true),
				this.output_pattern_gen(~atrWall_fxLBus, 7, 2, true),
				this.output_pattern_gen(~retCeiling_fxLBus, 8, 2, true),
				this.output_pattern_gen(~retAlcove_fxLBus, 8, 2, true),
				]},
			)

		);

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
		hcut = rrand(
			intensity.linlin(0, 4, 800, 20000),
			intensity.linlin(0, 4, 2000, 20000)),
		lcut = intensity.linlin(0, 4, 40, 40),
		amps = Array.fill((pattern.size * modifier), {
			arg i;
			var amp = rrand(~snareLevel / 4, ~snareLevel);
			if (i % pattern.size == 0, { amp = amp * onbeat });
			amp;
		}),

		outs = this.interlace_n_arrays(

			switch(intensity,
			0, {[
				this.output_pattern_gen(~atrCeiling_fxLBus, 3, 2, false),
				this.output_pattern_gen(~atrWall_fxLBus, 3, 2, false),
				this.output_pattern_gen(~retCeiling_fxLBus, 3, 2, false),
				this.output_pattern_gen(~retAlcove_fxLBus, 3, 2, false),
				]},
			1, {[
				this.output_pattern_gen(~atrCeiling_fxLBus, 4, 2, false),
				this.output_pattern_gen(~atrWall_fxLBus, 4, 2, false),
				this.output_pattern_gen(~retCeiling_fxLBus, 4, 2, false),
				this.output_pattern_gen(~retAlcove_fxLBus, 4, 2, false),
				]},
			2, {[
				this.output_pattern_gen(~atrCeiling_fxLBus, 5, 2, false),
				this.output_pattern_gen(~atrWall_fxLBus, 5, 2, false),
				this.output_pattern_gen(~retCeiling_fxLBus, 5, 2, true),
				this.output_pattern_gen(~retAlcove_fxLBus, 5, 2, false),
				]},
			3, {[
				this.output_pattern_gen(~atrCeiling_fxLBus, 6, 2, true),
				this.output_pattern_gen(~atrWall_fxLBus, 6, 2, true),
				this.output_pattern_gen(~retCeiling_fxLBus, 6, 2, true),
				this.output_pattern_gen(~retAlcove_fxLBus, 6, 2, false),
				]},
			4, {[
				this.output_pattern_gen(~atrCeiling_fxLBus, 7, 2, true),
				this.output_pattern_gen(~atrWall_fxLBus, 7, 2, true),
				this.output_pattern_gen(~retCeiling_fxLBus, 8, 2, true),
				this.output_pattern_gen(~retAlcove_fxLBus, 8, 2, true),
				]},
			)

		);


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
		lcut = rrand(
			intensity.linlin(0, 4, 90, 500),
			intensity.linlin(0, 4, 600, 200)),

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

		outs = this.interlace_n_arrays(

			switch(intensity,
			0, {[
				this.output_pattern_gen(~atrCeiling_fxLBus, 3, 2, false),
				this.output_pattern_gen(~atrWall_fxLBus, 3, 2, false),
				this.output_pattern_gen(~retCeiling_fxLBus, 3, 2, false),
				this.output_pattern_gen(~retAlcove_fxLBus, 3, 2, false),
				]},
			1, {[
				this.output_pattern_gen(~atrCeiling_fxLBus, 4, 2, false),
				this.output_pattern_gen(~atrWall_fxLBus, 4, 2, false),
				this.output_pattern_gen(~retCeiling_fxLBus, 4, 2, false),
				this.output_pattern_gen(~retAlcove_fxLBus, 4, 2, false),
				]},
			2, {[
				this.output_pattern_gen(~atrCeiling_fxLBus, 5, 2, false),
				this.output_pattern_gen(~atrWall_fxLBus, 5, 2, false),
				this.output_pattern_gen(~retCeiling_fxLBus, 5, 2, true),
				this.output_pattern_gen(~retAlcove_fxLBus, 5, 2, false),
				]},
			3, {[
				this.output_pattern_gen(~atrCeiling_fxLBus, 6, 2, true),
				this.output_pattern_gen(~atrWall_fxLBus, 6, 2, true),
				this.output_pattern_gen(~retCeiling_fxLBus, 6, 2, true),
				this.output_pattern_gen(~retAlcove_fxLBus, 6, 2, false),
				]},
			4, {[
				this.output_pattern_gen(~atrCeiling_fxLBus, 7, 2, true),
				this.output_pattern_gen(~atrWall_fxLBus, 7, 2, true),
				this.output_pattern_gen(~retCeiling_fxLBus, 8, 2, true),
				this.output_pattern_gen(~retAlcove_fxLBus, 8, 2, true),
				]},
			)

		);


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
		modifier = rrand(1, 4),
		modifier2 = rrand(1, 4),
		modifier3 = rrand(1, 4),
		dur = 60 / (pattern * ~tempo),
		onbeat = rrand(0, 1),
		atk = rrand(~loopLen / 4, ~loopLen / 2),
		rel = rrand(~loopLen / 4, ~loopLen / 2),
		hcut = rrand(800, 20000),
		lcut = rrand(40, 1000),
		pitch = Array.fill(modifier2 * modifier, {
			var temp = [0.25, 0.5, 1.0, 2.0, 4.0],
			try = [0.1, 0.1, 0.7, 0.2, 0.1].windex;
			temp[try];
		}),
		amps = Array.fill((pattern.size * modifier), {
			arg i;
			var amp = rrand(~loopLevel / 3, ~loopLevel);
			if (i % pattern.size == 0, { amp = amp * onbeat });
			amp;
		}),

		outs = this.interlace_n_arrays(

			switch(intensity,
			0, {[
				this.output_pattern_gen(~atrCeiling_fxLBus, 3, 8, false),
				this.output_pattern_gen(~atrWall_fxLBus, 3, 8, false),
				this.output_pattern_gen(~retCeiling_fxLBus, 3, 8, false),
				this.output_pattern_gen(~retAlcove_fxLBus, 3, 8, false),
				]},
			1, {[
				this.output_pattern_gen(~atrCeiling_fxLBus, 4, 8, false),
				this.output_pattern_gen(~atrWall_fxLBus, 4, 8, false),
				this.output_pattern_gen(~retCeiling_fxLBus, 4, 8, false),
				this.output_pattern_gen(~retAlcove_fxLBus, 4, 8, false),
				]},
			2, {[
				this.output_pattern_gen(~atrCeiling_fxLBus, 5, 8, false),
				this.output_pattern_gen(~atrWall_fxLBus, 5, 8, false),
				this.output_pattern_gen(~retCeiling_fxLBus, 5, 8, true),
				this.output_pattern_gen(~retAlcove_fxLBus, 5, 8, false),
				]},
			3, {[
				this.output_pattern_gen(~atrCeiling_fxLBus, 6, 8, true),
				this.output_pattern_gen(~atrWall_fxLBus, 6, 8, true),
				this.output_pattern_gen(~retCeiling_fxLBus, 6, 8, true),
				this.output_pattern_gen(~retAlcove_fxLBus, 6, 8, false),
				]},
			4, {[
				this.output_pattern_gen(~atrCeiling_fxLBus, 7, 8, true),
				this.output_pattern_gen(~atrWall_fxLBus, 7, 8, true),
				this.output_pattern_gen(~retCeiling_fxLBus, 8, 8, true),
				this.output_pattern_gen(~retAlcove_fxLBus, 8, 8, true),
				]},
			)

		);

		outs.postln;

		^Pbind(
			\instrument, \playbackP,
			\dur, Pseq(dur, inf),
			\buf, Pseq(buf, inf),
			\atk, Pwhite(atk / 2, atk),
			\rel, Pwhite(rel / 2, rel),
			\repitch, Pseq(pitch, inf),
			\hcut, Pwhite(hcut / 2, hcut),
			\lcut, Pwhite(lcut / 2, lcut),
			\amp, Pseq(amps, inf),
			\out, Pseq(outs, inf)
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
		modifier2 = rrand(1, 4),
		modifier3 = rrand(1, 4),
		dur = 60 / (pattern * ~tempo),
		onbeat = rrand(0, 1),
		hcut = rrand(800, 20000),
		lcut = rrand(40, 1000),
		pitch = Array.fill(modifier2 * modifier, {
			var temp = [0.25, 0.5, 1.0, 2.0, 4.0],
			try = [0.1, 0.1, 0.7, 0.2, 0.1].windex;
			temp[try];
		}),
		amps = Array.fill((pattern.size * modifier), {
			arg i;
			var amp = rrand(~hitLevel / 1.3, ~hitLevel);
			if (i % pattern.size == 0, { amp = amp * onbeat });
			amp;
		}),

		outs = this.interlace_n_arrays(

			switch(intensity,
			0, {[
				this.output_pattern_gen(~atrCeiling_fxLBus, 3, 3, false),
				this.output_pattern_gen(~atrWall_fxLBus, 3, 3, false),
				this.output_pattern_gen(~retCeiling_fxLBus, 3, 3, false),
				this.output_pattern_gen(~retAlcove_fxLBus, 3, 3, false),
				]},
			1, {[
				this.output_pattern_gen(~atrCeiling_fxLBus, 4, 2, false),
				this.output_pattern_gen(~atrWall_fxLBus, 4, 2, false),
				this.output_pattern_gen(~retCeiling_fxLBus, 4, 2, false),
				this.output_pattern_gen(~retAlcove_fxLBus, 4, 2, false),
				]},
			2, {[
				this.output_pattern_gen(~atrCeiling_fxLBus, 5, 2, false),
				this.output_pattern_gen(~atrWall_fxLBus, 5, 2, false),
				this.output_pattern_gen(~retCeiling_fxLBus, 5, 2, true),
				this.output_pattern_gen(~retAlcove_fxLBus, 5, 2, false),
				]},
			3, {[
				this.output_pattern_gen(~atrCeiling_fxLBus, 6, 2, true),
				this.output_pattern_gen(~atrWall_fxLBus, 6, 2, true),
				this.output_pattern_gen(~retCeiling_fxLBus, 6, 2, true),
				this.output_pattern_gen(~retAlcove_fxLBus, 6, 2, false),
				]},
			4, {[
				this.output_pattern_gen(~atrCeiling_fxLBus, 7, 2, true),
				this.output_pattern_gen(~atrWall_fxLBus, 7, 2, true),
				this.output_pattern_gen(~retCeiling_fxLBus, 8, 2, true),
				this.output_pattern_gen(~retAlcove_fxLBus, 8, 2, true),
				]},
			)

		);

		^Pbind(
			\instrument, \playbackP,
			\dur, Pseq(dur, inf),
			\buf, Pseq(buf, inf),
			\repitch, Pseq(pitch, inf),
			\hcut, Pwhite(hcut / 2, hcut),
			\lcut, Pwhite(lcut / 2, lcut),
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
			var temp = [0.25, 0.5, 1.0, 2.0, 4.0],
			try = [0.2, 0.4, 0.2, 0.4, 0.2].windex;
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

		outs = this.interlace_n_arrays(

			switch(intensity,
			0, {[
				this.output_pattern_gen(~atrCeiling_fxLBus, 3, 2, false),
				this.output_pattern_gen(~atrWall_fxLBus, 3, 2, false),
				this.output_pattern_gen(~retCeiling_fxLBus, 3, 2, false),
				this.output_pattern_gen(~retAlcove_fxLBus, 3, 2, false),
				]},
			1, {[
				this.output_pattern_gen(~atrCeiling_fxLBus, 4, 2, false),
				this.output_pattern_gen(~atrWall_fxLBus, 4, 2, false),
				this.output_pattern_gen(~retCeiling_fxLBus, 4, 2, false),
				this.output_pattern_gen(~retAlcove_fxLBus, 4, 2, false),
				]},
			2, {[
				this.output_pattern_gen(~atrCeiling_fxLBus, 5, 2, false),
				this.output_pattern_gen(~atrWall_fxLBus, 5, 2, false),
				this.output_pattern_gen(~retCeiling_fxLBus, 5, 2, true),
				this.output_pattern_gen(~retAlcove_fxLBus, 5, 2, false),
				]},
			3, {[
				this.output_pattern_gen(~atrCeiling_fxLBus, 6, 2, true),
				this.output_pattern_gen(~atrWall_fxLBus, 6, 2, true),
				this.output_pattern_gen(~retCeiling_fxLBus, 6, 2, true),
				this.output_pattern_gen(~retAlcove_fxLBus, 6, 2, false),
				]},
			4, {[
				this.output_pattern_gen(~atrCeiling_fxLBus, 7, 2, true),
				this.output_pattern_gen(~atrWall_fxLBus, 7, 2, true),
				this.output_pattern_gen(~retCeiling_fxLBus, 8, 2, true),
				this.output_pattern_gen(~retAlcove_fxLBus, 8, 2, true),
				]},
			)

		);

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

		("WORKING: Generating Schemas for" + instrument.asString).postln;

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
