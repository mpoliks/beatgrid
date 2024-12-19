(/* TO RUN, JUST HIT CMD+ENTER ANYWHERE WITHIN THIS PATCH */

/* ----- MAIN PARAMETERS ----- */

~hardwareInputs = 12; // should be 12 for 3o ambisonic system
~hardwareOutputs = 20; // can be 2 or 18 (16 + 2x sub)
~ambiOrder = 3; // third-order ambisonics = 16 channels
~numAmbiChans = ( ~ambiOrder + 1 )**2; // = 16
~tempo = 30;
~kitOverride = false; // for specific kit testing


~micLevel = 0.0; // input level of ambisonic mic
// can be \stereo, \stem, \false = default (live, no mixdown)
~mixdown = \false;
// master fader will only work if mixdown is false
~fadetime = 8.0; // Duration for fade in/out in seconds
~meditation = false; // initial state of whether or not the meditation playback is invoked
~meditationLevel = 0.6;
~nFLevel = 0.2; // night fountain level







/* ----- SERVER SPECS ----- */

ServerOptions.devices; //-- use this if you need to specifically invoke a hardware object
//Server.default.options.device = 0;
Server.default.options.numInputBusChannels = ~hardwareInputs;
Server.default.options.numOutputBusChannels = ~hardwareOutputs;
s.options.memSize = 365536;
s.options.numBuffers = 8096;
s.options.sampleRate = 48000;
s.options.numWireBufs = 1024;
s.reboot; // initialize audio server







/* ----- INITIALIZATIONS ----- */

~seed = [
	1, 0, 1, 1,
	1, 0, 1, 0,
	1, 0, 1, 0,
	0, 1, 1, 1,
	1, 0, 0, 0,
	0, 1, 1, 1,
	1, 0, 0, 1,
	1, 0, 1, 0,
]; // random 4x8 matrix to seed pattern generation

// a little manual mixer for live relevelling
~initLevel = 0.3; // default audio level for patterns
~scl = 0.51; // to scale instruments against loop
~bassLevel = 0.4 * ~scl;
~kickLevel = 0.45 * ~scl;
~snareLevel = 0.42 * ~scl;
~clapLevel = 0.50 * ~scl;
~hatLevel = 0.47 * ~scl;
~loopLevel = 0.33;
~hitLevel = 0.51 * ~scl;
~miscLevel = 0.22 * ~scl;
~loopLen = 60; // to set length of any looped multichannel background material

~instruments = [\bass, \kick, \snare, \clap, \hat, \loop, \hit, \misc];
~micMetrics = Dictionary.new;
// for audio gate:
~micGateThreshold = 0.1;
~micGateAttack = 0.25;
~micGateRelease = 0.25;







/* ----- SERVER INITIALIZATIONS ----- */
s.waitForBoot {

	s.sync;

	// allocate Groups to order I/O flow
	~dryGroup = Group.tail(s);
	~fxGroup = Group.tail(s);
	~analysisGroup = Group.tail(s);
	~ambiBusGroup = Group.tail(s);
	~ambiSumGroup = Group.tail(s);
	~ambiMixGroup = Group.tail(s);
	~finalMixGroup = Group.tail(s);
	~gainStageGroup = Group.tail(s);







/* ----- INSTRUMENTS ----- */
	~instrumentBuses = (
		\bass: (
			dryBus: Bus.audio(s, 1), // declares the associated instrument buses
			fxBus:  Bus.audio(s, 1),
			monoBus: Bus.audio(s, 1),
			ambiBus: Bus.audio(s, ~numAmbiChans),
			az: 0, // starting azimuth of audio
			el: 0, // starting elevation of audio
			tumbleRate: 0.0, // rotation around y-axis
			tiltRate: 0.0, // rotation around z-axis
			rotateRate: 0.02, // rotation around x-axis
			tumbleModAmount: 0.0, // degree to which an LFO modulates tumble frequency
			tiltModAmount: 0.0,
			rotateModAmount: 0.1,
			tumbleModRate: 0.0, // rate of the LFO modulating tumble frequency
			tiltModRate: 0.0,
			rotateModRate: 0.005
		),
		\kick: (
			dryBus: Bus.audio(s, 1),
			fxBus:  Bus.audio(s, 1),
			monoBus: Bus.audio(s, 1),
			ambiBus: Bus.audio(s, ~numAmbiChans),
			az: 0,
			el: 0,
			tumbleRate: 0.0,
			tiltRate: 0.0,
			rotateRate: 0.08,
			tumbleModAmount: 0.0,
			tiltModAmount: 0.0,
			rotateModAmount: 0.08,
			tumbleModRate: 0.0,
			tiltModRate: 0.0,
			rotateModRate: 0.005
		),
		\clap: (
			dryBus: Bus.audio(s, 1),
			fxBus:  Bus.audio(s, 1),
			monoBus: Bus.audio(s, 1),
			ambiBus: Bus.audio(s, ~numAmbiChans),
			az: -90,
			el: 0,
			tumbleRate: 0.0,
			tiltRate: 0.003,
			rotateRate: 0.02,
			tumbleModAmount: 0.0,
			tiltModAmount: 0.02,
			rotateModAmount: 0.1,
			tumbleModRate: 0.0,
			tiltModRate: 0.02,
			rotateModRate: 0.005
		),
		\snare: (
			dryBus: Bus.audio(s, 1),
			fxBus:  Bus.audio(s, 1),
			monoBus: Bus.audio(s, 1),
			ambiBus: Bus.audio(s, ~numAmbiChans),
			az: 135,
			el:270,
			tumbleRate: 0.01,
			tiltRate: 0.0,
			rotateRate: 0.03,
			tumbleModAmount: 0.001,
			tiltModAmount: 0.0,
			rotateModAmount: 0.1,
			tumbleModRate: 0.02,
			tiltModRate: 0.0,
			rotateModRate: 0.005
		),
		\hat: (
			dryBus: Bus.audio(s, 1),
			fxBus:  Bus.audio(s, 1),
			monoBus: Bus.audio(s, 1),
			ambiBus: Bus.audio(s, ~numAmbiChans),
			az: 180,
			el: 90,
			tumbleRate: 0.0,
			tiltRate: 0.0,
			rotateRate: 0.06,
			tumbleModAmount: 0.0,
			tiltModAmount: 0.0,
			rotateModAmount: 0.1,
			tumbleModRate: 0.0,
			tiltModRate: 0.0,
			rotateModRate: 0.005
		),
		\loop: (
			dryBus: Bus.audio(s, 1),
			fxBus:  Bus.audio(s, 1),
			monoBus: Bus.audio(s, 1),
			ambiBus: Bus.audio(s, ~numAmbiChans),
			az: 225,
			el: 0,
			tumbleRate: 0.0,
			tiltRate: 0.0,
			rotateRate: 0.0,
			tumbleModAmount: 0.0,
			tiltModAmount: 0.0,
			rotateModAmount: 0.0,
			tumbleModRate: 0.0,
			tiltModRate: 0.0,
			rotateModRate: 0.0
		),
		\hit: (
			dryBus: Bus.audio(s, 1),
			fxBus:  Bus.audio(s, 1),
			monoBus: Bus.audio(s, 1),
			ambiBus: Bus.audio(s, ~numAmbiChans),
			az: 270,
			el: 0,
			tumbleRate: 0.01,
			tiltRate: 0.1,
			rotateRate: 0.02,
			tumbleModAmount: 0.01,
			tiltModAmount: 0.04,
			rotateModAmount: 0.1,
			tumbleModRate: 0.06,
			tiltModRate: 0.07,
			rotateModRate: 0.002
		),
		\misc: (
			dryBus: Bus.audio(s, 1),
			fxBus:  Bus.audio(s, 1),
			monoBus: Bus.audio(s, 1),
			ambiBus: Bus.audio(s, ~numAmbiChans),
			az: 315,
			el: 90,
			tumbleRate: 0.0,
			tiltRate: 0.03,
			rotateRate: 0.0,
			tumbleModAmount: 0.0,
			tiltModAmount: 0.01,
			rotateModAmount: 0.0,
			tumbleModRate: 0.0,
			tiltModRate: 0.1,
			rotateModRate: 0.0
		)
	);







/* ----- MIC ----- */

	~micAmbiBus = Bus.audio(s, 12); // declares 16-channel bus to handle microphone input
	~micBuses = (
		\a: (
			monoBus: Bus.audio(s, 1),
			ambiBus: Bus.audio(s, ~numAmbiChans),
			az: 0,
			el: 30,
		),
		\b: (
			monoBus: Bus.audio(s, 1),
			ambiBus: Bus.audio(s, ~numAmbiChans),
			az: 90,
			el: 30,
		),
		\c: (
			monoBus: Bus.audio(s, 1),
			ambiBus: Bus.audio(s, ~numAmbiChans),
			az: 180,
			el: 30,
		),
		\d: (
			monoBus: Bus.audio(s, 1),
			ambiBus: Bus.audio(s, ~numAmbiChans),
			az: 270,
			el: 30,
		),
		\e: (
			monoBus: Bus.audio(s, 1),
			ambiBus: Bus.audio(s, ~numAmbiChans),
			az: 45,
			el: 150,
		),
		\f: (
			monoBus: Bus.audio(s, 1),
			ambiBus: Bus.audio(s, ~numAmbiChans),
			az: 135,
			el: 150,
		),
		\g: (
			monoBus: Bus.audio(s, 1),
			ambiBus: Bus.audio(s, ~numAmbiChans),
			az: 225,
			el: 150,
		),
		\h: (
			monoBus: Bus.audio(s, 1),
			ambiBus: Bus.audio(s, ~numAmbiChans),
			az: 315,
			el: 150,
		),
		\i: (
			monoBus: Bus.audio(s, 1),
			ambiBus: Bus.audio(s, ~numAmbiChans),
			az: 30,
			el: 270,
		),
		\j: (
			monoBus: Bus.audio(s, 1),
			ambiBus: Bus.audio(s, ~numAmbiChans),
			az: 120,
			el: 270,
		),
		\k: (
			monoBus: Bus.audio(s, 1),
			ambiBus: Bus.audio(s, ~numAmbiChans),
			az: 210,
			el: 270,
		),
		\l: (
			monoBus: Bus.audio(s, 1),
			ambiBus: Bus.audio(s, ~numAmbiChans),
			az: 300,
			el: 270,
		)
	);







/* ----- FILE RETRIEVAL ----- */

	~buffers = Dictionary.new;
	// peek into the directory and log what you see
	if (thisProcess.nowExecutingPath.notNil == true, {
		// look through the /samples directory
		p = PathName.new(thisProcess.nowExecutingPath.dirname +/+ "Samples/");
		// format logging
		~logPath = "~/"++Date.getDate.dayStamp.asString++".txt".standardizePath;
		// log samples found in each subdirectory
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
	// for issues in Windows
	{
		~appendLog.value("WARN: Windows Pathname Issue");
		p = PathName.new("C:/Users/User/Documents/GitHub/beatgrid/Samples");
	});
	// time to load everything into buffers
	p.folders.do({
		arg f;
		var bufs = Dictionary.new;
		bufs.add(f.folderName -> Dictionary.new);
		// iterate through sample directory
		f.folders.do({
			arg f_;
			var samples = Array.new;
			~appendLog.value(("OK: Processsing" + f_.entries.size.asString + "files from" + f_.asString));
			// store each sound in a buffer for easy retrieval
			f_.entries.do({ arg path;
				if (path.extension == "wav", {
					samples = samples.add(Buffer.read(s, path.fullPath));}); });
			// append entry into the general buffer dictionary
			bufs.at(f.folderName).putAll( Dictionary[f_.folderName -> samples]);
		});
		//complete the dictionary
		~buffers.putAll(bufs);
	});
	~meditationLoopBuffer = Buffer.read(s, thisProcess.nowExecutingPath.dirname
		+/+ "Meditation Loop/meditation.wav");
	~nightFountainLoopBuffer = Buffer.read(s, thisProcess.nowExecutingPath.dirname
		+/+ "Meditation Loop/nightfountain.wav");
	~appendLog.value("OK: Loading....");
	// wait for the server
	s.sync;
	// return an error if no samples found
	if ( p.folders == [], {
		~appendLog.value("ERR: No Samples Found -- Patch WILL NOT RUN"); });







/* ----- SYNTHDEFS ----- */

	SynthDef(\playback, { // playback synth for main sample playback
		arg rate = 1, atk = 0.09, rel = 2.4, lcut = 20, hcut = 20000, pan = 0,
		buf, amp = 1.0, out;
		// identify the buffer
		var sig = PlayBuf.ar(1, buf, BufRateScale.ir(buf) * rate, doneAction: 2),
		// envelope for playback, will release the synth once envelope or sample complete
		env = EnvGen.kr( Env.new([0,1,0], [atk, rel], [1, -1]), doneAction:2);
		// some filters for variation
		sig = HPF.ar(sig, lcut);
		sig = LPF.ar(sig, hcut);
		// final output with amplitude control
		Out.ar(out, sig * env * amp);
	}).add;

	SynthDef(\playbackP, { // playback synth (with pitch management)
		arg rate = 1, atk = 0.09, rel = 3.4, lcut = 20, hcut = 20000,
		repitch = 1.0, pdisp = 0.0, tdisp = 0.0, pan = 0, buf, amp = 1.0, out;
		var sig = PlayBuf.ar(1, buf, BufRateScale.ir(buf) * rate, doneAction: 2),
		env = EnvGen.kr( Env.new([0,1,0], [atk, rel], [1, -1]), doneAction:2);
		sig = HPF.ar(sig, lcut);
		sig = LPF.ar(sig, hcut);
		//sig = PitchShift.ar(sig, 0.2, repitch, pdisp = 0.1, tdisp = 0.1);
		Out.ar(out, sig * env * amp);
	}).add;

	SynthDef(\playbackM, { // playback synth for meditation loop
		arg buf, rate = 1, atk = 0.09, rel = 2.4, amp = 1.0, trig, out;
		// identify the buffer
		var sig = PlayBuf.ar(16, buf, BufRateScale.ir(buf) * rate, doneAction: 2),
		// envelope for playback, will release the synth once envelope or sample complete
		env = EnvGen.kr(Env.asr(~fadetime, 1, ~fadetime), gate: trig, doneAction: 2);
		// final output with amplitude control
		Out.ar(out, sig * env * amp);
	}).add;

	SynthDef(\playbackFountain, { // playback fountain
		arg buf, amp = 0.0, out;
		var sig = PlayBuf.ar(2, BufRateScale.ir(buf) * 1.0, loop: 1.0),
		fx = Greyhole.ar(sig, 1.0, (60/~tempo) * 0.333);
		Out.ar(out, ((sig + (0.3 * fx)) * amp));
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
		// delay with modulation
		//sig = AllpassC.ar(sig, 1.0, (60/~tempo) * delayTime, decayTime);
		sig = Greyhole.ar(sig, 1.0, (60/~tempo) * delayTime);
		// apply filters with modulated cutoff frequencies
		sig = LPF.ar(sig, lpfLFO);
		sig = HPF.ar(sig, hpfLFO);
		// add a reverb for more depth
		sig = JPverb.ar(sig);
		// output with defined amplitude
		sig = sig * amp;
		Out.ar(out, sig);
	}).add;

	SynthDef(\delay2, {
		arg in, out, delayTime = 0.33333,
		decayTime = 5, hcut = 10400, lcut = 10000, amp = 0.11, decay = 10;
		var sig = In.ar(in, 1),
		// main difference here is different approach to delay (uses AllpassC, and no LPF)
		hpfLFOFreq = XLine.kr(0.001, 0.1, 120),
		hpfLFO = SinOsc.kr(hpfLFOFreq, 0).range(1000, hcut);
		sig = AllpassC.ar(sig, 1.0, (60/~tempo) * delayTime, decayTime);
		sig = HPF.ar(sig, hpfLFO);
		sig = JPverb.ar(sig);
		sig = sig * amp;
		Out.ar(out, sig);
	}).add;

	SynthDef(\mixInstrument, { // for dry/wet mix at the instrument level
		arg inDry, inFx, out, amp = 1.0;
		var dry = In.ar(inDry, 1),
		fx = In.ar(inFx, 1),
		mixed = (dry + (0.8 * fx)) * amp;
		Out.ar(out, mixed);
	}).add;

	SynthDef(\micIn, { // mic input
		arg in, out;
		var sig = SoundIn.ar(in);
		//sig = HPF.ar(sig, 1000);
		Out.ar(out, sig);
	}).add;

	SynthDef(\inputAnalysis, {
		arg in;
		// full spectral analysis
		var
		sig = In.ar (in, 1),
		peak = Amplitude.ar(sig),
		rms = RMS.ar(sig),
		freq = Pitch.kr(sig),
		chain = FFT(LocalBuf(2048), sig),
		centroid = SpecCentroid.kr(chain),
		flat = SpecFlatness.kr(chain),
		rolloff = SpecPcile.kr(chain, 0.5),
		trig = Impulse.kr(1);
		// send analysis results over OSC
		SendReply.kr(trig,
			'/analysis',[
				in,
				peak,
				rms,
				freq[0],
				freq[1],
				centroid,
				flat,
				rolloff
			],
			10);
	}).add;

	SynthDef(\hoaEncodeGeneric, { // to encode mono instruments in HOA ambisonic space
		arg in = 0, out = 0,
		az = 0, el = 0,
		tumbleRate = 1, tiltRate = 1, rotateRate = 1,
		tumbleModAmount = 0, tiltModAmount = 0, rotateModAmount = 0,
		tumbleModRate = 0.1, tiltModRate = 0.1, rotateModRate = 0.1,
		radius = 2, order = 3;
		var sig = In.ar(in, 1),
		// modulation signals using SinOsc for smooth LFO modulation
		tumbleMod = SinOsc.kr(tumbleModRate, 0, tumbleModAmount, 0),
		tiltMod   = SinOsc.kr(tiltModRate,   0, tiltModAmount,   0),
		rotateMod = SinOsc.kr(rotateModRate, 0, rotateModAmount, 0),
		// encode the input signal into Ambisonics
		encoded = HoaEncodeDirection.ar(sig, az.degrad, el.degrad, radius, order:3);
		// apply tumble, tilt, and rotate with modulated rates
		encoded = HoaTumble.ar(encoded, LFSaw.kr(tumbleRate + tumbleMod, mul: pi), order:3);
		encoded = HoaTilt.ar(encoded, LFSaw.kr(tiltRate   + tiltMod,   mul: pi), order:3);
		encoded = HoaRotate.ar(encoded, LFSaw.kr(rotateRate + rotateMod, mul: pi), order:3);
		// output the encoded Ambisonic signal
		Out.ar(out, encoded);
	}).add;

	SynthDef(\sumAmbisonicBuses, { // matrix mixer for 8 instruments * 16
		arg outBus,
		inBus1 = 0, inBus2 = 0, inBus3 = 0, inBus4 = 0,
		inBus5 = 0, inBus6 = 0, inBus7 = 0, inBus8 = 0;
		// collect all ambisonic signals
		var signals = [
			In.ar(inBus1, 16),
			In.ar(inBus2, 16),
			In.ar(inBus3, 16),
			In.ar(inBus4, 16),
			In.ar(inBus5, 16),
			In.ar(inBus6, 16),
			In.ar(inBus7, 16),
			In.ar(inBus8, 16),
		],
		// sum all signals
		summedSignal = signals.sum;
		// output the summed signal
		Out.ar(outBus, summedSignal);
	}).add;

	SynthDef(\mixIO, { // compressor, limiter on the Ambisonic mix prior to final gain stage
		arg out, in, amp = 1.0, trig = 1,
		eqGains = #[1.0, 1.0, 1.0, 0.9, 0.9, 1.0, 1.0, 1.0],
		eqQ = 1.0; // a default Q for all bands
		var env, verb, sig = In.ar(in, 16), // Now reading all HOA channels
		lfo = SinOsc.kr(1 / (3* 60)).range(1, 10) + (LFNoise1.kr(0.01) * 0.5),
		eqFreqs = [63, 125, 250, 500, 1000, 2000, 4000, 8000], rq = 1 / eqQ;
		// apply the same processing to each channel of the ambisonic field
		sig = Compander.ar(sig, sig, thresh: 0.85, slopeBelow: 1.2, slopeAbove: 0.45, clampTime: 0.01, relaxTime: 0.01);
		eqFreqs.do{|freq, i|
			sig = BPeakEQ.ar(sig, freq, rq, eqGains[i]);
		};
		verb = HDVerb.ar(sig, mix: 0.2, decay: lfo);
		sig = ((sig * 0.5) + (verb * 0.8)) * amp;
		env = EnvGen.kr(Env.asr(~fadetime, 1, ~fadetime), gate: trig); // for triggering fadein/out for meditation blocks
		sig = Limiter.ar(sig, level: 0.94, dur: 0.1);
		sig = sig * env;
		Out.ar(out, sig);
	}).add;

	SynthDef(\masterGain, { |in, micIn, out, amp=1.0, micAmp=0.0|
		var sig = In.ar(in, 16), mic = In.ar(micIn, 12);
		// master fader
		sig = sig * amp;
		mic = mic * micAmp;
		// add in ambisonic mic post-fader
		sig = sig + mic;
		Out.ar(out, sig);
	}).add;

	SynthDef(\downmixToStereo, { |in, out = 0|
		var insig = In.ar(in, 16);
		// take W and maybe some other channels to fake stereo:
		var w = Select.ar(0, insig); // W channel is 0
		var x = Select.ar(3, insig); // X channel
		// simple fake stereo: w+(0.5*x) left, w-(0.5*x) right
		var left = w + (0.5 * x);
		var right = w - (0.5 * x);
		Out.ar(out, [left, right]);
	}).add;

	SynthDef(\directAmbiOut, { |in|
		var sig = In.ar(in, 16);
		Out.ar(0, sig);
	}).add;

	s.sync;







/* ----- INSTANCES ----- */

	~micBuses.keys.do {
		|micChan|
		var data = ~micBuses[micChan];

		Synth(\micIn, [
			\out, data[\monoBus],
			\in, micChan
		], ~dryGroup);

		Synth(\hoaEncodeGeneric, [
			\in, data[\monoBus],
			\out, data[\ambiBus],
			\az, data[\az],
			\el, data[\el]
		], ~ambiBusGroup);
	};

	OSCdef(
		\analysis_listener, {
			arg msg;
			var pitch = 0;

			if (msg[7] == 0.0, { pitch = 0; }, {pitch = msg[6]; });

			~micMetrics.putAll(
				Dictionary[msg[3].asString ->
					Dictionary[
						\peak -> msg[4],
						\rms -> msg[5],
						\pitch -> pitch,
						\hasPitch -> msg[7],
						\cent -> msg[8],
						\flat -> msg[9],
						\rolloff -> msg[10]]]);
	}, '/analysis');

	~instrumentBuses.keys.do { |instr|
		var data = ~instrumentBuses[instr],
		// iterate through instrument buses and create appropriate fx lines
		fx1 = Synth(\delay, [\in, data[\dryBus], \out, data[\fxBus]], ~fxGroup),
		fx2 = Synth(\delay2, [\in, data[\dryBus], \out, data[\fxBus]], ~fxGroup),
		// mix dry + fx into mono
		mixSynth = Synth(\mixInstrument, [
			\inDry, data[\dryBus],
			\inFx,  data[\fxBus],
			\out,   data[\monoBus],
			\amp, 1.0, // Start with full amplitude
			\fadeBus, ~fadeBus // Pass the fadeBus to the Synth
		], ~dryGroup);
		// store the synth references
		~mixInstrumentSynths = ~mixInstrumentSynths.add(mixSynth);
		// encode to HOA
		Synth(\hoaEncodeGeneric, [
			\in, data[\monoBus],
			\out, data[\ambiBus],
			\az, data[\az],
			\el, data[\el],
			\tumbleRate, data[\tumbleRate],
			\tiltRate, data[\tiltRate],
			\rotateRate, data[\rotateRate],
			\tumbleModAmount, data[\tumbleModAmount],
			\tiltModAmount, data[\tiltModAmount],
			\rotateModAmount, data[\rotateModAmount],
			\tumbleModRate, data[\tumbleModRate],
			\tiltModRate, data[\tiltModRate],
			\rotateModRate, data[\rotateModRate]
		], ~ambiBusGroup);
	};

	// add the mic signal alongside the converted instrument buses
	~ambiBuses = ~instrumentBuses.values.collect({ |v| v[\ambiBus] });
	// declare the sum bus for all of the ambisonic signals
	~ambiSumBus = Bus.audio(s, ~numAmbiChans);
	// sum them together
	Synth(\sumAmbisonicBuses, [
		\outBus, ~ambiSumBus,
		\inBus1, ~ambiBuses[0],
		\inBus2, ~ambiBuses[1],
		\inBus3, ~ambiBuses[2],
		\inBus4, ~ambiBuses[3],
		\inBus5, ~ambiBuses[4],
		\inBus6, ~ambiBuses[5],
		\inBus7, ~ambiBuses[6],
		\inBus8, ~ambiBuses[7]], ~ambiSumGroup);
	~micAmbiBuses = ~micBuses.values.collect({ |v| v[\ambiBus] });
	// declare the sum bus for all of the ambisonic signals
	~micSumBus = Bus.audio(s, ~numAmbiChans);
	// sum them together
	Synth(\sumAmbisonicBuses, [
		\outBus, ~micSumBus,
		\inBus1, ~micAmbiBuses[0],
		\inBus2, ~micAmbiBuses[1],
		\inBus3, ~micAmbiBuses[2],
		\inBus4, ~micAmbiBuses[3],
		\inBus5, ~micAmbiBuses[4],
		\inBus6, ~micAmbiBuses[5],
		\inBus7, ~micAmbiBuses[6],
		\inBus8, ~micAmbiBuses[7]], ~ambiSumGroup);
	~finalAmbiBus = ~ambiSumBus;
	// declare the output bus for mixIO on top of the summed buses
	~processedAmbiBus = Bus.audio(s, ~numAmbiChans);
	// compress / limit / EQ a bit with the mixIO synth
	~mixIOSynth = Synth(\mixIO, [\in, ~finalAmbiBus, \out, ~processedAmbiBus], ~ambiMixGroup);
	// push to the master fader
	~finalGainBus = Bus.audio(s, ~numAmbiChans);
	// declare the master fader object
	~masterGainSynth = Synth(
		\masterGain, [
			\in, ~processedAmbiBus,
			\micIn, ~micSumBus,
			\out, ~finalGainBus,
			\amp, ~initLevel ], ~finalMixGroup);

	~subwooferMix = Synth(\downmixToStereo, [\in,  ~finalGainBus, \out, 18], ~gainStageGroup);

	// if we are just monitoring on headphones (2 channels), decode or downmix
	// if we have 16 outputs (the install), route directly:
	if (~hardwareOutputs == 2, {
		// simple downmix to stereo using a FOA->Stereo approximation or using just W channel:
		// for a quick hack: take W channel only (first channel of ambisonics)
		// a proper decode requires a decode matrix or ATK decode.
		Synth(\downmixToStereo, [\in,  ~finalGainBus], ~gainStageGroup);
	}, {
		// If we have 16 hardware outputs, directly send them out:
		Synth(\directAmbiOut, [\in,  ~finalGainBus], ~gainStageGroup);
	});

	~nFSynth = Synth(\nightFountain, [\out, 0, \buf, ~nightFountainBuffer], ~gainStageGroup);







/* ----- FADES ----- */

	// function declarations for fading in/out instruments
	~fadeOut = {
		~appendLog.value("Fading out...");
		~mixIOSynth.set(\trig, 0);
	};

	~fadeIn = {
		~appendLog.value("Fading in...");
		~mixIOSynth.set(\trig, 1);
	};
	// toggle function
	~toggleMeditation = {
		~meditation = ~meditation.not;
		if (~meditation, {
			~appendLog.value("~meditation set to TRUE. Initiating fade out.");
			~fadeOut.value;
			~meditationSynth = Synth(\playbackM, [
				\buf, ~meditationLoopBuffer,
				\amp, ~meditationLevel,
				\trig, 1,
				\out, 0]);
		}, {
			~appendLog.value("~meditation set to FALSE. Initiating fade in.");
			~fadeIn.value;
			if (~meditationSynth.notNil, {
				~meditationSynth.set(\trig, 0);
			})
		});
	};







/* ----- WRAP UP ----- */

	s.sync; // resync server
	~reTime = ReTime.new(); // add swing over global time grid







/* ----- GUI ----- */

	Window.closeAll; // kill all existing GUI objects
	s.meter (~hardwareInputs, ~hardwareOutputs); // bring up amplitude meter

	~w = Window("GUI Controls", Rect(800,200,460,660)).front.alwaysOnTop_(true);
	// create host window for GUI
	~w.view.decorator_(FlowLayout(~w.bounds, 20@20, 20@20));
	// add decorator object to govern GUI object behavior

	~masterFader = EZSlider.new(~w, Rect(20, 160, 430, 40), "master fader",
		ControlSpec.new(0.00, 1.5, \lin, 0.01, 1.0, ""), // default 1.0
		{ arg slider; ~masterGainSynth.set(\amp, slider.value); },
		0, false, 80, 45
	).value_(~initLevel).setColors(Color.grey, Color.white);
	// master fader for global volume of instruments

	~micFader = EZSlider.new(~w, Rect(20, 160, 430, 40), "mic fader",
		ControlSpec.new(0.00, 1.5, \lin, 0.01, 1.0, ""), // default 1.0
		{ arg slider; ~masterGainSynth.set(\micAmp, slider.value); },
		0, false, 80, 45
	).value_(~micLevel).setColors(Color.grey, Color.white);
	// mic input fader

	~fountainFader = EZSlider.new(~w, Rect(20, 160, 430, 40), "fountain fader",
		ControlSpec.new(0.00, 1.5, \lin, 0.01, 1.0, ""), // default 1.0
		{ arg slider; ~nFSynth.set(\amp, slider.value); },
		0, false, 80, 45
	).value_(~nFLevel).setColors(Color.grey, Color.white);
	// mic input fader

	~startButton = Button(~w, Rect(20, 20, 420, 40))
	.states_([["Start", Color.gray, Color.yellow], ["Halt", Color.gray, Color.red]])
	.action_({ arg state;
		switch(state.value,
			0, {
				"OK: Running Patch".postln;
				c.conduct(~seed);
			},
			1, {
				"WARN: Stopping Patch".postln;
				if (c.notNil == true, {
					c.flag=false;
				});
			}
		);
	}).value_(1);
	// stop/start patch

	~nextKitTrigger = EZNumber(~w, Rect(150, 10, 140, 30),"Change Kit",
		ControlSpec.new(0,~buffers.size - 1,\lin,1), { arg n;
			if (c.notNil == true, {
				c.kit = n.value.asInteger;
				~kitOverride = true;
				("OK: Forcing Kit" + n.value.asInteger.asString).postln; });
	});
	// force movement to a new kit

	~intensityTrigger = EZNumber(~w, Rect(150, 10, 140, 30), "Change Intensity",
		ControlSpec.new(0, 4, \lin, 1), { arg n;
			if (c.notNil == true, {
				c.intensity = n.value.asInteger;
				~intensityOverride = true;
				("OK: Forcing Intensity" + n.value.asInteger.asString).postln; });
	});
	// force movement to a new intensity level

	~simulateHour = EZNumber(~w, Rect(150, 10, 140, 30), "Change Start Hour",
		ControlSpec.new(0, 24, \lin, 1), { arg n;
			if (c.notNil == true, {
				c.time_override = n.value.asInteger;
				~timeOverride = true;
				("OK: Forcing Hour" + n.value.asInteger.asString).postln; });
	});
	// simulate time of day

	~forceTransition = Button(~w, Rect(120, 20, 420, 40))
	.states_([["Force State Change", Color.gray, Color.yellow]])
	.action_({ arg state;
		switch(state.value,
			0, {
				~transitionOverride = true;
		});
	});
	// force transition to a new state

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
	// toggle new recording

	~meditationButton = Button(~w, Rect(20, 220, 420, 40))
	.states_([["Toggle Meditation", Color.gray, Color.green]])
	.action_({ arg state;
		~toggleMeditation.value;
	});
	// force meditation state

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
	// kill switches for individual instruments







/* ----- GO TIME ----- */
	s.sync;
	c = Conductor.new(); // initialize Conductor class
	~appendLog.value("OK: Loaded - Program Ready To Run");

	s.sync; // wait for the server to catch up and start the Conductor
	~appendLog.value("OK: Running Patch");
	c.conduct(~seed, s);

});







/* ----- UTILITIES FOR INPUT MONITORING ----- */

(
~micMetrics.keysValuesDo({ |channel, metrics|
    ("Channel: " ++ channel ++ ", Metrics: " ++ metrics).postln;
})
)

(
~getChannelWithHighestRMS = {
    var maxRMS = -1;
    var maxChannel = nil;

    ~micMetrics.keysValuesDo({ |channel, metrics|
        if (metrics[\rms] > maxRMS) {
            maxRMS = metrics[\rms];
            maxChannel = channel;
        };
    });

    [maxChannel, maxRMS]; // Return as an array: [channel, rms]
}.value.postln;
)

(
~averageMetrics = {
    var sumMetrics = Dictionary[
        \peak -> 0,
        \rms -> 0,
        \pitch -> 0,
        \hasPitch -> 0,
        \cent -> 0,
        \flat -> 0,
        \rolloff -> 0
    ];

    var numChannels = ~micMetrics.size;

    // Use keysValuesDo to iterate through each key-value pair in the dictionary
    ~micMetrics.keysValuesDo({ |channel, metrics|
        sumMetrics[\peak] = sumMetrics[\peak] + metrics[\peak];
        sumMetrics[\rms] = sumMetrics[\rms] + metrics[\rms];
        sumMetrics[\pitch] = sumMetrics[\pitch] + metrics[\pitch];
        sumMetrics[\hasPitch] = sumMetrics[\hasPitch] + metrics[\hasPitch];
        sumMetrics[\cent] = sumMetrics[\cent] + metrics[\cent];
        sumMetrics[\flat] = sumMetrics[\flat] + metrics[\flat];
        sumMetrics[\rolloff] = sumMetrics[\rolloff] + metrics[\rolloff];
    });

    // Divide each metric by the number of channels
    sumMetrics.keysValuesDo({ |key, value|
        sumMetrics[key] = value / numChannels;
    });

	sumMetrics; // Return the averaged metrics dictionary
}.value.postln;
)

// to tweak mic gate
~mic.set(\threshold, 0.02, \attack, 0.3, \release, 0.3);
