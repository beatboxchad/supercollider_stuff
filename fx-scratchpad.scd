(
~out = {
	var input;
	input = \in.ar(0);
	Limiter.ar(input, 0.25);
}
)
(
~phasor = {arg freq=0.2;
	var input, effect;
	input=\in.ar(0);//get two channels of input starting (and ending) on bus 0
	effect= AllpassN.ar(input, 0.02, SinOsc.kr(freq,0,0.01,0.01)); //max delay of 20msec
	Mix.ar(input + effect);
}
)
Ndef(\phasor).set(\freq, 2)
(
~normaldelay = {
	arg speed, feedback;
	var input, fBLoopIn, fBLoopOut, processing;
	input = \in.ar(0);
	fBLoopIn = LocalIn.ar(1);
	processing = LeakDC.ar((DelayC.ar(fBLoopIn, 3.5, speed, feedback)));
	processing = RHPF.ar(processing,200,0.8);
	fBLoopOut = LocalOut.ar(input + processing);
	input + processing

}

)

 (
~gardendelay = {
	arg speed, feedback;
	var input, fBLoopIn, fBLoopOut, processing;
	input = \in.ar(0);
	fBLoopIn = LocalIn.ar(1);
	processing = LeakDC.ar((DelayC.ar(fBLoopIn, 3.5, Lag.kr(speed, 3), feedback)));
	processing = PitchShift.ar(processing, 0.2, 1 - (SinOsc.kr(speed*12, 0, 0.03)));
	processing = RHPF.ar(processing,200,0.8);
	fBLoopOut = LocalOut.ar(input + processing);
	input + processing

}

)

(
Ndef(\out, ~out);
Ndef(\sine,
	{arg mult;
		mult = Lag.kr(mult, 3);
		SinOsc.ar(440 * mult + 440).clip * 0.25});
Ndef(\guitaramplitude, {Lag.kr(Amplitude.kr(SoundIn.ar(0), mul:100), 20)});
Ndef(\sine).map(\mult, Ndef(\guitaramplitude));
Ndef(\ampshift).map(\interval, Ndef(\guitaramplitude));


Ndef(\mousex, {MouseX.kr(0.0001,2,0,0.2)};);
Ndef(\mousey, {MouseY.kr(0.001, 1.1)});


Ndef(\ampdelay, ~normaldelay);
Ndef(\ampdelay).map(\speed, Ndef(\guitaramplitude));

Ndef(\guitar, { SoundIn.ar(0)});
Ndef(\voice, {SoundIn.ar(1)});
Ndef(\guitar).fadeTime = 0.2;

Ndef(\out).play;


Ndef(\ampdelay).map(\feedback, Ndef(\mousey));


Ndef(\guitardelay, ~gardendelay);
Ndef(\guitardelay).map(\speed, Ndef(\mousex));

Ndef(\guitardelay).map(\feedback, Ndef(\mousey));
Ndef(\ampshift, ~ampshift);


)
Ndef(\phasor , ~phasor);
Ndef(\out).play
Ndef(\ampdelay) <<>.in Ndef(\sine);
Ndef(\sine).play(out: Ndef(\out).index);
Ndef(\out) <<>.in Ndef(\guitar);
Ndef(\sine).stop
Ndef(\out) <<>.in Ndef(\phasor) <<>.in Ndef(\guitar);
Ndef(\guitardelay) <<>.in Ndef(\ampdelay)
Ndef(\ampdelay) <<>.in Ndef(\guitar)
Ndef(\ampdelay) <<>.in  Ndef(\guitar)
Ndef(\guitardelay) <<>.in  Ndef(\guitar);



(

~ampshift = {
	arg interval;
	var input, processing;
	input = \in.ar(0);
    processing = PitchShift.ar(input, 0.5, interval) * 0.5;
	(input + processing.clip);}
)
