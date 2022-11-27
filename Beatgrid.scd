

/*
some todos:
- what does scheduling pattern generation look like?
- how to make a new pattern every x# minutes
- finalize kits and how they are related
- create a few rockin' FX
*/


(
~hardwareInputs = 1;
~hardwareOutputs = 16;
~tempo = 60;


//ServerOptions.devices;
Server.default.options.numInputBusChannels = ~hardwareInputs;
Server.default.options.numOutputBusChannels = ~hardwareOutputs;
s.options.memSize = 65536;
s.options.numBuffers = 8096;
s.reboot;

//---- PLACEHOLDER TEMP

	~seed = [
		1, 0, 1, 1,
		1, 0, 1, 0,
		1, 0, 1, 0,
		0, 1, 1, 1,
		1, 0, 0, 0,
		0, 1, 1, 1,
		0, 0, 0, 0,
		1, 0, 1, 0,
	];

	~bassLevel = 0.2;
	~kickLevel = 0.2;
	~snareLevel = 0.08;
	~clapLevel = 0.06;
	~hatLevel = 0.1;
	~loopLevel = 0.2;
	~hitLevel = 0.08;

	~loopLen = 20;

//---- END TEMP

s.waitForBoot {

	~buffers = Dictionary.new;
	p = PathName.new(thisProcess.nowExecutingPath.dirname +/+ "Samples/");

	p.folders.do({ //samples
		arg f;
		var bufs = Dictionary.new;
		bufs.add(f.folderName -> Dictionary.new);

		f.folders.do({
			arg f_;
			var samples = Array.new;
			if ((f_.folderName != "F#") && (f_.folderName != "C#"), {
				f_.entries.do({ arg path;
					samples = samples.add(Buffer.read(s, path.fullPath));});
				bufs.at(f.folderName)
					.putAll( Dictionary[f_.folderName.asInteger -> samples]);
			},
			{
				bufs.at(f.folderName).add(f_.folderName -> Dictionary.new);
				f_.folders.do({
					arg f__;
					var samples_ = Array.new;
					f__.entries.do({ arg path;
						samples_ = samples_.add(Buffer.read(s, path.fullPath));});
					bufs.at(f.folderName).at(f_.folderName)
						.putAll(Dictionary[f__.folderName.asInteger -> samples_]);
				});
			});
		});
		~buffers.putAll(bufs);
	});

	s.sync;

	SynthDef(\playback, { // playback synth
		arg rate = 1, atk = 0.001, rel = 1.4, lcut = 20, hcut = 20000, pan = 0,
			buf, amp = 1.0, out;
		var sig = PlayBuf.ar(1, buf, BufRateScale.ir(buf) * rate, doneAction: 2),
		env = EnvGen.kr( Env.new([0,1,0], [atk, rel], [1, -1]), doneAction:2);
		sig = HPF.ar(sig, lcut);
		sig = LPF.ar(sig, hcut);
		sig = Pan2.ar(sig, pan, amp);
		Out.ar(out, sig * env);
	}).add;

	SynthDef(\playbackP, { // playback synth (with pitch management)
		arg rate = 1, atk = 0.001, rel = 1.4, lcut = 20, hcut = 20000,
			repitch = 1.0, pdisp = 0.0, tdisp = 0.0, pan = 0, buf, amp = 1.0, out;
		var sig = PlayBuf.ar(1, buf, BufRateScale.ir(buf) * rate, doneAction: 2),
		env = EnvGen.kr( Env.new([0,1,0], [atk, rel], [1, -1]), doneAction:2);
		sig = HPF.ar(sig, lcut);
		sig = LPF.ar(sig, hcut);
		sig = PitchShift.ar(sig, 0.2, repitch, pdisp, tdisp);
		sig = Pan2.ar(sig, pan, amp);
		Out.ar(out, sig * env);
	}).add;

	SynthDef(\hdVerb, { // nice sounding SC reverb
		arg in, out, predelay = 1.0, decay = 6.0, lpf1 = 14000, lpf2 = 15000;
		var sig = In.ar(in, 2);
		sig = Compander.ar(sig, sig, thresh: 0.5, slopeBelow: 1.0,
			slopeAbove: 0.25, clampTime: 0.01, relaxTime: 0.09);
		sig = HDVerb.ar(sig, predelay: predelay, decay: decay, lpf1: lpf1, lpf2: lpf2);
		Out.ar(out, sig);
	}).add;

	SynthDef(\mixIO, { // compressor and limiter on the mix bus
		arg out = 0, in = 0;
		var sig = In.ar(in, 2);
		sig = Compander.ar(sig,	sig, thresh: 0.5, slopeBelow: 1.0,
			slopeAbove: 0.25, clampTime: 0.01, relaxTime: 0.01);
		sig = Limiter.ar(sig, level: 0.8, dur: 0.1);
		Out.ar(out, sig);
	}).add;

	SynthDef(\patchCord, {
		arg in, out, amp = 1;
		var input = In.ar(in, 2);
		Out.ar(out, input * amp)
	}).add;

	s.sync;

	~dryBus = Bus.audio(s, 2);
	~fxSBus = Bus.audio(s, 2); ~fxMBus = Bus.audio(s, 2); ~fxLBus = Bus.audio(s, 2);
	~mixBus = Bus.audio(s, 2);
	~playbackGroup = Group.tail(s);
	~dryGroup = Group.tail(s); ~fxGroup = Group.tail(s); ~mixGroup = Group.tail(s);

	s.sync;

	~dryOut = Synth(\patchCord,
		[\in, ~dryBus, \out, ~mixBus], ~dryGroup);
	~revSOut = Synth(\hdVerb,
		[\in, ~fxSBus, \out, ~mixBus, \predelay, 0.01, \decay, 1.0], ~fxGroup);
	~revMOut = Synth(\hdVerb,
		[\in, ~fxMBus, \out, ~mixBus, \predelay, 0.05, \decay, 2.0], ~fxGroup);
	~revLOut = Synth(\hdVerb,
		[\in, ~fxLBus, \out, ~mixBus, \predelay, 0.05, \decay, 4.0], ~fxGroup);
	~mixOut = Synth(\mixIO,
		[\in, ~mixBus, \out, 0], ~mixGroup);

	s.sync;

	~reTime = Prout({
		arg ev;
		var now, nextTime = 0, thisShouldSwing, nextShouldSwing = false, adjust;
		while { ev.notNil } {
			now = nextTime;
			nextTime = now + ev.delta;
			thisShouldSwing = nextShouldSwing;
			nextShouldSwing = ((nextTime absdif: nextTime.round(ev[\swingBase])) <= (ev[\swingThreshold] ? 0))
				and: {
            	(nextTime / ev[\swingBase]).round.asInteger.odd
        		};
			adjust = ev[\swingBase] * ev[\swingAmount];
        	if( thisShouldSwing ) {
            	ev[\timingOffset] = (ev[\timingOffset] ? 0) + adjust;
            	if(nextShouldSwing.not) {
                	ev[\sustain] = ev.use { ~sustain.value } - adjust;
            	};
			}
			{
            if( nextShouldSwing ) {
                ev[\sustain] = ev.use { ~sustain.value } + adjust;
            	};
        	};
        	ev = ev.yield;
    	};
	});

	SystemClock.sched(0.0, {
		~t = Date.getDate;
		1;
		}
	);

	"LOADED".postln;

};
)