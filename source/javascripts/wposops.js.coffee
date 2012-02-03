#= require "app"
#= require "keyboard"

PosopCell = new Class
  initialize: (node, parent, x, y) ->
    @x = x
    @y = y
    @node = node
    @node.addEvent "click", => parent.select_cell(this)
    return null

  text: -> @node.get "text"
  
  select: -> @node.addClass "selected"

  unselect: -> @node.removeClass "selected"

  write: (str) -> @node.set("html", str)

  toggle_bottom_line: -> @node.toggleClass "bottom-line"
  
  toggle_left_line: -> @node.toggleClass "left-line"

  clear: ->
    @node.removeClass "bottom-line"
    @node.removeClass "left-line"
    @write("")

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

  clear: ->
    @cells.each (row) ->
      row.each (cell) ->
        cell.clear()
  
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
    
  draw_to_canvas: (canvas, img) ->
    begin = @first_filled_cell()
    end = @last_filled_cell()
    console.log(canvas.width = (end.y - begin.y) * 30 + 60)
    console.log(canvas.height = (end.x - begin.x) * 30 + 60)
    ctx = canvas.getContext("2d")
    ctx.clearRect(0,0,canvas.width,canvas.height)
    ctx.fillStyle = "rgb(255,255,255)"
    ctx.fillRect(0, 0, canvas.width, canvas.height)
    ctx.font = "12pt sans-serif"
    ctx.fillStyle = "rgb(0,0,0)"

    for x in [begin.x .. end.x]
      for y in [begin.y .. end.y]
        cell = @cells[x][y]
        text = cell.text()
        real_x = x - begin.x
        real_y = y - begin.y
        if text isnt ""
          ctx.fillText(text, real_y * 30 + 24, real_x * 30 + 30)
        if cell.node.hasClass("bottom-line")
          ctx.beginPath()
          ctx.moveTo(real_y * 30 + 15, real_x * 30 + 40)
          ctx.lineTo(real_y * 30 + 45, real_x * 30 + 40)
          ctx.stroke()
          ctx.fill()
        if cell.node.hasClass("left-line")
          ctx.beginPath()
          ctx.moveTo(real_y * 30 + 15, real_x * 30 + 10)
          ctx.lineTo(real_y * 30 + 15, real_x * 30 + 40)
          ctx.stroke()
          ctx.fill()

    img.setProperty("src", canvas.toDataURL())

  first_filled_cell: ->
    min_x = @max_x
    min_y = @max_y
    for x in [0..@max_x]
      for y in [0..@max_y]
        if @cells[x][y].text() isnt ""
          min_x = Math.min(min_x, x)
          min_y = Math.min(min_y, y)
    return @cells[min_x][min_y]

  last_filled_cell: ->
    max_x = max_y = 0
    for x in [@max_x..0]
      for y in [@max_y..0]
        if @cells[x][y].text() isnt ""
          max_x = Math.max(max_x, x)
          max_y = Math.max(max_y, y)
    return @cells[max_x][max_y]
 
window.removeEvents("load")
window.addEvent "load", ->
  canvas = document.getElementById('posop_canvas')
  po = new Posop $$("div#posop table")[0]
  
  $$("#vk_arrows .key").map (key) ->
    new Key key, ->
      po.move_to key.getProperty("data-key")

  $$("#vk_numbers .key").map (key) ->
    new Key key, ->
      text = key.get('text')
      po.current_cell().write text
      po.move_to "right"

  $$("#left-line").addEvent "click", ->
    po.current_cell().toggle_left_line()
    po.move_to "down"

  $$("#bottom-line").addEvent "click", ->
    po.current_cell().toggle_bottom_line()
    po.move_to "right"

  $$("#equal").addEvent "click", ->
    po.current_cell().write "="
    po.move_to "right"

  $$("#posop_clear").addEvent "click", -> po.clear()
  
  $$("#posop_convert").addEvent "click", -> po.draw_to_canvas(canvas, $$("#posop_export img"))



