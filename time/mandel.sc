NetAddr.broadcastFlag_(true);
MandelHub.debug = true

// #1: Tempo Tests
a = MandelHub("Leader", 0, 2, "test", leading:true, timeClass: MandelTimeDriver);
a.gui;


t.schedAbs(1, {n.sendBundle(1, ["/sync", t.nextTimeOnGrid, t.tempo]);	4})
t.clear

// accelerando
a.changeTempo(2);
