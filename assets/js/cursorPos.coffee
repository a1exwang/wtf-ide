module.exports = (element) ->
  this.getPos = ->
    1
  this.setPos = (line, col) ->
    range = document.createRange()
    sel = window.getSelection()
    range.setStart(element.childNodes[2], 5)
    range.collapse true
    sel.removeAllRanges()
    sel.addRange range
