parseLocations = require('./ast')

module.exports = (element) ->
  rawText = ''
  htmlParts = []
  @element = element
  @getRawText = ->
    rawText

  @loadText = (code, cb) ->
    rawText = code
    parseLocations(code, (locations) ->
      html = processLocations(locations)
      cb(html)
    )
  cursorOffset = 0
  @setCursor = (line, col) ->
    offset = getOffset(rawText, line, col)
    setCursor(offset)
  @setCursorOffset = (offset) ->
    cursorOffset = offset
    data = getIndexOfHtmlParts(offset)
    index = data[0]
    offsetInNode = data[1]
    targetNode = element.get(0).childNodes[index]

    range = document.createRange()
    sel = window.getSelection()
    range.setStart targetNode, offsetInNode
    range.collapse true
    sel.removeAllRanges()
    sel.addRange range
  @getCursor = ->
    cursorOffset

  getOffset = (text, line, col) ->
    lines = text.split("\n")
    offset = 0
    for lineStr in lines[0...line]
      offset += lineStr.length
    offset + col

  getIndexOfHtmlParts = (offset) ->
    index = 0
    for part in htmlParts
      if part.start <= offset and offset < part.end
        return [index, offset - part.start]
      index++
    return null

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
  processLocations = (locations) ->
    ranges = []
    for location, nodes of locations
      for node in nodes
        locationStr = location.split(',')
        line = parseInt(locationStr[0]) - 1
        col = parseInt(locationStr[1]) - 1
        switch node.type
          when "id"
            r = getWordRange(rawText, line, col, idRange)
            ranges.push(start: r[2], end: r[3], type: "id")
          when "str"
            r = getWordRange(rawText, line, col, strRange)
            ranges.push(start: r[2], end: r[3], type: "str")
    colors = {
      id: "yellow",
      str: "green"
    }
    # copy code
    codeTemp = new String(rawText)
    htmlParts = []
    for range in ranges.reverse()
      left = range.start
      right = range.end
      color = colors[range.type]

      plainPart = codeTemp.substr(right, codeTemp.length - right)
      plainPart = "<span>#{plainPart}</span>"
      obj = {
        html: plainPart,
        start: right,
        end: codeTemp.length
      }
      htmlParts.push(obj)

      codeSnippet = codeTemp.substr(left, right - left)
      codeSnippet = "<span style=\"color: #{color};\">#{codeSnippet}</span>"
      obj = {
        html: codeSnippet,
        start: left,
        end: right
      }
      htmlParts.push(obj)

      codeTemp = codeTemp.substr(0, left)
    $.map(htmlParts.reverse(), (x) -> x.html).join("")

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

  return this


