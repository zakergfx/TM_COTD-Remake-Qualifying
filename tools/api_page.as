Json::Value@ getLeaderboardPage(int cotdId, int offset)
{
    auto response = Json::Object();
    if (!cache.Exists(tostring(offset)))
    {
        // print("query");
        auto baseUrl = NadeoServices::BaseURLMeet();
        auto url = baseUrl+"/api/challenges/"+cotdId+"/leaderboard?length=100&offset="+offset;;
        auto req = NadeoServices::Get("NadeoClubServices", url);
        req.Start();
        total_requests += 1;
        // print("total_requests:"+tostring(total_requests));
        while(!req.Finished()){
            yield();
        }
        response = Json::Parse(req.String())["results"];
        cache[tostring(offset)] = Json::Write(response);    
    }
    else
    {
        response = Json::Parse(string(cache[tostring(offset)]));
        // print("cache");
    }

	return response;

}

Json::Value@ getTotdPage(uint offset)
{
	auto baseUrl = NadeoServices::BaseURLLive();
    auto url = baseUrl+"/api/token/campaign/month?offset="+offset+"&length=10&royal=0";
    auto newreq = NadeoServices::Get("NadeoLiveServices", url);
    newreq.Start();
    total_requests += 1;
    // print("total_requests:"+tostring(total_requests));
    while(!newreq.Finished()){
        yield();
    }
    auto response = Json::Parse(newreq.String());
    return response;

}

Json::Value@ getChallengesPage(int offset)
{
    auto baseUrl = NadeoServices::BaseURLMeet();
    auto url = baseUrl+"/api/challenges?length=100&offset="+offset;
    auto newreq = NadeoServices::Get("NadeoClubServices", url);
    total_requests += 1;
    // print("total_requests:"+tostring(total_requests));
    newreq.Start();
    while(!newreq.Finished()){
        yield();
    }
    auto response = Json::Parse(newreq.String());
    return response;

}





