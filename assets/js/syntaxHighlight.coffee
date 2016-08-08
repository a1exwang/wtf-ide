
traverseAst = (rootNode) ->
  locations = {}
  traverseArray = (arrayNode) ->
    for childNode in arrayNode
      if childNode['type']
        traverseObject(childNode)
      else if Array.isArray(childNode)
        traverseArray(childNode)
      else
        console.log("#{child} => #{childNode}")

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

getWordRange = (str, line, col) ->
  lines = str.split("\n")
  lines[line]
  i = col
  left = 0
  right = lines[line].length
  total = 0
  for l in lines[0...line]
    total += l.length
  while i >= 0
    if lines[line][i].match(/[^_a-z0-9]/i)
      left = i+1
      break
    i--

  i = col
  while i < lines[line].length
    if (lines[line][i].match(/[^_a-z0-9]/i))
      right = i
      break
    i++
  [left, right, total + left, total + right]

module.exports = (code, callback) ->
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
      ret = child_process.spawnSync("ruby",
        [config("interpPath"), "--file", "#{info.path}", "--stage", "ast"],
        shell: true
      )
      astRoot = JSON.parse(ret.stdout.toString("utf8"))
      locations = traverseAst(astRoot)
      for location, val of locations
        console.log(location[2])
        r = getWordRange(code, location[0], location[1])
        console.log [code.substr(r[2], r[3] - r[2]), val]
  )
