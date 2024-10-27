MwId getUserId()
{
	auto app = cast<CTrackMania>(GetApp());
	MwId userId;
	if (app.Network.ClientManiaAppPlayground.UserMgr.Users.Length > 0) 
	{
		userId = app.Network.ClientManiaAppPlayground.UserMgr.Users[0].Id;
	} 
	else 
	{
		userId.Value = uint(-1);
	}

	return userId;
}

bool isPlayerInGame()
{
	try
	{
		auto app = cast<CTrackMania>(GetApp());
		return !(app.RootMap is null);
	}
	catch 
	{
		return false;
	}
}


