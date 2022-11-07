

/* Hi Micah!!!!

Here's your test zone to play around with.

1. First, make sure you've moved the /lib folder to your Extensions directory. You can find this by evaluating: */
Platform.userExtensionDir; // Select this text and hit CMD+Enter!
/* Once you've moved that folder to the right location, recompile Supercollider by going to Language->Recompile Class Library.
Great! Hopefully you see no errors in the Post Window!

You only need to do this once! :) You can skip to step 3 whenever you do this in the future.

2. OK, now to make sure your directories are set up correctly for Supercollider to scan.

Contain all your samples in a folder called Samples and put it in the same directory as Beatgrid.scd.

I have a slight tweak to the directory structure I sent you:
Samples---\
Instrument---\ (use lower case, e.g. bass kick snare clap loop hit hat)
/---for Hit and Loop: Key (use upper case, e.g. C# or F#) ---\ /---for other things: Intensity (0-4)---\
/---for Hit and Loop: Intensity (0-4) ---\

So 3 folder levels for unpitched instruments and 4 levels for pitched instruments.
Makes the program go a bit faster!

3. Now open up the file Beatgrid.scd. Select anywhere within the window and hit CMD+Enter.
You'll see a bunch of activity happen as the audio server boots.

If you see any errors, open up your Audio MIDI Setup and ensure your I/O is set accordingly.
This can be a little finicky!

4. OK, time to set levels. You can do this in the future whenever you like.
These settings work well for me, but tweak as needed. Just click anywhere within the parenthesis and hit CMD+Enter.*/
(
	~bassLevel = 0.2;
	~kickLevel = 0.2;
	~snareLevel = 0.08;
	~clapLevel = 0.06;
	~hatLevel = 0.1;
	~loopLevel = 0.2;
	~hitLevel = 0.08;
)
/* Also, please set the length of files set as Loops. We should standardize this.
They do not all need to be the same length, but this helps set the envelope timing.
If they're more than 20 seconds long, just evaluate the 20 second default by hitting CMD+Enter.*/
(
	~loopLen = 20;
)/*

5. Generate a seed - it can be any array of 0s and 1s.
Try this one, by using CMD+Enter within the parentheses:*/
(
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
)

//6. Set the tempo:
(
	~tempo = 60
)/*

7. OK time to make some sound - test a simple kick drum pattern.
First, create the pattern with:*/

(
	n = ~p.generate_pattern(
	~seed, // set the seed
	\kick, // set the instrument
	3 // set the intensity
	);
)

// Generate a pattern with:
(
	k = ~b.go(
		n, // set the pattern
		\kick, // set the instrument
		2, // set the intensity
		nil // set the key
	).play(
		quant:(60/(~tempo) * 4) // this will enqueue the pattern to start play within a four beat grid
	);
)

// Stop the pattern with:
(
	k.stop;
)

// And start it up again with:
(
	k.play;
)/*

8. Here's a full instrumental set!
Keep in mind that the pattern generation and playback mechanisms are separate -
if you want a new pattern for an instrument, generate it first before turning on playback!

We've added swing to this!

You can execute these line by line - simply put your cursor on a given line and hit SHIFT->ENTER*/

x = ~p.generate_pattern(~seed, \bass, 3); // Pattern Gen!
y = ~b.go(x, \bass, 3, "C#").play(quant:(60/(~tempo) * 4)); // Sequence Gen!
b = Pchain(~reTime, y, (swingBase: 0.25, swingAmount: 0.1, swingThreshold: 0.05)).play(quant:(60/(~tempo) * 4)); //Playback with swing!
b.stop

x = ~p.generate_pattern(~seed, \kick, 2);
y = ~b.go(x, \kick, 2, nil);
k = Pchain(~reTime, y, (swingBase: 0.25, swingAmount: 0.1, swingThreshold: 0.05)).play(quant:(60/(~tempo) * 4));
k.stop

x = ~p.generate_pattern(~seed, \snare, 2);
y = ~b.go(x, \snare, 2, nil);
s = Pchain(~reTime, y, (swingBase: 0.25, swingAmount: 0.1, swingThreshold: 0.05)).play(quant:(60/(~tempo) * 4));
s.stop

x = ~p.generate_pattern(~seed, \clap, 3);
y = ~b.go(x, \clap, 3, nil);
c = Pchain(~reTime, y, (swingBase: 0.25, swingAmount: 0.1, swingThreshold: 0.05)).play(quant:(60/(~tempo) * 4));
c.stop

x = ~p.generate_pattern(~seed, \hat, 3);
y = ~b.go(x, \hat, 3, nil);
h = Pchain(~reTime, y, (swingBase: 0.25, swingAmount: 0.1, swingThreshold: 0.05)).play(quant:(60/(~tempo) * 4));
h.stop

// Remember you need to pass a key for loops and hits!
x = ~p.generate_pattern(~seed, \loop, 2);
y = ~b.go(x, \loop, 2, "C#");
l = Pchain(~reTime, y, (swingBase: 0.25, swingAmount: 0.1, swingThreshold: 0.05)).play(quant:(60/(~tempo) * 4));
l.stop

x = ~p.generate_pattern(~seed, \hit, 4);
y = ~b.go(x, \hit, 4, "C#");
t = Pchain(~reTime, y, (swingBase: 0.25, swingAmount: 0.1, swingThreshold: 0.05)).play(quant:(60/(~tempo) * 4));
t.stop

/* This is stereo only for now - passing outputs is EASY.

There are some other tweak that need to happen:
	a. Dynamic Pattern Concatenation:
		Right now, these patterns are looping and not concatenating.
		Concatenation will be handled by the conductor, but you can see how easy it is to generate patterns.
		Bear in mind that the longer your seed is, the longer the patterns you'll be generating (for now).
	b. Dynamic FX:
		Right now, there's just a few hamfisted reverbs.
		These will be refined once I have a more powerful computer to spit out x# reverbs and delays on demand.
	c. The Conductor / Full System Integration
		Obviously this is just a POC and that work comes once we come to an agreement about what's happening here.

