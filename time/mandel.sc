NetAddr.broadcastFlag_(true);
// MandelClock Tests
MandelHub.debug = true

// #1: Tempo Tests
a = MandelHub("Leader", 0, 2, "test", leading:true, timeClass: MandelTimeDriver);

a.gui;
a.metro(-1); // left

m = MandelHub.join("Follower", action: {m = MandelHub.instance;});

m.gui;
m.metro(1); // right

( // This simulates out-of-sync clocks, this should never happen to this extent!
{
	a.changeTempo(2);
	0.5.wait;
	m.time.listenToTicks = false;
	a.changeTempo(4);
	0.2.wait;
	a.changeTempo(2);
	m.time.listenToTicks = true; // now m should resync

}.fork;
)

a

// accelerando
a.changeTempo(2);

Platform.userExtensionDir

NetAddr.langPort

a = NetAddr("255.255.255.255", 57120);
a.sendMsg("/hello", "bingo", -1, NetAddr.langPort)

t = TempoClock();
t.tempo = 1
t.schedAbs(1, { t.beats.postln; t.tempo.postln; 1})

t.clear
t.beats2secs(t.nextTimeOnGrid)
thisThread.seconds
c = thisThread.clock

t.nextTimeOnGrid

b = NetAddr.new("127.0.0.1", 7771)
b.sendMsg("/hello", "there");

n = NetAddr("127.0.0.1", 6060);
t = TempoClock();
t.schedAbs(1, {n.sendBundle(1, ["/sync", t.nextTimeOnGrid, t.tempo]);	1 })
t.clear

(
a.tempo = 1.1;
n.sendBundle(1, ["/sync", a.nextTimeOnGrid, a.tempo])
)

t.tempo = 0.8


(
a= SynthDef(\help_beattrack2_1,{arg vol=1.0, beepvol=1.0, lock=0;
var in, kbus;
var trackb,trackh,trackq,tempo, phase, period, groove;
var bsound,hsound,qsound, beep;
var fft;
var feature1, feature2, feature3;

in= PlayBuf.ar(1,d.bufnum,BufRateScale.kr(d.bufnum),1,0,1);
//in = SoundIn.ar(0);

//Create some features
fft = FFT(b.bufnum, in);

feature1= RunningSum.rms(in,64);
feature2= MFCC.kr(fft,2); //two coefficients
feature3= A2K.kr(LPF.ar(in,1000));

kbus= Out.kr(0, [feature1, feature3]++feature2);

//Look at four features
#trackb,trackh,trackq,tempo, phase, period, groove=BeatTrack2.kr(0,4,2.0, 0.02, lock, -2.5);

beep= SinOsc.ar(1000,0.0,Decay.kr(trackb,0.1));

Out.ar(0,Pan2.ar((vol*in)+(beepvol*beep),0.0));
}).play
)


(
    // variable for array
    var timepoints;
    // create array
    timepoints = Array.new( );

    s.waitForBoot( {

        (    // synthdef from beattrack help file - edited
            a = SynthDef( \help_beattrack, {
                var in, trackb;
                // internal mic
                in = SoundIn.ar( 0 );
                // detect input
			FFT(LocalBuf(512)
                trackb = Coyote.kr( in, fastMul: 0.6, thresh: 0.5 );
                // send to OSCresponder
                SendTrig.kr( trackb, 0, 0.9 );

            } ).play
        );

        // receive trigger
        OSCresponder( s.addr, '/tr', { arg time, responder, msg;

            // post current time
            [ time ].postln;
            // place/add the ‘time’ -> my_clock_time, into an array
            timepoints = timepoints.add( time );
            // print the array
            timepoints.postln;

        } ).add;

    } );

)

(
s.boot;
s.doWhenBooted{
	~m = MykBeatTrack.new;
	~m.run.defer(0.5);
//~m.callback = {arg f; f.postln;}
}
)
a = Date.getDate
a.dayOfWeek