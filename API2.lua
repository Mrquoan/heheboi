
--███████████████████████--███████████████████████

-- Chuyển float → int32 (IEEE 754)
function math.float_to_int32(f)
    if f == 0 then return 0 end
    local sign = f < 0 and 1 or 0
    if sign == 1 then f = -f end
    local mantissa, exponent = math.frexp(f)
    exponent = exponent - 1
    mantissa = mantissa * 2 - 1
    local int_mantissa = math.floor(mantissa * 0x800000)
    local result = (sign * 0x80000000) + ((exponent + 127) * 0x800000) + int_mantissa
    return result
end

-- Chuyển double → int64 (IEEE 754) → trả về low32, high32
function math.double_to_int64(d)
    if d == 0 then return 0, 0 end
    local sign = d < 0 and 1 or 0
    if sign == 1 then d = -d end
    local mantissa, exponent = math.frexp(d)
    exponent = exponent - 1
    mantissa = mantissa * 2 - 1
    local int_mantissa = math.floor(mantissa * 0x10000000000000)
    local low32 = int_mantissa & 0xFFFFFFFF
    local high32 = (int_mantissa >> 32) & 0xFFFFFFFF
    high32 = high32 + ((exponent + 1023) << 20) + (sign << 31)
    return low32, high32
end

--███████████████████████--███████████████████████
-- getIntEdit (giữ nguyên)
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

        table.insert(edits, "hC0035FD6")
    end

    return edits
end

--███████████████████████--███████████████████████
-- getComplexFloatEdit - NÂNG CẤP: Real + Equivalent (giống xFLOATE)
--███████████████████████--███████████████████████
function getComplexFloatEdit(value, mode)
    value = tonumber(value)
    if not value then return {} end

    local edits = {}
    mode = mode or "Single"  -- "Single" = real float (FMOV), "Equivalent" = int equivalent

    -- Xử lý số nhỏ: dùng MOV W0, #imm
    if value >= -65536 and value <= 65535 then
        local imm = math.floor(value)
        if imm == 0 then
            edits[1] = "~A8 MOV W0, WZR"
        else
            edits[1] = "~A8 MOV W0, #" .. imm
        end

        if mode == "Single" then
            edits[2] = "h1E270000"  -- FMOV S0, W0
        end
        edits[#edits + 1] = "hC0035FD6"  -- RET
        return edits
    end

    -- Xử lý số lớn: dùng MOVZ + MOVK (32-bit IEEE 754)
    local float_hex = string.format("%08X", math.float_to_int32(value))
    local low16 = tonumber("0x" .. string.sub(float_hex, 7, 8) .. string.sub(float_hex, 5, 6))
    local high16 = tonumber("0x" .. string.sub(float_hex, 3, 4) .. string.sub(float_hex, 1, 2))

    -- MOVZ W0, #low16
    local movz = 0x52800000 + (low16 * 2)
    local movz_hex = string.format("%08X", movz)
    local le_movz = movz_hex:sub(7,8) .. movz_hex:sub(5,6) .. movz_hex:sub(3,4) .. movz_hex:sub(1,2)
    table.insert(edits, "h" .. le_movz:upper())

    -- MOVK W0, #high16, LSL #16
    if high16 ~= 0 then
        local movk = 0x72A00000 + (high16 * 2)
        local movk_hex = string.format("%08X", movk)
        local le_movk = movk_hex:sub(7,8) .. movk_hex:sub(5,6) .. movk_hex:sub(3,4) .. movk_hex:sub(1,2)
        table.insert(edits, "h" .. le_movk:upper())
    end

    -- Nếu là Real Float → thêm FMOV S0, W0
    if mode == "Single" then
        table.insert(edits, "h1E270000")
    end

    -- RET
    table.insert(edits, "hC0035FD6")
    return edits
end

--███████████████████████--███████████████████████
-- getDoubleEdit - NÂNG CẤP: Real + Equivalent
--███████████████████████--███████████████████████
function getDoubleEdit(value, mode)
    value = tonumber(value)
    if not value then return {} end

    local edits = {}
    mode = mode or "Double"  -- "Double" = real, "Equivalent" = int64 in X0

    -- Xử lý số nhỏ: dùng MOV W0, #imm → SCVTF D0, W0
    if value >= -65536 and value <= 65535 then
        local imm = math.floor(value)
        if imm == 0 then
            edits[1] = "~A8 MOV W0, WZR"
        else
            edits[1] = "~A8 MOV W0, #" .. imm
        end

        if mode == "Double" then
            edits[2] = "h9E670000"  -- SCVTF D0, W0
        end
        edits[#edits + 1] = "hC0035FD6"  -- RET
        return edits
    end

    -- Xử lý số lớn: dùng MOVZ + MOVK (64-bit IEEE 754)
    local low32, high32 = math.double_to_int64(value)

    -- MOVZ X0, #low32 & 0xFFFF
    local movz = 0xD2800000 + ((low32 & 0xFFFF) * 32)
    local movz_hex = string.format("%08X", movz)
    local le_movz = movz_hex:sub(7,8) .. movz_hex:sub(5,6) .. movz_hex:sub(3,4) .. movz_hex:sub(1,2)
    table.insert(edits, "h" .. le_movz:upper())

    -- MOVK X0, #(low32 >> 16), LSL #16
    local low_high = (low32 >> 16) & 0xFFFF
    if low_high ~= 0 then
        local movk = 0xF2800000 + (low_high * 32)
        local movk_hex = string.format("%08X", movk)
        local le_movk = movk_hex:sub(7,8) .. movk_hex:sub(5,6) .. movk_hex:sub(3,4) .. movk_hex:sub(1,2)
        table.insert(edits, "h" .. le_movk:upper())
    end

    -- MOVK X0, #high32, LSL #32
    if high32 ~= 0 then
        local movk32 = 0xF2A00000 + ((high32 & 0xFFFF) * 32)
        local movk32_hex = string.format("%08X", movk32)
        local le_movk32 = movk32_hex:sub(7,8) .. movk32_hex:sub(5,6) .. movk32_hex:sub(3,4) .. movk32_hex:sub(1,2)
        table.insert(edits, "h" .. le_movk32:upper())

        local high_high = (high32 >> 16) & 0xFFFF
        if high_high ~= 0 then
            local movk48 = 0xF2C00000 + (high_high * 32)
            local movk48_hex = string.format("%08X", movk48)
            local le_movk48 = movk48_hex:sub(7,8) .. movk48_hex:sub(5,6) .. movk48_hex:sub(3,4) .. movk48_hex:sub(1,2)
            table.insert(edits, "h" .. le_movk48:upper())
        end
    end

    -- Nếu là Real Double → thêm FMOV D0, X0
    if mode == "Double" then
        table.insert(edits, "h9E670000")
    end

    -- RET
    table.insert(edits, "hC0035FD6")
    return edits
end

--███████████████████████--███████████████████████
-- Cache để khôi phục
--███████████████████████--███████████████████████
local memoryCache = {}

--███████████████████████--███████████████████████
-- editarm - Hàm chính (cập nhật tương thích)
--███████████████████████--███████████████████████
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
        -- Tự động chọn: nếu cần equivalent → dùng "Equivalent", mặc định là "Single"
        edits = getComplexFloatEdit(value, "Single")  -- hoặc "Equivalent" nếu cần giống sc2
    elseif valueType == "double" then
        edits = getDoubleEdit(value, "Double")  -- hoặc "Equivalent"
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
-- ███████████████████████ -- ███████████████████████
function revert(tag)
    if memoryCache[tag] then
        local revertItems = {}
        for i, item in ipairs(memoryCache[tag].originalValues) do
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
--███████████████████████ -- ███████████████████████
function FieldMVQ(ten, offsetfield, loai)
    gg.clearResults()
    gg.setRanges(gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS | gg.REGION_OTHER)
    
    gg.setVisible(false)
    gg.searchNumber(":" .. ten, 1)
    gg.setVisible(false)
    
    if gg.getResultsCount() == 0 then
        E = 0
        return
    end
    
    local MVQu = gg.getResults(1)
    gg.getResults(gg.getResultsCount())
    gg.refineNumber(tonumber(MVQu[1].value), 1)
    
    MVQu = gg.getResults(gg.getResultsCount())
    gg.clearResults()
    
    for i = 1, #MVQu do
        local item = MVQu[i]
        item.address = item.address - 1
        item.flags = 1
    end
    
    MVQu = gg.getValues(MVQu)
    local MVQa = {}
    local MVQaa = 1
    
    for i = 1, #MVQu do
        local item = MVQu[i]
        if item.value == 0 then
            MVQa[MVQaa] = { address = item.address, flags = 1 }
            MVQaa = MVQaa + 1
        end
    end
    
    if #MVQa == 0 then
        gg.clearResults()
        E = 0
        return
    end
    
    for i = 1, #MVQa do
        local item = MVQa[i]
        item.address = item.address + #ten + 1
        item.flags = 1
    end
    
    MVQa = gg.getValues(MVQa)
    local MVQs = {}
    local MVQbb = 1
    
    for i = 1, #MVQa do
        local item = MVQa[i]
        if item.value == 0 then
            MVQs[MVQbb] = { address = item.address, flags = 1 }
            MVQbb = MVQbb + 1
        end
    end
    
    if #MVQs == 0 then
        gg.clearResults()

        E = 0
        return
    end
    
    for i = 1, #MVQs do
        local item = MVQs[i]
        item.address = item.address - #ten
        item.flags = 1
    end
    
    gg.loadResults(MVQs)
    gg.searchPointer(0)
    
    if gg.getResultsCount() == 0 then
        E = 0
        return
    end
    
    MVQu = gg.getResults(gg.getResultsCount())
    gg.clearResults()
    
    local MVQo1, MVQo2, MVQvt
    if gg.getTargetInfo().x64 then
        MVQo1 = 48
        MVQo2 = 56
        MVQvt = 32
    else
        MVQo1 = 24
        MVQo2 = 28
        MVQvt = 4
    end
    
    local ERROR = 0
    ::TRYAGAIN::
    local MVQy = {}
    local MVQz = {}
    
    for i = 1, #MVQu do
        local item = MVQu[i]
        MVQy[i] = { address = item.address + MVQo1, flags = MVQvt }
        MVQz[i] = { address = item.address + MVQo2, flags = MVQvt }
    end
    
    MVQy = gg.getValues(MVQy)
    MVQz = gg.getValues(MVQz)
    local MVQp = {}
    local MVQnn = 1
    
    for i = 1, #MVQy do
        if MVQy[i].value == MVQz[i].value and #tostring(MVQy[i].value) >= 8 then
            MVQp[MVQnn] = MVQy[i].value
            MVQnn = MVQnn + 1
        end
    end
    
    if #MVQp == 0 and ERROR == 0 then
        if gg.getTargetInfo().x64 then
            MVQo1 = 32
            MVQo2 = 40
        else
            MVQo1 = 16
            MVQo2 = 20
        end
        ERROR = 2
        goto TRYAGAIN
    end
    
    if #MVQp == 0 and ERROR == 2 then
        E = 0
        return
    end
    
    gg.setRanges(gg.REGION_ANONYMOUS)
    gg.clearResults()
    local MVQnnx = 1
    
    for i = 1, #MVQp do
        gg.searchNumber(tonumber(MVQp[i]), MVQvt)
        
        if gg.getResultsCount() ~= 0 then
            local MVQnn = gg.getResults(gg.getResultsCount())
            gg.clearResults()
            for j = 1, #MVQnn do
                MVQnn[j].name = "MVQ"
            end
            gg.addListItems(MVQnn)
            MVQnnx = MVQnnx + 1
        end
        
        gg.clearResults()
    end
    
    if MVQnnx == 1 then
        gg.clearResults()
--        gg.clearList()
        E = 0
        return
    end
    
    local MVQload = {}
    local MVQremove = {}
    MVQnn = 1
    MVQu = gg.getListItems()
    
    for i = 1, #MVQu do
        if MVQu[i].name == "MVQ" then
            MVQload[MVQnn] = { address = MVQu[i].address + offsetfield, flags = loai }
            MVQremove[MVQnn] = MVQu[i]
            MVQnn = MVQnn + 1
        end
    end
    
    MVQload = gg.getValues(MVQload)
    gg.loadResults(MVQload)
    gg.removeListItems(MVQremove)
end
--███████████████████████--███████████████████████
function search()
gg.getResults(gg.getResultsCount())
gg.clearResults()
gg.searchNumber(x,t) 
end; 
--███████████████████████--███████████████████████
function get()
	gg.getResults(gg.getResultsCount());
end; 
--███████████████████████--███████████████████████ 
function refine(x)
	gg.refineNumber(x, t, false ,loai); 
end;
--███████████████████████--███████████████████████ 
function check()
E=nil E=gg.getResultsCount()
end; 
--███████████████████████--███████████████████████
function freeze(dbang)
bien2 = gg.getResults(9999)
    for i, v in  pairs (bien2) do
    bien2[i].value = dbang
    bien2[i].freeze= true
    end
gg.addListItems(bien2)
gg.clearResults()
end;
--███████████████████████--███████████████████████
