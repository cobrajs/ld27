local self = {}

self.drawEntity = function(entity)
  if entity.img then
    local drawX = entity.pos.x
    local drawY = entity.pos.y
    local rotation = 0

    local image = entity.img
    if type(image) == 'table' then
      image = image[entity.current]
    end

    if entity.parent then
      drawX = drawX + entity.parent.pos.x
      drawY = drawY + entity.parent.pos.y
    end

    if entity.center then
      drawX = drawX - (entity.center.x and entity.img:getWidth() * (entity.size and entity.size.x or 0.5) or 0)
      drawY = drawY - (entity.center.y and entity.img:getHeight() * (entity.size and entity.size.y or 0.5) or 0)
    end

    if entity.offset and not entity.rot then
      drawX = drawX + entity.offset.x
      drawY = drawY + entity.offset.y
    end

    if entity.rot then
      rotation = math.rad(entity.rot)
      local rad = math.rad(entity.rot)
      local cos = math.cos(rad)
      local sin = math.sin(rad)
      drawX = drawX + (entity.offset.x * cos - entity.offset.y * sin)
      drawY = drawY + (entity.offset.x * sin + entity.offset.y * cos)
    end

    if entity.size then
      love.graphics.draw(image, drawX, drawY, rotation, entity.size.x, entity.size.y)
    else
      love.graphics.draw(image, drawX, drawY, rotation)
    end
  end
end

return self
