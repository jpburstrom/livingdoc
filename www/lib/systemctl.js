const fs = require('fs');
const ini = require('ini');
const path = require('path');
const { spawnSync } = require('child_process');

var basepath = path.join(__dirname, "/../../system");

exports.getServices = function() {
    return new Promise((res, rej) => {
        fs.readdir(basepath, function(err, items) {
            var services = [];
            if (!err) {
                for (var i=0; i<items.length; i++) {
                    var config = ini.parse(fs.readFileSync(path.join(basepath, items[i]), 'utf8'));
                    var stat = spawnSync("/bin/systemctl", ["is-enabled", items[i]]);

                    if (typeof(config["Unit"]) !== "undefined") {
                        services.push({
                            status: stat.stdout.toString().trim(),
                            name: items[i],
                            description: config["Unit"]["Description"]
                        })
                    }
                }
            } else {
                console.error(err);
            }
            res(services);
        })
    })
};

exports.restart = function(service) {
    spawnSync("/bin/systemctl", ["restart", service]);
}

exports.stop = function(service) {
    spawnSync("/bin/systemctl", ["stop", service]);
}


exports.setEnabled = function (service, enabled) {
    let verb = "enable";
    if (!enabled)  {
        verb = "disable"
    }
    spawnSync("/bin/systemctl", [verb, service]);
};

