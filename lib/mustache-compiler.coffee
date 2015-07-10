Os = require 'os'
Path = require 'path'
fs = require 'fs-plus'
resultFilePath = Path.join Os.tmpDir(), "result.txt"

remote = require "remote"
dialog = remote.require "dialog"

Milk = require 'milk'

module.exports = MustacheCompiler =
  config:
    defaultRootPath:
      type: 'string'
      default: '/'
    encoding:
      type: 'string'
      default: 'utf-8'

  activate: (state) ->
    # Register command that toggles this view
    atom.commands.add 'atom-workspace', 'mustache-compiler:compile': => @compile()

  compile: ->
    text = @getText()
    try
      params = JSON.parse text
    catch error
      atom.notifications.addError "Please check formatting of your file. (Supported formats is JSON)"
      return

    filenames = @getTemplatePath()
    if filenames?
      filename = filenames[0]
    else
      atom.notifications.addError "Please select mustache template."
      return

    template = fs.readFileSync filename, atom.config.get('mustache-compiler.encoding')
    result = Milk.render(template, params)

    fs.writeFileSync resultFilePath, result, flag:'w+', encoding:atom.config.get('mustache-compiler.encoding')
    atom.workspace.open resultFilePath, {activatePane: true}

  getText: ->
    editor = atom.workspace.getActivePaneItem()
    text = editor.getSelectedText() or editor.getText()
    return text

  getTemplatePath: ->
    options = {
      defaultPath: atom.config.get('mustache-compiler.defaultRootPath'),
      #filters: [
      #  { name: 'mustache', extensions: ['mustache'] },
      #  { name: 'Handlebars', extensions: ['hba'] },
      #],
      properties: ['openFile']
    }
    return dialog.showOpenDialog options
