EventManager {

	var <patterns, <schemas, <instruments, <streaming, <offramping, <onramping, <swing_, <hash;

	*new {
		arg seed, intensity, key, swing;
		^super.new.init(seed, intensity, key, swing)
	}



	init {

		arg seed, intensity, kit, swing;

		var p = PatternGen.new(),
		g = PlaybackSchema.new();

		hash = rrand(1, 10000);

		instruments = [	\bass, \kick, \snare, \clap, \hat, \loop, \hit, \misc ];
		onramping = List.new();
		offramping = List.new();

		patterns = Dictionary.new;
		schemas = Dictionary.new;
		streaming = Dictionary.new;
		swing_ = swing;

		instruments.do({
			arg inst;
			patterns.putAll(
				Dictionary[
					inst -> p.generate_pattern(
						seed, inst, intensity)
			]);

			schemas.putAll(
				Dictionary[
					inst -> g.go(
						patterns.at(inst), inst, intensity, kit);
			]);


		});

		"OK: Pattern Gen Complete".postln;
		"OK: Schema Gen Complete".postln;

	}


}