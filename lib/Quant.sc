Q {
	*uant {arg quant,input;
	^Pbind(\amp, Pseq([0],1),\foo,Pfunc{input.value()}).play(quant:quant)
}
}