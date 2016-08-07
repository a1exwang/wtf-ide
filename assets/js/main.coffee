#$(document).ready ->
#  $('[contenteditable]').on('focus',  ->
#    $this = $(this)
#    $this.data('before', $this.html())
#    $this
#  ).on('blur keyup paste', ->
#    $this = $(this)
#    if ($this.data('before') != $this.html())
#      $this.data('before', $this.html());
#      $this.trigger('change');
#    $this
#  ).keydown((e)->
#    TABKEY = 9
#    if(e.keyCode == TABKEY)
#      this.value += "  "
#      if(e.preventDefault)
#        e.preventDefault()
#      false
#  )
#  $('#wtfEditorText').change ->
#    # here, we can change the html style
#    $(this).children()
#    newHtml = $(this).html().replace(/new/, "<span style=\"color: yellow;\">new</span>")
#    console.log(newHtml)
#    $(this).html(newHtml)


