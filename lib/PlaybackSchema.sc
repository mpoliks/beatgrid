PlaybackSchema {

	*new { ^super.new.init() }

	init { }

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
		pans = Array.fill((pattern.size * modifier2), {
			rrand(-0.3, 0.3);
		}),
		outs = Array.fill((modifier2 * modifier3), {
			var temp = switch (intensity,
				0, {~fxMBus!modifier ++ ~fxLBus!modifier2},
				1, {~fxMBus!modifier ++ ~fxLBus!modifier2},
				2, {~fxSBus!modifier ++ ~fxMBus!modifier2},
				3, {~fxSBus!modifier ++ ~fxMBus!modifier2},
				4, {~fxSBus!modifier ++ ~dryBus!modifier2},
			),
			result = temp.scramble[0];
			result;
		});

		^Pbind(
			\instrument, \playback,
			\dur, Pseq(dur, inf),
			\buf, Pseq(buf, inf),
			\atk, Pwhite(atk / 2, atk),
			\rel, Pwhite(rel / 2, rel),
			\hcut, Pwhite(hcut / 2, hcut),
			\lcut, Pwhite(lcut / 2, lcut),
			\amp, Pseq(amps, inf),
			\pan, Pseq(pans, inf),
			\out, Pseq(outs, inf)
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
		outs = Array.fill((modifier2 * modifier3), {
			var temp = switch (intensity,
				0, {(~fxMBus!modifier) ++ (~fxMBus!modifier2)},
				1, {(~fxMBus!modifier) ++ (~fxMBus!modifier2)},
				2, {(~fxMBus!modifier) ++ (~fxMBus!modifier2)},
				3, {(~fxMBus!modifier) ++ (~fxMBus!modifier2)},
				4, {(~fxMBus!modifier) ++ (~dryBus!modifier2)},
			),
			result = temp.scramble[0];
			result;
		});

		^Pbind(
			\instrument, \playback,
			\dur, Pseq(dur, inf),
			\buf, Pseq(buf, inf),
			\hcut, Pwhite(hcut / 1.3, hcut),
			\amp, Pseq(amps, inf),
			\pan, 0,
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
			var amp = rrand(~clapLevel / 3, ~clapLevel);
			if (i % pattern.size == 0, { amp = amp * onbeat });
			amp;
		}),
		pans = Array.fill((pattern.size * modifier2), {
			rrand(-1.0, 1.0);
		}),
		outs = Array.fill((modifier2 * modifier3), {
			var temp = switch (intensity,
				0, {~fxMBus!modifier ++ ~fxLBus!modifier2},
				1, {~fxMBus!modifier ++ ~fxLBus!modifier2},
				2, {~fxSBus!modifier ++ ~fxMBus!modifier2},
				3, {~fxSBus!modifier ++ ~fxMBus!modifier2},
				4, {~fxSBus!modifier ++ ~dryBus!modifier2},
			),
			result = temp.scramble[0];
			result;
		});

		^Pbind(
			\instrument, \playback,
			\dur, Pseq(dur, inf),
			\buf, Pseq(buf, inf),
			\hcut, Pwhite(hcut / 2, hcut),
			\lcut, Pwhite(lcut / 2, lcut),
			\amp, Pseq(amps, inf),
			\pan, Pseq(pans, inf),
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
			var amp = rrand(~snareLevel / 3, ~snareLevel);
			if (i % pattern.size == 0, { amp = amp * onbeat });
			amp;
		}),
		pans = Array.fill((pattern.size * modifier2), {
			rrand(-0.4, 0.4);
		}),
		outs = Array.fill((modifier2 * modifier3), {
			var temp = switch (intensity,
				0, {~fxMBus!modifier ++ ~fxLBus!modifier2},
				1, {~fxMBus!modifier ++ ~fxLBus!modifier2},
				2, {~fxSBus!modifier ++ ~fxMBus!modifier2},
				3, {~fxSBus!modifier ++ ~fxMBus!modifier2},
				4, {~fxSBus!modifier ++ ~dryBus!modifier2},
			),
			result = temp.scramble[0];
			result;
		});

		^Pbind(
			\instrument, \playback,
			\dur, Pseq(dur, inf),
			\buf, Pseq(buf, inf),
			\hcut, Pwhite(hcut / 2, hcut),
			\lcut, Pwhite(lcut / 2, lcut),
			\amp, Pseq(amps, inf),
			\pan, Pseq(pans, inf),
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
		hcut = rrand(
			intensity.linlin(0, 4, 800, 20000),
			intensity.linlin(0, 4, 2000, 20000)),
		lcut = rrand(
			intensity.linlin(0, 4, 90, 500),
			intensity.linlin(0, 4, 600, 200)),
		envScl = pattern.size * 32 * modifier2 * modifier3,
		env = (Array.series(envScl, 0.0, 1.0 / envScl)) ++
			(Array.series(envScl, 1.0, -1.0 / envScl)),
		amps = Array.fill((envScl), {
			arg i;
			var amp = rrand(~hatLevel / 1.1, ~hatLevel);
			if (modifier <= 2, { amp = amp * env[i];  });
			if (i % pattern.size == 0, { amp = amp * onbeat });
			amp;
		}),
		pans = Array.fill((pattern.size * modifier2), {
			rrand(-0.3, 0.3);
		}),
		outs = Array.fill((modifier2 * modifier3), {
			var temp = switch (intensity,
				0, {~fxSBus!modifier ++ ~fxMBus!modifier2},
				1, {~fxSBus!modifier ++ ~fxMBus!modifier2},
				2, {~fxSBus!modifier ++ ~fxMBus!modifier2},
				3, {~fxSBus!modifier ++ ~fxSBus!modifier2},
				4, {~fxSBus!modifier ++ ~dryBus!modifier2},
			),
			result = temp.scramble[0];
			result;
		});

		^Pbind(
			\instrument, \playback,
			\dur, Pseq(dur, inf),
			\buf, Pseq(buf, inf),
			\hcut, Pwhite(hcut / 2, hcut),
			\lcut, Pwhite(lcut / 2, lcut),
			\amp, Pseq(amps, inf),
			\pan, Pseq(pans, inf),
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
		pans = Array.fill((pattern.size * modifier2), {
			rrand(-0.8, 0.8);
		}),
		outs = Array.fill((modifier2 * modifier3), {
			var temp = switch (intensity,
				0, {~fxMBus!modifier ++ ~fxLBus!modifier2},
				1, {~fxMBus!modifier ++ ~fxLBus!modifier2},
				2, {~fxSBus!modifier ++ ~fxMBus!modifier2},
				3, {~fxSBus!modifier ++ ~fxMBus!modifier2},
				4, {~fxSBus!modifier ++ ~fxMBus!modifier2},
			),
			result = temp.scramble[0];
			result;
		});

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
			\pan, Pseq(pans, inf),
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
		pans = Array.fill((pattern.size * modifier2), {
			rrand(-0.8, 0.8);
		}),
		outs = Array.fill((modifier2 * modifier3), {
			var temp = switch (intensity,
				0, {~fxMBus!modifier ++ ~fxLBus!modifier2},
				1, {~fxMBus!modifier ++ ~fxLBus!modifier2},
				2, {~fxSBus!modifier ++ ~fxMBus!modifier2},
				3, {~fxSBus!modifier ++ ~fxMBus!modifier2},
				4, {~fxSBus!modifier ++ ~fxMBus!modifier2},
			),
			result = temp.scramble[0];
			result;
		});

		^Pbind(
			\instrument, \playbackP,
			\dur, Pseq(dur, inf),
			\buf, Pseq(buf, inf),
			\repitch, Pseq(pitch, inf),
			\hcut, Pwhite(hcut / 2, hcut),
			\lcut, Pwhite(lcut / 2, lcut),
			\amp, Pseq(amps, inf),
			\pan, Pseq(pans, inf),
			\out, Pseq(outs, inf)
			);
	}

	go {
		arg pattern, instrument, intensity, key;
		var dir, pbind;

		("WORKING: Generating Schemas for" + instrument.asString).postln;
		if ((instrument.asString != "bass") && (instrument.asString != "loop") && (instrument.asString != "hit"),
			{ dir = ~buffers.at(instrument.asString).at(intensity); },
			{ dir = ~buffers.at(instrument.asString).at(key.asString).at(intensity); });

		pbind = switch (instrument,
			\bass, {this.bass(pattern, intensity, dir)},
			\kick, {this.kick(pattern, intensity, dir)},
			\clap, {this.clap(pattern, intensity, dir)},
			\snare, {this.snare(pattern, intensity, dir)},
			\hat, {this.hat(pattern, intensity, dir)},
			\loop, {this.loop(pattern, intensity, dir)},
			\hit, {this.hit(pattern, intensity, dir)}
		);

		^pbind;

	}

}
