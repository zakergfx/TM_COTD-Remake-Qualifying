// enum DisplayMode{
//     Always = 0,
//     On_OpenPlanet_UI = 1,
//     On_Game_UI = 2
// };

// [Setting  name="Only display the window when the game Interface is enabled"]
// DisplayMode settings_displayMode = DisplayMode::On_Game_UI;

// [Setting  category="Global" name="Turn on the plugin automatically"]
// bool settings_pluginAlwaysOn = false;

enum TextSize {
    Small=0,
    Medium=1,
    Large=2
}

[Setting  category="Window Display" name="Font size"]
TextSize settings_textSize = TextSize::Small;

[Setting  category="Window Display" name="Hide the window when the Openplanet overlay is hidden"]
bool settings_hideWhenNotOverlay = false;

[Setting  category="Window Display" name="Hide the window when the game UI is hidden"]
bool settings_hideWhenFocus = false;

[Setting  category="Fields Display" name="Display the rank"]
bool settings_showRank = true;

[Setting  category="Fields Display" name="Display the division"]
bool settings_showDiv = true;

[Setting  category="Fields Display" name="Display the top %"]
bool settings_showPercent = false;

[Setting  category="Fields Display" name="Display the session time"]
bool settings_showSessionTime = true;

[Setting  category="Fields Display" name="Display the COTD date"]
bool settings_showDate = false;

[Setting  category="Fields Display" name="Display the Target Div required time"]
bool settings_showTargetDiv = false;

[Setting  category="Fields Display" name="Target Div"]
uint settings_targetDiv = 1;