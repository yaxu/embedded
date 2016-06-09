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

