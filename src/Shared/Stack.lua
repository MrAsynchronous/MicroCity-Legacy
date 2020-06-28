local Stack = {}
Stack.__index = Stack

function Stack:Push(value)
	table.insert(self.stack, value)
end

function Stack:Pop()
	return table.remove(self.stack)
end

function Stack:Front()
	return self.stack[self:Length()]
end

function Stack:Back()
	return self.stack[1]
end

function Stack:Length()
	return #self.stack
end

function Stack.new(list)
	return setmetatable({
		stack = list or {}
	}, Stack)
end

return Stack