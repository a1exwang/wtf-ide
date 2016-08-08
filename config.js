var fs = require("fs");
var config = JSON.parse(fs.readFileSync(__dirname + "/config.json", { encoding: "utf-8" }));

module.exports = function (key) {
    if (config[key]) {
       if (typeof config[key] == 'string') {
           var matchData;
           if (matchData = config[key].match(/^\$(.*)$/)) {
               var envVar = matchData[1];
               return process.env[envVar];
           }
           else {
               return config[key].replace("\\$", "$")
           }
       }
       return config[key];
    }
    else
        throw "key not found";
};