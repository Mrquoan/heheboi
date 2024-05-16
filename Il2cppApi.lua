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
__bundle_register("GGIl2cpp", function(require, _LOADED, __bundle_register, __bundle_modules)
require("utils.il2cppconst")
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
end)
__bundle_register("il2cpp", function(require, _LOADED, __bundle_register, __bundle_modules)
local Il2cppMemory = require("utils.il2cppmemory")
local VersionEngine = require("utils.version")
local AndroidInfo = require("utils.androidinfo")
local Searcher = require("utils.universalsearcher")
local PatchApi = require("utils.patchapi")



---@class Il2cpp
local Il2cppBase = {
    il2cppStart = 0,
    il2cppEnd = 0,
    globalMetadataStart = 0,
    globalMetadataEnd = 0,
    globalMetadataHeader = 0,
    MainType = AndroidInfo.platform and gg.TYPE_QWORD or gg.TYPE_DWORD,
    pointSize = AndroidInfo.platform and 8 or 4,
    ---@type Il2CppTypeDefinitionApi
    Il2CppTypeDefinitionApi = {},
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
        local chars, char = {}, {
            address = Address,
            flags = gg.TYPE_BYTE
        }
        if not length then
            repeat
                _char = string.char(gg.getValues({char})[1].value & 0xFF)
                chars[#chars + 1] = _char
                char.address = char.address + 0x1
            until string.find(_char, "[%z%s]")
            return table.concat(chars, "", 1, #chars - 1)
        else
            for i = 1, length do
                local _char = gg.getValues({char})[1].value
                chars[i] = string.char(_char & 0xFF)
                char.address = char.address + 0x1
            end
            return table.concat(chars)
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

        Il2cppMemory:ClearMemorize()
    end,
    __index = function(self, key)
        assert(key == "PatchesAddress", "You didn't call 'Il2cpp'")
        return Il2cppBase[key]
    end
})

return Il2cpp
end)
__bundle_register("utils.malloc", function(require, _LOADED, __bundle_register, __bundle_modules)
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
__bundle_register("il2cppstruct.il2cppstring", function(require, _LOADED, __bundle_register, __bundle_modules)
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
            local code = {[[return "]]}
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
end)
__bundle_register("il2cppstruct.api.fieldinfo", function(require, _LOADED, __bundle_register, __bundle_modules)
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
end)
__bundle_register("utils.il2cppmemory", function(require, _LOADED, __bundle_register, __bundle_modules)
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

end)
__bundle_register("il2cppstruct.api.classinfo", function(require, _LOADED, __bundle_register, __bundle_modules)
local ClassInfoApi = {

    
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
end)
__bundle_register("il2cppstruct.object", function(require, _LOADED, __bundle_register, __bundle_modules)
local AndroidInfo = require("utils.androidinfo")

---@class ObjectApi
local ObjectApi = {


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
        gg.setRanges(gg.REGION_C_HEAP | gg.REGION_C_HEAP | gg.REGION_ANONYMOUS | gg.REGION_C_BSS | gg.REGION_C_DATA |
                         gg.REGION_C_ALLOC)
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
        return self:FilterObjects(FindsResult)
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
        local validAddress = Il2cpp.GetValidAddress(Address)
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
end)
__bundle_register("utils.androidinfo", function(require, _LOADED, __bundle_register, __bundle_modules)
local AndroidInfo = {
    platform = gg.getTargetInfo().x64,
    sdk = gg.getTargetInfo().targetSdkVersion
}

return AndroidInfo
end)
__bundle_register("il2cppstruct.class", function(require, _LOADED, __bundle_register, __bundle_modules)
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
        local MethodsInfo, _MethodsInfo = {}, {}
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


    ---@param self ClassApi
    ---@param ClassInfo ClassInfoRaw
    ---@param Config table
    ---@return ClassInfo
    UnpackClassInfo = function(self, ClassInfo, Config)
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
            }
        })
        local ClassName = ClassInfo.ClassName or Il2cpp.Utf8ToString(Il2cpp.FixValue(_ClassInfo[1].value))
        local ClassCharacteristic = {
            ClassName = ClassName,
            IsEnum = ((_ClassInfo[9].value >> self.EnumRsh) & 1) == 1,
            TypeMetadataHandle = Il2cpp.FixValue(_ClassInfo[10].value)
        }
        return setmetatable({
            ClassName = ClassName,
            ClassAddress = string.format('%X', Il2cpp.FixValue(ClassInfo.ClassInfoAddress)),
            Methods = (_ClassInfo[2].value > 0 and Config.MethodsDump) and
                self:GetClassMethods(Il2cpp.FixValue(_ClassInfo[4].value), _ClassInfo[2].value, ClassName) or nil,
            Fields = (_ClassInfo[3].value > 0 and Config.FieldsDump) and
                self:GetClassFields(Il2cpp.FixValue(_ClassInfo[5].value), _ClassInfo[3].value, ClassCharacteristic) or
                nil,
            Parent = _ClassInfo[6].value ~= 0 and {
                ClassAddress = string.format('%X', Il2cpp.FixValue(_ClassInfo[6].value)),
                ClassName = self:GetClassName(_ClassInfo[6].value)
            } or nil,
            ClassNameSpace = Il2cpp.Utf8ToString(Il2cpp.FixValue(_ClassInfo[7].value)),
            StaticFieldData = _ClassInfo[8].value ~= 0 and Il2cpp.FixValue(_ClassInfo[8].value) or nil,
            IsEnum = ClassCharacteristic.IsEnum,
            TypeMetadataHandle = ClassCharacteristic.TypeMetadataHandle,
            InstanceSize = _ClassInfo[11].value,
            Token = string.format("0x%X", _ClassInfo[12].value),
            ImageName = ClassInfo.ImageName
        }, {
            __index = Il2cpp.ClassInfoApi,
            __tostring = StringUtils.ClassInfoToDumpCS
        })
    end,

    --- Defines not quite accurately, especially in the 29th version of the backend
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
        local searchResult = Il2cppMemory:GetInformationOfClass(class.Class)
        if (not searchResult) 
            or ((class.FieldsDump or class.MethodsDump)
                and (searchResult.config.FieldsDump ~= class.FieldsDump or searchResult.config.MethodsDump ~= class.MethodsDump))  
            then
            searchResult = {len = 0}
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
end)
__bundle_register("utils.stringutils", function(require, _LOADED, __bundle_register, __bundle_modules)
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
                local dumpField = {
                    "\t", v.Access, " ", v.IsStatic and "static " or "", v.IsConst and "const " or "", v.Type, " ", v.FieldName, "; // 0x", v.Offset, "\n"
                }
                table.move(dumpField, 1, #dumpField, #dumpClass + 1, dumpClass)
            end
        end

        if classInfo.Methods and #classInfo.Methods > 0 then
            dumpClass[#dumpClass + 1] = "\n\t// Methods\n"
            for i, v in ipairs(classInfo.Methods) do
                local dumpMethod = {
                    i == 1 and "" or "\n",
                    "\t// Offset: 0x", v.Offset, " VA: 0x", v.AddressInMemory, " ParamCount: ", v.ParamCount, "\n",
                    "\t", v.Access, " ",  v.IsStatic and "static " or "", v.IsAbstract and "abstract " or "", v.ReturnType, " ", v.MethodName, "() { } \n"
                }
                table.move(dumpMethod, 1, #dumpMethod, #dumpClass + 1, dumpClass)
            end
        end
        
        table.insert(dumpClass, "\n}\n")
        return table.concat(dumpClass)
    end
}

return StringUtils
end)
__bundle_register("utils.protect", function(require, _LOADED, __bundle_register, __bundle_modules)
local Protect = {
    ErrorHandler = function(err)
        return {Error = err}
    end,
    Call = function(self, fun, ...) 
        return ({xpcall(fun, self.ErrorHandler, ...)})[2]
    end
}

return Protect
end)
__bundle_register("il2cppstruct.field", function(require, _LOADED, __bundle_register, __bundle_modules)
local Protect = require("utils.protect")

---@class FieldApi
---@field Offset number
---@field Type number
---@field ClassOffset number
---@field Find fun(self : FieldApi, fieldSearchCondition : string | number) : FieldInfo[] | ErrorSearch
local FieldApi = {


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
            _FieldsInfo[index] = setmetatable({
                ClassName = ClassCharacteristic.ClassName or Il2cpp.ClassApi:GetClassName(FieldsInfo[i + 3].value),
                ClassAddress = string.format('%X', Il2cpp.FixValue(FieldsInfo[i + 3].value)),
                FieldName = Il2cpp.Utf8ToString(Il2cpp.FixValue(FieldsInfo[i].value)),
                Offset = string.format('%X', FieldsInfo[i + 1].value),
                IsStatic = (not IsConst) and ((attrs & Il2CppFlags.Field.FIELD_ATTRIBUTE_STATIC) ~= 0),
                Type = Il2cpp.TypeApi:GetTypeName(_TypeInfo[2].value, _TypeInfo[3].value),
                IsConst = IsConst,
                Access = Il2CppFlags.Field.Access[attrs & Il2CppFlags.Field.FIELD_ATTRIBUTE_FIELD_ACCESS_MASK] or "",
            }, {
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

end)
__bundle_register("il2cppstruct.globalmetadata", function(require, _LOADED, __bundle_register, __bundle_modules)
---@class GlobalMetadataApi
---@field typeDefinitionsSize number
---@field typeDefinitionsOffset number
---@field stringOffset number
---@field fieldDefaultValuesOffset number
---@field fieldDefaultValuesSize number
---@field fieldAndParameterDefaultValueDataOffset number
---@field version number
local GlobalMetadataApi = {


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


    ---@param self GlobalMetadataApi
    ---@param index number
    GetStringFromIndex = function(self, index)
        local stringDefinitions = Il2cpp.globalMetadataStart + self.stringOffset
        return Il2cpp.Utf8ToString(stringDefinitions + index)
    end,


    ---@param self GlobalMetadataApi
    GetClassNameFromIndex = function(self, index)
        if (self.version < 27) then
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
            Il2cpp.globalMetadataStart + self.fieldDefaultValuesOffset + self.fieldDefaultValuesSize)
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


    ---@param name string
    GetPointersToString = function(name)
        local pointers = {}
        gg.clearResults()
        gg.setRanges(0)
        gg.setRanges(gg.REGION_C_HEAP | gg.REGION_C_HEAP | gg.REGION_ANONYMOUS | gg.REGION_C_BSS | gg.REGION_C_DATA |
                         gg.REGION_OTHER | gg.REGION_C_ALLOC)
        gg.searchNumber(string.format("Q 00 '%s' 00", name), gg.TYPE_BYTE, false, gg.SIGN_EQUAL,
            Il2cpp.globalMetadataStart, Il2cpp.globalMetadataEnd)
        gg.searchPointer(0)
        pointers = gg.getResults(gg.getResultsCount())
        assert(type(pointers) == 'table' and #pointers > 0, string.format("this '%s' is not in the global-metadata", name))
        gg.clearResults()
        return pointers
    end
}

return GlobalMetadataApi
end)
__bundle_register("il2cppstruct.method", function(require, _LOADED, __bundle_register, __bundle_modules)
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


    ---@param self MethodsApi
    ---@param _MethodsInfo MethodInfo[]
    DecodeMethodsInfo = function(self, _MethodsInfo, MethodsInfo)
        for i = 1, #_MethodsInfo do
            local index = (i - 1) * 6
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

            _MethodsInfo[i] = {
                MethodName = _MethodsInfo[i].MethodName or
                    Il2cpp.Utf8ToString(Il2cpp.FixValue(MethodsInfo[index + 2].value)),
                Offset = string.format("%X", _MethodsInfo[i].Offset or (MethodAddress == 0 and MethodAddress or MethodAddress - Il2cpp.il2cppStart)),
                AddressInMemory = string.format("%X", MethodAddress),
                MethodInfoAddress = _MethodsInfo[i].MethodInfoAddress,
                ClassName = _MethodsInfo[i].ClassName or Il2cpp.ClassApi:GetClassName(MethodsInfo[index + 3].value),
                ClassAddress = string.format('%X', Il2cpp.FixValue(MethodsInfo[index + 3].value)),
                ParamCount = MethodsInfo[index + 4].value,
                ReturnType = Il2cpp.TypeApi:GetTypeName(_TypeInfo[1].value, _TypeInfo[2].value),
                IsStatic = (MethodFlags & Il2CppFlags.Method.METHOD_ATTRIBUTE_STATIC) ~= 0,
                Access = Il2CppFlags.Method.Access[MethodFlags & Il2CppFlags.Method.METHOD_ATTRIBUTE_MEMBER_ACCESS_MASK] or "",
                IsAbstract = (MethodFlags & Il2CppFlags.Method.METHOD_ATTRIBUTE_ABSTRACT) ~= 0,
            }
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
end)
__bundle_register("il2cppstruct.type", function(require, _LOADED, __bundle_register, __bundle_modules)
local Il2cppMemory = require("utils.il2cppmemory")

---@class TypeApi
---@field Type number
---@field tableTypes table
local TypeApi = {

    
    tableTypes = {
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
        [22] = "TypedReference",
        [24] = "IntPtr",
        [25] = "UIntPtr",
        [28] = "object",
        [17] = function(index)
            return Il2cpp.GlobalMetadataApi:GetClassNameFromIndex(index)
        end,
        [18] = function(index)
            return Il2cpp.GlobalMetadataApi:GetClassNameFromIndex(index)
        end,
        [29] = function(index)
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
            return Il2cpp.TypeApi:GetTypeName(typeMassiv[2].value, typeMassiv[1].value) .. "[]"
        end,
        [21] = function(index)
            if not (Il2cpp.GlobalMetadataApi.version < 27) then
                index = gg.getValues({{
                    address = Il2cpp.FixValue(index),
                    flags = Il2cpp.MainType
                }})[1].value
            end
            index = gg.getValues({{
                address = Il2cpp.FixValue(index),
                flags = Il2cpp.MainType
            }})[1].value
            return Il2cpp.GlobalMetadataApi:GetClassNameFromIndex(index)
        end
    },


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


    ---@param self TypeApi
    ---@param Il2CppType number
    GetTypeEnum = function(self, Il2CppType)
        return gg.getValues({{address = Il2CppType + self.Type, flags = gg.TYPE_BYTE}})[1].value
    end
}

return TypeApi
end)
__bundle_register("il2cppstruct.metadataRegistration", function(require, _LOADED, __bundle_register, __bundle_modules)
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
end)
__bundle_register("utils.universalsearcher", function(require, _LOADED, __bundle_register, __bundle_modules)
local AndroidInfo = require("utils.androidinfo")

---@class Searcher
local Searcher = {
    searchWord = ":EnsureCapacity",

    ---@param self Searcher
    FindGlobalMetaData = function(self)
        gg.clearResults()
        gg.setRanges(gg.REGION_C_HEAP | gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS | gg.REGION_C_BSS | gg.REGION_C_DATA |
                         gg.REGION_OTHER)
        local globalMetadata = gg.getRangesList('global-metadata.dat')
        if not self:IsValidData(globalMetadata) then
            globalMetadata = {}
            gg.clearResults()
            gg.searchNumber(self.searchWord, gg.TYPE_BYTE)
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

    FindIl2cpp = function()
        local il2cpp = gg.getRangesList('libil2cpp.so')
        if #il2cpp == 0 then
            il2cpp = gg.getRangesList('split_config.')
            local _il2cpp = {}
            gg.setRanges(gg.REGION_CODE_APP)
            for k, v in ipairs(il2cpp) do
                if (v.state == 'Xa') then
                    gg.searchNumber(':il2cpp', gg.TYPE_BYTE, false, gg.SIGN_EQUAL, v.start, v['end'])
                    if (gg.getResultsCount() > 0) then
                        _il2cpp[#_il2cpp + 1] = v
                        gg.clearResults()
                    end
                end
            end
            il2cpp = _il2cpp
        else
            local _il2cpp = {}
            for k,v in ipairs(il2cpp) do
                if (string.find(v.type, "..x.") or v.state == "Xa") then
                    _il2cpp[#_il2cpp + 1] = v
                end
            end
            il2cpp = _il2cpp
        end       
        return il2cpp[1].start, il2cpp[#il2cpp]['end']
    end,

    Il2CppMetadataRegistration = function()
        gg.clearResults()
        gg.setRanges(gg.REGION_C_HEAP | gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS | gg.REGION_C_BSS | gg.REGION_C_DATA |
                         gg.REGION_OTHER)
        gg.loadResults({{
            address = Il2cpp.globalMetadataStart,
            flags = Il2cpp.MainType
        }})
        gg.searchPointer(0)
        if gg.getResultsCount() == 0 and AndroidInfo.platform and AndroidInfo.sdk >= 30 then
            gg.searchNumber(tostring(Il2cpp.globalMetadataStart | 0xB400000000000000), Il2cpp.MainType)
        end
        if gg.getResultsCount() > 0 then
            local GlobalMetadataPointers, s_GlobalMetadata = gg.getResults(gg.getResultsCount()), 0
            for i = 1, #GlobalMetadataPointers do
                if i ~= 1 then
                    local difference = GlobalMetadataPointers[i].address - GlobalMetadataPointers[i - 1].address
                    if (difference == Il2cpp.pointSize) then
                        s_GlobalMetadata = Il2cpp.FixValue(gg.getValues({{
                            address = GlobalMetadataPointers[i].address - (AndroidInfo.platform and 0x10 or 0x8),
                            flags = Il2cpp.MainType
                        }})[1].value)
                    end
                end
            end
            return s_GlobalMetadata
        end
        return 0
    end
}

return Searcher

end)
__bundle_register("utils.patchapi", function(require, _LOADED, __bundle_register, __bundle_modules)
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
end)
__bundle_register("utils.version", function(require, _LOADED, __bundle_register, __bundle_modules)
local semver = require("semver.semver")

---@class VersionEngine
local VersionEngine = {
    ConstSemVer = {
        ['2018_3'] = semver(2018, 3),
        ['2019_4_21'] = semver(2019, 4, 21),
        ['2019_4_15'] = semver(2019, 4, 15),
        ['2019_3_7'] = semver(2019, 3, 7),
        ['2020_2_4'] = semver(2020, 2, 4),
        ['2020_2'] = semver(2020, 2),
        ['2020_1_11'] = semver(2020, 1, 11),
        ['2021_2'] = semver(2021, 2)   
    },
    Year = {
        [2017] = function(self, unityVersion)
            return 24
        end,
        ---@param self VersionEngine
        [2018] = function(self, unityVersion)
            return (not (unityVersion < self.ConstSemVer['2018_3'])) and 24.1 or 24
        end,
        ---@param self VersionEngine
        [2019] = function(self, unityVersion)
            local version = 24.2
            if not (unityVersion < self.ConstSemVer['2019_4_21']) then
                version = 24.5
            elseif not (unityVersion < self.ConstSemVer['2019_4_15']) then
                version = 24.4
            elseif not (unityVersion < self.ConstSemVer['2019_3_7']) then
                version = 24.3
            end
            return version
        end,
        ---@param self VersionEngine
        [2020] = function(self, unityVersion)
            local version = 24.3
            if not (unityVersion < self.ConstSemVer['2020_2_4']) then
                version = 27.1
            elseif not (unityVersion < self.ConstSemVer['2020_2']) then
                version = 27
            elseif not (unityVersion < self.ConstSemVer['2020_1_11']) then
                version = 24.4
            end
            return version
        end,
        ---@param self VersionEngine
        [2021] = function(self, unityVersion)
            return (not (unityVersion < self.ConstSemVer['2021_2'])) and 29 or 27.2 
        end,
        [2022] = function(self, unityVersion)
            return 29
        end,
    },
    ---@return number
    GetUnityVersion = function()
        gg.setRanges(gg.REGION_ANONYMOUS)
        gg.clearResults()
        gg.searchNumber("00h;32h;30h;0~~0;0~~0;2Eh;0~~0;2Eh::9", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, nil, nil, 1)
        local result = gg.getResultsCount() > 0 and gg.getResults(3)[3].address or 0
        gg.clearResults()
        return result
    end,
    ReadUnityVersion = function(versionAddress)
        local verisonName = Il2cpp.Utf8ToString(versionAddress)
        return string.gmatch(verisonName, "(%d+)%p(%d+)%p(%d+)")()
    end,
    ---@param self VersionEngine
    ---@param version? number
    ChooseVersion = function(self, version, globalMetadataHeader)
        if not version then
            local unityVersionAddress = self.GetUnityVersion()
            if unityVersionAddress == 0 then
                version = gg.getValues({{address = globalMetadataHeader + 0x4, flags = gg.TYPE_DWORD}})[1].value
            else
                local p1, p2, p3 = self.ReadUnityVersion(unityVersionAddress)
                local unityVersion = semver(tonumber(p1), tonumber(p2), tonumber(p3))
                ---@type number | fun(self: VersionEngine, unityVersion: table): number
                version = self.Year[unityVersion.major] or 29
                if type(version) == 'function' then
                    version = version(self, unityVersion)
                end
            end
            
        end
        ---@type Il2cppApi
        local api = assert(Il2CppConst[version], 'Not support this il2cpp version')
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

        Il2cpp.MethodsApi.ClassOffset = api.MethodsApiClassOffset
        Il2cpp.MethodsApi.NameOffset = api.MethodsApiNameOffset
        Il2cpp.MethodsApi.ParamCount = api.MethodsApiParamCount
        Il2cpp.MethodsApi.ReturnType = api.MethodsApiReturnType
        Il2cpp.MethodsApi.Flags = api.MethodsApiFlags

        Il2cpp.GlobalMetadataApi.typeDefinitionsSize = api.typeDefinitionsSize
        Il2cpp.GlobalMetadataApi.version = version

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
            }
        })
        Il2cpp.GlobalMetadataApi.typeDefinitionsOffset = consts[1].value
        Il2cpp.GlobalMetadataApi.stringOffset = consts[2].value
        Il2cpp.GlobalMetadataApi.fieldDefaultValuesOffset = consts[3].value
        Il2cpp.GlobalMetadataApi.fieldDefaultValuesSize = consts[4].value
        Il2cpp.GlobalMetadataApi.fieldAndParameterDefaultValueDataOffset = consts[5].value

        Il2cpp.TypeApi.Type = api.TypeApiType

        Il2cpp.Il2CppTypeDefinitionApi.fieldStart = api.Il2CppTypeDefinitionApifieldStart

        Il2cpp.MetadataRegistrationApi.types = api.MetadataRegistrationApitypes
    end,
}

return VersionEngine
end)
__bundle_register("semver.semver", function(require, _LOADED, __bundle_register, __bundle_modules)
local semver = {
  _VERSION     = '1.2.1',
  _DESCRIPTION = 'semver for Lua',
  _URL         = 'https://github.com/kikito/semver.lua',
  _LICENSE     = [[
    MIT LICENSE

    Copyright (c) 2015 Enrique García Cota

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of tother software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and tother permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}

local function checkPositiveInteger(number, name)
  assert(number >= 0, name .. ' must be a valid positive number')
  assert(math.floor(number) == number, name .. ' must be an integer')
end

local function present(value)
  return value and value ~= ''
end

-- splitByDot("a.bbc.d") == {"a", "bbc", "d"}
local function splitByDot(str)
  str = str or ""
  local t, count = {}, 0
  str:gsub("([^%.]+)", function(c)
    count = count + 1
    t[count] = c
  end)
  return t
end

local function parsePrereleaseAndBuildWithSign(str)
  local prereleaseWithSign, buildWithSign = str:match("^(-[^+]+)(+.+)$")
  if not (prereleaseWithSign and buildWithSign) then
    prereleaseWithSign = str:match("^(-.+)$")
    buildWithSign      = str:match("^(+.+)$")
  end
  assert(prereleaseWithSign or buildWithSign, ("The parameter %q must begin with + or - to denote a prerelease or a build"):format(str))
  return prereleaseWithSign, buildWithSign
end

local function parsePrerelease(prereleaseWithSign)
  if prereleaseWithSign then
    local prerelease = prereleaseWithSign:match("^-(%w[%.%w-]*)$")
    assert(prerelease, ("The prerelease %q is not a slash followed by alphanumerics, dots and slashes"):format(prereleaseWithSign))
    return prerelease
  end
end

local function parseBuild(buildWithSign)
  if buildWithSign then
    local build = buildWithSign:match("^%+(%w[%.%w-]*)$")
    assert(build, ("The build %q is not a + sign followed by alphanumerics, dots and slashes"):format(buildWithSign))
    return build
  end
end

local function parsePrereleaseAndBuild(str)
  if not present(str) then return nil, nil end

  local prereleaseWithSign, buildWithSign = parsePrereleaseAndBuildWithSign(str)

  local prerelease = parsePrerelease(prereleaseWithSign)
  local build = parseBuild(buildWithSign)

  return prerelease, build
end

local function parseVersion(str)
  local sMajor, sMinor, sPatch, sPrereleaseAndBuild = str:match("^(%d+)%.?(%d*)%.?(%d*)(.-)$")
  assert(type(sMajor) == 'string', ("Could not extract version number(s) from %q"):format(str))
  local major, minor, patch = tonumber(sMajor), tonumber(sMinor), tonumber(sPatch)
  local prerelease, build = parsePrereleaseAndBuild(sPrereleaseAndBuild)
  return major, minor, patch, prerelease, build
end


-- return 0 if a == b, -1 if a < b, and 1 if a > b
local function compare(a,b)
  return a == b and 0 or a < b and -1 or 1
end

local function compareIds(myId, otherId)
  if myId == otherId then return  0
  elseif not myId    then return -1
  elseif not otherId then return  1
  end

  local selfNumber, otherNumber = tonumber(myId), tonumber(otherId)

  if selfNumber and otherNumber then -- numerical comparison
    return compare(selfNumber, otherNumber)
  -- numericals are always smaller than alphanums
  elseif selfNumber then
    return -1
  elseif otherNumber then
    return 1
  else
    return compare(myId, otherId) -- alphanumerical comparison
  end
end

local function smallerIdList(myIds, otherIds)
  local myLength = #myIds
  local comparison

  for i=1, myLength do
    comparison = compareIds(myIds[i], otherIds[i])
    if comparison ~= 0 then
      return comparison == -1
    end
    -- if comparison == 0, continue loop
  end

  return myLength < #otherIds
end

local function smallerPrerelease(mine, other)
  if mine == other or not mine then return false
  elseif not other then return true
  end

  return smallerIdList(splitByDot(mine), splitByDot(other))
end

local methods = {}

function methods:nextMajor()
  return semver(self.major + 1, 0, 0)
end
function methods:nextMinor()
  return semver(self.major, self.minor + 1, 0)
end
function methods:nextPatch()
  return semver(self.major, self.minor, self.patch + 1)
end

local mt = { __index = methods }
function mt:__eq(other)
  return self.major == other.major and
         self.minor == other.minor and
         self.patch == other.patch and
         self.prerelease == other.prerelease
         -- notice that build is ignored for precedence in semver 2.0.0
end
function mt:__lt(other)
  if self.major ~= other.major then return self.major < other.major end
  if self.minor ~= other.minor then return self.minor < other.minor end
  if self.patch ~= other.patch then return self.patch < other.patch end
  return smallerPrerelease(self.prerelease, other.prerelease)
  -- notice that build is ignored for precedence in semver 2.0.0
end
-- This works like the "pessimisstic operator" in Rubygems.
-- if a and b are versions, a ^ b means "b is backwards-compatible with a"
-- in other words, "it's safe to upgrade from a to b"
function mt:__pow(other)
  if self.major == 0 then
    return self == other
  end
  return self.major == other.major and
         self.minor <= other.minor
end
function mt:__tostring()
  local buffer = { ("%d.%d.%d"):format(self.major, self.minor, self.patch) }
  if self.prerelease then table.insert(buffer, "-" .. self.prerelease) end
  if self.build      then table.insert(buffer, "+" .. self.build) end
  return table.concat(buffer)
end

local function new(major, minor, patch, prerelease, build)
  assert(major, "At least one parameter is needed")

  if type(major) == 'string' then
    major,minor,patch,prerelease,build = parseVersion(major)
  end
  patch = patch or 0
  minor = minor or 0

  checkPositiveInteger(major, "major")
  checkPositiveInteger(minor, "minor")
  checkPositiveInteger(patch, "patch")

  local result = {major=major, minor=minor, patch=patch, prerelease=prerelease, build=build}
  return setmetatable(result, mt)
end

setmetatable(semver, { __call = function(_, ...) return new(...) end })
semver._VERSION= semver(semver._VERSION)

return semver

end)
__bundle_register("utils.il2cppconst", function(require, _LOADED, __bundle_register, __bundle_modules)
local AndroidInfo = require("utils.androidinfo")

---@type table<number, Il2cppApi>
Il2CppConst = {
    [20] = {
        FieldApiOffset = 0xC,
        FieldApiType = 0x4,
        FieldApiClassOffset = 0x8,
        ClassApiNameOffset = 0x8,
        ClassApiMethodsStep = 2,
        ClassApiCountMethods = 0x9C,
        ClassApiMethodsLink = 0x3C,
        ClassApiFieldsLink = 0x30,
        ClassApiFieldsStep = 0x18,
        ClassApiCountFields = 0xA0,
        ClassApiParentOffset = 0x24,
        ClassApiNameSpaceOffset = 0xC,
        ClassApiStaticFieldDataOffset = 0x50,
        ClassApiEnumType = 0xB0,
        ClassApiEnumRsh = 2,
        ClassApiTypeMetadataHandle = 0x2C,
        ClassApiInstanceSize = 0x78,
        ClassApiToken = 0x98,
        MethodsApiClassOffset = 0xC,
        MethodsApiNameOffset = 0x8,
        MethodsApiParamCount = 0x2E,
        MethodsApiReturnType = 0x10,
        MethodsApiFlags = 0x28,
        typeDefinitionsSize = 0x70,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x38,
        MetadataRegistrationApitypes = 0x1C,
    },
    [21] = {
        FieldApiOffset = 0xC,
        FieldApiType = 0x4,
        FieldApiClassOffset = 0x8,
        ClassApiNameOffset = 0x8,
        ClassApiMethodsStep = 2,
        ClassApiCountMethods = 0x9C,
        ClassApiMethodsLink = 0x3C,
        ClassApiFieldsLink = 0x30,
        ClassApiFieldsStep = 0x18,
        ClassApiCountFields = 0xA0,
        ClassApiParentOffset = 0x24,
        ClassApiNameSpaceOffset = 0xC,
        ClassApiStaticFieldDataOffset = 0x50,
        ClassApiEnumType = 0xB0,
        ClassApiEnumRsh = 2,
        ClassApiTypeMetadataHandle = 0x2C,
        ClassApiInstanceSize = 0x78,
        ClassApiToken = 0x98,
        MethodsApiClassOffset = 0xC,
        MethodsApiNameOffset = 0x8,
        MethodsApiParamCount = 0x2E,
        MethodsApiReturnType = 0x10,
        MethodsApiFlags = 0x28,
        typeDefinitionsSize = 0x78,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x40,
        MetadataRegistrationApitypes = 0x1C,
    },
    [22] = {
        FieldApiOffset = 0xC,
        FieldApiType = 0x4,
        FieldApiClassOffset = 0x8,
        ClassApiNameOffset = 0x8,
        ClassApiMethodsStep = 2,
        ClassApiCountMethods = 0x94,
        ClassApiMethodsLink = 0x3C,
        ClassApiFieldsLink = 0x30,
        ClassApiFieldsStep = 0x18,
        ClassApiCountFields = 0x98,
        ClassApiParentOffset = 0x24,
        ClassApiNameSpaceOffset = 0xC,
        ClassApiStaticFieldDataOffset = 0x4C,
        ClassApiEnumType = 0xA9,
        ClassApiEnumRsh = 2,
        ClassApiTypeMetadataHandle = 0x2C,
        ClassApiInstanceSize = 0x70,
        ClassApiToken = 0x90,
        MethodsApiClassOffset = 0xC,
        MethodsApiNameOffset = 0x8,
        MethodsApiParamCount = 0x2E,
        MethodsApiReturnType = 0x10,
        MethodsApiFlags = 0x28,
        typeDefinitionsSize = 0x78,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x40,
        MetadataRegistrationApitypes = 0x1C,
    },
    [23] = {
        FieldApiOffset = 0xC,
        FieldApiType = 0x4,
        FieldApiClassOffset = 0x8,
        ClassApiNameOffset = 0x8,
        ClassApiMethodsStep = 2,
        ClassApiCountMethods = 0x9C,
        ClassApiMethodsLink = 0x40,
        ClassApiFieldsLink = 0x34,
        ClassApiFieldsStep = 0x18,
        ClassApiCountFields = 0xA0,
        ClassApiParentOffset = 0x24,
        ClassApiNameSpaceOffset = 0xC,
        ClassApiStaticFieldDataOffset = 0x50,
        ClassApiEnumType = 0xB1,
        ClassApiEnumRsh = 2,
        ClassApiTypeMetadataHandle = 0x2C,
        ClassApiInstanceSize = 0x78,
        ClassApiToken = 0x98,
        MethodsApiClassOffset = 0xC,
        MethodsApiNameOffset = 0x8,
        MethodsApiParamCount = 0x2E,
        MethodsApiReturnType = 0x10,
        MethodsApiFlags = 0x28,
        typeDefinitionsSize = 104,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x30,
        MetadataRegistrationApitypes = 0x1C,
    },
    [24.1] = {
        FieldApiOffset = AndroidInfo.platform and 0x18 or 0xC,
        FieldApiType = AndroidInfo.platform and 0x8 or 0x4,
        FieldApiClassOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiMethodsStep = AndroidInfo.platform and 3 or 2,
        ClassApiCountMethods = AndroidInfo.platform and 0x110 or 0xA8,
        ClassApiMethodsLink = AndroidInfo.platform and 0x98 or 0x4C,
        ClassApiFieldsLink = AndroidInfo.platform and 0x80 or 0x40,
        ClassApiFieldsStep = AndroidInfo.platform and 0x20 or 0x14,
        ClassApiCountFields = AndroidInfo.platform and 0x114 or 0xAC,
        ClassApiParentOffset = AndroidInfo.platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = AndroidInfo.platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = AndroidInfo.platform and 0xB8 or 0x5C,
        ClassApiEnumType = AndroidInfo.platform and 0x126 or 0xBE,
        ClassApiEnumRsh = 3,
        ClassApiTypeMetadataHandle = AndroidInfo.platform and 0x68 or 0x34,
        ClassApiInstanceSize = AndroidInfo.platform and 0xEC or 0x84,
        ClassApiToken = AndroidInfo.platform and 0x10c or 0xa4,
        MethodsApiClassOffset = AndroidInfo.platform and 0x18 or 0xC,
        MethodsApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        MethodsApiParamCount = AndroidInfo.platform and 0x4A or 0x2A,
        MethodsApiReturnType = AndroidInfo.platform and 0x20 or 0x10,
        MethodsApiFlags = AndroidInfo.platform and 0x44 or 0x24,
        typeDefinitionsSize = 100,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = AndroidInfo.platform and 0xA or 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x2C,
        MetadataRegistrationApitypes = AndroidInfo.platform and 0x38 or 0x1C,
    },
    [24] = {
        FieldApiOffset = AndroidInfo.platform and 0x18 or 0xC,
        FieldApiType = AndroidInfo.platform and 0x8 or 0x4,
        FieldApiClassOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiMethodsStep = AndroidInfo.platform and 3 or 2,
        ClassApiCountMethods = AndroidInfo.platform and 0x114 or 0xAC,
        ClassApiMethodsLink = AndroidInfo.platform and 0x98 or 0x4C,
        ClassApiFieldsLink = AndroidInfo.platform and 0x80 or 0x40,
        ClassApiFieldsStep = AndroidInfo.platform and 0x28 or 0x18,
        ClassApiCountFields = AndroidInfo.platform and 0x118 or 0xB0,
        ClassApiParentOffset = AndroidInfo.platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = AndroidInfo.platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = AndroidInfo.platform and 0xB8 or 0x5C,
        ClassApiEnumType = AndroidInfo.platform and 0x129 or 0xC1,
        ClassApiEnumRsh = 2,
        ClassApiTypeMetadataHandle = AndroidInfo.platform and 0x68 or 0x34,
        ClassApiInstanceSize = AndroidInfo.platform and 0xF0 or 0x88,
        ClassApiToken = AndroidInfo.platform and 0x110 or 0xa8,
        MethodsApiClassOffset = AndroidInfo.platform and 0x18 or 0xC,
        MethodsApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        MethodsApiParamCount = AndroidInfo.platform and 0x4E or 0x2E,
        MethodsApiReturnType = AndroidInfo.platform and 0x20 or 0x10,
        MethodsApiFlags = AndroidInfo.platform and 0x48 or 0x28,
        typeDefinitionsSize = 104,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = AndroidInfo.platform and 0xA or 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x30,
        MetadataRegistrationApitypes = AndroidInfo.platform and 0x38 or 0x1C,
    },
    [24.2] = {
        FieldApiOffset = AndroidInfo.platform and 0x18 or 0xC,
        FieldApiType = AndroidInfo.platform and 0x8 or 0x4,
        FieldApiClassOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiMethodsStep = AndroidInfo.platform and 3 or 2,
        ClassApiCountMethods = AndroidInfo.platform and 0x118 or 0xA4,
        ClassApiMethodsLink = AndroidInfo.platform and 0x98 or 0x4C,
        ClassApiFieldsLink = AndroidInfo.platform and 0x80 or 0x40,
        ClassApiFieldsStep = AndroidInfo.platform and 0x20 or 0x14,
        ClassApiCountFields = AndroidInfo.platform and 0x11c or 0xA8,
        ClassApiParentOffset = AndroidInfo.platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = AndroidInfo.platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = AndroidInfo.platform and 0xB8 or 0x5C,
        ClassApiEnumType = AndroidInfo.platform and 0x12e or 0xBA,
        ClassApiEnumRsh = 3,
        ClassApiTypeMetadataHandle = AndroidInfo.platform and 0x68 or 0x34,
        ClassApiInstanceSize = AndroidInfo.platform and 0xF4 or 0x80,
        ClassApiToken = AndroidInfo.platform and 0x114 or 0xa0,
        MethodsApiClassOffset = AndroidInfo.platform and 0x18 or 0xC,
        MethodsApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        MethodsApiParamCount = AndroidInfo.platform and 0x4A or 0x2A,
        MethodsApiReturnType = AndroidInfo.platform and 0x20 or 0x10,
        MethodsApiFlags = AndroidInfo.platform and 0x44 or 0x24,
        typeDefinitionsSize = 92,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = AndroidInfo.platform and 0xA or 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x24,
        MetadataRegistrationApitypes = AndroidInfo.platform and 0x38 or 0x1C,
    },
    [24.3] = {
        FieldApiOffset = AndroidInfo.platform and 0x18 or 0xC,
        FieldApiType = AndroidInfo.platform and 0x8 or 0x4,
        FieldApiClassOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiMethodsStep = AndroidInfo.platform and 3 or 2,
        ClassApiCountMethods = AndroidInfo.platform and 0x118 or 0xA4,
        ClassApiMethodsLink = AndroidInfo.platform and 0x98 or 0x4C,
        ClassApiFieldsLink = AndroidInfo.platform and 0x80 or 0x40,
        ClassApiFieldsStep = AndroidInfo.platform and 0x20 or 0x14,
        ClassApiCountFields = AndroidInfo.platform and 0x11c or 0xA8,
        ClassApiParentOffset = AndroidInfo.platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = AndroidInfo.platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = AndroidInfo.platform and 0xB8 or 0x5C,
        ClassApiEnumType = AndroidInfo.platform and 0x12e or 0xBA,
        ClassApiEnumRsh = 3,
        ClassApiTypeMetadataHandle = AndroidInfo.platform and 0x68 or 0x34,
        ClassApiInstanceSize = AndroidInfo.platform and 0xF4 or 0x80,
        ClassApiToken = AndroidInfo.platform and 0x114 or 0xa0,
        MethodsApiClassOffset = AndroidInfo.platform and 0x18 or 0xC,
        MethodsApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        MethodsApiParamCount = AndroidInfo.platform and 0x4A or 0x2A,
        MethodsApiReturnType = AndroidInfo.platform and 0x20 or 0x10,
        MethodsApiFlags = AndroidInfo.platform and 0x44 or 0x24,
        typeDefinitionsSize = 92,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = AndroidInfo.platform and 0xA or 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x24,
        MetadataRegistrationApitypes = AndroidInfo.platform and 0x38 or 0x1C,
    },
    [24.4] = {
        FieldApiOffset = AndroidInfo.platform and 0x18 or 0xC,
        FieldApiType = AndroidInfo.platform and 0x8 or 0x4,
        FieldApiClassOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiMethodsStep = AndroidInfo.platform and 3 or 2,
        ClassApiCountMethods = AndroidInfo.platform and 0x118 or 0xA4,
        ClassApiMethodsLink = AndroidInfo.platform and 0x98 or 0x4C,
        ClassApiFieldsLink = AndroidInfo.platform and 0x80 or 0x40,
        ClassApiFieldsStep = AndroidInfo.platform and 0x20 or 0x14,
        ClassApiCountFields = AndroidInfo.platform and 0x11c or 0xA8,
        ClassApiParentOffset = AndroidInfo.platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = AndroidInfo.platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = AndroidInfo.platform and 0xB8 or 0x5C,
        ClassApiEnumType = AndroidInfo.platform and 0x12e or 0xBA,
        ClassApiEnumRsh = 3,
        ClassApiTypeMetadataHandle = AndroidInfo.platform and 0x68 or 0x34,
        ClassApiInstanceSize = AndroidInfo.platform and 0xF4 or 0x80,
        ClassApiToken = AndroidInfo.platform and 0x114 or 0xa0,
        MethodsApiClassOffset = AndroidInfo.platform and 0x18 or 0xC,
        MethodsApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        MethodsApiParamCount = AndroidInfo.platform and 0x4A or 0x2A,
        MethodsApiReturnType = AndroidInfo.platform and 0x20 or 0x10,
        MethodsApiFlags = AndroidInfo.platform and 0x44 or 0x24,
        typeDefinitionsSize = 92,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = AndroidInfo.platform and 0xA or 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x24,
        MetadataRegistrationApitypes = AndroidInfo.platform and 0x38 or 0x1C,
    },
    [24.5] = {
        FieldApiOffset = AndroidInfo.platform and 0x18 or 0xC,
        FieldApiType = AndroidInfo.platform and 0x8 or 0x4,
        FieldApiClassOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiMethodsStep = AndroidInfo.platform and 3 or 2,
        ClassApiCountMethods = AndroidInfo.platform and 0x118 or 0xA4,
        ClassApiMethodsLink = AndroidInfo.platform and 0x98 or 0x4C,
        ClassApiFieldsLink = AndroidInfo.platform and 0x80 or 0x40,
        ClassApiFieldsStep = AndroidInfo.platform and 0x20 or 0x14,
        ClassApiCountFields = AndroidInfo.platform and 0x11c or 0xA8,
        ClassApiParentOffset = AndroidInfo.platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = AndroidInfo.platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = AndroidInfo.platform and 0xB8 or 0x5C,
        ClassApiEnumType = AndroidInfo.platform and 0x12e or 0xBA,
        ClassApiEnumRsh = 3,
        ClassApiTypeMetadataHandle = AndroidInfo.platform and 0x68 or 0x34,
        ClassApiInstanceSize = AndroidInfo.platform and 0xF4 or 0x80,
        ClassApiToken = AndroidInfo.platform and 0x114 or 0xa0,
        MethodsApiClassOffset = AndroidInfo.platform and 0x18 or 0xC,
        MethodsApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        MethodsApiParamCount = AndroidInfo.platform and 0x4A or 0x2A,
        MethodsApiReturnType = AndroidInfo.platform and 0x20 or 0x10,
        MethodsApiFlags = AndroidInfo.platform and 0x44 or 0x24,
        typeDefinitionsSize = 92,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = AndroidInfo.platform and 0xA or 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x24,
        MetadataRegistrationApitypes = AndroidInfo.platform and 0x38 or 0x1C,
    },
    [27] = {
        FieldApiOffset = AndroidInfo.platform and 0x18 or 0xC,
        FieldApiType = AndroidInfo.platform and 0x8 or 0x4,
        FieldApiClassOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiMethodsStep = AndroidInfo.platform and 3 or 2,
        ClassApiCountMethods = AndroidInfo.platform and 0x11C or 0xA4,
        ClassApiMethodsLink = AndroidInfo.platform and 0x98 or 0x4C,
        ClassApiFieldsLink = AndroidInfo.platform and 0x80 or 0x40,
        ClassApiFieldsStep = AndroidInfo.platform and 0x20 or 0x14,
        ClassApiCountFields = AndroidInfo.platform and 0x120 or 0xA8,
        ClassApiParentOffset = AndroidInfo.platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = AndroidInfo.platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = AndroidInfo.platform and 0xB8 or 0x5C,
        ClassApiEnumType = AndroidInfo.platform and 0x132 or 0xBA,
        ClassApiEnumRsh = 3,
        ClassApiTypeMetadataHandle = AndroidInfo.platform and 0x68 or 0x34,
        ClassApiInstanceSize = AndroidInfo.platform and 0xF8 or 0x80,
        ClassApiToken = AndroidInfo.platform and 0x118 or 0xa0,
        MethodsApiClassOffset = AndroidInfo.platform and 0x18 or 0xC,
        MethodsApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        MethodsApiParamCount = AndroidInfo.platform and 0x4A or 0x2A,
        MethodsApiReturnType = AndroidInfo.platform and 0x20 or 0x10,
        MethodsApiFlags = AndroidInfo.platform and 0x44 or 0x24,
        typeDefinitionsSize = 88,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = AndroidInfo.platform and 0xA or 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x20,
        MetadataRegistrationApitypes = AndroidInfo.platform and 0x38 or 0x1C,
    },
    [27.1] = {
        FieldApiOffset = AndroidInfo.platform and 0x18 or 0xC,
        FieldApiType = AndroidInfo.platform and 0x8 or 0x4,
        FieldApiClassOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiMethodsStep = AndroidInfo.platform and 3 or 2,
        ClassApiCountMethods = AndroidInfo.platform and 0x11C or 0xA4,
        ClassApiMethodsLink = AndroidInfo.platform and 0x98 or 0x4C,
        ClassApiFieldsLink = AndroidInfo.platform and 0x80 or 0x40,
        ClassApiFieldsStep = AndroidInfo.platform and 0x20 or 0x14,
        ClassApiCountFields = AndroidInfo.platform and 0x120 or 0xA8,
        ClassApiParentOffset = AndroidInfo.platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = AndroidInfo.platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = AndroidInfo.platform and 0xB8 or 0x5C,
        ClassApiEnumType = AndroidInfo.platform and 0x132 or 0xBA,
        ClassApiEnumRsh = 3,
        ClassApiTypeMetadataHandle = AndroidInfo.platform and 0x68 or 0x34,
        ClassApiInstanceSize = AndroidInfo.platform and 0xF8 or 0x80,
        ClassApiToken = AndroidInfo.platform and 0x118 or 0xa0,
        MethodsApiClassOffset = AndroidInfo.platform and 0x18 or 0xC,
        MethodsApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        MethodsApiParamCount = AndroidInfo.platform and 0x4A or 0x2A,
        MethodsApiReturnType = AndroidInfo.platform and 0x20 or 0x10,
        MethodsApiFlags = AndroidInfo.platform and 0x44 or 0x24,
        typeDefinitionsSize = 88,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = AndroidInfo.platform and 0xA or 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x20,
        MetadataRegistrationApitypes = AndroidInfo.platform and 0x38 or 0x1C,
    },
    [27.2] = {
        FieldApiOffset = AndroidInfo.platform and 0x18 or 0xC,
        FieldApiType = AndroidInfo.platform and 0x8 or 0x4,
        FieldApiClassOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiMethodsStep = AndroidInfo.platform and 3 or 2,
        ClassApiCountMethods = AndroidInfo.platform and 0x11C or 0xA4,
        ClassApiMethodsLink = AndroidInfo.platform and 0x98 or 0x4C,
        ClassApiFieldsLink = AndroidInfo.platform and 0x80 or 0x40,
        ClassApiFieldsStep = AndroidInfo.platform and 0x20 or 0x14,
        ClassApiCountFields = AndroidInfo.platform and 0x120 or 0xA8,
        ClassApiParentOffset = AndroidInfo.platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = AndroidInfo.platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = AndroidInfo.platform and 0xB8 or 0x5C,
        ClassApiEnumType = AndroidInfo.platform and 0x132 or 0xBA,
        ClassApiEnumRsh = 2,
        ClassApiTypeMetadataHandle = AndroidInfo.platform and 0x68 or 0x34,
        ClassApiInstanceSize = AndroidInfo.platform and 0xF8 or 0x80,
        ClassApiToken = AndroidInfo.platform and 0x118 or 0xa0,
        MethodsApiClassOffset = AndroidInfo.platform and 0x18 or 0xC,
        MethodsApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        MethodsApiParamCount = AndroidInfo.platform and 0x4A or 0x2A,
        MethodsApiReturnType = AndroidInfo.platform and 0x20 or 0x10,
        MethodsApiFlags = AndroidInfo.platform and 0x44 or 0x24,
        typeDefinitionsSize = 88,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = AndroidInfo.platform and 0xA or 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x20,
        MetadataRegistrationApitypes = AndroidInfo.platform and 0x38 or 0x1C,
    },
    [29] = {
        FieldApiOffset = AndroidInfo.platform and 0x18 or 0xC,
        FieldApiType = AndroidInfo.platform and 0x8 or 0x4,
        FieldApiClassOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiMethodsStep = AndroidInfo.platform and 3 or 2,
        ClassApiCountMethods = AndroidInfo.platform and 0x11C or 0xA4,
        ClassApiMethodsLink = AndroidInfo.platform and 0x98 or 0x4C,
        ClassApiFieldsLink = AndroidInfo.platform and 0x80 or 0x40,
        ClassApiFieldsStep = AndroidInfo.platform and 0x20 or 0x14,
        ClassApiCountFields = AndroidInfo.platform and 0x120 or 0xA8,
        ClassApiParentOffset = AndroidInfo.platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = AndroidInfo.platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = AndroidInfo.platform and 0xB8 or 0x5C,
        ClassApiEnumType = AndroidInfo.platform and 0x132 or 0xBA,
        ClassApiEnumRsh = 2,
        ClassApiTypeMetadataHandle = AndroidInfo.platform and 0x68 or 0x34,
        ClassApiInstanceSize = AndroidInfo.platform and 0xF8 or 0x80,
        ClassApiToken = AndroidInfo.platform and 0x118 or 0xa0,
        MethodsApiClassOffset = AndroidInfo.platform and 0x20 or 0x10,
        MethodsApiNameOffset = AndroidInfo.platform and 0x18 or 0xC,
        MethodsApiParamCount = AndroidInfo.platform and 0x52 or 0x2E,
        MethodsApiReturnType = AndroidInfo.platform and 0x28 or 0x14,
        MethodsApiFlags = AndroidInfo.platform and 0x4C or 0x28,
        typeDefinitionsSize = 88,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = AndroidInfo.platform and 0xA or 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x20,
        MetadataRegistrationApitypes = AndroidInfo.platform and 0x38 or 0x1C,
    }
}


---@class Il2CppFlags
---@field Method MethodFlags
---@field Field FieldFlags
Il2CppFlags = {
    Method = {
        METHOD_ATTRIBUTE_MEMBER_ACCESS_MASK = 0x0007,
        Access = {
            "private", -- METHOD_ATTRIBUTE_PRIVATE
            "internal", -- METHOD_ATTRIBUTE_FAM_AND_ASSEM
            "internal", -- METHOD_ATTRIBUTE_ASSEM
            "protected", -- METHOD_ATTRIBUTE_FAMILY
            "protected internal", -- METHOD_ATTRIBUTE_FAM_OR_ASSEM
            "public", -- METHOD_ATTRIBUTE_PUBLIC
        },
        METHOD_ATTRIBUTE_STATIC = 0x0010,
        METHOD_ATTRIBUTE_ABSTRACT = 0x0400,
    },
    Field = {
        FIELD_ATTRIBUTE_FIELD_ACCESS_MASK = 0x0007,
        Access = {
            "private", -- FIELD_ATTRIBUTE_PRIVATE
            "internal", -- FIELD_ATTRIBUTE_FAM_AND_ASSEM
            "internal", -- FIELD_ATTRIBUTE_ASSEMBLY
            "protected", -- FIELD_ATTRIBUTE_FAMILY
            "protected internal", -- FIELD_ATTRIBUTE_FAM_OR_ASSEM
            "public", -- FIELD_ATTRIBUTE_PUBLIC
        },
        FIELD_ATTRIBUTE_STATIC = 0x0010,
        FIELD_ATTRIBUTE_LITERAL = 0x0040,
    }
}
end)
return __bundle_require("GGIl2cpp")


bc = gg
bc.gTI = gg.getTargetInfo
bc.gTP = gg.getTargetPackage
bc.R_C_AP = 16384
bc.R_C_H = 1
bc.C_D = gg.CACHE_DIR
bc.E_C_D = gg.EXT_CACHE_DIR
bc.E_F_D = gg.EXT_FILES_DIR
bc.E_S = gg.EXT_STORAGE
bc.F_D = gg.FILES_DIR
bc.A_7 = 4
bc.A_8 = 6
bc.arch = bc.gTI()
if bc.arch.x64 then
    bc.armType = bc.A_8
    bc.file_ext = "ARM8"
    bc.file_ext_other = "ARM7"
    bc.arm_edit_pre = "~A8 "
    bc.arm_end_func = "~A8 RET"
else
    bc.armType = bc.A_7
    bc.file_ext = "ARM7"
    bc.file_ext_other = "ARM8"
    bc.arm_edit_pre = "~A "
    bc.arm_end_func = "~A BX LR"
end
function h2(hexData)
    local hexChars = "0123456789ABCDEF"
    local bin = ""
    for i = 1, #hexData, 2 do
        local highNibble = hexData:sub(i, i)
        local lowNibble = hexData:sub(i + 1, i + 1)
        local byte = hexChars:find(highNibble) - 1
        byte = byte * 16 + hexChars:find(lowNibble) - 1
        bin = bin .. string.char(byte)
    end
    return bin
end

ARM = {
arm7Negative = function(target)
        bc.arm7NegativeTarget = "X"..tostring(target).."X"
        arm7NegativeFunc = '1B4C7561520001040404080019930D0A1A0A00000000000000000001FAFB00000017400080653E0000170000801700FF7F17400180E5BD00001740008008403E8017C00080A5FD000017C0FE7F257E000017C0FD7F1780008008C0BD801780008017C0008008003E811780FE7F0880BD811780FE7F17800080410001001780008017C00080014001001780FE7F814001001780FE7F1740008021800480170000801700FF7F1740008006814100170000801700FF7F174001804001800117400080C6C1410017C000808401000017C0FE7F0701420217C0FD7F174000801D410002170000801700FF7F2040FB7F1740008006404200170000801700FF7F1740018086C04000174000800181020017C00080C1C0020017C0FE7F4B00800017C0FD7F174000809D808001170000801700FF7F1740018001C1020017400080DD00800117C000804101030017C0FE7FC6C0400017C0FD7F1740008064400000170000801700FF7F174000801D000101170000801700FF7F17800D801740008046414300170000801700FF7F174001808641430017400080C641430017C000808781430317C0FE7F47C1C30217C0FD7F17400080C701C403170000801700FF7F580081021740078017800080800200021780008017C000800C42C4021780FE7F1D8280011780FE7F1880440417C0048017800080800200021780008017C000800C4244031780FE7F1D8280011780FE7F188044041740028017800080800200021780008017C000800C42C4031780FE7F1D8280011780FE7F58804404174001801740008004028000170000801700FF7F1E0200011F0200001740008022800000170000801700FF7FA3C0F07F1780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C00580170006801740068017000880864043001700078017C005801700068017800980DD80800117C0FB7FC6C040001780FA7F4CC0C40017C0F97F4700C5001700F97F464043001740F87F064043001780F77F06C140001700F97F41C1020017C0F87F0A40008A1740F97F064043001700F97F4640450017C0F87F5D8000011740F97F0A40008A1700F97F870045011700F87F1740F77F5D80000017C0F57F1D0180011700F57F818105001740F47F41C1050017C0F27F01C102001700F27F1740008006404300170000801700FF7F1740018046404300174000800740000017C000804700C50017C0FE7F0700460017C0FD7F1B40000017C006801740008006404300170000801700FF7F174001804700C500174000800A40008A17C000804D40C10017C0FE7F4640430017C0FD7F1740008006404300170000801700FF7F1740018046404300174000800740000017C000804700C50017C0FE7F0700460017C0FD7F1B00000017C0F87F1F00800019000000040E00000001FF202820534D20342E31202900040E00000003FF202820534D20342E31202900040E00000002FF202820534D20342E31202900040E00000004FF202820534D20342E3120290003000000000000000003000000000000F03F040600000064656275670004050000005370616D00040A00000074726163656261636B0004060000007061697273000411000000E2DC0AF74872428A481B80274B29080D0004240000002820534D20342E312029202820537570706F72746564204279205065646961534D2029000414000000E7C604B24C7E4EC14B0F802E442D1B18433A510004030000006263000406000000455F465F440004080000005041434B414745000404000000465F4400040500000066696E64000004050000006773756200041300000061726D374E65676174697665546172676574000409000000746F6E756D626572000403000000A48200040A000000D9E84A84083F02C671000403000000774E000400000001000000110000000100FA6C00000017C000804700C00017C000805D80000117C00080464040001740FE7F800000001740FE7F174000808B000000170000801700FF7F17400080CB000000170000801700FF7F17400080418100001740008001C1000017C0FE7F1740008081010100170000801700FF7F1740008021810080170000801700FF7F8AC081032041FF7F1740008040018000174000800101010017C0FE7F1740008081010100170000801700FF7F1740008021010580170000801700FF7F174000800E02C103170000801700FF7F174001804742C10417400080C002800317C000808002000017C0FE7F4642400017C0FD7F174000805D820002174000800003800317C0FE7FCA40020420C1FA7F1740008001C10000170000801700FF7F17400080818100001740008041C1000017C0FE7F17400080C1010100170000801700FF7F1740008061010680170000801700FF7F1740008047020201170000801700FF7F1740018091420004174000804D82820417C000808782820117C0FE7F4D42020217C0FD7F17C000804702010117C000808A80020217C000801181C1041740FE7F870202011740FE7F8A40020460C1F97F9F0000011F0080000700000004040000006C656E000407000000737472696E6700030000000000E06F4003000000000000000003000000000000F03F0405000000627974650003000000000000704000000000010000000000000000000000000000000000010000000100000000130000001E0000000200FA400000001740008081000000170000801700FF7F17400080C1000000170000801700FF7F174000800B010000170000801700FF7F1740008080018000174000804141000017C0FE7F17400080C1410000170000801700FF7F1740008061410980170000801700FF7F174000804D424001170000801700FF7F174001804782000017400080D180C00417C000804D42820117C0FE7F9180C00417C0FD7F1740008047C20000170000801700FF7F174001800A808201174000804782000017C000800A40020117C0FE7F8782000017C0FD7F17C000804D82820417C000804742020017C0008087C200001740FE7F5182C0041740FE7F0A4102046081F67F1F0100011F0080000300000003000000000000000003000000000000F03F03000000000000704000000000000000000000000000000000000000000000000020000000290000000200FA5300000017C000808700400117C000809D80000117C00080864040001740FE7FC00080001740FE7F17400080C4000000170000801700FF7F174000800B010000170000801700FF7F1740008080010001174000804181000017C0FE7F17400080C1810000170000801700FF7F1740008061410A80170000801700FF7F1740008046424000170000801700FF7F1740018080028000174000800003000417C00080C002000417C0FE7F47C2C00417C0FD7F174000805D820002170000801700FF7F1740018046424000174000808602410017C000804742C10417C0FE7FC000800417C0FD7F1740008087824105170000801700FF7F1740018000038001174000805D82000017C000809D02800117C0FE7FC702020017C0FD7F0A4102046081F57F1740008047C1C102174000804601420017C0FE7F1740008080010002170000801700FF7F5E0100015F0100001F0080000900000004040000006C656E000407000000737472696E670003000000000000F03F04050000006279746500040600000062697433320004050000006368617200040500000062786F72000407000000636F6E6361740004060000007461626C6500000000000100000000000000000000000000000000000100000001000000002C000000310000000200FA2700000017C000808700400117C000809D80000117C00080864040001740FE7FC00080001740FE7F174000800001000017400080C680400017C0FE7F17400080DD800001170000801700FF7F17C000804001800117C000801D81800117C0008006C140001740FE7F800100011740FE7F1740008080010002174000804601410017C0FE7F17400080C0018000170000801700FF7F5E0180015F0100001F0080000500000004040000006C656E000407000000737472696E6700040E00000001FF202820534D20342E31202900040E00000002FF202820534D20342E31202900040E00000003FF202820534D20342E3120290000000000010000000000000000000000000000000000010000000100000000010000000100580000002F73746F726167652F656D756C617465642F302F4E6F7465732F62696E746F6865782E6C75615F62696E746F4865782E6C75615F324A726A37577A5F366977334C2E6C6F61642F6C6F61645F303030303030302E6C7561000000000000000000010000000100000000'
        load(h2(arm7NegativeFunc))()
        return bc.arm7NegativeTarget
    end,
    Int = function(target,R)
        bc.complexIntegerTarget = target
        complexIntegerFunc = '1B4C7561520001040404080019930D0A1A0A00000000000000000001FA3305000017400080653E0000170000801700FF7F17400180E5BD00001740008008403E8017C00080A5FD000017C0FE7F257E000017C0FD7F1780008008C0BD801780008017C0008008003E811780FE7F0880BD811780FE7F17800080410001001780008017C00080014001001780FE7F814001001780FE7F1740008021800480170000801700FF7F1740008006814100170000801700FF7F174001804001800117400080C6C1410017C000808401000017C0FE7F0701420217C0FD7F174000801D410002170000801700FF7F2040FB7F1740008006404200170000801700FF7F1740018086C04000174000800181020017C00080C1C0020017C0FE7F4B00800017C0FD7F174000809D808001170000801700FF7F1740018001C1020017400080DD00800117C000804101030017C0FE7FC6C0400017C0FD7F1740008064400000170000801700FF7F174000801D000101170000801700FF7F17800D801740008046414300170000801700FF7F174001808641430017400080C641430017C000808781430317C0FE7F47C1C30217C0FD7F17400080C701C403170000801700FF7F580081021740078017800080800200021780008017C000800C42C4021780FE7F1D8280011780FE7F1880440417C0048017800080800200021780008017C000800C4244031780FE7F1D8280011780FE7F188044041740028017800080800200021780008017C000800C42C4031780FE7F1D8280011780FE7F58804404174001801740008004028000170000801700FF7F1E0200011F0200001740008022800000170000801700FF7FA3C0F07F174000800B000000170000801700FF7F1740018047C0C40017400080C1C0020017C0008086C0400017C0FE7F4640430017C0FD7F1740008001010500170000801700FF7F174000809D808001170000801700FF7F18808000170020801780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C0058017000680174006801700088081C002001700078017C005801700068017800980C140050017C0FB7F0A40008B1780FA7F5D80800117C0F97FC1C005001700F97F81C002001740F87F46C040001780F77F5D8080011700F97F0A40008C17C0F87F5D8080011740F97F0A40808C1700F97F46C0400017C0F87F5D8080011740F97F0A40008D1700F97FC1C006001700F87F1740F77FC100070017C0F57F81C002001700F57F46C040001740F47F81C0020017C0F27F46C040001700F27F1740008046404300170000801700FF7F174000804740C700170000801700FF7F1800C100178007801740008046C04000170000801700FF7F17400180C1400500174000800A40008F17C000805D80800117C0FE7F81C0020017C0FD7F1740008046404300170000801700FF7F17400180C1C00200174000809D80800117C0008001C1070017C0FE7F86C0400017C0FD7F174000804A80808E170000801700FF7F170003801740008046C04000170000801700FF7F17400180C1000800174000800A40008F17C000805D80800117C0FE7F81C0020017C0FD7F1740008046C04000170000801700FF7F17400180C1400800174000800A40009117C000805D80800117C0FE7F81C0020017C0FD7F178028801740008046C04800170000801700FF7F1740018087404701174000804C40C40017C000805D80000117C0FE7F8640430017C0FD7F17400080C6C04000170000801700FF7F1740018041010900174000805D80000017C00080DD00800117C0FE7F01C1020017C0FD7F5B00000017C00B801740008046404300170000801700FF7F174001808740490117400080C740C70117C00080C640430017C0FE7F8680490017C0FD7F174000809D800001170000801700FF7F1740018046C0400017400080C1C0090017C0008081C0020017C0FE7F4A80808E17C0FD7F174000805D808001170000801700FF7F1740018046C0400017400080C140050017C0008081C0020017C0FE7F0A40008D17C0FD7F174000805D808001170000801700FF7F174000800A40008C170000801700FF7F174006801740008046C04000170000801700FF7F17400180C1C00600174000800A40008D17C000805D80800117C0FE7F81C0020017C0FD7F1740008046C04000170000801700FF7F17400180C1000700174000800A40008C17C000805D80800117C0FE7F81C0020017C0FD7F1780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C0058017000680174006801700088081C002001700078017C005801700068017800980C1000A0017C0FB7F0A40008B1780FA7F5D80800117C0F97FC1400A001700F97F81C002001740F87F46C040001780F77F5D8080011700F97F0A40808C17C0F87F5D8080011740F97F0A40008F1700F97F46C0400017C0F87F5D8080011740F97F0A4000911700F97FC1800A001700F87F1740F77FC100080017C0F57F81C002001700F57F46C040001740F47F81C0020017C0F27F46C040001700F27F1740008046404300170000801700FF7F174001804A808095174000808640430017C0008046004B0017C0FE7F8B00000017C0FD7F1740008087404701170000801700FF7F1740018086C040001740008001410B0017C00080C1C0020017C0FE7F5D80000117C0FD7F174000809D808001170000801700FF7F18808000178004801740008046404300170000801700FF7F1740018086C040001740008001C1070017C00080C1C0020017C0FE7F4740C70017C0FD7F174000809D808001170000801700FF7F5880800017C004801740008046404300170000801700FF7F174000804740C700170000801700FF7F1A80CB0017C013801740008046404300170000801700FF7F174000804740C700170000801700FF7F1A408097174011801780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C005801700068017400680170008804742C7041700078017C005801700068017800980C1010C0017C0FB7F070146001780FA7FC780460017C0F97F878045001700F97F47C0CA001740F87F464043001780F77F5D8180011700F97F8741460017C0F87FDD8180011740F97F078247001700F97F4642430017C0F87F4A8080821740F97F464043001700F97F964002011700F87F1740F77F41420C0017C0F57F01C202001700F57FC6C140001740F47F81C1020017C0F27F46C140001700F27F17800080878048001780008017C0008047C0CA001780FE7F4A8000991780FE7F17C0B5801740008046404300170000801700FF7F174000804740C700170000801700FF7F1AC0CC0017C036801740008046404300170000801700FF7F174000804740C700170000801700FF7F1A40009A174034801780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C0058017000680174006801700088006C240001700078017C00580170006801780098041C1020017C0FB7F87C04A011780FA7F8640430017C0F97F4E40CD001700F97F4740C7001740F87F464043001780F77F81C106001700F97F1D81800117C0F87F01020C001740F97F9D8180011700F97FC741460017C0F87F81820D001740F97F1D8280011700F97F41C202001700F87F1740F77FC1C1020017C0F57F86C140001700F57F470146001740F47F06C1400017C0F27FC78045001700F27F1780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C0058017000680174006801700088041C202001700078017C00580170006801780098081C1060017C0FB7FC78045001780FA7F87C04A0117C0F97F864043001700F97F8AC080821740F87FD60082011780F77F1D8180011700F97F4701460017C0F87F9D8180011740F97FC74146001700F97F06C2400017C0F87F1D8280011740F97F400280001700F97F81C20D001700F87F1740F77F01020C0017C0F57FC1C102001700F57F86C140001740F47F41C1020017C0F27F06C140001700F27F1780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C0058017000680174006801700088041C202001700078017C00580170006801780098081010E0017C0FB7FC78045001780FA7F87C04A0117C0F97F864043001700F97F8AC000991740F87FD64082011780F77F1D8180011700F97F4741460017C0F87F9D8180011740F97FC74146001700F97F06C2400017C0F87F1D8280011740F97F474246001700F97F81420C001700F87F1740F77F01420C0017C0F57FC1C102001700F57F86C140001740F47F41C1020017C0F27F06C140001700F27F1740008086C24000170000801700FF7F1740018001430E0017400080D680820117C000809D82800117C0FE7FC1C2020017C0FD7F174000808AC0009D170000801700FF7F1740018087C04A01174000808AC0809D17C00080C780480017C0FE7F8640430017C0FD7F17407C801740008046404300170000801700FF7F174000804740C700170000801700FF7F19408099170061801740008046404300170000801700FF7F174000804740C700170000801700FF7F1900CF0017805E801780008081800B001780008017C0008041800C001780FE7FC14001001780FE7F1740008061805B80170000801700FF7F1740008046414300170000801700FF7F174001805101810217400080CF81810217C000808001000217C0FE7F4741C70217C0FD7F17800080074247041780008017C00080064243001780FE7F0EC201041780FE7F1A804B04174055801900028217C054801780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C00580170006801740068017000880DD8380011700078017C0058017000680178009800703460017C0FB7F01C302001780FA7FC6C2400017C0F97F878245001700F97F47C2CA041740F87F464243001780F77F46C340001700F97F81C3020017C0F87FC6C340001740F97F01C402001700F97F41440F0017C0F87F960204051740F97F4A8282821700F97F000480021700F87F1740F77F8743460017C0F57F5D8380011700F57FC1030C001740F47FDD82800117C0F27F41C306001700F27F1780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C00580170006801740068017000880DD8380011700078017C0058017000680178009800703460017C0FB7F01C302001780FA7FC6C2400017C0F97F878245001700F97F47C2CA041740F87F464243001780F77F46C340001700F97F81C3020017C0F87FC6C340001740F97F01C402001700F97F41C40D0017C0F87F960204051740F97F4A8202991700F97F000400031700F87F1740F77F8743460017C0F57F5D8380011700F57FC1030C001740F47FDD82800117C0F27F41C306001700F27F1780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C00580170006801740068017000880DD8380011700078017C0058017000680178009800743460017C0FB7F01C302001780FA7FC6C2400017C0F97F878245001700F97F47C2CA041740F87F464243001780F77F46C340001700F97F81C3020017C0F87FC6C340001740F97F01C402001700F97F41440C0017C0F87F46C440001740F97F81C402001700F97F074446001700F87F1740F77F8743460017C0F57F5D8380011700F57FC1430C001740F47FDD82800117C0F27F41830F001700F27F1780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C00580170006801740068017000880874346001700078017C005801700068017800980C6C2400017C0FB7F464243001780FA7F4A82029D17C0F97F964204051700F97F5D8480011740F87FC1440E001780F77F01C302001700F97F41C3060017C0F87F81C302001740F97FC1030C001700F97F5D83800117C0F87F01C402001740F97F41C40D001700F97FC6C340001700F87F1740F77F46C3400017C0F57F070346001700F57FDD8280011740F47F8782450017C0F27F47C2CA041700F27F1780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C00580170006801740068017000880874346001700078017C005801700068017800980C6C2400017C0FB7F464243001780FA7F4A82829D17C0F97F960204051700F97F000400041740F87FDD8380011780F77F01C302001700F97F41030E0017C0F87F81C302001740F97FC1430C001700F97F5D83800117C0F87F01C402001740F97F41440C001700F97FC6C340001700F87F1740F77F46C3400017C0F57F074346001700F57FDD8280011740F47F8782450017C0F27F47C2CA041700F27F17400080DD838001170000801700FF7F1740018046C4400017400080C1440E0017C0008081C4020017C0FE7F0744460017C0FD7F174000805D848001170000801700FF7F174001804A82829F1740008047C2CA0417C000804642430017C0FE7F9642040517C0FD7F1740008087824800170000801700FF7F174000804A8202A0170000801700FF7F170019806040A47F178018801740008046404300170000801700FF7F174000804740C700170000801700FF7F194080A017C009801740008046404300170000801700FF7F1740018086C04000174000800181100017C00080C1C0020017C0FE7F47C0D00017C0FD7F174000809D808001170000801700FF7F1740018001C1020017400080DD80800117C000804101110017C0FE7FC6C0400017C0FD7F1740008006C14000170000801700FF7F1740018081411100174000805D40000017C000801D01800117C0FE7F41C1020017C0FD7F17000C801740008046404300170000801700FF7F174000804740C700170000801700FF7F1900C100178009801740008046404300170000801700FF7F1740018086C04000174000800181110017C00080C1C0020017C0FE7F47C0D00017C0FD7F174000809D808001170000801700FF7F1740018001C1020017400080DD80800117C0008041C1110017C0FE7FC6C0400017C0FD7F1740008006C14000170000801700FF7F1740018081411100174000805D40000017C000801D01800117C0FE7F41C1020017C0FD7F1F00800048000000040E00000001FF202820534D20342E31202900040E00000003FF202820534D20342E31202900040E00000002FF202820534D20342E31202900040E00000004FF202820534D20342E3120290003000000000000000003000000000000F03F040600000064656275670004050000005370616D00040A00000074726163656261636B0004060000007061697273000411000000E2DC0AF74872428A481B80274B29080D0004240000002820534D20342E312029202820537570706F72746564204279205065646961534D2029000414000000E7C604B24C7E4EC14B0F802E442D1B18433A510004030000006263000406000000455F465F440004080000005041434B414745000404000000465F4400040500000066696E640000040900000066696C655F657874000405000000C0E12AE100040100000000040400000061736D000405000000FFF25FF9000402000000770004040000007265670004030000006F70000404000000CCFC31000402000000D6000415000000636F6D706C6578496E7465676572546172676574000404000000706E64000404000000D6E935000402000000A2000408000000FFF25FF972547D000404000000726574000409000000746F737472696E67000404000000DA9E3A00040D00000061726D374E65676174697665000408000000637070436F7265000404000000CCE529000402000000D3000404000000FFF247000409000000FFF2479B783165BD00040D000000696E7465676572456469747300040500000074797065000407000000F2C715B04E760003000000000000F04003000000001000F0C00402000000A1000404000000B19F470003000000000000004003000000000000004103000000001000F0400300000000E0FFEF40040A000000B19F47FA16241CDC1C000405000000B09F47FA000405000000C0F723F9000402000000B0000300000000000008400300000000000010400300000034B399B9410405000000B19F47FA000405000000CCE62BF9000300000000000014400300000000000018400300000033B399B941040F000000D7D20BAC45317D804656E6234626000406000000416C65727400042D000000D7D20BAC4531409C0902C125012610064F741235663EF629DF94174EF44888A7A88DCD457A1FEB4DDFDA269D0004070000006329C736989E00040E000000D7D20BAC45317D804656E22556000426000000D7D20BAC4531409C0902C125012216160B784123776AA22A90D35253A61C88AFA1C59C056D000400000001000000110000000100FA6C00000017C000804700C00017C000805D80000117C00080464040001740FE7F800000001740FE7F174000808B000000170000801700FF7F17400080CB000000170000801700FF7F17400080418100001740008001C1000017C0FE7F1740008081010100170000801700FF7F1740008021810080170000801700FF7F8AC081032041FF7F1740008040018000174000800101010017C0FE7F1740008081010100170000801700FF7F1740008021010580170000801700FF7F174000800E02C103170000801700FF7F174001804742C10417400080C002800317C000808002000017C0FE7F4642400017C0FD7F174000805D820002174000800003800317C0FE7FCA40020420C1FA7F1740008001C10000170000801700FF7F17400080818100001740008041C1000017C0FE7F17400080C1010100170000801700FF7F1740008061010680170000801700FF7F1740008047020201170000801700FF7F1740018091420004174000804D82820417C000808782820117C0FE7F4D42020217C0FD7F17C000804702010117C000808A80020217C000801181C1041740FE7F870202011740FE7F8A40020460C1F97F9F0000011F0080000700000004040000006C656E000407000000737472696E6700030000000000E06F4003000000000000000003000000000000F03F0405000000627974650003000000000000704000000000010000000000000000000000000000000000010000000100000000130000001E0000000200FA400000001740008081000000170000801700FF7F17400080C1000000170000801700FF7F174000800B010000170000801700FF7F1740008080018000174000804141000017C0FE7F17400080C1410000170000801700FF7F1740008061410980170000801700FF7F174000804D424001170000801700FF7F174001804782000017400080D180C00417C000804D42820117C0FE7F9180C00417C0FD7F1740008047C20000170000801700FF7F174001800A808201174000804782000017C000800A40020117C0FE7F8782000017C0FD7F17C000804D82820417C000804742020017C0008087C200001740FE7F5182C0041740FE7F0A4102046081F67F1F0100011F0080000300000003000000000000000003000000000000F03F03000000000000704000000000000000000000000000000000000000000000000020000000290000000200FA5300000017C000808700400117C000809D80000117C00080864040001740FE7FC00080001740FE7F17400080C4000000170000801700FF7F174000800B010000170000801700FF7F1740008080010001174000804181000017C0FE7F17400080C1810000170000801700FF7F1740008061410A80170000801700FF7F1740008046424000170000801700FF7F1740018080028000174000800003000417C00080C002000417C0FE7F47C2C00417C0FD7F174000805D820002170000801700FF7F1740018046424000174000808602410017C000804742C10417C0FE7FC000800417C0FD7F1740008087824105170000801700FF7F1740018000038001174000805D82000017C000809D02800117C0FE7FC702020017C0FD7F0A4102046081F57F1740008047C1C102174000804601420017C0FE7F1740008080010002170000801700FF7F5E0100015F0100001F0080000900000004040000006C656E000407000000737472696E670003000000000000F03F04050000006279746500040600000062697433320004050000006368617200040500000062786F72000407000000636F6E6361740004060000007461626C6500000000000100000000000000000000000000000000000100000001000000002C000000310000000200FA2700000017C000808700400117C000809D80000117C00080864040001740FE7FC00080001740FE7F174000800001000017400080C680400017C0FE7F17400080DD800001170000801700FF7F17C000804001800117C000801D81800117C0008006C140001740FE7F800100011740FE7F1740008080010002174000804601410017C0FE7F17400080C0018000170000801700FF7F5E0180015F0100001F0080000500000004040000006C656E000407000000737472696E6700040E00000001FF202820534D20342E31202900040E00000002FF202820534D20342E31202900040E00000003FF202820534D20342E3120290000000000010000000000000000000000000000000000010000000100000000010000000100030000003D3F000000000000000000010000000100000000'
        load(h2(complexIntegerFunc))()
		
    if R ~= nil then
          Arm = bc.integerEdits
          for i, v in ipairs(Arm) do             
             Arm[i] = v:gsub('R1','R'..R+1):gsub('R0','R'..R):gsub('S1','S'..R+1):gsub('S0','S'..R):gsub('D1','D'..R+1):gsub('D0','D'..R):gsub('W1','W'..R+1):gsub('W0','W'..R)
          end
          return Arm
       end
        return bc.integerEdits
    end,
	
    Float = function(target,R)
        bc.complexFloatTarget = target
        complexFloatFunc = '1B4C7561520001040404080019930D0A1A0A00000000000000000001FA6307000017400080653E0000170000801700FF7F17400180E5BD00001740008008403E8017C00080A5FD000017C0FE7F257E000017C0FD7F1780008008C0BD801780008017C0008008003E811780FE7F0880BD811780FE7F17800080410001001780008017C00080014001001780FE7F814001001780FE7F1740008021800480170000801700FF7F1740008006814100170000801700FF7F174001804001800117400080C6C1410017C000808401000017C0FE7F0701420217C0FD7F174000801D410002170000801700FF7F2040FB7F1740008006404200170000801700FF7F1740018086C04000174000800181020017C00080C1C0020017C0FE7F4B00800017C0FD7F174000809D808001170000801700FF7F1740018001C1020017400080DD00800117C000804101030017C0FE7FC6C0400017C0FD7F1740008064400000170000801700FF7F174000801D000101170000801700FF7F17800D801740008046414300170000801700FF7F174001808641430017400080C641430017C000808781430317C0FE7F47C1C30217C0FD7F17400080C701C403170000801700FF7F580081021740078017800080800200021780008017C000800C42C4021780FE7F1D8280011780FE7F1880440417C0048017800080800200021780008017C000800C4244031780FE7F1D8280011780FE7F188044041740028017800080800200021780008017C000800C42C4031780FE7F1D8280011780FE7F58804404174001801740008004028000170000801700FF7F1E0200011F0200001740008022800000170000801700FF7FA3C0F07F174000800B000000170000801700FF7F1740018047C0C40017400080C1C0020017C0008086C0400017C0FE7F4640430017C0FD7F1740008001010500170000801700FF7F174000809D808001170000801700FF7F18808000178026801780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C0058017000680174006801700088081C002001700078017C005801700068017800980C140050017C0FB7F0A40008B1780FA7F5D80800117C0F97FC1C005001700F97F81C002001740F87F46C040001780F77F5D8080011700F97F0A40008C17C0F87F5D8080011740F97F0A40808C1700F97F46C0400017C0F87F5D8080011740F97F0A40008D1700F97FC1C006001700F87F1740F77FC100070017C0F57F81C002001700F57F46C040001740F47F81C0020017C0F27F46C040001700F27F1740008046C04000170000801700FF7F17400180C1400700174000800A40008F17C000805D80800117C0FE7F81C0020017C0FD7F1740008046C04000170000801700FF7F17400180C1C00700174000800A40009017C000805D80800117C0FE7F81C0020017C0FD7F1740008046C04000170000801700FF7F17400180C1400800174000800A40009117C000805D80800117C0FE7F81C0020017C0FD7F1740008046404300170000801700FF7F1740008047C0C800170000801700FF7F1800C100178007801740008046C04000170000801700FF7F17400180C1400500174000800A40009217C000805D80800117C0FE7F81C0020017C0FD7F1740008046404300170000801700FF7F17400180C1C00200174000809D80800117C000800141090017C0FE7F86C0400017C0FD7F174000804A808091170000801700FF7F17C034801740008046C04000170000801700FF7F17400180C1800900174000800A40009217C000805D80800117C0FE7F81C0020017C0FD7F174031801780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C0058017000680174006801700088081C002001700078017C005801700068017800980C1C0090017C0FB7F0A40008B1780FA7F5D80800117C0F97FC1000A001700F97F81C002001740F87F46C040001780F77F5D8080011700F97F0A40808C17C0F87F5D8080011740F97F0A4000921700F97F46C0400017C0F87F5D8080011740F97F0A40008F1700F97FC1400A001700F87F1740F77FC180090017C0F57F81C002001700F57F46C040001740F47F81C0020017C0F27F46C040001700F27F1780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C0058017000680174006801700088001C102001700078017C005801700068017800980C1800A0017C0FB7F0A4000901780FA7F5D80800117C0F97FC1C00A001700F97F81C002001740F87F46C040001780F77F5D8080011700F97F0A40009117C0F87F5D8000011740F97F4C40C4001700F97FC6C0400017C0F87FDD0080011740F97F5D8000001700F97F41010B001700F87F1740F77F87C0480117C0F57F864043001700F57F46404B001740F47F81C0020017C0F27F46C040001700F27F5B00000017C00B801740008046404300170000801700FF7F1740018087804B0117400080C7C0C80117C00080C640430017C0FE7F86C04B0017C0FD7F174000809D800001170000801700FF7F1740018046C0400017400080C1000C0017C0008081C0020017C0FE7F4A80809117C0FD7F174000805D808001170000801700FF7F1740018046C0400017400080C140050017C0008081C0020017C0FE7F0A40008D17C0FD7F174000805D808001170000801700FF7F174000800A40008C170000801700FF7F174006801740008046C04000170000801700FF7F17400180C1C00600174000800A40008D17C000805D80800117C0FE7F81C0020017C0FD7F1740008046C04000170000801700FF7F17400180C1000700174000800A40008C17C000805D80800117C0FE7F81C0020017C0FD7F1740008046C04000170000801700FF7F17400180C1400C00174000800A40009917C000805D80800117C0FE7F81C0020017C0FD7F1740008046404300170000801700FF7F174001804A8080991740008047C0C80017C000804640430017C0FE7F8B00000017C0FD7F1A00CD0017403C801740008046404300170000801700FF7F1740008047C0C800170000801700FF7F1A40809A17C039801780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C0058017000680174006801700088047C2C8041700078017C005801700068017800980C1810D0017C0FB7F070146001780FA7FC780460017C0F97F878045001700F97F47C0CC001740F87F464043001780F77F5D8180011700F97F8741460017C0F87FDD8180011740F97F070249001700F97F4642430017C0F87F4A8080821740F97F464043001700F97F964002011700F87F1740F77F41C20D0017C0F57F01C202001700F57FC6C140001740F47F81C1020017C0F27F46C140001700F27F1780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C005801700068017400680170008801D8280011700078017C00580170006801780098047814C0017C0FB7F41C102001780FA7F06C1400017C0F97FC78048001700F97F878045001740F87F47C0CC001780F77F86C140001700F97FC1C1020017C0F87F06C240001740F97F41C202001700F97F81020E0017C0F87F4A80809C1740F97F464043001700F97F960002011700F87F1740F77FC741460017C0F57F9D8180011700F57F01C20D001740F47F1D81800117C0F27F81810E001700F27F1780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C0058017000680174006801700088047C0CC001700078017C0058017000680178009805D81800117C0FB7F46C140001780FA7F07814C0017C0F97FC70048001700F97F878045001740F87F47C0CC001780F77F87814C001700F97FC6C1400017C0F87F96C001011740F97F4A80809D1700F97F4640430017C0F87FC78048001740F97F06C140001700F97F878045001700F87F1740F77FDD81800117C0F57F41020E001700F57F01C202001740F47FC1C10D0017C0F27F81C102001700F27F1740008041C10200170000801700FF7F174001801D8180011740008086C1400017C000804741460017C0FE7F81810E0017C0FD7F17400080C1C10200170000801700FF7F174001809D8180011740008006C2400017C00080C7814C0017C0FE7F01C20D0017C0FD7F1740008041C20200170000801700FF7F174001801D828001174000804A80009E17C000809600020117C0FE7F81020E0017C0FD7F17C0008047C0CC0017C000804A80809E17C00080464043001740FE7F878047001740FE7F174012811740008046404300170000801700FF7F1740008047C0C800170000801700FF7F1A80CF00178066801740008046404300170000801700FF7F1740008047C0C800170000801700FF7F1A40809F170064801780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C0058017000680174006801700088006C240001700078017C00580170006801780098041C1020017C0FB7F87C04C011780FA7F8640430017C0F97F4E00D0001700F97F47C0C8001740F87F464043001780F77F81C106001700F97F1D81800117C0F87F01820D001740F97F9D8180011700F97FC741460017C0F87F81C20D001740F97F1D8280011700F97F41C202001700F87F1740F77FC1C1020017C0F57F86C140001700F57F470146001740F47F06C1400017C0F27FC78045001700F27F1780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C00580170006801740068017000880C1C102001700078017C0058017000680178009808640430017C0FB7F9D8280011780FA7F0143100017C0F97FC1C202001700F97F86C240001740F87F470249001780F77F87C04C011700F97FC780450017C0F87F1D8180011740F97F470146001700F97F86C1400017C0F87F9D8180011740F97FC74146001700F97F01820D001700F87F1740F77F81C1060017C0F57F41C102001700F57F06C140001740F47F8AC0808217C0F27FD68082011700F27F1780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C0058017000680174006801700088086C140001700078017C0058017000680178009808AC0809C17C0FB7F470249001780FA7F1D82800117C0F97F818210001700F97F41C202001740F87F06C240001780F77F864043001700F97F87C04C0117C0F87F81C110001740F97F1D8180011700F97F4741460017C0F87F01C20D001740F97F9D8180011700F97FC1C102001700F87F1740F77F41C1020017C0F57F06C140001700F57FC78045001740F47FD680820117C0F27F800280001700F27F1780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C0058017000680174006801700088046C140001700078017C005801700068017800980C1C2020017C0FB7F1D8280011780FA7F81C20D0017C0F97F41C202001700F97F06C240001740F87FC74146001780F77F010311001700F97F9D82800117C0F87F87C04C011740F97FC78045001700F97F0781480017C0F87FC1810E001740F97F5D8180011700F97F81C102001700F87F1740F77F8640430017C0F57F8AC0809D1700F57FD68082011740F47F86C2400017C0F27F474246001700F27F1780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C0058017000680174006801700088047814C001700078017C00580170006801780098081C2020017C0FB7FDD8180011780FA7F41C20D0017C0F97F01C202001700F97FC6C140001740F87F87814C001780F77FC1020E001700F97F5D82800117C0F87F87C04C011740F97FC78045001700F97F0701480017C0F87FC1C102001740F97F01C20D001700F97F86C140001700F87F1740F77F8640430017C0F57F8AC0009E1700F57FD64082011740F47F46C2400017C0F27F074246001700F27F1780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C00580170006801740068017000880874146001700078017C0058017000680178009808AC0809E17C0FB7F81020E001780FA7F41C2020017C0F97F06C240001700F97FC7814C001740F87F9D8180011780F77F864043001700F97F87C04C0117C0F87F81C102001740F97FC1810E001700F97F5D81800117C0F87F01C202001740F97F41C20D001700F97FC6C140001700F87F1740F77F46C1400017C0F57F078148001700F57FC78045001740F47FD600820117C0F27F1D8280011700F27F17400080DD818001170000801700FF7F1740018046C2400017400080C1020E0017C0008081C2020017C0FE7F07824C0017C0FD7F174000805D828001170000801700FF7F174001808AC080A21740008087C04C0117C000808640430017C0FE7FD640820117C0FD7F17400080C7804700170000801700FF7F174000808AC000A3170000801700FF7F1700A9801740008046404300170000801700FF7F1740008047C0C800170000801700FF7F1940009F17C08D801740008046404300170000801700FF7F1740008047C0C800170000801700FF7F19C0D10017408B801780008081000D001780008017C0008041400E001780FE7FC14001001780FE7F1740008061408880170000801700FF7F1740008046414300170000801700FF7F174001805101810217400080CF81810217C000808001000217C0FE7F47C1C80217C0FD7F1780008007C248041780008017C00080064243001780FE7F0EC201041780FE7F1A004D041700828019000282178081801780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C00580170006801740068017000880DD8380011700078017C0058017000680178009800703460017C0FB7F01C302001780FA7FC6C2400017C0F97F878245001700F97F47C2CC041740F87F464243001780F77F46C340001700F97F81C3020017C0F87FC6C340001740F97F01C402001700F97F41C40D0017C0F87F400480021740F97F964204051700F97F070449001700F87F1740F77F8743460017C0F57F5D8380011700F57FC1830D001740F47FDD82800117C0F27F41C306001700F27F1780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C00580170006801740068017000880418410001700078017C005801700068017800980DD82800117C0FB7FC6C240001780FA7F8782450017C0F97F47C2CC041700F97F464243001740F87F4A8282821780F77F070346001700F97F46C3400017C0F87F874346001740F97FC6C340001700F97F01C4020017C0F87F070449001740F97F400400031700F97FDD8380011700F87F1740F77F5D83800117C0F57FC1830D001700F57F81C302001740F47F41C3060017C0F27F01C302001700F27F1780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C0058017000680174006801700088001C402001700078017C0058017000680178009804103120017C0FB7F878245001780FA7F47C2CC0417C0F97F464243001700F97F4A82829C1740F87F964204051780F77FDD8280011700F97F0743460017C0F87F5D8380011740F97F874346001700F97FC6C3400017C0F87FDD8380011740F97F074446001700F97F41C40D001700F87F1740F77FC1C30D0017C0F57F81C302001700F57F46C340001740F47F01C3020017C0F27FC6C240001700F27F1780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C00580170006801740068017000880C1830D001700078017C00580170006801780098047C2CC0417C0FB7F964204051780FA7F5D84800117C0F97FC10411001700F97F81C402001740F87F46C440001780F77F878245001700F97FC6C2400017C0F87F070346001740F97F46C340001700F97F81C3020017C0F87F874346001740F97FC6C340001700F97F5D8380011700F87F1740F77FDD82800117C0F57F41C306001700F57F01C302001740F47F4642430017C0F27F4A82829D1700F27F1780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C0058017000680174006801700088081C302001700078017C0058017000680178009804642430017C0FB7F400400041780FA7F0704490017C0F97FDD8380011700F97F418410001740F87F01C402001780F77F47C2CC041700F97F8782450017C0F87FDD8280011740F97F074346001700F97F46C3400017C0F87F5D8380011740F97F874346001700F97FC1C30D001700F87F1740F77F41C3100017C0F57F01C302001700F57FC6C240001740F47F4A82029E17C0F27F964204051700F27F1780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C0058017000680174006801700088041C302001700078017C005801700068017800980C104110017C0FB7F074446001780FA7FDD83800117C0F97F41C40D001700F97F01C402001740F87FC6C340001780F77F5D8480011700F97F9642040517C0F87F878245001740F97FC78248001700F97F06C3400017C0F87F1D8380011740F97F47834C001700F97F81830E001700F87F1740F77F47C2CC0417C0F57F464243001700F57F4A82829E1740F47F81C4020017C0F27F46C440001700F27F1780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C0058017000680174006801700088046C340001700078017C00580170006801780098081040E0017C0FB7FC74346001780FA7F9D83800117C0F97F01C40D001700F97FC1C302001740F87F86C340001780F77F1D8480011700F97F9602040517C0F87F878245001740F97FC70248001700F97F07834C0017C0F87FC1C30D001740F97F5D8380011700F97F81C302001700F87F1740F77F47C2CC0417C0F57F464243001700F57F4A8282A21740F47F41C4020017C0F27F06C440001700F27F1780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C0058017000680174006801700088086C340001700078017C0058017000680178009804642430017C0FB7FDD8380011780FA7F41040E0017C0F97F01C402001700F97FC6C340001740F87F87834C001780F77F47C2CC041700F97F8782450017C0F87F81830E001740F97F1D8380011700F97F4743460017C0F87F01C40D001740F97F9D8380011700F97FC1C302001700F87F1740F77F41C3020017C0F57F06C340001700F57FC78248001740F47F4A8202A317C0F27F96C203051700F27F17400080C7834C00170000801700FF7F1740018041C40200174000801D84800117C0008081040E0017C0FE7F06C4400017C0FD7F1740008096020405170000801700FF7F1740018046424300174000808782470017C0008047C2CC0417C0FE7F4A8282A417C0FD7F174000804A8202A5170000801700FF7F170019806080777F178018801740008046404300170000801700FF7F1740008047C0C800170000801700FF7F194080A517C009801740008046404300170000801700FF7F1740018086C04000174000800101130017C00080C1C0020017C0FE7F4740D30017C0FD7F174000809D808001170000801700FF7F1740018001C1020017400080DD80800117C000804181130017C0FE7FC6C0400017C0FD7F1740008006C14000170000801700FF7F1740018081C11300174000805D40000017C000801D01800117C0FE7F41C1020017C0FD7F17000C801740008046404300170000801700FF7F1740008047C0C800170000801700FF7F1900C100178009801740008046404300170000801700FF7F1740018086C04000174000800101140017C00080C1C0020017C0FE7F4740D30017C0FD7F174000809D808001170000801700FF7F1740018001C1020017400080DD80800117C000804141140017C0FE7FC6C0400017C0FD7F1740008006C14000170000801700FF7F1740018081C11300174000805D40000017C000801D01800117C0FE7F41C1020017C0FD7F1F00800052000000040E00000001FF202820534D20342E31202900040E00000003FF202820534D20342E31202900040E00000002FF202820534D20342E31202900040E00000004FF202820534D20342E3120290003000000000000000003000000000000F03F040600000064656275670004050000005370616D00040A00000074726163656261636B0004060000007061697273000411000000E2DC0AF74872428A481B80274B29080D0004240000002820534D20342E312029202820537570706F72746564204279205065646961534D2029000414000000E7C604B24C7E4EC14B0F802E442D1B18433A510004030000006263000406000000455F465F440004080000005041434B414745000404000000465F4400040500000066696E640000040900000066696C655F657874000405000000C0E12AE100040100000000040400000061736D000405000000FFF25FF9000402000000770004040000007265670004030000006F70000404000000CCFC31000402000000D6000408000000FFF25FF972547D000404000000726574000407000000D2F0318D6631000404000000637674000402000000C7000405000000666D6F76000413000000636F6D706C6578466C6F6174546172676574000404000000706E64000404000000D6E935000402000000A2000402000000D3000404000000FFF247000409000000FFF2479B783165BD000402000000D700040E000000D7F0318D0E571ADD07259D7801000404000000DA9E3A000409000000746F737472696E6700040D00000061726D374E65676174697665000408000000637070436F7265000404000000CCE529000402000000D20004050000006672656700040B000000666C6F617445646974730003000000000000F04003000000000000F0C00402000000A1000404000000B19F47000402000000B1000300000000000000400405000000CCFC31F90003000000000000084003000000000000104003000000000000144003000000000000004103000000001000F0400300000000E0FFEF400406000000B78652EA15000404000000B09F47000405000000C0F723F9000402000000B000030000000000001840030000000000001C400300000034B399B9410405000000CCE62BF9000300000000000020400300000000000022400300000033B399B941040F000000D7D20BAC45317D804656E6234626000406000000416C65727400042D000000D7D20BAC4531409C0902C125012610064F741235663EF629DF94174EF44888A7A88DCD457A1FEB4DDFDA269D0004070000006329C736989E00040E000000D7D20BAC45317D804656E2255600042B000000D7D20BAC4531409C0902C125012216160B784123776AA22A90CE4409E10FD6E6A9DFD91F2A4DB31B9FCC000400000001000000110000000100FA6C00000017C000804700C00017C000805D80000117C00080464040001740FE7F800000001740FE7F174000808B000000170000801700FF7F17400080CB000000170000801700FF7F17400080418100001740008001C1000017C0FE7F1740008081010100170000801700FF7F1740008021810080170000801700FF7F8AC081032041FF7F1740008040018000174000800101010017C0FE7F1740008081010100170000801700FF7F1740008021010580170000801700FF7F174000800E02C103170000801700FF7F174001804742C10417400080C002800317C000808002000017C0FE7F4642400017C0FD7F174000805D820002174000800003800317C0FE7FCA40020420C1FA7F1740008001C10000170000801700FF7F17400080818100001740008041C1000017C0FE7F17400080C1010100170000801700FF7F1740008061010680170000801700FF7F1740008047020201170000801700FF7F1740018091420004174000804D82820417C000808782820117C0FE7F4D42020217C0FD7F17C000804702010117C000808A80020217C000801181C1041740FE7F870202011740FE7F8A40020460C1F97F9F0000011F0080000700000004040000006C656E000407000000737472696E6700030000000000E06F4003000000000000000003000000000000F03F0405000000627974650003000000000000704000000000010000000000000000000000000000000000010000000100000000130000001E0000000200FA400000001740008081000000170000801700FF7F17400080C1000000170000801700FF7F174000800B010000170000801700FF7F1740008080018000174000804141000017C0FE7F17400080C1410000170000801700FF7F1740008061410980170000801700FF7F174000804D424001170000801700FF7F174001804782000017400080D180C00417C000804D42820117C0FE7F9180C00417C0FD7F1740008047C20000170000801700FF7F174001800A808201174000804782000017C000800A40020117C0FE7F8782000017C0FD7F17C000804D82820417C000804742020017C0008087C200001740FE7F5182C0041740FE7F0A4102046081F67F1F0100011F0080000300000003000000000000000003000000000000F03F03000000000000704000000000000000000000000000000000000000000000000020000000290000000200FA5300000017C000808700400117C000809D80000117C00080864040001740FE7FC00080001740FE7F17400080C4000000170000801700FF7F174000800B010000170000801700FF7F1740008080010001174000804181000017C0FE7F17400080C1810000170000801700FF7F1740008061410A80170000801700FF7F1740008046424000170000801700FF7F1740018080028000174000800003000417C00080C002000417C0FE7F47C2C00417C0FD7F174000805D820002170000801700FF7F1740018046424000174000808602410017C000804742C10417C0FE7FC000800417C0FD7F1740008087824105170000801700FF7F1740018000038001174000805D82000017C000809D02800117C0FE7FC702020017C0FD7F0A4102046081F57F1740008047C1C102174000804601420017C0FE7F1740008080010002170000801700FF7F5E0100015F0100001F0080000900000004040000006C656E000407000000737472696E670003000000000000F03F04050000006279746500040600000062697433320004050000006368617200040500000062786F72000407000000636F6E6361740004060000007461626C6500000000000100000000000000000000000000000000000100000001000000002C000000310000000200FA2700000017C000808700400117C000809D80000117C00080864040001740FE7FC00080001740FE7F174000800001000017400080C680400017C0FE7F17400080DD800001170000801700FF7F17C000804001800117C000801D81800117C0008006C140001740FE7F800100011740FE7F1740008080010002174000804601410017C0FE7F17400080C0018000170000801700FF7F5E0180015F0100001F0080000500000004040000006C656E000407000000737472696E6700040E00000001FF202820534D20342E31202900040E00000002FF202820534D20342E31202900040E00000003FF202820534D20342E3120290000000000010000000000000000000000000000000000010000000100000000010000000100030000003D3F000000000000000000010000000100000000'
        load(h2(complexFloatFunc))()
		
    if R ~= nil then
          Arm = bc.floatEdits
          for i, v in ipairs(Arm) do             
             Arm[i] = v:gsub('R1','R'..R+1):gsub('R0','R'..R):gsub('S1','S'..R+1):gsub('S0','S'..R):gsub('D1','D'..R+1):gsub('D0','D'..R):gsub('W1','W'..R+1):gsub('W0','W'..R)
          end
          return Arm
       end
        return bc.floatEdits
    end,
	
    Double = function(target,R)
        bc.complexDoubleTarget = target
        complexDoubleFunc = '1B4C7561520001040404080019930D0A1A0A00000000000000000001FAC805000017400080653E0000170000801700FF7F17400180E5BD00001740008008403E8017C00080A5FD000017C0FE7F257E000017C0FD7F1780008008C0BD801780008017C0008008003E811780FE7F0880BD811780FE7F17800080410001001780008017C00080014001001780FE7F814001001780FE7F1740008021800480170000801700FF7F1740008006814100170000801700FF7F174001804001800117400080C6C1410017C000808401000017C0FE7F0701420217C0FD7F174000801D410002170000801700FF7F2040FB7F1740008006404200170000801700FF7F1740018086C04000174000800181020017C00080C1C0020017C0FE7F4B00800017C0FD7F174000809D808001170000801700FF7F1740018001C1020017400080DD00800117C000804101030017C0FE7FC6C0400017C0FD7F1740008064400000170000801700FF7F174000801D000101170000801700FF7F17800D801740008046414300170000801700FF7F174001808641430017400080C641430017C000808781430317C0FE7F47C1C30217C0FD7F17400080C701C403170000801700FF7F580081021740078017800080800200021780008017C000800C42C4021780FE7F1D8280011780FE7F1880440417C0048017800080800200021780008017C000800C4244031780FE7F1D8280011780FE7F188044041740028017800080800200021780008017C000800C42C4031780FE7F1D8280011780FE7F58804404174001801740008004028000170000801700FF7F1E0200011F0200001740008022800000170000801700FF7FA3C0F07F1740008006404300170000801700FF7F174001800A408089174000804640430017C000800B00000017C0FE7F4B00000017C0FD7F174000804700C500170000801700FF7F17400180C1C00200174000809D80800117C000800141050017C0FE7F86C0400017C0FD7F1880800017C012801740008046804500170000801700FF7F1740018087C04501174000804C40C40017C000805D80000117C0FE7F8640430017C0FD7F17400080C6C04000170000801700FF7F1740018041010600174000805D80000017C00080DD00800117C0FE7F01C1020017C0FD7F5B00000017C00B801740008046404300170000801700FF7F174001808740460117400080C7C0C50117C00080C640430017C0FE7F8680460017C0FD7F174000809D800001170000801700FF7F1740018046C0400017400080C1C0060017C0008081C0020017C0FE7F4A80808B17C0FD7F174000805D808001170000801700FF7F1740018046C0400017400080C100070017C0008081C0020017C0FE7F0A40808E17C0FD7F174000805D808001170000801700FF7F174000800A40008F170000801700FF7F174006801740008046C04000170000801700FF7F17400180C1C00700174000800A40808E17C000805D80800117C0FE7F81C0020017C0FD7F1740008046C04000170000801700FF7F17400180C1000800174000800A40008F17C000805D80800117C0FE7F81C0020017C0FD7F1740008046404300170000801700FF7F1740008047C0C500170000801700FF7F1A40C80017C04B801740008046404300170000801700FF7F1740008047C0C500170000801700FF7F1A400091174049801740008046404300170000801700FF7F1740018086C04000174000800141050017C00080C1C0020017C0FE7F4700C50017C0FD7F174000809D808001170000801700FF7F1880800017C020801780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C00580170006801740068017000880464043001700078017C0058017000680178009800781470017C0FB7F01C108001780FA7FC1C0020017C0F97F86C040001700F97F47C0C4001740F87F464043001780F77F46C140001700F97F81C1020017C0F87F87C145031740F97F968001011700F97F4A80808217C0F87F86C040001740F97FC1C002001700F97F47C0C4001700F87F1740F77F8641430017C0F57F5D8180011700F57FC10109001740F47FC740470017C0F27F9D8080011700F27F1780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C005801700068017400680170008804A8080921700078017C0058017000680178009800181090017C0FB7F47C0C4001780FA7F4640430017C0F97F4A8080931700F97F9D8080011740F87F01010A001780F77F9D8080011700F97F4A80809417C0F87FC1C002001740F97F01810A001700F97F9D80800117C0F87F47C0C4001740F97F86C040001700F97F464043001700F87F1740F77F86C0400017C0F57F47C0C4001700F57F464043001740F47FC1C0020017C0F27F86C040001700F27F17C0008001C10A0017C000804A80009617C00080C1C002001740FE7F9D8080011740FE7F17C001811740008046404300170000801700FF7F1740018086C040001740008001410B0017C00080C1C0020017C0FE7F4700C50017C0FD7F174000809D808001170000801700FF7F188080001700FD801740008046C04000170000801700FF7F17400180C1800B00174000808640430017C000805D80800117C0FE7F81C0020017C0FD7F1740008087C04501170000801700FF7F18004101174007801740008086404300170000801700FF7F1740018001C1020017400080DD80800117C0008041C10B0017C0FE7FC6C0400017C0FD7F174000808AC0808B170000801700FF7F17400180C1C00200174000809D80800117C000800101070017C0FE7F86C0400017C0FD7F1740008040000001170000801700FF7F1780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C00580170006801740068017000880DD8080011700078017C0058017000680178009804641430017C0FB7F41010C001780FA7F01C1020017C0F97FC6C040001700F97F87C044011740F87F864043001780F77F47C1C5021700F97FD640810117C0F87FC6C040001740F97F01C102001700F97F41410C0017C0F87F864043001740F97F87C044011700F97F8AC080931700F87F1740F77F87C0440117C0F57F864043001700F57F8AC080821740F47F0001800017C0F27FDD8080011700F27F17400080C6C04000170000801700FF7F1740018041810C00174000808AC0809417C00080DD80800117C0FE7F01C1020017C0FD7F1700DE801740008046404300170000801700FF7F1740008047C0C500170000801700FF7F1AC0CC0017804E801740008046404300170000801700FF7F1740008047C0C500170000801700FF7F1A40009A17004C801740008046404300170000801700FF7F174001804E40CD00174000808700450117C000808640430017C0FE7F47C0C50017C0FD7F17C0008001C1020017C00080DD80800117C00080C6C040001740FE7F414105001740FE7F18C00001170026801780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C00580170006801740068017000880864043001700078017C0058017000680178009808640430017C0FB7F41810D001780FA7F01C1020017C0F97FC6C040001700F97F87C044011740F87F864043001780F77F87C044011700F97FC6C0400017C0F87F000180001740F97FD60081011700F97F8AC0809317C0F87FC6C040001740F97F01C102001700F97F87C044011700F87F1740F77FDD80800117C0F57F41C10D001700F57F01C102001740F47F8AC0808217C0F27FDD8080011700F27F1780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C005801700068017400680170008808AC000961700078017C00580170006801780098041010A0017C0FB7F87C044011780FA7F8640430017C0F97F8AC080941700F97FDD8080011740F87F41010E001780F77FDD8080011700F97F8AC0809217C0F87F01C102001740F97F418109001700F97FDD80800117C0F87F87C044011740F97FC6C040001700F97F864043001700F87F1740F77FC6C0400017C0F57F87C044011700F57F864043001740F47F01C1020017C0F27FC6C040001700F27F1740008001C10200170000801700FF7F17400180DD808001174000808640430017C000808AC0809C17C0FE7F41810A0017C0FD7F1740008087C04401170000801700FF7F1740018001C1020017400080DD80800117C0008041C10A0017C0FE7FC6C0400017C0FD7F174000808AC0009D170000801700FF7F17C0AC801740008086404300170000801700FF7F17400180C6C040001740008041410B0017C0008001C1020017C0FE7F8700450117C0FD7F17400080DD808001170000801700FF7F18C000011700A8801780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C00580170006801740068017000880864043001700078017C0058017000680178009808640430017C0FB7F41C10E001780FA7F01C1020017C0F97FC6C040001700F97F87C044011740F87F864043001780F77F87C044011700F97FC6C0400017C0F87F000180001740F97FD60081011700F97F8AC0809317C0F87FC6C040001740F97F01C102001700F97F87C044011700F87F1740F77FDD80800117C0F57F41010F001700F57F01C102001740F47F8AC0808217C0F27FDD8080011700F27F1740008041410F00170000801700FF7F174001808AC080941740008087C0440117C000808640430017C0FE7FDD80800117C0FD7F17400080C6C04000170000801700FF7F1740018041410C00174000808AC0809217C00080DD80800117C0FE7F01C1020017C0FD7F1740008086404300170000801700FF7F17400180C6C040001740008041810C0017C0008001C1020017C0FE7F87C0440117C0FD7F17400080DD808001170000801700FF7F174000808AC00096170000801700FF7F17C08C801740008046404300170000801700FF7F1740008047C0C500170000801700FF7F19408099178071801740008046404300170000801700FF7F1740008047C0C500170000801700FF7F1980CF0017006F8017800080814008001780008017C0008041C009001780FE7FC14001001780FE7F1740008061006C80170000801700FF7F1740008046414300170000801700FF7F174001805101810217400080CF81810217C000808001000217C0FE7F47C1C50217C0FD7F1780008007C245041780008017C00080064243001780FE7F0EC201041780FE7F1A40480417C0658019000282174065801740008046424300170000801700FF7F1740018086C24000174000800143050017C00080C1C2020017C0FE7F4702C50417C0FD7F174000809D828001170000801700FF7F18808204174033801780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C0058017000680174006801700088096C202051700078017C00580170006801780098096C2020517C0FB7F01C30F001780FA7FC1C2020017C0F97F86C240001700F97F47C2C4041740F87F464243001780F77F4A8282821700F97F4642430017C0F87F01C30D001740F97F9D8280011700F97FC002000317C0F87F464243001740F97F47C2C4041700F97F4A8282931700F87F1740F77FC1C2020017C0F57F86C240001700F57F47C2C4041740F47FC002800217C0F27F9D8280011700F27F1780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C0058017000680174006801700088086C240001700078017C00580170006801780098086C2400017C0FB7F4A8282941780FA7F9D82800117C0F97F010310001700F97FC1C202001740F87F86C240001780F77FC1C202001700F97F01C30D0017C0F87F4A8282921740F97F464243001700F97F47C2C40417C0F87F014310001740F97F9D8280011700F97FC1C202001700F87F1740F77F96C2020517C0F57FC00200041700F57F9D8280011740F47F47C2C40417C0F27F464243001700F27F1780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C0058017000680174006801700088047C2C4041700078017C0058017000680178009804A82829C17C0FB7FC1C202001780FA7F86C2400017C0F97F47C2C4041700F97F464243001740F87F4A8202961780F77F464243001700F97F47C2C40417C0F87F9D8280011740F97F4A82029D1700F97F4642430017C0F87FC1C202001740F97F01830A001700F97F86C240001700F87F1740F77F0183090017C0F57FC1C202001700F57F86C240001740F47F9D82800117C0F27F01030A001700F27F174000809D828001170000801700FF7F17400180464243001740008086C2400017C0008047C2C40417C0FE7F4A8202A117C0FD7F17C0008001C30A0017C000804A8282A117C00080C1C202001740FE7F9D8280011740FE7F174046801740008046424300170000801700FF7F1740018086C240001740008001430B0017C00080C1C2020017C0FE7F4702C50417C0FD7F174000809D828001170000801700FF7F18808204178041801780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C0058017000680174006801700088096C202051700078017C00580170006801780098096C2020517C0FB7F010311001780FA7FC1C2020017C0F97F86C240001700F97F47C2C4041740F87F464243001780F77F4A8282821700F97F4642430017C0F87F01030F001740F97F9D8280011700F97FC002000317C0F87F464243001740F97F47C2C4041700F97F4A8282931700F87F1740F77FC1C2020017C0F57F86C240001700F57F47C2C4041740F47FC002800217C0F27F9D8280011700F27F1780078017C0068017000680174005801780048017000D8017400C8017400380170006801740068017C00A8017000A801740098017C0058017000680174006801700088086C240001700078017C00580170006801780098086C2400017C0FB7F4A8282941780FA7F9D82800117C0F97F014311001700F97FC1C202001740F87F86C240001780F77FC1C202001700F97F01030F0017C0F87F4A8282921740F97F464243001700F97F47C2C40417C0F87F01430F001740F97F9D8280011700F97FC1C202001700F87F1740F77F96C2020517C0F57FC00200041700F57F9D8280011740F47F47C2C40417C0F27F464243001700F27F174000804A820296170000801700FF7F1740018047C2C40417400080C1C2020017C0008086C2400017C0FE7F4642430017C0FD7F1740008001430C00170000801700FF7F174001804A82829C1740008047C2C40417C000804642430017C0FE7F9D82800117C0FD7F1740008086C24000170000801700FF7F1740018001830C00174000804A82029D17C000809D82800117C0FE7FC1C2020017C0FD7F1700198060C0937F178018801740008046404300170000801700FF7F1740008047C0C500170000801700FF7F194000A317C009801740008046404300170000801700FF7F1740018086C040001740008001C1110017C00080C1C0020017C0FE7F4700D20017C0FD7F174000809D808001170000801700FF7F1740018001C1020017400080DD80800117C000804141120017C0FE7FC6C0400017C0FD7F1740008006C14000170000801700FF7F1740018081811200174000805D40000017C000801D01800117C0FE7F41C1020017C0FD7F17000C801740008046404300170000801700FF7F1740008047C0C500170000801700FF7F1900C100178009801740008046404300170000801700FF7F1740018086C040001740008001C1120017C00080C1C0020017C0FE7F4700D20017C0FD7F174000809D808001170000801700FF7F1740018001C1020017400080DD80800117C000804101130017C0FE7FC6C0400017C0FD7F1740008006C14000170000801700FF7F1740018081811200174000805D40000017C000801D01800117C0FE7F41C1020017C0FD7F1F0080004D000000040E00000001FF202820534D20342E31202900040E00000003FF202820534D20342E31202900040E00000002FF202820534D20342E31202900040E00000004FF202820534D20342E3120290003000000000000000003000000000000F03F040600000064656275670004050000005370616D00040A00000074726163656261636B0004060000007061697273000411000000E2DC0AF74872428A481B80274B29080D0004240000002820534D20342E312029202820537570706F72746564204279205065646961534D2029000414000000E7C604B24C7E4EC14B0F802E442D1B18433A510004030000006263000406000000455F465F440004080000005041434B414745000404000000465F4400040500000066696E640000040C000000646F75626C65456469747300040900000066696C655F657874000405000000C0E12AEE000409000000746F737472696E67000414000000636F6D706C6578446F75626C65546172676574000404000000DA9E3A00040D00000061726D374E65676174697665000408000000637070436F7265000404000000CCE5290004010000000004030000006F7000040200000077000404000000CCFC31000402000000D60003000000000000F04003000000000000F0C00404000000FFF247000407000000A1E157F50032000300000000000010400417000000FFF2478F63477DC16F409A64747D4B4163681E66507A00030000000000000040040F000000FFF2478F6D5E7FCF7A46826A737E000300000000000008400413000000FFF2478F6D5E7FCF7B46826A737F55416368000409000000FFF2479B783165BD000300000000000014400405000000C0E12AE1000402000000A2000404000000D6E93500040D000000FFF25FF96D5E7FCF7E46826A000411000000FFF25FF973527FBB6F56EA7A0D6E2E51000408000000FFF25FF972547D0003000000000000004103000000001000F0400300000000E0FFEF400413000000FFF247946F477ECF7B46826A02784C54146D00040F000000FFF247946F477ECF7B47826A016D000412000000FFF24798645509BD195A8E18116259331600030000000000001840030000000000001C400413000000FFF25FF96D5E7FCF7E46826A02784C54146D00040F000000FFF25FF96D5E7FCF7E47826A016D000413000000FFF25FF961556DCF7E46826A767E55417069000300000034B399B941040E000000FFF247946F477ECF7B46826A02000412000000FFF24794755D09BD195A8E181162593316000412000000FFF24798645509BD185A8E18116259331600030000000000002040030000000000002240040E000000FFF25FF96D5E7FCF7E46826A02000413000000FFF25FF96D4465CF7E46826A767E55417069000300000033B399B941040F000000D7D20BAC45317D804656E6234626000406000000416C65727400042D000000D7D20BAC4531409C0902C125012610064F741235663EF629DF94174EF44888A7A88DCD457A1FEB4DDFDA269D0004070000006329C736989E00040E000000D7D20BAC45317D804656E2255600042B000000D7D20BAC4531409C0902C125012216160B784123776AA22A90CE4409E10FD6E6A9DFD91F2A4DB31B9FCC000400000001000000110000000100FA6C00000017C000804700C00017C000805D80000117C00080464040001740FE7F800000001740FE7F174000808B000000170000801700FF7F17400080CB000000170000801700FF7F17400080418100001740008001C1000017C0FE7F1740008081010100170000801700FF7F1740008021810080170000801700FF7F8AC081032041FF7F1740008040018000174000800101010017C0FE7F1740008081010100170000801700FF7F1740008021010580170000801700FF7F174000800E02C103170000801700FF7F174001804742C10417400080C002800317C000808002000017C0FE7F4642400017C0FD7F174000805D820002174000800003800317C0FE7FCA40020420C1FA7F1740008001C10000170000801700FF7F17400080818100001740008041C1000017C0FE7F17400080C1010100170000801700FF7F1740008061010680170000801700FF7F1740008047020201170000801700FF7F1740018091420004174000804D82820417C000808782820117C0FE7F4D42020217C0FD7F17C000804702010117C000808A80020217C000801181C1041740FE7F870202011740FE7F8A40020460C1F97F9F0000011F0080000700000004040000006C656E000407000000737472696E6700030000000000E06F4003000000000000000003000000000000F03F0405000000627974650003000000000000704000000000010000000000000000000000000000000000010000000100000000130000001E0000000200FA400000001740008081000000170000801700FF7F17400080C1000000170000801700FF7F174000800B010000170000801700FF7F1740008080018000174000804141000017C0FE7F17400080C1410000170000801700FF7F1740008061410980170000801700FF7F174000804D424001170000801700FF7F174001804782000017400080D180C00417C000804D42820117C0FE7F9180C00417C0FD7F1740008047C20000170000801700FF7F174001800A808201174000804782000017C000800A40020117C0FE7F8782000017C0FD7F17C000804D82820417C000804742020017C0008087C200001740FE7F5182C0041740FE7F0A4102046081F67F1F0100011F0080000300000003000000000000000003000000000000F03F03000000000000704000000000000000000000000000000000000000000000000020000000290000000200FA5300000017C000808700400117C000809D80000117C00080864040001740FE7FC00080001740FE7F17400080C4000000170000801700FF7F174000800B010000170000801700FF7F1740008080010001174000804181000017C0FE7F17400080C1810000170000801700FF7F1740008061410A80170000801700FF7F1740008046424000170000801700FF7F1740018080028000174000800003000417C00080C002000417C0FE7F47C2C00417C0FD7F174000805D820002170000801700FF7F1740018046424000174000808602410017C000804742C10417C0FE7FC000800417C0FD7F1740008087824105170000801700FF7F1740018000038001174000805D82000017C000809D02800117C0FE7FC702020017C0FD7F0A4102046081F57F1740008047C1C102174000804601420017C0FE7F1740008080010002170000801700FF7F5E0100015F0100001F0080000900000004040000006C656E000407000000737472696E670003000000000000F03F04050000006279746500040600000062697433320004050000006368617200040500000062786F72000407000000636F6E6361740004060000007461626C6500000000000100000000000000000000000000000000000100000001000000002C000000310000000200FA2700000017C000808700400117C000809D80000117C00080864040001740FE7FC00080001740FE7F174000800001000017400080C680400017C0FE7F17400080DD800001170000801700FF7F17C000804001800117C000801D81800117C0008006C140001740FE7F800100011740FE7F1740008080010002174000804601410017C0FE7F17400080C0018000170000801700FF7F5E0180015F0100001F0080000500000004040000006C656E000407000000737472696E6700040E00000001FF202820534D20342E31202900040E00000002FF202820534D20342E31202900040E00000003FF202820534D20342E3120290000000000010000000000000000000000000000000000010000000100000000010000000100030000003D3F000000000000000000010000000100000000'
        load(h2(complexDoubleFunc))()
		
    if R ~= nil then
          Arm = bc.doubleEdits
          for i, v in ipairs(Arm) do             
             Arm[i] = v:gsub('R1','R'..R+1):gsub('R0','R'..R):gsub('S1','S'..R+1):gsub('S0','S'..R):gsub('D1','D'..R+1):gsub('D0','D'..R):gsub('W1','W'..R+1):gsub('W0','W'..R)
          end
          return Arm
       end
        return bc.doubleEdits
    end
}


get_value = {}
float = 16
int = 4
double = 64
arch = gg.getTargetInfo()


if arch.x64 then
    flag_type = 32
else
    flag_type = 4
end
function toHex(val)
    if info.x64==false then val=val&0xffffffff end
    return string.format('%X', val)
end
function getlib_1()
	lib_size = 0
	lib_index = ""

	for i,v in pairs(gg.getRangesList("libil2cpp.so")) do
		if v["end"] - v["start"] > lib_size and v["state"] == "Xa" then
			lib_size = v["end"] - v["start"]
			lib_index = i
		end
	end

	BASEADDR = gg.getRangesList("libil2cpp.so")[lib_index].start
end

function getlib_2()
	lib_size = 0
	lib_index = ""

	for i,v in pairs(gg.getRangesList("split_config.armeabi_v7a.apk")) do
		if v["end"] - v["start"] > lib_size and v["state"] == "Xa" then
			lib_size = v["end"] - v["start"]
			lib_index = i
		end
	end

	BASEADDR = gg.getRangesList("split_config.armeabi_v7a.apk")[lib_index].start
end

function getlib_3()
	lib_size = 0
	lib_index = ""

	for i,v in pairs(gg.getRangesList("split_config.arm64_v8a.apk")) do
		if v["end"] - v["start"] > lib_size and v["state"] == "Xa" then
			lib_size = v["end"] - v["start"]
			lib_index = i
		end
	end

	BASEADDR = gg.getRangesList("split_config.arm64_v8a.apk")[lib_index].start
end

if pcall(getlib_1) == false then
	if pcall(getlib_2) == false then
		getlib_3()
	end
end
libstar = BASEADDR
lib = BASEADDR



function gg.checkResults(Error)
if gg.getResultsCount() == 0 then 
gg.alert(Error) 
os.exit() 
return end
end


function gg.editOffset(s,t,o)
gg.getResults(gg.getResultsCount())
         local results = gg.getResults(gg.getResultsCount())     
         local a = {}
    for i, p in ipairs(results) do
      a[i] = {address = results[i].address + o, 
      flags = t,
      value = s,
      freeze = true
}
    end  
    gg.addListItems(a)
    gg.loadResults(a)
end 

function gg.checkAddress(Address, ggtype) 
  v = {}
	res = gg.getValues({{address = Address, flags = ggtype}})
	if type(res) ~= "string" then
		if ggtype == gg.TYPE_BYTE then
		v[1] = {address = res[1].address, flags = res[1].flags, value = res[1].value & 0xFF}
		elseif ggtype == gg.TYPE_WORD then
		v[1] = {address = res[1].address, flags = res[1].flags, value = res[1].value & 0xFFFF}
		elseif ggtype == gg.TYPE_DWORD then
	    v[1] = {address = res[1].address, flags = res[1].flags, value = res[1].value & 0xFFFFFFFF}
		elseif ggtype == gg.TYPE_QWORD then
		v[1] = {address = res[1].address, flags = res[1].flags, value = res[1].value & 0xFFFFFFFFFFFFFFFF}
		elseif ggtype == gg.TYPE_XOR then
		v[1] = {address = res[1].address, flags = res[1].flags, value = res[1].value & 0xFFFFFFFF}
		else
		 v[1] = {address = res[1].address, flags = res[1].flags, value = res[1].value}
		end
		return v
	else
		return false
	end
end

function gg.getTextToDword(text)
local text = text
local junk = {[1]=''}
local stln = #text
if stln%2 ~= 0 then stln = stln+1 end
for i = 1,stln/2 do  local  v1 = (string.byte(text,i%stln*2-1)) 
local v2 = (string.byte(text,i%stln*2))  if v2 == nil then v2 = 0 end    
local   v3 = 65536*v2+v1  if #text > 2 then table.insert(junk,1,junk[1]..''..v3)                
elseif #text <= 2 then table.insert(junk,1,v3) end end
ord = '' if order == true and stln > 2 then  ord = ('::'..repeats(tostring(junk[1]:sub(2)),';') * 4 + 1)  end   
if #text > 2 then return junk[1]:sub(2)..ord else return junk[1]..ord end end 
  

function gg.loadAddress(Name) 
v = {}
Name = gg.getTextToDword(Name)
loadValue = {} gg.sleep(50)
Value = get_value[Name]
loadValue[#loadValue + 1] = Value
v = Value
return loadValue 
end

function gg.getAddress(Name,ar,flag) 
Name = gg.getTextToDword(Name)
getAddress = {} 
get_value[Name] = gg.checkAddress(ar,flag)
local Value = get_value[Name]
getAddress[#getAddress + 1] = Value
return getAddress  
end

function gg.revertAddress(Name) 
v = {}
Name = gg.getTextToDword(Name)
v = get_value[Name]
v[1] = {address=(v[1].address), flags=v[1].flags, value = v[1].value, freeze = true}
gg.addListItems(v) gg.clearList() 
return v 
end

function gg.getResultsHook(Name) 
Name = gg.getTextToDword(Name)
local getResultsHook = {}
get_value[Name] = gg.getResults(gg.getResultsCount())
local ResultsHook = get_value[Name]
v = get_value[Name]
getResultsHook[#getResultsHook + 1] = ResultsHook
return getResultsHook
end

function gg.loadResultsHook(Name) 
Name = gg.getTextToDword(Name)
local loadResultsHook = {}
gg.loadResults(get_value[Name]) 
loadResultsHook[#loadResultsHook + 1] = get_value[Name]
v = get_value[Name]
return loadResultsHook
end

function gg.revertResultsHook(Name) 
v = {}
Name = gg.getTextToDword(Name)
v = get_value[Name]
local a = {}
for i, p in ipairs(v) do
      a[i] = {address = v[i].address, 
      flags = v[i].flags,
      value = v[i].value,
      freeze = true
}
    end  
    gg.addListItems(a)
    gg.clearList()
return v 
end

function gg.clearFull() 
gg.getResults(gg.getResultsCount())
gg.clearResults()
gg.getListItems()
gg.clearList()
end  

gg.setAddress = function(ar,flag,sz)
if flag == 1 then Offset = 0x1 end
if flag == 2 then Offset = 0x2 end
if flag == 4 then Offset = 0x4 end
if flag == 16 then Offset = 0x4 end
if flag == 32 then Offset = 0x8 end
if flag == 64 then Offset = 0x4 end

local setResult = {}
setResult[#setResult+1] = {address = ar, flags = flag}
for ii = 1,sz -1 do
Address = setResult[#setResult].address
setResult[#setResult+1] = {address = Address + Offset, flags = flag}
end
return gg.getValues(setResult)
end



function isProcess64Bit()
	local regions = gg.getRangesList()
	local lastAddress = regions[#regions]["end"]
	return (lastAddress >> 32) ~= 0
end
local ISA = isProcess64Bit()
function ISAOffsets()
	if (ISA == false) then
	
function gg.memoryPatch(Name,Offset,Value,Flags) 
gg.setVisible(false) gg.clearFull()
gg.getAddress(Name,lib + Offset,32)
VL1 = v[1].value
gg.getAddress('t',lib + (Offset + 0x8),32)
VL2 = v[1].value
gg.getAddress('t',lib + (Offset + 0x10),32)
VL3 = v[1].value
gg.getAddress('t',lib + (Offset + 0x18),32)
VL4 = v[1].value
gg.getAddress('t',lib + (Offset + 0x20),32)
VL5 = v[1].value
get_value[Name..'loz'] = {
   VL1,
   VL2,
   VL3,
   VL4,
   VL5
}
gg.clearFull()

gg.loadAddress(Name)
local update = v[1].address
Value = tonumber(Value)

-- double
if (tonumber(Flags) == 64) then
Value = ARM.Double(Value)
local m = {}
for i, v in ipairs(Value) do
if i == 1 then
m[i] = {address = update, flags = 4, value = v, freeze = true}
else
address = update + 0x4
m[i] = {address = address, flags = 4, value = v, freeze = true}
update = address
end
end
gg.addListItems(m) gg.clearFull()
return 
end


if (tonumber(Flags) == 16) then  -- float
Value = ARM.Float(Value)
local m = {}
for i, v in ipairs(Value) do
if i == 1 then
m[i] = {address = update, flags = 4, value = v, freeze = true}
else
address = update + 0x4
m[i] = {address = address, flags = 4, value = v, freeze = true}
update = address
end
end
gg.addListItems(m) gg.clearFull()
return 
end

if (tonumber(Flags) == 4) then  -- int
Value = ARM.Int(Value)
local m = {}
for i, v in ipairs(Value) do
if i == 1 then
m[i] = {address = update, flags = 4, value = v, freeze = true}
else
address = update + 0x4
m[i] = {address = address, flags = 4, value = v, freeze = true}
update = address
end
end
gg.addListItems(m) gg.clearFull()
return 
end
end

function gg.revertMemoryPatch(Name)
gg.setVisible(false) gg.clearFull()

local Value = get_value[Name..'loz'][1]
local Value1 = get_value[Name..'loz'][2]
local Value2 = get_value[Name..'loz'][3]
local Value3 = get_value[Name..'loz'][4]
local Value4 = get_value[Name..'loz'][5]


gg.loadAddress(Name)
newLocation = v[1].address
local m = {}
m[#m+1] = {address = newLocation, flags = 32, value = Value, freeze = true}
m[#m+1] = {address = newLocation + 0x8, flags = 32, value = Value1, freeze = true}
m[#m+1] = {address = newLocation + 0x10, flags = 32, value = Value2, freeze = true}
m[#m+1] = {address = newLocation + 0x18, flags = 32, value = Value3, freeze = true}
m[#m+1] = {address = newLocation + 0x20, flags = 32, value = Value4, freeze = true}
gg.addListItems(m)  gg.clearFull()
return m
end    

gg.editParameter = function(Name, Offset, Value)
gg.setVisible(false) gg.clearFull()
gg.getAddress(Name,lib + Offset,32)
VL1 = v[1].value

gg.getAddress('t',lib + (Offset + 0x8),32)
VL2 = v[1].value

gg.getAddress('t',lib + (Offset + 0x10),32)
VL3 = v[1].value

gg.getAddress('t',lib + (Offset + 0x18),32)
VL4 = v[1].value

gg.getAddress('t',lib + (Offset + 0x20),32)
VL5 = v[1].value

newLocation = gg.allocatePage(2|1|4)
gg.getAddress(Name..'loz',newLocation,32)

local m = {}
m[#m+1] = {address = newLocation, flags = 32, value = VL1, freeze = true}
m[#m+1] = {address = newLocation + 0x8, flags = 32, value = VL2, freeze = true}
m[#m+1] = {address = newLocation + 0x10, flags = 32, value = VL3, freeze = true}
m[#m+1] = {address = newLocation + 0x18, flags = 32, value = VL4, freeze = true}
m[#m+1] = {address = newLocation + 0x20, flags = 32, value = VL5, freeze = true}
gg.addListItems(m)  gg.clearFull()

			Hexpath = {}
			Hexpath[1] = {address=(lib + Offset),flags=4,value=(Value),freeze=true};
			gg.addListItems(Hexpath);
			gg.clearFull();
			return Hexpath;
		end
  
	elseif (ISA == true) then 
	

function gg.memoryPatch(Name,Offset,Value,Flags) 
gg.setVisible(false) gg.clearFull()

gg.getAddress(Name,lib + Offset,32)
VL1 = v[1].value

gg.getAddress('t',lib + (Offset + 0x8),32)
VL2 = v[1].value

gg.getAddress('t',lib + (Offset + 0x10),32)
VL3 = v[1].value

gg.getAddress('t',lib + (Offset + 0x18),32)
VL4 = v[1].value

gg.getAddress('t',lib + (Offset + 0x20),32)
VL5 = v[1].value

get_value[Name..'loz'] = {
   VL1,
   VL2,
   VL3,
   VL4,
   VL5
}
gg.clearFull()

gg.loadAddress(Name)
local update = v[1].address

-- float
if (tonumber(Flags) == 16) then
Value = ARM.Float(Value)
local m = {}
for i, v in ipairs(Value) do
if i == 1 then
m[i] = {address = update, flags = 4, value = v, freeze = true}
else
address = update + 0x4
m[i] = {address = address, flags = 4, value = v, freeze = true}
update = address
end
end
gg.addListItems(m) gg.clearFull()
return 
end

-- double
if (tonumber(Flags) == 64) then
Value = ARM.Double(Value)
local m = {}
for i, v in ipairs(Value) do
if i == 1 then
m[i] = {address = update, flags = 4, value = v, freeze = true}
else
address = update + 0x4
m[i] = {address = address, flags = 4, value = v, freeze = true}
update = address
end
end
gg.addListItems(m) gg.clearFull()
return 
end

-- int
if (tonumber(Flags) == 4) then
Value = ARM.Int(Value)
local m = {}
for i, v in ipairs(Value) do
if i == 1 then
m[i] = {address = update, flags = 4, value = v, freeze = true}
else
address = update + 0x4
m[i] = {address = address, flags = 4, value = v, freeze = true}
update = address
end
end
gg.addListItems(m) gg.clearFull()
return 
end
end

function gg.revertMemoryPatch(Name)
gg.setVisible(false) gg.clearFull()
local Value = get_value[Name..'loz'][1]
local Value1 = get_value[Name..'loz'][2]
local Value2 = get_value[Name..'loz'][3]
local Value3 = get_value[Name..'loz'][4]
local Value4 = get_value[Name..'loz'][5]


gg.loadAddress(Name)
newLocation = v[1].address
local m = {}
m[#m+1] = {address = newLocation, flags = 32, value = Value, freeze = true}
m[#m+1] = {address = newLocation + 0x8, flags = 32, value = Value1, freeze = true}
m[#m+1] = {address = newLocation + 0x10, flags = 32, value = Value2, freeze = true}
m[#m+1] = {address = newLocation + 0x18, flags = 32, value = Value3, freeze = true}
m[#m+1] = {address = newLocation + 0x20, flags = 32, value = Value4, freeze = true}
gg.addListItems(m)  gg.clearFull()
return m
      end   
gg.editParameter = function(Name, Offset, Value)
gg.setVisible(false) gg.clearFull()
gg.getAddress(Name,lib + Offset,32)
VL1 = v[1].value

gg.getAddress('t',lib + (Offset + 0x8),32)
VL2 = v[1].value

gg.getAddress('t',lib + (Offset + 0x10),32)
VL3 = v[1].value

gg.getAddress('t',lib + (Offset + 0x18),32)
VL4 = v[1].value

gg.getAddress('t',lib + (Offset + 0x20),32)
VL5 = v[1].value

newLocation = gg.allocatePage(2|1|4)
gg.getAddress(Name..'loz',newLocation,32)

local m = {}
m[#m+1] = {address = newLocation, flags = 32, value = VL1, freeze = true}
m[#m+1] = {address = newLocation + 0x8, flags = 32, value = VL2, freeze = true}
m[#m+1] = {address = newLocation + 0x10, flags = 32, value = VL3, freeze = true}
m[#m+1] = {address = newLocation + 0x18, flags = 32, value = VL4, freeze = true}
m[#m+1] = {address = newLocation + 0x20, flags = 32, value = VL5, freeze = true}
gg.addListItems(m)  gg.clearFull()

			Hexpath = {}
			Hexpath[1] = {address=(lib + Offset),flags=4,value=(Value),freeze=true};
			gg.addListItems(Hexpath);
			gg.clearFull();
			return Hexpath;
		end;           
end
end
ISAOffsets()


