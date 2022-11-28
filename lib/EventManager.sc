EventManager {

	var <patterns, <schemas, <instruments, <streaming, <offramping, <onramping, <swing_;

	*new {
		arg seed, intensity, key, swing;
		^super.new.init(seed, intensity, key, swing)
	}



	init {

		arg seed, intensity, key, swing;

		var p = PatternGen.new(),
		g = PlaybackSchema.new();

		instruments = [	\bass, \kick, \snare, \clap, \hat, \loop, \hit ];
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
						patterns.at(inst), inst, intensity, key);
			]);


		});

		"OK: Pattern Gen Complete".postln;
		"OK: Schema Gen Complete".postln;

	}


}