--
-- Swipe the Roast
--

local screen = {w = 900, h = 500}

local utils = require("utils")

local entity = require("entity")

-- 
-- Sections
--

local cartSection = require("cart_section")

local marketSection = require("market_section")

local entities = {}

function love.load()
  love.graphics.setBackgroundColor(255, 255, 255)
  love.graphics.setMode(900, 500)

  --
  -- Handle Cart section
  --

  cartSection:updateSizing(screen)
  cartSection:setupPhysics()

  --
  -- Handle market section
  --
  
  marketSection:updateSizing(screen)
  marketSection.size.w = screen.w - cartSection.size.w

  -- Add entities
  table.insert(entities, cartSection.drop)
  table.insert(entities, cartSection.cart)
  table.insert(entities, marketSection.cart_guy)

end

function love.update(dt)
  cartSection:update(dt)
  marketSection:update(dt)
end

function love.draw()
  cartSection:draw()
  marketSection:draw()

  --[[
  love.graphics.setColor(50, 50, 200)
  for desc, wall in pairs(cartSection.physics.sides) do
    love.graphics.polygon("fill", wall.body:getWorldPoints(wall.shape:getPoints()))
  end
  --]]

  love.graphics.setColor(255, 255, 255)
  for i, e in ipairs(entities) do
    entity.drawEntity(e)
  end
end

function love.keypressed(key, uni)
  if key == "q" or key == "escape" then
    love.event.push("quit")
  elseif key == " " then
    cartSection:addGrocery(drop)
  elseif key == 'c' then
    local total = #cartSection.groceries
    local inCart = 0
    for i, grocery in ipairs(cartSection.groceries) do
      if cartSection:inCart(grocery) then
        inCart = inCart + 1
      end
    end

    print ("Total: ", total, " In Cart: ", inCart)
  elseif key == 'd' then
    for i, grocery in ipairs(cartSection.groceries) do
      grocery.body:destroy()
    end
  end
end
