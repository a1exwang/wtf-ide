
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

run = require('../run')
module.exports = (code, callback) ->
  run(code, ['--stage', 'ast'], [], (result) ->
    try
      astRoot = JSON.parse(result)
    catch exception
      console.log(exception)
      console.log(result)
      return
    locations = traverseAst(astRoot)
    callback(locations)
  )

