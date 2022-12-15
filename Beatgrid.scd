(
~hardwareInputs = 1;
~hardwareOutputs = 33;
~tempo = 60;
~kitOverride = false;


//ServerOptions.devices;
Server.default.options.numInputBusChannels = ~hardwareInputs;
Server.default.options.numOutputBusChannels = ~hardwareOutputs;
s.options.memSize = 365536;
s.options.numBuffers = 8096;
s.options.sampleRate = 48000;
s.reboot;

//---- PLACEHOLDER TEMP

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
~bassLevel = 0.60 * ~scl;
~kickLevel = 0.40 * ~scl;
~snareLevel = 0.42 * ~scl;
~clapLevel = 0.53 * ~scl;
~hatLevel = 0.57 * ~scl;
~loopLevel = 0.65;
~hitLevel = 0.60 * ~scl;
~miscLevel = 0.47 * ~scl;

~instruments = [\bass, \kick, \snare, \clap, \hat, \loop, \hit, \misc];

~loopLen = 60;

//---- END TEMP

s.waitForBoot {


	s.sync;
	~buffers = Dictionary.new;

	//z = Buffer.cueSoundFile(s, "C:/Users/User/Documents/GitHub/beatgrid/Samples/18/hat/MoonKit17.wav", 0, 33);

	if (thisProcess.nowExecutingPath.notNil == true, {
		p = PathName.new(thisProcess.nowExecutingPath.dirname +/+ "Samples/");
	},
	{
		"WARN: Windows Pathname Issue".postln;
		p = PathName.new("C:/Users/User/Documents/GitHub/beatgrid/Samples");
		// TO FIX STUPID WINDOWS BUG>
	});



	p.folders.do({ //samples
		arg f;
		var bufs = Dictionary.new;
		bufs.add(f.folderName -> Dictionary.new);

		f.folders.do({
			arg f_;
			var samples = Array.new;
			("OK: Processsing" + f_.entries.size.asString + "files from" + f_.asString).postln;
			f_.entries.do({ arg path;
				if (path.extension == "wav", {
					samples = samples.add(Buffer.read(s, path.fullPath));}); });
			bufs.at(f.folderName).putAll( Dictionary[f_.folderName -> samples]);
		});

	~buffers.putAll(bufs);

	});

	"OK: Loading....".postln;
	s.sync;

	if ( p.folders == [], {
		"ERR: No Samples Found -- Patch WILL NOT RUN".postln; },
	{

		SynthDef(\playback, { // playback synth
			arg rate = 1, atk = 0.001, rel = 1.4, lcut = 20, hcut = 20000, pan = 0,
			buf, amp = 1.0, out;
			var sig = PlayBuf.ar(1, buf, BufRateScale.ir(buf) * rate, doneAction: 2),
			env = EnvGen.kr( Env.new([0,1,0], [atk, rel], [1, -1]), doneAction:2);
			sig = HPF.ar(sig, lcut);
			sig = LPF.ar(sig, hcut);
			Out.ar(out, sig * env * amp);
		}).add;

		SynthDef(\playbackP, { // playback synth (with pitch management)
			arg rate = 1, atk = 0.001, rel = 1.4, lcut = 20, hcut = 20000,
			repitch = 1.0, pdisp = 0.0, tdisp = 0.0, pan = 0, buf, amp = 1.0, out;
			var sig = PlayBuf.ar(1, buf, BufRateScale.ir(buf) * rate, doneAction: 2),
			env = EnvGen.kr( Env.new([0,1,0], [atk, rel], [1, -1]), doneAction:2);
			sig = HPF.ar(sig, lcut);
			sig = LPF.ar(sig, hcut);
			sig = PitchShift.ar(sig, 0.2, repitch, pdisp, tdisp);
			Out.ar(out, sig * env * amp);
		}).add;

		SynthDef(\playbackLoop, {
			arg buf, out, amp = 1.0, atk, rel, env_atk, env_rel, lcut = 40;
			var sig = PlayBuf.ar(32, buf, BufRateScale.ir(buf) * 1.0, doneAction: 2),
			env = EnvGen.kr( Env.new([0,1,1,0], [10, 30, 19]), doneAction:2),
			hfenv = EnvGen.kr( Env.new([200, 40, lcut, lcut * 2], [6, 20, 20, 14]) );
			//sig = HPF.ar(sig, hfenv);
			Out.ar(out, sig * amp * env);
		}).add;

		SynthDef(\delay, {
			arg in, out, lfo1freq = 0.02, lfo2freq = 0.01, delayTime = 0.33333,
			decayTime = 1.4, hcut = 12000, lcut = 200, amp = 0.2;
			var sig = In.ar(in, 1),
			lfo1 = SinOsc.kr(lfo1freq, 0.3, 1.0, 7000),
			lfo2 = SinOsc.kr(lfo2freq, 1.0, 1.0, 7000);
			sig = AllpassC.ar(sig, 1.0, (60/~tempo) * delayTime, decayTime);
			sig = LPF.ar(sig, hcut - lfo1);
			sig = HPF.ar(sig, lcut + lfo2);
			//sig = AnalogVintageDistortion.ar(sig, 0.1);
			sig = sig * amp;
			Out.ar(out, sig);
		}).add;

		SynthDef(\mixIO, { // compressor and limiter on the mix Bus
			arg out = 0, in = 0, amp = 1.0;
			var sig = In.ar(in, 1);
			sig = Compander.ar(sig,	sig, thresh: 0.85, slopeBelow: 1.2, slopeAbove: 0.45, clampTime: 0.01, relaxTime: 0.01);
			sig = sig * amp;
			sig = BPeakEQ.ar(sig, 100, 1.0, 1.0);
			sig = Limiter.ar(sig, level: 0.94, dur: 0.1);
			Out.ar(out, sig);
		}).add;

		SynthDef(\patchCord, {
			arg in, out, amp = 1.0;
			var sig = In.ar(in, 1);
			sig = sig * amp;
			Out.ar(out, sig);
		}).add;

		s.sync;

		~playbackGroup = Group.tail(s);
		~dryGroup = Group.tail(s); ~fxGroup = Group.tail(s); ~mixGroup = Group.tail(s); ~masterGroup = Group.tail(s);

		/* FOR REFERENCE:

		0 - 7: Atrium Wall Left to Right
		8 - 9: Atrium Ceiling Left
		10 - 11: Atrium Subs Left
		12 - 13: Atrium Ceiling Right
		14 - 15: Atrium Subs Right
		16 - 17: Retail Alcove
		18: Retail Sub L
		19 - 22: Retail Alcove R
		23: Retail Sub R
		24: Retail Alcove R (cont)
		25 - 32: Ceilings

		*/

		~atrWall_dryBus = Array.fill(8, { Bus.audio(s, 1) });
		~atrCeiling_dryBus = Array.fill(4, { Bus.audio(s, 1) });
		~atrSubs_dryBus = Array.fill(4, { Bus.audio(s, 1) });
		~retAlcove_dryBus = Array.fill(7, { Bus.audio(s, 1) });
		~retCeiling_dryBus = Array.fill(8, { Bus.audio(s, 1) });
		~retSubs_dryBus = Array.fill(2, {Bus.audio(s, 1) });

		~atrWall_fxSBus = Array.fill(8, { Bus.audio(s, 1) });
		~atrCeiling_fxSBus = Array.fill(4, { Bus.audio(s, 1) });
		~atrSubs_fxSBus = Array.fill(4, { Bus.audio(s, 1) });
		~retAlcove_fxSBus = Array.fill(7, { Bus.audio(s, 1) });
		~retCeiling_fxSBus = Array.fill(8, { Bus.audio(s, 1) });
		~retSubs_fxSBus = Array.fill(2, {Bus.audio(s, 1) });

		~atrWall_fxMBus = Array.fill(8, { Bus.audio(s, 1) });
		~atrCeiling_fxMBus = Array.fill(4, { Bus.audio(s, 1) });
		~atrSubs_fxMBus = Array.fill(4, { Bus.audio(s, 1) });
		~retAlcove_fxMBus = Array.fill(7, { Bus.audio(s, 1) });
		~retCeiling_fxMBus = Array.fill(8, { Bus.audio(s, 1) });
		~retSubs_fxMBus = Array.fill(2, {Bus.audio(s, 1) });

		~atrWall_fxLBus = Array.fill(8, { Bus.audio(s, 1) });
		~atrCeiling_fxLBus = Array.fill(4, { Bus.audio(s, 1) });
		~atrSubs_fxLBus = Array.fill(4, { Bus.audio(s, 1) });
		~retAlcove_fxLBus = Array.fill(7, { Bus.audio(s, 1) });
		~retCeiling_fxLBus = Array.fill(8, { Bus.audio(s, 1) });
		~retSubs_fxLBus = Array.fill(2, {Bus.audio(s, 1) });

		~loopBus = Bus.audio(s,33);

		~drySeq =
		~atrWall_dryBus ++
		~atrCeiling_dryBus[0] ++ ~atrCeiling_dryBus[1] ++
		~atrSubs_dryBus[0] ++ ~atrSubs_dryBus[1] ++
		~atrCeiling_dryBus[2] ++ ~atrCeiling_dryBus[3] ++
		~atrSubs_dryBus[2] ++ ~atrSubs_dryBus[3] ++
		~retAlcove_dryBus[0] ++ ~retAlcove_dryBus[1] ++
		~retSubs_dryBus[0] ++
		~retAlcove_dryBus[2] ++ ~retAlcove_dryBus[3] ++ ~retAlcove_dryBus[4] ++ ~retAlcove_dryBus[5] ++
		~retSubs_dryBus[1] ++
		~retAlcove_dryBus[6] ++
		~retCeiling_dryBus;

		~fxSSeq =
		~atrWall_fxSBus ++
		~atrCeiling_fxSBus[0] ++ ~atrCeiling_fxSBus[1] ++
		~atrSubs_fxSBus[0] ++ ~atrSubs_fxSBus[1] ++
		~atrCeiling_fxSBus[2] ++ ~atrCeiling_fxSBus[3] ++
		~atrSubs_fxSBus[2] ++ ~atrSubs_fxSBus[3] ++
		~retAlcove_fxSBus[0] ++ ~retAlcove_fxSBus[1] ++
		~retSubs_fxSBus[0] ++
		~retAlcove_fxSBus[2] ++ ~retAlcove_fxSBus[3] ++ ~retAlcove_fxSBus[4] ++ ~retAlcove_fxSBus[5] ++
		~retSubs_fxSBus[1] ++
		~retAlcove_fxSBus[6] ++
		~retCeiling_fxSBus;


		~fxMSeq =
		~atrWall_fxMBus ++
		~atrCeiling_fxMBus[0] ++ ~atrCeiling_fxMBus[1] ++
		~atrSubs_fxMBus[0] ++ ~atrSubs_fxMBus[1] ++
		~atrCeiling_fxMBus[2] ++ ~atrCeiling_fxMBus[3] ++
		~atrSubs_fxMBus[2] ++ ~atrSubs_fxMBus[3] ++
		~retAlcove_fxMBus[0] ++ ~retAlcove_fxMBus[1] ++
		~retSubs_fxMBus[0] ++
		~retAlcove_fxMBus[2] ++ ~retAlcove_fxMBus[3] ++ ~retAlcove_fxMBus[4] ++ ~retAlcove_fxMBus[5] ++
		~retSubs_fxMBus[1] ++
		~retAlcove_fxMBus[6] ++
		~retCeiling_fxMBus;

		~fxLSeq =
		~atrWall_fxLBus ++
		~atrCeiling_fxLBus[0] ++ ~atrCeiling_fxLBus[1] ++
		~atrSubs_fxLBus[0] ++ ~atrSubs_fxLBus[1] ++
		~atrCeiling_fxLBus[2] ++ ~atrCeiling_fxLBus[3] ++
		~atrSubs_fxLBus[2] ++ ~atrSubs_fxLBus[3] ++
		~retAlcove_fxLBus[0] ++ ~retAlcove_fxLBus[1] ++
		~retSubs_fxLBus[0] ++
		~retAlcove_fxLBus[2] ++ ~retAlcove_fxLBus[3] ++ ~retAlcove_fxLBus[4] ++ ~retAlcove_fxLBus[5] ++
		~retSubs_fxLBus[1] ++
		~retAlcove_fxLBus[6] ++
		~retCeiling_fxLBus;

		~mixBus = Array.fill(~hardwareOutputs, { Bus.audio(s, 1) });
		~masterBus = Array.fill(~hardwareOutputs, { Bus.audio(s, 1) });

		s.sync;

		~dryPatch = Array.fill(~hardwareOutputs, { arg i;
			Synth(\patchCord, [\in, ~drySeq[i], \out, ~mixBus[i]], ~dryGroup); });

		~drySPatch = Array.fill(~hardwareOutputs, { arg i;
			Synth(\patchCord, [\in, ~fxSSeq[i], \out, ~mixBus[i]], ~dryGroup); });

		~dryMPatch = Array.fill(~hardwareOutputs, { arg i;
			Synth(\patchCord, [\in, ~fxMSeq[i], \out, ~mixBus[i]], ~dryGroup); });

		~dryLPatch = Array.fill(~hardwareOutputs, { arg i;
			Synth(\patchCord, [\in, ~fxLSeq[i], \out, ~mixBus[i]], ~dryGroup); });

		~dlySPatch = Array.fill(~hardwareOutputs, { arg i;
			Synth(\delay, [\in, ~fxSSeq[i], \out, ~mixBus[i], \delayTime, 0.66666, \decayTime, 0.13], ~fxGroup); });

		~dlyS2Patch = Array.fill(~hardwareOutputs, { arg i;
			Synth(\delay, [\in, ~fxSSeq[i], \out, ~mixBus[i], \delayTime, 0.75, \decayTime, 0.13], ~fxGroup); });

		~dlyMPatch = Array.fill(~hardwareOutputs, { arg i;
			Synth(\delay, [\in, [i], ~fxMSeq[i], \out, ~mixBus[i], \lfo1freq, 0.20, \lfo2freq, 0.03, \delayTime, 0.75, \decayTime, 0.13], ~fxGroup); });

		~dlyM2Patch = Array.fill(~hardwareOutputs, { arg i;
			Synth(\delay, [\in, ~fxMSeq[i], \out, ~mixBus[i], \lfo1freq, 0.10, \lfo2freq, 0.02, \delayTime, 0.25, \decayTime, 0.078], ~fxGroup); });

		~dlyLPatch = Array.fill(~hardwareOutputs, { arg i;
			Synth(\delay, [\in, ~fxLSeq[i], \out, ~mixBus[i], \lfo1freq, 0.10, \lfo2freq, 0.03, \delayTime, 0.5, \decayTime, 0.13], ~fxGroup); });

		~dlyL2Patch = Array.fill(~hardwareOutputs, { arg i;
			Synth(\delay, [\in, ~fxLSeq[i], \out, ~mixBus[i], \lfo1freq, 0.01, \lfo2freq, 0.03, \delayTime, 0.75, \decayTime, 0.13], ~fxGroup); });

		~dlyL3Patch = Array.fill(~hardwareOutputs, { arg i;
			Synth(\delay, [\in, ~fxLSeq[i], \out, ~mixBus[i], \lfo1freq, 0.04, \lfo2freq, 0.05, \delayTime, 1.25, \decayTime, 0.13], ~fxGroup); });

		~revBypassPatch = Array.fill(~hardwareOutputs, { arg i;
			Synth(\mixIO, [\in, ~mixBus[i], \out, ~masterBus[i]], ~mixGroup); });

		~mixPatch = Array.fill(~hardwareOutputs, { arg i;
			Synth(\patchCord, [\in, ~masterBus[i], \out, i], ~masterGroup); });

		s.sync;

		~reTime = ReTime.new();

		Window.closeAll;
		s.meter (~hardwareInputs, ~hardwareOutputs);

		~w = Window("GUI Controls", Rect(800,200,480,520)).front.alwaysOnTop_(true);
		~w.view.decorator_(FlowLayout(~w.bounds, 20@20, 20@20));

		~masterFader = EZSlider.new(~w, Rect(20, 160, 430, 40), "master fader",
			ControlSpec.new(0.00, 1.5, \lin, 0.01, 0, ""), {
				arg slider;
				~hardwareOutputs.do {
					arg i;
					~mixPatch[i].set(\amp, slider.value)};
		}, 0, false, 80, 45).value_(~initLevel).setColors(Color.grey,Color.white);

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
						s.stop;
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
				0, {
					s.record();
					"OK: Recording in Progress".postln;
				},
				1, {
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

		~hardwareOutputs.do { arg i; ~mixPatch[i].set(\amp, ~initLevel ) };

		s.sync;

		c = Conductor.new();

		"OK: Loaded - Program Ready To Run".postln;

	});

});


s.record(bus:0, numChannels:33, duration:100)

c.kit
c.intensity

//22 with big dreamy bassy