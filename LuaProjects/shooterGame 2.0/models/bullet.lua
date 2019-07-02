local json = require("libs.json")

function bullet(xPos, yPos, bulletSize, bulletSpeed, bulletDamage, bulletSpread)
	
	local angle = math.atan2((yMouse - (love.graphics.getHeight()/2)), (xMouse - (love.graphics.getWidth()/2)))
	local xPos = xPos
	local yPos = yPos
	local createdAt = love.timer.getTime()
	local spread = bulletSpread * math.pi / 180
	math.randomseed(love.timer.getTime())
	local randomSpread = spread * (math.random(-5000, 5000) / 10000)
	angle = angle + randomSpread
	local cos = math.cos(angle)
	local sin = math.sin(angle)
	local playerID

	local function setNewAngle(newAngle)
		angle = newAngle + randomSpread
		cos = math.cos(angle)
		sin = math.sin(angle)
	end

	return {
		getX = function() return xPos end,
		getY = function() return yPos end,
		getBulletDamage = function() return bulletDamage end,
		getRadius = function() return bulletSize end,
		getAngle = function() return angle end,
		getBulletSpeed = function() return bulletSpeed end,
		getBulletDamage = function() return bulletDamage end,
		getShotSpread = function() return bulletSpread end,
		setAngle = function(newAngle) return setNewAngle(newAngle) end,
		setPlayerID = function(newPlayerID) playerID = newPlayerID end,
		getPlayerID = function() return playerID end,
		draw = function () 
			love.graphics.setColor(175/255,48/255,48/255,1)
			desenhaCirculo(xPos,yPos, bulletSize)			
		end,
		update = function (dt)
			xPos = xPos + cos * bulletSpeed * dt
			yPos = yPos + sin * bulletSpeed * dt
		end
	}end


local function spawnBullet(xPos, yPos, bulletSize, bulletSpeed, bulletDamage, bulletSpread, angle, playerID) 

	bul = bullet(xPos, yPos, bulletSize, bulletSpeed, bulletDamage, bulletSpread)
	if angle ~= nil then
		bul.setAngle(angle)
	end
	if playerID ~= nil then
		bul.setPlayerID(playerID)
	end
	table.insert(bullets, bul)
	return bul
end

local M = {}
M.spawnBullet = spawnBullet
return M