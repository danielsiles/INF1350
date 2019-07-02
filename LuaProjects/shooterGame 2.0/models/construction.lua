function construction(xPos, yPos, radius)
	local xPos = xPos
	local yPos = yPos
	local radius = radius
	math.randomseed(love.timer.getTime())
	local r = math.random(1, 255)/255
	local g = math.random(1, 255)/255
	local b = math.random(1, 255)/255
	return {
		getX = function() return xPos end,
		getY = function() return yPos end,
		getRadius = function() return radius end,
		draw = function () 
			love.graphics.setColor(r, g, b)
			love.graphics.circle("fill", xPos, yPos, radius)  		
		end,
	}
end

function loadConstructions()	
	local wallRadius = 20
	local constructionDefaultRadius = 70

	for i=1,(mapHeight * 2) / wallRadius do
		table.insert(constructions, construction(-mapWidth, -mapHeight + (i - 1) * wallRadius, wallRadius))	
		table.insert(constructions, construction(mapWidth, -mapHeight + (i - 1) * wallRadius, wallRadius))	
	end
	for i=1,(mapWidth * 2) / wallRadius do
		table.insert(constructions, construction(-mapWidth + (i - 1) * wallRadius, mapHeight, wallRadius))	
		table.insert(constructions, construction(-mapWidth + (i - 1) * wallRadius, -mapHeight, wallRadius))	
	end
	table.insert(constructions, construction(-1650, -1500, constructionDefaultRadius))	
	
	for i=1,100 do
		math.randomseed(i)
		local posX = math.random(-2000, 2000)
		local posY = math.random(-2000, 2000)
		print(posX .. " , " .. posY)
		table.insert(constructions, construction(posX, posY, constructionDefaultRadius))	
	end
	print(tableLength(constructions))
	-- testConstruction = construction.construction(350, 300, 70)
	
end

local M = {}
M.construction = construction
M.loadConstructions = loadConstructions
return M