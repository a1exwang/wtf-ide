$(document).ready ->
  $("#wtfEditorText").keydown (e) ->
    if e.keyCode == 13
      document.execCommand("insertHTML", false, "\n")
      e.preventDefault()
      return false