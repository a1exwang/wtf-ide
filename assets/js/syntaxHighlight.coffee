
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

idRange = (char, direction) ->
  if char.match(/[^_a-z0-9]/i)
    if direction == "left"
      return "right"
    else
      return "this"
  else
    return null
strRange = (char, direction) ->
  if "\"" == char
    if direction == "left"
      return "this"
    else
      return "right"
  else
    return null

getWordRange = (str, line, col, sep) ->
  lines = str.split("\n")
  lines[line]
  i = col
  left = 0
  right = lines[line].length
  total = 0
  for l in lines[0...line]
    total += l.length + 1 # new line character
  while i >= 0
    status = sep(lines[line][i], "left")
    if status == "left"
      left = i-1
      break
    else if status == "right"
      left = i+1
      break
    else if status == "this"
      left = i
      break
    i--

  i = col + 1
  while i < lines[line].length
    status = sep(lines[line][i], "right")
    if status == "left"
      right = i-1
      break
    else if status == "right"
      right = i+1
      break
    else if status == "this"
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
      try
        astRoot = JSON.parse(ret.stdout.toString("utf8"))
      catch exception
        console.log(exception)
        return
      locations = traverseAst(astRoot)
      ranges = []
      for location, nodes of locations
        for node in nodes
          locationStr = location.split(',')
          line = parseInt(locationStr[0]) - 1
          col = parseInt(locationStr[1]) - 1
          switch node.type
            when "id"
              r = getWordRange(code, line, col, idRange)
              ranges.push(start: r[2], end: r[3], type: "id")
            when "str"
              r = getWordRange(code, line, col, strRange)
              ranges.push(start: r[2], end: r[3], type: "str")
      colors = {
        id: "yellow",
        str: "green"
      }
      # copy code
      codeTemp = new String(code)
      stringParts = []
      for range in ranges.reverse()
        left = range.start
        right = range.end
        color = colors[range.type]
        stringParts.push(codeTemp.substr(right, codeTemp.length - right))
        codeSnippet = codeTemp.substr(left, right - left)
        codeSnippet = "<span style=\"color: #{color};\">#{codeSnippet}</span>"
        stringParts.push(codeSnippet)
        codeTemp = codeTemp.substr(0, left)
      callback(stringParts.reverse().join(""))
  )
