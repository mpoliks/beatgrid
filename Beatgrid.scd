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

~scl = 0.5;
~bassLevel = 0.85 * ~scl;
~kickLevel = 0.60 * ~scl;
~snareLevel = 0.40 * ~scl;
~clapLevel = 0.47 * ~scl;
~hatLevel = 0.5 * ~scl;
~loopLevel = 0.25 * ~scl;
~hitLevel = 0.50 * ~scl;
~miscLevel = 0.50 * ~scl;

~loopLen = 60;

//---- END TEMP

s.waitForBoot {


	s.sync;
	~buffers = Dictionary.new;
	if (thisProcess.nowExecutingPath.notNil == true, {
		p = PathName.new(thisProcess.nowExecutingPath.dirname +/+ "Samples/");
	},
	{
		"WARN: Windows Pathname Issue".postln;
		p = PathName.new("C:/Users/User/Documents/GitHub/beatgrid/Samples");
		// TO FIX STUPID WINDOWS BUG
	});

	s.sync;

	p.folders.do({ //samples
		arg f;
		var bufs = Dictionary.new;
		bufs.add(f.folderName -> Dictionary.new);

		f.folders.do({
			arg f_;
			var samples = Array.new;

			f_.folderName.postln;

			("OK: Processsing" + f_.entries.size.asString + "files from" + f_.asString).postln;

			if (f_.folderName == "loop", {
				f_.entries.do({ arg path;
					samples = samples.add(Buffer.cueSoundFile(s, path.fullPath, 0, 33));
					bufs.at(f.folderName).putAll( Dictionary[f_.folderName -> samples]);
				})
			});
		});

		f.folders.do({
			arg f_;
			var samples = Array.new;
			if(f_.folderName != "loop", {
				f_.entries.do({ arg path;
					samples = samples.add(Buffer.read(s, path.fullPath));});
				bufs.at(f.folderName)
				.putAll( Dictionary[f_.folderName -> samples]);
			});
		});

		~buffers.putAll(bufs);
	});

	s.sync;

	p.folders.postln;

	if ( p.folders == [], {
		"ERR: No Samples Found -- Patch WILL NOT RUN".postln; },
	{

		"OK: Loading....".postln;

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
			arg bufnum, out, amp = 1.0, atk, rel;
			var sig = DiskIn.ar(33, bufnum),
			env = EnvGen.kr( Env.new([0,1,0], [atk, rel], [1, -1]), doneAction:2);
			Out.ar(out, sig * amp * env);
		}).add;

		SynthDef(\hdVerb, { // nice sounding SC reverb
			arg in, out, predelay = 0.1, decay = 0.6, lpf1 = 14000, lpf2 = 15000, mix = 0.2;
			var sig = In.ar(in, 1);
			sig = Compander.ar(sig, sig, thresh: 0.5, slopeBelow: 1.0,
				slopeAbove: 0.25, clampTime: 0.01, relaxTime: 0.09);
			sig = HPF.ar(sig, 330);
			sig = HDVerb.ar(sig, mix: mix, predelay: predelay, decay: decay, lpf1: lpf1, lpf2: lpf2);
			Out.ar(out, sig);
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
			sig = Compander.ar(sig,	sig, thresh: 0.55, slopeBelow: 1.1, slopeAbove: 0.45, clampTime: 0.01, relaxTime: 0.01);
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
			Synth(\delay, [\in, ~fxSSeq[i], \out, ~mixBus[i], \delayTime, 0.66666, \decayTime, 0.1], ~fxGroup); });

		~dlyS2Patch = Array.fill(~hardwareOutputs, { arg i;
			Synth(\delay, [\in, ~fxSSeq[i], \out, ~mixBus[i], \delayTime, 0.75, \decayTime, 0.1], ~fxGroup); });

		~dlyMPatch = Array.fill(~hardwareOutputs, { arg i;
			Synth(\delay, [\in, [i], ~fxMSeq[i], \out, ~mixBus[i], \lfo1freq, 0.20, \lfo2freq, 0.03, \delayTime, 0.75, \decayTime, 0.1], ~fxGroup); });

		~dlyM2Patch = Array.fill(~hardwareOutputs, { arg i;
			Synth(\delay, [\in, ~fxMSeq[i], \out, ~mixBus[i], \lfo1freq, 0.10, \lfo2freq, 0.02, \delayTime, 0.25, \decayTime, 0.07], ~fxGroup); });

		~dlyLPatch = Array.fill(~hardwareOutputs, { arg i;
			Synth(\delay, [\in, ~fxLSeq[i], \out, ~mixBus[i], \lfo1freq, 0.10, \lfo2freq, 0.03, \delayTime, 0.5, \decayTime, 0.2], ~fxGroup); });

		~dlyL2Patch = Array.fill(~hardwareOutputs, { arg i;
			Synth(\delay, [\in, ~fxLSeq[i], \out, ~mixBus[i], \lfo1freq, 0.01, \lfo2freq, 0.03, \delayTime, 0.75, \decayTime, 0.1], ~fxGroup); });

		~dlyL3Patch = Array.fill(~hardwareOutputs, { arg i;
			Synth(\delay, [\in, ~fxLSeq[i], \out, ~mixBus[i], \lfo1freq, 0.04, \lfo2freq, 0.05, \delayTime, 1.25, \decayTime, 0.1], ~fxGroup); });

		~revPatch = Array.fill(~hardwareOutputs, { arg i;
			Synth(\hdVerb, [\in, ~mixBus[i], \out, ~masterBus[i]], ~mixGroup); });

		~revBypassPatch = Array.fill(~hardwareOutputs, { arg i;
			Synth(\patchCord, [\in, ~mixBus[i], \out, ~masterBus[i]], ~mixGroup); });

		~mixPatch = Array.fill(~hardwareOutputs, { arg i;
			Synth(\mixIO, [\in, ~masterBus[i], \out, i], ~masterGroup); });

		s.sync;

		~reTime = ReTime.new();

		Window.closeAll;
		s.meter (~hardwareInputs, ~hardwareOutputs);

		~w = Window("GUI Controls", Rect(1500,500,550,200)) .front.alwaysOnTop_(true);
		~w.view.decorator_(FlowLayout(~w.bounds, 10@10, 10@10));

		~masterFader = EZSlider.new(~w, Rect(20, 160, 430, 40), "master fader",
			ControlSpec.new(0.00, 1.0, \lin, 0.01, 0, ""), {
				arg slider;
				~hardwareOutputs.do {
					arg i;
					~mixPatch[i].set(\amp, slider.value)};
		}, 0, false, 80, 45).value_(1.0).setColors(Color.grey,Color.white);

		~startButton = Button(~w, Rect(20, 20, 340, 30))
		.states_([["Start", Color.gray, Color.yellow], ["Halt", Color.gray, Color.red]])
		.action_({ arg state;
			switch(state.value,
				1, {
					"OK: Running Patch".postln;
					c = Conductor.new(); // STEP 1 TO RUN PATCH (use Shift + Enter)
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

		~forceTransition = Button(~w, Rect(20, 20, 340, 30))
		.states_([["Force", Color.gray, Color.yellow]])
		.action_({ arg state;
			switch(state.value,
				0, {
					if (c.notNil == true, { c.event_time = Date.getDate; }); });
		});

		~nextKitTrigger = NumberBox(~w, Rect(150, 10, 100, 20))
		.value_(0).action_({
			arg n;
			if (c.notNil == true, {
				c.kit = n.value.asInteger;
			});
		});

		~recordButton = Button(~w, Rect(20, 20, 340, 30))
		.states_([["Start Recording", Color.gray, Color.yellow], ["Stop Recording", Color.gray, Color.red]])
		.action_({ arg state;
			switch(state.value,
				0, {
					s.record(~hardwareOutputs);
					"OK: Recording in Progress".postln;
				},
				1, {
					s.stopRecording;
					"WARN: Stopped Recording".postln;
				}
			);
		}).value_(0);

		"OK: Loaded - Program Ready To Run".postln;

	});

});
