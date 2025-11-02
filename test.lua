--███████████████████████--███████████████████████
function getIntEdit(value)
    if value == nil then return nil end
    local numValue = tonumber(value)
    if numValue == nil then return nil end
    
    numValue = math.floor(numValue)
    local isNegative = numValue < 0
    local absValue = math.abs(numValue)
    local edits = {}

    if absValue == 0 then
        edits = {"h000080D2", "hC0035FD6"} 
    elseif absValue == 1 then
        edits = {"h200080D2", "hC0035FD6"}  
    else

        local low16 = absValue & 0xFFFF
        local high16 = (absValue >> 16) & 0xFFFF

        local movz_word = 0xD2800000 + (low16 * 32)  
        local movz_hex = string.format("%08X", movz_word)
        local le_movz = movz_hex:sub(7,8) .. movz_hex:sub(5,6) .. movz_hex:sub(3,4) .. movz_hex:sub(1,2)
        table.insert(edits, "h" .. le_movz:upper())


        if high16 ~= 0 then
            local movk_word = 0xF2A00000 + (high16 * 32) 
            local movk_hex = string.format("%08X", movk_word)
            local le_movk = movk_hex:sub(7,8) .. movk_hex:sub(5,6) .. movk_hex:sub(3,4) .. movk_hex:sub(1,2)
            table.insert(edits, "h" .. le_movk:upper())
        end

        if isNegative then
            table.insert(edits, "h1F00002A")  
        end

        -- RET
        table.insert(edits, "hC0035FD6")
    end

    return edits
end

--███████████████████████--███████████████████████
function getComplexFloatEdit(value)
    value = tonumber(value)
    if not value then return {} end

    local edits = {}

    -- Chuyển float → uint32 (IEEE 754)
    local function floatToHex(f)
        if f == 0 then return 0 end
        local sign = f < 0 and 1 or 0
        f = math.abs(f)
        if f == math.huge then return sign == 1 and 0xFF800000 or 0x7F800000 end
        if f ~= f then return 0x7FC00000 end -- NaN

        local mantissa, exponent = math.frexp(f)
        exponent = exponent - 1 + 127
        mantissa = (mantissa * 2 - 1) * 0x800000

        local hex = math.floor(mantissa + 0.5)
        hex = hex + (exponent * 0x800000)
        if sign == 1 then hex = hex + 0x80000000 end
        return hex
    end

    local hex = floatToHex(value)
    local low16 = hex & 0xFFFF
    local high16 = (hex >> 16) & 0xFFFF

    -- MOVZ W0, #low16
    local movz = 0x52000000 + (low16 * 32)  -- 0x52 = MOVZ Wd, #imm16
    local movz_hex = string.format("%08X", movz)
    local le_movz = movz_hex:sub(7,8) .. movz_hex:sub(5,6) .. movz_hex:sub(3,4) .. movz_hex:sub(1,2)
    table.insert(edits, "~A8 MOVZ W0, #" .. low16)

    -- MOVK W0, #high16, LSL #16 nếu cần
    if high16 ~= 0 then
        local movk = 0x72000000 + (high16 * 32)  -- 0x72 = MOVK Wd, #imm16, LSL #16
        local movk_hex = string.format("%08X", movk)
        local le_movk = movk_hex:sub(7,8) .. movk_hex:sub(5,6) .. movk_hex:sub(3,4) .. movk_hex:sub(1,2)
        table.insert(edits, "~A8 MOVK W0, #" .. high16 .. ", LSL #16")
    end

    -- FMOV S0, W0
    table.insert(edits, "1E270000r")  -- FMOV S0, W0

    -- RET
    table.insert(edits, "C0035FD6r")

    return edits
end

--███████████████████████--███████████████████████
function getDoubleEdit(value)
    value = tonumber(value)
    if not value then return {} end

    local edits = {}

    -- Chuyển double → uint64 (IEEE 754)
    local function doubleToHex(d)
        if d == 0 then return 0, 0 end
        local sign = d < 0 and 1 or 0
        d = math.abs(d)
        if d == math.huge then return 0x00000000, (sign == 1 and 0xFFF00000 or 0x7FF00000) end
        if d ~= d then return 0x00000001, 0x7FF80000 end -- NaN

        local mantissa, exponent = math.frexp(d)
        exponent = exponent - 1 + 1023
        mantissa = (mantissa * 2 - 1) * 0x10000000000000 -- 52-bit mantissa

        local low32 = math.floor(mantissa) & 0xFFFFFFFF
        local high32 = (math.floor(mantissa / 0x100000000) & 0xFFFFF) + (exponent * 0x100000)
        if sign == 1 then high32 = high32 + 0x80000000 end

        return low32, high32
    end

    local low32, high32 = doubleToHex(value)
    local low16 = low32 & 0xFFFF
    local high16_low = (low32 >> 16) & 0xFFFF
    local high16_high = high32 & 0xFFFF
    local highest16 = (high32 >> 16) & 0xFFFF

    -- MOVZ X0, #low16
    local movz = 0xD2800000 + (low16 * 32)
    local movz_hex = string.format("%08X", movz)
    local le_movz = movz_hex:sub(7,8) .. movz_hex:sub(5,6) .. movz_hex:sub(3,4) .. movz_hex:sub(1,2)
    table.insert(edits, "~A8 MOVZ X0, #" .. low16)

    -- MOVK X0, #high16_low, LSL #16
    if high16_low ~= 0 then
        local movk = 0xF2800000 + (high16_low * 32)
        local movk_hex = string.format("%08X", movk)
        local le_movk = movk_hex:sub(7,8) .. movk_hex:sub(5,6) .. movk_hex:sub(3,4) .. movk_hex:sub(1,2)
        table.insert(edits, "~A8 MOVK X0, #" .. high16_low .. ", LSL #16")
    end

    -- MOVK X0, #high16_high, LSL #32
    if high16_high ~= 0 then
        local movk = 0xF2A00000 + (high16_high * 32)
        local movk_hex = string.format("%08X", movk)
        local le_movk = movk_hex:sub(7,8) .. movk_hex:sub(5,6) .. movk_hex:sub(3,4) .. movk_hex:sub(1,2)
        table.insert(edits, "~A8 MOVK X0, #" .. high16_high .. ", LSL #32")
    end

    -- MOVK X0, #highest16, LSL #48
    if highest16 ~= 0 then
        local movk = 0xF2C00000 + (highest16 * 32)
        local movk_hex = string.format("%08X", movk)
        local le_movk = movk_hex:sub(7,8) .. movk_hex:sub(5,6) .. movk_hex:sub(3,4) .. movk_hex:sub(1,2)
        table.insert(edits, "~A8 MOVK X0, #" .. highest16 .. ", LSL #48")
    end

    -- FMOV D0, X0
    table.insert(edits, "9E670000r")  -- FMOV D0, X0

    -- RET
    table.insert(edits, "C0035FD6r")

    return edits
end

-- ███████████████████████ -- ███████████████████████
local memoryCache = {}
-- ███████████████████████ -- ███████████████████████
function editarm(tag, value, valueType)
    local results = gg.getResults(gg.getResultsCount())
    if results == nil or #results == 0 then
        gg.alert("ERROR: No Search Results! ")
        return false
    end
    
    local edits = {}
    valueType = valueType:lower()
    
    if valueType == "int" then
        edits = getIntEdit(value)
    elseif valueType == "single" or valueType == "float" then
        edits = getComplexFloatEdit(value, "Single")
    elseif valueType == "double" then
        edits = getDoubleEdit(value, "Double")
    end
    
    if edits == nil or #edits == 0 then
        gg.alert("Lỗi: Không thể tạo mã ARM cho giá trị này!")
        return false
    end
    
    local valuetoedit = {}
    for i, v in ipairs(results) do
        for j, editVal in ipairs(edits) do
            table.insert(valuetoedit, {
                address = v.address + (4 * (j - 1)),
                flags = gg.TYPE_DWORD,
                value = editVal,
                freeze = true
            })
        end
    end
    
    if tag and not memoryCache[tag] then
        memoryCache[tag] = {
            originalValues = gg.getValues(valuetoedit),
            valueType = valueType,
            originalValue = value
        }
    end
    
    gg.addListItems(valuetoedit)
    gg.removeListItems(valuetoedit)
    gg.clearResults()
	gg.sleep(500)
    return true
end
--███████████████████████--███████████████████████
function edit(tagOrValue, valuesString)
    local tag, values

    if valuesString == nil then
        values = tagOrValue
        tag = nil
    else
        tag = tagOrValue
        values = valuesString
    end

    if values == nil then
        gg.alert("⚠️ Lỗi: Không có giá trị nào được nhập!")
        return false
    end
    
    local mvqedit = {}
    for val in string.gmatch(tostring(values), "([^;]+)") do
        val = val:match("^%s*(.-)%s*$") 
        if val ~= "" then
            table.insert(mvqedit, val)
        end
    end
    
    if #mvqedit == 0 then
        gg.alert("⚠️ Lỗi: Chuỗi giá trị không hợp lệ!")
        return false
    end

    local Quoan = gg.getResults(gg.getResultsCount())
    if Quoan == nil or #Quoan == 0 then
        gg.alert("⚠️ Lỗi: Không có kết quả tìm kiếm nào!")
        return false
    end

    local valuetoedit = {}
    for i, addrInfo in ipairs(Quoan) do
        local addr = addrInfo.address or addrInfo
        local dataType = addrInfo.flags 
        for j = 1, #mvqedit do
            local value = mvqedit[j]
            local convertedValue = value
            if dataType == gg.TYPE_DWORD or 
               dataType == gg.TYPE_WORD or 
               dataType == gg.TYPE_QWORD or 
               dataType == gg.TYPE_BYTE or 
               dataType == gg.TYPE_XOR or
               dataType == gg.TYPE_FLOAT or 
               dataType == gg.TYPE_DOUBLE then
                convertedValue = tonumber(value) or value
            else
                gg.alert("⚠️ Lỗi: Loại dữ liệu không được hỗ trợ: " .. tostring(dataType))
                return false
            end
            table.insert(valuetoedit, {
                address = addr + (4 * (j - 1)),
                flags = dataType,
                value = convertedValue,
                freeze = true
            })
        end
    end

    if tag and not memoryCache[tag] then
        memoryCache[tag] = gg.getValues(valuetoedit)
    end

    gg.addListItems(valuetoedit)
    gg.removeListItems(valuetoedit)
    gg.clearResults()
    gg.sleep(500)
    return true
end
--███████████████████████--███████████████████████
function revert(tag)
    if memoryCache[tag] then
        local revertItems = {}
        for i, item in ipairs(memoryCache[tag]) do
            item.freeze = true
            table.insert(revertItems, item)
        end
        gg.addListItems(revertItems)
        gg.removeListItems(revertItems)
        gg.clearResults()
        gg.sleep(500)
        memoryCache[tag] = nil
        return true
    end
    return false
end
--███████████████████████--███████████████████████



