traverseArray = (arrayNode) ->
  for childNode in arrayNode
    if childNode['type']
      traverseAst(childNode)
    else if Array.isArray(childNode)
      traverseArray(childNode)
    else
      console.log("#{child} => #{childNode}")

traverseAst = (node) ->
  if node['location']
    s = node['location'].split(",")
    line = parseInt(s[1])
    col = parseInt(s[2])
    console.log([line, col])

  for child of node
    if node.hasOwnProperty(child)
      childNode = node[child]
      if childNode['type']
        traverseAst(childNode)
      else if Array.isArray(childNode)
        traverseArray(childNode)
      else
        # normal ast node attributes
#        console.log("#{child} => #{childNode}")

module.exports = (text, callback) ->
  fs = require('fs')

  temp = require('temp').track()
  fs   = require('fs')
  util  = require('util')
  child_process = require('child_process')

  temp.open('wtf-code', (err, info) ->
    if (!err)
      fs.write(info.fd, text)
      fs.close(info.fd, (err) -> console.log("close failed") if err);
      ret = child_process.spawnSync("ruby",
        ["/home/alexwang/dev/proj/ruby/wtf-interp/wtf.rb", "--file", "#{info.path}", "--stage", "ast"],
        shell: true
      )
      astRoot = JSON.parse(ret.stdout.toString("utf8"))
      traverseAst(astRoot)
  )
