PatternGen {

	*new { ^super.new.init() }

	init { }

	interpret {
		arg to_process;
		var counter = 0, temp = List.new();

		to_process.size.do({
			arg i;
			if (to_process[i] == 0, {
				counter = counter + 1;
			},
			{
			if (counter != 0, {temp.add(counter)});
			counter = 0;
			});
		});

		^temp;
	}

	model_weights {
		arg to_process;
		var weights = List.new();

		to_process.size.do({
			arg i;
			var temp = ((i + 1)!(to_process.size + 1));
			to_process.size.do({
				arg l;
				if (l % 2 == 0,
					{ temp.add(i + l)},
					{temp.add(i - l)});
			});
		weights.add([i, temp.asArray]);
		});

		weights = weights.asArray.abs % to_process.size;

		^MarkovSet(weights);
	}

	interpolate {
		arg to_process, seed;
		var stream, raw = List.new();

		to_process.makeSeeds;
		stream = to_process.asStream;
		seed.size.do({arg i; stream.next(i)});
		seed.size.do({arg l; raw.add(seed[stream.next(l)])});

		^raw;
	}

	time_process {
		arg pattern_;
		var tempo_values = List.new();

		pattern_.size.do({
			arg k;
			tempo_values.add(
					1/((pattern_[k] * 0.25)))
			});

		^tempo_values.asArray;
	}

	//----------------------------------------------KICK
	kick_pattern {
		arg pattern, intensity;
		var return_, scale = 1;
		switch (intensity,

			0, {
				var choose = rrand(1,2),
					choose_ = rrand(0, choose),
				temp = pattern.reshape(choose);
				if (temp.sum % 32.0 != 0.0, {
					temp = temp.insert(choose_,
						32.0 - (temp.sum % 32.0))});
				return_ = temp * 4;
				scale = 2;
			},

			1, {
				var choose = rrand(1,3),
					choose_ = rrand(0, choose),
				temp = pattern.reshape(choose);
				if (temp.sum < 8.0, {
					temp = temp ++ temp;
				});
				if (temp.sum % 16.0 != 0.0, {
					temp = temp.insert(choose_,
						16.0 - (temp.sum % 16.0))});
				return_ = temp * 4;
				scale = 2;
			},

			2, {
				var choose = rrand(1,3),
					choose_ = rrand(0, choose),
				temp = pattern.reshape(choose);
				if (temp.sum < 8.0, {
					temp = temp ++ temp;
				});
				if (temp.sum % 16.0 != 0.0, {
					temp = temp.insert(choose_,
						16.0 - (temp.sum % 16.0))});
				return_ = temp * 2;
			},

			3, {
				var choose = rrand(1,pattern.size),
					choose_ = rrand(0, choose),
				temp = pattern.reshape(choose);
				if (temp.sum < 8.0, {
					temp = temp ++ temp;
				});
				if (temp.sum % 16.0 != 0.0, {
					temp = temp.insert(choose_,
						16.0 - (temp.sum % 16.0))});
				return_ = temp * 2;
			},

			4, {
				var choose = rrand(1,pattern.size),
					choose_ = rrand(0, choose),
				temp = pattern.reshape(choose);
				if (temp.sum < 8.0, {
					temp = temp ++ temp;
				});
				if (temp.sum % 16.0 != 0.0, {
					temp = temp.insert(choose_,
						16.0 - (temp.sum % 16.0))});
				return_ = temp;
			},
		);

		return_ = [[8.0, 8.0] * scale,
			[4.0, 4.0] * scale, [4.0, 2.0, 2.0] * scale,
			[2.0, 2.0] * scale,
			return_, return_, return_];
		return_ = return_[rrand(0, 6)];

		^return_;
	}


	//----------------------------------------------BASS
	bass_pattern {
		arg pattern, intensity;
		var return_, scale = 1;
		switch (intensity,

			0, {
				var choose = rrand(1,2),
					choose_ = rrand(0, choose),
				temp = pattern.reshape(choose);
				if (temp.sum % 32.0 != 0.0, {
					temp = temp.insert(choose_,
						32.0 - (temp.sum % 32.0))});
				return_ = temp * 4;
				scale = 2;
			},

			1, {
				var choose = rrand(1,3),
					choose_ = rrand(0, choose),
				temp = pattern.reshape(choose);
				if (temp.sum < 8.0, {
					temp = temp ++ temp;
				});
				if (temp.sum % 16.0 != 0.0, {
					temp = temp.insert(choose_,
						16.0 - (temp.sum % 16.0))});
				return_ = temp * 4;
				scale = 2;
			},

			2, {
				var choose = rrand(1,3),
					choose_ = rrand(0, choose),
				temp = pattern.reshape(choose);
				if (temp.sum < 8.0, {
					temp = temp ++ temp;
				});
				if (temp.sum % 16.0 != 0.0, {
					temp = temp.insert(choose_,
						16.0 - (temp.sum % 16.0))});
				return_ = temp * 2;
			},

			3, {
				var choose = rrand(1,pattern.size),
					choose_ = rrand(0, choose),
				temp = pattern.reshape(choose);
				if (temp.sum < 8.0, {
					temp = temp ++ temp;
				});
				if (temp.sum % 16.0 != 0.0, {
					temp = temp.insert(choose_,
						16.0 - (temp.sum % 16.0))});
				return_ = temp * 2;
			},

			4, {
				var choose = rrand(1,pattern.size),
					choose_ = rrand(0, choose),
				temp = pattern.reshape(choose);
				if (temp.sum < 8.0, {
					temp = temp ++ temp;
				});
				if (temp.sum % 16.0 != 0.0, {
					temp = temp.insert(choose_,
						16.0 - (temp.sum % 16.0))});
				return_ = temp;
			},
		);

		return_ = [[4.0, 8.0, 4.0] * scale, [6.0, 2.0] * scale, [1.0, 7.0] * scale, return_, return_, return_];
		return_ = return_[rrand(0, 5)];

		^return_;
	}

	//----------------------------------------------LONG
	long_pattern {
		arg pattern, intensity;
		var return_;
		switch (intensity,

			0, {
				var choose = rrand(1,1),
					choose_ = rrand(0, choose),
				temp = pattern.reshape(choose);
				if (temp.sum % 32.0 != 0.0, {
					temp = temp.insert(choose_,
						32.0 - (temp.sum % 32.0))});
				return_ = temp * 8;
			},

			1, {
				var choose = rrand(1,1),
					choose_ = rrand(0, choose),
				temp = pattern.reshape(choose);
				if (temp.sum < 8.0, {
					temp = temp ++ temp;
				});
				if (temp.sum % 16.0 != 0.0, {
					temp = temp.insert(choose_,
						16.0 - (temp.sum % 16.0))});
				return_ = temp * 8;
			},

			2, {
				var choose = rrand(1,1),
					choose_ = rrand(0, choose),
				temp = pattern.reshape(choose);
				if (temp.sum < 8.0, {
					temp = temp ++ temp;
				});
				if (temp.sum % 16.0 != 0.0, {
					temp = temp.insert(choose_,
						16.0 - (temp.sum % 16.0))});
				return_ = temp * 8;
			},

			3, {
				var choose = rrand(1,1),
					choose_ = rrand(0, choose),
				temp = pattern.reshape(choose);
				if (temp.sum < 8.0, {
					temp = temp ++ temp;
				});
				if (temp.sum % 16.0 != 0.0, {
					temp = temp.insert(choose_,
						16.0 - (temp.sum % 16.0))});
				return_ = temp * 8;
			},

			4, {
				var choose = rrand(1,1),
					choose_ = rrand(0, choose),
				temp = pattern.reshape(choose);
				if (temp.sum < 8.0, {
					temp = temp ++ temp;
				});
				if (temp.sum % 16.0 != 0.0, {
					temp = temp.insert(choose_,
						16.0 - (temp.sum % 16.0))});
				return_ = temp * 8;
			},
		);

		return_ = return_ * 8;

		^return_;
	}

	//----------------------------------------------HIT
	hit_pattern {
		arg pattern, intensity;
		var return_, alt, fill, punct, scale = 2;
		switch (intensity,

			0, {
				var choose = rrand(1,3),
					choose_ = rrand(0, choose),
				temp = pattern.reshape(choose);
				if (temp.sum % 16.0 != 0.0, {
					temp = temp.insert(choose_,
						16.0 - (temp.sum % 32.0))});
				return_ = temp * 2;
				choose_ = rrand(0, 2);
				if (choose_ == 0, {return_ = return_ / 2} );
			},

			1, {
				var choose = rrand(1,4),
					choose_ = rrand(0, choose),
				temp = pattern.reshape(choose);
				if (temp.sum < 8.0, {
					temp = temp ++ temp;
				});
				if (temp.sum % 16.0 != 0.0, {
					temp = temp.insert(choose_,
						16.0 - (temp.sum % 16.0))});
				return_ = temp * 2;
				choose_ = rrand(0, 2);
				if (choose_ == 0, {return_ = return_ / 2} );
			},

			2, {
				var choose = rrand(1,4),
					choose_ = rrand(0, choose),
				temp = pattern.reshape(choose);
				if (temp.sum < 8.0, {
					temp = temp ++ temp;
				});
				if (temp.sum % 16.0 != 0.0, {
					temp = temp.insert(choose_,
						16.0 - (temp.sum % 16.0))});
				return_ = temp * 2;
				choose_ = rrand(0, 2);
				if (choose_ == 0, {return_ = return_ / 4} );
				scale = 1;
			},

			3, {
				var choose = rrand(1,pattern.size),
					choose_ = rrand(0, choose),
				temp = pattern.reshape(choose);
				if (temp.sum < 8.0, {
					temp = temp ++ temp;
				});
				if (temp.sum % 16.0 != 0.0, {
					temp = temp.insert(choose_,
						16.0 - (temp.sum % 16.0))});
				return_ = temp ++ temp;
				choose_ = rrand(0, 2);
				if (choose_ == 0, {return_ = return_ / 2 });
				scale = 1;
			},

			4, {
				var choose = rrand(1,pattern.size),
					choose_ = rrand(0, choose),
				temp = pattern.reshape(choose);
				if (temp.sum < 8.0, {
					temp = temp ++ temp;
				});
				if (temp.sum % 16.0 != 0.0, {
					temp = temp.insert(choose_,
						16.0 - (temp.sum % 16.0))});
				return_ = (temp / 2)++(temp / 2);
				scale = 1;
			},
		);


		fill = rrand(0, 2);
		if (fill == 0, {
			alt = return_.scramble;
			return_ = return_++return_++return_++alt;
		});

		fill = rrand(1, 8);
		alt = rrand(0, 3);
		punct = [[fill] ++ ((0.5)!alt) ++ [(16 - (fill + (0.5 * alt)))]][0];

		/*return_ = [([4.0] ++ (8.0!63) ++ [4.0]),
			[10.0, 4.0, 1.0, 1.0] * scale,
			[ 6.0, 0.5, 0.5, 0.5, 0.5 ] * scale,
			[0.5, 0.5, 9.0, 1.0, 5.0],
			[3.0, 0.5, 12.5],
			punct, punct * scale,
			return_, return_, return_, return_];
		return_ = return_[rrand(0, 10)]; */

		^return_;
	}

	//----------------------------------------------MISC
	misc_pattern {
		arg pattern, intensity;
		var return_;
		switch (intensity,

			0, {
				var choose = rrand(1,2),
					choose_ = rrand(0, choose),
				temp = pattern.reshape(choose);
				if (temp.sum % 32.0 != 0.0, {
					temp = temp.insert(choose_,
						32.0 - (temp.sum % 32.0))});
				return_ = (temp * 2) ++ temp ++ (temp / 2) ++ (temp / 4) ++ (temp / 4);
			},

			1, {
				var choose = rrand(1,3),
					choose_ = rrand(0, choose),
				temp = pattern.reshape(choose);
				if (temp.sum < 8.0, {
					temp = temp ++ temp;
				});
				if (temp.sum % 16.0 != 0.0, {
					temp = temp.insert(choose_,
						16.0 - (temp.sum % 16.0))});
				return_ = (temp * 2) ++ (temp / 2) ++ (temp / 2) ++ (temp / 2) ++ (temp / 2);
			},

			2, {
				var choose = rrand(1,3),
					choose_ = rrand(0, choose),
				temp = pattern.reshape(choose);
				if (temp.sum < 8.0, {
					temp = temp ++ temp;
				});
				if (temp.sum % 16.0 != 0.0, {
					temp = temp.insert(choose_,
						16.0 - (temp.sum % 16.0))});
				return_ = temp ++ (temp / 2) ++ (temp / 4) ++ (temp / 4);
			},

			3, {
				var choose = rrand(1, 4),
					choose_ = rrand(0, choose),
				temp = pattern.reshape(choose);
				if (temp.sum < 8.0, {
					temp = temp ++ temp;
				});
				if (temp.sum % 16.0 != 0.0, {
					temp = temp.insert(choose_,
						16.0 - (temp.sum % 16.0))});
				return_ = temp ++ temp;
			},

			4, {
				var choose = rrand(1, 4),
					choose_ = rrand(0, choose),
				temp = pattern.reshape(choose);
				if (temp.sum < 8.0, {
					temp = temp ++ temp;
				});
				if (temp.sum % 16.0 != 0.0, {
					temp = temp.insert(choose_,
						16.0 - (temp.sum % 16.0))});
				return_ = temp ++ (temp / 2) ++ (temp / 4) ++ (temp / 4);
			},
		);

		/*return_ = [[0.5, 0.5], [4.0, 4.0], [2.0, 2.0], return_];
		return_ = return_[rrand(0, 3)];*/
		^return_;
	}

	//----------------------------------------------HAT
	hat_pattern {
		arg pattern, intensity;
		var return_, scale = 1;
		switch (intensity,

			0, {
				var choose = rrand(1,2),
					choose_ = rrand(0, choose),
				temp = pattern.reshape(choose);
				if (temp.sum < 8.0, {
					temp = temp ++ temp;
				});
				if (temp.sum < 8.0, {
					temp = temp ++ temp;
				});
				if (temp.sum % 16.0 != 0.0, {
					temp = temp.insert(choose_,
						16.0 - (temp.sum % 32.0))});
				return_ = temp * 2;
				scale = 2;
			},

			1, {
				var choose = rrand(1,2),
					choose_ = rrand(0, choose),
				temp = pattern.reshape(choose);
				if (temp.sum < 8.0, {
					temp = temp ++ temp;
				});
				if (temp.sum < 8.0, {
					temp = temp ++ temp;
				});
				if (temp.sum % 16.0 != 0.0, {
					temp = temp.insert(choose_,
						16.0 - (temp.sum % 16.0))});
				return_ = temp * 2;
			},

			2, {
				var choose = rrand(1,2),
					choose_ = rrand(0, choose),
				temp = pattern.reshape(choose);
				if (temp.sum < 8.0, {
					temp = temp ++ temp;
				});
				if (temp.sum < 8.0, {
					temp = temp ++ temp;
				});
				if (temp.sum % 16.0 != 0.0, {
					temp = temp.insert(choose_,
						16.0 - (temp.sum % 16.0))});
				return_ = temp;
			},

			3, {
				var choose = rrand(1,4),
					choose_ = rrand(0, choose),
				temp = pattern.reshape(choose);
				if (temp.sum < 8.0, {
					temp = temp ++ temp;
				});
				if (temp.sum < 8.0, {
					temp = temp ++ temp;
				});
				if (temp.sum % 16.0 != 0.0, {
					temp = temp.insert(choose_,
						16.0 - (temp.sum % 16.0))});
				return_ = temp;
			},

			4, {
				var choose = rrand(1,pattern.size),
					choose_ = rrand(0, choose),
				temp = pattern.reshape(choose);
				if (temp.sum < 8.0, {
					temp = temp ++ temp;
				});
				if (temp.sum < 8.0, {
					temp = temp ++ temp;
				});
				if (temp.sum % 16.0 != 0.0, {
					temp = temp.insert(choose_,
						16.0 - (temp.sum % 16.0))});
				return_ = (temp / 2)++(temp / 2);
			},
		);

		return_ = [[2.0, 2.0] * scale,
			[1.0, 1.0] * scale,
			([2.0] ++ (4.0!63) ++ [2.0]),
			[2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 1.0, 1.0, 1.0, 1.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 1.0, 1.0, 0.5, 0.5, 1.0] * scale,
			return_, return_];
		return_ = return_[rrand(0, 5)];

		^return_;
	}

	post_process {
		arg pattern, instrument, intensity;
		var return;
		pattern = pattern.asArray;
		switch (instrument,
			\bass, {return = this.bass_pattern(pattern, intensity)},
			\kick, {return = this.kick_pattern(pattern, intensity)},
			\clap, {return = this.hit_pattern(pattern, intensity)},
			\snare, {return = this.hit_pattern(pattern, intensity)},
			\hat, {return = this.hat_pattern(pattern, intensity)},
			\loop, {return = this.long_pattern(pattern, intensity)},
			\hit, {return = this.hit_pattern(pattern, intensity)},
			\misc, {return = this.misc_pattern(pattern, intensity)}
		);
		return = this.time_process(return);
		^return;
	}

	generate_pattern {
		arg input, instrument, intensity;
		var processed_seed = this.interpret(input),
		model = this.model_weights(processed_seed),
		pattern = this.interpolate(model, processed_seed);
		~appendLog.value("WORKING: Printing Patterns for" + instrument.asString);
		^this.post_process(pattern, instrument, intensity);
	}


}