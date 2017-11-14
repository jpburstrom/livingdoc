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
    } else if (req.query.action == "restart") {
        systemctl.restart(req.query.service);
        return res.redirect("/");
    } else if (req.query.actino == "stop") {
        systemctl.stop(req.query.service);
        return res.redirect("/");
    };
    systemctl.getServices().then((result) => {
      res.render('index', { 
          title: 'Living Documents' ,
          services: result
      });
    });
});


module.exports = router;
