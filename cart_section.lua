local self = {}
local utils = require("utils")
local groceries = require("groceries")

self.size = {w = 0, h = 0}
self.pos = {x = 0, y = 0}

self.updateSizing = function(self, screen)
  self.size.w = self.cart.img:getWidth() * self.cart.size.x
  self.size.h = screen.h
  self.pos.x = screen.w - self.size.w
  self.pos.y = 0

  self.cart.pos.y = screen.h - self.cart.img:getHeight() * self.cart.size.y
  self.drop.max.x = self.size.w
end

self.cart = (function()
  local temp = {}
  temp.img = love.graphics.newImage("gfx/shopping_cart.png")
  temp.pos = {x = 0, y = 0}
  temp.size = {x = 0.5, y = 0.5}
  temp.parent = self
  return temp
end)()

self.drop = (function()
  local temp = {
    pos = {x = 0, y = 0},
    vel = {x = 5, y = 0},
    max = {x = 0, y = 0},
    img = nil,
    center = {x = true, y = false}
  }
  temp.img = love.graphics.newImage("gfx/arrow.png")
  temp.parent = self
  return temp
end)()


-- Setup cart physics
self.physics = {}
self.physics.world = love.physics.newWorld(0, 9.81 * 64, true)

self.physics.sides = {}

self.setupPhysics = function()
  -- Left side
  self.physics.sides.left = (function()
    local temp = {}
    temp.body = love.physics.newBody(self.physics.world, 70, self.size.h / 4 * 3)
    temp.body:setAngle(math.rad(-15))
    temp.shape = love.physics.newRectangleShape(10, self.size.h * 0.4)
    temp.fixture = love.physics.newFixture(temp.body, temp.shape)
    return temp
  end)()

  -- Right side
  self.physics.sides.right = (function()
    local temp = {}
    temp.body = love.physics.newBody(self.physics.world, self.size.w - 14, self.size.h / 4 * 3)
    temp.shape = love.physics.newRectangleShape(10, self.size.h * 0.25)
    temp.fixture = love.physics.newFixture(temp.body, temp.shape)
    return temp
  end)()

  -- Bottom side
  self.physics.sides.bottom = (function()
    local temp = {}
    temp.body = love.physics.newBody(self.physics.world, self.size.w / 2 + 35, self.size.h - 85)
    temp.body:setAngle(math.rad(-2))
    temp.shape = love.physics.newRectangleShape(self.size.w * 0.75, 20)
    temp.fixture = love.physics.newFixture(temp.body, temp.shape)
    return temp
  end)()

  -- Handle 
  self.physics.sides.handle = (function()
    local temp = {}
    temp.body = love.physics.newBody(self.physics.world, 30, self.size.h / 2 + 20)
    temp.body:setAngle(math.rad(30))
    temp.shape = love.physics.newRectangleShape(45, 10)
    temp.fixture = love.physics.newFixture(temp.body, temp.shape)
    return temp
  end)()
end

self.groceries = {}

self.addGrocery = function(self)
  table.insert(self.groceries, (function()

    --[[
    local temp = {}
    temp.body = love.physics.newBody(self.physics.world, self.drop.pos.x, self.drop.pos.y + self.drop.img:getHeight(), "dynamic")
    if utils.rand(2) == 1 then
      temp.type = 'circle'
      temp.shape = love.physics.newCircleShape(utils.rand(20) + 10)
    else
      temp.type = 'rect'
      temp.shape = love.physics.newRectangleShape(utils.rand(20) + 10, utils.rand(20) + 10)
    end
    temp.fixture = love.physics.newFixture(temp.body, temp.shape, 1)
    temp.fixture:setRestitution(0.3)
    return temp
    --]]
    
    return groceries:generateGrocery(
      groceries:randomGrocery(),
      self.physics.world, self.drop.pos.x, self.drop.pos.y + self.drop.img:getHeight()
    )

  end)())
end

self.draw = function(self) 
  love.graphics.setColor(255, 255, 255)
  for i, grocery in ipairs(self.groceries) do
    if grocery.active then
      local angle = grocery.body:getAngle()
      local cos = math.cos(angle)
      local sin = math.sin(angle)
      local drawX = grocery.body:getX() + self.pos.x
      local drawY = grocery.body:getY() + self.pos.y
      local offsetX = -grocery.img:getWidth() / 2
      local offsetY = -grocery.img:getHeight() / 2

      drawX = drawX + (offsetX * cos - offsetY * sin)
      drawY = drawY + (offsetX * sin + offsetY * cos)

      love.graphics.draw(grocery.img, drawX, drawY, angle)

      --[[
      love.graphics.setColor(100, 100, 100)
      if grocery.type == 'circle' then
        love.graphics.circle("line", grocery.body:getX() + self.pos.x, grocery.body:getY(), grocery.shape:getRadius())
      else
        love.graphics.polygon("line", utils.shiftPoints(self.pos, grocery.body:getWorldPoints(grocery.shape:getPoints())))
      end
      --]]
    end
  end
end

self.inCart = function(self, grocery)
  local groceryX = grocery.body:getX()
  local groceryY = grocery.body:getY()

  return groceryX < self.size.w and
     groceryX > 0 and
     groceryY < self.size.h
end

self.update = function(self, dt)
  self.physics.world:update(dt)

  self.drop.pos.x = self.drop.pos.x + self.drop.vel.x
  if self.drop.vel.x > 0 then
    if self.drop.pos.x > self.drop.max.x then
      self.drop.vel.x = self.drop.vel.x * -1
      self.drop.pos.x = self.drop.max.x
    end
  else
    if self.drop.pos.x < 0 then
      self.drop.vel.x = self.drop.vel.x * -1
      self.drop.pos.x = 0
    end
  end
end

return self
