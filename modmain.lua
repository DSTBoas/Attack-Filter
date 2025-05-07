local _G = GLOBAL
local TheInput = _G.TheInput
local TheWorld = _G.TheWorld

local function getKeyFromConfig(name)
    local k = GetModConfigData(name)
    return (type(k) == "string") and _G[k] or k
end

local ACTIONKEY = getKeyFromConfig("FILTER_ENTITY_KEY")
local SAVE_FILE = "attack_filter_data.txt"

local function Tint(ent, on)
    if ent and ent.AnimState then
        if on then
            ent.AnimState:SetMultColour(1, 0, 0, 1)
        else
            ent.AnimState:SetMultColour(1, 1, 1, 1)
        end
    end
end

local function RetintPrefab(prefab, on)
    for _, inst in pairs(_G.Ents) do
        if inst.prefab == prefab then
            Tint(inst, on)
        end
    end
end

local function saveFilter(tbl)
    local out, n = {}, 0
    for prefab in pairs(tbl) do
        n = n + 1
        out[n] = prefab
    end
    _G.TheSim:SetPersistentString(SAVE_FILE, table.concat(out, "\n"), false)
end

local function loadFilter(cb)
    _G.TheSim:GetPersistentString(
        SAVE_FILE,
        function(ok, data)
            local filter = {}
            if ok and data then
                for prefab in data:gmatch("[^\r\n]+") do
                    filter[prefab] = true
                end
            end
            cb(filter)
        end
    )
end

local AttackFilters = {}

local function Toggle(ent)
    if not (ent and ent.prefab) then
        return
    end
    local prefab = ent.prefab
    local filtered = not AttackFilters[prefab]

    AttackFilters[prefab] = filtered or nil
    saveFilter(AttackFilters)
    RetintPrefab(prefab, filtered)

    local msg = filtered and ("Now ignoring %s"):format(ent.name or prefab) or
                ("Will attack %s again"):format(ent.name or prefab)
    if _G.ThePlayer and _G.ThePlayer.components.talker then
        _G.ThePlayer.components.talker:Say(msg)
    end
end

local function IsFiltered(_, guy)
    return guy and AttackFilters[guy.prefab]
end

local function OnPlayerActivated(_, player)
    if player ~= _G.ThePlayer then
        return
    end
    local combat, old = player.replica.combat, player.replica.combat.IsAlly
    function combat:IsAlly(guy, ...)
        return IsFiltered(self, guy) or old(self, guy, ...)
    end
end

AddPrefabPostInitAny(function(inst)
    if inst.prefab and AttackFilters[inst.prefab] then
        Tint(inst, true)
    end
end)

if TheInput then
    TheInput:AddKeyDownHandler(
        ACTIONKEY,
        function()
            if _G.IsPaused() then
                return
            end
            local ent = TheInput:GetWorldEntityUnderMouse()
            if ent and ent.replica and ent.replica.health then
                Toggle(ent)
            end
        end
    )
end

AddPrefabPostInit(
    "world",
    function(inst)
        loadFilter(
            function(filter)
                AttackFilters = filter
                for prefab in pairs(AttackFilters) do
                    RetintPrefab(prefab, true)
                end
            end
        )

        inst:ListenForEvent("playeractivated", OnPlayerActivated, TheWorld)
    end
)
