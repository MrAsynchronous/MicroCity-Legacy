-- Queue
-- MrAsync
-- April 15, 2020


--[[

		Super simple queue class

]]


local Queue = {}
Queue.__index = Queue

--Queue object constructor
function Queue.new()
	local self = setmetatable({
		List = {} 
	}, Queue)

	return self
end


--Queues data at beginning of queue
function Queue:Enqueue(data)
	table.insert(self.List, 1, data)
end


--Removes and returns data at end of queue
function Queue:Dequeue()
	return table.remove(self.List, #self.List)
end


return Queue