void displayUI()
{

if (showUI)
	{
		if (settings_textSize == 0)
		{
			@font = g_SmallFont;
		}
		else if (settings_textSize == 1)
		{
			@font = g_MidFont;
		}
		else if (settings_textSize == 2)
		{
			@font = g_BigFont;
		}

		UI::Begin(ColoredString("$EEECOTD Remake Qualifying"), 65);
		if (display == "loading")
		{

			UI::Text("LOADING...");
		}
		else if (display == "no data")
		{

			UI::Text("This COTD was broken. \nNo qualifying data.");
		}
		else if (display == "too old")
		{

			UI::Text("This COTD is too old. \nNo qualifying data.");
		}
		else if (display == "regular")
		{
			auto rank = tostring(int(data["rank"]));
			auto nbPlayers = tostring(int(data["nbPlayers"]));
			auto percentile = tostring(float(data["percentile"]));
			auto time = uint(data["time"]);
			auto date = string(data["date"]);
			auto div = tostring(Math::Ceil(float(Text::ParseInt(rank))/64));
			auto totalDiv = tostring(Math::Ceil(float(Text::ParseInt(nbPlayers))/64));
            
			auto formattedDate = date;

            auto formattedTime = formatSessionTime(time);

			uint nbElementToDisplay = boolToInt(settings_showRank)+boolToInt(settings_showDiv)+boolToInt(settings_showPercent)+boolToInt(settings_showSessionTime)+boolToInt(settings_showDate);

			if (settings_showRank)
			{
				UI::Text(ColoredString("$BBBRANK: $FFF"+rank+" / "+nbPlayers));
			}
			if (settings_showDiv)
			{
				UI::Text(ColoredString("$BBBDIV: $FFF"+div+" / "+totalDiv));
			}
			if (settings_showPercent)
			{
				UI::Text(ColoredString("$BBBTOP: $FFF"+percentile+" %"));
			}
			if (settings_showTargetDiv)
			{
				UI::Text(ColoredString("$BBBDIV " + settings_targetDiv + " TIME: $FFF"+targetDivTime));
			}
			if (settings_showSessionTime)
			{
				UI::Text(ColoredString("$BBBSESSION TIME: $FFF"+formattedTime));
			}
			if (settings_showDate)
			{
				UI::Text(ColoredString("$BBBCOTD DATE: $FFF"+formattedDate));
			}
		}

		UI::End();
	}
}



void Render()
{
	UI::PushFont(font);
	if (!(settings_hideWhenFocus && !UI::IsGameUIVisible() || settings_hideWhenNotOverlay && !UI::IsOverlayShown()))
	{
		displayUI();
	}
	UI::PopFont();
}


// void Render() { 
// 	UI::PushFont(g_BigFont);
// 	UI::Begin("window here");
// 	UI::Text("hi"); 
  
//   UI::End();
//   UI::PopFont();
// }

// void RenderMenu()
// {
// 	if (playerInGame && !working && !settings_pluginAlwaysOn)
// 	{
// 		if (UI::MenuItem("\\$FF0"+ Icons::FlagCheckered + "\\$FF0 RUN COTD Remake Qualifying", "", working || settings_pluginAlwaysOn))
// 		{
// 			working = !working || settings_pluginAlwaysOn;
// 		}
// 	}

// }