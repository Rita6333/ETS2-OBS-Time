-- This OBS plugin was created by RITA
obs = obslua

-- Global variables
local source_name = ""
local last_text = ""
local activated = false
local script_settings = nil

-- Month abbreviation mapping
local month_names = {
    [1] = "Jan", [2] = "Feb", [3] = "Mar", [4] = "Apr",
    [5] = "May", [6] = "Jun", [7] = "Jul", [8] = "Aug",
    [9] = "Sep", [10] = "Oct", [11] = "Nov", [12] = "Dec"
}

-- Get the formatted time string
function get_formatted_time()
    if not script_settings then
        return "Settings not loaded"
    end
    
    local timezone_setting = obs.obs_data_get_string(script_settings, "timezone")
    local use_24hour = obs.obs_data_get_bool(script_settings, "use_24hour")
    
    local time_info
    if timezone_setting == "UTC" then
        time_info = os.date("!*t")  -- UTC Time
    else
        time_info = os.date("*t")   -- Local time
    end
    
    local year = time_info.year
    local month = month_names[time_info.month] or "Feb"
    local day = string.format("%02d", time_info.day)
    local hour = time_info.hour
    local minute = string.format("%02d", time_info.min)
    local second = string.format("%02d", time_info.sec)
    
    -- Handling the 12-hour format
    if not use_24hour then
        local am_pm = "AM"
        if hour >= 12 then
            am_pm = "PM"
        end
        if hour > 12 then
            hour = hour - 12
        elseif hour == 0 then
            hour = 12
        end
        return string.format("Current Time: %d-%s-%s %d:%s:%s %s", 
                            year, month, day, hour, minute, second, am_pm)
    end
    
    -- 24-hour format
    hour = string.format("%02d", hour)
    local timezone_text = (timezone_setting == "UTC") and "UTC" or ""
    return string.format("Current Time: %d-%s-%s %s:%s:%s %s", 
                        year, month, day, hour, minute, second, timezone_text)
end

-- Set time text
function set_time_text()
    if source_name == "" then
        return
    end
    
    local text = get_formatted_time()
    
    if text ~= last_text then
        local source = obs.obs_get_source_by_name(source_name)
        if source ~= nil then
            local settings = obs.obs_data_create()
            obs.obs_data_set_string(settings, "text", text)
            obs.obs_source_update(source, settings)
            obs.obs_data_release(settings)
            obs.obs_source_release(source)
        end
    end
    
    last_text = text
end

-- Timer callback
function timer_callback()
    set_time_text()
end

-- Activate/Deactivate function
function activate(activating)
    if activated == activating then
        return
    end
    
    activated = activating
    
    if activating then
        set_time_text()
        obs.timer_add(timer_callback, 1000)  -- Updates every second.
    else
        obs.timer_remove(timer_callback)
    end
end

-- Signal processing functions
function activate_signal(cd, activating)
    local source = obs.calldata_source(cd, "source")
    if source ~= nil then
        local name = obs.obs_source_get_name(source)
        if name == source_name then
            activate(activating)
        end
    end
end

function source_activated(cd)
    activate_signal(cd, true)
end

function source_deactivated(cd)
    activate_signal(cd, false)
end

-- Reset and reactivate
function reset()
    -- Stop the current active state.
    if activated then
        activate(false)
    end
    
    -- Check if the source exists and reactivate it.
    if source_name ~= "" then
        local source = obs.obs_get_source_by_name(source_name)
        if source ~= nil then
            local active = obs.obs_source_active(source)
            obs.obs_source_release(source)
            if active then
                activate(true)
            end
        end
    end
end

----------------------------------------------------------
-- Script interface and configuration
----------------------------------------------------------

-- Script properties (settings interface)
function script_properties()
    local props = obs.obs_properties_create()
    
    -- Add a dropdown menu for selecting text sources.
    local p = obs.obs_properties_add_list(props, "source", "Text Source", 
        obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
    
    -- Add an empty option
    obs.obs_property_list_add_string(p, "", "-- Select text source --")
    
    -- Enumerate all text sources
    local sources = obs.obs_enum_sources()
    if sources ~= nil then
        for _, source in ipairs(sources) do
            local source_id = obs.obs_source_get_id(source)
            if source_id == "text_gdiplus" or source_id == "text_ft2_source" then
                local name = obs.obs_source_get_name(source)
                obs.obs_property_list_add_string(p, name, name)
            end
        end
        obs.source_list_release(sources)
    end
    
    -- Add formatting examples
    obs.obs_properties_add_text(props, "format_label", "格式: Current Time: 2026-Feb-04\n12:14:19 UTC", obs.OBS_TEXT_INFO)
    
    -- Add time zone option
    local timezone_list = obs.obs_properties_add_list(props, "timezone", "Timezone",
        obs.OBS_COMBO_TYPE_LIST, obs.OBS_COMBO_FORMAT_STRING)
    obs.obs_property_list_add_string(timezone_list, "UTC", "UTC")
    obs.obs_property_list_add_string(timezone_list, "Local Time", "Local Time")
    
    -- Add a 24-hour format option.
    obs.obs_properties_add_bool(props, "use_24hour", "24-Hour Format")
    
    -- Add test button
    obs.obs_properties_add_button(props, "test_button", "Tests show that", 
        function(props, property)
            if source_name ~= "" then
                set_time_text()
            end
            return true
        end)
    
    return props
end

-- Script Description
function script_description()
    return "Display the time in the format 'Current Time: 2026-Feb-04 12:14:19 UTC'.\n\n" ..
           "Supports UTC and local time\n" ..
           "Automatically update the time when the text source is activated.\n\n" ..
           "Important: You must select the text source in the settings on the right!"
end

-- Script update (called when settings change)
function script_update(settings)
    -- Save settings to global variables.
    script_settings = settings
    
    -- Get a new source name.
    local new_source_name = obs.obs_data_get_string(settings, "source")
    
    -- If the source name changes, disable the old one first.
    if source_name ~= "" and source_name ~= new_source_name then
        activate(false)
    end
    
    -- Update source name
    source_name = new_source_name
    
    -- Reactivate
    reset()
end

-- Default settings
function script_defaults(settings)
    obs.obs_data_set_default_string(settings, "timezone", "UTC")
    obs.obs_data_set_default_bool(settings, "use_24hour", true)
end

-- Script loading
function script_load(settings)
    -- Save settings to global variables.
    script_settings = settings
    
    -- Get the source name from the settings.
    if settings ~= nil then
        source_name = obs.obs_data_get_string(settings, "source")
    end
    
    -- Connected to OBS signal
    local sh = obs.obs_get_signal_handler()
    obs.signal_handler_connect(sh, "source_activate", source_activated)
    obs.signal_handler_connect(sh, "source_deactivate", source_deactivated)
    
    -- Delayed initialization ensures that everything is loaded.
    obs.timer_add(function()
        if source_name ~= "" then
            reset()
        end
    end, 500)
end

-- Script uninstallation
function script_unload()
    activate(false)
end