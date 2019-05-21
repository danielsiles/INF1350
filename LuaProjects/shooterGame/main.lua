local function desenhaCirculo(x,y,raio)
  love.graphics.circle("fill", x, y, raio)   
end

local function desenhaLinha(x1, y1, x2, y2)
  love.graphics.setColor(1.0, 0, 0.3)
  love.graphics.line(x1, y1, x2, y2)   
end

local function getMousePosition() 
	xMouse, yMouse = love.mouse.getPosition()
end

local function checkDistCollision(circleA, circleB)
 	local dist = (circleA.getX() - circleB.getX())^2 + (circleA.getY() - circleB.getY())^2
    return dist <= (circleA.getRadius() + circleB.getRadius())^2
end		

function bullet(xPos, yPos, bulletSize, bulletSpeed, bulletDamage)
	local angle = math.atan2((yMouse - yPos), (xMouse - xPos))
	local cos = math.cos(angle)
	local sin = math.sin(angle)
	
	return {
		getX = function() return xPos end,
		getY = function() return yPos end,
		getBulletDamage = function() return bulletDamage end,
		getRadius = function() return bulletSize end,
		draw = function () 
			desenhaCirculo(xPos,yPos, bulletSize)			
		end,
		update = function (dt)
			xPos = xPos + cos * bulletSpeed * dt
			yPos = yPos + sin * bulletSpeed * dt
		end
	}
end

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

local function spawnBullet(xPos, yPos, bulletSize, bulletSpeed, bulletDamage) 
	bul = bullet(xPos, yPos, bulletSize, bulletSpeed, bulletDamage)
	table.insert(bullets, bul)
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

local function createPlayer(xPos, yPos, playerRadius, playerSpeed, playerHealth, playerDamage) 
	local angle = math.atan2((yMouse - yPos), (xMouse - xPos))
	local cos = math.cos(angle)
	local sin = math.sin(angle)
	local canFire = true
	local lastShoot = 0;


	local function handleEnemyDamage(dmg)
		playerHealth = playerHealth - dmg
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
		mouseDown = love.mouse.isDown(2)
		if mouseDown then
			if love.timer.getTime() - lastShoot > 0.2  then
				lastShoot = love.timer.getTime()
				spawnBullet(xPos, yPos, 9, 800, playerDamage)
			end	
		end	
	end

	return {
		getPos = function ()
			return xPos, yPos
		end,
		getX = function() return xPos end,
		getY = function() return yPos end,
		getRadius = function() return playerRadius end,
		getHealth = function() return playerHealth end,
		getDamage = function() return playerDamage end,
		getSpeed = function() return playerSpeed end,
		handleEnemyDamage = function(dmg) handleEnemyDamage(dmg) end,
		handlePickItem = function(type) handlePickItem(type) end,
		draw = function ()
			love.graphics.setColor(0.6, 0.5, 0.3)
			desenhaCirculo(xPos,yPos, playerRadius)
			desenhaLinha(xPos, yPos, xPos + cos * (playerRadius * 1.2) , yPos + sin * (playerRadius * 1.2))
		end,
		update = function (dt)
			xMouse, yMouse = love.mouse.getPosition()
			shoot()
			angle = math.atan2((yMouse - yPos), (xMouse - xPos))
			cos = math.cos(angle)
			sin = math.sin(angle)
			downUp = love.keyboard.isDown("s") or love.keyboard.isDown("w")
			leftRight = love.keyboard.isDown("a") or love.keyboard.isDown("d")

			speed = playerSpeed
			if(downUp and leftRight) then
			speed = speed / math.sqrt(2)
			end

			if love.keyboard.isDown("s") and yPos<love.graphics.getHeight()-playerRadius*2 then
			yPos = yPos + dt * speed
			elseif love.keyboard.isDown("w") and yPos>0 then
			yPos = yPos - dt * speed
			end

			if love.keyboard.isDown("d") and xPos<love.graphics.getWidth()-playerRadius*2 then
			xPos = xPos + dt * speed
			elseif love.keyboard.isDown("a") and xPos>0 then
			xPos = xPos - dt * speed
			end

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
				killCount = killCount + 1
				
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

function love.load(arg)
	if arg[#arg] == "-debug" then require("mobdebug").start() end
	love.window.setFullscreen(true)
	love.graphics.setBackgroundColor(0.21, 0.67, 0.97)
	xMouse = 0
	yMouse = 0
	wave = 0
	enemies = {}
	killCount = 0
	itemsGenerated = 0
	player = createPlayer(0,0,32, 200, 100, 50)
	
	table.insert(enemies, enemy)
	table.insert(enemies, enemy2)
	playerDead = false
	bullets = {}
	items = {}

end

local function drawUI()
	windowHeight = love.graphics.getHeight()
	windowWidth = love.graphics.getWidth()
	love.graphics.print(player.getHealth() .. " HP", 50,50, 0, 2, 2, 0,0,0,0)
	love.graphics.print("DAMAGE: " .. player.getDamage(), windowWidth - 200,50, 0, 2, 2, 0,0,0,0)
	love.graphics.print("SPEED: " .. player.getSpeed(), windowWidth - 200,100, 0, 2, 2, 0,0,0,0)
	love.graphics.print("KILLS: " .. killCount, windowWidth - 200,150, 0, 2, 2, 0,0,0,0)
	love.graphics.print("WAVE " .. wave, windowWidth - 200, windowHeight - 50, 0, 2, 2, 0,0,0,0)
	love.graphics.print("ENEMIES ALIVE: " .. tableLength(enemies), 50, windowHeight - 50, 0, 2, 2, 0,0,0,0)
end

local function drawDeadUI() 
	if playerDead == true then
		love.graphics.print("GAME OVER", 50, 50, 0, 5, 5, 0,0,0,0)
		love.graphics.print("WAVE " .. wave, 50, 150, 0, 2, 2, 0,0,0,0)
		love.graphics.print("KILLS: " .. killCount, 50,200, 0, 2, 2, 0,0,0,0)
	end
end	

function love.draw()
	if playerDead == false then
		player.draw()
		for index, bullet in ipairs(bullets) do
			bullet.draw()
		end

		for index, enemy in ipairs(enemies) do
			enemy.draw()
		end

		for index, item in ipairs(items) do
			item.draw()
		end
		drawUI()
	end
	drawDeadUI()
end

function love.update(dt)
	if playerDead == false then
		getMousePosition()
		player.update(dt)
		updateAndCheckBullet(dt)
		updateAndCheckEnemy(dt)
		updateAndCheckItems(dt)
		if tableLength(enemies) == 0 then
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