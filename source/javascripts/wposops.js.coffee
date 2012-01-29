#= require "app"
#= require "keyboard"

PosopCell = new Class
  initialize: (node, parent, x, y) ->
    @x = x
    @y = y
    @node = node
    @posop = parent
    @node.addEvent "click", -> parent.select_cell(this)
    return null

  select: -> @node.addClass "selected"

  unselect: -> @node.removeClass "selected"

  write: (str) -> @node.set("html", str)

Posop = new Class
  initialize: (node) ->
    @target = node
    @cells = [[]]
   
    bind = this
    trs = @target.getElements("tr")
    trs.each (tr, x) ->
      bind.cells[x] ?= []
      tds = tr.getElements("td")
      tds.each (td, y) ->
        bind.cells[x][y] = new PosopCell td, bind, x, y
    
    @max_x = @cells.length - 1
    @max_y = @cells[0].length - 1
    
    @select_cell(@cells[0][0], false) if @cells[0][0]?
      
    return null

  current_cell: -> @cells[@x_sel][@y_sel]

  select_cell: (cell, unselect = true) ->
    @current_cell().unselect() if unselect
    @x_sel = cell.x
    @y_sel = cell.y
    @current_cell().select()
  
  move_to: (key) ->
    y_sel = @y_sel
    x_sel = @x_sel
    switch key
      when "left" then y_sel = Math.max(0, @y_sel - 1)
      when "right" then y_sel = Math.min(@max_y, @y_sel + 1)
      when "up" then x_sel = Math.max(0, @x_sel - 1)
      when "down" then x_sel = Math.min(@max_x, @x_sel + 1)
    @select_cell @cells[x_sel][y_sel]
    return null

window.removeEvents("load")
window.addEvent "load", ->
  po = new Posop $$("div#posop table")[0]
  
  Array.each ["left", "up", "right", "down"], (key) -> new Key(key, -> po.move_to(key))
  
  keys = $$(".key").map (key) ->
    new Key key, ->
      po.current_cell().write key.get('text')



