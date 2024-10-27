bool isMapOld(uint date)
{
	return date < 1604300400;
}

string getCurrentMapId()
{

	auto app = cast<CTrackMania>(GetApp());
	return app.RootMap.MapInfo.MapUid;
}

uint getPbFromMapId(MwId userId, const string &in mapId)
{
	auto app = cast<CTrackMania>(GetApp());
	auto network = cast<CTrackManiaNetwork>(app.Network);

	return network.ClientManiaAppPlayground.ScoreMgr.Map_GetRecord_v2(userId, mapId, "PersonalBest", "", "TimeAttack", "");
}

// check if the player is playing the map through the cotd server or totd campaign or directly in local
bool isPlaygroundCorrect()
{
	auto app = cast<CTrackMania>(GetApp());
	auto network = cast<CTrackManiaNetwork>(app.Network);
	
	return network.PlaygroundClientScriptAPI.ServerInfo.ModeName == "TM_TimeAttack_Online" || network.PlaygroundClientScriptAPI.ServerInfo.ModeName == "TM_Campaign_Local" || network.PlaygroundClientScriptAPI.ServerInfo.ModeName == "TM_PlayMap_Local";
}

bool isMapCotd(const string &in mapId)
{
	auto baseUrl = NadeoServices::BaseURLLive();
	auto url = baseUrl+"/api/campaign/map/"+mapId;
	auto newreq = NadeoServices::Get("NadeoLiveServices", url);
	newreq.Start();
	total_requests += 1;
	// print("total_requests:"+tostring(total_requests));
	while(!newreq.Finished()){
		yield();
	}

	auto response = Json::Parse(newreq.String());

	return Json::Write(response["totdMaps"]) != "[]";
}