ide = angular.module('wtfIde', [])
ide.directive "contenteditable", -> {
  restrict: "A",
  require: "ngModel",
  link: (scope, element, attrs, ngModel) ->
    ngModel.$render = ->
      element.html(ngModel.$viewValue || "")

    element.bind "blur keyup change paste", ->
      ngModel.$setViewValue(element.html())
}

ide.controller 'editorCtrl', ['$scope', '$element', ($scope, $element) ->
  syntaxHighlighter = require('../js/syntaxHighlight')
#  # called when editor text changed
#  observer = new MutationObserver((mutations) ->
#    mutations.forEach (mutation) ->
#      if mutation['type'] == 'attributes'
#        if mutation['attributeName'] == 'class'
#          console.log('class')
#        else
#          console.log(mutation['attributeName'])
#      else if mutation['type'] == 'characterData'
#        $scope.$parent.$emit('loadText', $($element[0]).text())
#        console.log('textChanged')
#      else
#        console.log(mutation['type'])
#  )
#
#  config = { attributes: true, childList: true, characterData: true, subtree: true, characterData: true }
#  observer.observe($element[0], config)
  loadText = (newRawText) ->
    $scope.rawText = newRawText
    syntaxHighlighter(newRawText, (text)->
      $scope.$apply ->
        $scope.text = text
    )

  $scope.$parent.$on('loadText', (event, rawText) ->
    loadText(rawText)
  )

  prevText = $("#wtfEditorText").html()
  $scope.textChanged = ->
    if prevText != $("#wtfEditorText").html()
      prevText = $("#wtfEditorText").html()
      console.log 'textChanged'
      loadText($("#wtfEditorText").text())
  $scope.$parent.$on('run', (event, args) ->
    run = require('../js/run')
    run($scope.rawText, (output) ->
      $scope.$parent.$emit('consoleOutput', output)
    )
  )
]

ide.controller 'toolbarCtrl', ['$scope', '$rootScope', ($scope) ->
  dialog = require('electron').remote['dialog']

  $scope.clickNew = ->
  $scope.clickLoad = ->
    dialog.showOpenDialog properties: ['openFile'], (pathList) ->
      filePath = pathList[0]
      fs = require('fs')
      str = fs.readFileSync(filePath, encoding: 'utf-8')
      $scope.$parent.$emit("loadText", str);
      $scope.$parent.$emit("consoleOutput", "file loaded: '#{filePath}'")

  $scope.clickSaveAs = ->
    dialog.showSaveDialog (path) ->
      console.log(path)
  $scope.clickSave = ->
    console.log('save')

  $scope.clickRun = ->
    $scope.$parent.$emit("run");
  $scope.clickDebug = ->
    console.log('debug')
]

ide.controller 'consoleCtrl', ($scope) ->
  $scope.$parent.$on('consoleOutput', (event, text) ->
    $scope.$apply ->
      $scope.text = text
      console.log(text)
  )

ide.controller 'statusBarCtrl', ($scope) ->
  $scope.leftText = 'Left text'
  $scope.rightText = 'Right text'

