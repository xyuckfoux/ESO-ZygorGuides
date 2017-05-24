local ZGV = ZygorGuidesViewer	if not ZGV then return end
local Pointer = ZGV.Pointer	if not Pointer then return end

local arrowskindir,arrowskinlc,arrowskinname = "Stealth","stealth","Stealth"

local arrowframeproto = {}

local CHAIN=ZGV.Utils.ChainCall

local arrowskin = ZGV.Pointer:AddArrowSkin(arrowskinlc,arrowskinname)

arrowskin.features={colordist=false,smooth=true}

local sprite_angles_base = {[0]=0,0.5,1.1,2.6,4.5,6.9,9.7,13.0,16.7,20.8,25.3,30.1,35.3,40.7,46.4,52.4,58.7,65.2,71.9,78.8,85.9,93.1,100.5,108.1,115.7,123.5,131.4,139.4,147.4,155.5,163.6,168,173,180}
local sprite_angles={}

local min,max = math.min,math.max

DEBUGSPRITE1= sprite_angles_base
DEBUGSPRITE2= sprite_angles

local WM=WINDOW_MANAGER

function arrowskin:CreateFrame()
	if not self.frame then
		self.frame = CHAIN(ZGVArrowFrame)
			:SetDimensions(50,50)
			:SetHidden(false)
			:SetAnchor(TOP,GuiRoot,TOP,0,100)
			:SetMovable(true)
			:SetMouseEnabled(true)
			:SetHandler("OnUpdate",function(self,elapsed) end)
			.__END
		
		-- Have to inherit base to allow :Hide and :Show
		ZGV.UI:InheritClass(self.frame,"Base")

		self.frame.here = CHAIN(WM:CreateControl(self.frame:GetName().."_Here",self.frame,CT_LABEL))
			:SetFont("ZoFontGame")
			:SetColor(255,255,255,1)
			:SetDimensions(0,20)
			:SetAnchor(TOP,self.frame,TOP,0,0)
			:SetText("HERE")
		.__END

		-- Have to inherit base to allow :Hide and :Show
		ZGV.UI:InheritClass(self.frame.here,"Base")

		self.frame.arrow = CHAIN(WM:CreateControl(self.frame:GetName().."_Arrow", self.frame, CT_TEXTURE))
			:SetTexture("arrow.dds")
			:SetDrawLayer(DL_OVERLAY)
			:SetDrawLevel(1)
			:SetBlendMode(TEX_BLEND_MODE_ALPHA) -- 1 or 0
			:SetDimensions(50,50)
			:SetAnchor(TOP,self.frame,TOP,0,0)
			:SetHidden(true)
		.__END

		-- Have to inherit base to allow :Hide and :Show
		ZGV.UI:InheritClass(self.frame.arrow,"Base")	

		self.frame.spec = CHAIN(WM:CreateControl(self.frame:GetName().."_Spec", self.frame, CT_TEXTURE))
			:SetTexture("arrow.dds")
			:SetDrawLayer(DL_OVERLAY)
			:SetDrawLevel(2)
			:SetBlendMode(TEX_BLEND_MODE_ADD) -- 1 or 0
			:SetDimensions(50,50)
			:SetAnchor(TOP,self.frame,TOP,0,0)
			:SetAlpha(1.0)
			:SetHidden(true)
		.__END

		-- Have to inherit base to allow :Hide and :Show
		ZGV.UI:InheritClass(self.frame.spec,"Base")

		self.frame.title = CHAIN(WM:CreateControl(self.frame:GetName().."_Title",self.frame,CT_LABEL))
			:SetFont("ZoFontGame")
			:SetColor(255,255,255,1)
			:SetDimensions(300,60)
			:SetAnchor(TOP,self.frame,TOP,0,50)
			:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
			:SetText("TITLE")
		.__END

		-- Have to inherit base to allow :Hide and :Show
		ZGV.UI:InheritClass(self.frame.title,"Base")

	end

	self.frame.style = self.id

	for f,fu in pairs(arrowframeproto) do self.frame[f] = fu end

	if self.frame.OnLoad then self.frame:OnLoad() end

	return self.frame
end

function arrowframeproto:ShowText (title,dist,eta)
	self.stairs=false

	Pointer.ArrowFrame_Proto_ShowText(self)
	local disttxt = Pointer.ArrowFrame_Proto_GetDistTxt(self,dist)
	local etatxt = Pointer.ArrowFrame_Proto_GetETATxt(self,eta)

	local distcolor
	if type(dist)=="number" then
		--local perc=max(0,1-(dist/min(max(100,Pointer.initialdist or 0),500)))
		--local r,g,b = ZGV.gradient3(perc, 1.0,0.5,0.4, 1.0,0.9,0.5, 0.7,1.0,0.6, 0.7)
		local r,g,b=1,1,1
		distcolor = ("|c%02x%02x%02x"):format(r*255,g*255,b*255)
	else
		distcolor = "|cffff00"
	end

	self.title:SetText( (title and "|cffffff"..title.."|r\n" or "") .. (disttxt and distcolor..disttxt.."|r" or "") .. (etatxt or "") )
end


local function BetterTexCoord(obj,x,w,y,h)  -- aka  n,w,h
	if not h then  x,w,y,h=(x or 0),w,nil,y  y=math.floor(x/w)+1  x=(x%w)+1  end
	obj:SetTexCoord((x-1)/w,x/w,(y-1)/h,y/h)
end


------------ color
local ar,ag,ab = 0.60,0.60,0.60
local br,bg,bb = 0.95,0.95,0.95
local cr,cg,cb = 1.00,1.00,1.00

local msin,mcos,mabs,mfloor=math.sin,math.cos,math.abs,math.floor
local rad2deg = 180/math.pi

local mfloor=math.floor
local mround=zo_round

function arrowframeproto:OnLoad()
	local skindir = ZGV.DIR.."/Arrows/".. arrowskindir
	self.arrow:SetTexture(skindir.."/arrow.dds")
	self.spec:SetTexture(skindir.."/arrow-specular.dds")
	--self.arrow.arrspecular:SetTexture(true)
	--self.arrow.arrspecular:SetTexture(skindir.."\\arrow-specular",false)
	--self.arrow.arrspecular:SetDrawLayer("ARTWORK",2)
	self.arrow:Hide()
	self.spec:Hide()
	--self.special:SetTexture(skindir.."\\specials",false)
	--self.special:Hide()

	local spr_w,spr_h = 102,68
	local imgw,imgh = 1024,1024
	local w,h,inrow,total = spr_w/imgw,spr_h/imgh,mfloor(imgw/spr_w),mfloor(imgw/spr_w)*mfloor(imgh/spr_h)
	local step=360/total
	
	local TINY_TURNS = false

	self.SetAngle = function(self,angle)
		self.angle = angle
		angle=angle*rad2deg
		
		if TINY_TURNS then
			local frac_angle = angle%step
			
			if (angle<90 or angle>270) then
				if frac_angle>step*0.5 then frac_angle=frac_angle-step end
				local q=((angle<180) and angle or 360-angle)/180
				frac_angle=frac_angle*(1+q*0.7)
				
				frac_angle = frac_angle * (1+mcos(angle*2))/2
			else
				frac_angle=0
			end
			
			--self.turn.anim:SetRadians(frac_angle/rad2deg)  self.turn:Play()
		end
		
		--angle=(angle+(step/2))%360  -- shift step/2 forward
		local num = mround(angle/step)%total
		local row,col = mfloor(num/inrow),num%inrow
		self.arrow:SetTextureCoords(col*w,(col+1)*w,row*h,(row+1)*h)
		self.spec:SetTextureCoords(col*w,(col+1)*w,row*h,(row+1)*h)
		--self.arrspecular:SetAlpha(0.7)
	
		-- precision!
		if num==0 or num==1 or num==total-1 then
			if ZGV.db.profile.arrowcolordist then
				local r,g,b,a = 1,1,1,1 --self.arr:GetVertexColor()
				r = r + (1-r)*0.5
				g = g + (1-g)*0.5
				b = b + (1-b)*0.5
				self.arrow:SetVertexColors(15,r,g,b,a)
			else
				self.arrow:SetVertexColors(15,0.6,1.0,0.4,1.0)
				--self.arrspecular:SetAlpha(1.0)
			end
		end
		self.arrow:SetVertexColors(15,0.3,0.8,0.0,1.0)

	end
	self:Hide()
	--self.back:SetTexture(skindir.."\\shadow",false)
	--self.title:SetFont(ZGV.Font,9)
end

function arrowframeproto:OnUpdate (elapsed)
end

function arrowframeproto:ShowArrived()
	self.arrow:Hide()

	self.here:Show()
	--self.back:SetTexCoord(0,0,0,1,1,0,1,1)

	--self.arrow.upstairs:Stop()
	--self.arrow.downstairs:Stop()
end

function arrowframeproto:ShowNothing()
	self.arrow:Hide()
	self.here:Hide()
end

local precspan = 0.2

function arrowframeproto:ShowTraveling (elapsed,angle,dist)
	self.here:Hide()
	
	self.arrow:Show()
	self.spec:Show()
	--self.precise:Show()
	--self.title:Show()

	local profile=ZGV.db.profile

	local perc,tier

	local spangood,spanperf=0.10,0.02
	--if dist<500 then local mul=1-(dist/500)  mul=mul*mul*mul*mul*mul  spangood,spanperf = spangood+spangood*mul,spanperf+spanperf*mul  end

	Pointer.initialdist = Pointer.initialdist or dist

	perc = mabs(1-angle*0.3183)  -- 1/pi  ;  0=target backwards, 1=target ahead
	perc,tier = Pointer.CalculateDirectionTiers(perc,1-spangood,1-spangood+0.02,1-spanperf,1)

	--local r,g,b = ZGV.gradient3(perc, ar,ag,ab, br,bg,bb, cr,cg,cb, 1)
	--self.arrow:SetVertexColor(r,g,b)


	------------ rotation of elements

	self:SetAngle(angle)

	--[[
	if perc>0.5 and self.precise.turn then
		-- precision dot
		local precangle = angle
		if precangle>3.141592 then precangle=precangle-6.283185 end
		precangle = precangle * 8  -- precision!
		while precangle>6.283185 do precangle=precangle-6.283185 end
		while precangle<0 do precangle=precangle+6.283185 end

		self.precise:SetAlpha((perc-0.5)*4)
		self.precise.turn.anim:SetRadians(precangle)
		self.precise.turn:Play()
	else
		self.precise:SetAlpha(0)
	end
	--]]
end

function arrowframeproto:ShowStairs(up)
	self.precise:Hide()
	self.here:Hide()
	self.arrow:Show()
	if up then
		self.arrow.downstairs:Stop()
		self.arrow.upstairs:Play()
	else
		self.arrow.upstairs:Stop()
		self.arrow.downstairs:Play()
	end
end

function arrowframeproto:ShowWaiting(phase)
	self.precise:Show()
	self.here:Hide()
	self.arrow:Hide()
	self.precise:SetAlpha(1)
	self.precise.turn.anim:SetRadians(phase*6.28)
	self.precise.turn:Play()
end

function arrowframeproto:ShowWarning()
	UIFrameFlash(self.arrow,0.2,0.2,0.2, true,0,0)
end

function arrowframeproto:OnMouseWheel(delta)
	if IsControlKeyDown() then
		ZGV.db.profile.arrowscale = ZGV.db.profile.arrowscale + delta * 0.2
		if ZGV.db.profile.arrowscale<0.4 then ZGV.db.profile.arrowscale=0.4 end
		self:SetScale(ZGV.db.profile.arrowscale)
	end
end
--]]