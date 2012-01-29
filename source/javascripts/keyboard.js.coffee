#= require "app"

DOMEvent.defineKeys
  '96':  'numpad_0'
  '97':  'numpad_1'
  '98':  'numpad_2'
  '99':  'numpad_3'
  '100':  'numpad_4'
  '101': 'numpad_5'
  '102': 'numpad_6'
  '103': 'numpad_7'
  '104': 'numpad_8'
  '105': 'numpad_9'
  '106': 'numpad_*'
  '107': 'numpad_p'
  '109': 'numpad_-'
  '110': 'numpad_.'
  '111': 'numpad_/'

keyboard = new Keyboard
  defaultEventType: 'keyup'
  active: true

input = null
add_to_input = (str) ->
  ->
    console.log str
    input.setProperty("value", input.getProperty("value") + str)

Key = new Class
  initialize: (node) ->
    text = node.get "text"
    shortcut = node.get("data-key") ? "numpad_#{text}"
    activation_fn = add_to_input(text)

    # Keyboard shortcut
    keyboard.addShortcut text,
      keys: shortcut
      description: "Add #{text} to the input."
      handler: activation_fn

    # Click function
    node.addEvent 'click', activation_fn

window.addEvent "load", ->
  input = $$("#vk_numbers_target")
  keys = $$(".key").map (key) -> new Key key

