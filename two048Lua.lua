if not torch then
    require 'torch'
end

local two048Lua = {}

two048Lua.oldScore = 0;
two048Lua.score = 0;
two048Lua.stateValue = 0;
two048Lua.oldStateValue = 0;
two048Lua.highestTile = 0;
two048Lua.grid = {};
two048Lua.actions = {"u", "d", "l", "r"};

function two048Lua.getActions()
    return two048Lua.actions;
end

function two048Lua.getScore()
    return two048Lua.score;
end

function two048Lua.updateStateValue()
    local stateValue = 0;
    stateValue = stateValue + 2 * two048Lua.grid[4][4] + 0.8 * ( two048Lua.grid[3][4] + two048Lua.grid[4][3] ) + 0.6 * (two048Lua.grid[2][4] + two048Lua.grid[4][2]) + 0.4 * (two048Lua.grid[4][1] + two048Lua.grid[1][4])
    local zeroPos = 0;
    for i = 1, 4 do
        for j = 1, 4 do
            if two048Lua.grid[i][j] == 0 then
                zeroPos = zeroPos + 1;
            end
        end
    end
    stateValue = 1.1^zeroPos * stateValue
    two048Lua.stateValue = stateValue 
end

function two048Lua.getGrid()
    return two048Lua.grid;
end

function two048Lua.getHighestTile()
    return two048Lua.highestTile
end

function two048Lua.getState()
    local screen = two048Lua.getGrid();
    local reward = two048Lua.score - two048Lua.oldScore + two048Lua.stateValue - two048Lua.oldStateValue;
    local terminal = two048Lua.isOver();
    local score = two048Lua.score - two048Lua.oldScore
    --local reward = score
    return torch.Tensor(screen), reward, terminal, score;
end

function two048Lua.initGrid(m,n)
    m = m or 4;
    n = n or 4;
    two048Lua.score = 0;
    two048Lua.highestTile = 0;
    for i=1,m do
        if not two048Lua.grid[i] then
            two048Lua.grid[i] = {}
        end
        for j=1,n do
            two048Lua.grid[i][j] = 0
        end
    end
    two048Lua.randomNum(two048Lua.grid);
    two048Lua.randomNum(two048Lua.grid);
    two048Lua.updateStateValue(); 
end

function two048Lua.printGrid()
    local celllen = 8
    local gridStrLines = {}
    table.insert(gridStrLines,"-------------------------------------")
    for i,row in ipairs(two048Lua.grid) do
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

function two048Lua.getRandomZeroPos()
    local m = #two048Lua.grid
    local n = #two048Lua.grid[1]
    local zeros = {}
    for i=1,m do
        for j=1,n do
            if two048Lua.grid[i][j]==0 then
                table.insert(zeros,{i=i,j=j})
            end
        end
    end
    if #zeros>0 then
        math.randomseed(os.time());
        local r = torch.random(1,#zeros)
        return zeros[r].i,zeros[r].j
    end
end

function two048Lua.nextRandomGame()
    two048Lua.restart();
    for i = 1,30 do 
        math.randomseed(os.time());
        two048Lua.move(two048Lua.actions[torch.random(1,#two048Lua.actions)]);
    end
end

function two048Lua.randomNum()
    local i,j = two048Lua.getRandomZeroPos(two048Lua.grid)
    if i and j then
        math.randomseed(os.time());
        local r = torch.random(1,100)
        if r<90 then
            two048Lua.grid[i][j] = 2
        else
            two048Lua.grid[i][j] = 4
        end
        if two048Lua.grid[i][j] > two048Lua.highestTile then
            two048Lua.highestTile = two048Lua.grid[i][j]
        end
        return i,j
    end
end

function two048Lua.moveLeft()
    local oldScore = two048Lua.score
    local canMove = false
    local m = #two048Lua.grid
    local n = #two048Lua.grid[1]
    for i=1,m do
        local line = {}
        for j=1,n do
            if two048Lua.grid[i][j]~=0 then
                table.insert(line,two048Lua.grid[i][j])
            end
        end
        local k=#line
        for j=1,n do
            if j<=k then
                if two048Lua.grid[i][j] ~= line[j] then
                    canMove = true
                end
                two048Lua.grid[i][j] = line[j]
            else
                two048Lua.grid[i][j] = 0
            end
        end
        for j=1,k-1 do
            if two048Lua.grid[i][j]==two048Lua.grid[i][j+1] then
                two048Lua.grid[i][j+1] = two048Lua.grid[i][j] + two048Lua.grid[i][j+1]
                if two048Lua.grid[i][j+1] > two048Lua.highestTile then
                    two048Lua.highestTile = two048Lua.grid[i][j+1]
                end
                two048Lua.score = two048Lua.score + 2 * two048Lua.grid[i][j]
                for x=j,n-1 do
                    two048Lua.grid[i][x] = two048Lua.grid[i][x+1]
                end
                two048Lua.grid[i][n] = 0
            end
        end
    end
    if oldScore ~= two048Lua.score then
        canMove = true
    end
    if canMove == true then
        two048Lua.randomNum();
    end
end

function two048Lua.moveRight()
    local oldScore = two048Lua.score
    local canMove = false
    local m = #two048Lua.grid
    local n = #two048Lua.grid[1]
    for i=1,m do
        local line = {}
        for j=n,1,-1 do
            if two048Lua.grid[i][j]~=0 then
                table.insert(line,two048Lua.grid[i][j])
            end
        end
        local k = #line
        for j=n,1,-1 do
            if n-j+1<=k then
                if two048Lua.grid[i][j] ~= line[n-j+1] then
                    canMove = true
                end
                two048Lua.grid[i][j] = line[n-j+1]
            else
                two048Lua.grid[i][j] = 0
            end
        end
        for j=n,n-k+2,-1 do
            if two048Lua.grid[i][j]==two048Lua.grid[i][j-1] and two048Lua.grid[i][j] ~= 0 then
                two048Lua.grid[i][j-1] = two048Lua.grid[i][j] + two048Lua.grid[i][j-1]
                if two048Lua.grid[i][j-1] > two048Lua.highestTile then
                    two048Lua.highestTile = two048Lua.grid[i][j-1]
                end
                two048Lua.score = two048Lua.score + 2 * two048Lua.grid[i][j]
                for x=j,2,-1 do
                    two048Lua.grid[i][x] = two048Lua.grid[i][x-1]
                end
                two048Lua.grid[i][1] = 0
            end
        end
    end
    if oldScore ~= two048Lua.score then
        canMove = true
    end
    if canMove == true then
        two048Lua.randomNum();
    end
end


function two048Lua.moveUp()
    local oldScore = two048Lua.score
    local canMove = false
    local m = #two048Lua.grid
    local n = #two048Lua.grid[1]
    for j=1,n do
        local line = {}
        for i=1,m do
            if two048Lua.grid[i][j]~=0 then
                table.insert(line,two048Lua.grid[i][j])
            end
        end
        local k = #line
        for i=1,m do
            if i<=k then
                if two048Lua.grid[i][j] ~= line[i] then
                    canMove = true
                end
                two048Lua.grid[i][j] = line[i]
            else
                two048Lua.grid[i][j] = 0
            end
        end
        for i=1,k-1 do
            if two048Lua.grid[i][j] == two048Lua.grid[i+1][j] and two048Lua.grid[i][j] ~= 0 then
                two048Lua.grid[i+1][j] = two048Lua.grid[i][j] + two048Lua.grid[i+1][j]
                if two048Lua.grid[i+1][j] > two048Lua.highestTile then
                    two048Lua.highestTile = two048Lua.grid[i+1][j]
                end
                two048Lua.score = two048Lua.score + 2 * two048Lua.grid[i][j]
                for x=i,m-1 do
                    two048Lua.grid[x][j] = two048Lua.grid[x+1][j]
                end
                two048Lua.grid[m][j] = 0
            end             
        end
    end
    if oldScore ~= two048Lua.score then
        canMove = true
    end
    if canMove == true then
        two048Lua.randomNum();
    end
end

function two048Lua.moveDown()
    local oldScore = two048Lua.score
    local canMove = false
    local m = #two048Lua.grid
    local n = #two048Lua.grid[1]
    for j=1,n do
        local line = {}
        for i=m,1,-1 do
            if two048Lua.grid[i][j]~=0 then
                table.insert(line,two048Lua.grid[i][j])
            end
        end
        local k = #line
        for i=m,1,-1 do
            if m-i+1<=k then
                if two048Lua.grid[i][j] ~= line[m-i+1] then
                    canMove = true
                end
                two048Lua.grid[i][j] = line[m-i+1]
            else
                two048Lua.grid[i][j] = 0
            end
        end
        for i=m,m-k+2,-1 do
            if two048Lua.grid[i][j]==two048Lua.grid[i-1][j] then
                two048Lua.grid[i-1][j] = two048Lua.grid[i][j] + two048Lua.grid[i-1][j]
                if two048Lua.grid[i-1][j] > two048Lua.highestTile then
                    two048Lua.highestTile = two048Lua.grid[i-1][j]
                end
                two048Lua.score = two048Lua.score + 2 * two048Lua.grid[i][j]
                for x=i,2,-1 do
                    two048Lua.grid[x][j] = two048Lua.grid[x-1][j]
                end
                two048Lua.grid[1][j] = 0
            end
        end
    end
    if oldScore ~= two048Lua.score then
        canMove = true
    end
    if canMove == true then
        two048Lua.randomNum();
    end
end

function two048Lua.isOver()
    local m = #two048Lua.grid
    local n = #two048Lua.grid[1]
    for i=1,m do
        for j=1,n do
            if two048Lua.grid[i][j]==0 then
                return false
            end
            -- if (i<m and j<n)
            -- and (two048Lua.grid[i][j]==two048Lua.grid[i][j+1]
            --     or two048Lua.grid[i][j]==two048Lua.grid[i+1][j]) then
            --     return true
            -- end
        end
    end
    for i = 1,m do
        for j = 1, n - 1 do
            if two048Lua.grid[i][j] == two048Lua.grid[i][j+1] then
                return false;
            end
        end
    end
    for j = 1, n do
        for i = 1, m - 1 do
            if two048Lua.grid[i][j] == two048Lua.grid[i+1][j] then
                return false;
            end
        end
    end
    return true;
end

function two048Lua.restart()
    two048Lua.initGrid(4,4);
    -- print("two048Lua.score: " .. two048Lua.score .. " HIGHEST TILE: " .. two048Lua.highestTile);
    -- two048Lua.printGrid();
end

function two048Lua.silentRestart()
    two048Lua.initGrid(4,4);
end

function two048Lua.move(action)
    two048Lua.updateStateValue();
    two048Lua.oldStateValue = two048Lua.stateValue;
    two048Lua.oldScore = two048Lua.score;
    if action == "u" then
        two048Lua.moveUp();
    elseif action == "d"  then
        two048Lua.moveDown();
    elseif action == "l" then
        two048Lua.moveLeft();
    elseif action == "r" then
        two048Lua.moveRight();
    end
    two048Lua.updateStateValue();
end

function two048Lua.step(action)
    two048Lua.move(action);
    return two048Lua.getState()
end

function two048Lua.run()
    -- two048Lua.initGrid(4,4);
    print("two048Lua.score: " .. two048Lua.score .. " HIGHEST TILE: " .. two048Lua.highestTile);
    two048Lua.printGrid();
    io.write("next step 'a'[←],'w'[↑],'s'[↓],'d'[→],'q'[exit] >> ")
    local input = io.read()
    while input~="q" and not two048Lua.isOver() do
        if input=="a" or input=="w" or input=="s" or input=="d" then
            local moved = false
            if input=="a" then
                two048Lua.move("l");
            elseif input=="w" then
                two048Lua.move("u");
            elseif input=="s" then
                two048Lua.move("d");
            elseif input=="d" then
                two048Lua.move("r");
            end
            print("Score: " .. two048Lua.score .. " Reward:  " .. two048Lua.score - two048Lua.oldScore .. " HIGHEST TILE: " .. two048Lua.highestTile)
            two048Lua.printGrid();
            if two048Lua.isOver() then 
                break;
            end
            -- print(torch.Tensor(two048Lua.grid))
        elseif input == "r" then
            two048Lua.restart();
        else
            print("error input. please input 'a'[←] or 'w'[↑] or 's'[↓] or 'd'[→] or 'q'[exit]")
        end
        io.write("next step 'a'[←],'w'[↑],'s'[↓],'d'[→],'q'[exit] >> ")
        input = io.read()
    end
    print("GAME OVER! " .. "Your score is: " .. two048Lua.score)
end

return two048Lua

