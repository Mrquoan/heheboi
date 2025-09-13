(function() local modules = {
   Name = 'Lua Obfuscator',
   Version = 'v0.1',
   By = 'LeThi9GG'
}
modules['cli'] = function()
local obfLT9 = require("obfLT9");

local function file_exists(file)
    local f = io.open(file, "rb")
    if f then f:close() end
    return f ~= nil
end

--! get all lines from a file, returns an empty
--! list/table if the file does not exist
local function lines_from(file)
    if not file_exists(file) then return {} end
    local lines = {}
    for line in io.lines(file) do
      lines[#lines + 1] = line
    end
    return lines
  end

--! CLI
local config;
local sourceFile;
local outFile;
local luaVersion;
local prettyPrint;


getLocale = gg.getLocale()
infoScript = "Script Lua Obfuscator By LeThi9GG \n\n"
if getLocale ~= "vi" then
    fcnName = {infoScript..
    "Script Path:",
    "Beautify",
    "Minify",
    --"Weak",
    "Medium",
    "Strong",
    }
else
    fcnName = {infoScript..
    "Đường dẫn tập lệnh:",
    "Làm đẹp",
    "Thu nhỏ",
    --"Yếu đuối",
    "Trung bình",
    "Mạnh",
    }
end

local cfg_file = gg.EXT_CACHE_DIR..'/obfGG.cfg'
local chunk = loadfile(cfg_file)
local cfg = nil
if chunk ~= nil then
	cfg = chunk()
end
if not cfg then
    cfg = {gg.EXT_STORAGE, false, false, false, true}
end




local defaults = cfg
function home()
    prompts = gg.prompt(fcnName, defaults, {
      "file",
      "checkbox",
      "checkbox",
      "checkbox",
      "checkbox",
      "checkbox",
      "checkbox",
    })    
    if prompts == nil then
        return
    end
    if prompts[1] ~= gg.EXT_STORAGE then
        sourceFile = prompts[1]
    else
        return
    end
    if prompts[2] then
        prettyPrint = true;
        obfName = "beautify";
    end
    if prompts[3] then
        config = obfLT9.Presets.Minify;
        obfName = "minify";
    end
    --[[if prompts[4] then
        config = obfLT9.Presets.Weak;
        obfName = "weak";
    end]]
    if prompts[4] then
        config = obfLT9.Presets.Weak;
        obfName = "weak";
    end
    if prompts[5] then
        config = obfLT9.Presets.Medium;
        obfName = "strong";
    end
    defaults = prompts
    gg.saveVariable(defaults, cfg_file)
    LuaVersion = "Lua53";
    print("Script Lua Obfuscator By LeThi9GG\n")
    if not sourceFile then
    obfLT9.Logger:error("No input file was specified!")
end

    if not file_exists(sourceFile) then
        obfLT9.Logger:error(string.format("The File \"%s\" was not found!", sourceFile));
    end
    local source = io.open(sourceFile, "r"):read("a");

    if not outFile then
        if sourceFile:sub(-4) == ".lua" then
            outFile = sourceFile:sub(0, -5) .. "-" .. obfName .. ".lua";
        else
            outFile = sourceFile .. "-" .. obfName .. ".lua";
        end
    end
    if not config and prettyPrint then
        local config = obfLT9.Presets.Beautify;
        local pipeline = obfLT9.Pipeline:fromConfig(config);
        local out = pipeline:apply(source, sourceFile); 
        obfLT9.Logger:info(string.format("Writing output to \"%s\"", outFile));
        io.open(outFile, "w"):write(out):close()
        gg.alert("Script Lua Obfuscator By LeThi9GG\n\n" .. string.format("Writing output to \"%s\"", outFile) .. "\n\n\n" .. table.concat(logger_results, '\n') .. "\n\n")
        return
    end

    --! Add Option to override Lua Version
    config.LuaVersion = luaVersion or config.LuaVersion;
    config.PrettyPrint = prettyPrint ~= nil and prettyPrint or config.PrettyPrint;
    
    for i, v in pairs(config.Steps) do
        if v.Name == "AntiTamper" and config.PrettyPrint then
            obfLT9.Logger:warn(string.format("\"%s\" cannot be used with Beautify, ignoring \"%s\"", "Anti Tamper", "Beautify"));
            config.PrettyPrint = false
        end
    end
    
    local pipeline = obfLT9.Pipeline:fromConfig(config);
    local out = pipeline:apply(source, sourceFile);
    obfLT9.Logger:info(string.format("Writing output to \"%s\"", outFile));

    --! Write Output
    local handle = io.open(outFile, "w");
    handle:write(out);
    handle:close();
    gg.alert("Script Lua Obfuscator By LeThi9GG\n\n" .. string.format("Writing output to \"%s\"", outFile) .. "\n\n\n" .. table.concat(logger_results, '\n') .. "\n\n")
end
home()
end;modules['obfLT9'] = function()
-- Math.random Fix for Lua5.1
-- Check if fix is needed
if not pcall(function()
    return math.random(1, 2^40);
end) then
    local oldMathRandom = math.random;
    math.random = function(a, b)
        if not a and b then
            return oldMathRandom();
        end
        if not b then
            return math.random(1, a);
        end
        if a > b then
            a, b = b, a;
        end
        local diff = b - a;
        assert(diff >= 0);
        if diff > 2 ^ 31 - 1 then
            return math.floor(oldMathRandom() * diff + a);
        else
            return oldMathRandom(a, b);
        end
    end
end

-- newproxy polyfill
_G.newproxy = _G.newproxy or function(arg)
    if arg then
        return setmetatable({}, {});
    end
    return {};
end


-- Require obfLT9 Submodules
local Pipeline  = require("obfLT9.pipeline");
local highlight = require("highlightlua");
local Logger    = require("logger");
local Presets   = require("presets");
local Config    = require("config");
local util      = require("obfLT9.util");


-- Export
return {
    Pipeline  = Pipeline;
    Config    = util.readonly(Config); -- Readonly
    Logger    = Logger;
    highlight = highlight;
    Presets   = Presets;
}


end;modules['obfLT9.pipeline'] = function()
local config = require("config");
local Ast    = require("obfLT9.ast");
local Enums  = require("obfLT9.enums");
local util = require("obfLT9.util");
local Parser = require("obfLT9.parser");
local Unparser = require("obfLT9.unparser");
local logger = require("logger");

local NameGenerators = require("obfLT9.namegenerators");

local Steps = require("obfLT9.steps");

local lookupify = util.lookupify;
local LuaVersion = Enums.LuaVersion;
local AstKind = Ast.AstKind;

-- On Windows os.clock can be used. On other Systems os.time must be used for benchmarking
local isWindows = package and package.config and type(package.config) == "string" and package.config:sub(1,1) == "\\";
local function gettime()
	if isWindows then
		return os.clock();
	else
		return os.time();
	end
end

local Pipeline = {
	NameGenerators = NameGenerators;
	Steps = Steps;
	DefaultSettings = {
		LuaVersion = LuaVersion.Lua53; -- The Lua Version to use for the Tokenizer, Parser and Unparser
		PrettyPrint = false; -- Note that Pretty Print is currently not producing Pretty results
		Seed = 0; -- The Seed. 0 or below uses the current time as a seed
		VarNamePrefix = ""; -- The Prefix that every variable will start with
		RenameVariables = true;
	}
}


function Pipeline:new(settings)
	local settings = settings or {}
	local luaVersion = settings.LuaVersion or Pipeline.DefaultSettings.LuaVersion;
	local conventions = Enums.Conventions[luaVersion];
	if(not conventions) then
		logger:error("The Lua Version \"" .. luaVersion 
			.. "\" is not recognised by the Tokenizer! Please use one of the following: \"" .. table.concat(util.keys(Enums.Conventions), "\",\"") .. "\"");
	end
	
	local prettyPrint = settings.PrettyPrint or Pipeline.DefaultSettings.PrettyPrint;
	local prefix = settings.VarNamePrefix or Pipeline.DefaultSettings.VarNamePrefix;
	local seed = settings.Seed or 0;
	if settings.RenameVariables == false then
	    renameVar = false
	elseif settings.RenameVariables == nil then
	    renameVar = Pipeline.DefaultSettings.RenameVariables-- == false and false or Pipeline.DefaultSettings.RenameVariables;
	elseif settings.RenameVariables then
	    renameVar = true
	end
	
	local pipeline = {
		LuaVersion = luaVersion;
		PrettyPrint = prettyPrint;
		VarNamePrefix = prefix;
		Seed = seed;
		RenameVariables = renameVar;
		parser = Parser:new({
			LuaVersion = luaVersion;
		});
		unparser = Unparser:new({
			LuaVersion = luaVersion;
			PrettyPrint = prettyPrint;
			Highlight = settings.Highlight;
		});
		namegenerator = Pipeline.NameGenerators.MangledShuffled;
		conventions = conventions;
		steps = {};
	}
	
	setmetatable(pipeline, self);
	self.__index = self;
	
	return pipeline;
end

function Pipeline:fromConfig(config)
	config = config or {};
	local pipeline = Pipeline:new({
		LuaVersion    = config.LuaVersion or LuaVersion.Lua53;
		PrettyPrint   = config.PrettyPrint or false;
		VarNamePrefix = config.VarNamePrefix or "";
		Seed          = config.Seed or 0;
		RenameVariables = config.RenameVariables;
	});

	pipeline:setNameGenerator(config.NameGenerator or "MangledShuffled")

	-- Add all Steps defined in Config
	local steps = config.Steps or {};
	for i, step in ipairs(steps) do
		if type(step.Name) ~= "string" then
			logger:error("Step.Name must be a String");
		end
		local constructor = pipeline.Steps[step.Name];
		if not constructor then
			logger:error(string.format("The Step \"%s\" was not found!", step.Name));
		end
		pipeline:addStep(constructor:new(step.Settings or {}));
	end

	return pipeline;
end

function Pipeline:addStep(step)
	table.insert(self.steps, step);
end

function Pipeline:resetSteps(step)
	self.steps = {};
end

function Pipeline:getSteps()
	return self.steps;
end

function Pipeline:setOption(name, value)
	assert(false, "TODO");
	if(Pipeline.DefaultSettings[name] ~= nil) then
		
	else
		logger:error(string.format("\"%s\" is not a valid setting"));
	end
end

function Pipeline:setLuaVersion(luaVersion)
	local conventions = Enums.Conventions[luaVersion];
	if(not conventions) then
		logger:error("The Lua Version \"" .. luaVersion 
			.. "\" is not recognised by the Tokenizer! Please use one of the following: \"" .. table.concat(util.keys(Enums.Conventions), "\",\"") .. "\"");
	end
	
	self.parser = Parser:new({
		luaVersion = luaVersion;
	});
	self.unparser = Unparser:new({
		luaVersion = luaVersion;
	});
	self.conventions = conventions;
end

function Pipeline:getLuaVersion()
	return self.luaVersion;
end

function Pipeline:setNameGenerator(nameGenerator)
	if(type(nameGenerator) == "string") then
		nameGenerator = Pipeline.NameGenerators[nameGenerator];
	end
	
	if(type(nameGenerator) == "function" or type(nameGenerator) == "table") then
		self.namegenerator = nameGenerator;
		return;
	else
		logger:error("The Argument to Pipeline:setNameGenerator must be a valid NameGenerator function or function name e.g: \"mangled\"")
	end
end

function Pipeline:apply(code, filename)
	local startTime = gettime();
	filename = filename or "Anonymus Script";
	logger:info(string.format("Applying Obfuscation Pipeline to %s ...", filename));
	-- Seed the Random Generator
	if(self.Seed > 0) then
		math.randomseed(self.Seed);
	else
		math.randomseed(os.time())
	end
	
	logger:info("Parsing ...");
	local parserStartTime = gettime();

	local sourceLen = string.len(code);
	local ast = self.parser:parse(code);

	local parserTimeDiff = gettime() - parserStartTime;
	logger:info(string.format("Parsing Done in %.2f seconds", parserTimeDiff));
	
	-- User Defined Steps
	for i, step in ipairs(self.steps) do
		local stepStartTime = gettime();
		logger:info(string.format("Applying Step \"%s\" ...", step.Name or "Unnamed"));
		local newAst = step:apply(ast, self);
		if type(newAst) == "table" then
			ast = newAst;
		end
		logger:info(string.format("Step \"%s\" Done in %.2f seconds", step.Name or "Unnamed", gettime() - stepStartTime));
	end
	
	-- Rename Variables Step
	if self.RenameVariables then
	    self:renameVariables(ast);
	end
	
	code = self:unparse(ast);
	
	local timeDiff = gettime() - startTime;
	logger:info(string.format("Obfuscation Done in %.2f seconds", timeDiff));
	
	logger:info(string.format("Generated Code size is %.2f%% of the Source Code size", (string.len(code) / sourceLen)*100))
	
	return code;
end

function Pipeline:unparse(ast)
	local startTime = gettime();
	logger:info("Generating Code ...");
	
	local unparsed = self.unparser:unparse(ast);
	
	local timeDiff = gettime() - startTime;
	logger:info(string.format("Code Generation Done in %.2f seconds", timeDiff));
	
	return unparsed;
end

function Pipeline:renameVariables(ast)
	local startTime = gettime();
	logger:info("Renaming Variables ...");
	
	
	local generatorFunction = self.namegenerator or Pipeline.NameGenerators.mangled;
	if(type(generatorFunction) == "table") then
		if (type(generatorFunction.prepare) == "function") then
			generatorFunction.prepare(ast);
		end
		generatorFunction = generatorFunction.generateName;
	end
	
	if not self.unparser:isValidIdentifier(self.VarNamePrefix) and #self.VarNamePrefix ~= 0 then
		logger:error(string.format("The Prefix \"%s\" is not a valid Identifier in %s", self.VarNamePrefix, self.LuaVersion));
	end

	local globalScope = ast.globalScope;
	globalScope:renameVariables({
		Keywords = self.conventions.Keywords;
		generateName = generatorFunction;
		prefix = self.VarNamePrefix;
	});
	
	local timeDiff = gettime() - startTime;
	logger:info(string.format("Renaming Done in %.2f seconds", timeDiff));
end

setmetatable(Pipeline, {
    __call = Pipeline.new,
})


return Pipeline;

end;modules['config'] = function()

local NAME    = "obfLT9";
local REVISION = "Alpha";
local VERSION = "v0.1";
local BY      = "LeThi9GG";

-- Config Starts here
return {
	Name = NAME,
	NameUpper = string.upper(NAME),
	NameAndVersion = string.format("%s %s", NAME, VERSION),
	Version = VERSION;
	Revision = REVISION;
	IdentPrefix = "__lethi9gg_";
	SPACE = " "; -- Khoảng trắng được sử dụng bởi trình giải phân tích cú pháp
	TAB   = "\t"; -- Tab Khoảng trắng được sử dụng bởi trình giải mã để in đẹp
}
end;modules['obfLT9.ast'] = function()
local Ast = {}

local AstKind = {
	-- Misc
	TopNode = "TopNode";
	Block = "Block";

	-- Stats
	ContinueStat = "ContinueStat";
	BreakStat = "BreakStat";
	
	GotoStat = "GotoStat";
	LabelStat = "LabelStat";
	
	DoStat = "DoStat";
	WhileStat = "WhileStat";
	ReturnStat = "ReturnStat";
	RepeatStat = "RepeatStat";
	ForInStat = "ForInStat";
	ForStat = "ForStat";
	IfStat = "IfStat";
	FunctionDecl = "FunctionDecl";
	LocalFunctionDecl = "LocalFunctionDecl";
	LocalVariableDecl = "LocalVariableDecl";
	FunctionCallStat = "FunctionCallStat";
	PassSelfFunctionCallStat = "PassSelfFunctionCallStat";
	AssiStat = "AssiStat";

	-- LuaU Compound Stats
	CompoundAddStat = "CompoundAddStat";
	CompoundSubStat = "CompoundSubStat";
	CompoundMulStat = "CompoundMulStat";
	CompoundDivStat = "CompoundDivStat";
	CompoundModStat = "CompoundModStat";
	CompoundPowStat = "CompoundPowStat";
	CompoundConcatStat = "CompoundConcatStat";

	-- Assi Index
	AssiIndexing = "AssiIndexing";
	AssiVariable = "AssiVariable";  

	-- Expr Nodes
	BooleanExpr = "BooleanExpr";
	NumberExpr = "NumberExpr";
	StringExpr = "StringExpr";
	NilExpr = "NilExpr";
	VarargExpr = "VarargExpr";
	OrExpr = "OrExpr";
	AndExpr = "AndExpr";
	LessThanExpr = "LessThanExpr";
	GreaterThanExpr = "GreaterThanExpr";
	LessThanOrEqualsExpr = "LessThanOrEqualsExpr";
	GreaterThanOrEqualsExpr = "GreaterThanOrEqualsExpr";
	NotEqualsExpr = "NotEqualsExpr";
	EqualsExpr = "EqualsExpr";
	StrCatExpr = "StrCatExpr";
	AddExpr = "AddExpr";
	SubExpr = "SubExpr";
	MulExpr = "MulExpr";
	DivExpr = "DivExpr";
	ModExpr = "ModExpr";
	
	BandExpr = "BandExpr";
	BxorExpr = "BxorExpr";
	BorExpr = "BorExpr";
	ShlExpr = "ShlExpr";
	ShrExpr = "ShrExpr";
	IdivExpr = "IdivExpr";
	
	BnotExpr = "BnotExpr";
	
	NotExpr = "NotExpr";
	LenExpr = "LenExpr";
	NegateExpr = "NegateExpr";
	PowExpr = "PowExpr";
	IndexExpr = "IndexExpr";
	FunctionCallExpr = "FunctionCallExpr";
	PassSelfFunctionCallExpr = "PassSelfFunctionCallExpr";
	VariableExpr = "VariableExpr";
	FunctionLiteralExpr = "FunctionLiteralExpr";
	TableConstructorExpr = "TableConstructorExpr";

	-- Table Entry
	TableEntry = "TableEntry";
	KeyedTableEntry = "KeyedTableEntry";

	-- Misc
	NopStat = "NopStat";
}

local astKindExprLookup = {
	[AstKind.BooleanExpr] = 0;
	[AstKind.NumberExpr] = 0;
	[AstKind.StringExpr] = 0;
	[AstKind.NilExpr] = 0;
	[AstKind.VarargExpr] = 0;
	[AstKind.OrExpr] = 12;
	[AstKind.AndExpr] = 11;
	[AstKind.LessThanExpr] = 10;
	[AstKind.GreaterThanExpr] = 10;
	[AstKind.LessThanOrEqualsExpr] = 10;
	[AstKind.GreaterThanOrEqualsExpr] = 10;
	[AstKind.NotEqualsExpr] = 10;
	[AstKind.EqualsExpr] = 10;
	[AstKind.StrCatExpr] = 9;
	[AstKind.AddExpr] = 8;
	[AstKind.SubExpr] = 8;
	[AstKind.MulExpr] = 7;
	[AstKind.DivExpr] = 7;
	[AstKind.ModExpr] = 7;
	
	[AstKind.BandExpr] = 7;
	[AstKind.BxorExpr] = 7;
	[AstKind.BorExpr] = 7;
	[AstKind.ShlExpr] = 7;
	[AstKind.ShrExpr] = 7;
	[AstKind.IdivExpr] = 7;
	
	[AstKind.BnotExpr] = 5;
	[AstKind.NotExpr] = 5;
	[AstKind.LenExpr] = 5;
	[AstKind.NegateExpr] = 5;
	[AstKind.PowExpr] = 4;
	[AstKind.IndexExpr] = 1;
	[AstKind.AssiIndexing] = 1;
	[AstKind.FunctionCallExpr] = 2;
	[AstKind.PassSelfFunctionCallExpr] = 2;
	[AstKind.VariableExpr] = 0;
	[AstKind.AssiVariable] = 0;
	[AstKind.FunctionLiteralExpr] = 3;
	[AstKind.TableConstructorExpr] = 3;
}

Ast.AstKind = AstKind;


function Ast.astKindExprToNumber(kind)
	return astKindExprLookup[kind] or 100;
end

function Ast.ConstantNode(val)
	if type(val) == "nil" then
		return Ast.NilExpr();
	end

	if type(val) == "string" then
		return Ast.StringExpr(val);
	end

	if type(val) == "number" then
		return Ast.NumberExpr(val);
	end

	if type(val) == "boolean" then
		return Ast.BooleanExpr(val);
	end
end



function Ast.NopStat()
	return {
		kind = AstKind.NopStat;
	}
end

-- Create Ast Top Node
function Ast.TopNode(body, globalScope)
	return {
		kind = AstKind.TopNode,
		body = body,
		globalScope = globalScope,

	}
end

function Ast.TableEntry(value)
	return {
		kind = AstKind.TableEntry,
		value = value,

	}
end

function Ast.KeyedTableEntry(key, value)
	return {
		kind = AstKind.KeyedTableEntry,
		key = key,
		value = value,

	}
end

function Ast.TableConstructorExpr(entries)
	return {
		kind = AstKind.TableConstructorExpr,
		entries = entries,
	};
end

-- Create Stat Block
function Ast.Block(stats, scope)
	return {
		kind = AstKind.Block,
		stats = stats,
		scope = scope,
	}
end

-- Create Break Stat
function Ast.BreakStat(loop, scope)
	return {
		kind = AstKind.BreakStat,
		loop = loop,
		scope = scope,
	}
end


-- Cấu trúc cho GotoStat
function Ast.GotoStat(label, pos)
    return {
        kind = AstKind.GotoStat,
        label = label,
    }
end


-- Cấu trúc cho LabelStat
function Ast.LabelStat(label, pos, scope)
    return {
        kind = AstKind.LabelStat,
        pos = pos,
		scope = scope,
        label = label,
    }
end


-- Create Continue Stat
function Ast.ContinueStat(loop, scope)
	return {
		kind = AstKind.ContinueStat,
		loop = loop,
		scope = scope,
	}
end

function Ast.PassSelfFunctionCallStat(base, passSelfFunctionName, args)
	return {
		kind = AstKind.PassSelfFunctionCallStat,
		base = base,
		passSelfFunctionName = passSelfFunctionName,
		args = args,
	}
end

function Ast.AssiStat(lhs, rhs)
	if(#lhs < 1) then
		print(debug.traceback());
		error("Something went wrong!");
	end
	return {
		kind = AstKind.AssiStat,
		lhs = lhs,
		rhs = rhs,
	}
end

function Ast.CompoundAddStat(lhs, rhs)
	return {
		kind = AstKind.CompoundAddStat,
		lhs = lhs,
		rhs = rhs,
	}
end

function Ast.CompoundSubStat(lhs, rhs)
	return {
		kind = AstKind.CompoundSubStat,
		lhs = lhs,
		rhs = rhs,
	}
end

function Ast.CompoundMulStat(lhs, rhs)
	return {
		kind = AstKind.CompoundMulStat,
		lhs = lhs,
		rhs = rhs,
	}
end

function Ast.CompoundDivStat(lhs, rhs)
	return {
		kind = AstKind.CompoundDivStat,
		lhs = lhs,
		rhs = rhs,
	}
end

function Ast.CompoundPowStat(lhs, rhs)
	return {
		kind = AstKind.CompoundPowStat,
		lhs = lhs,
		rhs = rhs,
	}
end

function Ast.CompoundModStat(lhs, rhs)
	return {
		kind = AstKind.CompoundModStat,
		lhs = lhs,
		rhs = rhs,
	}
end

function Ast.CompoundConcatStat(lhs, rhs)
	return {
		kind = AstKind.CompoundConcatStat,
		lhs = lhs,
		rhs = rhs,
	}
end

function Ast.FunctionCallStat(base, args)
	return {
		kind = AstKind.FunctionCallStat,
		base = base,
		args = args,
	}
end

function Ast.ReturnStat(args)
	return {
		kind = AstKind.ReturnStat,
		args = args,
	}
end

function Ast.DoStat(body)
	return {
		kind = AstKind.DoStat,
		body = body,
	}
end

function Ast.WhileStat(body, condition, parentScope)
	return {
		kind = AstKind.WhileStat,
		body = body,
		condition = condition,
		parentScope = parentScope,
	}
end

function Ast.ForInStat(scope, vars, exps, body, parentScope)
	return {
		kind = AstKind.ForInStat,
		scope = scope,
		ids = vars,
		vars = vars,
		exps = exps,
		body = body,
		parentScope = parentScope,
	}
end

function Ast.ForStat(scope, id, initialValue, finalValue, incrementBy, body, parentScope)
	return {
		kind = AstKind.ForStat,
		scope = scope,
		id = id,
		initialValue = initialValue,
		finalValue = finalValue,
		incrementBy = incrementBy,
		body = body,
		parentScope = parentScope,
	}
end

function Ast.RepeatStat(condition, body, parentScope)
	return {
		kind = AstKind.RepeatStat,
		body = body,
		condition = condition,
		parentScope = parentScope,
	}
end

function Ast.IfStat(condition, body, elseifs, elsebody)
	return {
		kind = AstKind.IfStat,
		condition = condition,
		body = body,
		elseifs = elseifs,
		elsebody = elsebody,
	}
end

function Ast.FunctionDecl(scope, id, indices, args, body)
	return {
		kind = AstKind.FunctionDecl,
		scope = scope,
		baseScope = scope,
		id = id,
		baseId = id,
		indices = indices,
		args = args,
		body = body,
		--[[getName = function(self)
			return self.scope:getVariableName(self.id);
		end,]]
	}
end

function Ast.LocalFunctionDecl(scope, id, args, body)
	return {
		kind = AstKind.LocalFunctionDecl,
		scope = scope,
		id = id,
		args = args,
		body = body,
		--[[getName = function(self)
			return self.scope:getVariableName(self.id);
		end,]]
	}
end

function Ast.LocalVariableDecl(scope, ids, exps)
	return {
		kind = AstKind.LocalVariableDecl,
		scope = scope,
		ids = ids,
		exps = exps,
	}
end

function Ast.VarargExpr()
	return {
		kind = AstKind.VarargExpr;
		isConstant = false,
	}
end

function Ast.BooleanExpr(value)
	return {
		kind = AstKind.BooleanExpr,
		isConstant = true,
		value = value,
	}
end

function Ast.NilExpr()
	return {
		kind = AstKind.NilExpr,
		isConstant = true,
		value = nil,
	}
end

function Ast.NumberExpr(value)
	return {
		kind = AstKind.NumberExpr,
		isConstant = true,
		value = value,
	}
end

function Ast.StringExpr(value)
	return {
		kind = AstKind.StringExpr,
		isConstant = true,
		value = value,
	}
end

function Ast.OrExpr(lhs, rhs, simplify)
	if(simplify and rhs.isConstant and lhs.isConstant) then
		local success, val = pcall(function() return lhs.value or rhs.value end);
		if success then
			return Ast.ConstantNode(val);
		end
	end

	return {
		kind = AstKind.OrExpr,
		lhs = lhs,
		rhs = rhs,
		isConstant = false,
	}
end

function Ast.AndExpr(lhs, rhs, simplify)
	if(simplify and rhs.isConstant and lhs.isConstant) then
		local success, val = pcall(function() return lhs.value and rhs.value end);
		if success then
			return Ast.ConstantNode(val);
		end
	end

	return {
		kind = AstKind.AndExpr,
		lhs = lhs,
		rhs = rhs,
		isConstant = false,
	}
end

function Ast.LessThanExpr(lhs, rhs, simplify)
	if(simplify and rhs.isConstant and lhs.isConstant) then
		local success, val = pcall(function() return lhs.value < rhs.value end);
		if success then
			return Ast.ConstantNode(val);
		end
	end

	return {
		kind = AstKind.LessThanExpr,
		lhs = lhs,
		rhs = rhs,
		isConstant = false,
	}
end

function Ast.GreaterThanExpr(lhs, rhs, simplify)
	if(simplify and rhs.isConstant and lhs.isConstant) then
		local success, val = pcall(function() return lhs.value > rhs.value end);
		if success then
			return Ast.ConstantNode(val);
		end
	end

	return {
		kind = AstKind.GreaterThanExpr,
		lhs = lhs,
		rhs = rhs,
		isConstant = false,
	}
end

function Ast.LessThanOrEqualsExpr(lhs, rhs, simplify)
	if(simplify and rhs.isConstant and lhs.isConstant) then
		local success, val = pcall(function() return lhs.value <= rhs.value end);
		if success then
			return Ast.ConstantNode(val);
		end
	end

	return {
		kind = AstKind.LessThanOrEqualsExpr,
		lhs = lhs,
		rhs = rhs,
		isConstant = false,
	}
end

function Ast.GreaterThanOrEqualsExpr(lhs, rhs, simplify)
	if(simplify and rhs.isConstant and lhs.isConstant) then
		local success, val = pcall(function() return lhs.value >= rhs.value end);
		if success then
			return Ast.ConstantNode(val);
		end
	end

	return {
		kind = AstKind.GreaterThanOrEqualsExpr,
		lhs = lhs,
		rhs = rhs,
		isConstant = false,
	}
end

function Ast.NotEqualsExpr(lhs, rhs, simplify)
	if(simplify and rhs.isConstant and lhs.isConstant) then
		local success, val = pcall(function() return lhs.value ~= rhs.value end);
		if success then
			return Ast.ConstantNode(val);
		end
	end

	return {
		kind = AstKind.NotEqualsExpr,
		lhs = lhs,
		rhs = rhs,
		isConstant = false,
	}
end

function Ast.EqualsExpr(lhs, rhs, simplify)
	if(simplify and rhs.isConstant and lhs.isConstant) then
		local success, val = pcall(function() return lhs.value == rhs.value end);
		if success then
			return Ast.ConstantNode(val);
		end
	end

	return {
		kind = AstKind.EqualsExpr,
		lhs = lhs,
		rhs = rhs,
		isConstant = false,
	}
end

function Ast.StrCatExpr(lhs, rhs, simplify)
	if(simplify and rhs.isConstant and lhs.isConstant) then
		local success, val = pcall(function() return lhs.value .. rhs.value end);
		if success then
			return Ast.ConstantNode(val);
		end
	end

	return {
		kind = AstKind.StrCatExpr,
		lhs = lhs,
		rhs = rhs,
		isConstant = false,
	}
end

function Ast.AddExpr(lhs, rhs, simplify)
	if(simplify and rhs.isConstant and lhs.isConstant) then
		local success, val = pcall(function() return lhs.value + rhs.value end);
		if success then
			return Ast.ConstantNode(val);
		end
	end

	return {
		kind = AstKind.AddExpr,
		lhs = lhs,
		rhs = rhs,
		isConstant = false,
	}
end

function Ast.SubExpr(lhs, rhs, simplify)
	if(simplify and rhs.isConstant and lhs.isConstant) then
		local success, val = pcall(function() return lhs.value - rhs.value end);
		if success then
			return Ast.ConstantNode(val);
		end
	end

	return {
		kind = AstKind.SubExpr,
		lhs = lhs,
		rhs = rhs,
		isConstant = false,
	}
end

function Ast.MulExpr(lhs, rhs, simplify)
	if(simplify and rhs.isConstant and lhs.isConstant) then
		local success, val = pcall(function() return lhs.value * rhs.value end);
		if success then
			return Ast.ConstantNode(val);
		end
	end

	return {
		kind = AstKind.MulExpr,
		lhs = lhs,
		rhs = rhs,
		isConstant = false,
	}
end

function Ast.DivExpr(lhs, rhs, simplify)
	if(simplify and rhs.isConstant and lhs.isConstant and rhs.value ~= 0) then
		local success, val = pcall(function() return lhs.value / rhs.value end);
		if success then
			return Ast.ConstantNode(val);
		end
	end

	return {
		kind = AstKind.DivExpr,
		lhs = lhs,
		rhs = rhs,
		isConstant = false,
	}
end

function Ast.ModExpr(lhs, rhs, simplify)
	if(simplify and rhs.isConstant and lhs.isConstant) then
		local success, val = pcall(function() return lhs.value % rhs.value end);
		if success then
			return Ast.ConstantNode(val);
		end
	end

	return {
		kind = AstKind.ModExpr,
		lhs = lhs,
		rhs = rhs,
		isConstant = false,
	}
end

--5.3
function Ast.BandExpr(lhs, rhs, simplify)
	if(simplify and rhs.isConstant and lhs.isConstant and rhs.value ~= 0) then
		local success, val = pcall(function() return lhs.value & rhs.value end);
		if success then
			return Ast.ConstantNode(val);
		end
	end
	return {
		kind = AstKind.BandExpr,
		lhs = lhs,
		rhs = rhs,
		isConstant = false,
	}
end

function Ast.BxorExpr(lhs, rhs, simplify)
	if(simplify and rhs.isConstant and lhs.isConstant and rhs.value ~= 0) then
		local success, val = pcall(function() return lhs.value ~ rhs.value end);
		if success then
			return Ast.ConstantNode(val);
		end
	end
	return {
		kind = AstKind.BxorExpr,
		lhs = lhs,
		rhs = rhs,
		isConstant = false,
	}
end

function Ast.BorExpr(lhs, rhs, simplify)
	if(simplify and rhs.isConstant and lhs.isConstant and rhs.value ~= 0) then
		local success, val = pcall(function() return lhs.value | rhs.value end);
		if success then
			return Ast.ConstantNode(val);
		end
	end
	return {
		kind = AstKind.BorExpr,
		lhs = lhs,
		rhs = rhs,
		isConstant = false,
	}
end

function Ast.ShlExpr(lhs, rhs, simplify)
	if(simplify and rhs.isConstant and lhs.isConstant and rhs.value ~= 0) then
		local success, val = pcall(function() return lhs.value << rhs.value end);
		if success then
			return Ast.ConstantNode(val);
		end
	end
	return {
		kind = AstKind.ShlExpr,
		lhs = lhs,
		rhs = rhs,
		isConstant = false,
	}
end

function Ast.ShrExpr(lhs, rhs, simplify)
	if(simplify and rhs.isConstant and lhs.isConstant and rhs.value ~= 0) then
		local success, val = pcall(function() return lhs.value >> rhs.value end);
		if success then
			return Ast.ConstantNode(val);
		end
	end
	return {
		kind = AstKind.ShrExpr,
		lhs = lhs,
		rhs = rhs,
		isConstant = false,
	}
end

function Ast.IdivExpr(lhs, rhs, simplify)
	if(simplify and rhs.isConstant and lhs.isConstant and rhs.value ~= 0) then
		local success, val = pcall(function() return lhs.value // rhs.value end);
		if success then
			return Ast.ConstantNode(val);
		end
	end
	return {
		kind = AstKind.IdivExpr,
		lhs = lhs,
		rhs = rhs,
		isConstant = false,
	}
end

function Ast.BnotExpr(rhs, simplify)
	if(simplify and rhs.isConstant) then
		local success, val = pcall(function() return ~rhs.value end);
		if success then
			return Ast.ConstantNode(val);
		end
	end

	return {
		kind = AstKind.BnotExpr,
		rhs = rhs,
		isConstant = false,
	}
end

function Ast.NotExpr(rhs, simplify)
	if(simplify and rhs.isConstant) then
		local success, val = pcall(function() return not rhs.value end);
		if success then
			return Ast.ConstantNode(val);
		end
	end

	return {
		kind = AstKind.NotExpr,
		rhs = rhs,
		isConstant = false,
	}
end

function Ast.NegateExpr(rhs, simplify)
	if(simplify and rhs.isConstant) then
		local success, val = pcall(function() return -rhs.value end);
		if success then
			return Ast.ConstantNode(val);
		end
	end

	return {
		kind = AstKind.NegateExpr,
		rhs = rhs,
		isConstant = false,
	}
end

function Ast.LenExpr(rhs, simplify)
	if(simplify and rhs.isConstant) then
		local success, val = pcall(function() return #rhs.value end);
		if success then
			return Ast.ConstantNode(val);
		end
	end

	return {
		kind = AstKind.LenExpr,
		rhs = rhs,
		isConstant = false,
	}
end

function Ast.PowExpr(lhs, rhs, simplify)
	if(simplify and rhs.isConstant and lhs.isConstant) then
		local success, val = pcall(function() return lhs.value ^ rhs.value end);
		if success then
			return Ast.ConstantNode(val);
		end
	end

	return {
		kind = AstKind.PowExpr,
		lhs = lhs,
		rhs = rhs,
		isConstant = false,
	}
end

function Ast.IndexExpr(base, index)
	return {
		kind = AstKind.IndexExpr,
		base = base,
		index = index,
		isConstant = false,
	}
end

function Ast.AssiIndexing(base, index)
	return {
		kind = AstKind.AssiIndexing,
		base = base,
		index = index,
		isConstant = false,
	}
end

function Ast.PassSelfFunctionCallExpr(base, passSelfFunctionName, args)
	return {
		kind = AstKind.PassSelfFunctionCallExpr,
		base = base,
		passSelfFunctionName = passSelfFunctionName,
		args = args,

	}
end

function Ast.FunctionCallExpr(base, args)
	return {
		kind = AstKind.FunctionCallExpr,
		base = base,
		args = args,
	}
end

function Ast.VariableExpr(scope, id)
	scope:addReference(id);
	return {
		kind = AstKind.VariableExpr, 
		scope = scope,
		id = id,
		--[[getName = function(self)
			return self.scope.getVariableName(self.id);
		end,]]
	}
end

function Ast.AssiVariable(scope, id)
	scope:addReference(id);
	return {
		kind = AstKind.AssiVariable, 
		scope = scope,
		id = id,
		--[[getName = function(self)
			return self.scope.getVariableName(self.id);
		end,]]
	}
end

function Ast.FunctionLiteralExpr(args, body)
	return {
		kind = AstKind.FunctionLiteralExpr,
		args = args,
		body = body,
	}
end
--[[
function AstNode(args)
    if type(args) ~= "table" then
        return args
    end
    return setmetatable(args, {__name = args.kind})
end
if not __AstNode then
    for i, v in pairs(Ast) do
        if type(v) == "function" then
            Ast[i] = function(...) return AstNode(v(...)) end
        end
    end
__AstNode = true
end
]]
return Ast;
end;modules['obfLT9.enums'] = function()
local Enums = {};

local chararray = require("obfLT9.util").chararray;

Enums.LuaVersion = {
	LuaU  = "LuaU" ,
	Lua51 = "Lua51",
	Lua53 = "Lua53",
}

Enums.Conventions = {
	[Enums.LuaVersion.Lua51] = {
		Keywords = {
			"and",    "break",  "do",    "else",     "elseif", 
			"end",    "false",  "for",   "function", "if",   
			"in",     "local",  "nil",   "not",      "or",
			"repeat", "return", "then",  "true",     "until",    "while"
		},
		
		SymbolChars = chararray("+-*/%^#=~<>(){}[];:,."),
		MaxSymbolLength = 3,
		Symbols = {
			"+",  "-",  "*",  "/",  "%",  "^",  "#",
			"==", "~=", "<=", ">=", "<",  ">",  "=",
			"(",  ")",  "{",  "}",  "[",  "]",
			";",  ":",  ",",  ".",  "..", "...",
		},

		IdentChars          = chararray("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789"),
		NumberChars         = chararray("0123456789"),
		HexNumberChars      = chararray("0123456789abcdefABCDEF"),
		BinaryNumberChars   = {"0", "1"},
		DecimalExponent     = {"e", "E"},
		HexadecimalNums     = {"x", "X"},
		BinaryNums          = {"b", "B"},
		DecimalSeperators   = false,
		
		EscapeSequences     = {
			["a"] = "\a";
			["b"] = "\b";
			["f"] = "\f";
			["n"] = "\n";
			["r"] = "\r";
			["t"] = "\t";
			["v"] = "\v";
			["\\"] = "\\";
			["\""] = "\"";
			["\'"] = "\'";
		},
		NumericalEscapes = true,
		EscapeZIgnoreNextWhitespace = true,
		HexEscapes = true,
		UnicodeEscapes = true,
	},
	
	[Enums.LuaVersion.Lua53] = {
		Keywords = {
			"and",    "break",  "do",    "else",     "elseif", 
			"end",    "false",  "for",   "function", "if",   
			"in",     "local",  "nil",   "not",      "or",
			"repeat", "return", "then",  "true",     "until",    "while",
			"goto",
		},
		
		SymbolChars = chararray("+-*/%&|^#=~<>(){}[];:,."),
		MaxSymbolLength = 3,
		Symbols = {
			"+",  "-",  "*",  "/",  "%",  "^",  "#",
			"==", "~=", "<=", ">=", "<",  ">",  "=",
			"&", "~", "|", "<<", ">>", "//", "::",
			"(",  ")",  "{",  "}",  "[",  "]",
			";",  ":",  ",",  ".",  "..", "...",
		},

		IdentChars          = chararray("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789"),
		NumberChars         = chararray("0123456789"),
		HexNumberChars      = chararray("0123456789abcdefABCDEF"),
		BinaryNumberChars   = {"0", "1"},
		DecimalExponent     = {"e", "E"},
		HexadecimalNums     = {"x", "X"},
		BinaryNums          = {"b", "B"},
		DecimalSeperators   = false,
		
		EscapeSequences     = {
			["a"] = "\a";
			["b"] = "\b";
			["f"] = "\f";
			["n"] = "\n";
			["r"] = "\r";
			["t"] = "\t";
			["v"] = "\v";
			["\\"] = "\\";
			["\""] = "\"";
			["\'"] = "\'";
		},
		NumericalEscapes = true,
		EscapeZIgnoreNextWhitespace = true,
		HexEscapes = true,
		UnicodeEscapes = true,
	},
	
	[Enums.LuaVersion.LuaU] = {
		Keywords = {
			"and",    "break",  "do",    "else",     "elseif", "continue",
			"end",    "false",  "for",   "function", "if",   
			"in",     "local",  "nil",   "not",      "or",
			"repeat", "return", "then",  "true",     "until",    "while"
		},
		
		SymbolChars = chararray("+-*/%^#=~<>(){}[];:,."),
		MaxSymbolLength = 3,
		Symbols = {
			"+",  "-",  "*",  "/",  "%",  "^",  "#",
			"==", "~=", "<=", ">=", "<",  ">",  "=",
			"+=", "-=", "/=", "%=", "^=", "..=", "*=",
			"(",  ")",  "{",  "}",  "[",  "]",
			";",  ":",  ",",  ".",  "..", "...",
			"::", "->", "?",  "|",  "&", 
		},

		IdentChars          = chararray("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789"),
		NumberChars         = chararray("0123456789"),
		HexNumberChars      = chararray("0123456789abcdefABCDEF"),
		BinaryNumberChars   = {"0", "1"},
		DecimalExponent     = {"e", "E"},
		HexadecimalNums     = {"x", "X"},
		BinaryNums          = {"b", "B"},
		DecimalSeperators   = {"_"},
		
		EscapeSequences     = {
			["a"] = "\a";
			["b"] = "\b";
			["f"] = "\f";
			["n"] = "\n";
			["r"] = "\r";
			["t"] = "\t";
			["v"] = "\v";
			["\\"] = "\\";
			["\""] = "\"";
			["\'"] = "\'";
		},
		NumericalEscapes = true,
		EscapeZIgnoreNextWhitespace = true,
		HexEscapes = true,
		UnicodeEscapes = true,
	},
}

return Enums;

end;modules['obfLT9.util'] = function()
local logger = require("logger");
--local bit32  = require("obfLT9.bit").bit32;

local MAX_UNPACK_COUNT = 195;

local function lookupify(tb)
	local tb2 = {};
	for _, v in ipairs(tb) do
		tb2[v] = true
	end
	return tb2
end

local function unlookupify(tb)
	local tb2 = {};
	for v, _ in pairs(tb) do
		table.insert(tb2, v);
	end
	return tb2;
end

local function escape(str)
	return str:gsub(".", function(char)
		if char:match("[^ %-~\n\t\a\b\v\r\"\']") then -- Check if non Printable ASCII Character
			return char:gsub("\\", "\\\\")--string.format("\\%03d", string.byte(char))
		end
		if(char == "\\") then
			return "\\\\";
		end
		if(char == "\n") then
			return "\\n";
		end
		if(char == "\r") then
			return "\\r";
		end
		if(char == "\t") then
			return "\\t";
		end
		if(char == "\a") then
			return "\\a";
		end
		if(char == "\b") then
			return "\\b";
		end
		if(char == "\v") then
			return "\\v";
		end
		if(char == "\"") then
			return "\\\"";
		end
		if(char == "\'") then
			return "\\\'";
		end
		return char;
	end)
end

local function chararray(str)
	local tb = {};
	for i = 1, str:len(), 1 do
		table.insert(tb, str:sub(i, i));
	end
	return tb;
end

local function keys(tb)
	local keyset={}
	local n=0
	for k,v in pairs(tb) do
		n=n+1
		keyset[n]=k
	end
	return keyset
end

local utf8char;
do
	local string_char = string.char
	function utf8char(cp)
	  if cp < 128 then
		return string_char(cp)
	  end
	  local suffix = cp % 64
	  local c4 = 128 + suffix
	  cp = (cp - suffix) / 64
	  if cp < 32 then
		return string_char(192 + cp, c4)
	  end
	  suffix = cp % 64
	  local c3 = 128 + suffix
	  cp = (cp - suffix) / 64
	  if cp < 16 then
		return string_char(224 + cp, c3, c4)
	  end
	  suffix = cp % 64
	  cp = (cp - suffix) / 64
	  return string_char(240 + cp, 128 + suffix, c3, c4)
	end
  end

local function shuffle(tb)
	for i = #tb, 2, -1 do
		local j = math.random(i)
		tb[i], tb[j] = tb[j], tb[i]
	end
	return tb
end
local function shuffle_string(str)
    local len = #str
    local t = {}
    for i = 1, len do
        t[i] = string.sub(str, i, i)
    end
    for i = 1, len do
        local j = math.random(i, len)
        t[i], t[j] = t[j], t[i]
    end
    return table.concat(t)
end

local function readDouble(bytes) 
	local sign = 1
	local mantissa = bytes[2] % 2^4
	for i = 3, 8 do
		mantissa = mantissa * 256 + bytes[i]
	end
	if bytes[1] > 127 then sign = -1 end
	local exponent = (bytes[1] % 128) * 2^4 + math.floor(bytes[2] / 2^4)

	if exponent == 0 then
		return 0
	end
	mantissa = (math.ldexp(mantissa, -52) + 1) * sign
	return math.ldexp(mantissa, exponent - 1023)
end

local function writeDouble(num)
	local bytes = {0,0,0,0, 0,0,0,0}
	if num == 0 then
		return bytes
	end
	local anum = math.abs(num)

	local mantissa, exponent = math.frexp(anum)
	exponent = exponent - 1
	mantissa = mantissa * 2 - 1
	local sign = num ~= anum and 128 or 0
	exponent = exponent + 1023

	bytes[1] = sign + math.floor(exponent / 2^4)
	mantissa = mantissa * 2^4
	local currentmantissa = math.floor(mantissa)
	mantissa = mantissa - currentmantissa
	bytes[2] = (exponent % 2^4) * 2^4 + currentmantissa
	for i= 3, 8 do
		mantissa = mantissa * 2^8
		currentmantissa = math.floor(mantissa)
		mantissa = mantissa - currentmantissa
		bytes[i] = currentmantissa
	end
	return bytes
end

local function writeU16(u16)
	if (u16 < 0 or u16 > 65535) then
		logger:error(string.format("u16 out of bounds: %d", u16));
	end
	local lower = bit32.band(u16, 255);
	local upper = bit32.rshift(u16, 8);
	return {lower, upper}
end

local function readU16(arr)
	return bit32.bor(arr[1], bit32.lshift(arr[2], 8));
end

local function writeU24(u24)
	if(u24 < 0 or u24 > 16777215) then
		logger:error(string.format("u24 out of bounds: %d", u24));
	end
	
	local arr = {};
	for i = 0, 2 do
		arr[i + 1] = bit32.band(bit32.rshift(u24, 8 * i), 255);
	end
	return arr;
end

local function readU24(arr)
	local val = 0;

	for i = 0, 2 do
		val = bit32.bor(val, bit32.lshift(arr[i + 1], 8 * i));
	end

	return val;
end

local function writeU32(u32)
	if(u32 < 0 or u32 > 4294967295) then
		logger:error(string.format("u32 out of bounds: %d", u32));
	end

	local arr = {};
	for i = 0, 3 do
		arr[i + 1] = bit32.band(bit32.rshift(u32, 8 * i), 255);
	end
	return arr;
end

local function readU32(arr)
	local val = 0;

	for i = 0, 3 do
		val = bit32.bor(val, bit32.lshift(arr[i + 1], 8 * i));
	end

	return val;
end

local function bytesToString(arr)
	local lenght = arr.n or #arr;

	if lenght < MAX_UNPACK_COUNT then
		return string.char(table.unpack(arr))
	end

	local str = "";
	local overflow = lenght % MAX_UNPACK_COUNT;

	for i = 1, (#arr - overflow) / MAX_UNPACK_COUNT do
		str = str .. string.char(table.unpack(arr, (i - 1) * MAX_UNPACK_COUNT + 1, i * MAX_UNPACK_COUNT));
	end

	return str..(overflow > 0 and string.char(table.unpack(arr, lenght - overflow + 1, lenght)) or "");
end

local function isNaN(n)
	return type(n) == "number" and n ~= n;
end

local function isInt(n)
	return math.floor(n) == n;
end

local function isU32(n)
	return n >= 0 and n <= 4294967295 and isInt(n);
end

local function toBits(num)
    -- returns a table of bits, least significant first.
    local t={} -- will contain the bits
	local rest;
    while num>0 do
        rest=math.fmod(num,2)
        t[#t+1]=rest
        num=(num-rest)/2
    end
    return t
end


local function readonly(obj)
	local r = newproxy(true);
	getmetatable(r).__index = obj;
	return r;
end

return {
	lookupify = lookupify,
	unlookupify = unlookupify,
	escape = escape,
	chararray = chararray,
	keys = keys,
	shuffle = shuffle,
	shuffle_string = shuffle_string,
	readDouble = readDouble,
	writeDouble = writeDouble,
	readU16 = readU16,
	writeU16 = writeU16,
	readU32 = readU32,
	writeU32 = writeU32,
	readU24 = readU24,
	writeU24 = writeU24,
	isNaN = isNaN,
	isU32 = isU32,
	isInt = isInt,
	utf8char = utf8char,
	toBits = toBits,
	bytesToString = bytesToString,
	readonly = readonly,
}

end;modules['logger'] = function()
local logger = {}
local config = require("config");
logger_results = {}

local pprint = function(...)
    print(...)
    gg.toast(...)
    logger_results[#logger_results+1] = (...)
end

local eerror = function(...)
    if gg.alert("\nError!\n\n" .. ... .. "\n\n", "ok", "copy") == 2 then
        gg.copyText(..., false)
    end
    error(...)
end

logger.LogLevel = {
	Error = 0,
	Warn = 1,
	Log = 2,
	Info = 2,
	Debug = 3,
}

logger.logLevel = logger.LogLevel.Log;

logger.debugCallback = function(...)
	pprint(config.NameUpper .. ": " ..  ...)
end;
function logger:debug(...)
	if self.logLevel >= self.LogLevel.Debug then
		self.debugCallback(...);
	end
end

logger.logCallback = function(...)
	pprint(config.NameUpper .. ": " .. ...);
end;
function logger:log(...)
	if self.logLevel >= self.LogLevel.Log then
		self.logCallback(...);
	end
end

function logger:info(...)
	if self.logLevel >= self.LogLevel.Log then
		self.logCallback(...);
	end
end

logger.warnCallback = function(...)
	pprint(config.NameUpper .. ": " .. ...)
end;
function logger:warn(...)
	if self.logLevel >= self.LogLevel.Warn then
		self.warnCallback(...);
	end
end

logger.errorCallback = function(...)
	pprint(config.NameUpper .. ": " .. ...)
	eerror(...);
end;
function logger:error(...)
	self.errorCallback(...);
	eerror(config.NameUpper .. ": logger.errorCallback did not throw an Error!");
end


return logger;
end;modules['obfLT9.parser'] = function()
local Tokenizer = require("obfLT9.tokenizer");
local Enums = require("obfLT9.enums");
local util = require("obfLT9.util");
local Ast = require("obfLT9.ast");
local Scope = require("obfLT9.scope");
local logger = require("logger");
--local tolua = require("tolua")

local AstKind = Ast.AstKind;

local LuaVersion = Enums.LuaVersion;
local lookupify = util.lookupify;
local unlookupify = util.unlookupify;
local escape = util.escape;
local chararray = util.chararray;
local keys = util.keys;

local TokenKind = Tokenizer.TokenKind;

local Parser = {};

local ASSIGNMENT_NO_WARN_LOOKUP = lookupify{
	AstKind.NilExpr,
	AstKind.FunctionCallExpr,
	AstKind.PassSelfFunctionCallExpr,
	AstKind.VarargExpr
};

local function generateError(self, message)
	local token;
	if(self.index > self.length) then
		token = self.tokens[self.length];
	elseif(self.index < 1) then
		return "Parsing Error at Position 0:0, " .. message;
	else
		token = self.tokens[self.index];
	end
	
	return "Parsing Error at Position " .. tostring(token.line) .. ":" .. tostring(token.linePos) .. ", " .. message;
end

local function generateWarning(token, message)
	return "Warning at Position " .. tostring(token.line) .. ":" .. tostring(token.linePos) .. ", " .. message;
end

function Parser:new(settings)
	local luaVersion = (settings and (settings.luaVersion or settings.LuaVersion)) or LuaVersion.Lua53;
	local parser = {
		luaVersion = luaVersion,
		tokenizer = Tokenizer:new({
			luaVersion = luaVersion
		}),
		tokens = {};
		length = 0;
		index = 0;
	};
	
	setmetatable(parser, self);
	self.__index = self;
	
	return parser;
end



--! Function to peek the n'th token
local function peek(self, n)
	n = n or 0;
	local i = self.index + n + 1;
	if i > self.length then
		return Tokenizer.EOF_TOKEN;
	end
	return self.tokens[i];
end

--! Function to get the next Token
local function get(self)
	local i = self.index + 1;
	if i > self.length then
		error(generateError(self, "Unexpected end of Input"));
	end
	self.index = self.index + 1;
	local tk = self.tokens[i];
	if tk.source:find("0x") and tk.kind == "Number" then
	    tk.value = nil
	    tk.value = tk.source
	end
	return tk;
end

local function is(self, kind, sourceOrN, n)
	local token = peek(self, n);
	
	local source = nil;
	if(type(sourceOrN) == "string") then
		source = sourceOrN;
	else
		n = sourceOrN;
	end
	n = n or 0;
	
	if(token.kind == kind) then
		if(source == nil or token.source == source) then
			return true;
		end
	end
	
	return false;
end

local function consume(self, kind, source)
	if(is(self, kind, source)) then
		self.index = self.index + 1;
		return true;
	end
	return false;
end

local function expect(self, kind, source)
	if(is(self, kind, source, 0)) then
		return get(self);
	end
	
	local token = peek(self);
	if self.disableLog then error() end
	if(source) then
		logger:error(generateError(self, string.format("unexpected token <%s> \"%s\", expected <%s> \"%s\"", token.kind, token.source, kind, source)));
	else
		logger:error(generateError(self, string.format("unexpected token <%s> \"%s\", expected <%s>", token.kind, token.source, kind)));
	end
end

--! Parse the given code to an Abstract Syntax Tree
function Parser:parse(code)
	self.tokenizer:append(code);
	self.tokens = self.tokenizer:scanAll();
	self.length = #self.tokens;
	self.labels = {};
	self.gotos = {};
	
	
	--! Create Global Variable Scope
	local globalScope = Scope:newGlobal();
	
	local ast = Ast.TopNode(self:block(globalScope, false), globalScope);
	--! File Must be Over when Top Node is Fully Parsed
	expect(self, TokenKind.Eof);
	
	
	for _,g in pairs(self.gotos) do
		assert(self.labels[g.label], string.format("label '%s' is already defined", g.label))
	end
	--ast.labels = self.labels
	--ast.gotos = self.gotos
	logger:debug("Cleaning up Parser for next Use ...")
	--! Clean Up
	self.tokenizer:reset();
	self.tokens = {};
	self.index = 0;
	self.length = 0;
	self.labels = {}
	self.gotos = {}
	
	logger:debug("Cleanup Done")
	
	return setmetatable(ast, {
	    __index = ast,
	    --__tostring = tolua
	})
end

--! Parse a Code Block
function Parser:block(parentScope, currentLoop, scope)
	scope = scope or Scope:new(parentScope);
	local stats = {};
	local labels = {};
	
	
	repeat
		local stat, isTerminatingStat = self:stat(scope, currentLoop);
		
		if stat and stat.kind == AstKind.LabelStat then
            --if self.labels[stat.labelName] then
            --!    logger:error(generateError(self, string.format("label '%s' is already defined", stat.labelName)))
            --end
            self.labels[stat.label] = true --! Đánh dấu nhãn đã được định nghĩa
            table.insert(stats, stat)
        else
            table.insert(stats, stat)
        end
        
		--table.insert(stats, stat);
	until isTerminatingStat or not stat
--[[	
	for _, stmt in ipairs(stats) do
        if stmt.kind == AstKind.GotoStat then
            if not self.labels[stmt.labelName] then
                --print( stats )
                logger:error(generateError(self, string.format("goto to undefined label '%s'", stmt.labelName)))
            end
        end
    end
]]    
	--print( stats )
	--! Consume Eventual Semicolon after terminating return, break or continue
	consume(self, TokenKind.Symbol, ";");
	
	return Ast.Block(stats, scope);
end


function Parser:stat(scope, currentLoop)
	
	
	
	while(consume(self, TokenKind.Symbol, ";")) do
		
	end
	
	--! Kiểm tra lệnh goto
    if consume(self, TokenKind.Keyword, "goto") then
        local label = expect(self, TokenKind.Ident)
        local stat = Ast.GotoStat(label.value)
         self.gotos[#self.gotos+1] = stat
        return stat
    end
	  
	
	--! Break Stat - only valid inside of Loops
	if(consume(self, TokenKind.Keyword, "break")) then
		if(not currentLoop) then
			if self.disableLog then error() end;
			logger:error(generateError(self, "the break Stat is only valid inside of loops"));
		end
		--! Return true as Second value because break must be the last Stat in a block
		return Ast.BreakStat(currentLoop, scope), true;
	end
	
	
	--! Kiểm tra nhãn (label)
    if consume(self, TokenKind.Symbol, "::") then
        local labelName = expect(self, TokenKind.Ident).value
        local pos = expect(self, TokenKind.Symbol, "::")
        return Ast.LabelStat(labelName, pos)
    end
    
	
	--! Continue Stat - only valid inside of Loops - only valid in LuaU
	if(self.luaVersion == LuaVersion.LuaU or self.luaVersion == LuaVersion.Lua53 and consume(self, TokenKind.Keyword, "continue")) then
		if(not currentLoop) then
			if self.disableLog then error() end;
			logger:error(generateError(self, "the continue Stat is only valid inside of loops"));
		end
		--! Return true as Second value because continue must be the last Stat in a block
		return Ast.ContinueStat(currentLoop, scope), true;
	end
	
	--! do ... end Stat
	if(consume(self, TokenKind.Keyword, "do")) then
		local body = self:block(scope, currentLoop);
		expect(self, TokenKind.Keyword, "end");
		return Ast.DoStat(body);
	end
	
	--! While Stat
	if(consume(self, TokenKind.Keyword, "while")) then
		local condition = self:exp(scope);
		expect(self, TokenKind.Keyword, "do");
		local stat = Ast.WhileStat(nil, condition, scope);
		stat.body = self:block(scope, stat);
		expect(self, TokenKind.Keyword, "end");
		return stat;
	end
	
	--! Repeat Stat
	if(consume(self, TokenKind.Keyword, "repeat")) then
		local repeatScope = Scope:new(scope);
		local stat = Ast.RepeatStat(nil, nil, scope);
		stat.body = self:block(nil, stat, repeatScope);
		expect(self, TokenKind.Keyword, "until");
		stat.condition = self:exp(repeatScope);
		return stat;
	end
	
	--! Return Stat
	if(consume(self, TokenKind.Keyword, "return")) then
		local args = {};
		if(not is(self, TokenKind.Keyword, "end") and not is(self, TokenKind.Keyword, "elseif") and not is(self, TokenKind.Keyword, "else") and not is(self, TokenKind.Symbol, ";") and not is(self, TokenKind.Eof)) then
			args = self:exprList(scope);
		end
		--! Return true as Second value because return must be the last Stat in a block
		return Ast.ReturnStat(args), true;
	end
	
	--! If Stat
	if(consume(self, TokenKind.Keyword, "if")) then
		local condition = self:exp(scope);
		expect(self, TokenKind.Keyword, "then");
		local body = self:block(scope, currentLoop);
		
		local elseifs = {};
		--! Elseifs
		while(consume(self, TokenKind.Keyword, "elseif")) do
			local condition = self:exp(scope);
			expect(self, TokenKind.Keyword, "then");
			local body = self:block(scope, currentLoop);
			
			table.insert(elseifs, {
				condition = condition,
				body = body,
			});
		end
		
		local elsebody = nil;
		--! Else
		if(consume(self, TokenKind.Keyword, "else")) then
			elsebody = self:block(scope, currentLoop);
		end
		
		expect(self, TokenKind.Keyword, "end");
		
		return Ast.IfStat(condition, body, elseifs, elsebody);
	end
	
	--! Function Decl
	if(consume(self, TokenKind.Keyword, "function")) then
		--! TODO: Parse Function Decl Name
		local obj = self:funcName(scope);
		local baseScope = obj.scope;
		local baseId = obj.id;
		local indices = obj.indices;
		
		local funcScope = Scope:new(scope);
		
		expect(self, TokenKind.Symbol, "(");
		local args = self:functionArgList(funcScope);
		expect(self, TokenKind.Symbol, ")");
		
		if(obj.passSelf) then
			local id = funcScope:addVariable("self", obj.token);
			table.insert(args, 1, Ast.VariableExpr(funcScope, id));
		end

		local body = self:block(nil, false, funcScope);
		expect(self, TokenKind.Keyword, "end");
		
		return Ast.FunctionDecl(baseScope, baseId, indices, args, body);
	end
	
	--! Local Function or Variable Decl
	if(consume(self, TokenKind.Keyword, "local")) then
		--! Local Function Decl
		if(consume(self, TokenKind.Keyword, "function")) then
			local ident = expect(self, TokenKind.Ident);
			local name = ident.value;
			
			local id = scope:addVariable(name, ident);
			local funcScope = Scope:new(scope);
			
			expect(self, TokenKind.Symbol, "(");
			local args = self:functionArgList(funcScope);
			expect(self, TokenKind.Symbol, ")");

			local body = self:block(nil, false, funcScope);
			expect(self, TokenKind.Keyword, "end");

			return Ast.LocalFunctionDecl(scope, id, args, body);
		end
		
		--! Local Variable Decl
		local ids = self:nameList(scope);
		local exps = {};
		if(consume(self, TokenKind.Symbol, "=")) then
			exps = self:exprList(scope);
		end

		--! Các biến chỉ có thể được tham chiếu đến trong stat tiếp theo, vì vậy các id được bật sau khi các exp đã được phân tích cú pháp
		self:enableNameList(scope, ids);
		
		if(#exps > #ids) then
			logger:warn(generateWarning(peek(self, -1), string.format("assigning %d values to %d variable" .. ((#ids > 1 and "s") or ""), #exps, #ids)));
		elseif(#ids > #exps and #exps > 0 and not ASSIGNMENT_NO_WARN_LOOKUP[exps[#exps].kind]) then
			logger:warn(generateWarning(peek(self, -1), string.format("assigning %d value" .. ((#exps > 1 and "s") or "") .. 
				" to %d variables initializes extra variables with nil, add a nil value to silence", #exps, #ids)));
		end		
		return Ast.LocalVariableDecl(scope, ids, exps);
	end
	
	--! For Stat
	if(consume(self, TokenKind.Keyword, "for")) then
		--! Normal for Stat
		if(is(self, TokenKind.Symbol, "=", 1)) then
			local forScope = Scope:new(scope);
			
			local ident = expect(self, TokenKind.Ident);
			local varId = forScope:addDisabledVariable(ident.value, ident);
			
			expect(self, TokenKind.Symbol, "=");
			local initialValue = self:exp(scope);
			
			expect(self, TokenKind.Symbol, ",");
			local finalValue = self:exp(scope);
			local incrementBy = Ast.NumberExpr(1);
			if(consume(self, TokenKind.Symbol, ",")) then
				incrementBy = self:exp(scope);
			end
			
			local stat = Ast.ForStat(forScope, varId, initialValue, finalValue, incrementBy, nil, scope);
			forScope:enableVariable(varId);
			expect(self, TokenKind.Keyword, "do");
			stat.body = self:block(nil, stat, forScope);
			expect(self, TokenKind.Keyword, "end");
			return stat;
		end
		
		--! For ... in ... stat
		local forScope = Scope:new(scope);
		
		local ids = self:nameList(forScope);
		expect(self, TokenKind.Keyword, "in");
		local exps = self:exprList(scope);
		--! Enable Ids after Expr Parsing so that code like this works:
		--	local z = {10,20}
		--	for y,z in ipairs(z) do
		--		print(y, z);
		--! 	end
		self:enableNameList(forScope, ids);
		expect(self, TokenKind.Keyword, "do");
		local stat = Ast.ForInStat(forScope, ids, exps, nil, scope);
		stat.body = self:block(nil, stat, forScope);
		expect(self, TokenKind.Keyword, "end");
		
		return stat;
	end
	
	local expr = self:primaryExpr(scope);
	--! Variable Assi or Function Call
	if expr then
		--! Function Call Stat
		if(expr.kind == AstKind.FunctionCallExpr) then
			return Ast.FunctionCallStat(expr.base, expr.args);
		end
		
		--! Function Call Stat passing self
		if(expr.kind == AstKind.PassSelfFunctionCallExpr) then
			return Ast.PassSelfFunctionCallStat(expr.base, expr.passSelfFunctionName, expr.args);
		end
		
		--! Variable Assi
		if(expr.kind == AstKind.IndexExpr or expr.kind == AstKind.VariableExpr) then
			if(expr.kind == AstKind.IndexExpr) then
				expr.kind = AstKind.AssiIndexing
			end
			if(expr.kind == AstKind.VariableExpr) then
				expr.kind = AstKind.AssiVariable
			end

			if(self.luaVersion == LuaVersion.LuaU) then
				--! LuaU Compound Assi
				if(consume(self, TokenKind.Symbol, "+=")) then
					local rhs = self:exp(scope);
					return Ast.CompoundAddStat(expr, rhs);
				end

				if(consume(self, TokenKind.Symbol, "-=")) then
					local rhs = self:exp(scope);
					return Ast.CompoundSubStat(expr, rhs);
				end

				if(consume(self, TokenKind.Symbol, "*=")) then
					local rhs = self:exp(scope);
					return Ast.CompoundMulStat(expr, rhs);
				end

				if(consume(self, TokenKind.Symbol, "/=")) then
					local rhs = self:exp(scope);
					return Ast.CompoundDivStat(expr, rhs);
				end

				if(consume(self, TokenKind.Symbol, "%=")) then
					local rhs = self:exp(scope);
					return Ast.CompoundModStat(expr, rhs);
				end

				if(consume(self, TokenKind.Symbol, "^=")) then
					local rhs = self:exp(scope);
					return Ast.CompoundPowStat(expr, rhs);
				end

				if(consume(self, TokenKind.Symbol, "..=")) then
					local rhs = self:exp(scope);
					return Ast.CompoundConcatStat(expr, rhs);
				end
			end

			local lhs = {
				expr
			}
			
			while consume(self, TokenKind.Symbol, ",") do
				expr = self:primaryExpr(scope);
				
				if(not expr) then
					if self.disableLog then error() end;
					logger:error(generateError(self, string.format("expected a valid assi stat lhs part but got nil")));
				end
				
				if(expr.kind == AstKind.IndexExpr or expr.kind == AstKind.VariableExpr) then
					if(expr.kind == AstKind.IndexExpr) then
						expr.kind = AstKind.AssiIndexing
					end
					if(expr.kind == AstKind.VariableExpr) then
						expr.kind = AstKind.AssiVariable
					end
					table.insert(lhs, expr);
				else
					if self.disableLog then error() end;
					logger:error(generateError(self, string.format("expected a valid assi stat lhs part but got <%s>", expr.kind)));
				end
			end
			
			expect(self, TokenKind.Symbol, "=");
			
			local rhs = self:exprList(scope);
			
			return Ast.AssiStat(lhs, rhs);
		end
		
		if self.disableLog then error() end;
		logger:error(generateError(self, "exps are not valid stats!"));
	end
	
	return nil;
end

function Parser:primaryExpr(scope)
	local i = self.index;
	local s = self;
	self.disableLog = true;
	local status, val = pcall(self.expFunctionCall, self, scope);
	self.disableLog = false;
	if(status) then
		return val;
	else
		self.index = i;
		return nil;
	end
end

--! List of exps Seperated by a comma
function Parser:exprList(scope)
	local exps = {
		self:exp(scope)
	};
	while(consume(self, TokenKind.Symbol, ",")) do
		table.insert(exps, self:exp(scope));
	end
	return exps;
end

--! list of local variable names
function Parser:nameList(scope)
	local ids = {};
	
	local ident = expect(self, TokenKind.Ident);
	local id = scope:addDisabledVariable(ident.value, ident);
	table.insert(ids, id);
	
	while(consume(self, TokenKind.Symbol, ",")) do
		ident = expect(self, TokenKind.Ident);
		id = scope:addDisabledVariable(ident.value, ident);
		table.insert(ids, id);
	end
	
	return ids;
end

function Parser:enableNameList(scope, list)
	for i, id in ipairs(list) do
		scope:enableVariable(id);
	end
end


--! function name
function Parser:funcName(scope)
	local ident = expect(self, TokenKind.Ident);
	local baseName = ident.value;
	
	local baseScope, baseId = scope:resolve(baseName);
	
	local indices = {};
	local passSelf = false;
	while(consume(self, TokenKind.Symbol, ".")) do
		table.insert(indices, expect(self, TokenKind.Ident).value);
	end
	
	if(consume(self, TokenKind.Symbol, ":")) then
		table.insert(indices, expect(self, TokenKind.Ident).value);
		passSelf = true;
	end
	
	return {
		scope = baseScope,
		id = baseId,
		indices = indices,
		passSelf = passSelf,
		token = ident,
	};
end

--! Expr
function Parser:exp(scope)
	return self:expOr(scope);
end

function Parser:expOr(scope)
	local lhs = self:expAnd(scope);
	
	if(consume(self, TokenKind.Keyword, "or")) then
		local rhs = self:expOr(scope);
		return Ast.OrExpr(lhs, rhs, true);
	end
	
	return lhs;
end

function Parser:expAnd(scope)
	local lhs = self:expComparision(scope);

	if(consume(self, TokenKind.Keyword, "and")) then
		local rhs = self:expAnd(scope);
		return Ast.AndExpr(lhs, rhs, true);
	end

	return lhs;
end

function Parser:expComparision(scope)
	local curr = self:expStrCat(scope);
	repeat
		local found = false;
		if(consume(self, TokenKind.Symbol, "<")) then
			local rhs = self:expStrCat(scope);
			curr = Ast.LessThanExpr(curr, rhs, true);
			found = true;
		end
		
		if(consume(self, TokenKind.Symbol, ">")) then
			local rhs = self:expStrCat(scope);
			curr = Ast.GreaterThanExpr(curr, rhs, true);
			found = true;
		end
		
		if(consume(self, TokenKind.Symbol, "<=")) then
			local rhs = self:expStrCat(scope);
			curr = Ast.LessThanOrEqualsExpr(curr, rhs, true);
			found = true;
		end
	
		if(consume(self, TokenKind.Symbol, ">=")) then
			local rhs = self:expStrCat(scope);
			curr = Ast.GreaterThanOrEqualsExpr(curr, rhs, true);
			found = true;
		end
		
		if(consume(self, TokenKind.Symbol, "~=")) then
			local rhs = self:expStrCat(scope);
			curr = Ast.NotEqualsExpr(curr, rhs, true);
			found = true;
		end
	
		if(consume(self, TokenKind.Symbol, "==")) then
			local rhs = self:expStrCat(scope);
			curr = Ast.EqualsExpr(curr, rhs, true);
			found = true;
		end
	until not found;

	return curr;
end

function Parser:expStrCat(scope)
	local lhs = self:expAddSub(scope);

	if(consume(self, TokenKind.Symbol, "..")) then
		local rhs = self:expStrCat(scope);
		return Ast.StrCatExpr(lhs, rhs, true);
	end

	return lhs;
end

function Parser:expAddSub(scope)
	local curr = self:expMulDivMod(scope);

	repeat
		local found = false;
		if(consume(self, TokenKind.Symbol, "+")) then
			local rhs = self:expMulDivMod(scope);
			curr = Ast.AddExpr(curr, rhs, false);
			found = true;
		end
		
		if(consume(self, TokenKind.Symbol, "-")) then
			local rhs = self:expMulDivMod(scope);
			curr = Ast.SubExpr(curr, rhs, false);
			found = true;
		end
	until not found;
	

	return curr;
end

function Parser:expMulDivMod(scope)
	local curr = self:expUnary(scope);

	repeat
		local found = false;
		if(consume(self, TokenKind.Symbol, "*")) then
			local rhs = self:expUnary(scope);
			curr = Ast.MulExpr(curr, rhs, false);
			found = true;
		end
	
		if(consume(self, TokenKind.Symbol, "/")) then
			local rhs = self:expUnary(scope);
			curr = Ast.DivExpr(curr, rhs, false);
			found = true;
		end

		if(consume(self, TokenKind.Symbol, "%")) then
			local rhs = self:expUnary(scope);
			curr = Ast.ModExpr(curr, rhs, false);
			found = true;
		end
		
		if(consume(self, TokenKind.Symbol, "&")) then
			local rhs = self:expUnary(scope);
			curr = Ast.BandExpr(curr, rhs, false);
			found = true;
		end
		
		if(consume(self, TokenKind.Symbol, "~")) then
			local rhs = self:expUnary(scope);
			curr = Ast.BxorExpr(curr, rhs, false);
			found = true;
		end
		
		if(consume(self, TokenKind.Symbol, "|")) then
			local rhs = self:expUnary(scope);
			curr = Ast.BorExpr(curr, rhs, false);
			found = true;
		end
		
		if(consume(self, TokenKind.Symbol, "<<")) then
			local rhs = self:expUnary(scope);
			curr = Ast.ShlExpr(curr, rhs, false);
			found = true;
		end
		
		if(consume(self, TokenKind.Symbol, ">>")) then
			local rhs = self:expUnary(scope);
			curr = Ast.ShrExpr(curr, rhs, false);
			found = true;
		end
		
		if(consume(self, TokenKind.Symbol, "//")) then
			local rhs = self:expUnary(scope);
			curr = Ast.IdivExpr(curr, rhs, false);
			found = true;
		end
		
	until not found;

	return curr;
end

function Parser:expUnary(scope)
	if(consume(self, TokenKind.Keyword, "not")) then
		local rhs = self:expUnary(scope);
		return Ast.NotExpr(rhs, true);
	end
	
	if(consume(self, TokenKind.Symbol, "#")) then
		local rhs = self:expUnary(scope);
		return Ast.LenExpr(rhs, true);
	end
	
	if(consume(self, TokenKind.Symbol, "-")) then
		local rhs = self:expUnary(scope);
		return Ast.NegateExpr(rhs, true);
	end
	
	if(consume(self, TokenKind.Symbol, "~")) then
		local rhs = self:expUnary(scope);
		return Ast.BnotExpr(rhs, false);
	end

	return self:expPow(scope);
end

function Parser:expPow(scope)
	local lhs = self:tableOrFunctionLiteral(scope);

	if(consume(self, TokenKind.Symbol, "^")) then
		local rhs = self:expPow(scope);
		return Ast.PowExpr(lhs, rhs, false);
	end

	return lhs;
end

--! Table Literals and Function Literals cannot directly be called or indexed
function Parser:tableOrFunctionLiteral(scope)
	
	if(is(self, TokenKind.Symbol, "{")) then
		return self:tableConstructor(scope);
	end
	
	if(is(self, TokenKind.Keyword, "function")) then
		return self:expFunctionLiteral(scope);
	end
	
	return self:expFunctionCall(scope);
end

function Parser:expFunctionLiteral(parentScope)
	local scope = Scope:new(parentScope);
	
	expect(self, TokenKind.Keyword, "function");
	
	expect(self, TokenKind.Symbol, "(");
	local args = self:functionArgList(scope);
	expect(self, TokenKind.Symbol, ")");
	
	local body = self:block(nil, false, scope);
	expect(self, TokenKind.Keyword, "end");
	
	return Ast.FunctionLiteralExpr(args, body);
end

function Parser:functionArgList(scope)
	local args = {};
	if(consume(self, TokenKind.Symbol, "...")) then
		table.insert(args, Ast.VarargExpr());
		return args;
	end
	
	if(is(self, TokenKind.Ident)) then
		local ident = get(self);
		local name = ident.value;
		
		local id = scope:addVariable(name, ident);
		table.insert(args, Ast.VariableExpr(scope, id));
		
		while(consume(self, TokenKind.Symbol, ",")) do
			if(consume(self, TokenKind.Symbol, "...")) then
				table.insert(args, Ast.VarargExpr());
				return args;
			end
			
			ident = get(self);
			name = ident.value;

			id = scope:addVariable(name, ident);
			table.insert(args, Ast.VariableExpr(scope, id));
		end
	end
	
	return args;
end

function Parser:expFunctionCall(scope, base)
	base = base or self:expIndex(scope);
	
	--! Normal Function Call
	local args = {};
	if(is(self, TokenKind.String)) then
		args = {
			Ast.StringExpr(get(self).value),
		};
	elseif(is(self, TokenKind.Symbol, "{")) then
		args = {
			self:tableConstructor(scope),
		};
	elseif(consume(self, TokenKind.Symbol, "(")) then
		if(not is(self, TokenKind.Symbol, ")")) then
			args = self:exprList(scope);
		end
		expect(self, TokenKind.Symbol, ")");
	else
		return base;
	end
	
	local node = Ast.FunctionCallExpr(base, args);
	
	--! the result of a function call can be indexed
	if(is(self, TokenKind.Symbol, ".") or is(self, TokenKind.Symbol, "[") or is(self, TokenKind.Symbol, ":")) then
		return self:expIndex(scope, node);
	end

	--! The result of a function call can be a function that is again called
	if(is(self, TokenKind.Symbol, "(") or is(self, TokenKind.Symbol, "{") or is(self, TokenKind.String)) then
		return self:expFunctionCall(scope, node);
	end
	
	return node;
end

function Parser:expIndex(scope, base)
	base = base or self:expLiteral(scope);
	
	--! Parse Indexing Exprs
	while(consume(self, TokenKind.Symbol, "[")) do
		local expr = self:exp(scope);
		expect(self, TokenKind.Symbol, "]");
		base = Ast.IndexExpr(base, expr);
	end
	
	--! Parse Indexing Exprs
	while consume(self, TokenKind.Symbol, ".") do
		local ident = expect(self, TokenKind.Ident);
		base = Ast.IndexExpr(base, Ast.StringExpr(ident.value));
		
		while(consume(self, TokenKind.Symbol, "[")) do
			local expr = self:exp(scope);
			expect(self, TokenKind.Symbol, "]");
			base = Ast.IndexExpr(base, expr);
		end
	end

	--! Function Passing self
	if(consume(self, TokenKind.Symbol, ":")) then
		local passSelfFunctionName = expect(self, TokenKind.Ident).value;
		local args = {};
		if(is(self, TokenKind.String)) then
			args = {
				Ast.StringExpr(get(self).value),
			};
		elseif(is(self, TokenKind.Symbol, "{")) then
			args = {
				self:tableConstructor(scope),
			};
		else
			expect(self, TokenKind.Symbol, "(");
			if(not is(self, TokenKind.Symbol, ")")) then
				args = self:exprList(scope);
			end
			expect(self, TokenKind.Symbol, ")");
		end
		
		local node = Ast.PassSelfFunctionCallExpr(base, passSelfFunctionName, args);

		--! the result of a function call can be indexed
		if(is(self, TokenKind.Symbol, ".") or is(self, TokenKind.Symbol, "[") or is(self, TokenKind.Symbol, ":")) then
			return self:expIndex(scope, node);
		end

		--! The result of a function call can be a function that is again called
		if(is(self, TokenKind.Symbol, "(") or is(self, TokenKind.Symbol, "{") or is(self, TokenKind.String)) then
			return self:expFunctionCall(scope, node);
		end
		
		return node
	end

	--! The result of a function call can be a function that is again called
	if(is(self, TokenKind.Symbol, "(") or is(self, TokenKind.Symbol, "{") or is(self, TokenKind.String)) then
		return self:expFunctionCall(scope, base);
	end
	
	return base;
end

function Parser:expLiteral(scope)
	--! () exp
	if(consume(self, TokenKind.Symbol, "(")) then
		local expr = self:exp(scope);
		expect(self, TokenKind.Symbol, ")");
		return expr;
	end
	
	--! String Literal
	if(is(self, TokenKind.String)) then
		return Ast.StringExpr(get(self).value);
	end
	
	--! Number Literal
	if(is(self, TokenKind.Number)) then
		return Ast.NumberExpr(get(self).value);
	end
	
	--! True Literal
	if(consume(self, TokenKind.Keyword, "true")) then
		return Ast.BooleanExpr(true);
	end
	
	--! False Literal
	if(consume(self, TokenKind.Keyword, "false")) then
		return Ast.BooleanExpr(false);
	end
	
	--! Nil Literal
	if(consume(self, TokenKind.Keyword, "nil")) then
		return Ast.NilExpr();
	end
	
	--! Vararg Literal
	if(consume(self, TokenKind.Symbol, "...")) then
		return Ast.VarargExpr();
	end
	
	--! Variable
	if(is(self, TokenKind.Ident)) then
		local ident = get(self);
		local name = ident.value;
		
		local scope, id = scope:resolve(name);
		return Ast.VariableExpr(scope, id);
	end
	
	if(self.disableLog) then error() end
	logger:error(generateError(self, "Unexpected Token \"" .. peek(self).source .. "\". Expected a Expr!"))
end

function Parser:tableConstructor(scope)
	--! TODO: Parse Table Literals
	local entries = {};
	
	expect(self, TokenKind.Symbol, "{");
	
	while (not consume(self, TokenKind.Symbol, "}")) do
		if(consume(self, TokenKind.Symbol, "[")) then
			local key = self:exp(scope);
			expect(self, TokenKind.Symbol, "]");
			expect(self, TokenKind.Symbol, "=");
			local value = self:exp(scope);
			table.insert(entries, Ast.KeyedTableEntry(key, value));
		elseif(is(self, TokenKind.Ident, 0) and is(self, TokenKind.Symbol, "=", 1)) then
			local key = Ast.StringExpr(get(self).value);
			expect(self, TokenKind.Symbol, "=");
			local value = self:exp(scope);
			table.insert(entries, Ast.KeyedTableEntry(key, value));
		else
			local value = self:exp(scope);
			table.insert(entries, Ast.TableEntry(value));
		end
		
		
		if (not consume(self, TokenKind.Symbol, ";") and not consume(self, TokenKind.Symbol, ",") and not is(self, TokenKind.Symbol, "}")) then
			if self.disableLog then error() end
			logger:error(generateError(self, "expected a \";\" or a \",\""));
		end
	end
	
	return Ast.TableConstructorExpr(entries);
end

setmetatable(Parser, {
    __call = Parser.new,
})
return Parser
end;modules['obfLT9.tokenizer'] = function()
local Enums = require("obfLT9.enums");
local util = require("obfLT9.util");
local logger = require("logger");
local config = require("config");

local LuaVersion = Enums.LuaVersion;
local lookupify = util.lookupify;
local unlookupify = util.unlookupify;
local escape = util.escape;
local chararray = util.chararray;
local keys = util.keys;
local Tokenizer = {};

Tokenizer.EOF_CHAR = "<EOF>";
Tokenizer.WHITESPACE_CHARS = lookupify{
	" ", "\t", "\n", "\r",
}

Tokenizer.ANNOTATION_CHARS = lookupify(chararray("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_"))
Tokenizer.ANNOTATION_START_CHARS = lookupify(chararray("!@"))

Tokenizer.Conventions = Enums.Conventions;

Tokenizer.TokenKind = {
	Eof     = "Eof",
	Keyword = "Keyword",
	Symbol  = "Symbol",
	Ident   = "Identifier",
	Number  = "Number",
	String  = "String",
}

Tokenizer.EOF_TOKEN = {
	kind = Tokenizer.TokenKind.Eof,
	value = "<EOF>",
	startPos = -1,
	endPos = -1,
	source = "<EOF>",
}

local function token(self, startPos, kind, value)
	local line, linePos = self:getPosition(self.index);
	local annotations = self.annotations
	self.annotations = {};
	return {
		kind     = kind,
		value    = value,
		startPos = startPos,
		endPos   = self.index,
		source   = self.source:sub(startPos + 1, self.index),
		line     = line,
		linePos  = linePos,
		annotations = annotations,
	}
end

local function generateError(self, message)
	local line, linePos = self:getPosition(self.index);
	return "Lexing Error at Position " .. tostring(line) .. ":" .. tostring(linePos) .. ", " .. message;
end

local function generateWarning(token, message)
	return "Warning at Position " .. tostring(token.line) .. ":" .. tostring(token.linePos) .. ", " .. message;
end

function Tokenizer:getPosition(i)
	local column = self.columnMap[i]

	if not column then --// `i` is bigger than self.length, this shouldnt happen, but it did. (Theres probably some error in the tokenizer, cant find it.)
		column = self.columnMap[#self.columnMap] 
	end

	return column.id, column.charMap[i]
end

--// Prepare columnMap for getPosition
function Tokenizer:prepareGetPosition()
	local columnMap, column = {}, { charMap = {}, id = 1, length = 0 }

	for index = 1, self.length do
		local character = string.sub(self.source, index, index) -- NOTE_1: this could use table.clone to reduce amount of NEWTABLE (if that causes any performance issues)

		local columnLength = column.length + 1
		column.length = columnLength
		column.charMap[index] = columnLength

		if character == "\n" then
			column = { charMap = {}, id = column.id + 1, length = 0 } -- NOTE_1
		end

		columnMap[index] = column
	end

	self.columnMap = columnMap
end

-- Constructor for Tokenizer
function Tokenizer:new(settings) 
	local luaVersion = (settings and (settings.luaVersion or settings.LuaVersion)) or LuaVersion.LuaU;
	local conventions = Tokenizer.Conventions[luaVersion];
	
	if(conventions == nil) then
		logger:error("The Lua Version \"" .. luaVersion .. "\" is not recognised by the Tokenizer! Please use one of the following: \"" .. table.concat(keys(Tokenizer.Conventions), "\",\"") .. "\"");
	end
	
	local tokenizer = {
		index  = 0,           -- Index where the current char is read
		length = 0,
		source = "", -- Source to Tokenize
		luaVersion = luaVersion, -- LuaVersion to be used while Tokenizing
		conventions = conventions;
		
		NumberChars       = conventions.NumberChars,
		NumberCharsLookup = lookupify(conventions.NumberChars),
		Keywords          = conventions.Keywords,
		KeywordsLookup    = lookupify(conventions.Keywords),
		BinaryNumberChars = conventions.BinaryNumberChars,
		BinaryNumberCharsLookup = lookupify(conventions.BinaryNumberChars);
		BinaryNums        = conventions.BinaryNums,
		HexadecimalNums   = conventions.HexadecimalNums,
		HexNumberChars    = conventions.HexNumberChars,
		HexNumberCharsLookup = lookupify(conventions.HexNumberChars),
		DecimalExponent   = conventions.DecimalExponent,
		DecimalSeperators = conventions.DecimalSeperators,
		IdentChars        = conventions.IdentChars,
		IdentCharsLookup  = lookupify(conventions.IdentChars),
		
		EscapeSequences   = conventions.EscapeSequences,
		NumericalEscapes  = conventions.NumericalEscapes,
		EscapeZIgnoreNextWhitespace = conventions.EscapeZIgnoreNextWhitespace,
		HexEscapes        = conventions.HexEscapes,
		UnicodeEscapes    = conventions.UnicodeEscapes,
		
		SymbolChars       = conventions.SymbolChars,
		SymbolCharsLookup = lookupify(conventions.SymbolChars),
		MaxSymbolLength   = conventions.MaxSymbolLength,
		Symbols           = conventions.Symbols,
		SymbolsLookup     = lookupify(conventions.Symbols),
		
		StringStartLookup = lookupify({"\"", "\'"}),
		annotations = {},
	};
	
	setmetatable(tokenizer, self);
	self.__index = self;
	
	return tokenizer;
end

-- Reset State of Tokenizer to Tokenize another File
function Tokenizer:reset()
	self.index = 0;
	self.length = 0;
	self.source = "";
	self.annotations = {};
	self.columnMap = {};
end

-- Append String to this Tokenizer
function Tokenizer:append(code)
	self.source = self.source .. code
	self.length = self.length + code:len();
	self:prepareGetPosition();
end

-- Function to peek the n'th char in the source of the tokenizer
local function peek(self, n)
	n = n or 0;
	local i = self.index + n + 1;
	if i > self.length then
		return Tokenizer.EOF_CHAR
	end
	return self.source:sub(i, i);
end

-- Function to get the next char in the source
local function get(self)
	local i = self.index + 1;
	if i > self.length then
		logger:error(generateError(self, "Unexpected end of Input"));
	end
	self.index = self.index + 1;
	return self.source:sub(i, i);
end

-- The same as get except it throws an Error if the char is not contained in charOrLookup
local function expect(self, charOrLookup)
	if(type(charOrLookup) == "string") then
		charOrLookup = {[charOrLookup] = true};
	end
	
	local char = peek(self);
	if charOrLookup[char] ~= true then
		local etb = unlookupify(charOrLookup);
		for i, v in ipairs(etb) do
			etb[i] = escape(v);
		end
		local errorMessage = "Unexpected char \"" .. escape(char) .. "\"! Expected one of \"" .. table.concat(etb, "\",\"") .. "\"";
		logger:error(generateError(self, errorMessage));
	end
	
	self.index = self.index + 1;
	return char;
end

-- Returns wether the n'th char is in the lookup
local function is(self, charOrLookup, n)
	local char = peek(self, n);
	if(type(charOrLookup) == "string") then
		return char == charOrLookup;
	end
	return charOrLookup[char];
end

function Tokenizer:parseAnnotation()
	if is(self, Tokenizer.ANNOTATION_START_CHARS) then
		self.index = self.index + 1;
		local source, length = {}, 0;
		while(is(self, Tokenizer.ANNOTATION_CHARS)) do
			source[length + 1] = get(self)
			length = #source
		end
		if length > 0 then
			self.annotations[string.lower(table.concat(source))] = true;
		end
		return nil;
	end
	return get(self);
end

-- skip one or 0 Comments and return wether one was found
function Tokenizer:skipComment()
	if(is(self, "-", 0) and is(self, "-", 1)) then
		self.index = self.index + 2;
		if(is(self, "[")) then
			self.index = self.index + 1;
			local eqCount = 0;
			while(is(self, "=")) do
				self.index = self.index + 1;
				eqCount = eqCount + 1;
			end
			if(is(self, "[")) then
				-- Multiline Comment
				-- Get all Chars to Closing bracket but also consider that the count of equal signs must be the same
				while true do
					if(self:parseAnnotation() == ']') then
						local eqCount2 = 0;
						while(is(self, "=")) do
							self.index = self.index + 1;
							eqCount2 = eqCount2 + 1;
						end
						if(is(self, "]")) then
							if(eqCount2 == eqCount) then
								self.index = self.index + 1;
								return true
							end
						end
					end
				end
			end
		end
		-- Single Line Comment
		-- Get all Chars to next Newline
		while(self.index < self.length and self:parseAnnotation() ~= "\n") do end
		return true;
	end
	return false;
end

-- skip All Whitespace and Comments to next Token
function Tokenizer:skipWhitespaceAndComments()
	while self:skipComment() do end
	while is(self, Tokenizer.WHITESPACE_CHARS) do
		self.index = self.index + 1;
		while self:skipComment() do end
	end
end

local function int(self, chars, seperators)
	local buffer = {};
	while true do
		if (is(self, chars)) then
			buffer[#buffer + 1] = get(self)
		elseif (is(self, seperators)) then
			self.index = self.index + 1;
		else
			break
		end
	end
	return table.concat(buffer);
end

-- Lex the next token as a Number
function Tokenizer:number()
	local startPos = self.index;
	local source   = expect(self, setmetatable({["."] = true}, {__index = self.NumberCharsLookup}));
	
	if source == "0" then
		if self.BinaryNums and is(self, lookupify(self.BinaryNums)) then
			self.index = self.index + 1;
			source = int(self, self.BinaryNumberCharsLookup, lookupify(self.DecimalSeperators or {}));
			local value = tonumber(source, 2);
			return token(self, startPos, Tokenizer.TokenKind.Number, value);
		end
		
		if self.HexadecimalNums and is(self, lookupify(self.HexadecimalNums)) then
			self.index = self.index + 1;
			source = int(self, self.HexNumberCharsLookup, lookupify(self.DecimalSeperators or {}));
			local value = tonumber(source, 16);
			return token(self, startPos, Tokenizer.TokenKind.Number, value);
		end
	end
	
	if source == "." then
		source = source .. int(self, self.NumberCharsLookup, lookupify(self.DecimalSeperators or {}));
	else
		source = source .. int(self, self.NumberCharsLookup, lookupify(self.DecimalSeperators or {}));
		if(is(self, ".")) then
			source = source .. get(self) .. int(self, self.NumberCharsLookup, lookupify(self.DecimalSeperators or {}));
		end
	end
	
	if(self.DecimalExponent and is(self, lookupify(self.DecimalExponent))) then
		source = source .. get(self);
		if(is(self, lookupify({"+","-"}))) then
			source = source .. get(self);
		end
		local v = int(self, self.NumberCharsLookup, lookupify(self.DecimalSeperators or {}));
		if(v:len() < 1) then
			logger:error(generateError(self, "Expected a Valid Exponent!"));
		end
		source = source .. v;
	end
	
	local value = tonumber(source);
	return token(self, startPos, Tokenizer.TokenKind.Number, value);
end

-- Lex the Next Token as Identifier or Keyword
function Tokenizer:ident()
	local startPos = self.index;
	local source = expect(self, self.IdentCharsLookup)
	local sourceAddContent = {source}
	while(is(self, self.IdentCharsLookup)) do
		-- source = source .. get(self);
		table.insert(sourceAddContent, get(self))
	end
	source = table.concat(sourceAddContent)
	if(self.KeywordsLookup[source]) then
		return token(self, startPos, Tokenizer.TokenKind.Keyword, source);
	end
	
	local tk = token(self, startPos, Tokenizer.TokenKind.Ident, source);
	
	if(string.sub(source, 1, string.len(config.IdentPrefix)) == config.IdentPrefix) then
		logger:warn(generateWarning(tk, string.format("identifiers should not start with \"%s\" as this may break the program", config.IdentPrefix)));
	end
	
	return tk;
end

function Tokenizer:singleLineString()
	local startPos = self.index;
	local startChar = expect(self, self.StringStartLookup);
	local buffer = {};

	while (not is(self, startChar)) do
		local char = get(self);
		
		-- Single Line String may not contain Linebreaks except when they are escaped by \
		if(char == '\n') then
			self.index = self.index - 1;
			logger:error(generateError(self, "Unterminated String"));
		end
		
		
		if(char == "\\") then
			char = get(self);
			
			local escape = self.EscapeSequences[char];
			if(type(escape) == "string") then
				char = escape;
				
			elseif(self.NumericalEscapes and self.NumberCharsLookup[char]) then
				local numstr = char;
				
				if(is(self, self.NumberCharsLookup)) then
					char = get(self);
					numstr = numstr .. char;
				end
		
				if(is(self, self.NumberCharsLookup)) then
					char = get(self);
					numstr = numstr .. char;
				end
				
				char = string.char(tonumber(numstr));
				
			elseif(self.UnicodeEscapes and char == "u") then
				expect(self, "{");
				local num = "";
				while (is(self, self.HexNumberCharsLookup)) do
					num = num .. get(self);
				end
				expect(self, "}");
				char = util.utf8char(tonumber(num, 16));
			elseif(self.HexEscapes and char == "x") then
				local hex = expect(self, self.HexNumberCharsLookup) .. expect(self, self.HexNumberCharsLookup);
				char = string.char(tonumber(hex, 16));
			elseif(self.EscapeZIgnoreNextWhitespace and char == "z") then
				char = "";
				while(is(self, Tokenizer.WHITESPACE_CHARS)) do
					self.index = self.index + 1;
				end
			end
		end
		
		--// since table.insert is slower in lua51
		buffer[#buffer + 1] = char
	end
	
	expect(self, startChar);
	
	return token(self, startPos, Tokenizer.TokenKind.String, table.concat(buffer))
end

function Tokenizer:multiLineString()
	local startPos = self.index;
	if(is(self, "[")) then
		self.index = self.index + 1;
		local eqCount = 0;
		while(is(self, "=")) do
			self.index = self.index + 1;
			eqCount = eqCount + 1;
		end
		if(is(self, "[")) then
			-- Multiline String
			-- Parse String to Closing bracket but also consider that the count of equal signs must be the same
			
			-- Skip Leading newline if existing
			self.index = self.index + 1;
			if(is(self, "\n")) then
				self.index = self.index + 1;
			end
			
			local value = "";
			while true do
				local char = get(self);
				if(char == ']') then
					local eqCount2 = 0;
					while(is(self, "=")) do
						char = char .. get(self);
						eqCount2 = eqCount2 + 1;
					end
					if(is(self, "]")) then
						if(eqCount2 == eqCount) then
							self.index = self.index + 1;
							return token(self, startPos, Tokenizer.TokenKind.String, value), true
						end
					end
				end
				value = value .. char;
			end
		end
	end
	self.index = startPos;
	return nil, false -- There was not an actual multiline string at the given Position
end

function Tokenizer:symbol()
	local startPos = self.index;
	for len = self.MaxSymbolLength, 1, -1 do
		local str = self.source:sub(self.index + 1, self.index + len);
		if self.SymbolsLookup[str] then
			self.index = self.index + len;
			return token(self, startPos, Tokenizer.TokenKind.Symbol, str);
		end
	end
	logger:error(generateError(self, "Unknown Symbol"));
end


-- get the Next token
function Tokenizer:next()
	-- Skip All Whitespace before the token
	self:skipWhitespaceAndComments();
	
	local startPos = self.index;
	if startPos >= self.length then
		return token(self, startPos, Tokenizer.TokenKind.Eof);
	end
	
	-- Numbers
	if(is(self, self.NumberCharsLookup)) then
		return self:number();
	end
	
	-- Identifiers and Keywords
	if(is(self, self.IdentCharsLookup)) then
		return self:ident();
	end
	
	-- Singleline String Literals
	if(is(self, self.StringStartLookup)) then
		return self:singleLineString();
	end
	
	-- Multiline String Literals
	if(is(self, "[", 0)) then
		-- The isString variable is due to the fact that "[" could also be a symbol for indexing
		local value, isString = self:multiLineString();
		if isString then
			return value;
		end
	end

	-- Number starting with dot
	if(is(self, ".") and is(self, self.NumberCharsLookup, 1)) then
		return self:number();
	end
	
	-- Symbols
	if(is(self, self.SymbolCharsLookup)) then
		return self:symbol();
	end
	

	logger:error(generateError(self, "Unexpected char \"" .. escape(peek(self)) .. "\"!"));
end

function Tokenizer:scanAll()
	local tb = {};
	repeat
		local token = self:next();
		table.insert(tb, token);
	until token.kind == Tokenizer.TokenKind.Eof
	return tb
end

return Tokenizer

end;modules['obfLT9.scope'] = function()
local logger = require("logger");
local config = require("config");

local Scope = {};

local scopeI = 0;
local function nextName()
	scopeI = scopeI + 1;
	return "local_scope_" .. tostring(scopeI);
end

local function generateWarning(token, message)
	return "Warning at Position " .. tostring(token.line) .. ":" .. tostring(token.linePos) .. ", " .. message;
end

-- Create a new Local Scope
function Scope:new(parentScope, name)
	local scope = {
		isGlobal = false,
		parentScope = parentScope,
		variables = {},
		referenceCounts = {};
		variablesLookup = {},
		variablesFromHigherScopes = {},
		skipIdLookup = {};
		name = name or nextName(),
		children = {},
		level = parentScope.level and (parentScope.level + 1) or 1;
	}
	
	setmetatable(scope, self);
	self.__index = self;
	parentScope:addChild(scope);
	return scope;
end

-- Create a new Global Scope
function Scope:newGlobal()
	local scope = {
		isGlobal = true,
		parentScope = nil,
		variables = {},
		variablesLookup = {};
		referenceCounts = {};
		skipIdLookup = {};
		name = "global_scope",
		children = {},
		level = 0,
	};
	
	setmetatable(scope, self);
	self.__index = self;
	
	return scope;
end

-- Returns the Parent Scope
function Scope:getParent(parentScope)
	return self.parentScope;
end

function Scope:setParent(parentScope)
	self.parentScope:removeChild(self);
	parentScope:addChild(self);
	self.parentScope = parentScope;
	self.level = parentScope.level + 1;
end

local next_name_i = 1;
-- Adds a Variable to the scope and returns the variable id, if no name is passed then a name is generated
function Scope:addVariable(name, token)
	if (not name) then
		name = string.format("%s%i", config.IdentPrefix, next_name_i);
		next_name_i = next_name_i + 1;
	end
	
	if self.variablesLookup[name] ~= nil then
		if(token) then
			logger:warn(generateWarning(token, "the variable \"" .. name .. "\" is already defined in that scope"));
		else
			logger:error(string.format("A variable with the name \"%s\" was already defined, you should have no variables starting with \"%s\"", name, config.IdentPrefix));
		end
		
		--return self.variablesLookup[name];
	end
	
	table.insert(self.variables, name);
	local id = #self.variables;
	self.variablesLookup[name] = id;
	return id;
end

function Scope:enableVariable(id)
	local name = self.variables[id];
	self.variablesLookup[name] = id;
end

function Scope:addDisabledVariable(name, token)
	if (not name) then
		name = string.format("%s%i", config.IdentPrefix, next_name_i);
		next_name_i = next_name_i + 1;
	end
	
	if self.variablesLookup[name] ~= nil then
		if(token) then
			logger:warn(generateWarning(token, "the variable \"" .. name .. "\" is already defined in that scope"));
		else
			logger:warn(string.format("a variable with the name \"%s\" was already defined", name));
		end
		
		--return self.variablesLookup[name];
	end
	
	table.insert(self.variables, name);
	local id = #self.variables;
	return id;
end

function Scope:addIfNotExists(id)
	if(not self.variables[id]) then
		local name = string.format("%s%i", config.IdentPrefix, next_name_i);
		next_name_i = next_name_i + 1;
		self.variables[id] = name;
		self.variablesLookup[name] = id;
	end
	return id;
end

-- Returns wether the variable is defined in this Scope
function Scope:hasVariable(name)
	if(self.isGlobal) then
		if self.variablesLookup[name] == nil then
			self:addVariable(name);
		end
		return true;
	end
	return self.variablesLookup[name] ~= nil;
end

-- Get List of all Variables defined in this Scope
function Scope:getVariables()
	return self.variables;
end

function Scope:resetReferences(id)
	self.referenceCounts[id] = 0;
end

function Scope:getReferences(id)
	return self.referenceCounts[id] or 0;
end

function Scope:removeReference(id)
	self.referenceCounts[id] = (self.referenceCounts[id] or 0) - 1;
end

function Scope:addReference(id)
	self.referenceCounts[id] = (self.referenceCounts[id] or 0) + 1;
end

-- Resolve the scope of a variable by name
function Scope:resolve(name)
	if(self:hasVariable(name)) then
		return self, self.variablesLookup[name];
	end
	assert(self.parentScope, "No Global Variable Scope was Created! This should not be Possible!");
	local scope, id = self.parentScope:resolve(name);
	self:addReferenceToHigherScope(scope, id, nil, true);
	return scope, id;
end

function Scope:resolveGlobal(name)
	if(self.isGlobal and self:hasVariable(name)) then
		return self, self.variablesLookup[name];
	end
	assert(self.parentScope, "No Global Variable Scope was Created! This should not be Possible!");
	local scope, id = self.parentScope:resolveGlobal(name);
	self:addReferenceToHigherScope(scope, id, nil, true);
	return scope, id;
end

-- Returns the name of an Variable by id - this is used for unparsing
function Scope:getVariableName(id)
	return self.variables[id];
end

-- Remove A Variable from this Scope
function Scope:removeVariable(id)
	local name = self.variables[id];
	self.variables[id] = nil;
	self.variablesLookup[name] = nil;
	self.skipIdLookup[id] = true;
end

-- Add a Children Scope
function Scope:addChild(scope)
	-- This will add all References from that Scope to higher Scopes. Note that the higher scopes may only be global
	for scope, ids in pairs(scope.variablesFromHigherScopes) do
		for id, count in pairs(ids) do
			if count and count > 0 then
				self:addReferenceToHigherScope(scope, id, count);
			end
		end
	end
	table.insert(self.children, scope);
end

function Scope:clearReferences()
	self.referenceCounts = {};
	self.variablesFromHigherScopes = {};
end

function Scope:removeChild(child)
	for i, v in ipairs(self.children) do
		if(v == child) then
			-- This will add all References from that Scope to higher Scopes. Note that the higher scopes may only be global
			for scope, ids in pairs(v.variablesFromHigherScopes) do
				for id, count in pairs(ids) do
					if count and count > 0 then
						self:removeReferenceToHigherScope(scope, id, count);
					end
				end
			end
			return table.remove(self.children, i);
		end
	end
end

function Scope:getMaxId()
	return #self.variables;
end

function Scope:addReferenceToHigherScope(scope, id, n, b)
	n = n or 1;
	if self.isGlobal then
		if not scope.isGlobal then
			logger:error(string.format("Could not resolve Scope \"%s\"", scope.name))
		end
		return
	end
	if scope == self then
		self.referenceCounts[id] = (self.referenceCounts[id] or 0) + n;
		return
	end
	if not self.variablesFromHigherScopes[scope] then
		self.variablesFromHigherScopes[scope] = {};
	end
	local scopeReferences = self.variablesFromHigherScopes[scope];
	if scopeReferences[id] then
		scopeReferences[id]  = scopeReferences[id] + n;
	else
		scopeReferences[id] = n;
	end
	if not b then
		self.parentScope:addReferenceToHigherScope(scope, id, n);
	end
end

function Scope:removeReferenceToHigherScope(scope, id, n, b)
	n = n or 1;
	if self.isGlobal then
		return
	end
	if scope == self then
		self.referenceCounts[id] = (self.referenceCounts[id] or 0) - n;
		return
	end
	if not self.variablesFromHigherScopes[scope] then
		self.variablesFromHigherScopes[scope] = {};
	end
	local scopeReferences = self.variablesFromHigherScopes[scope];
	if scopeReferences[id] then
		scopeReferences[id]  = scopeReferences[id] - n;
	else
		scopeReferences[id] = 0;
	end
	if not b then
		self.parentScope:removeReferenceToHigherScope(scope, id, n);
	end
end

-- Rename Variables from that scope downwards
-- this function needs a settings object with the following properties
-- Keywords => forbidden Variable Names
-- generateName(id, scope, originalName) => function to generate unique variable name based on the id and scope
function Scope:renameVariables(settings)
	if(not self.isGlobal) then
		local prefix = settings.prefix or "";
		local forbiddenNamesLookup = {};
		for _, keyword in pairs(settings.Keywords) do
			forbiddenNamesLookup[keyword] = true;
		end
		
		for scope, ids in pairs(self.variablesFromHigherScopes) do
			for id, count in pairs(ids) do
				if count and count > 0 then
					local name = scope:getVariableName(id);
					forbiddenNamesLookup[name] = true;
				end
			end
		end
		
		self.variablesLookup = {};
		
		local i = 0;
		for id, originalName in pairs(self.variables) do
			if(not self.skipIdLookup[id] and (self.referenceCounts[id] or 0) >= 0) then
				local name;
				repeat
					name = prefix .. settings.generateName(i, self, originalName);
					if name == nil then
						name = originalName;
					end
					i = i + 1;
				until not forbiddenNamesLookup[name];

				self.variables[id] = name;
				self.variablesLookup[name] = id;
			end
		end
	end
	
	for _, scope in pairs(self.children) do
		scope:renameVariables(settings);
	end
end
setmetatable(Scope, {
    __call = Scope.new,
})
return Scope;
end;modules['obfLT9.unparser'] = function()
local config = require("config");
local Ast    = require("obfLT9.ast");
local Enums  = require("obfLT9.enums");
local util = require("obfLT9.util");
local logger = require("logger");

local lookupify = util.lookupify;
local LuaVersion = Enums.LuaVersion;
local AstKind = Ast.AstKind;

local Unparser = {}

Unparser.SPACE = config.SPACE;
Unparser.TAB = config.TAB;

local function escapeString(str)
	str = util.escape(str)
	return str;
end
    

function Unparser:new(settings)
	local luaVersion = (settings and (settings.luaVersion or settings.LuaVersion)) or LuaVersion.Lua53;
	local conventions = Enums.Conventions[luaVersion];
	local unparser = {
		luaVersion = luaVersion;
		conventions = conventions;
		identCharsLookup = lookupify(conventions.IdentChars);
		numberCharsLookup = lookupify(conventions.NumberChars);
		prettyPrint = settings and settings.PrettyPrint or false;
		notIdentPattern = "[^" .. table.concat(conventions.IdentChars, "") .. "]";
		numberPattern = "^[" .. table.concat(conventions.NumberChars, "") .. "]";
		highlight     = settings and settings.Highlight or false;
		keywordsLookup = lookupify(conventions.Keywords);
	}
	
	setmetatable(unparser, self);
	self.__index = self;
	
	return unparser;
end

function Unparser:isValidIdentifier(source)
	if(string.find(source, self.notIdentPattern)) then
		return false;
	end
	if(string.find(source, self.numberPattern)) then
		return false;
	end
	if self.keywordsLookup[source] then
		return false;
	end
	return #source > 0;
end

function Unparser:setPrettyPrint(prettyPrint)
	self.prettyPrint = prettyPrint;
end

function Unparser:getPrettyPrint()
	return self.prettyPrint;
end

function Unparser:tabs(i, ws_needed)
	return self.prettyPrint and string.rep(self.TAB, i) or ws_needed and self.SPACE or "";
end

function Unparser:newline(ws_needed)
	return self.prettyPrint and "\n" or ws_needed and self.SPACE or "";
end

function Unparser:whitespaceIfNeeded(following, ws)
	if(self.prettyPrint or self.identCharsLookup[string.sub(following, 1, 1)]) then
		return ws or self.SPACE;
	end
	return "";
end

function Unparser:whitespaceIfNeeded2(leading, ws)
	if(self.prettyPrint or self.identCharsLookup[string.sub(leading, #leading, #leading)]) then
		return ws or self.SPACE;
	end
	return "";
end

function Unparser:optionalWhitespace(ws)
	return self.prettyPrint and (ws or self.SPACE) or "";
end

function Unparser:whitespace(ws)
	return self.SPACE or ws;
end

function Unparser:unparse(ast)
	if(ast.kind ~= AstKind.TopNode) then
		logger:error("Unparser:unparse expects a TopNode as first argument")
	end
	
	return self:unparseBlock(ast.body);
end

function Unparser:unparseBlock(block, tabbing)
	local code = "";
	
	if(#block.stats < 1) then
		return self:whitespace();
	end
	
	for i, stat in ipairs(block.stats) do
		if(stat.kind ~= AstKind.NopStat) then
			local statCode = self:unparseStat(stat, tabbing);
			if(not self.prettyPrint and #code > 0 and string.sub(statCode, 1, 1) == "(") then
				-- This is so that the following works:
				-- print("Test");(function() print("Test2") end)();
				statCode = ";" .. statCode;
			end
			local ws = self:whitespaceIfNeeded2(code, self:whitespaceIfNeeded(statCode, self:newline(true)));
			if i ~= 1 then
				code = code .. ws;
			end
			if(self.prettyPrint) then
				statCode = statCode .. ";"
			end
			code = code .. statCode;
		end
	end
	
	return code;
end

function Unparser:unparseStat(stat, tabbing)
	tabbing = tabbing and tabbing + 1 or 0;
	local code = "";
	
	if(stat.kind == AstKind.ContinueStat) then
		code = "continue";
		
	-- Break Stat
	elseif(stat.kind == AstKind.BreakStat) then
		code = "break";
		
	-- Label Stat
	elseif(stat.kind == AstKind.LabelStat) then
		code = "::" .. stat.label .. "::";
		
	-- Goto Stat
	elseif(stat.kind == AstKind.GotoStat) then
		code = "goto " .. stat.label;
		
		
	-- Do Stat
	elseif(stat.kind == AstKind.DoStat) then
		local bodyCode = self:unparseBlock(stat.body, tabbing);
		code = "do" ..  self:whitespaceIfNeeded(bodyCode, self:newline(true))
			.. bodyCode .. self:newline(false)
			.. self:whitespaceIfNeeded2(bodyCode, self:tabs(tabbing, true)) .. "end";
		
	-- While Stat
	elseif(stat.kind == AstKind.WhileStat) then
		local expCode = self:unparseExpr(stat.condition, tabbing);
		
		local bodyCode = self:unparseBlock(stat.body, tabbing);
		
		
		code = "while" .. self:whitespaceIfNeeded(expCode) .. expCode .. self:whitespaceIfNeeded2(expCode) 
			.. "do" .. self:whitespaceIfNeeded(bodyCode, self:newline(true))
			.. bodyCode .. self:newline(false)
			.. self:whitespaceIfNeeded2(bodyCode, self:tabs(tabbing, true)) .. "end";
			
	-- Repeat Until Stat
	elseif(stat.kind == AstKind.RepeatStat) then
		local expCode = self:unparseExpr(stat.condition, tabbing);

		local bodyCode = self:unparseBlock(stat.body, tabbing);


		code = "repeat" ..  self:whitespaceIfNeeded(bodyCode, self:newline(true))
			.. bodyCode
			.. self:whitespaceIfNeeded2(bodyCode, self:newline() .. self:tabs(tabbing, true)) .. "until" .. self:whitespaceIfNeeded(expCode) .. expCode;

	-- For Stat
	elseif(stat.kind == AstKind.ForStat) then
		local bodyCode = self:unparseBlock(stat.body, tabbing);
		
		code = "for" .. self:whitespace() .. stat.scope:getVariableName(stat.id) .. self:optionalWhitespace() .. "=";
		code = code .. self:optionalWhitespace() .. self:unparseExpr(stat.initialValue, tabbing) .. ",";
		code = code .. self:optionalWhitespace() .. self:unparseExpr(stat.finalValue, tabbing) .. ",";
		
		local incrementByCode = stat.incrementBy and self:unparseExpr(stat.incrementBy, tabbing) or "1";
		code = code .. self:optionalWhitespace() .. incrementByCode .. self:whitespaceIfNeeded2(incrementByCode)  .. "do" .. self:whitespaceIfNeeded(bodyCode, self:newline(true))
			.. bodyCode .. self:newline(false)
			.. self:whitespaceIfNeeded2(bodyCode, self:tabs(tabbing, true)) .. "end";
		
		
	-- For In Stat
	elseif(stat.kind == AstKind.ForInStat) then
		code = "for" .. self:whitespace();
		
		for i, id in ipairs(stat.ids) do
			if(i ~= 1) then
				code = code .. "," .. self:optionalWhitespace();
			end
			
			code = code .. stat.scope:getVariableName(id);
		end
		
		code = code .. self:whitespace() .. "in";
		
		local exprcode = self:unparseExpr(stat.exps[1], tabbing);
		code = code .. self:whitespaceIfNeeded(exprcode) .. exprcode;
		for i = 2, #stat.exps, 1 do
			exprcode = self:unparseExpr(stat.exps[i], tabbing);
			code = code .. "," .. self:optionalWhitespace() .. exprcode;
		end
		
		local bodyCode = self:unparseBlock(stat.body, tabbing);
		code = code .. self:whitespaceIfNeeded2(code) .. "do" .. self:whitespaceIfNeeded(bodyCode, self:newline(true))
			.. bodyCode .. self:newline(false)
			.. self:whitespaceIfNeeded2(bodyCode, self:tabs(tabbing, true)) .. "end";
		
		
	-- If Stat
	elseif(stat.kind == AstKind.IfStat) then
		local exprcode = self:unparseExpr(stat.condition, tabbing);
		
		local bodyCode = self:unparseBlock(stat.body, tabbing);
		code = "if" .. self:whitespaceIfNeeded(exprcode) .. exprcode .. self:whitespaceIfNeeded2(exprcode) .. "then" .. self:whitespaceIfNeeded(bodyCode, self:newline(true))
			.. bodyCode;
		
		for i, eif in ipairs(stat.elseifs) do
			exprcode = self:unparseExpr(eif.condition, tabbing);
			bodyCode = self:unparseBlock(eif.body, tabbing);
			code = code .. self:newline(false) .. self:whitespaceIfNeeded2(code, self:tabs(tabbing, true)) .. "elseif" .. self:whitespaceIfNeeded(exprcode) .. exprcode .. self:whitespaceIfNeeded2(exprcode) 
				.. "then" .. self:whitespaceIfNeeded(bodyCode, self:newline(true))
				.. bodyCode;
		end
		
		if(stat.elsebody) then
			bodyCode = self:unparseBlock(stat.elsebody, tabbing);
			code = code .. self:newline(false) .. self:whitespaceIfNeeded2(code, self:tabs(tabbing, true)) .. "else" .. self:whitespaceIfNeeded(bodyCode, self:newline(true))
				.. bodyCode;
		end
		
		code = code .. self:newline(false) .. self:whitespaceIfNeeded2(bodyCode, self:tabs(tabbing, true)) .. "end";
		
		
	-- Function Decl
	elseif(stat.kind == AstKind.FunctionDecl) then
		local funcname = stat.scope:getVariableName(stat.id);
		for _, index in ipairs(stat.indices) do
			funcname = funcname .. "." .. index;
		end
		
		code = "function" .. self:whitespace() .. funcname .. "(";
		
		for i, arg in ipairs(stat.args) do
			if i > 1 then
				code = code .. "," .. self:optionalWhitespace();
			end
			if(arg.kind == AstKind.VarargExpr) then
				code = code .. "...";
			else
				code = code .. arg.scope:getVariableName(arg.id);
			end
		end
		code = code .. ")";
		
		local bodyCode = self:unparseBlock(stat.body, tabbing);
		code = code .. self:newline(false) .. bodyCode .. self:newline(false) .. self:whitespaceIfNeeded2(bodyCode, self:tabs(tabbing, true)) .. "end";
		
		
	-- Local Function Decl
	elseif(stat.kind == AstKind.LocalFunctionDecl) then
		local funcname = stat.scope:getVariableName(stat.id);
		code = "local" ..  self:whitespace() .. "function" .. self:whitespace() .. funcname .. "(";
		
		for i, arg in ipairs(stat.args) do
			if i > 1 then
				code = code .. "," .. self:optionalWhitespace();
			end
			if(arg.kind == AstKind.VarargExpr) then
				code = code .. "...";
			else
				code = code .. arg.scope:getVariableName(arg.id);
			end
		end
		code = code .. ")";

		local bodyCode = self:unparseBlock(stat.body, tabbing);
		code = code .. self:newline(false) .. bodyCode .. self:newline(false) .. self:whitespaceIfNeeded2(bodyCode, self:tabs(tabbing, true)) .. "end";
		
	-- Local Variable Decl
	elseif(stat.kind == AstKind.LocalVariableDecl) then
		code = "local" .. self:whitespace();
		
		for i, id in ipairs(stat.ids) do
			if i > 1 then
				code = code .. "," .. self:optionalWhitespace();
			end
			code = code .. stat.scope:getVariableName(id);
		end

		if(#stat.exps > 0) then
			code = code .. self:optionalWhitespace() .. "=" .. self:optionalWhitespace();
			for i, expr in ipairs(stat.exps) do
				if i > 1 then
					code = code .. "," .. self:optionalWhitespace();
				end
				code = code .. self:unparseExpr(expr, tabbing + 1);
			end
		end
	-- Function Call Stat
	elseif(stat.kind == AstKind.FunctionCallStat) then
		if not (stat.base.kind == AstKind.IndexExpr or stat.base.kind == AstKind.VariableExpr) then
			code = "(" .. self:unparseExpr(stat.base, tabbing) .. ")";
		else
			code = self:unparseExpr(stat.base, tabbing);
		end
		
		code = code .. "(";
		
		for i, arg in ipairs(stat.args) do
			if i > 1 then
				code = code .. "," .. self:optionalWhitespace();
			end
			code = code .. self:unparseExpr(arg, tabbing);
		end
		
		code = code .. ")";
		
	-- Pass Self Function Call Stat
	elseif(stat.kind == AstKind.PassSelfFunctionCallStat) then
		if not (stat.base.kind == AstKind.IndexExpr or stat.base.kind == AstKind.VariableExpr) then
			code = "(" .. self:unparseExpr(stat.base, tabbing) .. ")";
		else
			code = self:unparseExpr(stat.base, tabbing);
		end

		code = code .. ":" .. stat.passSelfFunctionName;

		code = code .. "(";

		for i, arg in ipairs(stat.args) do
			if i > 1 then
				code = code .. "," .. self:optionalWhitespace();
			end
			code = code .. self:unparseExpr(arg, tabbing);
		end

		code = code .. ")";
		
		
	elseif(stat.kind == AstKind.AssiStat) then
		for i, primary_expr in ipairs(stat.lhs) do
			if i > 1 then
				code = code .. "," .. self:optionalWhitespace();
			end
			code = code .. self:unparseExpr(primary_expr, tabbing);
		end
		
		code = code .. self:optionalWhitespace() .. "=" .. self:optionalWhitespace();
		
		for i, expr in ipairs(stat.rhs) do
			if i > 1 then
				code = code .. "," .. self:optionalWhitespace();
			end
			code = code .. self:unparseExpr(expr, tabbing + 1);
		end
		
	-- Return Stat
	elseif(stat.kind == AstKind.ReturnStat) then
		code = "return";
		if(#stat.args > 0) then
			local exprcode = self:unparseExpr(stat.args[1], tabbing);
			code = code .. self:whitespaceIfNeeded(exprcode) .. exprcode;
			for i = 2, #stat.args, 1 do
				exprcode = self:unparseExpr(stat.args[i], tabbing);
				code = code .. "," .. self:optionalWhitespace() .. exprcode;
			end
		end
	elseif self.luaVersion == LuaVersion.LuaU then
		local compoundOperators = {
		    [AstKind.CompoundAddStat] = "+=",
		    [AstKind.CompoundSubStat] = "-=",
		    [AstKind.CompoundMulStat] = "*=",
		    [AstKind.CompoundDivStat] = "/=",
		    [AstKind.CompoundModStat] = "%=",
		    [AstKind.CompoundPowStat] = "^=",
		    [AstKind.CompoundConcatStat] = "..=",
		}
		
		local operator = compoundOperators[stat.kind]
		if operator then
		    code = code .. self:unparseExpr(stat.lhs, tabbing) .. self:optionalWhitespace() .. operator .. self:optionalWhitespace() .. self:unparseExpr(stat.rhs, tabbing)
		else
		    logger:error(string.format("\"%s\" is not a valid unparseable stat in %s!", stat.kind, self.luaVersion))
		end
	end
	
	return self:tabs(tabbing, false) .. code;
end

local function randomTrueNode()
	local op = math.random(1, 2);
	if(op == 1) then
		-- Less than
		local a = math.random(1, 9)
		local b = math.random(0, a - 1);
		return tostring(a) .. ">" .. tostring(b);
	else
		-- Greater than
		local a = math.random(1, 9)
		local b = math.random(0, a - 1);
		return tostring(b) .. "<" .. tostring(a);
	end
end

local function randomFalseNode()
	local op = math.random(1, 2);
	if(op == 1) then
		-- Less than
		local a = math.random(1, 9)
		local b = math.random(0, a - 1);
		return tostring(b) .. ">" .. tostring(a);
	else
		-- Greater than
		local a = math.random(1, 9)
		local b = math.random(0, a - 1);
		return tostring(a) .. "<" .. tostring(b);
	end
end

function Unparser:unparseExpr(exp, tabbing)
	local code = "";
	
	if(exp.kind == AstKind.BooleanExpr) then
		if(exp.value) then
			return "true";
		else
			return "false";
		end
	end
	
	if(exp.kind == AstKind.NumberExpr) then
		local str = tostring(exp.value);
		if(str == "inf") then
			return "2e1024"
		end
		if(str == "-inf") then
			return "-2e1024"
		end
		if(str:sub(1, 2) == "0.") then
			str = str:sub(2);
		end
		return str;
	end
	
	if(exp.kind == AstKind.VariableExpr or exp.kind == AstKind.AssiVariable) then
			return exp.scope:getVariableName(exp.id);
	end
	
	if(exp.kind == AstKind.StringExpr) then
		return "\"" .. escapeString(exp.value) .. "\"";
	end
	
	if(exp.kind == AstKind.NilExpr) then
		return "nil";
	end
	
	if(exp.kind == AstKind.VarargExpr) then
		return "...";
	end
	
	local k = AstKind.OrExpr;
	if(exp.kind == k) then
		local lhs = self:unparseExpr(exp.lhs, tabbing);
		local rhs = self:unparseExpr(exp.rhs, tabbing);
		return lhs .. self:whitespaceIfNeeded2(lhs) .. "or" .. self:whitespaceIfNeeded(rhs) .. rhs;
	end
	
	k = AstKind.AndExpr;
	if(exp.kind == k) then
		local lhs = self:unparseExpr(exp.lhs, tabbing);
		if(Ast.astKindExprToNumber(exp.lhs.kind) >= Ast.astKindExprToNumber(k)) then
			lhs = "(" .. lhs .. ")";
		end
		
		local rhs = self:unparseExpr(exp.rhs, tabbing);
		if(Ast.astKindExprToNumber(exp.rhs.kind) >= Ast.astKindExprToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end
		
		return lhs .. self:whitespaceIfNeeded2(lhs) .. "and" .. self:whitespaceIfNeeded(rhs) .. rhs;
	end
	
	k = AstKind.LessThanExpr;
	if(exp.kind == k) then
		local lhs = self:unparseExpr(exp.lhs, tabbing);
		if(Ast.astKindExprToNumber(exp.lhs.kind) >= Ast.astKindExprToNumber(k)) then
			lhs = "(" .. lhs .. ")";
		end

		local rhs = self:unparseExpr(exp.rhs, tabbing);
		if(Ast.astKindExprToNumber(exp.rhs.kind) >= Ast.astKindExprToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		return lhs .. self:optionalWhitespace() .. "<" .. self:optionalWhitespace() .. rhs;
	end
	
	k = AstKind.GreaterThanExpr;
	if(exp.kind == k) then
		local lhs = self:unparseExpr(exp.lhs, tabbing);
		if(Ast.astKindExprToNumber(exp.lhs.kind) >= Ast.astKindExprToNumber(k)) then
			lhs = "(" .. lhs .. ")";
		end

		local rhs = self:unparseExpr(exp.rhs, tabbing);
		if(Ast.astKindExprToNumber(exp.rhs.kind) >= Ast.astKindExprToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		return lhs .. self:optionalWhitespace() .. ">" .. self:optionalWhitespace() .. rhs;
	end
	
	k = AstKind.LessThanOrEqualsExpr;
	if(exp.kind == k) then
		local lhs = self:unparseExpr(exp.lhs, tabbing);
		if(Ast.astKindExprToNumber(exp.lhs.kind) >= Ast.astKindExprToNumber(k)) then
			lhs = "(" .. lhs .. ")";
		end

		local rhs = self:unparseExpr(exp.rhs, tabbing);
		if(Ast.astKindExprToNumber(exp.rhs.kind) >= Ast.astKindExprToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		return lhs .. self:optionalWhitespace() .. "<=" .. self:optionalWhitespace() .. rhs;
	end
	
	k = AstKind.GreaterThanOrEqualsExpr;
	if(exp.kind == k) then
		local lhs = self:unparseExpr(exp.lhs, tabbing);
		if(Ast.astKindExprToNumber(exp.lhs.kind) >= Ast.astKindExprToNumber(k)) then
			lhs = "(" .. lhs .. ")";
		end

		local rhs = self:unparseExpr(exp.rhs, tabbing);
		if(Ast.astKindExprToNumber(exp.rhs.kind) >= Ast.astKindExprToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		return lhs .. self:optionalWhitespace() .. ">=" .. self:optionalWhitespace() .. rhs;
	end
	
	k = AstKind.NotEqualsExpr;
	if(exp.kind == k) then
		local lhs = self:unparseExpr(exp.lhs, tabbing);
		if(Ast.astKindExprToNumber(exp.lhs.kind) >= Ast.astKindExprToNumber(k)) then
			lhs = "(" .. lhs .. ")";
		end

		local rhs = self:unparseExpr(exp.rhs, tabbing);
		if(Ast.astKindExprToNumber(exp.rhs.kind) >= Ast.astKindExprToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		return lhs .. self:optionalWhitespace() .. "~=" .. self:optionalWhitespace() .. rhs;
	end
	
	k = AstKind.EqualsExpr;
	if(exp.kind == k) then
		local lhs = self:unparseExpr(exp.lhs, tabbing);
		if(Ast.astKindExprToNumber(exp.lhs.kind) >= Ast.astKindExprToNumber(k)) then
			lhs = "(" .. lhs .. ")";
		end

		local rhs = self:unparseExpr(exp.rhs, tabbing);
		if(Ast.astKindExprToNumber(exp.rhs.kind) >= Ast.astKindExprToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		return lhs .. self:optionalWhitespace() .. "==" .. self:optionalWhitespace() .. rhs;
	end
	
	k = AstKind.StrCatExpr;
	if(exp.kind == k) then
		local lhs = self:unparseExpr(exp.lhs, tabbing);
		if(Ast.astKindExprToNumber(exp.lhs.kind) >= Ast.astKindExprToNumber(k)) then
			lhs = "(" .. lhs .. ")";
		end

		local rhs = self:unparseExpr(exp.rhs, tabbing);
		if(Ast.astKindExprToNumber(exp.rhs.kind) >= Ast.astKindExprToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		if(self.numberCharsLookup[string.sub(lhs, #lhs, #lhs)]) then
			lhs = lhs .. " ";
		end
		
		return lhs .. --[[self:optionalWhitespace() ..]] " .. " --[[.. self:optionalWhitespace()]] .. rhs;
	end
	
	k = AstKind.AddExpr;
	if(exp.kind == k) then
		local lhs = self:unparseExpr(exp.lhs, tabbing);
		if(Ast.astKindExprToNumber(exp.lhs.kind) >= Ast.astKindExprToNumber(k)) then
			lhs = "(" .. lhs .. ")";
		end

		local rhs = self:unparseExpr(exp.rhs, tabbing);
		if(Ast.astKindExprToNumber(exp.rhs.kind) >= Ast.astKindExprToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		return lhs .. self:optionalWhitespace() .. "+" .. self:optionalWhitespace() .. rhs;
	end
	
	k = AstKind.SubExpr;
	if(exp.kind == k) then
		local lhs = self:unparseExpr(exp.lhs, tabbing);
		if(Ast.astKindExprToNumber(exp.lhs.kind) >= Ast.astKindExprToNumber(k)) then
			lhs = "(" .. lhs .. ")";
		end

		local rhs = self:unparseExpr(exp.rhs, tabbing);
		if(Ast.astKindExprToNumber(exp.rhs.kind) >= Ast.astKindExprToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		if string.sub(rhs, 1, 1) == "-" then
			rhs = "(" .. rhs .. ")";
		end 

		return lhs .. self:optionalWhitespace() .. "-" .. self:optionalWhitespace() .. rhs;
	end
	
	k = AstKind.MulExpr;
	if(exp.kind == k) then
		local lhs = self:unparseExpr(exp.lhs, tabbing);
		if(Ast.astKindExprToNumber(exp.lhs.kind) >= Ast.astKindExprToNumber(k)) then
			lhs = "(" .. lhs .. ")";
		end

		local rhs = self:unparseExpr(exp.rhs, tabbing);
		if(Ast.astKindExprToNumber(exp.rhs.kind) >= Ast.astKindExprToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		return lhs .. self:optionalWhitespace() .. "*" .. self:optionalWhitespace() .. rhs;
	end
	
	k = AstKind.DivExpr;
	if(exp.kind == k) then
		local lhs = self:unparseExpr(exp.lhs, tabbing);
		if(Ast.astKindExprToNumber(exp.lhs.kind) >= Ast.astKindExprToNumber(k)) then
			lhs = "(" .. lhs .. ")";
		end

		local rhs = self:unparseExpr(exp.rhs, tabbing);
		if(Ast.astKindExprToNumber(exp.rhs.kind) >= Ast.astKindExprToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		return lhs .. self:optionalWhitespace() .. "/" .. self:optionalWhitespace() .. rhs;
	end
	
	k = AstKind.ModExpr;
	if(exp.kind == k) then
		local lhs = self:unparseExpr(exp.lhs, tabbing);
		if(Ast.astKindExprToNumber(exp.lhs.kind) >= Ast.astKindExprToNumber(k)) then
			lhs = "(" .. lhs .. ")";
		end

		local rhs = self:unparseExpr(exp.rhs, tabbing);
		if(Ast.astKindExprToNumber(exp.rhs.kind) >= Ast.astKindExprToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		return lhs .. self:optionalWhitespace() .. "%" .. self:optionalWhitespace() .. rhs;
	end
	
	--5.3
	k = AstKind.BandExpr;
	if(exp.kind == k) then
		local lhs = self:unparseExpr(exp.lhs, tabbing);
		if(Ast.astKindExprToNumber(exp.lhs.kind) >= Ast.astKindExprToNumber(k)) then
			lhs = "(" .. lhs .. ")";
		end

		local rhs = self:unparseExpr(exp.rhs, tabbing);
		if(Ast.astKindExprToNumber(exp.rhs.kind) >= Ast.astKindExprToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		return lhs .. self:optionalWhitespace() .. "&" .. self:optionalWhitespace() .. rhs;
	end
	
	k = AstKind.BxorExpr;
	if(exp.kind == k) then
		local lhs = self:unparseExpr(exp.lhs, tabbing);
		if(Ast.astKindExprToNumber(exp.lhs.kind) >= Ast.astKindExprToNumber(k)) then
			lhs = "(" .. lhs .. ")";
		end

		local rhs = self:unparseExpr(exp.rhs, tabbing);
		if(Ast.astKindExprToNumber(exp.rhs.kind) >= Ast.astKindExprToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		return lhs .. self:optionalWhitespace() .. "~" .. self:optionalWhitespace() .. rhs;
	end
	
	k = AstKind.BorExpr;
	if(exp.kind == k) then
		local lhs = self:unparseExpr(exp.lhs, tabbing);
		if(Ast.astKindExprToNumber(exp.lhs.kind) >= Ast.astKindExprToNumber(k)) then
			lhs = "(" .. lhs .. ")";
		end

		local rhs = self:unparseExpr(exp.rhs, tabbing);
		if(Ast.astKindExprToNumber(exp.rhs.kind) >= Ast.astKindExprToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		return lhs .. self:optionalWhitespace() .. "|" .. self:optionalWhitespace() .. rhs;
	end
	
	k = AstKind.ShlExpr;
	if(exp.kind == k) then
		local lhs = self:unparseExpr(exp.lhs, tabbing);
		if(Ast.astKindExprToNumber(exp.lhs.kind) >= Ast.astKindExprToNumber(k)) then
			lhs = "(" .. lhs .. ")";
		end

		local rhs = self:unparseExpr(exp.rhs, tabbing);
		if(Ast.astKindExprToNumber(exp.rhs.kind) >= Ast.astKindExprToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		return lhs .. self:optionalWhitespace() .. "<<" .. self:optionalWhitespace() .. rhs;
	end
	
	k = AstKind.ShrExpr;
	if(exp.kind == k) then
		local lhs = self:unparseExpr(exp.lhs, tabbing);
		if(Ast.astKindExprToNumber(exp.lhs.kind) >= Ast.astKindExprToNumber(k)) then
			lhs = "(" .. lhs .. ")";
		end

		local rhs = self:unparseExpr(exp.rhs, tabbing);
		if(Ast.astKindExprToNumber(exp.rhs.kind) >= Ast.astKindExprToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		return lhs .. self:optionalWhitespace() .. ">>" .. self:optionalWhitespace() .. rhs;
	end
	
	k = AstKind.IdivExpr;
	if(exp.kind == k) then
		local lhs = self:unparseExpr(exp.lhs, tabbing);
		if(Ast.astKindExprToNumber(exp.lhs.kind) >= Ast.astKindExprToNumber(k)) then
			lhs = "(" .. lhs .. ")";
		end

		local rhs = self:unparseExpr(exp.rhs, tabbing);
		if(Ast.astKindExprToNumber(exp.rhs.kind) >= Ast.astKindExprToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		return lhs .. self:optionalWhitespace() .. "//" .. self:optionalWhitespace() .. rhs;
	end
	
	k = AstKind.PowExpr;
	if(exp.kind == k) then
		local lhs = self:unparseExpr(exp.lhs, tabbing);
		if(Ast.astKindExprToNumber(exp.lhs.kind) >= Ast.astKindExprToNumber(k)) then
			lhs = "(" .. lhs .. ")";
		end

		local rhs = self:unparseExpr(exp.rhs, tabbing);
		if(Ast.astKindExprToNumber(exp.rhs.kind) >= Ast.astKindExprToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		return lhs .. self:optionalWhitespace() .. "^" .. self:optionalWhitespace() .. rhs;
	end
	
	-- Unary Exprs
	k = AstKind.NotExpr;
	if(exp.kind == k) then
		local rhs = self:unparseExpr(exp.rhs, tabbing);
		if(Ast.astKindExprToNumber(exp.rhs.kind) >= Ast.astKindExprToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		return "not" .. self:whitespaceIfNeeded(rhs) .. rhs;
	end
	
	--[[
	k = AstKind.BnotExpr;
	if(exp.kind == k) then
		local rhs = self:unparseExpr(exp.rhs, tabbing);
		if(Ast.astKindExprToNumber(exp.rhs.kind) >= Ast.astKindExprToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		return "~" .. self:whitespaceIfNeeded(rhs) .. rhs;
	end]]
	
	k = AstKind.BnotExpr;
	if(exp.kind == k) then
		local rhs = self:unparseExpr(exp.rhs, tabbing);
		if(Ast.astKindExprToNumber(exp.rhs.kind) >= Ast.astKindExprToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		if string.sub(rhs, 1, 1) == "~" then
			rhs = "(" .. rhs .. ")";
		end 

		return "~" .. rhs;
	end
	
	k = AstKind.NegateExpr;
	if(exp.kind == k) then
		local rhs = self:unparseExpr(exp.rhs, tabbing);
		if(Ast.astKindExprToNumber(exp.rhs.kind) >= Ast.astKindExprToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		if string.sub(rhs, 1, 1) == "-" then
			rhs = "(" .. rhs .. ")";
		end 

		return "-" .. rhs;
	end
	
	k = AstKind.LenExpr;
	if(exp.kind == k) then
		local rhs = self:unparseExpr(exp.rhs, tabbing);
		if(Ast.astKindExprToNumber(exp.rhs.kind) >= Ast.astKindExprToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		return "#" .. rhs;
	end
	
	k = AstKind.IndexExpr;
	if(exp.kind == k or exp.kind == AstKind.AssiIndexing) then
		local base = self:unparseExpr(exp.base, tabbing);
		if(Ast.astKindExprToNumber(exp.base.kind) > Ast.astKindExprToNumber(k)) then
			base = "(" .. base .. ")";
		end
		
		-- Identifier Indexing e.g: x.y instead of x["y"];
		if(exp.index.kind == AstKind.StringExpr and self:isValidIdentifier(exp.index.value)) then
			return base .. "." .. exp.index.value;
		end
		
		-- Index never needs parens
		local index = self:unparseExpr(exp.index, tabbing);
		return base .. "[" .. index .. "]";
	end
	
	k = AstKind.FunctionCallExpr;
	if(exp.kind == k) then
		if not (exp.base.kind == AstKind.IndexExpr or exp.base.kind == AstKind.VariableExpr) then
			code = "(" .. self:unparseExpr(exp.base, tabbing) .. ")";
		else
			code = self:unparseExpr(exp.base, tabbing);
		end

		code = code .. "(";

		for i, arg in ipairs(exp.args) do
			if i > 1 then
				code = code .. "," .. self:optionalWhitespace();
			end
			code = code .. self:unparseExpr(arg, tabbing);
		end

		code = code .. ")";
		return code;
	end
	
	
	k = AstKind.PassSelfFunctionCallExpr;
	if(exp.kind == k) then
		if not (exp.base.kind == AstKind.IndexExpr or exp.base.kind == AstKind.VariableExpr) then
			code = "(" .. self:unparseExpr(exp.base, tabbing) .. ")";
		else
			code = self:unparseExpr(exp.base, tabbing);
		end

		code = code .. ":" .. exp.passSelfFunctionName;

		code = code .. "(";

		for i, arg in ipairs(exp.args) do
			if i > 1 then
				code = code .. "," .. self:optionalWhitespace();
			end
			code = code .. self:unparseExpr(arg, tabbing);
		end

		code = code .. ")";
		return code;
	end
	
	k = AstKind.FunctionLiteralExpr;
	if(exp.kind == k) then
		code = "function" .. "(";

		for i, arg in ipairs(exp.args) do
			if i > 1 then
				code = code .. "," .. self:optionalWhitespace();
			end
			if(arg.kind == AstKind.VarargExpr) then
				code = code .. "...";
			else
				code = code .. arg.scope:getVariableName(arg.id);
			end
		end
		code = code .. ")";

		local bodyCode = self:unparseBlock(exp.body, tabbing);
		code = code .. self:newline(false) .. bodyCode .. self:newline(false) .. self:whitespaceIfNeeded2(bodyCode, self:tabs(tabbing, true)) .. "end";
		return code;
	end
	
	k = AstKind.TableConstructorExpr;
	if(exp.kind == k) then
		if(#exp.entries == 0) then return "{}" end;

		local inlineTable = #exp.entries <= 3;
		local tableTabbing = tabbing + 1;
		code = "{";
		if inlineTable then
			code = code .. self:optionalWhitespace();
		else
			code = code .. self:optionalWhitespace(self:newline() .. self:tabs(tableTabbing));
		end
		
		local p = false;
		for i, entry in ipairs(exp.entries) do
			p = true;
			local sep = self.prettyPrint and "," or (math.random(1, 2) == 1 and "," or ";");
			if i > 1 and not inlineTable then
				code = code .. sep .. self:optionalWhitespace(self:newline() .. self:tabs(tableTabbing));
			elseif i > 1 then
				code = code .. sep .. self:optionalWhitespace();
			end
			if(entry.kind == AstKind.KeyedTableEntry) then
				if(entry.key.kind == AstKind.StringExpr and self:isValidIdentifier(entry.key.value)) then
					code = code .. entry.key.value;
				else
					code = code .. "[" .. self:unparseExpr(entry.key, tableTabbing) .. "]";
				end
				code = code .. self:optionalWhitespace() .. "=" .. self:optionalWhitespace() .. self:unparseExpr(entry.value, tableTabbing);
			else
				code = code .. self:unparseExpr(entry.value, tableTabbing);
			end
		end

		if inlineTable then
			return code .. self:optionalWhitespace() .. "}";
		end
		
		return code .. self:optionalWhitespace((p and "," or "") .. self:newline() .. self:tabs(tabbing)) .. "}";
	end

	logger:error(string.format("\"%s\" is not a valid unparseable exp", exp.kind));
end

setmetatable(Unparser, {
    __call = Unparser.new,
})

return Unparser

end;modules['obfLT9.namegenerators'] = function()
return {
	Mangled = require("obfLT9.namegenerators.mangled");
	MangledShuffled = require("obfLT9.namegenerators.mangled_shuffled");
	Il = require("obfLT9.namegenerators.Il");
	Number = require("obfLT9.namegenerators.number");
	Confuse = require("obfLT9.namegenerators.confuse");
}
end;modules['obfLT9.namegenerators.mangled'] = function()
local util = require("obfLT9.util");
local chararray = util.chararray;

local idGen = 0
local VarDigits = chararray("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_");
local VarStartDigits = chararray("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ");

return function(id, scope)
	local name = ''
	local d = id % #VarStartDigits
	id = (id - d) / #VarStartDigits
	name = name..VarStartDigits[d+1]
	while id > 0 do
		local d = id % #VarDigits
		id = (id - d) / #VarDigits
		name = name..VarDigits[d+1]
	end
	return name
end
end;modules['obfLT9.namegenerators.mangled_shuffled'] = function()
local util = require("obfLT9.util");
local chararray = util.chararray;

local VarDigits = chararray("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_");
local VarStartDigits = chararray("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ");

local function generateName(id, scope)
	local name = ''
	local d = id % #VarStartDigits
	id = (id - d) / #VarStartDigits
	name = name..VarStartDigits[d+1]
	while id > 0 do
		local d = id % #VarDigits
		id = (id - d) / #VarDigits
		name = name..VarDigits[d+1]
	end
	return name
end

local function prepare(ast)
	util.shuffle(VarDigits);
	util.shuffle(VarStartDigits);
end

return {
	generateName = generateName, 
	prepare = prepare
};
end;modules['obfLT9.namegenerators.Il'] = function()
local MIN_CHARACTERS = 5;
local MAX_INITIAL_CHARACTERS = 10;

local util = require("obfLT9.util");
local chararray = util.chararray;

local offset = 0;
local VarDigits = chararray("Il1");
local VarStartDigits = chararray("Il");

local function generateName(id, scope)
	local name = ''
	id = id + offset;
	local d = id % #VarStartDigits
	id = (id - d) / #VarStartDigits
	name = name..VarStartDigits[d+1]
	while id > 0 do
		local d = id % #VarDigits
		id = (id - d) / #VarDigits
		name = name..VarDigits[d+1]
	end
	return name
end

local function prepare(ast)
	util.shuffle(VarDigits);
	util.shuffle(VarStartDigits);
	offset = math.random(3 ^ MIN_CHARACTERS, 3 ^ MAX_INITIAL_CHARACTERS);
end

return {
	generateName = generateName, 
	prepare = prepare
};

end;modules['obfLT9.namegenerators.number'] = function()
local PREFIX = "_";

return function(id, scope)
	return PREFIX .. tostring(id);
end

end;modules['obfLT9.namegenerators.confuse'] = function()
local util = require("obfLT9.util");
local chararray = util.chararray;

local varNames = {
    "index",
    "iterator",
    "length",
    "size",
    "key",
    "value",
    "data",
    "count",
    "increment",
    "include",
    "string",
    "number",
    "type",
    "void",
    "int",
    "float",
    "bool",
    "char",
    "double",
    "long",
    "short",
    "unsigned",
    "signed",
    "program",
    "factory",
    "Factory",
    "new",
    "delete",
    "table",
    "array",
    "object",
    "class",
    "arr",
    "obj",
    "cls",
    "dir",
    "directory",
    "isWindows",
    "isLinux",
    "game",
    "roblox",
    "gmod",
    "gsub",
    "gmatch",
    "gfind",
    "onload",
    "load",
    "loadstring",
    "loadfile",
    "dofile",
    "require",
    "parse",
    "byte",
    "code",
    "bytecode",
    "idx",
    "const",
    "loader",
    "loaders",
    "module",
    "export",
    "exports",
    "import",
    "imports",
    "package",
    "packages",
    "_G",
    "math",
    "os",
    "io",
    "write",
    "print",
    "read",
    "readline",
    "readlines",
    "close",
    "flush",
    "open",
    "popen",
    "tmpfile",
    "tmpname",
    "rename",
    "remove",
    "seek",
    "setvbuf",
    "lines",
    "call",
    "apply",
    "raise",
    "pcall",
    "xpcall",
    "coroutine",
    "create",
    "resume",
    "status",
    "wrap",
    "yield",
    "debug",
    "traceback",
    "getinfo",
    "getlocal",
    "setlocal",
    "getupvalue",
    "setupvalue",
    "getuservalue",
    "setuservalue",
    "upvalueid",
    "upvaluejoin",
    "sethook",
    "gethook",
    "hookfunction",
    "hooks",
    "error",
    "setmetatable",
    "getmetatable",
    "rand",
    "randomseed",
    "next",
    "ipairs",
    "hasnext",
    "loadlib",
    "searchpath",
    "oldpath",
    "newpath",
    "path",
    "rawequal",
    "rawset",
    "rawget",
    "rawnew",
    "rawlen",
    "select",
    "tonumber",
    "tostring",
    "assert",
    "collectgarbage",
    "a", "b", "c", "i", "j", "m",
}

local function generateName(id, scope)
    local name = {};
    local d = id % #varNames
	id = (id - d) / #varNames
	table.insert(name, varNames[d + 1]);
	while id > 0 do
		local d = id % #varNames
		id = (id - d) / #varNames
		table.insert(name, varNames[d + 1]);
	end
	return table.concat(name, "_");
end

local function prepare(ast)
    util.shuffle(varNames);
end

return {
	generateName = generateName, 
	prepare = prepare
};

end;modules['obfLT9.steps'] = function()
return {
	WrapInFunction       = require("obfLT9.steps.WrapInFunction");
	SplitStrings         = require("obfLT9.steps.SplitStrings");
	Vmify                = require("obfLT9.steps.Vmify");
	ConstantArray        = require("obfLT9.steps.ConstantArray");
	ProxifyLocals  			 = require("obfLT9.steps.ProxifyLocals");
	AntiTamper  				 = require("obfLT9.steps.AntiTamper");
	EncryptStrings 			 = require("obfLT9.steps.EncryptStrings");
	NumbersToExprs = require("obfLT9.steps.NumbersToExprs");
	AddVararg 					 = require("obfLT9.steps.AddVararg");
	WatermarkCheck		   = require("obfLT9.steps.WatermarkCheck");
}
end;modules['obfLT9.steps.WrapInFunction'] = function()
local Step = require("obfLT9.step");
local Ast = require("obfLT9.ast");
local Scope = require("obfLT9.scope");

local WrapInFunction = Step:extend();
WrapInFunction.Description = "This Step Wraps the Entire Script into a Function";
WrapInFunction.Name = "Wrap in Function";

WrapInFunction.SettingsDescriptor = {
	Iterations = {
		name = "Iterations",
		description = "The Number Of Iterations",
		type = "number",
		default = 1,
		min = 1,
		max = nil,
	}
}

function WrapInFunction:init(settings)
	
end

function WrapInFunction:apply(ast)
	for i = 1, self.Iterations, 1 do
		local body = ast.body;

		local scope = Scope:new(ast.globalScope);
		body.scope:setParent(scope);

		ast.body = Ast.Block({
			Ast.ReturnStat({
				Ast.FunctionCallExpr(Ast.FunctionLiteralExpr({Ast.VarargExpr()}, body), {Ast.VarargExpr()})
			});
		}, scope);
	end
end

return WrapInFunction;
end;modules['obfLT9.step'] = function()
local logger = require("logger");
local util = require("obfLT9.util");

local lookupify = util.lookupify;

local Step = {};

Step.SettingsDescriptor = {}

function Step:new(settings)
	local instance = {};
	setmetatable(instance, self);
	self.__index = self;
	
	if type(settings) ~= "table" then
		settings = {};
	end
	
	for key, data in pairs(self.SettingsDescriptor) do
		if settings[key] == nil then
			if data.default == nil then
				logger:error(string.format("The Setting \"%s\" was not provided for the Step \"%s\"", key, self.Name));
			end
			instance[key] = data.default;
		elseif(data.type == "enum") then
			local lookup = lookupify(data.values);
			if not lookup[settings[key]] then
				logger:error(string.format("Invalid value for the Setting \"%s\" of the Step \"%s\". It must be one of the following: %s", key, self.Name, table.concat(data, ", ")));
			end
			instance[key] = settings[key];
		elseif(type(settings[key]) ~= data.type) then
			logger:error(string.format("Invalid value for the Setting \"%s\" of the Step \"%s\". It must be a %s", key, self.Name, data.type));
		else
			if data.min then
				if  settings[key] < data.min then
					logger:error(string.format("Invalid value for the Setting \"%s\" of the Step \"%s\". It must be at least %d", key, self.Name, data.min));
				end
			end
			
			if data.max then
				if  settings[key] > data.max then
					logger:error(string.format("Invalid value for the Setting \"%s\" of the Step \"%s\". The biggest allowed value is %d", key, self.Name, data.min));
				end
			end
			
			instance[key] = settings[key];
		end
	end
	
	instance:init();

	return instance;
end

function Step:init()
	logger:error("Abstract Steps cannot be Created");
end

function Step:extend()
	local ext = {};
	setmetatable(ext, self);
	self.__index = self;
	return ext;
end

function Step:apply(ast, pipeline)
	logger:error("Abstract Steps cannot be Applied")
end

Step.Name = "Abstract Step";
Step.Description = "Abstract Step";

return Step;

end;modules['obfLT9.steps.SplitStrings'] = function()
local Step = require("obfLT9.step");
local Ast = require("obfLT9.ast");
local visitAst = require("obfLT9.visitast");
local Parser = require("obfLT9.parser");
local util = require("obfLT9.util");
local enums = require("obfLT9.enums")

local LuaVersion = enums.LuaVersion;

local SplitStrings = Step:extend();
SplitStrings.Description = "This Step splits Strings to a specific or random length";
SplitStrings.Name = "Split Strings";

SplitStrings.SettingsDescriptor = {
	Treshold = {
		name = "Treshold",
		description = "The relative amount of nodes that will be affected",
		type = "number",
		default = 1,
		min = 0,
		max = 1,
	},
	MinLength = {
		name = "MinLength",
		description = "The minimal length for the chunks in that the Strings are splitted",
		type = "number",
		default = 5,
		min = 1,
		max = nil,
	},
	MaxLength = {
		name = "MaxLength",
		description = "The maximal length for the chunks in that the Strings are splitted",
		type = "number",
		default = 5,
		min = 1,
		max = nil,
	},
	ConcatenationType = {
		name = "ConcatenationType",
		description = "The Functions used for Concatenation. Note that when using custom, the String Array will also be Shuffled",
		type = "enum",
		values = {
			"strcat",
			"table",
			"custom",
		},
		default = "custom",
	},
	CustomFunctionType = {
		name = "CustomFunctionType",
		description = "The Type of Function code injection This Option only applies when custom Concatenation is selected.\
Note that when chosing inline, the code size may increase significantly!",
		type = "enum",
		values = {
			"global",
			"local",
			"inline",
		},
		default = "global",
	},
	CustomLocalFunctionsCount = {
		name = "CustomLocalFunctionsCount",
		description = "The number of local functions per scope. This option only applies when CustomFunctionType = local",
		type = "number",
		default = 2,
		min = 1,
	}
}

function SplitStrings:init(settings) end

local function generateTableConcatNode(chunks, data)
	local chunkNodes = {};
	for i, chunk in ipairs(chunks) do
		table.insert(chunkNodes, Ast.TableEntry(Ast.StringExpr(chunk)));
	end
	local tb = Ast.TableConstructorExpr(chunkNodes);
	data.scope:addReferenceToHigherScope(data.tableConcatScope, data.tableConcatId);
	return Ast.FunctionCallExpr(Ast.VariableExpr(data.tableConcatScope, data.tableConcatId), {tb});	
end

local function generateStrCatNode(chunks)
	-- Put Together Expr for Concatenating String
	local generatedNode = nil;
	for i, chunk in ipairs(chunks) do
		if generatedNode then
			generatedNode = Ast.StrCatExpr(generatedNode, Ast.StringExpr(chunk));
		else
			generatedNode = Ast.StringExpr(chunk);
		end
	end
	return generatedNode
end

local customVariants = 2;
local custom1Code = [=[
function custom(table)
    local stringTable, str = table[#table], "";
    for i=1,#stringTable, 1 do
        str = str .. stringTable[table[i]];
	end
	return str
end
]=];

local custom2Code = [=[
function custom(tb)
	local str = "";
	for i=1, #tb / 2, 1 do
		str = str .. tb[#tb / 2 + tb[i]];
	end
	return str
end
]=];

local function generateCustomNodeArgs(chunks, data, variant)
	local shuffled = {};
	local shuffledIndices = {};
	for i = 1, #chunks, 1 do
		shuffledIndices[i] = i;
	end
	util.shuffle(shuffledIndices);
	
	for i, v in ipairs(shuffledIndices) do
		shuffled[v] = chunks[i];
	end
	
	-- Custom Function Type 1
	if variant == 1 then
		local args = {};
		local tbNodes = {};
		
		for i, v in ipairs(shuffledIndices) do
			table.insert(args, Ast.TableEntry(Ast.NumberExpr(v)));
		end
		
		for i, chunk in ipairs(shuffled) do
			table.insert(tbNodes, Ast.TableEntry(Ast.StringExpr(chunk)));
		end
		
		local tb = Ast.TableConstructorExpr(tbNodes);
		
		table.insert(args, Ast.TableEntry(tb));
		return {Ast.TableConstructorExpr(args)};
		
	-- Custom Function Type 2
	else
		
		local args = {};
		for i, v in ipairs(shuffledIndices) do
			table.insert(args, Ast.TableEntry(Ast.NumberExpr(v)));
		end
		for i, chunk in ipairs(shuffled) do
			table.insert(args, Ast.TableEntry(Ast.StringExpr(chunk)));
		end
		return {Ast.TableConstructorExpr(args)};
	end
	
end

local function generateCustomFunctionLiteral(parentScope, variant)
	local parser = Parser:new({
		LuaVersion = LuaVersion.Lua52;
	});

	-- Custom Function Type 1
	if variant == 1 then
		local funcDeclNode = parser:parse(custom1Code).body.stats[1];
		local funcBody = funcDeclNode.body;
		local funcArgs = funcDeclNode.args;
		funcBody.scope:setParent(parentScope);
		return Ast.FunctionLiteralExpr(funcArgs, funcBody);
		
		-- Custom Function Type 2
	else
		local funcDeclNode = parser:parse(custom2Code).body.stats[1];
		local funcBody = funcDeclNode.body;
		local funcArgs = funcDeclNode.args;
		funcBody.scope:setParent(parentScope);
		return Ast.FunctionLiteralExpr(funcArgs, funcBody);
	end
end

local function generateGlobalCustomFunctionDecl(ast, data)
	local parser = Parser:new({
		LuaVersion = LuaVersion.Lua52;
	});
	
	-- Custom Function Type 1
	if data.customFunctionVariant == 1 then
		local astScope = ast.body.scope;
		local funcDeclNode = parser:parse(custom1Code).body.stats[1];
		local funcBody = funcDeclNode.body;
		local funcArgs = funcDeclNode.args;
		funcBody.scope:setParent(astScope);
		return Ast.LocalVariableDecl(astScope, {data.customFuncId},
		{Ast.FunctionLiteralExpr(funcArgs, funcBody)});
	-- Custom Function Type 2
	else
		local astScope = ast.body.scope;
		local funcDeclNode = parser:parse(custom2Code).body.stats[1];
		local funcBody = funcDeclNode.body;
		local funcArgs = funcDeclNode.args;
		funcBody.scope:setParent(astScope);
		return Ast.LocalVariableDecl(data.customFuncScope, {data.customFuncId},
		{Ast.FunctionLiteralExpr(funcArgs, funcBody)});
	end
end

function SplitStrings:variant()
	return math.random(1, customVariants);
end

function SplitStrings:apply(ast, pipeline)
	local data = {};
	
	
	if(self.ConcatenationType == "table") then
		local scope = ast.body.scope;
		local id = scope:addVariable();
		data.tableConcatScope = scope;
		data.tableConcatId = id;
	elseif(self.ConcatenationType == "custom") then
		data.customFunctionType = self.CustomFunctionType;
		if data.customFunctionType == "global" then
			local scope = ast.body.scope;
			local id = scope:addVariable();
			data.customFuncScope = scope;
			data.customFuncId = id;
			data.customFunctionVariant = self:variant();
		end
	end
	
	
	local customLocalFunctionsCount = self.CustomLocalFunctionsCount;
	local self2 = self;
	
	visitAst(ast, function(node, data) 
		-- Previsit Function
		
		-- Create Local Function decls
		if(self.ConcatenationType == "custom" and data.customFunctionType == "local" and node.kind == Ast.AstKind.Block and node.isFunctionBlock) then
			data.functionData.localFunctions = {};
			for i = 1, customLocalFunctionsCount, 1 do
				local scope = data.scope;
				local id = scope:addVariable();
				local variant = self:variant();
				table.insert(data.functionData.localFunctions, {
					scope = scope,
					id = id,
					variant = variant,
					used = false,
				});
			end
		end
		
	end, function(node, data)
		-- PostVisit Function
		
		-- Create actual function literals for local customFunctionType
		if(self.ConcatenationType == "custom" and data.customFunctionType == "local" and node.kind == Ast.AstKind.Block and node.isFunctionBlock) then
			for i, func in ipairs(data.functionData.localFunctions) do
				if func.used then
					local literal = generateCustomFunctionLiteral(func.scope, func.variant);
					table.insert(node.stats, 1, Ast.LocalVariableDecl(func.scope, {func.id}, {literal}));
				end
			end
		end
		
		
		-- Apply Only to String nodes
		if(node.kind == Ast.AstKind.StringExpr) then
			local str = node.value;
			local chunks = {};
			local i = 1;
			
			-- Split String into Parts of length between MinLength and MaxLength
			while i <= string.len(str) do
				local len = math.random(self.MinLength, self.MaxLength);
				table.insert(chunks, string.sub(str, i, i + len - 1));
				i = i + len;
			end
			
			if(#chunks > 1) then
				if math.random() < self.Treshold then
					if self.ConcatenationType == "strcat" then
						node = generateStrCatNode(chunks);
					elseif self.ConcatenationType == "table" then
						node = generateTableConcatNode(chunks, data);
					elseif self.ConcatenationType == "custom" then
						if self.CustomFunctionType == "global" then
							local args = generateCustomNodeArgs(chunks, data, data.customFunctionVariant);
							-- Add Reference for Variable Renaming
							data.scope:addReferenceToHigherScope(data.customFuncScope, data.customFuncId);
							node = Ast.FunctionCallExpr(Ast.VariableExpr(data.customFuncScope, data.customFuncId), args);
						elseif self.CustomFunctionType == "local" then
							local lfuncs = data.functionData.localFunctions;
							local idx = math.random(1, #lfuncs);
							local func = lfuncs[idx];
							local args = generateCustomNodeArgs(chunks, data, func.variant);
							func.used = true;
							-- Add Reference for Variable Renaming
							data.scope:addReferenceToHigherScope(func.scope, func.id);
							node = Ast.FunctionCallExpr(Ast.VariableExpr(func.scope, func.id), args);
						elseif self.CustomFunctionType == "inline" then
							local variant = self:variant();
							local args = generateCustomNodeArgs(chunks, data, variant);
							local literal = generateCustomFunctionLiteral(data.scope, variant);
							node = Ast.FunctionCallExpr(literal, args);
						end
					end
				end
			end
			
			return node, true;
		end
	end, data)
	
	
	if(self.ConcatenationType == "table") then
		local globalScope = data.globalScope;
		local tableScope, tableId = globalScope:resolve("table")
		ast.body.scope:addReferenceToHigherScope(globalScope, tableId);
		table.insert(ast.body.stats, 1, Ast.LocalVariableDecl(data.tableConcatScope, {data.tableConcatId}, 
		{Ast.IndexExpr(Ast.VariableExpr(tableScope, tableId), Ast.StringExpr("concat"))}));
	elseif(self.ConcatenationType == "custom" and self.CustomFunctionType == "global") then
		table.insert(ast.body.stats, 1, generateGlobalCustomFunctionDecl(ast, data));
	end
end

return SplitStrings;
end;modules['obfLT9.visitast'] = function()
local Ast = require("obfLT9.ast");
local util = require("obfLT9.util");

local AstKind = Ast.AstKind;
local lookupify = util.lookupify;

local visitAst, visitBlock, visitStat, visitExpr;

function visitAst(ast, previsit, postvisit, data)
	ast.isAst = true;
	data = data or {};
	data.scopeStack = {};
	data.functionData = {
		depth = 0;
		scope = ast.body.scope;
		node = ast;
	};
	data.scope = ast.globalScope;
	data.globalScope = ast.globalScope;
	if(type(previsit) == "function") then
		local node, skip = previsit(ast, data);
		ast = node or ast;
		if skip then
			return ast;
		end
	end
	
	-- Is Function Block because global scope is treated like a Function
	visitBlock(ast.body, previsit, postvisit, data, true);
	
	if(type(postvisit) == "function") then
		ast = postvisit(ast, data) or ast;
	end
	return ast;
end

local compundStats = lookupify{
	AstKind.CompoundAddStat,
	AstKind.CompoundSubStat,
	AstKind.CompoundMulStat,
	AstKind.CompoundDivStat,
	AstKind.CompoundModStat,
	AstKind.CompoundPowStat,
	AstKind.CompoundConcatStat,
}

function visitBlock(block, previsit, postvisit, data, isFunctionBlock)
	block.isBlock = true;
	block.isFunctionBlock = isFunctionBlock or false;
	data.scope = block.scope;
	local parentBlockData = data.blockData;
	data.blockData = {};
	table.insert(data.scopeStack, block.scope);
	if(type(previsit) == "function") then
		local node, skip = previsit(block, data);
		block = node or block;
		if skip then
			data.scope = table.remove(data.scopeStack);
			return block
		end
	end
	
	local i = 1;
	while i <= #block.stats do
		local stat = table.remove(block.stats, i);
		i = i - 1;
		local returnedStats = {visitStat(stat, previsit, postvisit, data)};
		for j, stat in ipairs(returnedStats) do
			i = i + 1;
			table.insert(block.stats, i, stat);
		end
		i = i + 1;
	end

	if(type(postvisit) == "function") then
		block = postvisit(block, data) or block;
	end
	data.scope = table.remove(data.scopeStack);
	data.blockData = parentBlockData;
	return block;
end

function visitStat(stat, previsit, postvisit, data)
	stat.isStat = true;
	if(type(previsit) == "function") then
		local node, skip = previsit(stat, data);
		stat = node or stat;
		if skip then
			return stat;
		end
	end
	
	-- Visit Child Nodes of Stat
	if(stat.kind == AstKind.ReturnStat) then
		for i, exp in ipairs(stat.args) do
			stat.args[i] = visitExpr(exp, previsit, postvisit, data);
		end
	elseif(stat.kind == AstKind.PassSelfFunctionCallStat or stat.kind == AstKind.FunctionCallStat) then
		stat.base = visitExpr(stat.base, previsit, postvisit, data);
		for i, exp in ipairs(stat.args) do
			stat.args[i] = visitExpr(exp, previsit, postvisit, data);
		end
	elseif(stat.kind == AstKind.AssiStat) then
		for i, primaryExpr in ipairs(stat.lhs) do
			stat.lhs[i] = visitExpr(primaryExpr, previsit, postvisit, data);
		end
		for i, exp in ipairs(stat.rhs) do
			stat.rhs[i] = visitExpr(exp, previsit, postvisit, data);
		end
	elseif(stat.kind == AstKind.FunctionDecl or stat.kind == AstKind.LocalFunctionDecl) then
		local parentFunctionData = data.functionData;
		data.functionData = {
			depth = parentFunctionData.depth + 1;
			scope = stat.body.scope;
			node = stat;
		};
		stat.body = visitBlock(stat.body, previsit, postvisit, data, true);
		data.functionData = parentFunctionData;
	elseif(stat.kind == AstKind.DoStat) then
		stat.body = visitBlock(stat.body, previsit, postvisit, data, false);
	elseif(stat.kind == AstKind.WhileStat) then
		stat.condition = visitExpr(stat.condition, previsit, postvisit, data);
		stat.body = visitBlock(stat.body, previsit, postvisit, data, false);
	elseif(stat.kind == AstKind.RepeatStat) then
		stat.body = visitBlock(stat.body, previsit, postvisit, data);
		stat.condition = visitExpr(stat.condition, previsit, postvisit, data);
	elseif(stat.kind == AstKind.ForStat) then
		stat.initialValue = visitExpr(stat.initialValue, previsit, postvisit, data);
		stat.finalValue = visitExpr(stat.finalValue, previsit, postvisit, data);
		stat.incrementBy = visitExpr(stat.incrementBy, previsit, postvisit, data);
		stat.body = visitBlock(stat.body, previsit, postvisit, data, false);
	elseif(stat.kind == AstKind.ForInStat) then
		for i, exp in ipairs(stat.exps) do
			stat.exps[i] = visitExpr(exp, previsit, postvisit, data);
		end
		visitBlock(stat.body, previsit, postvisit, data, false);
	elseif(stat.kind == AstKind.IfStat) then
		stat.condition = visitExpr(stat.condition, previsit, postvisit, data);
		stat.body = visitBlock(stat.body, previsit, postvisit, data, false);
		for i, eif in ipairs(stat.elseifs) do
			eif.condition = visitExpr(eif.condition, previsit, postvisit, data);
			eif.body = visitBlock(eif.body, previsit, postvisit, data, false);
		end
		if(stat.elsebody) then
			stat.elsebody = visitBlock(stat.elsebody, previsit, postvisit, data, false);
		end
	elseif(stat.kind == AstKind.LocalVariableDecl) then
		for i, exp in ipairs(stat.exps) do
			stat.exps[i] = visitExpr(exp, previsit, postvisit, data);
		end
	elseif compundStats[stat.kind] then
		stat.lhs = visitExpr(stat.lhs, previsit, postvisit, data);
		stat.rhs = visitExpr(stat.rhs, previsit, postvisit, data);
	end

	if(type(postvisit) == "function") then
		local stats = {postvisit(stat, data)};
		if #stats > 0 then
			return unpack(stats);
		end
	end
	
	return stat;
end

local binaryExprs = lookupify{
	AstKind.OrExpr,
	AstKind.AndExpr,
	AstKind.LessThanExpr,
	AstKind.GreaterThanExpr,
	AstKind.LessThanOrEqualsExpr,
	AstKind.GreaterThanOrEqualsExpr,
	AstKind.NotEqualsExpr,
	AstKind.EqualsExpr,
	AstKind.StrCatExpr,
	AstKind.AddExpr,
	AstKind.SubExpr,
	AstKind.MulExpr,
	AstKind.DivExpr,
	AstKind.ModExpr,
	AstKind.BandExpr,
	AstKind.BxorExpr,
	AstKind.BorExpr,
	AstKind.ShlExpr,
	AstKind.ShrExpr,
	AstKind.IdivExpr,
	AstKind.PowExpr,
}
function visitExpr(exp, previsit, postvisit, data)
	exp.isExpr = true;
	if(type(previsit) == "function") then
		local node, skip = previsit(exp, data);
		exp = node or exp;
		if skip then
			return exp;
		end
	end
	
	if(binaryExprs[exp.kind]) then
		exp.lhs = visitExpr(exp.lhs, previsit, postvisit, data);
		exp.rhs = visitExpr(exp.rhs, previsit, postvisit, data);
	end
	
	if(exp.kind == AstKind.NotExpr or exp.kind == AstKind.NegateExpr or exp.kind == AstKind.LenExpr) then
		exp.rhs = visitExpr(exp.rhs, previsit, postvisit, data);
	end
	
	if(exp.kind == AstKind.PassSelfFunctionCallExpr or exp.kind == AstKind.FunctionCallExpr) then
		exp.base = visitExpr(exp.base, previsit, postvisit, data);
		for i, arg in ipairs(exp.args) do
			exp.args[i] = visitExpr(arg, previsit, postvisit, data);
		end
	end
	
	if(exp.kind == AstKind.FunctionLiteralExpr) then
		local parentFunctionData = data.functionData;
		data.functionData = {
			depth = parentFunctionData.depth + 1;
			scope = exp.body.scope;
			node = exp;
		};
		exp.body = visitBlock(exp.body, previsit, postvisit, data, true);
		data.functionData = parentFunctionData;
	end
	
	if(exp.kind == AstKind.TableConstructorExpr) then
		for i, entry in ipairs(exp.entries) do
			if entry.kind == AstKind.KeyedTableEntry then
				entry.key = visitExpr(entry.key, previsit, postvisit, data);
			end
			entry.value = visitExpr(entry.value, previsit, postvisit, data);
		end
	end
	
	if(exp.kind == AstKind.IndexExpr or exp.kind == AstKind.AssiIndexing) then
		exp.base = visitExpr(exp.base, previsit, postvisit, data);
		exp.index = visitExpr(exp.index, previsit, postvisit, data);
	end

	if(type(postvisit) == "function") then
		exp = postvisit(exp, data) or exp;
	end
	return exp;
end

return visitAst;
end;modules['obfLT9.steps.Vmify'] = function()
local Step = require("obfLT9.step");
local Compiler = require("obfLT9.compiler.compiler");

local Vmify = Step:extend();
Vmify.Description = "This Step will Compile your script into a fully-custom (not a half custom like other lua obfuscators) Bytecode Format and emit a vm for executing it.";
Vmify.Name = "Vmify";

Vmify.SettingsDescriptor = {
}

function Vmify:init(settings)
	
end

function Vmify:apply(ast)
    -- Create Compiler
	local compiler = Compiler:new();
    
    -- Compile the Script into a bytecode vm
    return compiler:compile(ast);
end

return Vmify;
end;modules['obfLT9.compiler.compiler'] = function()
local MAX_REGS = 100;
local MAX_REGS_MUL = 0;

local Compiler = {};

local Ast = require("obfLT9.ast");
local Scope = require("obfLT9.scope");
local logger = require("logger");
local util = require("obfLT9.util");
local visitast = require("obfLT9.visitast")
local randomStrings = require("obfLT9.randomStrings")

local lookupify = util.lookupify;
local AstKind = Ast.AstKind;

local unpack = unpack or table.unpack;

function Compiler:new()
    local compiler = {
        blocks = {};
        registers = {
        };
        activeBlock = nil;
        registersForVar = {};
        usedRegisters = 0;
        maxUsedRegister = 0;
        registerVars = {};

        VAR_REGISTER = newproxy(false);
        RETURN_ALL = newproxy(false); 
        POS_REGISTER = newproxy(false);
        RETURN_REGISTER = newproxy(false);
        UPVALUE = newproxy(false);

        BIN_OPS = lookupify{
            AstKind.LessThanExpr,
            AstKind.GreaterThanExpr,
            AstKind.LessThanOrEqualsExpr,
            AstKind.GreaterThanOrEqualsExpr,
            AstKind.NotEqualsExpr,
            AstKind.EqualsExpr,
            AstKind.StrCatExpr,
            AstKind.AddExpr,
            AstKind.SubExpr,
            AstKind.MulExpr,
            AstKind.DivExpr,
            AstKind.ModExpr,
            --5.3
            AstKind.BandExpr,
            AstKind.BxorExpr,
            AstKind.BorExpr,
            AstKind.ShlExpr,
            AstKind.ShrExpr,
            AstKind.IdivExpr,
            
            AstKind.PowExpr,
        };
    };

    setmetatable(compiler, self);
    self.__index = self;

    return compiler;
end

function Compiler:createBlock()
    local id;
    repeat
        id = math.random(0, 2^24)
    until not self.usedBlockIds[id];
    self.usedBlockIds[id] = true;

    local scope = Scope:new(self.containerFuncScope);
    local block = {
        id = id;
        stats = {

        };
        scope = scope;
        advanceToNextBlock = true;
    };
    table.insert(self.blocks, block);
    return block;
end

function Compiler:setActiveBlock(block)
    self.activeBlock = block;
end

function Compiler:addStat(stat, writes, reads, usesUpvals)
    if(self.activeBlock.advanceToNextBlock) then  
        table.insert(self.activeBlock.stats, {
            stat = stat,
            writes = lookupify(writes),
            reads = lookupify(reads),
            usesUpvals = usesUpvals or false,
        });
    end
end

function Compiler:compile(ast)
    self.blocks = {};
    self.registers = {};
    self.activeBlock = nil;
    self.registersForVar = {};
    self.scopeFunctionDepths = {};
    self.maxUsedRegister = 0;
    self.usedRegisters = 0;
    self.registerVars = {};
    self.usedBlockIds = {};
    
    self.upvalVars = {};
    self.registerUsageStack = {};

    self.upvalsProxyLenReturn = math.random(-2^22, 2^22);

    local newGlobalScope = Scope:newGlobal();
    local psc = Scope:new(newGlobalScope, nil);

    local _, getfenvVar = newGlobalScope:resolve("getfenv");
    local _, tableVar  = newGlobalScope:resolve("table");
    local _, unpackVar = newGlobalScope:resolve("unpack");
    local _, envVar = newGlobalScope:resolve("_ENV");
    local _, newproxyVar = newGlobalScope:resolve("newproxy");
    local _, setmetatableVar = newGlobalScope:resolve("setmetatable");
    local _, getmetatableVar = newGlobalScope:resolve("getmetatable");
    local _, selectVar = newGlobalScope:resolve("select");
    
    psc:addReferenceToHigherScope(newGlobalScope, getfenvVar, 2);
    psc:addReferenceToHigherScope(newGlobalScope, tableVar);
    psc:addReferenceToHigherScope(newGlobalScope, unpackVar);
    psc:addReferenceToHigherScope(newGlobalScope, envVar);
    psc:addReferenceToHigherScope(newGlobalScope, newproxyVar);
    psc:addReferenceToHigherScope(newGlobalScope, setmetatableVar);
    psc:addReferenceToHigherScope(newGlobalScope, getmetatableVar);

    self.scope = Scope:new(psc);
    self.envVar = self.scope:addVariable();
    self.containerFuncVar = self.scope:addVariable();
    self.unpackVar = self.scope:addVariable();
    self.newproxyVar = self.scope:addVariable();
    self.setmetatableVar = self.scope:addVariable();
    self.getmetatableVar = self.scope:addVariable();
    self.selectVar = self.scope:addVariable();

    local argVar = self.scope:addVariable();

    self.containerFuncScope = Scope:new(self.scope);
    self.whileScope = Scope:new(self.containerFuncScope);

    self.posVar = self.containerFuncScope:addVariable();
    self.argsVar = self.containerFuncScope:addVariable();
    self.currentUpvaluesVar = self.containerFuncScope:addVariable();
    self.detectGcCollectVar = self.containerFuncScope:addVariable();
    self.returnVar  = self.containerFuncScope:addVariable();

    --! Upvalues Handling
    self.upvaluesTable = self.scope:addVariable();
    self.upvaluesReferenceCountsTable = self.scope:addVariable();
    self.allocUpvalFunction = self.scope:addVariable();
    self.currentUpvalId = self.scope:addVariable();

    --! Gc Handling for Upvalues
    self.upvaluesProxyFunctionVar = self.scope:addVariable();
    self.upvaluesGcFunctionVar = self.scope:addVariable();
    self.freeUpvalueFunc = self.scope:addVariable();

    self.createClosureVars = {};
    self.createVarargClosureVar = self.scope:addVariable();
    local createClosureScope = Scope:new(self.scope);
    local createClosurePosArg = createClosureScope:addVariable();
    local createClosureUpvalsArg = createClosureScope:addVariable();
    local createClosureProxyObject = createClosureScope:addVariable();
    local createClosureFuncVar = createClosureScope:addVariable();

    local createClosureSubScope = Scope:new(createClosureScope);

    local upvalEntries = {};
    local upvalueIds   = {};
    self.getUpvalueId = function(self, scope, id)
        local exp;
        local scopeFuncDepth = self.scopeFunctionDepths[scope];
        if(scopeFuncDepth == 0) then
            if upvalueIds[id] then
                return upvalueIds[id];
            end
            exp = Ast.FunctionCallExpr(Ast.VariableExpr(self.scope, self.allocUpvalFunction), {});
        else
            logger:error("Unresolved Upvalue, this error should not occur!");
        end
        table.insert(upvalEntries, Ast.TableEntry(exp));
        local uid = #upvalEntries;
        upvalueIds[id] = uid;
        return uid;
    end

    --! Reference to Higher Scopes
    createClosureSubScope:addReferenceToHigherScope(self.scope, self.containerFuncVar);
    createClosureSubScope:addReferenceToHigherScope(createClosureScope, createClosurePosArg)
    createClosureSubScope:addReferenceToHigherScope(createClosureScope, createClosureUpvalsArg, 1)
    createClosureScope:addReferenceToHigherScope(self.scope, self.upvaluesProxyFunctionVar)
    createClosureSubScope:addReferenceToHigherScope(createClosureScope, createClosureProxyObject);

    self:findLabel(ast.body)
    --! Invoke Compiler
    self:compileTopNode(ast);

    local functionNodeAssis = {
        {
            var = Ast.AssiVariable(self.scope, self.containerFuncVar),
            val = Ast.FunctionLiteralExpr({
                Ast.VariableExpr(self.containerFuncScope, self.posVar),
                Ast.VariableExpr(self.containerFuncScope, self.argsVar),
                Ast.VariableExpr(self.containerFuncScope, self.currentUpvaluesVar),
                Ast.VariableExpr(self.containerFuncScope, self.detectGcCollectVar)
            }, self:emitContainerFuncBody());
        }, {
            var = Ast.AssiVariable(self.scope, self.createVarargClosureVar),
            val = Ast.FunctionLiteralExpr({
                    Ast.VariableExpr(createClosureScope, createClosurePosArg),
                    Ast.VariableExpr(createClosureScope, createClosureUpvalsArg),
                },
                Ast.Block({
                    Ast.LocalVariableDecl(createClosureScope, {
                        createClosureProxyObject
                    }, {
                        Ast.FunctionCallExpr(Ast.VariableExpr(self.scope, self.upvaluesProxyFunctionVar), {
                            Ast.VariableExpr(createClosureScope, createClosureUpvalsArg)
                        })
                    }),
                    Ast.LocalVariableDecl(createClosureScope, {createClosureFuncVar},{
                        Ast.FunctionLiteralExpr({
                            Ast.VarargExpr();
                        },
                        Ast.Block({
                            Ast.ReturnStat{
                                Ast.FunctionCallExpr(Ast.VariableExpr(self.scope, self.containerFuncVar), {
                                    Ast.VariableExpr(createClosureScope, createClosurePosArg),
                                    Ast.TableConstructorExpr({Ast.TableEntry(Ast.VarargExpr())}),
                                    Ast.VariableExpr(createClosureScope, createClosureUpvalsArg), --! Upvalues
                                    Ast.VariableExpr(createClosureScope, createClosureProxyObject)
                                })
                            }
                        }, createClosureSubScope)
                        );
                    });
                    Ast.ReturnStat{Ast.VariableExpr(createClosureScope, createClosureFuncVar)};
                }, createClosureScope)
            );
        }, {
            var = Ast.AssiVariable(self.scope, self.upvaluesTable),
            val = Ast.TableConstructorExpr({}),
        }, {
            var = Ast.AssiVariable(self.scope, self.upvaluesReferenceCountsTable),
            val = Ast.TableConstructorExpr({}),
        }, {
            var = Ast.AssiVariable(self.scope, self.allocUpvalFunction),
            val = self:createAllocUpvalFunction(),
        }, {
            var = Ast.AssiVariable(self.scope, self.currentUpvalId),
            val = Ast.NumberExpr(0),
        }, {
            var = Ast.AssiVariable(self.scope, self.upvaluesProxyFunctionVar),
            val = self:createUpvaluesProxyFunc(),
        }, {
            var = Ast.AssiVariable(self.scope, self.upvaluesGcFunctionVar),
            val = self:createUpvaluesGcFunc(),
        }, {
            var = Ast.AssiVariable(self.scope, self.freeUpvalueFunc),
            val = self:createFreeUpvalueFunc(),
        },
    }

    local tbl = {
        Ast.VariableExpr(self.scope, self.containerFuncVar),
        Ast.VariableExpr(self.scope, self.createVarargClosureVar),
        Ast.VariableExpr(self.scope, self.upvaluesTable),
        Ast.VariableExpr(self.scope, self.upvaluesReferenceCountsTable),
        Ast.VariableExpr(self.scope, self.allocUpvalFunction),
        Ast.VariableExpr(self.scope, self.currentUpvalId),
        Ast.VariableExpr(self.scope, self.upvaluesProxyFunctionVar),
        Ast.VariableExpr(self.scope, self.upvaluesGcFunctionVar),
        Ast.VariableExpr(self.scope, self.freeUpvalueFunc),
    };
    for i, entry in pairs(self.createClosureVars) do
        table.insert(functionNodeAssis, entry);
        table.insert(tbl, Ast.VariableExpr(entry.var.scope, entry.var.id));
    end

    util.shuffle(functionNodeAssis);
    local assiStatLhs, assiStatRhs = {}, {};
    for i, v in ipairs(functionNodeAssis) do
        assiStatLhs[i] = v.var;
        assiStatRhs[i] = v.val;
    end

    --! Emit Code
    local functionNode = Ast.FunctionLiteralExpr({
        Ast.VariableExpr(self.scope, self.envVar),
        Ast.VariableExpr(self.scope, self.unpackVar),
        Ast.VariableExpr(self.scope, self.newproxyVar),
        Ast.VariableExpr(self.scope, self.setmetatableVar),
        Ast.VariableExpr(self.scope, self.getmetatableVar),
        Ast.VariableExpr(self.scope, self.selectVar),
        Ast.VariableExpr(self.scope, argVar),
        unpack(util.shuffle(tbl))
    }, Ast.Block({
        Ast.AssiStat(assiStatLhs, assiStatRhs);
        Ast.ReturnStat{
            Ast.FunctionCallExpr(Ast.FunctionCallExpr(Ast.VariableExpr(self.scope, self.createVarargClosureVar), {
                    Ast.NumberExpr(self.startBlockId);
                    Ast.TableConstructorExpr(upvalEntries);
                }), {Ast.FunctionCallExpr(Ast.VariableExpr(self.scope, self.unpackVar), {Ast.VariableExpr(self.scope, argVar)})});
        }
    }, self.scope));

    return Ast.TopNode(Ast.Block({
        Ast.ReturnStat{Ast.FunctionCallExpr(functionNode, {
            Ast.OrExpr(Ast.AndExpr(Ast.VariableExpr(newGlobalScope, getfenvVar), Ast.FunctionCallExpr(Ast.VariableExpr(newGlobalScope, getfenvVar), {})), Ast.VariableExpr(newGlobalScope, envVar));
            Ast.OrExpr(Ast.VariableExpr(newGlobalScope, unpackVar), Ast.IndexExpr(Ast.VariableExpr(newGlobalScope, tableVar), Ast.StringExpr("unpack")));
            Ast.VariableExpr(newGlobalScope, newproxyVar);
            Ast.VariableExpr(newGlobalScope, setmetatableVar);
            Ast.VariableExpr(newGlobalScope, getmetatableVar);
            Ast.VariableExpr(newGlobalScope, selectVar);
            Ast.TableConstructorExpr({
                Ast.TableEntry(Ast.VarargExpr());
            })
        })};
    }, psc), newGlobalScope);
end

function Compiler:getCreateClosureVar(argCount)
    if not self.createClosureVars[argCount] then
        local var = Ast.AssiVariable(self.scope, self.scope:addVariable());
        local createClosureScope = Scope:new(self.scope);
        local createClosureSubScope = Scope:new(createClosureScope);
        
        local createClosurePosArg = createClosureScope:addVariable();
        local createClosureUpvalsArg = createClosureScope:addVariable();
        local createClosureProxyObject = createClosureScope:addVariable();
        local createClosureFuncVar = createClosureScope:addVariable();

        createClosureSubScope:addReferenceToHigherScope(self.scope, self.containerFuncVar);
        createClosureSubScope:addReferenceToHigherScope(createClosureScope, createClosurePosArg)
        createClosureSubScope:addReferenceToHigherScope(createClosureScope, createClosureUpvalsArg, 1)
        createClosureScope:addReferenceToHigherScope(self.scope, self.upvaluesProxyFunctionVar)
        createClosureSubScope:addReferenceToHigherScope(createClosureScope, createClosureProxyObject);

        local  argsTb, argsTb2 = {}, {};
        for i = 1, argCount do
            local arg = createClosureSubScope:addVariable()
            argsTb[i] = Ast.VariableExpr(createClosureSubScope, arg);
            argsTb2[i] = Ast.TableEntry(Ast.VariableExpr(createClosureSubScope, arg));
        end

        local val = Ast.FunctionLiteralExpr({
            Ast.VariableExpr(createClosureScope, createClosurePosArg),
            Ast.VariableExpr(createClosureScope, createClosureUpvalsArg),
        }, Ast.Block({
                Ast.LocalVariableDecl(createClosureScope, {
                    createClosureProxyObject
                }, {
                    Ast.FunctionCallExpr(Ast.VariableExpr(self.scope, self.upvaluesProxyFunctionVar), {
                        Ast.VariableExpr(createClosureScope, createClosureUpvalsArg)
                    })
                }),
                Ast.LocalVariableDecl(createClosureScope, {createClosureFuncVar},{
                    Ast.FunctionLiteralExpr(argsTb,
                    Ast.Block({
                        Ast.ReturnStat{
                            Ast.FunctionCallExpr(Ast.VariableExpr(self.scope, self.containerFuncVar), {
                                Ast.VariableExpr(createClosureScope, createClosurePosArg),
                                Ast.TableConstructorExpr(argsTb2),
                                Ast.VariableExpr(createClosureScope, createClosureUpvalsArg), --! Upvalues
                                Ast.VariableExpr(createClosureScope, createClosureProxyObject)
                            })
                        }
                    }, createClosureSubScope)
                    );
                });
                Ast.ReturnStat{Ast.VariableExpr(createClosureScope, createClosureFuncVar)}
            }, createClosureScope)
        );
        self.createClosureVars[argCount] = {
            var = var,
            val = val,
        }
    end

    
    local var = self.createClosureVars[argCount].var;
    return var.scope, var.id;
end

function Compiler:pushRegisterUsageInfo()
    table.insert(self.registerUsageStack, {
        usedRegisters = self.usedRegisters;
        registers = self.registers;
    });
    self.usedRegisters = 0;
    self.registers = {};
end

function Compiler:popRegisterUsageInfo()
    local info = table.remove(self.registerUsageStack);
    self.usedRegisters = info.usedRegisters;
    self.registers = info.registers;
end

function Compiler:createUpvaluesGcFunc()
    local scope = Scope:new(self.scope);
    local selfVar = scope:addVariable();

    local iteratorVar = scope:addVariable();
    local valueVar = scope:addVariable();

    local whileScope = Scope:new(scope);
    whileScope:addReferenceToHigherScope(self.scope, self.upvaluesReferenceCountsTable, 3);
    whileScope:addReferenceToHigherScope(scope, valueVar, 3);
    whileScope:addReferenceToHigherScope(scope, iteratorVar, 3);

    local ifScope = Scope:new(whileScope);
    ifScope:addReferenceToHigherScope(self.scope, self.upvaluesReferenceCountsTable, 1);
    ifScope:addReferenceToHigherScope(self.scope, self.upvaluesTable, 1);
    

    return Ast.FunctionLiteralExpr({Ast.VariableExpr(scope, selfVar)}, Ast.Block({
        Ast.LocalVariableDecl(scope, {iteratorVar, valueVar}, {Ast.NumberExpr(1), Ast.IndexExpr(Ast.VariableExpr(scope, selfVar), Ast.NumberExpr(1))}),
        Ast.WhileStat(Ast.Block({
            Ast.AssiStat({
                Ast.AssiIndexing(Ast.VariableExpr(self.scope, self.upvaluesReferenceCountsTable), Ast.VariableExpr(scope, valueVar)),
                Ast.AssiVariable(scope, iteratorVar),
            }, {
                Ast.SubExpr(Ast.IndexExpr(Ast.VariableExpr(self.scope, self.upvaluesReferenceCountsTable), Ast.VariableExpr(scope, valueVar)), Ast.NumberExpr(1)),
                Ast.AddExpr(unpack(util.shuffle{Ast.VariableExpr(scope, iteratorVar), Ast.NumberExpr(1)})),
            }),
            Ast.IfStat(Ast.EqualsExpr(unpack(util.shuffle{Ast.IndexExpr(Ast.VariableExpr(self.scope, self.upvaluesReferenceCountsTable), Ast.VariableExpr(scope, valueVar)), Ast.NumberExpr(0)})), Ast.Block({
                Ast.AssiStat({
                    Ast.AssiIndexing(Ast.VariableExpr(self.scope, self.upvaluesReferenceCountsTable), Ast.VariableExpr(scope, valueVar)),
                    Ast.AssiIndexing(Ast.VariableExpr(self.scope, self.upvaluesTable), Ast.VariableExpr(scope, valueVar)),
                }, {
                    Ast.NilExpr(),
                    Ast.NilExpr(),
                })
            }, ifScope), {}, nil),
            Ast.AssiStat({
                Ast.AssiVariable(scope, valueVar),
            }, {
                Ast.IndexExpr(Ast.VariableExpr(scope, selfVar), Ast.VariableExpr(scope, iteratorVar)),
            }),
        }, whileScope), Ast.VariableExpr(scope, valueVar), scope);
    }, scope));
end

function Compiler:createFreeUpvalueFunc()
    local scope = Scope:new(self.scope);
    local argVar = scope:addVariable();
    local ifScope = Scope:new(scope);
    ifScope:addReferenceToHigherScope(scope, argVar, 3);
    scope:addReferenceToHigherScope(self.scope, self.upvaluesReferenceCountsTable, 2);
    return Ast.FunctionLiteralExpr({Ast.VariableExpr(scope, argVar)}, Ast.Block({
        Ast.AssiStat({
            Ast.AssiIndexing(Ast.VariableExpr(self.scope, self.upvaluesReferenceCountsTable), Ast.VariableExpr(scope, argVar))
        }, {
            Ast.SubExpr(Ast.IndexExpr(Ast.VariableExpr(self.scope, self.upvaluesReferenceCountsTable), Ast.VariableExpr(scope, argVar)), Ast.NumberExpr(1));
        }),
        Ast.IfStat(Ast.EqualsExpr(unpack(util.shuffle{Ast.IndexExpr(Ast.VariableExpr(self.scope, self.upvaluesReferenceCountsTable), Ast.VariableExpr(scope, argVar)), Ast.NumberExpr(0)})), Ast.Block({
            Ast.AssiStat({
                Ast.AssiIndexing(Ast.VariableExpr(self.scope, self.upvaluesReferenceCountsTable), Ast.VariableExpr(scope, argVar)),
                Ast.AssiIndexing(Ast.VariableExpr(self.scope, self.upvaluesTable), Ast.VariableExpr(scope, argVar)),
            }, {
                Ast.NilExpr(),
                Ast.NilExpr(),
            })
        }, ifScope), {}, nil)
    }, scope))
end

function Compiler:createUpvaluesProxyFunc()
    local scope = Scope:new(self.scope);
    scope:addReferenceToHigherScope(self.scope, self.newproxyVar);

    local entriesVar = scope:addVariable();

    local ifScope = Scope:new(scope);
    local proxyVar = ifScope:addVariable();
    local metatableVar = ifScope:addVariable();
    local elseScope = Scope:new(scope);
    ifScope:addReferenceToHigherScope(self.scope, self.newproxyVar);
    ifScope:addReferenceToHigherScope(self.scope, self.getmetatableVar);
    ifScope:addReferenceToHigherScope(self.scope, self.upvaluesGcFunctionVar);
    ifScope:addReferenceToHigherScope(scope, entriesVar);
    elseScope:addReferenceToHigherScope(self.scope, self.setmetatableVar);
    elseScope:addReferenceToHigherScope(scope, entriesVar);
    elseScope:addReferenceToHigherScope(self.scope, self.upvaluesGcFunctionVar);

    local forScope = Scope:new(scope);
    local forArg = forScope:addVariable();
    forScope:addReferenceToHigherScope(self.scope, self.upvaluesReferenceCountsTable, 2);
    forScope:addReferenceToHigherScope(scope, entriesVar, 2);

    return Ast.FunctionLiteralExpr({Ast.VariableExpr(scope, entriesVar)}, Ast.Block({
        Ast.ForStat(forScope, forArg, Ast.NumberExpr(1), Ast.LenExpr(Ast.VariableExpr(scope, entriesVar)), Ast.NumberExpr(1), Ast.Block({
            Ast.AssiStat({
                Ast.AssiIndexing(Ast.VariableExpr(self.scope, self.upvaluesReferenceCountsTable), Ast.IndexExpr(Ast.VariableExpr(scope, entriesVar), Ast.VariableExpr(forScope, forArg)))
            }, {
                Ast.AddExpr(unpack(util.shuffle{
                    Ast.IndexExpr(Ast.VariableExpr(self.scope, self.upvaluesReferenceCountsTable), Ast.IndexExpr(Ast.VariableExpr(scope, entriesVar), Ast.VariableExpr(forScope, forArg))),
                    Ast.NumberExpr(1),
                }))
            })
        }, forScope), scope);
        Ast.IfStat(Ast.VariableExpr(self.scope, self.newproxyVar), Ast.Block({
            Ast.LocalVariableDecl(ifScope, {proxyVar}, {
                Ast.FunctionCallExpr(Ast.VariableExpr(self.scope, self.newproxyVar), {
                    Ast.BooleanExpr(true)
                });
            });
            Ast.LocalVariableDecl(ifScope, {metatableVar}, {
                Ast.FunctionCallExpr(Ast.VariableExpr(self.scope, self.getmetatableVar), {
                    Ast.VariableExpr(ifScope, proxyVar);
                });
            });
            Ast.AssiStat({
                Ast.AssiIndexing(Ast.VariableExpr(ifScope, metatableVar), Ast.StringExpr("__index")),
                Ast.AssiIndexing(Ast.VariableExpr(ifScope, metatableVar), Ast.StringExpr("__gc")),
                Ast.AssiIndexing(Ast.VariableExpr(ifScope, metatableVar), Ast.StringExpr("__len")),
            }, {
                Ast.VariableExpr(scope, entriesVar),
                Ast.VariableExpr(self.scope, self.upvaluesGcFunctionVar),
                Ast.FunctionLiteralExpr({}, Ast.Block({
                    Ast.ReturnStat({Ast.NumberExpr(self.upvalsProxyLenReturn)})
                }, Scope:new(ifScope)));
            });
            Ast.ReturnStat({
                Ast.VariableExpr(ifScope, proxyVar)
            })
        }, ifScope), {}, Ast.Block({
            Ast.ReturnStat({Ast.FunctionCallExpr(Ast.VariableExpr(self.scope, self.setmetatableVar), {
                Ast.TableConstructorExpr({}),
                Ast.TableConstructorExpr({
                    Ast.KeyedTableEntry(Ast.StringExpr("__gc"), Ast.VariableExpr(self.scope, self.upvaluesGcFunctionVar)),
                    Ast.KeyedTableEntry(Ast.StringExpr("__index"), Ast.VariableExpr(scope, entriesVar)),
                    Ast.KeyedTableEntry(Ast.StringExpr("__len"), Ast.FunctionLiteralExpr({}, Ast.Block({
                        Ast.ReturnStat({Ast.NumberExpr(self.upvalsProxyLenReturn)})
                    }, Scope:new(ifScope)))),
                })
            })})
        }, elseScope));
    }, scope));
end

function Compiler:createAllocUpvalFunction()
    local scope = Scope:new(self.scope);
    scope:addReferenceToHigherScope(self.scope, self.currentUpvalId, 4);
    scope:addReferenceToHigherScope(self.scope, self.upvaluesReferenceCountsTable, 1);

    return Ast.FunctionLiteralExpr({}, Ast.Block({
        Ast.AssiStat({
                Ast.AssiVariable(self.scope, self.currentUpvalId),
            },{
                Ast.AddExpr(unpack(util.shuffle({
                    Ast.VariableExpr(self.scope, self.currentUpvalId),
                    Ast.NumberExpr(1),
                }))),
            }
        ),
        Ast.AssiStat({
            Ast.AssiIndexing(Ast.VariableExpr(self.scope, self.upvaluesReferenceCountsTable), Ast.VariableExpr(self.scope, self.currentUpvalId)),
        }, {
            Ast.NumberExpr(1),
        }),
        Ast.ReturnStat({
            Ast.VariableExpr(self.scope, self.currentUpvalId),
        })
    }, scope));
end

function Compiler:emitContainerFuncBody()
    local blocks = {};

    util.shuffle(self.blocks);

    for _, block in ipairs(self.blocks) do
        local id = block.id;
        local blockstats = block.stats;

        --! Shuffle Blockstats
        for i = 2, #blockstats do
            local stat = blockstats[i];
            local reads = stat.reads;
            local writes = stat.writes;
            local maxShift = 0;
            local usesUpvals = stat.usesUpvals;
            for shift = 1, i - 1 do
                local stat2 = blockstats[i - shift];

                if stat2.usesUpvals and usesUpvals then
                    break;
                end

                local reads2 = stat2.reads;
                local writes2 = stat2.writes;
                local f = true;

                for r, b in pairs(reads2) do
                    if(writes[r]) then
                        f = false;
                        break;
                    end
                end

                if f then
                    for r, b in pairs(writes2) do
                        if(writes[r]) then
                            f = false;
                            break;
                        end
                        if(reads[r]) then
                            f = false;
                            break;
                        end
                    end
                end

                if not f then
                    break
                end

                maxShift = shift;
            end

            local shift = math.random(0, maxShift);
            for j = 1, shift do
                    blockstats[i - j], blockstats[i - j + 1] = blockstats[i - j + 1], blockstats[i - j];
            end
        end

        blockstats = {};
        for i, stat in ipairs(block.stats) do
            table.insert(blockstats, stat.stat);
        end

        table.insert(blocks, { id = id, block = Ast.Block(blockstats, block.scope) });
    end

    table.sort(blocks, function(a, b)
        return a.id < b.id;
    end);

    local function buildIfBlock(scope, id, lBlock, rBlock)
        return Ast.Block({
            Ast.IfStat(Ast.LessThanExpr(self:pos(scope), Ast.NumberExpr(id)), lBlock, {}, rBlock);
        }, scope);
    end

    local function buildWhileBody(tb, l, r, pScope, scope)
        local len = r - l + 1;
        if len == 1 then
            tb[r].block.scope:setParent(pScope);
            return tb[r].block;
        elseif len == 0 then
            return nil;
        end

        local mid = l + math.ceil(len / 2);
        local bound = math.random(tb[mid - 1].id + 1, tb[mid].id);
        local ifScope = scope or Scope:new(pScope);

        local lBlock = buildWhileBody(tb, l, mid - 1, ifScope);
        local rBlock = buildWhileBody(tb, mid, r, ifScope);

        return buildIfBlock(ifScope, bound, lBlock, rBlock);
    end

    local whileBody = buildWhileBody(blocks, 1, #blocks, self.containerFuncScope, self.whileScope);

    self.whileScope:addReferenceToHigherScope(self.containerFuncScope, self.returnVar, 1);
    self.whileScope:addReferenceToHigherScope(self.containerFuncScope, self.posVar);
 
    self.containerFuncScope:addReferenceToHigherScope(self.scope, self.unpackVar);

    local decls = {
        self.returnVar,
    }

    for i, var in pairs(self.registerVars) do
        if(i ~= MAX_REGS) then
            table.insert(decls, var);
        end
    end

    local stats = {
        Ast.LocalVariableDecl(self.containerFuncScope, util.shuffle(decls), {});
        Ast.WhileStat(whileBody, Ast.VariableExpr(self.containerFuncScope, self.posVar));
        Ast.AssiStat({
            Ast.AssiVariable(self.containerFuncScope, self.posVar)
        }, {
            Ast.LenExpr(Ast.VariableExpr(self.containerFuncScope, self.detectGcCollectVar))
        }),
        Ast.ReturnStat{
            Ast.FunctionCallExpr(Ast.VariableExpr(self.scope, self.unpackVar), {
                Ast.VariableExpr(self.containerFuncScope, self.returnVar)
            });
        }
    }

    if self.maxUsedRegister >= MAX_REGS then
        table.insert(stats, 1, Ast.LocalVariableDecl(self.containerFuncScope, {self.registerVars[MAX_REGS]}, {Ast.TableConstructorExpr({})}));
    end

    return Ast.Block(stats, self.containerFuncScope);
end

function Compiler:freeRegister(id, force)
    if force or not (self.registers[id] == self.VAR_REGISTER) then
        self.usedRegisters = self.usedRegisters - 1;
        self.registers[id] = false
    end
end

function Compiler:isVarRegister(id)
    return self.registers[id] == self.VAR_REGISTER;
end

function Compiler:allocRegister(isVar)
    self.usedRegisters = self.usedRegisters + 1;

    if not isVar then
        --! POS register can be temporarily used
        if not self.registers[self.POS_REGISTER] then
            self.registers[self.POS_REGISTER] = true;
            return self.POS_REGISTER;
        end

        --! RETURN register can be temporarily used
        if not self.registers[self.RETURN_REGISTER] then
            self.registers[self.RETURN_REGISTER] = true;
            return self.RETURN_REGISTER;
        end
    end
    

    local id = 0;
    if self.usedRegisters < MAX_REGS * MAX_REGS_MUL then
        repeat
            id = math.random(1, MAX_REGS - 1);
        until not self.registers[id];
    else
        repeat
            id = id + 1;
        until not self.registers[id];
    end

    if id > self.maxUsedRegister then
        self.maxUsedRegister = id;
    end

    if(isVar) then
        self.registers[id] = self.VAR_REGISTER;
    else
        self.registers[id] = true
    end
    return id;
end

function Compiler:isUpvalue(scope, id)
    return self.upvalVars[scope] and self.upvalVars[scope][id];
end

function Compiler:makeUpvalue(scope, id)
    if(not self.upvalVars[scope]) then
        self.upvalVars[scope] = {}
    end
    self.upvalVars[scope][id] = true;
end

function Compiler:getVarRegister(scope, id, functionDepth, potentialId)
    if(not self.registersForVar[scope]) then
        self.registersForVar[scope] = {};
        self.scopeFunctionDepths[scope] = functionDepth;
    end

    local reg = self.registersForVar[scope][id];
    if not reg then
        if potentialId and self.registers[potentialId] ~= self.VAR_REGISTER and potentialId ~= self.POS_REGISTER and potentialId ~= self.RETURN_REGISTER then
            self.registers[potentialId] = self.VAR_REGISTER;
            reg = potentialId;
        else
            reg = self:allocRegister(true);
        end
        self.registersForVar[scope][id] = reg;
    end
    return reg;
end

function Compiler:getRegisterVarId(id)
    local varId = self.registerVars[id];
    if not varId then
        varId = self.containerFuncScope:addVariable();
        self.registerVars[id] = varId;
    end
    return varId;
end

--! Maybe convert ids to strings
function Compiler:register(scope, id)
    if id == self.POS_REGISTER then
        return self:pos(scope);
    end

    if id == self.RETURN_REGISTER then
        return self:getReturn(scope);
    end

    if id < MAX_REGS then
        local vid = self:getRegisterVarId(id);
        scope:addReferenceToHigherScope(self.containerFuncScope, vid);
        return Ast.VariableExpr(self.containerFuncScope, vid);
    end

    local vid = self:getRegisterVarId(MAX_REGS);
    scope:addReferenceToHigherScope(self.containerFuncScope, vid);
    return Ast.IndexExpr(Ast.VariableExpr(self.containerFuncScope, vid), Ast.NumberExpr((id - MAX_REGS) + 1));
end

function Compiler:registerList(scope, ids)
    local l = {};
    for i, id in ipairs(ids) do
        table.insert(l, self:register(scope, id));
    end
    return l;
end

function Compiler:registerAssi(scope, id)
    if id == self.POS_REGISTER then
        return self:posAssi(scope);
    end
    if id == self.RETURN_REGISTER then
        return self:returnAssi(scope);
    end

    if id < MAX_REGS then
        local vid = self:getRegisterVarId(id);
        scope:addReferenceToHigherScope(self.containerFuncScope, vid);
        return Ast.AssiVariable(self.containerFuncScope, vid);
    end

    local vid = self:getRegisterVarId(MAX_REGS);
    scope:addReferenceToHigherScope(self.containerFuncScope, vid);
    return Ast.AssiIndexing(Ast.VariableExpr(self.containerFuncScope, vid), Ast.NumberExpr((id - MAX_REGS) + 1));
end

--! Maybe convert ids to strings
function Compiler:setRegister(scope, id, val, compundArg)
    if(compundArg) then
        return compundArg(self:registerAssi(scope, id), val);
    end
    return Ast.AssiStat({
        self:registerAssi(scope, id)
    }, {
        val
    });
end

function Compiler:setRegisters(scope, ids, vals)
    local idStats = {};
    for i, id in ipairs(ids) do
        table.insert(idStats, self:registerAssi(scope, id));
    end

    return Ast.AssiStat(idStats, vals);
end

function Compiler:copyRegisters(scope, to, from)
    local idStats = {};
    local vals    = {};
    for i, id in ipairs(to) do
        local from = from[i];
        if(from ~= id) then
            table.insert(idStats, self:registerAssi(scope, id));
            table.insert(vals, self:register(scope, from));
        end
    end

    if(#idStats > 0 and #vals > 0) then
        return Ast.AssiStat(idStats, vals);
    end
end

function Compiler:resetRegisters()
    self.registers = {};
end

function Compiler:pos(scope)
    scope:addReferenceToHigherScope(self.containerFuncScope, self.posVar);
    return Ast.VariableExpr(self.containerFuncScope, self.posVar);
end

function Compiler:posAssi(scope)
    scope:addReferenceToHigherScope(self.containerFuncScope, self.posVar);
    return Ast.AssiVariable(self.containerFuncScope, self.posVar);
end

function Compiler:args(scope)
    scope:addReferenceToHigherScope(self.containerFuncScope, self.argsVar);
    return Ast.VariableExpr(self.containerFuncScope, self.argsVar);
end

function Compiler:unpack(scope)
    scope:addReferenceToHigherScope(self.scope, self.unpackVar);
    return Ast.VariableExpr(self.scope, self.unpackVar);
end

function Compiler:env(scope)
    scope:addReferenceToHigherScope(self.scope, self.envVar);
    return Ast.VariableExpr(self.scope, self.envVar);
end

function Compiler:jmp(scope, to)
    scope:addReferenceToHigherScope(self.containerFuncScope, self.posVar);
    return Ast.AssiStat({Ast.AssiVariable(self.containerFuncScope, self.posVar)},{to});
end

function Compiler:setPos(scope, val)
    if not val then
       
        local v =  Ast.IndexExpr(self:env(scope), randomStrings.randomStringNode(math.random(12, 14))); --Ast.NilExpr();
        scope:addReferenceToHigherScope(self.containerFuncScope, self.posVar);
        return Ast.AssiStat({Ast.AssiVariable(self.containerFuncScope, self.posVar)}, {v});
    end
    scope:addReferenceToHigherScope(self.containerFuncScope, self.posVar);
    return Ast.AssiStat({Ast.AssiVariable(self.containerFuncScope, self.posVar)}, {Ast.NumberExpr(val) or Ast.NilExpr()});
end

function Compiler:setReturn(scope, val)
    scope:addReferenceToHigherScope(self.containerFuncScope, self.returnVar);
    return Ast.AssiStat({Ast.AssiVariable(self.containerFuncScope, self.returnVar)}, {val});
end

function Compiler:getReturn(scope)
    scope:addReferenceToHigherScope(self.containerFuncScope, self.returnVar);
    return Ast.VariableExpr(self.containerFuncScope, self.returnVar);
end

function Compiler:returnAssi(scope)
    scope:addReferenceToHigherScope(self.containerFuncScope, self.returnVar);
    return Ast.AssiVariable(self.containerFuncScope, self.returnVar);
end

function Compiler:setUpvalueMember(scope, idExpr, valExpr, compoundConstructor)
    scope:addReferenceToHigherScope(self.scope, self.upvaluesTable);
    if compoundConstructor then
        return compoundConstructor(Ast.AssiIndexing(Ast.VariableExpr(self.scope, self.upvaluesTable), idExpr), valExpr);
    end
    return Ast.AssiStat({Ast.AssiIndexing(Ast.VariableExpr(self.scope, self.upvaluesTable), idExpr)}, {valExpr});
end

function Compiler:getUpvalueMember(scope, idExpr)
    scope:addReferenceToHigherScope(self.scope, self.upvaluesTable);
    return Ast.IndexExpr(Ast.VariableExpr(self.scope, self.upvaluesTable), idExpr);
end

function Compiler:compileTopNode(node)
    --! Create Initial Block
    local startBlock = self:createBlock();
    local scope = startBlock.scope;
    self.startBlockId = startBlock.id;
    self:setActiveBlock(startBlock);

    local varAccessLookup = lookupify{
        AstKind.AssiVariable,
        AstKind.VariableExpr,
        AstKind.FunctionDecl,
        AstKind.LocalFunctionDecl,
    }

    local functionLookup = lookupify{
        AstKind.FunctionDecl,
        AstKind.LocalFunctionDecl,
        AstKind.FunctionLiteralExpr,
        AstKind.TopNode,
    }
    --! Collect Upvalues
    visitast(node, function(node, data) 
        if node.kind == AstKind.Block then
            node.scope.__depth = data.functionData.depth;
        end

        if varAccessLookup[node.kind] then
            if not node.scope.isGlobal then
                if node.scope.__depth < data.functionData.depth then
                    if not self:isUpvalue(node.scope, node.id) then
                        self:makeUpvalue(node.scope, node.id);
                    end
                end
            end
        end
    end, nil, nil)

    self.varargReg = self:allocRegister(true);
    scope:addReferenceToHigherScope(self.containerFuncScope, self.argsVar);
    scope:addReferenceToHigherScope(self.scope, self.selectVar);
    scope:addReferenceToHigherScope(self.scope, self.unpackVar);
    self:addStat(self:setRegister(scope, self.varargReg, Ast.VariableExpr(self.containerFuncScope, self.argsVar)), {self.varargReg}, {}, false);

    --! Compile Block
    
    self:compileBlock(node.body, 0);
    if(self.activeBlock.advanceToNextBlock) then
        self:addStat(self:setPos(self.activeBlock.scope, nil), {self.POS_REGISTER}, {}, false);
        self:addStat(self:setReturn(self.activeBlock.scope, Ast.TableConstructorExpr({})), {self.RETURN_REGISTER}, {}, false)
        self.activeBlock.advanceToNextBlock = false;
    end

    self:resetRegisters();
end

function Compiler:compileFunction(node, funcDepth)
    funcDepth = funcDepth + 1;
    local oldActiveBlock = self.activeBlock;
    
    local upperVarargReg = self.varargReg;
    self.varargReg = nil;

    local upvalueExprs = {};
    local upvalueIds = {};
    local usedRegs = {};

    local oldGetUpvalueId = self.getUpvalueId;
    self.getUpvalueId = function(self, scope, id)
        if(not upvalueIds[scope]) then
            upvalueIds[scope] = {};
        end
        if(upvalueIds[scope][id]) then
            return upvalueIds[scope][id];
        end
        local scopeFuncDepth = self.scopeFunctionDepths[scope];
        local exp;
        if(scopeFuncDepth == funcDepth) then
            oldActiveBlock.scope:addReferenceToHigherScope(self.scope, self.allocUpvalFunction);
            exp = Ast.FunctionCallExpr(Ast.VariableExpr(self.scope, self.allocUpvalFunction), {});
        elseif(scopeFuncDepth == funcDepth - 1) then
            local varReg = self:getVarRegister(scope, id, scopeFuncDepth, nil);
            exp = self:register(oldActiveBlock.scope, varReg);
            table.insert(usedRegs, varReg);
        else
            local higherId = oldGetUpvalueId(self, scope, id);
            oldActiveBlock.scope:addReferenceToHigherScope(self.containerFuncScope, self.currentUpvaluesVar);
            exp = Ast.IndexExpr(Ast.VariableExpr(self.containerFuncScope, self.currentUpvaluesVar), Ast.NumberExpr(higherId));
        end
        table.insert(upvalueExprs, Ast.TableEntry(exp));
        local uid = #upvalueExprs;
        upvalueIds[scope][id] = uid;
        return uid;
    end
    
    

    local block = self:createBlock();
    self:setActiveBlock(block);
    local scope = self.activeBlock.scope;
    self:pushRegisterUsageInfo();
    for i, arg in ipairs(node.args) do
        if(arg.kind == AstKind.VariableExpr) then
            if(self:isUpvalue(arg.scope, arg.id)) then
                scope:addReferenceToHigherScope(self.scope, self.allocUpvalFunction);
                local argReg = self:getVarRegister(arg.scope, arg.id, funcDepth, nil);
                self:addStat(self:setRegister(scope, argReg, Ast.FunctionCallExpr(Ast.VariableExpr(self.scope, self.allocUpvalFunction), {})), {argReg}, {}, false);
                self:addStat(self:setUpvalueMember(scope, self:register(scope, argReg), Ast.IndexExpr(Ast.VariableExpr(self.containerFuncScope, self.argsVar), Ast.NumberExpr(i))), {}, {argReg}, true);
            else
                local argReg = self:getVarRegister(arg.scope, arg.id, funcDepth, nil);
                scope:addReferenceToHigherScope(self.containerFuncScope, self.argsVar);
                self:addStat(self:setRegister(scope, argReg, Ast.IndexExpr(Ast.VariableExpr(self.containerFuncScope, self.argsVar), Ast.NumberExpr(i))), {argReg}, {}, false);
            end
        else
            self.varargReg = self:allocRegister(true);
            scope:addReferenceToHigherScope(self.containerFuncScope, self.argsVar);
            scope:addReferenceToHigherScope(self.scope, self.selectVar);
            scope:addReferenceToHigherScope(self.scope, self.unpackVar);
            self:addStat(self:setRegister(scope, self.varargReg, Ast.TableConstructorExpr({
                Ast.TableEntry(Ast.FunctionCallExpr(Ast.VariableExpr(self.scope, self.selectVar), {
                    Ast.NumberExpr(i);
                    Ast.FunctionCallExpr(Ast.VariableExpr(self.scope, self.unpackVar), {
                        Ast.VariableExpr(self.containerFuncScope, self.argsVar),
                    });
                })),
            })), {self.varargReg}, {}, false);
        end
    end
    self:compileBlock(node.body, funcDepth);
    if(self.activeBlock.advanceToNextBlock) then
        self:addStat(self:setPos(self.activeBlock.scope, nil), {self.POS_REGISTER}, {}, false);
        self:addStat(self:setReturn(self.activeBlock.scope, Ast.TableConstructorExpr({})), {self.RETURN_REGISTER}, {}, false);
        self.activeBlock.advanceToNextBlock = false;
    end

    if(self.varargReg) then
        self:freeRegister(self.varargReg, true);
    end
    self.varargReg = upperVarargReg;
    self.getUpvalueId = oldGetUpvalueId;

    self:popRegisterUsageInfo();
    self:setActiveBlock(oldActiveBlock);

    local scope = self.activeBlock.scope;
    
    local retReg = self:allocRegister(false);

    local isVarargFunction = #node.args > 0 and node.args[#node.args].kind == AstKind.VarargExpr;

    local retrieveExpr
    if isVarargFunction then
        scope:addReferenceToHigherScope(self.scope, self.createVarargClosureVar);
        retrieveExpr = Ast.FunctionCallExpr(Ast.VariableExpr(self.scope, self.createVarargClosureVar), {
            Ast.NumberExpr(block.id),
            Ast.TableConstructorExpr(upvalueExprs)
        });
    else
        local varScope, var = self:getCreateClosureVar(#node.args + math.random(0, 5));
        scope:addReferenceToHigherScope(varScope, var);
        retrieveExpr = Ast.FunctionCallExpr(Ast.VariableExpr(varScope, var), {
            Ast.NumberExpr(block.id),
            Ast.TableConstructorExpr(upvalueExprs)
        });
    end

    self:addStat(self:setRegister(scope, retReg, retrieveExpr), {retReg}, usedRegs, false);
    return retReg;
end

function Compiler:findLabel(block)
    self.labels = self.labels or {}
    for i, stat in ipairs(block.stats) do
        if stat.kind == AstKind.LabelStat then
            if self.labels[stat.label] then
                logger:error(string.format("Error: Label '%s' is already defined at line %d!", stat.label, stat.pos.line))
                return
            end
            stat.createBlock = self:createBlock()
            self.labels[stat.label] = stat
        elseif stat.body or stat.elsebody then
            self:findLabel(stat.body or stat.elsebody)
        end
    end
    return self.labels
end

function Compiler:compileBlock(block, funcDepth)
    for i, stat in ipairs(block.stats) do
        self:compileStat(stat, funcDepth);
    end

    local scope = self.activeBlock.scope;
    for id, name in ipairs(block.scope.variables) do
        local varReg = self:getVarRegister(block.scope, id, funcDepth, nil);
        if self:isUpvalue(block.scope, id) then
            scope:addReferenceToHigherScope(self.scope, self.freeUpvalueFunc);
            self:addStat(self:setRegister(scope, varReg, Ast.FunctionCallExpr(Ast.VariableExpr(self.scope, self.freeUpvalueFunc), {
                self:register(scope, varReg)
            })), {varReg}, {varReg}, false);
        else
            self:addStat(self:setRegister(scope, varReg, Ast.NilExpr()), {varReg}, {}, false);
        end
        self:freeRegister(varReg, true);
    end
end

function Compiler:compileStat(stat, funcDepth)
    local scope = self.activeBlock.scope;
    
    --! Return Stat
    if(stat.kind == AstKind.ReturnStat) then
        local entries = {};
        local regs = {};

        for i, expr in ipairs(stat.args) do
            if i == #stat.args and (expr.kind == AstKind.FunctionCallExpr or expr.kind == AstKind.PassSelfFunctionCallExpr or expr.kind == AstKind.VarargExpr) then
                local reg = self:compileExpr(expr, funcDepth, self.RETURN_ALL)[1];
                table.insert(entries, Ast.TableEntry(Ast.FunctionCallExpr(
                    self:unpack(scope),
                    {self:register(scope, reg)})));
                table.insert(regs, reg);
            else
                local reg = self:compileExpr(expr, funcDepth, 1)[1];
                table.insert(entries, Ast.TableEntry(self:register(scope, reg)));
                table.insert(regs, reg);
            end
        end

        for _, reg in ipairs(regs) do
            self:freeRegister(reg, false);
        end

        self:addStat(self:setReturn(scope, Ast.TableConstructorExpr(entries)), {self.RETURN_REGISTER}, regs, false);
        self:addStat(self:setPos(self.activeBlock.scope, nil), {self.POS_REGISTER}, {}, false);
        self.activeBlock.advanceToNextBlock = false;
        return;
    end

    --! Local Variable Decl
    if(stat.kind == AstKind.LocalVariableDecl) then
        local exprregs = {};
        for i, expr in ipairs(stat.exps) do
            if(i == #stat.exps and #stat.ids > #stat.exps) then
                local regs = self:compileExpr(expr, funcDepth, #stat.ids - #stat.exps + 1);
                for i, reg in ipairs(regs) do
                    table.insert(exprregs, reg);
                end
            else
                if stat.ids[i] or expr.kind == AstKind.FunctionCallExpr or expr.kind == AstKind.PassSelfFunctionCallExpr then
                    local reg = self:compileExpr(expr, funcDepth, 1)[1];
                    table.insert(exprregs, reg);
                end
            end
        end

        if #exprregs == 0 then
            for i=1, #stat.ids do
                table.insert(exprregs, self:compileExpr(Ast.NilExpr(), funcDepth, 1)[1]);
            end
        end

        for i, id in ipairs(stat.ids) do
            if(exprregs[i]) then
                if(self:isUpvalue(stat.scope, id)) then
                    local varreg = self:getVarRegister(stat.scope, id, funcDepth);
                    local varReg = self:getVarRegister(stat.scope, id, funcDepth, nil);
                    scope:addReferenceToHigherScope(self.scope, self.allocUpvalFunction);
                    self:addStat(self:setRegister(scope, varReg, Ast.FunctionCallExpr(Ast.VariableExpr(self.scope, self.allocUpvalFunction), {})), {varReg}, {}, false);
                    self:addStat(self:setUpvalueMember(scope, self:register(scope, varReg), self:register(scope, exprregs[i])), {}, {varReg, exprregs[i]}, true);
                    self:freeRegister(exprregs[i], false);
                else
                    local varreg = self:getVarRegister(stat.scope, id, funcDepth, exprregs[i]);
                    self:addStat(self:copyRegisters(scope, {varreg}, {exprregs[i]}), {varreg}, {exprregs[i]}, false);
                    self:freeRegister(exprregs[i], false);
                end
            end
        end

        if not self.scopeFunctionDepths[stat.scope] then
            self.scopeFunctionDepths[stat.scope] = funcDepth;
        end

        return;
    end

    --! Function Call Stat
    if(stat.kind == AstKind.FunctionCallStat) then
        local baseReg = self:compileExpr(stat.base, funcDepth, 1)[1];
        local retReg  = self:allocRegister(false);
        local regs = {};
        local args = {};

        for i, expr in ipairs(stat.args) do
            if i == #stat.args and (expr.kind == AstKind.FunctionCallExpr or expr.kind == AstKind.PassSelfFunctionCallExpr or expr.kind == AstKind.VarargExpr) then
                local reg = self:compileExpr(expr, funcDepth, self.RETURN_ALL)[1];
                table.insert(args, Ast.FunctionCallExpr(
                    self:unpack(scope),
                    {self:register(scope, reg)}));
                table.insert(regs, reg);
            else
                local reg = self:compileExpr(expr, funcDepth, 1)[1];
                table.insert(args, self:register(scope, reg));
                table.insert(regs, reg);
            end
        end

        self:addStat(self:setRegister(scope, retReg, Ast.FunctionCallExpr(self:register(scope, baseReg), args)), {retReg}, {baseReg, unpack(regs)}, true);
        self:freeRegister(baseReg, false);
        self:freeRegister(retReg, false);
        for i, reg in ipairs(regs) do
            self:freeRegister(reg, false);
        end
        
        return;
    end

    --! Pass Self Function Call Stat
    if(stat.kind == AstKind.PassSelfFunctionCallStat) then
        local baseReg = self:compileExpr(stat.base, funcDepth, 1)[1];
        local tmpReg  = self:allocRegister(false);
        local args = { self:register(scope, baseReg) };
        local regs = { baseReg };

        for i, expr in ipairs(stat.args) do
            if i == #stat.args and (expr.kind == AstKind.FunctionCallExpr or expr.kind == AstKind.PassSelfFunctionCallExpr or expr.kind == AstKind.VarargExpr) then
                local reg = self:compileExpr(expr, funcDepth, self.RETURN_ALL)[1];
                table.insert(args, Ast.FunctionCallExpr(
                    self:unpack(scope),
                    {self:register(scope, reg)}));
                table.insert(regs, reg);
            else
                local reg = self:compileExpr(expr, funcDepth, 1)[1];
                table.insert(args, self:register(scope, reg));
                table.insert(regs, reg);
            end
        end
        self:addStat(self:setRegister(scope, tmpReg, Ast.StringExpr(stat.passSelfFunctionName)), {tmpReg}, {}, false);
        self:addStat(self:setRegister(scope, tmpReg, Ast.IndexExpr(self:register(scope, baseReg), self:register(scope, tmpReg))), {tmpReg}, {tmpReg, baseReg}, false);

        self:addStat(self:setRegister(scope, tmpReg, Ast.FunctionCallExpr(self:register(scope, tmpReg), args)), {tmpReg}, {tmpReg, unpack(regs)}, true);

        self:freeRegister(tmpReg, false);
        for i, reg in ipairs(regs) do
            self:freeRegister(reg, false);
        end
        
        return;
    end

    --! Local Function Decl
    if(stat.kind == AstKind.LocalFunctionDecl) then
        
        if(self:isUpvalue(stat.scope, stat.id)) then
            local varReg = self:getVarRegister(stat.scope, stat.id, funcDepth, nil);
            scope:addReferenceToHigherScope(self.scope, self.allocUpvalFunction);
            self:addStat(self:setRegister(scope, varReg, Ast.FunctionCallExpr(Ast.VariableExpr(self.scope, self.allocUpvalFunction), {})), {varReg}, {}, false);
            local retReg = self:compileFunction(stat, funcDepth);
            self:addStat(self:setUpvalueMember(scope, self:register(scope, varReg), self:register(scope, retReg)), {}, {varReg, retReg}, true);
            self:freeRegister(retReg, false);
        else
            local retReg = self:compileFunction(stat, funcDepth);
            local varReg = self:getVarRegister(stat.scope, stat.id, funcDepth, retReg);
            self:addStat(self:copyRegisters(scope, {varReg}, {retReg}), {varReg}, {retReg}, false);
            self:freeRegister(retReg, false);
        end
        return;
    end

    --! Function Decl
    if(stat.kind == AstKind.FunctionDecl) then
        local retReg = self:compileFunction(stat, funcDepth);
        if(#stat.indices > 0) then
            local tblReg;
            if stat.scope.isGlobal then
                tblReg = self:allocRegister(false);
                self:addStat(self:setRegister(scope, tblReg, Ast.StringExpr(stat.scope:getVariableName(stat.id))), {tblReg}, {}, false);
                self:addStat(self:setRegister(scope, tblReg, Ast.IndexExpr(self:env(scope), self:register(scope, tblReg))), {tblReg}, {tblReg}, true);
            else
                if self.scopeFunctionDepths[stat.scope] == funcDepth then
                    if self:isUpvalue(stat.scope, stat.id) then
                        tblReg = self:allocRegister(false);
                        local reg = self:getVarRegister(stat.scope, stat.id, funcDepth);
                        self:addStat(self:setRegister(scope, tblReg, self:getUpvalueMember(scope, self:register(scope, reg))), {tblReg}, {reg}, true);
                    else
                        tblReg = self:getVarRegister(stat.scope, stat.id, funcDepth, retReg);
                    end
                else
                    tblReg = self:allocRegister(false);
                    local upvalId = self:getUpvalueId(stat.scope, stat.id);
                    scope:addReferenceToHigherScope(self.containerFuncScope, self.currentUpvaluesVar);
                    self:addStat(self:setRegister(scope, tblReg, self:getUpvalueMember(scope, Ast.IndexExpr(Ast.VariableExpr(self.containerFuncScope, self.currentUpvaluesVar), Ast.NumberExpr(upvalId)))), {tblReg}, {}, true);
                end
            end

            for i = 1, #stat.indices - 1 do
                local index = stat.indices[i];
                local indexReg = self:compileExpr(Ast.StringExpr(index), funcDepth, 1)[1];
                local tblRegOld = tblReg;
                tblReg = self:allocRegister(false);
                self:addStat(self:setRegister(scope, tblReg, Ast.IndexExpr(self:register(scope, tblRegOld), self:register(scope, indexReg))), {tblReg}, {tblReg, indexReg}, false);
                self:freeRegister(tblRegOld, false);
                self:freeRegister(indexReg, false);
            end

            local index = stat.indices[#stat.indices];
            local indexReg = self:compileExpr(Ast.StringExpr(index), funcDepth, 1)[1];
            self:addStat(Ast.AssiStat({
                Ast.AssiIndexing(self:register(scope, tblReg), self:register(scope, indexReg)),
            }, {
                self:register(scope, retReg),
            }), {}, {tblReg, indexReg, retReg}, true);
            self:freeRegister(indexReg, false);
            self:freeRegister(tblReg, false);
            self:freeRegister(retReg, false);

            return;
        end
        if stat.scope.isGlobal then
            local tmpReg = self:allocRegister(false);
            self:addStat(self:setRegister(scope, tmpReg, Ast.StringExpr(stat.scope:getVariableName(stat.id))), {tmpReg}, {}, false);
            self:addStat(Ast.AssiStat({Ast.AssiIndexing(self:env(scope), self:register(scope, tmpReg))},
             {self:register(scope, retReg)}), {}, {tmpReg, retReg}, true);
            self:freeRegister(tmpReg, false);
        else
            if self.scopeFunctionDepths[stat.scope] == funcDepth then
                if self:isUpvalue(stat.scope, stat.id) then
                    local reg = self:getVarRegister(stat.scope, stat.id, funcDepth);
                    self:addStat(self:setUpvalueMember(scope, self:register(scope, reg), self:register(scope, retReg)), {}, {reg, retReg}, true);
                else
                    local reg = self:getVarRegister(stat.scope, stat.id, funcDepth, retReg);
                    if reg ~= retReg then
                        self:addStat(self:setRegister(scope, reg, self:register(scope, retReg)), {reg}, {retReg}, false);
                    end
                end
            else
                local upvalId = self:getUpvalueId(stat.scope, stat.id);
                scope:addReferenceToHigherScope(self.containerFuncScope, self.currentUpvaluesVar);
                self:addStat(self:setUpvalueMember(scope, Ast.IndexExpr(Ast.VariableExpr(self.containerFuncScope, self.currentUpvaluesVar), Ast.NumberExpr(upvalId)), self:register(scope, retReg)), {}, {retReg}, true);
            end
        end
        self:freeRegister(retReg, false);
        return;
     end

    --! Assi Stat
    if(stat.kind == AstKind.AssiStat) then
        local exprregs = {};
        local assiIndexingRegs = {};
        for i, primaryExpr in ipairs(stat.lhs) do
            if(primaryExpr.kind == AstKind.AssiIndexing) then
                assiIndexingRegs [i] = {
                    base = self:compileExpr(primaryExpr.base, funcDepth, 1)[1],
                    index = self:compileExpr(primaryExpr.index, funcDepth, 1)[1],
                };
            end
        end

        for i, expr in ipairs(stat.rhs) do
            if(i == #stat.rhs and #stat.lhs > #stat.rhs) then
                local regs = self:compileExpr(expr, funcDepth, #stat.lhs - #stat.rhs + 1);

                for i, reg in ipairs(regs) do
                    if(self:isVarRegister(reg)) then
                        local ro = reg;
                        reg = self:allocRegister(false);
                        self:addStat(self:copyRegisters(scope, {reg}, {ro}), {reg}, {ro}, false);
                    end
                    table.insert(exprregs, reg);
                end
            else
                if stat.lhs[i] or expr.kind == AstKind.FunctionCallExpr or expr.kind == AstKind.PassSelfFunctionCallExpr then
                    local reg = self:compileExpr(expr, funcDepth, 1)[1];
                    if(self:isVarRegister(reg)) then
                        local ro = reg;
                        reg = self:allocRegister(false);
                        self:addStat(self:copyRegisters(scope, {reg}, {ro}), {reg}, {ro}, false);
                    end
                    table.insert(exprregs, reg);
                end
            end
        end

        for i, primaryExpr in ipairs(stat.lhs) do
            if primaryExpr.kind == AstKind.AssiVariable then
                if primaryExpr.scope.isGlobal then
                    local tmpReg = self:allocRegister(false);
                    self:addStat(self:setRegister(scope, tmpReg, Ast.StringExpr(primaryExpr.scope:getVariableName(primaryExpr.id))), {tmpReg}, {}, false);
                    self:addStat(Ast.AssiStat({Ast.AssiIndexing(self:env(scope), self:register(scope, tmpReg))},
                     {self:register(scope, exprregs[i])}), {}, {tmpReg, exprregs[i]}, true);
                    self:freeRegister(tmpReg, false);
                else
                    if self.scopeFunctionDepths[primaryExpr.scope] == funcDepth then
                        if self:isUpvalue(primaryExpr.scope, primaryExpr.id) then
                            local reg = self:getVarRegister(primaryExpr.scope, primaryExpr.id, funcDepth);
                            self:addStat(self:setUpvalueMember(scope, self:register(scope, reg), self:register(scope, exprregs[i])), {}, {reg, exprregs[i]}, true);
                        else
                            local reg = self:getVarRegister(primaryExpr.scope, primaryExpr.id, funcDepth, exprregs[i]);
                            if reg ~= exprregs[i] then
                                self:addStat(self:setRegister(scope, reg, self:register(scope, exprregs[i])), {reg}, {exprregs[i]}, false);
                            end
                        end
                    else
                        local upvalId = self:getUpvalueId(primaryExpr.scope, primaryExpr.id);
                        scope:addReferenceToHigherScope(self.containerFuncScope, self.currentUpvaluesVar);
                        self:addStat(self:setUpvalueMember(scope, Ast.IndexExpr(Ast.VariableExpr(self.containerFuncScope, self.currentUpvaluesVar), Ast.NumberExpr(upvalId)), self:register(scope, exprregs[i])), {}, {exprregs[i]}, true);
                    end
                end
            elseif primaryExpr.kind == AstKind.AssiIndexing then
                local baseReg = assiIndexingRegs[i].base;
                local indexReg = assiIndexingRegs[i].index;
                self:addStat(Ast.AssiStat({
                    Ast.AssiIndexing(self:register(scope, baseReg), self:register(scope, indexReg))
                }, {
                    self:register(scope, exprregs[i])
                }), {}, {exprregs[i], baseReg, indexReg}, true);
                self:freeRegister(exprregs[i], false);
                self:freeRegister(baseReg, false);
                self:freeRegister(indexReg, false);
            else
                error(string.format("Invalid Assi lhs: %s", stat.lhs));
            end
        end

        return
    end

    --! If Stat
    if(stat.kind == AstKind.IfStat) then
        local conditionReg = self:compileExpr(stat.condition, funcDepth, 1)[1];
        local finalBlock = self:createBlock();

        local nextBlock
        if stat.elsebody or #stat.elseifs > 0 then
            nextBlock = self:createBlock();
        else
            nextBlock = finalBlock;
        end
        local innerBlock = self:createBlock();

        self:addStat(self:setRegister(scope, self.POS_REGISTER, Ast.OrExpr(Ast.AndExpr(self:register(scope, conditionReg), Ast.NumberExpr(innerBlock.id)), Ast.NumberExpr(nextBlock.id))), {self.POS_REGISTER}, {conditionReg}, false);
        
        self:freeRegister(conditionReg, false);

        self:setActiveBlock(innerBlock);
        scope = innerBlock.scope
        self:compileBlock(stat.body, funcDepth);
        self:addStat(self:setRegister(scope, self.POS_REGISTER, Ast.NumberExpr(finalBlock.id)), {self.POS_REGISTER}, {}, false);

        for i, eif in ipairs(stat.elseifs) do
            self:setActiveBlock(nextBlock);
            conditionReg = self:compileExpr(eif.condition, funcDepth, 1)[1];
            local innerBlock = self:createBlock();
            if stat.elsebody or i < #stat.elseifs then
                nextBlock = self:createBlock();
            else
                nextBlock = finalBlock;
            end
            local scope = self.activeBlock.scope;
            self:addStat(self:setRegister(scope, self.POS_REGISTER, Ast.OrExpr(Ast.AndExpr(self:register(scope, conditionReg), Ast.NumberExpr(innerBlock.id)), Ast.NumberExpr(nextBlock.id))), {self.POS_REGISTER}, {conditionReg}, false);
        
            self:freeRegister(conditionReg, false);

            self:setActiveBlock(innerBlock);
            scope = innerBlock.scope;
            self:compileBlock(eif.body, funcDepth);
            self:addStat(self:setRegister(scope, self.POS_REGISTER, Ast.NumberExpr(finalBlock.id)), {self.POS_REGISTER}, {}, false);
        end

        if stat.elsebody then
            self:setActiveBlock(nextBlock);
            self:compileBlock(stat.elsebody, funcDepth);
            self:addStat(self:setRegister(scope, self.POS_REGISTER, Ast.NumberExpr(finalBlock.id)), {self.POS_REGISTER}, {}, false);
        end

        self:setActiveBlock(finalBlock);

        return;
    end

    --! Do Stat
    if(stat.kind == AstKind.DoStat) then
        self:compileBlock(stat.body, funcDepth);
        return;
    end

    --! While Stat
    if(stat.kind == AstKind.WhileStat) then
        local innerBlock = self:createBlock();
        local finalBlock = self:createBlock();
        local checkBlock = self:createBlock();

        stat.__start_block = checkBlock;
        stat.__final_block = finalBlock;

        self:addStat(self:setPos(scope, checkBlock.id), {self.POS_REGISTER}, {}, false);

        self:setActiveBlock(checkBlock);
        local scope = self.activeBlock.scope;
        local conditionReg = self:compileExpr(stat.condition, funcDepth, 1)[1];
        self:addStat(self:setRegister(scope, self.POS_REGISTER, Ast.OrExpr(Ast.AndExpr(self:register(scope, conditionReg), Ast.NumberExpr(innerBlock.id)), Ast.NumberExpr(finalBlock.id))), {self.POS_REGISTER}, {conditionReg}, false);
        self:freeRegister(conditionReg, false);

        self:setActiveBlock(innerBlock);
        local scope = self.activeBlock.scope;
        self:compileBlock(stat.body, funcDepth);
        self:addStat(self:setPos(scope, checkBlock.id), {self.POS_REGISTER}, {}, false);
        self:setActiveBlock(finalBlock);
        return;
    end

    --! Repeat Stat
    if(stat.kind == AstKind.RepeatStat) then
        local innerBlock = self:createBlock();
        local finalBlock = self:createBlock();
        local checkBlock = self:createBlock();
        stat.__start_block = checkBlock;
        stat.__final_block = finalBlock;

        local conditionReg = self:compileExpr(stat.condition, funcDepth, 1)[1];
        self:addStat(self:setRegister(scope, self.POS_REGISTER, Ast.NumberExpr(innerBlock.id)), {self.POS_REGISTER}, {}, false);
        self:freeRegister(conditionReg, false);

        self:setActiveBlock(innerBlock);
        self:compileBlock(stat.body, funcDepth);
        local scope = self.activeBlock.scope
        self:addStat(self:setPos(scope, checkBlock.id), {self.POS_REGISTER}, {}, false);
        self:setActiveBlock(checkBlock);
        local scope = self.activeBlock.scope;
        local conditionReg = self:compileExpr(stat.condition, funcDepth, 1)[1];
        self:addStat(self:setRegister(scope, self.POS_REGISTER, Ast.OrExpr(Ast.AndExpr(self:register(scope, conditionReg), Ast.NumberExpr(finalBlock.id)), Ast.NumberExpr(innerBlock.id))), {self.POS_REGISTER}, {conditionReg}, false);
        self:freeRegister(conditionReg, false);

        self:setActiveBlock(finalBlock);

        return;
    end

    --! For Stat
    if(stat.kind == AstKind.ForStat) then
        local checkBlock = self:createBlock();
        local innerBlock = self:createBlock();
        local finalBlock = self:createBlock();

        stat.__start_block = checkBlock;
        stat.__final_block = finalBlock;

        local posState = self.registers[self.POS_REGISTER];
        self.registers[self.POS_REGISTER] = self.VAR_REGISTER;

        local initialReg = self:compileExpr(stat.initialValue, funcDepth, 1)[1];

        local finalExprReg = self:compileExpr(stat.finalValue, funcDepth, 1)[1];
        local finalReg = self:allocRegister(false);
        self:addStat(self:copyRegisters(scope, {finalReg}, {finalExprReg}), {finalReg}, {finalExprReg}, false);
        self:freeRegister(finalExprReg);

        local incrementExprReg = self:compileExpr(stat.incrementBy, funcDepth, 1)[1];
        local incrementReg = self:allocRegister(false);
        self:addStat(self:copyRegisters(scope, {incrementReg}, {incrementExprReg}), {incrementReg}, {incrementExprReg}, false);
        self:freeRegister(incrementExprReg);

        local tmpReg = self:allocRegister(false);
        self:addStat(self:setRegister(scope, tmpReg, Ast.NumberExpr(0)), {tmpReg}, {}, false);
        local incrementIsNegReg = self:allocRegister(false);
        self:addStat(self:setRegister(scope, incrementIsNegReg, Ast.LessThanExpr(self:register(scope, incrementReg), self:register(scope, tmpReg))), {incrementIsNegReg}, {incrementReg, tmpReg}, false);     
        self:freeRegister(tmpReg);

        local currentReg = self:allocRegister(true);
        self:addStat(self:setRegister(scope, currentReg, Ast.SubExpr(self:register(scope, initialReg), self:register(scope, incrementReg))), {currentReg}, {initialReg, incrementReg}, false);
        self:freeRegister(initialReg);

        --print( checkBlock.id )
        self:addStat(self:jmp(scope, Ast.NumberExpr(checkBlock.id)), {self.POS_REGISTER}, {}, false);

        self:setActiveBlock(checkBlock);

        scope = checkBlock.scope;
        self:addStat(self:setRegister(scope, currentReg, Ast.AddExpr(self:register(scope, currentReg), self:register(scope, incrementReg))), {currentReg}, {currentReg, incrementReg}, false);
        local tmpReg1 = self:allocRegister(false);
        local tmpReg2 = self:allocRegister(false);
        self:addStat(self:setRegister(scope, tmpReg2, Ast.NotExpr(self:register(scope, incrementIsNegReg))), {tmpReg2}, {incrementIsNegReg}, false);
        self:addStat(self:setRegister(scope, tmpReg1, Ast.BnotExpr(self:register(scope, currentReg), self:register(scope, finalReg))), {tmpReg1}, {currentReg, finalReg}, false);
        self:addStat(self:setRegister(scope, tmpReg1, Ast.LessThanOrEqualsExpr(self:register(scope, currentReg), self:register(scope, finalReg))), {tmpReg1}, {currentReg, finalReg}, false);
        self:addStat(self:setRegister(scope, tmpReg1, Ast.AndExpr(self:register(scope, tmpReg2), self:register(scope, tmpReg1))), {tmpReg1}, {tmpReg1, tmpReg2}, false);
        self:addStat(self:setRegister(scope, tmpReg2, Ast.GreaterThanOrEqualsExpr(self:register(scope, currentReg), self:register(scope, finalReg))), {tmpReg2}, {currentReg, finalReg}, false);
        self:addStat(self:setRegister(scope, tmpReg2, Ast.AndExpr(self:register(scope, incrementIsNegReg), self:register(scope, tmpReg2))), {tmpReg2}, {tmpReg2, incrementIsNegReg}, false);
        self:addStat(self:setRegister(scope, tmpReg1, Ast.OrExpr(self:register(scope, tmpReg2), self:register(scope, tmpReg1))), {tmpReg1}, {tmpReg1, tmpReg2}, false);
        self:freeRegister(tmpReg2);
        tmpReg2 = self:compileExpr(Ast.NumberExpr(innerBlock.id), funcDepth, 1)[1];
        self:addStat(self:setRegister(scope, self.POS_REGISTER, Ast.AndExpr(self:register(scope, tmpReg1), self:register(scope, tmpReg2))), {self.POS_REGISTER}, {tmpReg1, tmpReg2}, false);
        self:freeRegister(tmpReg2);
        self:freeRegister(tmpReg1);
        tmpReg2 = self:compileExpr(Ast.NumberExpr(finalBlock.id), funcDepth, 1)[1];
        self:addStat(self:setRegister(scope, self.POS_REGISTER, Ast.OrExpr(self:register(scope, self.POS_REGISTER), self:register(scope, tmpReg2))), {self.POS_REGISTER}, {self.POS_REGISTER, tmpReg2}, false);
        self:freeRegister(tmpReg2);

        self:setActiveBlock(innerBlock);
        scope = innerBlock.scope;
        self.registers[self.POS_REGISTER] = posState;

        local varReg = self:getVarRegister(stat.scope, stat.id, funcDepth, nil);

        if(self:isUpvalue(stat.scope, stat.id)) then
            scope:addReferenceToHigherScope(self.scope, self.allocUpvalFunction);
            self:addStat(self:setRegister(scope, varReg, Ast.FunctionCallExpr(Ast.VariableExpr(self.scope, self.allocUpvalFunction), {})), {varReg}, {}, false);
            self:addStat(self:setUpvalueMember(scope, self:register(scope, varReg), self:register(scope, currentReg)), {}, {varReg, currentReg}, true);
        else
            self:addStat(self:setRegister(scope, varReg, self:register(scope, currentReg)), {varReg}, {currentReg}, false);
        end

        
        self:compileBlock(stat.body, funcDepth);
        self:addStat(self:setRegister(scope, self.POS_REGISTER, Ast.NumberExpr(checkBlock.id)), {self.POS_REGISTER}, {}, false);
        
        self.registers[self.POS_REGISTER] = self.VAR_REGISTER;
        self:freeRegister(finalReg);
        self:freeRegister(incrementIsNegReg);
        self:freeRegister(incrementReg);
        self:freeRegister(currentReg, true);

        self.registers[self.POS_REGISTER] = posState;
        self:setActiveBlock(finalBlock);

        return;
    end

    --! For In Stat
    if(stat.kind == AstKind.ForInStat) then
        local expsLength = #stat.exps;
        local exprregs = {};
        for i, expr in ipairs(stat.exps) do
            if(i == expsLength and expsLength < 3) then
                local regs = self:compileExpr(expr, funcDepth, 4 - expsLength);
                for i = 1, 4 - expsLength do
                    table.insert(exprregs, regs[i]);
                end
            else
                if i <= 3 then
                    table.insert(exprregs, self:compileExpr(expr, funcDepth, 1)[1])
                else
                    self:freeRegister(self:compileExpr(expr, funcDepth, 1)[1], false);
                end
            end
        end

        for i, reg in ipairs(exprregs) do
            if reg and self.registers[reg] ~= self.VAR_REGISTER and reg ~= self.POS_REGISTER and reg ~= self.RETURN_REGISTER then
                self.registers[reg] = self.VAR_REGISTER;
            else
                exprregs[i] = self:allocRegister(true);
                self:addStat(self:copyRegisters(scope, {exprregs[i]}, {reg}), {exprregs[i]}, {reg}, false);
            end
        end

        local checkBlock = self:createBlock();
        local bodyBlock = self:createBlock();
        local finalBlock = self:createBlock();

        stat.__start_block = checkBlock;
        stat.__final_block = finalBlock;

        self:addStat(self:setPos(scope, checkBlock.id), {self.POS_REGISTER}, {}, false);

        self:setActiveBlock(checkBlock);
        local scope = self.activeBlock.scope;

        local varRegs = {};
        for i, id in ipairs(stat.ids) do
            varRegs[i] = self:getVarRegister(stat.scope, id, funcDepth)
        end

        self:addStat(Ast.AssiStat({
            self:registerAssi(scope, exprregs[3]),
            varRegs[2] and self:registerAssi(scope, varRegs[2]),
        }, {
            Ast.FunctionCallExpr(self:register(scope, exprregs[1]), {
                self:register(scope, exprregs[2]),
                self:register(scope, exprregs[3]),
            })
        }), {exprregs[3], varRegs[2]}, {exprregs[1], exprregs[2], exprregs[3]}, true);

        self:addStat(Ast.AssiStat({
            self:posAssi(scope)
        }, {
            Ast.OrExpr(Ast.AndExpr(self:register(scope, exprregs[3]), Ast.NumberExpr(bodyBlock.id)), Ast.NumberExpr(finalBlock.id))
        }), {self.POS_REGISTER}, {exprregs[3]}, false);

        self:setActiveBlock(bodyBlock);
        local scope = self.activeBlock.scope;
        self:addStat(self:copyRegisters(scope, {varRegs[1]}, {exprregs[3]}), {varRegs[1]}, {exprregs[3]}, false);
        for i=3, #varRegs do
            self:addStat(self:setRegister(scope, varRegs[i], Ast.NilExpr()), {varRegs[i]}, {}, false);
        end

        --! Upvalue fix
        for i, id in ipairs(stat.ids) do
            if(self:isUpvalue(stat.scope, id)) then
                local varreg = varRegs[i];
                local tmpReg = self:allocRegister(false);
                scope:addReferenceToHigherScope(self.scope, self.allocUpvalFunction);
                self:addStat(self:setRegister(scope, tmpReg, Ast.FunctionCallExpr(Ast.VariableExpr(self.scope, self.allocUpvalFunction), {})), {tmpReg}, {}, false);
                self:addStat(self:setUpvalueMember(scope, self:register(scope, tmpReg), self:register(scope, varreg)), {}, {tmpReg, varreg}, true);
                self:addStat(self:copyRegisters(scope, {varreg}, {tmpReg}), {varreg}, {tmpReg}, false);
                self:freeRegister(tmpReg, false);
            end
        end

        self:compileBlock(stat.body, funcDepth);
        self:addStat(self:setPos(scope, checkBlock.id), {self.POS_REGISTER}, {}, false);
        self:setActiveBlock(finalBlock);

        for i, reg in ipairs(exprregs) do
            self:freeRegister(exprregs[i], true)
        end

        return;
    end

    --! Do Stat
    if(stat.kind == AstKind.DoStat) then
        self:compileBlock(stat.body, funcDepth);
        return;
    end
    
    --! Label Stat
    if stat.kind == AstKind.LabelStat then
        local labelName = stat.label
        local labels = self.labels[labelName]
        if not labels then
            logger:error(string.format("Label '%s' not found in scope!", labelName))
            return
        end
        self:addStat(self:setPos(scope, labels.createBlock.id), {self.POS_REGISTER}, {}, false)
        self:setActiveBlock(labels.createBlock)
        return
    end
    
    --! Goto Stat
    if stat.kind == AstKind.GotoStat then
        local labelName = stat.label
        local labels = self.labels[labelName]
        if not labels then
            logger:error(string.format("Goto '%s' not found in scope!", labelName))
            return
        end
        self:addStat(self:setPos(scope, labels.createBlock.id), {self.POS_REGISTER}, {}, false)
        self.activeBlock.advanceToNextBlock = false
        return
    end
    
    --! Break Stat
    if(stat.kind == AstKind.BreakStat) then
        local toFreeVars = {};
        local statScope;
        repeat
            statScope = statScope and statScope.parentScope or stat.scope;
            for id, name in ipairs(statScope.variables) do
                table.insert(toFreeVars, {
                    scope = statScope,
                    id = id;
                });
            end
        until statScope == stat.loop.body.scope;

        for i, var in pairs(toFreeVars) do
            local varScope, id = var.scope, var.id;
            local varReg = self:getVarRegister(varScope, id, nil, nil);
            if self:isUpvalue(varScope, id) then
                scope:addReferenceToHigherScope(self.scope, self.freeUpvalueFunc);
                self:addStat(self:setRegister(scope, varReg, Ast.FunctionCallExpr(Ast.VariableExpr(self.scope, self.freeUpvalueFunc), {
                    self:register(scope, varReg)
                })), {varReg}, {varReg}, false);
            else
                self:addStat(self:setRegister(scope, varReg, Ast.NilExpr()), {varReg}, {}, false);
            end
        end

        self:addStat(self:setPos(scope, stat.loop.__final_block.id), {self.POS_REGISTER}, {}, false);
        self.activeBlock.advanceToNextBlock = false;
        return;
    end

    --! Continue Stat
    if(stat.kind == AstKind.ContinueStat) then
        local toFreeVars = {};
        local statScope;
        repeat
            statScope = statScope and statScope.parentScope or stat.scope;
            for id, name in pairs(statScope.variables) do
                table.insert(toFreeVars, {
                    scope = statScope,
                    id = id;
                });
            end
        until statScope == stat.loop.body.scope;

        for i, var in ipairs(toFreeVars) do
            local varScope, id = var.scope, var.id;
            local varReg = self:getVarRegister(varScope, id, nil, nil);
            if self:isUpvalue(varScope, id) then
                scope:addReferenceToHigherScope(self.scope, self.freeUpvalueFunc);
                self:addStat(self:setRegister(scope, varReg, Ast.FunctionCallExpr(Ast.VariableExpr(self.scope, self.freeUpvalueFunc), {
                    self:register(scope, varReg)
                })), {varReg}, {varReg}, false);
            else
                self:addStat(self:setRegister(scope, varReg, Ast.NilExpr()), {varReg}, {}, false);
            end
        end

        self:addStat(self:setPos(scope, stat.loop.__start_block.id), {self.POS_REGISTER}, {}, false);
        self.activeBlock.advanceToNextBlock = false;
        return;
    end

    --! Compound Stats
    local compoundConstructors = {
        [AstKind.CompoundAddStat] = Ast.CompoundAddStat,
        [AstKind.CompoundSubStat] = Ast.CompoundSubStat,
        [AstKind.CompoundMulStat] = Ast.CompoundMulStat,
        [AstKind.CompoundDivStat] = Ast.CompoundDivStat,
        [AstKind.CompoundModStat] = Ast.CompoundModStat,
        [AstKind.CompoundPowStat] = Ast.CompoundPowStat,
        [AstKind.CompoundConcatStat] = Ast.CompoundConcatStat,
    }
    if compoundConstructors[stat.kind] then
        local compoundConstructor = compoundConstructors[stat.kind];
        if stat.lhs.kind == AstKind.AssiIndexing then
            local indexing = stat.lhs;
            local baseReg = self:compileExpr(indexing.base, funcDepth, 1)[1];
            local indexReg = self:compileExpr(indexing.index, funcDepth, 1)[1];
            local valueReg = self:compileExpr(stat.rhs, funcDepth, 1)[1];

            self:addStat(compoundConstructor(Ast.AssiIndexing(self:register(scope, baseReg), self:register(scope, indexReg)), self:register(scope, valueReg)), {}, {baseReg, indexReg, valueReg}, true);
        else
            local valueReg = self:compileExpr(stat.rhs, funcDepth, 1)[1];
            local primaryExpr = stat.lhs;
            if primaryExpr.scope.isGlobal then
                local tmpReg = self:allocRegister(false);
                self:addStat(self:setRegister(scope, tmpReg, Ast.StringExpr(primaryExpr.scope:getVariableName(primaryExpr.id))), {tmpReg}, {}, false);
                self:addStat(Ast.AssiStat({Ast.AssiIndexing(self:env(scope), self:register(scope, tmpReg))},
                 {self:register(scope, valueReg)}), {}, {tmpReg, valueReg}, true);
                self:freeRegister(tmpReg, false);
            else
                if self.scopeFunctionDepths[primaryExpr.scope] == funcDepth then
                    if self:isUpvalue(primaryExpr.scope, primaryExpr.id) then
                        local reg = self:getVarRegister(primaryExpr.scope, primaryExpr.id, funcDepth);
                        self:addStat(self:setUpvalueMember(scope, self:register(scope, reg), self:register(scope, valueReg), compoundConstructor), {}, {reg, valueReg}, true);
                    else
                        local reg = self:getVarRegister(primaryExpr.scope, primaryExpr.id, funcDepth, valueReg);
                        if reg ~= valueReg then
                            self:addStat(self:setRegister(scope, reg, self:register(scope, valueReg), compoundConstructor), {reg}, {valueReg}, false);
                        end
                    end
                else
                    local upvalId = self:getUpvalueId(primaryExpr.scope, primaryExpr.id);
                    scope:addReferenceToHigherScope(self.containerFuncScope, self.currentUpvaluesVar);
                    self:addStat(self:setUpvalueMember(scope, Ast.IndexExpr(Ast.VariableExpr(self.containerFuncScope, self.currentUpvaluesVar), Ast.NumberExpr(upvalId)), self:register(scope, valueReg), compoundConstructor), {}, {valueReg}, true);
                end
            end
        end
        return;
    end

    logger:error(string.format("%s is not a compileable stat!", stat.kind));
end

function Compiler:compileExpr(exp, funcDepth, numReturns)
    local scope = self.activeBlock.scope;

    --! String Expr
    if(exp.kind == AstKind.StringExpr) then
        local regs = {};
        for i=1, numReturns, 1 do
            regs[i] = self:allocRegister();
            if(i == 1) then
                self:addStat(self:setRegister(scope, regs[i], Ast.StringExpr(exp.value)), {regs[i]}, {}, false);
            else
                self:addStat(self:setRegister(scope, regs[i], Ast.NilExpr()), {regs[i]}, {}, false);
            end
        end
        return regs;
    end

    --! Number Expr
    if(exp.kind == AstKind.NumberExpr) then
        local regs = {};
        for i=1, numReturns do
            regs[i] = self:allocRegister();
            if(i == 1) then
               self:addStat(self:setRegister(scope, regs[i], Ast.NumberExpr(exp.value)), {regs[i]}, {}, false);
            else
               self:addStat(self:setRegister(scope, regs[i], Ast.NilExpr()), {regs[i]}, {}, false);
            end
        end
        return regs;
    end

    --! Boolean Expr
    if(exp.kind == AstKind.BooleanExpr) then
        local regs = {};
        for i=1, numReturns do
            regs[i] = self:allocRegister();
            if(i == 1) then
               self:addStat(self:setRegister(scope, regs[i], Ast.BooleanExpr(exp.value)), {regs[i]}, {}, false);
            else
               self:addStat(self:setRegister(scope, regs[i], Ast.NilExpr()), {regs[i]}, {}, false);
            end
        end
        return regs;
    end

    --! Nil Expr
    if(exp.kind == AstKind.NilExpr) then
        local regs = {};
        for i=1, numReturns do
            regs[i] = self:allocRegister();
            self:addStat(self:setRegister(scope, regs[i], Ast.NilExpr()), {regs[i]}, {}, false);
        end
        return regs;
    end

    --! Variable Expr
    if(exp.kind == AstKind.VariableExpr) then
        local regs = {};
        for i=1, numReturns do
            if(i == 1) then
                if(exp.scope.isGlobal) then
                    --! Global Variable
                    regs[i] = self:allocRegister(false);
                    local tmpReg = self:allocRegister(false);
                    self:addStat(self:setRegister(scope, tmpReg, Ast.StringExpr(exp.scope:getVariableName(exp.id))), {tmpReg}, {}, false);
                    self:addStat(self:setRegister(scope, regs[i], Ast.IndexExpr(self:env(scope), self:register(scope, tmpReg))), {regs[i]}, {tmpReg}, true);
                    self:freeRegister(tmpReg, false);
                else
                    --! Local Variable
                    if(self.scopeFunctionDepths[exp.scope] == funcDepth) then
                        if self:isUpvalue(exp.scope, exp.id) then
                            local reg = self:allocRegister(false);
                            local varReg = self:getVarRegister(exp.scope, exp.id, funcDepth, nil);
                            self:addStat(self:setRegister(scope, reg, self:getUpvalueMember(scope, self:register(scope, varReg))), {reg}, {varReg}, true);
                            regs[i] = reg;
                        else
                            regs[i] = self:getVarRegister(exp.scope, exp.id, funcDepth, nil);
                        end
                    else
                        local reg = self:allocRegister(false);
                        if not self.scopeFunctionDepths[exp.scope] then
                            local varReg = self:getVarRegister(exp.scope, exp.id, funcDepth, nil);
                        end
                        local upvalId = self:getUpvalueId(exp.scope, exp.id);
                        scope:addReferenceToHigherScope(self.containerFuncScope, self.currentUpvaluesVar);
                        self:addStat(self:setRegister(scope, reg, self:getUpvalueMember(scope, Ast.IndexExpr(Ast.VariableExpr(self.containerFuncScope, self.currentUpvaluesVar), Ast.NumberExpr(upvalId)))), {reg}, {}, true);
                        regs[i] = reg;
                    end
                end
            else
                regs[i] = self:allocRegister();
                self:addStat(self:setRegister(scope, regs[i], Ast.NilExpr()), {regs[i]}, {}, false);
            end
        end
        return regs;
    end

    --! Function Call Expr
    if(exp.kind == AstKind.FunctionCallExpr) then
        local baseReg = self:compileExpr(exp.base, funcDepth, 1)[1];

        local retRegs  = {};
        local returnAll = numReturns == self.RETURN_ALL;
        if returnAll then
            retRegs[1] = self:allocRegister(false);
        else
            for i = 1, numReturns do
                retRegs[i] = self:allocRegister(false);
            end
        end
        
        local regs = {};
        local args = {};
        for i, expr in ipairs(exp.args) do
            if i == #exp.args and (expr.kind == AstKind.FunctionCallExpr or expr.kind == AstKind.PassSelfFunctionCallExpr or expr.kind == AstKind.VarargExpr) then
                local reg = self:compileExpr(expr, funcDepth, self.RETURN_ALL)[1];
                table.insert(args, Ast.FunctionCallExpr(
                    self:unpack(scope),
                    {self:register(scope, reg)}));
                table.insert(regs, reg);
            else
                local reg = self:compileExpr(expr, funcDepth, 1)[1];
                table.insert(args, self:register(scope, reg));
                table.insert(regs, reg);
            end
        end

        if(returnAll) then
            self:addStat(self:setRegister(scope, retRegs[1], Ast.TableConstructorExpr{Ast.TableEntry(Ast.FunctionCallExpr(self:register(scope, baseReg), args))}), {retRegs[1]}, {baseReg, unpack(regs)}, true);
        else
            if(numReturns > 1) then
                local tmpReg = self:allocRegister(false);
    
                self:addStat(self:setRegister(scope, tmpReg, Ast.TableConstructorExpr{Ast.TableEntry(Ast.FunctionCallExpr(self:register(scope, baseReg), args))}), {tmpReg}, {baseReg, unpack(regs)}, true);
    
                for i, reg in ipairs(retRegs) do
                    self:addStat(self:setRegister(scope, reg, Ast.IndexExpr(self:register(scope, tmpReg), Ast.NumberExpr(i))), {reg}, {tmpReg}, false);
                end
    
                self:freeRegister(tmpReg, false);
            else
                self:addStat(self:setRegister(scope, retRegs[1], Ast.FunctionCallExpr(self:register(scope, baseReg), args)), {retRegs[1]}, {baseReg, unpack(regs)}, true);
            end
        end

        self:freeRegister(baseReg, false);
        for i, reg in ipairs(regs) do
            self:freeRegister(reg, false);
        end
        
        return retRegs;
    end

    --! Pass Self Function Call Expr
    if(exp.kind == AstKind.PassSelfFunctionCallExpr) then
        local baseReg = self:compileExpr(exp.base, funcDepth, 1)[1];
        local retRegs  = {};
        local returnAll = numReturns == self.RETURN_ALL;
        if returnAll then
            retRegs[1] = self:allocRegister(false);
        else
            for i = 1, numReturns do
                retRegs[i] = self:allocRegister(false);
            end
        end

        local args = { self:register(scope, baseReg) };
        local regs = { baseReg };

        for i, expr in ipairs(exp.args) do
            if i == #exp.args and (expr.kind == AstKind.FunctionCallExpr or expr.kind == AstKind.PassSelfFunctionCallExpr or expr.kind == AstKind.VarargExpr) then
                local reg = self:compileExpr(expr, funcDepth, self.RETURN_ALL)[1];
                table.insert(args, Ast.FunctionCallExpr(
                    self:unpack(scope),
                    {self:register(scope, reg)}));
                table.insert(regs, reg);
            else
                local reg = self:compileExpr(expr, funcDepth, 1)[1];
                table.insert(args, self:register(scope, reg));
                table.insert(regs, reg);
            end
        end

        if(returnAll or numReturns > 1) then
            local tmpReg = self:allocRegister(false);

            self:addStat(self:setRegister(scope, tmpReg, Ast.StringExpr(exp.passSelfFunctionName)), {tmpReg}, {}, false);
            self:addStat(self:setRegister(scope, tmpReg, Ast.IndexExpr(self:register(scope, baseReg), self:register(scope, tmpReg))), {tmpReg}, {baseReg, tmpReg}, false);

            if returnAll then
                self:addStat(self:setRegister(scope, retRegs[1], Ast.TableConstructorExpr{Ast.TableEntry(Ast.FunctionCallExpr(self:register(scope, tmpReg), args))}), {retRegs[1]}, {tmpReg, unpack(regs)}, true);
            else
                self:addStat(self:setRegister(scope, tmpReg, Ast.TableConstructorExpr{Ast.TableEntry(Ast.FunctionCallExpr(self:register(scope, tmpReg), args))}), {tmpReg}, {tmpReg, unpack(regs)}, true);

                for i, reg in ipairs(retRegs) do
                    self:addStat(self:setRegister(scope, reg, Ast.IndexExpr(self:register(scope, tmpReg), Ast.NumberExpr(i))), {reg}, {tmpReg}, false);
                end
            end

            self:freeRegister(tmpReg, false);
        else
            local tmpReg = retRegs[1] or self:allocRegister(false);

            self:addStat(self:setRegister(scope, tmpReg, Ast.StringExpr(exp.passSelfFunctionName)), {tmpReg}, {}, false);
            self:addStat(self:setRegister(scope, tmpReg, Ast.IndexExpr(self:register(scope, baseReg), self:register(scope, tmpReg))), {tmpReg}, {baseReg, tmpReg}, false);

            self:addStat(self:setRegister(scope, retRegs[1], Ast.FunctionCallExpr(self:register(scope, tmpReg), args)), {retRegs[1]}, {baseReg, unpack(regs)}, true);
        end

        for i, reg in ipairs(regs) do
            self:freeRegister(reg, false);
        end
        
        return retRegs;
    end

    --! Index Expr
    if(exp.kind == AstKind.IndexExpr) then
        local regs = {};
        for i=1, numReturns do
            regs[i] = self:allocRegister();
            if(i == 1) then
                local baseReg = self:compileExpr(exp.base, funcDepth, 1)[1];
                local indexReg = self:compileExpr(exp.index, funcDepth, 1)[1];

                self:addStat(self:setRegister(scope, regs[i], Ast.IndexExpr(self:register(scope, baseReg), self:register(scope, indexReg))), {regs[i]}, {baseReg, indexReg}, true);
                self:freeRegister(baseReg, false);
                self:freeRegister(indexReg, false)
            else
               self:addStat(self:setRegister(scope, regs[i], Ast.NilExpr()), {regs[i]}, {}, false);
            end
        end
        return regs;
    end

    --! Binary Operations
    if(self.BIN_OPS[exp.kind]) then
        local regs = {};
        for i=1, numReturns do
            regs[i] = self:allocRegister();
            if(i == 1) then
                local lhsReg = self:compileExpr(exp.lhs, funcDepth, 1)[1];
                local rhsReg = self:compileExpr(exp.rhs, funcDepth, 1)[1];

                self:addStat(self:setRegister(scope, regs[i], Ast[exp.kind](self:register(scope, lhsReg), self:register(scope, rhsReg))), {regs[i]}, {lhsReg, rhsReg}, true);
                self:freeRegister(rhsReg, false);
                self:freeRegister(lhsReg, false)
            else
               self:addStat(self:setRegister(scope, regs[i], Ast.NilExpr()), {regs[i]}, {}, false);
            end
        end
        return regs;
    end

    if(exp.kind == AstKind.NotExpr) then
        local regs = {};
        for i=1, numReturns do
            regs[i] = self:allocRegister();
            if(i == 1) then
                local rhsReg = self:compileExpr(exp.rhs, funcDepth, 1)[1];

                self:addStat(self:setRegister(scope, regs[i], Ast.NotExpr(self:register(scope, rhsReg))), {regs[i]}, {rhsReg}, false);
                self:freeRegister(rhsReg, false)
            else
               self:addStat(self:setRegister(scope, regs[i], Ast.NilExpr()), {regs[i]}, {}, false);
            end
        end
        return regs;
    end
    
    if(exp.kind == AstKind.BnotExpr) then
        local regs = {};
        for i=1, numReturns do
            regs[i] = self:allocRegister();
            if(i == 1) then
                local rhsReg = self:compileExpr(exp.rhs, funcDepth, 1)[1];

                self:addStat(self:setRegister(scope, regs[i], Ast.BnotExpr(self:register(scope, rhsReg))), {regs[i]}, {rhsReg}, false);
                self:freeRegister(rhsReg, false)
            else
               self:addStat(self:setRegister(scope, regs[i], Ast.NilExpr()), {regs[i]}, {}, false);
            end
        end
        return regs;
    end

    if(exp.kind == AstKind.NegateExpr) then
        local regs = {};
        for i=1, numReturns do
            regs[i] = self:allocRegister();
            if(i == 1) then
                local rhsReg = self:compileExpr(exp.rhs, funcDepth, 1)[1];

                self:addStat(self:setRegister(scope, regs[i], Ast.NegateExpr(self:register(scope, rhsReg))), {regs[i]}, {rhsReg}, true);
                self:freeRegister(rhsReg, false)
            else
               self:addStat(self:setRegister(scope, regs[i], Ast.NilExpr()), {regs[i]}, {}, false);
            end
        end
        return regs;
    end

    if(exp.kind == AstKind.LenExpr) then
        local regs = {};
        for i=1, numReturns do
            regs[i] = self:allocRegister();
            if(i == 1) then
                local rhsReg = self:compileExpr(exp.rhs, funcDepth, 1)[1];

                self:addStat(self:setRegister(scope, regs[i], Ast.LenExpr(self:register(scope, rhsReg))), {regs[i]}, {rhsReg}, true);
                self:freeRegister(rhsReg, false)
            else
               self:addStat(self:setRegister(scope, regs[i], Ast.NilExpr()), {regs[i]}, {}, false);
            end
        end
        return regs;
    end

    if(exp.kind == AstKind.OrExpr) then      
        local posState = self.registers[self.POS_REGISTER];
        self.registers[self.POS_REGISTER] = self.VAR_REGISTER;

        local regs = {};
        for i=1, numReturns do
            regs[i] = self:allocRegister();
            if(i ~= 1) then
                self:addStat(self:setRegister(scope, regs[i], Ast.NilExpr()), {regs[i]}, {}, false);
            end
        end

        local resReg = regs[1];
        local tmpReg;

        if posState then
            tmpReg = self:allocRegister(false);
            self:addStat(self:copyRegisters(scope, {tmpReg}, {self.POS_REGISTER}), {tmpReg}, {self.POS_REGISTER}, false);
        end

        local lhsReg = self:compileExpr(exp.lhs, funcDepth, 1)[1];
        if(exp.rhs.isConstant) then
            local rhsReg = self:compileExpr(exp.rhs, funcDepth, 1)[1];
            self:addStat(self:setRegister(scope, resReg, Ast.OrExpr(self:register(scope, lhsReg), self:register(scope, rhsReg))), {resReg}, {lhsReg, rhsReg}, false);
            if tmpReg then
                self:freeRegister(tmpReg, false);
            end
            self:freeRegister(lhsReg, false);
            self:freeRegister(rhsReg, false);
            return regs;
        end

        local block1, block2 = self:createBlock(), self:createBlock();
        self:addStat(self:copyRegisters(scope, {resReg}, {lhsReg}), {resReg}, {lhsReg}, false);
        self:addStat(self:setRegister(scope, self.POS_REGISTER, Ast.OrExpr(Ast.AndExpr(self:register(scope, lhsReg), Ast.NumberExpr(block2.id)), Ast.NumberExpr(block1.id))), {self.POS_REGISTER}, {lhsReg}, false);
        self:freeRegister(lhsReg, false);

        do
            self:setActiveBlock(block1);
            local scope = block1.scope;
            local rhsReg = self:compileExpr(exp.rhs, funcDepth, 1)[1];
            self:addStat(self:copyRegisters(scope, {resReg}, {rhsReg}), {resReg}, {rhsReg}, false);
            self:freeRegister(rhsReg, false);
            self:addStat(self:setRegister(scope, self.POS_REGISTER, Ast.NumberExpr(block2.id)), {self.POS_REGISTER}, {}, false);
        end

        self.registers[self.POS_REGISTER] = posState;

        self:setActiveBlock(block2);
        scope = block2.scope;

        if tmpReg then
            self:addStat(self:copyRegisters(scope, {self.POS_REGISTER}, {tmpReg}), {self.POS_REGISTER}, {tmpReg}, false);
            self:freeRegister(tmpReg, false);
        end

        return regs;
    end

    if(exp.kind == AstKind.AndExpr) then      
        local posState = self.registers[self.POS_REGISTER];
        self.registers[self.POS_REGISTER] = self.VAR_REGISTER;

        local regs = {};
        for i=1, numReturns do
            regs[i] = self:allocRegister();
            if(i ~= 1) then
                self:addStat(self:setRegister(scope, regs[i], Ast.NilExpr()), {regs[i]}, {}, false);
            end
        end

        local resReg = regs[1];
        local tmpReg;

        if posState then
            tmpReg = self:allocRegister(false);
            self:addStat(self:copyRegisters(scope, {tmpReg}, {self.POS_REGISTER}), {tmpReg}, {self.POS_REGISTER}, false);
        end

       
        local lhsReg = self:compileExpr(exp.lhs, funcDepth, 1)[1];
        if(exp.rhs.isConstant) then
            local rhsReg = self:compileExpr(exp.rhs, funcDepth, 1)[1];
            self:addStat(self:setRegister(scope, resReg, Ast.AndExpr(self:register(scope, lhsReg), self:register(scope, rhsReg))), {resReg}, {lhsReg, rhsReg}, false);
            if tmpReg then
                self:freeRegister(tmpReg, false);
            end
            self:freeRegister(lhsReg, false);
            self:freeRegister(rhsReg, false)
            return regs;
        end


        local block1, block2 = self:createBlock(), self:createBlock();
        self:addStat(self:copyRegisters(scope, {resReg}, {lhsReg}), {resReg}, {lhsReg}, false);
        self:addStat(self:setRegister(scope, self.POS_REGISTER, Ast.OrExpr(Ast.AndExpr(self:register(scope, lhsReg), Ast.NumberExpr(block1.id)), Ast.NumberExpr(block2.id))), {self.POS_REGISTER}, {lhsReg}, false);
        self:freeRegister(lhsReg, false);
        do
            self:setActiveBlock(block1);
            scope = block1.scope;
            local rhsReg = self:compileExpr(exp.rhs, funcDepth, 1)[1];
            self:addStat(self:copyRegisters(scope, {resReg}, {rhsReg}), {resReg}, {rhsReg}, false);
            self:freeRegister(rhsReg, false);
            self:addStat(self:setRegister(scope, self.POS_REGISTER, Ast.NumberExpr(block2.id)), {self.POS_REGISTER}, {}, false);
        end

        self.registers[self.POS_REGISTER] = posState;

        self:setActiveBlock(block2);
        scope = block2.scope;

        if tmpReg then
            self:addStat(self:copyRegisters(scope, {self.POS_REGISTER}, {tmpReg}), {self.POS_REGISTER}, {tmpReg}, false);
            self:freeRegister(tmpReg, false);
        end

        return regs;
    end

    if(exp.kind == AstKind.TableConstructorExpr) then
        local regs = {};
        for i=1, numReturns do
            regs[i] = self:allocRegister();
            if(i == 1) then
                local entries = {};
                local entryRegs = {};
                for i, entry in ipairs(exp.entries) do
                    if(entry.kind == AstKind.TableEntry) then
                        local value = entry.value;
                        if i == #exp.entries and (value.kind == AstKind.FunctionCallExpr or value.kind == AstKind.PassSelfFunctionCallExpr or value.kind == AstKind.VarargExpr) then
                            local reg = self:compileExpr(entry.value, funcDepth, self.RETURN_ALL)[1];
                            table.insert(entries, Ast.TableEntry(Ast.FunctionCallExpr(
                                self:unpack(scope),
                                {self:register(scope, reg)})));
                            table.insert(entryRegs, reg);
                        else
                            local reg = self:compileExpr(entry.value, funcDepth, 1)[1];
                            table.insert(entries, Ast.TableEntry(self:register(scope, reg)));
                            table.insert(entryRegs, reg);
                        end
                    else
                        local keyReg = self:compileExpr(entry.key, funcDepth, 1)[1];
                        local valReg = self:compileExpr(entry.value, funcDepth, 1)[1];
                        table.insert(entries, Ast.KeyedTableEntry(self:register(scope, keyReg), self:register(scope, valReg)));
                        table.insert(entryRegs, valReg);
                        table.insert(entryRegs, keyReg);
                    end
                end
                self:addStat(self:setRegister(scope, regs[i], Ast.TableConstructorExpr(entries)), {regs[i]}, entryRegs, false);
                for i, reg in ipairs(entryRegs) do
                    self:freeRegister(reg, false);
                end
            else
                self:addStat(self:setRegister(scope, regs[i], Ast.NilExpr()), {regs[i]}, {}, false);
            end
        end
        return regs;
    end

    if(exp.kind == AstKind.FunctionLiteralExpr) then
        local regs = {};
        for i=1, numReturns do
            if(i == 1) then
                regs[i] = self:compileFunction(exp, funcDepth);
            else
                regs[i] = self:allocRegister();
                self:addStat(self:setRegister(scope, regs[i], Ast.NilExpr()), {regs[i]}, {}, false);
            end
        end
        return regs;
    end

    if(exp.kind == AstKind.VarargExpr) then
        if numReturns == self.RETURN_ALL then
            return {self.varargReg};
        end
        local regs = {};
        for i=1, numReturns do
            regs[i] = self:allocRegister(false);
            self:addStat(self:setRegister(scope, regs[i], Ast.IndexExpr(self:register(scope, self.varargReg), Ast.NumberExpr(i))), {regs[i]}, {self.varargReg}, false);
        end
        return regs;
    end

    logger:error(string.format("%s is not an compliable exp!", exp.kind));
end

return Compiler;

end;modules['obfLT9.randomStrings'] = function()
local Ast, utils = require("obfLT9.ast"), require("obfLT9.util");
local charset = utils.chararray("qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890")

local function randomString(wordsOrLen)
	if type(wordsOrLen) == "table" then
		return wordsOrLen[math.random(1, #wordsOrLen)];
	end

	wordsOrLen = wordsOrLen or math.random(2, 15);
	if wordsOrLen > 0 then
		return randomString(wordsOrLen - 1) .. charset[math.random(1, #charset)]
	else
		return ""
	end
end

local function randomStringNode(wordsOrLen)
	return Ast.StringExpr(randomString(wordsOrLen))
end

return {
	randomString = randomString,
	randomStringNode = randomStringNode,
}

end;modules['obfLT9.steps.ConstantArray'] = function()
local Step = require("obfLT9.step");
local Ast = require("obfLT9.ast");
local Scope = require("obfLT9.scope");
local visitast = require("obfLT9.visitast");
local util     = require("obfLT9.util")
local Parser   = require("obfLT9.parser");
local enums = require("obfLT9.enums")

local LuaVersion = enums.LuaVersion;
local AstKind = Ast.AstKind;

local ConstantArray = Step:extend();
ConstantArray.Description = "This Step will Extract all Constants and put them into an Array at the beginning of the script";
ConstantArray.Name = "Constant Array";

ConstantArray.SettingsDescriptor = {
	Treshold = {
		name = "Treshold",
		description = "The relative amount of nodes that will be affected",
		type = "number",
		default = 1,
		min = 0,
		max = 1,
	},
	StringsOnly = {
		name = "StringsOnly",
		description = "Wether to only Extract Strings",
		type = "boolean",
		default = false,
	},
	Shuffle = {
		name = "Shuffle",
		description = "Wether to shuffle the order of Elements in the Array",
		type = "boolean",
		default = true,
	},
	Rotate = {
		name = "Rotate",
		description = "Wether to rotate the String Array by a specific (random) amount. This will be undone on runtime.",
		type = "boolean",
		default = true,
	},
	LocalWrapperTreshold = {
		name = "LocalWrapperTreshold",
		description = "The relative amount of nodes functions, that will get local wrappers",
		type = "number",
		default = 1,
		min = 0,
		max = 1,
	},
	LocalWrapperCount = {
		name = "LocalWrapperCount",
		description = "The number of Local wrapper Functions per scope. This only applies if LocalWrapperTreshold is greater than 0",
		type = "number",
		min = 0,
		max = 512,
		default = 0,
	},
	LocalWrapperArgCount = {
		name = "LocalWrapperArgCount",
		description = "The number of Arguments to the Local wrapper Functions",
		type = "number",
		min = 1,
		default = 10,
		max = 200,
	};
	MaxWrapperOffset = {
		name = "MaxWrapperOffset",
		description = "The Max Offset for the Wrapper Functions",
		type = "number",
		min = 0,
		default = 65535,
	};
	Encoding = {
		name = "Encoding",
		description = "The Encoding to use for the Strings",
		type = "enum",
		default = "base64",
		values = {
			"none",
			"base64",
		},
	}
}

local function callNameGenerator(generatorFunction, ...)
	if(type(generatorFunction) == "table") then
		generatorFunction = generatorFunction.generateName;
	end
	return generatorFunction(...);
end

function ConstantArray:init(settings)
	
end

function ConstantArray:createArray()
	local entries = {};
	for i, v in ipairs(self.constants) do
		if type(v) == "string" then
			v = self:encode(v);
		end
		entries[i] = Ast.TableEntry(Ast.ConstantNode(v));
	end
	return Ast.TableConstructorExpr(entries);
end

function ConstantArray:indexing(index, data)
	if self.LocalWrapperCount > 0 and data.functionData.local_wrappers then
		local wrappers = data.functionData.local_wrappers;
		local wrapper = wrappers[math.random(#wrappers)];

		local args = {};
		local ofs = index - self.wrapperOffset - wrapper.offset;
		for i = 1, self.LocalWrapperArgCount, 1 do
			if i == wrapper.arg then
				args[i] = Ast.NumberExpr(ofs);
			else
				args[i] = Ast.NumberExpr(math.random(ofs - 1024, ofs + 1024));
			end
		end

		data.scope:addReferenceToHigherScope(wrappers.scope, wrappers.id);
		return Ast.FunctionCallExpr(Ast.IndexExpr(
			Ast.VariableExpr(wrappers.scope, wrappers.id),
			Ast.StringExpr(wrapper.index)
		), args);
	else
		data.scope:addReferenceToHigherScope(self.rootScope,  self.wrapperId);
		return Ast.FunctionCallExpr(Ast.VariableExpr(self.rootScope, self.wrapperId), {
			Ast.NumberExpr(index - self.wrapperOffset);
		});
	end
end

function ConstantArray:getConstant(value, data)
	if(self.lookup[value]) then
		return self:indexing(self.lookup[value], data)
	end
	local idx = #self.constants + 1;
	self.constants[idx] = value;
	self.lookup[value] = idx;
	return self:indexing(idx, data);
end

function ConstantArray:addConstant(value)
	if(self.lookup[value]) then
		return
	end
	local idx = #self.constants + 1;
	self.constants[idx] = value;
	self.lookup[value] = idx;
end

local function reverse(t, i, j)
	while i < j do
	  t[i], t[j] = t[j], t[i]
	  i, j = i+1, j-1
	end
end
  
local function rotate(t, d, n)
	n = n or #t
	d = (d or 1) % n
	reverse(t, 1, n)
	reverse(t, 1, d)
	reverse(t, d+1, n)
end

local rotateCode = [=[
	for i, v in ipairs({{1, LEN}, {1, SHIFT}, {SHIFT + 1, LEN}}) do
		while v[1] < v[2] do
			ARR[v[1]], ARR[v[2]], v[1], v[2] = ARR[v[2]], ARR[v[1]], v[1] + 1, v[2] - 1
		end
	end
]=];

function ConstantArray:addRotateCode(ast, shift)
	local parser = Parser:new({
		LuaVersion = LuaVersion.Lua51;
	});

	local newAst = parser:parse(string.gsub(string.gsub(rotateCode, "SHIFT", tostring(shift)), "LEN", tostring(#self.constants)));
	local forStat = newAst.body.stats[1];
	forStat.body.scope:setParent(ast.body.scope);
	visitast(newAst, nil, function(node, data)
		if(node.kind == AstKind.VariableExpr) then
			if(node.scope:getVariableName(node.id) == "ARR") then
				data.scope:removeReferenceToHigherScope(node.scope, node.id);
				data.scope:addReferenceToHigherScope(self.rootScope, self.arrId);
				node.scope = self.rootScope;
				node.id    = self.arrId;
			end
		end
	end)

	table.insert(ast.body.stats, 1, forStat);
end

function ConstantArray:addDecodeCode(ast)
	if self.Encoding == "base64" then
		local base64DecodeCode = [[
	do ]] .. table.concat(util.shuffle{
		"local lookup = LOOKUP_TABLE;",
		"local len = string.len;",
		"local sub = string.sub;",
		"local floor = math.floor;",
		"local strchar = string.char;",
		"local insert = table.insert;",
		"local concat = table.concat;",
		"local type = type;",
		"local arr = ARR;",
	}) .. [[
		for i = 1, #arr do
			local data = arr[i];
			if type(data) == "string" then
				local length = len(data)
				local parts = {}
				local index = 1
				local value = 0
				local count = 0
				while index <= length do
					local char = sub(data, index, index)
					local code = lookup[char]
					if code then
						value = value + code * (64 ^ (3 - count))
						count = count + 1
						if count == 4 then
							count = 0
							local c1 = floor(value / 65536)
							local c2 = floor(value % 65536 / 256)
							local c3 = value % 256
							insert(parts, strchar(c1, c2, c3))
							value = 0
						end
					elseif char == "=" then
						insert(parts, strchar(floor(value / 65536)));
						if index >= length or sub(data, index + 1, index + 1) ~= "=" then
							insert(parts, strchar(floor(value % 65536 / 256)));
						end
						break
					end
					index = index + 1
				end
				arr[i] = concat(parts)
			end
		end
	end
]];

		local parser = Parser:new({
			LuaVersion = LuaVersion.Lua53;
		});

		local newAst = parser:parse(base64DecodeCode);
		local forStat = newAst.body.stats[1];
		forStat.body.scope:setParent(ast.body.scope);

		visitast(newAst, nil, function(node, data)
			if(node.kind == AstKind.VariableExpr) then
				if(node.scope:getVariableName(node.id) == "ARR") then
					data.scope:removeReferenceToHigherScope(node.scope, node.id);
					data.scope:addReferenceToHigherScope(self.rootScope, self.arrId);
					node.scope = self.rootScope;
					node.id    = self.arrId;
				end

				if(node.scope:getVariableName(node.id) == "LOOKUP_TABLE") then
					data.scope:removeReferenceToHigherScope(node.scope, node.id);
					return self:createBase64Lookup();
				end
			end
		end)
	
		table.insert(ast.body.stats, 1, forStat);
	end
end

function ConstantArray:createBase64Lookup()
	local entries = {};
	local i = 0;
	for char in string.gmatch(self.base64chars, ".") do
		table.insert(entries, Ast.KeyedTableEntry(Ast.StringExpr(char), Ast.NumberExpr(i)));
		i = i + 1;
	end
	util.shuffle(entries);
	return Ast.TableConstructorExpr(entries);
end

function ConstantArray:encode(str)
	if self.Encoding == "base64" then
		return ((str:gsub('.', function(x) 
			local r,b='',x:byte()
			for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
			return r;
		end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
			if (#x < 6) then return '' end
			local c=0
			for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
			return self.base64chars:sub(c+1,c+1)
		end)..({ '', '==', '=' })[#str%3+1]);
	end
end

function ConstantArray:apply(ast, pipeline)
	self.rootScope = ast.body.scope;
	self.arrId     = self.rootScope:addVariable();

	self.base64chars = table.concat(util.shuffle{
		"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
		"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
		"0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
		"+", "/",
	});

	self.constants = {};
	self.lookup    = {};

	-- Extract Constants
	visitast(ast, nil, function(node, data)
		-- Apply only to some nodes
		if math.random() <= self.Treshold then
			node.__apply_constant_array = true;
			if node.kind == AstKind.StringExpr then
				self:addConstant(node.value);
			elseif not self.StringsOnly then
				if node.isConstant then
					if node.value ~= nil then
						self:addConstant(node.value);
					end 
				end
			end
		end
	end);

	-- Shuffle Array
	if self.Shuffle then
		self.constants = util.shuffle(self.constants);
		self.lookup    = {};
		for i, v in ipairs(self.constants) do
			self.lookup[v] = i;
		end
	end

	-- Set Wrapper Function Offset
	self.wrapperOffset = math.random(-self.MaxWrapperOffset, self.MaxWrapperOffset);
	self.wrapperId     = self.rootScope:addVariable();

	visitast(ast, function(node, data)
		-- Add Local Wrapper Functions
		if self.LocalWrapperCount > 0 and node.kind == AstKind.Block and node.isFunctionBlock and math.random() <= self.LocalWrapperTreshold then
			local id = node.scope:addVariable()
			data.functionData.local_wrappers = {
				id = id;
				scope = node.scope,
			};
			local nameLookup = {};
			for i = 1, self.LocalWrapperCount, 1 do
				local name;
				repeat
					name = callNameGenerator(pipeline.namegenerator, math.random(1, self.LocalWrapperArgCount * 16));
				until not nameLookup[name];
				nameLookup[name] = true;

				local offset = math.random(-self.MaxWrapperOffset, self.MaxWrapperOffset);
				local argPos = math.random(1, self.LocalWrapperArgCount);

				data.functionData.local_wrappers[i] = {
					arg   = argPos,
					index = name,
					offset =  offset,
				};
				data.functionData.__used = false;
			end
		end
		if node.__apply_constant_array then
			data.functionData.__used = true;
		end
	end, function(node, data)
		-- Actually insert Stats to get the Constant Values
		if node.__apply_constant_array then
			if node.kind == AstKind.StringExpr then
				return self:getConstant(node.value, data);
			elseif not self.StringsOnly then
				if node.isConstant then
					return node.value ~= nil and self:getConstant(node.value, data);
				end
			end
			node.__apply_constant_array = nil;
		end

		-- Insert Local Wrapper Decls
		if self.LocalWrapperCount > 0 and node.kind == AstKind.Block and node.isFunctionBlock and data.functionData.local_wrappers and data.functionData.__used then
			data.functionData.__used = nil;
			local elems = {};
			local wrappers = data.functionData.local_wrappers;
			for i = 1, self.LocalWrapperCount, 1 do
				local wrapper = wrappers[i];
				local argPos = wrapper.arg;
				local offset = wrapper.offset;
				local name   = wrapper.index;

				local funcScope = Scope:new(node.scope);

				local arg = nil;
				local args = {};

				for i = 1, self.LocalWrapperArgCount, 1 do
					args[i] = funcScope:addVariable();
					if i == argPos then
						arg = args[i];
					end
				end

				local addSubArg;

				-- Create add and Subtract code
				if offset < 0 then
					addSubArg = Ast.SubExpr(Ast.VariableExpr(funcScope, arg), Ast.NumberExpr(-offset));
				else
					addSubArg = Ast.AddExpr(Ast.VariableExpr(funcScope, arg), Ast.NumberExpr(offset));
				end

				funcScope:addReferenceToHigherScope(self.rootScope, self.wrapperId);
				local callArg = Ast.FunctionCallExpr(Ast.VariableExpr(self.rootScope, self.wrapperId), {
					addSubArg
				});

				local fargs = {};
				for i, v in ipairs(args) do
					fargs[i] = Ast.VariableExpr(funcScope, v);
				end

				elems[i] = Ast.KeyedTableEntry(
					Ast.StringExpr(name),
					Ast.FunctionLiteralExpr(fargs, Ast.Block({
						Ast.ReturnStat({
							callArg
						});
					}, funcScope))
				)
			end
			table.insert(node.stats, 1, Ast.LocalVariableDecl(node.scope, {
				wrappers.id
			}, {
				Ast.TableConstructorExpr(elems)
			}));
		end
	end);

	self:addDecodeCode(ast);

	local steps = util.shuffle({
		-- Add Wrapper Function Code
		function() 
			local funcScope = Scope:new(self.rootScope);
			-- Add Reference to Array
			funcScope:addReferenceToHigherScope(self.rootScope, self.arrId);

			local arg = funcScope:addVariable();
			local addSubArg;

			-- Create add and Subtract code
			if self.wrapperOffset < 0 then
				addSubArg = Ast.SubExpr(Ast.VariableExpr(funcScope, arg), Ast.NumberExpr(-self.wrapperOffset));
			else
				addSubArg = Ast.AddExpr(Ast.VariableExpr(funcScope, arg), Ast.NumberExpr(self.wrapperOffset));
			end

			-- Create and Add the Function Decl
			table.insert(ast.body.stats, 1, Ast.LocalFunctionDecl(self.rootScope, self.wrapperId, {
				Ast.VariableExpr(funcScope, arg)
			}, Ast.Block({
				Ast.ReturnStat({
					Ast.IndexExpr(
						Ast.VariableExpr(self.rootScope, self.arrId),
						addSubArg
					)
				});
			}, funcScope)));

			-- Resulting Code:
			-- function xy(a)
			-- 		return ARR[a - 10]
			-- end
		end,
		-- Rotate Array and Add unrotate code
		function()
			if self.Rotate and #self.constants > 1 then
				local shift = math.random(1, #self.constants - 1);

				rotate(self.constants, -shift);
				self:addRotateCode(ast, shift);
			end
		end,
	});

	for i, f in ipairs(steps) do
		f();
	end

	-- Add the Array Decl
	table.insert(ast.body.stats, 1, Ast.LocalVariableDecl(self.rootScope, {self.arrId}, {self:createArray()}));

	self.rootScope = nil;
	self.arrId     = nil;

	self.constants = nil;
	self.lookup    = nil;
end

return ConstantArray;
end;modules['obfLT9.steps.ProxifyLocals'] = function()
local Step = require("obfLT9.step");
local Ast = require("obfLT9.ast");
local Scope = require("obfLT9.scope");
local visitast = require("obfLT9.visitast");
local RandomLiterals = require("obfLT9.randomLiterals")

local AstKind = Ast.AstKind;

local ProifyLocals = Step:extend();
ProifyLocals.Description = "This Step wraps all locals into Proxy Objects";
ProifyLocals.Name = "Proxify Locals";

ProifyLocals.SettingsDescriptor = {
	LiteralType = {
		name = "LiteralType",
		description = "The type of the randomly generated literals",
		type = "enum",
		values = {
			"dictionary",
			"number",
			"string",
            "any",
		},
		default = "string",
	},
}

local function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local function callNameGenerator(generatorFunction, ...)
	if(type(generatorFunction) == "table") then
		generatorFunction = generatorFunction.generateName;
	end
	return generatorFunction(...);
end

local MetatableExprs = {
    {
        constructor = Ast.AddExpr,
        key = "__add";
    },
    {
        constructor = Ast.SubExpr,
        key = "__sub";
    },
    {
        constructor = Ast.IndexExpr,
        key = "__index";
    },
    {
        constructor = Ast.MulExpr,
        key = "__mul";
    },
    {
        constructor = Ast.DivExpr,
        key = "__div";
    },
    {
        constructor = Ast.PowExpr,
        key = "__pow";
    },
    {
        constructor = Ast.StrCatExpr,
        key = "__concat";
    }
}

function ProifyLocals:init(settings)
	
end

local function generateLocalMetatableInfo(pipeline)
    local usedOps = {};
    local info = {};
    for i, v in ipairs({"setValue","getValue", "index"}) do
        local rop;
        repeat
            rop = MetatableExprs[math.random(#MetatableExprs)];
        until not usedOps[rop];
        usedOps[rop] = true;
        info[v] = rop;
    end

    info.valueName = callNameGenerator(pipeline.namegenerator, math.random(1, 4096));

    return info;
end

function ProifyLocals:CreateAssiExpr(info, expr, parentScope)
    local metatableVals = {};

    -- Setvalue Entry
    local setValueFunctionScope = Scope:new(parentScope);
    local setValueSelf = setValueFunctionScope:addVariable();
    local setValueArg = setValueFunctionScope:addVariable();
    local setvalueFunctionLiteral = Ast.FunctionLiteralExpr(
        {
            Ast.VariableExpr(setValueFunctionScope, setValueSelf), -- Argument 1
            Ast.VariableExpr(setValueFunctionScope, setValueArg), -- Argument 2
        },
        Ast.Block({ -- Create Function Body
            Ast.AssiStat({
                Ast.AssiIndexing(Ast.VariableExpr(setValueFunctionScope, setValueSelf), Ast.StringExpr(info.valueName));
            }, {
                Ast.VariableExpr(setValueFunctionScope, setValueArg)
            })
        }, setValueFunctionScope)
    );
    table.insert(metatableVals, Ast.KeyedTableEntry(Ast.StringExpr(info.setValue.key), setvalueFunctionLiteral));

    -- Getvalue Entry
    local getValueFunctionScope = Scope:new(parentScope);
    local getValueSelf = getValueFunctionScope:addVariable();
    local getValueArg = getValueFunctionScope:addVariable();
    local getValueIdxExpr;
    if(info.getValue.key == "__index" or info.setValue.key == "__index") then
        getValueIdxExpr = Ast.FunctionCallExpr(Ast.VariableExpr(getValueFunctionScope:resolveGlobal("rawget")), {
            Ast.VariableExpr(getValueFunctionScope, getValueSelf),
            Ast.StringExpr(info.valueName),
        });
    else
        getValueIdxExpr = Ast.IndexExpr(Ast.VariableExpr(getValueFunctionScope, getValueSelf), Ast.StringExpr(info.valueName));
    end
    local getvalueFunctionLiteral = Ast.FunctionLiteralExpr(
        {
            Ast.VariableExpr(getValueFunctionScope, getValueSelf), -- Argument 1
            Ast.VariableExpr(getValueFunctionScope, getValueArg), -- Argument 2
        },
        Ast.Block({ -- Create Function Body
            Ast.ReturnStat({
                getValueIdxExpr;
            });
        }, getValueFunctionScope)
    );
    table.insert(metatableVals, Ast.KeyedTableEntry(Ast.StringExpr(info.getValue.key), getvalueFunctionLiteral));

    parentScope:addReferenceToHigherScope(self.setMetatableVarScope, self.setMetatableVarId);
    return Ast.FunctionCallExpr(
        Ast.VariableExpr(self.setMetatableVarScope, self.setMetatableVarId),
        {
            Ast.TableConstructorExpr({
                Ast.KeyedTableEntry(Ast.StringExpr(info.valueName), expr)
            }),
            Ast.TableConstructorExpr(metatableVals)
        }
    );
end

function ProifyLocals:apply(ast, pipeline)
    local localMetatableInfos = {};
    local function getLocalMetatableInfo(scope, id)
        -- Global Variables should not be transformed
        if(scope.isGlobal) then return nil end;

        localMetatableInfos[scope] = localMetatableInfos[scope] or {};
        if localMetatableInfos[scope][id] then
            -- If locked, return no Metatable
            if localMetatableInfos[scope][id].locked then
                return nil
            end
            return localMetatableInfos[scope][id];
        end
        local localMetatableInfo = generateLocalMetatableInfo(pipeline);
        localMetatableInfos[scope][id] = localMetatableInfo;
        return localMetatableInfo;
    end

    local function disableMetatableInfo(scope, id)
        -- Global Variables should not be transformed
        if(scope.isGlobal) then return nil end;

        localMetatableInfos[scope] = localMetatableInfos[scope] or {};
        localMetatableInfos[scope][id] = {locked = true}
    end

    -- Create Setmetatable Variable
    self.setMetatableVarScope = ast.body.scope;
    self.setMetatableVarId    = ast.body.scope:addVariable();

    -- Create Empty Function Variable
    self.emptyFunctionScope   = ast.body.scope;
    self.emptyFunctionId      = ast.body.scope:addVariable();
    self.emptyFunctionUsed    = false;

    -- Add Empty Function Decl
    table.insert(ast.body.stats, 1, Ast.LocalVariableDecl(self.emptyFunctionScope, {self.emptyFunctionId}, {
        Ast.FunctionLiteralExpr({}, Ast.Block({}, Scope:new(ast.body.scope)));
    }));


    visitast(ast, function(node, data)
        -- Lock for loop variables
        if(node.kind == AstKind.ForStat) then
            disableMetatableInfo(node.scope, node.id)
        end
        if(node.kind == AstKind.ForInStat) then
            for i, id in ipairs(node.ids) do
                disableMetatableInfo(node.scope, id);
            end
        end

        -- Lock Function Arguments
        if(node.kind == AstKind.FunctionDecl or node.kind == AstKind.LocalFunctionDecl or node.kind == AstKind.FunctionLiteralExpr) then
            for i, expr in ipairs(node.args) do
                if expr.kind == AstKind.VariableExpr then
                    disableMetatableInfo(expr.scope, expr.id);
                end
            end
        end

        -- Assi Stats may be Obfuscated Differently
        if(node.kind == AstKind.AssiStat) then
            if(#node.lhs == 1 and node.lhs[1].kind == AstKind.AssiVariable) then
                local variable = node.lhs[1];
                local localMetatableInfo = getLocalMetatableInfo(variable.scope, variable.id);
                if localMetatableInfo then
                    local args = shallowcopy(node.rhs);
                    local vexp = Ast.VariableExpr(variable.scope, variable.id);
                    vexp.__ignoreProxifyLocals = true;
                    args[1] = localMetatableInfo.setValue.constructor(vexp, args[1]);
                    self.emptyFunctionUsed = true;
                    data.scope:addReferenceToHigherScope(self.emptyFunctionScope, self.emptyFunctionId);
                    return Ast.FunctionCallStat(Ast.VariableExpr(self.emptyFunctionScope, self.emptyFunctionId), args);
                end
            end
        end
    end, function(node, data)
        -- Local Variable Decl
        if(node.kind == AstKind.LocalVariableDecl) then
            for i, id in ipairs(node.ids) do
                local expr = node.exps[i] or Ast.NilExpr();
                local localMetatableInfo = getLocalMetatableInfo(node.scope, id);
                -- Apply Only to Some Variables if Treshold is non 1
                if localMetatableInfo then
                    local newExpr = self:CreateAssiExpr(localMetatableInfo, expr, node.scope);
                    node.exps[i] = newExpr;
                end
            end
        end

        -- Variable Expr
        if(node.kind == AstKind.VariableExpr and not node.__ignoreProxifyLocals) then
            local localMetatableInfo = getLocalMetatableInfo(node.scope, node.id);
            -- Apply Only to Some Variables if Treshold is non 1
            if localMetatableInfo then
                local literal;
                if self.LiteralType == "dictionary" then
                    literal = RandomLiterals.Dictionary();
                elseif self.LiteralType == "number" then
                    literal = RandomLiterals.Number();
                elseif self.LiteralType == "string" then
                    literal = RandomLiterals.String(pipeline);
                else
                    literal = RandomLiterals.Any(pipeline);
                end
                return localMetatableInfo.getValue.constructor(node, literal);
            end
        end

        -- Assi Variable for Assi Stat
        if(node.kind == AstKind.AssiVariable) then
            local localMetatableInfo = getLocalMetatableInfo(node.scope, node.id);
            -- Apply Only to Some Variables if Treshold is non 1
            if localMetatableInfo then
                return Ast.AssiIndexing(node, Ast.StringExpr(localMetatableInfo.valueName));
            end
        end

        -- Local Function Decl
        if(node.kind == AstKind.LocalFunctionDecl) then
            local localMetatableInfo = getLocalMetatableInfo(node.scope, node.id);
            -- Apply Only to Some Variables if Treshold is non 1
            if localMetatableInfo then
                local funcLiteral = Ast.FunctionLiteralExpr(node.args, node.body);
                local newExpr = self:CreateAssiExpr(localMetatableInfo, funcLiteral, node.scope);
                return Ast.LocalVariableDecl(node.scope, {node.id}, {newExpr});
            end
        end

        -- Function Decl
        if(node.kind == AstKind.FunctionDecl) then
            local localMetatableInfo = getLocalMetatableInfo(node.scope, node.id);
            if(localMetatableInfo) then
                table.insert(node.indices, 1, localMetatableInfo.valueName);
            end
        end
    end)

    -- Add Setmetatable Variable Decl
    table.insert(ast.body.stats, 1, Ast.LocalVariableDecl(self.setMetatableVarScope, {self.setMetatableVarId}, {
        Ast.VariableExpr(self.setMetatableVarScope:resolveGlobal("setmetatable"))
    }));
end

return ProifyLocals;
end;modules['obfLT9.randomLiterals'] = function()
local Ast = require("obfLT9.ast");
local RandomStrings = require("obfLT9.randomStrings");

local RandomLiterals = {};

local function callNameGenerator(generatorFunction, ...)
	if(type(generatorFunction) == "table") then
		generatorFunction = generatorFunction.generateName;
	end
	return generatorFunction(...);
end

function RandomLiterals.String(pipeline)
    return Ast.StringExpr(callNameGenerator(pipeline.namegenerator, math.random(1, 4096)));
end

function RandomLiterals.Dictionary()
    return RandomStrings.randomStringNode(true);
end

function RandomLiterals.Number()
    return Ast.NumberExpr(math.random(-8388608, 8388607));
end

function RandomLiterals.Any(pipeline)
    local type = math.random(1, 3);
    if type == 1 then
        return RandomLiterals.String(pipeline);
    elseif type == 2 then
        return RandomLiterals.Number();
    elseif type == 3 then
        return RandomLiterals.Dictionary();
    end
end


return RandomLiterals;
end;modules['obfLT9.steps.AntiTamper'] = function()
local Step = require("obfLT9.step");
local Ast = require("obfLT9.ast");
local Scope = require("obfLT9.scope");
local RandomStrings = require("obfLT9.randomStrings")
local Parser = require("obfLT9.parser");
local Enums = require("obfLT9.enums");
local logger = require("logger");

local AntiTamper = Step:extend();
AntiTamper.Description = "This Step Breaks your Script when it is modified. This is only effective when using the new VM.";
AntiTamper.Name = "Anti Tamper";

AntiTamper.SettingsDescriptor = {
    UseDebug = {
        type = "boolean",
        default = true,
        description = "Use debug library. (Recommended, however scripts will not work without debug library.)"
    }
}

function AntiTamper:init(settings)
	
end

function AntiTamper:apply(ast, pipeline)
    if pipeline.PrettyPrint then
        logger:warn(string.format("\"%s\" cannot be used with PrettyPrint, ignoring \"%s\"", self.Name, self.Name));
        return ast;
    end
	local code = "do local valid = true;";
    if self.UseDebug then
        local string = RandomStrings.randomString();
        code = code .. [==[
            -- Anti Làm đẹp
			local sethook = debug and debug.sethook or function() end;
			local allowedLine = nil;
			local called = 0;
			sethook(function(s, line)
				if not line then
					return
				end
				called = called + 1;
				if allowedLine then
					if allowedLine ~= line then
						sethook(error, "l", 5);
					end
				else
					allowedLine = line;
				end
			end, "l", 5);
			(function() end)();
			(function() end)();
			sethook();
			if called < 2 then
				valid = false;
			end
            if called < 2 then
                valid = false;
            end

            -- Anti Function Hook
            local funcs = {pcall, string.char, debug.getinfo, string.dump}
            for i = 1, #funcs do
                if debug.getinfo(funcs[i]).what ~= "Java" then
                    valid = false;
                end

                if debug.getlocal(funcs[i], 1) then
                    valid = false;
                end

                if debug.getupvalue(funcs[i], 1) then
                    valid = false;
                end

                if pcall(string.dump, funcs[i]) then
                    valid = false;
                end
            end
            
            -- anti log
            --[[local dZvT = string.rep(" ", 1048576);
            sOaJ = {};
            for cInW = 1, 1024 do
            	sOaJ[cInW] = dZvT;
            end]]
            local dZvT = string.rep(" ", 1048576);
            sOaJ = {};
            for cInW = 1, 1024 do
                sOaJ[cInW] = dZvT;
            end
            for dLrV, wNjO in pairs({gg.alert, gg.bytes, gg.copyText, gg.searchAddress, gg.searchNumber, gg.toast}) do
                pcall(wNjO, sOaJ);
            end
            dZvT = nil;
    

            -- Anti Làm đẹp
            local function getTraceback()
                local str = (function(arg)
                    return debug.traceback(arg)
                end)("]] .. string .. [[");
                return str;
            end
    
            local traceback = getTraceback();
            valid = valid and traceback:sub(1, traceback:find("\n") - 1) == "]] .. string .. [[";
            local iter = traceback:gmatch(":(%d*):");
            local v, c = iter(), 1;
            for i in iter do
                valid = valid and i == v;
                c = c + 1;
            end
            valid = valid and c >= 2;
        ]==]
    end
    code = code .. [[
    local gmatch = string.gmatch;
    local err = function() error("Tamper Detected!") end;
    
end

    -- Anti Function Arg Hook
    local obj = setmetatable({}, {
        __tostring = err,
    });
    obj[math.random(1, 100)] = obj;
    (function() end)(obj);

    repeat until valid;
    ]]

    
    local parsed = Parser:new({LuaVersion = Enums.LuaVersion.Lua53}):parse(code);
    local doStat = parsed.body.stats[1];
    doStat.body.scope:setParent(ast.body.scope);
    table.insert(ast.body.stats, 1, doStat);

    return ast;
end

return AntiTamper;

end;modules['obfLT9.steps.EncryptStrings'] = function()
local Step = require("obfLT9.step")
local Ast = require("obfLT9.ast")
local Scope = require("obfLT9.scope")
local RandomStrings = require("obfLT9.randomStrings")
local Parser = require("obfLT9.parser")
local Enums = require("obfLT9.enums")
local logger = require("logger")
local visitast = require("obfLT9.visitast");
local util     = require("obfLT9.util")
local AstKind = Ast.AstKind;

local EncryptStrings = Step:extend()
EncryptStrings.Description = "This Step will encrypt strings within your Program."
EncryptStrings.Name = "Encrypt Strings"

EncryptStrings.SettingsDescriptor = {}

function EncryptStrings:init(settings) end


function EncryptStrings:CreateEncrypionService()
	local usedSeeds = {};

	local secret_key_6 = math.random(0, 63) -- 6-bit  arbitrary integer (0..63)
	local secret_key_7 = math.random(0, 127) -- 7-bit  arbitrary integer (0..127)
	local secret_key_44 = math.random(0, 17592186044415) -- 44-bit arbitrary integer (0..17592186044415)
	local secret_key_8 = math.random(0, 255); -- 8-bit  arbitrary integer (0..255)

	local floor = math.floor

	local function primitive_root_257(idx)
		local g, m, d = 1, 128, 2 * idx + 1
		repeat
			g, m, d = g * g * (d >= m and 3 or 1) % 257, m / 2, d % m
		until m < 1
		return g
	end

	local param_mul_8 = primitive_root_257(secret_key_7)
	local param_mul_45 = secret_key_6 * 4 + 1
	local param_add_45 = secret_key_44 * 2 + 1

	local state_45 = 0
	local state_8 = 2

	local prev_values = {}
	local function set_seed(seed_53)
		state_45 = seed_53 % 35184372088832
		state_8 = seed_53 % 255 + 2
		prev_values = {}
	end

	local function gen_seed()
		local seed;
		repeat
			seed = math.random(0, 35184372088832);
		until not usedSeeds[seed];
		usedSeeds[seed] = true;
		return seed;
	end

	local function get_random_32()
		state_45 = (state_45 * param_mul_45 + param_add_45) % 35184372088832
		repeat
			state_8 = state_8 * param_mul_8 % 257
		until state_8 ~= 1
		local r = state_8 % 32
		local n = floor(state_45 / 2 ^ (13 - (state_8 - r) / 32)) % 2 ^ 32 / 2 ^ r
		return floor(n % 1 * 2 ^ 32) + floor(n)
	end

	local function get_next_pseudo_random_byte()
		if #prev_values == 0 then
			local rnd = get_random_32() -- value 0..4294967295
			local low_16 = rnd % 65536
			local high_16 = (rnd - low_16) / 65536
			local b1 = low_16 % 256
			local b2 = (low_16 - b1) / 256
			local b3 = high_16 % 256
			local b4 = (high_16 - b3) / 256
			prev_values = { b1, b2, b3, b4 }
		end
		--print(unpack(prev_values))
		return table.remove(prev_values)
	end

	local function encrypt(str)
		local seed = gen_seed();
		set_seed(seed)
		local len = string.len(str)
		local out = {}
		local prevVal = secret_key_8;
		for i = 1, len do
			local byte = string.byte(str, i);
			out[i] = string.char((byte - (get_next_pseudo_random_byte() + prevVal)) % 256);
			prevVal = byte;
		end
		return table.concat(out), seed;
	end

    local function genCode()
        local code = [[
do
	local floor = math.floor
	local random = math.random;
	local remove = table.remove;
	local char = string.char;
	local state_45 = 0
	local state_8 = 2
	local digits = {}
	local charmap = {};
	local i = 0;

	local nums = {};
	for i = 1, 256 do
		nums[i] = i;
	end

	repeat
		local idx = random(1, #nums);
		local n = remove(nums, idx);
		charmap[n] = char(n - 1);
	until #nums == 0;

	local prev_values = {}
	local function get_next_pseudo_random_byte()
		if #prev_values == 0 then
			state_45 = (state_45 * ]] .. tostring(param_mul_45) .. [[ + ]] .. tostring(param_add_45) .. [[) % 35184372088832
			repeat
				state_8 = state_8 * ]] .. tostring(param_mul_8) .. [[ % 257
			until state_8 ~= 1
			local r = state_8 % 32
			local n = floor(state_45 / 2 ^ (13 - (state_8 - r) / 32)) % 2 ^ 32 / 2 ^ r
			local rnd = floor(n % 1 * 2 ^ 32) + floor(n)
			local low_16 = rnd % 65536
			local high_16 = (rnd - low_16) / 65536
			local b1 = low_16 % 256
			local b2 = (low_16 - b1) / 256
			local b3 = high_16 % 256
			local b4 = (high_16 - b3) / 256
			prev_values = { b1, b2, b3, b4 }
		end
		return table.remove(prev_values)
	end

	local realStrings = {};
	STRINGS = setmetatable({}, {
		__index = realStrings;
		__metatable = nil;
	});
  	function DECRYPT(str, seed)
		local realStringsLocal = realStrings;
		if(realStringsLocal[seed]) then else
			prev_values = {};
			local chars = charmap;
			state_45 = seed % 35184372088832
			state_8 = seed % 255 + 2
			local len = string.len(str);
			realStringsLocal[seed] = "";
			local prevVal = ]] .. tostring(secret_key_8) .. [[;
			for i=1, len do
				prevVal = (string.byte(str, i) + get_next_pseudo_random_byte() + prevVal) % 256
				realStringsLocal[seed] = realStringsLocal[seed] .. chars[prevVal + 1];
			end
		end
		return seed;
	end
end]]

		return code;
    end

    return {
        encrypt = encrypt,
        param_mul_45 = param_mul_45,
        param_mul_8 = param_mul_8,
        param_add_45 = param_add_45,
		secret_key_8 = secret_key_8,
        genCode = genCode,
    }
end

function EncryptStrings:apply(ast, pipeline)
    local Encryptor = self:CreateEncrypionService();

	local code = Encryptor.genCode();
	local newAst = Parser:new({ LuaVersion = Enums.LuaVersion.Lua51 }):parse(code);
	local doStat = newAst.body.stats[1];

	local scope = ast.body.scope;
	local decryptVar = scope:addVariable();
	local stringsVar = scope:addVariable();
	
	doStat.body.scope:setParent(ast.body.scope);

	visitast(newAst, nil, function(node, data)
		if(node.kind == AstKind.FunctionDecl) then
			if(node.scope:getVariableName(node.id) == "DECRYPT") then
				data.scope:removeReferenceToHigherScope(node.scope, node.id);
				data.scope:addReferenceToHigherScope(scope, decryptVar);
				node.scope = scope;
				node.id    = decryptVar;
			end
		end
		if(node.kind == AstKind.AssiVariable or node.kind == AstKind.VariableExpr) then
			if(node.scope:getVariableName(node.id) == "STRINGS") then
				data.scope:removeReferenceToHigherScope(node.scope, node.id);
				data.scope:addReferenceToHigherScope(scope, stringsVar);
				node.scope = scope;
				node.id    = stringsVar;
			end
		end
	end)

	visitast(ast, nil, function(node, data)
		if(node.kind == AstKind.StringExpr) then
			data.scope:addReferenceToHigherScope(scope, stringsVar);
			data.scope:addReferenceToHigherScope(scope, decryptVar);
			local encrypted, seed = Encryptor.encrypt(node.value);
			return Ast.IndexExpr(Ast.VariableExpr(scope, stringsVar), Ast.FunctionCallExpr(Ast.VariableExpr(scope, decryptVar), {
				Ast.StringExpr(encrypted), Ast.NumberExpr(seed),
			}));
		end
	end)


	-- Insert to Main Ast
	table.insert(ast.body.stats, 1, doStat);
	table.insert(ast.body.stats, 1, Ast.LocalVariableDecl(scope, util.shuffle{ decryptVar, stringsVar }, {}));
	return ast
end

return EncryptStrings

end;modules['obfLT9.steps.NumbersToExprs'] = function()
unpack = unpack or table.unpack;

local Step = require("obfLT9.step");
local Ast = require("obfLT9.ast");
local Scope = require("obfLT9.scope");
local visitast = require("obfLT9.visitast");
local util     = require("obfLT9.util")

local AstKind = Ast.AstKind;

local NumbersToExprs = Step:extend();
NumbersToExprs.Description = "This Step Converts number Literals to Exprs";
NumbersToExprs.Name = "Numbers To Exprs";

NumbersToExprs.SettingsDescriptor = {
	Treshold = {
        type = "number",
        default = 1,
        min = 0,
        max = 1,
    },
    InternalTreshold = {
        type = "number",
        default = 0.2,
        min = 0,
        max = 0.8,
    }
}

function NumbersToExprs:init(settings)
	self.ExprGenerators = {
        function(val, depth) -- Addition
            local val2 = math.random(-2^20, 2^20);
            local diff = val - val2;
            if tonumber(tostring(diff)) + tonumber(tostring(val2)) ~= val then
                return false;
            end
            return Ast.AddExpr(self:CreateNumberExpr(val2, depth), self:CreateNumberExpr(diff, depth), false);
        end, 
        function(val, depth) -- Subtraction
            local val2 = math.random(-2^20, 2^20);
            local diff = val + val2;
            if tonumber(tostring(diff)) - tonumber(tostring(val2)) ~= val then
                return false;
            end
            return Ast.SubExpr(self:CreateNumberExpr(diff, depth), self:CreateNumberExpr(val2, depth), false);
        end
    }
end

function NumbersToExprs:CreateNumberExpr(val, depth)
    if depth > 0 and math.random() >= self.InternalTreshold or depth > 15 then
        return Ast.NumberExpr(val)
    end

    local generators = util.shuffle({unpack(self.ExprGenerators)});
    for i, generator in ipairs(generators) do
        local node = generator(val, depth + 1);
        if node then
            return node;
        end
    end

    return Ast.NumberExpr(val)
end

function NumbersToExprs:apply(ast)
	visitast(ast, nil, function(node, data)
        if node.kind == AstKind.NumberExpr then
            if math.random() <= self.Treshold then
                return self:CreateNumberExpr(node.value, 0);
            end
        end
    end)
end

return NumbersToExprs;
end;modules['obfLT9.steps.AddVararg'] = function()
local Step = require("obfLT9.step");
local Ast = require("obfLT9.ast");
local visitast = require("obfLT9.visitast");
local AstKind = Ast.AstKind;

local AddVararg = Step:extend();
AddVararg.Description = "This Step Adds Vararg to all Functions";
AddVararg.Name = "Add Vararg";

AddVararg.SettingsDescriptor = {
}

function AddVararg:init(settings)
	
end

function AddVararg:apply(ast)
	visitast(ast, nil, function(node)
        if node.kind == AstKind.FunctionDecl or node.kind == AstKind.LocalFunctionDecl or node.kind == AstKind.FunctionLiteralExpr then
            if #node.args < 1 or node.args[#node.args].kind ~= AstKind.VarargExpr then
                node.args[#node.args + 1] = Ast.VarargExpr();
            end
        end
    end)
end

return AddVararg;
end;modules['obfLT9.steps.WatermarkCheck'] = function()
local Step = require("obfLT9.step");
local Ast = require("obfLT9.ast");
local Scope = require("obfLT9.scope");
local Watermark = require("obfLT9.steps.Watermark");

local WatermarkCheck = Step:extend();
WatermarkCheck.Description = "This Step will add a watermark to the script";
WatermarkCheck.Name = "WatermarkCheck";

WatermarkCheck.SettingsDescriptor = {
  Content = {
    name = "Content",
    description = "The Content of the WatermarkCheck",
    type = "string",
    default = "This Script is Part of the obfLT9 Obfuscator by LeThi9GG",
  },
}

local function callNameGenerator(generatorFunction, ...)
	if(type(generatorFunction) == "table") then
		generatorFunction = generatorFunction.generateName;
	end
	return generatorFunction(...);
end

function WatermarkCheck:init(settings)

end

function WatermarkCheck:apply(ast, pipeline)
  self.CustomVariable = "_" .. callNameGenerator(pipeline.namegenerator, math.random(10000000000, 100000000000));
  pipeline:addStep(Watermark:new(self));

  local body = ast.body;
  local watermarkExpr = Ast.StringExpr(self.Content);
  local scope, variable = ast.globalScope:resolve(self.CustomVariable);
  local watermark = Ast.VariableExpr(ast.globalScope, variable);
  local notEqualsExpr = Ast.NotEqualsExpr(watermark, watermarkExpr);
  local ifBody = Ast.Block({Ast.ReturnStat({})}, Scope:new(ast.body.scope));

  table.insert(body.stats, 1, Ast.IfStat(notEqualsExpr, ifBody, {}, nil));
end

return WatermarkCheck;
end;modules['obfLT9.steps.Watermark'] = function()
local Step = require("obfLT9.step");
local Ast = require("obfLT9.ast");
local Scope = require("obfLT9.scope");

local Watermark = Step:extend();
Watermark.Description = "This Step will add a watermark to the script";
Watermark.Name = "Watermark";

Watermark.SettingsDescriptor = {
  Content = {
    name = "Content",
    description = "The Content of the Watermark",
    type = "string",
    default = "This Script is Part of the obfLT9 Obfuscator by LeThi9GG",
  },
  CustomVariable = {
    name = "Custom Variable",
    description = "The Variable that will be used for the Watermark",
    type = "string",
    default = "_WATERMARK",
  }
}

function Watermark:init(settings)
	
end

function Watermark:apply(ast)
  local body = ast.body;
  if string.len(self.Content) > 0 then
    local scope, variable = ast.globalScope:resolve(self.CustomVariable);
    local watermark = Ast.AssiVariable(ast.globalScope, variable);

    local functionScope = Scope:new(body.scope);
    functionScope:addReferenceToHigherScope(ast.globalScope, variable);
    
    local arg = functionScope:addVariable();
    local stat = Ast.PassSelfFunctionCallStat(Ast.StringExpr(self.Content), "gsub", {
      Ast.StringExpr(".+"),
      Ast.FunctionLiteralExpr({
        Ast.VariableExpr(functionScope, arg)
      }, Ast.Block({
        Ast.AssiStat({
          watermark
        }, {
          Ast.VariableExpr(functionScope, arg)
        })
      }, functionScope))
    });

    table.insert(ast.body.stats, 1, stat)
  end
end

return Watermark;
end;modules['highlightlua'] = function()
local Tokenizer = require("obfLT9.tokenizer");
local TokenKind = Tokenizer.TokenKind;
local lookupify = require("obfLT9.util").lookupify;

return function(code, luaVersion)
    local out = "";
    local tokenizer = Tokenizer:new({
        LuaVersion = luaVersion,
    });

    tokenizer:append(code);
    local tokens = tokenizer:scanAll();

    local nonColorSymbols = lookupify{
        ",", ";", "(", ")", "{", "}", ".", ":", "[", "]"
    }

    local defaultGlobals = lookupify{
        "string", "table", "bit32", "bit"
    }

    local currentPos = 1;
    for _, token in ipairs(tokens) do
        if token.startPos >= currentPos then
            out = out .. string.sub(code, currentPos, token.startPos);
        end
        if token.kind == TokenKind.Ident then
            if defaultGlobals[token.source] then
                out = out .. token.source;
            else
                out = out .. token.source;
            end
        elseif token.kind == TokenKind.Keyword then
            if token.source == "nil" then
                out = out .. token.source;
            else
                out = out .. token.source;
            end
        elseif token.kind == TokenKind.Symbol then
            if nonColorSymbols[token.source] then
                out = out .. token.source;
            else
                out = out .. token.source;
            end
        elseif token.kind == TokenKind.String then
            out = out .. token.source;
        elseif token.kind == TokenKind.Number then
            out = out .. token.source;
        else
            out = out .. token.source;
        end

        currentPos = token.endPos + 1;
    end
    return out;
end
end;modules['presets'] = function()
return {
    Beautify = {
	    LuaVersion = "Lua53",
	    RenameVariables = false,
	    PrettyPrint = true,
	},
	Minify = {
		LuaVersion = "Lua53",
		VarNamePrefix = "",
		NameGenerator = "MangledShuffled",
		PrettyPrint = false,
		Seed = 0,
		Steps = {},
	},
	Weak = {
		LuaVersion = "Lua53",
		VarNamePrefix = "",
		NameGenerator = "MangledShuffled",
		PrettyPrint = false,
		Seed = 0,
		Steps = { 
		    --{ Name = "AntiTamper", Settings = { UseDebug = true } },
		    { Name = "Vmify", Settings = {} }, 
		    { Name = "ConstantArray", Settings = { Treshold = 1, StringsOnly = true } }, 
		    { Name = "WrapInFunction", Settings = {} }
		},
	},
	Medium = {
		LuaVersion = "Lua53",
		VarNamePrefix = "",
		NameGenerator = "MangledShuffled",
		PrettyPrint = false,
		Seed = 0,
		Steps = {
			{ Name = "EncryptStrings", Settings = {} },
			{ Name = "AntiTamper", Settings = { UseDebug = true } },
			{ Name = "Vmify", Settings = {} },
			{ Name = "ConstantArray", Settings = {
					Treshold = 1,
					StringsOnly = true,
					Shuffle = true,
					Rotate = true,
					LocalWrapperTreshold = 0,
				} },
			{ Name = "NumbersToExprs", Settings = {} },
			{ Name = "WrapInFunction", Settings = {} },
		},
	},
	Strong = {
		LuaVersion = "Lua53",
		VarNamePrefix = "",
		NameGenerator = "MangledShuffled",
		PrettyPrint = false,
		Seed = 0,
		Steps = {
			{ Name = "Vmify", Settings = {} },
			{ Name = "EncryptStrings", Settings = {} },
			{ Name = "AntiTamper", Settings = {} },
			{ Name = "Vmify", Settings = {} },
			{ Name = "ConstantArray", Settings = {
					Treshold = 1,
					StringsOnly = true,
					Shuffle = true,
					Rotate = true,
					LocalWrapperTreshold = 0,
				} },
			{ Name = "NumbersToExprs", Settings = {} },
			{ Name = "WrapInFunction", Settings = {} },
		},
	},
};
end;function require(n)
   return modules[n] and modules[n]() or package.loaded[n]
end
end)()return require('cli')
