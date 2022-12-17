# beatgrid
Beatgrid is a generative queueing environment that utilizes Supercolliders pattern scheduler to daploy samples across a variety of rhythms and rhythmic substructures.

From the "ground up" there are a number of key classes and concepts that all enlist each other asynchronously.

## PatternGen
Takes a seed (the global var ~seed) and trains a pattern generation model. Uses this model to generate different pattern types per instrument type and intensity level. Hit, Snare, Clap all use the /hit instrument pattern type. Loop uses the /long pattern type (currently overridden to directly meet curatorial demand).

Intensity levels result in varyingly dense and active patterning. This can be refined further upon request. Currently there are five intensity levels (0 - mostly ambient, 4 - "dancey").

Patterns are interpolated into raw time values and presented to the PlaybackSchema.

## Playback Schema

Take an instrument, kit, intensity level, and pattern and generate a scheduled series of events to which various parameters are dynamically applied on a per-instrument basis (e.g. low pass filter, amplitude level, sample buffer ID). The core instruments are:

* Kick: heavily gridded, low frequency
* Bass: long envelopes, low frequency
* Snare: central rhythmic actor
* Clap: auxiliary rhythmic actor
* Misc: "hidden" density enrichment
* Hit: pitch-altered, dynamic material
* Hat: high frequency material with long amplitude / filter envelopes
* Loop: 32-channel playback, periodic (background layer)

## Event Manager

Generates PatternGen and Playback Schema upon request.

## Transition Manager

Interlace instrument-by-instrument transition from one State to another.

## Conductor

Should be quite clear to read - simply watches the clock and creates events when the next State is triggered. States are triggered every 1-4 minutes and have a 66% chance of invoking a Kit (soundworld) change.

Base intensity depends on the hour (0 for early morning, 1 for mid-activity periods, 2 for high activity periods).

Every 13 minutes an arc of +1 and +2 intensity from the base intensity is reached. High intensity States are varied more quickly.

Logging is produced every 10 seconds that indexes current State.

## ReTime and Quant
Intake scheduler events and interpolate them onto tempo and microtiming grid. ReTime takes swing values and swing base as inputs.

## BeatGrid

The main audio machine. Initializes the audio server, allocates (a ton!) of buffers into RAM (ideal for stable playback), creates a massive bus network (no effects to some effects routed to each channel), defines the playback system, initializes the GUI objects (for system test only!!!!) and queues the Conductor to begin.

## Synths
Various function definitions for effects.

## Installation instructions
Move /lib to User/AppData/Local/SuperCollider/Extension
Executable
Add Supercollider (Applications dir) to path.
Point bash or whatever shell to location of Beatgrid.scd and run with shell command `sclang`.
Terminate simply by pkilling (e.g. via cron).

## Notes
Code uses computer clock time to make decisions about intensity, so its accuracy is imperative.
Recommend 24 hour purge and restart of the program.
Please use QSYS to manage volume and avoid level changes earlier in the signal chain.
Sclang GUI currently built in for state change (“force state change”). Would recommend against interfacing with other GUI objects.
For incident reporting please provide a timestamp.

