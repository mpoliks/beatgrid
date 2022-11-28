

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

4. Now just run:*/

c = Conductor.new()

// and then:

c.conduct(~seed)

/* And it'll start playing! It's using your system clock to make decisions about intensity.
This is stereo only for now - passing outputs is EASY.
