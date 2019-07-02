local mqtt = require('libs.mqtt_library')
local Player = require('models/player')
local json = require('libs.json')
local weaponItem = require("models.item")
local weapon = require("models.weapon")
local construction = require("models.construction")
local bullet = require('models.bullet')

require("models.camera")

local function getMousePosition() 
	xMouse, yMouse = love.mouse.getPosition()
end

local function checkDistCollision(circleA, circleB)
 	local dist = (circleA.getX() - circleB.getX())^2 + (circleA.getY() - circleB.getY())^2
    return dist <= (circleA.getRadius() + circleB.getRadius())^2
end		

-- function bullet(xPos, yPos, bulletSize, bulletSpeed, bulletDamage)
-- 	local angle = math.atan2((yMouse - yPos), (xMouse - xPos))
-- 	local cos = math.cos(angle)
-- 	local sin = math.sin(angle)
	
-- 	return {
-- 		getX = function() return xPos end,
-- 		getY = function() return yPos end,
-- 		getBulletDamage = function() return bulletDamage end,
-- 		getRadius = function() return bulletSize end,
-- 		draw = function () 
-- 			desenhaCirculo(xPos,yPos, bulletSize)			
-- 		end,
-- 		update = function (dt)
-- 			xPos = xPos + cos * bulletSpeed * dt
-- 			yPos = yPos + sin * bulletSpeed * dt
-- 		end
-- 	}
-- end

-- 1: HEALTH, 2: DAMAGE, 3: SPEED
function item(xPos, yPos, size, type)
	local text = ""
	return {
		getX = function() return xPos end,
		getY = function() return yPos end,
		getRadius = function() return size end,
		getType = function() return type end,
		draw = function () 
			if type == 1 then
				love.graphics.setColor(0, 0, 1)
				text = "HP"
			elseif type == 2 then
				love.graphics.setColor(0, 1, 0.0)
				text = "DMG"
			elseif type == 3 then
				love.graphics.setColor(0.5, 0, 1)
				text = "SPEED"
			end
			desenhaCirculo(xPos,yPos, size)		
			love.graphics.setColor(1.0, 1.0, 1.0)	
			love.graphics.print(text, xPos - size/2,yPos - size/8, 0, 1, 1, 0,0,0,0)
		end,
		update = function (dt)
		end
	}
end

local function spawnItem() 
	math.randomseed(os.time())
	xPos= math.random(30, windowWidth)
	yPos= math.random(30, windowHeight)
	type= math.random(1, 3)
	spawnedItem = item(xPos, yPos, 10, type)
	table.insert(items, spawnedItem)
end



local function createEnemy(xPos, yPos, health, size, damage, speed)
	local playerXPos, playerYPos = player.getPos()
	local angle = math.atan2((playerYPos - yPos), (playerXPos - xPos))
	local cos = math.cos(angle)
	local sin = math.sin(angle)

	local function handleBulletDamage(bulletDamage)
		health = health - bulletDamage
	end

	return {
		getX = function() return xPos end,
		getY = function() return yPos end,
		getEnemyDamage = function() return damage end,
		getHealth = function() return health end,
		handleBulletDamage = function(dmg) handleBulletDamage(dmg) end,
		getRadius = function() return size end,
		getDamage = function() return damage end,
		draw = function () 
			love.graphics.setColor(1.0, 0, 0)
			desenhaCirculo(xPos,yPos, size)		
			love.graphics.setColor(1.0, 1.0, 1.0)	
			love.graphics.print(health .. "HP", xPos - size/2,yPos - size/8, 0, 1, 1, 0,0,0,0)
		end,
		update = function (dt)
			playerXPos, playerYPos = player.getPos()
			angle = math.atan2((playerYPos - yPos), (playerXPos - xPos))
			cos = math.cos(angle)
			sin = math.sin(angle)
			xPos = xPos + cos * speed * dt
			yPos = yPos + sin * speed * dt
		end
	}
end

local function updateAndCheckBullet(dt)
	for bulIndex, bullet in ipairs(bullets) do
		bullet.update(dt)
		for enIndex, enemy in ipairs(enemies) do
			
			if checkDistCollision(bullet,enemy) then
				enemy.handleBulletDamage(bullet.getBulletDamage())
				if enemy.getHealth() <= 0 then
					killCount = killCount + 1
					table.remove(enemies, enIndex)
				end
				table.remove(bullets, bulIndex)
				-- io.write("Collision" ..dt.. "\n")
			end
		end

		for playerIndex, pl in ipairs(players) do
			-- print(bullet.getPlayerID() .. " | " .. pl.getPlayerID())
			if bullet.getPlayerID() ~= pl.getPlayerID() then
				if checkDistCollision(bullet,pl) then
					pl.handleBulletDamage(bullet.getBulletDamage())
					if pl.getHealth() <= 0 then
						-- killCount = killCount + 1
						table.remove(players, playerIndex)
					end
					table.remove(bullets, bulIndex)
					-- io.write("Collision" ..dt.. "\n")
				end
			end
		end

		for constructionIndex, construction in ipairs(constructions) do
			if checkDistCollision(bullet,construction) then
				table.remove(bullets, bulIndex)
				-- io.write("Collision" ..dt.. "\n")
			end
		end
		
	end
end

local function updateAndCheckEnemy(dt)
	for enIndex, enemy in ipairs(enemies) do
		enemy.update(dt)
		if checkDistCollision(enemy,player) then
				player.handleEnemyDamage(enemy.getDamage())
				if player.getHealth() <= 0 then
					playerDead = true
				end
				table.remove(enemies, enIndex)
				-- killCount = killCount + 1
				
				-- io.write("Collision" ..dt.. "\n")
			end
	end
end

local function updateAndCheckItems(dt)
	for index, item in ipairs(items) do
		item.update(dt)
		if checkDistCollision(item,player) then
			io.write("colide")
			player.handlePickItem(item.getType())
			table.remove(items, index)
		end
	end
end

local function generateWave(wave) 
	math.randomseed(os.time())
	windowHeight = love.graphics.getHeight()
	windowWidth = love.graphics.getWidth()
	enemyCount = wave * 5
	enemyHealth = 200 + wave * 20
	enemySpeed = 100 + wave * 10
	enemyDamage = 5 + wave
	if enemySpeed > 160 then
		enemySpeed = 160
	end
	if enemyHealth > 2500 then
		enemyHealth = 2500
	end
	if enemyDamage > 20 then
		enemyDamage = 20
	end
	for enemy = enemyCount, 1, -1 do
		xPos= math.random(player.getX() - windowWidth * 2, player.getX() + windowWidth * 2)
		yPos= math.random(player.getY() - windowHeight * 2, player.getY() + windowHeight * 2)
		enemy = createEnemy(xPos, yPos, enemyHealth, 20, enemyDamage, enemySpeed)
		table.insert(enemies, enemy)
	end
end

function tableLength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end


local function drawUI()
	windowHeight = love.graphics.getHeight()
	windowWidth = love.graphics.getWidth()
	love.graphics.setColor(48/255,48/255,48/255,1)
	-- love.graphics.rectangle("fill", (windowWidth / 2) - 100, windowHeight - 50, 200, 50)
	love.graphics.print(player.getHealth() .. " HP", 50,50, 0, 2, 2, 0,0,0,0)
	-- love.graphics.print("DAMAGE: " .. player.getDamage(), windowWidth - 200,50, 0, 2, 2, 0,0,0,0)
	-- love.graphics.print("SPEED: " .. player.getSpeed(), windowWidth - 200,100, 0, 2, 2, 0,0,0,0)
	-- love.graphics.print("KILLS: " .. killCount, windowWidth - 200,150, 0, 2, 2, 0,0,0,0)
	-- love.graphics.print("WAVE " .. wave, windowWidth - 200, windowHeight - 50, 0, 2, 2, 0,0,0,0)
	-- love.graphics.print("ENEMIES ALIVE: " .. tableLength(enemies), 50, windowHeight - 50, 0, 2, 2, 0,0,0,0)
end

local function drawDeadUI() 
	if playerDead == true then
		love.graphics.print("GAME OVER", 50, 50, 0, 5, 5, 0,0,0,0)
		love.graphics.print("WAVE " .. wave, 50, 150, 0, 2, 2, 0,0,0,0)
		love.graphics.print("KILLS: " .. killCount, 50,200, 0, 2, 2, 0,0,0,0)
	end
end	

local function updatePlayersPos(message) 
	local decMessage = json.decode(message)
	local playerFound = false
	for index, player in ipairs(players) do
		if player.getPlayerID() == decMessage.playerID then
			if decMessage.playerID ~= generatedPlayerID then
				player.setX(decMessage.xPos)
				player.setY(decMessage.yPos)	
				player.setAngle(decMessage.angle)
			end
			playerFound = true
		end
	end		
	if playerFound == false then
		print("Criou o novo player")
		local player = Player.create(decMessage.playerID, decMessage.xPos,decMessage.yPos,32, 200, 100, 50)
		table.insert(players, player)
	end
end

local function updateBulletsPos(message) 
	local decMessage = json.decode(message)
	if decMessage.playerId ~= player.getPlayerID() then
		bullet.spawnBullet(decMessage.xPos, decMessage.yPos, decMessage.bulletSize, decMessage.bulletSpeed,
			 decMessage.bulletDamage, decMessage.shotSpread, decMessage.angle, decMessage.playerId)
	end
end

function callback(topic, message)
    -- print("Received: " .. topic .. ": " .. message)
    if (topic == "1311291playerMovement") then 
    	updatePlayersPos(message)

	elseif (topic == "1311291shoot") then 
		-- print(message)
		updateBulletsPos(message)

	elseif (topic == "1311291pickItem") then 
		local decMessage = json.decode(message)
		for index, gameItem in ipairs(gameItems) do
			if gameItem.getId() == decMessage.itemIndex then
				table.remove(gameItems, index)
			end
		end
	elseif (topic == "1311291returnItem") then 
		local decMessage = json.decode(message)
		table.insert(gameItems, weaponItem.createWeaponItem(decMessage.x, decMessage.y, decMessage.weaponId))
    end

end	

function love.load(arg)
	if arg[#arg] == "-debug" then require("mobdebug").start() end
	love.window.setMode(1200, 700)
	love.window.setFullscreen(false)
	love.graphics.setBackgroundColor(66/255, 245/255, 105/255)
	
	-- mqtt.Utility.set_debug(true)
	math.randomseed(os.time())
	generatedPlayerID = math.random(1, 500000)
	-- 85.119.83.194
	mqtt_client = mqtt.client.create("127.0.0.1", 1883, callback)
  	mqtt_client:connect("cliente " .. generatedPlayerID)
  	mqtt_client:subscribe({"1311291playerMovement"})
  	mqtt_client:subscribe({"1311291shoot"})
  	mqtt_client:subscribe({"1311291pickItem"})
  	mqtt_client:subscribe({"1311291returnItem"})

  	mapWidth = 2000
  	mapHeight = 2000
	xMouse = 0
	yMouse = 0
	wave = 0
	enemies = {}
	killCount = 0
	itemsGenerated = 0

	playerDead = false

	bullets = {}
	items = {}
	players = {}
	weapons = {}
	gameItems = {}
	constructions = {}

	playersLength = tableLength(players)
	playerIniX = 0
	playerIniY = 0
	if playersLength == 1 then
		playerIniX = -1500
		playerIniY = 1500
	elseif playersLength == 2 then
		playerIniX = 1500
		playerIniY = -1500
	elseif playersLength == 3 then
		playerIniX = 1500
		playerIniY = 1500
	elseif playersLength == 4 then
		playerIniX = 0
		playerIniY = 0
	end
	player = Player.create(generatedPlayerID, playerIniX, playerIniY,32, 200, 100, 50)

	table.insert(players, player)
	weapon.loadWeapons()

	weaponItem.loadItems()

	for index, gameItem in ipairs(gameItems) do
		print(gameItem.getId())
	end
	-- testConstruction = construction.construction(350, 300, 70)
	construction.loadConstructions()
	-- table.insert(constructions, testConstruction)	
	-- world = love.physics.newWorld( 0, 100, false )
	-- body = love.physics.newBody( world, 50, 50, "dynamic" )
	-- shape = love.physics.newCircleShape( 20 )
	-- fixture = love.physics.newFixture( body, shape )
	-- fixture:setRestitution(0.9)
end


function love.draw()
	-- love.graphics.setColor(0.28, 0.63, 0.05) -- set the drawing color to green for the ground
 --  	love.graphics.circle("fill", body:getX(), body:getY(), shape:getRadius())

 	if playerDead == false then
		camera:set()
		for index, construction in ipairs(constructions) do
			construction.draw()
		end

		for index, bullet in ipairs(bullets) do
			bullet.draw()
		end

		for index, gameItem in ipairs(gameItems) do
			gameItem.draw()
		end

		for index, enemy in ipairs(enemies) do
			enemy.draw()
		end

		for index, item in ipairs(items) do
			item.draw()
		end
		for index, player in ipairs(players) do
			if player.isDead() == false then
				player.draw()
			elseif playerID == generatedPlayerID then
				playerDead = true	
			end
		end

		camera:unset()

		player.getInventory().draw()
		
			
		drawUI()
	end
	drawDeadUI()
end

last = 0

function love.update(dt)
	-- world:update(dt)
	if playerDead == false then
		mqtt_client:handler()
		getMousePosition()
		player.update(dt)

		camera.x = player.getX() - love.graphics.getWidth()/2
		camera.y = player.getY() - love.graphics.getHeight()/2

		-- if camera.x < 0 then camera.x = 0 end
		-- if camera.y < 0 then camera.y = 0 end
		if camera.x > mapWidth - love.graphics.getWidth()/2 then
		  camera.x = mapWidth - love.graphics.getWidth()/2
		end
		if camera.y > mapHeight - love.graphics.getHeight()/2 then
		  camera.y = mapHeight - love.graphics.getHeight()/2
		end

		player.getInventory().update(dt)
		updateAndCheckBullet(dt)
		updateAndCheckEnemy(dt)
		updateAndCheckItems(dt)
		if false  then--tableLength(enemies) == 0 then
			wave = wave + 1
			generateWave(wave)
		end
		
		if killCount % 10 == 0  then
			if itemsGenerated < killCount / 10 then
				itemsGenerated = itemsGenerated + 1
				spawnItem()
			end
		end
	end
	
end