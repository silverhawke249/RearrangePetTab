local function setLabelColor()
	for i = 1, 12 do
		local thisButton = _G["CompanionButton"..i]
		local thisLabel = _G["CompanionButton"..i.."Label"]
		local pFrame = _G["PetPaperDollFrameCompanionFrame"]
		local hl, hr, ht, hb = thisButton:GetHitRectInsets()

		-- Lua error guard (why does Lua have no `continue` statement?)
		if thisLabel ~= nil then
			-- This entry is currently active
			if thisButton.active then
				thisLabel:SetFontObject(GameFontNormalHugeBlue)
			-- This entry is being moused over
			elseif thisButton:IsMouseOver(-ht, -hb, -hl, -hr) then
				thisLabel:SetFontObject(GameFontNormalHugeWhite)
			-- This entry is selected
			elseif thisButton.creatureID == (pFrame.mode == "CRITTER" and pFrame.idCritter or pFrame.idMount) then
				thisLabel:SetFontObject(GameFontNormalHugeWhite)
			-- Regular text
			else
				thisLabel:SetFontObject(GameFontNormalHuge)
			end
		end
	end
end

local function setButtonText()
	local pFrame = _G["PetPaperDollFrameCompanionFrame"]
	if pFrame.mode == "CRITTER" then
		PetNameText:SetText("Companions")
	elseif pFrame.mode == "MOUNT" then
		PetNameText:SetText("Mounts")
	end

	for i = 1, 12 do
		local companionName = GetSpellInfo(_G["CompanionButton"..i].spellID)
		local thisButton = _G["CompanionButton"..i]
		local thisLabel = _G["CompanionButton"..i.."Label"]

		thisLabel:Hide()
		thisLabel:SetText(companionName)
		if companionName then
			thisButton:SetHitRectInsets(0, -10 - thisLabel:GetStringWidth(), 0, 0)
		end
		thisLabel:Show()
	end

	setLabelColor()
end

local eventHandler = {}
eventHandler.PLAYER_ENTERING_WORLD = function()
	-- Hide UI elements
	CompanionModelFrame:Hide()
	CompanionSummonButton:Hide()
	CompanionSelectedName:Hide()
	for i = 1, PetPaperDollFrameCompanionFrame:GetNumRegions() do
		local region = select(i, PetPaperDollFrameCompanionFrame:GetRegions())
		if (region:GetObjectType() == "Texture") then
			region:Hide()
		end
	end

	local whiteFont = CreateFont("GameFontNormalHugeWhite")
	whiteFont:CopyFontObject(GameFontNormalHuge)
	whiteFont:SetTextColor(1, 1, 1, 1)

	local blueFont = CreateFont("GameFontNormalHugeBlue")
	blueFont:CopyFontObject(GameFontNormalHuge)
	blueFont:SetTextColor(106/255, 174/255, 242/255, 1)

	-- Enable mouse wheel input
	PetPaperDollFrameCompanionFrame:EnableMouseWheel(true)
	PetPaperDollFrameCompanionFrame:SetScript("OnMouseWheel", function(self, delta)
		if delta == 1 then
			CompanionPrevPageButton:Click()
		elseif delta == -1 then
			CompanionNextPageButton:Click()
		end
	end)

	for i = 1, 12 do
		local thisButton = _G["CompanionButton"..i]

		-- Hook scripts
		thisButton:HookScript("OnEnter", setLabelColor)
		thisButton:HookScript("OnLeave", setLabelColor)
		thisButton:HookScript("OnClick", setLabelColor)

		-- Move buttons
		thisButton:SetScale(0.65)
		if i == 1 then
			thisButton:SetPoint("TOPLEFT", PetPaperDollFrameCompanionFrame, "TOPLEFT", 45, -125)
		else
			thisButton:ClearAllPoints()
			thisButton:SetPoint("TOP", _G["CompanionButton"..(i-1)], "BOTTOM", 0, -4)
		end

		local label = thisButton:CreateFontString("CompanionButton"..i.."Label", "ARTWORK", "GameFontNormalHuge")
		label:SetPoint("LEFT", thisButton, "RIGHT", 10, 0)
	end

	-- Set background (unless ElvUI is active)
	if ElvUI == nil then
		local topLeft = PetPaperDollFrameCompanionFrame:CreateTexture(nil, "BACKGROUND")
		local topRight = PetPaperDollFrameCompanionFrame:CreateTexture(nil, "BACKGROUND")
		local bottomLeft = PetPaperDollFrameCompanionFrame:CreateTexture(nil, "BACKGROUND")
		local bottomRight = PetPaperDollFrameCompanionFrame:CreateTexture(nil, "BACKGROUND")

		topLeft:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft")
		topRight:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight")
		bottomLeft:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomLeft")
		bottomRight:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomRight")

		topLeft:SetPoint("TOPLEFT", PetPaperDollFrameCompanionFrame, "TOPLEFT", 0, 0)
		topRight:SetPoint("TOPLEFT", PetPaperDollFrameCompanionFrame, "TOPLEFT", 255, 0)
		bottomLeft:SetPoint("TOPLEFT", PetPaperDollFrameCompanionFrame, "TOPLEFT", 0, -255)
		bottomRight:SetPoint("TOPLEFT", PetPaperDollFrameCompanionFrame, "TOPLEFT", 255, -255)

		-- Why is it slightly off?
		CompanionPageNumber:SetPoint("CENTER", PetPaperDollFrameCompanionFrame, "CENTER", -13, -158)
	else
		CompanionPageNumber:SetPoint("CENTER", PetPaperDollFrameCompanionFrame, "CENTER", -13, -164)
	end

	-- Reparent window title (would probably break once battle pets are a thing)
	PetNameText:SetParent(PetPaperDollFrameCompanionFrame)

	-- Hook script
	PetPaperDollFrameCompanionFrame:HookScript("OnShow", setButtonText)
	PetPaperDollFrameTab2:HookScript("OnClick", setButtonText)
	PetPaperDollFrameTab3:HookScript("OnClick", setButtonText)
	CompanionPrevPageButton:HookScript("OnClick", setButtonText)
	CompanionNextPageButton:HookScript("OnClick", setButtonText)
end
eventHandler.COMPANION_UPDATE = setLabelColor
eventHandler.COMPANION_LEARNED = setButtonText
eventHandler.COMPANION_UNLEARNED = setButtonText

local function handleEvents(self, event, ...)
	if eventHandler[event] == nil then return end
	eventHandler[event](...)
end

if WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC then
	local f = CreateFrame("Frame")
	f:RegisterEvent("PLAYER_ENTERING_WORLD")
	f:RegisterEvent("COMPANION_UPDATE")
	f:RegisterEvent("COMPANION_LEARNED")
	f:RegisterEvent("COMPANION_UNLEARNED")
	f:SetScript("OnEvent", handleEvents)
end
