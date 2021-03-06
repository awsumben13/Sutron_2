
local items = { }

game.engine.item = { }
game.engine.item.get = function( name )
	if items[name] then
		return items[name]
	end
	return false
end

game.engine.item.create = function( )
	local i = { }
	i.name = "Stone"
	i.type = "Block"
	i.emitLightSource = false; -- think about it ok ( so it emits a light source in your hand )?
	i.blockBreakingTimes = { };
	i.typeBreakingTimes = { };
	
	i.useInMap = function( self, map, x, y, xd, yd )
		local x = math.floor( x / map.blockSize )
		local y = math.floor( y / map.blockSize )
		local xd = xd == "none" and "left" or xd
		local yd = yd == "none" and "left" or yd
		if self.type == "Block" then
			local ok = true
			for i = 1,#map.entities do
				local col = game.physics.collisionBERR( map.entities[i], x, y )
				if col then ok = false end
			end
			if map.blocks[x] and map.blocks[x][y] and map.blocks[x][y].block.solid then
				ok = false
			end
			if ok then
				local b = map:placeBlock( x, y, self.name )
				if b then
					b.block.xdirection = xd
					b.block.ydirection = yd
				end
			end
		elseif self.type == "Tool" then
			local block = map.blocks[x] and map.blocks[x][y] and map.blocks[x][y].block or false
			if block then
				if block.type ~= "Air" then
					local ts = self.toolTargetDensity or 1
					local td = self.toolTargetDamage or 1
					local speed = td / math.abs( ts - block.density )
					if speed > block.maxDamage then speed = block.maxDamage end
					map:hitBlock( x, y, speed, self )
				end
			end
		end
	end

	i.render = function( self, image, x, y, dir )
		if not game.data.Items[self.name][image] then return end
		local image = game.data.Items[self.name][image].image
		if dir == "right" then
			x = x + 20
		end
		love.graphics.draw( image, x, y, 0, dir == "right" and -1 or 1 )
	end;
	i.setType = function( self, type )
		items[type] = self
		self.name = type
		self.itemName = type
		self:setData( game.data.Items[type] )
		if self.load then
			self:load( )
		end
	end
	i.setData = function( self, t )
		if not t["ItemData"] then return end
		local data = t.ItemData
		local env = { }
		env.item = self
		env.game = game
		setmetatable( env, { __index = getfenv( ) } )
		setfenv( data, env )
		data( )
	end
	return i
end

for k, v in pairs( game.data.Items ) do
	local i = game.engine.item.create( )
	i:setType( k )
end
