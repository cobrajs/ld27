--
-- Swipe the Roast
--

local screen = {w = 900, h = 500}

local utils = require("utils")

local entity = require("entity")

local groceries = require("groceries")

-- 
-- Sections
--

local cartSection = require("cart_section")
cartSection.addGroceriesVar(groceries)

local marketSection = require("market_section")
marketSection.addGroceriesVar(groceries)

local entities = {}

local countdown = {
  go = {
    img = nil
  }
}

local numbers = {}

local finalScore = {}

--
-- Screens
--

local screens = {
  title = {
    delay = 3,
    exit = "help",
    img = nil
  },
  help = {
    exit = "game",
    img = nil
  },
  game = {
    started = false,
    startDelay = 3,
    goDelay = 1,
    timer = 10,
    delay = 3,
    exit = "score"
  },
  score = {
    delay = 5,
    exit = "about"
  },
  about = {
    img = nil
  }
}

local timeImg = nil
local gameoverImg = nil
local font = nil

local currentScreen = "title"

function love.load()
  love.graphics.setBackgroundColor(255, 255, 255)
  love.graphics.setMode(900, 500)

  font = love.graphics.newFont(32)

  --
  -- Load images for screens
  --
  
  screens.title.img = love.graphics.newImage("gfx/title.png")
  screens.about.img = love.graphics.newImage("gfx/about.png")
  screens.help.img = love.graphics.newImage("gfx/help.png")

  countdown[3] = love.graphics.newImage("gfx/3.png")
  countdown[2] = love.graphics.newImage("gfx/2.png")
  countdown[1] = love.graphics.newImage("gfx/1.png")
  countdown.go = love.graphics.newImage("gfx/go.png")

  numbers.dot = love.graphics.newImage("gfx/numbers/dot.png")
  for i = 0, 9 do
    numbers[i] = love.graphics.newImage("gfx/numbers/" .. i .. ".png")
  end

  timeImg = love.graphics.newImage("gfx/time.png")
  gameoverImg = love.graphics.newImage("gfx/gameover.png")

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
  marketSection.grabGrocery = function(self, groceryType)
    cartSection:addGrocery(groceryType)
  end

  marketSection:setupGrocerySections(groceries)

  -- Add entities
  table.insert(entities, cartSection.drop)
  table.insert(entities, cartSection.cart)
  table.insert(entities, marketSection.cart_guy)

end

function love.update(dt)
  local screen = screens[currentScreen]
  if currentScreen == "game" then
    cartSection:update(dt, screen.started and screen.timer > 0)
    marketSection:update(dt, screen.started and screen.timer > 0)

    if screen.started then 
      if screen.timer > 0 then
        screen.timer = screen.timer - dt
      end

      if screen.timer <= 0 then
        screen.delay = screen.delay - dt

        if screen.delay <= 0 then
          finalScore = cartSection:getScore()
          currentScreen = "score"
        end
      end

      if screen.goDelay > 0 then
        screen.goDelay = screen.goDelay - dt
      end
    else
      screen.startDelay = screen.startDelay - dt
      if screen.startDelay <= 0 then
        screen.started = true
      end
    end
  elseif currentScreen == "title" or currentScreen == "score" then
    screen.delay = screen.delay - dt
    if screen.delay <= 0 then
      currentScreen = screen.exit
    end
  end
end

function love.draw()
  if currentScreen == "game" then
    cartSection:draw()
    marketSection:draw()

    if not screens[currentScreen].started then
      local image = countdown[math.ceil(screens[currentScreen].startDelay)]
      love.graphics.draw(image, screen.w / 2 - image:getWidth() / 2, screen.h / 2 - image:getHeight() / 2)
    end

    if screens[currentScreen].started and screens[currentScreen].goDelay > 0 then
      love.graphics.draw(countdown.go, screen.w / 2 - countdown.go:getWidth() / 2, screen.h / 2 - countdown.go:getHeight() / 2)
    end

    if screens[currentScreen].timer <= 0 then
      love.graphics.draw(gameoverImg, screen.w / 2 - gameoverImg:getWidth() / 2, screen.h / 2 - gameoverImg:getHeight() / 2)
    end

    if screens[currentScreen].started then
      local number = math.floor(screens[currentScreen].timer)
      if number < 10 and number >= 0 then
        love.graphics.draw(timeImg, 50, 420)

        local image = numbers[number]
        love.graphics.draw(image, 180, 440)
      end
    end

    love.graphics.setColor(255, 255, 255)
    for i, e in ipairs(entities) do
      entity.drawEntity(e)
    end
  elseif currentScreen == "title" or currentScreen == "about" or currentScreen == "help" then
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(screens[currentScreen].img)
  elseif currentScreen == "score" then
    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(font)
    love.graphics.print("Worth: $" .. finalScore.worth, 20, 20)
    love.graphics.print("Damaged: $" .. finalScore.damaged, 20, 70)
    love.graphics.print("Total: " .. finalScore.inCart .. "/" .. finalScore.total, 20, 120)
    love.graphics.print("Final Score: $" .. finalScore.final, 20, 170)
  end
end

function love.keypressed(key, uni)
  if key == "q" or key == "escape" then
    love.event.push("quit")
  end

  if currentScreen == "title" or currentScreen == "help" or currentScreen == "score" then
    currentScreen = screens[currentScreen].exit
  end
end

