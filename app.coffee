{app, BrowserWindow} = require('electron')

createWindow = ->
  win = new BrowserWindow(width: 1440, height: 900)

  win.loadURL("file://#{__dirname}/assets/html/index.html")

  win.webContents.openDevTools()

  win.on 'closed', ->
    win = null

app.on 'ready', createWindow

app.on 'window-all-closed', ->
  if (process.platform != 'darwin')
    app.quit()

app.on 'activate', ->
  if (win == null)
    createWindow()

