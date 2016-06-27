Server.default = s = Server.internal.boot;

play({SinOsc.ar(LFNoise0.kr(3, mul:600, add:1000), 0.3)})

{
play({RLPF.ar(Dust.ar([12,15]), 	  LFNoise1.ar(1/[2,4],1200,1600), 0.02)     });
}



SynthDef(\fm, {|out = 0, gate = 1, amp = 1, carFreq = 1000, modFreq = 100, modAmount = 2000, clipAmount = 0.1|
	var modEnv = EnvGen.ar(Env.adsr(0.5, 0.5, 0.7, 0.1, peakLevel: modAmount), gate);
	var mod = SinOsc.ar(modFreq) * modEnv;
	var car = SinOsc.ar(carFreq + mod);
	var ampEnv = EnvGen.ar(Env.adsr(0.1, 0.3, 0.7, 0.2, peakLevel: amp), gate, doneAction: 2);
	var clip = clipAmount * 500;
	Out.ar(out, (car * ampEnv * clip).clip(-0.7, 0.7) * 0.1);
}).add;
