local ZGV = ZygorGuidesViewer
if not ZGV then return end

local tinsert,tremove,sort,min,max,floor,type,pairs,ipairs = table.insert,table.remove,table.sort,math.min,math.max,math.floor,type,pairs,ipairs
local print = ZGV.print

local Log = {}
ZGV.Log = Log

Log.entries = {}
Log.size = 100
Log.loud = false

-- Common functions
local GetTimeString = GetTimeString
local GetFrameTimeSeconds = GetFrameTimeSeconds
local GetFrameTimeMilliseconds = GetFrameTimeMilliseconds

function Log:SetSize(size)
	self.size = size
	self:Trim()
end

function Log:Trim()
	local len = #self.entries
	if len>self.size then
		for i=1,len-self.size,1 do
			tremove(self.entries,1)
		end
	end
end

function Log:Add(frm,...)
	local s = frm:format(...)

	local debugms = (GetFrameTimeMilliseconds()*1000)%1000
	local datestamp = ("%s.%03d.%03d"):format(GetTimeString(),(GetFrameTimeSeconds()%1)*1000,debugms)

	tinsert(self.entries, datestamp .. "> "..s)
	if #self.entries>self.size then
		tremove(self.entries,1)
	end
	if self.loud then
		print("|c8888ff".. datestamp ..">|r |cccccff"..s.."|r")
	end
end

function Log:Print(n)
	local len = #self.entries
	if not n or n>len then n=len end
	for i=len-n+1,len,1 do
		print(self.entries[i])
	end
end

function Log:Dump(n)
	local s = ""
	local len = #self.entries
	if not n or n>len then n=len end
	for i=len-n+1,len,1 do
		s = s .. self.entries[i] .. "\n"
	end
	return s
end