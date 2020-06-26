local StackTemplate = {}

function StackTemplate:Push(value)
	table.insert(self.queue, value)
end

function StackTemplate:Pop()
	return table.remove(self.queue, self:Length())
end

function StackTemplate:Front()
	return self.queue[#self.queue]
end

function StackTemplate:Back()
	return self.queue[1]
end

function StackTemplate:Length()
	return #self.queue
end

local StackMetatable = {}
StackMetatable.__index = StackMetatable

local Stack = {}

Stack.new = function(list)
	return setmetatable({
		stack = list or {}
	}, StackMetatable)
end

return Stack
