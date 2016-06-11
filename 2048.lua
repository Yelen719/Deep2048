-- require('torch')

score = 0;
highestTile = 0;

local function initGrid(m,n)
    local grid = {}
    for i=1,m do
        if not grid[i] then
            grid[i] = {}
        end
        for j=1,n do
            grid[i][j] = 0
        end
    end
    return grid
end

local function printGrid(grid)
    local celllen = 8  -- 每个格子占用字符数
    local gridStrLines = {}
    table.insert(gridStrLines,"-------------------------------------")
    for i,row in ipairs(grid) do
        local line = {} 
        for _,num in ipairs(row) do
            if num==0 then
                local pres = ""
                for tmp=1,celllen do
                    pres = pres .. " "
                end
                local s = string.format("%s",pres)
                table.insert(line,s)
            else
                local s = tostring(num)
                local l = string.len(s)
                local l = (celllen-l)/2
                local prel = math.floor(l)
                local sufl = math.ceil(l)
                local pres = ""
                for tmp=1,prel do
                    pres = pres .. " "
                end
                local sufs = pres
                if sufl>prel then
                    sufs = pres.. " "
                end
                local s = string.format("%s%s%s",pres,s,sufs)
                table.insert(line,s)
            end
        end
        local line = table.concat(line,"|")
        line = "|" .. line .. "|"
        table.insert(gridStrLines,line)
        table.insert(gridStrLines,"-------------------------------------")
    end
    local gridStr = table.concat(gridStrLines,"\n")
    print(gridStr)
end

local function getRandomZeroPos(grid)
    local m = #grid
    local n = #grid[1]
    local zeros = {}
    for i=1,m do
        for j=1,n do
            if grid[i][j]==0 then
                table.insert(zeros,{i=i,j=j})
            end
        end
    end
    if #zeros>0 then
        local r = math.random(1,#zeros)
        return zeros[r].i,zeros[r].j
    end
end

local function randomNum(grid)
    local i,j = getRandomZeroPos(grid)
    if i and j then
        local r = math.random()
        if r<0.9 then
            grid[i][j] = 2
        else
            grid[i][j] = 4
        end
        if grid[i][j] > highestTile then
            highestTile = grid[i][j]
        end
        return i,j
    end
end

local function moveLeft(grid)
    local oldScore = score
    local canMove = false
    local m = #grid
    local n = #grid[1]
    for i=1,m do
        local line = {}
        for j=1,n do
            if grid[i][j]~=0 then
                table.insert(line,grid[i][j])
            end
        end
        local k=#line
        for j=1,n do
            if j<=k then
                if grid[i][j] ~= line[j] then
                    canMove = true
                end
                grid[i][j] = line[j]
            else
                grid[i][j] = 0
            end
        end
        for j=1,k-1 do
            if grid[i][j]==grid[i][j+1] then
                grid[i][j+1] = grid[i][j] + grid[i][j+1]
                if grid[i][j+1] > highestTile then
                    highestTile = grid[i][j+1]
                end
                score = score + 2 * grid[i][j]
                for x=j,n-1 do
                    grid[i][x] = grid[i][x+1]
                end
                grid[i][n] = 0
            end             
        end
    end
    if oldScore ~= score then
        canMove = true
    end
    return canMove
end

local function moveRight(grid)
    local oldScore = score
    local canMove = false
    local m = #grid
    local n = #grid[1]
    for i=1,m do
        local line = {}
        for j=n,1,-1 do
            if grid[i][j]~=0 then
                table.insert(line,grid[i][j])
            end
        end
        local k = #line
        for j=n,1,-1 do
            if n-j+1<=k then
                if grid[i][j] ~= line[n-j+1] then
                    canMove = true
                end
                grid[i][j] = line[n-j+1]
            else
                grid[i][j] = 0
            end
        end
        for j=n,n-k+2,-1 do
            if grid[i][j]==grid[i][j-1] and grid[i][j] ~= 0 then
                grid[i][j-1] = grid[i][j] + grid[i][j-1]
                if grid[i][j-1] > highestTile then
                    highestTile = grid[i][j-1]
                end
                score = score + 2 * grid[i][j]
                for x=j,2,-1 do
                    grid[i][x] = grid[i][x-1]
                end
                grid[i][1] = 0
            end
        end
    end
    if oldScore ~= score then
        canMove = true
    end
    return canMove
end


local function moveUp(grid)
    local oldScore = score
    local canMove = false
    local m = #grid
    local n = #grid[1]
    for j=1,n do
        local line = {}
        for i=1,m do
            if grid[i][j]~=0 then
                table.insert(line,grid[i][j])
            end
        end
        local k = #line
        for i=1,m do
            if i<=k then
                if grid[i][j] ~= line[i] then
                    canMove = true
                end
                grid[i][j] = line[i]
            else
                grid[i][j] = 0
            end
        end
        for i=1,k-1 do
            if grid[i][j]==grid[i+1][j] and grid[i][j] ~= 0 then
                grid[i+1][j] = grid[i][j] + grid[i+1][j]
                if grid[i+1][j] > highestTile then
                    highestTile = grid[i+1][j]
                end
                score = score + 2 * grid[i][j]
                for x=i,m-1 do
                    grid[x][j] = grid[x+1][j]
                end
                grid[m][j] = 0
            end             
        end
    end
    if oldScore ~= score then
        canMove = true
    end
    return canMove
end

local function moveDown(grid)
    local oldScore = score
    local canMove = false
    local m = #grid
    local n = #grid[1]
    for j=1,n do
        local line = {}
        for i=m,1,-1 do
            if grid[i][j]~=0 then
                table.insert(line,grid[i][j])
            end
        end
        local k = #line
        for i=m,1,-1 do
            if m-i+1<=k then
                if grid[i][j] ~= line[m-i+1] then
                    canMove = true
                end
                grid[i][j] = line[m-i+1]
            else
                grid[i][j] = 0
            end
        end
        for i=m,m-k+2,-1 do
            if grid[i][j]==grid[i-1][j] then
                grid[i-1][j] = grid[i][j] + grid[i-1][j]
                if grid[i-1][j] > highestTile then
                    highestTile = grid[i-1][j]
                end
                score = score + 2 * grid[i][j]
                for x=i,2,-1 do
                    grid[x][j] = grid[x-1][j]
                end
                grid[1][j] = 0
            end
        end
    end
    if oldScore ~= score then
        canMove = true
    end
    return canMove
end

local function isOver(grid)
    local m = #grid
    local n = #grid[1]
    for i=1,m do
        for j=1,n do
            if grid[i][j]==0 then
                return true
            end
            if (i<m and j<n)
            and (grid[i][j]==grid[i][j+1]
                or grid[i][j]==grid[i+1][j]) then
                return true
            end
        end
    end
    return false
end

local function main()
    math.randomseed(os.time())
    local grid = initGrid(4,4)
    randomNum(grid)
    randomNum(grid)
    print("SCORE: " .. score .. " HIGHEST TILE: " .. highestTile)
    printGrid(grid)
    io.write("next step 'a'[←],'w'[↑],'s'[↓],'d'[→],'q'[exit] >> ")
    local input = io.read()
    while input~="q" and isOver(grid) do
        if input=="a" or input=="w" or input=="s" or input=="d" then
            local moved = false
            if input=="a" then
                moved = moveLeft(grid)
            elseif input=="w" then
                moved = moveUp(grid)
            elseif input=="s" then
                moved = moveDown(grid)
            elseif input=="d" then
                moved = moveRight(grid)
            end
            if moved == true then
                randomNum(grid)
            end
            print("SCORE: " .. score .. " HIGHEST TILE: " .. highestTile)
            printGrid(grid)
            -- print(torch.Tensor(grid))
        elseif input == "r" then
            score = 0
            highestTile = 0
            grid = initGrid(4, 4)
            math.randomseed(os.time())
            randomNum(grid)
            randomNum(grid)
            print("SCORE: " .. score .. " HIGHEST TILE: " .. highestTile)
            printGrid(grid)
        else
            print("error input. please input 'a'[←] or 'w'[↑] or 's'[↓] or 'd'[→] or 'q'[exit]")
        end
        io.write("next step 'a'[←],'w'[↑],'s'[↓],'d'[→],'q'[exit] >> ")
        input = io.read()
    end
    print("GAME OVER! " .. "Your Score is: " .. score)
end

main()

