(
~hardwareInputs = 1;
~hardwareOutputs = 2;
~ambiOrder = 3; // Third-order Ambisonics
~numAmbiChans = ( ~ambiOrder + 1 )**2; // = 16
~tempo = 30;
~kitOverride = false;

// can be \stereo, \stem, \false = default
~mixdown = \stereo;
// master fader will only work if mixdown is false



// Audio Signal Flow Diagram

// For Each Instrument (e.g. \kick):
// Pattern (Pbind) output ---> dryBus + optional fxBus
//
// dryBus               fxBus
//   |                   |
//   v                   v
//  [mixInstrument Synth]  -- mixes dry+fx --> monoBus
//             |
//             v
//        [hoaEncodeGeneric Synth] -- encodes mono into HOA --> ambiBus
//
// After all instruments are encoded:
// ambiBus_1, ambiBus_2, ... ambiBus_n -- here's where instrument-based spat occurs
//       |        |               |
//       v        v               v
//      [ambiSum Synths chain them together] --> finalAmbiBus
//
// finalAmbiBus
//       |
//       v
//      [mixIO Synth] (Compander, EQ, Verb, Limiter) --> processedAmbiBus (mix processing)
//
// processedAmbiBus
//       |
//       v
//      [masterGain Synth] (master amplitude control) --> finalGainBus
//
// finalGainBus
//     |
//     +--> If monitoring in stereo: [downmixToStereo Synth] --> Out.ar(0,1) hardware outputs
//     |
//     +--> If 16-channel system: [directAmbiOut Synth] --> Out.ar(0..15) hardware outputs


//ServerOptions.devices;
Server.default.options.numInputBusChannels = ~hardwareInputs;
Server.default.options.numOutputBusChannels = ~hardwareOutputs;
s.options.memSize = 365536;
s.options.numBuffers = 8096;
s.options.sampleRate = 48000;
s.options.numWireBufs = 1024;
s.reboot;


~seed = [
	1, 0, 1, 1,
	1, 0, 1, 0,
	1, 0, 1, 0,
	0, 1, 1, 1,
	1, 0, 0, 0,
	0, 1, 1, 1,
	1, 0, 0, 1,
	1, 0, 1, 0,
];

~initLevel = 1.00;
~scl = 0.51;
~bassLevel = 0.50 * ~scl;
~kickLevel = 0.40 * ~scl;
~snareLevel = 0.42 * ~scl;
~clapLevel = 0.50 * ~scl;
~hatLevel = 0.57 * ~scl;
~loopLevel = 0.33;
~hitLevel = 0.51 * ~scl;
~miscLevel = 0.47 * ~scl;

~instruments = [\bass, \kick, \snare, \clap, \hat, \loop, \hit, \misc];

~instrumentBuses = (
    \bass: (
        dryBus: Bus.audio(s, 1),
        fxBus:  Bus.audio(s, 1),
        monoBus: Bus.audio(s, 1),
		ambiBus: Bus.audio(s, ~numAmbiChans),
        az: 0,
        el: 0
    ),
    \kick: (
        dryBus: Bus.audio(s, 1),
        fxBus:  Bus.audio(s, 1),
        monoBus: Bus.audio(s, 1),
        ambiBus: Bus.audio(s, ~numAmbiChans),
        az: 45,
        el: 0
    ),
    \clap: (
        dryBus: Bus.audio(s, 1),
        fxBus:  Bus.audio(s, 1),
        monoBus: Bus.audio(s, 1),
        ambiBus: Bus.audio(s, ~numAmbiChans),
        az: 90,
        el: 0
    ),
    \snare: (
        dryBus: Bus.audio(s, 1),
        fxBus:  Bus.audio(s, 1),
        monoBus: Bus.audio(s, 1),
        ambiBus: Bus.audio(s, ~numAmbiChans),
        az: 135,
        el: 0
    ),
    \hat: (
        dryBus: Bus.audio(s, 1),
        fxBus:  Bus.audio(s, 1),
        monoBus: Bus.audio(s, 1),
        ambiBus: Bus.audio(s, ~numAmbiChans),
        az: 180,
        el: 0
    ),
    \loop: (
        dryBus: Bus.audio(s, 1),
        fxBus:  Bus.audio(s, 1),
        monoBus: Bus.audio(s, 1),
        ambiBus: Bus.audio(s, ~numAmbiChans),
        az: 225,
        el: 0
    ),
    \hit: (
        dryBus: Bus.audio(s, 1),
        fxBus:  Bus.audio(s, 1),
        monoBus: Bus.audio(s, 1),
        ambiBus: Bus.audio(s, ~numAmbiChans),
        az: 270,
        el: 0
    ),
    \misc: (
        dryBus: Bus.audio(s, 1),
        fxBus:  Bus.audio(s, 1),
        monoBus: Bus.audio(s, 1),
        ambiBus: Bus.audio(s, ~numAmbiChans),
        az: 315,
        el: 0
    )
);

~loopLen = 60;

s.waitForBoot {

	s.sync;
	~buffers = Dictionary.new;

	if (thisProcess.nowExecutingPath.notNil == true, {
		p = PathName.new(thisProcess.nowExecutingPath.dirname +/+ "Samples/");
		~logPath = "~/"++Date.getDate.dayStamp.asString++".txt".standardizePath;
		~appendLog = {
			arg log;
			if (log == nil, {log = "WARN: NIL" });
			File.use(~logPath.standardizePath, "a", { arg f;
				f.write(Date.getDate.asString ++ ": ");
				f.write(log);
				log.postln;
				f.write("\n"); });
		};

	},
	{
		~appendLog.value("WARN: Windows Pathname Issue");
		p = PathName.new("C:/Users/User/Documents/GitHub/beatgrid/Samples");
		// TO FIX STUPID WINDOWS BUG
	});

	p.folders.do({ //samples
		arg f;
		var bufs = Dictionary.new;
		bufs.add(f.folderName -> Dictionary.new);

		f.folders.do({
			arg f_;
			var samples = Array.new;
			~appendLog.value(("OK: Processsing" + f_.entries.size.asString + "files from" + f_.asString));
			f_.entries.do({ arg path;
				if (path.extension == "wav", {
					samples = samples.add(Buffer.read(s, path.fullPath));}); });
			bufs.at(f.folderName).putAll( Dictionary[f_.folderName -> samples]);
		});

		~buffers.putAll(bufs);

	});

	~appendLog.value("OK: Loading....");
	s.sync;

	if ( p.folders == [], {
		~appendLog.value("ERR: No Samples Found -- Patch WILL NOT RUN"); },
	{

		SynthDef(\playback, { // playback synth
			arg rate = 1, atk = 0.09, rel = 2.4, lcut = 20, hcut = 20000, pan = 0,
			buf, amp = 1.0, out;
			var sig = PlayBuf.ar(1, buf, BufRateScale.ir(buf) * rate, doneAction: 2),
			env = EnvGen.kr( Env.new([0,1,0], [atk, rel], [1, -1]), doneAction:2);
			sig = HPF.ar(sig, lcut);
			sig = LPF.ar(sig, hcut);
			Out.ar(out, sig * env * amp);
		}).add;

		SynthDef(\playbackP, { // playback synth (with pitch management)
			arg rate = 1, atk = 0.09, rel = 3.4, lcut = 20, hcut = 20000,
			repitch = 1.0, pdisp = 0.0, tdisp = 0.0, pan = 0, buf, amp = 1.0, out;
			var sig = PlayBuf.ar(1, buf, BufRateScale.ir(buf) * rate, doneAction: 2),
			env = EnvGen.kr( Env.new([0,1,0], [atk, rel], [1, -1]), doneAction:2);
			sig = HPF.ar(sig, lcut);
			sig = LPF.ar(sig, hcut);
			sig = PitchShift.ar(sig, 0.2, repitch, pdisp = 0.1, tdisp = 0.1);
			Out.ar(out, sig * env * amp);
		}).add;


		SynthDef(\delay, {
			arg in, out, delayTime = 0.33333,
			decayTime = 3, hcut = 100, lcut = 10000, amp = 0.2, decay = 10;

			var sig = In.ar(in, 1),
			// LFOs for filter modulation
			hpfLFOFreq = XLine.kr(0.001, 0.1, 120),
			lpfLFOFreq = XLine.kr(0.002, 0.05, 60),
			hpfLFO = SinOsc.kr(hpfLFOFreq, 0).range(40, hcut),
			lpfLFO = SinOsc.kr(lpfLFOFreq, 0).range(1000, lcut);

			// Delay with modulation
			//sig = AllpassC.ar(sig, 1.0, (60/~tempo) * delayTime, decayTime);
			sig = Greyhole.ar(sig, 1.0, (60/~tempo) * delayTime);

			// Apply filters with modulated cutoff frequencies
			sig = LPF.ar(sig, lpfLFO);
			sig = HPF.ar(sig, hpfLFO);

			// Add a reverb for more depth
			sig = JPverb.ar(sig);

			// Output with defined amplitude
			sig = sig * amp;
			Out.ar(out, sig);

		}).add;

		SynthDef(\delay2, {
			arg in, out, delayTime = 0.33333,
			decayTime = 5, hcut = 10400, lcut = 10000, amp = 0.11, decay = 10;

			var sig = In.ar(in, 1),
			// LFOs for filter modulation
			hpfLFOFreq = XLine.kr(0.001, 0.1, 120),
			//lpfLFOFreq = XLine.kr(0.002, 0.05, 60),
			hpfLFO = SinOsc.kr(hpfLFOFreq, 0).range(1000, hcut);
			//lpfLFO = SinOsc.kr(lpfLFOFreq, 0).range(1000, lcut);

			// Delay with modulation
			sig = AllpassC.ar(sig, 1.0, (60/~tempo) * delayTime, decayTime);

			// Apply filters with modulated cutoff frequencies
			//sig = LPF.ar(sig, lpfLFO);
			sig = HPF.ar(sig, hpfLFO);

			// Add a reverb for more depth
			sig = JPverb.ar(sig);

			// Output with defined amplitude
			sig = sig * amp;
			Out.ar(out, sig);

		}).add;

		SynthDef(\mixIO, { // compressor, limiter on the Ambisonic mix
			arg out, in, amp = 1.0;
			var sig = In.ar(in, 16), // Now reading all HOA channels
			lfo = SinOsc.kr(1 / (3* 60)).range(1, 10) + (LFNoise1.kr(0.01) * 0.5);
			// Apply the same processing to each channel of the ambisonic field:
			// Compander, EQ, Verb, Limiter all handle arrays gracefully.
			sig = Compander.ar(sig, sig, thresh: 0.85, slopeBelow: 1.2, slopeAbove: 0.45, clampTime: 0.01, relaxTime: 0.01);
			sig = BPeakEQ.ar(sig, 100, 1.0, 1.0);
			sig = HDVerb.ar(sig, mix: 0.2, decay: lfo);
			sig = sig * amp;
			sig = Limiter.ar(sig, level: 0.94, dur: 0.1);
			Out.ar(out, sig);
		}).add;

		// One SynthDef to mix Dry+FX
		SynthDef(\mixInstrument, {
			arg inDry, inFx, out;
			var dry = In.ar(inDry, 1),
			fx = In.ar(inFx, 1);
			Out.ar(out, dry + fx);
		}).add;

		// One SynthDef to encode Ambisonics (3rd order)
		SynthDef(\hoaEncodeGeneric, {
			arg in, out, az=0, el=0, amp=1.0, order=3;
			var sig = In.ar(in, 1),
			encoded = HoaEncodeDirection.ar(sig, az.degrad, el.degrad, radius:3, order:3);
			Out.ar(out, encoded);
		}).add;


		// SynthDef to sum two ambisonic signals
		SynthDef(\ambiSum, { |out, inA, inB|
			var sigA = In.ar(inA, 16);
			var sigB = In.ar(inB, 16);
			Out.ar(out, sigA + sigB);
		}).add;

		SynthDef(\masterGain, { |in, out, amp=1.0|
			var sig = In.ar(in, 16);
			// Multiply by amp, which will be controlled by the GUI slider.
			sig = sig * amp;
			Out.ar(out, sig);
		}).add;

		s.sync;

		// Setup instruments
		~instrumentBuses.keys.do { |instr|
			var data = ~instrumentBuses[instr];

			// Mix dry + fx into mono
			Synth(\mixInstrument, [
				\inDry, data[\dryBus],
				\inFx,  data[\fxBus],
				\out,   data[\monoBus]
			]);

			// Encode to HOA
			Synth(\hoaEncodeGeneric, [
				\in, data[\monoBus],
				\out, data[\ambiBus],
				\az, data[\az],
				\el, data[\el]
			]);
		};

		~ambiBuses = ~instrumentBuses.values.collect { |v| v[\ambiBus] };
		~currentSumBus = ~ambiBuses[0];

		~ambiBuses[1..].do { |b|
			var newSumBus = Bus.audio(s, ~numAmbiChans);
			Synth(\ambiSum, [\out, newSumBus, \inA, ~currentSumBus, \inB, b]);
			~currentSumBus = newSumBus;
		};

		// Now currentSumBus is the final summed Ambisonic signal
		~finalAmbiBus = ~currentSumBus;

		~processedAmbiBus = Bus.audio(s, ~numAmbiChans);
		Synth(\mixIO, [\in, ~finalAmbiBus, \out, ~processedAmbiBus]);

		~finalGainBus = Bus.audio(s, ~numAmbiChans);
		~masterGainSynth = Synth(\masterGain, [\in, ~processedAmbiBus, \out, ~finalGainBus, \amp, ~initLevel]);


		// If we are just monitoring on headphones (2 channels), decode or downmix
		// If we have 16 outputs (the install), route directly:
		if (~hardwareOutputs == 2) {
			// Simple downmix to stereo using a FOA->Stereo approximation or using just W channel:
			// For a quick hack: take W channel only (first channel of ambisonics)
			// A proper decode requires a decode matrix or ATK decode.
			SynthDef(\downmixToStereo, { |in|
				var insig = In.ar(in, 16);
				// Here we just take W and maybe some other channels to fake stereo:
				var w = Select.ar(0, insig); // W channel is 0
				var x = Select.ar(3, insig); // X channel
				// simple fake stereo: w+(0.5*x) left, w-(0.5*x) right
				var left = w + (0.5 * x);
				var right = w - (0.5 * x);
				Out.ar(0, [left, right]);
			}).add;
			Synth(\downmixToStereo, [\in,  ~finalGainBus]);
		} {
			// If we have 16 hardware outputs, directly send them out:
			SynthDef(\directAmbiOut, { |in|
				var sig = In.ar(in, 16);
				Out.ar(0, sig);
			}).add;
			Synth(\directAmbiOut, [\in,  ~finalGainBus]);
		}
		});

		s.sync;

		~reTime = ReTime.new();

		Window.closeAll;
		s.meter (~hardwareInputs, ~hardwareOutputs);

		~w = Window("GUI Controls", Rect(800,200,480,520)).front.alwaysOnTop_(true);
		~w.view.decorator_(FlowLayout(~w.bounds, 20@20, 20@20));

		~masterFader = EZSlider.new(~w, Rect(20, 160, 430, 40), "master fader",
			ControlSpec.new(0.00, 1.5, \lin, 0.01, 1.0, ""), // default 1.0
    		{ arg slider; ~masterGainSynth.set(\amp, slider.value); },
    		0, false, 80, 45
		).value_(~initLevel).setColors(Color.grey, Color.white);

		~startButton = Button(~w, Rect(20, 20, 420, 40))
		.states_([["Start", Color.gray, Color.yellow], ["Halt", Color.gray, Color.red]])
		.action_({ arg state;
			switch(state.value,
				1, {
					"OK: Running Patch".postln;
					c.conduct(~seed);
				},
				0, {
					"WARN: Stopping Patch".postln;
					if (c.notNil == true, {
						c.flag=false;
						s.killAll;
					});
				}
			);
		});

		~nextKitTrigger = EZNumber(~w, Rect(150, 10, 140, 30),"Change Kit",
			ControlSpec.new(0,~buffers.size - 1,\lin,1), { arg n;
				if (c.notNil == true, {
					c.kit = n.value.asInteger;
					~kitOverride = true;
					("OK: Forcing Kit" + n.value.asInteger.asString).postln; });
		});

		~intensityTrigger = EZNumber(~w, Rect(150, 10, 140, 30), "Change Intensity",
			ControlSpec.new(0, 4, \lin, 1), { arg n;
				if (c.notNil == true, {
					c.intensity = n.value.asInteger;
					~intensityOverride = true;
					("OK: Forcing Intensity" + n.value.asInteger.asString).postln; });
		});

		~simulateHour = EZNumber(~w, Rect(150, 10, 140, 30), "Change Start Hour",
			ControlSpec.new(0, 24, \lin, 1), { arg n;
				if (c.notNil == true, {
					c.time_override = n.value.asInteger;
					~timeOverride = true;
					("OK: Forcing Hour" + n.value.asInteger.asString).postln; });
		});

		~forceTransition = Button(~w, Rect(120, 20, 420, 40))
		.states_([["Force State Change", Color.gray, Color.yellow]])
		.action_({ arg state;
			switch(state.value,
				0, {
					~transitionOverride = true;
			});
		});

		~recordButton = Button(~w, Rect(120, 20, 420, 40))
		.states_([["Start Recording", Color.gray, Color.yellow], ["Stop Recording", Color.gray, Color.red]])
		.action_({ arg state;
			switch(state.value,
				1, {
					s.record();
					"OK: Recording in Progress".postln;
				},
				0, {
					s.stopRecording;
					"WARN: Stopped Recording".postln;
				}
			);
		}).value_(0);

		~instruments.do({
			arg instrument;
			Button(~w, Rect(120, 20, 60, 60))
			.states_([["Kill" + instrument.asString, Color.gray, Color.yellow]])
			.action_({ arg state;
				switch(state.value,
					0, {
						if (c.notNil == true, {
							c.transition.event.streaming.at(instrument).patterns[1].stop;
							c.transition.event.streaming.at(instrument).patterns[1].free;  }); });
			});
		});

		s.sync;

		c = Conductor.new();

		~appendLog.value("OK: Loaded - Program Ready To Run");

		s.sync;

		~appendLog.value("OK: Running Patch");
		c.conduct(~seed, s);

	});

});


s.record(bus:0, numChannels:33, duration:100)

c.kit
c.intensity

