local self = {}

self.rand = function(max)
  return math.floor(math.random() * max)
end

self.shiftPoints = function(vector, ...)
  local pointsList = {...}
  for i = 1, #pointsList do
    pointsList[i] = pointsList[i] + (i % 2 == 0 and vector.y or vector.x)
  end
  return unpack(pointsList)
end

return self
