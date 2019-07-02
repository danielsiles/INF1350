function desenhaCirculo(x,y,raio)
  love.graphics.circle("fill", x, y, raio)   
end

function desenhaLinha(x1, y1, x2, y2)
  love.graphics.setColor(1.0, 0, 0.3)
  love.graphics.line(x1, y1, x2, y2)   
end

function getImageScaleForNewDimensions( image, newWidth, newHeight )
    local currentWidth, currentHeight = image:getDimensions()
    return ( newWidth / currentWidth ), ( newHeight / currentHeight )
end



local M = {}
M.desenhaLinha = desenhaLinha
M.desenhaCirculo = desenhaCirculo
M.getImageScaleForNewDimensions = getImageScaleForNewDimensions
return M