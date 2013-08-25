local self = {}

local utils = require("utils")

self.grocerySections = {}
self.addGrocerySection = function(x, y, w, h, groceryType)
end

self.groceryTypes = {
  "apple", "can", "cereal", "chicken", "chips", "donut", "fish", "milk", "yogurt"
}

self.images = {}
self.data = {}

for _, groceryType in ipairs(self.groceryTypes) do
  local image = love.graphics.newImage("gfx/groceries/" .. groceryType .. ".png")
  local data = dofile("data/" .. groceryType .. ".lua")

  if data.physics.type == 'circle' then
    data.physics.size.r = math.max(image:getWidth(), image:getHeight()) * data.physics.size.r
  elseif data.physics.type == 'rect' then
    data.physics.size.w = image:getWidth() * data.physics.size.w
    data.physics.size.h = image:getHeight() * data.physics.size.h
  end

  self.data[groceryType] = data
  self.images[groceryType] = image
end

self.randomGrocery = function(self)
  return self.groceryTypes[utils.rand(#self.groceryTypes) + 1]
end

self.generateGrocery = function(self, groceryType, world, x, y)
  local data = self.data[groceryType]
  local temp = {
    active = true
  }

  print(groceryType)
  print(data.physics.size.w, data.physics.size.h, data.physics.size.r)

  temp.body = love.physics.newBody(world, x, y, "dynamic")
  temp.type = data.physics.type
  if data.physics.type == 'circle' then
    temp.shape = love.physics.newCircleShape(data.physics.size.r)
  elseif data.physics.type == 'rect' then
    temp.shape = love.physics.newRectangleShape(data.physics.size.w, data.physics.size.h)
  end
  temp.fixture = love.physics.newFixture(temp.body, temp.shape, 1)
  temp.fixture:setRestitution(data.physics.restitution)
  temp.groceryType = groceryType
  temp.img = self.images[groceryType]

  return temp
end

self.drawAll = function(self, screen)
  local x = 0
  local y = 0
  local yStep = 0
  for groceryType, grocery in pairs(self.images) do
    local size = self.data[groceryType].size.x
    love.graphics.draw(grocery, x, y, 0, size, size)
    x = x + grocery:getWidth() * size
    yStep = math.max(yStep, grocery:getHeight() * size)
    if x > screen.w then
      y = y + yStep
      x = 0
      yStep = 0
    end
  end
end

return self
