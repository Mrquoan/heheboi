API = gg.makeRequest('https://raw.githubusercontent.com/Mrquoan/heheboi/refs/heads/main/APITEST.lua').content
pcall(load(API))
EDIT = gg.makeRequest('https://raw.githubusercontent.com/Mrquoan/heheboi/refs/heads/main/EDIT.lua').content
pcall(load(EDIT))
FIELD = gg.makeRequest('https://raw.githubusercontent.com/Mrquoan/heheboi/refs/heads/main/FIELD.lua').content
pcall(load(FIELD))


function MVQFind(className, methodName)
    local classes = Il2Cpp.Class(className)
    local klass = classes[1] 
    local method = klass:GetMethod(methodName)
    gg.loadResults({{address = method.methodPointer, flags = gg.TYPE_DWORD}})
    gg.setVisible(false)
    
    return true
end

function MVQClass(className)
    local r = {}
    for _, k in ipairs(Il2Cpp.Class(className) or {}) do
        for _, m in ipairs(k:GetMethods() or {}) do
            if m.methodPointer and m.methodPointer ~= 0 then
                r[#r+1] = {address = m.methodPointer, flags = gg.TYPE_DWORD}
            end
        end
    end
    if #r > 0 then gg.loadResults(r) gg.setVisible(false) end
    return #r > 0
end

function MVQMethod(methodName)
    local r = {}
    for _, m in ipairs(Il2Cpp.Method(methodName) or {}) do
        if m.methodPointer and m.methodPointer ~= 0 then
            r[#r+1] = {address = m.methodPointer, flags = gg.TYPE_DWORD}
        end
    end
    if #r > 0 then gg.loadResults(r) gg.setVisible(false) end
    return #r > 0
end


