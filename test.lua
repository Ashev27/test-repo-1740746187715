local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Configuration
local API_URL = "https://aged-wood-309e.gamaoashly6.workers.dev/?key="
local KEY_FILE = "AshlyFree_SavedKey.txt"

-- Free Script State
local AshlyState = {
    ESPEnabled = false,
    ChamsEnabled = false,
    EnemyOnly = false,
    AimbotEnabled = true,
    FOVEnabled = false,
    AimbotSmoothness = 4,
    SelectedHitbox = "Head",  -- Head | Torso | Random
    SpeedEnabled = false,
    SpeedValue = 16,
    PredictionEnabled = false,
    PredictionAmount = 0.16,
    NoclipEnabled = false,
    HPEnabled = false,
    TelekillEnabled = false
}

-- =====================================
-- AUTHENTICATION BOOTSTRAPPER
-- =====================================

local function LoadFreeScript()
    pcall(function()
        setclipboard("https://discord.gg/uevZf2qtM")
    end)

    local Window = Rayfield:CreateWindow({
       Name = "Ashly Hub (Free)",
       LoadingTitle = "Ashly Hub",
       LoadingSubtitle = "by Ashe",
       ToggleUIKeybind = "K",
       ConfigurationSaving = {Enabled = false},
       Discord = {
          Enabled = true,
          Invite = "uevZf2qtM",
          RememberJoins = true
       },
       KeySystem = false
    })

    local Tab = Window:CreateTab("Main", 4483362458)

    Tab:CreateButton({
       Name = "Join Our Discord",
       Callback = function()
          setclipboard("https://discord.gg/uevZf2qtM")
          Rayfield:Notify({
             Title = "Discord",
             Content = "Link copied to clipboard! Opening Discord...",
             Duration = 5,
             Image = 4483362458,
          })
          local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
          if req then
             pcall(function()
                req({
                   Url = 'http://127.0.0.1:6463/rpc?v=1',
                   Method = 'POST',
                   Headers = {['Content-Type'] = 'application/json', Origin = 'https://discord.com'},
                   Body = game:GetService('HttpService'):JSONEncode({
                      cmd = 'INVITE_BROWSER',
                      nonce = game:GetService('HttpService'):GenerateGUID(false),
                      args = {code = 'uevZf2qtM'}
                   })
                })
             end)
          end
       end,
    })

    -- ── ESP Tab ──
    Tab:CreateSection("ESP")
    Tab:CreateToggle({
        Name = "Show Health (Bar & Text)",
        CurrentValue = false,
        Flag = "HP_Toggle",
        Callback = function(Value)
            AshlyState.HPEnabled = Value
        end
    })
    Tab:CreateToggle({
        Name = "ESP",
        CurrentValue = false,
        Flag = "ESP_Toggle",
        Callback = function(Value)
            AshlyState.ESPEnabled = Value
        end
    })

    Tab:CreateToggle({
        Name = "Team Check (Hide Teammates)",
        CurrentValue = false,
        Flag = "Team_Check",
        Callback = function(Value)
            AshlyState.EnemyOnly = Value
        end
    })

    Tab:CreateToggle({
        Name = "Chams (Through Walls)",
        CurrentValue = false,
        Flag = "Chams_Toggle",
        Callback = function(Value)
            AshlyState.ChamsEnabled = Value
        end
    })

    -- ── Aimbot Tab ──
    local Tab2 = Window:CreateTab("Aimbot", 4483362458)
    Tab2:CreateSection("Aimbot")

    Tab2:CreateToggle({
        Name = "Aimbot",
        CurrentValue = true,
        Flag = "Aimbot_Toggle",
        Callback = function(Value)
            AshlyState.AimbotEnabled = Value
        end
    })

    Tab2:CreateToggle({
        Name = "Show FOV Circle (Fixed 100px)",
        CurrentValue = false,
        Flag = "FOV_Toggle",
        Callback = function(Value)
            AshlyState.FOVEnabled = Value
        end
    })

    Tab2:CreateToggle({
        Name = "Enable Prediction",
        CurrentValue = false,
        Flag = "Prediction_Toggle",
        Callback = function(Value)
            AshlyState.PredictionEnabled = (Value == true)
        end
    })

    Tab2:CreateSlider({
        Name = "Prediction Amount",
        Range = {0, 100},
        Increment = 1,
        Suffix = "%",
        CurrentValue = 16,
        Flag = "Prediction_Slider",
        Callback = function(Value)
            AshlyState.PredictionAmount = Value / 100
        end,
    })

    -- Hitbox selector
    Tab2:CreateDropdown({
        Name = "Target Hitbox",
        Options = {"Head", "Torso", "Random"},
        CurrentOption = "Head",
        Flag = "Hitbox_Dropdown",
        Callback = function(Value)
            AshlyState.SelectedHitbox = Value
        end
    })

    Tab2:CreateSection("Telekill")
    local TelekillToggle = Tab2:CreateToggle({
        Name = "Telekill / Auto Backstab [T]",
        CurrentValue = false,
        Flag = "Telekill_Toggle",
        Callback = function(Value)
            AshlyState.TelekillEnabled = Value
            if not Value then
                -- Reset velocity when turned off
                local char = LocalPlayer.Character
                if char then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.Velocity = Vector3.new(0, 0, 0)
                        root.RotVelocity = Vector3.new(0, 0, 0)
                    end
                end
            end
        end
    })

    Tab2:CreateSection("Hold Left Shift to Aimbot")

    -- ── Player Tab ──
    local Tab3 = Window:CreateTab("Player", 4483362458)
    Tab3:CreateSection("Movement")

    local SpeedToggle = Tab3:CreateToggle({
        Name = "Speed Hack [V]",
        CurrentValue = false,
        Flag = "Speed_Toggle",
        Callback = function(Value)
            AshlyState.SpeedEnabled = Value
            if not Value then
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then pcall(function() hum.WalkSpeed = 16 end) end
                end
            end
        end
    })

    Tab3:CreateSlider({
        Name = "Adjust Speed",
        Range = {16, 250},
        Increment = 1,
        Suffix = " WS",
        CurrentValue = 16,
        Flag = "Speed_Slider",
        Callback = function(Value)
            AshlyState.SpeedValue = Value
        end,
    })

    local NoclipOriginalCollisions = {}
    local NoclipToggle = Tab3:CreateToggle({
        Name = "Noclip [N]",
        CurrentValue = false,
        Flag = "Noclip_Toggle",
        Callback = function(Value)
            AshlyState.NoclipEnabled = Value
            local char = LocalPlayer.Character
            if not char then return end
            
            if Value then
                -- Store original collisions
                NoclipOriginalCollisions = {}
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        NoclipOriginalCollisions[part] = part.CanCollide
                    end
                end
            else
                -- Restore original collisions
                for part, canCollide in pairs(NoclipOriginalCollisions) do
                    if part and part.Parent then
                        part.CanCollide = canCollide
                    end
                end
                NoclipOriginalCollisions = {}
            end
        end
    })

    -- =====================================
    -- LOGIC VARIABLES
    -- =====================================

    local ESPObjects = {}

    -- FOV circle
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 2
    FOVCircle.Filled = false
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    FOVCircle.Visible = false
    FOVCircle.Radius = 100

    -- Aim indicator drawings
    local AimRing = Drawing.new("Circle")
    AimRing.Thickness = 2
    AimRing.Filled = false
    AimRing.Color = Color3.fromRGB(255, 50, 50)
    AimRing.Radius = 12
    AimRing.Visible = false

    local AimDot = Drawing.new("Circle")
    AimDot.Thickness = 1
    AimDot.Filled = true
    AimDot.Color = Color3.fromRGB(255, 255, 50)
    AimDot.Radius = 3
    AimDot.Visible = false

    local AimLine = Drawing.new("Line")
    AimLine.Thickness = 1
    AimLine.Color = Color3.fromRGB(255, 50, 50)
    AimLine.Transparency = 0.5
    AimLine.Visible = false

    local AimbotTarget = nil
    local AimbotHolding = false
    local _currentTelekillTarget = nil

    -- =====================================
    -- HELPER FUNCTIONS
    -- =====================================

    local function GetCharacter(player)
        if not player then return nil end
        local char = player.Character
        if char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildOfClass("Humanoid")) then return char end
        local wsChar = workspace:FindFirstChild(player.Name)
        if wsChar and wsChar:IsA("Model") and (wsChar:FindFirstChild("HumanoidRootPart") or wsChar:FindFirstChildOfClass("Humanoid")) then return wsChar end
        return nil
    end

    local function GetRootPart(char)
        if not char then return nil end
        return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    end

    local function GetHumanoid(char)
        if not char then return nil end
        return char:FindFirstChildOfClass("Humanoid")
    end

    local function IsAlive(char)
        if not char then return false end
        local hum = GetHumanoid(char)
        if hum then return hum.Health > 0 end
        return GetRootPart(char) ~= nil
    end

    -- Track which players we've already debugged (avoids spam)
    local _debuggedPlayers = {}

    local function IsEnemy(player)
        if not player or player == LocalPlayer then return false end
        
        -- Skip if Team Check is disabled
        if not AshlyState.EnemyOnly then return true end
        
        local character = player.Character
        if not character then return true end
        
        -- METHOD 1 (PRIMARY - Rivals specific): TeammateLabel on HumanoidRootPart
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart and rootPart:FindFirstChild("TeammateLabel") then
            return false  -- Teammate, skip
        end
        
        -- METHOD 2: Standard Player.Team
        if player.Team then
            if LocalPlayer.Team and player.Team == LocalPlayer.Team then
                return false
            end
        end
        
        -- METHOD 3: TeamColor (skip white/neutral)
        if player.TeamColor and player.TeamColor ~= BrickColor.new("White") then
            if LocalPlayer.TeamColor and player.TeamColor == LocalPlayer.TeamColor then
                return false
            end
        end
        
        -- METHOD 4: Attributes
        local teamAttr = player:GetAttribute("Team") or player:GetAttribute("Side")
        if teamAttr then
            local myTeam = LocalPlayer:GetAttribute("Team") or LocalPlayer:GetAttribute("Side")
            if myTeam and teamAttr == myTeam then
                return false
            end
        end
        
        -- METHOD 5: Value objects in Player
        for _, name in ipairs({"Team", "TeamId", "Side", "Faction"}) do
            local val = player:FindFirstChild(name)
            if val and (val:IsA("StringValue") or (val:IsA("NumberValue") and name == "TeamId")) then
                local myVal = LocalPlayer:FindFirstChild(name)
                if myVal and val.Value == myVal.Value then
                    return false
                end
            end
        end
        
        -- METHOD 6: Value objects in Character
        if character then
            for _, name in ipairs({"Team", "TeamId", "Side", "Faction"}) do
                local val = character:FindFirstChild(name)
                if val and (val:IsA("StringValue") or val:IsA("NumberValue")) then
                    local myChar = LocalPlayer.Character
                    if myChar then
                        local myVal = myChar:FindFirstChild(name)
                        if myVal and val.Value == myVal.Value then
                            return false
                        end
                    end
                end
            end
        end
        
        -- METHOD 7: leaderstats
        local ls = player:FindFirstChild("leaderstats")
        local myLS = LocalPlayer:FindFirstChild("leaderstats")
        if ls and myLS then
            for _, child in ipairs(ls:GetChildren()) do
                local myChild = myLS:FindFirstChild(child.Name)
                if myChild and child.Value == myChild.Value then
                    return false
                end
            end
        end
        
        -- METHOD 8: Default - treat as enemy
        return true
    end

    -- Returns the target body part based on selected hitbox option
    local function GetHitbox(char, hitbox)
        if not char then return nil end
        if hitbox == "Head" then
            return char:FindFirstChild("Head")
        elseif hitbox == "Torso" then
            return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
        elseif hitbox == "Random" then
            local parts = {"Head", "UpperTorso", "Torso", "HumanoidRootPart", "LeftArm", "RightArm"}
            local found = {}
            for _, name in ipairs(parts) do
                local p = char:FindFirstChild(name)
                if p then table.insert(found, p) end
            end
            return found[math.random(#found)]
        end
        return char:FindFirstChild("Head")
    end

    local function GetPredictedPosition(part)
        if not part then return Vector3.new() end
        local pos = part.Position
        if AshlyState.PredictionEnabled == true then
            local vel = part.AssemblyLinearVelocity
            if not vel and part:FindFirstChild("Velocity") then vel = part.Velocity end
            if vel then
                pos = pos + (vel * AshlyState.PredictionAmount)
            end
        end
        return pos
    end

    local function CreateESP(player)
        if player == LocalPlayer then return end
        if ESPObjects[player] then return end

        local box = Drawing.new("Square")
        box.Thickness = 2
        box.Filled = false
        box.Color = Color3.fromRGB(255, 255, 255)
        box.Visible = false

        local nameText = Drawing.new("Text")
        nameText.Size = 16
        nameText.Color = Color3.fromRGB(255, 255, 255)
        nameText.Outline = true
        nameText.Center = true
        nameText.Visible = false

        local hpBarBg = Drawing.new("Square")
        hpBarBg.Filled = true
        hpBarBg.Color = Color3.fromRGB(0, 0, 0)
        hpBarBg.Visible = false

        local hpBar = Drawing.new("Square")
        hpBar.Filled = true
        hpBar.Visible = false

        local hpText = Drawing.new("Text")
        hpText.Size = 13
        hpText.Outline = true
        hpText.Center = true
        hpText.Visible = false

        -- Occluded mode: chams only visible when player is in line-of-sight
        local highlight = Instance.new("Highlight")
        highlight.FillColor = Color3.fromRGB(0, 255, 0)
        highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
        highlight.FillTransparency = 0.4
        highlight.OutlineTransparency = 0.2
        highlight.DepthMode = Enum.HighlightDepthMode.Occluded
        highlight.Enabled = false
        pcall(function() highlight.Parent = game:GetService("CoreGui") end)
        if not highlight.Parent then highlight.Parent = workspace end

        ESPObjects[player] = {Box = box, Name = nameText, Highlight = highlight, HpBarBg = hpBarBg, HpBar = hpBar, HpText = hpText}
    end

    -- =====================================
    -- MAIN RENDER LOOP
    -- =====================================

    RunService.RenderStepped:Connect(function()
        local Camera = workspace.CurrentCamera
        local mousePos = UserInputService:GetMouseLocation()

        -- Speed Hack enforce
        if AshlyState.SpeedEnabled then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.MoveDirection.Magnitude > 0 then
                    -- CFrame method works on almost all games, including ones with custom movement
                    -- Adjusting multiplier based on RenderStepped delta to ensure smooth movement regardless of FPS
                    local extraSpeed = math.clamp((AshlyState.SpeedValue - 16) / 50, 0, 5) 
                    hrp.CFrame = hrp.CFrame + (hum.MoveDirection * extraSpeed)
                end
            end
        end


        -- FOV circle
        if AshlyState.FOVEnabled and AshlyState.AimbotEnabled then
            FOVCircle.Position = mousePos
            FOVCircle.Visible = true
        else
            FOVCircle.Visible = false
        end

        -- ── ESP + Chams ──
        if AshlyState.ESPEnabled or AshlyState.ChamsEnabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player == LocalPlayer then continue end
                local isEnemy = IsEnemy(player)

                if not isEnemy then
                    if ESPObjects[player] then
                        ESPObjects[player].Box.Visible = false
                        ESPObjects[player].Name.Visible = false
                        if ESPObjects[player].HpBarBg then ESPObjects[player].HpBarBg.Visible = false end
                        if ESPObjects[player].HpBar then ESPObjects[player].HpBar.Visible = false end
                        if ESPObjects[player].HpText then ESPObjects[player].HpText.Visible = false end
                        if ESPObjects[player].Highlight then ESPObjects[player].Highlight.Enabled = false end
                    end
                    continue
                end

                if not ESPObjects[player] then CreateESP(player) end

                local char = GetCharacter(player)
                local root = GetRootPart(char)
                local alive = IsAlive(char)
                local obj = ESPObjects[player]

                if root and alive then
                    -- Chams: green = enemy, cyan = teammate, AlwaysOnTop
                    if AshlyState.ChamsEnabled and obj.Highlight then
                        if obj.Highlight.Adornee ~= char then obj.Highlight.Adornee = char end
                        obj.Highlight.Enabled = true
                        if isEnemy then
                            obj.Highlight.FillColor = Color3.fromRGB(0, 255, 0)
                            obj.Highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                        else
                            obj.Highlight.FillColor = Color3.fromRGB(0, 255, 255)
                            obj.Highlight.OutlineColor = Color3.fromRGB(0, 255, 255)
                        end
                    else
                        if obj.Highlight then obj.Highlight.Enabled = false end
                    end

                    -- ESP boxes and HP
                    if AshlyState.ESPEnabled or AshlyState.HPEnabled then
                        local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                        if onScreen then
                            local size = Vector2.new(4000 / pos.Z, 6000 / pos.Z)
                            local boxPos = Vector2.new(pos.X - size.X / 2, pos.Y - size.Y / 2)
                            local color = isEnemy and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 255, 255)
                            
                            if AshlyState.ESPEnabled then
                                obj.Box.Size = size
                                obj.Box.Position = boxPos
                                obj.Box.Color = color
                                obj.Name.Color = color
                                obj.Box.Visible = true
                                obj.Name.Text = player.Name
                                obj.Name.Position = Vector2.new(pos.X, pos.Y - size.Y / 2 - 20)
                                obj.Name.Visible = true
                            else
                                obj.Box.Visible = false
                                obj.Name.Visible = false
                            end
                            
                            if AshlyState.HPEnabled then
                                local hum = GetHumanoid(char)
                                if hum then
                                    local maxHp = hum.MaxHealth > 0 and hum.MaxHealth or 100
                                    local hp = hum.Health
                                    local hpPercent = math.clamp(hp / maxHp, 0, 1)
                                    
                                    local barHeight = size.Y * hpPercent
                                    
                                    obj.HpBarBg.Size = Vector2.new(4, size.Y)
                                    obj.HpBarBg.Position = Vector2.new(boxPos.X - 8, boxPos.Y)
                                    obj.HpBarBg.Visible = true
                                    
                                    obj.HpBar.Size = Vector2.new(2, barHeight)
                                    obj.HpBar.Position = Vector2.new(boxPos.X - 7, boxPos.Y + (size.Y - barHeight))
                                    obj.HpBar.Color = Color3.fromRGB(255 - (hpPercent * 255), hpPercent * 255, 0)
                                    obj.HpBar.Visible = true
                                    
                                    obj.HpText.Text = tostring(math.floor(hp))
                                    obj.HpText.Position = Vector2.new(boxPos.X - 20, boxPos.Y + (size.Y - barHeight) - 6)
                                    obj.HpText.Color = obj.HpBar.Color
                                    obj.HpText.Visible = true
                                else
                                    if obj.HpBarBg then obj.HpBarBg.Visible = false end
                                    if obj.HpBar then obj.HpBar.Visible = false end
                                    if obj.HpText then obj.HpText.Visible = false end
                                end
                            else
                                if obj.HpBarBg then obj.HpBarBg.Visible = false end
                                if obj.HpBar then obj.HpBar.Visible = false end
                                if obj.HpText then obj.HpText.Visible = false end
                            end
                        else
                            obj.Box.Visible = false
                            obj.Name.Visible = false
                            if obj.HpBarBg then obj.HpBarBg.Visible = false end
                            if obj.HpBar then obj.HpBar.Visible = false end
                            if obj.HpText then obj.HpText.Visible = false end
                        end
                    else
                        obj.Box.Visible = false
                        obj.Name.Visible = false
                        if obj.HpBarBg then obj.HpBarBg.Visible = false end
                        if obj.HpBar then obj.HpBar.Visible = false end
                        if obj.HpText then obj.HpText.Visible = false end
                    end
                else
                    obj.Box.Visible = false
                    obj.Name.Visible = false
                    if obj.HpBarBg then obj.HpBarBg.Visible = false end
                    if obj.HpBar then obj.HpBar.Visible = false end
                    if obj.HpText then obj.HpText.Visible = false end
                    if obj.Highlight then obj.Highlight.Enabled = false end
                end
            end
        else
            for _, obj in pairs(ESPObjects) do
                obj.Box.Visible = false
                obj.Name.Visible = false
                if obj.HpBarBg then obj.HpBarBg.Visible = false end
                if obj.HpBar then obj.HpBar.Visible = false end
                if obj.HpText then obj.HpText.Visible = false end
                if obj.Highlight then obj.Highlight.Enabled = false end
            end
        end

        -- ── Aimbot target selection (scans hitbox part, not just root) ──
        if AshlyState.AimbotEnabled then
            local closestDist = math.huge
            local closestPlayer = nil

            for _, player in pairs(Players:GetPlayers()) do
                if player == LocalPlayer then continue end
                if not IsEnemy(player) then continue end
                local char = GetCharacter(player)
                if not char or not IsAlive(char) then continue end
                local part = GetHitbox(char, AshlyState.SelectedHitbox)
                if not part then part = GetRootPart(char) end
                if not part then continue end
                local targetPos = GetPredictedPosition(part)
                local pos, onScreen = Camera:WorldToViewportPoint(targetPos)
                if onScreen then
                    local screenPos = Vector2.new(pos.X, pos.Y)
                    local dist = (screenPos - mousePos).Magnitude
                    if AshlyState.FOVEnabled and dist > FOVCircle.Radius then continue end
                    if dist < closestDist then
                        closestDist = dist
                        closestPlayer = player
                    end
                end
            end
            AimbotTarget = closestPlayer
        else
            AimbotTarget = nil
        end

        -- ── Aim indicator: red ring + yellow dot + line while right-clicking ──
        if AshlyState.AimbotEnabled and AimbotHolding and AimbotTarget then
            local char = GetCharacter(AimbotTarget)
            local part = GetHitbox(char, AshlyState.SelectedHitbox)
            if not part then part = GetRootPart(char) end
            if part and IsAlive(char) then
                local targetPos = GetPredictedPosition(part)
                local pos, onScreen = Camera:WorldToViewportPoint(targetPos)
                if onScreen then
                    local targetScreenPos = Vector2.new(pos.X, pos.Y)
                    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    AimRing.Position = targetScreenPos
                    AimRing.Visible = true
                    AimDot.Position = targetScreenPos
                    AimDot.Visible = true
                    AimLine.From = screenCenter
                    AimLine.To = targetScreenPos
                    AimLine.Visible = true
                else
                    AimRing.Visible = false
                    AimDot.Visible = false
                    AimLine.Visible = false
                end
            else
                AimRing.Visible = false
                AimDot.Visible = false
                AimLine.Visible = false
            end
        else
            AimRing.Visible = false
            AimDot.Visible = false
            AimLine.Visible = false
        end
    end)

    -- ── Player tracking ──
    local function OnCharacterAdded(player)
        player.CharacterAdded:Connect(function()
            task.wait(1)
            if player ~= LocalPlayer then CreateESP(player) end
        end)
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then CreateESP(player) end
        OnCharacterAdded(player)
    end

    Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then CreateESP(player) end
        OnCharacterAdded(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        if ESPObjects[player] then
            if ESPObjects[player].Box then ESPObjects[player].Box:Remove() end
            if ESPObjects[player].Name then ESPObjects[player].Name:Remove() end
            if ESPObjects[player].HpBarBg then ESPObjects[player].HpBarBg:Remove() end
            if ESPObjects[player].HpBar then ESPObjects[player].HpBar:Remove() end
            if ESPObjects[player].HpText then ESPObjects[player].HpText:Remove() end
            if ESPObjects[player].Highlight then ESPObjects[player].Highlight:Destroy() end
            ESPObjects[player] = nil
        end
    end)

    local function GetClosestEnemyToCharacter()
        local closestDist = math.huge
        local closestEnemy = nil
        local lpChar = LocalPlayer.Character
        if not lpChar then return nil end
        local lpRoot = GetRootPart(lpChar)
        if not lpRoot then return nil end

        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            if not IsEnemy(p) then continue end
            local char = p.Character
            if not char or not IsAlive(char) then continue end
            local root = GetRootPart(char)
            if not root then continue end

            local dist = (root.Position - lpRoot.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closestEnemy = p
            end
        end
        return closestEnemy
    end

    -- Physics / Movement Loop
    RunService.Stepped:Connect(function()
    if AshlyState.NoclipEnabled then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end

    -- Telekill (SIMPLE TELEPORT + SILENT AIM/BULLET REDIRECT)
    if AshlyState.TelekillEnabled then
        if not _currentTelekillTarget or not IsAlive(GetCharacter(_currentTelekillTarget)) or not IsEnemy(_currentTelekillTarget) then
            _currentTelekillTarget = GetClosestEnemyToCharacter()
        end
        local target = _currentTelekillTarget
        local lpChar = LocalPlayer.Character
        local lpRoot = GetRootPart(lpChar)
        
        if target and lpRoot then
            local tChar = target.Character
            local tRoot = GetRootPart(tChar)
            if tRoot then
                -- Pure teleport to the back of the target
                local backPos = tRoot.Position - (tRoot.CFrame.LookVector * 5)
                lpRoot.CFrame = CFrame.new(backPos, tRoot.Position)
            end
        end
    else
        _currentTelekillTarget = nil
    end
end)

    -- ── Left Shift keybind ──
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.LeftShift then
            AimbotHolding = true
        elseif input.KeyCode == Enum.KeyCode.V then
            if SpeedToggle then
                SpeedToggle:Set(not AshlyState.SpeedEnabled)
            end
        elseif input.KeyCode == Enum.KeyCode.N then
            if NoclipToggle then
                NoclipToggle:Set(not AshlyState.NoclipEnabled)
            end
        elseif input.KeyCode == Enum.KeyCode.T then
            if TelekillToggle then
                TelekillToggle:Set(not AshlyState.TelekillEnabled)
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.LeftShift then
            AimbotHolding = false
        end
    end)

    -- Randomised smoothness to evade static anti-cheat pattern matching
    local function getSmoothness()
        return AshlyState.AimbotSmoothness + (math.random(-2, 2) / 10)
    end

    -- ── Telekill Auto Kill / Bullet Redirect ──
    RunService:BindToRenderStep("TelekillCamLock", 205, function()
        if AshlyState.TelekillEnabled and _currentTelekillTarget then
            local target = _currentTelekillTarget
            local tChar = target.Character
            if not tChar or not IsAlive(tChar) then return end
            local tHead = tChar:FindFirstChild("Head") or GetRootPart(tChar)
            if not tHead then return end
            
            local cam = workspace.CurrentCamera
            local lpChar = LocalPlayer.Character
            
            if lpChar then
                -- ===== CAMERA LOCK / AUTO AIM =====
                -- Force camera to always look exactly at the target's head
                cam.CFrame = CFrame.new(cam.CFrame.Position, tHead.Position)
                
                -- ===== AUTO KILL / SILENT AIM =====
                local tool = lpChar:FindFirstChildOfClass("Tool")
                if tool then
                    -- Auto-activate tool every frame
                    pcall(function()
                        tool:Activate()
                    end)
                    
                    -- Fire all remote events in the tool directly at the target head
                    for _, remote in ipairs(tool:GetDescendants()) do
                        if remote:IsA("RemoteEvent") then
                            pcall(function()
                                remote:FireServer(tHead, tHead.Position)
                            end)
                        end
                        if remote:IsA("RemoteFunction") then
                            pcall(function()
                                remote:InvokeServer(tHead, tHead.Position)
                            end)
                        end
                    end
                    
                    -- Try weapon-specific events
                    for _, child in ipairs(tool:GetChildren()) do
                        if child:IsA("RemoteEvent") or child.Name:lower():find("fire") or child.Name:lower():find("shoot") or child.Name:lower():find("hit") then
                            pcall(function()
                                child:FireServer(tHead, tHead.Position, tHead)
                            end)
                        end
                    end
                end
                
                -- Also try tools in character
                for _, child in ipairs(lpChar:GetChildren()) do
                    if child:IsA("Tool") and child ~= tool then
                        pcall(function()
                            child:Activate()
                            for _, remote in ipairs(child:GetDescendants()) do
                                if remote:IsA("RemoteEvent") then
                                    pcall(function()
                                        remote:FireServer(tHead, tHead.Position)
                                    end)
                                end
                            end
                        end)
                    end
                end
            end
        end
    end)

    -- ── Aimbot execution at render priority 201 (after camera update) ──
    RunService:BindToRenderStep("AshlyAimbot", 201, function()
        if not AshlyState.AimbotEnabled then return end
        if not AimbotHolding then return end
        if not AimbotTarget then return end

        local Camera = workspace.CurrentCamera
        local char = GetCharacter(AimbotTarget)
        if not char or not IsAlive(char) then return end

        local part = GetHitbox(char, AshlyState.SelectedHitbox)
        if not part then part = GetRootPart(char) end
        if not part then return end

        local targetPos = GetPredictedPosition(part)
        local pos, onScreen = Camera:WorldToViewportPoint(targetPos)
        if not onScreen then return end

        local smooth = getSmoothness()
        local mouseLoc = UserInputService:GetMouseLocation()
        local diffX = pos.X - mouseLoc.X
        local diffY = pos.Y - mouseLoc.Y

        if mousemoverel then
            pcall(mousemoverel, diffX / smooth, diffY / smooth)
        else
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
        end
    end)

    -- Diagnostic: Dump Character Info
    local function DumpCharacterInfo()
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            local char = player.Character
            if not char then continue end
            
            local text = string.format("[%s] Character children:\n", player.Name)
            for _, child in ipairs(char:GetChildren()) do
                text = text .. string.format("  %s (%s)\n", child.Name, child.ClassName)
            end
            
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                text = text .. string.format("  HumanoidRootPart children:\n")
                for _, child in ipairs(hrp:GetChildren()) do
                    text = text .. string.format("    %s (%s)\n", child.Name, child.ClassName)
                end
            end
            
            warn(text)
        end
    end

    -- Call it after a short delay to let characters load
    task.delay(3, DumpCharacterInfo)

end -- End of LoadFreeScript

-- =====================================
-- KEY VERIFICATION LOGIC
-- =====================================

local function VerifyKey(key)
    local success, response = pcall(function()
        return game:HttpGet(API_URL .. key)
    end)

    if not success then
        warn("HTTP Request Failed. Reason: " .. tostring(response))
        return "ERROR"
    end

    response = response:gsub("%s+", "")
    return response
end

local function InitAuthUI()
    if isfile and isfile(KEY_FILE) then
        local savedKey = readfile(KEY_FILE)
        local status = VerifyKey(savedKey)
        if status == "VALID" then
            LoadFreeScript()
            return
        end
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AshlyAuthFree"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0, 350, 0, 200)

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Parent = MainFrame
    UIStroke.Color = Color3.fromRGB(255, 100, 100)
    UIStroke.Thickness = 2

    local Title = Instance.new("TextLabel")
    Title.Parent = MainFrame
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 0, 0, 15)
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "Ashly Free Authentication"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Parent = MainFrame
    Subtitle.BackgroundTransparency = 1
    Subtitle.Position = UDim2.new(0, 0, 0, 45)
    Subtitle.Size = UDim2.new(1, 0, 0, 20)
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.Text = "Enter your Daily Free Key"
    Subtitle.TextColor3 = Color3.fromRGB(180, 180, 180)
    Subtitle.TextSize = 14

    local KeyInput = Instance.new("TextBox")
    KeyInput.Parent = MainFrame
    KeyInput.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    KeyInput.Position = UDim2.new(0.1, 0, 0.45, 0)
    KeyInput.Size = UDim2.new(0.8, 0, 0, 40)
    KeyInput.Font = Enum.Font.GothamSemibold
    KeyInput.PlaceholderText = "ASHLY-XXXXXXXX"
    KeyInput.Text = ""
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.TextSize = 14

    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 6)
    InputCorner.Parent = KeyInput

    local SubmitBtn = Instance.new("TextButton")
    SubmitBtn.Parent = MainFrame
    SubmitBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    SubmitBtn.Position = UDim2.new(0.1, 0, 0.75, 0)
    SubmitBtn.Size = UDim2.new(0.8, 0, 0, 35)
    SubmitBtn.Font = Enum.Font.GothamBold
    SubmitBtn.Text = "Verify Key"
    SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitBtn.TextSize = 14

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = SubmitBtn

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Parent = MainFrame
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0, 0, 0.65, 0)
    StatusLabel.Size = UDim2.new(1, 0, 0, 20)
    StatusLabel.Font = Enum.Font.GothamBold
    StatusLabel.Text = ""
    StatusLabel.TextSize = 12

    SubmitBtn.MouseButton1Click:Connect(function()
        local key = KeyInput.Text
        if key == "" then
            StatusLabel.Text = "Please enter a key"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            return
        end

        SubmitBtn.Text = "Checking..."
        local status = VerifyKey(key)

        if status == "VALID" then
            StatusLabel.Text = "Access Granted!"
            StatusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
            if writefile then writefile(KEY_FILE, key) end
            task.wait(1)
            ScreenGui:Destroy()
            LoadFreeScript()
        elseif status == "ERROR" then
            StatusLabel.Text = "Server Error (Check Domain)"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        else
            StatusLabel.Text = "Invalid Free Key"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        end
        SubmitBtn.Text = "Verify Key"
    end)
end

InitAuthUI()
