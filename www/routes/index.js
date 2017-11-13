var express = require('express');
var fs = require('fs');
var router = express.Router();
var systemctl = require("../lib/systemctl");

/* GET home page. */
router.get('/', function(req, res, next) {
    if (req.query.action == "enable") {
        systemctl.setEnabled(req.query.service, true);
        return res.redirect("/");
    } else if (req.query.action == "disable") {
        systemctl.setEnabled(req.query.service, false);
        return res.redirect("/");
    };
    systemctl.getServices().then((result) => {
      res.render('index', { 
          title: 'Living Documents' ,
          services: result
      });
    });
});


router.get('/keyboard', function(req, res) {
    fs.readFile("/tmp/shell-output", "utf8", function(error, data) {

        res.send('<meta http-equiv="refresh" content="5"><pre>' + data);
    });
});

module.exports = router;
