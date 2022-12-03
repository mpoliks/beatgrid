ReTime {

	*new { ^super.new.init(ev) }

	init {

	arg ev;

	^Prout({
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

	}

}