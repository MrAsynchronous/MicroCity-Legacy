-- Visits Service
-- MrAsync
-- July 17, 2020



local VisitsService = {Client = {}}


local HttpService = game:GetService("HttpService")

local AWS_URI = "https://90c9c052t5.execute-api.us-east-2.amazonaws.com/default/getGameVisits"


function VisitsService:GetGameInfo()
    local data = HttpService:PostAsync({Url = AWS_URI}, "MrAsync")
    if (data.Success) then
        local body = HttpService:JSONDecode(data.Body);
        print(body.playing)
        print(body.visits)
    end
end


function VisitsService:Init()
	self:GetGameInfo()
end


return VisitsService