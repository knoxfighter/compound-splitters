--require "defines"
--0.13 no longer requires this define...

DEBUG = true

--splitter formats
FORMAT = {ROUND_ROBIN = 1, PRIORITY = 2 }

--vectors
DV = 
{
{x= 0, y=-1},--index one
{x= 1, y=-1},
{x= 1, y= 0},
{x= 1, y= 1},
{x= 0, y= 1},
{x=-1, y= 1},
{x=-1, y= 0},
{x=-1, y=-1}
}
--   -
--x -0+
--   +
--   y

--opposite direction
OPP = {4,5,6,7,0,1,2,3}
--perpendicular directions based on input direction
PERP = {
		{a=3,b=7},--index one
		{a=4,b=8},
		{a=5,b=1},
		{a=6,b=2},
		{a=7,b=3},
		{a=8,b=4},
		{a=1,b=5},
		{a=2,b=6}
	   }

script.on_init(function(event) onInit() end)
script.on_load(function(event) onInit() end)
script.on_event(defines.events.on_built_entity, function(event) onBuiltEventHandler(event) end)
script.on_event(defines.events.on_entity_died, function(event) HandleRemovedFromGame(event) end)
script.on_event(defines.events.on_preplayer_mined_item, function(event) HandleRemovedFromGame(event) end)
script.on_event(defines.events.on_robot_pre_mined, function(event) HandleRemovedFromGame(event) end)

script.on_configuration_changed( 
function(data)
	if data.mod_changes ~= nil and data.mod_changes["My Mod"] ~= nil and data.mod_changes["My Mod"].new_version == "0.1.4" then
	--I don't know how "My Mod" referred to this mod in specific
	--recipes changes in 0.1.4
		recipes["cs-express-transport-belt"].reload()
		recipes["compound-splitter-endcap"].reload()
		recipes["compound-splitter-lane"].reload()
		recipes["compound-splitter-priority-totem"].reload()
		recipes["compound-splitter-round-robin-totem"].reload()
		recipes["compound-splitter-buffer"].reload()
	end
end
)


function onInit(event)
	global.splitters = global.splitters or {}
			script.on_event(defines.events.on_tick,function(event) onTickEventHandler(event) end)
			
end

    -- 0.1.2 method of handling the compound splitter
function handleSplitterBuffered(index)
	local outputTransportLine = (global.splitters[index].outformat == FORMAT.ROUND_ROBIN) and global.splitters[index].outputLineCounter or 1
	local inputTransportLine = nil
	local linesChecked = 1
	local currentItemType = nil
	local currentStack = nil

	local bufferInventory = global.splitters[index].buffer.get_inventory(1);
	local bufferSize = bufferInventory.get_item_count()
	
-- load leveling: divisor is # of items buffered per lane. stack size impacts how useful the buffer size is.
	local itemsToOutput = (bufferSize / 10) + 1
	local itemsOutputtedCounter = 1
	-- uses first item found and assumes the same item will be used for the rest of the function.
	local currentItemType = next(bufferInventory.get_contents())
	local currentStack = {name=currentItemType,count = 1}
	
--place items on output belts until buffer empty, load leveling conditions met, or 1 complete cycle of the output belts made.	
	if (bufferSize > 0 ) then 
		repeat 
			if (global.splitters[index].outlines[outputTransportLine].can_insert_at_back()) then
				if (bufferInventory.remove(currentStack) == 1 ) then
					global.splitters[index].outlines[outputTransportLine].insert_at((1-0.000001),currentStack)--13.3 workaround 2nd try
					itemsOutputtedCounter = itemsOutputtedCounter + 1
				else
				--buffer emptied during loop, end early
				linesChecked = #global.splitters[index].outlines + 1
				end
				
			end
			
			outputTransportLine = outputTransportLine + 1
			linesChecked = linesChecked + 1
			
			if (outputTransportLine > #global.splitters[index].outlines) then outputTransportLine = 1 end
			
		until (itemsOutputtedCounter >= itemsToOutput or linesChecked > #global.splitters[index].outlines)
	end
--try to fill buffer from input belts until buffer full or a complete cycle is made
	if (itemsOutputtedCounter ~= 1 or bufferSize <960) then
		inputTransportLine = (global.splitters[index].informat == FORMAT.ROUND_ROBIN) and global.splitters[index].inputLineCounter or 1 
		linesChecked = 1
		repeat 
			currentItemType = next(global.splitters[index].inlines[inputTransportLine].get_contents())
			if (currentItemType ~= nil) then 
				currentStack = {name = currentItemType, count = 1}
				if bufferInventory.can_insert(currentStack) and not global.splitters[index].inlines[inputTransportLine].can_insert_at(0.0001) then
				--swap into buffer
					global.splitters[index].inlines[inputTransportLine].remove_item(currentStack)
					bufferInventory.insert(currentStack)
					bufferSize = bufferSize + 1
				else
				-- buffer filled during loop, early end
					linesChecked = #global.splitters[index].inlines + 1
				end
			end
			inputTransportLine = inputTransportLine + 1
			linesChecked = linesChecked + 1
			if (inputTransportLine > #global.splitters[index].inlines) then inputTransportLine = 1 end--handle round robin array overflow
		until (bufferSize >=960 or linesChecked > #global.splitters[index].inlines)
		global.splitters[index].inputLineCounter = inputTransportLine
	end

	global.splitters[index].outputLineCounter = outputTransportLine
	--schedule next tick
	if (uC ~= 1) then 
		global.splitters[index].lastItemTick = game.tick
		global.splitters[index].nextTick = game.tick + 3
	else if ((game.tick - global.splitters[index].lastItemTick) > 300) then
			global.splitters[index].nextTick = game.tick + 60
		else
			global.splitters[index].nextTick = game.tick+9
		end
	end
end

function onTickEventHandler(event)
	if game.tick % 3 ~= 0  then return end -- quick exit
	if #global.splitters == 0 then script.on_event(defines.events.on_tick, nil) end
	local index

	--loop splitters in global
	for index=1,#global.splitters,1 do
		
		if (global.splitters[index].nextTick <= game.tick) then	
			if pcall(handleSplitterBuffered, index) then
			--if (true) then handleSplitterBuffered(index)
				--no error
			else
				--derailed execution for a splitter, remove it.
				debugPrint("Splitter stopped working")
				table.remove(global.splitters,index)
				return
			end
		end
	end
end


--OnBuiltEventHandler
--if an endcap is placed, the event will check to see if it's a completed 
function onBuiltEventHandler(event)
	--figuring out if we have a complete compound entity
	--in this initial version, we are ignoring robot placement which requires being able to build the compound entity in any order
	--if endcap is placed, check the cardinal adjacent squares for the lane piece.
	--there should be: 1 lane-piece (compound-splitter-lane) adjacent to this endcap
	--if there is only one lane piece, we can determine direction to look for continuing lane pieces
	--there should be up to 2 totems adjacent to the endcap and 'lane 1' that run perpendicular to the middle piece
	--'walk' down the line of middle lane entities to find the buffer and totems attached to it.
	--examine the 'above and below' positions to find belts and determine 'direction' above and below becomes in/out lanes
	--grab the transport-lanes of each belt and store them in array of in/outlanes
	--
	if event.created_entity.name == "compound-splitter-endcap" then
	   local surface = event.created_entity.surface
	   local endcap = event.created_entity --first endpiece
	   local buffer = nil
	   local foundLanePieces = 0
	   local dir = 0
	   local search_dir = -1--actual cs direction will be perpendicular to this
	   local currentEntity = nil
	   
	   for dir=1,7,2 do--find the adjoining lane piece. there should be only one of these.
			currentEntity = endcap.surface.find_entity("compound-splitter-lane",{endcap.position.x+DV[dir].x,endcap.position.y+DV[dir].y})
			if (currentEntity~=nil and currentEntity.valid) then
				foundLanePieces=foundLanePieces+1
				if (search_dir == -1) then search_dir = dir end
			end
	    end
	    if foundLanePieces == 1 then --endpiece valid enough to continue.
			--debugPrint("endcap placed, looking for other endcap")
	    else
			debugPrint("orphan endpiece: no detected lanes")
			return
		end
	--find lane pieces
		local lanes = {}
		local i = 1
		local potentialEndcap
		currentEntity = endcap.surface.find_entity("compound-splitter-lane",{endcap.position.x+DV[search_dir].x,endcap.position.y+DV[search_dir].y})
		while (currentEntity~=nil and currentEntity.valid) do
			potentialEndcap = currentEntity
			lanes[i] = currentEntity
			i=i+1
		    currentEntity = currentEntity.surface.find_entity("compound-splitter-lane",{currentEntity.position.x+DV[search_dir].x,currentEntity.position.y+DV[search_dir].y})
	   	end
	--find the chest to be used (buffer, or smart-buffer)
		if (potentialEndcap ~= nil and potentialEndcap.valid) then
			--buffer = potentialEndcap.surface.find_entities_filtered({area = {{potentialEndcap.position.x+DV[search_dir].x-.5,potentialEndcap.position.y+DV[search_dir].y-.5},{potentialEndcap.position.x+DV[search_dir].x+.5,potentialEndcap.position.y+DV[search_dir].y+.5}}, type="container"})[1]
			--potential way to allow any chest become a buffer, add 2nd  search to allow logistic-container types too
			
			--buffer = potentialEndcap.surface.find_entity("compound-splitter-buffer",{potentialEndcap.position.x+DV[search_dir].x,potentialEndcap.position.y+DV[search_dir].y})
			if (buffer~=nil and buffer.valid) then
				--debugPrint("endcap found, prospective splitter size: " .. #lanes)
			else
				
			end

		end
	--find totems, should be two or less, one on each side of lanes, next to endcap
		local totemA1, totemA2, totemB1, totemB2
		--totemA1
		currentEntity = endcap.surface.find_entity("compound-splitter-round-robin-totem",{endcap.position.x+DV[PERP[search_dir].a].x,endcap.position.y+DV[PERP[search_dir].a].y})
		if (currentEntity == nil) then 
			currentEntity = endcap.surface.find_entity("compound-splitter-priority-totem",{endcap.position.x+DV[PERP[search_dir].a].x,endcap.position.y+DV[PERP[search_dir].a].y})
		end
		if currentEntity ~= nil and currentEntity.valid then
			totemA1 = currentEntity
		end
		--totemA2
		currentEntity = endcap.surface.find_entity("compound-splitter-round-robin-totem",{endcap.position.x+DV[PERP[search_dir].b].x,endcap.position.y+DV[PERP[search_dir].b].y})
		if (currentEntity == nil) then 
			currentEntity = endcap.surface.find_entity("compound-splitter-priority-totem",{endcap.position.x+DV[PERP[search_dir].b].x,endcap.position.y+DV[PERP[search_dir].b].y})
		end
		if currentEntity ~= nil and currentEntity.valid then
			totemA2 = currentEntity
		end
		--totemB1
		currentEntity = buffer.surface.find_entity("compound-splitter-round-robin-totem",{buffer.position.x+DV[PERP[search_dir].a].x,buffer.position.y+DV[PERP[search_dir].a].y})
		if (currentEntity == nil) then 
			currentEntity = buffer.surface.find_entity("compound-splitter-priority-totem",{buffer.position.x+DV[PERP[search_dir].a].x,buffer.position.y+DV[PERP[search_dir].a].y})
		end
		if currentEntity ~= nil and currentEntity.valid then
			totemB1 = currentEntity
		end
		--totemA2
		currentEntity = buffer.surface.find_entity("compound-splitter-round-robin-totem",{buffer.position.x+DV[PERP[search_dir].b].x,buffer.position.y+DV[PERP[search_dir].b].y})
		if (currentEntity == nil) then 
			currentEntity = buffer.surface.find_entity("compound-splitter-priority-totem",{buffer.position.x+DV[PERP[search_dir].b].x,buffer.position.y+DV[PERP[search_dir].b].y})
		end
		if currentEntity ~= nil and currentEntity.valid then
			totemB2 = currentEntity
		end
	--do we have two on one side, then error and return
		if (totemA1 ~= nil and totemA1.valid) and (totemB1 ~= nil and totemB1.valid) or
		   (totemA2 ~= nil and totemA2.valid) and (totemB2 ~= nil and totemB2.valid) then
			debugPrint("Invalid totem placement: only 1 totem per side")
			return
		else
			--debugPrint("valid totem placement")
		end
		local totem = {}
		totem[1] = totemA1 or totemB1
		totem[2] = totemA2 or totemB2
	--find belts1 belts2
		local belts = {}
		belts[1] = {}
		belts[2] = {}

		local input, output
		i = 1
		local j,k = 1,1
		local currentPosition = {x=(endcap.position.x+DV[search_dir].x),y=(endcap.position.y+DV[search_dir].y)}
		for i=1,#lanes,1 do
			--side 1
			currentEntity = surface.find_entity("cs-express-transport-belt",{currentPosition.x+DV[PERP[search_dir].a].x,currentPosition.y+DV[PERP[search_dir].a].y})
			if (currentEntity ~= nil and currentEntity.valid) then 
				belts[1][j] = currentEntity
				j=j+1
			end
			--side 2
			currentEntity = surface.find_entity("cs-express-transport-belt",{currentPosition.x+DV[PERP[search_dir].b].x,currentPosition.y+DV[PERP[search_dir].b].y})
			if (currentEntity ~= nil and currentEntity.valid) then 
				belts[2][k] = currentEntity
				k=k+1
			end
			currentPosition.x = currentPosition.x + DV[search_dir].x
			currentPosition.y = currentPosition.y + DV[search_dir].y
		end
		if #belts[1] > 0 and #belts[2] > 0 then
			--debugPrint("minimum belts found:")
		else
			debugPrint("missing an input or output belt")
			return
		end
	--find input and output belt sides
		currentEntity = surface.find_entity("compound-splitter-lane", 
			{
				belts[1][1].position.x+
				DV[belts[1][1].direction+1].x,
				belts[1][1].position.y+
				DV[belts[1][1].direction+1].y
			})
		if (currentEntity ~=nil and currentEntity.valid) then
			input = 1
			output = 2
		else
			output = 1
			input = 2
		end
		debugPrint(#belts[input] .. "-" .. #belts[output].." compound splitter detected")
	-- determine order of belts in belts array compared to totems
		local currentBelt
		if (totem[1] ~= nil and totem[1].valid) and
		   (math.abs(totem[1].position.x-belts[1][1].position.x) <=1) and
		   (math.abs(totem[1].position.y-belts[1][1].position.y) <=1) then
		else
			for currentBelt=1, math.floor(#belts[1] / 2) do--swap belts[1]
				currentEntity = belts[1][currentBelt]
				belts[1][currentBelt] = belts[1][#belts[1] - currentBelt + 1]
				belts[1][#belts[1] - currentBelt + 1] = currentEntity
			end
		end
		if (totem[2] ~= nil and totem[2].valid) and
		  (math.abs(totem[2].position.x-belts[2][1].position.x) <=1) and
		    (math.abs(totem[2].position.y-belts[2][1].position.y) <=1) 
				then
				--nothing?
				else
					for currentBelt=1, math.floor(#belts[2] / 2) do--swap belts[2]
						currentEntity = belts[2][currentBelt]
						belts[2][currentBelt] = belts[2][#belts[2] - currentBelt + 1]
						belts[2][#belts[2] - currentBelt + 1] = currentEntity
					end			
		end		   
	--generate transportLane tables
		--input
		local beltsIn, beltsOut = {},{}
		local count=1

		for currentBelt=1, #belts[input],1 do
			beltsIn[count] = belts[input][currentBelt].get_transport_line(1)
			count=count+1
			beltsIn[count] = belts[input][currentBelt].get_transport_line(2)
			count=count+1
		end
		--output
		count=1
		for currentBelt=1, #belts[output],1 do
			beltsOut[count] = belts[output][currentBelt].get_transport_line(1)
			count=count+1
			beltsOut[count] = belts[output][currentBelt].get_transport_line(2)
			count=count+1
		end
	-- add splitter to list of belts
		newSplitter = CreateNewSet()
		newSplitter.lanes = lanes
		newSplitter.inbelts = belts[input]
		newSplitter.outbelts = belts[output]
		newSplitter.outlines = beltsOut
		newSplitter.inlines = beltsIn
		newSplitter.endcap = endcap
		newSplitter.buffer = buffer
		newSplitter.totems = totem
		newSplitter.informat = (totem[input] ~= nil and totem[input].name == "compound-splitter-priority-totem" and FORMAT.PRIORITY) or FORMAT.ROUND_ROBIN 
		newSplitter.outformat = (totem[output] ~= nil and totem[output].name == "compound-splitter-priority-totem" and FORMAT.PRIORITY) or FORMAT.ROUND_ROBIN
		newSplitter.bounds = 
		{
			{endcap.position.x + DV[PERP[search_dir].a].x,endcap.position.y + DV[PERP[search_dir].a].y},
			{buffer.position.x + DV[PERP[search_dir].b].x,buffer.position.y + DV[PERP[search_dir].b].y}
		}
		newSplitter.surface = surface
		newSplitter.nextTick = game.tick
		newSplitter.lastItemTick = game.tick
		
		if #global.splitters == 0 then
			script.on_event(defines.events.on_tick,function(event) onTickEventHandler(event) end)
			global.gNext = game.tick
		end
		
	table.insert(global.splitters,newSplitter)

	
	--debugPrint("spliter added to global.splitters")
	
	end
end

--function to see if a removed entity is part of a compound splitter
--parameters:
-- entity- the entity that triggered the game event
-- index- an index  for global.splitters

function IsPartOfSplitter(entity,index)
    if entity.name == "compound-splitter-endcap" then
		return global.splitters[index].endcap == entity
	end	
    if entity.name == "compound-splitter-lane" then
		for currentLane=1, #global.splitters[index].lanes,1 do
			if global.splitters[index].lanes[currentLane] == entity then 
				return true 
			end
		end
		return false
	end	
    if entity.name == "compound-splitter-priority-totem" or 
	   entity.name == "compound-splitter-round-robin-totem" then
		return global.splitters[index].totems[1] == entity or global.splitters[index].totems[2] == entity
	end
 
 
	return false
 end
 
 function HandleRemovedFromGame(event)
	--quickly determine if we need to check this entity out in detail
	--all entities for this mod have a prefix of compound-splitter
	--containers are handled by the ontick event
	entity = event.entity
	if (string.find(entity.name,"compound-splitter",1,true) == nil) then 
		return
	end
	for index=1,#global.splitters,1 do
		
		if (IsPartOfSplitter(entity,index)) then	
				debugPrint("Component Removed")
				table.remove(global.splitters,index)
				return
			end
		end
	end

function CreateNewSet()
	return {	
				lanes = {},
				inbelts = {},
				outbelts = {},
				outlines = {},
				inlines = {},
				endcap = nil,--
				buffer = nil,
				totems = {},
				informat = nil,
				outformat = nil,
				bounds = {},--table of two positions
				surface = nil,
				inputLineCounter = 1,
				outputLineCounter = 1,
				nextTick = nil,
				lastItemTick = nil
		   }
end

--test function to destroy entities in a table
function testDestroy(items)
--valid checks if entity referenced was destroyed after scripting last manipulated items
for i,v in ipairs(items) do if (v~= nil and v.valid) then v.destroy() end end

end

function debugPrint(message)
	if DEBUG then
		for i=1,#game.players,1 do
			game.players[i].print("Compound Splitters: " .. message)
		end
	end
end
