-- Lua Height widget
--
--
--
-- widget display groessen
-- 3x3 Raster = 256x78
-- 3x1 = 256x294
-- 3x2 = 256x132
-- 2x2 = 388x132
-- 2x1 = 388x294
-- 1x2 = 784x132
-- 1x1 = 784x294
-- full 800x458
--

local locales = require("includes.locales") -- Importiere die Sprachvariablen

local scriptVersion = "1.4.0" -- Version des Skripts
local supportedLocales = {"de", "en"} -- Liste der unterstützten Sprachen

local hedline = locales.hedline
local waitForStart = locales.waitForStart
local menuL = locales.menuL
local configStgR = locales.configStgR
local configStgRmin = locales.configStgRmin
local configResetSwitch = locales.configResetSwitch
local configMenuSwitch = locales.configMenuSwitch
local configPlayValue = locales.configPlayValue
local LastMenuL = locales.LastMenuL
local mainMenuL = locales.mainMenuL
local headHistory = locales.headHistory
local headHistoryPath = locales.headHistoryPath
local needSup = locales.needSup
local helpWindow = locales.helpWindow
local help1 = locales.help1
local help2 = locales.help2
local help3 = locales.help3
local help4 = locales.help4
local help5 = locales.help5
local ignoreHeight = locales.ignoreHeight
local delLast = locales.delLast
local menuSwitch = "Default"
local HistoryMenu = 0
local soundPlayed = 0



local function create()
    return {
        value=nil,
        menuSw = nil, 
        SteigrateActive = 800, 
        SteigrateMin = 200, 
        wHeightReset = nil, 
        modelName = model.name();
    }
    
end

local function isLocaleSupported(locale, locales)
    for _, value in ipairs(locales) do
        if value == locale then
            return true
        end
    end
    return false
end
-- Überprüfen, ob locale unterstützt wird
if not isLocaleSupported(locale, supportedLocales) then
    locale = "en" -- Fallback auf "en", wenn locale nicht unterstützt wird
end

local function deleteLastLine(filePathDelete)
    -- Datei öffnen und alle Zeilen lesen
    local lines = {}
    local file, err = io.open(filePathDelete, "r")
    if not file then
        print("Datei konnte nicht geöffnet werden:", err)
        return
    end

    -- Datei Zeile für Zeile lesen
    while true do
        local success, line = pcall(function() return file:read("*l") end) -- Liest eine Zeile ohne Zeilenumbruch
        if not success or not line then
            break -- Beende die Schleife, wenn ein Fehler auftritt oder das Ende der Datei erreicht ist
        end
        table.insert(lines, line)
    end
    file:close()

    -- Entferne die letzte Zeile
    if #lines > 0 then
        table.remove(lines, #lines)
    else
        print("Datei ist leer, keine Zeile zu löschen.")
        return
    end

    -- Datei überschreiben ohne die letzte Zeile
    file, err = io.open(filePathDelete, "w")
    if not file then
        print("Fehler beim Schreiben der Datei:", err)
        return
    end

    for index, line in ipairs(lines) do
        file:write(line) -- Schreibe die Zeile
        if index < #lines then
            file:write("\n") -- Füge nur zwischen den Zeilen einen Zeilenumbruch hinzu
        end
    end
    file:close()
    print("Letzte Zeile erfolgreich gelöscht.")
end

local function name(widget)
    locale = system.getLocale()
    -- Prüfen, ob locale unterstützt wird
    if not isLocaleSupported(locale, supportedLocales) then
        locale = "en" -- Fallback auf "en"
    end
    return hedline[locale]
end

local function reverseTable(tbl)
    local reversed = {}
    for i = #tbl, 1, -1 do
        table.insert(reversed, tbl[i])
    end
    return reversed
end

local function paint(widget)
    local w, h = lcd.getWindowSize()
    -- Widget größe bestimmen und anpassen
    local lcdBorder = 2
    local text_w, text_h = lcd.getTextSize("")
    local widgetSizeType = nil
    local calcSteigrateMin = widget.SteigrateMin /100
    local calcSteigrateActive = widget.SteigrateActive /100
    local filePath = widget.modelName.."-startheight.txt"
    local entries = {}
    -- Datei öffnen
    local file = io.open(filePath, "r")
    if file then
        while true do
            local success, line = pcall(function() return file:read("L") end) -- Liest eine Zeile
            if not success or not line then
                break -- Beende die Schleife, wenn ein Fehler auftritt oder das Ende der Datei erreicht ist
            end
            table.insert(entries, line) -- Zeile zur Liste hinzufügen
        end
        file:close()
    else
        print("Datei konnte nicht geöffnet werden:", filePath)
    end
    -- Einträge umkehren, damit der letzte zuerst angezeigt wird
    entries = reverseTable(entries)

    if HistoryMenu == 1 then
        
        menuSwitch = mainMenuL[locale]

        

        if w <= 256 and h <= 78 
        then 
            widgetSizeType = "3x3"
            lcd.font(FONT_S_BOLD)        
            lcd.drawText(lcdBorder, lcdBorder, headHistory[locale], LEFT)
            lcd.font(FONT_S)
            -- Debug-Ausgabe der Einträge
            if #entries == 0 then
                lcd.font(FONT_S_BOLD)
                print("Keine Daten vorhanden")
                lcd.drawText(lcdBorder, text_h+5, "Keine Daten vorhanden", LEFT)
            else
                lcd.font(FONT_S)
                local y = text_h -- Startposition für die Anzeige auf dem LCD
                for _, entry in ipairs(entries) do
                    lcd.drawText(lcdBorder, y, entry, LEFT)
                    y = y + text_h+1 -- Abstand zwischen den Zeilen
                end
            end

            
        elseif w <= 256 and h <= 132 then 
            widgetSizeType = "3x2"
            lcd.font(FONT_S_BOLD)        
            lcd.drawText(lcdBorder, lcdBorder, headHistory[locale], LEFT)
            lcd.font(FONT_S)
            -- Debug-Ausgabe der Einträge
            if #entries == 0 then
                lcd.font(FONT_S_BOLD)
                print("Keine Daten vorhanden")
                lcd.drawText(lcdBorder, text_h+5, "Keine Daten vorhanden", LEFT)
            else
                lcd.font(FONT_S)
                local y = text_h -- Startposition für die Anzeige auf dem LCD
                for _, entry in ipairs(entries) do
                    lcd.drawText(lcdBorder, y, entry, LEFT)
                    y = y + text_h+1 -- Abstand zwischen den Zeilen
                end
            end
            
        elseif w <= 256 and h <= 294 then 
            widgetSizeType = "3x1"
            lcd.font(FONT_S_BOLD)        
            lcd.drawText(lcdBorder, lcdBorder, headHistory[locale], LEFT)
            lcd.font(FONT_S)
            -- Debug-Ausgabe der Einträge
            if #entries == 0 then
                lcd.font(FONT_S_BOLD)
                print("Keine Daten vorhanden")
                lcd.drawText(lcdBorder, text_h+5, "Keine Daten vorhanden", LEFT)
            else
                lcd.font(FONT_S)
                local y = text_h -- Startposition für die Anzeige auf dem LCD
                for _, entry in ipairs(entries) do
                    lcd.drawText(lcdBorder, y, entry, LEFT)
                    y = y + text_h+1 -- Abstand zwischen den Zeilen
                end
            end
            
        elseif w <= 388 and h <= 132 then 
            widgetSizeType = "2x2"
            lcd.font(FONT_L_BOLD)        
            lcd.drawText(lcdBorder, lcdBorder, headHistory[locale], LEFT)
            lcd.font(FONT_BOLD)-- Debug-Ausgabe der Einträge
            if #entries == 0 then
                lcd.font(FONT_L_BOLD)
                print("Keine Daten vorhanden")
                lcd.drawText(lcdBorder, text_h+5, "Keine Daten vorhanden", LEFT)
            else
                lcd.font(FONT_BOLD)
                local y = text_h+5 -- Startposition für die Anzeige auf dem LCD
                for _, entry in ipairs(entries) do
                    lcd.drawText(lcdBorder, y, entry, LEFT)
                    y = y + text_h + 1 -- Abstand zwischen den Zeilen
                end
            end
            
        elseif w <= 388 and h <= 294 then 
            widgetSizeType = "2x1"
            lcd.font(FONT_L_BOLD)        
            lcd.drawText(lcdBorder, lcdBorder, headHistory[locale], LEFT)
            lcd.font(FONT_BOLD)
            -- Debug-Ausgabe der Einträge
            if #entries == 0 then
                lcd.font(FONT_L_BOLD)
                print("Keine Daten vorhanden")
                lcd.drawText(lcdBorder, text_h+5, "Keine Daten vorhanden", LEFT)
            else
                lcd.font(FONT_BOLD)
                local y = text_h+5 -- Startposition für die Anzeige auf dem LCD
                for _, entry in ipairs(entries) do
                    lcd.drawText(lcdBorder, y, entry, LEFT)
                    y = y + text_h + 1 -- Abstand zwischen den Zeilen
                end
            end
            
        elseif w <= 784 and h <= 132 then 
            widgetSizeType = "1x2"
            lcd.font(FONT_L_BOLD)        
            lcd.drawText(lcdBorder, lcdBorder, headHistory[locale], LEFT)
            lcd.font(FONT_BOLD)
            -- Debug-Ausgabe der Einträge
            if #entries == 0 then
                lcd.font(FONT_L_BOLD)
                print("Keine Daten vorhanden")
                lcd.drawText(lcdBorder, text_h+5, "Keine Daten vorhanden", LEFT)
            else
                lcd.font(FONT_BOLD)
                local y = text_h+5 -- Startposition für die Anzeige auf dem LCD
                for _, entry in ipairs(entries) do
                    lcd.drawText(lcdBorder, y, entry, LEFT)
                    y = y + text_h + 1 -- Abstand zwischen den Zeilen
                end
            end
            
        elseif w <= 784 and h <= 294 then 
            widgetSizeType = "1x1"
            lcd.font(FONT_L_BOLD)        
            lcd.drawText(lcdBorder, lcdBorder, headHistory[locale], LEFT)
            lcd.font(FONT_BOLD)
            

            -- Debug-Ausgabe der Einträge
            if #entries == 0 then
                lcd.font(FONT_L_BOLD)
                print("Keine Daten vorhanden")
                lcd.drawText(lcdBorder, text_h+5, "Keine Daten vorhanden", LEFT)
            else
                lcd.font(FONT_BOLD)
                local y = text_h+5 -- Startposition für die Anzeige auf dem LCD
                for _, entry in ipairs(entries) do
                    lcd.drawText(lcdBorder, y, entry, LEFT)
                    y = y + text_h + 1 -- Abstand zwischen den Zeilen
                end
            end
            
        elseif w <= 800 and h <= 458 then 
            widgetSizeType = "full"
            lcd.font(FONT_L_BOLD)        
            lcd.drawText(lcdBorder, lcdBorder, headHistory[locale], LEFT)
            lcd.font(FONT_BOLD)
            

            -- Debug-Ausgabe der Einträge
            if #entries == 0 then
                lcd.font(FONT_L_BOLD)
                print("Keine Daten vorhanden")
                lcd.drawText(lcdBorder, text_h+5, "Keine Daten vorhanden", LEFT)
            else
                lcd.font(FONT_BOLD)
                local y = text_h+5 -- Startposition für die Anzeige auf dem LCD
                for _, entry in ipairs(entries) do
                    lcd.drawText(lcdBorder, y, entry, LEFT)
                    y = y + text_h + 1 -- Abstand zwischen den Zeilen
                end
            end
            
        else 
            widgetSizeType = "Default"
            lcd.font(FONT_L_BOLD)        
            lcd.drawText(lcdBorder, lcdBorder, headHistory[locale], LEFT)
            lcd.font(FONT_BOLD)
            

            -- Debug-Ausgabe der Einträge
            if #entries == 0 then
                lcd.font(FONT_L_BOLD)
                print("Keine Daten vorhanden")
                lcd.drawText(lcdBorder, text_h+5, "Keine Daten vorhanden", LEFT)
            else
                lcd.font(FONT_BOLD)
                local y = text_h+5 -- Startposition für die Anzeige auf dem LCD
                for _, entry in ipairs(entries) do
                    lcd.drawText(lcdBorder, y, entry, LEFT)
                    y = y + text_h + 1 -- Abstand zwischen den Zeilen
                end
            end
            
        end
        
    else
        menuSwitch = LastMenuL[locale]
        -- 3x3
        if w <= 256 and h <= 78 then 
            widgetSizeType = "3x3"
            lcd.font(FONT_XS)        
            lcd.drawText(lcdBorder, h-text_h/2-2, "Min:"..calcSteigrateMin.."m/s", LEFT)
            lcd.drawText(w-text_w-lcdBorder, h-text_h/2-2, "Active:"..calcSteigrateActive.."m/s", RIGHT)
            lcd.font(FONT_XL) 
            if widget.valueWurfhoehe ~= nil and widget.valueWurfhoehe ~= 0 and widget.valueWurfhoehe ~= "0" then
                lcd.drawText(w/2, h/2-text_h, widget.valueWurfhoehe, CENTERED)
            else
                lcd.drawText(w/2, h/2-text_h, waitForStart[locale], CENTERED)
            end
        -- 3x2
        elseif w <= 256 and h <= 132 then 
            widgetSizeType = "3x2"
            lcd.font(FONT_XXS)        
            lcd.drawText(lcdBorder, h/2-text_h/2, "Min:"..calcSteigrateMin.."m/s", LEFT)
            lcd.drawText(w-text_w-lcdBorder, h/2-text_h/2, "Active:"..calcSteigrateActive.."m/s", RIGHT)
            lcd.font(FONT_BOLD) 
            if widget.valueWurfhoehe ~= nil and widget.valueWurfhoehe ~= 0 and widget.valueWurfhoehe ~= "0" then
                lcd.drawText(w/2, h/4/2+text_h/2-15, widget.valueWurfhoehe, CENTERED)
            else
                lcd.drawText(w/2, h/4/2+text_h/2-15, waitForStart[locale], CENTERED)
            end
            lcd.drawLine(4, h/2-1, w-4, h/2-1)
            lcd.drawLine(4, h/2, w-4, h/2)
            lcd.drawLine(4, h/2+1, w-4, h/2+1)
            -- lcd.font(FONT_S)        
            -- lcd.drawText(w/2, h/2+5, headHistory[locale], CENTERED)
            if #entries == 0 then
                lcd.font(FONT_XS)
                print("Keine Daten vorhanden")
                lcd.drawText(w/2, h/2+text_h/2, "Keine Daten vorhanden", CENTERED)
            else
                lcd.font(FONT_XS)
                local y = h/2+2-- Startposition für die Anzeige auf dem LCD
                for _, entry in ipairs(entries) do
                    if y >= h-text_h+2 then
                        return -- Beende die Schleife, wenn der Bildschirm voll ist
                    end
                    lcd.drawText(w/2, y, entry, CENTERED)
                    y = y + text_h/2+1 -- Abstand zwischen den Zeilen
                end
            end
        -- 3x1
        elseif w <= 256 and h <= 294 then 
            widgetSizeType = "3x1"
            lcd.font(FONT_XS)        
            lcd.drawText(lcdBorder, h/2-text_h/2-2, "Min:"..calcSteigrateMin.."m/s", LEFT)
            lcd.drawText(w-text_w-lcdBorder, h/2-text_h/2-2, "Active:"..calcSteigrateActive.."m/s", RIGHT)
            lcd.font(FONT_L_BOLD) 
            if widget.valueWurfhoehe ~= nil and widget.valueWurfhoehe ~= 0 and widget.valueWurfhoehe ~= "0" then
                lcd.drawText(w/2, h/4/2+text_h/2, widget.valueWurfhoehe, CENTERED)
            else
                lcd.drawText(w/2, h/4/2+text_h/2, waitForStart[locale], CENTERED)
            end
            lcd.drawLine(4, h/2-1, w-4, h/2-1)
            lcd.drawLine(4, h/2, w-4, h/2)
            lcd.drawLine(4, h/2+1, w-4, h/2+1)
            -- lcd.font(FONT_S_BOLD)        
            -- lcd.drawText(w/2, h/2+5, headHistory[locale], CENTERED)
            if #entries == 0 then
                lcd.font(FONT_S)
                print("Keine Daten vorhanden")
                lcd.drawText(w/2, h/2+text_h/2, "Keine Daten vorhanden", CENTERED)
            else
                lcd.font(FONT_S)
                local y = h/2+2 -- Startposition für die Anzeige auf dem LCD
                for _, entry in ipairs(entries) do
                    if y >= h-text_h+2 then
                        return -- Beende die Schleife, wenn der Bildschirm voll ist
                    end
                    lcd.drawText(w/2, y, entry, CENTERED)
                    y = y + text_h/2+1 -- Abstand zwischen den Zeilen
                end
            end
        -- 2x2
        elseif w <= 388 and h <= 132 then 
            widgetSizeType = "2x2"
            lcd.font(FONT_XXS)        
            lcd.drawText(lcdBorder, h-text_h/2-3, "Min:"..calcSteigrateMin.."m/s", LEFT)
            lcd.drawText(w/2-text_w-lcdBorder, h-text_h/2-3, "Active:"..calcSteigrateActive.."m/s", RIGHT)
            lcd.font(FONT_L) 
            if widget.valueWurfhoehe ~= nil and widget.valueWurfhoehe ~= 0 and widget.valueWurfhoehe ~= "0" then
                lcd.drawText(w/4, h/2-text_h, widget.valueWurfhoehe, CENTERED)
            else
                lcd.drawText(w/4, h/2-text_h, waitForStart[locale], CENTERED)
            end
            lcd.drawLine(w/2-1, 4, w/2-1, h-4)
            lcd.drawLine(w/2, 4, w/2, h-4)
            lcd.drawLine(w/2+1, 4, w/2+1, h-4)
            -- lcd.font(FONT_S)        
            -- lcd.drawText(w/2+10, 5, headHistory[locale], LEFT)
            if #entries == 0 then
                lcd.font(FONT_XS)
                print("Keine Daten vorhanden")
                lcd.drawText(w/2+10, text_h/2, "Keine Daten vorhanden", LEFT)
            else
                lcd.font(FONT_XS)
                local y = text_h/2 -- Startposition für die Anzeige auf dem LCD
                for _, entry in ipairs(entries) do
                    if y >= h-text_h+2 then
                        return -- Beende die Schleife, wenn der Bildschirm voll ist
                    end
                    lcd.drawText(w/2+10, y, entry, LEFT)
                    y = y + text_h/2+2 -- Abstand zwischen den Zeilen
                end
            end
        -- 2x1
        elseif w <= 388 and h <= 294 then 
            widgetSizeType = "2x1"
            lcd.font(FONT_XS)        
            lcd.drawText(lcdBorder, h/2-text_h/2-2, "Min:"..calcSteigrateMin.."m/s", LEFT)
            lcd.drawText(w-text_w-lcdBorder, h/2-text_h/2-2, "Active:"..calcSteigrateActive.."m/s", RIGHT)
            lcd.font(FONT_XXL) 
            if widget.valueWurfhoehe ~= nil and widget.valueWurfhoehe ~= 0 and widget.valueWurfhoehe ~= "0" then
                lcd.drawText(w/2, h/4/2+text_h/2, widget.valueWurfhoehe, CENTERED)
            else
                lcd.drawText(w/2, h/4/2+text_h/2, waitForStart[locale], CENTERED)
            end
            lcd.drawLine(4, h/2-1, w-4, h/2-1)
            lcd.drawLine(4, h/2, w-4, h/2)
            lcd.drawLine(4, h/2+1, w-4, h/2+1)
            -- lcd.font(FONT_S_BOLD)        
            -- lcd.drawText(w/2, h/2+5, headHistory[locale], CENTERED)
            if #entries == 0 then
                lcd.font(FONT_S)
                -- print("Keine Daten vorhanden")
                lcd.drawText(w/2, h/2+text_h/2, "Keine Daten vorhanden", CENTERED)
            else
                lcd.font(FONT_S)
                local y = h/2+2 -- Startposition für die Anzeige auf dem LCD
                for _, entry in ipairs(entries) do
                    if y >= h-text_h+2 then
                        return -- Beende die Schleife, wenn der Bildschirm voll ist
                    end
                    lcd.drawText(w/2, y, entry, CENTERED)
                    y = y + text_h/2+2 -- Abstand zwischen den Zeilen
                end
            end
        -- 1x2
        elseif w <= 784 and h <= 132 then 
            widgetSizeType = "1x2"
            lcd.font(FONT_XS)        
            lcd.drawText(lcdBorder, h-text_h/2-2, "Min:"..calcSteigrateMin.."m/s", LEFT)
            lcd.drawText(w/2-text_w-lcdBorder, h-text_h/2-2, "Active:"..calcSteigrateActive.."m/s", RIGHT)
            lcd.font(FONT_XXL) 
            if widget.valueWurfhoehe ~= nil and widget.valueWurfhoehe ~= 0 and widget.valueWurfhoehe ~= "0" then
                lcd.drawText(w/4, h/2-text_h, widget.valueWurfhoehe, CENTERED)
            else
                lcd.drawText(w/4, h/2-text_h, waitForStart[locale], CENTERED)
            end
            lcd.drawLine(w/2-1, 4, w/2-1, h-4)
            lcd.drawLine(w/2, 4, w/2, h-4)
            lcd.drawLine(w/2+1, 4, w/2+1, h-4)
            -- lcd.font(FONT_BOLD)        
            -- lcd.drawText(w/2+10, 5, headHistory[locale], LEFT)
            if #entries == 0 then
                lcd.font(FONT_STD)
                print("Keine Daten vorhanden")
                lcd.drawText(w/2+10, text_h/2+2, "Keine Daten vorhanden", LEFT)
            else
                lcd.font(FONT_STD)
                local y = text_h/2 -- Startposition für die Anzeige auf dem LCD
                for _, entry in ipairs(entries) do
                    if y >= h-text_h+2 then
                        return -- Beende die Schleife, wenn der Bildschirm voll ist
                    end
                    lcd.drawText(w/2+10, y, entry, LEFT)
                    y = y + text_h/2+6 -- Abstand zwischen den Zeilen
                end
            end
        -- 1x1
        elseif w <= 784 and h <= 294 then 
            widgetSizeType = "1x1"
            lcd.font(FONT_XS)        
            lcd.drawText(lcdBorder, h-text_h/2-2, "Min:"..calcSteigrateMin.."m/s", LEFT)
            lcd.drawText(w/2-text_w-lcdBorder, h-text_h/2-2, "Active:"..calcSteigrateActive.."m/s", RIGHT)
            lcd.font(FONT_XXL) 
            if widget.valueWurfhoehe ~= nil and widget.valueWurfhoehe ~= 0 and widget.valueWurfhoehe ~= "0" then
                lcd.drawText(w/4, h/2-text_h, widget.valueWurfhoehe, CENTERED)
            else
                lcd.drawText(w/4, h/2-text_h, waitForStart[locale], CENTERED)
            end
            lcd.drawLine(w/2-1, 4, w/2-1, h-4)
            lcd.drawLine(w/2, 4, w/2, h-4)
            lcd.drawLine(w/2+1, 4, w/2+1, h-4)
            -- lcd.font(FONT_L_BOLD)        
            -- lcd.drawText(w/2+10, 10, headHistory[locale], LEFT)
            if #entries == 0 then
                lcd.font(FONT_STD)
                print("Keine Daten vorhanden")
                lcd.drawText(w/2+10, text_h/2+2, "Keine Daten vorhanden", LEFT)
            else
                lcd.font(FONT_STD)
                local y = text_h/2 -- Startposition für die Anzeige auf dem LCD
                for _, entry in ipairs(entries) do
                    lcd.drawText(w/2+10, y, entry, LEFT)
                    y = y + text_h/2+10 -- Abstand zwischen den Zeilen
                end
            end
        -- full
        elseif w <= 800 and h <= 458 then 
            widgetSizeType = "full"
            lcd.font(FONT_XS)        
            lcd.drawText(lcdBorder, h-text_h/2-2, "Min:"..calcSteigrateMin.."m/s", LEFT)
            lcd.drawText(w/2-text_w-lcdBorder, h-text_h/2-2, "Active:"..calcSteigrateActive.."m/s", RIGHT)
            lcd.font(FONT_XXL) 
            if widget.valueWurfhoehe ~= nil and widget.valueWurfhoehe ~= 0 and widget.valueWurfhoehe ~= "0" then
                lcd.drawText(w/4, h/2-text_h, widget.valueWurfhoehe, CENTERED)
            else
                lcd.drawText(w/4, h/2-text_h, waitForStart[locale], CENTERED)
            end
            lcd.drawLine(w/2-1, 4, w/2-1, h-4)
            lcd.drawLine(w/2, 4, w/2, h-4)
            lcd.drawLine(w/2+1, 4, w/2+1, h-4)
            -- lcd.font(FONT_L_BOLD)        
            -- lcd.drawText(w/2+10, 10, headHistory[locale], LEFT)
            if #entries == 0 then
                lcd.font(FONT_STD)
                print("Keine Daten vorhanden")
                lcd.drawText(w/2+10, text_h/2+2, "Keine Daten vorhanden", LEFT)
            else
                lcd.font(FONT_STD)
                local y = text_h/2 -- Startposition für die Anzeige auf dem LCD
                for _, entry in ipairs(entries) do
                    lcd.drawText(w/2+10, y, entry, LEFT)
                    y = y + text_h/2+10 -- Abstand zwischen den Zeilen
                end
            end
        -- Default
        else 
            widgetSizeType = "Default"      
            lcd.font(FONT_XS)        
            lcd.font(FONT_XS)        
            lcd.drawText(lcdBorder, h-text_h/2-2, "Min:"..calcSteigrateMin.."m/s", LEFT)
            lcd.drawText(w/2-text_w-lcdBorder, h-text_h/2-2, "Active:"..calcSteigrateActive.."m/s", RIGHT)
            lcd.font(FONT_XXL) 
            if widget.valueWurfhoehe ~= nil and widget.valueWurfhoehe ~= 0 and widget.valueWurfhoehe ~= "0" then
                lcd.drawText(w/4, h/2-text_h, widget.valueWurfhoehe, CENTERED)
            else
                lcd.drawText(w/4, h/2-text_h, waitForStart[locale], CENTERED)
            end
            lcd.drawLine(w/2-1, 4, w/2-1, h-4)
            lcd.drawLine(w/2, 4, w/2, h-4)
            lcd.drawLine(w/2+1, 4, w/2+1, h-4)
            -- lcd.font(FONT_L_BOLD)        
            -- lcd.drawText(w/2+10, 10, headHistory[locale], LEFT)
            if #entries == 0 then
                lcd.font(FONT_STD)
                print("Keine Daten vorhanden")
                lcd.drawText(w/2+10, text_h/2+2, "Keine Daten vorhanden", LEFT)
            else
                lcd.font(FONT_STD)
                local y = text_h/2 -- Startposition für die Anzeige auf dem LCD
                for _, entry in ipairs(entries) do
                    lcd.drawText(w/2+10, y, entry, LEFT)
                    y = y + text_h/2+10 -- Abstand zwischen den Zeilen
                end
            end
        end
    end   
end

local function wakeup(widget)
    local sensorFlughoehe = system.getSource({category=CATEGORY_TELEMETRY, appId=0x0100})
    local sensorSteigrate = system.getSource({category=CATEGORY_TELEMETRY, appId=0x0110})
    local valueSteigrateString = nil
    local valueFlughoheString = nil
    local redSteigRate = nil
    local multipRedSteigRate = nil
    widget.valueReset = valueReset
    -- if widget.valueWurfhoehe == nil then
    --     widget.valueWurfhoehe = "200m"
    -- end

    -- Überprüfen, ob sensorSteigrate gültig ist
    valueSteigrateString = sensorSteigrate and sensorSteigrate:stringValue() or nil
    valueFlughoheString = sensorFlughoehe and sensorFlughoehe:stringValue() or nil

    -- Sicherstellen, dass valueSteigrateString gültig ist
    if valueSteigrateString and valueSteigrateString ~= "" and valueSteigrateString ~= nil then
        redSteigRate = tonumber((string.gsub(valueSteigrateString, "m/s", "")))
    else
        redSteigRate = 0 -- Standardwert, falls die Umwandlung fehlschlägt
    end

    -- Sicherstellen, dass redSteigRate nicht nil ist
    multipRedSteigRate = (redSteigRate or 0) * 100
    if sensorFlughoehe ~= nil then
        if multipRedSteigRate >= widget.SteigrateActive or start == 1 and widget.valueReset == 1 then
            start = 1  
            if multipRedSteigRate <= widget.SteigrateMin and widget.valueReset == 1 then
                widget.valueWurfhoehe = valueFlughoheString
                valueReset = 0
                start = 0
                widget.valueReset = valueReset
                highestPoint = multipRedSteigRate
                if widget.playValue == true and soundPlayed == 0 then
                    wurfHoehe = tonumber((string.gsub(widget.valueWurfhoehe, "m", "")))
                    print("Wurfhoehe without multipl: " .. wurfHoehe)
                    -- wurfHoehe = wurfHoehe * 100
                    -- print("Wurfhoehe: " .. wurfHoehe)
                    system.playNumber(wurfHoehe,UNIT_METER,2)
                    soundPlayed = 1
                end
                
            end
        end
    end
    -- print("ResetValue: " .. widget.wHeightReset:stringValue())
    if widget.wHeightReset ~= nil and type(widget.wHeightReset) == "userdata" and widget.wHeightReset:stringValue() ~= nil then
        
        if widget.wHeightReset:stringValue() == "100" then
            if widget.valueWurfhoehe ~= "0" and widget.valueWurfhoehe ~= 0 and widget.valueWurfhoehe ~= nil then 
                local filePath = widget.modelName.."-startheight.txt"
                local entries = {}

                -- Datei öffnen
                local file = io.open(filePath, "r")
                if file then
                    while true do
                        local success, line = pcall(function() return file:read("L") end) -- Liest eine Zeile
                        if not success or not line then
                            break -- Beende die Schleife, wenn ein Fehler auftritt oder das Ende der Datei erreicht ist
                        end
                        line = string.gsub(line, "\r?\n", "") -- Entfernt Zeilenumbrüche
                        if string.match(line, "%S") then -- Nur nicht-leere Zeilen hinzufügen
                            table.insert(entries, line)
                        end
                    end
                    file:close()
                else
                    print("Datei konnte nicht geöffnet werden:", filePath)
                end

                -- Debug-Ausgabe der Einträge
                if #entries == 0 then
                    print("Keine Daten vorhanden")
                else
                    for _, entry in ipairs(entries) do
                        print(entry)
                    end
                end

                -- Neuen Eintrag hinzufügen
                local timestamp = os.date("%d.%m.%y %H:%M:%S")
                if widget.valueWurfhoehe and widget.valueWurfhoehe ~= "" then
                    local cleanedValue = string.gsub(widget.valueWurfhoehe, "m", "") -- Entfernt die Einheit "m"
                    local valueWithoutUnit = tonumber(cleanedValue) -- Konvertiert den bereinigten String in eine Zahl
                    if valueWithoutUnit then
                        local newEntry = string.format("%s - %.2fm", timestamp, valueWithoutUnit)
                        
                        -- Überprüfen, ob der Eintrag leer ist
                        if string.match(newEntry, "%S") then -- %S prüft, ob der String nicht nur aus Leerzeichen besteht
                            table.insert(entries, newEntry)
                        else
                            print("Leerer Eintrag wird nicht hinzugefügt.")
                        end
                    else
                        print("Ungültiger Wert für widget.valueWurfhoehe:", widget.valueWurfhoehe)
                    end
                else
                    print("widget.valueWurfhoehe ist nil oder leer")
                end
                -- Nur die letzten 10 Einträge behalten
                while #entries > 10 do
                    table.remove(entries, 1)
                end

                -- Datei überschreiben
                file = io.open(filePath, "w")
                if file then
                    for index, entry in ipairs(entries) do
                        if string.match(entry, "%S") then -- Überprüfen, ob die Zeile nicht leer ist
                            file:write(entry) -- Schreibe den Eintrag
                            if index < #entries then
                                file:write("\n") -- Füge nur zwischen den Einträgen einen Zeilenumbruch hinzu
                            end
                        end
                    end
                    file:close()
                else
                    print("Fehler beim Schreiben der Datei:", filePath)
                end
                widget.valueWurfhoehe = 0
                valueReset = 1
                start = 0
                soundPlayed = 0
            end
                   
        end
    end
    if widget.value ~= valueFlughoheString then
        widget.value = valueFlughoheString
        widget.valueReset = valueReset
        lcd.invalidate()
    end
    

    if widget.menuSw ~= nil and widget.menuSw:stringValue() ~= nil then
        if widget.menuSw:stringValue() == "100" then
            menuSWlastValue = widget.menuSw:stringValue()
            -- print("MenuSW lastValue 100: " .. menuSWlastValue)
        end
        if (widget.menuSw:stringValue() == "-100" or widget.menuSw:stringValue() == "0") and menuSWlastValue == "100" then
            -- print("MenuSW unterschied lastValue: " .. menuSWlastValue)
            if HistoryMenu == 0 then
                HistoryMenu = 1
            elseif HistoryMenu == 1 then
                HistoryMenu = 0
            end
            menuSWlastValue = widget.menuSw:stringValue()
            lcd.invalidate()
        end
    end
    
end

-- Menu Aneige bei touch Bedienung

local function menu(widget)
    return {
         {menuSwitch,
         function()
            if HistoryMenu == 0 then
                HistoryMenu = 1
            elseif HistoryMenu == 1 then
                HistoryMenu = 0
            end
         end},
         {menuL[locale],
         function()
            if widget.valueWurfhoehe ~= "0" and widget.valueWurfhoehe ~= 0 and widget.valueWurfhoehe ~= nil then 
                local filePath = widget.modelName.."-startheight.txt"
                local entries = {}

                -- Datei öffnen
                local file = io.open(filePath, "r")
                if file then
                    while true do
                        local success, line = pcall(function() return file:read("L") end) -- Liest eine Zeile
                        if not success or not line then
                            break -- Beende die Schleife, wenn ein Fehler auftritt oder das Ende der Datei erreicht ist
                        end
                        line = string.gsub(line, "\r?\n", "") -- Entfernt Zeilenumbrüche
                        if string.match(line, "%S") then -- Nur nicht-leere Zeilen hinzufügen
                            table.insert(entries, line)
                        end
                    end
                    file:close()
                else
                    print("Datei konnte nicht geöffnet werden:", filePath)
                end

                -- Debug-Ausgabe der Einträge
                if #entries == 0 then
                    print("Keine Daten vorhanden")
                else
                    for _, entry in ipairs(entries) do
                        print(entry)
                    end
                end

                -- Neuen Eintrag hinzufügen
                local timestamp = os.date("%d.%m.%y %H:%M:%S")
                if widget.valueWurfhoehe and widget.valueWurfhoehe ~= "" then
                    local cleanedValue = string.gsub(widget.valueWurfhoehe, "m", "") -- Entfernt die Einheit "m"
                    local valueWithoutUnit = tonumber(cleanedValue) -- Konvertiert den bereinigten String in eine Zahl
                    if valueWithoutUnit then
                        local newEntry = string.format("%s - %.2fm", timestamp, valueWithoutUnit)
                        
                        -- Überprüfen, ob der Eintrag leer ist
                        if string.match(newEntry, "%S") then -- %S prüft, ob der String nicht nur aus Leerzeichen besteht
                            table.insert(entries, newEntry)
                        else
                            print("Leerer Eintrag wird nicht hinzugefügt.")
                        end
                    else
                        print("Ungültiger Wert für widget.valueWurfhoehe:", widget.valueWurfhoehe)
                    end
                else
                    print("widget.valueWurfhoehe ist nil oder leer")
                end
                -- Nur die letzten 10 Einträge behalten
                while #entries > 10 do
                    table.remove(entries, 1)
                end

                -- Datei überschreiben
                file = io.open(filePath, "w")
                if file then
                    for index, entry in ipairs(entries) do
                        if string.match(entry, "%S") then -- Überprüfen, ob die Zeile nicht leer ist
                            file:write(entry) -- Schreibe den Eintrag
                            if index < #entries then
                                file:write("\n") -- Füge nur zwischen den Einträgen einen Zeilenumbruch hinzu
                            end
                        end
                    end
                    file:close()
                else
                    print("Fehler beim Schreiben der Datei:", filePath)
                end
                widget.valueWurfhoehe = 0
                valueReset = 1
                start = 0
                soundPlayed = 0
            end
         end},
         {ignoreHeight[locale],
         function()
            widget.valueWurfhoehe = 0
            valueReset = 1
            start = 0
            soundPlayed = 0
         end},
         {delLast[locale],
         function()
            filePathDelete = model.name().."-startheight.txt"
            print("Datei löschen: " .. filePathDelete)
            deleteLastLine(filePathDelete)

         end}
            
    }
        --  {LastMenuL[locale],
        --  function()
        --     if HistoryMenu == 0 then
        --         HistoryMenu = 1
        --     elseif HistoryMenu == 1 then
        --         HistoryMenu = 0
        --     end
            
        --  end},
end

local function event(widget, category, value, x, y)
    print("Event received:", category, value, x, y)
    if category == EVT_KEY and value == KEY_ENTER_LONG then
        print("Board " .. system.getVersion().board .. " Version " .. system.getVersion().version)
        print("Date " .. os.date() .. " Time " .. os.time())
        lcd.invalidate()
        system.killEvent(value)
        return true
    else
        return false
    end
end

local function configure(widget)
    -- Steigraten erkennung
    lineStrgActive = form.addLine(configStgR[locale])
    local SteigrateActiveField = form.addNumberField(lineStrgActive, nil,40, 1000, function() return widget.SteigrateActive end, function(value) widget.SteigrateActive = value end)
    SteigrateActiveField:suffix("m/s")
    SteigrateActiveField:decimals(2)
    SteigrateActiveField:default(500)
    -- Steigrate höchster Punkt
    lineStrgMin = form.addLine(configStgRmin[locale])
    local SteigrateMinField = form.addNumberField(lineStrgMin, nil,40, 500, function() return widget.SteigrateMin end, function(value) widget.SteigrateMin = value end)
    SteigrateMinField:suffix("m/s")
    SteigrateMinField:decimals(2)
    SteigrateMinField:default(50)
    -- Reset Schalter
    line = form.addLine(configResetSwitch[locale])
    form.addSwitchField(line, form.getFieldSlots(line)[0], function() return widget.wHeightReset end, function(value) widget.wHeightReset = value end)
    -- Menu Schalter
    line = form.addLine(configMenuSwitch[locale])
    form.addSwitchField(line, form.getFieldSlots(line)[0], function() return widget.menuSw end, function(value) widget.menuSw = value end)
    -- Play Value after detection
    line = form.addLine(configPlayValue[locale])
    form.addBooleanField(line, nil, function() return widget.playValue end, function(newValue) widget.playValue = newValue end)
     -- History Dateiname
    lineHistoryPath = form.addLine(headHistoryPath[locale]) form.addStaticText(lineHistoryPath, nil, widget.modelName.."-startheight.txt")
    -- Version
    lineVersion = form.addLine("Script Version") form.addStaticText(lineVersion, nil, scriptVersion)
    
    -- Hilfe-Button
    lineHelp = form.addLine(needSup[locale]) form.addButton(lineHelp, nil, {text = helpWindow[locale], paint = function() end, press = function() 
        local buttons = {
            {label="OK", action=function() return true end},
        }
        local dialog = form.openDialog({
            title=helpWindow[locale], 
            message=help1[locale]..help2[locale]..help3[locale]..help4[locale]..help5[locale].."\n\n\n\n",
            width=500,
            buttons=buttons,
            options=TEXT_LEFT,
            wakeup=function()
            end,
            paint=function()
            end
        })    
    end})
    
end

local function read(widget)

    widget.SteigrateActive = storage.read("A")
    widget.SteigrateMin = storage.read("B")
    widget.wHeightReset = storage.read("C") 
    widget.menuSw = storage.read("D") 
    widget.playValue = storage.read("E")
end

local function write(widget)
    storage.write("A", widget.SteigrateActive)
    storage.write("B", widget.SteigrateMin)
    storage.write("C", widget.wHeightReset)
    storage.write("D", widget.menuSw) 
    storage.write("E", widget.playValue)
end

local function init()
    system.registerWidget({key="STRT", name=name, create=create, paint=paint, event=event, menu=menu, wakeup=wakeup, configure=configure, read=read, write=write})
    valueReset = 1
    widget.valueWurfhoehe = 0
end

return {init=init}