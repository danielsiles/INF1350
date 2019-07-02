local bullet = require('models.bullet')
local json = require('libs.json')

function weapon(name, icon, playerIcon, firingMode, ammoType, magCapacity, reloadTime, firingDelay, shotSpread, bulletPerShot, equipMoveSpeed, firingMoveSpeed, bulletSpeed, bulletDamage)
	local name = name
	local firingMode = firingMode
	local ammoType = ammoType
	local magCapacity = magCapacity
	local reloadTime = reloadTime
	local firingDelay = firingDelay
	local shotSpread = shotSpread
	local equipMoveSpeed = equipMoveSpeed
	local firingMoveSpeed = firingMoveSpeed
	local bulletPerShot = bulletPerShot
	local bulletsInMag = 0
	local icon = love.graphics.newImage(icon)
	local playerIcon = love.graphics.newImage(playerIcon)

	local function fire()
		if(bulletsInMag > 0) then
			for i = 1, bulletPerShot do
				local bul = bullet.spawnBullet(player.getX(), player.getY(), 9, bulletSpeed, bulletDamage, shotSpread, nil, player.getPlayerID())
				local bulletData = {
					playerId = generatedPlayerID,
					xPos = player.getX(),
					yPos = player.getY(),
					bulletSize = 9,
					bulletSpeed = bulletSpeed,
					bulletDamage = bulletDamage,
					shotSpread = shotSpread,
					angle = bul.getAngle()
				}

				mqtt_client:publish("1311291shoot", json.encode(bulletData))
			end
			bulletsInMag = bulletsInMag - 1
		end
	end

	return {
		getName = function() return name end,
		getIcon = function() return icon end,
		getPlayerIcon = function() return playerIcon end,
		getFiringMode = function() return firingMode end,
		getAmmoType = function() return ammoType end,
		getMagCapacity = function() return magCapacity end,
		getReloadTime = function() return reloadTime end,
		getFiringDelay = function() return firingDelay end,
		getShotSpread = function() return shotSpread end,
		getEquipMoveSpeed = function() return equipMoveSpeed end,
		getFiringMoveSpeed = function() return firingMoveSpeed end,
		getBulletPerShot = function() return bulletPerShot end,
		getBulletsInMag = function() return bulletsInMag end,
		setBulletsInMag = function(amount) bulletsInMag = amount end,
		fire = function() fire() end,	
		draw = function () 
			desenhaCirculo(xPos,yPos, bulletSize)			
		end,
		update = function (dt)
		
			xPos = xPos + cos * bulletSpeed * dt
			yPos = yPos + sin * bulletSpeed * dt
		end
	}
end

function loadWeapons()
	table.insert(weapons, weapon("Pump", "img/pumpIcon.png", "img/pumpIcon.png",1, 1, 5, 2.4, 0.9, 35, 18,80, 60, 3000, 9))
	table.insert(weapons, weapon("SMG", "img/smgIcon.png", "img/smgPlayerIcon.png",1, 2, 35, 2.4, 0.09, 15, 1,80, 60, 7000, 16))
	table.insert(weapons, weapon("AK-47", "img/ak47Icon.png", "img/ak47PlayerIcon.png",1, 2, 30, 2.4, 0.14, 7, 1, 80, 60, 8000, 24))
	table.insert(weapons, weapon("Barret", "img/sniperIcon.png", "img/sniperPlayerIcon.png",1, 3, 5, 2.4, 1.9, 1, 1, 80, 60, 10000, 80))
end

-- firemode 1 = single
-- firemode 2 = burst
-- firemode 3 = auto

-- ammoType 1 = shotgun
-- ammoType 2 = smg
-- ammoType 3 = dmr
-- ammoType 4 = sniper

local M = {}
M.weapon = weapon
M.loadWeapons = loadWeapons
return M