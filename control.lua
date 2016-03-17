require "defines"

DEBUG = true

--cheat sheet:
--glob reference point for the script stuff
--add item to back
--game.surfaces["nauvis"].find_entity("express-transport-belt",{140.5,160.5}).get_transport_line(1).insert_at_back({name ="express-transport-belt",count = 50})
--get_contents
--game.local_player.print(game.surfaces["nauvis"].find_entity("express-transport-belt",{140.5,160.5}).get_transport_line(1).get_contents())
--event bindings:

--splitter formats
FORMAT = {ROUND_ROBIN = 1, PRIORITY = 2 }
--LR needed?

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
--script.on_event(defines.events.on_tick, function(event) onTickEventHandler(event) end)
script.on_event(defines.events.on_built_entity, function(event) onBuiltEventHandler(event) end)
--script.on_event(defines.events.on_entity_died, function(event) onEntityDiedEventHandler(event) end)
--script.on_event(defines.events.on_preplayer_minded_item, function(event) onEntityMinedEventHandler(event) end)
--script.on_event(defines.events.on_robot_pre_mined, function(event) onEntityMinedEventHandler(event) end)
--script.on_event(defines.events.on_player_rotated_entity, function(event) onPlayerRotated(event) end)


function onInit(event)
--nothing major needed here hopefully
	global.splitters = global.splitters or {}
			script.on_event(defines.events.on_tick,function(event) onTickEventHandler(event) end)
			
end

    -- 0.1.2 method of handling the compound splitter
function handleSplitterBuffered(i)
	oC = (global.splitters[i].outformat == FORMAT.ROUND_ROBIN) and global.splitters[i].ouC or 1
	oE = 1
	cI = nil
	cS = nil

	bEi = global.splitters[i].buffer.get_inventory(1);
	bSize = bEi.get_item_count()
	
-- load leveling: divisor is # of items buffered per lane. stack size impacts how useful the buffer size is.
	u = (bSize / 10) + 1
	uC = 1
	-- uses first item found and assumes the rest of the chest has the same item.
	cI = next(bEi.get_contents())
	cS = {name=cI,count = 1}
	if (bSize > 0 ) then 
		repeat 
			if (global.splitters[i].outlines[oC].can_insert_at_back()) then
				if (bEi.remove(cS) == 1 ) then
					global.splitters[i].outlines[oC].insert_at_back(cS)
					uC = uC + 1
				else
				--early end
				oE = #global.splitters[i].outlines + 1
				end
				
			end
			
			oC = oC + 1
			oE = oE + 1
			
			if (oC > #global.splitters[i].outlines) then oC = 1 end
			
		until (uC >= u or oE > #global.splitters[i].outlines)
	end
	if (uC ~= 1 or bSize <400) then
		iC = (global.splitters[i].informat == FORMAT.ROUND_ROBIN) and global.splitters[i].inC or 1 
		iE = 1
		repeat 
			cI = next(global.splitters[i].inlines[iC].get_contents())
			if (cI ~= nil) then 
				cS = {name = cI, count = 1}
				if bEi.can_insert(cS) then
				--swap into buffer
					global.splitters[i].inlines[iC].remove_item(cS)
					bEi.insert(cS)
					bSize = bSize + 1
				else
				-- early exit
					iE = #global.splitters[i].inlines + 1
				end
			end
			iC = iC + 1
			iE = iE + 1
			if (iC > #global.splitters[i].inlines) then iC = 1 end--handle round robin array overflow
		until (bSize >=400 or iE > #global.splitters[i].inlines)
		global.splitters[i].inC = iC
	end

	global.splitters[i].ouC = oC
	--schedule next tick
	if (uC ~= 1) then 
		global.splitters[i].lastItemTick = game.tick
		global.splitters[i].nextTick = game.tick + 3
	else if ((game.tick - global.splitters[i].lastItemTick) > 300) then
			global.splitters[i].nextTick = game.tick + 60
		else
			global.splitters[i].nextTick = game.tick+9
		end
	end
	
	
end

	--the 0.0.1 method for splitter handling
function handleSplitter(i)
	iC = (global.splitters[i].informat == FORMAT.ROUND_ROBIN) and global.splitters[i].inC or 1 
	oC = (global.splitters[i].outformat == FORMAT.ROUND_ROBIN) and global.splitters[i].ouC or 1
	iE = 1
	oE = 1
	uC = 1
	j=false
	k=false
	repeat
	--important: {name = next(game.player.selected.get_transport_line(1).get_contents()), count = 1}
	-- find output lane to add item to
		if (global.splitters[i].outlines[oC].can_insert_at_back()==false) 
		then
			oC = oC + 1
			oE = oE + 1
		else j=true
		end
	-- find input lane to pull item from
		cI = next(global.splitters[i].inlines[iC].get_contents())
		if (cI == nil) then
			iC = iC + 1
			iE = iE + 1
		else k=true
		end
	--perform swap
		if j and k then 
			cS = {name = cI, count = 1}
			global.splitters[i].inlines[iC].remove_item(cS)
			global.splitters[i].outlines[oC].insert_at_back(cS)
			j = false
			k = false
			iC= iC + 1
			oC= oC + 1
			uC= uC + 1
		end
	if (iC > #global.splitters[i].inlines) then iC = 1 end
	if (oC > #global.splitters[i].outlines) then oC = 1 end

	until (iE > #global.splitters[i].inlines or oE > #global.splitters[i].outlines)
	global.splitters[i].inC = iC
	global.splitters[i].ouC = oC
	
		--schedule next tick
	if (uC ~= 1) then 
		global.splitters[i].lastItemTick = game.tick
		global.splitters[i].nextTick = game.tick + 3
	else if ((game.tick - global.splitters[i].lastItemTick) > 300) then
			global.splitters[i].nextTick = game.tick + 60
		else
			global.splitters[i].nextTick = game.tick+9
		end
	end
	

end

function onTickEventHandler(event)
	if game.tick % 3 ~= 0  then return end -- quick exit
	if #global.splitters == 0 then script.on_event(defines.events.on_tick, nil) end
	local i

	--loop splitters in global
	for i=1,#global.splitters,1 do
		
		if (global.splitters[i].nextTick <= game.tick) then	
			if pcall(handleSplitterBuffered, i) then
			--if (true) then handleSplitterBuffered(i)
				--no error
			else
				--derailed execution for a splitter, remove it.
				debugPrint("Splitter stopped working")
				table.remove(global.splitters,i)
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
	   local aEnt = event.created_entity --first endpiece
	   local bEnt
	   local lane = 0
	   local dir = 0
	   local search_dir = -1--actual cs direction will be perpendicular to this
	   local nEnt = nil
	   
	   for dir=1,7,2 do--find the adjoining lane piece. there should be only one of these.
			nEnt = aEnt.surface.find_entity("compound-splitter-lane",{aEnt.position.x+DV[dir].x,aEnt.position.y+DV[dir].y})
			if (nEnt~=nil and nEnt.valid) then
				lane=lane+1
				if (search_dir == -1) then search_dir = dir end
			end
	    end
	    if lane == 1 then --endpiece valid enough to continue.
			--debugPrint("endcap placed, looking for other endcap")
	    else
			debugPrint("orphan endpiece: no detected lanes")
			return
		end
	--find lane pieces
		local lanes = {}
		local i = 1
		local pEnt
		nEnt = aEnt.surface.find_entity("compound-splitter-lane",{aEnt.position.x+DV[search_dir].x,aEnt.position.y+DV[search_dir].y})
		while (nEnt~=nil and nEnt.valid) do
			pEnt = nEnt
			lanes[i] = nEnt
			i=i+1
		    nEnt = nEnt.surface.find_entity("compound-splitter-lane",{nEnt.position.x+DV[search_dir].x,nEnt.position.y+DV[search_dir].y})
	   	end
	--find other endpost
		if (pEnt ~= nil and pEnt.valid) then
			bEnt = pEnt.surface.find_entity("compound-splitter-buffer",{pEnt.position.x+DV[search_dir].x,pEnt.position.y+DV[search_dir].y})
			if (bEnt~=nil and bEnt.valid) then
				--debugPrint("endcap found, prospective splitter size: " .. #lanes)
			else
				--debugPrint("place other endcap")
				return				
			end

		end
	--find totems, should be two, one on each side of lanes, next to endcap
		local totemA1, totemA2, totemB1, totemB2
		--totemA1
		nEnt = aEnt.surface.find_entity("compound-splitter-round-robin-totem",{aEnt.position.x+DV[PERP[search_dir].a].x,aEnt.position.y+DV[PERP[search_dir].a].y})
		if (nEnt == nil) then 
			nEnt = aEnt.surface.find_entity("compound-splitter-priority-totem",{aEnt.position.x+DV[PERP[search_dir].a].x,aEnt.position.y+DV[PERP[search_dir].a].y})
		end
		if nEnt ~= nil and nEnt.valid then
			totemA1 = nEnt
		end
		--totemA2
		nEnt = aEnt.surface.find_entity("compound-splitter-round-robin-totem",{aEnt.position.x+DV[PERP[search_dir].b].x,aEnt.position.y+DV[PERP[search_dir].b].y})
		if (nEnt == nil) then 
			nEnt = aEnt.surface.find_entity("compound-splitter-priority-totem",{aEnt.position.x+DV[PERP[search_dir].b].x,aEnt.position.y+DV[PERP[search_dir].b].y})
		end
		if nEnt ~= nil and nEnt.valid then
			totemA2 = nEnt
		end
		--totemB1
		nEnt = bEnt.surface.find_entity("compound-splitter-round-robin-totem",{bEnt.position.x+DV[PERP[search_dir].a].x,bEnt.position.y+DV[PERP[search_dir].a].y})
		if (nEnt == nil) then 
			nEnt = bEnt.surface.find_entity("compound-splitter-priority-totem",{bEnt.position.x+DV[PERP[search_dir].a].x,bEnt.position.y+DV[PERP[search_dir].a].y})
		end
		if nEnt ~= nil and nEnt.valid then
			totemB1 = nEnt
		end
		--totemA2
		nEnt = bEnt.surface.find_entity("compound-splitter-round-robin-totem",{bEnt.position.x+DV[PERP[search_dir].b].x,bEnt.position.y+DV[PERP[search_dir].b].y})
		if (nEnt == nil) then 
			nEnt = bEnt.surface.find_entity("compound-splitter-priority-totem",{bEnt.position.x+DV[PERP[search_dir].b].x,bEnt.position.y+DV[PERP[search_dir].b].y})
		end
		if nEnt ~= nil and nEnt.valid then
			totemB2 = nEnt
		end
	--do we have two on one side, then error and return
		if (totemA1 ~= nil and totemA1.valid) and (totemB1 ~= nil and totemB1.valid) or
		   (totemA2 ~= nil and totemA2.valid) and (totemB2 ~= nil and totemB2.valid) then
			debugPrint("Invalid totem placement")
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
		local nPos = {x=(aEnt.position.x+DV[search_dir].x),y=(aEnt.position.y+DV[search_dir].y)}
		for i=1,#lanes,1 do
		--side 1
		nEnt = surface.find_entity("cs-express-transport-belt",{nPos.x+DV[PERP[search_dir].a].x,nPos.y+DV[PERP[search_dir].a].y})
		if (nEnt ~= nil and nEnt.valid) then 
			belts[1][j] = nEnt
			j=j+1
		end
		--side 2
		nEnt = surface.find_entity("cs-express-transport-belt",{nPos.x+DV[PERP[search_dir].b].x,nPos.y+DV[PERP[search_dir].b].y})
		if (nEnt ~= nil and nEnt.valid) then 
			belts[2][k] = nEnt
			k=k+1
		end
			nPos.x = nPos.x + DV[search_dir].x
			nPos.y = nPos.y + DV[search_dir].y
		end
		if #belts[1] > 0 and #belts[2] > 0 then
			--debugPrint("minimum belts found:")
		else
			debugPrint("missing an input or output belt")
			return
		end
	--find input and output sides
		nEnt = surface.find_entity("compound-splitter-lane", 
			{
				belts[1][1].position.x+
				DV[belts[1][1].direction+1].x,
				belts[1][1].position.y+
				DV[belts[1][1].direction+1].y
			})
		if (nEnt ~=nil and nEnt.valid) then
			input = 1
			output = 2
		else
			output = 1
			input = 2
		end
		debugPrint(#belts[input] .. "-" .. #belts[output].." compound splitter detected")
	-- determine order of belts in belts array compared to totems
		if (totem[1] ~= nil and totem[1].valid) and
		   (math.abs(totem[1].position.x-belts[1][1].position.x) <=1) and
		   (math.abs(totem[1].position.y-belts[1][1].position.y) <=1) then
		else
			for i=1, math.floor(#belts[1] / 2) do--swap belts[1]
				nEnt = belts[1][i]
				belts[1][i] = belts[1][#belts[1] - i + 1]
				belts[1][#belts[1] - i + 1] = nEnt
			end
		end
		if (math.abs(totem[2].position.x-belts[2][1].position.x) <=1) and
		   (math.abs(totem[2].position.y-belts[2][1].position.y) <=1) then
		else
			for i=1, math.floor(#belts[2] / 2) do--swap belts[2]
				nEnt = belts[2][i]
				belts[2][i] = belts[2][#belts[2] - i + 1]
				belts[2][#belts[2] - i + 1] = nEnt
			end			
		end		   
	--generate transportLane tables
		--input
		local beltsIn, beltsOut = {},{}
		i=1
		for j=1, #belts[input],1 do
			beltsIn[i] = belts[input][j].get_transport_line(1)
			i=i+1
			beltsIn[i] = belts[input][j].get_transport_line(2)
			i=i+1
		end
		--output
		i=1
		for j=1, #belts[output],1 do
			beltsOut[i] = belts[output][j].get_transport_line(1)
			i=i+1
			beltsOut[i] = belts[output][j].get_transport_line(2)
			i=i+1
		end
	-- add splitter to list of belts
		newSplitter = CreateNewSet()
		newSplitter.lanes = lanes
		newSplitter.inbelts = belts[input]
		newSplitter.outbelts = belts[output]
		newSplitter.outlines = beltsOut
		newSplitter.inlines = beltsIn
		newSplitter.endcap = aEnt
		newSplitter.buffer = bEnt
		newSplitter.totems = totem
		newSplitter.informat = totem[input].name == "compound-splitter-round-robin-totem" and FORMAT.ROUND_ROBIN or FORMAT.PRIORITY
		newSplitter.outformat = totem[output].name == "compound-splitter-round-robin-totem" and FORMAT.ROUND_ROBIN or FORMAT.PRIORITY
		newSplitter.bounds = 
		{
			{aEnt.position.x + DV[PERP[search_dir].a].x,aEnt.position.y + DV[PERP[search_dir].a].y},
			{bEnt.position.x + DV[PERP[search_dir].b].x,bEnt.position.y + DV[PERP[search_dir].b].y}
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
				inC = 1,
				ouC = 1,
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
