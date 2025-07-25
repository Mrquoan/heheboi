local __bundle_require, __bundle_loaded, __bundle_register, __bundle_modules = (function(superRequire)
	local loadingPlaceholder = {[{}] = true}

	local register
	local modules = {}

	local require
	local loaded = {}

	register = function(name, body)
		if not modules[name] then
			modules[name] = body
		end
	end

	require = function(name)
		local loadedModule = loaded[name]

		if loadedModule then
			if loadedModule == loadingPlaceholder then
				return nil
			end
		else
			if not modules[name] then
				if not superRequire then
					local identifier = type(name) == 'string' and '\"' .. name .. '\"' or tostring(name)
					error('Tried to require ' .. identifier .. ', but no such module has been registered')
				else
					return superRequire(name)
				end
			end

			loaded[name] = loadingPlaceholder
			loadedModule = modules[name](require, loaded, register, modules)
			loaded[name] = loadedModule
		end

		return loadedModule
	end

	return require, loaded, register, modules
end)(require)
__bundle_register("Il2cppLT9-cli", function(require, _LOADED, __bundle_register, __bundle_modules)
require('index')
gg.setVisible(false)
local ResultsTabSearch = gg.getResults(gg.getResultsCount())
Il2cpp()
gg.loadResults(ResultsTabSearch)
gg.setVisible(true)
script_title = ""
cli = {
    Toast = function(toast_string, emoji)
        local _ = utf8.char(9552)
        gg.toast(script_title .. "\n\n" .. emoji .. _ .. _ .. _ .. _ .. _ .. _ .. _ .. _ .. _ .. _
                     .. _ .. _ .. _ .. emoji .. "\n\n" .. toast_string .. "\n\n" .. emoji .. _ .. _
                     .. _ .. _ .. _ .. _ .. _ .. _ .. _ .. _ .. _ .. _ .. _ .. emoji)
    end,
    Alert = function(headerString, bodyString, emoji)
        if #bodyString > 0 then
            gg.alert(script_title .. "\n\n" .. emoji .. " " .. headerString .. " " .. emoji .. "\n\n" .. bodyString)
        else
            gg.alert(script_title .. "\n\n" .. emoji .. " " .. headerString .. " " .. emoji)
        end
    end,
    Choice = function(headerString, bodyString, emoji)
        if #bodyString > 0 then
            return script_title .. "\n\n" .. emoji .. " " .. headerString .. " " .. emoji .. "\n\n" .. bodyString
        else
            return script_title .. "\n\n" .. emoji .. " " .. headerString .. " " .. emoji
        end
    end,
    Prompt = function(headerString, emoji)
        return script_title .. "\n\n" .. emoji .. " " .. headerString .. " " .. emoji
    end
}

arch = gg.getTargetInfo()
local armType = arch.x64 and 6 or 4

local function getSelectedItems()
  local items = {}
  local tab = gg.getActiveTab()
  if tab == gg.TAB_SEARCH then
    items = gg.getSelectedResults()
    _tab = "search" -- TAB_SEARCH
  elseif tab == gg.TAB_SAVED_LIST then
    items = gg.getSelectedListItems()
    _tab = "list" --TAB_SAVED_LIST
  elseif tab == gg.TAB_MEMORY_EDITOR then
    for index, addr in ipairs(gg.getSelectedElements()) do
      items[index] = {address = addr}
    end
    _tab = "memory" -- TAB_MEMORY_EDITOR
  end
  return items, _tab
end

local x64 = arch.x64
local asmLT9 = {
    op = gg.allocatePage(1|2|4),
    op_int = x64 and "~A8 MOV W0, #" or "~A MOVT R0, #",
    op_return = (x64 and "~A8 RET" or "~A BX	 LR"),
    
    gV = function(self, value, flags)
        gg.setValues({
        {address = self.op, flags = 32, value = 0},
        {address = self.op, flags = flags, value = value},
        {address = self.op, flags = 2, value = 0},
        })
        gg.setValues({{address = self.op+2, flags = 2, value = gg.getValues({{address = self.op+2, flags = 2}})[1].value+1}})
        return gg.getValues({{address = self.op, flags = 4}})[1].value
    end,
    getInt = function(self, value, param)
        local param = (param and self.op_int:gsub(0, param) or self.op_int)
        if value > 0 and value < 65535 and not x64 then
            return param:gsub("T", "W") .. value
        elseif x64 and value > -65535 and value < 65535 then
            return param .. value
        end
        local value = self:gV(value, 4)
        return param .. (x64 and value or value / 65535)
    end,
    getFloat = function(self, value, param)
        local param = (param and self.op_int:gsub(0, param) or self.op_int)
        if x64 then
            return param .. self:gV(value, 16)
        else
            self:gV(value, 16)
            return param .. gg.getValues({{address = self.op+2, flags = 2}})[1].value
        end
    end,
}

end)__bundle_register("index", function(require, _LOADED, __bundle_register, __bundle_modules)
require("utils.__il2cppconst")
require("il2cpp")

---@class ClassInfoRaw
---@field ClassName string | nil
---@field ClassInfoAddress number
---@field ImageName string

---@class ClassInfo
---@field ClassName string
---@field ClassAddress string
---@field Methods MethodInfo[] | nil
---@field Fields FieldInfo[] | nil
---@field Parent ParentClassInfo | nil
---@field ClassNameSpace string
---@field StaticFieldData number | nil
---@field IsEnum boolean
---@field TypeMetadataHandle number
---@field InstanceSize number
---@field Token string
---@field ImageName string
---@field GetFieldWithName fun(self : ClassInfo, name : string) : FieldInfo | nil @Get FieldInfo by Field Name. If Fields weren't dumped, then this function return `nil`. Also, if Field isn't found by name, then function will return `nil`
---@field GetMethodsWithName fun(self : ClassInfo, name : string) : MethodInfo[] | nil @Get MethodInfo[] by MethodName. If Methods weren't dumped, then this function return `nil`. Also, if Method isn't found by name, then function will return `table with zero size`
---@field GetFieldWithOffset fun(self : ClassInfo, fieldOffset : number) : FieldInfo | nil

---@class ParentClassInfo
---@field ClassName string
---@field ClassAddress string

---@class FieldInfoRaw
---@field FieldInfoAddress number
---@field ClassName string | nil


---@class ClassMemory
---@field config ClassConfig
---@field result ClassInfo[] | ErrorSearch
---@field len number
---@field isNew boolean | nil

---@class MethodMemory
---@field len number
---@field result MethodInfo[] | ErrorSearch
---@field isNew boolean | nil

---@class FieldInfo
---@field ClassName string 
---@field ClassAddress string 
---@field FieldName string
---@field Offset string
---@field IsStatic boolean
---@field Type string
---@field IsConst boolean
---@field Access string
---@field GetConstValue fun(self : FieldInfo) : nil | string | number


---@class MethodInfoRaw
---@field MethodName string | nil
---@field Offset number | nil
---@field MethodInfoAddress number
---@field ClassName string | nil
---@field MethodAddress number


---@class ErrorSearch
---@field Error string


---@class MethodInfo
---@field MethodName string
---@field Offset string
---@field AddressInMemory string
---@field MethodInfoAddress number
---@field ClassName string
---@field ClassAddress string
---@field ParamCount number
---@field ReturnType string
---@field IsStatic boolean
---@field IsAbstract boolean
---@field Access string


---@class Il2cppApi
---@field FieldApiOffset number
---@field FieldApiType number
---@field FieldApiClassOffset number
---@field ClassApiNameOffset number
---@field ClassApiMethodsStep number
---@field ClassApiCountMethods number
---@field ClassApiMethodsLink number
---@field ClassApiFieldsLink number
---@field ClassApiFieldsStep number
---@field ClassApiCountFields number
---@field ClassApiParentOffset number
---@field ClassApiNameSpaceOffset number
---@field ClassApiStaticFieldDataOffset number
---@field ClassApiEnumType number
---@field ClassApiEnumRsh number
---@field ClassApiTypeMetadataHandle number
---@field ClassApiInstanceSize number
---@field ClassApiToken number
---@field MethodsApiClassOffset number
---@field MethodsApiNameOffset number
---@field MethodsApiParamCount number
---@field MethodsApiReturnType number
---@field MethodsApiFlags number
---@field typeDefinitionsSize number
---@field typeDefinitionsOffset number
---@field stringOffset number
---@field fieldDefaultValuesOffset number
---@field fieldDefaultValuesSize number
---@field fieldAndParameterDefaultValueDataOffset number
---@field TypeApiType number
---@field Il2CppTypeDefinitionApifieldStart number
---@field MetadataRegistrationApitypes number


---@class ClassConfig
---@field Class number | string @Class Name or Address Class
---@field FieldsDump boolean
---@field MethodsDump boolean


---@class Il2cppConfig
---@field libilcpp table | nil
---@field globalMetadata table | nil
---@field il2cppVersion number | nil
---@field globalMetadataHeader number | nil
---@field metadataRegistration number | nil


---@class Il2CppTypeDefinitionApi
---@field fieldStart number

---@class MethodFlags
---@field Access string[]
---@field METHOD_ATTRIBUTE_MEMBER_ACCESS_MASK number
---@field METHOD_ATTRIBUTE_STATIC number
---@field METHOD_ATTRIBUTE_ABSTRACT number


---@class FieldFlags
---@field Access string[]
---@field FIELD_ATTRIBUTE_FIELD_ACCESS_MASK number
---@field FIELD_ATTRIBUTE_STATIC number
---@field FIELD_ATTRIBUTE_LITERAL number


return Il2cpp
end)__bundle_register("utils.__il2cppconst", function(require, _LOADED, __bundle_register, __bundle_modules)
local AndroidInfo = require("utils.androidinfo")

--- Định nghĩa kiểu dữ liệu cho các hằng số Il2Cpp theo cấu trúc mới
--- @class Il2CppVersionedConstant
--- @field offset number | boolean | any Giá trị offset, kích thước hoặc hằng số khác. Có thể là biểu thức ternary (conditional)
--- @field version table Khoảng phiên bản áp dụng
--- @field version.min number Phiên bản tối thiểu (inclusive)
--- @field version.max number Phiên bản tối đa (inclusive)

--- @type table<string, Il2CppVersionedConstant[]>
Il2CppConst = {
    FieldApiOffset = {
        { offset = 0xC, version = { min = 20, max = 23 } },
        { offset = AndroidInfo.platform and 0x18 or 0xC, version = { min = 24, max = 31 } },
    },
    FieldApiType = {
        { offset = 0x4, version = { min = 20, max = 23 } },
        { offset = AndroidInfo.platform and 0x8 or 0x4, version = { min = 24, max = 31 } },
    },
    FieldApiClassOffset = {
        { offset = 0x8, version = { min = 20, max = 23 } },
        { offset = AndroidInfo.platform and 0x10 or 0x8, version = { min = 24, max = 31 } },
    },
    ClassApiNameOffset = {
        { offset = 0x8, version = { min = 20, max = 23 } },
        { offset = AndroidInfo.platform and 0x10 or 0x8, version = { min = 24, max = 31 } },
    },
    ClassApiMethodsStep = {
        { offset = 2, version = { min = 20, max = 23 } },
        { offset = AndroidInfo.platform and 3 or 2, version = { min = 24, max = 31 } },
    },
    ClassApiCountMethods = {
        { offset = 0x9C, version = { min = 20, max = 21 } },
        { offset = 0x94, version = { min = 22, max = 22 } },
        { offset = 0x9C, version = { min = 23, max = 23 } },
        { offset = AndroidInfo.platform and 0x110 or 0xA8, version = { min = 24.1, max = 24.1 } },
        { offset = AndroidInfo.platform and 0x114 or 0xAC, version = { min = 24, max = 24 } },
        { offset = AndroidInfo.platform and 0x118 or 0xA4, version = { min = 24.2, max = 24.5 } },
        { offset = AndroidInfo.platform and 0x11C or 0xA4, version = { min = 27, max = 29 } }, -- Bao gồm 27, 27.1, 27.2, 29
        { offset = AndroidInfo.platform and 0x120 or 0xAC, version = { min = 29.1, max = 31 } }, -- Bao gồm 29.1 và 31
    },
    ClassApiMethodsLink = {
        { offset = 0x3C, version = { min = 20, max = 22 } },
        { offset = 0x40, version = { min = 23, max = 23 } },
        { offset = AndroidInfo.platform and 0x98 or 0x4C, version = { min = 24, max = 31 } },
    },
    ClassApiFieldsLink = {
        { offset = 0x30, version = { min = 20, max = 22 } },
        { offset = 0x34, version = { min = 23, max = 23 } },
        { offset = AndroidInfo.platform and 0x80 or 0x40, version = { min = 24, max = 31 } },
    },
    ClassApiFieldsStep = {
        { offset = 0x18, version = { min = 20, max = 23 } },
        { offset = AndroidInfo.platform and 0x28 or 0x18, version = { min = 24, max = 24 } },
        { offset = AndroidInfo.platform and 0x20 or 0x14, version = { min = 24.1, max = 31 } }, -- Bao gồm 24.1-24.5, 27-27.2, 29-31
    },
    ClassApiCountFields = {
        { offset = 0xA0, version = { min = 20, max = 21 } },
        { offset = 0x98, version = { min = 22, max = 22 } },
        { offset = 0xA0, version = { min = 23, max = 23 } },
        { offset = AndroidInfo.platform and 0x114 or 0xAC, version = { min = 24.1, max = 24.1 } },
        { offset = AndroidInfo.platform and 0x118 or 0xB0, version = { min = 24, max = 24 } },
        { offset = AndroidInfo.platform and 0x11C or 0xA8, version = { min = 24.2, max = 24.5 } },
        { offset = AndroidInfo.platform and 0x120 or 0xA8, version = { min = 27, max = 29 } }, -- Bao gồm 27, 27.1, 27.2, 29
        { offset = AndroidInfo.platform and 0x124 or 0xAC, version = { min = 29.1, max = 31 } }, -- Bao gồm 29.1 và 31 (Đã sửa)
    },
    ClassApiParentOffset = {
        { offset = 0x24, version = { min = 20, max = 23 } },
        { offset = AndroidInfo.platform and 0x58 or 0x2C, version = { min = 24, max = 31 } },
    },
    ClassApiNameSpaceOffset = {
        { offset = 0xC, version = { min = 20, max = 23 } },
        { offset = AndroidInfo.platform and 0x18 or 0xC, version = { min = 24, max = 31 } },
    },
    ClassApiStaticFieldDataOffset = {
        { offset = 0x50, version = { min = 20, max = 21 } },
        { offset = 0x4C, version = { min = 22, max = 22 } },
        { offset = 0x50, version = { min = 23, max = 23 } },
        { offset = AndroidInfo.platform and 0xB8 or 0x5C, version = { min = 24, max = 31 } },
    },
    ClassApiEnumType = {
        { offset = 0xB0, version = { min = 20, max = 20 } },
        { offset = 0xB1, version = { min = 21, max = 21 } },
        { offset = 0xA9, version = { min = 22, max = 22 } },
        { offset = 0xB1, version = { min = 23, max = 23 } },
        { offset = AndroidInfo.platform and 0x126 or 0xBE, version = { min = 24.1, max = 24.1 } },
        { offset = AndroidInfo.platform and 0x129 or 0xC1, version = { min = 24, max = 24 } },
        { offset = AndroidInfo.platform and 0x12e or 0xBA, version = { min = 24.2, max = 24.5 } },
        { offset = AndroidInfo.platform and 0x12e or 0xBA, version = { min = 27, max = 27.1 } },
        { offset = AndroidInfo.platform and 0x132 or 0xBA, version = { min = 27.2, max = 31 } }, -- Bao gồm 27.2, 29, 29.1, và 31
    },
    ClassApiEnumRsh = {
        { offset = 2, version = { min = 20, max = 24 } }, -- Bao gồm 20-23 và 24
        { offset = 3, version = { min = 24.1, max = 24.5 } },
        { offset = 3, version = { min = 27, max = 27.1 } },
        { offset = 2, version = { min = 27.2, max = 31 } }, -- Bao gồm 27.2, 29, 29.1, và 31
    },
    ClassApiTypeMetadataHandle = {
        { offset = 0x2C, version = { min = 20, max = 23 } },
        { offset = AndroidInfo.platform and 0x68 or 0x34, version = { min = 24, max = 31 } },
    },
    ClassApiInstanceSize = {
        { offset = 0x78, version = { min = 20, max = 21 } },
        { offset = 0x70, version = { min = 22, max = 22 } },
        { offset = 0x78, version = { min = 23, max = 23 } },
        { offset = AndroidInfo.platform and 0xEC or 0x84, version = { min = 24.1, max = 24.1 } },
        { offset = AndroidInfo.platform and 0xF0 or 0x88, version = { min = 24, max = 24 } },
        { offset = AndroidInfo.platform and 0xF4 or 0x80, version = { min = 24.2, max = 24.5 } },
        { offset = AndroidInfo.platform and 0xF4 or 0x80, version = { min = 27, max = 27.1 } },
        { offset = AndroidInfo.platform and 0xF8 or 0x80, version = { min = 27.2, max = 31 } }, -- Bao gồm 27.2, 29, 29.1, và 31
    },
    ClassApiToken = {
        { offset = 0x98, version = { min = 20, max = 21 } },
        { offset = 0x90, version = { min = 22, max = 22 } },
        { offset = 0x98, version = { min = 23, max = 23 } },
        { offset = AndroidInfo.platform and 0x10c or 0xa4, version = { min = 24.1, max = 24.1 } },
        { offset = AndroidInfo.platform and 0x110 or 0xa8, version = { min = 24, max = 24 } },
        { offset = AndroidInfo.platform and 0x114 or 0xa0, version = { min = 24.2, max = 24.5 } },
        { offset = AndroidInfo.platform and 0x114 or 0xa0, version = { min = 27, max = 27.1 } },
        { offset = AndroidInfo.platform and 0x118 or 0xa0, version = { min = 27.2, max = 31 } }, -- Bao gồm 27.2, 29, 29.1, và 31
    },
    MethodsApiClassOffset = {
        { offset = 0xC, version = { min = 20, max = 23 } },
        { offset = AndroidInfo.platform and 0x18 or 0xC, version = { min = 24, max = 27.2 } }, -- Bao gồm 24, 24.1-24.5, 27-27.2
        { offset = AndroidInfo.platform and 0x20 or 0x10, version = { min = 29, max = 31 } }, -- Bao gồm 29, 29.1, và 31
    },
    MethodsApiNameOffset = {
        { offset = 0x8, version = { min = 20, max = 23 } },
        { offset = AndroidInfo.platform and 0x10 or 0x8, version = { min = 24, max = 27.2 } }, -- Bao gồm 24, 24.1-24.5, 27-27.2
        { offset = AndroidInfo.platform and 0x18 or 0xC, version = { min = 29, max = 31 } }, -- Bao gồm 29, 29.1, và 31
    },
    MethodsApiParamCount = {
        { offset = 0x2E, version = { min = 20, max = 23 } },
        { offset = AndroidInfo.platform and 0x4E or 0x2E, version = { min = 24, max = 24 } },
        { offset = AndroidInfo.platform and 0x4A or 0x2A, version = { min = 24.1, max = 24.5 } },
        { offset = AndroidInfo.platform and 0x4A or 0x2A, version = { min = 27, max = 27.2 } },
        { offset = AndroidInfo.platform and 0x52 or 0x2E, version = { min = 29, max = 31 } }, -- Bao gồm 29, 29.1, và 31
    },
    MethodsApiReturnType = {
        { offset = 0x10, version = { min = 20, max = 23 } },
        { offset = AndroidInfo.platform and 0x20 or 0x10, version = { min = 24, max = 27.2 } }, -- Bao gồm 24, 24.1-24.5, 27-27.2
        { offset = AndroidInfo.platform and 0x28 or 0x14, version = { min = 29, max = 31 } }, -- Bao gồm 29, 29.1, và 31
    },
    MethodsApiFlags = {
        { offset = 0x28, version = { min = 20, max = 23 } },
        { offset = AndroidInfo.platform and 0x48 or 0x28, version = { min = 24, max = 24 } },
        { offset = AndroidInfo.platform and 0x44 or 0x24, version = { min = 24.1, max = 24.5 } },
        { offset = AndroidInfo.platform and 0x44 or 0x24, version = { min = 27, max = 27.2 } },
        { offset = AndroidInfo.platform and 0x4C or 0x28, version = { min = 29, max = 31 } }, -- Bao gồm 29, 29.1, và 31
    },
    typeDefinitionsSize = {
        { offset = 0x70, version = { min = 20, max = 20 } },
        { offset = 0x78, version = { min = 21, max = 23 } },
        { offset = 100, version = { min = 24.1, max = 24.1 } },
        { offset = 104, version = { min = 24, max = 24 } },
        { offset = 92, version = { min = 24.2, max = 24.5 } },
        { offset = 88, version = { min = 27, max = 31 } }, -- Bao gồm 27, 27.1, 27.2, 29, 29.1, và 31
    },
    typeDefinitionsOffset = {
        { offset = 0xA0, version = { min = 20, max = 31 } },
    },
    stringOffset = {
        { offset = 0x18, version = { min = 20, max = 31 } },
    },
    fieldDefaultValuesOffset = {
        { offset = 0x40, version = { min = 20, max = 31 } },
    },
    fieldDefaultValuesSize = {
        { offset = 0x44, version = { min = 20, max = 31 } },
    },
    fieldAndParameterDefaultValueDataOffset = {
        { offset = 0x48, version = { min = 20, max = 31 } },
    },
    TypeApiType = {
        { offset = 0x6, version = { min = 20, max = 23 } },
        { offset = AndroidInfo.platform and 0xA or 0x6, version = { min = 24, max = 31 } },
    },
    Il2CppTypeDefinitionApifieldStart = {
        { offset = 0x38, version = { min = 20, max = 20 } },
        { offset = 0x40, version = { min = 21, max = 22 } },
        { offset = 0x30, version = { min = 23, max = 24 } }, -- Bao gồm 23 và 24
        { offset = 0x2C, version = { min = 24.1, max = 24.1 } },
        { offset = 0x24, version = { min = 24.2, max = 24.5 } },
        { offset = 0x20, version = { min = 27, max = 31 } }, -- Bao gồm 27, 27.1, 27.2, 29, 29.1, và 31
    },
    MetadataRegistrationApitypes = {
        { offset = 0x1C, version = { min = 20, max = 23 } },
        { offset = AndroidInfo.platform and 0x38 or 0x1C, version = { min = 24, max = 31 } },
    },
}


setmetatable(Il2CppConst, {
    __call = function(self, version)
        local results = {}
        for k, v in pairs(self) do
            if type(v) == 'table' and #v > 0 then
                for _, entry in ipairs(v) do
                    if version >= entry.version.min and version <= entry.version.max then
                        -- Trả về giá trị offset cho phiên bản này
                        results[k] = entry.offset
                    end
                end
            end
        end
        return results
    end
})

---@class Il2CppFlags
---@field Method MethodFlags
---@field Field FieldFlags
Il2CppFlags = {
    Method = {
        METHOD_ATTRIBUTE_MEMBER_ACCESS_MASK = 0x0007,
        Access = {
            "private", -- METHOD_ATTRIBUTE_PRIVATE (0)
            "internal", -- METHOD_ATTRIBUTE_FAM_AND_ASSEM (1) -- Value is 3, "internal" name is for 3 and 5?
            "internal", -- METHOD_ATTRIBUTE_ASSEMBLY (2)
            "protected", -- METHOD_ATTRIBUTE_FAMILY (4)
            "protected internal", -- METHOD_ATTRIBUTE_FAM_OR_ASSEM (5)
            "public", -- METHOD_ATTRIBUTE_PUBLIC (6)
        },
        -- Correct mapping based on C# MethodAttributes enum values
        AccessByValue = {
            [0] = "private",
            [1] = "private", -- Family and Assembly
            [2] = "internal", -- Assembly
            [3] = "internal", -- Family and Assembly
            [4] = "protected", -- Family
            [5] = "protected internal", -- Family or Assembly
            [6] = "public",
            [7] = "public", -- Compiler Controlled (should not be used)
        },
        METHOD_ATTRIBUTE_STATIC = 0x0010,
        METHOD_ATTRIBUTE_ABSTRACT = 0x0400,
        METHOD_ATTRIBUTE_VIRTUAL = 0x0020,
        METHOD_ATTRIBUTE_FINAL = 0x0004, -- Added from common attributes
        METHOD_ATTRIBUTE_ASSEMBLY = 0x0004, -- Correct value for ASSEMBLY access
        METHOD_ATTRIBUTE_FAMILY = 0x0005, -- Correct value for FAMILY access
        METHOD_ATTRIBUTE_FAM_AND_ASSEM = 0x0002, -- Correct value
        METHOD_ATTRIBUTE_FAM_OR_ASSEM = 0x0003, -- Correct value
        METHOD_ATTRIBUTE_PUBLIC = 0x0006, -- Correct value
        METHOD_ATTRIBUTE_PRIVATE = 0x0001, -- Correct value
    },
    Field = {
        FIELD_ATTRIBUTE_FIELD_ACCESS_MASK = 0x0007,
        Access = {
            "private", -- FIELD_ATTRIBUTE_PRIVATE (0)
            "internal", -- FIELD_ATTRIBUTE_FAM_AND_ASSEM (1) -- Value is 3, "internal" name is for 3 and 5?
            "internal", -- FIELD_ATTRIBUTE_ASSEMBLY (2)
            "protected", -- FIELD_ATTRIBUTE_FAMILY (4)
            "protected internal", -- FIELD_ATTRIBUTE_FAM_OR_ASSEM (5)
            "public", -- FIELD_ATTRIBUTE_PUBLIC (6)
        },
        -- Correct mapping based on C# FieldAttributes enum values
         AccessByValue = {
            [0] = "private", -- Compiler Controlled
            [1] = "private", -- Private
            [2] = "internal", -- Assembly
            [3] = "internal", -- Family and Assembly
            [4] = "protected", -- Family
            [5] = "protected internal", -- Family or Assembly
            [6] = "public",
        },
        FIELD_ATTRIBUTE_STATIC = 0x0010,
        FIELD_ATTRIBUTE_LITERAL = 0x0040,
        FIELD_ATTRIBUTE_INIT_ONLY = 0x0020, -- Added from common attributes
    },
     Class = { -- TypeAttributes
         TYPE_ATTRIBUTES_VISIBILITY_MASK = 0x00000007,
         VisibilityByValue = {
             [0] = "NotPublic", -- Should not be used
             [1] = "Public",
             [2] = "NestedPublic",
             [3] = "NestedPrivate",
             [4] = "NestedFamily",
             [5] = "NestedAssembly",
             [6] = "NestedFamANDAssem",
             [7] = "NestedFamORAssem",
         },
         TYPE_ATTRIBUTE_ABSTRACT = 0x00000080,
         TYPE_ATTRIBUTE_SEALED = 0x00000100,
         TYPE_ATTRIBUTE_INTERFACE = 0x00000020,
         TYPE_ATTRIBUTE_ENUM = 0x00000008, -- Check if this is the flag in TypeAttributes or Il2CppTypeDefinition.bitfield
         TYPE_ATTRIBUTE_VALUE_TYPE = 0x00000010, -- Check if this is the flag in TypeAttributes or Il2CppTypeDefinition.bitfield
     }
}

end)__bundle_register("utils.androidinfo", function(require, _LOADED, __bundle_register, __bundle_modules)
local info = gg.getTargetInfo()
local AndroidInfo = {
    platform = info.x64,
    sdk = info.targetSdkVersion,
    pkg = gg.getTargetPackage(),
    path = gg.EXT_CACHE_DIR .. "/" .. info.packageName .. "-" .. info.versionCode .. "-" .. (info.x64 and "64" or "32")
}

return AndroidInfo
end)__bundle_register("il2cpp", function(require, _LOADED, __bundle_register, __bundle_modules)
local Il2cppMemory = require("utils.il2cppmemory")
local VersionEngine = require("utils.version")
local AndroidInfo = require("utils.androidinfo")
local Searcher = require("utils.universalsearcher")
local PatchApi = require("utils.patchapi")
local Cli = require("utils.cli")
require("utils.dictionary")


---@class Il2cpp
local Il2cppBase = {
    Searcher = Searcher,
    cli = Cli,
    il2cppStart = 0,
    il2cppEnd = 0,
    globalMetadataStart = 0,
    globalMetadataEnd = 0,
    globalMetadataHeader = 0,
    MainType = AndroidInfo.platform and gg.TYPE_QWORD or gg.TYPE_DWORD,
    pointSize = AndroidInfo.platform and 8 or 4,
    regionClass = (4 | 32 | -2080896),
    regionType = {Ca = 4, A = 32, O = -2080896},
    ---@type Il2CppTypeDefinitionApi
    Il2CppTypeDefinitionApi = {},
    Utf8ToStringCache = {},
    MetadataRegistrationApi = require("il2cppstruct.metadataRegistration"),
    TypeApi = require("il2cppstruct.type"),
    MethodsApi = require("il2cppstruct.method"),
    GlobalMetadataApi = require("il2cppstruct.globalmetadata"),
    FieldApi = require("il2cppstruct.field"),
    ClassApi = require("il2cppstruct.class"),
    ObjectApi = require("il2cppstruct.object"),
    ClassInfoApi = require("il2cppstruct.api.classinfo"),
    FieldInfoApi = require("il2cppstruct.api.fieldinfo"),
    ---@type MyString
    String = require("il2cppstruct.il2cppstring"),
    MemoryManager = require("utils.malloc"),
    --- Patch `Bytescodes` to `add`
    ---
    --- Example:
    --- arm64: 
    --- `mov w0,#0x1`
    --- `ret`
    ---
    --- `Il2cpp.PatchesAddress(0x100, "\x20\x00\x80\x52\xc0\x03\x5f\xd6")`
    ---@param add number
    ---@param Bytescodes string
    ---@return Patch
    PatchesAddress = function(add, Bytescodes)
        local patchCode = {}
        for code in string.gmatch(Bytescodes, '.') do
            patchCode[#patchCode + 1] = {
                address = add + #patchCode,
                value = string.byte(code),
                flags = gg.TYPE_BYTE
            }
        end
        ---@type Patch
        local patch = PatchApi:Create(patchCode)
        patch:Patch()
        return patch
    end,


    --- Searches for a method, or rather information on the method, by name or by offset, you can also send an address in memory to it.
    --- 
    --- Return table with information about methods.
    ---@generic TypeForSearch : number | string
    ---@param searchParams TypeForSearch[] @TypeForSearch = number | string
    ---@return table<number, MethodInfo[] | ErrorSearch>
    FindMethods = function(searchParams)
        Il2cppMemory:SaveResults()
        for i = 1, #searchParams do
            ---@type number | string
            searchParams[i] = Il2cpp.MethodsApi:Find(searchParams[i])
        end
        Il2cppMemory:ClearSavedResults()
        return searchParams
    end,


    --- Searches for a class, by name, or by address in memory.
    --- 
    --- Return table with information about class.
    ---@param searchParams ClassConfig[]
    ---@return table<number, ClassInfo[] | ErrorSearch>
    FindClass = function(searchParams)
        Il2cppMemory:SaveResults()
        for i = 1, #searchParams do
            searchParams[i] = Il2cpp.ClassApi:Find(searchParams[i])
        end
        Il2cppMemory:ClearSavedResults()
        return searchParams
    end,


    --- Searches for an object by name or by class address, in memory.
    --- 
    --- In some cases, the function may return an incorrect result for certain classes. For example, sometimes the garbage collector may not have time to remove an object from memory and then a `fake object` will appear or for a turnover, the object may still be `not implemented` or `not created`.
    ---
    --- Returns a table of objects.
    ---@param searchParams table
    ---@return table
    FindObject = function(searchParams)
        Il2cppMemory:SaveResults()
        for i = 1, #searchParams do
            searchParams[i] = Il2cpp.ObjectApi:Find(Il2cpp.ClassApi:Find({Class = searchParams[i]}))
        end
        Il2cppMemory:ClearSavedResults()
        return searchParams
    end,
    
    FindHead = function(searchParams, FieldsDump, MethodsDump)
        local clazz = ""
        local results = {}
        for i, v in pairs(searchParams) do
           -- print(v.address)
            local results = Il2cpp.ObjectApi.FindHead(v.address)
            local Info = string.format("[%d]: address: %X // 0x%X\n\n", i, v.address, v.address - results.address)
            local classAddress = Il2cpp.FixValue(results.value)
            clazz = clazz..Info..tostring(Il2cpp.FindClass({{Class = classAddress, FieldsDump = FieldsDump, MethodsDump = MethodsDump}})[1][1]).."\n\n"
            results[#results+1] = {address = v.address, flags = v.flags, name = clazz}
        end
        return clazz, results;--(#searchParams ~= 0 and table.concat(searchParams) or "class: 0");
    end,


    --- Searches for a field, or rather information about the field, by name or by address in memory.
    --- 
    --- Return table with information about fields.
    ---@generic TypeForSearch : number | string
    ---@param searchParams TypeForSearch[] @TypeForSearch = number | string
    ---@return table<number, FieldInfo[] | ErrorSearch>
    FindFields = function(searchParams)
        Il2cppMemory:SaveResults()
        for i = 1, #searchParams do
            ---@type number | string
            local searchParam = searchParams[i]
            local searchResult = Il2cppMemory:GetInformationOfField(searchParam)
            if not searchResult then
                searchResult = Il2cpp.FieldApi:Find(searchParam)
                Il2cppMemory:SetInformationOfField(searchParam, searchResult)
            end
            searchParams[i] = searchResult
        end
        Il2cppMemory:ClearSavedResults()
        return searchParams
    end,


    ---@param Address number
    ---@param length? number
    ---@return string
    Utf8ToString = function(Address, length)
        if Il2cpp.Utf8ToStringCache[Address] then
            return Il2cpp.Utf8ToStringCache[Address]
        end
        local chars, char = {}, {
            address = Address,
            flags = gg.TYPE_BYTE
        }
        if not length then
            while true do
                _char = string.char(gg.getValues({char})[1].value & 0xFF)
                chars[#chars + 1] = _char
                char.address = char.address + 0x1
                if string.find(_char, "[%z%s]") then break end
            end
            local Text = table.concat(chars, "", 1, #chars - 1)
            Il2cpp.Utf8ToStringCache[Address] = Text
            return Text
        else
            for i = 1, length do
                local _char = gg.getValues({char})[1].value
                chars[i] = string.char(_char & 0xFF)
                char.address = char.address + 0x1
            end
            local Text = table.concat(chars)
            Il2cpp.Utf8ToStringCache[Address] = Text
            return Text
        end
    end,


    ---@param bytes string
    ChangeBytesOrder = function(bytes)
        local newBytes, index, lenBytes = {}, 0, #bytes / 2
        for byte in string.gmatch(bytes, "..") do
            newBytes[lenBytes - index] = byte
            index = index + 1
        end
        return table.concat(newBytes)
    end,


    FixValue = function(val)
        return AndroidInfo.platform and val & 0x00FFFFFFFFFFFFFF or val & 0xFFFFFFFF
    end,


    GetValidAddress = function(Address)
        local lastByte = Address & 0x000000000000000F
        local delta = 0
        local checkTable = {[12] = true, [4] = true, [8] = true, [0] = true}
        while not checkTable[lastByte - delta] do
            delta = delta + 1
        end
        return Address - delta
    end,


    ---@param self Il2cpp
    ---@param address number | string
    SearchPointer = function(self, address)
        address = self.ChangeBytesOrder(type(address) == 'number' and string.format('%X', address) or address)
        gg.searchNumber('h ' .. address)
        gg.refineNumber('h ' .. address:sub(1, 6))
        gg.refineNumber('h ' .. address:sub(1, 2))
        local FindsResult = gg.getResults(gg.getResultsCount())
        gg.clearResults()
        return FindsResult
    end,
    
    GetPtr = function(self, address)
        return Il2cpp.FixValue(gg.getValues({{address = Il2cpp.FixValue(address), flags = Il2cpp.MainType}})[1].value)
    end,
    
    FindStringCache = {},
    FindString = function(Name)
    	if Il2cpp.FindStringCache[Name] then
    	    return Il2cpp.FindStringCache[Name]
    	end
    	local result, chars = {}, {};
    	for key, name in pairs({string.lower(Name),string.upper(Name),Name}) do
    		local Name = ":" .. name;
    		gg.setRanges(-1);
    		gg.clearResults();
    		gg.searchNumber(Name, gg.TYPE_BYTE, false, gg.SIGN_EQUAL, Il2cpp.GlobalMetadataApi.stringDefinitions, Il2cpp.globalMetadataEnd);
	    	gg.refineNumber(Name:sub(1, 2), gg.TYPE_BYTE);
    		local t = gg.getResults(gg.getResultsCount());
    		gg.clearResults();
    		for k, v in pairs(t) do
	    		local char = {address=(v.address + 1),flags=1};
    			while true do
    			    _value = gg.getValues({char})[1].value;
    				_char = string.char(_value & 255);
    				char.address = char.address - 1;
    				if string.find(_char, "[%z%s]") then break end
    			end
    			local address = char.address + 2;
    			local name = Il2cpp.Utf8ToString(address);
    			chars[#chars + 1] = name;
    			result[#result + 1] = {address=address,flags=1,name=name};
    		end
    	end
    	Il2cpp.FindStringCache[Name] = {chars,result};
    	return {chars,result};
    end,
    FindPointerStringCache = {},
    FindPointerString = function(Results)
        if Il2cpp.FindPointerStringCache[tostring(Results)] then
    	    return Il2cpp.FindPointerStringCache[tostring(Results)]
    	end
    	local pointerString = pointerString or {}
    	local ResultsPointer = {}
        gg.clearResults()
        gg.setRanges(Il2cpp.regionClass)
        gg.loadResults(Results)
        gg.searchPointer(0);
        if gg.getResultsCount() == 0 and AndroidInfo.platform and AndroidInfo.sdk >= 30 then
            for i, v in pairs(Results) do
                gg.clearResults()
                gg.searchNumber(tostring(v.address | 0xB400000000000000), Il2cpp.MainType, nil, nil, #pointerString ~= 0 and pointerString[1].start or nil, #pointerString ~= 0 and pointerString[#pointerString]["end"] or nil)
                local results = gg.getResults(gg.getResultsCount());
                gg.clearResults()
                if #results ~= 0 then
                    if #pointerString == 0 then
                        for k, v in ipairs(gg.getRangesList()) do
                            if (v.state == 'Ca' or v.state == 'A' or v.state == 'O') then
                                pointerString[#pointerString + 1] = (Il2cpp.FixValue(v.start) <= Il2cpp.FixValue(results[1].address) and Il2cpp.FixValue(results[1].address) < Il2cpp.FixValue(v['end'])) and v or nil
                            end
                        end
                        gg.setRanges(#pointerString ~= 0 and -1 or Il2cpp.regionClass)
                    end
                    if Il2cpp.regionClass == -2080860 then
                        local Range = gg.getValuesRange(gg.getResults(1))[1]
                        Il2cpp.regionClass = Il2cpp.regionType[Range];
                        gg.setRanges(Il2cpp.regionClass);
                        Il2cpp.pointerProtect = true
                    end
                    for ii, vv in ipairs(results) do
                        ResultsPointer[#ResultsPointer+1] = vv
                    end
                end
            end
        end
        local ResultsPointer = #ResultsPointer > 0 and ResultsPointer or gg.getResults(gg.getResultsCount())
        gg.clearResults()
        if #ResultsPointer == 0 then
            return false
        end
        gg.loadResults(ResultsPointer)
        local ResultsPointer = gg.getResults(gg.getResultsCount())
        gg.clearResults()
        Il2cpp.FindPointerStringCache[tostring(Results)] = ResultsPointer
        return ResultsPointer
    end,
    FindMethodsApi = function(searchParams)
        local searchParams = type(searchParams) == "table" and searchParams or Il2cpp.FindPointerString(Il2cpp.FindString(searchParams)[2])
        local results = Il2cpp.MethodsApi:FindMethodWithFindString(searchParams) or {}
        function results:AddList(self)
            local result = {}
            for i, v in ipairs(results) do
                local dumpMethod = {
                    "\tClass: ", v.ClassName, "\n",
                    "\tOffset: 0x", v.Offset, " VA: 0x", v.AddressInMemory, "\n",
                    "\t", v.Access, " ",  v.IsStatic and "static " or "", v.IsAbstract and "abstract " or "", v.ReturnType, " ", v.MethodName, "(" .. v.ParamType .. ") { } \n"
                }
                result[i] = {address = tonumber(v.AddressInMemory, 16), flags = 4, name = table.concat(dumpMethod)}
            end
            gg.addListItems(result)
        end
        function results:ClearList(self)
            return gg.removeListItems(result or {})
        end
        return results
    end,
    
    FindClassApi = function(searchParams, FieldsDump, MethodsDump)
        local searchParams = type(searchParams) == "table" and searchParams or Il2cpp.FindPointerString(Il2cpp.FindString(searchParams)[2])
        local results = Il2cpp.ClassApi:FindClassWithFindString(searchParams, FieldsDump, MethodsDump) or {}
         function results:Dump(self)
            local result = {}
            for i, v in pairs(results) do
                result[i] = tostring(results[i])
            end
            return table.concat(result, "\n")
        end
        function results:AddList(self)
            local result = {}
            for i, v in ipairs(results) do
                result[i] = {address = tonumber(v.ClassAddress, 16), flags = Il2cpp.MainType, name = tostring(results[i])}
            end
            gg.addListItems(result)
        end
        function results:ClearList(self)
            return gg.removeListItems(result or {})
        end
        return results
    end,
    FindFieldsApi = function(searchParams)
        local searchParams = type(searchParams) == "table" and searchParams or Il2cpp.FindPointerString(Il2cpp.FindString(searchParams)[2])
        local results = Il2cpp.FieldApi:FindFieldWithFindString(searchParams) or {}
        function results:AddList(self)
            result = {}
            local class = {}
            for i, v in ipairs(results) do               
                local name = "Class: "..v.ClassName .. "\n"
                local dumpField = {
                    v.Access, " ", v.IsStatic and "static " or "", v.IsConst and "const " or "", v.Type, " ", v.FieldName, v.Value and " = " or "; // 0x", v.Value and v.Value .. ";" or v.Offset, "\n"
                }
                name = name .. table.concat(dumpField)
                result[#result+1] = {address = tonumber(v.FieldInfoAddress, 16), flags = Il2cpp.MainType, name = name}
            end
            gg.addListItems(result)
        end
        function results:ClearList(self)
            return gg.removeListItems(result or {})
        end
        return results
    end,
    
    searchName = function(searchParams, kind)
        local kind = kind or {}
        local searchParams = type(searchParams) == "table" and searchParams or (kind.Api and Il2cpp.FindPointerString(Il2cpp.FindString(searchParams)[2]) or Il2cpp.GlobalMetadataApi.GetPointersToString(searchParams))
        local results = {}
        if kind.Class then
            results.Class = Il2cpp.ClassApi:FindClassWithFindString(searchParams, kind.Class.Fields, kind.Class.Methods) or {}
            function results.Class:AddList(self)
                local result = {}
                for i, v in ipairs(results.Class) do
                    result[i] = {address = tonumber(v.ClassAddress, 16), flags = Il2cpp.MainType, name = tostring(results.Class[i])}
                end
                gg.addListItems(result)
            end
        end
        if kind.Fields then
            results.Fields = Il2cpp.FieldApi:FindFieldWithFindString(searchParams) or {}
            function results.Fields:AddList(self)
                local result = {}
                for i, v in ipairs(results.Fields) do               
                    local name = "Class: "..v.ClassName .. "\n"
                    local dumpField = {
                        v.Access, " ", v.IsStatic and "static " or "", v.IsConst and "const " or "", v.Type, " ", v.FieldName, v.Value and " = " or "; // 0x", v.Value and v.Value .. ";" or v.Offset, "\n"
                    }
                    name = name .. table.concat(dumpField)
                    result[#result+1] = {address = tonumber(v.FieldInfoAddress, 16), flags = Il2cpp.MainType, name = name}
                end
                gg.addListItems(result)
            end
        end
        if kind.Methods then
            results.Methods = Il2cpp.MethodsApi:FindMethodWithFindString(searchParams) or {}
            function results.Methods:AddList(self)
                local result = {}
                for i, v in ipairs(results.Methods) do
                    local dumpMethod = {
                        "\tClass: ", v.ClassName, "\n",
                        "\tOffset: 0x", v.Offset, " VA: 0x", v.AddressInMemory, "\n",
                        "\t", v.Access, " ",  v.IsStatic and "static " or "", v.IsAbstract and "abstract " or "", v.ReturnType, " ", v.MethodName, '(' .. v.ParamType:gsub("{", ''):gsub("}", ''):gsub("_", " "):gsub("'", "") .. ") { } \n"
                    }
                    result[i] = {address = tonumber(v.AddressInMemory, 16), flags = 4, name = table.concat(dumpMethod)}
                end
                gg.addListItems(result)
            end
        end
        function results:AddList(self)
            if results.Class then
                results.Class:AddList()
            end
            if results.Fields then
                results.Fields:AddList()
            end
            if results.Methods then
                results.Methods:AddList()
            end
        end
        return results
    end,
    
    FindApi = function(searchParams, FieldsDump, MethodsDump)
        local results = {Class = Il2cpp.FindClassApi(searchParams, FieldsDump, MethodsDump), Fields = Il2cpp.FindFieldsApi(searchParams), Methods = Il2cpp.FindMethodsApi(searchParams)}
        function results:AddList(self)
            local Class = results.Class
            local Fields = results.Fields
            local Methods = results.Methods;
            if Class then
                Class:AddList()
            end
            if Fields then
                Fields:AddList()
            end
            if Methods then
                Methods:AddList()
            end
        end
        function results:ClearList(self)
            local Class = results.Class
            local Fields = results.Fields
            local Methods = results.Methods
            if Class then
                Class:ClearList()
            end
            if Fields then
                Fields:ClearList()
            end
            if Methods then
                Methods:ClearList()
            end
        end
        return results
    end,
    
    
    
    Dumper = function(self, outputDir, callback)
        gg.setVisible(false);
        --setup
        Il2cpp.GlobalMetadataApi:GetClassPointer()
        local classPointer = Il2cpp.GlobalMetadataApi.typeDef
        if not Il2cpp.MetadataRegistrationApi.classCount then
            Searcher.Il2CppMetadataRegistration()
        end
        local classCount = Il2cpp.MetadataRegistrationApi.classCount
        local infoGame = gg.getTargetInfo()
        local nameFile = infoGame.packageName .. "-" .. infoGame.versionCode .. "-" .. (infoGame.x64 and "64" or "32")
        --ok
        local Path = outputDir or "/sdcard/LeThi9GG"
        local PathDump = Path.."/"..nameFile
        local PathDump = PathDump .. "-dump." .. (self.ClassApi.outputDumper == "Lua" and "lua" or "cs")
        if not os.rename(Path, Path) then
            gg.dumpMemory(0, 0, Path)
            os.remove(Path.."/"..gg.getTargetPackage().."-maps.txt")
        end
        local dumpcs = io.open(PathDump, "w+")
        dumpcs:write(self.ClassApi.outputDumper == "Lua" and "local il2cpp = {\n\tName = 'il2cppLT9',\n\tVersion = 0.1,\n\tBy = 'LeThi9GG',\n\tclass = {}\n};\nil2cpp.il2cppVersion = " .. Il2cpp.il2cppVersion .. ";\n\n" or "// il2cppLT9 - 0.1 | By LeThi9GG\n// il2cppVersion: " .. Il2cpp.il2cppVersion .. "\n\n")
        local Text = string.format("il2cppLT9 - LeThi9GG\n\nOutput: %s\nClassCount: %d\n\n", PathDump, classCount)
        gg.toast(Text);print(Text);gg.alert(Text, "", "")
        
        for i, imageDef in ipairs(Il2cpp.GlobalMetadataApi:GetImageDef()) do
            dumpcs:write(string.format("%s Image %d: %s - %d\n", self.ClassApi.outputDumper == "Lua" and "--" or "//", i - 1, imageDef.name, imageDef.typeStart))
        end
        
        dumpcs:write("\n\n")
        
        local address = classPointer
        --local index = 1
        --gg.setVisible(false);
        --gg.processPause();
        local results = {}
        --local klass = {}
        
        for i = 1, classCount do
            results[i] = {address = address, flags = Il2cpp.MainType}
            address = address + Il2cpp.pointSize
        end
        --[[
        results = gg.getValues(results)
        while true do
            local v = results[index]
            local klass = Il2cpp.ClassApi:Find{Class = v.value, FieldsDump = true, MethodsDump = true}
            if klass[1] then
                dumpcs:write(tostring(klass[1]))
            end
            if index == #results then break end
            index = index + 1
        end]]
        -- [[
        local count = classCount / 100
        for i, v in ipairs(gg.getValues(results)) do
            
            if gg.isClickedUiButton() then--gg.isVisible() then
                local message = ": " .. i .. "/" .. classCount .. " -> " .. (i / count) .. "%"
                if callback(message) and gg.alert("Dumper Interrupted:\n\n- Done: " .. i .. "/" .. classCount .. " Class.\n- Continue?\n", "Ok", "", "Exit") == 3 then
                    break
                end
            end
            
            local klass = Il2cpp.ClassApi:Find{Class = v.value, FieldsDump = true, MethodsDump = true}
            if klass[1] then
                dumpcs:write(tostring(klass[1]))
            end
        end
        --[[
        local clazz = Il2cpp.FindClass(klass);
        for i, v in ipairs(clazz) do
            dumpcs:write(tostring(v))
        end]]
        --[[
        while true do
            local clazz = Il2cpp.FindClass({{Class = Il2cpp:GetPtr(address), FieldsDump = true, MethodsDump = true}})[1]
            if clazz and clazz[1] then
                dumpcs:write(tostring(clazz[1]))
                local info = string.format("[%d]: %d - %d%%\n\timage: %s\n\tspace: %s\n\tclass: %s", classCount, index, index / (classCount / 100), clazz[1].ImageName, clazz[1].ClassNameSpace, clazz[1].ClassName)
                self.cli:toast(info, "Dumper", nil, 0)
                index = index + 1
            end
            address = address + Il2cpp.pointSize
            if index == classCount then break end
        end
        ]]
        dumpcs:write(self.ClassApi.outputDumper == "Lua" and "return il2cpp;" or "")
        --gg.processResume();
        dumpcs:close()
        gg.alert("Done", "", "")
    end,
    
    DumpResults = function(Results, Pointer)
        local Path = "/sdcard/LeThi9GG"
        local PathDump = Path.."/"..gg.getTargetPackage().. (AndroidInfo.platform and "-arm64" or "-arm")
        local PathDump = PathDump .. "-".. #Results .. "-dump.cs"
        local dumpcs = io.open(PathDump, "w+")
        local Text = string.format("Path: %s\nClassCount: %d", PathDump, #Results)
        gg.toast(Text);print(Text);gg.alert(Text, "", "")
        gg.setVisible(false);
        gg.processPause();
        for i, v in ipairs(Results) do
            local clazz = Il2cpp.FindClass({{Class = (Pointer and Il2cpp.FixValue(v.value) or v.address), FieldsDump = true, MethodsDump = true}})[1]
            if clazz and clazz[1] then
                dumpcs:write(tostring(clazz[1]))
                gg.toast(string.format("%d[%d]", #Results, i))
            end
        end
        gg.processResume();
        dumpcs:close()
        gg.alert("Done", "", "")
    end,
    
    FindClassOb = function()
	    gg.clearResults();
	    gg.setRanges(4 | 32 | -2080896);
	    gg.searchNumber(102400, 4);
	    local t = gg.getResults(gg.getResultsCount())
	    gg.clearResults()
	    local r = {}
	    for i, v in pairs(t) do
	        local address = Il2cpp:GetPtr(v.address - Il2cpp.pointSize);
	        if Il2cpp.ClassApi.IsClassInfo(Il2cpp:GetPtr(address)) and address ~= Il2cpp.GlobalMetadataApi.classResults.address then
	            gg.searchNumber(0, Il2cpp.MainType, nil, nil, address, -1, 1);
	            local results = gg.getResults(1)
	            gg.clearResults()
	            local count = (results[1].address - Il2cpp.pointSize - address) / Il2cpp.pointSize
	            for ii = 0, count do
	                r[#r+1] = {address = address + (ii * Il2cpp.pointSize), flags = Il2cpp.MainType}
	            end    
	        end
	    end
	    gg.loadResults(r)
	    local t = gg.getResults(gg.getResultsCount())
	    gg.clearResults()
	    return t
	end,
    
    --Il2CppTypeDefinitionApi.GetGenericClassTypeDefinition = function(genericClass)
        
    
    
}

---@type Il2cpp
Il2cpp = setmetatable({}, {
    ---@param self Il2cpp
    ---@param config? Il2cppConfig
    __call = function(self, config)
        config = config or {}
        getmetatable(self).__index = Il2cppBase

        if config.libilcpp then
            self.il2cppStart, self.il2cppEnd = config.libilcpp.start, config.libilcpp['end']
        else
            self.il2cppStart, self.il2cppEnd = Searcher.FindIl2cpp()
        end

        if config.globalMetadata then
            self.globalMetadataStart, self.globalMetadataEnd = config.globalMetadata.start, config.globalMetadata['end']
        else
            self.globalMetadataStart, self.globalMetadataEnd = Searcher:FindGlobalMetaData()
        end

        if config.globalMetadataHeader then
            self.globalMetadataHeader = config.globalMetadataHeader
        else
            self.globalMetadataHeader = self.globalMetadataStart
        end
        
        self.MetadataRegistrationApi.metadataRegistration = config.metadataRegistration

        VersionEngine:ChooseVersion(config.il2cppVersion, self.globalMetadataHeader)
        
        self.il2cppVersion = Il2cpp.GlobalMetadataApi.version
        Il2cpp.GlobalMetadataApi:GetStringDefinitions()
        Il2cpp.cli.name = "il2cppLT9 - LeThi9GG"
        
        Il2cpp.regionClass = self.il2cppVersion >= 29.1 and Il2cpp.regionType.A or Il2cpp.regionClass
        
        if not Il2cpp.MetadataRegistrationApi.classCount then
            Searcher.Il2CppMetadataRegistration()
        end

        Il2cppMemory:ClearMemorize()
        
        if (gg.getTargetPackage() == "com.garena.game.kgvn") then
        	Il2cpp.MethodsApi.ParamCount = Il2cpp.MethodsApi.ParamCount + ((AndroidInfo.platform and 16) or 8);
        	Il2cpp.ClassApi.CountMethods = AndroidInfo.platform and 0x114 or 0xAC
        	Il2cpp.ClassApi.CountFields = AndroidInfo.platform and 0x118 or 0xB0
        end
    end,
    __index = function(self, key)
        assert(key == "PatchesAddress", "You didn't call 'Il2cpp'")
        return Il2cppBase[key]
    end,
    __name = "il2cppLT9"
})

return Il2cpp
end)__bundle_register("utils.il2cppmemory", function(require, _LOADED, __bundle_register, __bundle_modules)
-- Memorizing Il2cpp Search Result
---@class Il2cppMemory
---@field Methods table<number | string, MethodMemory>
---@field Classes table<string | number, ClassMemory>
---@field Fields table<number | string, FieldInfo[] | ErrorSearch>
---@field Results table
---@field Types table<number, string>
---@field DefaultValues table<number, string | number>
---@field GetInformaionOfMethod fun(self : Il2cppMemory, searchParam : number | string) : MethodMemory | nil
---@field SetInformaionOfMethod fun(self : Il2cppMemory, searchParam : string | number, searchResult : MethodMemory) : void
---@field GetInformationOfClass fun(self : Il2cppMemory, searchParam : string | number) : ClassMemory | nil
---@field SetInformationOfClass fun(self : Il2cppMemory, searchParam : string | number, searchResult : ClassMemory) : void
---@field GetInformationOfField fun(self : Il2cppMemory, searchParam : number | string) : FieldInfo[] | nil | ErrorSearch
---@field SetInformationOfField fun(self : Il2cppMemory, searchParam : string | number, searchResult : FieldInfo[] | ErrorSearch) : void
---@field GetInformationOfType fun(self : Il2cppMemory, index : number) : string | nil
---@field SetInformationOfType fun(self : Il2cppMemory, index : number, typeName : string)
---@field SaveResults fun(self : Il2cppMemory) : void
---@field ClearSavedResults fun(self : Il2cppMemory) : void
local Il2cppMemory = {
    Methods = {},
    Classes = {},
    Fields = {},
    DefaultValues = {},
    Results = {},
    Types = {},


    ---@param self Il2cppMemory
    ---@return nil | string
    GetInformationOfType = function(self, index)
        return self.Types[index]
    end,


    ---@param self Il2cppMemory
    SetInformationOfType = function(self, index, typeName)
        self.Types[index] = typeName
    end,

    ---@param self Il2cppMemory
    SaveResults = function(self)
        if gg.getResultsCount() > 0 then
            self.Results = gg.getResults(gg.getResultsCount())
        end
    end,


    ---@param self Il2cppMemory
    ClearSavedResults = function(self)
        self.Results = {}
    end,


    ---@param self Il2cppMemory
    ---@param fieldIndex number
    ---@return string | number | nil
    GetDefaultValue = function(self, fieldIndex)
        return self.DefaultValues[fieldIndex]
    end,


    ---@param self Il2cppMemory
    ---@param fieldIndex number
    ---@param defaultValue number | string | nil
    SetDefaultValue = function(self, fieldIndex, defaultValue)
        self.DefaultValues[fieldIndex] = defaultValue or "nil"
    end,


    ---@param self Il2cppMemory
    ---@param searchParam number | string
    ---@return FieldInfo[] | nil | ErrorSearch
    GetInformationOfField = function(self, searchParam)
        return self.Fields[searchParam]
    end,


    ---@param self Il2cppMemory
    ---@param searchParam number | string
    ---@param searchResult FieldInfo[] | ErrorSearch
    SetInformationOfField = function(self, searchParam, searchResult)
        if not searchResult.Error then
            self.Fields[searchParam] = searchResult
        end
    end,


    GetInformaionOfMethod = function(self, searchParam)
        return self.Methods[searchParam]
    end,


    SetInformaionOfMethod = function(self, searchParam, searchResult)
        if not searchResult.Error then
            self.Methods[searchParam] = searchResult
        end
    end,


    GetInformationOfClass = function(self, searchParam)
        return self.Classes[searchParam]
    end,


    SetInformationOfClass = function(self, searchParam, searchResult)
        self.Classes[searchParam] = searchResult
    end,


    ---@param self Il2cppMemory
    ---@return void
    ClearMemorize = function(self)
        self.Methods = {}
        self.Classes = {}
        self.Fields = {}
        self.DefaultValues = {}
        self.Results = {}
        self.Types = {}
    end
}

return Il2cppMemory

end)__bundle_register("utils.version", function(require, _LOADED, __bundle_register, __bundle_modules)
local AndroidInfo = require("utils.androidinfo")
local osUV = 0x11

local function compareVersions(v1, v2)
    if v1.major ~= v2.major then
        return v1.major < v2.major and -1 or 1
    end
    if v1.minor ~= v2.minor then
        return v1.minor < v2.minor and -1 or 1
    end
    if v1.patch ~= v2.patch then
        return v1.patch < v2.patch and -1 or 1
    end
    return 0
end


---@class VersionEngine
local VersionEngine = {
    ConstSemVer = {
        ['2018_3'] = { major = 2018, minor = 3, patch = 0 },
        ['2019_4_21'] = { major = 2019, minor = 4, patch = 21 },
        ['2019_4_15'] = { major = 2019, minor = 4, patch = 15 },
        ['2019_3_7'] = { major = 2019, minor = 3, patch = 7 },
        ['2020_2_4'] = { major = 2020, minor = 2, patch = 4 },
        ['2020_2'] = { major = 2020, minor = 2, patch = 0 },
        ['2020_1_11'] = { major = 2020, minor = 1, patch = 11 },
        ['2021_2'] = { major = 2021, minor = 2, patch = 0 },
        ['2022_2'] = { major = 2022, minor = 2, patch = 0 },
        ['2022_3_38'] = { major = 2022, minor = 3, patch = 38 },
        ['2022_3_41'] = { major = 2022, minor = 3, patch = 41 },
    },
    Year = {
        [2017] = function(self, unityVersion)
            return 24
        end,
        [2018] = function(self, unityVersion)
            return compareVersions(unityVersion, self.ConstSemVer['2018_3']) >= 0 and 24.1 or 24
        end,
        [2019] = function(self, unityVersion)
            local version = 24.2
            if compareVersions(unityVersion, self.ConstSemVer['2019_4_21']) >= 0 then
                version = 24.5
            elseif compareVersions(unityVersion, self.ConstSemVer['2019_4_15']) >= 0 then
                version = 24.4
            elseif compareVersions(unityVersion, self.ConstSemVer['2019_3_7']) >= 0 then
                version = 24.3
            end
            return version
        end,
        [2020] = function(self, unityVersion)
            local version = 24.3
            if compareVersions(unityVersion, self.ConstSemVer['2020_2_4']) >= 0 then
                version = 27.1
            elseif compareVersions(unityVersion, self.ConstSemVer['2020_2']) >= 0 then
                version = 27
            elseif compareVersions(unityVersion, self.ConstSemVer['2020_1_11']) >= 0 then
                version = 24.4
            end
            return version
        end,
        [2021] = function(self, unityVersion)
            return compareVersions(unityVersion, self.ConstSemVer['2021_2']) >= 0 and 29 or 27.2
        end,
        [2022] = function(self, unityVersion)
            local version = 29
            if compareVersions(unityVersion, self.ConstSemVer['2022_3_38']) >= 0 then
                version = 31
            elseif compareVersions(unityVersion, self.ConstSemVer['2022_2']) >= 0 then
                version = 29.1
            end
            return version
        end,
        [2023] = function(self, unityVersion)
            return 31
        end,
    },
    ReadUnityVersion = function()
        local version = {2018, 2019, 2020, 2021, 2022, 2023, 2024}
        local lm = gg.getRangesList('libmain.so')
        if #lm > 0 then
            local libMain = io.open(lm[1].name, "rb"):read("*a")
            for i, v in pairs(version) do
                if libMain:find(v) then
                    local versionName = v .. libMain:gmatch(v .. "(.-)_")()
                    --print( versionName )
                    local major, minor, patch = string.gmatch(versionName, "(%d+)%p(%d+)%p(%d+)")()
                    return { major = tonumber(major), minor = tonumber(minor), patch = tonumber(patch) }
                end
            end
        else
            gg.setRanges(gg.REGION_C_ALLOC)
            gg.clearResults()
            gg.searchNumber("Q 'X-Unity-Version:'", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, nil, nil, 1)
            if gg.getResultsCount() == 0 then
               gg.setRanges(gg.REGION_JAVA_HEAP)
               gg.searchNumber("Q 'SDK_UnityVersion'", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, nil, nil, 1)
               osUV = 0x20
            end
            local result = gg.getResultsCount() > 0 and gg.getResults(1)[1].address + osUV or 0
            if gg.getResultsCount() == 0 then
                gg.setRanges(gg.REGION_ANONYMOUS)
                gg.clearResults()
                gg.searchNumber("00h;32h;30h;0~~0;0~~0;2Eh;0~~0;2Eh::9", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, nil, nil, 1)
                result = gg.getResultsCount() > 0 and gg.getResults(3)[3].address or 0
                gg.clearResults()
            end
            gg.clearResults()
            local versionName = Il2cpp.Utf8ToString(result)
            --print( versionName )
            local major, minor, patch = string.gmatch(versionName, "(%d+)%p(%d+)%p(%d+)")()
            return { major = tonumber(major), minor = tonumber(minor), patch = tonumber(patch) }
        end
    end,
    ChooseVersion = function(self, version, globalMetadataHeader)
        if not version then
            local unityVersion = self.ReadUnityVersion()
            if not unityVersion then
                gg.alert("Cannot determine Unity version", "", "")
                version = 31
            else
                version = self.Year[unityVersion.major] or 31
                if type(version) == 'function' then
                    version = version(self, unityVersion)
                end
            end
        end
        if version > 31 then
            gg.alert("Not support this il2cpp version", "", "")
            version = 31
        end
        local api = assert(Il2CppConst(version), 'Not support this il2cpp version')
        --for i = 1, #api do api[Il2CppConst.__name[i]] = api[i] end
        --Il2CppConst = nil
        --
        Il2cpp.FieldApi.Offset = api.FieldApiOffset
        Il2cpp.FieldApi.Type = api.FieldApiType
        Il2cpp.FieldApi.ClassOffset = api.FieldApiClassOffset

        Il2cpp.ClassApi.NameOffset = api.ClassApiNameOffset
        Il2cpp.ClassApi.MethodsStep = api.ClassApiMethodsStep
        Il2cpp.ClassApi.CountMethods = api.ClassApiCountMethods
        Il2cpp.ClassApi.MethodsLink = api.ClassApiMethodsLink
        Il2cpp.ClassApi.FieldsLink = api.ClassApiFieldsLink
        Il2cpp.ClassApi.FieldsStep = api.ClassApiFieldsStep
        Il2cpp.ClassApi.CountFields = api.ClassApiCountFields
        Il2cpp.ClassApi.ParentOffset = api.ClassApiParentOffset
        Il2cpp.ClassApi.NameSpaceOffset = api.ClassApiNameSpaceOffset
        Il2cpp.ClassApi.StaticFieldDataOffset = api.ClassApiStaticFieldDataOffset
        Il2cpp.ClassApi.EnumType = api.ClassApiEnumType
        Il2cpp.ClassApi.EnumRsh = api.ClassApiEnumRsh
        Il2cpp.ClassApi.TypeMetadataHandle = api.ClassApiTypeMetadataHandle
        Il2cpp.ClassApi.InstanceSize = api.ClassApiInstanceSize
        Il2cpp.ClassApi.Token = api.ClassApiToken
        Il2cpp.ClassApi.GenericContainer = api.ClassApiInstanceSize - (version > 27 and Il2cpp.pointSize or 4)
        
        Il2cpp.ClassApi.Flags = Il2cpp.ClassApi.EnumType + 4

        Il2cpp.MethodsApi.ClassOffset = api.MethodsApiClassOffset
        Il2cpp.MethodsApi.NameOffset = api.MethodsApiNameOffset
        Il2cpp.MethodsApi.ParamCount = api.MethodsApiParamCount
        Il2cpp.MethodsApi.ReturnType = api.MethodsApiReturnType
        Il2cpp.MethodsApi.Flags = api.MethodsApiFlags
        
        Il2cpp.MethodsApi.FixParamOffset = ((version > 27) and 0) or (AndroidInfo.platform and 16) or 12;
        Il2cpp.MethodsApi.FixParamStep = ((version > 27) and ((AndroidInfo.platform and 8) or 4)) or (AndroidInfo.platform and 24) or 16;
        Il2cpp.MethodsApi.ParamLink = api.MethodsApiReturnType + (AndroidInfo.platform and 8 or 4)
        Il2cpp.MethodsApi.TypeMetadataHandle = Il2cpp.MethodsApi.ParamLink + (AndroidInfo.platform and 8 or 4)

        Il2cpp.GlobalMetadataApi.typeDefinitionsSize = api.typeDefinitionsSize
        Il2cpp.GlobalMetadataApi.version = version
        Il2cpp.GlobalMetadataApi.parameterStart = (version == 31) and 0x10 or 0xC

        local consts = gg.getValues({
            { -- [1] 
                address = Il2cpp.globalMetadataHeader + api.typeDefinitionsOffset,
                flags = gg.TYPE_DWORD
            },
            { -- [2]
                address = Il2cpp.globalMetadataHeader + api.stringOffset,
                flags = gg.TYPE_DWORD,
            },
            { -- [3]
                address = Il2cpp.globalMetadataHeader + api.fieldDefaultValuesOffset,
                flags = gg.TYPE_DWORD,
            },
            { -- [4]
                address = Il2cpp.globalMetadataHeader + api.fieldDefaultValuesSize,
                flags = gg.TYPE_DWORD
            },
            { -- [5]
                address = Il2cpp.globalMetadataHeader + api.fieldAndParameterDefaultValueDataOffset,
                flags = gg.TYPE_DWORD
            },
            { -- [6]
                address = Il2cpp.globalMetadataHeader + 22 * 4,
                flags = gg.TYPE_DWORD
            },
            { -- [7]
                address = Il2cpp.globalMetadataHeader + 23 * 4,
                flags = gg.TYPE_DWORD
            },
            { -- [8]
                address = Il2cpp.globalMetadataHeader + 26 * 4,
                flags = gg.TYPE_DWORD
            },
            { -- [9]
                address = Il2cpp.globalMetadataHeader + 27 * 4,
                flags = gg.TYPE_DWORD
            },
            { -- [10]
                address = Il2cpp.globalMetadataHeader + 24 * 4,
                flags = gg.TYPE_DWORD
            },
            { -- [11]
                address = Il2cpp.globalMetadataHeader + 25 * 4,
                flags = gg.TYPE_DWORD
            },
            { -- [12]
                address = Il2cpp.globalMetadataHeader + 30 * 4,
                flags = gg.TYPE_DWORD
            },
            { -- [13]
                address = Il2cpp.globalMetadataHeader + 31 * 4,
                flags = gg.TYPE_DWORD
            }
        })
        Il2cpp.GlobalMetadataApi.typeDefinitionsOffset = consts[1].value
        
        --gg.addListItems{{address = Il2cpp.globalMetadataHeader + Il2cpp.GlobalMetadataApi.typeDefinitionsOffset, flags = 4, name = "typeDefinitionsOffset"}}
        --os.exit()
        
        Il2cpp.GlobalMetadataApi.stringOffset = consts[2].value
        Il2cpp.GlobalMetadataApi.fieldDefaultValuesOffset = consts[3].value
        Il2cpp.GlobalMetadataApi.fieldDefaultValuesSize = consts[4].value
        Il2cpp.GlobalMetadataApi.fieldAndParameterDefaultValueDataOffset = consts[5].value
        Il2cpp.GlobalMetadataApi.parametersOffset = consts[6].value
        Il2cpp.GlobalMetadataApi.parametersSize = consts[7].value
        Il2cpp.GlobalMetadataApi.genericParametersOffset = consts[8].value
        Il2cpp.GlobalMetadataApi.genericParametersSize = consts[9].value
        Il2cpp.GlobalMetadataApi.fieldsOffset = consts[10].value
        Il2cpp.GlobalMetadataApi.fieldsSize = consts[11].value
        Il2cpp.GlobalMetadataApi.genericContainersOffset = consts[12].value
        Il2cpp.GlobalMetadataApi.genericContainersSize = consts[13].value
        
        Il2cpp.GlobalMetadataApi.Il2CppFieldDefinition.nameIndex = 0
        Il2cpp.GlobalMetadataApi.Il2CppFieldDefinition.typeIndex = 4
        Il2cpp.GlobalMetadataApi.Il2CppFieldDefinition.token = version > 24 and 8 or 12
        
        Il2cpp.GlobalMetadataApi.Il2CppParameterDefinition.nameIndex = 0
        Il2cpp.GlobalMetadataApi.Il2CppParameterDefinition.token = 4
        Il2cpp.GlobalMetadataApi.Il2CppParameterDefinition.typeIndex = version > 24 and 8 or 12
        Il2cpp.GlobalMetadataApi.Il2CppParameterDefinition.parametersAddress = Il2cpp.globalMetadataHeader + Il2cpp.GlobalMetadataApi.parametersOffset

        Il2cpp.GlobalMetadataApi.classPointer = version < 27 and (AndroidInfo.platform and 24 or 12) or (AndroidInfo.platform and 40 or 20);
        Il2cpp.GlobalMetadataApi.dllPointer = version < 27 and (AndroidInfo.platform and 72 or 36) or (AndroidInfo.platform and 24 or 12);

        Il2cpp.TypeApi.Type = api.TypeApiType

        Il2cpp.Il2CppTypeDefinitionApi.fieldStart = api.Il2CppTypeDefinitionApifieldStart

        Il2cpp.MetadataRegistrationApi.types = api.MetadataRegistrationApitypes
    end,
}

return setmetatable(VersionEngine, {
    __call = function(self)
        return self:ChooseVersion()
    end
})
end)__bundle_register("utils.universalsearcher", function(require, _LOADED, __bundle_register, __bundle_modules)
local AndroidInfo = require("utils.androidinfo")

---@class Searcher
local Searcher = {
    searchWord = ":EnsureCapacity",

    ---@param self Searcher
    FindGlobalMetaData = function(self)
        gg.clearResults()
        gg.setRanges(gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS |
                         gg.REGION_OTHER)
        local globalMetadata = gg.getRangesList('global-metadata.dat')
        --gg.addListItems({{address = globalMetadata[1].start, flags = 4}})
        if not self:IsValidData(globalMetadata) then
            globalMetadata = gg.getRangesList("dev/zero")
        end
        if not self:IsValidData(globalMetadata) then
            globalMetadata = {}
            gg.clearResults()
            gg.searchNumber(self.searchWord, gg.TYPE_BYTE, false, gg.SIGN_EQUAL, nil, nil, 1)
            gg.refineNumber(self.searchWord:sub(1, 2), gg.TYPE_BYTE)
            local EnsureCapacity = gg.getResults(gg.getResultsCount())
            gg.clearResults()
            for k, v in ipairs(gg.getRangesList()) do
                if (v.state == 'Ca' or v.state == 'A' or v.state == 'Cd' or v.state == 'Cb' or v.state == 'Ch' or
                    v.state == 'O') then
                    for key, val in ipairs(EnsureCapacity) do
                        globalMetadata[#globalMetadata + 1] =
                            (Il2cpp.FixValue(v.start) <= Il2cpp.FixValue(val.address) and Il2cpp.FixValue(val.address) <
                                Il2cpp.FixValue(v['end'])) and v or nil
                    end
                end
            end
        end
        gg.searchNumber(-89056337, 4, false, gg.SIGN_EQUAL, globalMetadata[1].start,
                globalMetadata[#globalMetadata]['end'])
        globalMetadata[1].start = gg.getResults(1)[1].address
        gg.clearResults()
        return globalMetadata[1].start, globalMetadata[#globalMetadata]['end']
    end,

    ---@param self Searcher
    IsValidData = function(self, globalMetadata)
        if #globalMetadata ~= 0 then
            gg.searchNumber(self.searchWord, gg.TYPE_BYTE, false, gg.SIGN_EQUAL, globalMetadata[1].start,
                globalMetadata[#globalMetadata]['end'])
            if gg.getResultsCount() > 0 then
                gg.clearResults()
                return true
            end
        end
        return false
    end,
    
    FindGlobalMetaDataOb = function(self)
        if not Il2cpp.globalMetadataObStart then
            gg.setRanges(4 | 32);
            gg.clearResults()
            gg.searchNumber("Q 00 'Assembly-CSharp.dll' 00", 1, false, gg.SIGN_EQUAL, nil, nil, 1)
            local t = gg.getResults(1)
            gg.clearResults()
            for k, v in ipairs(gg.getRangesList()) do
                if t[1].address > v.start and t[1].address < v['end'] then
                    Il2cpp.globalMetadataObStart = v.start
                    Il2cpp.globalMetadataObEnd = v['end']
                end
            end
            Il2cpp.globalMetadataOb = true
        end
    end,
    
    FindLib = function(libName)
        local il2cpp = gg.getRangesList(libName)
        if #il2cpp == 0 then
            il2cpp = gg.getRangesList('split_config.')
            local name = ":" .. il2cpp[1].name .. "!/lib/" .. il2cpp[1].name:gmatch("split_config.(.-).apk")():gsub("_", "-") .. "/" .. libName
            local _il2cpp = {}
            gg.setRanges(gg.REGION_OTHER)
            gg.clearResults()
            gg.searchNumber(name, gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 1)
            gg.searchPointer(0)
            local results = gg.getResults(gg.getResultsCount())
            gg.clearResults()
            for i, v in ipairs(results) do
                local addr = Il2cpp:GetPtr(v.address - Il2cpp.pointSize)
                local Value = gg.getValues({{address = addr, flags = 4}})[1].value
                if Value==0x464C457F or Value==263434879 then
                    for i, v in ipairs(il2cpp) do
                        if v.start == addr then
                            _il2cpp[1] = v
                            _il2cpp[2] = il2cpp[i+1]
                            break
                        end
                    end
                end
            end
            il2cpp = _il2cpp
        else
            local _il2cpp = {}
            for k,v in ipairs(il2cpp) do
                local Value = gg.getValues({{address = v.start, flags = 4}})[1].value
                if Value==0x464C457F or Value==263434879 then
                --if (string.find(v.type, "..x.") or v.state == "Xa") then
                    _il2cpp[#_il2cpp + 1] = v
                end
            end
            il2cpp[1] = _il2cpp[#_il2cpp]
            --il2cpp = _il2cpp
        end
        return il2cpp
    end,

    FindIl2cpp = function()
        local il2cpp = gg.getRangesList('libil2cpp.so')
        if #il2cpp == 0 then
            il2cpp = gg.getRangesList('split_config.')
            
            local name = ":" .. il2cpp[1].name .. "!/lib/" .. il2cpp[1].name:gmatch("split_config.(.-).apk")():gsub("_", "-") .. "/libil2cpp.so"
            local _il2cpp = {}
            gg.setRanges(gg.REGION_OTHER)
            gg.clearResults()
            gg.searchNumber(name, gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 1)
            gg.searchPointer(0)
            local results = gg.getResults(gg.getResultsCount())
            gg.clearResults()
            for i, v in ipairs(results) do
                local addr = Il2cpp:GetPtr(v.address - Il2cpp.pointSize)
                local Value = gg.getValues({{address = addr, flags = 4}})[1].value
                if Value==0x464C457F or Value==263434879 then
                    for i, v in ipairs(il2cpp) do
                        if v.start == addr then
                            _il2cpp[1] = v
                            _il2cpp[#_il2cpp+1] = il2cpp[i+1]
                            break
                        end
                    end
                end
            end
            --[[
            for k, v in ipairs(il2cpp) do
                if (v.state == 'Xa' or (v.state == 'O' and v.type == "r--p") or v.state == 'Cd') then
                    gg.searchNumber("Q 00 'Assembly-CSharp.dll' 00", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, v.start, v['end'], 1)
                    if (gg.getResultsCount() > 0) then
                        gg.clearResults()
                        gg.searchNumber(v.start, Il2cpp.MainType)
                        local results = gg.getResults(gg.getResultsCount())
                        gg.clearResults()
                        for ii, vv in ipairs(results) do
                            if Il2cpp.Utf8ToString(Il2cpp:GetPtr(vv.address + Il2cpp.pointSize)):find("il2cpp") then
                                _il2cpp[#_il2cpp + 1] = v
                            end
                        end
                    end
                end
            end]]
            il2cpp = _il2cpp
            
        else
            local _il2cpp = {}
            for k,v in ipairs(il2cpp) do
                local Value = gg.getValues({{address = v.start, flags = 4}})[1].value
                if Value==0x464C457F or Value==263434879 then
                --if (string.find(v.type, "..x.") or v.state == "Xa") then
                    _il2cpp[#_il2cpp + 1] = v
                end
            end
            il2cpp[1] = _il2cpp[#_il2cpp]
            --il2cpp = _il2cpp
        end       
        return il2cpp[1].start, il2cpp[#il2cpp]['end']
    end,

    Il2CppMetadataRegistration = function()
        error("Il2CppMetadataRegistration", Il2cpp.MetadataRegistrationApi)
        local gmt = gg.getRangesList("global-metadata.dat");
	    local gmt = ((#gmt > 0) and gmt[1].start) or Il2cpp.globalMetadataStart;
	    gg.clearResults();
	    gg.setRanges(16 | 32);
	    gg.searchNumber(gmt, Il2cpp.MainType, nil, nil, Il2cpp.il2cppStart, -1, 1);
	    if gg.getResultsCount() == 0 and AndroidInfo.platform and AndroidInfo.sdk >= 30 then
            gg.searchNumber(tostring(gmt | 0xB400000000000000), Il2cpp.MainType, nil, nil, Il2cpp.il2cppStart, -1, 1);
        end
        local t = gg.getResults(1)
        gg.clearResults();
        local address = t[1].address
        while true do
            local Range = gg.getValuesRange({{address = Il2cpp:GetPtr(address), flags = Il2cpp.MainType}})[1]
            address = address - Il2cpp.pointSize
            if Range == 'Cd' then break end
        end
        g_code = Il2cpp:GetPtr(address)
        g_meta = Il2cpp:GetPtr(address + Il2cpp.pointSize)
        classCount = gg.getValues({{address = g_meta + Il2cpp.pointSize * 12, flags = Il2cpp.MainType}})[1].value
        if classCount == 0 or classCount < 0 then
            error("classCount: "..classCount)
        end
        Il2cpp.MetadataRegistrationApi.metadataRegistration = g_meta
        Il2cpp.MetadataRegistrationApi.il2cppRegistration = g_code
        Il2cpp.MetadataRegistrationApi.classCount = classCount
        Il2cpp.MetadataRegistrationApi.typeCount = classCount
        return g_meta, g_code
    end
}

return Searcher

end)__bundle_register("utils.patchapi", function(require, _LOADED, __bundle_register, __bundle_modules)
---@class Patch
---@field oldBytes table
---@field newBytes table
---@field Create fun(self : Patch, patchCode : table) : Patch
---@field Patch fun(self : Patch) : void
---@field Undo fun(self : Patch) : void
local PatchApi = {

    ---@param self Patch
    ---@param patchCode table
    Create = function(self, patchCode)
        return setmetatable({
            newBytes = patchCode,
            oldBytes = gg.getValues(patchCode)
        },
        {
            __index = self,
        })
    end,
    
    ---@param self Patch
    Patch = function(self)
        if self.newBytes then
            gg.setValues(self.newBytes)
        end 
    end,

    ---@param self Patch
    Undo = function(self)
        if self.oldBytes then
            gg.setValues(self.oldBytes)
        end
    end,
}

return PatchApi
end)__bundle_register("utils.cli", function(require, _LOADED, __bundle_register, __bundle_modules)
return {
    count = 0,
    name = '',
    toast = function(self, index, size, text, sleep)
        if type(index) == "string" and type(size) == "string" and not text then
            gg.toast(string.format("%s\n\n\t%s:\n\t%s\n\n", self.name, size, index))
            gg.sleep(sleep or 20)
        else
            if self:pt(index, size) then
                local count = self.count * (size > 100 and 1 or 10)
                gg.toast(text and string.format("%s\n\n\t%s %d%%\n\n", self.name, text, count) or count .. "%")
                gg.sleep(sleep or 20)
            else
                return false
            end
        end
    end,
    pt = function(self, index, size)
        local pt = size > 100 and 100 or 10
        local size = size / pt
        local count = index / size
        if self.count < count and count <= pt then
            self.count = count
            return count
        end
    end,
}
end)__bundle_register("utils.dictionary", function(require, _LOADED, __bundle_register, __bundle_modules)
local gg = gg;
local targetInfo = gg.getTargetInfo();
local x64 = targetInfo.x64;
local flagsType = (x64 and 32) or 4;
local sizeType = x64 and 0x8 or 0x4;
local flagsFix = {[1] = 0xFF,[2] = 0xFFFF,[4] = 0xFFFFFFFF,[8] = 0xFFFFFFFF,[32] = 0x00FFFFFFFFFFFFFF}

local function class(...)
	local cl = ...;
	cl.class = cl;
	cl.super = ...;
	cl.isaSet = { [cl] = true };
	for i = 1, select("#", ...) do
		local parent = select(i, ...);
		if parent ~= nil then
			cl.isaSet[parent] = true;
			if parent.isaSet then
				for grandparent, _ in pairs(parent.isaSet) do
					cl.isaSet[grandparent] = true;
				end;
			end;
		end;
	end;
	for ancestor, _ in pairs(cl.isaSet) do
		ancestor.descendantSet = ancestor.descendantSet or {};
		ancestor.descendantSet[cl] = true;
	end;
	cl.__index = cl;
	cl.new = function(class, ...)
    	local obj = setmetatable({}, class);
    	if obj.init then
    		return obj, obj:init(...);
    	end;
    	return obj;
    end;
	cl.isa = function(cl, obj)
    	assert(cl, "isa: argument 1 is nil, should be the class object");
    	if type(obj) ~= "table" then
    		return false;
    	end;
    	if not obj.isaSet then
    		return false;
    	end;
    	return obj.isaSet[cl] or false;
    end;
	cl.subclass = class;
	setmetatable(cl, {
	    __call = function(self, ...)
			return self:new(...);
		end
	});
	return cl;
end;

function gV(address, flags)
	if type(address) == "table" then
	    return gg.getValues(address);
	else
	    local flags = flags and flags or flagsType
	    local value = gg.getValues({{address=address,flags=flags}})[1].value
	    return value;--(flags == 16 or flags == 64) and value or value & flagsFix[flags];
	end;
end
function sV(Results, Freeze)
    local t = {}
    for i, v in pairs(Results) do
        t[#t+1] = {address = v.address, flags = v.flags, value = v.value, freeze = true}
    end
    gg.addListItems(t); gg.removeListItems(Freeze and {} or t)
    return t
end


Dictionary = class{
    name_cache = {},
    _buckets = x64 and 0x10 or 0x8,
    _entries = x64 and 0x18 or 0xC,
    _count = x64 and 0x20 or 0x10,
    _key = x64 and 0x8 or 0x4,
    _value = x64 and 0x10 or 0xC,
    cache = {},
    items = {},
    
    getEntries = function(self)
        if self.cache[self.Entries] then
            return self.cache[self.Entries]
        end
        local results, _results = {}, {}
        local Entries = self.Entries or 0
        local Count = self.Count or 0
        for i = 1, Count do
            local index = (i * self._entries) + self._key--(i == 1 and self._key or 0)
            local key = gV(Entries + index, 4)
            local name = gV(Entries + (index + 8))
            local address = Entries + (index + self._value)
            local value = gV(address)
            if key == name then
                name = name
            else
                if self.name_cache[name] then
                    name = self.name_cache[name]
                else
                    local _name = {}
                    local address = name + self._buckets
                    local size = gV(address, 4)
                    local address = address + 2
                    for i = 1, size do
                        local byte = gV(address + (i * 2), 1)
                        _name[i] = string.char(byte)
                    end
                    name = table.concat(_name)
                    self.name_cache[name] = name
                end
            end
            results[i] = {address = value, flags = flagsType, name = name}
            _results[i] = {address = address, flags = flagsType, name = name}
            self.items[self.Entries][name] = results[i]
        end
        self.cache[self.Entries] = results
        return results, _results
    end,
    get_Item = function(self, key)
        if not self.cache[self.Entries] then
            self:getEntries()
        end
        local items = self.cache[self.Entries]
        if not key then
            return items
        elseif self.items[self.Entries][key] then
            return self.items[self.Entries][key]
        else
            for i, v in pairs(items) do
                if v.name == tostring(key) then
                    return v
                end
            end
        end
    end,
    set_Item = function(self, results)
        local t = {}
        for k, v in pairs(results) do
            local items = self:get_Item(k)
            t[#t+1] = {
                address = items.address + self._buckets,
                flags = 64,
                value = v,
                name = items.name
            }
        end
        sV(t)
        --sV({{address = self.Buckets, flags = flagsType, value = 0}})
        return t
    end,
    init = function(self, address)
        self.Entries = gV(address+self._entries);
        self.Count = gV(address+self._count, 4);
        --self.Buckets = address + self._buckets
        if not self.items[self.Entries] then
            self.items[self.Entries] = {}
        end
        --return self
    end
}

List = class{
    _items = x64 and 0x10 or 0x8,
    _size = x64 and 0x18 or 0xC,
    _start = x64 and 0x20 or 0x10,
    cache = {},
    get_Item = function(self)
        if self.cache[self.items] then
            return self.cache[self.items]
        end
        local results = {}
        for i = 1, self.size do
            local index = ((i-1) * sizeType) + self._start
            results[i] = {address = gV(self.items + index), flags = flagsType}
        end
        self.cache[self.items] = results
        return results
    end,
    init = function(self, address)
        self.items = gV(address + self._items)
        self.size = gV(address + self._size, 4)
        return self
    end,
}

end)__bundle_register("il2cppstruct.metadataRegistration", function(require, _LOADED, __bundle_register, __bundle_modules)
local Searcher = require("utils.universalsearcher")

---@class MetadataRegistrationApi
---@field metadataRegistration number
---@field types number
local MetadataRegistrationApi = {


    ---@param self MetadataRegistrationApi
    ---@return number
    GetIl2CppTypeFromIndex = function(self, index)
        if not self.metadataRegistration then
            self:FindMetadataRegistration()
        end
        local types = gg.getValues({{address = self.metadataRegistration + self.types, flags = Il2cpp.MainType}})[1].value
        return Il2cpp.FixValue(gg.getValues({{address = types + (Il2cpp.pointSize * index), flags = Il2cpp.MainType}})[1].value)
    end,


    ---@param self MetadataRegistrationApi
    ---@return void
    FindMetadataRegistration = function(self)
        self.metadataRegistration = Searcher.Il2CppMetadataRegistration()
    end
}

return MetadataRegistrationApi
end)__bundle_register("il2cppstruct.type", function(require, _LOADED, __bundle_register, __bundle_modules)
local Il2cppMemory = require("utils.il2cppmemory")
local AndroidInfo = require("utils.androidinfo")

---@class TypeApi
---@field Type number
---@field tableTypes table
local TypeApi = {

    
    tableTypes = {
        --[0] = "LIST_END",
        [1] = "void",
        [2] = "bool",
        [3] = "char",
        [4] = "sbyte",
        [5] = "byte",
        [6] = "short",
        [7] = "ushort",
        [8] = "int",
        [9] = "uint",
        [10] = "long",
        [11] = "ulong",
        [12] = "float",
        [13] = "double",
        [14] = "string",
        --[19] = "T",
        [22] = "TypedReference",
        [24] = "IntPtr",
        [25] = "UIntPtr",
        [28] = "object",
        --[30] = "T",
        [15] = function(index)
            return Il2cpp.TypeApi.getType(index) .. "*";
        end,
        [17] = function(index)
            return Il2cpp.GlobalMetadataApi:GetClassNameFromIndex(index)
        end,
        [18] = function(index) -- class
            return Il2cpp.GlobalMetadataApi:GetClassNameFromIndex(index)
        end,
        [29] = function(index)
            return Il2cpp.TypeApi.getType(index) .. "[]";
        end,
        [20] = function(index)
            local typeMassiv = gg.getValues({
                {
                    address = Il2cpp.FixValue(index),
                    flags = Il2cpp.MainType
                },
                {
                    address = Il2cpp.FixValue(index) + Il2cpp.pointSize,
                    flags = gg.TYPE_BYTE
                }
            })
            return Il2cpp.TypeApi.getType(typeMassiv[1].value) .. "[" .. string.rep(",", typeMassiv[2].value - 1) .. "]"
        end,
        [21] = function(index)
            return Il2cpp.TypeApi.GetGenericType(index)
        end,
        [19] = function(index)
            return Il2cpp.TypeApi.GetGenericParameter(index)
        end,
        [30] = function(index)
            return Il2cpp.TypeApi.GetGenericParameter(index)
        end
    },
    
    getType = function(address)
        local typeMassiv = gg.getValues({
            {address = Il2cpp.FixValue(address),flags = Il2cpp.MainType},
            {address = Il2cpp.FixValue(address) + Il2cpp.TypeApi.Type, flags = 1}
        })
        return Il2cpp.TypeApi:GetTypeName(typeMassiv[2].value, Il2cpp.FixValue(typeMassiv[1].value))
    end,
    GetGenericType = function(index)
        local results = {}
        local clazz = Il2cpp:GetPtr(index + Il2cpp.pointSize)
        local count = gg.getValues({{address = clazz, flags = 4}})[1].value
        if not (Il2cpp.GlobalMetadataApi.version < 27) then
            index = Il2cpp:GetPtr(index);
        end
        local typeName = Il2cpp.GlobalMetadataApi:GetClassNameFromIndex(Il2cpp:GetPtr(index));--Il2cpp.TypeApi.getType(index)
        if count == 0 then
            return typeName
        end
        local link = Il2cpp:GetPtr(clazz + Il2cpp.pointSize)
        for i = 1, count do
            local address = Il2cpp:GetPtr(link + ((i-1) * Il2cpp.pointSize))
            results[#results+1] = Il2cpp.TypeApi.getType(address)
        end
        --gg.addListItems({{address = index, flags = 32}} )
        --print( Il2cpp.GlobalMetadataApi:GetClassNameFromIndex(1550) )
        return typeName:gsub("`%d", "") .. "<" .. table.concat(results, ", ") .. ">"
    end,
    
    
    ---@param self TypeApi
    ---@param typeIndex number @number for tableTypes
    ---@param index number @for an api that is higher than 24, this can be a reference to the index
    ---@return string
    GetTypeName = function(self, typeIndex, index)
        ---@type string | fun(index : number) : string
        local typeName = self.tableTypes[typeIndex] or string.format('(not support type -> 0x%X)', typeIndex)
        if (type(typeName) == 'function') then
            local resultType = Il2cppMemory:GetInformationOfType(index)
            if not resultType then
                resultType = typeName(index)
                Il2cppMemory:SetInformationOfType(index, resultType)
            end
            typeName = resultType
        end
        return typeName
    end,
    TypePtrCache = {},
    GetTypePtr = function(self, index)
        if self.TypePtrCache[index] then
            return self.TypePtrCache[index]
        end
        if Il2cpp:GetPtr(index) ~= 0 then
            local typeMassiv = gg.getValues({
                {
                    address = Il2cpp.FixValue(index),
                    flags = Il2cpp.MainType
                },
                {
                    address = Il2cpp.FixValue(index) + Il2cpp.TypeApi.Type,
                    flags = gg.TYPE_BYTE
                }
            })
            local name = Il2cpp.TypeApi:GetTypeName(typeMassiv[2].value, typeMassiv[1].value) .. "*"
            self.TypePtrCache[index] = name
            return name
        end
        local _index = gg.getValues({{address = Il2cpp.FixValue(index), flags = 4}})[1].value
        local address = Il2cpp:GetPtr(Il2cpp.GlobalMetadataApi.classResults.address + (_index * Il2cpp.pointSize))
        local name = Il2cpp.ClassApi:GetClassName(address)
        self.TypePtrCache[index] = name .. "*";
        return name .. "*";
    end,


    ---@param self TypeApi
    ---@param Il2CppType number
    GetTypeEnum = function(self, Il2CppType)
        return gg.getValues({{address = Il2CppType + self.Type, flags = gg.TYPE_BYTE}})[1].value
    end,
    
    GetGenericParameter = function(Il2CppType)
        local genericParameter = Il2cpp.GlobalMetadataApi:getGenericParameterFromIl2CppType(Il2CppType)
        return Il2cpp.GlobalMetadataApi:GetStringFromIndex(genericParameter[1].value)
    end
    
    
}

return TypeApi
end)__bundle_register("il2cppstruct.method", function(require, _LOADED, __bundle_register, __bundle_modules)
local AndroidInfo = require("utils.androidinfo")
local Protect = require("utils.protect")
local Il2cppMemory = require("utils.il2cppmemory")

---@class MethodsApi
---@field ClassOffset number
---@field NameOffset number
---@field ParamCount number
---@field ReturnType number
---@field Flags number
local MethodsApi = {


    ---@param self MethodsApi
    ---@param MethodName string
    ---@param searchResult MethodMemory
    ---@return MethodInfoRaw[]
    FindMethodWithName = function(self, MethodName, searchResult)
        local FinalMethods = {}
        local MethodNamePointers = Il2cpp.GlobalMetadataApi.GetPointersToString(MethodName)
        if searchResult.len < #MethodNamePointers then
            for methodPointIndex, methodPoint in ipairs(MethodNamePointers) do
                methodPoint.address = methodPoint.address - self.NameOffset
                local MethodAddress = Il2cpp.FixValue(gg.getValues({methodPoint})[1].value)
                if MethodAddress > Il2cpp.il2cppStart and MethodAddress < Il2cpp.il2cppEnd then
                    FinalMethods[#FinalMethods + 1] = {
                        MethodName = MethodName,
                        MethodAddress = MethodAddress,
                        MethodInfoAddress = methodPoint.address
                    }
                end
            end
        else
            searchResult.isNew = false
        end
        assert(#FinalMethods > 0, string.format("The '%s' method is not initialized", MethodName))
        return FinalMethods
    end,


    ---@param self MethodsApi
    ---@param MethodOffset number
    ---@param searchResult MethodMemory | nil
    ---@return MethodInfoRaw[]
    FindMethodWithOffset = function(self, MethodOffset, searchResult)
        local MethodsInfo = self:FindMethodWithAddressInMemory(Il2cpp.il2cppStart + MethodOffset, searchResult, MethodOffset)
        return MethodsInfo
    end,


    ---@param self MethodsApi
    ---@param MethodAddress number
    ---@param searchResult MethodMemory
    ---@param MethodOffset number | nil
    ---@return MethodInfoRaw[]
    FindMethodWithAddressInMemory = function(self, MethodAddress, searchResult, MethodOffset)
        local RawMethodsInfo = {} -- the same as MethodsInfo
        gg.clearResults()
        gg.setRanges(gg.REGION_C_HEAP | gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS | gg.REGION_C_BSS | gg.REGION_C_DATA |
                         gg.REGION_OTHER)
        if gg.BUILD < 16126 then
            gg.searchNumber(string.format("%Xh", MethodAddress), Il2cpp.MainType)
        else
            gg.loadResults({{
                address = MethodAddress,
                flags = Il2cpp.MainType
            }})
            gg.searchPointer(0)
        end
        local r_count = gg.getResultsCount()
        if r_count > searchResult.len then
            local r = gg.getResults(r_count)
            for j = 1, #r do
                RawMethodsInfo[#RawMethodsInfo + 1] = {
                    MethodAddress = MethodAddress,
                    MethodInfoAddress = r[j].address,
                    Offset = MethodOffset
                }
            end
        else
            searchResult.isNew = false
        end 
        gg.clearResults()
        assert(#RawMethodsInfo > 0, string.format("nothing was found for this address 0x%X", MethodAddress))
        return RawMethodsInfo
    end,
    
    FindMethodWithFindString = function(self, MethodResults)
        local _MethodsInfo = {} -- the same as MethodsInfo
        local ResultsMethod = MethodResults
        if #ResultsMethod == 0 then
            return false
        end
        gg.loadResults(ResultsMethod)
        local t = gg.getResults(gg.getResultsCount())
        local MethodsInfo = {}
        for i, v in pairs(t) do
            local MethodInfoAddress = v.address - self.NameOffset
            local MethodAddress = Il2cpp:GetPtr(MethodInfoAddress)
            if (MethodAddress > Il2cpp.il2cppStart and MethodAddress < Il2cpp.il2cppEnd) and Il2cpp.ClassApi.IsClassInfo(Il2cpp:GetPtr(MethodInfoAddress + self.ClassOffset)) --[[and gg.getValuesRange({{address = MethodAddress, flags = Il2cpp.MainType}})[1] == "Xa"]] then
                _MethodsInfo[#_MethodsInfo + 1] = {
                    MethodAddress = MethodAddress,
                    MethodInfoAddress = MethodInfoAddress
                }
                local MethodInfo
                MethodInfo, _MethodsInfo[#_MethodsInfo] = self:UnpackMethodInfo(_MethodsInfo[#_MethodsInfo])
                table.move(MethodInfo, 1, #MethodInfo, #MethodsInfo + 1, MethodsInfo)
            end
        end
        gg.clearResults()
        if #_MethodsInfo == 0 then
            return false
        end
        MethodsInfo = gg.getValues(MethodsInfo)
        self:DecodeMethodsInfo(_MethodsInfo, MethodsInfo)
        return _MethodsInfo    
    end,
           
    
    getTypeParam = function(self, ParamCount, ParamLink, ParamStart)
		if ((ParamCount == 0) or not ParamCount) then
			return Il2cpp.ClassApi.outputDumper == 'Lua' and "{}" or "";
		end
		local ParamInfo = {};
		local ParamName = ParamLink
		local ParamLink = ParamLink + self.FixParamOffset;
		local paramStart = gg.getValues({{address = ParamStart + Il2cpp.GlobalMetadataApi.parameterStart, flags = 4}})[1].value
		local paramToken = Il2cpp.il2cppVersion >= 31 and gg.getValues({{address = ParamStart + Il2cpp.GlobalMetadataApi.parameterStart - 4, flags = 4}})[1].value
		--print(paramToken)
		for i = 1, ParamCount do
			local index = (i - 1) * self.FixParamStep;
			local Address = Il2cpp.FixValue(gg.getValues({{address=(ParamLink + index),flags=Il2cpp.MainType}})[1].value);
			local Param = gg.getValues({{address=(Address + Il2cpp.TypeApi.Type),flags=1}})[1].value;
			local Param2 = Il2cpp.FixValue(gg.getValues({{address=Address,flags=Il2cpp.MainType}})[1].value);
			if Il2cpp.il2cppVersion > 27 then
			    local indexParam = paramStart + i - 1
			    local parameterDef = Il2cpp.GlobalMetadataApi.Il2CppParameterDefinition.getIndex(indexParam, paramToken)
			    TypeName = Il2cpp.GlobalMetadataApi:GetStringFromIndex(parameterDef.nameIndex)
			    
			else   
			    TypeName = Il2cpp.Utf8ToString(Il2cpp.FixValue(gg.getValues({{address=(ParamName + index),flags=Il2cpp.MainType}})[1].value))
			end
			ParamInfo[#ParamInfo + 1] = Il2cpp.ClassApi.outputDumper == 'Lua' and "'" .. Il2cpp.TypeApi:GetTypeName(Param, Param2) .. "_" .. TypeName .. "'" or Il2cpp.TypeApi:GetTypeName(Param, Param2) .. " " .. TypeName
		end
		return Il2cpp.ClassApi.outputDumper == 'Lua' and "{" .. table.concat(ParamInfo, ", ") .. "}" or table.concat(ParamInfo, ", ")
	end,


    ---@param self MethodsApi
    ---@param _MethodsInfo MethodInfo[]
    DecodeMethodsInfo = function(self, _MethodsInfo, MethodsInfo)
        for i = 1, #_MethodsInfo do
            local index = (i - 1) * 8
            local TypeInfo = Il2cpp.FixValue(MethodsInfo[index + 5].value)
            local _TypeInfo = gg.getValues({{ -- type index
                address = TypeInfo + Il2cpp.TypeApi.Type,
                flags = gg.TYPE_BYTE
            }, { -- index
                address = TypeInfo,
                flags = Il2cpp.MainType
            }})
            local MethodAddress = Il2cpp.FixValue(MethodsInfo[index + 1].value)
            local MethodFlags = MethodsInfo[index + 6].value
            local MethodParamLink = Il2cpp.FixValue(MethodsInfo[index + 7].value)
            local MethodParamCount = MethodsInfo[index + 4].value
            local MethodParamStart = Il2cpp.FixValue(MethodsInfo[index + 8].value)
            local MethodName = _MethodsInfo[i].MethodName or
                    Il2cpp.Utf8ToString(Il2cpp.FixValue(MethodsInfo[index + 2].value))
            
            local methodDefIndex = gg.getValues{{address = MethodParamStart, flags = 4}}[1].value
            if Il2cpp.globalMetadataOb and not Il2cpp.GlobalMetadataApi.stringDefinitionsOb and methodDefIndex > 0x40000000 then
                Il2cpp.GlobalMetadataApi.stringDefinitionsOb = Il2cpp.FixValue(MethodsInfo[index + 2].value) - (methodDefIndex & 0xfffff)
            end
            
            _MethodsInfo[i] = --[[setmetatable(]]{
                MethodName = MethodName,
                Offset = string.format("%X", _MethodsInfo[i].Offset or (MethodAddress == 0 and MethodAddress or MethodAddress - Il2cpp.il2cppStart)),
                AddressInMemory = string.format("%X", MethodAddress),
                MethodInfoAddress = _MethodsInfo[i].MethodInfoAddress,
                ClassName = _MethodsInfo[i].ClassName or Il2cpp.ClassApi:GetClassName(MethodsInfo[index + 3].value),
                ClassAddress = string.format('%X', Il2cpp.FixValue(MethodsInfo[index + 3].value)),
                ParamCount = MethodParamCount,
                ParamType = self:getTypeParam(MethodParamCount, MethodParamLink, MethodParamStart),
                ReturnType = Il2cpp.TypeApi:GetTypeName(_TypeInfo[1].value, _TypeInfo[2].value),
                IsStatic = (MethodFlags & Il2CppFlags.Method.METHOD_ATTRIBUTE_STATIC) ~= 0,
                Access = Il2CppFlags.Method.Access[MethodFlags & Il2CppFlags.Method.METHOD_ATTRIBUTE_MEMBER_ACCESS_MASK] or "",
                IsAbstract = (MethodFlags & Il2CppFlags.Method.METHOD_ATTRIBUTE_ABSTRACT) ~= 0,
            }--[[,{
                __name = MethodName
            })]]
        end
    end,


    ---@param self MethodsApi
    ---@param MethodInfo MethodInfoRaw
    UnpackMethodInfo = function(self, MethodInfo)
        return {
            { -- [1] Address Method in Memory
                address = MethodInfo.MethodInfoAddress,
                flags = Il2cpp.MainType
            },
            { -- [2] Name Address
                address = MethodInfo.MethodInfoAddress + self.NameOffset,
                flags = Il2cpp.MainType
            },
            { -- [3] Class address
                address = MethodInfo.MethodInfoAddress + self.ClassOffset,
                flags = Il2cpp.MainType
            },
            { -- [4] Param Count
                address = MethodInfo.MethodInfoAddress + self.ParamCount,
                flags = gg.TYPE_BYTE
            },
            { -- [5] Return Type
                address = MethodInfo.MethodInfoAddress + self.ReturnType,
                flags = Il2cpp.MainType
            },
            { -- [6] Flags
                address = MethodInfo.MethodInfoAddress + self.Flags,
                flags = gg.TYPE_WORD
            },
            { -- [7] ParamLink
                address = MethodInfo.MethodInfoAddress + self.ParamLink,
                flags = Il2cpp.MainType
            },
            { -- [8] TypeMetadataHandle
                address = MethodInfo.MethodInfoAddress + self.TypeMetadataHandle,
                flags = Il2cpp.MainType
            }
        }, 
        {
            MethodName = MethodInfo.MethodName or nil,
            Offset = MethodInfo.Offset or nil,
            MethodInfoAddress = MethodInfo.MethodInfoAddress,
            ClassName = MethodInfo.ClassName
        }
    end,


    FindParamsCheck = {
        ---@param self MethodsApi
        ---@param method number
        ---@param searchResult MethodMemory
        ['number'] = function(self, method, searchResult)
            if (method > Il2cpp.il2cppStart and method < Il2cpp.il2cppEnd) then
                return Protect:Call(self.FindMethodWithAddressInMemory, self, method, searchResult)
            else
                return Protect:Call(self.FindMethodWithOffset, self, method, searchResult)
            end
        end,
        ---@param self MethodsApi
        ---@param method string
        ---@param searchResult MethodMemory
        ['string'] = function(self, method, searchResult)
            return Protect:Call(self.FindMethodWithName, self, method, searchResult)
        end,
        ['default'] = function()
            return {
                Error = 'Invalid search criteria'
            }
        end
    },


    ---@param self MethodsApi
    ---@param method number | string
    ---@return MethodInfo[] | ErrorSearch
    Find = function(self, method)
        local searchResult = Il2cppMemory:GetInformaionOfMethod(method)
        if not searchResult then
            searchResult = {len = 0}
        end
        searchResult.isNew = true

        ---@type MethodInfoRaw[] | ErrorSearch
        local _MethodsInfo = (self.FindParamsCheck[type(method)] or self.FindParamsCheck['default'])(self, method, searchResult)
        if searchResult.isNew then
            local MethodsInfo = {}
            for i = 1, #_MethodsInfo do
                local MethodInfo
                MethodInfo, _MethodsInfo[i] = self:UnpackMethodInfo(_MethodsInfo[i])
                table.move(MethodInfo, 1, #MethodInfo, #MethodsInfo + 1, MethodsInfo)
            end
            MethodsInfo = gg.getValues(MethodsInfo)
            self:DecodeMethodsInfo(_MethodsInfo, MethodsInfo)

            -- save result
            searchResult.len = #_MethodsInfo
            searchResult.result = _MethodsInfo
            Il2cppMemory:SetInformaionOfMethod(method, searchResult)
        else
            _MethodsInfo = searchResult.result
        end

        return _MethodsInfo
    end
}

return MethodsApi
end)__bundle_register("utils.protect", function(require, _LOADED, __bundle_register, __bundle_modules)
local Protect = {
    ErrorHandler = function(err)
        return {Error = err}
    end,
    Call = function(self, fun, ...) 
        return ({xpcall(fun, self.ErrorHandler, ...)})[2]
    end
}

return Protect
end)__bundle_register("il2cppstruct.globalmetadata", function(require, _LOADED, __bundle_register, __bundle_modules)
local AndroidInfo = require("utils.androidinfo")

---@class GlobalMetadataApi
---@field typeDefinitionsSize number
---@field typeDefinitionsOffset number
---@field stringOffset number
---@field fieldDefaultValuesOffset number
---@field fieldDefaultValuesSize number
---@field fieldAndParameterDefaultValueDataOffset number
---@field version number
local GlobalMetadataApi = {

    parameterStart = 0xC,
    
    ---@type table<number, fun(blob : number) : string | number>
    behaviorForTypes = {
        [2] = function(blob)
            return Il2cpp.GlobalMetadataApi.ReadNumberConst(blob, gg.TYPE_BYTE)
        end,
        [3] = function(blob)
            return Il2cpp.GlobalMetadataApi.ReadNumberConst(blob, gg.TYPE_BYTE)
        end,
        [4] = function(blob)
            return Il2cpp.GlobalMetadataApi.ReadNumberConst(blob, gg.TYPE_BYTE)
        end,
        [5] = function(blob)
            return Il2cpp.GlobalMetadataApi.ReadNumberConst(blob, gg.TYPE_BYTE)
        end,
        [6] = function(blob)
            return Il2cpp.GlobalMetadataApi.ReadNumberConst(blob, gg.TYPE_WORD)
        end,
        [7] = function(blob)
            return Il2cpp.GlobalMetadataApi.ReadNumberConst(blob, gg.TYPE_WORD)
        end,
        [8] = function(blob)
            local self = Il2cpp.GlobalMetadataApi
            return self.version < 29 and self.ReadNumberConst(blob, gg.TYPE_DWORD) or self.ReadCompressedInt32(blob)
        end,
        [9] = function(blob)
            local self = Il2cpp.GlobalMetadataApi
            return self.version < 29 and Il2cpp.FixValue(self.ReadNumberConst(blob, gg.TYPE_DWORD)) or self.ReadCompressedUInt32(blob)
        end,
        [10] = function(blob)
            return Il2cpp.GlobalMetadataApi.ReadNumberConst(blob, gg.TYPE_QWORD)
        end,
        [11] = function(blob)
            return Il2cpp.GlobalMetadataApi.ReadNumberConst(blob, gg.TYPE_QWORD)
        end,
        [12] = function(blob)
            return Il2cpp.GlobalMetadataApi.ReadNumberConst(blob, gg.TYPE_FLOAT)
        end,
        [13] = function(blob)
            return Il2cpp.GlobalMetadataApi.ReadNumberConst(blob, gg.TYPE_DOUBLE)
        end,
        [14] = function(blob)
            local self = Il2cpp.GlobalMetadataApi
            local length, offset = 0, 0
            if self.version >= 29 then
                length, offset = self.ReadCompressedInt32(blob)
            else
                length = self.ReadNumberConst(blob, gg.TYPE_DWORD) 
                offset = 4
            end

            if length ~= -1 then
                return Il2cpp.Utf8ToString(blob + offset, length)
            end
            return ""
        end
    },
    
    GetStringDefinitions = function (self)
        local function isImage(addr)
            local imageStr = Il2cpp.Utf8ToString(Il2cpp:GetPtr(addr))
            local check = string.find(imageStr, ".-%.dll") or string.find(imageStr, "__Generated")
            return check and imageStr
        end
            
        if Il2cpp.Utf8ToString(Il2cpp.globalMetadataStart + self.stringOffset, 100):find(".dll") then
            self.stringDefinitions = Il2cpp.globalMetadataStart + self.stringOffset;
            --return self.stringDefinitions
        end
        local gmt = Il2cpp.globalMetadataStart;
        
	    gg.clearResults();
	    gg.setRanges(gg.REGION_C_BSS | gg.REGION_ANONYMOUS | gg.REGION_OTHER);
	    gg.searchNumber(gmt, Il2cpp.MainType, nil, nil, Il2cpp.il2cppStart, -1, 1);
	    if gg.getResultsCount() == 0 and AndroidInfo.platform and AndroidInfo.sdk >= 30 then
            gg.searchNumber(tostring(gmt | 0xB400000000000000), Il2cpp.MainType, nil, nil, Il2cpp.il2cppStart, -1, 1);
        end
        local t = gg.getResults(1)
        gg.clearResults();
        local Range, a = {}, t[1].address - (10 * Il2cpp.pointSize)
        for i = 1, 20 do
            Range[i] = {address = a + (i * Il2cpp.pointSize), flags = Il2cpp.MainType}
        end
        local res = {}
        for i, v in ipairs(gg.getValues(Range)) do
            local addr = Il2cpp.FixValue(v.value)
            if addr ~= gmt then
                res[#res+1] = {address = addr}
            end
        end
        for i, v in ipairs(gg.getValuesRange(res)) do
            if v == "Cd" or v == "O" then
                Il2cpp.MetadataRegistrationApi.il2cppRegistration = res[i].address
                Il2cpp.MetadataRegistrationApi.metadataRegistration = res[i+1].address
                Il2cpp.MetadataRegistrationApi.classCount = gg.getValues({{address = res[i+1].address + Il2cpp.pointSize * 12, flags = Il2cpp.MainType}})[1].value
                break
            end
        end

        local imgAddr = t[1].address + self.dllPointer
        local results = gg.getValues({
            {address=(Il2cpp:GetPtr(imgAddr) + 16),flags=Il2cpp.MainType},
            {address=Il2cpp:GetPtr(t[1].address + self.classPointer),flags=Il2cpp.MainType}});
        if Il2cpp:GetPtr(results[1].value) == 0 then
            results[1] = gg.getValues({{address=(Il2cpp:GetPtr(imgAddr) + 16 + 8),flags=Il2cpp.MainType}})[1];
        end
        if Il2cpp:GetPtr(results[2].value) == 0 then
            results[2].address = Il2cpp:GetPtr(t[1].address + self.classPointer + (4 * Il2cpp.pointSize))
        end
        local addr = results[1].address
        self.typeDef = results[2].address
        self.classPointer = results[2];
        
        for i = 1, 100 do
            if not self.imageCount then
                local count = Il2cpp:GetPtr(t[1].address + (i * Il2cpp.pointSize))
                if count < 1000 then
                    self.imageCount = count
                end
            end
            if not self.imageDef then
                local addr = Il2cpp:GetPtr(Il2cpp:GetPtr(self.typeDef + (i * Il2cpp.pointSize)))
                local image = isImage(addr)
                if image then
                    self.imageDef = addr
                end
            end
            if self.imageDef then
                local addr = self.imageDef + (i * Il2cpp.pointSize)
                if isImage(addr) then
                    self.imageSize = addr - self.imageDef
                    break
                end
            end
        end
        
        --[[
        if isImage(Il2cpp:GetPtr(addr)) then
            self.imageDef = Il2cpp:GetPtr(addr)
            self.imageCount = Il2cpp:GetPtr(imgAddr - Il2cpp.pointSize)
        else  
            local imgAddr = t[1].address + self.classPointer
            for i = 1, 100 do
                local addr = imgAddr + (i * Il2cpp.pointSize)
                if isImage(Il2cpp:GetPtr(addr)) then
                    self.imageDef = Il2cpp:GetPtr(addr)
                    self.imageCount = Il2cpp:GetPtr(addr - Il2cpp.pointSize)
                    break
                end
            end
        end
        for i = 1, 100 do
            local addr = self.imageDef + (i * Il2cpp.pointSize)
            if isImage(addr) then
                self.imageSize = addr - self.imageDef
                break
            end
        end]]
        --gg.addListItems({{address = self.imageDef, flags = 32}})
        --print(self.imageSize, self:GetImageDef());os.exit()
        
        if self.stringDefinitions then
            return self.stringDefinitions
        end
        if (self.version < 27) then
            self.stringDefinitions = Il2cpp.FixValue(Il2cpp:GetPtr(self.dllResults.address + ((AndroidInfo.platform and 8) or 0)));
            return self.stringDefinitions
        else
            address = Il2cpp:GetPtr(self.dllResults.value + (AndroidInfo.platform and 16 or 8)) + (AndroidInfo.platform and 24 or 16);
        end
        self.stringDefinitions = Il2cpp:GetPtr(address);
        return self.stringDefinitions
    end,
    
    GetImageDef = function(self)
        local typeStart = 0
        local addr = self.imageDef
        local typeCountOffset = gg.getValues({{address = addr + (Il2cpp.pointSize * 3), flags = 4}})[1].value == 0 and (Il2cpp.pointSize * 3) + 4 or Il2cpp.pointSize * 3
        local results = {}
        for i = 1, self.imageCount do
            local imageInfo = gg.getValues({
                {address = addr, flags = Il2cpp.MainType},
                {address = addr + typeCountOffset, flags = 4}
            })
            results[#results+1] = {
                name = Il2cpp.Utf8ToString(Il2cpp.FixValue(imageInfo[1].value)),
                typeCount = imageInfo[2].value,
                typeStart = typeStart
            }
            typeStart = typeStart + imageInfo[2].value
            addr = addr + self.imageSize
        end
        return results
    end,
    
    isClassPointer = function(self, address)
        if Il2cpp.ClassApi.IsClassInfo(Il2cpp:GetPtr(address + Il2cpp.pointSize)) and Il2cpp.ClassApi.IsClassInfo(Il2cpp:GetPtr(address + Il2cpp.pointSize * 2)) and Il2cpp.ClassApi.IsClassInfo(Il2cpp:GetPtr(address + Il2cpp.pointSize * 3)) then
            return true
        else
            return false
        end
    end,
    
    GetClassPointer = function(self)
        if self.typeDef and self:isClassPointer(self.typeDef) then
            return self.typeDef
        else
            local addr = self.typeDef
            for i = 1, 100 do
                if self:isClassPointer(addr + (i * Il2cpp.pointSize)) then
                    return self.typeDef
                end
            end
        end
        local t = Il2cpp.FindClass({{Class = '<Module>'}})[1]
        assert(#t > 0, t.Error)
        gg.clearResults()
        gg.setRanges(gg.REGION_C_HEAP | gg.REGION_C_HEAP | gg.REGION_ANONYMOUS | gg.REGION_C_BSS | gg.REGION_C_DATA |
                         gg.REGION_OTHER | gg.REGION_C_ALLOC)
        gg.searchNumber(tonumber(t[1].ClassAddress, 16), Il2cpp.MainType, false, gg.SIGN_EQUAL)
        if gg.getResultsCount() == 0 and AndroidInfo.platform and AndroidInfo.sdk >= 30 then
            gg.searchNumber(tostring(tonumber(t[1].ClassAddress, 16) | 0xB400000000000000), Il2cpp.MainType)
        end
        local results = gg.getResults(gg.getResultsCount())
        if #results == 0 then
            error("not support")
        end
        for i, v in ipairs(results) do
            if self:isClassPointer(v.address) then
                self.typeDef = v
                break
            end
        end
    end,


    ---@param self GlobalMetadataApi
    ---@param index number
    GetStringFromIndex = function(self, index)
        --local stringDefinitions = Il2cpp.globalMetadataStart + self.stringOffset
        if index > 0x40000000 then
            local strings = Il2cpp.Utf8ToString(self.stringDefinitionsOb + (index & 0xfffff))
            return strings
        end
        return Il2cpp.Utf8ToString(self.stringDefinitions + index)
    end,


    ---@param self GlobalMetadataApi
    GetClassNameFromIndex = function(self, index)
        if (self.version < 27) and AndroidInfo.pkg ~= "com.endragonpow.android" then
            local typeDefinitions = Il2cpp.globalMetadataStart + self.typeDefinitionsOffset
            index = (self.typeDefinitionsSize * index) + typeDefinitions
        else
            index = Il2cpp.FixValue(index)
        end
        local typeDefinition = gg.getValues({{
            address = index,
            flags = gg.TYPE_DWORD
        }})[1].value
        return self:GetStringFromIndex(typeDefinition)
    end,


    ---@param self GlobalMetadataApi
    ---@param dataIndex number
    GetFieldOrParameterDefalutValue = function(self, dataIndex)
        return self.fieldAndParameterDefaultValueDataOffset + Il2cpp.globalMetadataStart + dataIndex
    end,


    ---@param self GlobalMetadataApi
    ---@param index string
    GetIl2CppFieldDefaultValue = function(self, index)
        gg.clearResults()
        gg.setRanges(0)
        gg.setRanges(gg.REGION_C_HEAP | gg.REGION_C_HEAP | gg.REGION_ANONYMOUS | gg.REGION_C_BSS | gg.REGION_C_DATA |
                         gg.REGION_OTHER | gg.REGION_C_ALLOC)
        gg.searchNumber(index, gg.TYPE_DWORD, false, gg.SIGN_EQUAL,
            Il2cpp.globalMetadataStart + self.fieldDefaultValuesOffset,
            Il2cpp.globalMetadataStart + self.fieldDefaultValuesOffset + self.fieldDefaultValuesSize, 1)
        if gg.getResultsCount() > 0 then
            local Il2CppFieldDefaultValue = gg.getResults(1)
            gg.clearResults()
            return Il2CppFieldDefaultValue
        end
        return {}
    end,

    
    ---@param Address number
    ReadCompressedUInt32 = function(Address)
        local val, offset = 0, 0
        local read = gg.getValues({
            { -- [1]
                address = Address, 
                flags = gg.TYPE_BYTE
            },
            { -- [2]
                address = Address + 1, 
                flags = gg.TYPE_BYTE
            },
            { -- [3]
                address = Address + 2, 
                flags = gg.TYPE_BYTE
            },
            { -- [4]
                address = Address + 3, 
                flags = gg.TYPE_BYTE
            }
        })
        local read1 = read[1].value & 0xFF
        offset = 1
        if (read1 & 0x80) == 0 then
            val = read1
        elseif (read1 & 0xC0) == 0x80 then
            val = (read1 & ~0x80) << 8
            val = val | (read[2].value & 0xFF)
            offset = offset + 1
        elseif (read1 & 0xE0) == 0xC0 then
            val = (read1 & ~0xC0) << 24
            val = val | ((read[2].value & 0xFF) << 16)
            val = val | ((read[3].value & 0xFF) << 8)
            val = val | (read[4].value & 0xFF)
            offset = offset + 3
        elseif read1 == 0xF0 then
            val = gg.getValues({{address = Address + 1, flags = gg.TYPE_DWORD}})[1].value
            offset = offset + 4
        elseif read1 == 0xFE then
            val = 0xffffffff - 1
        elseif read1 == 0xFF then
            val = 0xffffffff
        end
        return val, offset
    end,


    ---@param Address number
    ReadCompressedInt32 = function(Address)
        local encoded, offset = Il2cpp.GlobalMetadataApi.ReadCompressedUInt32(Address)

        if encoded == 0xffffffff then
            return -2147483647 - 1
        end

        local isNegative = (encoded & 1) == 1
        encoded = encoded >> 1
        if isNegative then
            return -(encoded + 1)
        end
        return encoded, offset
    end,


    ---@param Address number
    ---@param ggType number @gg.TYPE_
    ReadNumberConst = function(Address, ggType)
        return gg.getValues({{
            address = Address,
            flags = ggType
        }})[1].value
    end,
    
   
    ---@param self GlobalMetadataApi
    ---@param index number
    ---@return number | string | nil
    GetDefaultFieldValue = function(self, index)
        local Il2CppFieldDefaultValue = self:GetIl2CppFieldDefaultValue(tostring(index))
        if #Il2CppFieldDefaultValue > 0 then
            local _Il2CppFieldDefaultValue = gg.getValues({
                { -- TypeIndex [1]
                    address = Il2CppFieldDefaultValue[1].address + 4,
                    flags = gg.TYPE_DWORD,
                },
                { -- dataIndex [2]
                    address = Il2CppFieldDefaultValue[1].address + 8,
                    flags = gg.TYPE_DWORD
                }
            })
            local blob = self:GetFieldOrParameterDefalutValue(_Il2CppFieldDefaultValue[2].value)
            local Il2CppType = Il2cpp.MetadataRegistrationApi:GetIl2CppTypeFromIndex(_Il2CppFieldDefaultValue[1].value)
            local typeEnum = Il2cpp.TypeApi:GetTypeEnum(Il2CppType)
            ---@type string | fun(blob : number) : string | number
            local behavior = self.behaviorForTypes[typeEnum] or "Not support type"
            if type(behavior) == "function" then
                return behavior(blob)
            end
            return behavior
        end
        return nil
    end,

    
    Il2CppFieldDefaultValue = {
        fieldIndex = 0,
        typeIndex = 4,
        dataIndex = 8,
        value = {},
    
        new = function(self)
            if os.rename(AndroidInfo.path .. "-enum.cfg", AndroidInfo.path .. "-enum.cfg") then
                self.Il2CppFieldDefaultTable = loadfile(AndroidInfo.path .. "-enum.cfg")()
                return
            end
            if not self.fieldDefaultValues then
                self.fieldDefaultValues = Il2cpp.globalMetadataStart + Il2cpp.GlobalMetadataApi.fieldDefaultValuesOffset
            end
            self.Il2CppFieldDefaultTable, count = {}, Il2cpp.GlobalMetadataApi.fieldDefaultValuesSize / 0xC
            for index = 0, count do
                Il2cpp.cli:toast(index + 1, count, "Enums:", 0)
                local address = (self.fieldDefaultValues + index * 0xC)
                local v = gg.getValues({
                    {address = address + self.fieldIndex, flags = 4, name = "fieldIndex"},
                    {address = address + self.typeIndex, flags = 4, name = "typeIndex"},
                    {address = address + self.dataIndex, flags = 4, name = "dataIndex"},
                })
                self.Il2CppFieldDefaultTable[v[1].value] = {address = address + self.fieldIndex, id = index, typeIndex = v[2].value, dataIndex = v[3].value}
            end
            gg.saveVariable(self.Il2CppFieldDefaultTable, AndroidInfo.path .. "-enum.cfg")
        end,
        getIndex = function(self, index)
            --local v = self.Il2CppFieldDefaultTable[index];
            --gg.addListItems({{address = v.address, flags = 4}})
            return self.Il2CppFieldDefaultTable[index];--{fieldIndex = v[1].value, typeIndex = v[2].value, dataIndex = v[3].value}
        end,
        getValue = function(self, index)
            if self.value[index] then return self.value[index] end
            local v = self:getIndex(index)
            local blob = Il2cpp.GlobalMetadataApi:GetFieldOrParameterDefalutValue(v.dataIndex)
            local Il2CppType = Il2cpp.MetadataRegistrationApi:GetIl2CppTypeFromIndex(v.typeIndex)
            local typeEnum = Il2cpp.TypeApi:GetTypeEnum(Il2CppType)
            local behavior = Il2cpp.GlobalMetadataApi.behaviorForTypes[typeEnum] or "Not support type"
            if type(behavior) == "function" then
                local ok, res = pcall(behavior, blob)
                
                if not ok then return {Error = {index = index, blob = blob, Il2CppType = Il2CppType, typeEnum = typeEnum, behavior = behavior, v = v}} end
                
                self.value[index] = res--behavior(blob)
            else
                self.value[index] = behavior
            end
            return self.value[index]
        end
    },
    
    Il2CppFieldDefinition = {
        cache = {},
        new = function(self)
            if not self.Il2CppFieldDefinitionTable then
                self.Il2CppFieldDefinitionTable = {}
                self.fieldsAddress = Il2cpp.globalMetadataStart + Il2cpp.GlobalMetadataApi.fieldsOffset
                self.next = self.typeIndex + 4
                self.count = Il2cpp.GlobalMetadataApi.fieldsSize / self.next
                for index = 0, self.count do
                    local address = (self.fieldsAddress + index * self.next)
                    local v = gg.getValues({
                        {address = address + self.nameIndex, flags = 4},
                        {address = address + self.token, flags = 4},
                        {address = address + self.typeIndex, flags = 4},    
                    })
                    self.Il2CppFieldDefinitionTable[index] = {nameIndex = v[1].value, token = v[2].value, typeIndex = v[3].value}
                end
            end
        end,
        getIndex = function(index)
            if Il2cpp.GlobalMetadataApi.Il2CppFieldDefinition.cache[index] then
                return Il2cpp.GlobalMetadataApi.Il2CppFieldDefinition.cache[index]
            end
            if not Il2cpp.GlobalMetadataApi.Il2CppFieldDefinition.fieldsAddress then
                Il2cpp.GlobalMetadataApi.Il2CppFieldDefinition.fieldsAddress = Il2cpp.globalMetadataStart + Il2cpp.GlobalMetadataApi.fieldsOffset
            end
            local id = index * (Il2cpp.GlobalMetadataApi.Il2CppFieldDefinition.typeIndex + 4)
            local address = Il2cpp.GlobalMetadataApi.Il2CppFieldDefinition.fieldsAddress + id
            local v = gg.getValues({
                {address = address + Il2cpp.GlobalMetadataApi.Il2CppFieldDefinition.nameIndex, flags = 4},
                {address = address + Il2cpp.GlobalMetadataApi.Il2CppFieldDefinition.token, flags = 4},
                {address = address + Il2cpp.GlobalMetadataApi.Il2CppFieldDefinition.typeIndex, flags = 4},    
            })
            --gg.addListItems({v[1]})
            local data = {nameIndex = v[1].value, token = v[2].value, typeIndex = v[3].value}
            Il2cpp.GlobalMetadataApi.Il2CppFieldDefinition.cache[index] = data
            return data
        end
    },
    
    --Il2CppParameterDefinition
    
    Il2CppParameterDefinition = {
        cache = {},
        new = function(self)
            if not self.Il2CppParameterDefinitionTable then
                self.Il2CppParameterDefinitionTable = {}
                self.parametersAddress = Il2cpp.globalMetadataStart + Il2cpp.GlobalMetadataApi.parametersOffset
                self.next = self.typeIndex + 4
                self.count = Il2cpp.GlobalMetadataApi.parametersSize / self.next
                for index = 0, self.count do
                    local address = (self.parametersAddress + index * self.next)
                    local v = gg.getValues({
                        {address = address + self.nameIndex, flags = 4},
                        {address = address + self.token, flags = 4},
                        {address = address + self.typeIndex, flags = 4},    
                    })
                    self.Il2CppParameterDefinitionTable[index] = {nameIndex = v[1].value, token = v[2].value, typeIndex = v[3].value}
                end
            end
        end,
        getIndex = function(index, token)
            if Il2cpp.GlobalMetadataApi.Il2CppParameterDefinition.cache[index] then
                return Il2cpp.GlobalMetadataApi.Il2CppParameterDefinition.cache[index]
            end
            if not Il2cpp.GlobalMetadataApi.Il2CppParameterDefinition.parametersAddress then
                Il2cpp.GlobalMetadataApi.Il2CppParameterDefinition.parametersAddress = Il2cpp.globalMetadataStart + Il2cpp.GlobalMetadataApi.parametersOffset
            end
            local id = index * (Il2cpp.GlobalMetadataApi.Il2CppParameterDefinition.typeIndex + 4)
            local address = Il2cpp.GlobalMetadataApi.Il2CppParameterDefinition.parametersAddress + id
            local v = gg.getValues({
                {address = address + Il2cpp.GlobalMetadataApi.Il2CppParameterDefinition.nameIndex, flags = 4},
                {address = address + Il2cpp.GlobalMetadataApi.Il2CppParameterDefinition.token, flags = 4},
                {address = address + Il2cpp.GlobalMetadataApi.Il2CppParameterDefinition.typeIndex, flags = 4},    
            })
            local data = {nameIndex = v[1].value, token = v[2].value, typeIndex = v[3].value}
            if not Il2cpp.GlobalMetadataApi.Il2CppParameterDefinition.parametersFix and token and token ~= data.token then
                Il2cpp.GlobalMetadataApi.Il2CppParameterDefinition.parametersFix = true
                Il2cpp.GlobalMetadataApi.Il2CppParameterDefinition.parametersAddress = Il2cpp.globalMetadataStart + gg.getValues{{address = Il2cpp.globalMetadataStart + (20 * 4), flags = 4}}[1].value
                return Il2cpp.GlobalMetadataApi.Il2CppParameterDefinition.getIndex(index)
            end
            Il2cpp.GlobalMetadataApi.Il2CppParameterDefinition.cache[index] = data
            return data
        end
    },
    GenericContainers = {},
    getGenericContainers = function(self, index)
        if (self.version < 27) then
            local genericContainers = Il2cpp.globalMetadataStart + self.genericContainersOffset
            index = (0x10 * index) + genericContainers
        else
            index = Il2cpp.FixValue(index)
        end
        if self.GenericContainers[index] then return self.GenericContainers[index] end
        local genericContainers = gg.getValues({
        {
            address = index + 4,
            flags = gg.TYPE_DWORD
        },{
            address = index + 0xC,
            flags = gg.TYPE_DWORD
        }})
        genericContainers[1].name = 'type_argc'
        genericContainers[2].name = 'genericParameterStart'
        self.GenericContainers[index] = genericContainers
        return genericContainers
    end,
    
    GenericParameter = {},
    getGenericParameter = function(self, index)
        local genericParameter = Il2cpp.globalMetadataStart + self.genericParametersOffset
        index = (16 * index) + genericParameter
        if self.GenericParameter[index] then return self.GenericParameter[index] end
        local genericParameter = gg.getValues({
        {
            address = index + 4,
            flags = gg.TYPE_DWORD
        }})
        genericParameter[1].name = 'nameIndex'
        self.GenericParameter[index] = genericParameter
        return genericParameter
    end,
    
    getGenericParameterFromIl2CppType = function(self, il2CppType)
        if self.version >= 27 then
            local offset = il2CppType - Il2cpp.globalMetadataStart - self.genericParametersOffset
            local index = math.floor(offset / 16)
            return self:getGenericParameter(index)
        else
            return self:getGenericParameter(il2CppType)
        end
    end,


    ---@param name string
    GetPointersToString = function(name, mtStart, mtEnd)
        local pointers = {}
        gg.clearResults()
        gg.setRanges(0)
        gg.setRanges(gg.REGION_C_HEAP | gg.REGION_C_HEAP | gg.REGION_ANONYMOUS | gg.REGION_C_BSS | gg.REGION_C_DATA |
                         gg.REGION_OTHER | gg.REGION_C_ALLOC)
        gg.searchNumber(string.format("Q 00 '%s' 00", name), gg.TYPE_BYTE, false, gg.SIGN_EQUAL,
            mtStart or Il2cpp.globalMetadataStart, mtEnd or Il2cpp.globalMetadataEnd)
        if gg.getResultsCount() == 0 and Il2cpp.globalMetadataOb then
            Il2cpp.Searcher.FindGlobalMetaDataOb()
            gg.setRanges(-1);
            gg.searchNumber(string.format("Q 00 '%s' 00", name), gg.TYPE_BYTE, false, gg.SIGN_EQUAL, Il2cpp.globalMetadataObStart, Il2cpp.globalMetadataObEnd)
        end
        local results = gg.getResults(1, 1)
        if #results == 0 then
            return {}, string.format("Không tìm thấy lớp %s trong global-metadata", className)
        end
        gg.clearResults()
        gg.setRanges(Il2cpp.regionClass);
        gg.searchNumber(results[1].address, Il2cpp.MainType)
        if gg.getResultsCount() == 0 and AndroidInfo.platform and AndroidInfo.sdk >= 30 then
            gg.searchNumber(tostring(results[1].address | 0xB400000000000000), Il2cpp.MainType)
        end
        pointers = gg.getResults(gg.getResultsCount())
        if (#pointers == 0 or #pointers == 1) and not mtStart then
            Il2cpp.Searcher.FindGlobalMetaDataOb()
            return Il2cpp.GlobalMetadataApi.GetPointersToString(name, Il2cpp.globalMetadataObStart, Il2cpp.globalMetadataObEnd)
        end
        assert(type(pointers) == 'table' and #pointers > 0, string.format("this '%s' is not in the global-metadata", name))
        gg.clearResults()
        return pointers
    end
}

return GlobalMetadataApi
end)__bundle_register("il2cppstruct.field", function(require, _LOADED, __bundle_register, __bundle_modules)
local Protect = require("utils.protect")

---@class FieldApi
---@field Offset number
---@field Type number
---@field ClassOffset number
---@field Find fun(self : FieldApi, fieldSearchCondition : string | number) : FieldInfo[] | ErrorSearch
local FieldApi = {

    DumpEnum = false,
    ---@param self FieldApi
    ---@param FieldInfoAddress number
    UnpackFieldInfo = function(self, FieldInfoAddress)
        return {
            { -- Field Name
                address = FieldInfoAddress,
                flags = Il2cpp.MainType
            }, 
            { -- Offset Field
                address = FieldInfoAddress + self.Offset,
                flags = gg.TYPE_WORD
            }, 
            { -- Field type
                address = FieldInfoAddress + self.Type,
                flags = Il2cpp.MainType
            }, 
            { -- Class address
                address = FieldInfoAddress + self.ClassOffset,
                flags = Il2cpp.MainType
            }
        }
    end,


    ---@param self FieldApi
    DecodeFieldsInfo = function(self, FieldsInfo, ClassCharacteristic)
        
        if self.DumpEnum and not Il2cpp.GlobalMetadataApi.Il2CppFieldDefaultValue.Il2CppFieldDefaultTable then
            Il2cpp.GlobalMetadataApi.Il2CppFieldDefaultValue:new()
        end
        
        local index, _FieldsInfo = 0, {}
        local fieldStart = gg.getValues({{
            address = ClassCharacteristic.TypeMetadataHandle + Il2cpp.Il2CppTypeDefinitionApi.fieldStart,
            flags = gg.TYPE_DWORD
        }})[1].value
        for i = 1, #FieldsInfo, 4 do
            index = index + 1
            local TypeInfo = Il2cpp.FixValue(FieldsInfo[i + 2].value)
            local _TypeInfo = gg.getValues({
                { -- attrs
                    address = TypeInfo + self.Type,
                    flags = gg.TYPE_WORD
                }, 
                { -- type index | type
                    address = TypeInfo + Il2cpp.TypeApi.Type,
                    flags = gg.TYPE_BYTE
                }, 
                { -- index | data
                    address = TypeInfo,
                    flags = Il2cpp.MainType
                }
            })
            local attrs = _TypeInfo[1].value
            local IsConst = (attrs & Il2CppFlags.Field.FIELD_ATTRIBUTE_LITERAL) ~= 0
            local FieldName = Il2cpp.Utf8ToString(Il2cpp.FixValue(FieldsInfo[i].value))
            local Value = (self.DumpEnum and IsConst) and (ClassCharacteristic.TypeMetadataHandle == 0 and FieldName:gsub("Name", "") or Il2cpp.GlobalMetadataApi.Il2CppFieldDefaultValue:getValue(fieldStart + index - 1)) or nil
            if type(Value) == "table" and Value.Error then
                error{name = FieldName, error = Value.Error}
            end
            --print(Value)
            _FieldsInfo[index] = setmetatable({
                ClassName = ClassCharacteristic.ClassName or Il2cpp.ClassApi:GetClassName(FieldsInfo[i + 3].value),
                ClassAddress = string.format('%X', Il2cpp.FixValue(FieldsInfo[i + 3].value)),
                FieldName = FieldName,
                FieldInfoAddress = string.format('%X', FieldsInfo[i].address),
                Offset = string.format('%X', FieldsInfo[i + 1].value),
                Value = Value,
                IsStatic = (not IsConst) and ((attrs & Il2CppFlags.Field.FIELD_ATTRIBUTE_STATIC) ~= 0),
                Type = Il2cpp.TypeApi:GetTypeName(_TypeInfo[2].value, _TypeInfo[3].value),
                IsConst = IsConst,
                Access = Il2CppFlags.Field.Access[attrs & Il2CppFlags.Field.FIELD_ATTRIBUTE_FIELD_ACCESS_MASK] or "",
            }, {
                --__name = FieldName,
                __index = Il2cpp.FieldInfoApi,
                fieldIndex = fieldStart + index - 1
            })
        end
        return _FieldsInfo
    end,


    ---@param self FieldApi
    ---@param fieldName string
    ---@return FieldInfo[]
    FindFieldWithName = function(self, fieldName)
        local fieldNamePoint = Il2cpp.GlobalMetadataApi.GetPointersToString(fieldName)
        local ResultTable = {}
        for k, v in ipairs(fieldNamePoint) do
            local classAddress = gg.getValues({{
                address = v.address + self.ClassOffset,
                flags = Il2cpp.MainType
            }})[1].value
            if Il2cpp.ClassApi.IsClassInfo(classAddress) then
                local result = self.FindFieldInClass(fieldName, classAddress)
                table.move(result, 1, #result, #ResultTable + 1, ResultTable)
            end
        end
        assert(type(ResultTable) == "table" and #ResultTable > 0, string.format("The '%s' field is not initialized", fieldName))
        return ResultTable
    end,
    
    FindFieldWithFindString = function(self, fieldResults)
        local fieldNamePoint = fieldResults
        local ResultTable = {}
        for k, v in ipairs(fieldNamePoint) do
            local classAddress = gg.getValues({{
                address = v.address + self.ClassOffset,
                flags = Il2cpp.MainType
            }})[1].value
            local fieldName = Il2cpp.Utf8ToString(Il2cpp:GetPtr(v.address))
            if Il2cpp.ClassApi.IsClassInfo(classAddress) then
                local result = self.FindFieldInClass(fieldName, classAddress)
                table.move(result, 1, #result, #ResultTable + 1, ResultTable)
            end
        end
        if #ResultTable == 0 then
            return false
        end
        return ResultTable
    end,


    ---@param self FieldApi
    FindFieldWithAddress = function(self, fieldAddress)
        local ObjectHead = Il2cpp.ObjectApi.FindHead(fieldAddress)
        local fieldOffset = fieldAddress - ObjectHead.address
        local classAddress = Il2cpp.FixValue(ObjectHead.value)
        local ResultTable = self.FindFieldInClass(fieldOffset, classAddress)
        assert(#ResultTable > 0, string.format("nothing was found for this address 0x%X", fieldAddress))
        return ResultTable
    end,

    FindFieldInClass = function(fieldSearchCondition, classAddress)
        local ResultTable = {}
        local Il2cppClass = Il2cpp.FindClass({
            {
                Class = classAddress, 
                FieldsDump = true
            }
        })[1]
        for i, v in ipairs(Il2cppClass) do
            ResultTable[#ResultTable + 1] = type(fieldSearchCondition) == "number" 
                and v:GetFieldWithOffset(fieldSearchCondition)
                or v:GetFieldWithName(fieldSearchCondition)
        end
        return ResultTable
    end,


    FindTypeCheck = {
        ---@param self FieldApi
        ---@param fieldName string
        ['string'] = function(self, fieldName)
            return Protect:Call(self.FindFieldWithName, self, fieldName)
        end,
        ---@param self FieldApi
        ---@param fieldAddress number
        ['number'] = function(self, fieldAddress)
            return Protect:Call(self.FindFieldWithAddress, self, fieldAddress)
        end,
        ['default'] = function()
            return {
                Error = 'Invalid search criteria'
            }
        end
    },


    ---@param self FieldApi
    ---@param fieldSearchCondition number | string
    ---@return FieldInfo[] | ErrorSearch
    Find = function(self, fieldSearchCondition)
        local FieldsInfo = (self.FindTypeCheck[type(fieldSearchCondition)] or self.FindTypeCheck['default'])(self, fieldSearchCondition)
        return FieldsInfo
    end
}

return FieldApi

end)__bundle_register("il2cppstruct.class", function(require, _LOADED, __bundle_register, __bundle_modules)
local Protect = require("utils.protect")
local StringUtils = require("utils.stringutils")
local Il2cppMemory = require("utils.il2cppmemory")

---@class ClassApi
---@field NameOffset number
---@field MethodsStep number
---@field CountMethods number
---@field MethodsLink number
---@field FieldsLink number
---@field FieldsStep number
---@field CountFields number
---@field ParentOffset number
---@field NameSpaceOffset number
---@field StaticFieldDataOffset number
---@field EnumType number
---@field EnumRsh number
---@field TypeMetadataHandle number
---@field InstanceSize number
---@field Token number
---@field GetClassName fun(self : ClassApi, ClassAddress : number) : string
---@field GetClassMethods fun(self : ClassApi, MethodsLink : number, Count : number, ClassName : string | nil) : MethodInfo[]
local ClassApi = {
    
    outputDumper = "CS", -- Lua
    
    ---@param self ClassApi
    ---@param ClassAddress number
    GetClassName = function(self, ClassAddress)
        return Il2cpp.Utf8ToString(Il2cpp.FixValue(gg.getValues({{
            address = Il2cpp.FixValue(ClassAddress) + self.NameOffset,
            flags = Il2cpp.MainType
        }})[1].value))
    end,
    
    
    ---@param self ClassApi
    ---@param MethodsLink number
    ---@param Count number
    ---@param ClassName string | nil
    GetClassMethods = function(self, MethodsLink, Count, ClassName)
        local MethodsInfo, _MethodsInfo = {}, {}; --gg.addListItems({{address = MethodsLink, flags = 4, name = ClassName .. ": " .. Count}})
        for i = 0, Count - 1 do
            _MethodsInfo[#_MethodsInfo + 1] = {
                address = MethodsLink + (i << self.MethodsStep),
                flags = Il2cpp.MainType
            }
        end
        _MethodsInfo = gg.getValues(_MethodsInfo)
        for i = 1, #_MethodsInfo do
            local MethodInfo
            MethodInfo, _MethodsInfo[i] = Il2cpp.MethodsApi:UnpackMethodInfo({
                MethodInfoAddress = Il2cpp.FixValue(_MethodsInfo[i].value),
                ClassName = ClassName
            })
            table.move(MethodInfo, 1, #MethodInfo, #MethodsInfo + 1, MethodsInfo)
        end
        MethodsInfo = gg.getValues(MethodsInfo)
        Il2cpp.MethodsApi:DecodeMethodsInfo(_MethodsInfo, MethodsInfo)
        return _MethodsInfo
    end,


    GetClassFields = function(self, FieldsLink, Count, ClassCharacteristic)
        local FieldsInfo, _FieldsInfo = {}, {}
        for i = 0, Count - 1 do
            _FieldsInfo[#_FieldsInfo + 1] = {
                address = FieldsLink + (i * self.FieldsStep),
                flags = Il2cpp.MainType
            }
        end
        _FieldsInfo = gg.getValues(_FieldsInfo)
        for i = 1, #_FieldsInfo do
            local FieldInfo
            FieldInfo = Il2cpp.FieldApi:UnpackFieldInfo(Il2cpp.FixValue(_FieldsInfo[i].address))
            table.move(FieldInfo, 1, #FieldInfo, #FieldsInfo + 1, FieldsInfo)
        end
        FieldsInfo = gg.getValues(FieldsInfo)
        _FieldsInfo = Il2cpp.FieldApi:DecodeFieldsInfo(FieldsInfo, ClassCharacteristic)
        return _FieldsInfo
    end,
    
    FixName = function(name)
        return (name:find("`%d") and name:gsub("`%d+", "") .. string.gsub("<" .. string.rep(", type", name:gmatch("`(.*)")()) .. ">", "<, ", "<") or name)
    end,


    ---@param self ClassApi
    ---@param ClassInfo ClassInfoRaw
    ---@param Config table
    ---@return ClassInfo
    UnpackClassInfo = function(self, ClassInfo, Config)
        if Il2cpp.regionClass == -2080860 then
            local Range = gg.getValuesRange({{address = ClassInfo.ClassInfoAddress, flags = Il2cpp.MainType}})[1]
            Il2cpp.regionClass = Il2cpp.regionType[Range]
        end
        local _ClassInfo = gg.getValues({
            { -- Class Name [1]
                address = ClassInfo.ClassInfoAddress + self.NameOffset,
                flags = Il2cpp.MainType
            },
            { -- Methods Count [2]
                address = ClassInfo.ClassInfoAddress + self.CountMethods,
                flags = gg.TYPE_WORD
            },
            { -- Fields Count [3]
                address = ClassInfo.ClassInfoAddress + self.CountFields,
                flags = gg.TYPE_WORD
            },
            { -- Link as Methods [4]
                address = ClassInfo.ClassInfoAddress + self.MethodsLink,
                flags = Il2cpp.MainType
            },
            { -- Link as Fields [5]
                address = ClassInfo.ClassInfoAddress + self.FieldsLink,
                flags = Il2cpp.MainType
            },
            { -- Link as Parent Class [6]
                address = ClassInfo.ClassInfoAddress + self.ParentOffset,
                flags = Il2cpp.MainType
            },
            { -- Class NameSpace [7]
                address = ClassInfo.ClassInfoAddress + self.NameSpaceOffset,
                flags = Il2cpp.MainType
            },
            { -- Class Static Field Data [8]
                address = ClassInfo.ClassInfoAddress + self.StaticFieldDataOffset,
                flags = Il2cpp.MainType
            },
            { -- EnumType [9]
                address = ClassInfo.ClassInfoAddress + self.EnumType,
                flags = gg.TYPE_BYTE
            },
            { -- TypeMetadataHandle [10]
                address = ClassInfo.ClassInfoAddress + self.TypeMetadataHandle,
                flags = Il2cpp.MainType
            },
            { -- InstanceSize [11]
                address = ClassInfo.ClassInfoAddress + self.InstanceSize,
                flags = gg.TYPE_DWORD
            },
            { -- Token [12]
                address = ClassInfo.ClassInfoAddress + self.Token,
                flags = gg.TYPE_DWORD
            },
            { -- DeclaringType [13]
                address = ClassInfo.ClassInfoAddress + self.ParentOffset - Il2cpp.pointSize,
                flags = Il2cpp.MainType
            },
            { -- Flags [14]
                address = ClassInfo.ClassInfoAddress + 0x2A,
                flags = gg.TYPE_BYTE
            },
            { -- genericContainer [15]
                address = ClassInfo.ClassInfoAddress + self.GenericContainer,
                flags = Il2cpp.MainType--gg.TYPE_DWORD
            },
            { -- GeneratedClass [16]
                address = ClassInfo.ClassInfoAddress + self.ParentOffset + Il2cpp.pointSize,
                flags = Il2cpp.MainType
            },
        })
        local Name = ClassInfo.ClassName or Il2cpp.Utf8ToString(Il2cpp.FixValue(_ClassInfo[1].value))
        local index = Name:find("`")
        if --[[_ClassInfo[15].value ~= 0 and]] index then
            if index then
                Name = Name:sub(1, index - 1)
            end
            local genericContainers = Il2cpp.GlobalMetadataApi:getGenericContainers(_ClassInfo[15].value)
            local genericParameterNames = {}
            for i = 1, genericContainers[1].value do
                local genericParameterIndex = genericContainers[2].value + (i-1)
                local genericParameter = Il2cpp.GlobalMetadataApi:getGenericParameter(genericParameterIndex)
                genericParameterNames[i] = Il2cpp.GlobalMetadataApi:GetStringFromIndex(genericParameter[1].value)
            end
            Name = Name .. "<" .. table.concat(genericParameterNames, ", ") .. ">"
            --end
        end
        local ClassGenerated = _ClassInfo[13].value ~= 0 and {
           ClassAddress = string.format('%X', Il2cpp.FixValue(_ClassInfo[13].value)), 
           ClassName = self:GetClassName(_ClassInfo[13].value):gsub("`%d+", "") .. "." --self.FixName(self:GetClassName(_ClassInfo[13].value))
        } or nil
        --local Name = self.FixName(ClassInfo.ClassName or Il2cpp.Utf8ToString(Il2cpp.FixValue(_ClassInfo[1].value)))
        local ClassName = (not ClassGenerated and Name or ClassGenerated.ClassName .. Name)
        local ClassCharacteristic = {
            ClassName = ClassName,
            IsEnum = ((_ClassInfo[9].value >> self.EnumRsh) & 1) == 1,
            TypeMetadataHandle = Il2cpp.FixValue(_ClassInfo[10].value)
        }
        --gg.addListItems({_ClassInfo[9]})
        local typeDefIndex = gg.getValues{{address = ClassCharacteristic.TypeMetadataHandle, flags = 4}}[1].value
        if Il2cpp.globalMetadataOb and not Il2cpp.GlobalMetadataApi.stringDefinitionsOb and typeDefIndex > 0x40000000 then
            Il2cpp.GlobalMetadataApi.stringDefinitionsOb = Il2cpp.FixValue(_ClassInfo[1].value) - (typeDefIndex & 0xfffff)
        end
        
        return setmetatable({
            ClassName = ClassName,
            ClassAddress = string.format('%X', Il2cpp.FixValue(ClassInfo.ClassInfoAddress)),
            Methods = (_ClassInfo[2].value > 0 and Config.MethodsDump and _ClassInfo[4].value ~= 0) and
                self:GetClassMethods(Il2cpp.FixValue(_ClassInfo[4].value), _ClassInfo[2].value, ClassName) or nil,
            Fields = (_ClassInfo[3].value > 0 and Config.FieldsDump and _ClassInfo[5].value ~= 0) and
                self:GetClassFields(Il2cpp.FixValue(_ClassInfo[5].value), _ClassInfo[3].value, ClassCharacteristic) or
                nil,
            Parent = _ClassInfo[6].value ~= 0 and self:Find({Class = _ClassInfo[6].value})[1] or nil,
            Generated = ClassGenerated,
            ClassNameSpace = Il2cpp.Utf8ToString(Il2cpp.FixValue(_ClassInfo[7].value)),
            StaticFieldData = _ClassInfo[8].value ~= 0 and Il2cpp.FixValue(_ClassInfo[8].value) or nil,
            IsEnum = ClassCharacteristic.IsEnum,
            TypeMetadataHandle = ClassCharacteristic.TypeMetadataHandle,
            InstanceSize = _ClassInfo[11].value,
            --Flags = _ClassInfo[14].value,
            Token = string.format("0x%X", _ClassInfo[12].value),
            ImageName = ClassInfo.ImageName
        }, {
            __index = Il2cpp.ClassInfoApi,
            __tostring = self.outputDumper == "Lua" and StringUtils.ClassInfoToDumpLua or StringUtils.ClassInfoToDumpCS
        })
    end,
    
    getAccess = function(flags, IsEnum, IsValueType)
        local access
        local visibility = flags & 7 --[[Il2CppConstants.TYPE_ATTRIBUTE_VISIBILITY_MASK]]
        --print(flags, visibility)
        repeat
          if visibility == 1 --[[Il2CppConstants.TYPE_ATTRIBUTE_PUBLIC]] or visibility == 2 --[[Il2CppConstants.TYPE_ATTRIBUTE_NESTED_PUBLIC]] then
            access = "public "
            break
          elseif visibility == 0 --[[Il2CppConstants.TYPE_ATTRIBUTE_NOT_PUBLIC]] or visibility == 6 --[[Il2CppConstants.TYPE_ATTRIBUTE_NESTED_FAM_AND_ASSEM]] or visibility == 5 --[[Il2CppConstants.TYPE_ATTRIBUTE_NESTED_ASSEMBLY]] then
            access = "internal "
            break
          elseif visibility == 3 --[[Il2CppConstants.TYPE_ATTRIBUTE_NESTED_PRIVATE]] then
            access = "private "
            break
          elseif visibility == 4 --[[Il2CppConstants.TYPE_ATTRIBUTE_NESTED_FAMILY]] then
            access = "protected "
            break
          elseif visibility == 7 --[[Il2CppConstants.TYPE_ATTRIBUTE_NESTED_FAM_OR_ASSEM]] then
            access = "protected internal "
            break
          end
        until 1
        if (flags & 128 --[[Il2CppConstants.TYPE_ATTRIBUTE_ABSTRACT]]) ~= 0 and (flags & 256 --[[Il2CppConstants.TYPE_ATTRIBUTE_SEALED]]) ~= 0 then
          access = access .. "static "
        elseif (flags & 32 --[[Il2CppConstants.TYPE_ATTRIBUTE_INTERFACE]]) == 0 and (flags & 128 --[[Il2CppConstants.TYPE_ATTRIBUTE_ABSTRACT]]) ~= 0 then
          access = access .. "abstract "
        elseif not IsValueType and not IsEnum and (flags & 256 --[[Il2CppConstants.TYPE_ATTRIBUTE_SEALED]]) ~= 0 then
          access = access .. "sealed "
        end
        if (flags & 32 --[[Il2CppConstants.TYPE_ATTRIBUTE_INTERFACE]]) ~= 0 then
          access = access .. "interface "
        elseif IsEnum then
          access = access .. "enum "
        elseif IsValueType then
          access = access .. "struct "
        else
          access = access .. "class "
        end
        return access
    end,

    --- Không xác định chính xác lắm, đặc biệt là trong phiên bản thứ 29 của phần phụ trợ
    ---@param Address number
    IsClassInfo = function(Address)
        local imageAddress = Il2cpp.FixValue(gg.getValues(
            {
                {
                    address = Il2cpp.FixValue(Address),
                    flags = Il2cpp.MainType
                }
            }
        )[1].value)
        local imageStr = Il2cpp.Utf8ToString(Il2cpp.FixValue(gg.getValues(
            {
                {
                    address = imageAddress,
                    flags = Il2cpp.MainType
                }
            }
        )[1].value))
        local check = string.find(imageStr, ".-%.dll") or string.find(imageStr, "__Generated")
        return check and imageStr or nil
    end,


    ---@param self ClassApi
    ---@param ClassName string
    ---@param searchResult ClassMemory
    FindClassWithName = function(self, ClassName, searchResult)
        local ClassNamePoint = Il2cpp.GlobalMetadataApi.GetPointersToString(ClassName)
        local ResultTable = {}
        if #ClassNamePoint > searchResult.len then
            for classPointIndex, classPoint in ipairs(ClassNamePoint) do
                local classAddress = classPoint.address - self.NameOffset
                local imageName = self.IsClassInfo(classAddress)
                if (imageName) then
                    ResultTable[#ResultTable + 1] = {
                        ClassInfoAddress = Il2cpp.FixValue(classAddress),
                        ClassName = ClassName,
                        ImageName = imageName
                    }
                end
            end
            searchResult.len = #ClassNamePoint
        else
            searchResult.isNew = false
        end
        assert(#ResultTable > 0, string.format("The '%s' class is not initialized", ClassName))
        return ResultTable
    end,


    ---@param self ClassApi
    ---@param ClassAddress number
    ---@param searchResult ClassMemory
    ---@return ClassInfoRaw[]
    FindClassWithAddressInMemory = function(self, ClassAddress, searchResult)
        local ResultTable = {}
        if searchResult.len < 1 then
            local imageName = self.IsClassInfo(ClassAddress)
            if imageName then
                ResultTable[#ResultTable + 1] = {
                    ClassInfoAddress = ClassAddress,
                    ImageName = imageName
                }
            end
            searchResult.len = 1
        else
            searchResult.isNew = false
        end
        assert(#ResultTable > 0, string.format("nothing was found for this address 0x%X", ClassAddress))
        return ResultTable
    end,
    
    FindClassWithFindString = function(self, ClassResults, FieldsDump, MethodsDump)
        local ClassNamePoint = ClassResults
        local ClassInfo = {}
        if #ClassNamePoint > 0 then
            for classPointIndex, classPoint in ipairs(ClassNamePoint) do
                local classAddress = classPoint.address - self.NameOffset
                local imageName = self.IsClassInfo(classAddress)
                if (imageName) then
                    ClassInfo[#ClassInfo + 1] = {
                        ClassInfoAddress = Il2cpp.FixValue(classAddress),
                        ClassName = ClassName,
                        ImageName = imageName
                    }
                    ClassInfo[#ClassInfo] = self:UnpackClassInfo(ClassInfo[#ClassInfo], {
                    FieldsDump = FieldsDump,
                    MethodsDump = MethodsDump
                    })
                end
            end
        else
            return false
        end
        return ClassInfo
    end,

    
    


    FindParamsCheck = {
        ---@param self ClassApi
        ---@param _class number @Class Address In Memory
        ---@param searchResult ClassMemory
        ['number'] = function(self, _class, searchResult)
            return Protect:Call(self.FindClassWithAddressInMemory, self, _class, searchResult)
        end,
        ---@param self ClassApi
        ---@param _class string @Class Name
        ---@param searchResult ClassMemory
        ['string'] = function(self, _class, searchResult)
            return Protect:Call(self.FindClassWithName, self, _class, searchResult)
        end,
        ['default'] = function()
            return {
                Error = 'Invalid search criteria'
            }
        end
    },


    ---@param self ClassApi
    ---@param class ClassConfig
    ---@return ClassInfo[] | ErrorSearch
    Find = function(self, class)
        --class.Class = class.Class or class[1]
        local searchResult = Il2cppMemory:GetInformationOfClass(class.Class)
        if not searchResult 
        or (class.FieldsDump and searchResult.config.FieldsDump ~= class.FieldsDump) 
        or (class.MethodsDump and searchResult.config.MethodsDump ~= class.MethodsDump) then
            searchResult =  {len = 0}
        end

        searchResult.isNew = true

        ---@type ClassInfoRaw[] | ErrorSearch
        local ClassInfo =
            (self.FindParamsCheck[type(class.Class)] or self.FindParamsCheck['default'])(self, class.Class, searchResult)
        if searchResult.isNew then
            for k = 1, #ClassInfo do
                ClassInfo[k] = self:UnpackClassInfo(ClassInfo[k], {
                    FieldsDump = class.FieldsDump,
                    MethodsDump = class.MethodsDump
                })
            end
            searchResult.config = {
                Class = class.Class,
                FieldsDump = class.FieldsDump,
                MethodsDump = class.MethodsDump
            }
            searchResult.result = ClassInfo
            Il2cppMemory:SetInformationOfClass(class.Class, searchResult)
        else
            ClassInfo = searchResult.result
        end
        return ClassInfo
    end
}

return ClassApi
end)__bundle_register("utils.stringutils", function(require, _LOADED, __bundle_register, __bundle_modules)
---@class StringUtils
local StringUtils = {

    ---@param classInfo ClassInfo
    ClassInfoToDumpCS = function(classInfo)
        local dumpClass = {
            "// ", classInfo.ImageName, "\n",
            "// Namespace: ", classInfo.ClassNameSpace, "\n";

            "class ", classInfo.ClassName, classInfo.Parent and " : " .. classInfo.Parent.ClassName or "", "\n", 
            "{\n"
        }

        if classInfo.Fields and #classInfo.Fields > 0 then
            dumpClass[#dumpClass + 1] = "\n\t// Fields\n"
            for i, v in ipairs(classInfo.Fields) do
                local enum = v.IsConst and Il2cpp.FieldApi.DumpEnum and true or false
                local dumpField = {
                    "\t", v.Access, " ", v.IsStatic and "static " or "", v.IsConst and "const " or "", v.Type, " ", v.FieldName, enum and " = " or "; // 0x", enum and v.Value .. ";" or v.Offset, "\n"
                }
                table.move(dumpField, 1, #dumpField, #dumpClass + 1, dumpClass)
            end
        end

        if classInfo.Methods and #classInfo.Methods > 0 then
            dumpClass[#dumpClass + 1] = "\n\t// Methods\n"
            for i, v in ipairs(classInfo.Methods) do
                
                    local dumpMethod = {
                        i == 1 and "" or "\n",
                        "\t// Offset: 0x", v.Offset, " VA: 0x", v.AddressInMemory, "\n",
                        "\t", v.Access, " ",  v.IsStatic and "static " or "", v.IsAbstract and "abstract " or "", v.ReturnType, " ", v.MethodName, "(" .. v.ParamType .. ") { } \n"
                    }
                
                table.move(dumpMethod, 1, #dumpMethod, #dumpClass + 1, dumpClass)
            end
        end
        
        table.insert(dumpClass, "\n}\n")
        return table.concat(dumpClass)
    end,
    ClassInfoToDumpLua = function(classInfo)
        local dumpClass = "--Dll " .. classInfo.ImageName .. "\n"
        dumpClass = dumpClass .. "il2cpp.class['" .. (classInfo.ClassNameSpace ~= "" and classInfo.ClassNameSpace .. "." or "") .. classInfo.ClassName .. "']={\n" .. (classInfo.Parent and "'" .. classInfo.Parent.ClassName .. "',\n" or "\n")
        if classInfo.Fields and #classInfo.Fields > 0 then
            dumpClass = dumpClass .. "\t" .. "fields={\n"
            for i, v in ipairs(classInfo.Fields) do
                local t = v.IsStatic and "static', '" or v.IsConst and "const', '" or ''
                local dumpField = "\t\t" ..
                        "{'" .. v.Access .. "', '" .. t .. v.Type .. "', '" .. v.FieldName .. (v.Value and "', " or "', 0x") .. (v.Value and (tonumber(v.Value) and v.Value or "'" .. tostring(v.Value):gsub("'", '"'):gsub("\\", "\\\\") .. "'") or v.Offset) .. "},\n"
                dumpClass = dumpClass .. dumpField
            end
            dumpClass = dumpClass .. "\t},\n"
        end
        if classInfo.Methods and #classInfo.Methods > 0 then
            dumpClass = dumpClass .. "\t" .. "methods={\n"
            for i, v in ipairs(classInfo.Methods) do
                local t = v.IsStatic and "', 'static" or v.IsAbstract and "', 'abstract" or ''
                local em = i < #classInfo.Methods and "\n\t\t\t\t}, {\n" or "\n\t\t\t\t}\n"
                local dumpMethod = "\t\t" ..
                   "{'" .. v.Access .. t .. 
                   "', '" .. v.ReturnType .. 
                   "', '" .. v.MethodName .. 
                   "', " .. v.ParamType ..
                   ", 0x" .. v.Offset ..
                   "},\n"
                dumpClass = dumpClass .. dumpMethod
            end
                dumpClass = dumpClass .. "\t}\n"
            end
        return dumpClass .. "};\n"
    end
}

return StringUtils
end)__bundle_register("il2cppstruct.object", function(require, _LOADED, __bundle_register, __bundle_modules)
local AndroidInfo = require("utils.androidinfo")

---@class ObjectApi
local ObjectApi = {

    regionObject = (gg.REGION_C_HEAP | gg.REGION_C_HEAP | gg.REGION_ANONYMOUS | gg.REGION_C_BSS | gg.REGION_C_DATA | gg.REGION_C_ALLOC),

    ---@param self ObjectApi
    ---@param Objects table
    FilterObjects = function(self, Objects)
        local FilterObjects = {}
        for k, v in ipairs(gg.getValuesRange(Objects)) do
            if v == 'A' then
                FilterObjects[#FilterObjects + 1] = Objects[k]
            end
        end
        Objects = FilterObjects
        gg.loadResults(Objects)
        gg.searchPointer(0)
        if gg.getResultsCount() <= 0 and AndroidInfo.platform and AndroidInfo.sdk >= 30 then
            local FixRefToObjects = {}
            for k, v in ipairs(Objects) do
                gg.searchNumber(tostring(v.address | 0xB400000000000000), gg.TYPE_QWORD)
                ---@type tablelib
                local RefToObject = gg.getResults(gg.getResultsCount())
                table.move(RefToObject, 1, #RefToObject, #FixRefToObjects + 1, FixRefToObjects)
                gg.clearResults()
            end
            gg.loadResults(FixRefToObjects)
        end
        local RefToObjects, FilterObjects = gg.getResults(gg.getResultsCount()), {}
        gg.clearResults()
        for k, v in ipairs(gg.getValuesRange(RefToObjects)) do
            if v == 'A' then
                FilterObjects[#FilterObjects + 1] = {
                    address = Il2cpp.FixValue(RefToObjects[k].value),
                    flags = RefToObjects[k].flags
                }
            end
        end
        gg.loadResults(FilterObjects)
        local _FilterObjects = gg.getResults(gg.getResultsCount())
        gg.clearResults()
        return _FilterObjects
    end,


    ---@param self ObjectApi
    ---@param ClassAddress string
    FindObjects = function(self, ClassAddress)
        gg.clearResults()
        gg.setRanges(0)
        --gg.setRanges(gg.REGION_C_HEAP | gg.REGION_C_HEAP | gg.REGION_ANONYMOUS | gg.REGION_C_BSS | gg.REGION_C_DATA | gg.REGION_C_ALLOC)
        gg.setRanges(self.regionObject)
        gg.loadResults({{
            address = tonumber(ClassAddress, 16),
            flags = Il2cpp.MainType
        }})
        gg.searchPointer(0)
        if gg.getResultsCount() <= 0 and AndroidInfo.platform and AndroidInfo.sdk >= 30 then
            gg.searchNumber(tostring(tonumber(ClassAddress, 16) | 0xB400000000000000), gg.TYPE_QWORD)
        end
        local FindsResult = gg.getResults(gg.getResultsCount())
        gg.clearResults()
        local t = {}
        for i, v in ipairs(FindsResult) do
            if gV(v.address + Il2cpp.pointSize) == 0 and gV(v.address + Il2cpp.ClassApi.NameOffset, 4) ~= 75 then
                t[#t+1]=v
            end
        end
        return self:FilterObjects(t);--self:FilterObjects(FindsResult)
    end,

    
    ---@param self ObjectApi
    ---@param ClassesInfo ClassInfo[]
    Find = function(self, ClassesInfo)
        local Objects = {}
        for j = 1, #ClassesInfo do
            local FindResult = self:FindObjects(ClassesInfo[j].ClassAddress)
            table.move(FindResult, 1, #FindResult, #Objects + 1, Objects)
        end
        return Objects
    end,


    FindHead = function(Address)
        local validAddress = Address--Il2cpp.GetValidAddress(Address)
        local mayBeHead = {}
        for i = 1, 1000 do
            mayBeHead[i] = {
                address = validAddress - (4 * (i - 1)),
                flags = Il2cpp.MainType
            } 
        end
        mayBeHead = gg.getValues(mayBeHead)
        for i = 1, #mayBeHead do
            local mayBeClass = Il2cpp.FixValue(mayBeHead[i].value)
            if Il2cpp.ClassApi.IsClassInfo(mayBeClass) then
                return mayBeHead[i]
            end
        end
        return {value = 0, address = 0}
    end,
}

return ObjectApi
end)__bundle_register("il2cppstruct.api.classinfo", function(require, _LOADED, __bundle_register, __bundle_modules)
local ClassInfoApi = {

    
    GetObject = function(self)
        return Il2cpp.FindObject({tonumber(self.ClassAddress, 16)})[1]
    end,

    
    ---Get FieldInfo by Field Name. If Field isn't found by name, then function will return `nil`
    ---@param self ClassInfo
    ---@param name string
    ---@return FieldInfo | nil
    GetFieldWithName = function(self, name)
        local FieldsInfo = self.Fields
        if FieldsInfo then
            for fieldIndex = 1, #FieldsInfo do
                if FieldsInfo[fieldIndex].FieldName == name then
                    return FieldsInfo[fieldIndex]
                end
            end
        else
            local ClassAddress = tonumber(self.ClassAddress, 16)
            local _ClassInfo = gg.getValues({
                { -- Link as Fields
                    address = ClassAddress + Il2cpp.ClassApi.FieldsLink,
                    flags = Il2cpp.MainType
                },
                { -- Fields Count
                    address = ClassAddress + Il2cpp.ClassApi.CountFields,
                    flags = gg.TYPE_WORD
                }
            })
            self.Fields = Il2cpp.ClassApi:GetClassFields(Il2cpp.FixValue(_ClassInfo[1].value), _ClassInfo[2].value, {
                ClassName = self.ClassName,
                IsEnum = self.IsEnum,
                TypeMetadataHandle = self.TypeMetadataHandle
            })
            return self:GetFieldWithName(name)
        end
        return nil
    end,


    ---Get MethodInfo[] by MethodName. If Method isn't found by name, then function will return `table with zero size`
    ---@param self ClassInfo
    ---@param name string
    ---@return MethodInfo[]
    GetMethodsWithName = function(self, name)
        local MethodsInfo, MethodsInfoResult = self.Methods, {}
        if MethodsInfo then
            for methodIndex = 1, #MethodsInfo do
                if MethodsInfo[methodIndex].MethodName == name then
                    MethodsInfoResult[#MethodsInfoResult + 1] = MethodsInfo[methodIndex]
                end
            end
            return MethodsInfoResult
        else
            local ClassAddress = tonumber(self.ClassAddress, 16)
            local _ClassInfo = gg.getValues({
                { -- Link as Methods
                    address = ClassAddress + Il2cpp.ClassApi.MethodsLink,
                    flags = Il2cpp.MainType
                },
                { -- Methods Count
                    address = ClassAddress + Il2cpp.ClassApi.CountMethods,
                    flags = gg.TYPE_WORD
                }
            })
            self.Methods = Il2cpp.ClassApi:GetClassMethods(Il2cpp.FixValue(_ClassInfo[1].value), _ClassInfo[2].value,
                self.ClassName)
            return self:GetMethodsWithName(name)
        end
    end,


    ---@param self ClassInfo
    ---@param fieldOffset number
    ---@return nil | FieldInfo
    GetFieldWithOffset = function(self, fieldOffset)
        if not self.Fields then
            local ClassAddress = tonumber(self.ClassAddress, 16)
            local _ClassInfo = gg.getValues({
                { -- Link as Fields
                    address = ClassAddress + Il2cpp.ClassApi.FieldsLink,
                    flags = Il2cpp.MainType
                },
                { -- Fields Count
                    address = ClassAddress + Il2cpp.ClassApi.CountFields,
                    flags = gg.TYPE_WORD
                }
            })
            self.Fields = Il2cpp.ClassApi:GetClassFields(Il2cpp.FixValue(_ClassInfo[1].value), _ClassInfo[2].value, {
                ClassName = self.ClassName,
                IsEnum = self.IsEnum,
                TypeMetadataHandle = self.TypeMetadataHandle
            })
        end
        if #self.Fields > 0 then
            local klass = self
            while klass ~= nil do
                if klass.Fields and klass.InstanceSize >= fieldOffset then
                    local lastField
                    for indexField, field in ipairs(klass.Fields) do
                        if not (field.IsStatic or field.IsConst) then
                            local offset = tonumber(field.Offset, 16)
                            if offset > 0 then 
                                local maybeStruct = fieldOffset < offset

                                if indexField == 1 and maybeStruct then
                                    break
                                elseif offset == fieldOffset or indexField == #klass.Fields then
                                    return field
                                elseif maybeStruct then
                                    return lastField
                                else
                                    lastField = field
                                end
                            end
                        end
                    end
                end
                klass = klass.Parent ~= nil 
                    and Il2cpp.FindClass({
                        {
                            Class = tonumber(klass.Parent.ClassAddress, 16), 
                            FieldsDump = true
                        }
                    })[1][1] 
                    or nil
            end
        end
        return nil
    end
}

return ClassInfoApi
end)__bundle_register("il2cppstruct.api.fieldinfo", function(require, _LOADED, __bundle_register, __bundle_modules)
local Il2cppMemory = require("utils.il2cppmemory")

---@type FieldInfo
local FieldInfoApi = {


    ---@param self FieldInfo
    ---@return nil | string | number
    GetConstValue = function(self)
        if self.IsConst then
            local fieldIndex = getmetatable(self).fieldIndex
            local defaultValue = Il2cppMemory:GetDefaultValue(fieldIndex)
            if not defaultValue then
                defaultValue = Il2cpp.GlobalMetadataApi:GetDefaultFieldValue(fieldIndex)
                Il2cppMemory:SetDefaultValue(fieldIndex, defaultValue)
            elseif defaultValue == "nil" then
                return nil
            end
            return defaultValue
        end
        return nil
    end
}

return FieldInfoApi
end)__bundle_register("il2cppstruct.il2cppstring", function(require, _LOADED, __bundle_register, __bundle_modules)
---@class StringApi
---@field address number
---@field pointToStr number
---@field Fields table<string, number>
---@field ClassAddress number
local StringApi = {

    ---@param self StringApi
    ---@param newStr string
    EditString = function(self, newStr)
        local _stringLength = gg.getValues{{address = self.address + self.Fields._stringLength, flags = gg.TYPE_DWORD}}[1].value
        _stringLength = _stringLength * 2
        local bytes = gg.bytes(newStr, "UTF-16LE")
        if _stringLength == #bytes then
            local strStart = self.address + self.Fields._firstChar
            for i, v in ipairs(bytes) do
                bytes[i] = {
                    address = strStart + (i - 1),
                    flags = gg.TYPE_BYTE,
                    value = v
                }
            end

            gg.setValues(bytes)
        elseif _stringLength > #bytes then
            local strStart = self.address + self.Fields._firstChar
            local _bytes = {}
            for i = 1, _stringLength do
                _bytes[#_bytes + 1] = {
                    address = strStart + (i - 1),
                    flags = gg.TYPE_BYTE,
                    value = bytes[i] or 0
                }
            end

            gg.setValues(_bytes)
        elseif _stringLength < #bytes then
            self.address = Il2cpp.MemoryManager.MAlloc(self.Fields._firstChar + #bytes + 8)
            local length = #bytes % 2 == 1 and #bytes + 1 or #bytes
            local _bytes = {
                { -- Head
                    address = self.address,
                    flags = Il2cpp.MainType,
                    value = self.ClassAddress
                },
                { -- _stringLength
                    address = self.address + self.Fields._stringLength,
                    flags = gg.TYPE_DWORD,
                    value = length / 2
                }
            }
            local strStart = self.address + self.Fields._firstChar
            for i = 1, length do
                _bytes[#_bytes + 1] = {
                    address = strStart + (i - 1),
                    flags = gg.TYPE_BYTE,
                    value = bytes[i] or 0
                }                
            end
            _bytes[#_bytes + 1] = {
                address = self.pointToStr,
                flags = Il2cpp.MainType,
                value = self.address
            }
            gg.setValues(_bytes)
        end
    end,



    ---@param self StringApi
    ---@return string
    ReadString = function(self)
        local _stringLength = gg.getValues{{address = self.address + self.Fields._stringLength, flags = gg.TYPE_DWORD}}[1].value
        local bytes = {}
        if _stringLength > 0 and _stringLength < 200 then
            local strStart = self.address + self.Fields._firstChar
            for i = 0, _stringLength do
                bytes[#bytes + 1] = {
                    address = strStart + (i << 1),
                    flags = gg.TYPE_WORD
                }
            end
            bytes = gg.getValues(bytes)
            local code = {'return "'}
            for i, v in ipairs(bytes) do
                code[#code + 1] = string.format([[\u{%x}]], v.value & 0xFFFF)
            end
            code[#code + 1] = '"'
            local read, err = load(table.concat(code))
            if read then
                return read()
            end
        end
        return ""
    end
}

---@class MyString
---@field From fun(address : number) : StringApi | nil
local String = {

    ---@param address number
    ---@return StringApi | nil
    From = function(address)
        local pointToStr = gg.getValues({{address = Il2cpp.FixValue(address), flags = Il2cpp.MainType}})[1]
        local str = setmetatable(
            {
                address = Il2cpp.FixValue(pointToStr.value), 
                Fields = {},
                pointToStr = Il2cpp.FixValue(address)
            }, {__index = StringApi})
        local pointClassAddress = gg.getValues({{address = str.address, flags = Il2cpp.MainType}})[1].value
        local stringInfo = Il2cpp.FindClass({{Class = Il2cpp.FixValue(pointClassAddress), FieldsDump = true}})[1]
        for i, v in ipairs(stringInfo) do
            if v.ClassNameSpace == "System" then
                str.ClassAddress = tonumber(v.ClassAddress, 16)
                for indexField, FieldInfo in ipairs(v.Fields) do
                    str.Fields[FieldInfo.FieldName] = tonumber(FieldInfo.Offset, 16)
                end
                return str
            end
        end
        return nil
    end,
    
}

return String
end)__bundle_register("utils.malloc", function(require, _LOADED, __bundle_register, __bundle_modules)
local MemoryManager = {
    availableMemory = 0,
    lastAddress = 0,

    NewAlloc = function(self)
        self.lastAddress = gg.allocatePage(gg.PROT_READ | gg.PROT_WRITE)
        self.availableMemory = 4096
    end,
}

local M = {
    ---@param size number
    MAlloc = function(size)
        local manager = MemoryManager
        if size > manager.availableMemory then
            manager:NewAlloc()
        end
        local address = manager.lastAddress
        manager.availableMemory = manager.availableMemory - size
        manager.lastAddress = manager.lastAddress + size
        return address
    end,
}

return M
end)
return __bundle_require("Il2cppLT9-cli")