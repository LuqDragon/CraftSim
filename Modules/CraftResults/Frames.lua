AddonName, CraftSim = ...

CraftSim.CRAFT_RESULTS.FRAMES = {}

function CraftSim.CRAFT_RESULTS.FRAMES:UpdateRecipeData(recipeID)
    local craftResultFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.CRAFT_RESULTS)

    CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID] = CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID] or CopyTable(CraftSim.CRAFT_RESULTS.baseRecipeEntry)

    local recipeCraftData = CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID]
    local statistics = recipeCraftData.statistics
    -- statistics
    local statisticsText = ""
    local expectedAverageProfit = CraftSim.UTIL:FormatMoney(0, true)
    local actualAverageProfit = CraftSim.UTIL:FormatMoney(0, true)
    if statistics.crafts > 0 then
        expectedAverageProfit = CraftSim.UTIL:FormatMoney((statistics.totalExpectedAverageProfit / statistics.crafts) or 0, true)
        actualAverageProfit = CraftSim.UTIL:FormatMoney((recipeCraftData.profit / statistics.crafts) or 0, true)
    end
    local actualProfit = CraftSim.UTIL:FormatMoney(recipeCraftData.profit, true)
    statisticsText = statisticsText .. "Crafts: " .. statistics.crafts .. "\n\n"
    statisticsText = statisticsText .. "Expected Ø Profit: " .. expectedAverageProfit .. "\n"
    statisticsText = statisticsText .. "Actual Ø Profit: " .. actualAverageProfit .. "\n"
    statisticsText = statisticsText .. "Actual Profit: " .. actualProfit .. "\n\n"
    statisticsText = statisticsText .. "Proccs:\n\n"

    if statistics.inspiration then
        statisticsText = statisticsText .. "Inspiration: " .. statistics.inspiration .. "\n"
    end
    if statistics.multicraft then
        statisticsText = statisticsText .. "Multicraft: " .. statistics.multicraft .. "\n"
        local averageExtraItems = CraftSim.UTIL:round(( statistics.multicraft > 0 and (statistics.multicraftExtraItems / statistics.multicraft)) or 0, 2)
        statisticsText = statisticsText .. "- Ø Extra Items: " .. averageExtraItems .. "\n"
    end
    if statistics.resourcefulness then
        statisticsText = statisticsText .. "Resourcefulness: " .. statistics.resourcefulness .. "\n"
    end

    craftResultFrame.content.statisticsText:SetText(statisticsText)
end

function CraftSim.CRAFT_RESULTS.FRAMES:Init()
    local frameNO_WO = CraftSim.FRAME:CreateCraftSimFrame(
        "CraftSimCraftResultsFrame", "CraftSim Crafting Results", 
        ProfessionsFrame.CraftingPage,
        ProfessionsFrame.CraftingPage.CraftingOutputLog, "TOPLEFT", "TOPLEFT", 0, 10, 700, 450, CraftSim.CONST.FRAMES.CRAFT_RESULTS, false, true, "FULLSCREEN", "modulesCraftResults")

    local function createContent(frame)
        -- Tracker

        frame.content.totalProfitAllTitle = CraftSim.FRAME:CreateText("Session Profit", frame.content, frame.content, 
        "TOP", "TOP", 140, -60, nil, nil, {type="H", value="LEFT"})
        frame.content.totalProfitAllValue = CraftSim.FRAME:CreateText(CraftSim.UTIL:FormatMoney(0, true), frame.content, frame.content.totalProfitAllTitle, 
        "TOPLEFT", "BOTTOMLEFT", 0, -5, nil, nil, {type="H", value="LEFT"})
    

        frame.content.clearButton = CraftSim.FRAME:CreateButton("Reset Data", frame.content, frame.content.totalProfitAllTitle, "TOPLEFT", "BOTTOMLEFT", 
        0, -40, 15, 25, true, function() 
            CraftSim.CRAFT_RESULTS:ResetData()
            frame.content.resultFrame.resultFeed:SetText("")
            frame.content.craftedItemsFrame.resultFeed:SetText("")
            frame.content.totalProfitAllValue:SetText(CraftSim.UTIL:FormatMoney(0, true))
            CraftSim.CRAFT_RESULTS.FRAMES:UpdateRecipeData(CraftSim.MAIN.currentRecipeData.recipeID)
        end)

        -- craft results
        frame.content.scrollFrame, frame.content.resultFrame = CraftSim.FRAME:CreateScrollFrame(frame.content, -50, 20, -350, 250)

        frame.content.craftsTitle = CraftSim.FRAME:CreateText("Craft Log", frame.content, frame.content.scrollFrame, "BOTTOM", "TOP", 0, 0)

        -- always scroll down on new craft
        frame.content.scrollFrame:HookScript("OnScrollRangeChanged", function() 
            frame.content.scrollFrame:SetVerticalScroll(frame.content.scrollFrame:GetVerticalScrollRange())
        end)

        frame.content.resultFrame.resultFeed = CraftSim.FRAME:CreateText("", frame.content.resultFrame, frame.content.resultFrame, 
            "TOPLEFT", "TOPLEFT", 10, -10, nil, nil, {type="H", value="LEFT"})
            frame.content.resultFrame.resultFeed:SetWidth(frame.content.resultFrame:GetWidth() - 5)
        frame.content.resultFrame.resultFeed:SetText("")

        frame.content.scrollFrame2, frame.content.craftedItemsFrame = CraftSim.FRAME:CreateScrollFrame(frame.content, -230, 20, -350, 20)

        frame.content.craftedItemsTitle = CraftSim.FRAME:CreateText("Crafted Items", frame.content, frame.content.scrollFrame2, "BOTTOM", "TOP", 0, 0)

        frame.content.craftedItemsFrame.resultFeed = CraftSim.FRAME:CreateText("", frame.content.craftedItemsFrame, frame.content.craftedItemsFrame, 
        "TOPLEFT", "TOPLEFT", 10, -10, nil, nil, {type="H", value="LEFT"})

        frame.content.statisticsTitle = CraftSim.FRAME:CreateText("Recipe Statistics", frame.content, frame.content.craftedItemsTitle, "LEFT", "RIGHT", 270, 0)
        frame.content.statisticsText = CraftSim.FRAME:CreateText("Nothing crafted yet!", frame.content, frame.content.statisticsTitle, "TOPLEFT", "BOTTOMLEFT", -70, -10, nil, nil, {type="H", value="LEFT"})
        frame.content.statisticsText:SetWidth(300)
    end

    createContent(frameNO_WO)
    CraftSim.FRAME:EnableHyperLinksForFrameAndChilds(frameNO_WO)
end

function CraftSim.CRAFT_RESULTS.FRAMES:UpdateItemList()
    local craftResultFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.CRAFT_RESULTS)
    -- total items
    local craftedItems = CraftSim.CRAFT_RESULTS.sessionData.total.craftedItems

    local craftedItemsText = ""
    for itemLink, count in pairs(craftedItems) do
        craftedItemsText = craftedItemsText .. count .. " x " .. itemLink .. "\n"
    end

    craftResultFrame.content.craftedItemsFrame.resultFeed:SetText(craftedItemsText)

    -- for recipe.. ?
end