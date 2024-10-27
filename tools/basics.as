float calcPercentage(const int &in pos, const uint &in total) {
	return float(int(((float(pos) / float(total)) * 100.0) * 100.0)) / 100.0;
}

uint boolToInt(bool x) 
{
	if (x)
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

string getFormattedDate(uint timestamp)
{
    auto timeObject = Time::ParseUTC(timestamp);
    auto year = ""+timeObject.Year;
    auto month = ""+timeObject.Month;
    auto day = ""+timeObject.Day;

    if(month.Length == 1)
    {
        month = "0"+month;
    }

    if(day.Length == 1)
    {
        day = "0"+day;
    }

    return day+"/"+month+"/"+year;
}

string formatDateComponent(int component)
{
	auto str_component = ""+component;
	if (str_component.Length == 1)
	{
		str_component = "0"+component;
	}

	return str_component;
}

uint getCustomTimeStamp(uint timestamp)
{
    auto timeObject = Time::ParseUTC(timestamp);
    auto year = ""+timeObject.Year;
    auto month = formatDateComponent(timeObject.Month);
    auto day = formatDateComponent(timeObject.Day);

    return uint(Text::ParseInt(year+""+month+""+day));
}


string formatSessionTime(uint time)
{
	string hour_str;
	string minute_str;
	string second_str;

	auto hour = time/3600;
	time -= hour*3600;
	if (hour < 10)
	{
		hour_str =  "0"+hour;;
	}
	else
	{
		hour_str = tostring(hour);
	}
	auto minute = time/60;
	if (minute < 10)
	{
		minute_str =  "0"+minute;
	}
	else
	{
		minute_str = tostring(minute);
	}
	time -= minute*60;
	auto second = time;
	if (second < 10)
	{
		second_str =  "0"+second;
	}
	else
	{
		second_str = tostring(second);
	}

	return hour_str+":"+minute_str+":"+second_str;
}

