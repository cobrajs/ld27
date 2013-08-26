local self = {}
local utils = require("utils")

local groceries = nil

self.addGroceriesVar = function(_groceries)
  groceries = _groceries
end

local key_handled = {
  x = true,
  c = true
}

self.size = {w = 0, h = 0}
self.pos = {x = 0, y = 0}

self.updateSizing = function(self, screen)
  self.size.h = screen.h

  self.market.loadCanvas()
end

self.cart_guy = (function()
  local temp = {
    pos = {x = 100, y = 100},
    vel = {x = 0, y = 0},
    size = {x = 0.25, y = 0.25},
    offset = {x = 0, y = 0},
    rot = 0,
    rotSpeed = 4,
    speed = 0
  }

  local styles = {'normal', 'left', 'right'}
  temp.img = {}
  for i, style in ipairs(styles) do
    temp.img[style] = love.graphics.newImage("gfx/cart_guy_" .. style .. ".png")
  end

  temp.img.width = temp.img.normal:getWidth()
  temp.img.height = temp.img.normal:getHeight()

  temp.current = 'normal'
  temp.offset.x = -temp.img.width * temp.size.x * 0.2
  temp.offset.y = -temp.img.height * temp.size.y / 2
  temp.parent = self

  return temp
end)()

self.setupGrocerySections = function(self, groceries)
  -- Side shelves
  groceries:addGrocerySection(0, 0, 164, 50, "milk", "wall")
  groceries:addGrocerySection(0, 0, 54, 200, "milk", "wall")

  groceries:addGrocerySection(0, 200, 54, 300, "donut", "wall")

  groceries:addGrocerySection(165, 0, 199, 50, "fish", "wall")

  groceries:addGrocerySection(365, 0, 195, 50, "chicken", "wall")
  groceries:addGrocerySection(493, 0, 60, 159, "chicken", "wall")

  groceries:addGrocerySection(493, 160, 60, 340, "apple", "wall")

  -- Middle shelves
  groceries:addGrocerySection(160, 160, 33, 230, "chips", "center")
  groceries:addGrocerySection(193, 160, 33, 230, "can", "center")

  groceries:addGrocerySection(326, 160, 33, 230, "cereal", "center")
  groceries:addGrocerySection(359, 160, 33, 230, "yogurt", "center")
end

self.market = {}
self.market.shelves = {}
self.market.addShelf = function(x, y, w, h)
  local temp = {
    x = x, y = y, w = w, h = h
  }
  table.insert(self.market.shelves, temp)
end
-- Side shelves
self.market.addShelf(0, 0, 54, 500)
self.market.addShelf(0, 0, 560, 50)
self.market.addShelf(493, 0, 60, 500)
self.market.addShelf(0, 500, 560, 50)

-- Middle shelves
self.market.addShelf(160, 160, 66, 230)
self.market.addShelf(326, 160, 66, 230)

-- Load the canvas later, since calling setMode messes everything up
self.market.loadCanvas = function()
  self.market.backImage = love.graphics.newImage("gfx/store.png")
  self.market.canvas = love.graphics.newCanvas()
  self.market.canvas:renderTo(function()
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.market.backImage)

    --[[
    love.graphics.setColor(100, 100, 100)
    for i, shelf in ipairs(self.market.shelves) do
      love.graphics.rectangle("fill", shelf.x, shelf.y, shelf.w, shelf.h)
    end
    --]]
  end)
end


self.draw = function(self)
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(self.market.canvas, 0, 0)
end

--
-- Function for checking points of the cart against the shelves
--
local checkShelves = function(newX, newY, newRot)
  local checkPoints = {
    {
      x = newX + math.cos(math.rad((newRot + 15) % 360)) * 70,
      y = newY + math.sin(math.rad((newRot + 15) % 360)) * 70
    },
    {
      x = newX + math.cos(math.rad((newRot - 15) % 360)) * 70,
      y = newY + math.sin(math.rad((newRot - 15) % 360)) * 70
    },
    {
      x = newX - math.cos(math.rad(newRot)) * 10,
      y = newY - math.sin(math.rad(newRot)) * 10
    }
  }

  for _, shelf in ipairs(self.market.shelves) do
    for _, point in ipairs(checkPoints) do
      if point.x > shelf.x and point.x < shelf.x + shelf.w and point.y > shelf.y and point.y < shelf.y + shelf.h then
        return false
      end
    end
  end

  return true
end

self.update = function(self, dt, started)
  if love.keyboard.isDown("left") then
    local newAngle = (self.cart_guy.rot - 5) % 360 
    if not checkShelves(self.cart_guy.pos.x, self.cart_guy.pos.y, newAngle) then
      newAngle = self.cart_guy.rot
    end
    self.cart_guy.rot = newAngle 
  elseif love.keyboard.isDown("right") then
    local newAngle = (self.cart_guy.rot + 5) % 360 
    if not checkShelves(self.cart_guy.pos.x, self.cart_guy.pos.y, newAngle) then
      newAngle = self.cart_guy.rot
    end
    self.cart_guy.rot = newAngle 
  end

  if love.keyboard.isDown("up") then
    self.cart_guy.speed = 8
  elseif love.keyboard.isDown("down") then
    self.cart_guy.speed = -2
  else
    self.cart_guy.speed = 0
  end

  if started then
    if love.keyboard.isDown("x") then
      if key_handled.x then
        self.cart_guy.current = 'left'
        key_handled.x = false
        local angle = math.rad((self.cart_guy.rot - 90) % 360)
        local groceryType = groceries:grabGrocery(
          self.cart_guy.pos.x + math.cos(angle) * 70,
          self.cart_guy.pos.y + math.sin(angle) * 70,
          self.cart_guy.pos.x + math.cos(angle) * 40,
          self.cart_guy.pos.y + math.sin(angle) * 40
        )
        if groceryType then
          self:grabGrocery(groceryType)
        end
      end
      key_handled.c = true
    elseif love.keyboard.isDown("c") then
      if key_handled.c then
        self.cart_guy.current = 'right'
        key_handled.c = false
        local angle = math.rad((self.cart_guy.rot + 90) % 360)
        local groceryType = groceries:grabGrocery(
          self.cart_guy.pos.x + math.cos(angle) * 70,
          self.cart_guy.pos.y + math.sin(angle) * 70,
          self.cart_guy.pos.x + math.cos(angle) * 40,
          self.cart_guy.pos.y + math.sin(angle) * 40
        )
        if groceryType then
          self:grabGrocery(groceryType)
        end
      end
      key_handled.x = true
    else
      self.cart_guy.current = 'normal'
      key_handled.x = true
      key_handled.c = true
    end
  end

  if self.cart_guy.speed ~= 0 then

    local baseCheckX = self.cart_guy.pos.x --+ math.cos(math.rad(self.cart_guy.rot)) * 70
    local baseCheckY = self.cart_guy.pos.y --+ math.sin(math.rad(self.cart_guy.rot)) * 70

    local addX = math.cos(math.rad(self.cart_guy.rot)) * self.cart_guy.speed
    local addY = math.sin(math.rad(self.cart_guy.rot)) * self.cart_guy.speed

    if checkShelves(baseCheckX + addX, baseCheckY, self.cart_guy.rot) then
      self.cart_guy.pos.x = self.cart_guy.pos.x + addX
    end

    if checkShelves(baseCheckX, baseCheckY + addY, self.cart_guy.rot) then
      self.cart_guy.pos.y = self.cart_guy.pos.y + addY
    end

  end
end

return self
