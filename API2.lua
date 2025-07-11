local gg = gg;
local open = io.open;
local sN, sP, rN, aLI, cR, gRC, sF, Log = gg.searchNumber, gg.searchPointer, gg.refineNumber, gg.addListItems, gg.clearResults, gg.getResultsCount, string.format, function() end;
local targetInfo = gg.getTargetInfo();
local x64 = targetInfo.x64;
local flagsType = (x64 and 32) or 4;
local isVN = ((gg.getLocale() == "vi") and true) or false;
local defaults, types = {}, {};
function WriteText(Direc, Text)
    f = io.open(Direc, "w");
    f:write(Text);
    f:close();
end
function gV(address, flags)
    return (not flags and gg.getValues(address)) or gg.getValues({{address=address,flags=flags}})[1].value;
end
function gRP(Pointer, From, To)
    return gg.getResults(gRC(), nil, From, To, nil, nil, nil, nil, Pointer);
end
function sV(Results, Freeze)
    local t = {};
    for i, v in pairs(Results) do
        t[#t + 1] = {address=v.address,flags=v.flags,value=v.value,freeze=true};
    end
    aLI(t);
    gg.removeListItems((Freeze and {}) or t);
    return t;
end
function gR(Count)
    return gg.getResults((Count and Count) or gRC());
end
function eO(Value, Flags, Offset, Freeze, Results)
    local t = {};
    for i, v in pairs((Results and Results) or gR()) do
        t[#t + 1] = {address=(v.address + Offset),flags=Flags,value=Value,freeze=true};
    end
    sV(t, Freeze);
    return t;
end
function rO(Value, Flags, Offset, Results)
    local t = {};
    for i, v in pairs((Results and Results) or gR()) do
        t[#t + 1] = {address=(v.address + Offset),flags=Flags};
    end
    local results = gV(t);
    gg.loadResults(results);
    gg.refineNumber(Value, Flags);
end
function gO(Offset, Flags, Table)
    local results = {};
    for i, v in pairs((Table and Table) or gR()) do
        results[#results + 1] = {address=(v.address + Offset),flags=Flags};
    end
    return gV(results);
end
function fV(val)
    return (x64 and (val & tonumber("0x00FFFFFFFFFFFFFF"))) or (val & tonumber("0xFFFFFFFF"));
end
function fA(val)
    return val | tonumber("0xB400000000000000");
end
function tH(val)
    return string.format("%X", val);
end
function gUTF(Address, Utf, Type)
    local bytes, char = {}, {address=fV(Address),flags=1};
    while gg.getValues({char})[1].value > 0 do
        bytes[#bytes + 1] = {address=char.address,flags=char.flags};
        char.address = char.address + ((Utf and 2) or 1);
    end
    return tostring(setmetatable(gg.getValues(bytes), {__tostring=function(self)
        for k, v in ipairs(self) do
            self[k] = string.char(v.value);
        end
        return table.concat(self);
    end}));
end
function gL(Name)
    local t = gg.getRangesList(Name);
    libs = {};
    for i, v in ipairs(t) do
        if ((gV(v.start, 4) == 1179403647) or (gV(v.start, 4) == 263434879)) then
            v["end"] = t[#t]["end"];
            libs[#libs + 1] = v;
        end
    end
    return libs[#libs].start, libs[#libs]["end"];
end
function gGMT()
    local gmt = gg.getRangesList("global-metadata.dat");
    if ((#gmt > 0) and (gV(gmt[1].start, 4) == -89056337)) then
        return gmt[1].start, gmt[#gmt]["end"];
    end
    gg.setRanges(gg.REGION_C_ALLOC);
    cR();
    sN("Q 00 'EnsureCapacity' 00", 1, nil, nil, nil, nil, 1);
    local t = gR();
    cR();
    for i, v in ipairs(gg.getRangesList()) do
        if (((t[1].address > v.start) and (t[1].address < v["end"])) or (t[1].address == v.start)) then
            return v.start, v["end"];
        end
    end
end
metaDataStart, metaDataEnd = gGMT();
il2cppStart, il2cppEnd = gL("libil2cpp.so");
Il2CppFlags = {Method={METHOD_ATTRIBUTE_MEMBER_ACCESS_MASK=7,Access={"private","internal","internal","protected","protected internal","public"},METHOD_ATTRIBUTE_STATIC=16,METHOD_ATTRIBUTE_ABSTRACT=1024},Field={FIELD_ATTRIBUTE_FIELD_ACCESS_MASK=7,Access={"private","internal","internal","protected","protected internal","public"},FIELD_ATTRIBUTE_STATIC=16,FIELD_ATTRIBUTE_LITERAL=64}};
local Il2cppMemory = {Methods={},Classes={},Fields={},DefaultValues={},Results={},Types={},GetInformationOfType=function(self, index)
    return self.Types[index];
end,SetInformationOfType=function(self, index, typeName)
    self.Types[index] = typeName;
end,SaveResults=function(self)
    if (gg.getResultsCount() > 0) then
        self.Results = gg.getResults(gg.getResultsCount());
    end
end,ClearSavedResults=function(self)
    self.Results = {};
end,GetDefaultValue=function(self, fieldIndex)
    return self.DefaultValues[fieldIndex];
end,SetDefaultValue=function(self, fieldIndex, defaultValue)
    self.DefaultValues[fieldIndex] = defaultValue or "nil";
end,GetInformationOfField=function(self, searchParam)
    return self.Fields[searchParam];
end,SetInformationOfField=function(self, searchParam, searchResult)
    if not searchResult.Error then
        self.Fields[searchParam] = searchResult;
    end
end,GetInformaionOfMethod=function(self, searchParam)
    return self.Methods[searchParam];
end,SetInformaionOfMethod=function(self, searchParam, searchResult)
    if not searchResult.Error then
        self.Methods[searchParam] = searchResult;
    end
end,GetInformationOfClass=function(self, searchParam)
    return self.Classes[searchParam];
end,SetInformationOfClass=function(self, searchParam, searchResult)
    self.Classes[searchParam] = searchResult;
end,ClearMemorize=function(self)
    self.Methods = {};
    self.Classes = {};
    self.Fields = {};
    self.DefaultValues = {};
    self.Results = {};
    self.Types = {};
end};
TypeApi = {version=gV(metaDataStart + 4, 4),tableTypes={[1]="void",[2]="bool",[3]="char",[4]="sbyte",[5]="byte",[6]="short",[7]="ushort",[8]="int",[9]="uint",[10]="long",[11]="ulong",[12]="float",[13]="double",[14]="string",[22]="TypedReference",[24]="IntPtr",[25]="UIntPtr",[28]="object",[15]=function(self, index)
    return self:GetTypePtr(index);
end,[17]=function(self, index)
    return self:GetClassNameFromIndex(index);
end,[18]=function(self, index)
    return self:GetClassNameFromIndex(index);
end,[29]=function(self, index)
    local typeMassiv = gg.getValues({{address=fV(index),flags=Unity.MainType},{address=(fV(index) + Unity.TypeOffset),flags=gg.TYPE_BYTE}});
    return self:GetTypeName(typeMassiv[2].value, typeMassiv[1].value) .. "[]";
end,[21]=function(self, index)
    if not (self.version < 27) then
        index = gg.getValues({{address=fV(index),flags=Unity.MainType}})[1].value;
    end
    index = gg.getValues({{address=fV(index),flags=Unity.MainType}})[1].value;
    return self:GetClassNameFromIndex(index);
end},GetClassNameFromIndex=function(self, index)
    if (self.version < 27) then
        local typeDefinitions = metaDataStart + self.typeDefinitionsOffset;
        index = (self.typeDefinitionsSize * index) + typeDefinitions;
    else
        index = fV(index);
    end
    local typeDefinition = gV(index, 4);
    return gUTF(self.StartIndex + typeDefinition);
end,GetTypeName=function(self, typeIndex, index)
    local typeName = self.tableTypes[typeIndex] or sF("(not support type -> 0x%X)", typeIndex);
    if (type(typeName) == "function") then
        local resultType = Il2cppMemory:GetInformationOfType(index);
        if not resultType then
            resultType = typeName(self, index);
            Il2cppMemory:SetInformationOfType(index, resultType);
        end
        typeName = resultType;
    end
    return typeName;
end,GetTypePtr=function(self, index)
    index = gV(fV(index), 4);
    local typeDefinitions = gV(self.classResults.address + (Unity.SizeType * index), flagsType);
    local typeName = gUTF(fV(gV(fV(typeDefinitions) + Unity.ClassNameOffset, Unity.MainType)));
    return typeName .. "*";
end,GetIndexApi=function(self)
    if (self.version == 0) then
        self.version = 29;
    end
    local gmt = gg.getRangesList("global-metadata.dat");
    local gmt = ((#gmt > 0) and gmt[1].start) or metaDataStart;
    cR();
    gg.setRanges(16 | 32);
    sN(gmt, flagsType, nil, nil, il2cppStart, -1, 1);
    if (gRC() == 0) then
        sN(fA(gmt), flagsType, nil, nil, il2cppStart, -1, 1);
    end
    local t = gR(1);
    cR();
    local results = gV({{address=(fV(gV(t[1].address + dllPointer, flagsType)) + 16),flags=flagsType},{address=fV(gV(t[1].address + classPointer, flagsType)),flags=flagsType}});
    self.dllResults = results[1];
    self.classResults = results[2];
    if (self.version < 27) then
        return fV(gV(self.dllResults.address + ((x64 and 8) or 0), flagsType));
    else
        address = gV(fV(self.dllResults.value + ((x64 and 16) or 8)), flagsType) + ((x64 and 24) or 16);
    end
    IndexStart = fV(gV(address, flagsType));
    return IndexStart;
end,GetTypeEnum=function(self, Il2CppType)
    return gg.getValues({{address=(Il2CppType + self.Type),flags=gg.TYPE_BYTE}})[1].value;
end};
dllPointer = (x64 and 24) or 12;
classPointer = (x64 and 40) or 20;
EnumType = (x64 and 306) or 186;
EnumRsh = 2;
FieldStart = 32;
if ((TypeApi.version < 27) and (TypeApi.version ~= 0)) then
    TypeApi.typeDefinitionsOffset = gV(metaDataStart + 160, 4);
    TypeApi.typeDefinitionsSize = 92;
    EnumType = (x64 and 302) or 186;
    EnumRsh = 3;
    FieldStart = 36;
    dllPointer = (x64 and 72) or 36;
    classPointer = (x64 and 24) or 12;
end
TypeApi.StartIndex = TypeApi:GetIndexApi();
FixUnityOffset = ((TypeApi.version == 29) and 0) or (x64 and 8) or 4;
FixParamOffset = ((TypeApi.version > 27) and 0) or (x64 and 16) or 12;
FixParamStep = ((TypeApi.version > 27) and ((x64 and 8) or 4)) or (x64 and 24) or 16;

function StringMetadata(Name)
    if not StringMetadataStart then
        StringMetadataStart = TypeApi.StartIndex;
        gg.setRanges(-1);
        gg.clearResults();
        gg.searchNumber("1~100000", 4, false, gg.SIGN_EQUAL, StringMetadataStart, metaDataEnd, 1);
        StringMetadataEnd = gR(1)[1].address;
        cR();
    end
    local result, chars = {}, {};
    for key, name in pairs({string.lower(Name),string.upper(Name),Name}) do
        local Name = ":" .. name;
        gg.setRanges(-1);
        gg.clearResults();
        gg.searchNumber(Name, gg.TYPE_BYTE, false, gg.SIGN_EQUAL, StringMetadataStart, StringMetadataEnd);
        gg.refineNumber(Name:sub(1, 2), gg.TYPE_BYTE);
        local t = gg.getResults(gg.getResultsCount());
        gg.clearResults();
        for k, v in pairs(t) do
            local char = {address=(v.address + 1),flags=1};
            repeat
                _value = gg.getValues({char})[1].value;
                _char = string.char(_value & 255);
                char.address = char.address - 1;
            until _value == 0 
            local address = char.address + 2;
            local name = gUTF(address);
            chars[#chars + 1] = name;
            result[#result + 1] = {address=address,flags=1,name=name};
        end
    end
    return {chars,result};
end
Unity = {TypeOffset=((x64 and 10) or 6),MainType=((x64 and 32) or 4),SizeType=((x64 and 8) or 4),ClassNameOffset=((x64 and 16) or 8),NamespaceOffset=((x64 and 24) or 12),StaticFieldsOffset=((x64 and 184) or 92),ParentOffset=((x64 and 88) or 44),TypeMetadataHandle=((x64 and 104) or 52),EnumType=EnumType,EnumRsh=EnumRsh,NumFields=((x64 and 288) or 168),FieldsLink=((x64 and 128) or 64),FieldsStep=((x64 and 32) or 20),FieldsOffset=((x64 and 24) or 12),FieldsType=((x64 and 8) or 4),FieldsStart=FieldStart,MethodsLink=((x64 and 152) or 76),MethodsFlags=(((x64 and 76) or 40) - FixUnityOffset),MethodsPC=(((x64 and 82) or 46) - FixUnityOffset),MethodsType=(((x64 and 40) or 20) - FixUnityOffset),MethodClassOffset=(((x64 and 32) or 16) - FixUnityOffset),MethodNameOffset=(((x64 and 24) or 12) - FixUnityOffset),MethodsParamType=(((x64 and (40 + 8)) or (20 + 4)) - FixUnityOffset),sPMT=function(self, Name)
    cR();
    gg.setRanges(0);
    gg.setRanges(gg.REGION_ANONYMOUS | gg.REGION_OTHER | gg.REGION_C_ALLOC);
    sN("Q 00 '" .. Name .. "' 00", 1, false, gg.SIGN_EQUAL, metaDataStart, metaDataEnd, 1);
    if (gRC() == 0) then
        return;
    end
    local t = gg.getResults(1, 1);
    cR();
    sN(t[1].address, self.MainType);
    if ((gRC() == 0) and x64) then
        sN(fA(t[1].address), self.MainType);
    end
end,getClass=function(self, className, fieldsInfo, methodsInfo)
    if (type(className) == "number") then
        return self:getClassInAddress(className, fieldsInfo, methodsInfo);
    end
    local classInfo = {};
    self:sPMT(className);
    local res = gR();
    cR();
    if (#res > 1) then
        for k, v in ipairs(res) do
            self.ClassInfo = v.address - self.ClassNameOffset;
            if gUTF(gV(gV(self.ClassInfo, v.flags), v.flags)):find(".dll") then
                _clazzInfo = self:getClassInAddress(self.ClassInfo, fieldsInfo, methodsInfo);
            end
        end
        return _clazzInfo;
    end
end,getClassInAddress=function(self, Address, fieldsInfo, methodsInfo)
    local classInfo = {};
    self.ClassInfo = fV(Address);
    if gUTF(gV(gV(self.ClassInfo, self.MainType), self.MainType)):find(".dll") then
        local ParentAddress = fV(gV(self.ClassInfo + self.ParentOffset, self.MainType));
        local TypeMetadataHandle = fV(gV(self.ClassInfo + self.TypeMetadataHandle, self.MainType));
        classInfo = {ClassName=gUTF(fV(gV(self.ClassInfo + self.ClassNameOffset, self.MainType))),Dll=gUTF(fV(gV(fV(gV(self.ClassInfo, self.MainType)), self.MainType))),ClassAddress=self.ClassInfo,NameSpace=gUTF(fV(gV(self.ClassInfo + self.NamespaceOffset, self.MainType))),IsEnum=(((gV(self.ClassInfo + self.EnumType, 1) >> self.EnumRsh) & 1) == 1),Parent={ClassName=gUTF(fV(gV(ParentAddress + self.ClassNameOffset, self.MainType))),Dll=gUTF(fV(gV(fV(gV(ParentAddress, self.MainType)), self.MainType))),ClassAddress=ParentAddress},TypeMetadataHandle=TypeMetadataHandle};
        if not self.NumMethods then
            self:setOffsetApiClass();
            if not self.NumMethods then
                Unity:getClass("PlayerCharacter");
                return self:getClassInAddress(Address, fieldsInfo, methodsInfo);
            end
        end
        if (not fieldsInfo and not methodsInfo) then
            return {classInfo};
        end
        if fieldsInfo then
            classInfo.Fields = self:setFields(self.ClassInfo);
        end
        if methodsInfo then
            classInfo.Methods = self:setMethods(self.ClassInfo);
        end
    end
    return {classInfo,function()
        return DumpCS({classInfo});
    end};
end,getObject=function(self, MemClass, Count)
    local Instances = {};
    gg.setRanges(gg.REGION_ANONYMOUS);
    cR();
    sN(MemClass.address, self.MainType);
    if (gRC() == 0) then
        sN(fA(MemClass.address), self.MainType);
    end
    local Instances = gR();
    gg.loadResults(Instances);
    sP(0, nil, nil, Count);
    local r, FilterInstances = gR(), {};
    for k, v in ipairs(r) do
        FilterInstances[#FilterInstances + 1] = {address=r[k].value,flags=r[k].flags} or nil;
    end
    gg.loadResults(FilterInstances);
    FilterInstances = gR();
    cR();
    return FilterInstances;
end,GetNumFields=function(self, ClassAddress)
    return gV(ClassAddress + self.NumFields, 2);
end,GetLinkFields=function(self, ClassAddress)
    return fV(gV(ClassAddress + self.FieldsLink, self.MainType));
end,GetNumMethods=function(self, ClassAddress)
    return gV(ClassAddress + self.NumMethods, 2);
end,GetLinkMethods=function(self, ClassAddress)
    return fV(gV(ClassAddress + self.MethodsLink, self.MainType));
end,setOffsetApiClass=function(self)
    local Address = fV((self.ClassInfo + self.NumFields) - 20);
    cR();
    sN("-1", 4, false, gg.SIGH_EQUAL, Address, Address + self.NumFields, 0);
    local pointer = gg.getResults(10);
    cR();
    if (#pointer == 0) then
        return;
    end
    local NumFieldsFix = fV((pointer[#pointer].address + 16) - self.ClassInfo);
    self.NumMethods = NumFieldsFix - 4;
    self.NumFields = NumFieldsFix;
    self.EnumType = NumFieldsFix + 15;
    gg.setRanges(-1);
    cR();
end,getTypeParam=function(self, ParamCount, ParamLink)
    if ((ParamCount == 0) or not ParamCount) then
        return "";
    end
    local ParamInfo = {};
    local ParamLink = ParamLink + FixParamOffset;
    for i = 1, ParamCount do
        local index = (i - 1) * FixParamStep;
        local Address = fV(gV({{address=(ParamLink + index),flags=self.MainType}})[1].value);
        local Param = gV({{address=(Address + self.TypeOffset),flags=1}})[1].value;
        local Param2 = fV(gV({{address=Address,flags=self.MainType}})[1].value);
        ParamInfo[#ParamInfo + 1] = TypeApi:GetTypeName(Param, Param2);
    end
    return table.concat(ParamInfo, ", ");
end,getMethodsInAddress=function(self, AddressMethodsInfo, _isClass)
    local methods = fV(AddressMethodsInfo);
    methodsInfo = gV({{address=(methods + self.MethodNameOffset),flags=self.MainType},{address=methods,flags=self.MainType},{address=(methods + self.MethodsFlags),flags=2},{address=(methods + self.MethodsPC),flags=1},{address=(methods + self.MethodsType),flags=self.MainType},{address=(methods + self.MethodsParamType),flags=self.MainType},{address=(methods + self.MethodClassOffset),flags=self.MainType}});
    local Count = methodsInfo[4].value;
    local ParamLink = fV(methodsInfo[6].value);
    local ParamType = self:getTypeParam(Count, ParamLink);
    local ClassAddress = fV(methodsInfo[7].value);
    local TypeInfo = gV({{address=fV(methodsInfo[5].value),flags=self.MainType},{address=(fV(methodsInfo[5].value) + self.TypeOffset),flags=1}});
    local MethodFlags = methodsInfo[3].value;
    local MethodsName = gUTF(fV(methodsInfo[1].value));
    Methods = {Dll=gUTF(fV(gV(fV(gV(ClassAddress, self.MainType)), self.MainType))),ClassName=gUTF(fV(gV(ClassAddress + self.ClassNameOffset, self.MainType))),ClassAddress=ClassAddress,MethodsName=MethodsName,Offset=sF("0x%X", fV(methodsInfo[2].value) - il2cppStart),AddressInMemory=fV(methodsInfo[2].value),AddressInfo=tH(fV(methodsInfo[2].address)),ParamCount=methodsInfo[4].value,ParamType=ParamType,ReturnType=TypeApi:GetTypeName(TypeInfo[2].value, fV(TypeInfo[1].value)),IsStatic=((MethodFlags & Il2CppFlags.Method.METHOD_ATTRIBUTE_STATIC) ~= 0),Access=(Il2CppFlags.Method.Access[MethodFlags & Il2CppFlags.Method.METHOD_ATTRIBUTE_MEMBER_ACCESS_MASK] or ""),IsAbstract=((MethodFlags & Il2CppFlags.Method.METHOD_ATTRIBUTE_ABSTRACT) ~= 0)};
    return Methods;
end,setMethods=function(self, AddressClass)
    local Methods = {};
    local MethodsCount, MethodsLink = self:GetNumMethods(AddressClass), self:GetLinkMethods(AddressClass);
    for i = 0, MethodsCount - 1 do
        local methods = fV(gV(MethodsLink + (i * self.SizeType), self.MainType));
        Methods[#Methods + 1] = self:getMethodsInAddress(methods, true);
    end
    return Methods;
end,setFields=function(self, AddressClass)
    AddressClass = fV(AddressClass);
    Fields = {};
    local FieldsCount, FieldsLink = self:GetNumFields(AddressClass), self:GetLinkFields(AddressClass);
    for i = 0, FieldsCount - 1 do
        local address = FieldsLink + (i * self.FieldsStep);
        Fields[#Fields + 1] = self:getFieldsInAddress(address, true);
    end
    return Fields;
end,getFields=function(self, fieldsName)
    if (type(fieldsName) == "number") then
        return self:getFieldsInAddress(fieldsName);
    end
    self:sPMT(fieldsName);
    local finaladdres, RetIl2CppFuncs = gR(), {};
    cR();
    for k, v in pairs(finaladdres) do
        local fields = fV(fieldsName);
        if self:isFields(fields) then
            RetIl2CppFuncs[#RetIl2CppFuncs + 1] = self:getFieldsInAddress(fields);
        end
    end
    return RetIl2CppFuncs;
end,getFieldsInAddress=function(self, address, _isFields)
    local fieldInfo = gg.getValues({{address=address,flags=self.MainType},{address=(address + self.FieldsOffset),flags=gg.TYPE_WORD},{address=(address + self.SizeType),flags=self.MainType},{address=(address + self.ClassNameOffset),flags=self.MainType}});
    local ClassInfo = self:isClass(fV(fieldInfo[4].value));
    local TypeInfo = gV({{address=(fV(fieldInfo[3].value) + self.SizeType),flags=2},{address=fV(fieldInfo[3].value),flags=self.MainType},{address=(fV(fieldInfo[3].value) + self.TypeOffset),flags=1}});
    local attrs = TypeInfo[1].value;
    local IsConst = (attrs & Il2CppFlags.Field.FIELD_ATTRIBUTE_LITERAL) ~= 0;
    searchResult = {Dll=ClassInfo[1].Dll,NameSpace=ClassInfo[1].NameSpace,ClassAddress=ClassInfo[1].ClassAddress,ClassName=ClassInfo[1].ClassName,Name=gUTF(fV(fieldInfo[1].value)),Offset=sF("0x%X", fieldInfo[2].value),IsStatic=(not IsConst and ((attrs & Il2CppFlags.Field.FIELD_ATTRIBUTE_STATIC) ~= 0)),Type=TypeApi:GetTypeName(TypeInfo[3].value, TypeInfo[2].value),IsConst=IsConst,Access=(Il2CppFlags.Field.Access[attrs & Il2CppFlags.Field.FIELD_ATTRIBUTE_FIELD_ACCESS_MASK] or "")};
    return searchResult;
end,isClass=function(self, address)
    local searchResult = Il2cppMemory:GetInformationOfClass(address);
    if searchResult then
        return searchResult;
    end
    local searchResult = self:getClass(fV(address));
    Il2cppMemory:SetInformationOfClass(fV(address), searchResult);
    return searchResult;
end,isMethods=function(self, address)
    local isClass = self:isClass(fV(gV(address + self.MethodClassOffset, flagsType)));
    if (isClass[1].ClassName and (isClass[1].ClassName ~= "")) then
        return true;
    end
    return false;
end,isFields=function(self, address)
    return (self:isClass(fV(gV(address + self.ClassNameOffset, flagsType)))[1].ClassName and true) or false;
end,getMethods=function(self, methodsName)
    if (type(methodsName) == "number") then
        local checkMethods = self:isMethods(methodsName)
        return checkMethods and self:getMethodsInAddress(methodsName) or nil
    end
    self:sPMT(methodsName);
    local finaladdres, RetIl2CppFuncs = gR(), {};
    cR();
    for k, v in pairs(finaladdres) do
        local methods = fV(v.address - self.MethodNameOffset);
        if self:isMethods(methods) then
            RetIl2CppFuncs[#RetIl2CppFuncs + 1] = self:getMethodsInAddress(methods);
            v.address = RetIl2CppFuncs[#RetIl2CppFuncs].AddressInMemory;
            v.name = tostring(RetIl2CppFuncs[#RetIl2CppFuncs]);
            finaladdres[k] = v;
        end
    end
    return RetIl2CppFuncs, finaladdres;
end};
if (gg.getTargetPackage() == "com.garena.game.kgvn") then
    Unity.MethodsPC = Unity.MethodsPC + ((x64 and 16) or 8);
end

function FindResultsMethods(Results)
    local MethodsInfo = {};
    gg.loadResults(Results);
    local t = gg.getResults(gg.getResultsCount());
    gg.clearResults();
    for i, v in ipairs(t) do
        MethodsInfo[#MethodsInfo + 1] = Unity:getMethods(v.address - Unity.MethodNameOffset);
    end
    return MethodsInfo;
end
function FindApi(Results, Type)
    local Methods = {};
    local Fields = {};
    local Class = {};
    local _result = {};
    gg.setRanges(gg.REGION_ANONYMOUS | gg.REGION_OTHER | gg.REGION_C_ALLOC);
    gg.loadResults(Results);
    sP(0);
    if (gRC() == 0) then
        for i, v in ipairs(Results) do
            cR();
            sN(fA(v.address), flagsType);
            local t = gR();
            if (#t > 0) then
                for ii, vv in ipairs(t) do
                    _result[#_result + 1] = vv;
                end
            end
        end
    end
    local t = ((#_result > 0) and _result) or gR();
    cR();
    for i, v in ipairs(t) do
        if (Type.Methods or not Type) then
            Methods[#Methods + 1] = Unity:getMethods(v.address - Unity.MethodNameOffset);
        end
        if (Type.Fields or not Type) then
            Fields[#Fields + 1] = Unity:getFields(v.address);
        end
        if (Type.Class or not Type) then
            local classInfo = Unity:isClass(v.address - Unity.ClassNameOffset)[1];
            Class[#Class + 1] = (classInfo.ClassName and classInfo) or nil;
        end
    end
    return {Class=Class,Fields=Fields,Methods=Methods};
end

	
--███████████████████████--███████████████████████
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

------------------------------------------------------------------------------  
function search()
gg.getResults(gg.getResultsCount())
gg.clearResults()
gg.searchNumber(x,t) 
end; 
------------------------------------------------------------------------------  
function get()
	gg.getResults(gg.getResultsCount());
end; 
------------------------------------------------------------------------------  
function refine(x)
	gg.refineNumber(x, t, false ,loai); 
end;
------------------------------------------------------------------------------  
function freeze(dbang)
bien2 = gg.getResults(9999)
    for i, v in  pairs (bien2) do
    bien2[i].value = dbang
    bien2[i].freeze= true
    end
gg.addListItems(bien2)
gg.clearResults()
end;
------------------------------------------------------------------------------  
function check()
E=nil E=gg.getResultsCount()
end; 
--███████████████████████--███████████████████████
--███████████████████████--███████████████████████
--███████████████████████--███████████████████████
--███████████████████████--███████████████████████
function getIntEdit(value)
    if value == nil then return nil end
    local numValue = tonumber(value)
    if numValue == nil then return nil end
    
    numValue = math.floor(numValue)
    local edits = {}

    -- Xử lý giá trị đặc biệt (tối ưu opcode)
    if numValue == 0 then
        return {"~A8 MOV W0, WZR", "~A8 RET"}
    elseif numValue == 1 then
        return {"~A8 MOV W0, #1", "~A8 RET"}
    end

    -- Logic từ xINT() - ARM64 only
    local AP = {}
    for i = 1, 2 do  -- Chỉ cần 2 lần đọc (32-bit)
        AP[i] = {
            address = gg.allocatePage(gg.PROT_READ | gg.PROT_WRITE) + (i-1)*2,
            flags = gg.TYPE_WORD
        }
    end
    gg.setValues({{
        address = AP[1].address,
        flags = gg.TYPE_DWORD,
        value = numValue
    }})
    AP = gg.getValues(AP)

    -- Chuyển sang HEX
    local hexParts = {}
    for i, v in ipairs(AP) do
        hexParts[i] = string.format("%04X", v.value & 0xFFFF)
    end
    local fullHex = hexParts[2]..hexParts[1]  -- Little-endian

    -- Tạo opcode tối ưu
    edits[1] = "~A8 MOV W0, #0x"..string.sub(fullHex, 5, 8)
    if string.sub(fullHex, 1, 4) ~= "0000" then
        edits[#edits+1] = "~A8 MOVK W0, #0x"..string.sub(fullHex, 1, 4)..", LSL #16"
    end

    -- Xử lý số âm
    if numValue < 0 then
        edits[#edits+1] = "~A8 NEG W0, W0"
    end

    edits[#edits+1] = "~A8 RET"
    return edits
end

--███████████████████████--███████████████████████
function getComplexFloatEdit(value)
    value = tonumber(value)
    local edits = {}

    -- Xử lý số từ 0 đến 65535 (tối ưu nhất)
	if value >= -65535 and value <= 65535 then
        if value == 0 then
            edits[1] = "~A8 MOV W0, WZR"  -- Gán 0
        else
            edits[1] = "~A8 MOV W0, #" .. value  -- Gán giá trị trực tiếp
        end
        edits[2] = "0000271Er"  -- FMOV S0, W0 (chuyển sang float)
        edits[3] = "00D8215Er"  -- SCVTF S0, S0 (convert to float)
        edits[4] = "0000261Er"  -- FMOV W0, S0 (đưa kết quả vào W0)
        edits[5] = "C0035FD6r"  -- RET (kết thúc hàm)

    -- Xử lý số từ 65536 đến 131072 (tách thành 65535 + N)
    elseif value <= 131072 and value >= 65537 then
        local remainder = value - 65535
        edits[1] = "~A8 MOV W0, #65535"
        edits[2] = "~A8 MOV W1, #" .. remainder
        edits[3] = "0000010Br"  -- ADD W0, W0, W1 (cộng 2 giá trị)
        edits[4] = "0000271Er"  -- FMOV S0, W0
        edits[5] = "00D8215Er"  -- SCVTF S0, S0
        edits[6] = "0000261Er"  -- FMOV W0, S0
        edits[7] = "C0035FD6r"  -- RET

    -- Xử lý số lớn >131072 (phân tích thành A*B + C)
    elseif value > 131072 and value < 429503284 then
        for i = 2, 65536 do
            local rem = value % i
            local mult = i
            local add_to = value - (rem * mult)
            if add_to <= 65536 and add_to > 0 then
                edits[1] = "~A8 MOV W0, #" .. rem
                edits[2] = "~A8 MOV W1, #" .. mult
                edits[3] = "007C011Br"  -- MUL W0, W0, W1 (nhân rem*mult)
                edits[4] = "~A8 MOV W1, #" .. add_to
                edits[5] = "0000010Br"  -- ADD W0, W0, W1 (cộng thêm add_to)
                edits[6] = "0000271Er"  -- FMOV S0, W0
                edits[7] = "00D8215Er"  -- SCVTF S0, S0
                edits[8] = "0000261Er"  -- FMOV W0, S0
                edits[9] = "C0035FD6r"  -- RET
                break
            end
        end
    else gg.alert("Không hỗ trợ")     
    end

    return edits
end

function getDoubleEdit(value)
    value = tonumber(value)
    local edits = {}

    -- Xử lý số từ 0 đến 65535 (tối ưu nhất)
	if value >= -65535 and value <= 65535 then
        if value == 0 then
            edits[1] = "~A8 MOV W0, WZR"  -- Gán 0
        else
            edits[1] = "~A8 MOV W0, #" .. value  -- Gán giá trị trực tiếp
        end
        edits[2] = "00D8215Er"  -- SCVTF D0, W0 (convert to double)
        edits[3] = "C0035FD6r"  -- RET (kết thúc hàm)

    -- Xử lý số từ 65536 đến 131072 (tách thành 65535 + N)
    elseif value <= 131072 and value >= 65537 then
        local remainder = value - 65535
        edits[1] = "~A8 MOV W0, #65535"
        edits[2] = "~A8 MOV W1, #" .. remainder
        edits[3] = "~A8 ADD W0, W0, W1"  -- ADD W0, W0, W1 (cộng 2 giá trị)
        edits[4] = "~A8 SCVTF D0, W0"  -- SCVTF D0, W0
        edits[5] = "C0035FD6r"  -- RET

    -- Xử lý số lớn >131072 (phân tích thành A*B + C)
    elseif value > 131072 and value < 429503284 then
        for i = 2, 65536 do
            local rem = value % i
            local mult = i
            local add_to = value - (rem * mult)
            if add_to <= 65536 and add_to > 0 then
                edits[1] = "~A8 MOV W0, #" .. rem
                edits[2] = "~A8 MOV W1, #" .. mult
                edits[3] = "~A8 MUL W0, W0, W1"  -- MUL W0, W0, W1 (nhân rem*mult)
                edits[4] = "~A8 MOV W1, #" .. add_to
                edits[5] = "~A8 ADD W0, W0, W1"  -- ADD W0, W0, W1 (cộng thêm add_to)
                edits[6] = "~A8 SCVTF D0, W0"  -- SCVTF D0, W0
                edits[7] = "C0035FD6r"  -- RET
                break
            end
        end
    else gg.alert("Không hỗ trợ") 
    end

    return edits
end
-- ███████████████████████ Hàm edit thông thường ███████████████████████
local memoryCache = {}

-- ███████████████████████ Hàm edit thông thường ███████████████████████
function edit(tagOrValue, valuesString)
    -- Xác định tham số đầu vào
    local tag, values
    
    -- Trường hợp chỉ có 1 tham số (dùng như edit("1;2;3"))
    if valuesString == nil then
        values = tagOrValue
        tag = nil
    -- Trường hợp có 2 tham số (dùng như edit("TAG", "1;2;3"))
    else
        tag = tagOrValue
        values = valuesString
    end
    
    -- Kiểm tra giá trị nhập vào
    if values == nil then
        gg.alert("⚠️ Lỗi: Không có giá trị nào được nhập!")
        return false
    end
    
    -- Chuyển đổi chuỗi thành bảng giá trị
    local mvqedit = {}
    for val in string.gmatch(tostring(values), "([^;]+)") do
        val = val:match("^%s*(.-)%s*$") -- Bỏ khoảng trắng thừa
        if val ~= "" then
            table.insert(mvqedit, val)
        end
    end
    
    if #mvqedit == 0 then
        gg.alert("⚠️ Lỗi: Chuỗi giá trị không hợp lệ!")
        return false
    end
    
    -- Lấy kết quả tìm kiếm hiện tại
    local Quoan = gg.getResults(gg.getResultsCount())
    if Quoan == nil or #Quoan == 0 then
        gg.alert("⚠️ Lỗi: Không có kết quả tìm kiếm nào!")
        return false
    end
    
    -- Tạo bảng giá trị để chỉnh sửa
    local valuetoedit = {}
    for i, addrInfo in ipairs(Quoan) do
        local addr = addrInfo.address or addrInfo
        for j = 1, #mvqedit do
            local numVal = tonumber(mvqedit[j])
            table.insert(valuetoedit, {
                address = addr + (4 * (j - 1)),
				flags = gg.TYPE_AUTO,
                value = numVal or mvqedit[j],
                freeze = true
            })
        end
    end
    
    -- Lưu vào cache nếu có tag
    if tag and not memoryCache[tag] then
        memoryCache[tag] = gg.getValues(valuetoedit)
    end
    
    -- Áp dụng thay đổi
    gg.addListItems(valuetoedit)
    gg.removeListItems(valuetoedit)
    gg.clearResults()
	gg.sleep(500)
    return true
end

-- ███████████████████████ Hàm edit dùng ARM assembly ███████████████████████
function editarm(tag, value, valueType)
    -- Kiểm tra giá trị đầu vào
        
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
--███████████████████████--███████████████████████
--███████████████████████--███████████████████████
function MVQFind2(clazz, method) --Method sau đó class
    local results = Unity:getMethods(method)
    for i, v in ipairs(results) do
        if v.ClassName == clazz then 
            gg.loadResults({{address = v.AddressInMemory, flags = gg.TYPE_DWORD}})
            return v.Offset
        end
    end
end
--███████████████████████--███████████████████████
function MVQAllClass(clazz)
    local classResults = Unity:getClass(clazz)
    local methods = Unity:setMethods(classResults[1].ClassAddress)
    local results = {}
    for i, v in ipairs(methods) do
        results[#results + 1] = {
            address = v.AddressInMemory,
            flags = gg.TYPE_DWORD,
            name = string.format("%s::%s (%s)", clazz, v.MethodsName, v.ReturnType),
        }
    end
    gg.loadResults(results)
end
--███████████████████████--███████████████████████
function MVQAllMethod(method)
    local results = Unity:getMethods(method)
    local resultList = {}
    for i, v in ipairs(results) do
        resultList[#resultList + 1] = {
            address = v.AddressInMemory,
            flags = gg.TYPE_DWORD,
        }
    end
    
    gg.loadResults(resultList) 
    return resultList
end	
--███████████████████████--███████████████████████
function MVQAllClass(clazz)
    local classInfo = Unity:getClass(clazz)
    local methods = Unity:setMethods(classInfo[1].ClassAddress)
    if not methods or #methods == 0 then
        gg.toast("Class không có methods")
        return
    end

    local results = {}
    for i, v in ipairs(methods) do
        if v.AddressInMemory and v.AddressInMemory ~= 0 then
            results[#results + 1] = {
                address = v.AddressInMemory,
                flags = gg.TYPE_DWORD,
            }
        end
    end
    gg.loadResults(results)
end
--███████████████████████--███████████████████████

      --Trying to leak my script? U dump fuck. Here!!! Dec this then u will know what in here
