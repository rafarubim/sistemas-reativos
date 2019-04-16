function love.load()
  ret = retangulo(50, 50, 200, 300)
  ret2 = retangulo(200, 200, 200, 300)
  rets = { ret, ret2 }
end

function love.keypressed(key)
  for _, ret in ipairs(rets) do
    ret:keypressed(key)
  end
end

function love.update (dt)
end

function retangulo (x, y, w, h)
  local xinit = x
  local yinit = y
  return {
    keypressed = function (self, key)
      local mx, my = love.mouse.getPosition() 
      if key == 'b' and self.naimagem (mx, my) then
        x = xinit
        y = yinit
      elseif key == 'down' and self.naimagem(mx, my) then
        y = y + 10
      elseif key == 'right' and self.naimagem(mx, my) then
        x = x + 10
      end
    end,
    draw = function (self)
      love.graphics.rectangle("line", x, y, w, h)
    end,
    naimagem = function (mx, my)
      return (mx > x) and (mx < x+w) and (my>y) and (my<y+h)
    end
  }
end

function love.draw ()
  for _, ret in ipairs(rets) do
    ret.draw()
  end
end