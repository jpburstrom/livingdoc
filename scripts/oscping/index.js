var osc = require('osc');
const interval = 1000;
const ip = "255.255.255.255";

var port = process.env.PORT || 57120;

var udpPort = new osc.UDPPort({
    localAddress: "0.0.0.0",
    remoteAddress: ip,
    //Send to default port
    remotePort: port,
    broadcast: true
});
udpPort.open();

//Send a ping every `interval` ms
udpPort.on("ready", function() {
    setInterval(function() {
        udpPort.send({ address: "/ping" });
    }, interval);
});

