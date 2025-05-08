name = "Attack Filter"
description = "Filter entities you attack by pressing a key!"

icon_atlas = "modicon.xml"
icon = "modicon.tex"

author = "Boas"
version = "1.0.1"
forumthread = ""

dont_starve_compatible = false
reign_of_giants_compatible = false
dst_compatible = true

all_clients_require_mod = false
client_only_mod = true

api_version = 10

local function AddConfig(label, name, options, default, hover)
    return {
        label = label,
        name = name,
        options = options,
        default = default,
        hover = hover
    }
end

local function AddSectionTitle(title)
    return AddConfig(title, "", {{description = "", data = 0}}, 0)
end

local function AddConfigOption(desc, data, hover)
    return {description = desc, data = data, hover = hover}
end

local function GetKeyboardOptions()
    local keys = {}

    local function AddConfigKey(t, key)
        t[#t + 1] = AddConfigOption(key, "KEY_" .. key, "")
    end

    local function AddDisabledConfigOption(t)
        t[#t + 1] = AddConfigOption("Disabled", false, "")
    end

    AddDisabledConfigOption(keys)

    local alphabet = {
        "A","B","C","D","E","F","G","H","I","J","K","L","M",
        "N","O","P","Q","R","S","T","U","V","W","X","Y","Z"
    }

    for i = 1, 26 do
        AddConfigKey(keys, alphabet[i])
    end

    for i = 1, 12 do
        AddConfigKey(keys, "F" .. i)
    end

    AddDisabledConfigOption(keys)

    return keys
end

local KeyboardOptions = GetKeyboardOptions()

configuration_options =
{
    AddSectionTitle("Attack Filter Keys"),
    AddConfig(
        "Filter Entity",
        "FILTER_ENTITY_KEY",
        KeyboardOptions,
        "KEY_F3",
        "Assign a key or disable"
    ),
    AddConfig(
        "Toggle Attack Filter",
        "TOGGLE_FILTER_KEY",
        KeyboardOptions,
        false,
        "Assign a key or disable"
    ),
    AddSectionTitle("Save Settings"),
    AddConfig(
        "Remember Filtered Targets",
        "PERSISTENCE_MODE",
        {
            AddConfigOption("Don't save", "disabled", "Never remember your filtered targets."),
            AddConfigOption("Save for all games", "game", "Remember filtered targets in every world."),
            AddConfigOption("Save per world", "world", "Each world remembers its own filtered targets."),
        },
        "game",
        "Choose how your filter is remembered"
    ),
}
