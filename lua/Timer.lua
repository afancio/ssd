-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2017 INPE and TerraLAB/UFOP -- www.terrame.org

-- This code is part of the TerraME framework.
-- This framework is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.

-- You should have received a copy of the GNU Lesser General Public
-- License along with this library.

-- The authors reassure the license terms regarding the warranties.
-- They specifically disclaim any warranties, including, but not limited to,
-- the implied warranties of merchantability and fitness for a particular purpose.
-- The framework provided hereunder is on an "as is" basis, and the authors have no
-- obligation to provide maintenance, support, updates, enhancements, or modifications.
-- In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
-- indirect, special, incidental, or consequential damages arising out of the use
-- of this software and its documentation.
--
-------------------------------------------------------------------------------------------


local function addFlowEvents(modelTimer)
    if (#ssdGlobals.__ssdTimer:getEvents() > 0) then
        forEachOrderedElement(ssdGlobals.__ssdTimer:getEvents(), function(idx, value, mtype)
            if mtype == "Event" then
                modelTimer:add(value)
            else
                incompatibleTypeError(idx, "Event", value)
            end
        end)
        --segunda possbilidade
        --                forEachElement(ssdGlobals.__ssdTimer:getEvents(), function(_, ev)
        --                    self:add(ev)
        --                end)

        --terceira possibilidade
        --        for idx, value in pairs(eventosTimer) do
        --            print(idx, value)
        --            self:add(value)
        --        end
    end

    ssdGlobals.__ssdTimer:clear()
    ssdGlobals.__ssdTimer:reset()
    return true
end

oldTimer_ = Timer_ --store old

Timer_ = {
	type_ = "Timer",
	--- Add a new Event to the timer. If the Event has a start time less than the current
	-- simulation time then add() will prompt a warning (but the Event will be added).
	-- @arg event An Event or table.
	-- When adding a table, this function converts the table into an Event.
	-- @usage timer = Timer{}
	--
	-- timer:add(Event{action = function() end})
	add = function(self, event)
		if type(event) == "table" then
			event = Event(event)
		end

		mandatoryArgument(1, "Event", event)

		if event.time < self.time then
			local msg = "Adding an Event with time ("..event.time..
				") before the current simulation time ("..self.time..")."
			customWarning(msg)
		end

		local pos = 1
		local evp = self.events[pos]
		local quant = #self.events
		local time = event.time
		local prio = event.priority
		while pos <= quant and (time > evp.time or (time == evp.time and prio >= evp.priority)) do
			pos = pos + 1
			evp = self.events[pos]
		end

		table.insert(self.events, pos, event)
		event.parent = self
	end,
	--- Remove all the Events from the Timer. Note that, when this function is called
	-- within an action of an Event, if such function does not return false, it
	-- will be added to the Timer again after the end of its execution. This
	-- means that the simulation will continue with a single Event until its final time.
	-- @usage timer = Timer{
	--     Event{action = function() print("step") end}
	-- }
	--
	-- timer:clear()
	clear = function(self)
		self.events = {}
	end,
	--- Return a vector with the Events of the Timer.
	-- @usage timer = Timer{
	--     Event{action = function() print("step") end}
	-- }
	--
	-- print(timer:getEvents()[1]:getTime())
	getEvents = function(self)
		return self.events
	end,
	--- Return the current simulation time.
	-- @usage timer = Timer{
	--     Event{action = function() print("step") end}
	-- }
	--
	-- timer:run(10)
	-- print(timer:getTime())
	getTime = function(self)
		return self.time
	end,
	--- Notify every Observer connected to the Timer.
	-- @usage timer = Timer{
	--     Event{action = function() print("step") end}
	-- }
	--
	-- Clock{target = timer}
	--
	-- timer:run(10)
	--
	-- timer:notify()
	notify = function(self)
		local modelTime = self:getTime()
		self.cObj_:notify(modelTime)
	end,
	--- Reset the Timer to time minus infinite, keeping the same Event queue.
	-- @usage timer = Timer{
	--     Event{action = function() print("step") end}
	-- }
	--
	-- Clock{target = timer}
	--
	-- timer:run(10)
	--
	-- timer:reset()
	-- print(timer:getTime())
	reset = function(self)
		self.time = -math.huge
	end,
	--- Run the Timer until a given final time. It manages the Event queue according to their execution
	-- times and priorities. The Event with lower time will be executed in each step. If there are two
	-- Events to be executed at the same time, it executes the one with lower priority. If both have
	-- the same priority, it executes the one that was scheuled first for that time.
	-- In order to activate an Event, the Timer executes its action, passing the Event itself as argument.
	-- If the action of the Event does not return false, the Event is scheduled to execute again according to
	-- its period. The Timer then repeats its execution again and again. It stops only when all its
	-- Events are scheduled to execute after the final time, or when there are no remaining Events.
	-- @arg finalTime A number representing the final time of the simulation.
	-- This argument is mandatory.
	-- @usage timer = Timer{
	--     Event{action = function() print("step") end}
	-- }
	--
	-- timer:run(10)
	run = function(self, finalTime)

		addFlowEvents(self)

		mandatoryArgument(1, "number", finalTime)

		if finalTime < self.time then
			local msg = "Simulating until a time ("..finalTime..
				") before the current simulation time ("..self:getTime()..")."
			customWarning(msg)
		end

		while true do
			if getn(self.events) == 0 then return end

			local ev = self.events[1]
			if ev.time > finalTime then
				self.time = finalTime
				return
			end

			self.time = ev.time

			table.remove(self.events, 1)

			local result = ev.action(ev, self)

			if result == false or ev.period == 0 then
				ev.parent = nil
			else
				ev.time = ev.time + ev.period

				local floor = math.floor(ev.time)
				local ceil = math.ceil(ev.time)

				if math.abs(ev.time - floor) < sessionInfo().round then
					ev.time = floor
				elseif math.abs(ev.time - ceil) < sessionInfo().round then
					ev.time = ceil
				end
				self:add(ev)
			end
		end
	end,

}

metaTableTimer_ = {
	__index = Timer_,
	__tostring = _Gtme.tostring,
	--- Return the number of Events in the Timer.
	-- @usage timer = Timer{
	--     Event{action = function()
	--         print("each time step")
	--     end},
	--     Event{period = 2, action = function()
	--         print("each two time steps")
	--     end}
	-- }
	--
	-- print(#timer)
	__len = function(self)
		return #self.events
	end
}

--- A Timer is an event-based scheduler that runs the simulation. It contains a
-- set of Events, allowing the simulation to work with processes that start
-- independently and act in different periodicities. As default, it execute the Events
-- in the order they were declared, but the arguments of Event (start, priority, and period)
-- can change this order. Once a Timer has a given simulation time, it ensures that all the
-- Events before that time were already executed. See Timer:run() for more details.
-- @arg data.... A set of Events.
-- @output cObj_ A pointer to a C++ representation of the Timer. Never use this object.
-- @output events An ordered vector with the Events.
-- @output time The current simulation time.
-- @usage timer = Timer{
--     Event{action = function()
--         print("each time step")
--     end},
--     Event{period = 2, action = function()
--         print("each two time steps")
--     end},
--     Event{priority = "high", period = 4, action = function()
--         print("each four time steps")
--     end}
-- }
--
-- timer:run(10)
function Timer(data)
	if type(data) ~= "table" then
		if data == nil then
			data = {}
		else
			customError(tableArgumentMsg())
		end
	end

	local cObj = TeTimer()

	local mdata = {
		events = {},
		time = -math.huge,
	}

	setmetatable(mdata, metaTableTimer_)

	forEachOrderedElement(data, function(idx, value, mtype)
		if mtype == "Event" then
			mdata:add(value)
		else
			incompatibleTypeError(idx, "Event", value)
		end
	end)

	mdata.cObj_ = cObj
	cObj:setReference(mdata)
	return mdata
end

