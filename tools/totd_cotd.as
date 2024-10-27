bool isChallengeMainCotd(Json::Value@ cotd)
{
	auto lowerName = Json::Write(cotd["name"]).ToLower();
	auto challengeIsCotd = lowerName.Contains("cotd") || lowerName.Contains("cup of the day");
	auto challengeIsCrossPlatform = lowerName.Contains("#1 - challenge") || (lowerName.Contains(" - challenge") && !lowerName.Contains("#"));
	
	auto dateObject = Time::ParseUTC(Text::ParseInt(Json::Write(cotd["startDate"])));
	auto hourIsCorrect = dateObject.Hour == 17 || dateObject.Hour == 18;

	return challengeIsCotd && challengeIsCrossPlatform && hourIsCorrect;
}

bool isCotdInProgress(Json::Value@ cotd)
{
	auto currentDateTs = Time::get_Stamp();
	auto currentDateObject = Time::ParseUTC(currentDateTs);
	auto currentDate = getFormattedDate(currentDateTs);

	auto startDate = string(cotd["date"]);

	auto cotdIsToday = currentDate == startDate;

	auto cotdHour = Time::ParseUTC(uint(cotd["ts"])).Hour;
	auto timeIsCotd = (currentDateObject.Hour == cotdHour) && (currentDateObject.Minute >= 0 && currentDateObject.Minute < 16);

	return cotdIsToday && timeIsCotd;

}

string getTargetTime(int cotdId, uint targetDiv, uint playerCount)
{
	uint targetRank = targetDiv*64;
	if (playerCount < targetRank || targetRank < 1)
	{
		targetRank = playerCount;
	}

	auto baseUrl = NadeoServices::BaseURLMeet();
	auto url = baseUrl+"/api/challenges/"+cotdId+"/leaderboard?length=1&offset="+tostring(targetRank-1);
	auto req = NadeoServices::Get("NadeoClubServices", url);
	req.Start();
	total_requests += 1;
	// print("total_requests:"+tostring(total_requests));
	while(!req.Finished()){
		yield();
	}
	auto response = Time::Format(uint(Json::Parse(req.String())["results"][0]["score"]));
	return response;


}

uint getPlayerCount(int cotdId)
{
	auto baseUrl = NadeoServices::BaseURLMeet();
	
	auto url = baseUrl+"/api/challenges/"+cotdId+"/leaderboard?length=1&offset=0";
	auto req = NadeoServices::Get("NadeoClubServices", url);
	req.Start();
	total_requests += 1;
	// print("total_requests:"+tostring(total_requests));
	while(!req.Finished()){
		yield();
	}
	auto response = Json::Parse(req.String())["cardinal"];
	if (response > 100000)
	{
		response = 0;
	}
		
	return response;
}

int getNbChallenges()
{
    auto baseUrl = NadeoServices::BaseURLMeet();
    auto url = baseUrl+"/api/challenges?length=1&offset=0";
    auto newreq = NadeoServices::Get("NadeoClubServices", url);
    newreq.Start();
	total_requests += 1;
	// print("total_requests:"+tostring(total_requests));
    while(!newreq.Finished()){
        yield();
    }
    
    auto response = int(Json::Parse(newreq.String())[0]["id"]);

    return response;
}   


// get all players scores and positions from the leaderboard page where your pb would have been, ~4 requests to api
dictionary getClosestLeaderboardPage(int cotdId, uint pb, uint playerCount)
{

	int offset = 0;
	auto nbElements = playerCount;
	bool isOver;
	int left = 0;
	int right = nbElements-1;
	while (left <= right)
	{
		auto mid = int(left+right)/2;
		offset = mid;
		auto response = getLeaderboardPage(cotdId, offset);
		isOver = response.Length == 0;

		if (isOver)
		{
			right = mid-1;
		}
		else
		{
			dictionary leaderboard = {};
			uint scoreMin = uint(response[0]["score"]);
			uint scoreMax = uint(response[response.Length-1]["score"]);
			if (pb < scoreMin)
			{
				right = mid-1;
			}
			else if (pb > scoreMax)
			{
				left = mid+1;
			}
			
			else
			{

				for(uint i=0; i < response.Length; i++)
				{
					uint score = uint(response[i]["score"]);
					string rank = Json::Write(response[i]["rank"]);
					leaderboard[rank] = score;
				}
				return leaderboard;
		}
	}

		
	}
		// if first
		auto response = getLeaderboardPage(cotdId, 0);
		dictionary leaderboard = {};

		for(uint i=0; i < response.Length; i++)
			{
				uint score = uint(response[i]["score"]);
				string rank = Json::Write(response[i]["rank"]);
				leaderboard[rank] = score;
			}
		return leaderboard;

}

//from a leaderboard page, return the position that is the closest to the pb in parameter
dictionary getRankInfo(dictionary leaderboard, uint pb, uint playerCount)
{
	dictionary data;
	uint closestScore;
	uint closestAbsolue = 4294967295;
	uint closestId;

	auto keys = leaderboard.GetKeys();

	if (pb != 4294967295)
	{

		for (uint i=0;i<keys.Length;i++)
		{
			uint absolue = Math::Abs(pb-uint(leaderboard[keys[i]]));

			if (absolue < closestAbsolue)
			{
				closestScore = uint(leaderboard[keys[i]]);
				closestAbsolue = absolue;
				closestId = Text::ParseInt(keys[i]);
			}
		}

	}
	else
	{
		closestId = playerCount;
	}
	
	data["rank"] = closestId;
	data["nbPlayers"] = playerCount;
	data["percentile"] = float(calcPercentage(closestId, playerCount));

	return data;
}	

// does between 1 (new totd) and 4 requests (old totd);
uint getTotdDateFromMapId(const string &in mapId)
{
	uint date;
	uint offset = 0;
	auto totdFound = false;
	while (!totdFound)
		{
			bool monthFinished = false;
			
			auto response = getTotdPage(offset);

			if (response.Length != 0)
			{
				for(uint monthId=0;monthId<response["monthList"].Length;monthId++)
				{
					auto month = response["monthList"][monthId];
					for(uint dayId=0;dayId<month["days"].Length;dayId++)
					{
						auto day = month["days"][dayId];
						auto currentMapId = Json::Write(day["mapUid"]);
						if (currentMapId.Contains(mapId))
						{
							date = int(day["startTimestamp"]);
							totdFound = true;
						}
					}
				}
			}
			offset += 10;
		}
	return date;
}

// does ~4 requests to the api
dictionary getCotdFromDate(uint rawDate)
{
    auto date = getCustomTimeStamp(rawDate);
	auto offset = 0;

	auto nbElements = getNbChallenges();
    bool isOver;
    auto left = 0;
    auto right = nbElements-1;
    uint minDate;

    uint maxDate;

    while (left <= right)
    {
        auto mid = int(left+right)/2;
        offset=mid;
        auto response = getChallengesPage(offset);
        isOver = response.Length == 0;
        //print(offset);
        if (isOver)
        {
            right = mid-1;
        }
        else
        {
            for (uint i=0; i<response.Length;i++)
            {
				auto cotd = response[i];
  		        if(isChallengeMainCotd(cotd))
                {
                    //print("maxdate: "+ dateObject.Year+"--"+dateObject.Month+"--"+dateObject.Day);
                    maxDate = getCustomTimeStamp(int(cotd["startDate"]));
                    break;
                }
            }

            for (uint i=response.Length-1; i>=0;i--)
            {
                auto cotd = response[i];
  		        if(isChallengeMainCotd(cotd))
                {
                    //print("maxdate: "+ dateObject.Year+"--"+dateObject.Month+"--"+dateObject.Day);
                    minDate = getCustomTimeStamp(int(cotd["startDate"]));
                    break;
                }
            }
            //print(date+"---"+minDate+"---"+maxDate);
            if (date < minDate)
            {
                left = mid+1;

            }
            else if(date > maxDate)
            {
                right = mid-1;
            }
            else
            {
				for (uint i=0;i<response.Length;i++)
                {
					auto cotd = response[i];
                    auto name = Json::Write(cotd["name"]);
                    auto id = Json::Write(cotd["id"]);

					auto cotdDate = uint(response[i]["startDate"]);
                    auto challDate = getCustomTimeStamp(cotdDate);
					auto formattedDate = getFormattedDate(cotdDate);

                    if(isChallengeMainCotd(cotd) && date == challDate)
                    {
                        dictionary values = {{"ts", cotdDate}, {"date", formattedDate}, {"name", name}, {"id", id}};
                        //print("VALUES: "+Json::Write(values));
                        return values;
                    }
                }

            }
        }
    }
    return {};
	
}
