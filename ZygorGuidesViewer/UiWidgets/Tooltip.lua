local ZGV = ZGV
if not ZGV then return end
-----------------------------------------
-- INFORMATION
-----------------------------------------
--[[
	
--]]

-----------------------------------------
-- LOCAL REFERENCES
-----------------------------------------

local tinsert,tremove,sort,zginherits,min,max,floor,type,pairs,ipairs,unpack = table.insert,table.remove,table.sort,table.zginherits,math.min,math.max,math.floor,type,pairs,ipairs,unpack
local CHAIN = ZGV.Utils.ChainCall
local print = ZGV.print
local ui = ZGV.UI

-----------------------------------------
-- LOCAL VARIABLES
-----------------------------------------

local Tooltip =  ZGV.Class:New("Tooltip")

local headerFont = ui:GetFont(14,true)
local HEADER_COLOR = {1,1,1}

local lineFont = ui:GetFont(13)
local LINE_COLOR = {1,1,1}

-----------------------------------------
-- LOAD TIME SETUP
-----------------------------------------

ui:RegisterWidget("Tooltip",Tooltip)

-----------------------------------------
-- TOOLTIP FUNCTIONS
-----------------------------------------

function Tooltip:New(parent,name)
	local tooltipFrame = CreateControlFromVirtual(name.."_BaseFrame",parent,"TooltipTopLevel")	-- TopLevel control. Needed to show tooltips
	local tooltip = CHAIN(ui:CreateControlFromVirtual(name,tooltipFrame,"ZO_BaseTooltip",Tooltip))	-- Create Tooltip
		:SetResizeToFitPadding(20,15)
	.__END
	tooltip:GetChild(1):SetHidden(true)	-- Hide their backdrop >:D

	tooltip.parent = tooltipFrame

	-- Our backdrop.
	tooltip.bd = ui:Create("Backdrop",tooltip,name and name.."_BD")

	return tooltip
end


function Tooltip:AddHeader(text)
	if not text then return end
	local line = 1
	local r,g,b = unpack(HEADER_COLOR)
	--self:AddHeaderLine(text,headerFont,line,TOOLTIP_HEADER_SIDE_LEFT,r,g,b)
	-- TODO can't use HeaderLine because it sets the tooltip to full width which is not desired.
	-- TODO can't left align the header because it doesn't work without the last argument, which sets it to full width : /
	self:savedAddLine(text,headerFont,r,g,b)--,TEXT_ALIGN_LEFT,MODIFY_TEXT_TYPE_NONE,TEXT_ALIGN_LEFT,true)
end

function Tooltip:AddLine(text)
	if not text then return end
	local r,g,b = unpack(LINE_COLOR)
	self:savedAddLine(text,lineFont,r,g,b)--,LEFT,MODIFY_TEXT_TYPE_NONE,TEXT_ALIGN_LEFT,true)
end

-- Overwrite show/hide to hide the parent with the tooltip
function Tooltip:Show()
	--self:SetWidth(0)

	self:SetHidden(false)
	self.parent:SetHidden(false)
end

function Tooltip:Hide()
	self:SetHidden(true)
	self.parent:SetHidden(true)
end

-----------------------------------------
-- INHERITANCE
-----------------------------------------

ui:InheritClass(Tooltip,"Backdrop")
