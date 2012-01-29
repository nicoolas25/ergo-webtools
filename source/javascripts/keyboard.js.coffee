#= require "app"

DOMEvent.defineKeys
  '61':  '='
  '96':  '0'
  '97':  '1'
  '98':  '2'
  '99':  '3'
  '100': '4'
  '101': '5'
  '102': '6'
  '103': '7'
  '104': '8'
  '105': '9'
  '106': '*'
  '107': 'plus'
  '109': '-'
  '110': '.'
  '111': '/'

keyboard = new Keyboard
  defaultEventType: 'keyup'
  active: true

Key = new Class
  initialize: (node, fun) ->
    if node.get?
      shortcut = node.get("data-key") ? node.get("text")
      node.addEvent 'click', fun
    else
      shortcut = node
    
    keyboard.addShortcut shortcut, { keys: shortcut, handler: fun }
    return null

(exports ? this).Key = Key

window.removeEvents("load")
window.addEvent "load", ->
  keys = $$(".key").map (key) -> new Key(key, -> console.log key.get('text'))

