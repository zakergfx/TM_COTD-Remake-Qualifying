dictionary data;
dictionary cache;
string display;
bool showUI = false;
auto total_requests = 0;
string targetDivTime;
UI::Font@ font;
void addAudiences()
{
	NadeoServices::AddAudience("NadeoLiveServices");
	NadeoServices::AddAudience("NadeoClubServices");
	while (!NadeoServices::IsAuthenticated("NadeoClubServices") && !NadeoServices::IsAuthenticated("NadeoLiveServices")){yield();}
}

UI::Font@ g_SmallFont;
UI::Font@ g_MidFont;
UI::Font@ g_BigFont;
void LoadFonts() {
	@g_SmallFont = UI::LoadFont("DroidSans.ttf", 16);
	@g_MidFont = UI::LoadFont("DroidSans.ttf", 20);
	@g_BigFont = UI::LoadFont("DroidSans.ttf", 24);
}

void Main()
{	

	startnew(LoadFonts);
	addAudiences();
	while (true)
	{

		auto playerInGame = isPlayerInGame();
		try
		{
			if (playerInGame)
			{
				//print("interloop");
				auto mapId = getCurrentMapId();
				if (isPlaygroundCorrect() && isMapCotd(mapId))
				{
					auto date = getTotdDateFromMapId(mapId);
					if (!isMapOld(date))
					{				
						
						auto cotd = getCotdFromDate(date);

						if(!isCotdInProgress(cotd))
						{
							display = "loading";
							showUI = true;
							auto userId = getUserId();

							auto cotd_id = Text::ParseInt(string(cotd["id"]));

							auto playerCount = getPlayerCount(cotd_id);

							if(playerCount > 0)
							{
								uint old_pb = 0;
								uint oldTargetDiv = 0;

								auto baseTime = Time::get_Stamp();

								cache = {};
								while (playerInGame)
								{
									data["time"] = Time::get_Stamp()-baseTime;
									//print("Main while");
									if (mapId == getCurrentMapId())
									{

										auto pb = getPbFromMapId(userId, mapId);

										if (settings_targetDiv != oldTargetDiv)
										{
											targetDivTime = getTargetTime(cotd_id, settings_targetDiv, playerCount);
											oldTargetDiv = settings_targetDiv;
										}

										if (pb != old_pb)
										{
											display = "loading";
											old_pb = pb;

											auto leaderboard = getClosestLeaderboardPage(cotd_id, pb, playerCount);
											
											auto rankInfo = getRankInfo(leaderboard, pb, playerCount);
											data["date"] = string(cotd["date"]);
											data["rank"] = int(rankInfo["rank"]);
											data["nbPlayers"] = int(rankInfo["nbPlayers"]);
											data["percentile"] = float(rankInfo["percentile"]);
											//print(Json::Write(data));
											display = "regular";
											print("total_requests: "+tostring(total_requests));
										}
										playerInGame = isPlayerInGame();
										
									}
									else
									{
										playerInGame = false;
										showUI = false;
									}
									sleep(1000);
								}
							}
							else
							{
								display = "no data";
								while (playerInGame)
								{
									if (mapId != getCurrentMapId())
									{
										playerInGame = false;
										showUI = false;
									}
									sleep(1000);
								}
							}
						}
						else
						{

							playerInGame = true;
							while (playerInGame)
							{
								if (!isPlayerInGame())
								{
									playerInGame=false;
								}
								sleep(1000);
							}
						}
						
					}
					else
					{
						display = "too old";
						showUI = true;
						while (playerInGame)
						{
							if (mapId != getCurrentMapId())
							{
								playerInGame = false;
								showUI = false;
							}
							sleep(1000);
						}
					}
				}
				else
				{
					while (playerInGame)
						{
							if (mapId != getCurrentMapId())
							{
								playerInGame = false;
							}
							sleep(1000);
						}
				}
			}
			else
			{
				playerInGame = false;
				showUI = false;
			}
		}
		catch
		{
			// print("catch--"+getExceptionInfo());
			showUI = false;
		}
	//print("while true");


		
	sleep(1000);
}
}

