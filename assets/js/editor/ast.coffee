
traverseAst = (rootNode) ->
  locations = {}
  traverseArray = (arrayNode) ->
    for childNode in arrayNode
      if childNode['type']
        traverseObject(childNode)
      else if Array.isArray(childNode)
        traverseArray(childNode)
      else
        console.log(childNode)

  traverseObject = (node) ->
    if node['location']
      s = node['location'].split(",")
      line = parseInt(s[1])
      col = parseInt(s[2])
      locations[[line, col]] ||= []
      locations[[line, col]].push(node)
    #      console.log([line, col, node.type])

    for child of node
      if node.hasOwnProperty(child)
        childNode = node[child]
        if childNode['type']
          traverseObject(childNode)
        else if Array.isArray(childNode)
          traverseArray(childNode)
        else
# normal ast node attributes
#        console.log("#{child} => #{childNode}")
  traverseObject(rootNode)
  locations

module.exports = (code, callback) ->
  fs = require('fs')
  temp = require('temp').track()
  fs   = require('fs')
  util  = require('util')
  child_process = require('child_process')
  config = require('../../../config')

  temp.open('wtf-code', (err, info) ->
    if (!err)
      fs.write(info.fd, code)
      fs.close(info.fd, (err) -> console.log("close failed") if err);
      ret = child_process.spawnSync("ruby",
        [config("interpPath"), "--file", "#{info.path}", "--stage", "ast"],
        shell: true
      )
      try
        astRoot = JSON.parse(ret.stdout.toString("utf8"))
      catch exception
        console.log(exception)
        return
      locations = traverseAst(astRoot)
      callback(locations)
  )
