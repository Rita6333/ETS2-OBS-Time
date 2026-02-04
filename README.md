# OBS Time Display Plugin Instructions

This OBS Lua plugin is a small tool specifically designed to display the current time in ETS2 screen recording scenarios. https://i.imgur.com/61z9ZA6.png
## 🕐 **Main Features**

1. **Flexible Time Format**
- Supports switching between UTC and local time
- Selectable 24-hour or 12-hour format (with AM/PM indicator)
- Output format example: `Current Time: 2026-Feb-04 12:14:19 UTC`

2. **Automatic Update Mechanism**
- Automatically updates the time display every second
- Intelligent activation/deactivation: Runs only when the text source is active, saving system resources

3. **Ease of Use Design**
- Directly select an existing text source in the OBS settings panel
- Provides a "Test Display" button for instant preview
- Supports both GDI+ and FreeType2 text sources

## ⚙️ **Installation and Configuration Steps**

1. **Install the Plugin**
- Place the `Time.lua` file in the OBS scripts directory
- In OBS, open the "Tools" menu → "Scripts" → click "+" to add this script

2. **Basic Configuration**
- In the script settings panel, select a text source from the dropdown list
- Select the time zone (UTC or local time)
- Select the time format (24-hour or 12-hour)

3. **Usage Instructions**
- The plugin will automatically detect the activation status of the text source
- When the scene containing the text source is activated, the time starts updating automatically
- The time refreshes every second for accurate display

## 🔧 **Technical Features**

- **Lightweight and Efficient:** The timer runs only when needed
- **Resource-Friendly:** Automatically binds to existing text sources, requiring no additional resources
- **Stable and Reliable:** Correctly handles signals and lifecycle management
- **Good Compatibility:** Supports standard text sources in OBS Studio

## 💡 **Use Cases**

- **Live Stream Time Display:** Let viewers know the current time
- **Screen Recording Timestamp:** Add a time reference to recorded videos
- **Multi-Time Zone Live Streaming:** Use UTC time for international viewers
- **Time-Sensitive Content:** Demonstrations or tutorials requiring accurate time recording

## ⚠️ **Notes**

- You must first create a text source in OBS. A text source must be created in OBS before it can be selected in the plugin.
- The plugin only updates the text content; font, color, position, and other styles need to be set in the text source properties.
- After changing the settings, you may need to reactivate the scene for the changes to take effect.

This plugin has a clear code structure and detailed comments, making it easy to understand and modify. If you need to customize different time formats, you can modify the formatting string in the `get_formatted_time()` function.