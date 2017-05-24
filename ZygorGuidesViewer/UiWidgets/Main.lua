local ZGV = ZygorGuidesViewer
if not ZGV then return end

-----------------------------------------
-- LOCAL REFERENCES
-----------------------------------------

local tinsert,tremove,sort,zginherits,min,max,floor,type,pairs,ipairs = table.insert,table.remove,table.sort,table.zginherits,math.min,math.max,math.floor,type,pairs,ipairs
local print = ZGV.print
local WM = ZGV.WM

-----------------------------------------
-- LOCAL VARIABLES
-----------------------------------------

local UI = {}
local savedwidgets = {}
local Classes = {}						-- Not available in UI

local FontGName = "ZygorFont"--..size..Reg/Bold
local FONT = ZGV.DIR.."/Viewer/opensans.ttf"
local BOLD = ZGV.DIR.."/Viewer/opensansb.ttf" 
local extras = "soft-shadow-thin"

local REG_FONTS = {}
local BOLD_FONTS = {}

-- TODO don't actually do anything with the font.. Just create it because all SetFont functions just want the global name. So use that.
local makeFont = function(size,font)
	size = floor(size)	-- Only integers work.
	local fontName = FontGName..tostring(size)..(font==FONT and "Reg" or "Bold")
	local fontString = font.."|"..size.."|"..extras
	
	local font = CreateFont(fontName,fontString)

	return fontName
end


-----------------------------------------
-- LOAD TIME SETUP
-----------------------------------------

setmetatable(REG_FONTS, { __index = function(me,size) 
	local fname = makeFont(size,FONT)
	me[size] = fname
	return fname
end })

setmetatable(BOLD_FONTS, { __index = function(me,size) 
	local fname = makeFont(size,BOLD)
	me[size] = fname
	return fname
end })

-----------------------------------------
-- SAVED REFERENCES
-----------------------------------------

ZGV.UI = UI
UI.Classes = Classes
UI.savedwidgets = savedwidgets

-----------------------------------------
-- CREATE FUNCTIONS
-----------------------------------------

--[[
	Returns a widget of type uiType
	@param uiType - String of the type of widget
	@param parent - parent of the widget. Can also be set later
	@param name - Global name of the widget if possible.
--]]
function UI:Create(uiType,parent,name,...)
	assert(type(uiType)=="string", "uiType must be a string not - "..type(uiType))
	assert(type(parent)=="userdata", "All UI element must be parented to another UI element.")
	assert(type(name)=="string", "All UI elements must have a name")
	
	local widgetClass = Classes[uiType]
	assert(widgetClass and widgetClass.New, uiType.." is not a valid ui type.") 

	local newWidget = widgetClass:New(parent,name,...)

	-- Widgets are sorted in this table by class so that later we can change themes easy.
	if not savedwidgets[uiType] then 
		savedwidgets[uiType] = {} 
	end
	tinsert(savedwidgets[uiType],newWidget)
	
	-- If the class isn't the same then inherit the class. Example is dropdown
	if newWidget.class ~= uiType then
		self:InheritClass(newWidget,widgetClass,1)
	end

	return newWidget
end

-- Used instead of calling WM:CreateControl directly so that inheritance can happen eariler.
function UI:CreateControl(name,parent,ct_type,class)
	local control = WM:CreateControl(name,parent,ct_type)

	-- Inherit all functions from the Base class because everyone gets those functions.
	self:InheritClass(control,"Base")

	-- Inherit all functions from the widget's class
	self:InheritClass(control,class)

	return control
end

-- Used instead of calling WM:CreateControl directly so that inheritance can happen eariler.
function UI:CreateControlFromVirtual(name,parent,virt,class)
	local control = WM:CreateControlFromVirtual(name,parent,virt)

	-- Inherit all functions from the Base class because everyone gets those functions.
	self:InheritClass(control,"Base")

	-- Inherit all functions from the widget's class
	self:InheritClass(control,class)

	return control
end

-----------------------------------------
-- HELPER FUNCTIONS
-----------------------------------------

--[[
	Register each widget so they are available in one place for use.
	@param name - Name used when attempting to create the widget.
	@param widgetProto - Object handler with a :New
	@param widgetObj - The actual widget object
--]]
function UI:RegisterWidget(name,widgetProto,widgetObj)
	widgetObj = widgetObj or widgetProto
	if not (name and widgetObj) then return end

	Classes[name] = widgetObj
end

--[[
	Copies all functions from the class into object
	@param obj - Where are we copying things too
	@param class - Class object or a string
--]]
function UI:InheritClass(obj,class,force)
	local classobj = type(class) == "string" and Classes[class] or class
	assert(classobj, tostring(class).." - Class does not exist")

	zginherits(obj,classobj)

	-- zginherits doesn't overwrite class, but sometimes it is needed
	if force then
		obj.class = classobj.class
	end
end

-----------------------------------------
-- FONT HELPERS
-----------------------------------------

function UI:GetFont(size,bold)
	local fonts = bold and BOLD_FONTS or REG_FONTS
	local font = fonts[size]
	assert(font, (bold and "Bold " or "").."Font size["..size.."] not available atm. Make it. It is easy.")

	return font
end

-----------------------------------------
-- OLD
-----------------------------------------

--[[
	At startup this is used to add some zgv specific functions to the metatables of various UI elements.
	Only needs to be done once because those metatables are used for all elements of that type.
	@param table - table of functions to add
	@param ctype - Type of control we are modifiying
--]]
-- Note this sticks our functions in ZOS's metatables, for EVERYONE to see. Not ideal and is phased out now
--[[
function UI:AddToControlMetatable(table,ctype)
	local control = WM:CreateControl(nil,GuiRoot,ctype)
	local meta = getusermetatable(control)

	zginherits(table,self:GetClass("Base"))		-- Add these to the table, all UI elements get these

	for f,fun in pairs(table) do
		-- inherit any function in there.
		if type(fun) == "function" then
			if meta.f then
				assert(not meta.f, f.." is already in this control.. Can't overwrite it")
				-- TODO maybe we hook it?
				break
			else
				meta[f]=fun
			end
		end
	end
end
--]]
--[[

function buildframestart()

	BuildFrame = CHAIN(ZGV.UI:Create("Frame",GuiRoot,"Build"))
			:SetPoint(CENTER)
			:SetSize(250,100)
	.__END

	CHAIN(ui:Create("Button",BuildFrame,"hi"))
		:SetPoint(TOPRIGHT)
		:SetPerfectSizing(true)
		:SetText("Hi")
		--:SetBackdropColor(unpack(butColor))

end

tinsert(ZGV.startups,function(self)
	buildframestart()
end)
--]]
