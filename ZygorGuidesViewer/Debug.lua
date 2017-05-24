local ZGV = ZGV
if not ZGV then return end

-----------------------------------------
-- LOCAL REFERENCES
-----------------------------------------

local tinsert,tremove,sort,min,max,floor,type,pairs,ipairs,class = table.insert,table.remove,table.sort,math.min,math.max,math.floor,type,pairs,ipairs,class
local print = ZGV.print
local L = ZGV.L

-----------------------------------------
-- LOCAL VARIABLES
-----------------------------------------

local debugcolor="|cff88dd"

local lastdate=0
local mscycle=0
local mscolors,mscolorsn={[0]="|cffcc00",[1]="|cffaa00"},2
local timecolor=mscolors[0]
local errorlog = ""

local blockedmsgs = {}

-----------------------------------------
-- LOCAL FUNCTIONS
-----------------------------------------

local flags = {}
-- Easy setting of flags
local function SetDebugFlags()
	flags = ZGV.sv and ZGV.sv.profile and ZGV.sv.profile.debug_flags or flags
	flags.quest = false
	flags.parser = false
	flags.viewer = false
	flags.goal = false
end

-----------------------------------------
-- DEBUG
-----------------------------------------

function ZGV:Debug (msg,...)
	if not msg or type(msg)~="string" then error("Debug msg type error") end
	SetDebugFlags()
	local flagsmsg

	while msg:sub(1,1)=="&" do
		local flag,rest = msg:match("^&([a-zA-Z0-9_]+)%s+(.*)$")
		if flag then
			local flagdata = flags[flag]
			if flagdata==false then return end -- otherwise assume it SET!
			if type(flagdata)=="table" and flagdata.color then flag = "|c"..flagdata.color..flag.."|r" end
			flagsmsg = (flagsmsg and (flagsmsg.." ") or "") .. "[" .. flag .. "]"

			msg = rest
		else
			msg="?"..msg:sub(2) -- failsafe, cut the & off
		end
	end

	if flagsmsg then msg = flagsmsg.." "..msg end
	local formatted_msg = string.format(tostring(msg),...) :gsub("|r",debugcolor)

	self.DebugI = (self.DebugI or 0) + 1
	local t = GetFrameTimeSeconds()
	local datestamp = ("%06.03f"):format(t%60)
	if t~=lastdate then
		mscycle=(mscycle+1)%mscolorsn
		lastdate=t
		timecolor=mscolors[mscycle]
	end
	local debugms = GetGameTimeMilliseconds() - t*1000

	local message = ("|cffee77Z|r: %s%s+%03d|r |c00ddbb#%d: %s%s"):format(timecolor,datestamp,debugms,self.DebugI,debugcolor,formatted_msg)

	if (not ZGV.blockdebug and self.sv and self.sv.profile and self.sv.profile.debug) or flags.forcedisplay or ZGV.DEV then
		print(message)
	else
		tinsert(blockedmsgs,message)
	end
	self.Log:Add("%s",formatted_msg)
end

-- Used in coroutines because they can't print
function ZGV:BlockDebugOutput()
	ZGV.blockdebug = true
end

function ZGV:UnBlockDebugOutput()
	ZGV.blockdebug = nil

	for i,msg in ipairs(blockedmsgs) do
		print(msg)
	end

	blockedmsgs = {}		-- TODO could wipe it instead. Meh
end

-----------------------------------------
-- PRINT
-----------------------------------------

function ZGV:Print(str,...)
	str = string.format(tostring(str),...)
	-- TODO
	print(L['name']..": "..str)
end

-----------------------------------------
-- ERROR
-----------------------------------------

function ZGV:Error(str,...)
	str = "|cff0000ERROR|r - "..str

	self:Print(str,...)
	self:Debug(str,...)		-- Eh send it there too
	errorlog = errorlog..str..'\n'
end

function ZGV:DumpErrorLog()
	if #errorlog<=0 then return end

	ZGV:Dump(errorlog)
end

-----------------------------------------
-- DUMP
-----------------------------------------

function ZGV:Dump(str,title)
	self.BugReport:ShowDump(str,title)
end
