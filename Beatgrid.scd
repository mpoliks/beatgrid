(
~hardwareInputs = 1;
~hardwareOutputs = 2;
~tempo = 60;
~kitOverride = false;


//ServerOptions.devices;
Server.default.options.numInputBusChannels = ~hardwareInputs;
Server.default.options.numOutputBusChannels = ~hardwareOutputs;
s.options.memSize = 265536;
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

	~bassLevel = 0.2;
	~kickLevel = 0.2;
	~snareLevel = 0.08;
	~clapLevel = 0.07;
	~hatLevel = 0.05;
	~loopLevel = 0.13;
	~hitLevel = 0.08;
	~miscLevel = 0.06;

	~loopLen = 20;

//---- END TEMP

s.waitForBoot {

	~buffers = Dictionary.new;
	p = PathName.new(thisProcess.nowExecutingPath.dirname +/+ "Samples/");

	s.sync;

	p.folders.do({ //samples
		arg f;
		var bufs = Dictionary.new;
		bufs.add(f.folderName -> Dictionary.new);

		f.folders.do({
			arg f_;
			var samples = Array.new;

			("OK: Processsing" + f_.entries.size.asString + "files from" + f_.asString).postln;
				f_.entries.do({ arg path;
					samples = samples.add(Buffer.read(s, path.fullPath));});
				bufs.at(f.folderName)
					.putAll( Dictionary[f_.folderName -> samples]);
		});


		~buffers.putAll(bufs);
	});

	"OK: Loading....".postln;

	s.sync;

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

	SynthDef(\hdVerb, { // nice sounding SC reverb
		arg in, out, predelay = 1.0, decay = 6.0, lpf1 = 14000, lpf2 = 15000;
		var sig = In.ar(in, 2);
		sig = Compander.ar(sig, sig, thresh: 0.5, slopeBelow: 1.0,
			slopeAbove: 0.25, clampTime: 0.01, relaxTime: 0.09);
		sig = HDVerb.ar(sig, predelay: predelay, decay: decay, lpf1: lpf1, lpf2: lpf2);
		Out.ar(out, sig);
	}).add;

	SynthDef(\delay, {
		arg in, out, lfo1freq = 0.02, lfo2freq = 0.01, delayTime = 0.33333, decayTime = 1.4, hcut = 12000, lcut = 200, amp = 0.2;
		var sig = In.ar(in, 2),
		lfo1 = SinOsc.kr(lfo1freq, 0.3, 1.0, 7000),
		lfo2 = SinOsc.kr(lfo2freq, 1.0, 1.0, 7000);
		sig = AllpassC.ar(sig, 1.0, (60/~tempo) * delayTime, decayTime);
		sig = LPF.ar(sig, hcut - lfo1);
		sig = HPF.ar(sig, lcut + lfo2);
		//sig = AnalogVintageDistortion.ar(sig, 0.1);
		sig = sig * amp;
		Out.ar(out, sig);
	}).add;

	SynthDef(\mixIO, { // compressor and limiter on the mix bus
		arg out = 0, in = 0, amp = 0.01;
		var sig = In.ar(in, 2);
		sig = Compander.ar(sig,	sig, thresh: 0.5, slopeBelow: 1.0, slopeAbove: 0.25, clampTime: 0.01, relaxTime: 0.01);
		//sig = DCompressor.ar(sig);
		sig = sig * amp;
		sig = BPeakEQ.ar(sig, 100, 1.0, 4.0);
		//sig = AnalogTape.ar(sig, 0.5, 0.3, 0.3);
		sig = Limiter.ar(sig, level: 0.94, dur: 0.1);
		Out.ar(out, sig);
	}).add;

	SynthDef(\patchCord, {
		arg in, out, amp = 1;
		var input = In.ar(in, 2);
		Out.ar(out, input * amp)
	}).add;

	s.sync;

	~playbackGroup = Group.tail(s);
	~dryGroup = Group.tail(s); ~fxGroup = Group.tail(s); ~mixGroup = Group.tail(s);


	~atrWall_dryBus = Array.fill(8, { Bus.audio(s, 1) });
	~atrCeiling_dryBus = Array.fill(8, { Bus.audio(s, 1) });
	~retAlcove_dryBus = Array.fill(16, { Bus.audio(s, 1) });
	~retCeiling_dryBus = Array.fill(8, { Bus.audio(s, 1) });

	~atrWall_fxSBus = Array.fill(8, { Bus.audio(s, 1) });
	~atrCeiling_fxSBus = Array.fill(8, { Bus.audio(s, 1) });
	~retAlcove_fxSbus = Array.fill(16, { Bus.audio(s, 1) });
	~retCeiling_fxSBus = Array.fill(8, { Bus.audio(s, 1) });

	~atrWall_fxMBus = Array.fill(8, { Bus.audio(s, 1) });
	~atrCeiling_fxMBus = Array.fill(8, { Bus.audio(s, 1) });
	~retAlcove_fxMBus = Array.fill(16, { Bus.audio(s, 1) });
	~retCeiling_fxMBus = Array.fill(8, { Bus.audio(s, 1) });

	~atrWall_fxLBus = Array.fill(8, { Bus.audio(s, 1) });
	~atrCeiling_fxLBus = Array.fill(8, { Bus.audio(s, 1) });
	~retAlcove_fxLbus = Array.fill(16, { Bus.audio(s, 1) });
	~retCeiling_fxLBus = Array.fill(8, { Bus.audio(s, 1) });

	~mixBus = Array.fill(40, { Bus.audio(s, 1) });

	s.sync;

	~dryPatch = Array.fill(40, {
		arg i;
		var buses = ~atrWall_dryBus ++
				~atrCeiling_dryBus ++
				~retAlcove_dryBus ++
				~retCeiling_dryBus;

		Synth(\patchCord, [\in, buses[i], ~out, ~mixBus[i]], ~dryGroup);

	});


	~dlySPatch = Array.fill(40, {
		arg i;
		var buses = ~atrWall_fxSBus ++
				~atrCeiling_fxSBus ++
				~retAlcove_fxSBus ++
				~retCeiling_fxSBus;
		Synth(\delay,
			[\in, buses[i], \out, ~mixBus[i],
				\delayTime, 0.66666, \decayTime, 0.1],
			~fxGroup);
	});

	~dlyS2Patch = Array.fill(40, {
		arg i;
		var buses = ~atrWall_fxSBus ++
				~atrCeiling_fxSBus ++
				~retAlcove_fxSBus ++
				~retCeiling_fxSBus;
		Synth(\delay,
			[\in, buses[i], \out, ~mixBus[i],
				\delayTime, 0.75, \decayTime, 0.1],
			~fxGroup);
	});

	~dlyMPatch = Array.fill(40, {
		arg i;
		var buses = ~atrWall_fxMBus ++
				~atrCeiling_fxMBus ++
				~retAlcove_fxMBus ++
				~retCeiling_fxMBus;
		Synth(\delay,
			[\in, buses[i], \out, ~mixBus[i],
				\lfo1freq, 0.20, \lfo2freq, 0.03, \delayTime, 0.75, \decayTime, 0.1],
			~fxGroup);
	});


	~dlyM2Patch = Array.fill(40, {
		arg i;
		var buses = ~atrWall_fxMBus ++
				~atrCeiling_fxMBus ++
				~retAlcove_fxMBus ++
				~retCeiling_fxMBus;
		Synth(\delay,
			[\in, buses[i], \out, ~mixBus[i],
				\lfo1freq, 0.10, \lfo2freq, 0.02, \delayTime, 0.25, \decayTime, 0.07],
			~fxGroup);
	});


	~dlyLPatch = Array.fill(40, {
		arg i;
		var buses = ~atrWall_fxLBus ++
				~atrCeiling_fxLBus ++
				~retAlcove_fxLBus ++
				~retCeiling_fxLBus;
		Synth(\delay,
			[\in, buses[i], \out, ~mixBus[i],
				\lfo1freq, 0.10, \lfo2freq, 0.03, \delayTime, 0.5, \decayTime, 0.2],
			~fxGroup);
	});

	~dlyL2Patch = Array.fill(40, {
		arg i;
		var buses = ~atrWall_fxLBus ++
				~atrCeiling_fxLBus ++
				~retAlcove_fxLBus ++
				~retCeiling_fxLBus;
		Synth(\delay,
			[\in, buses[i], \out, ~mixBus[i],
				\lfo1freq, 0.01, \lfo2freq, 0.03, \delayTime, 0.75, \decayTime, 0.1],
			~fxGroup);
	});

	~dlyL3Patch = Array.fill(40, {
		arg i;
		var buses = ~atrWall_fxLBus ++
				~atrCeiling_fxLBus ++
				~retAlcove_fxLBus ++
				~retCeiling_fxLBus;
		Synth(\delay,
			[\in, buses[i], \out, ~mixBus[i],
				\lfo1freq, 0.04, \lfo2freq, 0.05, \delayTime, 1.25, \decayTime, 0.1],
			~fxGroup);
	});

	~mixPatch = Array.fill(40, {
		arg i;
		Synth(\mixIO, [\in, ~mixBus[i], \out, i], ~mixGroup);
	});


	s.sync;

	~reTime = ReTime.new();

	Window.closeAll;
	s.meter(0, ~hardwareOutputs);

	~w = Window("GUI Controls", Rect(0,-100,440, 80))
	.front.alwaysOnTop_(true);
	~w.view.decorator_(FlowLayout(~w.bounds, 10@10, 10@10));

	~mFader = EZSlider.new(
	~w, Rect(20, 16.0, 420, 60),
	"Master",
	ControlSpec.new(0.0, 1.0, \lin, 0.01, 1, ""), {
		arg slider;
		~mixOut.set(
			\amp, slider.value)
		}, 0.3, false, 80, 45).value_(0.3)
	.setColors(Color.grey,Color.white);


	"OK: Loaded - Program Ready To Run".postln;

});


// MANUAL ACTIONS:

c = Conductor.new() // STEP 1 TO RUN PATCH (use Shift + Enter)

c.conduct(~seed) // STEP 2 TO RUN PATCH (use Shift + Enter)


s.record(); // Shift + Enter to RECORD

(
c.kit = 0; // Command + Enter to force a kit override during the next transition
~kitOverride = true;
);

c.event_time = Date.getDate; // Shift + Enter to force a transition


~mixOut.set(\amp, 0)

c.flag=false
