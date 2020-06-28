local ZERO = Vector3.new(0, 0, 0)

--

local AABB = {}
AABB.__index = AABB

--

local function vec3Compare(a, b, func)
	return Vector3.new(
		func(a.x, b.x),
		func(a.y, b.y),
		func(a.z, b.z)
	)
end

local function overlap(cfA, sizeA, cfB, sizeB)
	local rbCF = cfA:inverse() * cfB
	local A = AABB.fromPositionSize(ZERO, sizeA)
	local B = AABB.fromPositionSize(rbCF.p, AABB.worldBoundingBox(rbCF, sizeB))
	
	local union = A:Union(B)
	local area = union and union.Max - union.Min or ZERO
	
	return area.x*area.y*area.z
end

local function worldBoundingBox(cf, size)
	local size2 = size/2;
	
	local c1 = cf:VectorToWorldSpace(Vector3.new(size2.x, size2.y, size2.z))
	local c2 = cf:VectorToWorldSpace(Vector3.new(-size2.x, size2.y, size2.z))
	local c3 = cf:VectorToWorldSpace(Vector3.new(-size2.x, -size2.y, size2.z))
	local c4 = cf:VectorToWorldSpace(Vector3.new(-size2.x, -size2.y, -size2.z))
	local c5 = cf:VectorToWorldSpace(Vector3.new(size2.x, -size2.y, -size2.z))
	local c6 = cf:VectorToWorldSpace(Vector3.new(size2.x, size2.y, -size2.z))
	local c7 = cf:VectorToWorldSpace(Vector3.new(size2.x, -size2.y, size2.z))
	local c8 = cf:VectorToWorldSpace(Vector3.new(-size2.x, size2.y, -size2.z))
	
	local max = Vector3.new(
		math.max(c1.x, c2.x, c3.x, c4.x, c5.x, c6.x, c7.x, c8.x),
		math.max(c1.y, c2.y, c3.y, c4.y, c5.y, c6.y, c7.y, c8.y),
		math.max(c1.z, c2.z, c3.z, c4.z, c5.z, c6.z, c7.z, c8.z)
	)
	
	local min = Vector3.new(
		math.min(c1.x, c2.x, c3.x, c4.x, c5.x, c6.x, c7.x, c8.x),
		math.min(c1.y, c2.y, c3.y, c4.y, c5.y, c6.y, c7.y, c8.y),
		math.min(c1.z, c2.z, c3.z, c4.z, c5.z, c6.z, c7.z, c8.z)
	)
	
	return max - min
end

--

function AABB.new(a, b)
	local self = setmetatable({}, AABB)
	
	self.Min = vec3Compare(a, b, math.min)
	self.Max = vec3Compare(a, b, math.max)
	
	return self
end

function AABB.fromPositionSize(pos, size)
	return AABB.new(pos + size/2, pos - size/2)
end

AABB.worldBoundingBox = worldBoundingBox
AABB.overlap = overlap

--

function AABB:Intersects(aabb)
	local aMax, aMin = self.Max, self.Min
	local bMax, bMin = aabb.Max, aabb.Min
	
	if (bMin.x > aMax.x) then return false end
	if (bMin.y > aMax.y) then return false end
	if (bMin.z > aMax.z) then return false end
	if (bMax.x < aMin.x) then return false end
	if (bMax.y < aMin.y) then return false end
	if (bMax.z < aMin.z) then return false end
	
	return true
end

function AABB:Union(aabb)
	if (not self:Intersects(aabb)) then
		return nil
	end
	
	local min = vec3Compare(aabb.Min, self.Min, math.max)
	local max = vec3Compare(aabb.Max, self.Max, math.min)
	
	return AABB.new(min, max)
end

--

return AABB