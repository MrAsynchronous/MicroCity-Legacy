------------------------------------------------------------------------------------------------------------------
-- CFrameSerializer.lua
-- Written by CloneTrooper1019
-- @ 3/7/2019
------------------------------------------------------------------------------------------------------------------
-- Usage
--		string CFrameSerializer:EncodeCFrame(CFrame cf) < Compresses a CFrame into a JSON string.
--  	CFrame CFrameSerializer:DecodeCFrame(string cf) < Decompresses a JSON CFrame string.
------------------------------------------------------------------------------------------------------------------
-- Utility Functions
------------------------------------------------------------------------------------------------------------------

local function compressNumber(num)
	local floor = math.floor(num)
	if math.abs(num - floor) < 0.01 then
		return floor
	else
		return string.format("%.7f", num)
	end
end

local function compressNumbers(array)
	for k,v in pairs(array) do
		array[k] = compressNumber(v)
	end
	return array
end

local function isAxisAligned(cf)
	local matrix = { cf:GetComponents() }
	local s0, s1 = 0, 0
	
	for i = 4, 12 do
		local t = matrix[i]
		if t == -1 or t == 1 then
			s1 = s1 + 1
		elseif t == 0 or t == -0 then
			s0 = s0 + 1
		end
	end
	
	return (s0 == 6) and (s1 == 3)
end

local function toNormalId(vec)
	for _,normalId in pairs(Enum.NormalId:GetEnumItems()) do
		local normal = Vector3.FromNormalId(normalId)
		local dotProd = normal:Dot(vec)
		
		if dotProd == 1 then
			return normalId.Value
		end
	end
	
	return -1
end

local function legalOrientId(orientId)
	local xNormalAbs = math.floor(orientId / 6) % 3;
	local yNormalAbs = orientId % 3;
	
	return (xNormalAbs ~= yNormalAbs);
end

local function getOrientId(cf)
	if not isAxisAligned(cf) then
		return -1
	end
	
	local xNormal = toNormalId(cf.RightVector)
	local yNormal = toNormalId(cf.UpVector)
	
	local orientId = (6 * xNormal) + yNormal
	
	if not legalOrientId(orientId) then
		return -1
	end
	
	return orientId
end

local function toQuaternion(cf)
	local w, x, y, z
	
	local m11, m12, m13, m21, m22, m23, m31, m32, m33 = select(4, cf:GetComponents())
	local trace = m11 + m22 + m33
	
	if trace > 0 then
        local s = math.sqrt(1 + trace)
        local r = 0.5 / s

        w = s * 0.5;
        x = (m32 - m23) * r;
        y = (m13 - m31) * r;
        z = (m21 - m12) * r;
	else
		local big = math.max(m11, m22, m33)
		
		if big == m11 then
			local s = math.sqrt(1 + m11 - m22 - m33)
			local r = 0.5 / s
			
			w = (m32 - m23) * r;
			x = 0.5 * s;
			y = (m21 + m12) * r;
			z = (m13 + m31) * r;
		elseif big == m22 then
			local s = math.sqrt(1 - m11 + m22 - m33)
			local r = 0.5 / s
			
			w = (m13 - m31) * r;
			x = (m21 + m12) * r;
			y = 0.5 * s;
			z = (m32 + m23) * r;
		elseif big == m33 then
			local s = math.sqrt(1 - m11 - m22 + m33)
			local r = 0.5 / s
			
			w = (m21 - m12) * r;
			x = (m13 + m31) * r;
			y = (m32 + m23) * r;
			z = 0.5 * s;
		end
	end
	
	local result = { x, y, z, w }
	return compressNumbers(result)
end

------------------------------------------------------------------------------------------------------------------
-- Serializer
------------------------------------------------------------------------------------------------------------------

local CFrameSerializer = {}
local HttpService = game:GetService("HttpService")

function CFrameSerializer:EncodeCFrame(cf, raw)
	local pos = cf.Position
	local posTable = { pos.X, pos.Y, pos.Z }
	
	local serialCF = {}
	serialCF.p = compressNumbers(posTable)
	
	local orientId = getOrientId(cf)
	if orientId >= 0 then
		serialCF.o = orientId
	else
		serialCF.m = toQuaternion(cf)
	end
	
	if not raw then
		serialCF = HttpService:JSONEncode(serialCF)
	end
	
	return serialCF
end

function CFrameSerializer:EncodeCFrameForSaving(cf, raw)
	local pos = cf.Position
	local posTable = { pos.X, 0, pos.Z }
	
	local serialCF = {}
	serialCF.p = compressNumbers(posTable)
	
	local orientId = getOrientId(cf)
	if orientId >= 0 then
		serialCF.o = orientId
	else
		serialCF.m = toQuaternion(cf)
	end
	
	if not raw then
		serialCF = HttpService:JSONEncode(serialCF)
	end
	
	return serialCF
end

function CFrameSerializer:DecodeCFrame(cfJson, raw)
	local serialCF = raw and cfJson or HttpService:JSONDecode(cfJson)
	local pos = serialCF.p
	
	for i, comp in pairs(pos) do
		pos[i] = tonumber(comp)
	end
	
	if serialCF.m then
		local x, y, z = unpack(pos)
		local matrix = serialCF.m
		
		for k,v in pairs(matrix) do
			matrix[k] = tonumber(v)
		end
		
		return CFrame.new(x, y, z, unpack(matrix))
	elseif serialCF.o then
		local pos = Vector3.new(unpack(pos))
		local orientId = serialCF.o
		
		if legalOrientId(orientId) then
			local xn = orientId / 6
			local yn = orientId % 6
			
			local vx = Vector3.FromNormalId(xn)
			local vy = Vector3.FromNormalId(yn)
			
			return CFrame.fromMatrix(pos, vx, vy)
		end
	end
end

return CFrameSerializer

------------------------------------------------------------------------------------------------------------------