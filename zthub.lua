local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Adopt Me Hub Zero Tools",
   Icon = 0,
   LoadingTitle = "ZeroTools",
   LoadingSubtitle = "By noahblw",
   Theme = "Default",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "ZTfiles"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false,
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"Hello"}
   }
})

Rayfield:Notify({
   Title = "Adopt Me Hub",
   Content = "Adopt Me Hub by ZeroTools loaded...",
   Duration = 6.5,
   Image = 4483362458,
})

local Tab = Window:CreateTab("Main", "computer")

-- Variable zum Speichern der Ausgangsposition
local startPosition

-- Anti-AFK Funktion (Charakterbewegung)
local function moveCharacter()
   local character = game.Players.LocalPlayer.Character
   if character and character:FindFirstChild("HumanoidRootPart") then
       -- Speichere die Ausgangsposition, falls noch nicht geschehen
       if not startPosition then
           startPosition = character.HumanoidRootPart.Position
       end

       -- Bewege den Charakter leicht nach hinten
       character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -0.5)

       -- Warte kurz, bevor der Charakter zurückkehrt
       wait(0.5)

       -- Bewege den Charakter zurück zur Ausgangsposition
       character.HumanoidRootPart.CFrame = CFrame.new(startPosition)
   end
end

-- Variable zum Speichern der Verbindung
local antiAFKConnection

-- Timer für die Charakterbewegung (alle 30 Sekunden)
local moveCooldown = 30 -- Cooldown in Sekunden
local lastMoveTime = 0 -- Zeitpunkt der letzten Bewegung

-- Anti-AFK Toggle
local ToggleAntiAFK = Tab:CreateToggle({
   Name = "Anti-AFK",
   CurrentValue = false,
   Flag = "ToggleAntiAFK",
   Callback = function(Value)
      if Value then
         -- Aktiviert das Anti-AFK-Skript
         antiAFKConnection = game:GetService("RunService").Heartbeat:Connect(function()
            -- Kamerabewegung bei jedem Heartbeat
            local camera = workspace.CurrentCamera
            if camera then
               camera.CFrame = camera.CFrame * CFrame.Angles(0, math.rad(0.1), 0) -- Sehr kleine Kamerabewegung
            end

            -- Charakterbewegung alle 30 Sekunden
            if os.time() - lastMoveTime >= moveCooldown then
               moveCharacter() -- Charakterbewegung ausführen
               lastMoveTime = os.time() -- Timer zurücksetzen
            end
         end)
         Rayfield:Notify({
            Title = "Anti-AFK",
            Content = "Anti-AFK aktiviert.",
            Duration = 3,
            Image = 4483362458,
         })
         print("Anti-AFK aktiviert") -- Debug-Nachricht
      else
         -- Deaktiviert das Anti-AFK-Skript
         if antiAFKConnection then
            antiAFKConnection:Disconnect()
            antiAFKConnection = nil
            Rayfield:Notify({
               Title = "Anti-AFK",
               Content = "Anti-AFK deaktiviert.",
               Duration = 3,
               Image = 4483362458,
            })
            print("Anti-AFK deaktiviert") -- Debug-Nachricht
         end
      end
   end,
})

-- FPS-Slider
local FPSSlider = Tab:CreateSlider({
   Name = "FPS Cap",
   Range = {10, 60}, -- Minimum 10, Maximum 60
   Increment = 1, -- Schrittweite
   Suffix = "FPS",
   CurrentValue = 60, -- Standardwert
   Flag = "SliderFPS",
   Callback = function(Value)
      setfpscap(Value) -- Setzt den FPS-Cap auf den ausgewählten Wert
      print("FPS-Cap auf " .. Value .. " gesetzt") -- Debug-Nachricht
   end,
})

-- Neue Kategorie: Bucks Transfer
local BucksTransferTab = Window:CreateTab("Bucks Transfer", "banknote")

-- Funktion zum Finden der nächsten Kasse
local function findNearestRegister()
   local player = game.Players.LocalPlayer
   local character = player.Character
   if not character or not character:FindFirstChild("HumanoidRootPart") then
       print("Charakter oder HumanoidRootPart nicht gefunden.")
       return nil
   end

   local closestRegister = nil
   local closestDistance = math.huge

   -- Durchsuche alle Objekte im Workspace
   for _, obj in pairs(workspace:GetChildren()) do
       -- Überprüfe, ob das Objekt eine Kasse ist
       if obj.Name == "CashRegister" then
           print("Kasse gefunden: " .. obj.Name)
           -- Annahme: Die Kasse hat ein Teil namens "Head" oder ein anderes relevantes Teil für die Position
           local registerPart = obj:FindFirstChild("Head") or obj:FindFirstChild("MainPart") or obj.PrimaryPart
           if registerPart then
               print("Teil der Kasse gefunden: " .. registerPart.Name)
               local distance = (character.HumanoidRootPart.Position - registerPart.Position).Magnitude
               print("Entfernung zur Kasse: " .. distance)
               if distance < closestDistance then
                   closestDistance = distance
                   closestRegister = obj
               end
           else
               print("Kein relevantes Teil der Kasse gefunden.")
           end
       end
   end

   if closestRegister then
       print("Nächste Kasse gefunden: " .. closestRegister.Name)
   else
       print("Keine Kasse in der Nähe gefunden.")
   end

   return closestRegister
end

-- Button zum Finden der nächsten Kasse
local FindRegisterButton = BucksTransferTab:CreateButton({
   Name = "Find Nearest Register",
   Callback = function()
       local register = findNearestRegister()
       if register then
           Rayfield:Notify({
               Title = "Register Found",
               Content = "Nearest register found!",
               Duration = 3,
               Image = 4483362458,
           })
           print("Nächste Kasse gefunden an Position: " .. tostring(register.PrimaryPart.Position))
       else
           Rayfield:Notify({
               Title = "Register Not Found",
               Content = "No register found nearby.",
               Duration = 3,
               Image = 4483362458,
           })
           print("Keine Kasse in der Nähe gefunden.")
       end
   end,
})

-- Funktion zum Spenden von Bucks
local function donateBucks()
   local register = findNearestRegister()
   if not register then
       Rayfield:Notify({
           Title = "Donation Failed",
           Content = "No register found nearby.",
           Duration = 3,
           Image = 4483362458,
       })
       print("Keine Kasse gefunden.")
       return
   end

   for i = 1, 3 do
       -- Simuliere die Spende von 50 Bucks
       local success, errorMessage = pcall(function()
           game.ReplicatedStorage.Transactions.ClientToServer.Donate:InvokeServer(register, 50)
       end)
       if success then
           Rayfield:Notify({
               Title = "Donation Successful",
               Content = "Donated 50 Bucks! (" .. i .. "/3)",
               Duration = 3,
               Image = 4483362458,
           })
           print("Erfolgreich 50 Bucks gespendet (" .. i .. "/3)")
       else
           Rayfield:Notify({
               Title = "Donation Failed",
               Content = "Error: " .. errorMessage,
               Duration = 3,
               Image = 4483362458,
           })
           print("Fehler beim Spenden: " .. errorMessage)
       end
       wait(1) -- Kurze Pause zwischen den Spenden
   end

   -- Cooldown von 2 Minuten
   Rayfield:Notify({
       Title = "Donation Cooldown",
       Content = "Wait 2 minutes before donating again.",
       Duration = 3,
       Image = 4483362458,
   })
   print("Spenden-Cooldown gestartet. Warte 2 Minuten.")
   wait(120) -- 2 Minuten Cooldown
end

-- Button zum Spenden von Bucks
local DonateButton = BucksTransferTab:CreateButton({
   Name = "Donate Bucks",
   Callback = function()
       donateBucks()
   end,
})