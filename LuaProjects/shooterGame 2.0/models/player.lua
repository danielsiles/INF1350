local drawUtils = require('utils/drawUtils')
local json = require('libs.json')
local bullet = require('models.bullet')
local inventory = require('models.inventory')
require('models.camera')

local function checkDistCollision(circleA, circleB)
 	local dist = (circleA.getX() - circleB.getX())^2 + (circleA.getY() - circleB.getY())^2
    return dist <= (circleA.getRadius() + circleB.getRadius())^2
end		

local function create(playerID, xPos, yPos, playerRadius, playerSpeed, playerHealth, playerDamage)
	local angle = math.atan2((yMouse - (love.graphics.getHeight()/2)), (xMouse - (love.graphics.getWidth()/2)))
	local lastAngle = angle 
	local cos = math.cos(angle)
	local sin = math.sin(angle)
	local canFire = true
	local lastShoot = 0
	local playerID = playerID
	local inventory = inventory.createInventory()
	local canPickItem = true
	local reloading = false
	local playerHealth = playerHealth
	local dead = false

	local function handleEnemyDamage(dmg)
		playerHealth = playerHealth - dmg
	end

	local function handleBulletDamage(bulletDamage)
		playerHealth = playerHealth - bulletDamage
		print(playerHealth)
		if playerHealth < 0 then
			dead = true
		end
	end

	local function handlePickItem(type)
		if type == 1 then
			playerHealth = playerHealth + 40
			if playerHealth > 100 then
				playerHealth = 100
			end
		elseif type == 2 then
			playerDamage = playerDamage + 15
		elseif type == 3 then
			playerSpeed = playerSpeed + 15
		end
	end

	local function shoot() 
		mouseDown = love.mouse.isDown(1)
		if mouseDown then
			local weapon = inventory.getWeapon()
			if weapon ~= nil then 
				if love.timer.getTime() - lastShoot > weapon.getFiringDelay() then
					lastShoot = love.timer.getTime()
					weapon.fire()
				end	
			end
		end	
	end

	return {
		getPos = function ()
			return xPos, yPos
		end,
		getPlayerID = function() return playerID end,
		isDead = function() return dead end,
		getX = function() return xPos end,
		getY = function() return yPos end,
		setX = function(newPos) xPos = newPos end,
		setY = function(newPos) yPos = newPos end,
		getRadius = function() return playerRadius end,
		getHealth = function() return playerHealth end,
		getDamage = function() return playerDamage end,
		getSpeed = function() return playerSpeed end,
		getInventory = function() return inventory end,
		handleEnemyDamage = function(dmg) handleEnemyDamage(dmg) end,
		handleBulletDamage = function(dmg) handleBulletDamage(dmg) end,
		handlePickItem = function(type) handlePickItem(type) end,
		setAngle = function(newAngle) angle = newAngle end,
		draw = function ()
			if dead == false then
				love.graphics.setColor(0.6, 0.5, 0.3)
				drawUtils.desenhaCirculo(xPos,yPos, playerRadius)
				cos = math.cos(angle)
				sin = math.sin(angle)
				drawUtils.desenhaLinha(xPos, yPos, xPos + cos * (playerRadius * 1.2) , yPos + sin * (playerRadius * 1.2))
			end
			-- print(xPos .. " , " .. yPos)
		end,
		update = function (dt)
			if dead == false then
				xMouse, yMouse = love.mouse.getPosition()
				shoot()
				if playerID == generatedPlayerID then
					angle = math.atan2((yMouse - (love.graphics.getHeight()/2)), (xMouse - (love.graphics.getWidth()/2)))
					cos = math.cos(angle)
					sin = math.sin(angle)
				end
				downUp = love.keyboard.isDown("s") or love.keyboard.isDown("w")
				leftRight = love.keyboard.isDown("a") or love.keyboard.isDown("d")

				local changedPlayerData = false

				speed = playerSpeed
				if(downUp and leftRight) then
				speed = speed / math.sqrt(2)
				end


				local lastY = yPos
				local lastX = xPos

				if love.keyboard.isDown("s") and yPos< mapHeight -playerRadius*2 then
					yPos = yPos + dt * speed
					changedPlayerData = true
				elseif love.keyboard.isDown("w") and yPos>-mapHeight then
					yPos = yPos - dt * speed
					changedPlayerData = true
				end

				if love.keyboard.isDown("d") and xPos<mapWidth -playerRadius*2 then
					xPos = xPos + dt * speed
					changedPlayerData = true
				elseif love.keyboard.isDown("a") and xPos>-mapWidth then
					xPos = xPos - dt * speed
					changedPlayerData = true
				end

				for constructionIndex, construction in ipairs(constructions) do
					if checkDistCollision(player,construction) then
						yPos = lastY
						xPos = lastX
					end
				end


				if love.keyboard.isDown("space") then
					for index, gameItem in ipairs(gameItems) do
						if checkDistCollision(player, gameItem) then
							if canPickItem then
								canPickItem = false
								if gameItem.getItemType() == "weapon" then
									if inventory.pickWeaponItem(gameItem) then
										table.remove(gameItems, index)
									end
								elseif gameItem.getItemType() == "bullet" then
									if inventory.pickBulletItem(gameItem) then
										table.remove(gameItems, index)
									end
									
								end
								local itemData = {
									playerID = playerID,
									itemIndex = gameItem.getId()
								}
								mqtt_client:publish("1311291pickItem", json.encode(itemData))
							end
						end
					end
					
				else 
					canPickItem = true
				end

				if love.keyboard.isDown("r") then
					if reloading == false then
						reloading = true
						inventory.reloadWeapon()
					end
				else
					reloading = false
				end

				if playerID == generatedPlayerID then
					if changedPlayerData then
						local playerData = {
							playerID = playerID,
							xPos = xPos,
							yPos = yPos,
							angle = angle
						}

						mqtt_client:publish("1311291playerMovement", json.encode(playerData))
						-- socket.sleep(0.1)
					end
					-- 
				end
			end
		end
	}
end

local M = {}
M.create = create
return M