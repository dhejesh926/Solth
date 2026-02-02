local Solth = {}
Solth.__index = Solth

function Solth:new()
    return setmetatable({
        vars = {},
        funcs = {},
    }, Solth)
end

local function trim(s) return s:match("^%s*(.-)%s*$") end

-- Evaluate expression safely
function Solth:evaluate(expr)
    local env = setmetatable({}, {__index = self.vars})
    local f, err = load("return "..expr, "expr", "t", env)
    if not f then
        f, err = load(expr, "expr", "t", env)
        if not f then error("Eval error: "..err) end
    end
    local ok,res = pcall(f)
    if not ok then error("Eval error: "..res) end
    return res
end

-- Process print arguments
local function process_print_args(str, vars)
    local parts = {}
    local i = 1
    while i <= #str do
        local c = str:sub(i,i)
        if c == '"' then
            local j=i+1
            while j<=#str and str:sub(j,j)~='"' do j=j+1 end
            table.insert(parts, str:sub(i+1,j-1))
            i=j+1
        elseif c:match("[%w_]") then
            local j=i
            while j<=#str and str:sub(j,j):match("[%w_]") do j=j+1 end
            local token=str:sub(i,j-1)
            table.insert(parts, tostring(vars[token] ~= nil and vars[token] or token))
            i=j
        else i=i+1 end
    end
    return table.concat(parts," ")
end

-- Parse a block until matching 'end', returns lines and next index
function Solth:parse_block(lines, start_idx)
    local block = {}
    local depth = 1
    local i = start_idx
    while i <= #lines do
        local line = trim(lines[i])
        if line:match("^function ") or line:match("^if ") then
            depth = depth + 1
        elseif line == "end" then
            depth = depth - 1
            if depth == 0 then return block, i end
        end
        table.insert(block, line)
        i = i + 1
    end
    return block, #lines
end

-- Execute a sequence of lines
function Solth:execute(lines)
    if type(lines)=="string" then
        local tmp={}
        for l in lines:gmatch("[^\r\n]+") do table.insert(tmp,l) end
        lines=tmp
    end

    local i = 1
    while i <= #lines do
        local ok, next_i_or_err = pcall(function() return self:execute_line(lines[i], lines, i) end)
        if not ok then
            print("Solth Error:", next_i_or_err)
            i = i + 1 -- safely move to next line on error
        else
            if type(next_i_or_err)~="number" then
                i = i + 1
            else
                i = next_i_or_err + 1
            end
        end
    end
end

-- Execute a single line
function Solth:execute_line(line, lines, idx)
    line = trim(line)
    if line=="" or line:match("^#") then return idx end

    if line:match("^set ") then
        local name,val=line:match("^set%s+(%w+)%s*=%s*(.+)$")
        self.vars[name] = self:evaluate(val)
        return idx
    end

    if line:match("^print ") then
        print(process_print_args(line:sub(7), self.vars))
        return idx
    end

    if line:match("^input ") then
        local var=line:sub(7)
        io.write(var..": "); io.flush()
        self.vars[var]=io.read("*l")
        return idx
    end

    if line:match("^eval ") then
        print("Eval:", self:evaluate(line:sub(6)))
        return idx
    end

    if line:match("^function ") then
        local fname = line:match("^function%s+(%w+)")
        local block, next_idx = self:parse_block(lines, idx+1)
        self.funcs[fname] = block
        return next_idx
    end

    if line:match("^call ") then
        local fname = line:sub(6)
        local func = self.funcs[fname]
        if not func then error("Function "..fname.." not defined") end
        self:execute(func)
        return idx
    end

    if line:match("^if ") then
        return self:execute_if_chain(lines, idx)
    end

    error("Unknown Solth command: "..line)
end

-- Execute if/elseif/else chain
function Solth:execute_if_chain(lines, start_idx)
    local i=start_idx
    local executed=false
    while i<=#lines do
        local line=trim(lines[i])
        if line=="end" then return i end

        local cond_type, cond_expr
        if line:match("^if ") then
            cond_type, cond_expr="if", line:match("^if%s+(.+)$")
        elseif line:match("^elseif ") then
            cond_type, cond_expr="elseif", line:match("^elseif%s+(.+)$")
        elseif line=="else" then
            cond_type, cond_expr="else", nil
        else
            break
        end

        local block, next_idx = {}, i+1
        while next_idx <= #lines do
            local l=trim(lines[next_idx])
            if l:match("^elseif ") or l=="else" or l=="end" then break end
            table.insert(block, l)
            next_idx = next_idx + 1
        end

        if not executed then
            if cond_type=="if" or cond_type=="elseif" then
                local status, val = pcall(function() return self:evaluate(cond_expr) end)
                if not status then print("Solth Error:", val) end
                if status and val ~= 0 then
                    self:execute(block)
                    executed=true
                end
            elseif cond_type=="else" then
                self:execute(block)
                executed=true
            end
        end

        i = next_idx
    end
    return i
end

-- Execute a .solth file
function Solth:execute_file(path)
    local f=io.open(path,"r")
    if not f then print("Cannot open file:", path); return end
    local content=f:read("*a")
    f:close()
    self:execute(content)
end

-- Global instance
solth=Solth:new()
