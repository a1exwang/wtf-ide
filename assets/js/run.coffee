module.exports = (code, interpArgs, args, callback) ->
  fs = require('fs')
  temp = require('temp').track()
  fs   = require('fs')
  util  = require('util')
  child_process = require('child_process')
  config = require('../../config')

  temp.open('wtf-code', (err, info) ->
    if (!err)
      fs.write(info.fd, code)
      fs.close(info.fd, (err) -> console.log("close failed") if err);
      cmdLine = [config("interpPath"), "--file", "#{info.path}"]
      cmdLine = cmdLine.concat(interpArgs)
      cmdLine.push("-a")
      cmdLine = cmdLine.concat(args)
      console.log(cmdLine)
      ret = child_process.spawnSync("ruby",
        cmdLine
        shell: true
      )
      callback(ret.stdout.toString("utf8"))
  )
