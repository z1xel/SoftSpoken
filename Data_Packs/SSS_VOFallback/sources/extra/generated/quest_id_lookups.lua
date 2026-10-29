if not VoiceOver or not VoiceOver.DataModules then return end
AI_VoiceOverData_VanillaExtra.QuestIDLookup = {
	["accept"] = {
		["Wolves Across the Border"] = 33,
		["Kobold Camp Cleanup"] = 7,
		["Investigate Echo Ridge"] = 15,
		["Skirmish at Echo Ridge"] = 21,
		["Report to Goldshire"] = 54,
		["Simple Letter"] = 3100,
		["Consecrated Letter"] = 3101,
		["Encrypted Letter"] = 	{
			["Marshal McBride"] = 3102,
			["Syndicate Documents"] = 511
		},
		["Hallowed Letter"] = 3103,
		["Glyphic Letter"] = 3104,
		["Tainted Letter"] = 3105,
		["The Killing Fields"] = 9,
		["Report to Gryan Stoutmantle"] = 	{
			["Farmer Saldean"] = 109,
			["Farmer Furlbrow"] = 109,
			["Marshal Dughan"] = 109,
			["Guard Thomas"] = 109,
			["Marshal Haggard"] = 109,
			["Deputy Rainer"] = 109
		},
		["The People's Militia"] = 	{
			["Gryan Stoutmantle"] = 		{
				["The People's Militia has but one goal: To defend the lands of Westfall and return peace to our surroundings. Unfortunately, the price of peace is Molsen Farm and Furlbrow's Pumpkin Farm. If you seek to join our ranks, slay 15 Defias Trappers and 15 Defias Smugglers then return to me."] = 12,
				["A band of vicious Defias Pillagers has been seen plundering the Gold Coast Quarry, Moonbrook and the Alexston Farmstead. The People's Militia will not stand of the tower. As the next step of your training, I want you to kill 15 of those foul Defias Pillagers and 15 Defias Looters."] = 13,
				["Some Defias have eluded us. My most trusted scout reports that these Defias have been looting and pillaging the countryside, all the way into Southern Westfall. We believe they are hiding out in the Dagger Hills, plotting their next move. Slay the wretches in the name of The People's Militia."] = 14
			}
		},
		["The Defias Brotherhood"] = 	{
			["Gryan Stoutmantle"] = 		{
				["The band of wretches responsible for driving the good people of Westfall from the land call themselves The Defias Brotherhood. I need you to infiltrate by the name of Wiley who owes me a favor. Travel to Lakeshire in the Redridge Mountains, east of Elwynn, and find out what you can."] = 65,
				["I wonder what Wiley meant when he mentioned the Stonemasons. Perhaps that was a slip of tongue. Could the Defias gang be related to the Note and see if he has anything to add to this growing mystery. If you have trouble finding Shaw, check the Barracks in Old Town."] = 135,
				["We need to discover the location of the Defias hideout. $N, my scout reports that a Defias Messenger has been seen on the roads between Gold Coast Quarry and the Jangolode Mine. I want you to capture him. If he resists, kill him and bring me whatever he is carrying."] = 142,
				["There is but one task left for you to complete. Edwin VanCleef must be assassinated. While it saddens me to condemn any man to a of the people of Westfall that VanCleef is laid to rest once and for all. Bring me the villain's head once the deed is done."] = 166
			},
			["Wiley the Black"] = 132,
			["Master Mathias Shaw"] = 141,
			["The Defias Traitor"] = 155
		},
		["Messenger to Westfall"] = 	{
			["Gryan Stoutmantle"] = 144,
			["Magistrate Solomon"] = 143
		},
		["Goretusk Liver Pie"] = 22,
		["Westfall Stew"] = 	{
			["Salma Saldean"] = 38,
			["Verna Furlbrow"] = 36
		},
		["The Forgotten Heirloom"] = 64,
		["Poor Old Blanchy"] = 151,
		["Sweet Amber"] = 	{
			["Grimbooze Thunderbrew"] = 		{
				["In the land to the south where vines twist and creep Lies a hidden well where the water runs deep Pure as the Light's sacred Daughter Bring to where vines twist and creep Lies a hidden well where the water runs deep Pure as the Light's sacred Daughter Bring to me now some Holy Spring Water."] = 48,
				["Amber is the hue of my life's longest love Like the last embers of dusk in the sky above Retrieve for me so that my love shall the last embers of dusk in the sky above Retrieve for me so that my love shall be born One sack of each: barley, rye and corn."] = 49,
				["I'll mix and mix till we have a mash For this will be our own private stash A still must be fashioned of metal strong Bring me some a mash For this will be our own private stash A still must be fashioned of metal strong Bring me some Truesilver so I can finish this song."] = 50,
				["Not yet filtered but freshly distilled Like unseeded land waiting there tilled. Next I will fashion our pile of charcoal Deliver a sycamore branch, that is your next yet filtered but freshly distilled Like unseeded land waiting there tilled. Next I will fashion our pile of charcoal Deliver a sycamore branch, that is your next goal."] = 51,
				["Mellifluous liquid clear as a baby's tears Turns a lovely deep amber over the years But before we proceed to get lit to the hilt A barrel of baby's tears Turns a lovely deep amber over the years But before we proceed to get lit to the hilt A barrel of charred oak must be built."] = 53
			}
		},
		["Thunderbrew Lager"] = 117,
		["Further Concerns"] = 35,
		["Cloth and Leather Armor"] = 59,
		["The Fargodeep Mine"] = 62,
		["The Jasperlode Mine"] = 76,
		["Manhunt"] = 147,
		["Westbrook Garrison Needs Help!"] = 239,
		["A Fishy Peril"] = 40,
		["Gold Dust Exchange"] = 47,
		["Princess Must Die!"] = 88,
		["Back to Billy"] = 84,
		["Lost Necklace"] = 85,
		["Pie for Billy"] = 86,
		["Goldtooth"] = 87,
		["Note to William"] = 107,
		["Young Lovers"] = 106,
		["Speak with Gramma"] = 111,
		["Kobold Candles"] = 60,
		["Shipment to Stormwind"] = 61,
		["Collecting Kelp"] = 112,
		["The Escape"] = 	{
			["William Pestle"] = 114,
			["Wizzlecrank's Shredder"] = 863
		},
		["Find the Lost Guards"] = 37,
		["Deliver Thomas' Report"] = 39,
		["Bounty on Murlocs"] = 46,
		["Protect the Frontier"] = 52,
		["Messenger to Darkshire"] = 	{
			["Lord Ello Ebonlocke"] = 146,
			["Magistrate Solomon"] = 145
		},
		["Translate Abercrombie's Note"] = 251,
		["Bride of the Embalmer"] = 253,
		["The Night Watch"] = 	{
			["Commander Althea Ebonlocke"] = 		{
				["As Commander of The Night Watch it is my sworn duty to protect the citizens of Darkshire. Stormwind has retracted their commissioned guards from their by venturing forth into Tranquil Gardens, just south of Darkshire, and slaying 8 Skeletal Warriors and 6 Skeletal Mages. The undead threat must be thwarted!"] = 56,
				["$N, I'm getting reports of an undead infestation in the forest! If you're up to the job, journey to the Raven Hill graveyard and slay Skeletal Horrors. There are also reports of skeletons just south of Darkshire, in and around Tranquil Gardens Cemetery. The undead must be driven from Duskwood!"] = 57,
				["The situation in Raven Hill is still grim. The safety of Darkshire is in your hands, $N. I don't have enough Watchers to keep the Watchers to keep the town safe. We need you to dispatch for Raven Hill yet again and rid the eastern mausoleum of 20 Plague Spreaders!"] = 58
			}
		},
		["The Legend of Stalvan"] = 	{
			["Commander Althea Ebonlocke"] = 		{
				["I have had my eye on that creep, Stalvan, for quite sometime. But if this page was written by the same hand it proves his Registry, Clerk Daltry has become an expert at identifying handwriting. Show him this page and see if the writing matches that of the registry signature."] = 80,
				["Stalvan Mistmantle led a life of depravity. Innocent victims died by his hand. Undoubtedly he is guilty of countless crimes. Now the lunatic threatens Darkshire. and show her his family ring. After all, it was her premonition that led to this gruesome discovery. But Darkshire is safer because of her."] = 98
			},
			["Madame Eva"] = 66,
			["Clerk Daltry"] = 		{
				["Stalvan, eh? Let me check the town registry. Stalvan. . .Stalvan. . .let's see. Ah, here we go! I have a record of a Mr. Stalvan you happen to go out to Moonbrook, let me know if you get any update on this fellow. I like to keep the records clean."] = 67,
				["Oh my! Must have missed this the first time. In the registry, right beneath the first address for Stalvan there's another one listed, only partially one listed, only partially scratched out. Looks like he was headed to The Lion's Pride Inn over in Goldshire. Might want to check there, $N."] = 69,
				["Let Commander Ebonlocke know immediately that the handwriting matched, $N! Her suspicions were correct! Let Commander Ebonlocke know immediately that the handwriting matched, $N! Her suspicions were correct!"] = 97
			},
			["Tavernkeep Smitts"] = 79,
			["Marshal Haggard"] = 		{
				["There was a bundle of parchments in the chest upstairs when I moved into this place. I looked at them once when I first arrived pretty sure there's a faded journal page that might be of interest to you. Bring it to me and I'll help in anyway I can."] = 75,
				["I know of someone who might be able to assist you. Back when I was leading the Stormwind Guard, we used to get drinks at The Innkeeper there, Smitts, was quite an expert on the local lore. Show him this page and see what he has to say about it."] = 78
			},
			["Innkeeper Farley"] = 70,
			["Caretaker Folsom"] = 72,
			["Sealed Crate"] = 74,
			["Old Footlocker"] = 68
		},
		["Mor'Ladim"] = 228,
		["The Daughter Who Lived"] = 229,
		["The Totem of Infliction"] = 101,
		["Ghost Hair Thread"] = 149,
		["Deliver the Thread"] = 157,
		["The Shadowy Search Continues"] = 265,
		["Inquire at the Inn"] = 266,
		["The Carevin Family"] = 1042,
		["Morgan Ladimore"] = 227,
		["Translation to Ello"] = 252,
		["Wait for Sirra to Finish"] = 401,
		["Crime and Punishment"] = 377,
		["Seasoned Wolf Kabobs"] = 90,
		["Dusky Crab Cakes"] = 93,
		["Return to Jitters"] = 240,
		["Gather Rot Blossoms"] = 156,
		["Juice Delivery"] = 159,
		["Finding the Shadowy Figure"] = 453,
		["Look To The Stars"] = 	{
			["Viktori Prism'Antras"] = 		{
				["My Gnomish friend, Cog, has promised to help me build a device which will let me peer towards the stars. A truth exists, beyond magic, the strange transformation in the forest. Bring to me a bronze tube made by a skilled engineer. That is the first step, according to Cog's blueprint."] = 174,
				["According to Cog's blueprint, what I need now is a way to reflect light. I remember a woman by the name of Mary who became Mary down and see if she might lend us a reflective surface for this project? I believe she once resided in southern Duskwood. . ."] = 175,
				["Now there is just one more item needed to complete this device. Cog's blueprint calls for a lens of some sort. The only lens I Zzarc'Vul who resides in the mound in southern Duskwood. If you can, bring to me his monocle and I will use that as our lens!"] = 181
			},
			["Blind Mary"] = 177
		},
		["Red Linen Goods"] = 83,
		["Jitters' Growling Gut"] = 5,
		["Return to Sven"] = 268,
		["Ghoulish Effigy"] = 133,
		["Ogre Thieves"] = 134,
		["Supplies from Darkshire"] = 148,
		["Zombie Juice"] = 158,
		["Note to the Mayor"] = 160,
		["Dead-tooth Jack"] = 1667,
		["Return the Comb"] = 154,
		["Morbent Fel"] = 55,
		["Sven's Revenge"] = 95,
		["The Shadowy Figure"] = 262,
		["Seeking Wisdom"] = 269,
		["Proving Your Worth"] = 323,
		["A Watchful Eye"] = 94,
		["Morganth"] = 	{
			["Theocritus"] = 249,
			["Old Lion Statue"] = 249
		},
		["Speak with Jennea"] = 1860,
		["Report to Jennea"] = 	{
			["Zaldimar Wefhellt"] = 1919,
			["Magis Sparkmantle"] = 1919,
			["Dink"] = 1919
		},
		["Look to an Old Friend"] = 350,
		["Brotherhood's End"] = 395,
		["Snatch and Grab"] = 2206,
		["Mathias and the Defias"] = 2360,
		["The Touch of Zanzil"] = 	{
			["Master Mathias Shaw"] = 2607,
			["Doc Mixilpixil"] = 		{
				["Oh my, you look like death. Correction - I've seen death, you look worse than death. You, $g sir:miss;, would be what death coughed up to draw some blood. Don't worry, it only hurts the first few... fifty times or so... /lay down when you're ready for the treatment, $N."] = 2608,
				["It's unanimous, $N. You've got the 'itis.' Luckily, I have a cure for the 'itis.' Here's what I need: One bundle of simple wildflowers, one leaded vial, now, $N, and try not to touch anyone until you're cured. Oh, and Dr. Montgomery says you need a shower -- his words, not mine."] = 2609
			}
		},
		["Honor the Dead"] = 6183,
		["Flint Shadowmore"] = 6184,
		["Mazen's Behest"] = 	{
			["Mazen Mac'Nadir"] = 1363,
			["Acolyte Dellis"] = 1364
		},
		["The Everstill Bridge"] = 89,
		["The Lost Tools"] = 125,
		["Rethban Ore"] = 347,
		["An Unwelcome Guest"] = 34,
		["Delivering Daffodils"] = 131,
		["Redridge Goulash"] = 92,
		["Messenger to Stormwind"] = 	{
			["Magistrate Solomon"] = 120,
			["General Marcus Jonathan"] = 121
		},
		["Dry Times"] = 116,
		["Missing In Action"] = 219,
		["Return to Lewis"] = 6285,
		["In Favor of the Light"] = 	{
			["Priestess Anetta"] = 5623,
			["Branstock Khalder"] = 5626
		},
		["Cenarion Aid"] = 	{
			["High Priestess Laurena"] = 8254,
			["Malakai Cross"] = 8254,
			["Father Cobb"] = 8254,
			["Astarii Starseeker"] = 8254,
			["Jandria"] = 8254,
			["Aelthalyste"] = 8254,
			["Father Lazarus"] = 8254,
			["Theodrus Frostbeard"] = 8254,
			["Braenna Flintcrag"] = 8254,
			["Brother Joshua"] = 8254,
			["X'yera"] = 8254,
			["Ur'kyo"] = 8254,
			["Priestess Alathea"] = 8254,
			["High Priest Rohan"] = 8254,
			["Aldrae"] = 8254,
			["Lotheolan"] = 8254,
			["Caedmos"] = 8254,
			["Fallat"] = 8254
		},
		["Garments of the Light"] = 	{
			["Priestess Josetta"] = 5624,
			["Maxan Anvol"] = 5625
		},
		["A Free Lunch"] = 129,
		["Selling Fish"] = 127,
		["Murloc Poachers"] = 150,
		["Tharil'zun"] = 19,
		["Blackrock Menace"] = 20,
		["Shadow Magic"] = 115,
		["Keeper of the Flame"] = 103,
		["The Coastal Menace"] = 104,
		["The Coast Isn't Clear"] = 152,
		["The Price of Shoes"] = 118,
		["Underbelly Scales"] = 122,
		["A Baying of Gnolls"] = 124,
		["Howling in the Hills"] = 126,
		["Elmore's Task"] = 	{
			["Verner Osgood"] = 1097,
			["Smith Argus"] = 1097
		},
		["In Search of Menara Voidrender"] = 	{
			["Demisette Cloyce"] = 4738,
			["Zevrost"] = 4737,
			["Kaal Soulreaper"] = 4739,
			["Briarthorn"] = 4736
		},
		["Knowledge of the Orb of Orahil"] = 	{
			["Demisette Cloyce"] = 4968,
			["Zevrost"] = 4967,
			["Kaal Soulreaper"] = 4969,
			["Briarthorn"] = 4965,
			["Alamma"] = 4968
		},
		["An Imp's Request"] = 	{
			["Demisette Cloyce"] = 8419,
			["Kartosh"] = 8419,
			["Grol'dar"] = 8419,
			["Mirket"] = 8419,
			["Zevrost"] = 8419,
			["Kaal Soulreaper"] = 8419,
			["Luther Pickman"] = 8419,
			["Richard Kerwin"] = 8419,
			["Thistleheart"] = 8419,
			["Briarthorn"] = 8419,
			["Alexander Calder"] = 8419,
			["Ursula Deline"] = 8419,
			["Sandahl"] = 8419,
			["Alamma"] = 8419,
			["Talionia"] = 8419,
			["Zanien"] = 8419,
			["Babagaya Shadowcleft"] = 8419
		},
		["Visit the Herbalist"] = 130,
		["Encroaching Gnolls"] = 244,
		["Bookie Herod"] = 200,
		["Colonel Kurzen"] = 202,
		["Patrol Schedules"] = 330,
		["The Head of the Beast"] = 394,
		["The Missing Diplomat"] = 	{
			["Elling Trias"] = 		{
				["Jorgen, you ol' sonuva.... So, that's how it's going to be, huh? All right, I can deal with that. I hope he finds the Twisting Nether right outside of town. Just tell him you're looking into any Defias activity for me and he'll help you out with any information he can."] = 1243,
				["Yeah, now that I think about it... Dashel... Dashel something... What was his name? FIST! Dashel Stonefist. They call him Fist in some circles--probably on up some. And don't hesitate. If he's in this as deep as these papers suggest, then he's not going to give you any information willingly."] = 1246,
				["A contact of mine retired in the Wetlands at the harbor city of Menethil. He should be willing to help on your word alone if need to find out where they've taken him, or at least who he is. The docket doesn't mention anything about their plans after he's captured."] = 1248
			},
			["Watcher Backus"] = 		{
				["Defias activity? Well, there's always some activity; even if they keep to themselves we consider them a threat. But now that I think about it, there don't you check there first and bring me back anything you find? The farmstead is south of the road from Westfall just as you enter Duskwood."] = 1244,
				["Whoa, this looks way too complex to be something to just lead you astray. I shouldn't even be looking at this stuff. Take it to anyone I helped you. If my superiors found out I knew about any of this and didn't share it with them they'd probably hang me."] = 1245
			},
			["Jorgen"] = 1242,
			["Bishop DeLavey"] = 1241,
			["Dashel Stonefist"] = 		{
				["So yeah... um... I might know something 'bout that meeting at Addle's Stead. Happened a few weeks back I think. I really didn't have any adventurers. The guy we got on the inside for plan B came out of Menethil; guy called Slim. That's all I know regarding their backup plan."] = 1247,
				["Yeah, you're obviously not the smartest $c to come into Stormwind, but you're about to be one of the dumbest to never leave. Have you met obviously not the smartest $c to come into Stormwind, but you're about to be one of the dumbest to never leave. Have you met me friends?"] = 1447
			},
			["Tapoke 'Slim' Jahn"] = 1250,
			["Mikhail"] = 		{
				["You say Elling sent you here? Well then, the hospitality I expressed is now tenfold. Anything you need, just ask. I will do my best if you catch my meaning? If I were you, I'd do what you can to subdue him before he makes a break for the door."] = 1249,
				["The beginning of every month the Kul Tiras Marines all get paid and usually leave Theramore for somewhere else. A lot of them come here you find him if Hendel's still stationed there. He's completely loyal to Proudmoore, but if you drop Elling's name, he should help you out... discreetly."] = 1264
			},
			["Commander Samaul"] = 1265,
			["Private Hendel"] = 1324,
			["Archmage Tervosh"] = 1266,
			["Thomas"] = 1274
		},
		["Infiltrating the Castle"] = 2745,
		["A Swift Message"] = 6181,
		["Return to Verner"] = 119,
		["Continue to Stormwind"] = 6281,
		["A Daughter's Love"] = 231,
		["CLUCK!"] = 3861,
		["Raven Hill"] = 163,
		["Deliveries to Sven"] = 164,
		["The Hermit"] = 165,
		["Oh Brother. . ."] = 167,
		["Collecting Memories"] = 168,
		["Dwarven Outfitters"] = 179,
		["Coldridge Valley Mail Delivery"] = 	{
			["Sten Stoutarm"] = 233,
			["Talin Keeneye"] = 234
		},
		["Simple Rune"] = 3106,
		["Consecrated Rune"] = 3107,
		["Etched Rune"] = 3108,
		["Encrypted Rune"] = 3109,
		["Hallowed Rune"] = 3110,
		["Simple Memorandum"] = 3112,
		["Encrypted Memorandum"] = 3113,
		["Glyphic Memorandum"] = 3114,
		["Tainted Memorandum"] = 3115,
		["The Scythe of Elune"] = 1043,
		["Answered Questions"] = 1044,
		["Worgen in the Woods"] = 	{
			["Calor"] = 		{
				["Darkness seems drawn inexorably to Duskwood. Master Carevin's quest is the expulsion of evil and heresy. Through our efforts are the people of Darkshire kept wish to prove yourself, it will not be through words. Test your skills against the Nightbane Shadow Weaver worgen in Brightwood Grove--bright, hah!--and the Rotting Orchard."] = 173,
				["You might have noticed some larger worgen wandering around with the Shadow Weavers in the woods? From what we can tell, these Dark Runners make noticed that they have overrun the Rotting Orchard southwest of town. These worgen are a bit tougher than the last you faced. Be on your guard."] = 221,
				["Your previous accomplishments have convinced me that you are ready to take on the toughest worgen infesting the woods. Of the worgen that have made their settled down near some of the caves and in the mine to the south. From far away you can even see the light from their bonfires..."] = 222,
				["Here you go, $n. Bring this message to Master Carevin. <He quickly removes a piece of faded parchment and offers it to you.> A few more like you.> A few more like you, and we will outnumber the Night Watch! Perhaps then we could complete the work that we few carry on today."] = 223
			}
		},
		["A New Threat"] = 170,
		["The Boar Hunter"] = 183,
		["Raptor Mastery"] = 	{
			["Hemet Nesingwary Jr."] = 		{
				["So you think your hunting skills are in tip-top shape? I can put them to the test in a jiffy. Head out into that jungle much of a big game hunter you are. And no, I won't tell you where you can find them! Locating the beasts is half the challenge."] = 194,
				["Now let's step up the challenge and see if you're up to it. Venture into the jungle and bag yourself 10 of those bloody Lashtail and see if you're up to it. Venture into the jungle and bag yourself 10 of those bloody Lashtail Raptors. Let's see what you've got!"] = 195,
				["Let's see how you handle this next challenge. There is a cagey breed of raptor out there. We call them Jungle Stalkers. They are far kill than the other breeds you've been trying your luck at. Kill 10 Jungle Stalkers and I'll tip you off to the best hunting yet."] = 196,
				["Because you proved yourself to be such a go-getter in the jungle, let me tell you about a ferocious raptor that even I have failed prove yourself a true master, kill Tethis and bring me his talon. It would be a feat that no other big game hunter has accomplished."] = 197
			}
		},
		["Big Game Hunter"] = 208,
		["The Green Hills of Stranglethorn"] = 338,
		["Chapter I"] = 339,
		["Chapter II"] = 340,
		["Chapter III"] = 341,
		["Chapter IV"] = 342,
		["Welcome to the Jungle"] = 583,
		["Tiger Mastery"] = 	{
			["Ajeck Rouack"] = 		{
				["When I was but a young girl, my father trained me in the art of tiger hunting. You'll find the young felines much easier to track easy. One can often find young tigers near the expedition camp. Test your tracking skills and see if you can hunt some of the beasts down."] = 185,
				["You are learning, $c. Let us test your skills with the mature cats now. Kill 10 Stranglethorn Tigers this time out. You are learning, $c. Let us test your skills with the mature cats now. Kill 10 Stranglethorn Tigers this time out."] = 186,
				["Now I'm going to up the stakes on you and truly test your skill. Prove to me you can kill 10 Elder Stranglethorn Tigers. If a master tiger hunter in Master Nesingwary's presence. Elder Stranglethorn Tigers are not only the most difficult to find, they are also the fiercest to defeat."] = 187,
				["Here is the final challenge that I will put forth. We've been tracking an elusive tiger for weeks. We call the beast Sin'Dall. See if $r has done before: hunt down and kill Sin'Dall. Bring me her paw as proof of your accomplishment. Tracking her down will be no easy task."] = 188
			}
		},
		["Panther Mastery"] = 	{
			["Sir S. J. Erlgadin"] = 		{
				["If you want to be a part of the hunt with this crack group under Hemet Jr.'s leadership, you're going to need to prove yourself We'll start you out easy -- don't you worry. Let's see you kill 10 young panthers to start. Tracking them down is only half the challenge..."] = 190,
				["Now you're ready to turn it up a notch. If you want to prove yourself worthy of socializing with the likes of these big game need to prove that you can kill 10 panthers. Those big boys are tougher. They're not as easy as the young ones you were killing earlier."] = 191,
				["Now the hard part. A true panther hunter can show skill by dropping Shadowmaw Panthers, the deadliest in Stranglethorn. Prove to us that you can Prove to us that you can slay 10 of these beasts. If you think they are hard to track, wait until you attempt to slay one...."] = 192,
				["You've almost proven yourself to be a master hunter of panthers. A panther by the name of Bhag'thera has been prowling the jungle. So far our party. See if you can use your skills to kill the great Bhag'thera. Bring me the Fang of Bhag'thera and you'll have earned my respect!"] = 193
			}
		},
		["The Second Rebellion"] = 203,
		["Bad Medicine"] = 204,
		["Special Forces"] = 574,
		["Bloodscalp Ears"] = 189,
		["Skullsplitter Tusks"] = 209,
		["Hostile Takeover"] = 213,
		["Jungle Secrets"] = 215,
		["Troll Witchery"] = 205,
		["Mai'Zoth"] = 206,
		["Kurzen's Mystery"] = 207,
		["Krazek's Cookery"] = 210,
		["Supplies to Private Thorsen"] = 198,
		["Investigate the Camp"] = 201,
		["The Haunted Isle"] = 616,
		["Return to Corporal Kaleb"] = 622,
		["Favor for Krazek"] = 627,
		["Dream Dust in the Swamp"] = 1116,
		["Rumors for Kravel"] = 1117,
		["Tran'rek"] = 2864,
		["The Troll Cave"] = 182,
		["The Stolen Journal"] = 218,
		["Senir's Observations"] = 	{
			["Grelin Whitebeard"] = 282,
			["Mountaineer Thalos"] = 420
		},
		["Red Silk Bandanas"] = 214,
		["Patrolling Westfall"] = 102,
		["Bounty on Garrick Padfoot"] = 6,
		["Brotherhood of Thieves"] = 18,
		["A Threat Within"] = 783,
		["Milly Osworth"] = 3903,
		["Eagan Peltskinner"] = 5261,
		["Bring Back the Mug"] = 3365,
		["What Comes Around..."] = 386,
		["Red Leather Bandanas"] = 153,
		["Eight-Legged Menaces"] = 245,
		["Wolves at Our Heels"] = 226,
		["The Hunter's Path"] = 	{
			["Thorgas Grimson"] = 		{
				["Hello, young hunter. You look to me like you are skilled enough to handle a beast and train it as your companion. You must see Dazalar and train it as your companion. You must see Dazalar in Dolanaar. He can put you on the path to earning a pet of your own."] = 6072,
				["Hello, young hunter. You look to me like you are skilled enough to handle a beast and train it as your companion. You must see Grif train it as your companion. You must see Grif Wildheart in Kharanos. He can put you on the path to earning a pet of your own."] = 6075
			},
			["Kary Thunderhorn"] = 		{
				["Hello, young hunter. You look to me like you are skilled enough to handle a beast and train it as your companion. You must see Yaw it as your companion. You must see Yaw Sharpmane in Bloodhoof Village. He can put you on the path to earning a pet of your own."] = 6066,
				["Hello, young hunter. You look to me like you are skilled enough to handle a beast and train it as your companion. You must see Thotar train it as your companion. You must see Thotar at Razor Hill. He can put you on the path to earning a pet of your own."] = 6068
			},
			["Lanka Farshot"] = 		{
				["Hello, young hunter. You look to me like you are skilled enough to handle a beast and train it as your companion. You must see Yaw it as your companion. You must see Yaw Sharpmane in Bloodhoof Village. He can put you on the path to earning a pet of your own."] = 6067,
				["Hello, young hunter. You look to me like you are skilled enough to handle a beast and train it as your companion. You must see Thotar train it as your companion. You must see Thotar at Razor Hill. He can put you on the path to earning a pet of your own."] = 6069
			},
			["Jen'shan"] = 		{
				["Hello, young hunter. You look to me like you are skilled enough to handle a beast and train it as your companion. You must see Yaw it as your companion. You must see Yaw Sharpmane in Bloodhoof Village. He can put you on the path to earning a pet of your own."] = 6067,
				["Hello, young hunter. You look to me like you are skilled enough to handle a beast and train it as your companion. You must see Thotar train it as your companion. You must see Thotar at Razor Hill. He can put you on the path to earning a pet of your own."] = 6069
			},
			["Thotar"] = 6065,
			["Sian'dur"] = 		{
				["Hello, young hunter. You look to me like you are skilled enough to handle a beast and train it as your companion. You must see Yaw it as your companion. You must see Yaw Sharpmane in Bloodhoof Village. He can put you on the path to earning a pet of your own."] = 6067,
				["Hello, young hunter. You look to me like you are skilled enough to handle a beast and train it as your companion. You must see Thotar train it as your companion. You must see Thotar at Razor Hill. He can put you on the path to earning a pet of your own."] = 6070
			},
			["Ayanna Everstride"] = 		{
				["Hello, young hunter. You look to me like you are skilled enough to handle a beast and train it as your companion. You must see Dazalar and train it as your companion. You must see Dazalar in Dolanaar. He can put you on the path to earning a pet of your own."] = 6071,
				["Hello, young hunter. You look to me like you are skilled enough to handle a beast and train it as your companion. You must see Grif train it as your companion. You must see Grif Wildheart in Kharanos. He can put you on the path to earning a pet of your own."] = 6074
			},
			["Jocaste"] = 		{
				["Hello, young hunter. You look to me like you are skilled enough to handle a beast and train it as your companion. You must see Dazalar and train it as your companion. You must see Dazalar in Dolanaar. He can put you on the path to earning a pet of your own."] = 6071,
				["Hello, young hunter. You look to me like you are skilled enough to handle a beast and train it as your companion. You must see Grif train it as your companion. You must see Grif Wildheart in Kharanos. He can put you on the path to earning a pet of your own."] = 6074
			},
			["Dorion"] = 		{
				["Hello, young hunter. You look to me like you are skilled enough to handle a beast and train it as your companion. You must see Dazalar and train it as your companion. You must see Dazalar in Dolanaar. He can put you on the path to earning a pet of your own."] = 6071,
				["Hello, young hunter. You look to me like you are skilled enough to handle a beast and train it as your companion. You must see Grif train it as your companion. You must see Grif Wildheart in Kharanos. He can put you on the path to earning a pet of your own."] = 6074
			},
			["Regnus Thundergranite"] = 		{
				["Hello, young hunter. You look to me like you are skilled enough to handle a beast and train it as your companion. You must see Dazalar and train it as your companion. You must see Dazalar in Dolanaar. He can put you on the path to earning a pet of your own."] = 6072,
				["Hello, young hunter. You look to me like you are skilled enough to handle a beast and train it as your companion. You must see Grif train it as your companion. You must see Grif Wildheart in Kharanos. He can put you on the path to earning a pet of your own."] = 6074,
				["Hello, young hunter. You look to me like you are skilled enough to handle a beast and train it as your companion. You must see Dazalar and train it as your companion. You must see Dazalar in Dolanaar. He can put you on the path to earning a pet of your own. "] = 6721
			},
			["Einris Brightspear"] = 		{
				["Hello, young hunter. You look to me like you are skilled enough to handle a beast and train it as your companion. You must see Dazalar and train it as your companion. You must see Dazalar in Dolanaar. He can put you on the path to earning a pet of your own."] = 6722,
				["Hello, young hunter. You look to me like you are skilled enough to handle a beast and train it as your companion. You must see Grif train it as your companion. You must see Grif Wildheart in Kharanos. He can put you on the path to earning a pet of your own."] = 6076
			},
			["Tristane Shadowstone"] = 		{
				["Hello, young hunter. You look to me like you are skilled enough to handle a beast and train it as your companion. You must see Dazalar and train it as your companion. You must see Dazalar in Dolanaar. He can put you on the path to earning a pet of your own."] = 6072,
				["Hello, young hunter. You look to me like you are skilled enough to handle a beast and train it as your companion. You must see Grif train it as your companion. You must see Grif Wildheart in Kharanos. He can put you on the path to earning a pet of your own."] = 6075
			},
			["Telenus"] = 		{
				["Hello, young hunter. You look to me like you are skilled enough to handle a beast and train it as your companion. You must see Yaw it as your companion. You must see Yaw Sharpmane in Bloodhoof Village. He can put you on the path to earning a pet of your own."] = 6067,
				["Hello, young hunter. You look to me like you are skilled enough to handle a beast and train it as your companion. You must see Thotar train it as your companion. You must see Thotar at Razor Hill. He can put you on the path to earning a pet of your own."] = 6069
			},
			["Deremiis"] = 		{
				["Hello, young hunter. You look to me like you are skilled enough to handle a beast and train it as your companion. You must see Dazalar and train it as your companion. You must see Dazalar in Dolanaar. He can put you on the path to earning a pet of your own."] = 6073,
				["Hello, young hunter. You look to me like you are skilled enough to handle a beast and train it as your companion. You must see Grif train it as your companion. You must see Grif Wildheart in Kharanos. He can put you on the path to earning a pet of your own."] = 6074
			},
			["Acteon"] = 		{
				["Hello, young hunter. You look to me like you are skilled enough to handle a beast and train it as your companion. You must see Dazalar and train it as your companion. You must see Dazalar in Dolanaar. He can put you on the path to earning a pet of your own."] = 6073,
				["Hello, young hunter. You look to me like you are skilled enough to handle a beast and train it as your companion. You must see Grif train it as your companion. You must see Grif Wildheart in Kharanos. He can put you on the path to earning a pet of your own."] = 6074
			}
		},
		["Solomon's Law"] = 91,
		["Blackrock Bounty"] = 128,
		["A Warrior's Training"] = 	{
			["Lyria Du Lac"] = 1638,
			["Ilsa Corbin"] = 1638
		},
		["Seek out SI: 7"] = 2205,
		["SI:7"] = 2300,
		["A Simple Request"] = 	{
			["Osborne the Night Man"] = 8233,
			["Ormok"] = 8233,
			["Anishar"] = 8233,
			["Miles Dexter"] = 8233,
			["Ormyr Flinteye"] = 8233,
			["Fenthwick"] = 8233,
			["Lord Tony Romano"] = 8233,
			["Elara"] = 8233
		},
		["Tome of Divinity"] = 	{
			["Brother Wilhelm"] = 2998,
			["Lord Grayson Shadowbreaker"] = 3000,
			["Azar Stronghammer"] = 2997,
			["Brandur Ironhammer"] = 		{
				["Hello, $N. I know you're busy helping out the people of Dun Morogh, but when you have the time, you should go upstairs and speak ilk: Tiza Battleforge. She's the one the younger paladins go to when it's time they learn more about the Light and what's expected of ya."] = 2999,
				["Sorry to interrupt your travels, $r, but I thought you should know that word was sent from Stormwind recently asking that paladins report there for a special time and it's time you started studying the Tomes. Look for Duthorian Rall in Stormwind. He usually trains paladins in the Cathedral of Light."] = 3681
			}
		},
		["Emphasis on Sacrifice"] = 7637,
		["Exorcising Terrordale"] = 7640,
		["The Work of Grimand Elmore"] = 7641,
		["Ancient Equine Spirit"] = 7643,
		["The Divination Scryer"] = 7646,
		["Judgment and Redemption"] = 7647,
		["Chillwind Camp"] = 8415,
		["Ink Supplies"] = 345,
		["Return to Kristoff"] = 346,
		["Riverpaw Gnoll Bounty"] = 11,
		["Elemental Mastery"] = 	{
			["Haromm"] = 8410,
			["Siln Skychaser"] = 8410,
			["Tigor Skychaser"] = 8410,
			["Beram Skychaser"] = 8410,
			["Kardris Dreamseeker"] = 8410,
			["Sian'tsu"] = 8410,
			["Sagorne Creststrider"] = 8410,
			["Sulaa"] = 8410,
			["Hobahken"] = 8410,
			["Gurrag"] = 8410,
			["Farseer Umbrua"] = 8410,
			["Farseer Javad"] = 8410
		},
		["Broken Alliances"] = 	{
			["Gorn"] = 		{
				["From the Horde's alliance with the dragon Deathwing during the Second War, we know that two of his lieutenants, Blacklash and Hematus, were imprisoned within needed to unlock the drakes' prison. Tho'grun betrayed us though, overwhelming us and taking it for himself. Go to Camp Boff and take it back!"] = 782,
				["The Seal of the Earth is held by three runestones, held in the Pillars of Diamond, Opal, and Amethyst in Lethlor Ravine. Using the Sign to me. To reach the ravine, travel to the far eastern part of the Badlands. Be careful though, for the ravine is home to countless drakes."] = 793
			}
		},
		["Assessing the Threat"] = 246,
		["A Grim Task"] = 304,
		["A Dark Threat Looms"] = 	{
			["Ashlan Stonesmirk"] = 274,
			["Chief Engineer Hinderweir VII"] = 		{
				["If my suspicions are correct, this is some type of explosive powder. This must be analyzed by an explosives expert so we know just what Gate, follow the road through the Wetlands and seek out Stonesmirk in Dun Modr. Heed my advice: stick to the roads and stop for nothing!"] = 161,
				["Thank the stars someone is concerned about the well-being of the Dam. First the destruction of the Thandol Span and then the pillaging of Dun need you, $N. I spotted some Dark Iron Sappers milling about the eastern ramp of the Dam. Investigate the area and bring back a clue."] = 250,
				["Begin collecting the disarming materials immediately, $N. Lurker Venom can be found on the indigenous spiders in Loch Modan. Crocolisk tears are found here in need to be prepared to defuse a Dark Iron attack! Return to me once you've collected the needed items and I will prepare the mixture."] = 278,
				["Earlier today I spotted some Dark Iron Insurgents swimming toward the Dam with a large keg. No Mountaineers were on hand to stop them! I'm into the Disarming Mixture. There we go. Now I need you to take this mixture and stir it into the keg before it's too late! Hurry!"] = 280
			},
			["Suspicious Barrel"] = 199,
			["Explosive Charge"] = 283
		},
		["The Dark Iron War"] = 303,
		["The Fury Runs Deep"] = 378,
		["The Thandol Span"] = 	{
			["Rhag Garmason"] = 		{
				["A tremendous explosion roared through the hills. 'Twas horrible, I tell you! Good soldiers died defending the Thandol Span. Longbraid says we'll take revenge on the if we could secure it. That was days ago. We haven't the manpower to search for him with Dun Modr under siege. Perhaps you can find him..."] = 631,
				["Heavens no! Poor Rustlocke. 'Tis quite a tragedy indeed. We must not let his death pass in vain. This parchment you discovered indicates that Kam Deepfury, supply line to the north will be severed! The cache must be destroyed, $n! Return to me when your mission is complete. You're our only hope."] = 633
			},
			["Ebenezer Rustlocke's Corpse"] = 632
		},
		["Plea To The Alliance"] = 634,
		["In Search of The Excavation Team"] = 	{
			["Merrin Rockweaver"] = 306,
			["Tarrel Rockweaver"] = 305
		},
		["Uncovering the Past"] = 299,
		["Ormer's Revenge"] = 	{
			["Ormer Ironbraid"] = 		{
				["The situation is severe, that much is for sure. When we uncovered these bones it attracted the Raptors. These filthy beasts killed my brethren and West of the bluff there. Kill 10 of each, if you can. That will be a good start to the vengeance I have planned for them."] = 294,
				["Now it's time to really make those dreaded Raptors regret their blood-thirst. Just down below there are scores of Mottled Scytheclaws and Mottled Razormaws. Make regret their blood-thirst. Just down below there are scores of Mottled Scytheclaws and Mottled Razormaws. Make those rotten creatures pay by slaying 10 of each!"] = 295,
				["While you were down there I happened to notice that one of those beasts stood out from the rest. He was bigger and more menacing. justice. And considering the gravity of his crimes, justice in this case means death! Bring me one of his talons as proof of his death."] = 296
			}
		},
		["In Defense of the King's Lands"] = 	{
			["Mountaineer Cobbleflint"] = 224,
			["Mountaineer Wallbang"] = 263,
			["Mountaineer Gravelgaw"] = 237,
			["Captain Rugelfuss"] = 217
		},
		["The Trogg Threat"] = 267,
		["Resupplying the Excavation"] = 273,
		["Report to Ironforge"] = 301,
		["Ironband's Excavation"] = 436,
		["Mercenaries"] = 255,
		["A Meal Served Cold"] = 212,
		["Morgan Stern"] = 1260,
		["Crocolisk Hunting"] = 385,
		["Vyrin's Revenge"] = 	{
			["Vyrin Swiftwind"] = 271,
			["Daryl the Youngling"] = 531
		},
		["Down the Scarlet Path"] = 	{
			["Brother Anton"] = 		{
				["I will be frank. We are at war with the Scourge. It is an evil that corrupts our people and infects our land. It must courage and prove your allegiance--destroy the undead ravagers of Desolace, in the Valley of Bones to the south. Do this, and the Crusade will embrace you."] = 261,
				["We of the Scarlet Crusade lay claim to strongholds from Hearthglen to Tirisfal Glades. We are quite proud of our bastions of cleansing throughout Lordaeron. You the Devout. Give him this letter of commendation bearing my seal and he will escort you to a place of honor in our Scarlet Monastery."] = 1052
			}
		},
		["A Hunter's Boast"] = 257,
		["A Hunter's Challenge"] = 258,
		["The Doomed Fleet"] = 270,
		["Cleansing the Eye"] = 293,
		["Lightforge Iron"] = 321,
		["Blessed Arm"] = 322,
		["Lightforge Ingots"] = 526,
		["Speak with Bink"] = 1879,
		["Muren Stormpike"] = 1679,
		["Taming the Beast"] = 	{
			["Grif Wildheart"] = 		{
				["Hi there, $Glad:lass;! So, you'd be wanting to know how you can gain a pet of your own? Well, let's get started. There's nothing more important try out several creatures as companions and see what ya like. So, find a large crag boar, then use the taming rod to tame it."] = 6064,
				["Those crag boars are quite burly; maybe you'd like something with a little more finesse? Alright then, I've got jus' the thing. South and east find them to be much more agile an' swift than the boar you tamed. Take this taming rod and see how you like the snow leopard."] = 6084,
				["Perhaps you'd like a creature that possesses little more than brute strength. The ice claw bear is an excellent companion for a fledgling hunter like face the challenges you face, and gain experience alongside you. I will also show you how to call it and dismiss it as ya like. "] = 6085
			},
			["Yaw Sharpmane"] = 		{
				["As a tauren, it is important to follow the traditions of our ancestors by fighting mighty creatures. By besting these creatures, we are able to your choosing. But all things take practice, and you have much to learn. Begin by taking this taming rod; you must tame an adult plainstrider."] = 6061,
				["You have a fiery spirit, hunter, readily awaiting your next challenge. Your next task is to gain the companionship of a wolf known as the prairie team. In the end you must work as one, muscle to muscle. Here is the taming rod, $N. Tame a prairie stalker and practice your skills."] = 6087,
				["The final task that I have for you requires that you tame a creature that inhabits the sky. The swoop is a difficult opponent, but face the challenges you face, and gain experience alongside you. I will also show you how to call it and dismiss it as you wish. "] = 6088
			},
			["Thotar"] = 		{
				["It is an admirable skill to command one's authority over nature. As a hunter, you must strive to learn to use the force and power boar. You can find them quite close to Razor Hill. Practice your skills in battle with the boar at your side, then return to me."] = 6062,
				["The final creature you need to tame is one you should strive to emulate; the armored scorpid. It strikes quickly and confidently; to control a Under your control, your pet will gain experience alongside you. I will also show you how to call it and dismiss it as you wish. "] = 6082,
				["The advantage a pet affords you against your rivals is duly noted, $N. When you gain control over another creature, you are adding to your Village, near the Echo Isles. look for a spirited crab called the surf crawler. Use the taming rod to tame it, then practice your skills."] = 6083
			},
			["Dazalar"] = 		{
				["As a hunter, it is important to remember the responsibility you hold in your hands. Nature is not a power that can be bent to to take this taming rod. With it, you will be able to tame a webwood lurker. Tame it, and practice your skills as a hunter."] = 6063,
				["The variance of nature is something that can be relied upon, $N. It is predictable in the way that it never remains the same; it a nightsaber stalker, found to the south. Practice your skills as a hunter. Then you will begin to understand the similarities and differences of nature."] = 6101,
				["You have tamed two creatures that inhabit the land, now you must tame one that soars the skies. Use the taming rod to tame a face the challenges you face, and gain experience alongside you. I will also show you how to call it and dismiss it as you wish."] = 6102
			}
		},
		["Training the Beast"] = 	{
			["Grif Wildheart"] = 6086,
			["Yaw Sharpmane"] = 6089,
			["Thotar"] = 6081,
			["Dazalar"] = 6103
		},
		["Road to Salvation"] = 2218,
		["To Hulfdan!"] = 2299,
		["The Third Fleet"] = 288,
		["The Cursed Crew"] = 289,
		["Lifting the Curse"] = 290,
		["The Greenwarden"] = 463,
		["Claws from the Deep"] = 279,
		["Reclaiming Goods"] = 281,
		["Blisters on The Land"] = 275,
		["Tramping Paws"] = 276,
		["Fire Taboo"] = 277,
		["Frostmane Hold"] = 287,
		["The Reports"] = 291,
		["Those Blasted Troggs!"] = 432,
		["Protecting the Herd"] = 314,
		["Tundra MacGrann's Stolen Stash"] = 312,
		["Beer Basted Boar Ribs"] = 384,
		["Hurley Blackbreath"] = 4126,
		["Gnogaine"] = 2926,
		["The Only Cure is More Green Glow"] = 2962,
		["Operation Recombobulation"] = 412,
		["Bring the Light"] = 3636,
		["Dungar Longdrink"] = 6261,
		["Rat Catching"] = 416,
		["Stonegear's Search"] = 467,
		["Report to Mountaineer Rockgar"] = 468,
		["Mountaineer Stormpike's Task"] = 1339,
		["The Algaz Gauntlet"] = 455,
		["Filthy Paws"] = 307,
		["Stormpike's Order"] = 1338,
		["Excavation Progress Report"] = 298,
		["Agmond's Fate"] = 704,
		["Find Agmond"] = 738,
		["Gathering Idols"] = 297,
		["Powder to Ironband"] = 302,
		["Further Mysteries"] = 525,
		["Ironband Wants You!"] = 707,
		["The Lost Dwarves"] = 2398,
		["The Reason for the Season"] = 	{
			["Goli Krumn"] = 7062,
			["Furmund"] = 6964
		},
		["The Perfect Stout"] = 315,
		["A Favor for Evershine"] = 319,
		["Return to Bellowfiz"] = 320,
		["Shimmer Stout"] = 413,
		["Bitter Rivals"] = 310,
		["The Grizzled Den"] = 313,
		["Search for Incendicite"] = 466,
		["Stocking Jetsteam"] = 317,
		["Evershine"] = 318,
		["Protecting the Shipment"] = 309,
		["Armed and Ready"] = 325,
		["Stormpike's Delivery"] = 353,
		["Burning Blood"] = 1705,
		["Collection of Goods"] = 7642,
		["Grimand's Finest Work"] = 7648,
		["Report to Doren"] = 331,
		["Harlan Needs a Resupply"] = 333,
		["Package for Thurman"] = 334,
		["Wine Shop Advert"] = 332,
		["A Noble Brew"] = 	{
			["Zardeth of the Black Claw"] = 		{
				["Lord Wishock is causing quite a stir amongst the House of Nobles. He was made aware of our little 'establishment' down here and is lobbying Tilloa. I will also need a Musquash Root, found only at the very base of the falls far beneath the Stonewrought Dam in the Wetlands."] = 335,
				["Lord Wishock, like all men, has his weaknesses. His happens to be a fondness for liquor. The hypocrisy is astounding. The trite fool spends his quite a kick, $n. Take it to him and see how he likes it. Most likely the old fool is milling about the Hall of Petitioners."] = 336
			}
		},
		["You Have Served Us Well"] = 397,
		["Brother Paxton"] = 344,
		["Southshore"] = 538,
		["Neeka Bloodscar"] = 1418,
		["Pool of Tears"] = 1424,
		["The Atal'ai Exile"] = 1429,
		["The Temple of Atal'Hakkar"] = 1445,
		["Speaking of Fortitude"] = 343,
		["Uldaman Reagent Run"] = 	{
			["Ghak Healtouch"] = 17,
			["Jarkal Mossmeld"] = 2202
		},
		["Badlands Reagent Run"] = 	{
			["Ghak Healtouch"] = 2500,
			["Jarkal Mossmeld"] = 2258
		},
		["Badlands Reagent Run II"] = 	{
			["Ghak Healtouch"] = 2501,
			["Jarkal Mossmeld"] = 2203
		},
		["Rear Guard Patrol"] = 356,
		["Return to the Magistrate"] = 360,
		["A Putrid Task"] = 404,
		["The Mills Overrun"] = 426,
		["Ulag the Cleaver"] = 1819,
		["Speak with Coleman"] = 1820,
		["Proving Allegiance"] = 409,
		["The Prodigal Lich Returns"] = 411,
		["The Lich's Identity"] = 357,
		["Return the Book"] = 366,
		["Thule Ravenclaw"] = 446,
		["Graverobbers"] = 358,
		["Forsaken Duties"] = 359,
		["The Prodigal Lich"] = 405,
		["The Family Crypt"] = 408,
		["Raleigh and the Undercity"] = 441,
		["Deaths in the Family"] = 354,
		["Speak with Sevren"] = 355,
		["The Haunted Mills"] = 362,
		["Agamand Heirlooms"] = 1821,
		["At War With The Scarlet Crusade"] = 	{
			["Executor Zygand"] = 		{
				["The strategic documents from Executor Arren contain all the details we need to wipe the human infestation from the lands. According to the information, The Captain Perrine and a brigade to the ruined tower southwest of Brill. Kill Perrine along with 3 Zealots and 3 Missionaries and report back to me."] = 370,
				["We are still at war and the Scarlet Crusade grows in strength. The report Executor Arren sent me indicates Scarlet Crusaders have been raiding from Balnir Farmstead under the command of Captain Vachon. Kill Vachon along with 5 Scarlet Friars. It should prove to be a devastating blow to the Crusade!"] = 371,
				["Scarlet Crusaders have been raiding from the ruined tower in northern Tirisfal, past Faol's Rest. According to the information we have, a ruthless commander named evil crew. I am entrusting you now with a special and dangerous mission. Slay Melrache and his two bodyguards, in the name of The Dark Lady."] = 372,
				["The documents Executor Arren provided are just the break we needed in our battle with the wretched Scarlet Crusade. We now know their exact locations to me you are capable of serving The Dark Lady by travelling west to the tower past the Solliden Farmstead and slay 10 Scarlet Warriors."] = 427
			}
		},
		["A New Plague"] = 	{
			["Apothecary Johaan"] = 		{
				["Lady Sylvanas has called upon the Royal Apothecary Society. The Dark Lady believes our knowledge coupled with the newfound magic will provide the key to that the blood of beasts might prove to be the key. Bring to me 5 vials of darkhound blood so I can test my theory."] = 367,
				["While you were collecting samples for me, my experiments led me to realize that more reagents will be required for this new disease to spread need 5 Vile Fin Scales from Murlocs in the vicinity. You will find the creatures along the coast to the north or to the west."] = 368,
				["While you were out gathering, I uncovered some old text in one of my tomes that indicates that an ancient plague wiped out thousands of if the contagious element from the venom will work with my new concoction. Rumor has it the spiders can be found in Eastern Tirisfal Glades."] = 369,
				["According to the Deathguard, another one of those foolish Dwarven Mountaineers has just been captured. The Deathguard likes to use the cellar of the Gallows enjoys this special drink I made for him? It contains a subtle hint of what The Dark Lady has planned for the rest of Azeroth."] = 492
			}
		},
		["Fields of Grief"] = 	{
			["Apothecary Johaan"] = 407,
			["Deathguard Simmer"] = 365
		},
		["Delivery to Silverpine Forest"] = 445,
		["The Chill of Death"] = 375,
		["Rude Awakening"] = 363,
		["The Mindless Ones"] = 364,
		["Simple Scroll"] = 3095,
		["Encrypted Scroll"] = 3096,
		["Hallowed Scroll"] = 3097,
		["Glyphic Scroll"] = 3098,
		["Tainted Scroll"] = 3099,
		["Rattling the Rattlecages"] = 3901,
		["Night Web's Hollow"] = 380,
		["The Scarlet Crusade"] = 381,
		["The Red Messenger"] = 382,
		["Vital Intelligence"] = 383,
		["Ride to Ironforge"] = 6391,
		["Return to Brock"] = 6392,
		["Bazil Thredd"] = 389,
		["Shadow of the Past"] = 393,
		["An Audience with the King"] = 	{
			["Baros Alexston"] = 396,
			["King Varian Wrynn"] = 396
		},
		["Humble Beginnings"] = 399,
		["Proof of Demise"] = 374,
		["The Damned"] = 376,
		["Marla's Last Wish"] = 6395,
		["Honor Students"] = 6387,
		["Ammo for Rumbleshot"] = 5541,
		["Quell The Uprising"] = 387,
		["The Stockade Riots"] = 391,
		["The Curious Visitor"] = 392,
		["The Color of Blood"] = 388,
		["Scavenging Deathknell"] = 3902,
		["The First and the Last"] = 6182,
		["The Lord of Blackrock"] = 	{
			["Highlord Bolvar Fordragon"] = 7782,
			["Thrall"] = 7784,
			["King Varian Wrynn"] = 7782,
			["Head of Nefarian"] = 		{
				["The old feeling returns. The welcome pangs of victory reverberate throughout your being. Before you lies the monolithic, battle scarred head of Nefarian. Return it The welcome pangs of victory reverberate throughout your being. Before you lies the monolithic, battle scarred head of Nefarian. Return it to your Warchief, champion."] = 7783,
				["The old feeling returns. The welcome pangs of victory reverberate throughout your being. Before you lies the monolithic, battle scarred head of Nefarian. Return it welcome pangs of victory reverberate throughout your being. Before you lies the monolithic, battle scarred head of Nefarian. Return it to King Varian Wrynn, champion."] = 7781
			}
		},
		["Draenethyst Crystals"] = 1389,
		["In Dreams"] = 5944,
		["Inert Scourgestones"] = 8416,
		["Demon Dogs"] = 5542,
		["Blood Tinged Skies"] = 5543,
		["Carrion Grubbage"] = 5544,
		["Redemption"] = 5742,
		["Of Forgotten Memories"] = 5781,
		["Of Lost Honor"] = 5845,
		["Of Love and Family"] = 	{
			["Tirion Fordring"] = 5846,
			["Artist Renfray"] = 5848
		},
		["Find Myranda"] = 5861,
		["Tools for Steelgrill"] = 400,
		["Rejold's New Brew"] = 415,
		["Return to Quinn"] = 430,
		["Rot Hide Origins"] = 444,
		["A Recipe For Death"] = 	{
			["Apothecary Renferrel"] = 		{
				["Arthas's numbers are overwhelming. But with a New Plague we could eradicate both the Scourge Army and the Human infestation once and for all. My studies the northwest and from the bears wandering throughout Silverpine Forest. Deliver the reagents to Master Apothecary Faranell of the Royal Apothecary Society in the Undercity."] = 447,
				["According to Berard's Journal the moss from Lake Skulkers and Creepers might prove useful for our quest to brew a new plague. Those beasts dwell able to obtain one. Collect samples of the moss as well as the rare hardened tumor and take them to Master Apothecary Faranell in the Undercity."] = 451
			},
			["Master Apothecary Faranell"] = 450
		},
		["Report to Hadrec"] = 448,
		["Journey to Hillsbrad Foothills"] = 493,
		["Zinge's Delivery"] = 1359,
		["Arugal's Folly"] = 	{
			["Dalar Dawnweaver"] = 		{
				["As my understanding of Arugal's magic grows so does my disdain for the hapless fool. I am close to completing my research on his so townsfolk turn into Moonrage Worgen. I need to draw energy from the enchanted shackles Arugal cast on them. Bring to me six enchanted Pyrewood Shackles, $N."] = 99,
				["How Arugal gained acceptance within the Kirin Tor is beyond me. His spell-casting knowledge seemed as transparent as a blown glass bauble. What's important now is One of the Deathstalkers reported seeing some spellbooks but could not secure them. Retrieve for me the spell labeled Remedy of Arugal from those books."] = 422,
				["After examining Arugal's work my worst suspicions were confirmed. The old hack was not qualified to clean chamber pots in Dalaran let alone represent the Moonrage Darksouls until you have collected enough of their enchanted shackles for my research. The foul creatures have been seen to the north and east."] = 423,
				["It will indeed take me longer than I had thought to uncover the dark secrets behind the enchantments Arugal was using. But in the meantime I resource for Varimathras's advance. I want you to behead the tainted foreman of the mine, Grimson the Pale. With his death, the mine shall be ours."] = 424
			}
		},
		["Prove Your Worth"] = 421,
		["Dalaran's Intentions"] = 482,
		["Arugal Must Die"] = 1014,
		["Ivar the Foul"] = 425,
		["Wild Hearts"] = 429,
		["The Deathstalkers' Report"] = 449,
		["Lost Deathstalkers"] = 428,
		["The Dead Fields"] = 437,
		["The Decrepit Ferry"] = 438,
		["The Engraved Ring"] = 440,
		["Assault on Fenris Isle"] = 442,
		["Rot Hide Ichor"] = 443,
		["Deathstalkers in Shadowfang"] = 1098,
		["Speak with Renferrel"] = 3221,
		["Stout to Kadrell"] = 414,
		["The Lost Pilot"] = 419,
		["Thelsamar Blood Sausages"] = 418,
		["The Public Servant"] = 433,
		["Escorting Erland"] = 435,
		["The Woodland Protector"] = 	{
			["Tarindrella"] = 459,
			["Melithar Staghelm"] = 458
		},
		["A Husband's Revenge"] = 530,
		["Elixir of Agony"] = 	{
			["Master Apothecary Faranell"] = 515,
			["Apothecary Lydon"] = 		{
				["Another day, another elixir to be made. If it were up to me, I'd just let the pathetic humans and Scourge fight it out. They Stead, south of Tarren Mill and east of the river and Southshore. Collect for me 6 Mudsnout Blossoms from the field for my next elixir."] = 509,
				["Just when I thought another day was going to pass devoid of any joy, you brought me those marvelous Mudsnout Blossoms. First I will mix them it and then we'll be ready for some good fun indeed! Here, take this Mudsnout Composite and run it off to Master Faranell at once, $N."] = 513,
				["This new elixir is finally ready to be tested. But why let a perfectly good, highly contagious plague go to waste on a mere frog dwarves skitter about. Steal me a keg of their Shindigger Stout. Once I have that keg, you and I will have quite the party, $N."] = 517,
				["Next door the Deathguards are holding a few captured farmers hostage. High Executor Darthalia suspected one of the military strategists from Stormwind to be hiding we threw those farmers a party. Sounds like a grand ol' time! Place this tainted keg on the rug in their room. Plagued brew for all!"] = 524
			}
		},
		["Going, Going, Guano!"] = 1109,
		["Hearts of Zeal"] = 1113,
		["After the Ambush"] = 454,
		["Pyrewood Ambush"] = 452,
		["A Troubling Breeze"] = 475,
		["The Relics of Wakening"] = 483,
		["Ursal the Mauler"] = 486,
		["The Balance of Nature"] = 	{
			["Conservator Ilthalaine"] = 		{
				["Greetings, $N. I am Conservator Ilthalaine. My purpose in Shadowglen is to ensure that the balance of nature is maintained. The spring rains were particularly heavy produce so much food for the beasts. Journey forth, young $c, and thin the boar and saber populations so that nature's harmony will be preserved."] = 456,
				["Thinning the younger population of creatures here in Shadowglen was a good start, $N, but there is still work to be done. The resources of the for the good of all who share the land. Venture into the forest and slay mangy nightsabers and thistle boars in the name of balance."] = 457
			}
		},
		["Simple Sigil"] = 3116,
		["Etched Sigil"] = 3117,
		["Encrypted Sigil"] = 3118,
		["Hallowed Sigil"] = 3119,
		["Verdant Sigil"] = 3120,
		["Timberling Seeds"] = 918,
		["Timberling Sprouts"] = 919,
		["Rellian Greenspyre"] = 922,
		["Planting the Heart"] = 941,
		["Oakenscowl"] = 2499,
		["Seek Redemption!"] = 	{
			["Sentinel Kyra Starsong"] = 489,
			["Syral Bladeleaf"] = 489,
			["Moon Priestess Amara"] = 489,
			["Sentinel Shayla Nightbreeze"] = 489
		},
		["Webwood Venom"] = 916,
		["Webwood Egg"] = 917,
		["Tenaron's Summons"] = 920,
		["Denalan's Earth"] = 997,
		["Elixirs for the Bladeleafs"] = 1581,
		["Report to Captain Stoutfist"] = 473,
		["The Brassbolts Brothers"] = 	{
			["Pilot Longbeard"] = 1179,
			["Klockmort Spannerspan"] = 2769
		},
		["Daily Delivery"] = 469,
		["Apprentice's Duties"] = 471,
		["Young Crocolisk Skins"] = 484,
		["Fall of Dun Modr"] = 472,
		["War Banners"] = 464,
		["Nek'rosh's Gambit"] = 465,
		["Gnarlpine Corruption"] = 476,
		["Digging Through the Ooze"] = 470,
		["Border Crossings"] = 477,
		["Ambermill Investigations"] = 479,
		["The Weaver"] = 480,
		["Dalar's Analysis"] = 481,
		["Beren's Peril"] = 516,
		["In Favor of Darkness"] = 5651,
		["Speak with Anastasia"] = 1881,
		["Report to Anastasia"] = 	{
			["Cain Firesong"] = 1959,
			["Thurston Xane"] = 1959,
			["Un'Thuwa"] = 1959,
			["Uthel'nay"] = 1959
		},
		["Garments of Darkness"] = 5650,
		["Mennet Carkad"] = 1885,
		["Speak with Dillinger"] = 	{
			["Austil de Mon"] = 1818,
			["Baltus Fowler"] = 1818
		},
		["Zenn's Bidding"] = 488,
		["The Road to Darnassus"] = 487,
		["Elanaria"] = 	{
			["Moon Priestess Amara"] = 1684,
			["Kyra Windblade"] = 1684
		},
		["The New Frontier"] = 	{
			["Crier Goodman"] = 1015,
			["Arch Druid Fandral Staghelm"] = 6761,
			["Courier Hammerfall"] = 1019,
			["Herald Moonstalker"] = 1047,
			["Harbinger Balthazad"] = 1004,
			["Warcaller Gorlach"] = 1018,
			["Bluff Runner Windstrider"] = 1000
		},
		["A Call to Arms: The Plaguelands!"] = 	{
			["Crier Goodman"] = 5066,
			["Courier Hammerfall"] = 5090,
			["Herald Moonstalker"] = 5091,
			["Harbinger Balthazad"] = 5094,
			["Warcaller Gorlach"] = 5093,
			["Bluff Runner Windstrider"] = 5095
		},
		["Feathermoon Stronghold"] = 	{
			["Crier Goodman"] = 7494,
			["Courier Hammerfall"] = 7494,
			["Herald Moonstalker"] = 7494,
			["Herald Bran'daan"] = 7494
		},
		["Time To Strike"] = 494,
		["Battle of Hillsbrad"] = 	{
			["High Executor Darthalia"] = 		{
				["Stand at attention while addressing me, $c. I am under direct command of Varimathras. We are to quell the human infestation until our apothecaries can develop supply and infrastructure. Travel west. Raid the northernmost farms of Hillsbrad Fields. Make sure that the landowners, Farmer Ray and Farmer Getz, are executed as well."] = 527,
				["Word of the attack on the northern farms has the townsfolk panicked. Most excellent. Our Deathstalkers report peasants fleeing to the fields in southern Hillsbrad. The doom. Prove them wrong, $N. Return to Hillsbrad Fields and seek out the cowering peasants. Lay waste to them in the name of our Dark Lady. Dismissed!"] = 528,
				["The humans of Hillsbrad have been putting up unexpected resistance. The problem appears to be that the townsfolk are being armed by the local blacksmith. shipment of iron from their stockpile. The supplies will come in handy when we are done with the conquering of Hillsbrad and begin razing Southshore."] = 529,
				["The town of Hillsbrad is in disarray and we believe it will soon fall. We must, however, persist in our ruthlessness until the human scum as well as the town council. Destroy their revered political document as well, the Hillsbrad Proclamation. And while you're at it, steal the town registry."] = 532,
				["The Hillsbrad Town Registry indicates that the Azurelode Mine is under Alliance control. Furthermore, the mine is a prime source of iron ore for the and slay the foreman, a human by the name of Bonds. Kill his miners as well. That should send a clear message to the Alliance."] = 539,
				["Dwarves aiding the humans? Damn those filthy little beasts. We shall test the strength of the so-called Alliance. We'll see how anxious those little ankle-bashers are Thoradin's Wall called Dun Garok. The final mission of this battle is to lay siege on Dun Garok, $c. Captain Ironhill, their leader, must die."] = 541
			}
		},
		["Elixir of Suffering"] = 	{
			["Apothecary Lydon"] = 		{
				["Ah, another wretched day in Tarren Mill. All of this clean air puts me in such a foul mood, $N. The sooner we can plague the 10 Gray Bear Tongues and the very rare and hard to find, Creeper Ichor. You'll find both bears and creepers just outside of Tarren Mill."] = 496,
				["It will take but a moment for me to mix these components into what I have deemed an Elixir of Suffering. There we go! Ah, nothing little potion has achieved its desired effect. Give my assistant Umpi a taste of what the Dark Lady has planned for both humans and Scourge alike."] = 499
			}
		},
		["Elixir of Pain"] = 	{
			["Apothecary Lydon"] = 		{
				["Oh, $N. . .the flowers are blooming in Hillsbrad and the air is so fresh and brisk. I can't help but to wallow in the believe I can make the most splendid death-brew with the blood of a Mountain Lion. Bring some to me and we'll have a little fun."] = 501,
				["Ah, nothing like the smell of fresh blood in the foothills! Now we'll mix in a touch of this and a little of that and let test. Take this elixir out to the northern farm in Hillsbrad Fields to the southwest. Let's see how Farmer Ray's little dog Stanley likes this 'treat.'"] = 502
			}
		},
		["Blood of Innocents"] = 1066,
		["Return to Thunder Bluff"] = 	{
			["Apothecary Lydon"] = 1067,
			["Uldum Pedestal"] = 2967
		},
		["Undamaged Venom Sac"] = 2934,
		["Consult Master Gadrin"] = 2935,
		["Venom to the Undercity"] = 2938,
		["Ride to the Undercity"] = 6323,
		["The Crown of Will"] = 	{
			["Sharlindra"] = 495,
			["Melisara"] = 		{
				["Mug'Thol and his Crushridge ogres have overrun the ruins of Alterac. It will be hard to inflict any serious punishment upon him without thinning out It will be hard to inflict any serious punishment upon him without thinning out the ogres' numbers. After softening them up, we'll proceed. Understood? Good. Now go."] = 518,
				["Targ, Muckrake, and Glommus are Mug'Thol's lieutenants. They are loyal to him, though who can say what drives an ogre to loyalty. Bring me their heads, say what drives an ogre to loyalty. Bring me their heads, $n, and then all that will remain is to remove Mug'Thol's head, crown and all."] = 519,
				["With Mug'Thol's lieutenants dead, all that remains is to kill Mug'Thol and retrieve the Crown of Will. I have no doubt he'll be reluctant to too, given the... departure... of his fellows. Find Mug'Thol, and deliver his head and the Crown to me. The Crushridge resistance will be at an end."] = 520,
				["All that remains is to deliver the Crown of Will to Sharlindra in the Undercity. She will see that it is delivered to Lady Sylvanas. is delivered to Lady Sylvanas. I would warn you against thinking to use it for your own purposes, $n, Mug'Thol's fate should be illustration enough."] = 521
			}
		},
		["Down the Coast"] = 536,
		["Farren's Proof"] = 	{
			["Lieutenant Farren Orinelle"] = 		{
				["Would you believe it, $n? Redpath wasn't satisfied with all the murlocs we killed--oh now, don't be modest, you had some hand in it. Now some hand in it. Now he wants me to bring proof of the dead, hacking off cold, slimy murloc heads to submit for his approval."] = 559,
				["You know, $n, I'd really rather not take these heads... Since you've already got a handle on them, would you mind delivering them to Redpath $n, I'd really rather not take these heads... Since you've already got a handle on them, would you mind delivering them to Redpath for me?"] = 560
			},
			["Marshal Redpath"] = 561
		},
		["Stormwind Ho!"] = 562,
		["Reassignment"] = 563,
		["The Rescue"] = 498,
		["Gol'dir"] = 503,
		["Lord Aliden Perenolde"] = 507,
		["Infiltration"] = 533,
		["Regthar Deathgate"] = 	{
			["Krusk"] = 1361,
			["Belgrom Rockmaul"] = 1361,
			["Vol'jin"] = 1361
		},
		["Crushridge Bounty"] = 500,
		["Crushridge Warmongers"] = 504,
		["Syndicate Assassins"] = 505,
		["Noble Deaths"] = 512,
		["Baron's Demise"] = 523,
		["Dark Council"] = 537,
		["Letter to Stormpike"] = 514,
		["Preserving Knowledge"] = 540,
		["Return to Milton"] = 542,
		["Stormpike's Deciphering"] = 554,
		["The Perenolde Tiara"] = 543,
		["Mayara Brightwing"] = 4766,
		["Bring the End"] = 3341,
		["Blackmoore's Legacy"] = 506,
		["Taretha's Gift"] = 508,
		["Valik"] = 535,
		["Manna-Enriched Horse Feed"] = 7645,
		["Costly Menace"] = 564,
		["Hinott's Assistance"] = 	{
			["Serge Hinott"] = 2480,
			["Shenthul"] = 2479
		},
		["Soothing Turtle Bisque"] = 	{
			["Christoph Jeffcoat"] = 7321,
			["Chef Jessen"] = 555
		},
		["Prison Break In"] = 544,
		["Dalaran Patrols"] = 545,
		["Souvenirs of Death"] = 546,
		["Humbert's Sword"] = 547,
		["Into The Scarlet Monastery"] = 1048,
		["The Power to Destroy..."] = 5725,
		["The Crimson Courier"] = 	{
			["Varimathras"] = 6145,
			["Lady Sylvanas Windrunner"] = 6145
		},
		["An Unholy Alliance"] = 	{
			["Varimathras"] = 6521,
			["Small Scroll"] = 6522
		},
		["Helcular's Revenge"] = 	{
			["Novice Thaivand"] = 		{
				["Master Helcular was almost complete with his transformation into a Lich when a human lynch mob discovered his ritual lair in the hills and brutally of vengeance fall upon the town of Southshore. We will need Helcular's Rod first. Yeti overtook his ritual lair. Undoubtedly one of the beasts has it."] = 552,
				["Here, take the Rod of Helcular. You will need it. Helcular fashioned 3 ceremonial pyres as part of his most powerful spell. The Flame of Azel Once the ritual is complete, drive the rod into Helcular's grave in Southshore, the heavily guarded human town to the south. Vengeance shall be ours!"] = 553
			}
		},
		["Stone Tokens"] = 556,
		["Bracers of Binding"] = 557,
		["Bartolo's Yeti Fur Cloak"] = 565,
		["The Defense of Grom'gol"] = 	{
			["Commander Aggro'gosh"] = 		{
				["Throm'ka, $c! Your arrival at Grom'gol is timely, indeed. As commander of the Warchief's base camp here in the jungle I am bound by honor to putting you in charge of thinning out the raptor population outside of Grom'gol. Once you have made significant progress, report back to me for reassignment."] = 568,
				["When we first arrived in this jungle we did not intend to wage war on the local tribes. Our mission to supply Stonard is of with these uncooperative ogres. Travel to the ruins and attempt to drive them from the area. At the very least it will send a firm message."] = 569
			}
		},
		["Mok'thardin's Enchantment"] = 	{
			["Far Seer Mok'thardin"] = 		{
				["The power of the jungle's magic must be realized and then harnessed by the Horde. My rituals have proven successful so far. I can cast in pristine condition. The beasts lurk throughout the jungle but you will find some close by, just across the river from Mizjah Ruins to the southeast."] = 570,
				["What I need from you now will be very difficult to obtain. To hold all these feathers, claws and the pristine fang in place I require be perfect. It might take quite a few kills for you to find exactly what I need but it will be well worth the hunt."] = 571,
				["The items you gathered from the feline beasts of the Vale are only the first requirement for a powerful enchanted item. These jungle trinkets combined worn by the beasts on their armbands. You will find a tribe of the raptors directly south of Grom'gol, not far from the great arena."] = 572,
				["There is but one final reagent needed to complete the enchantment. In the south, towards the western coast, high above the bluffs, lies a Holy Spring. me Holy Spring Water. Be warned. An expedition of naga explorers have advanced upon the spring. They will need to be dealt with as well."] = 573
			}
		},
		["Stranglethorn Fever"] = 348,
		["The Bloodsail Buccaneers"] = 	{
			["Fleet Master Seahorn"] = 		{
				["Crazz speaks highly of your dedication to the Blackwater Raiders. I am going to trust you with a mission of extreme importance to the fleet. Infiltrate the Wild Shore. Raid the encampment. Bring me their charts along with their written orders. We shall see exactly what those scum are up to."] = 604,
				["Blast the nerve of Firallon! He couldn't sail a skiff through Crystal Lake let alone lead an entire fleet against us. The Bloodsail Buccaneers will pay party? $n, take some of your most skilled comrades out to Firallon's landing spot and assassinate the Bloodsail leadership. Their fleet will sink soon after...."] = 608
			},
			["First Mate Crazz"] = 		{
				["You sure seem eager to work, matey. Not sure why some land-loving $r $c is offering help to the Blackwater Raiders, but I'm not going looking for ladies! What I need is a scout. Check the cove just north of Booty Bay along the Savage Coast and see what you find."] = 595,
				["Shiver me timbers! So the Bloodsail Buccaneers are planning some sort of attack on Booty Bay? Why, the nerve of those scoundrels. Booty Bay will Raiders! This is bigger than I thought. Report what you have learned to Fleet Master Seahorn at once! The ol' sea dog is around town somewhere...."] = 599
			},
			["Bloodsail Correspondence"] = 597
		},
		["Sunken Treasure"] = 	{
			["Fleet Master Seahorn"] = 670,
			["Shakes O'Breen"] = 669,
			["Professor Phizzlethorpe"] = 665,
			["Doctor Draxlegauge"] = 		{
				["The treasure has been on the sea floor so long that the gems have calcified into thick stone. But the power harnessed in these goggles lost treasure for Captain O'Breen. I'd swim down there myself but...um...well, I have important scientific business to tend to up on the safe, dry land....er, yeah."] = 666,
				["Let's not leave Captain O'Breen waiting. He'll want to see these gems first hand. After all, that's why we're here! And after a few weeks of I have realized the last thing that's good for our health is to be caught hanging on to their treasure. Here, $n, take these to O'Breen."] = 668
			}
		},
		["Up to Snuff"] = 587,
		["Whiskey Slim's Lost Grog"] = 580,
		["Keep An Eye Out"] = 576,
		["Akiris by the Bundle"] = 	{
			["Privateer Bloads"] = 		{
				["You looking fer work, $N? I might have some if you're up for a little challenge. I got a friend named Groy who makes a killing me ten stalks of the stuff, and we'll have business to do. The naga were last seen along the beach to the north of here."] = 617,
				["$N, since I have you here, I got a message from Groy while you were gone. He mentioned bein' satisfied with the last shipment that me. Feeling adventurous? You do know where Dustwallow Marsh is, doncha? I'd be careful though, Theramore can be dangerous if you're the wrong kind of crowd."] = 623
			}
		},
		["Supply and Demand"] = 575,
		["Some Assembly Required"] = 577,
		["Excelsior"] = 628,
		["The Stone of the Tides"] = 578,
		["Water Elementals"] = 601,
		["Magical Analysis"] = 602,
		["Goblin Sponsorship"] = 	{
			["Baron Revilgaz"] = 		{
				["See, the Venture Company shredders out in Lake Nazferiti (in northern Stranglethorn) have been equipped with a new model fuel regulator. I was thinking that you might have more luck finding the blueprints though. I know he keeps them in his house, but they're almost certainly under lock and key."] = 1182,
				["You should be all set to go. Give Pozzik my regards and tell him that if he ever needs anything, not to hesitate to ask. him that if he ever needs anything, not to hesitate to ask. I'll be waiting for the news that he breaks the track record soon!"] = 1183
			},
			["Gazlowe"] = 1180,
			["Pozzik"] = 1178,
			["Wharfmaster Lozgil"] = 1181
		},
		["Hunt for Yenniku"] = 581,
		["Headhunting"] = 582,
		["Bloodscalp Clan Heads"] = 584,
		["Trollbane"] = 638,
		["Grim Message"] = 2932,
		["Venture Company Mining"] = 600,
		["Singing Blue Shards"] = 605,
		["Zanzil's Secret"] = 621,
		["Zanzil's Mixture and a Fool's Stout"] = 1119,
		["Fool's Stout"] = 1127,
		["The Captain's Chest"] = 8551,
		["The Captain's Cutlass"] = 8553,
		["Scaring Shaky"] = 606,
		["Voodoo Dues"] = 609,
		["Cracking Maury's Foot"] = 613,
		["Stoley's Debt"] = 2872,
		["Return to MacKinley"] = 607,
		["The Singing Crystals"] = 589,
		["The Mind's Eye"] = 591,
		["Saving Yenniku"] = 592,
		["Bloody Bone Necklaces"] = 596,
		["Split Bone Necklace"] = 598,
		["The Vile Reef"] = 629,
		["'Pretty Boy' Duncan"] = 610,
		["The Curse of the Tides"] = 611,
		["Ansirem's Key"] = 603,
		["Avast Ye, Scallywag"] = 1036,
		["Avast Ye, Admiral!"] = 4621,
		["Facing Negolash"] = 8554,
		["Death From Below"] = 667,
		["Message in a Bottle"] = 	{
			["Princess Poobah"] = 630,
			["Carefully Folded Note"] = 594
		},
		["Components for the Enchanted Gold Bloodrobe"] = 	{
			["Xizk Goodstitch"] = 4782,
			["Menara Voidrender"] = 		{
				["The first item I will aid you in creating is a robe. You will gather the items for me, and we will put them together. purchase one from someone else--I'd be most impressed if you could make it yourself--but regardless, bring me the robes, and we shall go from there."] = 1796,
				["Your next task is as simple as your first, but will require you to seek out aid. I require gold thread for the embroidery of the a master tailor and will be happy to spin the thread for you. Gold bars are smelted by skilled miners. Ask a miner for help."] = 4781,
				["The next components are found in Desolace, far to the west of the Barrens and even the Stonetalon Mountains. There, chaos still reigns after the Sundering. me their blood. From the lesser infernals in Mannoroc Coven, bring me a lesser infernal stone. We will use both in the construction of your robe."] = 4783,
				["I need only three things now, $N, then we can finish your robe. First, the fine gold thread Xizk is making for you. Return to him Wall. Finally, a soul shard created by you. After you have all the components, return here to the tower and I will complete the robe for you."] = 4784
			}
		},
		["Sara Balloo's Plea"] = 683,
		["MacKreel's Moonshine"] = 647,
		["Northfold Manor"] = 681,
		["Stromgarde Badges"] = 682,
		["Sigil of Strom"] = 639,
		["The Broken Sigil"] = 640,
		["Sigil of Arathor"] = 643,
		["Sigil of Trollbane"] = 644,
		["Trol'kalar"] = 	{
			["Zengu"] = 645,
			["Trollbane's Tomb"] = 646
		},
		["Sigil of Thoradin"] = 641,
		["Foul Magics"] = 	{
			["Tor'gan"] = 		{
				["I have felt a strangeness in the air... a feeling that simmers in my blood. I had my suspicions. I set off to find the The one I found was depleted, however. I'll need another to examine, but I dare not return to the manor. Can you bring me some?"] = 671,
				["There is no doubt in my mind that a powerful warlock resides within the walls of Stromgarde. From time to time, using an arcane magical on his person, and I will take steps to destroy it and see that its power is not used to taint this land any longer."] = 673
			}
		},
		["Raising Spirits"] = 	{
			["Tor'gan"] = 		{
				["We tried to settle him in, cheer him up, telling him stories of our mighty city at Orgrimmar in Kalimdor, but nothing would move him. Tales is worth a try! A small object we could make for him, yes... Bring me some raptor eyes, and I will see what I can do."] = 672,
				["Here, take this amulet to Gor'mul, and see if the raptors' strength can awaken the flame of the warrior that once burned through his veins. Here, take this amulet to Gor'mul, and see if the raptors' strength can awaken the flame of the warrior that once burned through his veins."] = 674
			},
			["Gor'mul"] = 675
		},
		["Guile of the Raptor"] = 	{
			["Tor'gan"] = 		{
				["With some additional objects, I will be able to create an item that will imbue Gor'mul with the guile of the raptor! With the power through him, Gor'mul will know our new power and rediscover the warrior that lies dormant! I will require raptor hearts to fashion the item and spell."] = 701,
				["Take this orb and use its energy to give Gor'mul the essence of the raptor. Surely this will invigorate his spirit and give him new to normal, we can explain to him the current state of the Horde, and we will have a great warrior's assistance in our unceasing battles."] = 702
			},
			["Gor'mul"] = 847
		},
		["Malin's Request"] = 	{
			["Archmage Malin"] = 690,
			["Skuerto"] = 697
		},
		["Hints of a New Plague?"] = 	{
			["Phin Odelic"] = 659,
			["Quae"] = 		{
				["<Quae begins to go through the folder.> This IS interesting. Seems Apothecary Jorell has been working on some deadly experiments here at Go'Shek. Not sure what it, she's going to need some protection when she goes down to the farm to steal whatever research Jorell still hasn't sent to Tarren Mill."] = 657,
				["So, Phin sent you to check on us? Not surprised--he worries too much. We've been watching the farm for days, and Kin claims she saw a be carrying notes to Tarren Mill. If we could get our hands on those documents, it might shed some light on what's happening in Hillsbrad."] = 658,
				["I've seen Kinelory look way worse after a night in the tavern than she does now. You obviously did a good job protecting her. These items after your attack, we're going to stay here for a bit longer. Would you be willing to head back to Southshore and talk to Phin?"] = 661
			},
			["Kinelory"] = 660
		},
		["Land Ho!"] = 663,
		["Deep Sea Salvage"] = 662,
		["Drowned Sorrows"] = 664,
		["The Hammer May Fall"] = 676,
		["Call to Arms"] = 	{
			["Drum Fel"] = 		{
				["The Witherbark trolls and Boulderfist ogres of Arathi are working together to rid us from this land, but we shall not meet our fates at our attack on the Witherbark trolls to the south of here. Slay them in droves, and only return when their camps run thick with blood."] = 677,
				["Your strength is evident, $N. Now to see how you fare against a real enemy. The Boulderfists have a lair to the southwest of here towards body when you are successful, or come to me in spirit when you fail. I shall give praise to your tenacity in battle either way."] = 678,
				["The head of the beast is ready to be taken off... with great force, $N. You have shown every sign that you are able to Stromgarde, a glaring symbol of human frailty. Find and slay those Boulderfist lords and their lackey shaman who would try and drive us from these lands."] = 679
			}
		},
		["The Real Threat"] = 680,
		["A King's Tribute"] = 	{
			["King Magni Bronzebeard"] = 686,
			["Grand Mason Marblesten"] = 		{
				["So our good King would like a memorial built in honor of a soldier named Sully Balloo? And you say the poor chap died during piece I want to work with one of the finest stones available. Travel to Darrow Hill in Hillsbrad and gather for me some Alterac Granite."] = 689,
				["Ah, such fine stone comes from Lordaeron. Such a shame the land is in such shambles. But the Memorial came out quite well! I should think think the King will be most pleased with it. Now if you will, please send word to His Majesty that the Memorial is complete as requested."] = 700
			}
		},
		["Kharan Mighthammer"] = 4341,
		["The Fate of the Kingdom"] = 4362,
		["Summoning the Princess"] = 656,
		["The Lost Fragments"] = 692,
		["Solution to Doom"] = 709,
		["To Ironforge for Yagyin's Digest"] = 727,
		["To the Undercity for Yagyin's Digest"] = 728,
		["Theldurin the Lost"] = 	{
			["Gerrig Bonegrip"] = 687,
			["Zaruk"] = 687
		},
		["The Star, the Hand and the Heart"] = 	{
			["Gerrig Bonegrip"] = 735,
			["Keeper Bel'dugur"] = 736
		},
		["Forbidden Knowledge"] = 	{
			["Gerrig Bonegrip"] = 737,
			["Keeper Bel'dugur"] = 737
		},
		["Knowledge in the Deeps"] = 971,
		["Worth Its Weight in Gold"] = 691,
		["An Apprentice's Enchantment"] = 695,
		["Wand over Fist"] = 693,
		["Trelane's Defenses"] = 694,
		["Attack on the Tower"] = 696,
		["Hammerfall"] = 655,
		["Barbecued Buzzard Wings"] = 703,
		["Pearl Diving"] = 705,
		["Power Stones"] = 2418,
		["Fiery Blaze Enchantments"] = 706,
		["Mirages"] = 718,
		["Scrounging"] = 733,
		["Tremors of the Earth"] = 	{
			["Garek"] = 		{
				["It has become obvious that we cannot ensure that Blacklash and Hematus will remain imprisoned in Lethlor. That black dragons have taken up residence there, using the Sign of the Earth. Those runestones can then be used to break the seal which imprisons them. $n... assure that their dreams are eternal."] = 717,
				["I heard from Sigrun that you have been a great help to him. Perhaps I might enlist your help. I was sent here by my Camp Boff, stole an object called the Sign of the Earth; I must have it. Bring it to me, and I will tell you more."] = 732
			}
		},
		["Amulet of Secrets"] = 722,
		["Prospect of Faith"] = 	{
			["Hammertoe Grez"] = 723,
			["Prospector Ryedol"] = 724
		},
		["A Dwarf and His Tools"] = 719,
		["A Sign of Hope"] = 	{
			["Prospector Ryedol"] = 721,
			["Crumpled Map"] = 720
		},
		["The Absent Minded Prospector"] = 	{
			["Archaeologist Flagongut"] = 943,
			["Chief Archaeologist Greywhisker"] = 942,
			["Archaeologist Hollee"] = 		{
				["What an honor it was when Master Greywhisker assigned me to work under the guidance of the great Prospector Remtravel. At the academy in Ironforge and overran the site. Remtravel never seemed to notice. I ran back to Auberdine for help. Please travel south and see if the prospector is okay!"] = 729,
				["So the prospector wants to send the mysterious fossil to the Explorers' League in Darnassus? I don't feel right leaving Darkshore without him. Here, $n, deliver to the Explorers' League in Darnassus? I don't feel right leaving Darkshore without him. Here, $n, deliver the mysterious fossil to Chief Archaeologist Greywhisker in Darnassus."] = 741
			},
			["Prospector Remtravel"] = 731
		},
		["Trouble In Darkshore?"] = 730,
		["Passing Word of a Threat"] = 	{
			["Historian Karnik"] = 725,
			["Advisor Belgrum"] = 726
		},
		["An Ambassador of Evil"] = 762,
		["Seeing What Happens"] = 	{
			["Historian Karnik"] = 2946,
			["Nara Wildmane"] = 2966
		},
		["A Future Task"] = 	{
			["Historian Karnik"] = 2964,
			["Nara Wildmane"] = 2968
		},
		["Passing the Burden"] = 3448,
		["The Feast of Winter Veil"] = 	{
			["Historian Karnik"] = 7063,
			["Sagorne Creststrider"] = 7061
		},
		["The Lost Tablets of Will"] = 1139,
		["Liquid Stone"] = 715,
		["Stone Is Better than Cloth"] = 716,
		["This Is Going to Be Hard"] = 	{
			["Lucien Tosselwrench"] = 777,
			["Lotwil Veriatus"] = 		{
				["Wonderful, wonderful. <Lotwil looks up at you for a moment before going back to his shackles.> Go speak to Lucien, $N. I need a cog #5. Bring you for a moment before going back to his shackles.> Go speak to Lucien, $N. I need a cog #5. Bring it to me, will you?"] = 734,
				["Haha! Done! The shackles are done! It's time, Lucien. It's time, Servo! Are you ready to bear witness to the perfect blend of alchemy, engineering, and the perfect blend of alchemy, engineering, and the arcane, $N? I shall summon forth a powerful elemental now. This is a groundbreaking day for all of us."] = 778
			}
		},
		["Study of the Elements: Rock"] = 	{
			["Lotwil Veriatus"] = 		{
				["Here in the Badlands I've stopped to work on my latest project: my shackles of elemental binding. When complete, they will allow mages to summon even a few gizmos I've pieced together. The shards are easily collected from the lesser rock elementals to the west of here. Could you bring me some?"] = 710,
				["$N, you've already proven more able than all my apprentices combined. The next parts I need require a little more strength. Large stone slabs can be them further west of here or southeast along the mountains' edges. Take your time; I'll need a while to test these smaller pieces you brought me."] = 711,
				["$N, there's one more part I need from the elementals here in the Badlands: the bracers of rock binding from the greater rock elementals. By here, near some ogres if I recall. Bring me 5 of their bracers just so I have extras. Servo's notorious for misplacing my reagents and research."] = 712
			}
		},
		["Coolant Heads Prevail"] = 713,
		["Gyro... What?"] = 714,
		["The Rise of the Machines"] = 	{
			["Lotwil Veriatus"] = 4063,
			["Hierophant Theodora Mulvadania"] = 		{
				["The machines made themselves known to us during our initial forays into the Searing Gorge. Upon further investigation we discovered that they were being imported and lesser rock creations of the region. Once you have collected a sufficient amount, return to me and I shall determine their source of origin. "] = 4061,
				["G.L.A. Those are the 'initials' imprinted on the elemental shards. Below the initials are a rank marking of some sort. The machinations you destroyed in the the east. He is a scholar of some renown in the field of elemental sciences. He may be able to assist us in our search."] = 4062
			}
		},
		["The Red Crystal"] = 4811,
		["As Water Cascades"] = 4812,
		["The Book of Ur"] = 1013,
		["Swoop Hunting"] = 761,
		["Poison Water"] = 748,
		["Winterhoof Cleansing"] = 754,
		["Thunderhorn Totem"] = 756,
		["Thunderhorn Cleansing"] = 758,
		["Wildmane Totem"] = 759,
		["Wildmane Cleansing"] = 760,
		["The Hunt Begins"] = 747,
		["The Hunt Continues"] = 750,
		["The Battleboars"] = 780,
		["Simple Note"] = 3091,
		["Etched Note"] = 3092,
		["Rune-Inscribed Note"] = 3093,
		["Verdant Note"] = 3094,
		["A Humble Task"] = 	{
			["Chief Hawkwind"] = 752,
			["Greatmother Hawkwind"] = 753
		},
		["Rites of the Earthmother"] = 	{
			["Chief Hawkwind"] = 		{
				["Your willingness to perform a humble task for the tauren of Narache and your eagerness to learn are noble traits, $n. I believe one day and tell him Chief Hawkwind has sent you. You will find the seer's abode directly to the south of Camp Narache, tucked away in the hills."] = 755,
				["For you to continue with the Rites of the Earthmother you must pass two more tests. It is time for you to broaden your experience, and help you on your path. Follow the road out of Camp Narache and travel with haste. Do not stray or you will lose your way."] = 763
			},
			["Cairne Bloodhoof"] = 776
		},
		["Rite of Strength"] = 757,
		["Rite of Wisdom"] = 773,
		["Dangers of the Windfury"] = 743,
		["Test of Faith"] = 1149,
		["Test of Endurance"] = 1150,
		["Test of Strength"] = 1151,
		["Test of Lore"] = 	{
			["Dorn Plainstalker"] = 1152,
			["Parqual Fintallas"] = 		{
				["I will tell you what you must seek, and I will even ask you my question, but not because you wish to prove yourself. Knowledge called Beginnings of the Undead Threat resides. It was used by the now-corrupt paladins there to train them to fight my kind. Bring it to me."] = 1160,
				["So the time is once again upon us. As a student of lore, you have shown great tenacity by undertaking my task. And so now I you your question. If you are ready, speak to me again, and take all the time you need, $N--there is no pressure to answer quickly."] = 6628
			},
			["Braug Dimspirit"] = 		{
				["You have passed Dorn's tests, and now you seek to pass your next trial. Very good. But up until now, your challenges have been childish. The Legacy of the Aspects. It can be found at the bottom of Dor'danil in southern Ashenvale, protected by the dead druids and their slayers."] = 1154,
				["Well done, $N. You have passed the first portion of the Test of Lore, but there is still another question to be answered. But that nature. He will have another requirement of you before he asks you anything, but you have done masterfully thus far--I'm sure you will overcome his obstacle."] = 1159,
				["You have brought me the book, and now it is time for your question. Are you ready? Time is not an issue, $c, so do not your question. Are you ready? Time is not an issue, $c, so do not feel pressured. You may take as long as you like to answer."] = 6627
			}
		},
		["Preparation for Ceremony"] = 744,
		["The Ravaged Caravan"] = 	{
			["Morin Cloudstalker"] = 749,
			["Sealed Supply Crate"] = 751
		},
		["The Venture Co."] = 764,
		["Supervisor Fizsprocket"] = 765,
		["Sharing the Land"] = 745,
		["Dwarven Digging"] = 746,
		["Rite of Vision"] = 	{
			["Baine Bloodhoof"] = 767,
			["Zarlman Two-Moons"] = 		{
				["In order to pass through the Rite of Vision, you must gather the reagents needed to make the Water of the Seers. I will need well the tribal fire, will cause you to encounter a vision. Follow it, and it will lead you to the next step of this holy quest."] = 771,
				["I now present you with the Water of the Seers. When you are ready, consume the waters near the tribal fire. Once you have ingested the will take a few moments before the vision materializes before the fire. At that point, it is up to you to follow it to your destiny...."] = 772
			}
		},
		["Journey into Thunder Bluff"] = 775,
		["Return to Jahan"] = 6364,
		["Call of Fire"] = 	{
			["Beram Skychaser"] = 1523,
			["Narm Skychaser"] = 2984,
			["Swart"] = 2983,
			["Searn Firewarder"] = 1522,
			["Telf Joolam"] = 		{
				["But you did not come here for a history lesson, did you? You came for the Eternal Flame and fire totem. The first step is to reagent pouch from one of the cultists of the Burning Blade. You can find them in a cave above the ravines northeast of Razor Hill."] = 1525,
				["The fire sapta is finished. The time has come for you to face the flame. Use the sapta at the shrine and head to the grow in power the longer you take to slay him. Once he is defeated, place his glowing embers within the brazier and light the torch."] = 1526
			},
			["Kranal Fiss"] = 1524,
			["Brazier of the Dormant Flame"] = 1527
		},
		["A Lesson to Learn"] = 	{
			["Turak Runetotem"] = 27,
			["Mathrengyl Bearwalker"] = 26
		},
		["Moonglade"] = 	{
			["Turak Runetotem"] = 5922,
			["Mathrengyl Bearwalker"] = 5921
		},
		["Body and Heart"] = 	{
			["Turak Runetotem"] = 6002,
			["Mathrengyl Bearwalker"] = 6001
		},
		["Lessons Anew"] = 	{
			["Turak Runetotem"] = 6126,
			["Mathrengyl Bearwalker"] = 6121
		},
		["Torwa Pathfinder"] = 	{
			["Turak Runetotem"] = 9063,
			["Sheal Runetotem"] = 9063,
			["Mathrengyl Bearwalker"] = 9063,
			["Denatharion"] = 9063,
			["Sheldras Moontree"] = 9063,
			["Theridran"] = 9063,
			["Jannos Lighthoof"] = 9063,
			["Golhine the Hooded"] = 9063,
			["Loganaar"] = 9063
		},
		["The Hunter's Charm"] = 	{
			["Holt Thunderhorn"] = 8151,
			["Ormak Grimshot"] = 8151,
			["Dorion"] = 8151,
			["Olmin Burningbeard"] = 8151,
			["Ulfir Ironbeard"] = 8151,
			["Oninath"] = 8151,
			["Deremiis"] = 8151
		},
		["The Islander"] = 	{
			["Torm Ragetotem"] = 1718,
			["Sorek"] = 1718,
			["Baltus Fowler"] = 1718,
			["Kelv Sternhammer"] = 1718,
			["Wu Shen"] = 1718,
			["Darnath Bladesinger"] = 1718
		},
		["A Troubled Spirit"] = 	{
			["Torm Ragetotem"] = 8417,
			["Sorek"] = 8417,
			["Christoph Walker"] = 8417,
			["Kelv Sternhammer"] = 8417,
			["Wu Shen"] = 8417,
			["Darnath Bladesinger"] = 8417,
			["Behomat"] = 8417
		},
		["Magecraft"] = 	{
			["Archmage Shymm"] = 8250,
			["Thurston Xane"] = 8250,
			["Pierce Shackleton"] = 8250,
			["Juli Stormkettle"] = 8250,
			["Elsharin"] = 8250,
			["Enyo"] = 8250,
			["Quithas"] = 8250,
			["Harnan"] = 8250
		},
		["Tabetha's Task"] = 	{
			["Ursyn Ghull"] = 2861,
			["Anastasia Hartwell"] = 2861,
			["Bink"] = 2861,
			["Jennea Cannon"] = 2861,
			["Deino"] = 2861,
			["Zaedana"] = 2861
		},
		["Gathering Leather"] = 768,
		["Kodo Hide Bag"] = 769,
		["The Hunter's Way"] = 861,
		["Mazzranache"] = 766,
		["Heeding the Call"] = 	{
			["Gart Mistrunner"] = 5927,
			["Gennia Runetotem"] = 5926,
			["Kal"] = 5923,
			["Theridran"] = 5924,
			["Harene Plainwalker"] = 5928,
			["Shalannius"] = 5925
		},
		["Veteran Uzzek"] = 	{
			["Krang Stonehoof"] = 1505,
			["Tarshaw Jaggedscar"] = 1505,
			["Sorek"] = 1505
		},
		["Call of Water"] = 	{
			["Narm Skychaser"] = 2986,
			["Swart"] = 2985,
			["Searn Firewarder"] = 1528,
			["Minor Manifestation of Water"] = 96,
			["Brine"] = 		{
				["Islen will have one more task for you before rewarding you with your next totem. The vial of water I've given you is necessary for totem. The vial of water I've given you is necessary for whatever that task is. Go now and find her. We shall meet again some day."] = 220,
				["Take this waterskin and head deep into the lush forest the night elves call Ashenvale. It is to the far north of the Barrens. Once you've a small fountain. Bring me a sample of the fountain's water. It will be the final component you'll need before I send you back to Islen."] = 1534,
				["To find understanding and gain the sapta from me, you must seek out only the purest forms of water. As you fetch the samples for with a simple task: down below my hut there is a pond of the precious liquid. Fill this skin with it and return to me."] = 1535,
				["Long ago I followed some companions into the Hillsbrad Foothills. We defended ourselves from some tenacious humans who make their home there and we found citizens of the town even realize its value--it's a small holy vestige in an unhallowed sea. Bring me a sample of that water in this waterskin."] = 1536
			},
			["Islen Waterseer"] = 		{
				["Along the coast of Silverpine, west of the Sepulcher, you will find a shrine that has become tainted by the plague. The spirits there no enough to summon a pure spirit for you to communicate with. Bring me proof the task is done, and I will reward you with your totem."] = 63,
				["If there is one lesson you must learn of water, it is this: water means rebirth. Its power flows, erodes, and makes clean all manner of vital a resource it is. If you wish the water sapta, find Brine deep in Southern Barrens. Her home is continually molested by the quilboar there."] = 1530
			},
			["Xanis Flameweaver"] = 1529,
			["Tiev Mordune"] = 		{
				["Light explodes as you finish the incantation. The sounds of the water drops hitting the flame have died down and your senses are overcome as The sounds of the water drops hitting the flame have died down and your senses are overcome as the corrupt spirits around you are destroyed."] = 100,
				["Greetin's, $g brotha:sista;! Have you too come to purify the waters here and prove your understandin' to Islen? I've just defeated the corrupt water spirit meself, the pure water spirit again. Bring me a water sapta from Islen as proof that you be ready, an' I'll wait to turn in me parts."] = 1103
			},
			["Brazier of Everfount"] = 100
		},
		["Vanquish the Betrayers"] = 784,
		["From The Wreckage...."] = 825,
		["The Admiral's Orders"] = 	{
			["Gar'Thok"] = 831,
			["Aged Envelope"] = 830
		},
		["Encroachment"] = 837,
		["Thwarting Kolkar Aggression"] = 786,
		["Dark Storms"] = 806,
		["Margoz"] = 828,
		["Cutting Teeth"] = 788,
		["Sting of the Scorpid"] = 789,
		["Simple Parchment"] = 	{
			["Gornek"] = 2383,
			["Simple Parchment"] = 2383
		},
		["Simple Tablet"] = 3065,
		["Etched Tablet"] = 3082,
		["Encrypted Tablet"] = 3083,
		["Rune-Inscribed Tablet"] = 3084,
		["Hallowed Tablet"] = 3085,
		["Glyphic Tablet"] = 3086,
		["Etched Parchment"] = 3087,
		["Encrypted Parchment"] = 3088,
		["Rune-Inscribed Parchment"] = 3089,
		["Tainted Parchment"] = 3090,
		["The New Horde"] = 787,
		["Vile Familiars"] = 	{
			["Zureetha Fargaze"] = 792,
			["Ruzan"] = 1499
		},
		["Burning Blade Medallion"] = 794,
		["Report to Sen'jin Village"] = 805,
		["Carry Your Weight"] = 791,
		["Therzok"] = 1859,
		["To Orgrimmar!"] = 2380,
		["Minshina's Skull"] = 808,
		["Report to Orgnil"] = 823,
		["Zalazane"] = 826,
		["The Spider God"] = 2936,
		["Summoning Shadra"] = 2937,
		["Finding the Antidote"] = 813,
		["Need for a Cure"] = 812,
		["Break a Few Eggs"] = 815,
		["Lost But Not Forgotten"] = 816,
		["Practical Prey"] = 817,
		["Skull Rock"] = 827,
		["Neeru Fireblade"] = 829,
		["Break Sharptusk!"] = 3376,
		["Ak'Zeloth"] = 809,
		["Hidden Enemies"] = 	{
			["Neeru Fireblade"] = 5730,
			["Thrall"] = 		{
				["One thing I will not tolerate are traitors in our midst, $N. But I would be a fool to play my hand so early--it would enough, then enter Skull Rock to the east of Orgrimmar, find a lieutenant's insignia off one of the Burning Blade there, and return to me."] = 5726,
				["Now let us see if this insignia you found is worth the effort. There is a warlock within the city who believes he has my trust. Cleft of Shadow here in Orgrimmar, speak to him and see if he believes you are one of his own, then return to me here."] = 5727,
				["Hmm, leaders of the Searing Blade... this concerns me most. If they are the ones of value to Neeru, then those are who we must be careful not to let Neeru know it was you who did this. You must retain your identity as one of his $gbrothers:sisters; in arms."] = 5728,
				["I think our next step should be to have you placed close to Neeru. If he is as agitated as reports suggest, then we may the void now that some of the leadership is in turmoil. Return to the Cleft and speak to him again, but do not be too overt."] = 5729
			}
		},
		["Slaying the Beast"] = 5761,
		["A Sacred Burial"] = 833,
		["Sarkoth"] = 	{
			["Hana'zua"] = 		{
				["$C! I thought I would die out here with none to know of it. While I was hunting the scorpids of the Valley, I came my blood. Please, you must kill the scorpid for me! My honor must be upheld! I fought it up on the plateau to the south."] = 790,
				["Seeing the deed you have done for me steels my heart. I cannot fall so easily! I must endure! But it remains that I cannot make make the trek back to the Den unassisted. Please, $n, return to the Den and tell Gornek of my situation. Perhaps he can help me."] = 804
			}
		},
		["Chen's Empty Keg"] = 	{
			["Brewmaster Drohn"] = 		{
				["Would you like a taste of Chen's namesake? Ahh, the stormstout is a mighty brew. Chen taught the recipe to my mentor, and my mentor plainstrider, and 1 thunder lizard horn from any species of thunder lizard. That should do the trick nicely. You can find these ingredients throughout the Barrens."] = 821,
				["Good stuff, that stormstout, huh? I have another recipe that I learned from Chen. Would you be interested? It won't take long to make, and it a kodo liver from any of the Barrens' kodos. Like I said, this stuff has kick; it's the trogg ale that I mentioned to you before."] = 822
			},
			["Chen's Empty Keg"] = 819
		},
		["Winds in the Desert"] = 834,
		["Securing the Lines"] = 835,
		["Gan'rul's Summons"] = 1506,
		["A Solvent Spirit"] = 818,
		["Return to the Crossroads."] = 6386,
		["You Too Good."] = 6608,
		["Conscript of the Horde"] = 840,
		["Crossroads Conscription"] = 842,
		["Plainstrider Menace"] = 844,
		["The Zhevra"] = 845,
		["Echeyakee"] = 881,
		["Prowlers of the Barrens"] = 903,
		["The Angry Scytheclaws"] = 905,
		["Jorn Skyseer"] = 3261,
		["The Guns of Northwatch"] = 891,
		["Gann's Reclamation"] = 843,
		["Revenge of Gann"] = 	{
			["Gann Stonespire"] = 		{
				["It is clear the prospector depended on explosives and those noisy vehicles to rip the ground apart. We can expect a new foreman to take the Keep are known to have the supplies. Collect these items and bring them to me. I will fashion a charge that the dwarves won't forget!"] = 846,
				["Following Khazgorm's plans it should be no problem to fashion an explosive charge Ah, there we go. Now, $n, I am going to entrust you with a an icon of power and an insult to the memory of my tribe. Make me proud by completing this heroic task and you shall be rewarded."] = 849
			}
		},
		["Speak with Ruga"] = 1823,
		["Horde Trauma"] = 6623,
		["Mahren Skyseer"] = 874,
		["Ishamuhale"] = 882,
		["Enraged Thunder Lizards"] = 907,
		["Cry of the Thunderhawk"] = 913,
		["Melor Sends Word"] = 1130,
		["The Ashenvale Hunt"] = 	{
			["Jorn Skyseer"] = 6382,
			["Warcaller Gorlach"] = 235,
			["Bluff Runner Windstrider"] = 742
		},
		["Isha Awak"] = 873,
		["Kolkar Leaders"] = 850,
		["Verog the Dervish"] = 851,
		["Hezrul Bloodmark"] = 852,
		["Centaur Bracers"] = 855,
		["The Kolkar of Desolace"] = 1362,
		["Counterattack!"] = 4021,
		["Fungal Spores"] = 848,
		["Apothecary Zamah"] = 853,
		["Wharfmaster Dizzywig"] = 	{
			["Apothecary Helbrim"] = 1492,
			["Kravel Koalbeard"] = 1111
		},
		["Southsea Freebooters"] = 887,
		["Stolen Booty"] = 888,
		["The Missing Shipment"] = 	{
			["Gazlowe"] = 890,
			["Wharfmaster Dizzywig"] = 892
		},
		["To Gadgetzan You Go!"] = 6611,
		["Zando'zan"] = 2379,
		["Deep Cover"] = 2458,
		["The Shattered Salute"] = 2460,
		["Wrenix of Ratchet"] = 2382,
		["Rig Wars"] = 2841,
		["Nogg's Ring Redo"] = 2950,
		["Chief Engineer Scooty"] = 2842,
		["Journey to the Crossroads"] = 854,
		["Serpentbloom"] = 962,
		["Journey to Tarren Mill"] = 1065,
		["The Flying Machine Airport"] = 1086,
		["The Tear of the Moons"] = 857,
		["Egg Hunt"] = 868,
		["The Swarm Grows"] = 	{
			["Korran"] = 1145,
			["Moktar Krin"] = 1147,
			["Belgrom Rockmaul"] = 1146
		},
		["Parts of the Swarm"] = 	{
			["Korran"] = 1184,
			["Cracked Silithid Carapace"] = 1148
		},
		["Disrupt the Attacks"] = 871,
		["The Disruption Ends"] = 872,
		["Supplies for the Crossroads"] = 5041,
		["Report to Kadrak"] = 	{
			["Thork"] = 6541,
			["Darn Talongrip"] = 6542
		},
		["Tribes at War"] = 878,
		["Betrayal from Within"] = 	{
			["Mangletooth"] = 		{
				["Three of my tribe came out of the Kraul to lead the raids against the Horde, $r. <snort> They are ruthless and cunning, and if is a spell caster, another a tracker, and their leader, the one called Orcbane, <snort> a warrior. Kill them, $r, like they have killed me."] = 879,
				["Take Lok's head to Thork in the Crossroads, $r. <snort> He should know what has happened to my tribe without any words--ha, not that he a great deed. <snort> I will continue to bless you with Agamaggan's power for as long as I remain in this cage, $r. Until then, farewell."] = 906
			}
		},
		["Blood Shards of Agamaggan"] = 5052,
		["Consumed by Hatred"] = 899,
		["Lost in Battle"] = 4921,
		["Weapons of Choice"] = 893,
		["A New Ore Sample"] = 1153,
		["Ignition"] = 858,
		["Sergra Darkthorn"] = 860,
		["Steelsnap"] = 1131,
		["Frostmaw"] = 1136,
		["Deadmire"] = 1205,
		["Samophlange"] = 	{
			["Sputtervalve"] = 894,
			["Control Console"] = 		{
				["The three control valves are currently opened. The various readings on the control panel lead you to presume that they must be shut off before opened. The various readings on the control panel lead you to presume that they must be shut off before the apparatus can be shut off."] = 900,
				["With the apparatus deactivated, the control panel can be opened up and the samophlange removed from the console. With everything else in place, all that and the samophlange removed from the console. With everything else in place, all that is left is to acquire the key to unlock the console."] = 901,
				["Pulling open the face of the control console reveals a dense jumble of wires, tubing and other strange mechanical objects--most of which seem to serve to serve no practical purpose. Pushing them aside and digging deeper into the console, you find the samophlange. A tug removes it from its housing."] = 902
			}
		},
		["Further Instructions"] = 	{
			["Sputtervalve"] = 1095,
			["Ziz Fizziks"] = 1094
		},
		["Ziz Fizziks"] = 1483,
		["Wenikee Boltbucket"] = 3921,
		["Dig Rat Stew"] = 862,
		["Raptor Horns"] = 865,
		["Root Samples"] = 866,
		["Deepmoss Spider Eggs"] = 1069,
		["Blueleaf Tubers"] = 1221,
		["Smart Drinks"] = 1491,
		["The Forgotten Pools"] = 870,
		["The Stagnant Oasis"] = 877,
		["Altered Beings"] = 880,
		["Hamuul Runetotem"] = 1489,
		["Mura Runetotem"] = 3301,
		["Gathering the Cure"] = 	{
			["Tonga Runetotem"] = 6128,
			["Alanndarian Nightsong"] = 6123
		},
		["Curing the Sick"] = 	{
			["Tonga Runetotem"] = 6129,
			["Alanndarian Nightsong"] = 6124
		},
		["Harpy Raiders"] = 867,
		["Harpy Lieutenants"] = 875,
		["Serena Bloodfeather"] = 876,
		["Letter to Jin'Zil"] = 1060,
		["Miner's Fortune"] = 896,
		["Passage to Booty Bay"] = 1040,
		["Parts for Kravel"] = 1112,
		["Raptor Thieves"] = 869,
		["News of Dogran"] = 	{
			["Gazrog"] = 1510,
			["Zankaja"] = 1509
		},
		["Stolen Silver"] = 3281,
		["Free From the Hold"] = 898,
		["A Bundle of Hides"] = 6361,
		["Meats to Orgrimmar"] = 6365,
		["Goblin Engineering"] = 	{
			["Tinkerwiz"] = 3633,
			["Graham Van Talen"] = 3526,
			["Springspindle Fizzlegear"] = 3629,
			["Lilliam Sparkspindle"] = 4181
		},
		["Gnome Engineering"] = 	{
			["Tinkerwiz"] = 		{
				["Engineering at the expert level breaks into two disciplines: gnome and goblin. While I think it is a waste, you should be aware of gnome Tinkmaster Overspark in Ironforge. Remember - membership is permanent and prevents joining the other discipline, so make sure you are sure before finishing his task!"] = 3634,
				["Engineering at the expert level breaks into two disciplines: gnome and goblin. While I think it is a waste, you should be aware of gnome Obnoticus in Booty Bay. Remember - membership is permanent and prevents joining the other discipline, so make sure you are sure before finishing his task."] = 3637
			},
			["Graham Van Talen"] = 3635,
			["Springspindle Fizzlegear"] = 3632,
			["Lilliam Sparkspindle"] = 3630
		},
		["Crown of the Earth"] = 	{
			["Tenaron Stormgrip"] = 		{
				["It is time for you to set out to seek your destiny, $n. But before you are ready to set out into the world beyond back the Burning Legion... There is a task you must perform. Go to the moonwell north of Aldrassil and return me a phial of its water."] = 921,
				["While there is more I could speak to you of the moonwells and of Teldrassil, I must send you along. Corithras Moonrage will be expecting to follow the cobblestones as the road turns west. Mind you stay on the road though, $n. There are dangerous beasts in the forests of late."] = 928
			},
			["Corithras Moonrage"] = 		{
				["First, let me tell you more of the task you must complete. The druids in Darnassus use the water of the moonwells of Teldrassil, and it with some of its waters, then return to me. When you have completed your task, I shall continue the story where Tenaron left off..."] = 929,
				["There is another moonwell southeast of the entrance to Darnassus, on the shores of the Pools of Arlithrien. The Sentinels are having problems patrolling the because of attacks and the growing ill-temperedness of the Gnarlpine furbolgs. Be wary as you seek out the well, and keep your weapons close at hand."] = 933,
				["Without the blessings of Alexstrasza the Life-Binder and Nozdormu the Timeless, Teldrassil's growth has not been without flaw. Strange beasts have been reported arising from the phials you brought into this vessel, for you to deliver to Darnassus. Bring it to Fandral Staghelm, you will find him in the druid grove."] = 935,
				["All was not well with Teldrassil, however. Staghelm's carefully made plans for the new World Tree had borne out as he had hoped, but there the boughs of the Oracle Tree lies the first and most powerful of our wells. Retrieve a phial of its water and return to me."] = 7383
			}
		},
		["Grove of the Ancients"] = 952,
		["Un'Goro Soil"] = 	{
			["Arch Druid Fandral Staghelm"] = 3764,
			["Arch Druid Hamuul Runetotem"] = 3761
		},
		["Morrowgrain Research"] = 	{
			["Arch Druid Fandral Staghelm"] = 3781,
			["Mathrengyl Bearwalker"] = 3785,
			["Arch Druid Hamuul Runetotem"] = 3782,
			["Bashana Runetotem"] = 3786
		},
		["Tumors"] = 923,
		["Return to Denalan"] = 2498,
		["The Enchanted Glade"] = 937,
		["Teldrassil"] = 940,
		["Good Luck Charm"] = 	{
			["Ol' Emma"] = 5050,
			["Jeremiah Payson"] = 5050
		},
		["The Demon Seed"] = 924,
		["Twisted Hatred"] = 932,
		["The Emerald Dreamcatcher"] = 2438,
		["Ferocitas the Dream Eater"] = 2459,
		["Mist"] = 938,
		["Cave Mushrooms"] = 947,
		["Onu"] = 948,
		["Therylune's Escape"] = 945,
		["In Favor of Elune"] = 5622,
		["The Apple Falls"] = 2241,
		["Erion Shadewhisper"] = 2259,
		["Garments of the Moon"] = 5621,
		["Ride to Thunder Bluff"] = 6362,
		["Ride to Orgrimmar"] = 6384,
		["The Master's Glaive"] = 944,
		["Mathystra Relics"] = 951,
		["The Fall of Ameth'Aran"] = 953,
		["For Love Eternal"] = 963,
		["Bashal'Aran"] = 	{
			["Thundris Windweaver"] = 954,
			["Asterion"] = 		{
				["If I were to relate the story of my life, I have no doubt it would surpass the limits of your patience. Let us say means of my imprisonment. A seal binds me, and by examining the earpieces of the sprites and grells, I may find a trace of it."] = 955,
				["If the grells have come into close contact with the seal that binds my eternal prison, I suspect I know the cause. No doubt the If you can obtain it, you would bring me so close to passing the bars of my prison that tears would come to my eyes."] = 956,
				["It was the craft of one of the most powerful of the Highborne that created the seal that formed my prison. In Ameth'Aran, the ruins twin to these, persists even today an ancient flame, blue in color. In this flame this seal could be destroyed. Be wary in the ruins, $n..."] = 957
			}
		},
		["Tools of the Highborne"] = 958,
		["Seeking the Kor Gem"] = 1442,
		["The Cliffspring River"] = 4762,
		["The Blackwood Corrupted"] = 4763,
		["The Tower of Althalaxx"] = 	{
			["Sentinel Elissa Starbreeze"] = 965,
			["Balthule Shadowstrike"] = 		{
				["A group of warlocks has taken up residence around and inside the tower. I would have returned to Auberdine to report to Elissa earlier, but but I need more to complete the puzzle. I warn you not to venture into the tower, however, the warlocks there are much more powerful!"] = 966,
				["My master, Delgren the Purifier, is a paladin who has graciously offered his assistance in defending our forests from the forces of the demons and find him far south of here at Maestra's Post in Ashenvale Forest. Be swift, I fear the Dark Strand's threat grows with each passing hour."] = 967,
				["For all the work that you have done, you deserve to be well rewarded. Return to Delgren and tell him that Athrikus Narassin lies stilled Return to Delgren and tell him that Athrikus Narassin lies stilled by your hand, and the Cult of the Dark Strand is beaten and scattered."] = 981,
				["I see. Well, if what you say is true, then now is the time to strike. I believe Athrikus resides at the top of the at the top of the tower. Be careful though, he is surrounded by many powerful warlocks, much more deadly than the ones you faced before."] = 1143
			},
			["Delgren the Purifier"] = 		{
				["Balthule's letter is dire. This Cult of the Dark Strand is a thorn in my side that must be removed. I have been dealing with gem that I believe holds the secret to the cult's power. Bring it to me, and I will be able to decipher the secrets held within."] = 970,
				["Ilkrud Magthrull. Yes, I have knowledge of him. He is a powerful orc warlock that makes his residence at the Fire Scar Shrine, a place Ashenvale. He had been little more than an annoyance until now, and I had not dealt with him, but it seems that his time has come."] = 973,
				["The writing of the orcs is little better than the scribblings of a child. Many of my order scoffed when I chose to learn their Satyrnaar, satyr-held areas in northeast Ashenvale. Be careful out there, $n, the satyrs' blood-soaked temples can be unsettling even for a seasoned $c such as yourself."] = 1140,
				["Before confronting Athrikus, it would probably be wise for you to consult with Balthule. I have no doubt he has been vigilant in his watch consult with Balthule. I have no doubt he has been vigilant in his watch of the Tower, and he may have information about recent developments."] = 1167
			}
		},
		["Trouble at the Docks"] = 959,
		["Buzzbox 827"] = 983,
		["Gaffer Jacks"] = 1579,
		["Electropellers"] = 1580,
		["Raene's Cleansing"] = 	{
			["Raene Wolfrunner"] = 		{
				["$N, a longtime friend of mine is also aiding the Sentinels here in Ashenvale, but he has yet to return. He had leads on finding an Lake Falathim at the base of the mountain to the west. The gem was being held there before it was overrun. Find my friend, $N, please."] = 991,
				["You'll have to do the research yourself, but from what notes Teronis has made, it sounds like your next course of action is to find Shael'dryn is better suited to guide you. Seek her out. Keep the gem with you--Shael'dryn will need it if she's to help you recreate the rod."] = 1024,
				["Alas, I'm not completely certain what he had in mind next. If what he said was true about the rod's power, then it will allow you Dartol would have to speak to a furbolg who was safe from the effects of Fel Moss. I would start your search southeast of Mystral Lake."] = 1030
			},
			["Teronis' Corpse"] = 1023,
			["Krolg"] = 		{
				["The night elves are as old as time, but their arrogance destroys their very world. And now it destroys our lives too. But that can only made him stronger. My hatred for the elves burns, but I do not wish ill upon their children, so we must police our own."] = 1045,
				["Return to your own tribe and let them know of your victory here. Show them your trophy, and bask in the glory... Return to your own tribe and let them know of your victory here. Show them your trophy, and bask in the glory..."] = 1046
			},
			["Shael'dryn"] = 		{
				["I wish your tidings were better. Raene is correct, I know about Dartol's creation and the treants in the area--at least I did once. They've become Felwood. Once you have it, look for a small glade west of the road near the Felwood border... the chest should be hidden around there."] = 1026,
				["The final piece of the rod was given to the druids of Dor'danil for safekeeping. I have no idea where they hid it. I'm sorry something I don't like to think about much. When you find the final piece, bring it to me and I will help you reconstruct the rod."] = 1027,
				["Here is the completed rod, $N. Reconstructing it was simple... it's finding the shrine that has the power to recharge it that will be the the north. The shrine is hidden within the mountains that surround this glade. Once there, place the rod within the shrine... the rest is magic. Hehe."] = 1028,
				["I suggest you find Raene and let her know the rod is finished. I'm sure she'll know what your next course should be. Good luck, $N. I suggest you find Raene and let her know the rod is finished. I'm sure she'll know what your next course should be. Good luck, $N."] = 1029
			},
			["Hidden Shrine"] = 1055
		},
		["An Aggressive Defense"] = 1025,
		["Culling the Threat"] = 1054,
		["Escape Through Force"] = 994,
		["Escape Through Stealth"] = 995,
		["How Big a Threat?"] = 	{
			["Terenthis"] = 		{
				["Some of my brethren were rescued from a corrupt furbolg in Teldrassil, and I've vowed to stop any more atrocities before more of our kind if the investigation continued with the furbolgs. Would you find one of their camps, and return to me if you see any signs of corruption?"] = 984,
				["You've already proven adept at scouting our enemy, $N. Do you have what it takes to fight them as well? Not all adventurers prefer straightforward combat the biggest threat to our people. You'll find some of the Blackwood tribe there. Kill 8 pathfinders and 5 windtalkers, and return to me here."] = 985
			}
		},
		["A Lost Master"] = 	{
			["Terenthis"] = 		{
				["$N, your skills have already helped me in my endeavor. Could I impose on you again to help Grimclaw and his master Volcor? In addition, moonstalker sire or matriarch to have enough material. The cats can be found near Wildbend River to the south, or even farther south near Ashenvale."] = 986,
				["The cloak is complete, $N. The time has come to find Volcor. I can only hope we are in time. The cloak's magic, once invoked, will will be alongside the road waiting for you. Signal to him by waving when you see him, and he'll point the way towards his master."] = 993
			}
		},
		["Thundris Windweaver"] = 4761,
		["Trek to Ashenvale"] = 990,
		["Plagued Lands"] = 2118,
		["Cleansing of the Infected"] = 2138,
		["Tharnariun's Hope"] = 2139,
		["Easy Strider Living"] = 2178,
		["Garments of Spirituality"] = 5648,
		["In Favor of Spirituality"] = 5649,
		["Proof of Deed"] = 3182,
		["Flight to Auberdine"] = 6342,
		["The Zoram Strand"] = 1008,
		["Pridewings of Stonetalon"] = 1134,
		["Kayneth Stillwind"] = 4581,
		["The Ancient Statuette"] = 1007,
		["Ruuzel"] = 1009,
		["Bathran's Hair"] = 1010,
		["Orendil's Cure"] = 1020,
		["Forsaken Diseases"] = 1011,
		["Insane Druids"] = 1012,
		["The Howling Vale"] = 1022,
		["Velinde Starsong"] = 1037,
		["Elemental Bracers"] = 1016,
		["Mage Summoner"] = 1017,
		["Elune's Tear"] = 1033,
		["The Ruins of Stardust"] = 1034,
		["Fallen Sky Lake"] = 1035,
		["Vile Satyr! Dryads in Danger!"] = 1021,
		["Satyr Slaying!"] = 1032,
		["The Branch of Cenarius"] = 1031,
		["The Ruins of Solarsal"] = 2866,
		["Against the Hatecrest"] = 	{
			["Shandris Feathermoon"] = 3130,
			["Latronicus Moonspear"] = 2869
		},
		["Rise of the Silithid"] = 	{
			["Shandris Feathermoon"] = 4267,
			["Senior Surveyor Fizzledowser"] = 		{
				["Here's your report. I urge you to take it to someone who might have working knowledge in this kind of thing. I know this troll scholar to him. We're going to need all the help we can get. Zil lives in a house on the second tier of the Drag in Orgrimmar."] = 32,
				["I urge you to take this report to someone who has working knowledge in this kind of thing. I know this night elf scholar named Gracina to stop it, give her the report. We'll need the help. Last I heard, she was residing in the Temple of the Moon, located in Darnassus."] = 162
			}
		},
		["The Caravan Road"] = 1041,
		["Compendium of the Fallen"] = 1049,
		["The Platinum Discs"] = 	{
			["Sage Truthseeker"] = 2440,
			["High Explorer Magellas"] = 2439,
			["The Discs of Norgannon"] = 		{
				["The centerpieces of this treasure chamber are four huge platinum discs, each adorned with numerous sigils of an unknown origin. Touching them makes your hand the Earthen has been chronicled and stored here for this world in the Discs of Norgannon.' You have uncovered a wealth of previously undiscovered worldly lore!"] = 2278,
				["Touching the Discs of Norgannon once again makes your hand tingle. This time, however, a strange grinding noise is heard from inside the discs. Your backpack ancient history of Azeroth. The Explorers' League in Ironforge is such a group, known throughout the Alliance; perhaps they can make good use of it."] = 2279,
				["Touching the Discs of Norgannon once again makes your hand tingle. This time, however, a strange grinding noise is heard from inside the discs. Your backpack the ancient history of Azeroth. The sages of Thunder Bluff are such historians, known throughout the Horde; perhaps they can make good use of it."] = 2280
			}
		},
		["Portents of Uldum"] = 	{
			["Sage Truthseeker"] = 2965,
			["High Explorer Magellas"] = 2963
		},
		["Mythology of the Titans"] = 1050,
		["In the Name of the Light"] = 1053,
		["Vorrel's Revenge"] = 1051,
		["Reclaiming the Charred Vale"] = 	{
			["Keeper Albagorm"] = 		{
				["As a protector of the forest spirits you can undoubtedly guess why I am alarmed. You have traveled through these mountains to reach this peak. Surely army of industrialists. Worse yet, the Bloodfuries that have encroached on the land refuse us passage in to begin regrowth. Drive the wretched harpies out, $n!"] = 1057,
				["The Bloodfuries have been subdued. But they will regroup soon enough if action is not taken. Far south of the Barrens lies a land known as of calling forth great forest spirits which can aid in the reclamation of the Charred Vale. Send word of our need! Seek him out at once!"] = 1059
			}
		},
		["Jin'Zil's Forest Magic"] = 1058,
		["Journey to Stonetalon Peak"] = 1056,
		["Forsaken Aid"] = 1064,
		["Magatha's Payment to Jediga"] = 3562,
		["Arikara"] = 5088,
		["The Spirits of Stonetalon"] = 1061,
		["The Crone of the Kraul"] = 1101,
		["Goblin Invaders"] = 1062,
		["The Elder Crone"] = 1063,
		["Shredding Machines"] = 1068,
		["A Gnome's Respite"] = 1071,
		["An Old Colleague"] = 1072,
		["A Scroll from Mauren"] = 1075,
		["Covert Ops - Alpha"] = 1079,
		["Covert Ops - Beta"] = 1080,
		["Kaela's Update"] = 1091,
		["Castpipe's Task"] = 2931,
		["Devils in Westfall"] = 1076,
		["Special Delivery for Gaxim"] = 1077,
		["Retrieval for Mauren"] = 1078,
		["On Guard in Stonetalon"] = 	{
			["Sentinel Thenysil"] = 1070,
			["Kaela Shadowspear"] = 1085
		},
		["Reception from Tyrande"] = 1081,
		["Update for Sentinel Thenysil"] = 1082,
		["Enraged Spirits"] = 1083,
		["Wounded Ancients"] = 1084,
		["Ineptitude + Chemicals = Fun"] = 	{
			["Lomac Gearstrip"] = 		{
				["Hahaha... you need Nitromirglyceronium to stop goblins from destroying a forest?! I don't care if you know Gaxim or not... I'll give you the stuff just away. The least you can do is prove you've got some skill as an alchemist before I just give you a sample of my greatest creation."] = 1073,
				["Here you go, stranger. Take heed with it though... it's volatile stuff. If you're really a friend of Gaxim's, then tell him I say hello. If though... it's volatile stuff. If you're really a friend of Gaxim's, then tell him I say hello. If you're not, then have fun blowin' yerself up."] = 1074
			}
		},
		["Vorlus Vilehoof"] = 1683,
		["The Shade of Elura"] = 1686,
		["Smith Mathiel"] = 1692,
		["Destiny Calls"] = 2242,
		["Ken'zigla's Draught"] = 1511,
		["Cenarius' Legacy"] = 1087,
		["Ordanus"] = 1088,
		["The Den"] = 1089,
		["Return to Nessa"] = 6343,
		["Super Reaper 6000"] = 1093,
		["Gerenzo Wrenchwhistle"] = 1096,
		["Erion's Behest"] = 2260,
		["Rabine Saturna"] = 	{
			["Mathrengyl Bearwalker"] = 6762,
			["Arch Druid Hamuul Runetotem"] = 1123
		},
		["Nessa Shadowsong"] = 6344,
		["Gryth Thurden"] = 6388,
		["Gerenzo's Orders"] = 	{
			["Piznik"] = 		{
				["You know, I was once the second most important person here at this site. That all changed when Gerenzo took over. Fired my boss, Ziz ore to be mined. I can get you a sample to bring to Ziz, but you'll have to watch for patrols while I get it."] = 1090,
				["I guess I'd better think about getting out of here, also. It won't take long for word of what happened here to spread to the the ore sample to Ziz right away. He told me that he'd set up camp somewhere on the western side of Windshear Crag. Good luck."] = 1092
			}
		},
		["A Vengeful Fate"] = 1102,
		["Rocket Car Parts"] = 1110,
		["Delivery to the Gnomes"] = 1114,
		["The Rumormonger"] = 1115,
		["Back to Booty Bay"] = 1118,
		["Get the Gnomes Drunk"] = 1120,
		["Get the Goblins Drunk"] = 1121,
		["Report Back to Fizzlebub"] = 1122,
		["Hemet Nesingwary Jr."] = 5762,
		["Hardened Shells"] = 1105,
		["Encrusted Tail Fins"] = 1107,
		["Gahz'rilla"] = 2770,
		["Salt Flat Venom"] = 1104,
		["Martek the Exiled"] = 1106,
		["Supplies to Auberdine"] = 976,
		["A Threat in Feralas"] = 2981,
		["Betrayed"] = 	{
			["Belgrom Rockmaul"] = 3504,
			["Ag'tor Bloodfist"] = 		{
				["I thought as much. We start our crusade against her workers along the southern bluffs on the northern peninsula of Azshara. Kill them with bloody rage--let find her personal camp. Scouting out where we can attack her would be wise. Perhaps there is something there we can use to provoke her."] = 3505,
				["Return to Belgrom in Orgrimmar. He will want to see her head for himself! We'll return there shortly. Ah, this is indeed a good day. Thank He will want to see her head for himself! We'll return there shortly. Ah, this is indeed a good day. Thank you for your help, $N."] = 3507
			},
			["Kaldorei Tome of Summoning"] = 3506
		},
		["To Steal From Thieves"] = 1164,
		["Final Passage"] = 1394,
		["The Burning of Spirits"] = 1435,
		["The Corrupter"] = 	{
			["Maurin Bonesplitter"] = 		{
				["I believe I can find this demon lord given the proper reagents. If he is indeed as powerful as I suspect, I will need items gathered from a satyr--but not any satyr. The scalp must come from a Hatefury shadowstalker. Search for them among the ancient ruins in the northeast of Desolace."] = 1481,
				["An oracle crystal would do nicely. They are crafted by the naga for their oracles to use. Northwest of here, along the coast, is a vast and will not react kindly to your intrusions, so be careful and make haste. When you return, we shall see about finding this demon lord Azrethoc."] = 1482,
				["This creature is far more dangerous than I had anticipated. No doubt Takata questions my abilities to take on such a creature, and it would to slay the demon if he would allow it, but do not press too hard. It is better if he thinks it his own idea."] = 1484
			},
			["Takata Steelblade"] = 1488,
			["Flayed Demon Skin (old2)"] = 1480,
			["Flayed Demon Skin"] = 1480
		},
		["Overlord Mok'Morokk's Concern"] = 1166,
		["The Brood of Onyxia"] = 	{
			["Overlord Mok'Morokk"] = 1171,
			["Draz'Zilb"] = 		{
				["Stonemaul Village was invaded by the brood of Onyxia. But why would the daughter of the black dragonlord, Deathwing, descend upon our lands? This is most troubling. Surely, Onyxia was driven here for a purpose beyond laying siege to a small band of ogres. Notify Mok'Morokk at once! Action must be taken."] = 1170,
				["Onyxia's brood has been scattered across the Dragonmurk. It is imperative that no more whelps be permitted to hatch. Make haste to Wyrmbog in the south and destroy them. We will never reclaim Stonemaul Village if the surrounding area remains a breeding ground. As for Mok'Morokk... I have other plans for the sod."] = 1172
			}
		},
		["Challenge Overlord Mok'Morokk"] = 1173,
		["Identifying the Brood"] = 1169,
		["Army of the Black Dragon"] = 1168,
		["Hungry!"] = 1177,
		["Willix the Importer"] = 1144,
		["Mortality Wanes"] = 1142,
		["A New Cloak's Sheen"] = 2973,
		["A Grim Discovery"] = 	{
			["Krueg Skullsplitter"] = 		{
				["What!? You came across tauren in the area? You're joking! What did they look like!? The Grimtotem clan! You found some of them? Belgrom, one of Grimtotem are not to be trifled with or underestimated. Go back and slay them; let the rivers in Feralas run red with their dark blood."] = 2974,
				["What?! Ah, so I did mention a bounty, didn't I? Well, that'll teach me to open my mouth, won't it? You did the work, so I suppose he'll want to know what you saw and he'll reward you for your hard work. Be well, $c, and thank you again for everything you've done."] = 2976
			}
		},
		["Return to Podrig"] = 6324,
		["Michael Garrett"] = 6322,
		["The Balnir Farmstead"] = 1882,
		["Speak with Deino"] = 	{
			["Anastasia Hartwell"] = 1943,
			["Quithas"] = 1943
		},
		["Return to the Marsh"] = 	{
			["Anastasia Hartwell"] = 1953,
			["Bink"] = 1953,
			["Jennea Cannon"] = 1953,
			["Uthel'nay"] = 1953
		},
		["Investigate the Alchemist Shop"] = 1960,
		["Gathering Materials"] = 	{
			["Anastasia Hartwell"] = 1961,
			["Jennea Cannon"] = 1921
		},
		["Indurium"] = 1108,
		["News for Fizzle"] = 1137,
		["A Bump in the Road"] = 1175,
		["Load Lightening"] = 1176,
		["The Eighteenth Pilot"] = 1186,
		["Keeping Pace"] = 1190,
		["Razzeric's Tweaking"] = 1187,
		["Safety First"] = 	{
			["Razzeric"] = 1188,
			["Shreev"] = 1189
		},
		["The Sacred Flame"] = 	{
			["Zangen Stonehoof"] = 		{
				["The Galak centaur in the Thousand Needles are protecting an artifact from the time of the centaurs' creation. We would like to retrieve it, but we Ashenvale Forest. There is a moonwell near the western bank of the Falfarren River, south of the main road, where you can fill the phial."] = 1195,
				["Bring the filled phial to Rau Cliffrunner at the Freewind Post in southeastern Thousand Needles. You can get to the Thousand Needles by taking the the Thousand Needles by taking the Great Lift at the southern edge of the Barrens. I wouldn't be surprised if you can help us out further."] = 1196
			},
			["Rau Cliffrunner"] = 1197
		},
		["Twilight Falls"] = 1199,
		["In Search of Thaelrid"] = 1198,
		["Blackfathom Villainy"] = 	{
			["Argent Guard Thaelrid"] = 		{
				["Strength has left me. Your help is needed! Long ago this site was a great temple of Elune. But misfortune led to ruin when the corruption occupy these grounds. The cultists, led by Kelris, sacrifice innocents to Aku'Mai for power. Slay Kelris and bring his head to Selgorm in Darnassus, $N, please."] = 1200,
				["Strength has left me. Your help is needed! Long ago this site was a great temple of Elune. But misfortune led to ruin when the corruption these grounds. The cultists, led by Kelris, sacrifice innocents to Aku'Mai for power. Slay Kelris and bring his head to Bashana in Thunder Bluff, $N, please."] = 6561
			}
		},
		["Theramore Spies"] = 1201,
		["The Theramore Docks"] = 1202,
		["The Troll Witchdoctor"] = 1240,
		["Report to Zor"] = 1262,
		["Jarl Needs a Blade"] = 1203,
		["Jarl Needs Eyes"] = 1206,
		["Marsh Frog Legs"] = 1218,
		["Mudrock Soup and Bugs"] = 1204,
		["... and Bugs"] = 1258,
		["Stinky's Escape"] = 	{
			["'Stinky' Ignatz"] = 		{
				["Great, finally something that doesn't want to eat me! I need help handling the critters around here, and you fit the mold, $gbuddy:lady;. The cook Morgan Stern for a bogbean plant... I got myself surrounded! Can you help me out of here, and watch my back as I look for the bogbean?"] = 1222,
				["Great, finally something that doesn't want to eat me!! I need help handling the critters around here, and you fit the mold, $gbuddy:lady;. A goblin from Ratchet got myself surrounded before I found the bogbean! Can you help me out of here, and watch my back as I look for Mebok's plant?"] = 1270
			}
		},
		["They Call Him Smiling Jim"] = 1282,
		["The Black Shield"] = 	{
			["Krog"] = 		{
				["Ah, I remember now! Mosarn is a well-respected blacksmith in Thunder Bluff. I knew I had heard his name somewhere, before. In thanks, the Earthen Ring more about the shield he crafted. It's not much of a lead, but since we didn't get anything useful out of Reethe, it's all we have."] = 1276,
				["Hmm... I don't see anything out of the ordinary with this shield. We should have Do'gol, the blacksmith, take a look at it, and see have Do'gol, the blacksmith, take a look at it, and see if he can tell us more about it, but I wouldn't hold out hope..."] = 1321
			},
			["Caz Twosprocket"] = 1320,
			["Captain Garran Vimes"] = 1319,
			["Do'gol"] = 		{
				["Hmmm, there's writing right here on the rim of the shield, but it's hard to read from all the burned stuff. I need acid to make have taken over an old mine, the Darkmist Cavern, northwest of the village. Get me some of their sacs and I can clean this up."] = 1322,
				["Oh, I think I might have dropped too much acid onto the shield. Let me just rub a little... Hm, kind of hard to read, but a little... Hm, kind of hard to read, but it looks like the name Mosarn. Never heard of him. Maybe Krog knows. Krog knows many people."] = 1323
			},
			["Black Shield"] = 1253
		},
		["Lieutenant Paval Reethe"] = 	{
			["Captain Garran Vimes"] = 1259,
			["Theramore Guard Badge"] = 		{
				["A glint of light on the ground catches your eye from underneath the rubble. Brushing away debris and ash caked onto the object reveals the the insignia of a gold anchor on white enameled on the surface: the sign of Theramore. Underneath the anchor is embossed the name 'Lieutenant Paval Reethe'."] = 1252,
				["A glint of light on the ground catches your eye from underneath the rubble. Brushing debris and ash caked onto the object reveals the insignia the insignia of a gold anchor on white, enameled on the surface: the sign of Theramore. Underneath the anchor is embossed the name 'Lieutenant Paval Reethe'."] = 1269
			}
		},
		["The Deserters"] = 	{
			["Captain Garran Vimes"] = 1286,
			["Balos Jacken"] = 1287
		},
		["Captain Vimes"] = 1220,
		["Daelin's Men"] = 1285,
		["The Eastern Kingdoms"] = 4002,
		["The Royal Rescue"] = 4003,
		["For The Horde!"] = 4974,
		["What the Wind Carries"] = 6566,
		["The Champion of the Horde"] = 6567,
		["Shadowshard Fragments"] = 	{
			["Archmage Tervosh"] = 7070,
			["Uthel'nay"] = 7068
		},
		["Questioning Reethe"] = 1273,
		["The Corruption Abroad"] = 3765,
		["James Hyal"] = 	{
			["Connor Rivers"] = 1301,
			["Vincent Hyal"] = 1302
		},
		["Assisting Arch Druid Staghelm"] = 	{
			["Innkeeper Firebrew"] = 3789,
			["Innkeeper Saelienne"] = 3763,
			["Innkeeper Allison"] = 3790
		},
		["Chicken Clucking for a Mint"] = 	{
			["Innkeeper Firebrew"] = 8353,
			["Innkeeper Norman"] = 8354
		},
		["Mage-tastic Gizmonitor"] = 1880,
		["High Sorcerer Andromath"] = 	{
			["Bink"] = 1939,
			["Jennea Cannon"] = 1939,
			["Harnan"] = 1939
		},
		["The Tome of Nobility"] = 	{
			["Brandur Ironhammer"] = 4486,
			["Arthur the Faithful"] = 4485
		},
		["Alliance Trauma"] = 6625,
		["I Know A Guy..."] = 6612,
		["I Got Nothin' Left!"] = 6609,
		["The Art of the Armorsmith"] = 	{
			["Grumnus Steelshaper"] = 5283,
			["Okothos Ironrager"] = 5301
		},
		["Simple Subterfugin'"] = 2238,
		["Kingly Shakedown"] = 2298,
		["Errand for Apothecary Zinge"] = 	{
			["Apothecary Zinge"] = 232,
			["Alessandro Luca"] = 238
		},
		["Into the Field"] = 243,
		["Sample for Helbrim"] = 1358,
		["Vivian Lagrave"] = 4133,
		["Vivian Lagrave and the Darkstone Tablet"] = 4769,
		["In Eranikus' Own Words"] = 3512,
		["In Search of The Temple"] = 1448,
		["To The Hinterlands"] = 1449,
		["Into The Temple of Atal'Hakkar"] = 1475,
		["Galen's Escape"] = 1393,
		["Coyote Thieves"] = 1419,
		["Report to Helgrum"] = 1420,
		["Khan Dez'hepah"] = 1365,
		["Centaur Bounty"] = 	{
			["Felgur Twocuts"] = 1366,
			["Corporal Melkins"] = 1387
		},
		["Strange Alliance"] = 1382,
		["Brutal Politics"] = 1385,
		["Stealing Supplies"] = 1370,
		["Ongeku"] = 1373,
		["Khan Jehn"] = 1374,
		["Khan Hratha"] = 	{
			["Uthek the Wise"] = 1380,
			["Warug"] = 1381
		},
		["Raid on the Kolkar"] = 1384,
		["Broken Tears"] = 1369,
		["Gizmo for Warug"] = 1371,
		["Khan Shaka"] = 1375,
		["Assault on the Kolkar"] = 1386,
		["Fire Plume Forged"] = 	{
			["Krinkle Goodsteel"] = 		{
				["You need two bars of thorium and a powerfully hot heat source to forge the key stem. You're on your own for the thorium, but up top; the lava will take care of the rest. That's it on my end. To finish your key, you'll need to talk to Arbington again."] = 5801,
				["You need two bars of thorium and a powerfully hot heat source to forge the key stem. You're on your own for the thorium, but up top; the lava will take care of the rest. That's it on my end. To finish your key, you'll need to talk to Dithers again."] = 5802
			}
		},
		["Magram Alliance"] = 1367,
		["Gelkis Alliance"] = 1368,
		["Grimand Elmore"] = 1700,
		["Fire Hardened Mail"] = 1701,
		["Mathiel"] = 1703,
		["Klockmort Spannerspan"] = 1704,
		["Nothing But The Truth"] = 	{
			["Apothecary Faustin"] = 		{
				["I have just the right serum in mind. It will deal with the truth in precisely the way the truth should be dealt with. For this need for the serum is the blood of a dreaming whelp, like the ones that live outside Itharius' cave in the swamp. Now, off you go!"] = 1383,
				["Everything is proceeding according to plan, $n. I want you to give this truth serum to Deathstalker Zraedus and he'll show you how to administer proceeding according to plan, $n. I want you to give this truth serum to Deathstalker Zraedus and he'll show you how to administer it.... properly. Haha!"] = 1388
			},
			["Deathstalker Zraedus"] = 		{
				["Our expeditionary force was sent at Varimathras's behest to survey lower Azeroth. While out scouting I noticed a human Infiltrator spying on Beggar's Haunt. Before I see our camp here but nonetheless I want to lend a hand. Work with Faustin here to develop a... truth serum for our friend in Stonard."] = 1372,
				["We need to operate with a certain amount of discretion. After all, it's not like you're going to waltz in there and convince the fool reluctance when it comes to chug-a-lugging a brew. Make haste to Stonard in the Swamp of Sorrows, $n. And keep our little mission nice and quiet..."] = 1391
			}
		},
		["Supplies for Nethergarde"] = 1395,
		["Encroaching Wildlife"] = 1396,
		["Driftwood"] = 1398,
		["The Lost Caravan"] = 1421,
		["Deliver the Shipment"] = 1425,
		["Yorus Barleybrew"] = 1698,
		["Mirror Lake"] = 1861,
		["Investigate the Blue Recluse"] = 1920,
		["Journey to the Marsh"] = 	{
			["Jennea Cannon"] = 1947,
			["Deino"] = 1947
		},
		["Mor'zul Bloodbringer"] = 	{
			["Spackle Thornberry"] = 7562,
			["Martha Strain"] = 7562,
			["Kurgul"] = 7562,
			["Jubahl Corpseseeker"] = 7562,
			["Greshka"] = 7562,
			["Torian"] = 7562,
			["Matero Zeshuwal"] = 7562
		},
		["Until Death Do Us Part"] = 264,
		["Jonespyre's Request"] = 	{
			["Tannysa"] = 3787,
			["Innkeeper Shyria"] = 3788
		},
		["Lack of Surplus"] = 	{
			["Dar"] = 698,
			["Tok'Kar"] = 699
		},
		["Fresh Meat"] = 1430,
		["Threat From the Sea"] = 	{
			["Tok'Kar"] = 1422,
			["Katar"] = 		{
				["I have no love for the sea, nor any creature I've seen come from its depths. It is a powerful but blind mistress; callous and any who do the Horde's will. Which brings us to you, $c. How many can you slay? Would you test yourself against their most powerful kind?"] = 1426,
				["Before you take rest, speak to Tok'Kar again. While you were gone I believe he finished a few weapons. For your help here, he would them to you. You would do well to test its strength against the fish men when you are ready... but only to please me further."] = 1427
			}
		},
		["Continued Threat"] = 1428,
		["Insect Part Analysis"] = 	{
			["Alchemist Pestlezugg"] = 113,
			["Senior Surveyor Fizzledowser"] = 110
		},
		["Bungle in the Jungle"] = 4496,
		["Pawn Captures Queen"] = 4507,
		["Calm Before the Storm"] = 	{
			["Alchemist Pestlezugg"] = 		{
				["My recent findings and the knowledge we have gained here today needs to reach hands that can quite possibly do something with it. As resourceful got friends who are Alliance bigwigs; if we can get them involved in this $N, then we just might make it out of this alive."] = 4508,
				["My recent findings and the knowledge we have gained here today needs to reach hands that can quite possibly do something with it. As resourceful who are high within the Horde; if we can get them involved in this $N, then we just might make it out of this alive."] = 4509
			},
			["Zilzibin Drumlore"] = 4511,
			["Gracina Spiritmight"] = 4510
		},
		["Return to Fel'Zerul"] = 1444,
		["Jammal'an the Prophet"] = 1446,
		["Rhapsody's Kalimdor Kocktail"] = 1452,
		["Rhapsody's Tale"] = 1469,
		["Gryphon Master Talonaxe"] = 1450,
		["Rhapsody Shindigger"] = 1451,
		["Witherbark Cages"] = 2988,
		["The Altar of Zul"] = 2989,
		["Thadius Grimshade"] = 2990,
		["Saving Sharpbeak"] = 2994,
		["Reclaimers' Business in Desolace"] = 1453,
		["The Karnitol Shipwreck"] = 	{
			["Kreldig Ungor"] = 		{
				["My first order of business is for the mage Karnitol--a noble of some sort in Stormwind. Seems his ship was attacked by sea giants while it and teleport himself and his servants to safety. He wants us to find the chest and its contents, and return it to him in Stormwind."] = 1454,
				["Intriguing. Well, we might not be without hope quite yet. Along that same coast, but to the north near Ranazjar Isle, there're night elf ruins at the south, then they must've been pretty powerful. If you're gonna find Karnitol's belongings, I'd start with the more powerful naga: the tidehunters or sea witches."] = 1456,
				["Take Karnitol's things back to Roetten in Ironforge and he'll pay you for a job well done. Haha, if you're not careful, he's gonna be so job, $N. Be careful on your way back, and don't take too much time--Karnitol's not the most of patient of men, but he's very generous nonetheless."] = 1457
			},
			["Karnitol's Chest"] = 1455
		},
		["Reagents for Reclaimers Inc."] = 	{
			["Kreldig Ungor"] = 		{
				["One of my tasks out here involves picking up some reagents for Leftwitch, a gnome mage in Kharanos . Roetten seems to think it's easy claws from the Hatefury satyr to the east of here. Bring 'em back to me and we'll get started on the rest of the list."] = 1458,
				["Next on Leftwitch's list is... let's see... hmm. Oh, here it is. Simple enough, but pretty explicit in his directions. He needs venom from the scorpashi, got to come from an aged kodo, not the dying or ancient ones. Mages, I tell ya, some of the stuff they want... it's just weird."] = 1459,
				["This is the last of the items, and I won't lie, it ain't pretty. I'm also expecting this to take you a little bit longer sorceress. And... ten vials of doomwarder blood from a doomwarder captain, or lord. Simple enough, huh? Sheesh... if you wanna pass on this one, I'd understand."] = 1466,
				["To get paid, you're gonna have to get back to Ironforge and speak to Roetten himself. He'll love getting Leftwitch's package out of the way booty. And don't worry, I'm still going to put in a good word for you when I get back. I shouldn't be in Desolace much longer."] = 1467
			}
		},
		["Alliance Relations"] = 	{
			["Craven Drok"] = 1431,
			["Keldran"] = 1432,
			["Takata Steelblade"] = 		{
				["The Burning Blade have many agendas, but know that they are evil to their core, their spirits corrupted, and their destruction is the only way plots against the Blade while I deal with the other demonic threats here in Desolace. Speak to him, and he will guide you in his designs."] = 1433,
				["The fight goes well, $N. Perhaps the Warchief will allow us to return to our homes before the seasons change if we continue to make reward you for your efforts here. His cause is important to him, and he will take pride in knowing that the Warchief respects his concerns."] = 1436
			}
		},
		["Befouled by Satyr"] = 1434,
		["Vahlarriel's Search"] = 	{
			["Vahlarriel Demonslayer"] = 		{
				["I am Vahlarriel, $N. I've come here to discover the whereabouts of two missing nobles of a Darnassian merchant family--House Malem. The father of the be here long. Last word tells of them passing through the Stonetalon Mountains a few weeks ago. If you find their wagon, please, come find me immediately."] = 1437,
				["Find both Dalinda and Tyranis if you can and come back to me with your findings. Start your search at this fortress. I will contact here. It is more important to them that Dalinda is found and brought back safely. Tyranis is to be... gauged before he is taken home."] = 1438
			},
			["Malem Chest"] = 1465
		},
		["Search for Tyranis"] = 1439,
		["Return to Vahlarriel"] = 1440,
		["Reclaimed Treasures"] = 	{
			["Patrick Garrett"] = 2342,
			["Krom Stoutarm"] = 1360
		},
		["The Binding"] = 	{
			["Carendin Halgar"] = 		{
				["Surely you have seen the circle of summoning below us? Only there will you be able to draw forth an unbound voidwalker. Using these runes, you to you. Come to me then, and I will elucidate the spell of summoning, so that it may serve you to whatever end you wish."] = 1471,
				["Using these hearts, cast a spell at the summoning circle to open a doorway for the succubus to come through. Your powers are greater now, will. When overcome, the succubus will be returned to the void, and I will teach you the spell to summon it forth at your command."] = 1474
			},
			["Gan'rul Bloodeye"] = 		{
				["Now, observe the Tablet of Verga, for it contains the glyphs you will need for the summoning. Take them to the circle in Neeru Fireblade's When this is completed, return to me with the glyphs of summoning and I will demonstrate how you may bind the creature to your will."] = 1504,
				["Take this to the summoning circle in Neeru's tent, $n. Summon forth a foul succubus, then show it your mastery. I believe in the strength overconfidence has overcome many a promising warlock. When you have defeated it, return the pendant to me so that I might deliver the news to Zankaja."] = 1513
			},
			["Gakin the Darkbinder"] = 		{
				["By retrieving my choker and besting Surena, you've proven that you're at least as capable as she was. With that said, I can tell you're direly summoning circle and subdue it using whatever weapons--physical and magical--you have at your disposal. Use the magic of this choker at the summoning circle below."] = 1689,
				["Using the heartswood core, you will be able to cast a spell at the summoning circle in the crypt below to open a portal for of minds. Once you have bested and returned it to the void, return to me and I will show you how to call and control it."] = 1739
			},
			["Strahad Farsan"] = 1795
		},
		["Devourer of Souls"] = 	{
			["Carendin Halgar"] = 1472,
			["Gan'rul Bloodeye"] = 1507,
			["Gakin the Darkbinder"] = 1716
		},
		["Creature of the Void"] = 	{
			["Carendin Halgar"] = 1473,
			["Gan'rul Bloodeye"] = 1501
		},
		["Seeking Strahad"] = 	{
			["Carendin Halgar"] = 3001,
			["Gan'rul Bloodeye"] = 2996,
			["Lago Blackwrench"] = 1798,
			["Gakin the Darkbinder"] = 1798,
			["Alamma"] = 3001
		},
		["Hearts of the Pure"] = 1476,
		["Vital Supplies"] = 1477,
		["Ur's Treatise on Shadow Magic"] = 1938,
		["Pristine Spider Silk"] = 1940,
		["Halgar's Summons"] = 1478,
		["Deviate Hides"] = 1486,
		["Deviate Eradication"] = 1487,
		["The Barrens Oases"] = 886,
		["Nara Wildmane"] = 1490,
		["Leaders of the Fang"] = 914,
		["Path of Defense"] = 1498,
		["Thun'grim Firegaze"] = 1502,
		["Forged Steel"] = 1503,
		["Brutal Armor"] = 1838,
		["Ula'elek and the Brutal Gauntlets"] = 1839,
		["Orm Stonehoof and the Brutal Helm"] = 1840,
		["Velora Nitely and the Brutal Legguards"] = 1841,
		["Ju-Ju Heaps"] = 1884,
		["Waters of Xavian"] = 1944,
		["Laughing Sisters"] = 1945,
		["Call of Earth"] = 	{
			["Canaga Earthcaller"] = 		{
				["The time is now, young $c. You've grown strong and your spirit endures like the earth. Following the shaman's path shows you have wisdom before the Felstalkers to the north, and take from them two of their hooves. Return to me then, and we shall speak more of your future. "] = 1516,
				["A sapta is a drink created to bind our spirits to the elements. Fused with magic, the potion will allow the strong willed to see that. Seek out Spirit Rock southwest of here--it is found at the end of the Hidden Path. Drink your sapta there, and... well, you shall see."] = 1517
			},
			["Seer Ravenfeather"] = 		{
				["The time has come, young $c. Your body ages and grows strong, and your spirit endures like the earth. I see it within you-you have the east, and take from them a salve they use in their rituals. Return to me only when you have enough for your own potion."] = 1519,
				["A sapta is a drink created to bind our spirits to the elements. Fused with magic, the potion will allow the open minded to see is always imbibed in a holy place, and never anywhere else. Seek out the shaman shrine to the east of here and drink of the sapta."] = 1520
			},
			["Minor Manifestation of Earth"] = 		{
				["Take this rough quartz from me and bring it to Canaga Earthcaller as proof of our meeting. He will craft a totem for you, and seek wisdom. This is what earth asks of you. In the end, you shall become one with the earth--respect it as it shall respect you."] = 1518,
				["Take this rough quartz from me and bring it to Seer Ravenfeather as proof of our meeting. She will craft a totem for you, and seek wisdom. This is what earth asks of you. In the end, you shall become one with the earth--respect it as it shall respect you."] = 1521
			}
		},
		["Call of Air"] = 	{
			["Searn Firewarder"] = 1531,
			["Xanis Flameweaver"] = 1532
		},
		["Cleansed Water Returns to Felwood"] = 5159,
		["Love's Gift"] = 1512,
		["Blind Cazul"] = 1508,
		["Dogran's Captivity"] = 1515,
		["Tooga's Quest"] = 1560,
		["Ghost-o-plasm Round Up"] = 6134,
		["Supplying the Front"] = 1578,
		["Gearing Redridge"] = 1618,
		["Ironband's Compound"] = 1681,
		["Moonglow Vest"] = 1582,
		["Bartleby the Drunk"] = 1639,
		["Marshal Haggard"] = 1666,
		["Beat Bartleby"] = 1640,
		["Bartleby's Mug"] = 1665,
		["Vejrek"] = 1678,
		["Tormus Deepforge"] = 1680,
		["The Slaughtered Lamb"] = 1715,
		["Gakin's Summons"] = 	{
			["Lago Blackwrench"] = 1717,
			["Remen Marcot"] = 1685
		},
		["Surena Caledon"] = 1688,
		["The Name of the Beast"] = 	{
			["Lord Arkkoroc"] = 		{
				["She kills my children, mortal. She that calls herself the ruler of these oceans. A false god, nothing more. Crush her and bring back all be given the name that you seek and something else of equal importance. She roams the clutch... Hetaera she is called. <Lord Arkkoroc points to the southwest.> Go! "] = 3510,
				["As promised, I will reveal the name of the demon lord, Razelikh the Defiler. First, however, I must prepare something of utmost importance for your the heads in between his gigantic fists, draining them of their blood.> Take the temper back to Loramus along with the name of the beast: Rakh'likh."] = 3511
			},
			["Loramus Thalipedes"] = 3509
		},
		["Sunscorched Shells"] = 1710,
		["Klockmort's Essentials"] = 2925,
		["The Rethban Gauntlet"] = 1699,
		["The Shieldsmith"] = 1702,
		["Iron Coral"] = 1708,
		["Essential Artificials"] = 2924,
		["The Tome of Divinity"] = 	{
			["Duthorian Rall"] = 		{
				["Your task then, $N, is to find someone here in Stormwind that is in need of aid. Someone who is pure of heart and motive. to me when you are finished. Then, we shall discuss more of your path and what it means to be a paladin of the Light."] = 1643,
				["Take this, $N. It is called the Symbol of Life. You've proven charitable and patient, and now the time has come to see if you're powerful priests. Take the Symbol and speak to him. If you can help him, then we will speak again soon. May you bask in the Light's glory."] = 1781
			},
			["Henze Faulk"] = 1787,
			["Gazin Tenorm"] = 		{
				["Henze and I had made it to Heroes' Vigil, an island in the middle of Stone Cairn Lake in northeastern Elwynn. We'd heard the Defias held them off for me while I escaped... the daft fool, going and being brave. He's out there now, Henze is. Can you help us, $N?"] = 1786,
				["I'll take the script to the King's advisors after Duthorian's taken a look at them, but in the meantime, you should go speak to Duthorian to pat you on the back for sure! Thank you again, $N. I hope we meet again. You're surely an ally I'm proud to call friend."] = 1788
			},
			["Stephanie Turner"] = 		{
				["Bless their hearts, most of them have no families because of the Scourge attacks in the last decade. My husband John collects the materials for me thank you, $N. If you could bring me some linen cloth so I can sew clothes for the kids, that would help me out so much."] = 1644,
				["I'll take these to the children this very day. Please be safe, good $c. It is not often $G men:women; of your character show their character show their faces in the city, but you've proven that the paladins here in Stormwind shall never turn their backs on those in need. Farewell."] = 1780
			},
			["John Turner"] = 		{
				["My wife and I run an orphanage in Stormwind, mostly for children who have lost parents due to the attacks by the Scourge in the and not very productive. If I could just get some more linen for my wife to make some clothes, I could finally send a shipment home."] = 1648,
				["I'm going to see about making plans to return home soon. Hopefully, Stephanie is doing well back in Stormwind. I can't wait to see her plans to return home soon. Hopefully, Stephanie is doing well back in Stormwind. I can't wait to see her again. Till next we meet, $c."] = 1778
			},
			["Narm Faulk"] = 1784,
			["Muiredon Battleforge"] = 		{
				["We was spyin' on some of the Dark Iron dwarves that've bunkered down south of Helm's Bed Lake. We knew they was up to no Narm tol' me to run an' get support, so 'ere I am. Narm needs help, an' I'll not rest till he gets it. C'n ya help, $N?"] = 1783,
				["I c'n see me wife's o'er there beamin' wit pride already. Ya better get yer tuchus o'er there pronto. I be thinkin' she'd have some wit ya. Light be witcha, mighty $c. I'll be lookin' fer ya on the battlefield against the Scourge and dem Dark Irons when the time comes."] = 1785
			},
			["Tiza Battleforge"] = 		{
				["Your task then, $N, is to find someone here in Ironforge that is in need of aid. Someone who is pure of heart and motive. means to be a paladin of the Light. I will remain here in the temple for your return. Other paladins will need my guidance also."] = 1647,
				["I want you to take this, $N. It is called the Symbol of Life. You've proven charitable and patient, and now I want you to prove our priests. Take the Symbol and speak to him. If you can help him, then we will speak again soon. May the Light shine upon you."] = 1779
			},
			["Tome of Divinity"] = 1646
		},
		["The Tome of Valor"] = 	{
			["Duthorian Rall"] = 1650,
			["Daphne Stilwell"] = 		{
				["Now, they'll be coming again soon, I'd wager, so get yourself ready. I've got myself a gun in the house. I'll grab it and be ready they sent earlier. Ask the Light for whatever blessings you can because... did you hear that? I think they're coming. We make our stand near the house!"] = 1651,
				["Please, return to Duthorian and let him know that I'm safe for now. I have you and the Church to thank for that. He'll send word word to Ironforge to let my Jordan know that he has nothing to fear. Oh, how I miss my husband. I can't wait till he returns."] = 1652
			},
			["Tome of Valor"] = 1649
		},
		["The Test of Righteousness"] = 	{
			["Duthorian Rall"] = 1653,
			["Jordan Stilwell"] = 		{
				["I'd like to reward you if you'd be willing to accept such a thing? Don't misunderstand me, my generosity is dependent on how much help it. I've already started taking notes on the items, it just requires someone brave and skilled enough to recover them. What do you say, $c?"] = 1654,
				["Why don't we go over to the forge and get started on this? I've been preparing for your arrival for some time, so it shouldn't your exploits makes me somewhat envious. But knowing that I can contribute to your adventures in my own significant way does bring me some joy."] = 1806
			}
		},
		["Lord Grayson Shadowbreaker"] = 7638,
		["Cyclonian"] = 1712,
		["The Summoning"] = 1713,
		["Spirit Totem"] = 8412,
		["Da Voodoo"] = 8413,
		["The Affray"] = 1719,
		["The Windwatcher"] = 1791,
		["Bailor's Ore Shipment"] = 1655,
		["Heartswood"] = 1738,
		["The Orb of Soran'ruk"] = 1740,
		["Tome of the Cabal"] = 	{
			["Strahad Farsan"] = 		{
				["It will take more than a simple summoning circle to bring forth a felhunter for you to challenge. My three acolytes and I will assist in Stoutarm can help you with this. An itinerant warlock these days, he spends his days hoarding ancient texts and skulking about the library in Ironforge."] = 1758,
				["It will take more than a simple summoning circle to bring forth a felhunter for you to challenge. My three acolytes and I will assist in help you with this. He's employed as a cartographer in the Undercity these days, but still knows more of ancient texts than any I know."] = 1801
			},
			["Jorah Annison"] = 		{
				["Ah! I see that you are a warlock of similar tastes to mine. Indeed, acquiring the Tome of the Cabal is a worthy aspiration. Did of the Thousand Needles. The rest of the text was to be transferred to Ironforge, but was lost in transit on the coast west of Southshore."] = 1803,
				["This is one of the most interesting texts I have perused in the last few years. The selection here is sparse--mostly books on geography--and I me to look at this text, I will share a secret: You can find the rods on orcs of the Dragonmaw Clan in the Wetlands."] = 1805
			},
			["Krom Stoutarm"] = 		{
				["It was lost, but there's some idea as to where it might be found. There was only one copy ever made and it was vandalized at Harbor by boat. It never arrived. In exchange for this knowledge, all I ask is that if you find it, bring it to me to see."] = 1802,
				["Well, ah, it's hard to let it go. But you found it, and you have more important things to do with it, of course. Just, where to find them, but I do! They were last used by the orcs of the Dragonmaw clan in the Wetlands. I'd check their spellcasters!"] = 1804
			}
		},
		["Shard of an Infernal"] = 4963,
		["Shard of a Felhound"] = 4962,
		["Fragments of the Orb of Orahil"] = 1799,
		["The Completed Robe"] = 4786,
		["The Completed Orb of Dar'Orahil"] = 4964,
		["The Completed Orb of Noh'Orahil"] = 4975,
		["Recipe of the Kaldorei"] = 4161,
		["Deep Ocean, Vast Sea"] = 982,
		["Supplying the Sepulcher"] = 6321,
		["Trial at the Field of Giants"] = 1824,
		["Speak with Thun'grim"] = 1825,
		["Satyr Hooves"] = 1842,
		["Chimaeric Horn"] = 1844,
		["Dragonmaw Shinbones"] = 1846,
		["The Shattered Hand"] = 	{
			["Therzok"] = 		{
				["I'll leave it to you to get Tazan's satchel open, and return to me with its contents. The locking mechanism is complex, so it would He had an assistant named Gamon. A drunkard, you'll most likely find him at the tavern. Perhaps you could quietly relieve him of the key."] = 1858,
				["The Warchief is too subtle in his methods. He is cautious to unleash the might of the Horde. Once we were stronger, mighty conquerors all. to prove your worth. The troll Tazan trades with the pirates near Ratchet. He has information I must have. Kill him and bring me his satchel."] = 1963
			}
		},
		["The Deathstalkers"] = 1978,
		["Fenwick Thatros"] = 1998,
		["Tools of the Trade"] = 1999,
		["Find the Shattered Hand"] = 2378,
		["Andron's Payment to Jediga"] = 3564,
		["Items of Power"] = 1948,
		["Hidden Secrets"] = 1949,
		["Mage's Wand"] = 1952,
		["The Infernal Orb"] = 1954,
		["The Exorcism"] = 1955,
		["Power in Uldaman"] = 1956,
		["Mana Surges"] = 1957,
		["Tiara of the Deep"] = 2846,
		["Cleansing of the Orb of Orahil"] = 4961,
		["Returning the Cleansed Orb"] = 4976,
		["Get the Scoop"] = 1950,
		["Rituals of Power"] = 1951,
		["Find Bingles"] = 2039,
		["Speak with Shoni"] = 2041,
		["The Day After"] = 2927,
		["Bingles' Missing Supplies"] = 2038,
		["Underground Assault"] = 2040,
		["Gyrodrillmatic Excavationators"] = 2928,
		["Gyromast's Revenge"] = 2078,
		["Gyromast's Retrieval"] = 2098,
		["Dancing for Marzipan"] = 	{
			["Innkeeper Saelienne"] = 8357,
			["Innkeeper Pala"] = 8360
		},
		["Assisting Arch Druid Runetotem"] = 	{
			["Innkeeper Norman"] = 3784,
			["Innkeeper Pala"] = 3762,
			["Innkeeper Gryshka"] = 936
		},
		["Sealed Azure Bag"] = 8234,
		["Rest and Relaxation"] = 2158,
		["A Task Unfinished"] = 1656,
		["Dolanaar Delivery"] = 2159,
		["Supplies to Tannok"] = 2160,
		["A Rogue's Deal"] = 	{
			["Calvin Montague"] = 		{
				["Hey, mate! Do a favor for a young man who's been fighting more than his fair share of mindless zombies and spiders? I got this here be a great spot for you to rest too if the need arises. You should check it out... you do and I'll pay you well."] = 8,
				["What? What?! You want money? I don't owe you any money. Letter? What letter? Oh, you wanna fight then? All right, mate... let's do this! Owe you any want money? I don't owe you any money. Letter? What letter? Oh, you wanna fight then? All right, mate... let's do this! Owe you any money..."] = 590
			}
		},
		["A Peon's Burden"] = 2161,
		["Lore for a Price"] = 2199,
		["Back to Uldaman"] = 2200,
		["Restoring the Necklace"] = 	{
			["Talvash del Kissel"] = 2204,
			["Talvash's Scrying Bowl"] = 2204
		},
		["Gnome Improvement"] = 2948,
		["Replacement Phial"] = 3375,
		["Incoming Gumdrop"] = 	{
			["Talvash del Kissel"] = 8355,
			["Kali Remik"] = 8358
		},
		["Translating the Journal"] = 	{
			["Jarkal Mossmeld"] = 2338,
			["Remains of a Paladin"] = 2318
		},
		["Find the Gems and Power Source"] = 2339,
		["Deliver the Gems"] = 2340,
		["Onin's Report"] = 2239,
		["The Hidden Chamber"] = 2240,
		["Find the Gems"] = 2201,
		["Doras the Wind Rider Master"] = 6385,
		["Flexing for Nougat"] = 	{
			["Innkeeper Gryshka"] = 8359,
			["Innkeeper Allison"] = 8356
		},
		["Redridge Rendezvous"] = 2281,
		["Alther's Mill"] = 2282,
		["Ripple Recovery"] = 	{
			["Dran Droffers"] = 649,
			["Malton Droffers"] = 650
		},
		["Necklace Recovery"] = 2283,
		["Necklace Recovery, Take 2"] = 2284,
		["Necklace Recovery, Take 3"] = 2341,
		["Horns of Nez'ra"] = 2358,
		["March of the Silithid"] = 	{
			["Zilzibin Drumlore"] = 4494,
			["Gracina Spiritmight"] = 4493
		},
		["Klaven's Tower"] = 2359,
		["Plundering the Plunderers"] = 2381,
		["Mission: Possible But Not Probable"] = 2478,
		["Speak with Un'thuwa"] = 1883,
		["Tears of the Moon"] = 2518,
		["Sathrah's Sacrifice"] = 2520,
		["The Temple of the Moon"] = 2519,
		["The Sleeping Druid"] = 2541,
		["Druid of the Claw"] = 2561,
		["To Serve Kum'isha"] = 2521,
		["Kum'isha's Endeavors"] = 2522,
		["Everything Counts In Large Amounts"] = 3501,
		["One Draenei's Junk..."] = 3502,
		["Show Your Work"] = 	{
			["Oglethorpe Obnoticus"] = 3643,
			["Tinkmaster Overspark"] = 3641,
			["Nixx Sprocketspring"] = 3639
		},
		["Slake That Thirst"] = 379,
		["Another Power Source?"] = 841,
		["Return to Apothecary Zinge"] = 864,
		["Wastewander Justice"] = 1690,
		["More Wastewander Justice"] = 1691,
		["Divino-matic Rod"] = 2768,
		["Water Pouch Bounty"] = 1707,
		["Snickerfang Jowls"] = 2581,
		["Rage of Ages"] = 2582,
		["A Boar's Vitality"] = 2583,
		["Spirit of the Boar"] = 2584,
		["The Decisive Striker"] = 2585,
		["Salt of the Scorpok"] = 2586,
		["The Basilisk's Bite"] = 2601,
		["Infallible Mind"] = 2602,
		["Vulture's Vigor"] = 2603,
		["Spiritual Domination"] = 2604,
		["The Thirsty Goblin"] = 2605,
		["In Good Taste"] = 2606,
		["Noggenfogger Elixir"] = 2662,
		["The Disgraced One"] = 2621,
		["The Stones That Bind Us"] = 2681,
		["Heroes of Old"] = 	{
			["Fallen Hero of the Horde"] = 2702,
			["Corporal Thund Splithoof"] = 2701
		},
		["Kirith"] = 2721,
		["The Demon Hunter"] = 2744,
		["Fall From Grace"] = 2784,
		["A Tale of Sorrow"] = 2801,
		["Uniting the Shattered Amulet"] = 3627,
		["You Are Rakh'likh, Demon"] = 3628,
		["Warrior Kinship"] = 8423,
		["War on the Shadowsworn"] = 8424,
		["Voodoo Feathers"] = 8425,
		["Sprinkle's Secret Ingredient"] = 2641,
		["Delivery for Marin"] = 2661,
		["The Missing Orders"] = 2622,
		["The Swamp Talker"] = 2623,
		["The Scrimshank Redemption"] = 10,
		["Noxious Lair Investigation"] = 82,
		["Gadgetzan Water Survey"] = 992,
		["The Cover of Darkness"] = 2743,
		["The Super Snapper FX"] = 2944,
		["Handle With Care"] = 3022,
		["The Stave of Equinex"] = 2879,
		["In Search of Knowledge"] = 2939,
		["The Giant Guardian"] = 2844,
		["The Attack!"] = 434,
		["Items of Some Consequence"] = 2746,
		["Gahz'ridian"] = 3161,
		["The Stone Circle"] = 3444,
		["Into the Depths"] = 3446,
		["Secret of the Circle"] = 3447,
		["Wandering Shay"] = 2845,
		["Haze of Evil"] = 4143,
		["Dark Heart"] = 3062,
		["Vengeance on the Northspring"] = 3063,
		["The Strength of Corruption"] = 4120,
		["Lethtendris's Web"] = 	{
			["Talo Thornhoof"] = 7489,
			["Latronicus Moonspear"] = 7488
		},
		["The Ogres of Feralas"] = 	{
			["Rok Orhan"] = 		{
				["The effects of the Gordunni Ogre tribe can hardly go unnoticed in this area. Look around, $N; their very presence scars this land. We must Feralas. Follow the river north, and you will find their outpost. Decrease their numbers, $N. We must show them that their kind is not wanted here."] = 2975,
				["Now that you have proven that you are a true fighter, I trust that you possess the courage to continue with the task at hand. Travel trees and desecrated terrain, you will find the Gordunni. Push them back. These ogres are much stronger than the ones you faced previously, $N. Be aware."] = 2980
			}
		},
		["Dark Ceremony"] = 2979,
		["The Gordunni Orb"] = 3002,
		["Rin'ji is Trapped!"] = 2742,
		["Loramus"] = 3141,
		["Breaking the Ward"] = 3508,
		["Azsharite"] = 3602,
		["The Formation of Felbane"] = 3621,
		["Rescue OOX-17/TN!"] = 648,
		["Barbaric Battlements"] = 2751,
		["On Iron Pauldrons"] = 2752,
		["Trampled Under Foot"] = 2753,
		["Horns of Frenzy"] = 2754,
		["Joys of Omosh"] = 2755,
		["The Old Ways"] = 2756,
		["Booty Bay or Bust!"] = 2757,
		["The Mithril Order"] = 2760,
		["The Origins of Smithing"] = 2758,
		["In Search of Galvan"] = 2759,
		["A Sticky Situation"] = 77,
		["Ripple Delivery"] = 81,
		["Smelt On, Smelt Off"] = 2761,
		["The Great Silver Deceiver"] = 2762,
		["The Art of the Imbue"] = 2763,
		["Galvan's Finest Pupil"] = 2764,
		["Expert Blacksmith!"] = 2765,
		["Enchanted Azsharite Fel Weaponry"] = 3625,
		["Return to the Blasted Lands"] = 3626,
		["A Good Head On Your Shoulders"] = 2771,
		["The World At Your Feet"] = 2772,
		["The Mithril Kid"] = 2773,
		["Troll Temper"] = 3042,
		["Did You Lose This?"] = 3321,
		["Rescue OOX-09/HL!"] = 836,
		["Rescue OOX-22/FE!"] = 2767,
		["Lines of Communication"] = 2995,
		["Petty Squabbles"] = 2783,
		["A Fine Mess"] = 2904,
		["The Mark of Quality"] = 	{
			["Pratt McGrubben"] = 2821,
			["Jangdor Swiftstrider"] = 2822
		},
		["Wild Leather Armor"] = 	{
			["Pratt McGrubben"] = 2847,
			["Jangdor Swiftstrider"] = 2854
		},
		["Wild Leather Shoulders"] = 	{
			["Pratt McGrubben"] = 2848,
			["Jangdor Swiftstrider"] = 2855
		},
		["Wild Leather Vest"] = 	{
			["Pratt McGrubben"] = 2849,
			["Jangdor Swiftstrider"] = 2856
		},
		["Wild Leather Helmet"] = 	{
			["Pratt McGrubben"] = 2850,
			["Jangdor Swiftstrider"] = 2857
		},
		["Wild Leather Boots"] = 	{
			["Pratt McGrubben"] = 2851,
			["Jangdor Swiftstrider"] = 2858
		},
		["Wild Leather Leggings"] = 	{
			["Pratt McGrubben"] = 2852,
			["Jangdor Swiftstrider"] = 2859
		},
		["Master of the Wild Leather"] = 	{
			["Pratt McGrubben"] = 2853,
			["Jangdor Swiftstrider"] = 2860
		},
		["Improved Quality"] = 	{
			["Pratt McGrubben"] = 7733,
			["Jangdor Swiftstrider"] = 7734
		},
		["Gnomer-gooooone!"] = 2843,
		["Dragonscale Leatherworking"] = 	{
			["Peter Galen"] = 5141,
			["Thorkaf Dragoneye"] = 5145
		},
		["Elemental Leatherworking"] = 	{
			["Sarah Tanner"] = 5144,
			["Brumn Winterhoof"] = 5146
		},
		["Tribal Leatherworking"] = 	{
			["Caryssia Moonhunter"] = 5143,
			["Se'Jib"] = 5148
		},
		["War on the Woodpaw"] = 2862,
		["Alpha Strike"] = 2863,
		["Woodpaw Investigation"] = 2902,
		["Zukk'ash Infestation"] = 7730,
		["Stinglasher"] = 7731,
		["Zukk'ash Report"] = 7732,
		["Scarab Shells"] = 2865,
		["Thistleshrub Valley"] = 3362,
		["Super Sticky"] = 4504,
		["Against Lord Shalzaru"] = 2870,
		["Delivering the Relic"] = 2871,
		["The Missing Courier"] = 	{
			["Latronicus Moonspear"] = 4124,
			["Ginro Hearthkindle"] = 4125
		},
		["The Mystery of Morrowgrain"] = 3791,
		["Psychometric Reading"] = 4130,
		["The Knife Revealed"] = 4129,
		["The Woodpaw Gnolls"] = 4131,
		["A Hero's Welcome"] = 4266,
		["Stoley's Shipment"] = 2873,
		["Deliver to MacKinley"] = 2874,
		["Southsea Shakedown"] = 8366,
		["Skulk Rock Clean-up"] = 2877,
		["Troll Necklace Bounty"] = 2880,
		["The High Wilderness"] = 2982,
		["The Sunken Temple"] = 	{
			["Angelas Moonbreeze"] = 3445,
			["Witch Doctor Uzer'i"] = 3380
		},
		["The Borrower"] = 2941,
		["Return to Troyas"] = 2943,
		["Starfall"] = 5250,
		["Moontouched Wildkin"] = 978,
		["Find Ranshalla"] = 979,
		["Favored of Elune?"] = 3661,
		["Wildkin of Elune"] = 4902,
		["Tinkmaster Overspark"] = 2923,
		["The Grand Betrayal"] = 2929,
		["Save Techbot's Brain!"] = 2922,
		["Data Rescue"] = 2930,
		["Freedom for All Creatures"] = 2969,
		["An Orphan Looking For a Home"] = 3841,
		["Doling Justice"] = 	{
			["Jer'kai Moonweaver"] = 		{
				["As she's already told you, Kindal and I will now take the fight to the Grimtotem. Together, we should still be able to pick off damage to the tauren as you can. We can all meet back here after they've felt the sting of Kindal's arrows and your own weapons."] = 2970,
				["Out here in the wilderness, Kindal and I have meager means to reward your help, but we don't want you to feel unappreciated. Take my my High Priestess Tyrande Whisperwind. The ring will let her know that we are well and give credit to your story. We both thank you, $N."] = 2972
			}
		},
		["Gordunni Cobalt"] = 2987,
		["Nekrum's Medallion"] = 2991,
		["The Divination"] = 2992,
		["Return to the Hinterlands"] = 2993,
		["Velinde's Effects"] = 1038,
		["The Barrens Port"] = 1039,
		["A Strange Request"] = 3121,
		["Testing the Vessel"] = 3123,
		["Hippogryph Muisek"] = 3124,
		["Faerie Dragon Muisek"] = 3125,
		["Treant Muisek"] = 3126,
		["Mountain Giant Muisek"] = 3127,
		["Natural Materials"] = 3128,
		["Weapons of Spirit"] = 3129,
		["Clamlette Surprise"] = 6610,
		["The Isle of Dread!"] = 8585,
		["Dirge's Kickin' Chimaerok Chops"] = 8586,
		["Return to Narain"] = 8587,
		["At Last!"] = 3201,
		["Dwarven Justice"] = 3371,
		["Suntara Stones"] = 	{
			["Dorius Stonetender"] = 3367,
			["Singed Letter"] = 3368
		},
		["Tal the Wind Rider Master"] = 6363,
		["Xylem's Payment to Jediga"] = 3565,
		["Encoded Fragments"] = 8235,
		["The Azure Key"] = 8236,
		["Magic Dust"] = 8251,
		["The Siren's Coral"] = 8252,
		["Destroy Morphaz"] = 8253,
		["Warlord Krellian"] = 9362,
		["Fragmented Magic"] = 9364,
		["A Crew Under Fire"] = 3382,
		["Seeping Corruption"] = 	{
			["Chemist Cuely"] = 		{
				["See that tauren behind me--the one who looks like she's going to be ill at any moment? She was in Azshara recently. She claims she to find out what she drank. Take this box, in it are some empty vials I labeled. Fill each at different pools and come back."] = 3568,
				["Give this to Thersa. Perhaps it will cure her... perhaps not. We really won't know until after she drinks it. Give this to Thersa. Perhaps it will cure her... perhaps not. We really won't know until after she drinks it."] = 3569
			}
		},
		["Return to Tymor"] = 3461,
		["Courser Antlers"] = 8153,
		["Wavethrashing"] = 8231,
		["The Green Drake"] = 8232,
		["Of Coursers We Know"] = 8255,
		["The Ichor of Undeath"] = 8256,
		["Blood of Morphaz"] = 8257,
		["A Refugee's Quandary"] = 3361,
		["Release Them"] = 3372,
		["Rise, Obsidion!"] = 3566,
		["In Nightmares"] = 	{
			["Falla Sagewind"] = 		{
				["This shard holds great secrets; it is the pure essence of the Emerald Dream. However, what I see in this shard is not a dream; wise druid as soon as you can. Hamuul Runetotem on Elder Rise is who you need to find. Head to Thunder Bluff. I cannot say more."] = 3369,
				["This shard holds great secrets; it is the pure essence of the Emerald Dream. However, what I see in this shard is not a dream; druid as soon as you can...  Mathrengyl Bearwalker in the Cenarion Circle is who you need to find. Head to Darnassus. I cannot say more."] = 3370
			}
		},
		["Kim'jael Indeed!"] = 3601,
		["Kim'jael's 'Missing' Equipment"] = 5534,
		["Prayer to Elune"] = 	{
			["Zamael Lunthistle"] = 		{
				["Will you assist me, mortal? Hear my tale. Will you assist me, mortal? Hear my tale."] = 3377,
				["Will you assist me, mortal? Will you find the prayer to Elune? As I stated, the prayer was etched onto a golden tablet. One of these malevolent actions that I have taken against this world and its inhabitants, but my prayer must be heard. Absolution is the last thing I expect."] = 3378
			}
		},
		["Shadoweaver"] = 3379,
		["The Undermarket"] = 	{
			["Nilith Lokrav"] = 		{
				["They call themselves the Undermarket: Cutthroat traders that will sell, move, trade and do just about anything for the right price. It gets worse, $N. They a message to their leadership. Slay Trade Master Kovic and his minion Clunk. Bring back his trader's satchel when the job is done. To the Cauldron!"] = 3385,
				["I want you to personally deliver the news of Kovic's defeat to Vizzklick in Gadgetzan. He will be so happy to hear that Kovic is defeat to Vizzklick in Gadgetzan. He will be so happy to hear that Kovic is dead that I'm certain he'll give you some grand reward."] = 3402
			}
		},
		["Divine Retribution"] = 3441,
		["The Flawless Flame"] = 3442,
		["Forging the Shaft"] = 3443,
		["The Flame's Casing"] = 3452,
		["The Torch of Retribution"] = 	{
			["Kalaran Windblade"] = 		{
				["Give me a moment to combine the pieces and apply the necessary enchantments.  Give me a moment to combine the pieces and apply the necessary enchantments. "] = 3453,
				["The torch must now be bound to its owner. Pick up the torch, $N. The torch must now be bound to its owner. Pick up the torch, $N."] = 3454
			}
		},
		["Squire Maltrake"] = 3462,
		["Zapper Fuel"] = 4146,
		["Volcanic Activity"] = 4502,
		["Arcane Runes"] = 3449,
		["An Easy Pickup"] = 3450,
		["Set Them Ablaze!"] = 3463,
		["Scourge of the Downs"] = 3523,
		["Extinguishing the Idol"] = 3525,
		["Signal for Pickup"] = 3451,
		["Screecher Spirits"] = 3520,
		["The Prophecy of Mosh'aru"] = 3527,
		["The God Hakkar"] = 3528,
		["The Ancient Egg"] = 4787,
		["Horde Presence"] = 3514,
		["The Warsong Reports"] = 6543,
		["Iverron's Antidote"] = 	{
			["Dirania Silvershine"] = 		{
				["We may be able to help Iverron, as I know of an antidote that should help with the poison. It requires some ingredients, though, before Moonpetal lilies, which only grow around watery pools. The last ingredient may prove the most difficult. From the very spiders that poisoned Iverron, collect Webwood ichor."] = 3521,
				["The antidote is ready, $N. Please see that Iverron drinks it. There is something that you should know -- the antidote -- it will only remain know -- the antidote -- it will only remain viable for 5 minutes. You must get it to him in time. Speed be with you, $N."] = 3522
			}
		},
		["A Good Friend"] = 4495,
		["A Friend in Need"] = 3519,
		["Stealing Knowledge"] = 3517,
		["Delivery to Magatha"] = 3518,
		["Delivery to Jes'rimon"] = 3541,
		["Delivery to Andron Gant"] = 3542,
		["Delivery to Archmage Xylem"] = 3561,
		["Jes'rimon's Payment to Jediga"] = 3563,
		["Bone-Bladed Weapons"] = 4300,
		["It's a Secret to Everybody"] = 	{
			["Linken"] = 3908,
			["A Small Pack"] = 3845,
			["A Wrecked Raft"] = 3844
		},
		["A Gnome's Assistance"] = 3941,
		["It's Dangerous to Go Alone"] = 3962,
		["Membership Card Renewal"] = 3646,
		["The Smoldering Ruins of Thaurissan"] = 	{
			["Royal Historian Archesonus"] = 		{
				["Venture to the smoldering ruins of Thaurissan in the Burning Steppes and gather as much information as possible. It is said that mysterious relics litter the you should start your search there, $N. Beware the Thaurissan guardians: Assassins that guard the ruins, keeping whatever secrets may still be buried there protected."] = 3701,
				["Would you like to hear a brief history of the Dark Iron dwarves? Would you like to hear a brief history of the Dark Iron dwarves?"] = 3702
			}
		},
		["Dark Iron Legacy"] = 	{
			["Franclorn Forgewright"] = 		{
				["Greetings, $N. I am Franclorn Forgewright. Yes, the Franclorn Forgewright responsible for the stonewrought method of architecture. You have undoubtedly passed through or stood upon valid questions. I need your assistance, of course. In exchange for your assistance, I shall grant you the key to the depths of my accursed city."] = 3801,
				["You will find Fineous Darkvire beyond the Ring of Law, in the Hall of Crafting. Kill the miserable cur and recover Ironfel. Take Ironfel to the Ironfel will remain forever in my grasp. Should they make an attempt to remove the hammer; both the statue and hammer will shatter, lost forever."] = 3802
			}
		},
		["The Princess Saved?"] = 4004,
		["The Princess's Surprise"] = 4363,
		["Hilary's Necklace"] = 3741,
		["Researching the Corruption"] = 1275,
		["What Is Going On?"] = 	{
			["Commander Gor'shak"] = 		{
				["I was sent here under the auspices of Thrall. Do you actually think these buffoons could capture me? I allowed myself to be captured so in this very city! I bet old Magni's heart almost stopped when he heard that news. <Gor'shak laughs.> Shhh! Do you hear that? Guards coming! DEFEND YOURSELF!"] = 3982,
				["So far, my communication with the dwarf, Kharan, in the cell across the hall, has been limited. I have, however, managed to convince him that Princess harmed, but instead, has some grand plan laid out, which includes her being safely returned to Ironforge. Kharan already knows all of this... Go! "] = 4001
			}
		},
		["Kharan's Tale"] = 4342,
		["The Bearer of Bad News"] = 4361,
		["Operation: Death to Angerforge"] = 4132,
		["Warlord's Command"] = 	{
			["Warlord Goretooth"] = 4903,
			["Warlord Goretooth's Command"] = 4903
		},
		["Eitrigg's Wisdom"] = 4941,
		["Lost Thunderbrew Recipe"] = 4134,
		["The Darkstone Tablet"] = 4768,
		["The Last Element"] = 7201,
		["Grark Lorkrub"] = 4122,
		["Operative Bijou"] = 4981,
		["Commander Gor'shak"] = 3981,
		["The Pack Mistress"] = 4724,
		["Dreadmaul Rock"] = 3821,
		["Disharmony of Flame"] = 3906,
		["Disharmony of Fire"] = 3907,
		["Aquementas"] = 4005,
		["Silver Heart"] = 4084,
		["The Corruption of the Jadefire"] = 4421,
		["Felbound Ancients"] = 4441,
		["Purified!"] = 4442,
		["Further Corruption"] = 4906,
		["Linken's Memory"] = 3942,
		["Linken's Adventure"] = 3961,
		["Crystals of Power"] = 4284,
		["The Northern Pylon"] = 4285,
		["The Eastern Pylon"] = 4287,
		["The Western Pylon"] = 4288,
		["Making Sense of It"] = 4321,
		["Larion and Muigin"] = 4145,
		["Marvon's Workshop"] = 4147,
		["Muigin and Larion"] = 4141,
		["A Visit to Gregan"] = 4142,
		["Krom'Grul"] = 3822,
		["Extinguish the Firegut"] = 3823,
		["Gor'tesh the Brute Lord"] = 3824,
		["Ogre Head On A Stick = Party"] = 3825,
		["FIFTY! YEP!"] = 4283,
		["The Good Stuff"] = 4286,
		["A Short Incubation"] = 3842,
		["The Newest Member of the Family"] = 3843,
		["Expedition Salvation"] = 3881,
		["Alien Ecology"] = 3883,
		["Roll the Bones"] = 3882,
		["Milly's Harvest"] = 3904,
		["Grape Manifest"] = 3905,
		["The Videre Elixir"] = 3909,
		["Meet at the Grave"] = 3912,
		["Strange Sources"] = 4842,
		["Threat of the Winterfall"] = 5082,
		["Falling to Corruption"] = 5084,
		["Toxic Horrors"] = 5086,
		["Winterfall Runners"] = 5087,
		["High Chief Winterfall"] = 5121,
		["Words of the High Chief"] = 5128,
		["A Grave Situation"] = 3913,
		["Nugget Slugs"] = 3922,
		["Rilli Greasygob"] = 3923,
		["Samophlange Manual"] = 3924,
		["A Taste of Flame"] = 	{
			["Cyrus Therepentous"] = 		{
				["The flight is aware of your work in the Searing Gorge. Show it to me, $r. The molt, imbecile. The flight is aware of your work in the Searing Gorge. Show it to me, $r. The molt, imbecile."] = 4022,
				["You seek out the Flight? Present to me proof of your worth, mortal. You seek out the Flight? Present to me proof of your worth, mortal."] = 4023,
				["I wish to taste the searing flames of the mountain of fire. To let the molten fires of Blackrock cascade across my being. That essence, smoldering remains bring for me a piece of his inner fire. Use the molt on his remains to safely extract the inner flame. Succeed and be rewarded."] = 4024
			}
		},
		["The Love Potion"] = 4201,
		["Ulathek the Traitor"] = 7624,
		["Xorothian Stardust"] = 7625,
		["Precarious Predicament"] = 4121,
		["Cleansing Felwood"] = 	{
			["Arathandris Silversky"] = 4101,
			["Maybess Riverbreeze"] = 4102
		},
		["The Heart of the Mountain"] = 4123,
		["Tablet of the Seven"] = 4296,
		["Ragnar Thunderbrew"] = 4128,
		["Ribbly Screwspigot"] = 4136,
		["Maxwell's Mission"] = 5081,
		["General Drakkisath's Demise"] = 5102,
		["Overmaster Pyron"] = 4262,
		["Incendius!"] = 4263,
		["Put Her Down"] = 4701,
		["Mother's Milk"] = 4866,
		["Doomrigger's Clasp"] = 4764,
		["Delivery to Ridgewell"] = 4765,
		["Ancient Spirit"] = 4261,
		["A Little Slime Goes a Long Way"] = 	{
			["Laris Geardawdle"] = 		{
				["But the thing I've studied most is ooze. I know it sounds odd, but they're all over! I helped a lady in Menethil find her bag of the oozes there so I can further my research. I'll give you containers, you use them to collect a sample from the deceased creatures."] = 4512,
				["I'm going to need more samples, $N. But--and I don't know how to put this--they have to be pure samples. I know, I know. 'What I'll need to find samples that haven't been polluted. But where? Where?! Bah! $N, take these containers just in case you find any on your own."] = 4513
			}
		},
		["Chasing A-Me 01"] = 	{
			["Karna Remtravel"] = 4243,
			["A-Me 01"] = 		{
				["A little further investigation shows a panel that slides open. Clearly written above some wiring is the statement, 'Replace Mithril Casing And Turn Power Off you wonder if it'll be that simple to fix A-Me 01 and get her back to Karna Remtravel near Marshall's Refuge. Only trying it will tell."] = 4244,
				["Checking to see if you're prepared to lead A-Me 01 back to Karna Remtravel, you flip the switch to the 'Off' position. Glancing around once happens when you flip the switch back to the 'On' position. This is your last chance... are you sure this is what you want to do?"] = 4245
			}
		},
		["The Apes of Un'Goro"] = 4289,
		["The Fare of Lar'korwi"] = 4290,
		["The Scent of Lar'korwi"] = 4291,
		["The Bait for Lar'korwi"] = 4292,
		["The Mighty U'cha"] = 4301,
		["Toxic Test"] = 9051,
		["Bloodpetal Poison"] = 9052,
		["A Better Ingredient"] = 9053,
		["A Husband's Last Battle"] = 6162,
		["Food for Baby"] = 4297,
		["Becoming a Parent"] = 4298,
		["Yuka Screwspigot"] = 4324,
		["Galgar's Cactus Apple Surprise"] = 4402,
		["Well of Corruption"] = 4505,
		["Corrupted Sabers"] = 4506,
		["Lost!"] = 4492,
		["Shizzle's Flyer"] = 4503,
		["A Little Help From My Friends"] = 4491,
		["Message to Freewind Post"] = 4542,
		["The Bounty of Teldrassil"] = 6341,
		["A Sample of Slime..."] = 4293,
		["... and a Batch of Ooze"] = 4294,
		["Melding of Influences"] = 4642,
		["Your Place In The World"] = 4641,
		["The Champion of the Banshee Queen"] = 5961,
		["Mistress of Deception"] = 6568,
		["Blood of the Black Dragon Champion"] = 6602,
		["Fruit of the Sea"] = 1138,
		["The Family and the Fishing Pole"] = 1141,
		["Washed Ashore"] = 	{
			["Gwennyth Bly'Leggonde"] = 		{
				["Majestic sea creatures are known to launch themselves at the Darkshore coastline, beached there until they die. Lately, these beasts have been washing ashore in just south of Auberdine that is ringed by the foul Greymist murlocs. Could you go there and retrieve bones from the creature for our study?"] = 3524,
				["That beached creature is not an isolated incident here in Darkshore. There are more along the coastline and even in the water. I would like our research. Also, in your travels you may find other creatures. By all means, if you should discover anything then please bring it to our attention!"] = 4681
			}
		},
		["Bijou's Belongings"] = 	{
			["Bijou"] = 		{
				["At night when this place is lightly guarded, I sneak around the city, taking notes and writing down anything I see that could be of to that gear. They've doubled and tripled up the patrols! All that information is lost. Get my belongings back and I'll return to the K.E.F. peacefully."] = 4982,
				["Ordinarily I don't deal with $rs but it seems that I'm stuck between a troll and a hard place. You see, my mission here is bunch of orcs. You help me out by finding my belongings and I'll help you out with some information that could prove useful to your kind. Deal?"] = 5001
			}
		},
		["Bijou's Reconnaissance Report"] = 4983,
		["Message to Maxwell"] = 5002,
		["Kibler's Exotic Pets"] = 4729,
		["En-Ay-Es-Tee-Why"] = 4862,
		["Broodling Essence"] = 4726,
		["Egg Freezing"] = 4734,
		["Egg Collection"] = 4735,
		["Felnok Steelspring"] = 4808,
		["Leonid Barthalomew"] = 5522,
		["Seal of Ascension"] = 	{
			["Vaelan"] = 		{
				["As you can see, the unadorned seal has three empty sockets. Each of those sockets must be filled with a gemstone representing the leadership's command. three generals of the lower citadel would carry a gemstone at any given time is rare. You must be vigilant in your quest. Remain determined!"] = 4742,
				["Few of the black dragonkin, outside of those in the upper citadel, have the ability to forge the seal with their own flaming breath. Wyrmthalak use this orb on his weakened form. You will have scant seconds to control his mind and fan the flames that will forge the seal."] = 4743
			}
		},
		["Guardians of the Altar"] = 4901,
		["Enraged Wildkin"] = 	{
			["Jaron Stoneshaper"] = 4861,
			["Harlo Wigglesworth"] = 6604,
			["Jaron's Wagon"] = 4864,
			["Damaged Crate"] = 4863
		},
		["Troubled Spirits of Kel'Theril"] = 5245,
		["Finding the Source"] = 974,
		["The New Springs"] = 980,
		["Ursius of the Shardtooth"] = 5054,
		["Brumeran of the Chillwind"] = 5055,
		["Shy-Rotam"] = 5056,
		["Past Endeavors"] = 5057,
		["Fragments of the Past"] = 	{
			["Aurora Skycaller"] = 		{
				["I did not realize... Forgive my callous words, $c. The mistakes of my ancestors are not what I wish to dwell on, but if your request those that stole it caused it to shatter. Go to the Temple of Zin-Malor in Azshara - I can only hope the book is still there."] = 5246,
				["I will be able to help you, if recreating the artifact is truly what you wish to do. To seal the pieces back together, I will this vial. While you are gone, I will attempt to glean from these pages the knowledge I need to repair the damage done to the relic."] = 5247
			}
		},
		["Tormented By the Past"] = 5248,
		["Are We There, Yeti?"] = 	{
			["Umi Rumplesnicker"] = 		{
				["Now that I have what I need to cover the mechanical moving parts, I only need one other thing. Well, actually two. Two horns! The ice of them there; you shouldn't have any problem finding them. Remember, I only want the best looking ones -- no beat up or broken horns, please!"] = 977,
				["My friends are always coming up with great ideas. I've never felt like I could match them... until today! I just drew up the plans know they'll be impressed! I need thick yeti fur from the ice thistle yeti to start with. Will you help? You'll find them to the southeast."] = 3783,
				["It's all ready, $N! Now, I sent some mail to my friends already, telling them that I have a surprise for them. This is where you in Everlook, Sprinkle in Gadgetzan, and Quixxil in Marshal's Refuge, come back and tell me what happened! Please bring my yeti back to me then, too."] = 5163
			}
		},
		["Wild Guardians"] = 	{
			["Trull Failbane"] = 		{
				["Winterspring lies just beyond Timbermaw, northeast of Felwood. Have you been there? I have heard that the area is laden with creatures called wildkin. These beasts that there are others called raging owlbeasts that may be found in the center of Winterspring. Clear them out, and gain access to the land."] = 4521,
				["Runners have returned from Winterspring with reports that there is a series of small caves in the southern area of Winterspring. It seems that there a challenge than the previous types, $N. The creatures seem to have gone mad from exposure to the very thing that they strive to protect."] = 4721,
				["In the northern areas of Winterspring, the Wildkin grow even more ferocious. We must continue our measures there. Hunt the moontouched owlbeasts in Winterspring, and explore dangerous ground, but I know that you will be able to handle the challenge. Return to me after you have slain 13 of the wildkin."] = 4741
			}
		},
		["Guarding Secrets"] = 	{
			["Trull Failbane"] = 4883,
			["Blue-feathered Necklace"] = 4882
		},
		["Luck Be With You"] = 969,
		["Cache of Mau'ari"] = 975,
		["The Test of Skulls, Scryer"] = 6582,
		["The Test of Skulls, Somnus"] = 6583,
		["The Test of Skulls, Chronalis"] = 6584,
		["The Test of Skulls, Axtroz"] = 6585,
		["Ascension..."] = 6601,
		["Wind Rider"] = 4767,
		["Homeward Bound"] = 4770,
		["Sacred Fire"] = 5062,
		["The Everlook Report"] = 	{
			["Gregor Greystone"] = 		{
				["I am looking for a responsible individual to aid me in a small but nonetheless important matter. I'm here as a representative of the Argent I may be so bold - this would be a perfect means to introduce yourself to my superior and perhaps earn some work from her!"] = 6028,
				["I'm looking for a responsible individual to aid me in a small but nonetheless important matter. I'm here as a representative of the Argent Dawn's I may be so bold - this would be a perfect means to introduce yourself to my superior and perhaps earn some work from him!"] = 6029
			}
		},
		["Duke Nicholas Zverenhoff"] = 6030,
		["The Final Tablets"] = 4788,
		["The Lost Tablets of Mosh'aru"] = 5065,
		["Confront Yeh'kinya"] = 8181,
		["The Hand of Rastakhan"] = 8182,
		["Chillwind Horns"] = 4809,
		["Return to Tinkee"] = 4810,
		["Tinkee Steamboil"] = 4907,
		["Pacify the Centaur"] = 4841,
		["Grimtotem Spying"] = 5064,
		["Family Tree"] = 5361,
		["Alien Egg"] = 4821,
		["Serpent Wild"] = 4865,
		["A Bundle of Trouble"] = 5545,
		["Frostsaber Provisions"] = 4970,
		["Winterfall Intrusion"] = 5201,
		["Rampaging Giants"] = 5981,
		["Fiery Plate Gauntlets"] = 5124,
		["Protect Kanati Greycloud"] = 4966,
		["Free at Last"] = 4904,
		["Doom Weed"] = 5482,
		["Gordo's Task"] = 5481,
		["A Matter of Time"] = 4971,
		["Counting Out Time"] = 	{
			["Chromie"] = 		{
				["I need you to reach into the world beyond this room, $N. Allow me to explain. You see the difference in this room compared to the time trinkets, ones trapped from when the plague hit. Find them in lockboxes found in the ruined buildings that make up this once proud city."] = 4972,
				["If you are willing to help once more, I can certainly use your assistance. I'll gladly take more watches you might uncover from the ruins with the timeline here. In exchange for those watches, I'll give you another item that, in the future, I suspect you'll find quite the use for."] = 4973
			}
		},
		["The Annals of Darrowshire"] = 5154,
		["Brother Carlin"] = 5210,
		["The Battle of Darrowshire"] = 5721,
		["Remorseful Highborne"] = 5252,
		["The Wildlife Suffers Too"] = 	{
			["Mulgris Deepriver"] = 		{
				["While there was little I could do alone to thwart the Scourge, I nevertheless came to these lands to try and heal the damage done sweet and merciful release. Seek out diseased wolves nearby and put them down. Please $N, end their misery - doing so will surely soothe mine."] = 4984,
				["To the east of where we are, near where the Eastern Plaguelands begin, once proud and majestic grizzlies roamed the countryside. The plague released by you to end their misery as well. The only cure for their suffering is a swift death, one that must be ministered by your hand."] = 4985
			}
		},
		["Glyphed Oaken Branch"] = 4987,
		["The Matron Protectorate"] = 5160,
		["Finkle Einhorn, At Your Service!"] = 5047,
		["Better Late Than Never"] = 	{
			["Janice Felstone"] = 5021,
			["Janice's Parcel"] = 		{
				["You pick up the package, wiping off a small layer of dust and grime that had settled on it. It is addressed in a hurried known that the Stormwind City Hall keep records on the populace of the city. This is handled through the Royal Factors of the Stormwind Census."] = 5022,
				["You pick up the package, wiping off a small layer of dust and grime that had settled on it. It is addressed in a hurried the Undercity, formerly known as Lordaeron, keeps records on the populace of the city. This is handled through the Royal Overseers of the Undercity Census."] = 5023
			}
		},
		["Two Halves Become One"] = 5051,
		["The Jeremiah Blues"] = 5049,
		["Good Natured Emma"] = 5048,
		["Urok Doomhowl"] = 4867,
		["Alas, Andorhal"] = 	{
			["High Executor Derrington"] = 105,
			["Commander Ashlam Valorfist"] = 211
		},
		["Scholomance"] = 	{
			["High Executor Derrington"] = 838,
			["Commander Ashlam Valorfist"] = 5533
		},
		["Scarlet Diversions"] = 5096,
		["All Along the Watchtowers"] = 	{
			["High Executor Derrington"] = 5098,
			["Commander Ashlam Valorfist"] = 5097
		},
		["The Scourge Cauldrons"] = 	{
			["High Executor Derrington"] = 5228,
			["Commander Ashlam Valorfist"] = 5215
		},
		["Clear the Way"] = 5092,
		["Dispelling Evil"] = 8414,
		["Forging the Mightstone"] = 8418,
		["Mantles of the Dawn"] = 	{
			["Argent Quartermaster Hasana"] = 5504,
			["Argent Quartermaster Lightspark"] = 5507,
			["Quartermaster Miranda Breechlock"] = 5513
		},
		["Chromatic Mantle of the Dawn"] = 	{
			["Argent Quartermaster Hasana"] = 5524,
			["Argent Quartermaster Lightspark"] = 5521,
			["Quartermaster Miranda Breechlock"] = 5517
		},
		["Camp Mojache"] = 	{
			["Harbinger Balthazad"] = 7492,
			["Warcaller Gorlach"] = 7492,
			["Bluff Runner Windstrider"] = 7492,
			["Herald Amorlin"] = 7492
		},
		["Lorax's Tale"] = 5126,
		["The Demon Forge"] = 5127,
		["Verifying the Corruption"] = 5156,
		["Forces of Jaedenar"] = 5155,
		["Collection of the Corrupt Water"] = 5157,
		["Seeking Spiritual Aid"] = 5158,
		["Dousing the Flames of Protection"] = 5165,
		["A Final Blow"] = 5242,
		["To Winterspring!"] = 5249,
		["Pamela's Doll"] = 5149,
		["Auntie Marlene"] = 5152,
		["Uncle Carlin"] = 5241,
		["Hidden Treasures"] = 5942,
		["Little Pamela"] = 5142,
		["A Strange Historian"] = 5153,
		["Wrath of the Blue Flight"] = 	{
			["Haleh"] = 		{
				["We understand what the cursed brood of Deathwing attempts to do and we know that it cannot be allowed. Because of the protection Blackrock mountain affords one full of peril. You must decide whether to accept our help. Ponder this and speak with me again when a decision has been made."] = 5161,
				["It is the arcane that I control and the arcane which will send you to your next destination. When you are ready, the journey will begin. and to Jeziba you will speak. He is a mortal as wise as the ancients and as patient as the immovable earth. Find him in Andorhal. "] = 5162
			}
		},
		["Hypercapacitor Gizmo"] = 5151,
		["Catalogue of the Wayward"] = 5164,
		["Rescue From Jaedenar"] = 5203,
		["Retribution of the Light"] = 5204,
		["The Remains of Trey Lightforge"] = 5385,
		["Barov Family Fortune"] = 	{
			["Alexi Barov"] = 5341,
			["Weldon Barov"] = 5343
		},
		["The Last Barov"] = 	{
			["Alexi Barov"] = 5342,
			["Weldon Barov"] = 5344
		},
		["The Great Fras Siabi"] = 5214,
		["That's Asking A Lot"] = 6026,
		["When Smokey Sings, I Get Violent"] = 6041,
		["The Argent Hold"] = 5265,
		["Dawn's Gambit"] = 4771,
		["The Flesh Does Not Lie"] = 5212,
		["The Active Agent"] = 5213,
		["Plagued Hatchlings"] = 5529,
		["Houses of the Holy"] = 5243,
		["Menethil's Gift"] = 	{
			["Leonid Barthalomew the Revered"] = 5463,
			["Menethil's Gift"] = 5464
		},
		["Soulbound Keepsake"] = 5465,
		["Betina Bigglezink"] = 5531,
		["The Restless Souls"] = 	{
			["Caretaker Alen"] = 5281,
			["Egan"] = 5282
		},
		["Zaeldarr the Outcast"] = 6021,
		["The Archivist"] = 5251,
		["Above and Beyond"] = 5263,
		["Lord Maxwell Tyrosus"] = 5264,
		["Target: Felstone Field"] = 	{
			["High Priestess MacDonnell"] = 5216,
			["Shadow Priestess Vandis"] = 5229
		},
		["Target: Dalson's Tears"] = 	{
			["High Priestess MacDonnell"] = 5219,
			["Shadow Priestess Vandis"] = 5231
		},
		["Target: Writhing Haunt"] = 	{
			["High Priestess MacDonnell"] = 5222,
			["Shadow Priestess Vandis"] = 5233
		},
		["Target: Gahrron's Withering"] = 	{
			["High Priestess MacDonnell"] = 5225,
			["Shadow Priestess Vandis"] = 5235
		},
		["Skeletal Fragments"] = 	{
			["Alchemist Arbington"] = 5537,
			["Apothecary Dithers"] = 964
		},
		["Mold Rhymes With..."] = 	{
			["Alchemist Arbington"] = 5538,
			["Apothecary Dithers"] = 5514
		},
		["Araj's Scarab"] = 	{
			["Alchemist Arbington"] = 5803,
			["Apothecary Dithers"] = 5804
		},
		["Heroes of Darrowshire"] = 5168,
		["Villains of Darrowshire"] = 5181,
		["Marauders of Darrowshire"] = 5206,
		["Defenders of Darrowshire"] = 5211,
		["Return to Chromie"] = 5941,
		["The Ruins of Kel'Theril"] = 5244,
		["The Crystal of Zin-Malor"] = 5253,
		["The Way of the Weaponsmith"] = 	{
			["Ironus Coldsteel"] = 5284,
			["Borgosh Corebender"] = 5302
		},
		["Sweet Serenity"] = 5305,
		["Snakestone of the Shadow Huntress"] = 5306,
		["Corruption"] = 5307,
		["Doctor Theolen Krastinov, the Butcher"] = 5382,
		["Kirtonos the Herald"] = 5384,
		["Krastinov's Bag of Horrors"] = 5515,
		["The Sleeper Has Awakened"] = 5321,
		["Catch of the Day"] = 5386,
		["The Human, Ras Frostwhisper"] = 5461,
		["The Dying, Ras Frostwhisper"] = 5462,
		["The Lich, Ras Frostwhisper"] = 5466,
		["Lazy Peons"] = 5441,
		["Thazz'ril's Pick"] = 6394,
		["To Show Due Judgment"] = 7639,
		["Bone Collector"] = 5501,
		["Superior Armaments of Battle - Friend of the Dawn"] = 9221,
		["Epic Armaments of Battle - Friend of the Dawn"] = 9222,
		["Superior Armaments of Battle - Honored Amongst the Dawn"] = 9223,
		["Epic Armaments of Battle - Honored Amongst the Dawn"] = 9224,
		["Epic Armaments of Battle - Revered Amongst the Dawn"] = 9225,
		["Superior Armaments of Battle - Revered Amongst the Dawn"] = 9226,
		["Superior Armaments of Battle - Exalted Amongst the Dawn"] = 9227,
		["Epic Armaments of Battle - Exalted Amongst the Dawn"] = 9228,
		["Spiritual Unrest"] = 5535,
		["A Land Filled with Hatred"] = 5536,
		["Timbermaw Ally"] = 8460,
		["Speak to Nafien"] = 8462,
		["The Root of All Evil"] = 8481,
		["The Brokering of Peace"] = 	{
			["Gorn One Eye"] = 		{
				["Your deeds go beyond the tale of a simple hero, $N. If you are a representative of your people, then your people are ones we with us on behalf of his Alliance. It is now only fitting to acknowledge you as the key in your Alliance's efforts in brokering peace."] = 8484,
				["Your deeds go beyond the tale of a simple hero, $N. If you are a representative of your people, then your people are ones we with us on behalf of his Horde. It is now only fitting to acknowledge you as the key in your Horde's efforts in brokering peace."] = 8485
			}
		},
		["Winterfall Activity"] = 8464,
		["Runecloth"] = 6031,
		["Sacred Cloth"] = 6032,
		["Kodo Roundup"] = 5561,
		["Unfinished Business"] = 	{
			["Kirsta Deepshadow"] = 		{
				["I was sent as a scout to do some damage and gauge the strength of Hearthglen's defenses. Some people in the Alliance feel the little at their camp near the small bulwark they've set up. If you prove strong enough, maybe I could get your help with my main goal."] = 6004,
				["My real mission was to weaken the Scarlet Crusade's outlying forces and then infiltrate Hearthglen to gauge their numbers. I'm still in no shape to forces outside the town: Huntsman Radley and Cavalier Durgen. Kill them, and we're making progress. They should be along Hearthglen Pass outside the town proper."] = 6023,
				["What? Really? You want to know more? But you've already done so much for me, $N. I couldn't possibly ask you to enter Hearthglen itself place to gain a good view of the town. From there you can gauge their numbers and report them back to me. But be careful...."] = 6025
			}
		},
		["A Plague Upon Thee"] = 	{
			["Mickey Levine"] = 		{
				["So, to bring pain and strife to the Scarlet Crusade, I want to take their precious lumber mill from them. I'm sure the loss of to Plaguewood in the Eastern Plaguelands. Fill it with the termites you find in their mounds throughout the woods. Come back when you have enough."] = 5901,
				["Now that we have plenty of termites, take this steel reinforced barrel to the Northridge Lumber Mill south of Hearthglen--you'll find it to the west a crate or something. After you open it, the rest should take care of itself. Just come back here and I'll reward you for helping me."] = 5902
			},
			["Nathaniel Dumah"] = 		{
				["I've tried many times to rout out the Scarlet Crusade through force alone, but to no avail. So, as an alternative, I've decided to make plague and the Scourge combined. Find their mounds and fill this jar with them, so we can prepare them to be unleashed on the Crusade."] = 5903,
				["Now that we have the termites, take this steel reinforced barrel to the Northridge Lumber Mill south of Hearthglen--you'll find it to the west of suitable, like on a crate and then open it. The termites should do their work from there and make the mill useless to the Crusade."] = 5904
			},
			["Termite Barrel"] = 6390
		},
		["Hand of Iruxos"] = 5381,
		["Portals of the Legion"] = 5581,
		["Bodyguard for Hire"] = 5821,
		["Gizelton Caravan"] = 5943,
		["Sister Pamela"] = 5601,
		["One Shot.  One Kill."] = 5713,
		["Vyletongue Corruption"] = 	{
			["Talendria"] = 7041,
			["Vark Battlescar"] = 7029
		},
		["Trouble in Winterspring!"] = 6603,
		["A Strange One"] = 6605,
		["A Little Luck"] = 6606,
		["The Dunemaul Compound"] = 5863,
		["Trial of the Sea Lion"] = 30,
		["Wasteland"] = 1124,
		["Shards of the Felvine"] = 5526,
		["A Reliquary of Purity"] = 5527,
		["Trial of the Lake"] = 29,
		["Aquatic Form"] = 	{
			["Dendrite Starblaze"] = 		{
				["You have completed the necessary lessons all young druids are taught before they can adopt an aquatic aspect. Go now back to your trainer, Turak what he has to teach you. He will complete your training, allowing you to become one with the water. Goodbye, young druid. We shall speak again."] = 31,
				["You have completed the necessary lessons all young druids are taught before they can adopt an aquatic aspect. Go now back to your trainer, Mathrengyl what he has to teach you. He will complete your training, allowing you to become one with the water. Goodbye, young druid. We shall speak again."] = 5061
			}
		},
		["Great Bear Spirit"] = 5929,
		["Back to Darnassus"] = 5931,
		["Back to Thunder Bluff"] = 5932,
		["The Principal Source"] = 	{
			["Dendrite Starblaze"] = 		{
				["The Cliffspring Falls in Darkshore serves as the principal source of drinking water for the region, and now I suspect it is the principal source deliver it to Alanndarian Nightsong in Auberdine. She is the one that requested our aid, and you will work with her to address this malady."] = 6122,
				["Dreadmist Peak to the northwest of the Crossroads is most likely a primary candidate as to the source of the spread of the poison. Its it to Tonga Runetotem at the Crossroads. He is the one that requested our aid, and you will work with him to address this malady."] = 6127
			}
		},
		["Power over Poison"] = 6130,
		["Stewvul, Ex-B.F.F."] = 8577,
		["Never Ask Me About My Business"] = 8584,
		["Draconic for Dummies"] = 8597,
		["Decoy!"] = 8606,
		["The Only Prescription"] = 8620,
		["The Good News and The Bad News"] = 8728,
		["The Wrath of Neptulon"] = 8729,
		["Warsong Supplies"] = 6571,
		["Waking Legends"] = 8447,
		["The Nightmare's Corruption"] = 8735,
		["The Nightmare Manifests"] = 8736,
		["The Champion Returns"] = 8741,
		["Searching for the Lost Satchel"] = 5722,
		["Testing an Enemy's Strength"] = 5723,
		["Returning the Lost Satchel"] = 5724,
		["Protect Kaya"] = 6523,
		["Kaya's Alive"] = 6401,
		["Avenge My Village"] = 6548,
		["Kill Grundig Darkcloud"] = 6629,
		["Calling in the Reserves"] = 5881,
		["Harpies Threaten"] = 6282,
		["Bloodfury Bloodline"] = 6283,
		["Boulderslide Ravine"] = 6421,
		["Earthen Arise"] = 6481,
		["Elemental War"] = 6393,
		["Trouble in the Deeps"] = 6562,
		["Sceptre of Light"] = 5741,
		["Book of the Ancients"] = 6027,
		["Cycle of Rebirth"] = 6301,
		["New Life"] = 6381,
		["Scarlet Subterfuge"] = 5862,
		["Oculus Illusions"] = 6569,
		["Emberstrife"] = 6570,
		["Hunting in Stranglethorn"] = 5763,
		["To Kill With Purpose"] = 6022,
		["Un-Life's Little Annoyances"] = 6042,
		["The Ranger Lord's Behest"] = 6133,
		["Duskwing, Oh How I Hate Thee..."] = 6135,
		["The Corpulent One"] = 6136,
		["The Call to Command"] = 6144,
		["Nathanos' Ruse"] = 6146,
		["The Scarlet Oracle, Demetria"] = 6148,
		["Ramstein"] = 6163,
		["Return to Nathanos"] = 6147,
		["Uncovering Past Secrets"] = 6845,
		["Clam Bait"] = 6142,
		["Irondeep Supplies"] = 	{
			["Stormpike Quartermaster"] = 5892,
			["Frostwolf Quartermaster"] = 6985
		},
		["Coldtooth Supplies"] = 	{
			["Stormpike Quartermaster"] = 6982,
			["Frostwolf Quartermaster"] = 5893
		},
		["Seed of Life"] = 7066,
		["Get Me Out of Here!"] = 6132,
		["Brother Anton"] = 6141,
		["Other Fish to Fry"] = 6143,
		["Augustus' Receipt Book"] = 6164,
		["The Eastern Plagues"] = 6185,
		["The Blightcaller Cometh"] = 6186,
		["Vorsha the Lasher"] = 6641,
		["The Lost Pages"] = 6504,
		["Naga at the Zoram Strand"] = 6442,
		["Troll Charm"] = 6462,
		["Satyr Horns"] = 6441,
		["The Essence of Aku'Mai"] = 6563,
		["Allegiance to the Old Gods"] = 	{
			["Je'neu Sancrea"] = 6565,
			["Damp Note"] = 6564
		},
		["Amongst the Ruins"] = 6921,
		["Stonetalon Standstill"] = 25,
		["Je'neu of the Earthen Ring"] = 824,
		["Scalding Mornbrew Delivery"] = 3364,
		["Between a Rock and a Thistlefur"] = 216,
		["King of the Foulweald"] = 6621,
		["Blood Feeders"] = 6461,
		["Freedom to Ruul"] = 6482,
		["Torek's Assault"] = 6544,
		["A Host of Evil"] = 6626,
		["Ashenvale Outrunners"] = 6503,
		["Nat Pagle, Angler Extreme"] = 6607,
		["Triage"] = 	{
			["Doctor Gregory Victor"] = 6622,
			["Doctor Gustaf VanHowzen"] = 6624
		},
		["Deeprun Rat Roundup"] = 	{
			["Monty"] = 6661,
			["Squirrel Token"] = 6661
		},
		["Me Brother, Nipsy"] = 	{
			["Monty"] = 6662,
			["Squirrel Token"] = 6662
		},
		["Nefarius's Corruption"] = 8730,
		["Master Ryson's All Seeing Eye"] = 6848,
		["Enemy Booty"] = 7224,
		["The Spirits of Southwind"] = 1125,
		["Hive in the Tower"] = 1126,
		["Umber, Archivist"] = 6844,
		["Armor Scraps"] = 7223,
		["Stormers and Rumblers"] = 6805,
		["Eye of the Emberseer"] = 6821,
		["The Molten Core"] = 6822,
		["Agent of Hydraxis"] = 6823,
		["Hands of the Enemy"] = 6824,
		["A Hero's Reward"] = 7486,
		["Zinfizzlex's Portable Shredder Unit"] = 	{
			["Master Engineer Zinfizzlex"] = 		{
				["I'm as anxious as you are to try out my portable shredder unit, $r, but before I can make the kit, I'm going to need those at the lumber mill. When I was nosing around in here (before my capture) I noticed a pile of steamsaws at the Stormpike lumber camp."] = 6861,
				["I'm as anxious as you are to try out my portable shredder unit, $r, but before I can make the kit, I'm going to need those at the lumber mill. When I was nosing around in here (before my capture) I noticed a pile of steamsaws at the Frostwolf lumber camp."] = 6862
			}
		},
		["Material Assistance"] = 7667,
		["The Darkreaver Menace"] = 8258,
		["Great-father Winter is Here!"] = 	{
			["Kaymard Copperpinch"] = 6961,
			["Nardstrum Copperpinch"] = 7024,
			["Whulwert Copperpinch"] = 7021
		},
		["Stolen Winter Veil Treats"] = 	{
			["Kaymard Copperpinch"] = 6963,
			["Macey Jinglepocket"] = 7042
		},
		["A Smokywood Pastures' Thank You!"] = 	{
			["Kaymard Copperpinch"] = 6984,
			["Wulmort Jinglepocket"] = 7045
		},
		["Greatfather Winter is Here!"] = 	{
			["Wulmort Jinglepocket"] = 7022,
			["Khole Jinglepocket"] = 7023,
			["Wolgren Jinglepocket"] = 7023
		},
		["Treats for Greatfather Winter"] = 7025,
		["Treats for Great-father Winter"] = 6962,
		["Defusing the Threat"] = 	{
			["Frostwolf Explosives Expert"] = 7368,
			["Stormpike Explosives Expert"] = 7367
		},
		["Empty Stables"] = 	{
			["Frostwolf Stable Master"] = 7001,
			["Stormpike Stable Master"] = 7027
		},
		["You're a Mean One..."] = 	{
			["Strange Snowman"] = 		{
				["A c-c-creature called 'The Abominable Greench' is the one w-w-who stole our shipment of t-t-treats, $N. Be c-c-careful though! He is t-t-the one who turned are; he's s-s-surely here s-s-somewhere! F-f-find the treats $N, take them b-b-back to Smokywood Pastures in Orgrimmar, and t-t-tell them I n-n-need to be unfrozen!"] = 6983,
				["A c-c-creature called 'The Abominable Greench' is the one w-w-who stole our shipment of t-t-treats, $N. Be c-c-careful though! He is t-t-the one who turned are; he's s-s-surely here s-s-somewhere! F-f-find the treats $N, take them b-b-back to Smokywood Pastures in Ironforge, and t-t-tell them I n-n-need to be unfrozen!"] = 7043
			}
		},
		["Twisted Evils"] = 7028,
		["Legends of Maraudon"] = 7044,
		["Corruption of Earth and Seed"] = 	{
			["Keeper Marandis"] = 7065,
			["Selendra"] = 7064
		},
		["The Scepter of Celebras"] = 7046,
		["The Pariah's Instructions"] = 7067,
		["The Graveyards of Alterac"] = 7082,
		["Towers and Bunkers"] = 	{
			["Corporal Teeka Bloodsnarl"] = 7101,
			["Sergeant Durgen Stormpike"] = 7102
		},
		["Capture a Mine"] = 	{
			["Corporal Teeka Bloodsnarl"] = 7124,
			["Sergeant Durgen Stormpike"] = 7122
		},
		["Alterac Valley Graveyards"] = 7081,
		["The Quartermaster"] = 7121,
		["Speak with our Quartermaster"] = 7123,
		["The Battle of Alterac"] = 7141,
		["The Battle for Alterac"] = 7142,
		["Proving Grounds"] = 	{
			["Warmaster Laggrond"] = 7161,
			["Lieutenant Haggerdin"] = 7162
		},
		["The Legend of Korrak"] = 7181,
		["The Return of Korrak"] = 7381,
		["Korrak the Bloodrager"] = 7202,
		["Korrak the Everliving"] = 7382,
		["In Defense of Frostwolf"] = 7241,
		["The Sovereign Imperative"] = 7261,
		["Favor Amongst the Darkspear"] = 7361,
		["Ally of the Tauren"] = 7362,
		["Unfinished Gordok Business"] = 1318,
		["The Gordok Ogre Suit"] = 5518,
		["Thunderaan the Windseeker"] = 7786,
		["Pusillin and the Elder Azj'Tordin"] = 7441,
		["The Madness Within"] = 7461,
		["The Treasure of the Shen'dralar"] = 7462,
		["Arcane Refreshment"] = 7463,
		["Libram of Rapidity"] = 7483,
		["Libram of Focus"] = 7484,
		["Libram of Protection"] = 7485,
		["Elven Legends"] = 	{
			["Sage Korolusk"] = 7481,
			["Scholar Runethorn"] = 7482
		},
		["Attunement to the Core"] = 7848,
		["Rage of Blood"] = 7563,
		["Wildeyes"] = 7564,
		["Bell of Dethmoora"] = 7626,
		["Wheel of the Black March"] = 7627,
		["Doomsday Candle"] = 7628,
		["Dreadsteed of Xoroth"] = 7631,
		["Lord Banehollow"] = 7623,
		["Imp Delivery"] = 7629,
		["Arcanite"] = 7630,
		["The Prison's Bindings"] = 7581,
		["The Prison's Casing"] = 7582,
		["Suppression"] = 7583,
		["What Niby Commands"] = 7601,
		["Flawless Fel Essence"] = 7602,
		["Kroshius' Infernal Core"] = 7603,
		["Hot and Itchy"] = 8420,
		["The Wrong Stuff"] = 8421,
		["Trolls of a Feather"] = 8422,
		["The Balance of Light and Shadow"] = 7622,
		["Stave of the Ancients"] = 7636,
		["A Proper String"] = 7635,
		["Ancient Sinew Wrapped Lamina"] = 7634,
		["Blessed Arcanite Barding"] = 7644,
		["What the Flux?"] = 7722,
		["Curse These Fat Fingers"] = 7723,
		["Fiery Menace!"] = 7724,
		["Incendosaurs? Whateverosaur is More Like It"] = 7727,
		["Zapped Giants"] = 7003,
		["Fuel for the Zapping"] = 7721,
		["Again With the Zapped Giants"] = 7725,
		["Refuel for the Zapping"] = 7726,
		["Lard Lost His Lunch"] = 7840,
		["Kidnapped Elder Torntusk!"] = 7845,
		["Dark Vessels"] = 7850,
		["Vilebranch Hooligans"] = 7839,
		["Message to the Wildhammer"] = 7841,
		["Another Message to the Wildhammer"] = 7842,
		["The Final Message to the Wildhammer"] = 7843,
		["Cannibalistic Cousins"] = 7844,
		["Snapjaws, Mon!"] = 7815,
		["Gammerita, Mon!"] = 7816,
		["Stalking the Stalkers"] = 7828,
		["Hunt the Savages"] = 7829,
		["Avenging the Fallen"] = 7830,
		["Separation Anxiety"] = 7849,
		["Recover the Key!"] = 7846,
		["Return to Primal Torntusk"] = 7847,
		["The Darkmoon Faire"] = 	{
			["Melnan Darkstone"] = 7905,
			["Kruban Darkblade"] = 7926
		},
		["Paragons of Power: The Freethinker's Armguards"] = 8053,
		["Paragons of Power: The Freethinker's Belt"] = 8054,
		["Paragons of Power: The Freethinker's Breastplate"] = 8055,
		["Paragons of Power: The Vindicator's Armguards"] = 8058,
		["Paragons of Power: The Vindicator's Belt"] = 8078,
		["Paragons of Power: The Vindicator's Breastplate"] = 8079,
		["Paragons of Power: The Demoniac's Wraps"] = 8059,
		["Paragons of Power: The Illusionist's Wraps"] = 8060,
		["Paragons of Power: The Confessor's Wraps"] = 8061,
		["Paragons of Power: The Illusionist's Mantle"] = 8068,
		["Paragons of Power: The Illusionist's Robes"] = 8069,
		["Paragons of Power: The Confessor's Bindings"] = 8070,
		["Paragons of Power: The Confessor's Mantle"] = 8071,
		["Paragons of Power: The Demoniac's Mantle"] = 8076,
		["Paragons of Power: The Demoniac's Robes"] = 8077,
		["Paragons of Power: The Augur's Bracers"] = 8056,
		["Paragons of Power: The Haruspex's Bracers"] = 8057,
		["Paragons of Power: The Haruspex's Belt"] = 8064,
		["Paragons of Power: The Haruspex's Tunic"] = 8065,
		["Paragons of Power: The Augur's Belt"] = 8074,
		["Paragons of Power: The Augur's Hauberk"] = 8075,
		["Paragons of Power: The Predator's Bracers"] = 8062,
		["Paragons of Power: The Madcap's Bracers"] = 8063,
		["Paragons of Power: The Predator's Belt"] = 8066,
		["Paragons of Power: The Predator's Mantle"] = 8067,
		["Paragons of Power: The Madcap's Mantle"] = 8072,
		["Paragons of Power: The Madcap's Tunic"] = 8073,
		["A Collection of Heads"] = 8201,
		["The Battle for Arathi Basin!"] = 	{
			["Field Marshal Oslight"] = 8168,
			["Deathmaster Dwire"] = 8171
		},
		["Control Four Bases"] = 8114,
		["Control Five Bases"] = 8115,
		["Honoring a Hero"] = 	{
			["Wagner Hammerstrike"] = 8149,
			["Javnir Nashak"] = 8150
		},
		["Take Four Bases"] = 8121,
		["Take Five Bases"] = 8122,
		["The Savage Guard - Arcanum of Protection"] = 9208,
		["The Savage Guard - Arcanum of Rapidity"] = 9209,
		["The Savage Guard - Arcanum of Focus"] = 9210,
		["The Heart of Hakkar"] = 8183,
		["A Bijou for Zanza"] = 8240,
		["Pirate Hats Ahoy!"] = 8365,
		["Glyph Chasing"] = 8309,
		["Unraveling the Mystery"] = 8314,
		["Breaking the Code"] = 8310,
		["Desert Recipe"] = 8307,
		["Kitchen Assistance"] = 8317,
		["Volunteer's Battlegear"] = 8548,
		["Veteran's Battlegear"] = 8572,
		["Champion's Battlegear"] = 8573,
		["Stalwart's Battlegear"] = 8574,
		["What Tomorrow Brings"] = 8286,
		["Only One May Rise"] = 8288,
		["The Path of the Righteous"] = 8301,
		["The Hand of the Righteous"] = 8302,
		["Anachronos"] = 8303,
		["Dearest Natalia"] = 8304,
		["Into The Maw of Madness"] = 8306,
		["The Twilight Mystery"] = 8284,
		["The Deserter"] = 8285,
		["The Calling"] = 8315,
		["Taking Back Silithus"] = 	{
			["Cenarion Emissary Jademoon"] = 8275,
			["Cenarion Emissary Blackhoof"] = 8276
		},
		["Deadly Desert Venom"] = 8277,
		["Noggle's Last Hope"] = 8278,
		["Noggle's Lost Satchel"] = 8282,
		["Securing the Supply Lines"] = 8280,
		["Stepping Up Security"] = 8281,
		["Long Forgotten Memories"] = 8305,
		["Atiesh, the Befouled Greatstaff"] = 9251,
		["Atiesh, Greatstaff of the Guardian"] = 9257,
		["The Twilight Lexicon"] = 8279,
		["A Terrible Purpose"] = 8287,
		["True Believers"] = 8323,
		["Stinking Up Southshore"] = 1657,
		["Rotten Eggs"] = 8322,
		["Crashing the Wickerman Festival"] = 1658,
		["The Power of Pine"] = 8373,
		["Twilight Geolords"] = 8320,
		["Vyral the Vile"] = 8321,
		["Aurel Goldleaf"] = 8331,
		["Goldleaf's Discovery"] = 8343,
		["Dukes of the Council"] = 8332,
		["Lords of the Council"] = 8341,
		["Bor Wildmane"] = 8349,
		["Bor Wishes to Speak"] = 8351,
		["A Humble Offering"] = 9248,
		["Secret Communication"] = 8318,
		["Signet of the Dukes"] = 8348,
		["Scepter of the Council"] = 8352,
		["Abyssal Contacts"] = 8361,
		["Hallow's End Treats for Spoops!"] = 8312,
		["Hallow's End Treats for Jesper!"] = 8311,
		["Eranikus, Tyrant of the Dream"] = 8733,
		["Imperial Qiraji Regalia"] = 8790,
		["The Savior of Kalimdor"] = 8802,
		["Imperial Qiraji Armaments"] = 8789,
		["The Alliance Needs Copper Bars!"] = 8492,
		["The Alliance Needs More Copper Bars!"] = 8493,
		["Deadwood of the North"] = 8461,
		["Speak to Salfa"] = 8465,
		["The Alliance Needs Iron Bars!"] = 8494,
		["The Alliance Needs More Iron Bars!"] = 8495,
		["The Alliance Needs Thorium Bars!"] = 8499,
		["The Alliance Needs More Thorium Bars!"] = 8500,
		["The Alliance Needs Stranglekelp!"] = 8503,
		["The Alliance Needs More Stranglekelp!"] = 8504,
		["The Alliance Needs Purple Lotus!"] = 8505,
		["The Alliance Needs More Purple Lotus!"] = 8506,
		["The Alliance Needs Arthas' Tears!"] = 8509,
		["The Alliance Needs More Arthas' Tears!"] = 8510,
		["The Alliance Needs Light Leather!"] = 8511,
		["The Alliance Needs More Light Leather!"] = 8512,
		["The Alliance Needs Medium Leather!"] = 8513,
		["The Alliance Needs More Medium Leather!"] = 8514,
		["The Alliance Needs Thick Leather!"] = 8515,
		["The Alliance Needs More Thick Leather!"] = 8516,
		["The Alliance Needs Linen Bandages!"] = 8517,
		["The Alliance Needs More Linen Bandages!"] = 8518,
		["The Alliance Needs Silk Bandages!"] = 8520,
		["The Alliance Needs More Silk Bandages!"] = 8521,
		["The Alliance Needs Runecloth Bandages!"] = 8522,
		["The Alliance Needs More Runecloth Bandages!"] = 8523,
		["The Alliance Needs Rainbow Fin Albacore!"] = 8524,
		["The Alliance Needs More Rainbow Fin Albacore!"] = 8525,
		["The Alliance Needs Roast Raptor!"] = 8526,
		["The Alliance Needs More Roast Raptor!"] = 8527,
		["The Alliance Needs Spotted Yellowtail!"] = 8528,
		["The Alliance Needs More Spotted Yellowtail!"] = 8529,
		["The Horde Needs Copper Bars!"] = 8532,
		["The Horde Needs More Copper Bars!"] = 8533,
		["The Horde Needs Tin Bars!"] = 8542,
		["The Horde Needs More Tin Bars!"] = 8543,
		["The Horde Needs Mithril Bars!"] = 8545,
		["The Horde Needs Peacebloom!"] = 8549,
		["Signet of Unyielding Strength"] = 8556,
		["Ring of Infinite Wisdom"] = 8697,
		["Ring of the Gathering Storm"] = 8698,
		["Band of Vaulted Secrets"] = 8699,
		["Band of Unending Life"] = 8700,
		["Band of Veiled Shadows"] = 8701,
		["Ring of Unspoken Names"] = 8702,
		["Ring of Eternal Justice"] = 8703,
		["Signet of the Unseen Path"] = 8704,
		["Sickle of Unyielding Strength"] = 8558,
		["Gavel of Infinite Wisdom"] = 8705,
		["Hammer of the Gathering Storm"] = 8706,
		["Blade of Vaulted Secrets"] = 8707,
		["Mace of Unending Life"] = 8708,
		["Dagger of Veiled Shadows"] = 8709,
		["Kris of Unspoken Names"] = 8710,
		["Blade of Eternal Justice"] = 8711,
		["Scythe of the Unseen Path"] = 8712,
		["Drape of Unyielding Strength"] = 8557,
		["Shroud of Infinite Wisdom"] = 8689,
		["Cloak of the Gathering Storm"] = 8690,
		["Drape of Vaulted Secrets"] = 8691,
		["Cloak of Unending Life"] = 8692,
		["Cloak of Veiled Shadows"] = 8693,
		["Shroud of Unspoken Names"] = 8694,
		["Cape of Eternal Justice"] = 8695,
		["Cloak of the Unseen Path"] = 8696,
		["Conqueror's Spaulders"] = 8544,
		["Conqueror's Crown"] = 8561,
		["Tiara of the Oracle"] = 8592,
		["Mantle of the Oracle"] = 8594,
		["Stormcaller's Pauldrons"] = 8602,
		["Stormcaller's Diadem"] = 8623,
		["Enigma Shoulderpads"] = 8625,
		["Avenger's Crown"] = 8628,
		["Avenger's Pauldrons"] = 8630,
		["Enigma Circlet"] = 8632,
		["Deathdealer's Helm"] = 8639,
		["Deathdealer's Spaulders"] = 8641,
		["Striker's Diadem"] = 8657,
		["Striker's Pauldrons"] = 8659,
		["Doomcaller's Circlet"] = 8662,
		["Doomcaller's Mantle"] = 8664,
		["Genesis Helm"] = 8667,
		["Genesis Shoulderpads"] = 8669,
		["Conqueror's Greaves"] = 8559,
		["Conqueror's Legguards"] = 8560,
		["Trousers of the Oracle"] = 8593,
		["Footwraps of the Oracle"] = 8596,
		["Stormcaller's Footguards"] = 8621,
		["Stormcaller's Leggings"] = 8624,
		["Striker's Footguards"] = 8626,
		["Avenger's Legguards"] = 8629,
		["Enigma Leggings"] = 8631,
		["Enigma Boots"] = 8634,
		["Deathdealer's Boots"] = 8637,
		["Deathdealer's Leggings"] = 8640,
		["Avenger's Greaves"] = 8655,
		["Striker's Leggings"] = 8658,
		["Doomcaller's Footwraps"] = 8660,
		["Doomcaller's Trousers"] = 8663,
		["Genesis Boots"] = 8665,
		["Genesis Trousers"] = 8668,
		["Conqueror's Breastplate"] = 8562,
		["Vestments of the Oracle"] = 8603,
		["Stormcaller's Hauberk"] = 8622,
		["Avenger's Breastplate"] = 8627,
		["Enigma Robes"] = 8633,
		["Deathdealer's Vest"] = 8638,
		["Striker's Hauberk"] = 8656,
		["Doomcaller's Robes"] = 8661,
		["Genesis Vest"] = 8666,
		["The Horde Needs Firebloom!"] = 8580,
		["The Horde Needs Purple Lotus!"] = 8582,
		["The Horde Needs Heavy Leather!"] = 8588,
		["The Horde Needs Thick Leather!"] = 8590,
		["The Horde Needs Rugged Leather!"] = 8600,
		["Love Song for Narain"] = 8599,
		["The Horde Needs Wool Bandages!"] = 8604,
		["The Horde Needs Mageweave Bandages!"] = 8607,
		["The Horde Needs Runecloth Bandages!"] = 8609,
		["The Horde Needs Lean Wolf Steaks!"] = 8611,
		["The Horde Needs Spotted Yellowtail!"] = 8613,
		["The Horde Needs Baked Salmon!"] = 8615,
		["Field Duty"] = 	{
			["Windcaller Kaldon"] = 		{
				["Greetings, $N. Before I assign you to more involved tasks in the war, you'll need to do your share of field duty.  You will find favor and stay away from the Orgrimmar Legion. We've been forced to keep the two forces well apart from one another due to mutual animosity."] = 8507,
				["Greetings, $N. Before I assign you to more involved tasks in the war, you'll need to do your share of field duty.  You will find advanced assignment ready for you. Oh, please do your best to stay away from the Ironforge Brigade. Tensions are high among our Alliance and Horde volunteers."] = 8731
			}
		},
		["Cenarion Battlegear"] = 8800,
		["Tyrande and Remulos"] = 8734,
		["The Horde Needs Your Help!"] = 	{
			["Senior Sergeant Taiga"] = 8792,
			["Senior Sergeant Grimsford"] = 8793,
			["Senior Sergeant Kai'jin"] = 8794
		},
		["The Alliance Needs Your Help!"] = 	{
			["Master Sergeant Fizzlebolt"] = 8795,
			["Master Sergeant Moonshadow"] = 8797
		},
		["Winter's Presents"] = 	{
			["Wonderform Operator"] = 		{
				["I hear Greatfather Winter - with the generous support of Smokeywood Pastures - has put presents for everyone under the tree in Ironforge. I wish to look after the PX-238 Winter Wondervolt. But you should definitely check it out. I'm sure Greatfather Winter has some presents with your name on them."] = 8827,
				["I hear Great-father Winter - with the generous support of Smokeywood Pastures - has put presents for everyone under the tree in Orgrimmar. I wish to look after the PX-238 Winter Wondervolt. But you should definitely check it out. I'm sure Great-father Winter has some presents with your name on them."] = 8828
			}
		},
		["Secrets of the Colossus - Zora"] = 8859,
		["Secrets of the Colossus - Ashi"] = 8857,
		["Secrets of the Colossus - Regal"] = 8858,
		["Elune's Blessing"] = 8868,
		["The Lunar Festival"] = 	{
			["Lunar Festival Herald"] = 8873,
			["Lunar Festival Emissary"] = 8870
		},
		["Lunar Fireworks"] = 8867,
		["Valadar Starsong"] = 8883,
		["Dearest Elenia,"] = 	{
			["Deathguard Tor"] = 8902,
			["Orok Deathbane"] = 8900,
			["Temma of the Wells"] = 8901
		},
		["An Earnest Proposition"] = 	{
			["Mokvar"] = 		{
				["Hail, $c! I can tell by your demeanor that you've seen and done much in this world. Yet I'm willing to wager you haven't seen venom drawn from the spiders and scorpions that inhabit Silithus. Bring this to me along with a few gold coins and I'll perform the exchange."] = 8913,
				["Hail, $c! I can tell by your demeanor that you've seen and done much in this world. Yet I'm willing to wager you haven't seen venom drawn from the spiders and scorpions that inhabit Silithus. Bring this to me along with a few gold coins and I'll perform the exchange. "] = 8916
			},
			["Deliana"] = 		{
				["Well met, $c. I've something that might interest you. I have in my possession a set of armor much like the one worn by those of Bring me a sizeable sample of it along with the bracers and a small amount of gold. You shall find the effort worth your while."] = 8911,
				["Well met, $c. I've something that might interest you. I have in my possession a set of armor much like the one worn by those of Bring me a sizeable sample of it along with the bracers and a small amount of gold. You shall find the effort worth your while. "] = 8912
			}
		},
		["A Supernatural Device"] = 	{
			["Mokvar"] = 8923,
			["Deliana"] = 8922
		},
		["Just Compensation"] = 	{
			["Mokvar"] = 		{
				["You've proven to be a very reliable individual, $N. As much as I trust that you'll help me through this predicament, it would be wise now I will exchange your belt and gloves. If we both see this through I shall make the rest of the pieces available to you."] = 8927,
				["You've proven to be a very reliable individual, $N. As much as I trust that you'll help me through this predicament, it would be wise now I will exchange your belt and gauntlets. If we both see this through I shall make the rest of the pieces available to you."] = 8942
			},
			["Deliana"] = 		{
				["You kept your word and brought the device built by Mux. I believe a reward is in order if I'm to keep you interested in me the belt and set of gloves that you wish to upgrade. I promise the ones I give you in return will be far superior."] = 8926,
				["You kept your word and brought the device built by Mux. I believe a reward is in order if I'm to keep you interested in if I'm to keep you interested in saving my skin. Bring me an ordinary belt and a set of gloves that you wish to upgrade."] = 8931,
				["You kept your word and brought the device built by Mux. I believe a reward is in order if I'm to keep you interested in me the belt and set of gauntlets that you wish to upgrade. I promise the ones I give you in return will be far superior."] = 8933
			}
		},
		["In Search of Anthion"] = 	{
			["Mokvar"] = 8930,
			["Deliana"] = 8929
		},
		["Saving the Best for Last"] = 	{
			["Mokvar"] = 9014,
			["Deliana"] = 9006
		},
		["Bodley's Unfortunate Fate"] = 	{
			["Mokvar"] = 9032,
			["Deliana"] = 8960
		},
		["The Ectoplasmic Distiller"] = 8921,
		["Hunting for Ectoplasm"] = 8924,
		["A Portable Power Source"] = 8925,
		["A Shifty Merchant"] = 8928,
		["Return to Deliana"] = 8977,
		["Return to Mokvar"] = 8978,
		["Dead Man's Plea"] = 8945,
		["Anthion's Strange Request"] = 8947,
		["Anthion's Old Friend"] = 8948,
		["Anthion's Parting Words"] = 9022,
		["Proof of Life"] = 8946,
		["Falrin's Vendetta"] = 8949,
		["The Instigator's Enchantment"] = 8950,
		["The Challenge"] = 9015,
		["Three Kings of Flame"] = 8961,
		["Components of Importance"] = 	{
			["Bodley"] = 		{
				["$C, listen closely. Now that we have the brazier, and the means to light it, we still need another component to suffuse it with; something have fallen to the silithid. I need you to retrieve some Druidical Remains from the silithid that inhabit the environs of Hive'Regal in southeastern Silithus."] = 8962,
				["$C, listen closely. Now that we have the brazier, and the means to light it, we still need another component to suffuse it with; something Starbreeze Village Relic from the Frostmaul giants of Frostwhisper Gorge in southern Winterspring, who are known for raiding to the north from time to time."] = 8963,
				["$C, listen closely. Now that we have the brazier, and the means to light it, we still need another component to suffuse it with; something aspired to knighthood within that vile organization. Go to Tyr's Hand in Eastern Plaguelands and retrieve a Brilliant Sword of Zealotry from the praetorians there."] = 8964,
				["$C, listen closely. Now that we have the brazier, and the means to light it, we still need another component to suffuse it with; something dead of Purgation Isle, off the south coast of the Hillsbrad Foothills. Go there and retrieve some Soul Ashes of the Banished from their remains."] = 8965
			}
		},
		["The Left Piece of Lord Valthalak's Amulet"] = 	{
			["Bodley"] = 		{
				["My friend, Mor Grayhoof, was the first to fall victim to possession of a piece of Lord Valthalak's amulet, and the corrupting spirit fragment that fall, only to be captured and tortured by War Master Voone. A few spectral assassins snuck in and slew him right in front of Voone."] = 8966,
				["It became known to us in later days, as we were doing what we could ourselves to survive, that Isalien, a night elf priestess of quite make it, though. Word got back to us that she was ambushed at the Shrine of Eldretharr by Alzzin the Wildshaper and his forces."] = 8967,
				["The siblings, Jarien and Sothos, decided to join the Scarlet Crusade upon the disbanding of our mercenary company. They took the left piece of Lord rites inside his chamber in the Scarlet Bastion. In any case, we... meaning you, are still going to need to retrieve that piece of the amulet."] = 8968,
				["Now we have what we need, so it's time to discuss who it is that you'll be summoning. Kormok was ok for an ogre, right up even there, or perhaps especially there, he was not safe from the spectral assassins. They slew him right in front of his master, Ras Frostwhisper."] = 8969
			}
		},
		["I See Alcaz Island In Your Future..."] = 8970,
		["More Components of Importance"] = 	{
			["Bodley"] = 		{
				["$C, listen closely. Now that we have the location of the last amulet piece, we still need another component to suffuse the brazier with; something Starbreeze Village Relic from the Frostmaul giants of Frostwhisper Gorge in southern Winterspring, who are known for raiding to the north from time to time."] = 8985,
				["$C, listen closely. Now that we have the location of the last amulet piece, we still need another component to suffuse the brazier with; something have fallen to the silithid. I need you to retrieve some Druidical Remains from the silithid that inhabit the environs of Hive'Regal in southeastern Silithus."] = 8986,
				["$C, listen closely. Now that we have the location of the last amulet piece, we still need another component to suffuse the brazier with; something aspired to knighthood within that vile organization. Go to Tyr's Hand in Eastern Plaguelands and retrieve a Brilliant Sword of Zealotry from the praetorians there. "] = 8987,
				["$C, listen closely. Now that we have the location of the last amulet piece, we still need another component to suffuse the brazier with; something dead of Purgation Isle, off the south coast of the Hillsbrad Foothills. Go there and retrieve some Soul Ashes of the Banished from their remains."] = 8988
			}
		},
		["The Right Piece of Lord Valthalak's Amulet"] = 	{
			["Bodley"] = 		{
				["My friend, Mor Grayhoof, was the first to fall victim to possession of a piece of Lord Valthalak's amulet, and the corrupting spirit fragment that fall, only to be captured and tortured by War Master Voone. A few spectral assassins snuck in and slew him right in front of Voone."] = 8989,
				["It became known to us in later days, as we were doing what we could ourselves to survive, that Isalien, a night elf priestess of quite make it, though. Word got back to us that she was ambushed at the Shrine of Eldretharr by Alzzin the Wildshaper and his forces."] = 8990,
				["The siblings, Jarien and Sothos, decided to join the Scarlet Crusade upon the disbanding of our mercenary company. They took the right piece of Lord rites inside his chamber in the Scarlet Bastion. In any case, we... meaning you, are still going to need to retrieve that piece of the amulet."] = 8991,
				["Now we have what we need, so it's time to discuss who it is that you'll be summoning next. Kormok was ok for an ogre, right even there, or perhaps especially there, he was not safe from the spectral assassins. They slew him right in front of his master, Ras Frostwhisper."] = 8992
			}
		},
		["Final Preparations"] = 8994,
		["Mea Culpa, Lord Valthalak"] = 8995,
		["Back to the Beginning"] = 	{
			["Bodley"] = 		{
				["I suppose that this is goodbye then, my friend. But, I'll always be here if you want to come back and talk with me from to join you for a raid on Blackrock Spire. Go, before I start to cry. Go back to Deliana in Ironforge and tell her what's happened."] = 8997,
				["I suppose that this is goodbye then, my friend. But, I'll always be here if you want to come back and talk with me from to join you for a raid on Blackrock Spire. Go, before I start to cry. Go back to Mokvar in Orgrimmar and tell him what's happened."] = 8998
			}
		},
		["Return to Bodley"] = 8996,
		["The Perfect Poison"] = 9023,
		["Tracing the Source"] = 	{
			["Aristan Mottar"] = 9026,
			["Fenstad Argyle"] = 8982,
			["Innkeeper Allison"] = 9027,
			["Innkeeper Norman"] = 8983
		},
		["The Source Revealed"] = 	{
			["Evert Sorisam"] = 9028,
			["Mara Rennick"] = 8984
		},
		["Binding the Dreadnaught"] = 9131,
		["Echoes of War"] = 9033,
		["Redemption Headpiece"] = 9045,
		["The Dread Citadel - Naxxramas"] = 	{
			["Archmage Angela Dosantos"] = 		{
				["In the thick of Plaguewood lies the entrance to the dread citadel of Naxxramas. Previously, all attempts to enter had been stymied by the magical is somewhat lacking, $N, the price will be high. You may decline and choose to return when you are revered or exalted for a discount."] = 9121,
				["In the thick of Plaguewood lies the entrance to the dread citadel of Naxxramas. Previously, all attempts to enter had been stymied by the magical said, the cloaking is costly. Since your dedication to the cause of the Dawn is admirable, we are willing to incur some of those costs."] = 9122,
				["In the thick of Plaguewood lies the entrance to the dread citadel of Naxxramas. Previously, all attempts to enter had been stymied by the magical own. With that said, the cloaking is costly; however, your dedication to the cause of the Dawn is unwavering! We will waive all cost associations."] = 9123
			}
		},
		["The Elemental Equation"] = 9128,
		["Bonescythe Digs"] = 9126,
		["Cryptstalker Armor Doesn't Make Itself..."] = 9124,
		["The Ice Guard"] = 9211,
		["The Shadow Guard"] = 9213,
		["Savage Flora"] = 9136,
		["The Forsaken"] = 9327,
		["They Call Me 'The Rooster'"] = 9141,
		["Writ of Safe Passage"] = 9165,
		["Chamber of Secrets"] = 12616,
		["Shadows of Doom"] = 9085,
		["Under the Shadow"] = 9153,
		["Icebane Gauntlets"] = 9234,
		["Icebane Bracers"] = 9235,
		["Icebane Breastplate"] = 9236,
		["Glacial Cloak"] = 9237,
		["Glacial Wrists"] = 9238,
		["Glacial Gloves"] = 9239,
		["Glacial Vest"] = 9240,
		["Polar Bracers"] = 9241,
		["Polar Gloves"] = 9242,
		["Polar Tunic"] = 9243,
		["Icy Scale Bracers"] = 9244,
		["Icy Scale Gauntlets"] = 9245,
		["Icy Scale Breastplate"] = 9246,
		["Cracked Necrotic Crystal"] = 9292,
		["Investigate the Scourge of Stormwind"] = 9260,
		["Investigate the Scourge of Ironforge"] = 9261,
		["Investigate the Scourge of Thunder Bluff"] = 9264,
		["Investigate the Scourge of Orgrimmar"] = 9263,
		["Investigate the Scourge of the Undercity"] = 9265,
		["Investigate the Scourge of Darnassus"] = 9262,
		["Faint Necrotic Crystal"] = 9310,
		["Establishing New Outposts"] = 9664,
		["Bolstering Our Defenses"] = 9665,
		["Scouring the Desert"] = 	{
			["General Kirika"] = 9422,
			["Marshal Bluewall"] = 9419
		},
		["Report to General Kirika"] = 9416,
		["Report to Marshal Bluewall"] = 9415,
		["Apothecary Zelana"] = 10449,
		["Bonechewer Blood"] = 10450,
		["Return to Witch Doctor Uzer'i"] = 3122,
		["Morgan's Discovery"] = 9025,
		["Zinge's Assessment"] = 8980,
		["Metzen the Reindeer"] = 	{
			["Kaymard Copperpinch"] = 8746,
			["Wulmort Jinglepocket"] = 8762
		},
		["The Hero of the Day"] = 	{
			["Kaymard Copperpinch"] = 8799,
			["Wulmort Jinglepocket"] = 8763
		},
		["A Warden of the Alliance"] = 171,
		["Jaina's Autograph"] = 558,
		["The Bough of the Eternals"] = 1479,
		["The Stonewrought Dam"] = 1558,
		["Spooky Lighthouse"] = 1687,
		["You Scream, I Scream..."] = 	{
			["Human Orphan"] = 4822,
			["Orcish Orphan"] = 915
		},
		["Down at the Docks"] = 910,
		["Gateway to the Frontier"] = 911,
		["Cairne's Hoofprint"] = 925,
		["Lordaeron Throne Room"] = 1800,
		["A Warden of the Horde"] = 5502,
		["Children's Week"] = 	{
			["Orphan Matron Nightingale"] = 1468,
			["Orphan Matron Battlewail"] = 172
		},
		["New Year Celebrations!"] = 	{
			["Wonderform Operator"] = 		{
				["Stormwind is holding a celebration for the new year! All day long today you can get free booze, and at night they'll put on a party goers. Can you do me a favor and deliver it! Thanks, $N! Innkeeper Allison is in the Gilded Rose, in the Trade District of Stormwind."] = 8860,
				["Thunder Bluff is holding a celebration for the new year! All day you'll find free booze there, and at night they'll put on a firework the party goers. Can you do me a favor and deliver it! Thanks, $N! Innkeeper Pala is in the inn near the bridge to Hunter's Rise."] = 8861
			}
		},
		["A Thief's Reward"] = 	{
			["Festival Loremaster"] = 9365,
			["Festival Talespinner"] = 9339
		},
		["Looking Further"] = 248,
		["Captain Sanders' Hidden Treasure"] = 	{
			["Old Jug"] = 140,
			["Captain's Footlocker"] = 138,
			["Broken Barrel"] = 139,
			["Captain Sanders' Treasure Map"] = 136
		},
		["Wanted: Lieutenant Fangore"] = 180,
		["Discover Rolf's Fate"] = 45,
		["Report to Thomas"] = 71,
		["Sven's Camp"] = 230,
		["Wanted: Gath'Ilzogg"] = 169,
		["The Weathered Grave"] = 225,
		["Wanted:  'Hogger'"] = 176,
		["WANTED: Chok'sul"] = 256,
		["Return the Statuette"] = 286,
		["The Search Continues"] = 284,
		["Return to Marleth"] = 311,
		["The Hidden Key"] = 328,
		["The Spy Revealed!"] = 329,
		["Wanted: Maggot Eye"] = 398,
		["Rot Hide Clues"] = 439,
		["The Hidden Niche"] = 461,
		["Defeat Nek'rosh"] = 474,
		["Maps and Runes"] = 478,
		["Foreboding Plans"] = 510,
		["WANTED: Syndicate Personnel"] = 549,
		["WANTED: Baron Vardus"] = 566,
		["Dangerous!"] = 567,
		["A Pilot's Revenge"] = 417,
		["Speaking with Nezzliok"] = 585,
		["Speaking with Gan'zulah"] = 586,
		["The Fate of Yenniku"] = 588,
		["Marg Speaks"] = 1261,
		["Cortello's Riddle"] = 	{
			["A Soggy Scroll"] = 625,
			["Musty Scroll"] = 626,
			["Cortello's Riddle"] = 624
		},
		["Myzrael's Allies"] = 	{
			["Keystone"] = 		{
				["<Myzrael speaks.> Free! I AM FREE! I am free to gather strength, hidden from my captors. For if they faced me now they would surely overpower me to the surface. Speak with Gerrig Bonegrip. He is in Ironforge, in a shop of the Forlorn Cavern. He knows how I can be summoned."] = 653,
				["<Myzrael speaks.> Free! I AM FREE! I am free to gather strength, hidden from my captors. For if they faced me now they would surely overpower When I am ready, I will need you to summon me to the surface Speak with Zaruk in Hammerfall. He knows how I can be summoned."] = 688
			}
		},
		["Stones of Binding"] = 651,
		["Breaking the Keystone"] = 652,
		["Wanted!  Marez Cowl"] = 684,
		["Wanted!  Otto and Falconcrest"] = 685,
		["The Lost Ingots"] = 324,
		["Murdaloc"] = 739,
		["WANTED: Baron Longshore"] = 895,
		["The Glowing Fruit"] = 930,
		["The Shimmering Frond"] = 931,
		["The Twilight Camp"] = 949,
		["Return to Onu"] = 950,
		["Buzzbox 411"] = 1001,
		["Buzzbox 323"] = 1002,
		["Buzzbox 525"] = 1003,
		["Rizzle's Schematics"] = 1194,
		["The Orc Report"] = 1219,
		["The Lost Report"] = 1238,
		["The Severed Head"] = 1239,
		["Wand to Bethor"] = 491,
		["The Eye of Paleth"] = 292,
		["The Princess Trapped"] = 642,
		["WANTED: Caliph Scorpidsting"] = 2781,
		["WANTED: Andre Firebeard"] = 2875,
		["Rin'ji's Secret"] = 2782,
		["Search More Hovels"] = 285,
		["Return to Feathermoon Stronghold"] = 2867,
		["The Battle Plans"] = 2903,
		["The Stone Watcher"] = 2954,
		["Return to Ironforge"] = 2977,
		["Return of the Ring"] = 	{
			["The Sparklematic 5200"] = 		{
				["Opening the box produced by the Sparklematic 5200 reveals what you had suspected - a shiny ring! Wearing the ring, you feel magic power surge the initials of the previous owner, or perhaps the initials of the ring's crafter. Keep the ring... or return it to this person. Decisions, decisions..."] = 2947,
				["Opening the box produced by the Sparklematic 5200 reveals a shiny ring! Donning the ring, you feel magic power surge through your body. Inside the band signify either the initials of the previous owner, or perhaps the initials of the ring's crafter. Keep the ring... or find 'NOG' - decisions, decisions..."] = 2949
			}
		},
		["The Sparklematic 5200!"] = 4602,
		["Venom Bottles"] = 2933,
		["Feralas: A History"] = 2940,
		["The Morrow Stone"] = 2942,
		["Linken's Sword"] = 3914,
		["Trinkets..."] = 3481,
		["KILL ON SIGHT: Dark Iron Dwarves"] = 4081,
		["KILL ON SIGHT: High Ranking Dark Iron Officials"] = 4082,
		["Boat Wreckage"] = 4127,
		["The Writhing Deep"] = 4135,
		["Freed from the Hive"] = 4265,
		["Caught!"] = 4449,
		["Ledger from Tanaris"] = 4450,
		["Beware of Pterrordax"] = 4501,
		["Beached Sea Creature"] = 	{
			["Beached Sea Creature"] = 		{
				["The corpse of what appears to be some sort of giant sea mammal lies partially gutted on the beach. A wheelbarrow and various tools lie it had been made previously. Though murlocs have scavenged this beast, enough of it remains to gather a suitable sample for Gwennyth Bly'Leggonde in Auberdine."] = 4728,
				["The half-devoured corpse of what might have been a giant sea mammal lies on the beach. A band of murlocs, stronger than those found closer residence around the fallen creature. Enough of the creature remains that a suitable sample of its bones could be delivered to Gwennyth Bly'Leggonde in Auberdine."] = 4730,
				["The remains of what appear to be a giant thresher have washed ashore on the rocky inlet of the Twilight Shore. The thresher is several native to Darkshore. Though the creature has been picked apart in places, enough of it remains to gather a suitable sample for Gwennyth Bly'Leggonde in Auberdine."] = 4733,
				["The remains of a giant thresher - much larger than one you'd expect to find in Darkshore - lie beached on the coast of the the beast.  While some of it has been picked clean, enough of it remains to take a sample for Gwennyth Bly'Leggonde in Auberdine to study."] = 4723
			}
		},
		["WANTED: Murkdeep!"] = 4740,
		["The Fragments Within"] = 4813,
		["Cap of the Scarlet Savant"] = 5063,
		["Leggings of Arcana"] = 5067,
		["Breastplate of Bloodthirst"] = 5068,
		["Hot Fiery Death"] = 5103,
		["Mystery Goo"] = 5085,
		["Wanted - Arnak Grimtotem"] = 5147,
		["Beached Sea Turtle"] = 	{
			["Beached Sea Turtle"] = 		{
				["You find a corpse of a sea turtle that had beached itself on the coast of Darkshore some time ago. It has been scavenged by Still, there appear to be some suitable samples left on the creature's remains that Gwennyth Bly'Leggonde in Auberdine might be able to make use of."] = 4722,
				["You find a corpse of a sea turtle that had beached itself on the coast of Darkshore some time ago. It has been picked nearly Still, there appear to be some suitable samples left on the creature's remains that Gwennyth Bly'Leggonde in Auberdine might be able to make use of."] = 4732,
				["The skeletal remains of a sea turtle lie in the sand of the northern Darkshore beaches. The Greymist murlocs have either not found this carcass, there is enough of the turtle left to take a sample back to Gwennyth Bly'Leggonde in Auberdine for the Temple of the Moon to study."] = 4727,
				["More sea turtle remains lie beached along the coastline. This particular set has an abandoned carriage attached to the turtle's shell. Perhaps this creature was feasting off the carrion. In the carriage, you find a box with strange markings on it; perhaps Gwennyth Bly'Leggonde in Auberdine can make sense of it."] = 4725,
				["Another set of sea turtle remains lie beached on the coastline. This set of remains has an abandoned carriage half buckled to the turtle's shell. creature their current home. In the carriage, you find a box with strange markings on it; perhaps Gwennyth Bly'Leggonde in Auberdine can make sense of it."] = 4731
			}
		},
		["Breastplate of the Chromatic Flight"] = 5166,
		["Legplates of the Chromatic Defier"] = 5167,
		["Return to Chillwind Camp"] = 	{
			["Scourge Cauldron"] = 		{
				["You fill the bottle with enough of the cauldron's poisonous concoction for a suitable sample to be studied. With the poison in hand, it is time suitable sample to be studied. With the poison in hand, it is time to return to High Priestess MacDonnell at Chillwind Camp to complete the mission."] = 5217,
				["You carefully close the spigot in the control panel, watching the cauldron's putrid ichors drip into the empty bottle. With the poison in hand, it is drip into the empty bottle. With the poison in hand, it is time to return to High Priestess MacDonnell at Chillwind Camp to complete the mission."] = 5226,
				["You delicately top off the empty bottle; a sample of the foul substance that churns under the platform of the cauldron now oozes back and inside the fragile glass container. With the poison in hand, it is time to return to High Priestess MacDonnell at Chillwind Camp to complete the mission."] = 5223,
				["You carefully fill the bottle with enough of the cauldron's ichors for what you consider to be suitably sized sample. With the poison in hand, it to be suitably sized sample. With the poison in hand, it is time to return to High Priestess MacDonnell at Chillwind Camp to complete the mission."] = 5220
			}
		},
		["Return to the Bulwark"] = 	{
			["Scourge Cauldron"] = 		{
				["You fill the bottle with enough of the cauldron's poisonous concoction for a suitable sample to be studied. With the poison in hand, it is time suitable sample to be studied. With the poison in hand, it is time to return to Shadow Priestess Vandis at the Bulwark to complete the mission."] = 5230,
				["You carefully close the spigot in the control panel, watching the cauldron's putrid ichors drip into the empty bottle. With the poison in hand, it is drip into the empty bottle. With the poison in hand, it is time to return to Shadow Priestess Vandis at the Bulwark to complete the mission."] = 5236,
				["You delicately top off the empty bottle; a sample of the foul substance that churns under the platform of the cauldron now oozes back and inside the fragile glass container. With the poison in hand, it is time to return to Shadow Priestess Vandis at the Bulwark to complete the mission."] = 5234,
				["You carefully fill the bottle with enough of the cauldron's ichors for what you consider to be suitably sized sample. With the poison in hand, it to be suitably sized sample. With the poison in hand, it is time to return to Shadow Priestess Vandis at the Bulwark to complete the mission."] = 5232
			}
		},
		["Hameya's Plea"] = 6024,
		["Claim Rackmore's Treasure!"] = 6161,
		["Arachnophobia"] = 6284,
		["Wanted: DWARVES!"] = 7401,
		["WANTED: Overseer Maltorius"] = 7701,
		["STOLEN: Smithing Tuyere and Lookout's Spyglass"] = 7728,
		["JOB OPPORTUNITY: Culling the Competition"] = 7729,
		["Wanted: Vile Priestess Hexx and Her Minions"] = 7861,
		["Job Opening: Guard Captain of Revantusk Village"] = 7862,
		["Nat's Measuring Tape"] = 8227,
		["Wanted - Deathclasp, Terror of the Sands"] = 8283,
		["Sharing the Knowledge"] = 8313,
		["Ruined Kegs"] = 8409,
		["A Pawn on the Eternal Board"] = 8519,
		["Scrying Goggles? No Problem!"] = 8578,
		["rAnS0m"] = 8598,
		["Suspicious Hoofprints"] = 1268,
		["The Collector"] = 123,
		["Theocritus' Retrieval"] = 178,
		["Furlbrow's Deed"] = 184,
		["An Old History Book"] = 337,
		["A Letter Undelivered"] = 361,
		["The Unsent Letter"] = 373,
		["Resting in Pieces"] = 460,
		["Assassin's Contract"] = 522,
		["The Ensorcelled Parchment"] = 551,
		["The Monogrammed Sash"] = 8552,
		["Sully Balloo's Letter"] = 637,
		["The Black Box"] = 708,
		["Crystal in the Mountains"] = 635,
		["The Demon Scarred Cloak"] = 770,
		["Burning Shadows"] = 832,
		["Lakota'mani"] = 883,
		["Owatanka"] = 884,
		["Washte Pawne"] = 885,
		["The Harvester"] = 897,
		["The Moss-twined Heart"] = 927,
		["The Powers Below"] = 968,
		["Lonebrow's Journal"] = 1100,
		["The Lost Supplies"] = 1423,
		["Noboru the Cudgel"] = 1392,
		["The Shattered Necklace"] = 2198,
		["Tanaris Field Sampling"] = 654,
		["Find OOX-17/TN!"] = 351,
		["Find OOX-09/HL!"] = 485,
		["Find OOX-22/FE!"] = 2766,
		["Ship Schedules"] = 2876,
		["Cuergo's Gold"] = 2882,
		["Grime-Encrusted Ring"] = 2945,
		["The Gordunni Scroll"] = 2978,
		["The Horn of the Beast"] = 3181,
		["The Glowing Shard"] = 6981,
		["The Essence of Eranikus"] = 	{
			["Essence of Eranikus"] = 3373,
			["Oathstone of Ysera's Dragonflight"] = 3374
		},
		["The Runed Scroll"] = 3513,
		["Williden's Journal"] = 3884,
		["Thalanaar Delivery"] = 4281,
		["Flute of Xavaric"] = 939,
		["The Key to Freedom"] = 4451,
		["Assassination Plot"] = 4881,
		["Winterfall Firewater"] = 5083,
		["General Drakkisath's Command"] = 5089,
		["The Final Piece"] = 5123,
		["A Strange Red Key"] = 5202,
		["The Truth Comes Crashing Down"] = 5262,
		["Healthy Dragon Scale"] = 5582,
		["Welcome!"] = 	{
			["Goldshire Gift Voucher"] = 5805,
			["Kharanos Gift Voucher"] = 5841,
			["Dolanaar Gift Voucher"] = 5842,
			["Razor Hill Gift Voucher"] = 5843,
			["Bloodhoof Village Gift Voucher"] = 5844,
			["Brill Gift Voucher"] = 5847
		},
		["Ursangous's Paw"] = 23,
		["Shadumbra's Head"] = 24,
		["Sharptalon's Claw"] = 2,
		["The Befouled Element"] = 1918,
		["Baron Aquanis"] = 6922,
		["The Manor, Ravenholdt"] = 6681,
		["<NYI> <TXT> bug crystal side quest"] = 1155,
		["Garona: A Study on Stealth and Treachery"] = 7498,
		["Codex of Defense"] = 7499,
		["The Arcanist's Cookbook"] = 7500,
		["The Light and How To Swing It"] = 7501,
		["Harnessing Shadows"] = 7502,
		["The Greatest Race of Hunters"] = 7503,
		["Holy Bologna: What the Light Won't Tell You"] = 7504,
		["Frost Shock and You"] = 7505,
		["The Emerald Dream..."] = 7506,
		["Victory for the Horde"] = 7490,
		["Victory for the Alliance"] = 7495,
		["Examine the Vessel"] = 	{
			["Vessel of Rebirth DEPRECATED"] = 7522,
			["Vessel of Rebirth"] = 7785
		},
		["A Binding Contract"] = 7604,
		["The Ancient Leaf"] = 7632,
		["Arena Master"] = 7810,
		["Enchanted Thorium Platemail: Volume I"] = 7649,
		["Enchanted Thorium Platemail: Volume II"] = 7650,
		["Enchanted Thorium Platemail: Volume III"] = 7651,
		["Look at the Size of It!"] = 7704,
		["Pristine Yeti Hide"] = 7735,
		["Perfect Yeti Hide"] = 7738,
		["Blackhand's Command"] = 7761,
		["Rise, Thunderfury!"] = 7787,
		["Darkmoon Beast Deck"] = 7907,
		["Darkmoon Warlords Deck"] = 7928,
		["Darkmoon Elementals Deck"] = 7929,
		["Darkmoon Portals Deck"] = 7927,
		["Your Fortune Awaits You..."] = 	{
			["Sayge's Fortune #23"] = 7937,
			["Sayge's Fortune #24"] = 7938,
			["Sayge's Fortune #25"] = 7944,
			["Sayge's Fortune #27"] = 7945
		},
		["Brann Bronzebeard's Lost Letter"] = 8308,
		["Shrouded in Nightmare"] = 8446,
		["Deadwood Ritual Totem"] = 8470,
		["Winterfall Ritual Totem"] = 8471,
		["Bandages for the Field"] = 8496,
		["Desert Survival Kits"] = 8497,
		["Boots for the Guard"] = 8540,
		["Grinding Stones for the Guard"] = 8541,
		["Target: Hive'Ashi Stingers"] = 8501,
		["Target: Hive'Ashi Workers"] = 8502,
		["Twilight Battle Orders"] = 8498,
		["Twilight Marauders"] = 8740,
		["Crimson Templar"] = 8537,
		["Hoary Templar"] = 8535,
		["The Four Dukes"] = 8538,
		["Azuregos's Magical Ledger"] = 8575,
		["Hive'Zora Scout Report"] = 8534,
		["Hive'Regal Scout Report"] = 8738,
		["Hive'Ashi Scout Report"] = 8739,
		["The Fall of Ossirian"] = 8791,
		["C'Thun's Legacy"] = 8801,
		["Secrets of the Qiraji"] = 8784,
		["Azure Templar"] = 8737,
		["Target: Hive'Zora Reavers"] = 8773,
		["Target: Hive'Zora Hive Sisters"] = 8539,
		["Target: Hive'Zora Waywatchers"] = 8772,
		["Target: Hive'Zora Tunnelers"] = 8687,
		["Target: Hive'Regal Ambushers"] = 8774,
		["Target: Hive'Regal Spitfires"] = 8775,
		["Target: Hive'Regal Slavemakers"] = 8776,
		["Target: Hive'Regal Burrowers"] = 8777,
		["The Ironforge Brigade Needs Explosives!"] = 8778,
		["The Orgrimmar Legion Needs Mojo!"] = 8785,
		["Scrying Materials"] = 8807,
		["Arms for the Field"] = 	{
			["Logistics Task Briefing VI"] = 		{
				["The Ironforge Brigade has been a worthy ally in our fight in Silithus. Unfortunately, many of their supplies were lost on their way here. Procure Silithus. Unfortunately, many of their supplies were lost on their way here. Procure a batch of weapons and deliver them to Janela Stouthammer near Hive'Zora."] = 8781,
				["The Orgrimmar Legion has put in a request for additional weapons that we haven't been able to provide at the moment. Obtain the weapons they've weapons that we haven't been able to provide at the moment. Obtain the weapons they've requested and bring them to Merok Longstride outside of Hive'Regal."] = 8786
			}
		},
		["Uniform Supplies"] = 8782,
		["Armor Kits for the Field"] = 	{
			["Logistics Task Briefing VII"] = 		{
				["The Ironforge Brigade's supply of armor kits in the battlefield is running dangerously low. Obtain a batch and deliver them to Janela Stouthammer at the armor kits in the battlefield is running dangerously low. Obtain a batch and deliver them to Janela Stouthammer at the Ironforge Brigade's outpost outside Hive'Zora."] = 8780,
				["The brave volunteers of the Orgrimmar Legion have arrived to Silithus to aid us in our cause. Their supplies of armor kits were somehow lost somehow lost in the trip. Obtain a batch of armor kits and deliver them to Merok Longstride at the location of the Orgrimmar Legion camp."] = 8787
			}
		},
		["Extraordinary Materials"] = 8783,
		["The Ultimate Deception"] = 8829,
		["Target: Hive'Ashi Defenders"] = 8770,
		["Target: Hive'Ashi Sandstalkers"] = 8771,
		["Earthen Templar"] = 8536,
		["The Fall of Kel'Thuzad"] = 9120,
		["Craftsman's Writ - Dense Weightstone"] = 9178,
		["Craftsman's Writ - Imperial Plate Chest"] = 9179,
		["Craftsman's Writ - Volcanic Hammer"] = 9181,
		["Craftsman's Writ - Huge Thorium Battleaxe"] = 9182,
		["Craftsman's Writ - Radiant Circlet"] = 9183,
		["Craftsman's Writ - Wicked Leather Headband"] = 9184,
		["Craftsman's Writ - Rugged Armor Kit"] = 9185,
		["Craftsman's Writ - Wicked Leather Belt"] = 9186,
		["Craftsman's Writ - Runic Leather Pants"] = 9187,
		["Craftsman's Writ - Brightcloth Pants"] = 9188,
		["Craftsman's Writ - Runecloth Boots"] = 9190,
		["Craftsman's Writ - Runecloth Bag"] = 9191,
		["Craftsman's Writ - Runecloth Robe"] = 9194,
		["Craftsman's Writ - Goblin Sapper Charge"] = 9195,
		["Craftsman's Writ - Thorium Grenade"] = 9196,
		["Craftsman's Writ - Gnomish Battle Chicken"] = 9197,
		["Craftsman's Writ - Thorium Tube"] = 9198,
		["Craftsman's Writ - Major Mana Potion"] = 9200,
		["Craftsman's Writ - Major Healing Potion"] = 9202,
		["Craftsman's Writ - Greater Arcane Protection Potion"] = 9201,
		["Craftsman's Writ - Potion of Petrification"] = 9203,
		["Craftsman's Writ - Stonescale Eel"] = 9204,
		["Craftsman's Writ - Plated Armorfish"] = 9205,
		["Craftsman's Writ - Lightning Eel"] = 9206,
		["Omarion's Handbook"] = 9233,
		["The Keeper's Call"] = 9247,
		["Frame of Atiesh"] = 9250,
		["Envelope from the Front"] = 9301,
		["Note from the Front"] = 9299,
		["Missive from the Front"] = 9302,
		["Page from the Front"] = 9300,
		["Document from the Front"] = 9304,
		["Letter from the Front"] = 9295,
		["Stealing Orgrimmar's Flame"] = 9324,
		["Stealing Thunder Bluff's Flame"] = 9325,
		["Stealing the Undercity's Flame"] = 9326,
		["Stealing Stormwind's Flame"] = 9330,
		["Stealing Ironforge's Flame"] = 9331,
		["Stealing Darnassus's Flame"] = 9332,
		["Personal Property"] = 24914
	},
	["complete"] = {
		["Wolves Across the Border"] = 33,
		["Eagan Peltskinner"] = 5261,
		["Kobold Camp Cleanup"] = 7,
		["Investigate Echo Ridge"] = 15,
		["Skirmish at Echo Ridge"] = 21,
		["A Threat Within"] = 783,
		["Glyphic Letter"] = 3104,
		["The Killing Fields"] = 9,
		["The People's Militia"] = 	{
			["Gryan Stoutmantle"] = 		{
				["Well done, $N. My scout witnessed your valiant acts. You are proving yourself quite well so far. Well done, $N. My scout witnessed your valiant acts. You are proving yourself quite well so far."] = 12,
				["Your worth to The People's Militia has been validated by your brave acts thus far. Your worth to The People's Militia has been validated by your brave acts thus far."] = 13,
				["When I left the tainted lands of Lordaeron I returned to a grim state of affairs here in my homeland. But there is hope for you serve our cause with honor. It is with great pride that I induct thee into The People's Militia. May the Light shine upon you."] = 14
			}
		},
		["Report to Gryan Stoutmantle"] = 109,
		["The Defias Brotherhood"] = 	{
			["Gryan Stoutmantle"] = 		{
				["Bah! I should have let that scoundrel rot when I had the chance. But this information is crucial. Good work. Bah! I should have let that scoundrel rot when I had the chance. But this information is crucial. Good work."] = 132,
				["Edwin VanCleef. . .I know the name well. To think that a man so industrious and talented could turn into such a scoundrel unnerves me. To think that a man so industrious and talented could turn into such a scoundrel unnerves me. I'll need further proof before I believe this."] = 141,
				["This is indeed firm proof that VanCleef is in charge. Now all we need to know is where the Defias gang is hiding out. We've had for his life. I want you to defend the traitor so he can reveal the hideout. Return to me once you have uncovered the location."] = 142,
				["Most excellent, $N! VanCleef is as good as ours now that we know where he is hiding. Most excellent, $N! VanCleef is as good as ours now that we know where he is hiding."] = 155,
				["$N, your bravery is remarkable. The People's Militia thanks you for your service to the people of Westfall. With VanCleef dead, this marks the beginning of the end for the Defias Brotherhood. Hopefully some day soon peace will once again grace the plains of this fair land. I salute you, $gLord:Lady;!"] = 166
			},
			["Wiley the Black"] = 65,
			["Master Mathias Shaw"] = 135
		},
		["Messenger to Westfall"] = 	{
			["Gryan Stoutmantle"] = 143,
			["Magistrate Solomon"] = 144
		},
		["Goretusk Liver Pie"] = 22,
		["Westfall Stew"] = 	{
			["Salma Saldean"] = 		{
				["That Verna was always such a sweet lass. We'll miss her here in Westfall but between you and me, she's a city girl at heart you and me, she's a city girl at heart and Stormwind will suit her just fine. But enough gossip! Now we can make Westfall Stew!"] = 36,
				["That Okra will thicken up this broth nicely! Now we just add the Stringy Vulture Meat, a few Murloc Eyes and those delicious Goretusk Snouts. Eyes and those delicious Goretusk Snouts. And we're done! For all your help, $N, I want you to take today's first batch of Westfall Stew!"] = 38
			}
		},
		["The Forgotten Heirloom"] = 64,
		["Furlbrow's Deed"] = 184,
		["Poor Old Blanchy"] = 151,
		["Sweet Amber"] = 	{
			["Grimbooze Thunderbrew"] = 		{
				["Hiccup! Ho Ho! Hiccup! Ho Ho!"] = 48,
				["Hiccup! Ho ho! Hiccup! Ho ho!"] = 49,
				["Aged in the barrel, filtered through coal It passes your lips and right through your soul. So lets us drink now, a toast to you And me while through coal It passes your lips and right through your soul. So lets us drink now, a toast to you And me while we're at it, Grimbooze Thunderbrew!"] = 53
			}
		},
		["Thunderbrew Lager"] = 117,
		["Deliver Thomas' Report"] = 39,
		["A Fishy Peril"] = 40,
		["Report to Goldshire"] = 54,
		["The Fargodeep Mine"] = 62,
		["The Jasperlode Mine"] = 76,
		["The Collector"] = 123,
		["Manhunt"] = 147,
		["Wanted:  'Hogger'"] = 176,
		["Gold Dust Exchange"] = 47,
		["Princess Must Die!"] = 88,
		["Pie for Billy"] = 86,
		["Goldtooth"] = 87,
		["Back to Billy"] = 84,
		["Lost Necklace"] = 85,
		["Speak with Gramma"] = 111,
		["The Escape"] = 	{
			["Maybell Maclure"] = 114,
			["Sputtervalve"] = 863
		},
		["Young Lovers"] = 106,
		["Kobold Candles"] = 60,
		["Note to William"] = 107,
		["Collecting Kelp"] = 112,
		["Give Gerard a Drink"] = 16,
		["Further Concerns"] = 35,
		["Bounty on Murlocs"] = 46,
		["Protect the Frontier"] = 52,
		["Report to Thomas"] = 71,
		["Messenger to Darkshire"] = 	{
			["Lord Ello Ebonlocke"] = 145,
			["Magistrate Solomon"] = 146
		},
		["Note to the Mayor"] = 160,
		["Translation to Ello"] = 252,
		["Bride of the Embalmer"] = 253,
		["The Night Watch"] = 	{
			["Commander Althea Ebonlocke"] = 		{
				["Splendid, $N. For your service to the people of Darkshire you shall be rewarded. Splendid, $N. For your service to the people of Darkshire you shall be rewarded."] = 56,
				["The people of Darkshire thank you, $N. You have proven yourself to be a great ally of The Night Watch. The people of Darkshire thank you, $N. You have proven yourself to be a great ally of The Night Watch."] = 57,
				["On behalf of the people of Darkshire and as the Leader of the Night Watch, I thank you, $N, for your bravery and dedication. May Darkshire and as the Leader of the Night Watch, I thank you, $N, for your bravery and dedication. May the Light shine upon your ways."] = 58
			}
		},
		["The Legend of Stalvan"] = 	{
			["Commander Althea Ebonlocke"] = 		{
				["My, you have proved yourself to be quite a detective, $c. My, you have proved yourself to be quite a detective, $c."] = 79,
				["I knew it! Fine work, $N. I knew it! Fine work, $N."] = 97
			},
			["Madame Eva"] = 98,
			["Clerk Daltry"] = 		{
				["Ah so Madame Eva sent you.... Ah so Madame Eva sent you...."] = 66,
				["Interesting. So the chap did spend some time in Moonbrook after all. It is rather odd the letter never got delivered. Nonetheless, I shall update the chap did spend some time in Moonbrook after all. It is rather odd the letter never got delivered. Nonetheless, I shall update the registry."] = 68,
				["Why yes! The writing on this page does in fact match that of the registry signatures. Why yes! The writing on this page does in fact match that of the registry signatures."] = 80
			},
			["Tavernkeep Smitts"] = 78,
			["Marshal Haggard"] = 		{
				["I can barely make out those letters. But that writing style reminds me of something I once saw before my vision became so poor. I can barely make out those letters. But that writing style reminds me of something I once saw before my vision became so poor."] = 74,
				["You found it! You found it!"] = 75
			},
			["Innkeeper Farley"] = 69,
			["Caretaker Folsom"] = 70,
			["Sealed Crate"] = 72,
			["Old Footlocker"] = 67
		},
		["Morgan Ladimore"] = 227,
		["Mor'Ladim"] = 228,
		["The Totem of Infliction"] = 101,
		["Supplies from Darkshire"] = 148,
		["Return the Comb"] = 154,
		["The Shadowy Figure"] = 262,
		["The Shadowy Search Continues"] = 265,
		["The Caravan Road"] = 1041,
		["The Weathered Grave"] = 225,
		["Translate Abercrombie's Note"] = 251,
		["Wait for Sirra to Finish"] = 401,
		["Crime and Punishment"] = 377,
		["Jitters' Growling Gut"] = 5,
		["Seasoned Wolf Kabobs"] = 90,
		["Dusky Crab Cakes"] = 93,
		["Gather Rot Blossoms"] = 156,
		["Zombie Juice"] = 158,
		["Inquire at the Inn"] = 266,
		["Look To The Stars"] = 	{
			["Viktori Prism'Antras"] = 		{
				["This is perfect, $N. The first step is complete! This is perfect, $N. The first step is complete!"] = 174,
				["Most superb! This will work perfectly. Many thanks! Most superb! This will work perfectly. Many thanks!"] = 177,
				["At last! The stargazing device is complete! Thank you, $N. Now I can continue my research. . . At last! The stargazing device is complete! Thank you, $N. Now I can continue my research. . ."] = 181
			},
			["Blind Mary"] = 175
		},
		["Cloth and Leather Armor"] = 59,
		["Red Linen Goods"] = 83,
		["Shipment to Stormwind"] = 61,
		["Raven Hill"] = 163,
		["Return to Jitters"] = 240,
		["Finding the Shadowy Figure"] = 453,
		["Ghoulish Effigy"] = 133,
		["Ogre Thieves"] = 134,
		["Deliver the Thread"] = 157,
		["Juice Delivery"] = 159,
		["The Hermit"] = 165,
		["Marshal Haggard"] = 1666,
		["Dead-tooth Jack"] = 1667,
		["Rest and Relaxation"] = 2158,
		["Ghost Hair Thread"] = 149,
		["Morbent Fel"] = 55,
		["Deliveries to Sven"] = 164,
		["Sven's Camp"] = 230,
		["Return to Sven"] = 268,
		["Proving Your Worth"] = 323,
		["Armed and Ready"] = 325,
		["Theocritus' Retrieval"] = 178,
		["Morganth"] = 249,
		["Shadow of the Past"] = 393,
		["The Head of the Beast"] = 394,
		["Seek out SI: 7"] = 2205,
		["Snatch and Grab"] = 2206,
		["Klaven's Tower"] = 2359,
		["The First and the Last"] = 6182,
		["Honor the Dead"] = 6183,
		["The Everstill Bridge"] = 89,
		["The Lost Tools"] = 125,
		["Ink Supplies"] = 345,
		["An Unwelcome Guest"] = 34,
		["Visit the Herbalist"] = 130,
		["Redridge Goulash"] = 92,
		["Messenger to Stormwind"] = 	{
			["Magistrate Solomon"] = 121,
			["General Marcus Jonathan"] = 120
		},
		["Wanted: Gath'Ilzogg"] = 169,
		["Wanted: Lieutenant Fangore"] = 180,
		["Dry Times"] = 116,
		["Dungar Longdrink"] = 6261,
		["Hallowed Letter"] = 3103,
		["In Favor of the Light"] = 	{
			["Priestess Josetta"] = 5623,
			["Maxan Anvol"] = 5626
		},
		["Garments of the Light"] = 	{
			["Priestess Josetta"] = 5624,
			["Maxan Anvol"] = 5625
		},
		["Delivering Daffodils"] = 131,
		["Selling Fish"] = 127,
		["Murloc Poachers"] = 150,
		["Tharil'zun"] = 19,
		["Blackrock Menace"] = 20,
		["Shadow Magic"] = 115,
		["Missing In Action"] = 219,
		["Keeper of the Flame"] = 103,
		["The Coastal Menace"] = 104,
		["The Coast Isn't Clear"] = 152,
		["Return to Verner"] = 119,
		["Underbelly Scales"] = 122,
		["A Baying of Gnolls"] = 124,
		["Howling in the Hills"] = 126,
		["Gearing Redridge"] = 1618,
		["Tainted Letter"] = 3105,
		["Tainted Memorandum"] = 3115,
		["A Free Lunch"] = 129,
		["Colonel Kurzen"] = 202,
		["Jungle Secrets"] = 215,
		["The Spy Revealed!"] = 329,
		["Report to Doren"] = 331,
		["Special Forces"] = 574,
		["Look to an Old Friend"] = 350,
		["The Attack!"] = 434,
		["The Missing Diplomat"] = 	{
			["Elling Trias"] = 		{
				["I'm sorry, a letter for me? Well, I'll be... not often you get a delivery that's not a crate or barrel when all you do do is work. Let's see what this is about. <Elling looks up at you while he opens the letter.> You look a little tense, you okay, $N?"] = 1242,
				["Yeah... this is an interesting read. Jorgen and DeLavey were smart to bring me in on this. Seems the Defias have been trying pretty hard to me in on this. Seems the Defias have been trying pretty hard to complete this plan of theirs. Hmm... what's this? Fist? That's a familiar name."] = 1245,
				["Good to see you're still alive, $N. So, it went well with Dashel then, huh? I've been reading up more on this plan of theirs, and to capture him. This Slim that Dashel mentioned doesn't have any other name written here, but if you say he's in Menethil, then that's a start."] = 1247
			},
			["Watcher Backus"] = 		{
				["Oh, Trias sent you, huh? That's a little different. Feel free to fight whatever monstrosities come at you from the darkness. I'm sure you'll be able the type to be hanging around with the likes of him. So, what does my friend need of me on such a gloomy day as this?"] = 1243,
				["You're back safe and sound. Couldn't ask for much more than that, could you? Now, let's see what we have here. This looks pretty official as as any Defias documents I've seen. But it could be a dupe just to throw you off track of whatever it is you're looking for."] = 1244
			},
			["Jorgen"] = 1241,
			["Bishop DeLavey"] = 1274,
			["Dashel Stonefist"] = 		{
				["What?! You come into me alley and ask questions about me personal business? Business which you obviously have nothing to do with. What?! You come into me alley and ask questions about me personal business? Business which you obviously have nothing to do with."] = 1246,
				["So, you came to me for a reason. What is it you need? So, you came to me for a reason. What is it you need?"] = 1447
			},
			["Mikhail"] = 		{
				["Welcome, welcome, welcome, $N. Good of you to join us. Perhaps an ale today? Or some mutton? Name your pleasure and I'll see to it that I look forward to serving you. Hmm? What's that? Trias? Keep your voice down, my friend. This isn't something for the whole tavern to hear about."] = 1248,
				["Caught him, huh? Good for you. I'm surprised that was Slim. I'll be honest, I never thought I'd miss the excitement of some of the more action. I'm glad I could at least be of a little service to you while you were in Menethil. If you need anything else, just ask."] = 1249,
				["THE KING?! I mean... the king? The real king? Are you joking? You didn't mention you were looking for the king's kidnappers. I didn't even got to have honor when it comes to some things. The key now is to find this Hendel. And I think I can help with that."] = 1250
			},
			["Commander Samaul"] = 1264,
			["Private Hendel"] = 1266,
			["Archmage Tervosh"] = 		{
				["The man you seek, the one known as Hendel, is not here. Other sources have brought to the Lady Proudmoore information I believe you already aid in your venture. If you would allow it, I will tell you where to find Private Hendel so we can bring him to justice."] = 1265,
				["I assure you, we're all quite upset about current events, but allow us to take him back to Theramore for some questioning, and we'll see see about finding the King. I'm sure my lady Proudmore would like to thank you for your help. Speak to her when you have a moment."] = 1324
			},
			["Lady Jaina Proudmoore"] = 1267
		},
		["Return to Lewis"] = 6285,
		["The Price of Shoes"] = 118,
		["A Swift Message"] = 6181,
		["The Daughter Who Lived"] = 229,
		["CLUCK!"] = 3861,
		["Oh Brother. . ."] = 167,
		["Collecting Memories"] = 168,
		["Dwarven Outfitters"] = 179,
		["Worgen in the Woods"] = 	{
			["Jonathan Carevin"] = 223,
			["Calor"] = 		{
				["Impressive, $N. It would seem that you are capable enough to handle yourself. Perhaps a more suitable challenge could be found for one of your of thin air. But then, with all the other strange creatures that have moved across our borders, I suppose it's only one of many concerns."] = 173,
				["You performed well against the Dark Runners, $N. But it seems as though their numbers are inexhaustible. Every time we make progress, more spring up they come to disturb our unhappy realm... I will put my faith in Master Carevin. No doubt he will get to the bottom of the problem."] = 221,
				["$N, to be honest with you, I did not believe that you would get this far, but you are clearly a $c to be reckoned to be reckoned with. In fact, if you wish to formally join Master Carevin's struggle, I will gladly write for you a letter of recommendation."] = 222
			}
		},
		["The Carevin Family"] = 1042,
		["The Scythe of Elune"] = 1043,
		["A New Threat"] = 170,
		["The Boar Hunter"] = 183,
		["Coldridge Valley Mail Delivery"] = 	{
			["Talin Keeneye"] = 233,
			["Grelin Whitebeard"] = 234
		},
		["Raptor Mastery"] = 	{
			["Hemet Nesingwary Jr."] = 		{
				["Nicely done, $g old chap : m'lady;! Nicely done, $g old chap : m'lady;!"] = 194,
				["Now that's how you get a trophy or two over the ol' hearth! Nice killing, $N! Now that's how you get a trophy or two over the ol' hearth! Nice killing, $N!"] = 195,
				["Ho ho!! We have ourselves a true raptor slayer! Nicely done, $g old chap : fair lady;! Ho ho!! We have ourselves a true raptor slayer! Nicely done, $g old chap : fair lady;!"] = 196,
				["$G Master : Mistress; $N, the raptor slayer! Has a nice ring to it, eh? $G Master : Mistress; $N, the raptor slayer! Has a nice ring to it, eh?"] = 197
			}
		},
		["Big Game Hunter"] = 208,
		["Welcome to the Jungle"] = 583,
		["Hemet Nesingwary Jr."] = 5762,
		["Hunting in Stranglethorn"] = 5763,
		["The Green Hills of Stranglethorn"] = 338,
		["Chapter I"] = 339,
		["Chapter II"] = 340,
		["Chapter III"] = 341,
		["Chapter IV"] = 342,
		["Tiger Mastery"] = 	{
			["Ajeck Rouack"] = 		{
				["Nicely done, $N. You are ready to move on. Nicely done, $N. You are ready to move on."] = 185,
				["I am impressed, $c. You are progressing quite well. I am impressed, $c. You are progressing quite well."] = 186,
				["Most impressive. I believe you are almost ready. Most impressive. I believe you are almost ready."] = 187,
				["Most impressive, I do say! You are a true Master Tiger Hunter, $N! Most impressive, I do say! You are a true Master Tiger Hunter, $N!"] = 188
			}
		},
		["Panther Mastery"] = 	{
			["Sir S. J. Erlgadin"] = 		{
				["Off to a good start, $N! Off to a good start, $N!"] = 190,
				["Perfectly executed, $N! Perfectly executed, $N!"] = 191,
				["You've done well, $N! You've done well, $N!"] = 192,
				["So the great Bhag'thera is dead! Cheers to you, $N. You are a mighty $c indeed! So the great Bhag'thera is dead! Cheers to you, $N. You are a mighty $c indeed!"] = 193
			}
		},
		["The Second Rebellion"] = 203,
		["Bad Medicine"] = 204,
		["Bloodscalp Ears"] = 189,
		["Skullsplitter Tusks"] = 209,
		["Hostile Takeover"] = 213,
		["Supplies to Private Thorsen"] = 198,
		["Troll Witchery"] = 205,
		["Mai'Zoth"] = 206,
		["Kurzen's Mystery"] = 207,
		["Return to Corporal Kaleb"] = 622,
		["Investigate the Camp"] = 201,
		["Krazek's Cookery"] = 210,
		["Favor for Krazek"] = 627,
		["The Rumormonger"] = 1115,
		["Dream Dust in the Swamp"] = 1116,
		["The Troll Cave"] = 182,
		["The Stolen Journal"] = 218,
		["Red Silk Bandanas"] = 214,
		["Patrolling Westfall"] = 102,
		["Bounty on Garrick Padfoot"] = 6,
		["Brotherhood of Thieves"] = 18,
		["Scalding Mornbrew Delivery"] = 3364,
		["Hallowed Rune"] = 3110,
		["What Comes Around..."] = 386,
		["Red Leather Bandanas"] = 153,
		["Eight-Legged Menaces"] = 245,
		["Wolves at Our Heels"] = 226,
		["Etched Rune"] = 3108,
		["Solomon's Law"] = 91,
		["Blackrock Bounty"] = 128,
		["Simple Letter"] = 3100,
		["Simple Rune"] = 3106,
		["Simple Memorandum"] = 3112,
		["Encrypted Letter"] = 	{
			["Jorik Kerridan"] = 3102,
			["Loremaster Dibbs"] = 511
		},
		["Encrypted Rune"] = 3109,
		["Encrypted Memorandum"] = 3113,
		["Consecrated Letter"] = 3101,
		["Consecrated Rune"] = 3107,
		["Lord Grayson Shadowbreaker"] = 7638,
		["To Show Due Judgment"] = 7639,
		["Exorcising Terrordale"] = 7640,
		["Blessed Arcanite Barding"] = 7644,
		["The Divination Scryer"] = 7646,
		["Grimand's Finest Work"] = 7648,
		["Again Into the Great Ossuary"] = 7666,
		["Glyphic Memorandum"] = 3114,
		["Brother Paxton"] = 344,
		["Rethban Ore"] = 347,
		["Grape Manifest"] = 3905,
		["Riverpaw Gnoll Bounty"] = 11,
		["Westbrook Garrison Needs Help!"] = 239,
		["Broken Alliances"] = 	{
			["Gorn"] = 		{
				["With Tho'grun dead, his corpse picked clean by the desert winds and scavenging buzzards, the ogres will be put into disarray. Though a small victory, now in our possession, and we can open the black drakes' prison in Lethlor. We shall free them from endless imprisonment, albeit to their doom!"] = 782,
				["The black dragonflight continues to ally with the renegade Blackrock orcs, and both must be brought into line, or removed. With Blacklash and Hematus dead, Blackrock orcs, and both must be brought into line, or removed. With Blacklash and Hematus dead, we can turn our attentions westwards, towards Blackrock Spire."] = 793
			}
		},
		["Encroaching Gnolls"] = 244,
		["Assessing the Threat"] = 246,
		["A Grim Task"] = 304,
		["Fall of Dun Modr"] = 472,
		["A Dark Threat Looms"] = 	{
			["Ashlan Stonesmirk"] = 161,
			["Chief Engineer Hinderweir VII"] = 		{
				["This is an alarming discovery, to say the least! This is an alarming discovery, to say the least!"] = 199,
				["A disarming colloid? For Seaforium? Oh heavens! A disarming colloid? For Seaforium? Oh heavens!"] = 274,
				["Just in time, $N! Just in time, $N!"] = 278,
				["Thank you so much, $N!! You have saved the Stonewrought Dam! Without your help, the Dark Iron terrorists would have surely seen to this mighty made the Kingdom and the Alliance proud, brave $c. The Dam is once again safe. . . for the time being at least. . . ."] = 283
			},
			["Suspicious Barrel"] = 250,
			["Explosive Charge"] = 280
		},
		["The Dark Iron War"] = 303,
		["The Fury Runs Deep"] = 378,
		["The Thandol Span"] = 	{
			["Rhag Garmason"] = 		{
				["Oh my, the news is grave.... Oh my, the news is grave...."] = 632,
				["The remaining bridge is saved! You have done a great service to King Magni and the people of Khaz Modan. Now if we can only hold done a great service to King Magni and the people of Khaz Modan. Now if we can only hold out long enough for reinforcements to show..."] = 633
			},
			["Ebenezer Rustlocke's Corpse"] = 631
		},
		["In Search of The Excavation Team"] = 	{
			["Merrin Rockweaver"] = 305,
			["Tarrel Rockweaver"] = 306
		},
		["Uncovering the Past"] = 299,
		["Ormer's Revenge"] = 	{
			["Ormer Ironbraid"] = 		{
				["Killing is a dirty business, but you did your job well, $N. If I weren't obligated to stay with the Prospector and Merrin, I'd be your job well, $N. If I weren't obligated to stay with the Prospector and Merrin, I'd be down there shedding blood right along side you."] = 294,
				["You did a bang-up job of clearing out those Raptors, $N! You did a bang-up job of clearing out those Raptors, $N!"] = 295,
				["Thank you, $N. Your efforts here will not be forgotten. Many innocent Dwarves died at this site, simply doing their jobs. The vengeance you delivered site, simply doing their jobs. The vengeance you delivered to those evil creatures should make them think twice before attacking King Magni's subjects ever again."] = 296
			}
		},
		["In Defense of the King's Lands"] = 	{
			["Mountaineer Cobbleflint"] = 224,
			["Mountaineer Wallbang"] = 263,
			["Mountaineer Gravelgaw"] = 237,
			["Captain Rugelfuss"] = 217
		},
		["The Trogg Threat"] = 267,
		["Excavation Progress Report"] = 298,
		["Powder to Ironband"] = 302,
		["Mercenaries"] = 255,
		["WANTED: Chok'sul"] = 256,
		["A Meal Served Cold"] = 212,
		["Feast at the Blue Recluse"] = 1271,
		["Crocolisk Hunting"] = 385,
		["Vyrin's Revenge"] = 	{
			["Vyrin Swiftwind"] = 531,
			["Daryl the Youngling"] = 271
		},
		["Down the Scarlet Path"] = 	{
			["Brother Anton"] = 261,
			["Raleigh the Devout"] = 1052
		},
		["Brother Anton"] = 6141,
		["A Hunter's Boast"] = 257,
		["A Hunter's Challenge"] = 258,
		["Seeking Wisdom"] = 269,
		["The Doomed Fleet"] = 270,
		["The Eye of Paleth"] = 292,
		["The Lost Ingots"] = 324,
		["Lightforge Ingots"] = 526,
		["Taming the Beast"] = 	{
			["Grif Wildheart"] = 		{
				["I know, I know; you're wondering what's next, aren't ya?! I know, I know; you're wondering what's next, aren't ya?!"] = 6064,
				["When I feel you've learned enough, I will grant you the ability to choose any pet of your liking. When I feel you've learned enough, I will grant you the ability to choose any pet of your liking."] = 6084,
				["Here you are, $N. I will now give ya the power to tame a beast, as well as call it and dismiss it as you power to tame a beast, as well as call it and dismiss it as you please. Find yerself a good, loyal pet, and enjoy the hunt!"] = 6085
			},
			["Yaw Sharpmane"] = 		{
				["Signs have appeared to me from the Earthmother; you have done well. Signs have appeared to me from the Earthmother; you have done well."] = 6061,
				["Yes... The Earthmother believes that you are ready for the next lesson. Yes... The Earthmother believes that you are ready for the next lesson."] = 6087,
				["You have learned all I can teach you, $N. May the blessings of the Earthmother guide you in choosing a pet. Here you are, $N. I tame a beast, as well as call it and dismiss it as you see fit. Use your new skills with pride and honor the Earthmother."] = 6088
			},
			["Thotar"] = 		{
				["You have done well, $N. I believe you are ready for your next task. You have done well, $N. I believe you are ready for your next task."] = 6062,
				["You have learned all I can teach you, $N. It is time for you to take what you have learned here and choose a pet tame a beast, as well as call it and dismiss it as you see fit. Use your new skills with pride; you have earned them."] = 6082,
				["You are a swift learner, $N. You have done well. You are a swift learner, $N. You have done well."] = 6083
			},
			["Dazalar"] = 		{
				["Excellent, $N! You are quite a fast learner. Excellent, $N! You are quite a fast learner."] = 6063,
				["I see your commitment and that you have understood what I have taught you, $N. I see your commitment and that you have understood what I have taught you, $N."] = 6101,
				["You have learned all I can teach you, $N. May I offer you one more piece of advice: use discretion when choosing your first pet. tame a beast, as well as call it and dismiss it as you see fit. Use your new skills with pride; you have earned them."] = 6102
			}
		},
		["The Hunter's Path"] = 	{
			["Grif Wildheart"] = 6074,
			["Yaw Sharpmane"] = 6065,
			["Thotar"] = 6068,
			["Dazalar"] = 6071
		},
		["The Third Fleet"] = 288,
		["The Cursed Crew"] = 289,
		["Claws from the Deep"] = 279,
		["Return the Statuette"] = 286,
		["Ammo for Rumbleshot"] = 5541,
		["Blisters on The Land"] = 275,
		["Tramping Paws"] = 276,
		["Fire Taboo"] = 277,
		["The Greenwarden"] = 463,
		["Frostmane Hold"] = 287,
		["Senir's Observations"] = 	{
			["Senir Whitebeard"] = 420,
			["Mountaineer Thalos"] = 282
		},
		["Those Blasted Troggs!"] = 432,
		["Protecting the Herd"] = 314,
		["Tundra MacGrann's Stolen Stash"] = 312,
		["Beer Basted Boar Ribs"] = 384,
		["Hurley Blackbreath"] = 4126,
		["Ragnar Thunderbrew"] = 4128,
		["Gnogaine"] = 2926,
		["The Day After"] = 2927,
		["The Only Cure is More Green Glow"] = 2962,
		["Operation Recombobulation"] = 412,
		["The Reports"] = 291,
		["Cleansing the Eye"] = 293,
		["Bring the Light"] = 3636,
		["Gathering Materials"] = 	{
			["Wynne Larson"] = 1921,
			["Josef Gregorian"] = 1961
		},
		["Pristine Spider Silk"] = 1940,
		["Manaweave Robe"] = 1941,
		["Astral Knot Garment"] = 1942,
		["Continue to Stormwind"] = 6281,
		["Stout to Kadrell"] = 414,
		["Rat Catching"] = 416,
		["Report to Mountaineer Rockgar"] = 468,
		["Filthy Paws"] = 307,
		["Stormpike's Delivery"] = 353,
		["Mountaineer Stormpike's Task"] = 1339,
		["Protecting the Shipment"] = 309,
		["Agmond's Fate"] = 704,
		["Ironband Wants You!"] = 707,
		["Murdaloc"] = 739,
		["Gathering Idols"] = 297,
		["Ironband's Excavation"] = 436,
		["Report to Ironforge"] = 301,
		["Letter to Stormpike"] = 514,
		["Stormpike's Deciphering"] = 554,
		["The Hidden Chamber"] = 2240,
		["Distracting Jarven"] = 308,
		["The Perfect Stout"] = 315,
		["Evershine"] = 318,
		["A Favor for Evershine"] = 319,
		["Rejold's New Brew"] = 415,
		["Return to Marleth"] = 311,
		["Tools for Steelgrill"] = 400,
		["The Grizzled Den"] = 313,
		["Search for Incendicite"] = 466,
		["Stonegear's Search"] = 467,
		["Stocking Jetsteam"] = 317,
		["Return to Bellowfiz"] = 320,
		["After the Ambush"] = 454,
		["Blessed Arm"] = 322,
		["Elmore's Task"] = 1097,
		["Grimand Elmore"] = 1700,
		["Burning Blood"] = 1705,
		["Grimand's Armor"] = 1706,
		["The Work of Grimand Elmore"] = 7641,
		["Collection of Goods"] = 7642,
		["Patrol Schedules"] = 330,
		["Harlan Needs a Resupply"] = 333,
		["Package for Thurman"] = 334,
		["Wine Shop Advert"] = 332,
		["A Noble Brew"] = 	{
			["Zardeth of the Black Claw"] = 335,
			["Lord Baurles K. Wishock"] = 336
		},
		["An Old History Book"] = 337,
		["Speaking of Fortitude"] = 343,
		["Return to Milton"] = 542,
		["Report to Helgrum"] = 1420,
		["Pool of Tears"] = 1424,
		["Return to Fel'Zerul"] = 1444,
		["The Temple of Atal'Hakkar"] = 1445,
		["Return to Kristoff"] = 346,
		["Stranglethorn Fever"] = 	{
			["Witch Doctor Unbagwa"] = 349,
			["Fin Fizracket"] = 348
		},
		["Uldaman Reagent Run"] = 	{
			["Ghak Healtouch"] = 17,
			["Jarkal Mossmeld"] = 2202
		},
		["Badlands Reagent Run"] = 	{
			["Ghak Healtouch"] = 2500,
			["Jarkal Mossmeld"] = 2258
		},
		["Badlands Reagent Run II"] = 	{
			["Ghak Healtouch"] = 2501,
			["Jarkal Mossmeld"] = 2203
		},
		["Rear Guard Patrol"] = 356,
		["Forsaken Duties"] = 359,
		["A Putrid Task"] = 404,
		["The Mills Overrun"] = 426,
		["Speak with Dillinger"] = 1818,
		["Ulag the Cleaver"] = 1819,
		["Return the Book"] = 366,
		["Proving Allegiance"] = 409,
		["The Lich's Identity"] = 357,
		["The Prodigal Lich"] = 405,
		["The Prodigal Lich Returns"] = 411,
		["Rot Hide Origins"] = 444,
		["Wand to Bethor"] = 491,
		["Speak with Sevren"] = 355,
		["Graverobbers"] = 358,
		["Return to the Magistrate"] = 360,
		["The Family Crypt"] = 408,
		["The Engraved Ring"] = 440,
		["Deaths in the Family"] = 354,
		["The Haunted Mills"] = 362,
		["Speak with Coleman"] = 1820,
		["Agamand Heirlooms"] = 1821,
		["Heirloom Weapon"] = 1822,
		["At War With The Scarlet Crusade"] = 	{
			["Executor Zygand"] = 		{
				["Captain Perrine's death will undoubtedly please The Dark Lady. You have performed your duty well, $c. Captain Perrine's death will undoubtedly please The Dark Lady. You have performed your duty well, $c."] = 370,
				["Captain Vachon's death will slow down the Scarlet Crusade's advancement in Tirisfal quite a bit. But other threats loom. Captain Vachon's death will slow down the Scarlet Crusade's advancement in Tirisfal quite a bit. But other threats loom."] = 371,
				["You have done extremely well, $c. With ruthless fighters like you conquering in the name of The Forsaken our race is one step closer to name of The Forsaken our race is one step closer to defeating Arthas once and for all. I have a good feeling about you, comrade."] = 372,
				["Most excellent, $c. Your skill in the art of combat is undeniable. Most excellent, $c. Your skill in the art of combat is undeniable."] = 427
			}
		},
		["Vital Intelligence"] = 383,
		["Wanted: Maggot Eye"] = 398,
		["Fields of Grief"] = 	{
			["Apothecary Johaan"] = 365,
			["Captured Scarlet Zealot"] = 407
		},
		["A New Plague"] = 	{
			["Apothecary Johaan"] = 		{
				["You have done well, $N and I thank you for your efforts. You have done well, $N and I thank you for your efforts."] = 367,
				["The scales are perfect, $N. Exactly what I needed for this concoction. The scales are perfect, $N. Exactly what I needed for this concoction."] = 368,
				["Ah, this venom will do perfectly, $N. Everything else has been added to my concoction and boiled down. Finally, I am ready to try this will do perfectly, $N. Everything else has been added to my concoction and boiled down. Finally, I am ready to try this new deadly agent!"] = 369
			},
			["Captured Mountaineer"] = 492
		},
		["The Chill of Death"] = 375,
		["A Letter Undelivered"] = 361,
		["Rude Awakening"] = 363,
		["The Mindless Ones"] = 364,
		["Rattling the Rattlecages"] = 3901,
		["Night Web's Hollow"] = 380,
		["The Scarlet Crusade"] = 381,
		["The Red Messenger"] = 382,
		["Honor Students"] = 6387,
		["Gryth Thurden"] = 6388,
		["The Unsent Letter"] = 373,
		["The Curious Visitor"] = 392,
		["Brotherhood's End"] = 395,
		["Humble Beginnings"] = 399,
		["Proof of Demise"] = 374,
		["The Damned"] = 376,
		["Marla's Last Wish"] = 6395,
		["Return to Brock"] = 6392,
		["Quell The Uprising"] = 387,
		["Bazil Thredd"] = 389,
		["The Stockade Riots"] = 391,
		["The Color of Blood"] = 388,
		["You Have Served Us Well"] = 397,
		["Scavenging Deathknell"] = 3902,
		["An Audience with the King"] = 	{
			["Lady Katrana Prestor"] = 396,
			["King Varian Wrynn"] = 396
		},
		["Draenethyst Crystals"] = 1389,
		["Noboru the Cudgel"] = 1392,
		["Scarlet Subterfuge"] = 5862,
		["Dispelling Evil"] = 8414,
		["Demon Dogs"] = 5542,
		["Blood Tinged Skies"] = 5543,
		["Carrion Grubbage"] = 5544,
		["Redemption"] = 5742,
		["Of Forgotten Memories"] = 5781,
		["Of Lost Honor"] = 5845,
		["Of Love and Family"] = 	{
			["Tirion Fordring"] = 5848,
			["Artist Renfray"] = 5846
		},
		["In Dreams"] = 	{
			["Tirion Fordring"] = 5944,
			["Lord Tirion Fordring"] = 5944
		},
		["Wild Hearts"] = 429,
		["Rot Hide Ichor"] = 443,
		["Delivery to Silverpine Forest"] = 445,
		["Thule Ravenclaw"] = 446,
		["A Recipe For Death"] = 	{
			["Apothecary Renferrel"] = 450,
			["Master Apothecary Faranell"] = 		{
				["How good of Apothecary Renferrel to send you to me, $N. These samples will indeed prove useful to the cause. I will begin studying their send you to me, $N. These samples will indeed prove useful to the cause. I will begin studying their toxic and contaminable properties at once."] = 447,
				["Such a blow to the Royal Apothecary Society to lose Berard. But through your hard work and Apothecary Renferrel's diligent research Berard's studies will still great here, $N. If you were not so skilled in the ways of combat I would try to recruit you for membership in the Society."] = 451
			}
		},
		["Speak with Renferrel"] = 3221,
		["Arugal's Folly"] = 	{
			["Dalar Dawnweaver"] = 		{
				["Your persistence is commendable. With the knowledge you helped me gather, Arugal will fall and his reckless magic shall be undone. Cheers to you, $N. Your persistence is commendable. With the knowledge you helped me gather, Arugal will fall and his reckless magic shall be undone. Cheers to you, $N."] = 99,
				["This is precisely the spell I was in search of, $c. If your dedication to The Dark Lady's cause remains infallible you will find you in search of, $c. If your dedication to The Dark Lady's cause remains infallible you will find you have quite a future amongst The Forsaken."] = 422,
				["I hope I can acquire enough energy from such a limited sample. Perhaps I should have had you get more shackles. Nonetheless, you showed great skill acquire enough energy from such a limited sample. Perhaps I should have had you get more shackles. Nonetheless, you showed great skill in collecting these, $c."] = 423,
				["Most excellent. The mine will provide superb resources for our forces as we spread throughout Silverpine and into Azeroth. Most excellent. The mine will provide superb resources for our forces as we spread throughout Silverpine and into Azeroth."] = 424
			}
		},
		["Prove Your Worth"] = 421,
		["Dalar's Analysis"] = 481,
		["Arugal Must Die"] = 1014,
		["Ivar the Foul"] = 425,
		["Lost Deathstalkers"] = 428,
		["Escorting Erland"] = 435,
		["Return to Quinn"] = 430,
		["The Dead Fields"] = 437,
		["Rot Hide Clues"] = 439,
		["Assault on Fenris Isle"] = 442,
		["Report to Hadrec"] = 448,
		["The Deathstalkers' Report"] = 449,
		["Shimmer Stout"] = 413,
		["A Pilot's Revenge"] = 417,
		["Thelsamar Blood Sausages"] = 418,
		["The Public Servant"] = 433,
		["The Woodland Protector"] = 	{
			["Tarindrella"] = 		{
				["I see you found me, young $R. Melithar is a wise druid to have sent you. I see you found me, young $R. Melithar is a wise druid to have sent you."] = 458,
				["Your service to the creatures of Shadowglen is worthy of reward, $N. You confirmed my fears, however. If the grells have become tainted by the Fel you find yourself in Dolanaar, able $c, seek out the knowledgeable druid, Athridas Bearmantle. He shares our concern for the well being of the forest."] = 459
			}
		},
		["Raleigh and the Undercity"] = 441,
		["A Husband's Revenge"] = 530,
		["Elixir of Agony"] = 	{
			["Master Apothecary Faranell"] = 513,
			["Apothecary Lydon"] = 		{
				["Ah, the horrible reek of Mudsnout Blossoms. At least those filthy Gnolls are good for something. Ah, the horrible reek of Mudsnout Blossoms. At least those filthy Gnolls are good for something."] = 509,
				["The excitement of this experiment has me feeling giddy! You have been such a great help, $N. Together we will spread death and disease to of this experiment has me feeling giddy! You have been such a great help, $N. Together we will spread death and disease to this land!"] = 515,
				["Finally! Now we are ready for action! Finally! Now we are ready for action!"] = 517
			},
			["Dusty Rug"] = 524
		},
		["Going, Going, Guano!"] = 1109,
		["Hearts of Zeal"] = 1113,
		["Venom to the Undercity"] = 2938,
		["Resupplying the Excavation"] = 273,
		["Pyrewood Ambush"] = 452,
		["Gnarlpine Corruption"] = 476,
		["The Relics of Wakening"] = 483,
		["Ursal the Mauler"] = 486,
		["The Balance of Nature"] = 	{
			["Conservator Ilthalaine"] = 		{
				["You performed your duties well, $N. You performed your duties well, $N."] = 456,
				["You have proven your dedication to nature well, $N. A young $c like yourself has a promising future. You have proven your dedication to nature well, $N. A young $c like yourself has a promising future."] = 457
			}
		},
		["Timberling Seeds"] = 918,
		["Timberling Sprouts"] = 919,
		["The Moss-twined Heart"] = 927,
		["The Glowing Fruit"] = 930,
		["The Shimmering Frond"] = 931,
		["Denalan's Earth"] = 997,
		["Return to Denalan"] = 2498,
		["Oakenscowl"] = 2499,
		["Webwood Venom"] = 916,
		["Webwood Egg"] = 917,
		["Elixirs for the Bladeleafs"] = 1581,
		["The Algaz Gauntlet"] = 455,
		["Daily Delivery"] = 469,
		["Apprentice's Duties"] = 471,
		["Young Crocolisk Skins"] = 484,
		["War Banners"] = 464,
		["Report to Captain Stoutfist"] = 473,
		["Defeat Nek'rosh"] = 474,
		["A Troubling Breeze"] = 475,
		["Digging Through the Ooze"] = 470,
		["Simple Scroll"] = 3095,
		["Maps and Runes"] = 478,
		["Ambermill Investigations"] = 479,
		["The Weaver"] = 480,
		["Dalaran's Intentions"] = 482,
		["Beren's Peril"] = 516,
		["Encrypted Scroll"] = 3096,
		["Hallowed Scroll"] = 3097,
		["Glyphic Scroll"] = 3098,
		["Tainted Scroll"] = 3099,
		["Garments of Darkness"] = 5650,
		["In Favor of Darkness"] = 5651,
		["Zenn's Bidding"] = 488,
		["Seek Redemption!"] = 489,
		["The Road to Darnassus"] = 487,
		["Time To Strike"] = 494,
		["Battle of Hillsbrad"] = 	{
			["High Executor Darthalia"] = 		{
				["At ease, $c. I see you have returned from battle. My sources tell me you performed well on the Hillsbrad front. At ease, $c. I see you have returned from battle. My sources tell me you performed well on the Hillsbrad front."] = 527,
				["The grip of death is tightening around the town of Hillsbrad. The battle goes well. The grip of death is tightening around the town of Hillsbrad. The battle goes well."] = 528,
				["Mission accomplished, $c. And carried out quite skillfully, I might add. Mission accomplished, $c. And carried out quite skillfully, I might add."] = 529,
				["News of your glories in Hillsbrad traveled fast. You have done well, $c. News of your glories in Hillsbrad traveled fast. You have done well, $c."] = 532,
				["The Dark Lady will be pleased when she learns that she has a new mine from which she can arm her soldiers. The Dark Lady will be pleased when she learns that she has a new mine from which she can arm her soldiers."] = 539,
				["Your actions on the battlefield are worthy of the highest praise. Your actions on the battlefield are worthy of the highest praise."] = 541
			}
		},
		["WANTED: Syndicate Personnel"] = 549,
		["WANTED: Baron Vardus"] = 566,
		["Dangerous!"] = 567,
		["Journey to Hillsbrad Foothills"] = 493,
		["Elixir of Suffering"] = 	{
			["Apothecary Lydon"] = 496,
			["Umpi"] = 499
		},
		["Elixir of Pain"] = 	{
			["Apothecary Lydon"] = 501,
			["Stanley"] = 502
		},
		["Journey to Tarren Mill"] = 1065,
		["Blood of Innocents"] = 1066,
		["Venom Bottles"] = 2933,
		["Undamaged Venom Sac"] = 2934,
		["Summoning Shadra"] = 2937,
		["Supplying the Sepulcher"] = 6321,
		["The Crown of Will"] = 	{
			["Sharlindra"] = 521,
			["Melisara"] = 		{
				["You were sent by Shalindra? Very well then, you'll find I don't waste much time with idle chatter. Mug'Thol is an irritant, and we will deal then, you'll find I don't waste much time with idle chatter. Mug'Thol is an irritant, and we will deal with him quickly, thoroughly, and without incident."] = 495,
				["The snow blooms red with the blood of the ogres, but we cannot cease our efforts until the spirit and numbers of the Crushridge have ogres, but we cannot cease our efforts until the spirit and numbers of the Crushridge have been crushed and ground into the dirt and snow."] = 518,
				["...and I thought ogres smelled foul enough to begin with. When you bring me Mug'Thol's head, I will have the four of them mounted on pikes head, I will have the four of them mounted on pikes above Alterac. A fitting monument to those who go against the Dark Lady's wishes."] = 519,
				["You have done your duty well, $N. Mug'Thol's head shall adorn the highest peak of the ruins of Alterac, and the Deathguard will sweep the Mug'Thol's head shall adorn the highest peak of the ruins of Alterac, and the Deathguard will sweep the remnants of the Crushridge into the ground."] = 520
			}
		},
		["Down the Coast"] = 536,
		["Farren's Proof"] = 	{
			["Lieutenant Farren Orinelle"] = 		{
				["Oh for the Love of the Light... they're dripping on the ground. Can't stand touching those things, myself. Fish are all well and good, but when grow legs and start walking around... Haven't eaten a fish in weeks, let me tell you, and in Southshore, that means you aren't eating much."] = 559,
				["The naga, eh? Redpath must have just received the same information as me... Ha! He'll not receive a promotion from my toil. Let me explain. The naga, eh? Redpath must have just received the same information as me... Ha! He'll not receive a promotion from my toil. Let me explain."] = 561
			},
			["Marshal Redpath"] = 560
		},
		["Stormwind Ho!"] = 562,
		["The Rescue"] = 498,
		["Blackmoore's Legacy"] = 506,
		["Taretha's Gift"] = 508,
		["Infiltration"] = 533,
		["Crushridge Bounty"] = 500,
		["Crushridge Warmongers"] = 504,
		["Syndicate Assassins"] = 505,
		["Foreboding Plans"] = 510,
		["Noble Deaths"] = 512,
		["Assassin's Contract"] = 522,
		["Baron's Demise"] = 523,
		["Further Mysteries"] = 525,
		["Dark Council"] = 537,
		["Southshore"] = 538,
		["Preserving Knowledge"] = 540,
		["The Ensorcelled Parchment"] = 551,
		["The Perenolde Tiara"] = 543,
		["Delivery to Ridgewell"] = 4765,
		["Bring the End"] = 3341,
		["Gol'dir"] = 503,
		["Lord Aliden Perenolde"] = 507,
		["Valik"] = 535,
		["Manna-Enriched Horse Feed"] = 7645,
		["Costly Menace"] = 564,
		["Hinott's Assistance"] = 	{
			["Serge Hinott"] = 		{
				["You look deliciously pale, $c. And what is that foul aroma you are giving off? I must know! You look deliciously pale, $c. And what is that foul aroma you are giving off? I must know!"] = 2479,
				["The cure is ready! Drink this anti-toxin and the creeping madness will stop, however, I will not be able to do anything about the smell. The cure is ready! Drink this anti-toxin and the creeping madness will stop, however, I will not be able to do anything about the smell."] = 2480
			}
		},
		["Soothing Turtle Bisque"] = 	{
			["Christoph Jeffcoat"] = 7321,
			["Chef Jessen"] = 555
		},
		["Prison Break In"] = 544,
		["Dalaran Patrols"] = 545,
		["Souvenirs of Death"] = 546,
		["Humbert's Sword"] = 547,
		["Into The Scarlet Monastery"] = 1048,
		["The Deathstalkers"] = 1978,
		["The Power to Destroy..."] = 5725,
		["An Unholy Alliance"] = 	{
			["Varimathras"] = 		{
				["Good. Well done, $c. Now that Malcin is dead, we can at least know that the Scourges advances will be halted. The Dark Lady thanks you a gift. Although we do not know the extent of the Scourges influence within the Downs, I am sure we will discover their plots soon enough."] = 6521,
				["I recognize the insignia on this scroll, $N. You found this on that crone who reigns over Razorfen Kraul? Interesting. The Scourge aren't content with one the kingdom of Lordaeron before things... changed. If the Scourge are trying to gain a foothold in Kalimdor, then it is up to us to act."] = 6522
			}
		},
		["Helcular's Revenge"] = 	{
			["Novice Thaivand"] = 552,
			["Helcular's Grave"] = 553
		},
		["Stone Tokens"] = 556,
		["Bracers of Binding"] = 557,
		["Bartolo's Yeti Fur Cloak"] = 565,
		["Reassignment"] = 563,
		["The Defense of Grom'gol"] = 	{
			["Commander Aggro'gosh"] = 		{
				["Your duty was performed with honor, $c. Your duty was performed with honor, $c."] = 568,
				["Well done. You have served the Warchief with honor. Well done. You have served the Warchief with honor."] = 569
			}
		},
		["Mok'thardin's Enchantment"] = 	{
			["Far Seer Mok'thardin"] = 		{
				["Your knowledge of the jungle is strong, $N. These specimens will be perfect. I will thank the spirits for sacrificing such fine beasts for the jungle is strong, $N. These specimens will be perfect. I will thank the spirits for sacrificing such fine beasts for the cause of the Horde."] = 570,
				["A most ideal sinew, $N. Your efforts will pay off soon. A most ideal sinew, $N. Your efforts will pay off soon."] = 571,
				["Most excellent. I will prepare these at once. Most excellent. I will prepare these at once."] = 572,
				["With this Holy Spring Water the ceremonial choker is ready for enchantment. Wear this with pride, $N, in the name of the Warchief and in defense Water the ceremonial choker is ready for enchantment. Wear this with pride, $N, in the name of the Warchief and in defense of the mighty Horde."] = 573
			}
		},
		["The Bloodsail Buccaneers"] = 	{
			["Fleet Master Seahorn"] = 		{
				["Bloodsail Buccaneers attacking Booty Bay? They might as well throw themselves off the Overlook Cliffs. Nonetheless, by bringing me this information you have done my off the Overlook Cliffs. Nonetheless, by bringing me this information you have done my fleet of swashbucklers a great service. The Blackwater Raiders thank you."] = 599,
				["Perfect, $N. Now that we know their plan, it's just a matter of time. And to think the fools have dropped anchor just off the cape.... Perfect, $N. Now that we know their plan, it's just a matter of time. And to think the fools have dropped anchor just off the cape...."] = 604,
				["Ah, what a great day for the Blackwater Raiders! Three cheers to you, $N! Ah, what a great day for the Blackwater Raiders! Three cheers to you, $N!"] = 608
			},
			["First Mate Crazz"] = 597,
			["Bloodsail Correspondence"] = 595
		},
		["Sunken Treasure"] = 	{
			["Fleet Master Seahorn"] = 669,
			["Shakes O'Breen"] = 		{
				["So the little gnomes proved their worth after all? I knew we kept those ankle biters around for a reason! So the little gnomes proved their worth after all? I knew we kept those ankle biters around for a reason!"] = 668,
				["Thank you for making such a long and perilous journey. You have the gratitude of the Blackwater Raiders. Thank you for making such a long and perilous journey. You have the gratitude of the Blackwater Raiders."] = 670
			},
			["Doctor Draxlegauge"] = 		{
				["The goggles work perfectly now! Well done, $N. The goggles work perfectly now! Well done, $N."] = 665,
				["Most superb, $N! The Captain will be very pleased! And just wait until word gets back to Fleetmaster Seahorn! Most superb, $N! The Captain will be very pleased! And just wait until word gets back to Fleetmaster Seahorn!"] = 666
			}
		},
		["Up to Snuff"] = 587,
		["Whiskey Slim's Lost Grog"] = 580,
		["Keep An Eye Out"] = 576,
		["Akiris by the Bundle"] = 	{
			["Privateer Bloads"] = 617,
			["Privateer Groy"] = 623
		},
		["Supply and Demand"] = 575,
		["Some Assembly Required"] = 577,
		["Excelsior"] = 628,
		["The Stone of the Tides"] = 578,
		["Water Elementals"] = 601,
		["The Curse of the Tides"] = 611,
		["The Haunted Isle"] = 616,
		["Goblin Sponsorship"] = 	{
			["Baron Revilgaz"] = 		{
				["Oh, sure of course I know what you're talking about. Nope, can't help you though. Some of my men were supposed to go track down can't help you though. Some of my men were supposed to go track down the blueprints for the fuel regulator, but they came back empty-handed."] = 1181,
				["Now, let me just get a copy of these blueprints for my own notes and you can bring these straight to Pozzik. Wouldn't want him for my own notes and you can bring these straight to Pozzik. Wouldn't want him to think that one of his sponsors was abandoning him."] = 1182
			},
			["Gazlowe"] = 1178,
			["Pozzik"] = 1183,
			["Wharfmaster Lozgil"] = 1180
		},
		["Hunt for Yenniku"] = 581,
		["Headhunting"] = 582,
		["Saving Yenniku"] = 592,
		["Grim Message"] = 2932,
		["Venture Company Mining"] = 600,
		["Singing Blue Shards"] = 605,
		["Zanzil's Secret"] = 621,
		["Back to Booty Bay"] = 1118,
		["Report Back to Fizzlebub"] = 1122,
		["Fool's Stout"] = 1127,
		["The Captain's Chest"] = 8551,
		["Facing Negolash"] = 8554,
		["The Monogrammed Sash"] = 8552,
		["Return to MacKinley"] = 607,
		["Voodoo Dues"] = 609,
		["Cracking Maury's Foot"] = 613,
		["Deliver to MacKinley"] = 2874,
		["Scaring Shaky"] = 606,
		["Stormwind Library"] = 579,
		["The Fate of Yenniku"] = 588,
		["The Singing Crystals"] = 589,
		["The Mind's Eye"] = 591,
		["Bloody Bone Necklaces"] = 596,
		["Split Bone Necklace"] = 598,
		["The Vile Reef"] = 629,
		["The Troll Witchdoctor"] = 1240,
		["Filling the Soul Gem"] = 593,
		["Ansirem's Key"] = 603,
		["'Pretty Boy' Duncan"] = 610,
		["Magical Analysis"] = 602,
		["Avast Ye, Scallywag"] = 1036,
		["Avast Ye, Admiral!"] = 4621,
		["Dressing the Part"] = 9272,
		["The Captain's Cutlass"] = 615,
		["Land Ho!"] = 663,
		["Death From Below"] = 667,
		["Message in a Bottle"] = 	{
			["Princess Poobah"] = 		{
				["Have you come to free me? Have you come to free me?"] = 594,
				["$N, you have saved me from a great dishonor. If it was within my power, I would offer you a place among my tribe. But a place among my tribe. But for now, all I can only offer you is this token for the courage and nobility you have shown."] = 630
			}
		},
		["Components for the Enchanted Gold Bloodrobe"] = 	{
			["Xizk Goodstitch"] = 4781,
			["Menara Voidrender"] = 		{
				["This will do nicely, $N. All magical items must begin with an item of high quality. The more effort and skill put into an item, the more expensive components hold the magic better. You will not regret having the robes fashioned into the ones we will make for you later on."] = 1796,
				["Good, you've returned, $N. And where is the thread? Ah, I understand. That is acceptable. The goblin and his brother have not failed us yet--I suppose have it prepared right then. So be it... we have other things we can attend to in the meantime. Are you prepared for the next step?"] = 4782,
				["Excellent, $N. These will do nicely. I will prepare them now while you move on to your last two components. Are you ready? Excellent, $N. These will do nicely. I will prepare them now while you move on to your last two components. Are you ready?"] = 4783,
				["Excellent, $N! The components are gathered and we are ready. I trust you will be pleased. Excellent, $N! The components are gathered and we are ready. I trust you will be pleased."] = 4784
			}
		},
		["Fine Gold Thread"] = 4785,
		["Sully Balloo's Letter"] = 637,
		["Plea To The Alliance"] = 634,
		["Northfold Manor"] = 681,
		["Stromgarde Badges"] = 682,
		["Wanted!  Marez Cowl"] = 684,
		["Wanted!  Otto and Falconcrest"] = 685,
		["Trollbane"] = 638,
		["Sigil of Strom"] = 639,
		["Sigil of Thoradin"] = 641,
		["Sigil of Arathor"] = 643,
		["Sigil of Trollbane"] = 644,
		["Trol'kalar"] = 	{
			["Zengu"] = 646,
			["Trollbane's Tomb"] = 645
		},
		["MacKreel's Moonshine"] = 647,
		["The Broken Sigil"] = 640,
		["Hammerfall"] = 655,
		["Foul Magics"] = 	{
			["Tor'gan"] = 		{
				["It will take some time for me to ascertain the true intentions of the Syndicate, but their obvious association with dark, demonic magic troubles me. ascertain the true intentions of the Syndicate, but their obvious association with dark, demonic magic troubles me. I will tell you when I know more."] = 671,
				["My restless nights will turn to peaceful slumber when I have destroyed this orb. Thank you, $N. It is a chilling reminder of the terrible Thank you, $N. It is a chilling reminder of the terrible power the demons held over the orcs before Hellscream released them from their curse."] = 673
			}
		},
		["Raising Spirits"] = 	{
			["Tor'gan"] = 		{
				["Excellent. The spirits of the raptors that gave these eyes will lend strength to the bearer of this amulet. Excellent. The spirits of the raptors that gave these eyes will lend strength to the bearer of this amulet."] = 672,
				["It did not work, I see. Nonetheless, I feel that showing him the power of the shamans will eventually return Gor'mul to his once proud of the shamans will eventually return Gor'mul to his once proud self. The amulet's power was not great enough to show him our newfound power."] = 675
			},
			["Gor'mul"] = 674
		},
		["Guile of the Raptor"] = 	{
			["Tor'gan"] = 		{
				["Yes, these will work perfectly. I will transfer their power and the spirit of the raptors into this orb. This orb will imbue Gor'mul with their power and the spirit of the raptors into this orb. This orb will imbue Gor'mul with the fiery strength and intelligence of the raptor."] = 701,
				["When the enchantment wears off, I will speak with Gor'mul. My thanks to you for your help in returning Gor'mul to the land of the thanks to you for your help in returning Gor'mul to the land of the living. I have no doubt he thanks you greatly as well."] = 847
			},
			["Gor'mul"] = 702
		},
		["Malin's Request"] = 	{
			["Archmage Malin"] = 697,
			["Skuerto"] = 690
		},
		["Hints of a New Plague?"] = 	{
			["Phin Odelic"] = 661,
			["Quae"] = 		{
				["Excellent! Let's see what this is about... Excellent! Let's see what this is about..."] = 658,
				["Try and stay as quiet as possible, traveler. Orcs don't take too well to being spied on, and there is more to this farm than meets stay as quiet as possible, traveler. Orcs don't take too well to being spied on, and there is more to this farm than meets the eye."] = 659,
				["You've done a great service for us, $N. Thank you. I hope Kin wasn't too much of a handful down there. She's very friendly, but can Thank you. I hope Kin wasn't too much of a handful down there. She's very friendly, but can be just as deadly when you're her enemy."] = 660
			},
			["Kinelory"] = 657
		},
		["Deep Sea Salvage"] = 662,
		["Drowned Sorrows"] = 664,
		["The Hammer May Fall"] = 676,
		["Call to Arms"] = 	{
			["Drum Fel"] = 		{
				["The signs of war are upon your garments, and sweat drips from your brow. Good, very good indeed. The signs of war are upon your garments, and sweat drips from your brow. Good, very good indeed."] = 677,
				["You are as strong as a kodo, and your lust for battle does your people proud. You are as strong as a kodo, and your lust for battle does your people proud."] = 678,
				["You do your people proud, $N. The threat has been greatly lessened, and I am sure we will begin to thrive here in the Highlands. You do your people proud, $N. The threat has been greatly lessened, and I am sure we will begin to thrive here in the Highlands."] = 679
			}
		},
		["The Real Threat"] = 680,
		["Sara Balloo's Plea"] = 683,
		["A King's Tribute"] = 	{
			["King Magni Bronzebeard"] = 700,
			["Grand Mason Marblesten"] = 		{
				["So King Magni Bronzebeard himself sent ye? My, my! This must be important! So King Magni Bronzebeard himself sent ye? My, my! This must be important!"] = 686,
				["Perfect! Better than I could have imagined! And I have quite an imagination you know... Perfect! Better than I could have imagined! And I have quite an imagination you know..."] = 689
			}
		},
		["The Bearer of Bad News"] = 4361,
		["The Princess's Surprise"] = 4363,
		["The Feast of Winter Veil"] = 	{
			["King Magni Bronzebeard"] = 7063,
			["Cairne Bloodhoof"] = 7061
		},
		["The Brokering of Peace"] = 	{
			["King Magni Bronzebeard"] = 8484,
			["Thrall"] = 8485
		},
		["Theldurin the Lost"] = 687,
		["The Lost Fragments"] = 692,
		["Solution to Doom"] = 709,
		["Forbidden Knowledge"] = 737,
		["Myzrael's Allies"] = 	{
			["Gerrig Bonegrip"] = 653,
			["Zaruk"] = 688
		},
		["To Ironforge for Yagyin's Digest"] = 727,
		["The Star, the Hand and the Heart"] = 	{
			["Gerrig Bonegrip"] = 735,
			["Keeper Bel'dugur"] = 736
		},
		["The Powers Below"] = 968,
		["Knowledge in the Deeps"] = 971,
		["Worth Its Weight in Gold"] = 691,
		["Trelane's Defenses"] = 694,
		["Wand over Fist"] = 693,
		["An Apprentice's Enchantment"] = 695,
		["Attack on the Tower"] = 696,
		["Barbecued Buzzard Wings"] = 703,
		["Pearl Diving"] = 705,
		["Flash Bomb Recipe"] = 1559,
		["Power Stones"] = 2418,
		["Fiery Blaze Enchantments"] = 706,
		["Mirages"] = 718,
		["Scrounging"] = 733,
		["Tremors of the Earth"] = 	{
			["Garek"] = 		{
				["No longer will the Kirin Tor need to worry over the prisoners of Lethlor. I will return to report success to my master. Krasus will Kirin Tor need to worry over the prisoners of Lethlor. I will return to report success to my master. Krasus will no doubt be pleased."] = 717,
				["Good tidings you bring bearing the Sign, $N. The Sign of the Earth was created by the Dark Iron dwarves of Angor Fortress to bind of the Earth was created by the Dark Iron dwarves of Angor Fortress to bind two of Deathwing's ruthless lieutenants, the twins Blacklash and Hematus."] = 732
			}
		},
		["A Sign of Hope"] = 	{
			["Hammertoe Grez"] = 721,
			["Prospector Ryedol"] = 720
		},
		["Amulet of Secrets"] = 722,
		["A Dwarf and His Tools"] = 719,
		["Prospect of Faith"] = 	{
			["Prospector Ryedol"] = 723,
			["Historian Karnik"] = 724
		},
		["The Absent Minded Prospector"] = 	{
			["Archaeologist Flagongut"] = 		{
				["Oh my! You say this came from the distant lands of Kalimdor? Amazing! Simply amazing! Oh my! You say this came from the distant lands of Kalimdor? Amazing! Simply amazing!"] = 942,
				["Most excellent, $N! Now to see if I can use the stone to decipher the powers of the fossils. Most excellent, $N! Now to see if I can use the stone to decipher the powers of the fossils."] = 943
			},
			["Chief Archaeologist Greywhisker"] = 741,
			["Archaeologist Hollee"] = 731,
			["Prospector Remtravel"] = 729
		},
		["Trouble In Darkshore?"] = 730,
		["Passing Word of a Threat"] = 	{
			["Historian Karnik"] = 726,
			["Advisor Belgrum"] = 725
		},
		["Portents of Uldum"] = 	{
			["Historian Karnik"] = 2963,
			["Nara Wildmane"] = 2965
		},
		["Return to Ironforge"] = 2977,
		["The Reason for the Season"] = 	{
			["Historian Karnik"] = 7062,
			["Sagorne Creststrider"] = 6964
		},
		["An Ambassador of Evil"] = 762,
		["The Lost Tablets of Will"] = 1139,
		["Liquid Stone"] = 715,
		["Stone Is Better than Cloth"] = 716,
		["This Is Going to Be Hard"] = 	{
			["Lucien Tosselwrench"] = 734,
			["Lotwil Veriatus"] = 		{
				["Ah, perfect. Stand back while I prepare to make more history! <Lotwil continues to work feverishly.> Ah, perfect. Stand back while I prepare to make more history! <Lotwil continues to work feverishly.>"] = 777,
				["Thank you, $N. That was quite an ordeal, wasn't it? I'm not sure what could have gone wrong. It was a good thing my magics were thing my magics were here to help send the creature back to its home plane. Perhaps a little token of appreciation for all your hard work..."] = 778
			}
		},
		["Study of the Elements: Rock"] = 	{
			["Lotwil Veriatus"] = 		{
				["These shall do nicely, $N. Thank you. Hmm, a bit more sand than I'd anticipated. Have to adjust the coefficient of friction. No, wait; it negligible with the frost oil. <Mumbling to himself, Lotwil puts one fist into the palm of his other hand and stares at them as if fascinated.>"] = 710,
				["$N, simply amazing! I would have thought it'd take half a dozen tauren to bring all these to me. $N, simply amazing! I would have thought it'd take half a dozen tauren to bring all these to me."] = 711,
				["$N, have you ever considered becoming a research assistant? No? I'm not sure what I'll do without your abilities here. Intelligence, curiosity, and strength--all combined ever considered becoming a research assistant? No? I'm not sure what I'll do without your abilities here. Intelligence, curiosity, and strength--all combined into one package."] = 712
			}
		},
		["Coolant Heads Prevail"] = 713,
		["Gyro... What?"] = 714,
		["The Rise of the Machines"] = 	{
			["Lotwil Veriatus"] = 		{
				["<Lotwil's face turns white.> I... I know these markings. <Lotwil's face turns white.> I... I know these markings."] = 4062,
				["What is this?!? This head is not flesh. This is some sort of dark iron creation: A shadow of Argelmach - ANOTHER machine! I suspect of Argelmach - ANOTHER machine! I suspect that your destruction of Argelmach will be short lived as another shall rise to take 'its' place soon."] = 4063
			},
			["Hierophant Theodora Mulvadania"] = 4061
		},
		["WANTED: Murkdeep!"] = 4740,
		["The Red Crystal"] = 4811,
		["The Fragments Within"] = 4813,
		["To the Undercity for Yagyin's Digest"] = 728,
		["The Book of Ur"] = 1013,
		["Swoop Hunting"] = 761,
		["Poison Water"] = 748,
		["Winterhoof Cleansing"] = 754,
		["Thunderhorn Totem"] = 756,
		["Thunderhorn Cleansing"] = 758,
		["Wildmane Totem"] = 759,
		["Wildmane Cleansing"] = 760,
		["The Hunt Begins"] = 747,
		["The Hunt Continues"] = 750,
		["The Battleboars"] = 780,
		["A Humble Task"] = 	{
			["Chief Hawkwind"] = 753,
			["Greatmother Hawkwind"] = 752
		},
		["Rite of Strength"] = 757,
		["Attack on Camp Narache"] = 781,
		["Rites of the Earthmother"] = 	{
			["Seer Graytongue"] = 755,
			["Baine Bloodhoof"] = 763,
			["Cairne Bloodhoof"] = 776
		},
		["Rite of Vision"] = 	{
			["Seer Wiserunner"] = 772,
			["Zarlman Two-Moons"] = 		{
				["I sensed you would be coming to me, $c. I can always recognize one who is trying to pass the Rites of the Earthmother. I sensed you would be coming to me, $c. I can always recognize one who is trying to pass the Rites of the Earthmother."] = 767,
				["I see you have learned to gather from our sacred land, $N. It will take but a moment for me to brew the Water of you have learned to gather from our sacred land, $N. It will take but a moment for me to brew the Water of the Seers."] = 771
			}
		},
		["Dangers of the Windfury"] = 743,
		["Test of Faith"] = 1149,
		["Test of Endurance"] = 1150,
		["Test of Strength"] = 1151,
		["Final Passage"] = 1394,
		["Preparation for Ceremony"] = 744,
		["The Ravaged Caravan"] = 	{
			["Morin Cloudstalker"] = 751,
			["Sealed Supply Crate"] = 749
		},
		["The Venture Co."] = 764,
		["Supervisor Fizsprocket"] = 765,
		["Sharing the Land"] = 745,
		["Dwarven Digging"] = 746,
		["Rite of Wisdom"] = 773,
		["Tal the Wind Rider Master"] = 6363,
		["Master of the Wild Leather"] = 	{
			["Una"] = 2860,
			["Telonis"] = 2853
		},
		["The Platinum Discs"] = 	{
			["Bena Winterhoof"] = 2440,
			["Sage Truthseeker"] = 2280,
			["High Explorer Magellas"] = 2279,
			["Dinita Stonemantle"] = 2439,
			["The Discs of Norgannon"] = 2278
		},
		["Aquatic Form"] = 	{
			["Turak Runetotem"] = 31,
			["Mathrengyl Bearwalker"] = 5061
		},
		["Heeding the Call"] = 	{
			["Turak Runetotem"] = 5928,
			["Mathrengyl Bearwalker"] = 5925
		},
		["Back to Thunder Bluff"] = 5932,
		["Body and Heart"] = 	{
			["Turak Runetotem"] = 6002,
			["Mathrengyl Bearwalker"] = 6001
		},
		["Power over Poison"] = 	{
			["Turak Runetotem"] = 6130,
			["Mathrengyl Bearwalker"] = 6125
		},
		["Training the Beast"] = 	{
			["Holt Thunderhorn"] = 6089,
			["Ormak Grimshot"] = 6081,
			["Jocaste"] = 6103,
			["Belia Thundergranite"] = 6086
		},
		["Gathering Leather"] = 768,
		["Kodo Hide Bag"] = 769,
		["The Demon Scarred Cloak"] = 770,
		["Mazzranache"] = 766,
		["Journey into Thunder Bluff"] = 775,
		["Simple Note"] = 3091,
		["Verdant Note"] = 3094,
		["Etched Note"] = 3092,
		["Rune-Inscribed Note"] = 3093,
		["Vanquish the Betrayers"] = 784,
		["From The Wreckage...."] = 825,
		["The Admiral's Orders"] = 830,
		["Encroachment"] = 837,
		["Thwarting Kolkar Aggression"] = 786,
		["Dark Storms"] = 806,
		["Report to Orgnil"] = 823,
		["The New Horde"] = 787,
		["Cutting Teeth"] = 788,
		["Sting of the Scorpid"] = 789,
		["Sarkoth"] = 	{
			["Gornek"] = 804,
			["Hana'zua"] = 790
		},
		["Your Place In The World"] = 4641,
		["Vile Familiars"] = 	{
			["Zureetha Fargaze"] = 		{
				["You have done well, $N. Although the Vile Familiars were merely pets of the darker powers within the Burning Blade, your success against them foretells greater done well, $N. Although the Vile Familiars were merely pets of the darker powers within the Burning Blade, your success against them foretells greater deeds ahead."] = 792,
				["You have done well, $N. Although the vile familiars were merely pets of the darker powers within the Burning Blade, your success against them foretells greater done well, $N. Although the vile familiars were merely pets of the darker powers within the Burning Blade, your success against them foretells greater deeds ahead."] = 1499
			}
		},
		["Burning Blade Medallion"] = 794,
		["Carry Your Weight"] = 791,
		["Simple Parchment"] = 2383,
		["Simple Tablet"] = 3065,
		["Etched Tablet"] = 3082,
		["Etched Parchment"] = 3087,
		["Encrypted Tablet"] = 3083,
		["Encrypted Parchment"] = 3088,
		["Tainted Parchment"] = 3090,
		["Rune-Inscribed Tablet"] = 3084,
		["Rune-Inscribed Parchment"] = 3089,
		["Report to Sen'jin Village"] = 805,
		["Minshina's Skull"] = 808,
		["Zalazane"] = 826,
		["Consult Master Gadrin"] = 2935,
		["The Spider God"] = 2936,
		["Finding the Antidote"] = 813,
		["Need for a Cure"] = 812,
		["Break a Few Eggs"] = 815,
		["Lost But Not Forgotten"] = 816,
		["Practical Prey"] = 817,
		["Skull Rock"] = 827,
		["Margoz"] = 828,
		["Break Sharptusk!"] = 3376,
		["Neeru Fireblade"] = 829,
		["Burning Shadows"] = 832,
		["Hidden Enemies"] = 	{
			["Neeru Fireblade"] = 5729,
			["Thrall"] = 		{
				["Good, $N! The spirits be praised, perhaps you are the one who will finally put my greatest fears to rest! Who would suspect someone so storm. But there is time for more praise later. You've not accomplished anything in comparison to what you will face... but this is a good start."] = 5726,
				["Excellent! Most excellent, $c! What you have done this day is only the first step in a much broader foundation--a foundation that we will build the the Shadow Council on, once and for all. Tell me all he said... and leave not one word out--it may be more important than you realize."] = 5727,
				["I am glad you've returned, $N. Some of those loyal to me brought word immediately that the caverns below Orgrimmar were in disarray now that Neeru was more than agitated. It seems we've put a dent in his armor. I can't say I'm displeased... even with such a minor victory."] = 5728,
				["Ashenvale? Hmm, I had not heard of any presence of the Council or the Burning Blade in Ashenvale. My spies will investigate, $N. You have spies will investigate, $N. You have done well. For now, rest, and keep yourself occupied with other tasks. I will call upon you again soon. Lok-Tar Ogar!"] = 5730
			}
		},
		["Slaying the Beast"] = 5761,
		["A Sacred Burial"] = 833,
		["Chen's Empty Keg"] = 	{
			["Brewmaster Drohn"] = 		{
				["Well, I'll be... This was one of Chen Stormstout's kegs. He traveled with Rexxar a long time ago. I haven't seen or heard about him in with Rexxar a long time ago. I haven't seen or heard about him in a kodo's age. I appreciate you bringing this to me, $N."] = 819,
				["Haha... I never thought I'd make more of this stuff ever again. You've stirred in me a great sense of nostalgia, $N. Kind of reminds me nostalgia, $N. Kind of reminds me of the last time I blacked out from too much trogg ale. Thank you. The memories warm my stomach."] = 821,
				["Haha! I knew you couldn't resist some of this brew. Come back again anytime you want some more, $N. Just bring me more of the resist some of this brew. Come back again anytime you want some more, $N. Just bring me more of the ingredients I had you collect."] = 822
			}
		},
		["Winds in the Desert"] = 834,
		["Securing the Lines"] = 835,
		["A Solvent Spirit"] = 818,
		["Calm Before the Storm"] = 	{
			["Karus"] = 4511,
			["Idriana"] = 4510,
			["Zilzibin Drumlore"] = 4509,
			["Gracina Spiritmight"] = 4508
		},
		["Doras the Wind Rider Master"] = 6385,
		["Conscript of the Horde"] = 840,
		["Crossroads Conscription"] = 842,
		["Plainstrider Menace"] = 844,
		["The Zhevra"] = 845,
		["Sergra Darkthorn"] = 860,
		["Echeyakee"] = 881,
		["Prowlers of the Barrens"] = 903,
		["The Angry Scytheclaws"] = 905,
		["The Guns of Northwatch"] = 891,
		["Free From the Hold"] = 898,
		["Gann's Reclamation"] = 843,
		["Revenge of Gann"] = 	{
			["Gann Stonespire"] = 		{
				["I see you are quite industrious, $c. No doubt we shall soon have a fitting surprise for those dwarves. I see you are quite industrious, $c. No doubt we shall soon have a fitting surprise for those dwarves."] = 846,
				["You have done well, $N! May you be revered in Thunder Bluff as a defender of sacred tauren lands and a champion of the lost have done well, $N! May you be revered in Thunder Bluff as a defender of sacred tauren lands and a champion of the lost tribe."] = 849
			}
		},
		["Ishamuhale"] = 882,
		["Lakota'mani"] = 883,
		["Owatanka"] = 884,
		["Washte Pawne"] = 885,
		["The Harvester"] = 897,
		["Enraged Thunder Lizards"] = 907,
		["Cry of the Thunderhawk"] = 913,
		["Jorn Skyseer"] = 3261,
		["Isha Awak"] = 873,
		["Mahren Skyseer"] = 874,
		["Kolkar Leaders"] = 850,
		["Verog the Dervish"] = 851,
		["Hezrul Bloodmark"] = 852,
		["Centaur Bracers"] = 855,
		["Regthar Deathgate"] = 1361,
		["Counterattack!"] = 4021,
		["Fungal Spores"] = 848,
		["Sample for Helbrim"] = 1358,
		["Southsea Freebooters"] = 887,
		["Stolen Booty"] = 888,
		["The Missing Shipment"] = 	{
			["Gazlowe"] = 892,
			["Wharfmaster Dizzywig"] = 890
		},
		["WANTED: Baron Longshore"] = 895,
		["Find the Shattered Hand"] = 2378,
		["To Orgrimmar!"] = 2380,
		["The Shattered Salute"] = 2460,
		["Mission: Possible But Not Probable"] = 2478,
		["Zando'zan"] = 2379,
		["Rig Wars"] = 2841,
		["Return of the Ring"] = 	{
			["Nogg"] = 2949,
			["Talvash del Kissel"] = 2947
		},
		["Nogg's Ring Redo"] = 2950,
		["Apothecary Zamah"] = 853,
		["Serpentbloom"] = 962,
		["Forsaken Aid"] = 1064,
		["Return to Thunder Bluff"] = 	{
			["Apothecary Zamah"] = 1067,
			["Nara Wildmane"] = 2967
		},
		["The Flying Machine Airport"] = 1086,
		["The Tear of the Moons"] = 857,
		["Egg Hunt"] = 868,
		["Parts of the Swarm"] = 	{
			["Korran"] = 1148,
			["Belgrom Rockmaul"] = 1184
		},
		["Journey to the Crossroads"] = 854,
		["Disrupt the Attacks"] = 871,
		["The Disruption Ends"] = 872,
		["Betrayal from Within"] = 	{
			["Thork"] = 906,
			["Mangletooth"] = 879
		},
		["Supplies for the Crossroads"] = 5041,
		["Tribes at War"] = 878,
		["Spirit of the Wind"] = 889,
		["Agamaggan's Strength"] = 5042,
		["Agamaggan's Agility"] = 5043,
		["Wisdom of Agamaggan"] = 5044,
		["Rising Spirit"] = 5045,
		["Razorhide"] = 5046,
		["Blood Shards of Agamaggan"] = 5052,
		["Consumed by Hatred"] = 899,
		["Lost in Battle"] = 4921,
		["Weapons of Choice"] = 893,
		["A New Ore Sample"] = 1153,
		["Ignition"] = 858,
		["The Hunter's Way"] = 861,
		["Melor Sends Word"] = 1130,
		["Steelsnap"] = 1131,
		["Frostmaw"] = 1136,
		["Deadmire"] = 1205,
		["Samophlange"] = 	{
			["Sputtervalve"] = 902,
			["Control Console"] = 		{
				["A variety of buttons, levers and blinking lights are somewhat erratically arrayed on the face of the control console. A small gauge indicates that the indicates that control valves one through three are currently open. There is a small keyhole set into the lower right side of the control panel."] = 894,
				["The lights indicating the three control valves dim as they are shut off. Green lights slowly fade into yellow, and the switch controlling the apparatus off. Green lights slowly fade into yellow, and the switch controlling the apparatus is now moveable, with the valves closed, it can be turned off."] = 900,
				["Turning the key in the lock, the control console unlocks. A red light at the top of the console turns off and all power drains in the lock, the control console unlocks. A red light at the top of the console turns off and all power drains from the terminal."] = 901
			}
		},
		["Further Instructions"] = 	{
			["Sputtervalve"] = 1094,
			["Ziz Fizziks"] = 1095
		},
		["Dig Rat Stew"] = 862,
		["Raptor Horns"] = 865,
		["Root Samples"] = 866,
		["Deepmoss Spider Eggs"] = 1069,
		["Blueleaf Tubers"] = 1221,
		["Stinky's Escape"] = 	{
			["Mebok Mizzyrix"] = 1270,
			["Morgan Stern"] = 1222
		},
		["Smart Drinks"] = 1491,
		["The Forgotten Pools"] = 870,
		["The Stagnant Oasis"] = 877,
		["Altered Beings"] = 880,
		["The Barrens Oases"] = 886,
		["The Principal Source"] = 	{
			["Tonga Runetotem"] = 6127,
			["Alanndarian Nightsong"] = 6122
		},
		["Gathering the Cure"] = 	{
			["Tonga Runetotem"] = 6128,
			["Alanndarian Nightsong"] = 6123
		},
		["Harpy Raiders"] = 867,
		["Harpy Lieutenants"] = 875,
		["Serena Bloodfeather"] = 876,
		["Miner's Fortune"] = 896,
		["The Barrens Port"] = 1039,
		["Wharfmaster Dizzywig"] = 	{
			["Wharfmaster Dizzywig"] = 		{
				["Oh yes. Parts for Kravel. I'm glad you're here. These things have been sitting out here for days, and I was afraid they'd rust! Oh yes. Parts for Kravel. I'm glad you're here. These things have been sitting out here for days, and I was afraid they'd rust!"] = 1111,
				["A small enough crate. Yes, I should be able to find room for this aboard the ship. It sails with the next tide, I trust next tide, I trust this is soon enough? Excellent. Let me just enter it into my ledger. All taken care of! Good day to you, $c."] = 1492
			}
		},
		["Raptor Thieves"] = 869,
		["News of Dogran"] = 	{
			["Gazrog"] = 1509,
			["Ken'zigla"] = 1510
		},
		["Stolen Silver"] = 3281,
		["Return to Jahan"] = 6364,
		["Laughing Sisters"] = 1945,
		["Nether-lace Garment"] = 1946,
		["Return to the Crossroads."] = 6386,
		["Tenaron's Summons"] = 920,
		["Crown of the Earth"] = 	{
			["Tenaron Stormgrip"] = 921,
			["Corithras Moonrage"] = 		{
				["Ah, I see. You were sent by Tenaron. Well then, it would seem we have much to talk about, much to do, and little time then, it would seem we have much to talk about, much to do, and little time to do it in. I think we'd best get started."] = 928,
				["After the Battle of Mount Hyjal, we were without direction. Nordrassil smoked from the fire it unleashed, and our immortality--the very essence of our beings!--was our beings!--was lost. It was in this trying time that the Betrayer was freed from his prison, and Shan'do Stormrage disappeared. A dark time for all."] = 929,
				["Shan'do Stormrage never returned, and the druids were in disarray, and to this day we still do not know what became of him. With Malfurion time for our people to regain their immortality. With the approval of the Circle, Staghelm and the most powerful druids grew Teldrassil, the new World Tree."] = 933,
				["To be in the presence of the Oracle Tree... it is almost to feel wisdom take form. Let me continue the telling... With Teldrassil grown, the chiding the druid for his arrogance. In agreement with Nozdormu, Alexstrasza also refused Staghelm, and without her blessing, Teldrassil's growth has been flawed and unpredictable..."] = 7383
			},
			["Arch Druid Fandral Staghelm"] = 935
		},
		["Teldrassil"] = 940,
		["The New Frontier"] = 	{
			["Arch Druid Fandral Staghelm"] = 1047,
			["Mathrengyl Bearwalker"] = 6761,
			["Arch Druid Hamuul Runetotem"] = 1018
		},
		["Assisting Arch Druid Staghelm"] = 3790,
		["Wildkin of Elune"] = 4902,
		["The Crystal of Zin-Malor"] = 5253,
		["Rellian Greenspyre"] = 922,
		["Tumors"] = 923,
		["The Enchanted Glade"] = 937,
		["Mist"] = 938,
		["Good Natured Emma"] = 5048,
		["Ak'Zeloth"] = 809,
		["The Demon Seed"] = 924,
		["Twisted Hatred"] = 932,
		["The Emerald Dreamcatcher"] = 2438,
		["Ferocitas the Dream Eater"] = 2459,
		["Cave Mushrooms"] = 947,
		["Therylune's Escape"] = 945,
		["Simple Sigil"] = 3116,
		["Encrypted Sigil"] = 3118,
		["Hallowed Sigil"] = 3119,
		["Etched Sigil"] = 3117,
		["Verdant Sigil"] = 3120,
		["Garments of the Moon"] = 5621,
		["In Favor of Elune"] = 5622,
		["A Bundle of Hides"] = 6361,
		["Meats to Orgrimmar"] = 6365,
		["Onu"] = 948,
		["Return to Onu"] = 950,
		["Mathystra Relics"] = 951,
		["Grove of the Ancients"] = 952,
		["Onu is meditating"] = 961,
		["The Fall of Ameth'Aran"] = 953,
		["For Love Eternal"] = 963,
		["Tools of the Highborne"] = 958,
		["Seeking the Kor Gem"] = 1442,
		["Thundris Windweaver"] = 4761,
		["The Cliffspring River"] = 4762,
		["The Blackwood Corrupted"] = 4763,
		["Bashal'Aran"] = 	{
			["Asterion"] = 		{
				["Ahh... To what could I possibly owe the exceedingly special honor of a $r such as yourself as company. Truly it says much of my please, do not let my uncivil tongue drive you from the place. It has indeed been many years, decades even, since I had civil accompaniment."] = 954,
				["Indeed... The grells of Bashal'Aran do not possess that which I am searching... however they have come into contact with it recently. Recently... I would it recently. Recently... I would reckon that by your time, not mine. Recent for me stretches into the veil of the past, almost another Age..."] = 955,
				["It... it is hard for me to even believe that what I hold now is that which has held me for so long. Let us me for so long. Let us waste no time, $N. When the seal is destroyed, I might walk the forests of the earth freely again."] = 956,
				["I am freed, $N! I can now see with my own eyes the changes that have come to our world... Only bits and pieces have our beloved queen. I sense that my jailor, my former master, Athrikus, still lives... Already my feelings of hopelessness will give way into thoughts of vengeance."] = 957
			}
		},
		["The Tower of Althalaxx"] = 	{
			["Balthule Shadowstrike"] = 		{
				["Elissa sent you? Then it is good tidings you bring. I have troubling news to report to her, and had no means with which to you? Then it is good tidings you bring. I have troubling news to report to her, and had no means with which to deliver it."] = 965,
				["Many thanks, $N. This should shed some light on this warlocks' gathering... Hmm... the Cult of the Dark Strand... I have never heard of this group it is all but impossible to say what their plans must be. There is no more time to delay. Warning must be delivered to Delgren immediately."] = 966,
				["With the death of Athrikus, I hope that the demonic forces in this area will be driven back. I have no doubt that they will be driven back. I have no doubt that they will regroup and return, but then we shall be even more prepared to meet their threat."] = 1143,
				["Ah, it's good to see you again, $N! The strangest things have been happening around here, I'm glad you showed up! It was very strange, $N. room of the tower. Then came the screams. The cries split the air, and lightning struck the ground from time to time. What's going on?"] = 1167
			},
			["Delgren the Purifier"] = 		{
				["If you don't mind my saying, you seem a bit well-equipped for a messenger, hm? I suppose Balthule wanted to be certain that his letter the Sentinels destroy them. At first I was unaccustomed to the manners of the night elves, but I have grown to respect them greatly as allies."] = 967,
				["Hmm, some dark magic enchants this soulstone. Let's see what's trapped inside, shall we? Hmm, some dark magic enchants this soulstone. Let's see what's trapped inside, shall we?"] = 970,
				["It was a grand thing you did today, $N. You should be quite proud of yourself for having faced down a warlock of such power. Now, You should be quite proud of yourself for having faced down a warlock of such power. Now, let's see what we can learn from Ilkrud's writings."] = 973,
				["I knew you would be up to the task, $N. I sense great deeds before you, and that you will right many of the wrongs that deeds before you, and that you will right many of the wrongs that plague our lands. Bear my blessings, $N, as well as this gift."] = 981,
				["Perhaps the satyrs have been allowed to persist in the forest for too long. I will speak with Elissa about it when next I travel travel to Auberdine. Nonetheless, with the soulgems destroyed, Athrikus' power will be greatly diminished. We must seize on this opportunity to eliminate him and his cult."] = 1140
			}
		},
		["Supplies to Auberdine"] = 976,
		["Trouble at the Docks"] = 959,
		["Gaffer Jacks"] = 1579,
		["Electropellers"] = 1580,
		["Trek to Ashenvale"] = 990,
		["Raene's Cleansing"] = 	{
			["Raene Wolfrunner"] = 		{
				["This is terrible, $N. Teronis is dead?! The time for mourning will come, but for now we must focus our efforts. I shall send some of gem he was seeking. Do you think you're capable of completing his task? I would rest much better knowing his death was not in vain."] = 1023,
				["You've recreated the rod Teronis had set out to find? That's wonderful to hear. Teronis would be proud to see his quest is continuing even after rod Teronis had set out to find? That's wonderful to hear. Teronis would be proud to see his quest is continuing even after his tragic passing."] = 1029,
				["So, this is the skull of the fiercest furbolg threat in Ashenvale? I am more than pleased with your abilities, $N. The Sentinels cannot thank you help our people. I shall put this skull and Dartol's Rod in a place of reverence for others to see. Teronis would be proud. Thank you again."] = 1046
			},
			["Teronis' Corpse"] = 991,
			["Krolg"] = 		{
				["Yes, yes... you are one of my kind, but still whole. Still clean. I am unsure how you have escaped the atrocities the night elves have people... They are the ones I blame for being cast out of my tribe. At night I can still see the campfires burning in the darkness."] = 1030,
				["You have done well, my friend. The forest is still tainted, but at least we know we have done a small part to return it to to return to me again, I would enjoy the company of my own kind. Be well. Perhaps our tribes will meet again under less violent times."] = 1045
			},
			["Shael'dryn"] = 		{
				["Oh, Raene sent you? It must be serious indeed. What can I help you with? Oh, Raene sent you? It must be serious indeed. What can I help you with?"] = 1024,
				["I'm pleased to see you're back, $N. I'm pleased to see you're back, $N."] = 1026,
				["You found the final piece? Wonderful for you... and for Raene. I guess we'll have to see about repairing it, won't we? You found the final piece? Wonderful for you... and for Raene. I guess we'll have to see about repairing it, won't we?"] = 1027,
				["You've done it, $N! Well done! You've done it, $N! Well done!"] = 1055
			},
			["Hidden Shrine"] = 1028
		},
		["An Aggressive Defense"] = 1025,
		["Culling the Threat"] = 1054,
		["A Lost Master"] = 	{
			["Volcor"] = 993,
			["Terenthis"] = 986
		},
		["How Big a Threat?"] = 	{
			["Terenthis"] = 		{
				["This is terrible news indeed, $N. With the furbolgs this close to Auberdine, we will have to prepare ourselves for the inevitable. Thank you, $N. This is terrible news indeed, $N. With the furbolgs this close to Auberdine, we will have to prepare ourselves for the inevitable. Thank you, $N."] = 984,
				["Wash the blood from your garments, $N, and do not mourn what you had to do. Instead, give thanks. You have lessened the threat to thanks. You have lessened the threat to our people here in Auberdine, even if Darkshore is still in jeopardy from the effects of fel moss."] = 985
			}
		},
		["Escape Through Force"] = 994,
		["Escape Through Stealth"] = 995,
		["Plagued Lands"] = 2118,
		["Cleansing of the Infected"] = 2138,
		["Tharnariun's Hope"] = 2139,
		["Easy Strider Living"] = 2178,
		["Garments of Spirituality"] = 5648,
		["In Favor of Spirituality"] = 5649,
		["Hallowed Tablet"] = 3085,
		["The Horn of the Beast"] = 3181,
		["At Last!"] = 3201,
		["The Bounty of Teldrassil"] = 6341,
		["The Zoram Strand"] = 1008,
		["Pridewings of Stonetalon"] = 1134,
		["The Ancient Statuette"] = 1007,
		["Ruuzel"] = 1009,
		["Bathran's Hair"] = 1010,
		["Forsaken Diseases"] = 1011,
		["Insane Druids"] = 1012,
		["Ancient Spirit"] = 4261,
		["Kayneth Stillwind"] = 4581,
		["The Howling Vale"] = 1022,
		["Elemental Bracers"] = 1016,
		["Mage Summoner"] = 1017,
		["Orendil's Cure"] = 1020,
		["Elune's Tear"] = 1033,
		["The Ruins of Stardust"] = 1034,
		["Fallen Sky Lake"] = 1035,
		["The Branch of Cenarius"] = 1031,
		["Satyr Slaying!"] = 1032,
		["Vile Satyr! Dryads in Danger!"] = 1021,
		["Return to Feathermoon Stronghold"] = 2867,
		["A Hero's Welcome"] = 4266,
		["Passage to Booty Bay"] = 1040,
		["Compendium of the Fallen"] = 1049,
		["A Future Task"] = 	{
			["Sage Truthseeker"] = 2968,
			["High Explorer Magellas"] = 2964
		},
		["Mythology of the Titans"] = 1050,
		["In the Name of the Light"] = 1053,
		["Vorrel's Revenge"] = 1051,
		["Journey to Stonetalon Peak"] = 1056,
		["Reclaiming the Charred Vale"] = 	{
			["Keeper Albagorm"] = 1057,
			["Falfindel Waywarder"] = 1059
		},
		["Jin'Zil's Forest Magic"] = 1058,
		["Letter to Jin'Zil"] = 1060,
		["The Elder Crone"] = 1063,
		["Delivery to Magatha"] = 3518,
		["Sacred Fire"] = 5062,
		["Report to Zor"] = 1262,
		["Service to the Horde"] = 7541,
		["Lonebrow's Journal"] = 1100,
		["The Crone of the Kraul"] = 1101,
		["Thalanaar Delivery"] = 4281,
		["The Spirits of Stonetalon"] = 1061,
		["Goblin Invaders"] = 1062,
		["Shredding Machines"] = 1068,
		["A Gnome's Respite"] = 1071,
		["Ineptitude + Chemicals = Fun"] = 	{
			["Gaxim Rustfizzle"] = 1074,
			["Lomac Gearstrip"] = 1073
		},
		["Special Delivery for Gaxim"] = 1077,
		["Covert Ops - Alpha"] = 1079,
		["Covert Ops - Beta"] = 1080,
		["On Guard in Stonetalon"] = 	{
			["Gaxim Rustfizzle"] = 1085,
			["Kaela Shadowspear"] = 1070
		},
		["A Scroll from Mauren"] = 1075,
		["Devils in Westfall"] = 1076,
		["Retrieval for Mauren"] = 1078,
		["Update for Sentinel Thenysil"] = 1082,
		["Enraged Spirits"] = 1083,
		["Wounded Ancients"] = 1084,
		["Kaela's Update"] = 1091,
		["An Old Colleague"] = 1072,
		["Vorlus Vilehoof"] = 1683,
		["Elanaria"] = 1684,
		["The Shade of Elura"] = 1686,
		["Prayer to Elune"] = 	{
			["Astarii Starseeker"] = 3378,
			["Zamael Lunthistle"] = 3377
		},
		["The Apple Falls"] = 2241,
		["Destiny Calls"] = 2242,
		["Cenarius' Legacy"] = 1087,
		["Ordanus"] = 1088,
		["Flight to Auberdine"] = 6342,
		["Gerenzo's Orders"] = 	{
			["Ziz Fizziks"] = 1092,
			["Piznik"] = 1090
		},
		["Super Reaper 6000"] = 1093,
		["Gerenzo Wrenchwhistle"] = 1096,
		["Ziz Fizziks"] = 1483,
		["Erion Shadewhisper"] = 2259,
		["In Nightmares"] = 	{
			["Mathrengyl Bearwalker"] = 3370,
			["Arch Druid Hamuul Runetotem"] = 3369
		},
		["Morrowgrain Research"] = 	{
			["Mathrengyl Bearwalker"] = 		{
				["Yes, this voucher is good for twenty packets of seeds. If you run out, we have more that can be provided. Unfortunately though, Tharlendris seeds out by offsetting some of the cost. Those who return with morrowgrain find that the reward the Arch Druid offers far makes up for the cost."] = 3781,
				["Well done $N, I will be sure to give these to the Arch Druid himself when he has need of them. Meanwhile, please accept this appreciation. Our need for morrowgrain, for now, is constant; if you wish to continue aiding us, then please return when you have cultivated more of it."] = 3785
			},
			["Bashana Runetotem"] = 		{
				["Yes, this voucher is good for twenty packets of seeds. If you run out, we have more that can be provided. Unfortunately though, Tharlendris seeds out by offsetting some of the cost. Those who return with morrowgrain find that the reward the Arch Druid offers far makes up for the cost."] = 3782,
				["Well done $N, I will be sure to give these to the Arch Druid himself when he has need of them. Meanwhile, please accept this appreciation. Our need for morrowgrain, for now, is constant; if you wish to continue aiding us, then please return when you have cultivated more of it."] = 3786
			}
		},
		["Morrowgrain to Darnassus"] = 3803,
		["Glyphed Oaken Branch"] = 	{
			["Mathrengyl Bearwalker"] = 4986,
			["Nara Wildmane"] = 4987
		},
		["Back to Darnassus"] = 5931,
		["Ride to Ironforge"] = 6391,
		["Deathstalkers in Shadowfang"] = 1098,
		["A Vengeful Fate"] = 1102,
		["Rocket Car Parts"] = 1110,
		["Parts for Kravel"] = 1112,
		["Rumors for Kravel"] = 1117,
		["Zanzil's Mixture and a Fool's Stout"] = 1119,
		["Hardened Shells"] = 1105,
		["Encrusted Tail Fins"] = 1107,
		["The Brassbolts Brothers"] = 	{
			["Wizzle Brassbolts"] = 		{
				["Ah! Longbeard sent you with a load of helmets! Hooray! Now maybe we can talk a pilot into driving our car... Ah! Longbeard sent you with a load of helmets! Hooray! Now maybe we can talk a pilot into driving our car..."] = 1179,
				["Ah, you want to help me? Great! There's a part I want for an experiment I'm working on, and I need a brave $c like you me? Great! There's a part I want for an experiment I'm working on, and I need a brave $c like you to help me get it!"] = 2769
			}
		},
		["Gahz'rilla"] = 2770,
		["Salt Flat Venom"] = 1104,
		["Delivery to the Gnomes"] = 1114,
		["News for Fizzle"] = 1137,
		["The Swarm Grows"] = 	{
			["Moktar Krin"] = 		{
				["Don't mind the thundering echoes off the mountains' walls. The goblins and gnomes are out among the Flats racing one another in atrocities created by half my war party. But we remain here until we hear word from Belgrom in Orgrimmar. Until then, we hold our position here, and stay vigilant."] = 1146,
				["Ha! That ichor you're covered in actually makes you prettier, $N! It certainly does make you reek at the same time though. Don't stand too think my companions would agree that your smell alone is proof you've done your part to help us against those insect creatures. Thank you, $N."] = 1147
			},
			["Belgrom Rockmaul"] = 1145
		},
		["A Grim Discovery"] = 	{
			["Belgrom Rockmaul"] = 2976,
			["Krueg Skullsplitter"] = 2974
		},
		["Betrayed"] = 	{
			["Belgrom Rockmaul"] = 3507,
			["Ag'tor Bloodfist"] = 		{
				["We've sent everything we had at her and her workers, but they are strong in battle. None have bothered to return. I'm assuming some have arrived, perhaps there's still something we can do. Perhaps we can still punish her for lying and betraying Belgrom. What do you say, are you in?"] = 3504,
				["RAR!! Incredible! You've done it! Belgrom will be pleased! Finally the spirits of dozens of our warriors can be at peace. Thank you, $N. RAR!! Incredible! You've done it! Belgrom will be pleased! Finally the spirits of dozens of our warriors can be at peace. Thank you, $N."] = 3506
			},
			["Kaldorei Tome of Summoning"] = 3505
		},
		["To Steal From Thieves"] = 1164,
		["Test of Lore"] = 	{
			["Parqual Fintallas"] = 		{
				["Braug sent you? Impossible. <Parqual looks you up and down.> Braved Dor'Danil, took a leap of faith, fought and overpowered a powerful elemental? Bah! You're probably a some adventurer that overheard talk in a tavern. And now you think you have what it takes to pass my test. So be it... $c."] = 1159,
				["This is the book I sent you to search for. <Parqual slowly caresses his hand over the top of the book as he stares down at and spirit. If you have studied the book long enough, then I shall ask you your question and you can be done with these tests!"] = 1160,
				["Well done, $N. I had my doubts if you studied the text I asked you to get, but you've answered correctly. Well done, $N. I had my doubts if you studied the text I asked you to get, but you've answered correctly."] = 6628
			},
			["Braug Dimspirit"] = 		{
				["The days and nights grow colder throughout the world as goblins rape the land, and the night elves point fingers at the younger races. The Dorn knows this, and he has sent you to me because you have shown the attributes necessary to realize it also. Now you stand before Braug."] = 1152,
				["This is the book I named. There is hope you will answer my question correctly then... unless you've forgotten to study its contents. When you are question correctly then... unless you've forgotten to study its contents. When you are prepared, speak to me again and I shall ask a question of you."] = 1154,
				["Well done, $c. You have studied the text I asked you to, and now you have passed another of our tests. Well done, $c. You have studied the text I asked you to, and now you have passed another of our tests."] = 6627
			}
		},
		["Get the Gnomes Drunk"] = 1120,
		["Get the Goblins Drunk"] = 1121,
		["Alliance Relations"] = 	{
			["Maurin Bonesplitter"] = 1433,
			["Keldran"] = 		{
				["Putanni, noble $c. I am Keldran, student of magic... and other mystical arts. The business Craven sent you here to speak to me about requires a aid... and yours. It starts with appearances, $N. How the Horde sees itself. How our allies see us. And most importantly, how our enemies see us."] = 1431,
				["You have returned from Desolace more than successful, $N. Thank you. Thank you for your efforts, your time, and your understanding to my plea. Thrall understands between the Horde and Alliance, and by taking measures to insure our appearance is acceptable, we will not provoke any further threats of unnecessary violence."] = 1436
			},
			["Takata Steelblade"] = 1432
		},
		["The Burning of Spirits"] = 1435,
		["The Corrupter"] = 	{
			["Maurin Bonesplitter"] = 		{
				["Hmm, these runes are indeed a language, $N, an old language. They seem remotely similar to the Eredun language, but the differences are drastic. If differences are drastic. If I am not mistaken, this is a contract of some kind.... Here, yes, this symbol is the demon's signature: Lord Azrethoc."] = 1480,
				["The shadowstalkers were unable to slay you, $c. Impressive... most impressive. This scalp will do nicely for my spell. While you were away, I was able for the spell. I am almost ready. I only need a focus for the spell--something to project an image of the demon lord and his whereabouts."] = 1481,
				["A precious oracle crystal... flawless... beautiful. Indeed. We shall begin immediately. Finding this demon lord should be our primary concern, and its slaying demands our utmost and its slaying demands our utmost attention. Take a step back, $c, and let us see what this demon is, and where he may be found."] = 1482
			},
			["Takata Steelblade"] = 		{
				["I witnessed what just occurred with Maurin and the demon lord. That creature, even as an apparition, seems to have more power than my warlock my responsibilities here, I would disgrace my clan if I turned my back on my duties here to battle this evil for my own honor."] = 1484,
				["A mighty victory for us all, $N. Let us rejoice in your success. I trust now that our future here is not as bleak as will be slain, the Burning Blade will fail in their efforts, and we may one day have a place we can safely call home again."] = 1488
			}
		},
		["Overlord Mok'Morokk's Concern"] = 1166,
		["The Brood of Onyxia"] = 	{
			["Overlord Mok'Morokk"] = 1170,
			["Draz'Zilb"] = 		{
				["That lazy coward! Mok'Morokk displayed strength when Rexxar was our leader. But soon after Rexxar's departure Mok'Morokk fell prey to temptations of power. Rather than lead, to temptations of power. Rather than lead, he demanded. He does not serve his people but rather expects us to serve him. Something must be done."] = 1171,
				["Splendid! It will be sometime before Onyxia can produce more eggs. On behalf of my people, I thank you, $N. I have asked much of you so Drive Mok'Morokk from this place by force. Only then can we appoint a new leader to return us to our proper home in the south."] = 1172
			}
		},
		["Identifying the Brood"] = 1169,
		["Challenge Overlord Mok'Morokk"] = 1173,
		["Army of the Black Dragon"] = 1168,
		["Hungry!"] = 1177,
		["Willix the Importer"] = 1144,
		["Mortality Wanes"] = 1142,
		["A New Cloak's Sheen"] = 2973,
		["Michael Garrett"] = 6322,
		["Ride to the Undercity"] = 6323,
		["Speak with Anastasia"] = 1881,
		["The Balnir Farmstead"] = 1882,
		["Report to Anastasia"] = 1959,
		["Investigate the Alchemist Shop"] = 1960,
		["Spellfire Robes"] = 1962,
		["Martek the Exiled"] = 1106,
		["Indurium"] = 1108,
		["A Bump in the Road"] = 1175,
		["Load Lightening"] = 1176,
		["Indurium Ore"] = 1192,
		["Rizzle's Schematics"] = 1194,
		["The Eighteenth Pilot"] = 1186,
		["Razzeric's Tweaking"] = 1187,
		["Safety First"] = 	{
			["Razzeric"] = 1189,
			["Shreev"] = 1188
		},
		["Zamek's Distraction"] = 1191,
		["The Sacred Flame"] = 	{
			["Zangen Stonehoof"] = 1195,
			["Rau Cliffrunner"] = 		{
				["Hm, yes, this phial of water will serve our purposes perfectly. Because of the shared ancestry of the dryads and the centaurs, the water of the dryads and the centaurs, the water of the moonwells will enable us to breach the protection of the eternal flame surrounding the centaur relic."] = 1196,
				["I sense a strange energy emanating from the Hoof... I have no doubt that we will discover surprising new information about the centaur from its discover surprising new information about the centaur from its study. My thanks, $N. Now I must begin to decipher the mysteries you have brought to me."] = 1197
			}
		},
		["Blackfathom Villainy"] = 	{
			["Dawnwatcher Selgorm"] = 1200,
			["Bashana Runetotem"] = 6561
		},
		["Twilight Falls"] = 1199,
		["In Search of Thaelrid"] = 1198,
		["Theramore Spies"] = 1201,
		["The Theramore Docks"] = 1202,
		["The Lost Report"] = 1238,
		["The Severed Head"] = 1239,
		["Marg Speaks"] = 1261,
		["Jarl Needs a Blade"] = 1203,
		["Jarl Needs Eyes"] = 1206,
		["Marsh Frog Legs"] = 1218,
		["Mudrock Soup and Bugs"] = 1204,
		["... and Bugs"] = 1258,
		["Morgan Stern"] = 1260,
		["The Black Shield"] = 	{
			["Krog"] = 		{
				["I grant that humans have strange decorating tastes, but would they use a plain iron shield to adorn their fireplace? Perhaps this shield was placed use a plain iron shield to adorn their fireplace? Perhaps this shield was placed there by the ones who burned the inn. A warning? A threat?"] = 1251,
				["Mosarn? Sounds familiar... I can't put my finger on it. Maybe it'll come to me later. It probably isn't important. A shield can come from anywhere can't put my finger on it. Maybe it'll come to me later. It probably isn't important. A shield can come from anywhere and not mean anything..."] = 1323
			},
			["Caz Twosprocket"] = 1319,
			["Mosarn"] = 1276,
			["Captain Garran Vimes"] = 		{
				["Hm, I'm no expert with the construction of arms and armor. Their use, yes, but not their making. This shield seems as ordinary as any, excepting and armor. Their use, yes, but not their making. This shield seems as ordinary as any, excepting the damage from the fire that engulfed the inn."] = 1253,
				["That's not much information to work on, but we'll have to keep it in mind. Hopefully some of the other pieces of this mystery will it in mind. Hopefully some of the other pieces of this mystery will fall into place, and paint a more helpful picture of what happened."] = 1320
			},
			["Do'gol"] = 		{
				["This is good shield. Very strong, heavy, good. But Do'gol don't need it. I make shields, not buy them, $N. You should know that. This is good shield. Very strong, heavy, good. But Do'gol don't need it. I make shields, not buy them, $N. You should know that."] = 1321,
				["I don't like spiders that are so big I can't sit on them and squish them. Thanks for getting them, $N. Now I rip them open so big I can't sit on them and squish them. Thanks for getting them, $N. Now I rip them open and pour them onto the shield..."] = 1322
			}
		},
		["Suspicious Hoofprints"] = 	{
			["Krog"] = 1268,
			["Captain Garran Vimes"] = 1284
		},
		["Lieutenant Paval Reethe"] = 	{
			["Krog"] = 1269,
			["Captain Garran Vimes"] = 1252,
			["Adjutant Tesoran"] = 1259
		},
		["Questioning Reethe"] = 1273,
		["Captain Vimes"] = 1220,
		["They Call Him Smiling Jim"] = 1282,
		["Daelin's Men"] = 1285,
		["The Deserters"] = 	{
			["Captain Garran Vimes"] = 1287,
			["Balos Jacken"] = 1286
		},
		["What Is Going On?"] = 	{
			["Thrall"] = 4001,
			["Commander Gor'shak"] = 3982
		},
		["The Eastern Kingdoms"] = 4002,
		["The Princess Saved?"] = 4004,
		["Eitrigg's Wisdom"] = 4941,
		["For The Horde!"] = 4974,
		["What the Wind Carries"] = 6566,
		["The Lord of Blackrock"] = 	{
			["Thrall"] = 7783,
			["Overlord Runthak"] = 7784,
			["Field Marshal Afrasiabi"] = 7782,
			["King Varian Wrynn"] = 7781
		},
		["Shadowshard Fragments"] = 	{
			["Archmage Tervosh"] = 7070,
			["Uthel'nay"] = 7068
		},
		["James Hyal"] = 	{
			["Vincent Hyal"] = 1301,
			["Clerk Lendry"] = 1302
		},
		["Chicken Clucking for a Mint"] = 	{
			["Innkeeper Firebrew"] = 8353,
			["Innkeeper Norman"] = 8354
		},
		["Speak with Bink"] = 1879,
		["Mage-tastic Gizmonitor"] = 1880,
		["The Tome of Valor"] = 	{
			["Brandur Ironhammer"] = 1794,
			["Duthorian Rall"] = 		{
				["Ah, you wish to petition me for a test of valor. Splendid. There are many tasks throughout the city and surrounding lands that hold much challenge, lives. The Church always wishes to bolster its ranks, but it understands the sacrifices needed to ensure the paladins serving it are worthy. Are you prepared?"] = 1649,
				["So, we meet again, $N, and you are in high spirits, I see. The Stilwell home will be safe for another day, and from your story the Church greatly, and having you protect their property--and their very lives--was the least we could do for them. For your valor, you will be rewarded."] = 1652,
				["It has been proven that the Light is with you, $N, but as times grow more dangerous, it becomes important to know what strength lies and your weapon. Protecting the weak, and not losing faith are two more lessons you must master while you study in the Cathedral of Light."] = 1793
			},
			["Daphne Stilwell"] = 		{
				["Hello, $N. I'm assuming by all that armor and weapon of yours, you're either here to try and take my land, or the Church finally They've been a little slow getting 'round the bend up there, but they probably saw you coming, which means they'll probably be here any minute."] = 1650,
				["We've done it, $N! Thank you for your help. You were truly amazing out there. I never thought a $c could handle so many enemies truly amazing out there. I never thought a $c could handle so many enemies at once. You've truly shown bravery in the face of overwhelming odds."] = 1651
			}
		},
		["The Art of the Armorsmith"] = 	{
			["Grumnus Steelshaper"] = 5283,
			["Okothos Ironrager"] = 5301
		},
		["Road to Salvation"] = 2218,
		["Onin's Report"] = 2239,
		["To Hulfdan!"] = 2299,
		["Errand for Apothecary Zinge"] = 	{
			["Apothecary Zinge"] = 238,
			["Alessandro Luca"] = 232
		},
		["Return to Apothecary Zinge"] = 864,
		["Zinge's Delivery"] = 1359,
		["The Essence of Eranikus"] = 	{
			["Itharius"] = 3374,
			["Essence Font"] = 3373
		},
		["In Search of The Temple"] = 1448,
		["Rhapsody's Tale"] = 1469,
		["Into The Temple of Atal'Hakkar"] = 1475,
		["Mazen's Behest"] = 	{
			["Watcher Mahar Ba"] = 1364,
			["Acolyte Dellis"] = 1363
		},
		["Supplies for Nethergarde"] = 1395,
		["The Lost Supplies"] = 1423,
		["Deliver the Shipment"] = 1425,
		["Neeka Bloodscar"] = 1418,
		["Coyote Thieves"] = 1419,
		["The Kolkar of Desolace"] = 1362,
		["Khan Dez'hepah"] = 1365,
		["Centaur Bounty"] = 	{
			["Felgur Twocuts"] = 1366,
			["Corporal Melkins"] = 1387
		},
		["Gelkis Alliance"] = 1368,
		["Stealing Supplies"] = 1370,
		["Ongeku"] = 1373,
		["Khan Jehn"] = 1374,
		["Khan Hratha"] = 	{
			["Uthek the Wise"] = 1380,
			["Warug"] = 1381
		},
		["Strange Alliance"] = 1382,
		["Raid on the Kolkar"] = 1384,
		["Magram Alliance"] = 1367,
		["Broken Tears"] = 1369,
		["Gizmo for Warug"] = 1371,
		["Khan Shaka"] = 1375,
		["Brutal Politics"] = 1385,
		["Assault on the Kolkar"] = 1386,
		["Ledger from Tanaris"] = 4450,
		["Mold Rhymes With..."] = 	{
			["Krinkle Goodsteel"] = 		{
				["Dithers said you'd deliver the goods, and deliver you have! A deal is a deal; let me pack the fragments into the mold for you. Did fragments into the mold for you. Did Dithers imbue them already? Excellent... otherwise, it would have been a long trip back to the Bulwark for you."] = 5514,
				["Arbington said you'd deliver the goods, and deliver you have! A deal is a deal; let me pack the fragments into the mold for you. Did into the mold for you. Did Arbington imbue them already? Excellent... otherwise, it would have been a long trip back to the Chillwind Camp for you."] = 5538
			}
		},
		["Stormpike's Order"] = 1338,
		["Fire Hardened Mail"] = 1701,
		["The Shieldsmith"] = 1702,
		["Furen's Armor"] = 1782,
		["Nothing But The Truth"] = 	{
			["Apothecary Faustin"] = 		{
				["Zraedus was just telling me about the nosey little Infiltrator before you arrived. Quite a problem, indeed. The last thing we need is a busybody sniffing any information they can from the human. Work with me, $N, and we will deliver a truth serum to Stonard. For the Horde! ...did I get that right?"] = 1372,
				["Splendid, $N! And just in time too. From what Zraedus tells me, the Infiltrator has recovered from his wounds and is ready to be questioned wounds and is ready to be questioned by the orcs. Give me but a moment to prepare the pois - I mean prepare the truth serum."] = 1383
			},
			["Infiltrator Marksen"] = 1391,
			["Deathstalker Zraedus"] = 1388
		},
		["Vital Supplies"] = 1477,
		["Encroaching Wildlife"] = 1396,
		["Driftwood"] = 1398,
		["The Lost Caravan"] = 1421,
		["Speak with Jennea"] = 1860,
		["Mirror Lake"] = 1861,
		["Report to Jennea"] = 1919,
		["Investigate the Blue Recluse"] = 1920,
		["Fresh Meat"] = 1430,
		["Lack of Surplus"] = 	{
			["Tok'Kar"] = 		{
				["Ah! Wonderful. Fresh meat for the fire tonight. Thank you, $N. You've helped make the coming nights more tolerable. The fire burns bright, and our stomachs bring us a shipment; Dar's not the most attractive orc anyone's laid eyes upon, but at least his attitude reeks far less than his smell."] = 698,
				["Glad to see you're alive and well, $N. These claws should make do nicely. The more weapons we have at the ready for attacks against us, get started on your weapon as soon as possible. It will only take a short time. I've become quite adept and quick at their production."] = 699
			}
		},
		["Threat From the Sea"] = 	{
			["Tok'Kar"] = 1427,
			["Katar"] = 		{
				["Be silent a moment, $c. Even over the dull roar of the sea you can still hear those disgusting gurgles from the fish men. Be silent a moment, $c. Even over the dull roar of the sea you can still hear those disgusting gurgles from the fish men."] = 1422,
				["The sea seems vast and relentless, but you have stained her with the blood of her own spawn. The fish men know pain. Their stupidity time I hear one of them silenced. Return to me if you wish to slay more of the fish men. I will gladly reward you again."] = 1426
			}
		},
		["Continued Threat"] = 1428,
		["Noxious Lair Investigation"] = 82,
		["Insect Part Analysis"] = 	{
			["Alchemist Pestlezugg"] = 110,
			["Senior Surveyor Fizzledowser"] = 113
		},
		["March of the Silithid"] = 	{
			["Alchemist Pestlezugg"] = 		{
				["Yes, I gathered that Gracina sent you to me. Your experience in fighting these beasties is priceless; no one to my knowledge has ever dealt mysterious and dangerous jungle to the west of here. Perhaps it is also one step closer to figuring out what the silithid are all about."] = 4493,
				["Yes, I gathered that Zilzibin sent you to me. Your experience in fighting these beasties is priceless; no one to my knowledge has ever dealt mysterious and dangerous jungle to the west of here. Perhaps it is also one step closer to figuring out what the silithid are all about."] = 4494
			}
		},
		["Bungle in the Jungle"] = 4496,
		["Pawn Captures Queen"] = 4507,
		["The Atal'ai Exile"] = 1429,
		["Jammal'an the Prophet"] = 1446,
		["Rhapsody Shindigger"] = 1451,
		["Rhapsody's Kalimdor Kocktail"] = 1452,
		["To The Hinterlands"] = 1449,
		["Gryphon Master Talonaxe"] = 1450,
		["Witherbark Cages"] = 2988,
		["The Altar of Zul"] = 2989,
		["Return to the Hinterlands"] = 2993,
		["Saving Sharpbeak"] = 2994,
		["The Karnitol Shipwreck"] = 	{
			["Roetten Stonehammer"] = 1457,
			["Kreldig Ungor"] = 		{
				["Welcome back to Nijel's Point, $N. So, tell me what you found. What!? Nothing? An empty chest ain't gonna get us paid, I'm afraid. Tell me more tell me what you found. What!? Nothing? An empty chest ain't gonna get us paid, I'm afraid. Tell me more about these marks you saw... these slashes."] = 1455,
				["This is great, $N! You found Karnitol's belongings! Those blasted naga, always causing trouble. I think I'd rather spend my life at war with the Horde I'd rather spend my life at war with the Horde than have to go against their kind. You've done a great service to the Reclaimers."] = 1456
			},
			["Karnitol's Chest"] = 1454
		},
		["Reagents for Reclaimers Inc."] = 	{
			["Roetten Stonehammer"] = 1467,
			["Kreldig Ungor"] = 		{
				["Good good, $N. Not sure if these are of any good quality, but if Leftwitch wanted a specific type, he should have specified before sending he should have specified before sending the Reclaimers out here to begin with. What say you to getting on with the next item on his list?"] = 1458,
				["Your help here's a boon, $N. You're cutting my time spent here in Desolace by half at least. I'll be back in Ironforge warming my of, and I'm back home, look me up, I'll buy you an ale for sure. But until then, let's get the rest of these reagents gathered."] = 1459,
				["Honestly? I wouldn't have thought it. You're amazing, $N. Taking on demons for a mage's experiments, and coming back in one piece to boot. Great a mage's experiments, and coming back in one piece to boot. Great job! I'm personally gonna tell Roetten about you when I get back to Ironforge."] = 1466
			}
		},
		["Reclaimers' Business in Desolace"] = 1453,
		["Befouled by Satyr"] = 1434,
		["Return to Vahlarriel"] = 1440,
		["Vahlarriel's Search"] = 	{
			["Vahlarriel Demonslayer"] = 1465,
			["Dalinda Malem"] = 1438,
			["Malem Chest"] = 1437
		},
		["Search for Tyranis"] = 1439,
		["Reclaimed Treasures"] = 	{
			["Patrick Garrett"] = 2342,
			["Krom Stoutarm"] = 1360
		},
		["The Binding"] = 	{
			["Carendin Halgar"] = 		{
				["You have done well, $N. Now, I will impart to you the spell used for summoning the voidwalker. The power that it unleashed upon you is will impart to you the spell used for summoning the voidwalker. The power that it unleashed upon you is now yours to command. Use it wisely."] = 1471,
				["Again, you have done well, $N. It has been quite some time since I have seen a young $c with as much potential as you. watch your progress, and prepare and assist you in your future trials. For now, let me show you the summoning spell for your newly dominated succubus."] = 1474
			},
			["Gan'rul Bloodeye"] = 		{
				["You have done well, $N. I will show you how to summon the voidwalker similar to the one you just defeated. You should know that we it go to your head, however, as the tasks that still lie before you will make this seem as simple as waking in the morning."] = 1504,
				["Success! Be sure I expected nothing less from my star pupil. You have proven your worth, and gladly will I show you the method of summoning are longer in years, but remember it, and hold it as protection against the wiles of the dark power you have learned to summon today."] = 1513
			},
			["Gakin the Darkbinder"] = 		{
				["You did better than I expected, $N, but as well as I'd hoped. Now, you can learn to command your subjugated voidwalker, an ally you that are sure to stand before you. I have nothing more to teach you at the present, but I am far from done with you, $N."] = 1689,
				["Well done, well done, $N. I see we've done right in deciding to train you. Your performance certainly does not disappoint. I've no qualms in showing deciding to train you. Your performance certainly does not disappoint. I've no qualms in showing you the way to control your newly bound succubus. Observe carefully."] = 1739
			},
			["Strahad Farsan"] = 1795
		},
		["Creature of the Void"] = 	{
			["Carendin Halgar"] = 1473,
			["Gan'rul Bloodeye"] = 1501
		},
		["Hearts of the Pure"] = 1476,
		["Halgar's Summons"] = 1478,
		["A Rogue's Deal"] = 	{
			["Innkeeper Renee"] = 8,
			["Calvin Montague"] = 590
		},
		["Devourer of Souls"] = 	{
			["Godrick Farsan"] = 1472,
			["Cazul"] = 1507,
			["Takar the Seer"] = 1716
		},
		["Ur's Treatise on Shadow Magic"] = 1938,
		["High Sorcerer Andromath"] = 1939,
		["Deviate Hides"] = 1486,
		["Deviate Eradication"] = 1487,
		["Assisting Arch Druid Runetotem"] = 936,
		["Hamuul Runetotem"] = 1489,
		["Leaders of the Fang"] = 914,
		["Nara Wildmane"] = 1490,
		["Guarding Secrets"] = 	{
			["Nara Wildmane"] = 4883,
			["Trull Failbane"] = 4882
		},
		["Path of Defense"] = 1498,
		["Veteran Uzzek"] = 1505,
		["Gan'rul's Summons"] = 1506,
		["Love's Gift"] = 1512,
		["Thun'grim Firegaze"] = 1502,
		["Forged Steel"] = 1503,
		["Speak with Thun'grim"] = 1825,
		["Brutal Armor"] = 1838,
		["Brutal Hauberk"] = 1848,
		["Speak with Un'thuwa"] = 1883,
		["Ju-Ju Heaps"] = 1884,
		["Glyphic Tablet"] = 3086,
		["Speak with Deino"] = 1943,
		["Waters of Xavian"] = 1944,
		["Earth Sapta"] = 	{
			["Canaga Earthcaller"] = 1463,
			["Seer Ravenfeather"] = 1462
		},
		["Call of Earth"] = 	{
			["Canaga Earthcaller"] = 		{
				["Excellent. Your success shows that you are prepared. Of all the elements, earth represents the foundation of all things. It is your strength, your stamina, and wisdom. Never forget the secrets earth shares with you. I shall make a sapta for you now, and by accepting it, you will realize your path."] = 1516,
				["Excellent! The totem I will craft for you is more than a symbol of your status among $c--it has abilities beyond that. One use of the trainers will know when you are ready for greater knowledge. But for now, take this earth totem, and a scroll to teach you your first ability."] = 1518
			},
			["Seer Ravenfeather"] = 		{
				["Good, $N. Your return here signifies that you are indeed prepared for the next step. Of all the elements, earth represents the foundation of all things. forget the secrets she shares with you. I shall make your sapta for you now, and by accepting it, a new path will open before you."] = 1519,
				["Splendid. The totem I will craft for you is more than a symbol--it has abilities beyond that. One use of the totem is a focus for will let you know as much when you visit them. But for now, take this earth totem, and a scroll to teach you your first ability."] = 1521
			},
			["Minor Manifestation of Earth"] = 1520
		},
		["Call of Water"] = 	{
			["Minor Manifestation of Water"] = 100,
			["Brine"] = 		{
				["Yes? Mmm. I have a feeling I know what you're going to ask me: what would possess someone to live out here in the deepest part Barrens to speak to a woman who obviously has no concern for her own well-being? I'm willing to bet we both know the answer to that."] = 1530,
				["Wonderful, $N. With all three samples gathered, I can create for you a vial of the purest water any living creature will find. It will pleased to count you among our kind, $N. You do all $c proud, and I look forward to hearing about your exploits in the future."] = 1534,
				["I thought some bloodshed might ensue if you tried to take water from the pool. It is a pity the quilboar do not realize that to put their differences aside and their clans came together. Again, a pity, but more than likely a boon for the other races of the Barrens."] = 1535,
				["This is good, $N. You're dedicated to the task at hand and have the ability to seek out that which is needed. One more sample is out that which is needed. One more sample is all I need to create the reagent needed for your sapta. Islen will be pleased as well."] = 1536
			},
			["Islen Waterseer"] = 		{
				["This is the proof I asked for. You've done well, $N. I am pleased to be the first to congratulate you and give you this... your many other effects. I suggest you seek out a shaman trainer when you have the time. They might have other spells for you to learn."] = 96,
				["Ah, a vial of water created and blessed by Brine, and gathered by you, no less. The liquid in this vial will be key in creating The remaining drops, well, the remaining drops I will tell you about if you feel you are ready. Are you prepared for one more journey, $N?"] = 220,
				["The wind approaches you quickly from the horizon; the earth is steady beneath your feet; and your spirit is already warmed by fire--I would say led you this far, and your spirit will give you the strength to carry on even further. But the first step is yours to take."] = 1528
			},
			["Tiev Mordune"] = 1103,
			["Brazier of Everfount"] = 63
		},
		["Fire Sapta"] = 1464,
		["Call of Fire"] = 	{
			["Telf Joolam"] = 		{
				["Ah, my mistake, $N. I apologize. I did not realize you possessed the Torch. I am pleased to make your acquaintance. Many adventurers find their way we know the truth, do we not, $N? This shrine holds a greater secret from the mundane members of the Horde. To us, it is sacred."] = 1524,
				["These will do nicely, $N. Fire is more than chaos and destruction--do well to remember that. It is also about life, and creation. All things are give one another meaning. Always remember this. Using different types of magic in conjunction with one another will show not only true skill, but great wisdom."] = 1525
			},
			["Kranal Fiss"] = 		{
				["Hmmm, Searn sent you to me, did he? Well then, Searn could always be trusted, so that must mean you're ready to take part of the of it. Patience, $N. Remember what earth taught you. Power and destruction will come easily, but you must still know when to stay your hand."] = 1522,
				["Hmmm, Narm sent you to me, did he? Well then, Narm could always be trusted, so that must mean you're ready to take part of the of it. Patience, $N. Remember what earth taught you. Power and destruction will come easily, but you must still know when to stay your hand."] = 2984,
				["Your spirit burns brighter than any torch I've ever seen, $N, and for that, you should be proud. If you continue down this path, the elements our brethren will look to you for guidance and wisdom. Let me be the first to congratulate you and present to you your newest totem."] = 1527,
				["Hmmm, Swart sent you to me, did he? Well then, Swart could always be trusted, so that must mean you're ready to take part of the of it. Patience, $N. Remember what earth taught you. Power and destruction will come easily, but you must still know when to stay your hand."] = 2983
			},
			["Brazier of the Dormant Flame"] = 1526
		},
		["Water Sapta"] = 972,
		["Seeking Spiritual Aid"] = 5158,
		["Call of Air"] = 	{
			["Prate Cloudseer"] = 		{
				["For the time being. I shall give you what you need to focus your spells and to call upon the spirits of air. Take this to focus your spells and to call upon the spirits of air. Take this totem, and when you are ready, train with me some more."] = 1531,
				["For the time being, I shall give you what you need to focus your spells and to call upon the spirits of air. Take this to focus your spells and to call upon the spirits of air. Take this totem, and when you are ready, train with me some more."] = 1532
			}
		},
		["Dogran's Captivity"] = 1515,
		["Blind Cazul"] = 1508,
		["Ken'zigla's Draught"] = 1511,
		["Tooga's Quest"] = 1560,
		["Get Me Out of Here!"] = 6132,
		["Ghost-o-plasm Round Up"] = 6134,
		["Supplying the Front"] = 1578,
		["Tormus Deepforge"] = 1680,
		["Ironband's Compound"] = 1681,
		["Grey Iron Weapons"] = 1682,
		["Moonglow Vest"] = 1582,
		["A Warrior's Training"] = 1638,
		["Bartleby's Mug"] = 1665,
		["Bartleby the Drunk"] = 1639,
		["Beat Bartleby"] = 1640,
		["Vejrek"] = 1678,
		["Muren Stormpike"] = 1679,
		["Gakin's Summons"] = 1717,
		["Surena Caledon"] = 1688,
		["The Slaughtered Lamb"] = 1715,
		["Heartswood"] = 1738,
		["The Name of the Beast"] = 	{
			["Lord Arkkoroc"] = 		{
				["A demon lord? <Lord Arkkoroc laughs.> Perhaps the one can assist you with this information; but first, you must assist the one.  A demon lord? <Lord Arkkoroc laughs.> Perhaps the one can assist you with this information; but first, you must assist the one. "] = 3509,
				["Finally, one worthy of the wisdom of Arkkoroc! Finally, one worthy of the wisdom of Arkkoroc!"] = 3510
			},
			["Loramus Thalipedes"] = 3511
		},
		["Smith Mathiel"] = 1692,
		["Weapons of Elunite"] = 1693,
		["Mathiel"] = 1703,
		["Sunscorched Shells"] = 1710,
		["Mathiel's Armor"] = 1711,
		["Yorus Barleybrew"] = 1698,
		["The Rethban Gauntlet"] = 1699,
		["Klockmort Spannerspan"] = 1704,
		["Iron Coral"] = 1708,
		["Klockmort's Creation"] = 1709,
		["Essential Artificials"] = 2924,
		["Klockmort's Essentials"] = 2925,
		["The Tome of Divinity"] = 	{
			["Duthorian Rall"] = 		{
				["Here in Stormwind, I am responsible for putting paladins on the path to greater virtue as they devote themselves to the Light and defend Azeroth some about the Light, and what is expected of you. If you understand it, and are capable, then you will succeed in attaining greater abilities."] = 1641,
				["Hello again, $N. How goes your studies of the Tome of Divinity? Then you should be prepared to have yourself tested. There are always tasks to the patience to help others, especially those who are less fortunate, you prove that you are a servant of the Light and of sound mind."] = 1642,
				["You've returned so quickly, $N. And what have you accomplished in your time away from the Cathedral? Have you helped a noble cause? Perhaps you've learned impressed, $N, those are surely the actions of one who follows the Light and values others above oneself. Such sacrifice will always be rewarded in time."] = 1780,
				["You've done well this day, $N. You should take some pride in what you've accomplished. Even more so, you should be proud of your abilities. Not power to bring back fallen companions much like you did for Henze. Be well, $N. The Light shines upon you and you should welcome it wholly."] = 1788
			},
			["Henze Faulk"] = 1786,
			["Gazin Tenorm"] = 		{
				["*cough* Pleasure to meet you, $R. Don't mind my wounds, the good priest here can take care of ol' Gazin this time. I won't be needing exactly what befell me and my friend Henze. And with any luck, and some skill on your part, perhaps you can still help us all."] = 1781,
				["Wonderful! You made it, and saved Henze. The Light is with you for sure, $N! Wonderful! You made it, and saved Henze. The Light is with you for sure, $N!"] = 1787
			},
			["Stephanie Turner"] = 		{
				["Oh, hello, luv. How go your adventures? Oh, I'm so glad to hear you're doing well. Oh, me? Thank you for asking--I'm doing well, all things the orphanage, but we'll manage. By 'we' I mean my husband and I. He's up in Ironforge trying to seek help from the citizens there."] = 1643,
				["Thank you, $N, thank you so much! The children will be so pleased, and you've saved me so much time. I'll now be able to focus to return home sooner than we thought. Thank you again, $N. I knew I could rely on the charity of others. The Light be with you."] = 1644
			},
			["John Turner"] = 		{
				["THE ORPHANAGE OF STOR... oh, sorry, didn't mean to shout at you, sir. My name is John Turner. How are you? Good, good, glad to hear things already, and I miss my wife terribly, but that's the price you have to pay when there are mouths to feed and backs to clothe."] = 1647,
				["This is so wonderful of you, $N. Thank you again. You're a noble man for doing this for me. It's no wonder you've chosen to follow least you could do? See? That's what I'm talking about, $N, noble to the end. Be safe, and may the Light protect you in your travels."] = 1648
			},
			["Narm Faulk"] = 1783,
			["Muiredon Battleforge"] = 		{
				["*cough* Good day to ya, $c. Don't mind me wounds, the good priest 'ere'll take care of ol' Muiredon in time. Not needin' the power of I'll take the time to talk to ya-I'll tell ya exactly wut happened to Muiredon and his best friend Narm, a $c jus' like yerself."] = 1779,
				["Haha! You've done it! Ya saved Narm, and ya found the proof me wife needs to take to the council. Yer a blessin' o' the to take to the council. Yer a blessin' o' the Light if I ever saw one... not includin' me wife o' course. Thank ya again, $N."] = 1784
			},
			["Tiza Battleforge"] = 		{
				["Here in Ironforge, I am responsible for putting paladins on the path to greater virtue as they devote themselves to the Light and defend Azeroth some about the Light, and what is expected of you. If you understand it, and are capable, then you will succeed in attaining greater abilities."] = 1645,
				["Welcome back, $N. You've spent time reading the book, I hope? Then you should be prepared to have yourself tested. There are always tasks to be the patience to help others, especially those who are less fortunate, you prove that you are a servant of the Light and of sound mind."] = 1646,
				["So, you've returned so quickly, huh? And what pray tell have you accomplished in your time away from here? Were you able to help a noble have you helped and how.... Impressive, $N, those are surely the actions of one who follows the Light. Such sacrifice will always be rewarded in time."] = 1778,
				["You've done all of Ironforge a great favor today, $N. I'm proud to count you among us, and if you feel you're ready, I would life. I will teach you the ability to resurrect your companions. Use it wisely, $N, and thank you, on behalf of myself, my husband, and Ironforge."] = 1785
			}
		},
		["The Symbol of Life"] = 	{
			["Duthorian Rall"] = 1790,
			["Tiza Battleforge"] = 1789
		},
		["Tome of Divinity"] = 	{
			["Duthorian Rall"] = 		{
				["It is beautiful here in Stormwind, is it not? Your timing actually couldn't have been better, $N. It is beautiful here in Stormwind, is it not? Your timing actually couldn't have been better, $N."] = 2998,
				["Welcome to the Cathedral of Light, $c. Welcome to the Cathedral of Light, $c."] = 3681
			},
			["Tiza Battleforge"] = 		{
				["Well met, $N. I hope the Light shows you the true path and keeps you safe from evil. Well met, $N. I hope the Light shows you the true path and keeps you safe from evil."] = 2997,
				["I greet you, and bid you welcome, $N. I greet you, and bid you welcome, $N."] = 3000
			}
		},
		["The Tome of Nobility"] = 4486,
		["Cyclonian"] = 1712,
		["The Summoning"] = 1713,
		["The Windwatcher"] = 1791,
		["Whirlwind Weapon"] = 1792,
		["Elemental Mastery"] = 8410,
		["Spirit Totem"] = 8412,
		["Da Voodoo"] = 8413,
		["The Test of Righteousness"] = 	{
			["Jordan Stilwell"] = 		{
				["Good day, $N. The Light is with you, I trust? What's that? You were sent by Duthorian!? My wife, how is she? I knew there was one that was sent to protect my wife? Then I thank you again, $N. I couldn't think of a better test of valor than that."] = 1653,
				["This is wonderful! You've gotten all the items. I should have no problem forging you a grand weapon with these. I've actually had the plans for the goods. Thank you, $N. It feels good to have my father's hammer again...and a Kor gem. I never thought I'd see one of these myself."] = 1654,
				["Here it is, $N. A weapon worthy of a champion of the Light such as yourself. I've named it after a great dwarven paladin who and my wife. We owe you a great debt, and the world will be a safer place with one of your skill traveling the land."] = 1806
			}
		},
		["The Islander"] = 1718,
		["The Affray"] = 1719,
		["Bailor's Ore Shipment"] = 1655,
		["The Orb of Soran'ruk"] = 1740,
		["Seeking Strahad"] = 	{
			["Strahad Farsan"] = 		{
				["$N? Ah, of course. Our latest prodigy. The real thing can not live up to the legend, I am afraid.  No matter, you have come not live up to the legend, I am afraid.  No matter, you have come here to learn, not to hear me make jokes to myself."] = 1798,
				["A busy day in Ratchet, isn't it? How I enjoy watching the toil of a port city. So much mystery, so much adventure... so much So much mystery, so much adventure... so much ignorance. Is that hatred I see in your eyes, $N? Good, we will put that to good use."] = 3001
			}
		},
		["Tome of the Cabal"] = 	{
			["Strahad Farsan"] = 1805,
			["Jorah Annison"] = 		{
				["Map making! Pictures, estimations of reality. I have no use for such things. In books, narrative, description! That is where truth lies. I would trade all I would trade all the maps in this store for one book on the rise of necromancy, or a tale of the Dark Lady's triumph."] = 1801,
				["Well well well! What do we have here? This is impressive, $N. I wouldn't have thought it possible, but here it is in my very hands, in my very hands, the complete Tome of the Cabal. Allow me to leaf through its pages for just a moment before you are off again."] = 1803
			},
			["Krom Stoutarm"] = 		{
				["Tome of Cabal? Hmm...sounds familiar. I have never seen it here before, though--and believe me, I remember every book I read.  Hmm... Ah, yes! I have seen it here before, though--and believe me, I remember every book I read.  Hmm... Ah, yes! I have seen reference to it in library cataloging books."] = 1758,
				["Fantastic! Now I may join the ranks of the few that have spied its contents. I can't wait to further peruse this text. This is a If you will just allow me to glance at it before you leave. I'm sure that Strahad will be willing to send me a copy."] = 1802
			}
		},
		["In Search of Menara Voidrender"] = 	{
			["Menara Voidrender"] = 		{
				["Ah, Briarthorn sent you. Good. Then word does reach far enough to find future students. This pleases me. It is typical of our kind, $N, to control them properly. I feel you've learned a great many things, and if you are willing, I would help you create tools to compliment your skills."] = 4736,
				["Ah, Zevrost sent you. Good. Then word does reach far enough to find future students. This pleases me. It is typical of our kind, $N, to control them properly. I feel you've learned a great many things, and if you are willing, I would help you create tools to compliment your skills."] = 4737,
				["Ah, Demisette sent you. Good. Then word does reach far enough to find future students. This pleases me. It is typical of our kind, $N, to control them properly. I feel you've learned a great many things, and if you are willing, I would help you create tools to compliment your skills."] = 4738,
				["Ah, Kaal sent you. Good. Then word does reach far enough to find future students. This pleases me. It is typical of our kind, $N, to control them properly. I feel you've learned a great many things, and if you are willing, I would help you create tools to compliment your skills."] = 4739
			}
		},
		["The Completed Robe"] = 4786,
		["Shard of a Felhound"] = 4962,
		["Shard of an Infernal"] = 4963,
		["The Completed Orb of Dar'Orahil"] = 4964,
		["Knowledge of the Orb of Orahil"] = 	{
			["Menara Voidrender"] = 		{
				["Ah, you do seek something more... substantial. That I can help you if you truly are prepared. It's a welcome change to see one of our prepared. It's a welcome change to see one of our kind seeking more power in forms other than just knowledge. So, do you feel you're ready, $N?"] = 4968,
				["Ah, you do seek something more... substantial. I can help you if you truly are prepared. It's a welcome change to see one of our kind prepared. It's a welcome change to see one of our kind seeking more power in forms other than just knowledge. So, do you feel you're ready, $N?"] = 4969
			}
		},
		["The Completed Orb of Noh'Orahil"] = 4975,
		["Returning the Cleansed Orb"] = 4976,
		["Recipe of the Kaldorei"] = 4161,
		["Deep Ocean, Vast Sea"] = 982,
		["Return to Podrig"] = 6324,
		["Speak with Ruga"] = 1823,
		["Trial at the Field of Giants"] = 1824,
		["Ula'elek and the Brutal Gauntlets"] = 1839,
		["Satyr Hooves"] = 1842,
		["Brutal Gauntlets"] = 1843,
		["Orm Stonehoof and the Brutal Helm"] = 1840,
		["Chimaeric Horn"] = 1844,
		["Brutal Helm"] = 1845,
		["Velora Nitely and the Brutal Legguards"] = 1841,
		["Dragonmaw Shinbones"] = 1846,
		["Brutal Legguards"] = 1847,
		["The Shattered Hand"] = 	{
			["Therzok"] = 		{
				["Hmmm, now this is interesting. You've more than proved your worth with this, $N. I am quite impressed. Consider yourself the newest member of the Consider yourself the newest member of the Shattered Hand. And take this, it will be a great help to you in the future, I think."] = 1858,
				["Hm, while I am glad to hear that Tazan is no longer with us, a locked satchel does us no good. We need the information does us no good. We need the information kept within. This should prove a worthy second challenge for one who wishes to join the Shattered Hand."] = 1963
			}
		},
		["Therzok"] = 1859,
		["Mennet Carkad"] = 1885,
		["Fenwick Thatros"] = 1998,
		["Tools of the Trade"] = 1999,
		["Delivery to Andron Gant"] = 3542,
		["Fragments of the Orb of Orahil"] = 1799,
		["Journey to the Marsh"] = 1947,
		["Items of Power"] = 1948,
		["Rituals of Power"] = 1951,
		["Mage's Wand"] = 1952,
		["Return to the Marsh"] = 1953,
		["The Infernal Orb"] = 1954,
		["The Exorcism"] = 1955,
		["Power in Uldaman"] = 1956,
		["Mana Surges"] = 1957,
		["Celestial Power"] = 1958,
		["Tiara of the Deep"] = 2846,
		["Tabetha's Task"] = 2861,
		["Cleansing of the Orb of Orahil"] = 4961,
		["Hidden Secrets"] = 1949,
		["Get the Scoop"] = 1950,
		["The Undermarket"] = 	{
			["Vizzklick"] = 3402,
			["Nilith Lokrav"] = 3385
		},
		["Bingles' Missing Supplies"] = 2038,
		["Find Bingles"] = 2039,
		["Underground Assault"] = 2040,
		["Speak with Shoni"] = 2041,
		["Gyrodrillmatic Excavationators"] = 2928,
		["Gyromast's Revenge"] = 2078,
		["Gyromast's Retrieval"] = 2098,
		["The Manor, Ravenholdt"] = 6681,
		["Junkboxes Needed"] = 8249,
		["Dancing for Marzipan"] = 	{
			["Innkeeper Saelienne"] = 8357,
			["Innkeeper Pala"] = 8360
		},
		["Dolanaar Delivery"] = 2159,
		["Flexing for Nougat"] = 	{
			["Innkeeper Allison"] = 8356,
			["Innkeeper Gryshka"] = 8359
		},
		["New Year Celebrations!"] = 	{
			["Innkeeper Allison"] = 8860,
			["Innkeeper Pala"] = 8861
		},
		["Tracing the Source"] = 	{
			["Innkeeper Allison"] = 9026,
			["Innkeeper Norman"] = 8982,
			["Evert Sorisam"] = 9027,
			["Mara Rennick"] = 8983
		},
		["A Task Unfinished"] = 1656,
		["Syndicate Emblems"] = 6701,
		["A Simple Request"] = 8233,
		["The Azure Key"] = 8236,
		["Supplies to Tannok"] = 2160,
		["The Shattered Necklace"] = 2198,
		["Lore for a Price"] = 2199,
		["Find the Gems"] = 	{
			["Talvash del Kissel"] = 2201,
			["Talvash's Scrying Bowl"] = 2201
		},
		["Restoring the Necklace"] = 	{
			["Talvash del Kissel"] = 		{
				["Well I'll be - I sure am glad to see you and this power source in one piece. It will take me a moment to it is done, however, the necklace will be yours! You're excited, aren't you? All tingly with anticipation? Now where did I put that spell focus at..."] = 2204,
				["I gladly give you this necklace, mighty $c. You have done me an invaluable service, and for that I thank you. Wear it with pride, mention loudly and repeatedly who made it for you! Also, if you could toss in the fact that it really isn't cursed, that would be great."] = 2361
			}
		},
		["Gnome Improvement"] = 2948,
		["Replacement Phial"] = 3375,
		["Incoming Gumdrop"] = 	{
			["Talvash del Kissel"] = 8355,
			["Kali Remik"] = 8358
		},
		["Translating the Journal"] = 	{
			["Jarkal Mossmeld"] = 		{
				["Mighty $c, I know what you are doing out here in the Badlands. I know you seek my gift of tongues. You're after the parts still, let me make you a better offer than Dran Droffers is, and it'll let you still complete your deal with them. Interested now, yes?"] = 2318,
				["You know a good deal when you see one - I knew I could count on you. It will be just a moment while I cast a form you will understand. I am a troll of my word; ask anyone in the Horde about Jarkal Mossmeld. Now, let's get this started..."] = 2338
			}
		},
		["Find the Gems and Power Source"] = 2339,
		["Necklace Recovery, Take 3"] = 2341,
		["Simple Subterfugin'"] = 2238,
		["The Lost Dwarves"] = 2398,
		["Back to Uldaman"] = 2200,
		["Necklace Recovery, Take 2"] = 2284,
		["A Peon's Burden"] = 2161,
		["Ride to Orgrimmar"] = 6384,
		["Erion's Behest"] = 2260,
		["Kingly Shakedown"] = 2298,
		["SI:7"] = 2300,
		["Redridge Rendezvous"] = 2281,
		["Alther's Mill"] = 2282,
		["Ripple Delivery"] = 81,
		["Necklace Recovery"] = 2283,
		["Deliver the Gems"] = 2340,
		["Ripple Recovery"] = 	{
			["Malton Droffers"] = 649,
			["Gilveradin Sunchaser"] = 650
		},
		["Horns of Nez'ra"] = 2358,
		["Rise of the Silithid"] = 	{
			["Zilzibin Drumlore"] = 32,
			["Gracina Spiritmight"] = 		{
				["This report... we night elves know of the terror mentioned here. Fizzledowser was wise to send this, and you, to me. These creatures will consume the are the tools of one of the greatest threats that both the Horde and Alliance face. If only we were smart enough to see that before."] = 162,
				["We night elves know of the terror outlined in this report. Shandris was wise to send this, and you, to me. These creatures will consume Feralas the greatest threats that both the Horde and Alliance will ever face. I pray we will have the resolve to defeat them before they destroy us."] = 4267
			}
		},
		["Zukk'ash Report"] = 7732,
		["Mathias and the Defias"] = 2360,
		["Plundering the Plunderers"] = 2381,
		["Wrenix of Ratchet"] = 2382,
		["The Touch of Zanzil"] = 	{
			["Doc Mixilpixil"] = 		{
				["It's about time! Just put the cheese on the table and skedaddle. Osborne will pay you on the way out. It's about time! Just put the cheese on the table and skedaddle. Osborne will pay you on the way out."] = 2607,
				["Give me a moment to confer with my colleagues, $N. Dr. Montgomery, Mr. Noarm, let us conference! Give me a moment to confer with my colleagues, $N. Dr. Montgomery, Mr. Noarm, let us conference!"] = 2608,
				["What am I doing? What does it look like I'm doing? I'm devising a cure for your 'itis!' Don't get indignant with me now, $N! Just with me now, $N! Just a few more seconds. There! Just spray this, um, fantastic smelling medicine on yourself and you'll be as good as new."] = 2609
			}
		},
		["Deep Cover"] = 2458,
		["The Gordunni Orb"] = 3002,
		["Tears of the Moon"] = 2518,
		["The Temple of the Moon"] = 2519,
		["Sathrah's Sacrifice"] = 2520,
		["The Sleeping Druid"] = 2541,
		["Druid of the Claw"] = 2561,
		["To Serve Kum'isha"] = 2521,
		["Kum'isha's Endeavors"] = 2522,
		["Everything Counts In Large Amounts"] = 3501,
		["One Draenei's Junk..."] = 3502,
		["Rescue OOX-17/TN!"] = 648,
		["Rescue OOX-09/HL!"] = 836,
		["Rescue OOX-22/FE!"] = 2767,
		["Gnome Engineering"] = 	{
			["Oglethorpe Obnoticus"] = 3635,
			["Tinkmaster Overspark"] = 3630
		},
		["Show Your Work"] = 	{
			["Oglethorpe Obnoticus"] = 3643,
			["Tinkmaster Overspark"] = 3641,
			["Nixx Sprocketspring"] = 3639
		},
		["Membership Card Renewal"] = 	{
			["Oglethorpe Obnoticus"] = 3647,
			["Tinkmaster Overspark"] = 3645,
			["Nixx Sprocketspring"] = 3644,
			["Vazario Linkgrease"] = 3646
		},
		["An OOX of Your Own"] = 3721,
		["Secrets of the Colossus - Ashi"] = 8857,
		["Into the Field"] = 243,
		["Slake That Thirst"] = 379,
		["Tanaris Field Sampling"] = 654,
		["Another Power Source?"] = 841,
		["Wastewander Justice"] = 1690,
		["More Wastewander Justice"] = 1691,
		["Divino-matic Rod"] = 2768,
		["WANTED: Caliph Scorpidsting"] = 2781,
		["Water Pouch Bounty"] = 1707,
		["Snickerfang Jowls"] = 2581,
		["Rage of Ages"] = 2582,
		["A Boar's Vitality"] = 2583,
		["Spirit of the Boar"] = 2584,
		["The Decisive Striker"] = 2585,
		["Salt of the Scorpok"] = 2586,
		["The Basilisk's Bite"] = 2601,
		["Infallible Mind"] = 2602,
		["Vulture's Vigor"] = 2603,
		["Spiritual Domination"] = 2604,
		["The Thirsty Goblin"] = 2605,
		["Delivery for Marin"] = 2661,
		["Noggenfogger Elixir"] = 2662,
		["The Swamp Talker"] = 2623,
		["The Stones That Bind Us"] = 2681,
		["The Cover of Darkness"] = 2743,
		["Petty Squabbles"] = 2783,
		["Fall From Grace"] = 2784,
		["A Tale of Sorrow"] = 2801,
		["Return to the Blasted Lands"] = 3626,
		["Uniting the Shattered Amulet"] = 3627,
		["You Are Rakh'likh, Demon"] = 3628,
		["A Troubled Spirit"] = 8417,
		["Warrior Kinship"] = 8423,
		["War on the Shadowsworn"] = 8424,
		["Voodoo Feathers"] = 8425,
		["In Good Taste"] = 2606,
		["Sprinkle's Secret Ingredient"] = 2641,
		["The Disgraced One"] = 2621,
		["The Missing Orders"] = 2622,
		["The Scrimshank Redemption"] = 10,
		["Gadgetzan Water Survey"] = 992,
		["Kirith"] = 2721,
		["Heroes of Old"] = 	{
			["Corporal Thund Splithoof"] = 		{
				["You are temporarily blinded by the sparkle and gleam. You are temporarily blinded by the sparkle and gleam."] = 2701,
				["Indeed, you have honored us all. Our thanks alone are not sufficient. Indeed, you have honored us all. Our thanks alone are not sufficient."] = 2702
			}
		},
		["An Extraordinary Egg"] = 2747,
		["A Fine Egg"] = 2748,
		["An Ordinary Egg"] = 2749,
		["A Bad Egg"] = 2750,
		["The Borrower"] = 2941,
		["The Morrow Stone"] = 2942,
		["Return to Troyas"] = 2943,
		["Wandering Shay"] = 2845,
		["Infiltrating the Castle"] = 2745,
		["Items of Some Consequence"] = 2746,
		["Gahz'ridian"] = 3161,
		["The Sunken Temple"] = 3445,
		["The Stone Circle"] = 3444,
		["To the Top"] = 3567,
		["The Giant Guardian"] = 2844,
		["The Videre Elixir"] = 	{
			["Gregan Brewspewer"] = 4041,
			["Donova Snowden"] = 3909
		},
		["A Visit to Gregan"] = 4142,
		["Dark Heart"] = 3062,
		["Vengeance on the Northspring"] = 3063,
		["The Strength of Corruption"] = 4120,
		["Lethtendris's Web"] = 	{
			["Talo Thornhoof"] = 7489,
			["Latronicus Moonspear"] = 7488
		},
		["Camp Mojache"] = 7492,
		["The Ogres of Feralas"] = 	{
			["Rok Orhan"] = 		{
				["Excellent, $N. In time, the land will heal. We must not give up. Excellent, $N. In time, the land will heal. We must not give up."] = 2975,
				["You have proven yourself to be a trustworthy and dependable ally, $N. You have proven yourself to be a trustworthy and dependable ally, $N."] = 2980
			}
		},
		["The Gordunni Scroll"] = 2978,
		["Dark Ceremony"] = 2979,
		["A Threat in Feralas"] = 2981,
		["The Demon Hunter"] = 2744,
		["Loramus"] = 3141,
		["Breaking the Ward"] = 3508,
		["Azsharite"] = 3602,
		["Find OOX-17/TN!"] = 351,
		["Barbaric Battlements"] = 2751,
		["On Iron Pauldrons"] = 2752,
		["Trampled Under Foot"] = 2753,
		["Horns of Frenzy"] = 2754,
		["Joys of Omosh"] = 2755,
		["The Old Ways"] = 2756,
		["Booty Bay or Bust!"] = 2757,
		["In Search of Galvan"] = 2759,
		["The Origins of Smithing"] = 2758,
		["A Sticky Situation"] = 77,
		["The Mithril Order"] = 2760,
		["Smelt On, Smelt Off"] = 2761,
		["The Great Silver Deceiver"] = 2762,
		["The Art of the Imbue"] = 2763,
		["Expert Blacksmith!"] = 2765,
		["The Formation of Felbane"] = 3621,
		["Enchanted Azsharite Fel Weaponry"] = 3625,
		["Galvan's Finest Pupil"] = 2764,
		["A Good Head On Your Shoulders"] = 2771,
		["The World At Your Feet"] = 2772,
		["The Mithril Kid"] = 2773,
		["Troll Temper"] = 3042,
		["Did You Lose This?"] = 3321,
		["Find OOX-09/HL!"] = 485,
		["Find OOX-22/FE!"] = 2766,
		["Rin'ji's Secret"] = 2782,
		["Lines of Communication"] = 2995,
		["Oran's Gratitude"] = 8273,
		["The Mark of Quality"] = 	{
			["Pratt McGrubben"] = 2821,
			["Jangdor Swiftstrider"] = 2822
		},
		["Wild Leather Armor"] = 	{
			["Pratt McGrubben"] = 2847,
			["Jangdor Swiftstrider"] = 2854
		},
		["Wild Leather Shoulders"] = 	{
			["Pratt McGrubben"] = 2848,
			["Jangdor Swiftstrider"] = 2855
		},
		["Wild Leather Vest"] = 	{
			["Pratt McGrubben"] = 2849,
			["Jangdor Swiftstrider"] = 2856
		},
		["Wild Leather Helmet"] = 	{
			["Pratt McGrubben"] = 2850,
			["Jangdor Swiftstrider"] = 2857
		},
		["Wild Leather Boots"] = 	{
			["Pratt McGrubben"] = 2851,
			["Jangdor Swiftstrider"] = 2858
		},
		["Wild Leather Leggings"] = 	{
			["Pratt McGrubben"] = 2852,
			["Jangdor Swiftstrider"] = 2859
		},
		["Improved Quality"] = 	{
			["Pratt McGrubben"] = 7733,
			["Jangdor Swiftstrider"] = 7734
		},
		["Pristine Yeti Hide"] = 7735,
		["Chief Engineer Scooty"] = 2842,
		["Gnomer-gooooone!"] = 2843,
		["A Fine Mess"] = 2904,
		["Perfect Yeti Hide"] = 7738,
		["Dragonscale Leatherworking"] = 	{
			["Peter Galen"] = 5141,
			["Thorkaf Dragoneye"] = 5145
		},
		["Elemental Leatherworking"] = 	{
			["Sarah Tanner"] = 5144,
			["Brumn Winterhoof"] = 5146
		},
		["Tribal Leatherworking"] = 	{
			["Caryssia Moonhunter"] = 5143,
			["Se'Jib"] = 5148
		},
		["War on the Woodpaw"] = 2862,
		["Alpha Strike"] = 2863,
		["The Battle Plans"] = 2903,
		["Zukk'ash Infestation"] = 7730,
		["Stinglasher"] = 7731,
		["Tran'rek"] = 2864,
		["Scarab Shells"] = 2865,
		["Thistleshrub Valley"] = 3362,
		["Super Sticky"] = 4504,
		["Against the Hatecrest"] = 	{
			["Latronicus Moonspear"] = 		{
				["Yes, yes, these scales are more than satisfactory. Actually, I think I will send these down to Pratt for him to take a look at. is your bounty for the scales. Your continued service to the General and Feathermoon Stronghold at large is a blessing in the face of adversity."] = 2869,
				["Excellent, $N - I value a 'can do' attitude in those who I work with. I've been tasked by General Feathermoon to address the naga in uncover what they are up to in the ruins. With your help, we'll counter the naga presence without sacrificing the general security of the stronghold."] = 3130
			}
		},
		["Against Lord Shalzaru"] = 2870,
		["Feathermoon Stronghold"] = 7494,
		["Delivering the Relic"] = 2871,
		["Jonespyre's Request"] = 3787,
		["The Mystery of Morrowgrain"] = 3791,
		["Morrowgrain to Feathermoon Stronghold"] = 3792,
		["The Knife Revealed"] = 4129,
		["The Missing Courier"] = 	{
			["Ginro Hearthkindle"] = 4124,
			["Wrecked Row Boat"] = 4125
		},
		["Boat Wreckage"] = 4127,
		["Psychometric Reading"] = 4130,
		["Freed from the Hive"] = 4265,
		["Stoley's Debt"] = 2872,
		["Stoley's Shipment"] = 2873,
		["WANTED: Andre Firebeard"] = 2875,
		["Ship Schedules"] = 2876,
		["Southsea Shakedown"] = 8366,
		["Skulk Rock Clean-up"] = 2877,
		["Troll Necklace Bounty"] = 2880,
		["The High Wilderness"] = 2982,
		["In Search of Knowledge"] = 2939,
		["Feralas: A History"] = 2940,
		["The Super Snapper FX"] = 2944,
		["Moontouched Wildkin"] = 978,
		["Handle With Care"] = 3022,
		["Favored of Elune?"] = 3661,
		["Guardians of the Altar"] = 4901,
		["The Grand Betrayal"] = 2929,
		["Save Techbot's Brain!"] = 2922,
		["Tinkmaster Overspark"] = 2923,
		["Data Rescue"] = 2930,
		["Castpipe's Task"] = 2931,
		["Freedom for All Creatures"] = 2969,
		["Doling Justice"] = 	{
			["Jer'kai Moonweaver"] = 2970,
			["Tyrande Whisperwind"] = 2972
		},
		["Reception from Tyrande"] = 1081,
		["Gordunni Cobalt"] = 2987,
		["Thadius Grimshade"] = 2990,
		["Nekrum's Medallion"] = 2991,
		["The Divination"] = 2992,
		["Velinde Starsong"] = 1037,
		["Velinde's Effects"] = 1038,
		["Answered Questions"] = 1044,
		["Return to Witch Doctor Uzer'i"] = 3122,
		["Testing the Vessel"] = 3123,
		["Hippogryph Muisek"] = 3124,
		["Faerie Dragon Muisek"] = 3125,
		["Treant Muisek"] = 3126,
		["Mountain Giant Muisek"] = 3127,
		["Natural Materials"] = 3128,
		["Weapons of Spirit"] = 3129,
		["Clamlette Surprise"] = 6610,
		["To Gadgetzan You Go!"] = 6611,
		["I Know A Guy..."] = 6612,
		["Never Ask Me About My Business"] = 8584,
		["The Isle of Dread!"] = 8585,
		["Dirge's Kickin' Chimaerok Chops"] = 8586,
		["Goblin Engineering"] = 4181,
		["Proof of Deed"] = 3182,
		["Suntara Stones"] = 	{
			["Curator Thorius"] = 3368,
			["Singed Letter"] = 3367
		},
		["Rise, Obsidion!"] = 3566,
		["Ride to Thunder Bluff"] = 6362,
		["Delivery to Archmage Xylem"] = 3561,
		["Sealed Azure Bag"] = 8234,
		["Encoded Fragments"] = 8235,
		["Magic Dust"] = 8251,
		["The Siren's Coral"] = 8252,
		["Destroy Morphaz"] = 8253,
		["Warlord Krellian"] = 9362,
		["Fragmented Magic"] = 9364,
		["A Crew Under Fire"] = 3382,
		["Mura Runetotem"] = 3301,
		["Seeping Corruption"] = 	{
			["Chemist Cuely"] = 		{
				["Wonderful. You're back before she died. Good, good. Let's get started on this then, shall we? I've been studying her symptoms for some time now, and it's three or four times all over the place... quite a pleasant odor. Give me just a moment to put something together to test on our... friend."] = 3568,
				["I never dreamed the elixir would take hold that quickly. Thank you, $N. I will get to work on the rest of these samples right get to work on the rest of these samples right away. I'm sure they'll be usable by the Lady Sylvanas and the Forsaken soon enough."] = 3570
			},
			["Thersa Windsong"] = 3569
		},
		["Arcane Runes"] = 3449,
		["Meeting with the Master"] = 3503,
		["Magecraft"] = 8250,
		["Return Trip"] = 3421,
		["The Jeremiah Blues"] = 5049,
		["The Hunter's Charm"] = 8151,
		["Courser Antlers"] = 8153,
		["Wavethrashing"] = 8231,
		["The Green Drake"] = 8232,
		["Cenarion Aid"] = 8254,
		["Of Coursers We Know"] = 8255,
		["The Ichor of Undeath"] = 8256,
		["A Refugee's Quandary"] = 3361,
		["Dwarven Justice"] = 3371,
		["The Glowing Shard"] = 6981,
		["Kim'jael Indeed!"] = 3601,
		["Kim'jael's 'Missing' Equipment"] = 5534,
		["Shadoweaver"] = 3379,
		["Divine Retribution"] = 3441,
		["The Flawless Flame"] = 3442,
		["Forging the Shaft"] = 3443,
		["The Flame's Casing"] = 3452,
		["The Torch of Retribution"] = 	{
			["Kalaran Windblade"] = 3453,
			["Torch of Retribution"] = 3454
		},
		["Marvon's Workshop"] = 4147,
		["Volcanic Activity"] = 4502,
		["Passing the Burden"] = 3448,
		["Return to Tymor"] = 3461,
		["Squire Maltrake"] = 3462,
		["Set Them Ablaze!"] = 3463,
		["Scourge of the Downs"] = 3523,
		["An Easy Pickup"] = 3450,
		["Signal for Pickup"] = 	{
			["Xiggs Fuselighter"] = 		{
				["Here's my standard issue flare gun, and be patient after you fire off the gun--there are only a couple charges in one of these, and minute to get to you depending on how far out to sea I am. Just look out to sea after you fire off the flare."] = 3451,
				["Ah, another flare gun, huh? That I can do. And don't forget, southern tip of Azshara. It's a small little island that's been turned into a tip of Azshara. It's a small little island that's been turned into a landing pad. You can't miss it if you're in the right spot."] = 3483
			}
		},
		["Screecher Spirits"] = 3520,
		["The Prophecy of Mosh'aru"] = 3527,
		["The God Hakkar"] = 3528,
		["The Ancient Egg"] = 4787,
		["Confront Yeh'kinya"] = 8181,
		["The Runed Scroll"] = 3513,
		["Horde Presence"] = 3514,
		["Report to Kadrak"] = 6541,
		["The Warsong Reports"] = 6543,
		["A Friend in Need"] = 3519,
		["Iverron's Antidote"] = 	{
			["Dirania Silvershine"] = 3521,
			["Iverron"] = 3522
		},
		["A Good Friend"] = 4495,
		["Stealing Knowledge"] = 3517,
		["Magatha's Payment to Jediga"] = 3562,
		["Jes'rimon's Payment to Jediga"] = 3563,
		["Andron's Payment to Jediga"] = 3564,
		["Xylem's Payment to Jediga"] = 3565,
		["In Eranikus' Own Words"] = 3512,
		["Delivery to Jes'rimon"] = 3541,
		["Bone-Bladed Weapons"] = 4300,
		["It's a Secret to Everybody"] = 	{
			["Linken"] = 3845,
			["Donova Snowden"] = 3908,
			["A Small Pack"] = 3844
		},
		["Linken's Sword"] = 3914,
		["Linken's Adventure"] = 3961,
		["It's Dangerous to Go Alone"] = 3962,
		["The Smoldering Ruins of Thaurissan"] = 	{
			["Royal Historian Archesonus"] = 		{
				["Oh my! This information explains quite a lot about Thaurissan. There is much more to learn! Oh my! This information explains quite a lot about Thaurissan. There is much more to learn!"] = 3701,
				["Shall we proceed? Shall we proceed?"] = 3702
			}
		},
		["Dark Iron Legacy"] = 	{
			["Franclorn Forgewright"] = 3801,
			["Monument of Franclorn Forgewright"] = 3802
		},
		["The Royal Rescue"] = 4003,
		["The Fate of the Kingdom"] = 4362,
		["Hilary's Necklace"] = 3741,
		["Researching the Corruption"] = 1275,
		["The Corruption Abroad"] = 3765,
		["Commander Gor'shak"] = 3981,
		["Kharan Mighthammer"] = 4341,
		["Kharan's Tale"] = 4342,
		["Un'Goro Soil"] = 	{
			["Jenal"] = 3764,
			["Ghede"] = 3761
		},
		["KILL ON SIGHT: Dark Iron Dwarves"] = 4081,
		["KILL ON SIGHT: High Ranking Dark Iron Officials"] = 4082,
		["Operation: Death to Angerforge"] = 4132,
		["Warlord's Command"] = 4903,
		["Vivian Lagrave"] = 4133,
		["Lost Thunderbrew Recipe"] = 4134,
		["The Darkstone Tablet"] = 4768,
		["Vivian Lagrave and the Darkstone Tablet"] = 4769,
		["The Last Element"] = 7201,
		["Precarious Predicament"] = 4121,
		["Bijou's Reconnaissance Report"] = 4983,
		["The Pack Mistress"] = 4724,
		["Krom'Grul"] = 3822,
		["Disharmony of Flame"] = 3906,
		["Disharmony of Fire"] = 3907,
		["Morrowgrain to Thunder Bluff"] = 3804,
		["Flute of Xavaric"] = 939,
		["Linken's Memory"] = 3942,
		["Silver Heart"] = 4084,
		["The Corruption of the Jadefire"] = 4421,
		["Felbound Ancients"] = 4441,
		["Purified!"] = 4442,
		["Further Corruption"] = 4906,
		["A Gnome's Assistance"] = 3941,
		["Aquementas"] = 4005,
		["Crystals of Power"] = 4284,
		["The Northern Pylon"] = 4285,
		["The Eastern Pylon"] = 4287,
		["The Western Pylon"] = 4288,
		["Making Sense of It"] = 4321,
		["Larion and Muigin"] = 4145,
		["Zapper Fuel"] = 4146,
		["Bloodpetal Zapper"] = 4148,
		["Muigin and Larion"] = 4141,
		["Haze of Evil"] = 4143,
		["Bloodpetal Sprouts"] = 4144,
		["Dreadmaul Rock"] = 3821,
		["Extinguish the Firegut"] = 3823,
		["Gor'tesh the Brute Lord"] = 3824,
		["Ogre Head On A Stick = Party"] = 3825,
		["FIFTY! YEP!"] = 4283,
		["The Good Stuff"] = 4286,
		["An Orphan Looking For a Home"] = 3841,
		["A Short Incubation"] = 3842,
		["Expedition Salvation"] = 3881,
		["Williden's Journal"] = 3884,
		["Alien Ecology"] = 3883,
		["Roll the Bones"] = 3882,
		["Dadanga is Hungry!"] = 5150,
		["Milly Osworth"] = 3903,
		["Milly's Harvest"] = 3904,
		["The New Springs"] = 980,
		["Strange Sources"] = 4842,
		["Threat of the Winterfall"] = 5082,
		["Winterfall Firewater"] = 5083,
		["Mystery Goo"] = 5085,
		["Toxic Horrors"] = 5086,
		["Winterfall Runners"] = 5087,
		["High Chief Winterfall"] = 5121,
		["The Final Piece"] = 5123,
		["Trouble in Winterspring!"] = 6603,
		["Meet at the Grave"] = 3912,
		["Wenikee Boltbucket"] = 3921,
		["Nugget Slugs"] = 3922,
		["Rilli Greasygob"] = 3923,
		["Samophlange Manual"] = 3924,
		["A Taste of Flame"] = 	{
			["Cyrus Therepentous"] = 		{
				["<Cyrus examines the molt.> You have proven that you are not entirely useless, mortal. <Cyrus examines the molt.> You have proven that you are not entirely useless, mortal."] = 4023,
				["<Cyrus snatches the fiery essence from your hands.> YES! Take your prize and be gone. Leave my sight at once! <Cyrus snatches the fiery essence from your hands.> YES! Take your prize and be gone. Leave my sight at once!"] = 4024
			}
		},
		["The Love Potion"] = 4201,
		["Rocknot's Ale"] = 4295,
		["Lord Banehollow"] = 7623,
		["Ulathek the Traitor"] = 7624,
		["Grark Lorkrub"] = 4122,
		["Cleansing Felwood"] = 	{
			["Arathandris Silversky"] = 4101,
			["Maybess Riverbreeze"] = 4102
		},
		["Salve via Hunting"] = 	{
			["Arathandris Silversky"] = 4103,
			["Maybess Riverbreeze"] = 5882
		},
		["Salve via Mining"] = 	{
			["Arathandris Silversky"] = 4104,
			["Maybess Riverbreeze"] = 5883
		},
		["Salve via Gathering"] = 	{
			["Arathandris Silversky"] = 4105,
			["Maybess Riverbreeze"] = 5884
		},
		["Salve via Skinning"] = 	{
			["Arathandris Silversky"] = 4106,
			["Maybess Riverbreeze"] = 5885
		},
		["Salve via Disenchanting"] = 	{
			["Arathandris Silversky"] = 4107,
			["Maybess Riverbreeze"] = 5886
		},
		["The Heart of the Mountain"] = 4123,
		["Tablet of the Seven"] = 4296,
		["Ribbly Screwspigot"] = 4136,
		["Yuka Screwspigot"] = 4324,
		["Message to Maxwell"] = 5002,
		["Maxwell's Mission"] = 5081,
		["General Drakkisath's Command"] = 5089,
		["General Drakkisath's Demise"] = 5102,
		["Overmaster Pyron"] = 4262,
		["Incendius!"] = 4263,
		["Put Her Down"] = 4701,
		["Mother's Milk"] = 4866,
		["Doomrigger's Clasp"] = 4764,
		["Mayara Brightwing"] = 4766,
		["A Little Slime Goes a Long Way"] = 	{
			["Laris Geardawdle"] = 		{
				["Amazing results, $N! You got close enough to take a sample of the corrupted things, and managed to look no worse for wear! Thank you. the Explorers' Leagues greatest scientists! That'll prove to all the dwarves that it wasn't a mistake to allow us gnomes into Ironforge after the Gnomeregan incident."] = 4512,
				["You've found it? $N, you are a treasure unto yourself. Your dedication and aid has been magnificent and I could not possibly thank you enough. Please, to do, but I'm sure, if you come back at a later time, I'll have need of your services again. Thank you. Thank you so much."] = 4513
			}
		},
		["Chasing A-Me 01"] = 	{
			["Karna Remtravel"] = 4245,
			["A-Me 01"] = 		{
				["As you look A-Me 01 over, you see two huge dents tarnishing what Karna obviously feels is a well-crafted piece of engineering. One dent decorates engineering. One dent decorates A-Me 01's shoulder, the other is on her head. No power seems to be running through her components as you investigate further."] = 4243,
				["You remove the panel from A-Me 01's back yet again and carefully remove the old mithril casing that seems to have burnt out. The new to do, assuming the mithril casing was the problem, is to flip the switch to the 'Off' position, and then back to the 'On' position."] = 4244
			}
		},
		["The Apes of Un'Goro"] = 4289,
		["The Fare of Lar'korwi"] = 4290,
		["The Scent of Lar'korwi"] = 4291,
		["The Bait for Lar'korwi"] = 4292,
		["The Mighty U'cha"] = 4301,
		["Toxic Test"] = 9051,
		["Bloodpetal Poison"] = 9052,
		["A Better Ingredient"] = 9053,
		["Torwa Pathfinder"] = 9063,
		["A Husband's Last Battle"] = 6162,
		["The Newest Member of the Family"] = 3843,
		["Food for Baby"] = 4297,
		["Becoming a Parent"] = 4298,
		["Galgar's Cactus Apple Surprise"] = 4402,
		["Libram of Rumination"] = 4463,
		["Libram of Constitution"] = 4481,
		["Libram of Tenacity"] = 4482,
		["Libram of Resilience"] = 4483,
		["Libram of Voracity"] = 4484,
		["Well of Corruption"] = 4505,
		["Corrupted Sabers"] = 4506,
		["A Strange One"] = 6605,
		["A Little Help From My Friends"] = 4491,
		["Beware of Pterrordax"] = 4501,
		["Shizzle's Flyer"] = 4503,
		["Lost!"] = 4492,
		["Return to Nessa"] = 6343,
		["Nessa Shadowsong"] = 6344,
		["A Sample of Slime..."] = 4293,
		["... and a Batch of Ooze"] = 4294,
		["Melding of Influences"] = 4642,
		["The Champion of the Horde"] = 6567,
		["Ascension..."] = 6601,
		["Blood of the Black Dragon Champion"] = 6602,
		["Fruit of the Sea"] = 1138,
		["The Family and the Fishing Pole"] = 1141,
		["Washed Ashore"] = 	{
			["Gwennyth Bly'Leggonde"] = 		{
				["I hope the murloc did not give you much trouble in collecting this for us! I will be sure to get this on the next some with our thanks. Your success here emboldens me to offer you a chance to aid the Temple of the Moon further, if you are interested..."] = 3524,
				["You've been a tremendous help here today; we now have a solid chance at unlocking the mystery of why these creatures choose to beach themselves but in its infancy. On behalf of the Temple of the Moon, please accept this as thanks for the effort you have given. Thank you, $N!"] = 4681
			}
		},
		["Beached Sea Turtle"] = 	{
			["Gwennyth Bly'Leggonde"] = 		{
				["Another discovery for us to research - well done $N! These remains will be properly studied once they get to Darnassus. Please accept this small will be properly studied once they get to Darnassus. Please accept this small honorarium in exchange for the remains you have provided for our study."] = 4722,
				["I have heard of the kinds of carriages found on the back of the turtle you found. Those I do believe are naga carriages, used Darkshore. I will send this box to Darnassus along with the rest of your discoveries. This is for you - thank you again for your assistance."] = 4725,
				["The bones you have are from gentle sea mammals that are known to inhabit the waters surrounding the base of Teldrassil. They had never been remains will bear the fruits of knowledge that we seek. Again, thank you for your aid. Please accept this honorarium from the Temple of the Moon."] = 4727,
				["I have heard of the kinds of carriages found on the back of that turtle. Those I do believe are naga carriages, used both in be sure to send this box to Darnassus with the rest of your discoveries. This is for you - thank you again for your assistance."] = 4731,
				["You've found even more beached creatures, $N? Sea turtles were commonly found frolicking along the base of Nordrassil before it was destroyed. With the birth some unknown reason. Your aid will perhaps unlock the mystery before us. Please accept this in exchange for the remains you have provided for our study."] = 4732
			}
		},
		["Beached Sea Creature"] = 	{
			["Gwennyth Bly'Leggonde"] = 		{
				["The bones you have are from gentle sea mammals that are known to inhabit the waters surrounding the base of Teldrassil. They had never been remains will bear the fruits of knowledge that we seek. Again, thank you for your aid. Please accept this honorarium from the Temple of the Moon."] = 4730,
				["Ah, I believe you discovered one that was originally being examined by the Explorer's League. They have a presence here in Darkshore, and they had the murlocs. You appear to have succeeded where we both have not. Please - accept this honorarium on behalf of the Temple of the Moon."] = 4728,
				["The dimensions of the thresher you mention are mind-boggling. Even the eldest of the threshers in this region grow to only a fraction of that related to this. While we analyze the bones you have brought us, please accept this on behalf of the Temple of the Moon. Thank you, $N."] = 4733
			}
		},
		["Operative Bijou"] = 4981,
		["Bijou's Belongings"] = 	{
			["Bijou"] = 		{
				["You've done it! Once Lexlort has these plans, he'll forget all about the nasty things he wanted to do to me. $N, you're my hero! You've done it! Once Lexlort has these plans, he'll forget all about the nasty things he wanted to do to me. $N, you're my hero!"] = 4982,
				["Well I'll be! Where were they?? Well I'll be! Where were they??"] = 5001
			}
		},
		["Kibler's Exotic Pets"] = 4729,
		["En-Ay-Es-Tee-Why"] = 4862,
		["Broodling Essence"] = 4726,
		["Egg Freezing"] = 4734,
		["Egg Collection"] = 4735,
		["Return to Tinkee"] = 4810,
		["Tinkee Steamboil"] = 4907,
		["Seal of Ascension"] = 	{
			["Vaelan"] = 		{
				["<Vaelan's image blurs for a moment.> <The pieces that you had collected have disappeared.> The Unforged Seal of Ascension is now ready. It is time for the blurs for a moment.> <The pieces that you had collected have disappeared.> The Unforged Seal of Ascension is now ready. It is time for the final step."] = 4742,
				["Stand steady while I cast the final invocation of protection. <Vaelan's eyes turn to twin orbs of flame.> The Seal of Ascension is complete... Know this, I have some powerful protective wards. In your darkest hour, when all appears to be lost, the might of the red flight will be at your disposal."] = 4743
			}
		},
		["Find Ranshalla"] = 979,
		["Enraged Wildkin"] = 	{
			["Jaron Stoneshaper"] = 		{
				["Well, I expected to hear as much, lad. I figured that the crazed beasts destroyed all of my belongings... But you did find my tools, and most importantly, the amulet! I wonder why the wildkin so fiercely defended this item... In any case, I'll think twice before heading their way again!"] = 4864,
				["Aye, what can I do for you? Aye, what can I do for you?"] = 6604
			},
			["Jaron's Wagon"] = 4863,
			["Damaged Crate"] = 4861
		},
		["The Ruins of Kel'Theril"] = 5244,
		["Finding the Source"] = 974,
		["Ursius of the Shardtooth"] = 5054,
		["Brumeran of the Chillwind"] = 5055,
		["Shy-Rotam"] = 5056,
		["Past Endeavors"] = 5057,
		["Troubled Spirits of Kel'Theril"] = 5245,
		["Fragments of the Past"] = 	{
			["Aurora Skycaller"] = 		{
				["The pages have gone untouched for many many years... The pages have gone untouched for many many years..."] = 5246,
				["Using these elements, I can fuse the fragments together... to hopefully what they once were. Using these elements, I can fuse the fragments together... to hopefully what they once were."] = 5247
			}
		},
		["Are We There, Yeti?"] = 	{
			["Umi Rumplesnicker"] = 		{
				["I can't wait to show my friends! Now, just wait a moment while I attach these... Perfect! I can't wait to show my friends! Now, just wait a moment while I attach these... Perfect!"] = 977,
				["These furs are perfect, $N. We're off to a great start here! These furs are perfect, $N. We're off to a great start here!"] = 3783,
				["Hah! They'll think twice before making fun of my ideas again! Thanks for your help, $N. I couldn't have had so much fun without you! Hah! They'll think twice before making fun of my ideas again! Thanks for your help, $N. I couldn't have had so much fun without you!"] = 5163
			}
		},
		["A Yeti of Your Own"] = 8798,
		["Wild Guardians"] = 	{
			["Trull Failbane"] = 		{
				["This is excellent news, $N. With these beasts out of the way, we can begin to adventure further into Winterspring. Are you ready for more? This is excellent news, $N. With these beasts out of the way, we can begin to adventure further into Winterspring. Are you ready for more?"] = 4521,
				["Hard work is something I have great respect for, $N. Now we can move forward with our plans for Winterspring. Hard work is something I have great respect for, $N. Now we can move forward with our plans for Winterspring."] = 4721,
				["I sense that you are enjoying your work. And I believe that we are onto something here. I sense that you are enjoying your work. And I believe that we are onto something here."] = 4741
			}
		},
		["Luck Be With You"] = 969,
		["Cache of Mau'ari"] = 975,
		["Frostsaber E'ko"] = 4801,
		["Winterfall E'ko"] = 4802,
		["Shardtooth E'ko"] = 4803,
		["Chillwind E'ko"] = 4804,
		["Ice Thistle E'ko"] = 4805,
		["Frostmaul E'ko"] = 4806,
		["Wildkin E'ko"] = 4807,
		["A Little Luck"] = 6606,
		["Emberstrife"] = 6570,
		["The Test of Skulls, Scryer"] = 6582,
		["The Test of Skulls, Somnus"] = 6583,
		["The Test of Skulls, Chronalis"] = 6584,
		["The Test of Skulls, Axtroz"] = 6585,
		["Wind Rider"] = 4767,
		["Homeward Bound"] = 4770,
		["Serpent Wild"] = 4865,
		["Arikara"] = 5088,
		["The Final Tablets"] = 4788,
		["The Lost Tablets of Mosh'aru"] = 5065,
		["Felnok Steelspring"] = 4808,
		["Chillwind Horns"] = 4809,
		["Message to Freewind Post"] = 4542,
		["Pacify the Centaur"] = 4841,
		["Grimtotem Spying"] = 5064,
		["Wanted - Arnak Grimtotem"] = 5147,
		["Alien Egg"] = 4821,
		["A Bundle of Trouble"] = 5545,
		["Frostsaber Provisions"] = 4970,
		["Winterfall Intrusion"] = 5201,
		["Rampaging Giants"] = 5981,
		["Finkle Einhorn, At Your Service!"] = 5047,
		["Cap of the Scarlet Savant"] = 5063,
		["Leggings of Arcana"] = 5067,
		["Breastplate of Bloodthirst"] = 5068,
		["Hot Fiery Death"] = 5103,
		["Fiery Plate Gauntlets"] = 5124,
		["Assassination Plot"] = 4881,
		["Protect Kanati Greycloud"] = 4966,
		["Free at Last"] = 4904,
		["Gordo's Task"] = 5481,
		["Doom Weed"] = 5482,
		["A Matter of Time"] = 4971,
		["Counting Out Time"] = 	{
			["Chromie"] = 		{
				["These are exactly what I need, $N. Thank you. Allow me to suitably reward you with this. You may not understand what you would need with extreme utility and function when consumed. Whether or not you choose to hold on to it until then... this, my friend, is up to you."] = 4972,
				["Again, I thank you for your assistance. Please accept this gift. While you still may not know when to use such an item, perhaps in the future the path of time will reveal its true intentions to you. You could say that I've seen as such happening to you, $N."] = 4973
			}
		},
		["A Strange Historian"] = 5153,
		["The Annals of Darrowshire"] = 5154,
		["Return to Chromie"] = 5941,
		["Tormented By the Past"] = 5248,
		["The Wildlife Suffers Too"] = 	{
			["Mulgris Deepriver"] = 		{
				["I... I sense that the souls of those wolves you have put down now have rest. They - and I - thank you for a you for a merciful release. The wolves are not alone in their suffering within this damnable place, $N. Please, I have need of you once more."] = 4984,
				["'I know that the grizzlies have been put down, their torment at an end. I... I have one more thing for you. I wrote it that, a heavy sigh is uttered by the druid, followed by what sounds like a death rattle. His body lies motionless on the cottage floor."] = 4985
			}
		},
		["Good Luck Charm"] = 5050,
		["Two Halves Become One"] = 5051,
		["Better Late Than Never"] = 	{
			["Royal Overseer Bauhaus"] = 5023,
			["Royal Factor Bathrilor"] = 5022,
			["Janice's Parcel"] = 5021
		},
		["Urok Doomhowl"] = 4867,
		["Alas, Andorhal"] = 	{
			["High Executor Derrington"] = 105,
			["Commander Ashlam Valorfist"] = 211
		},
		["A Call to Arms: The Plaguelands!"] = 	{
			["High Executor Derrington"] = 		{
				["Welcome to the Plaguelands, hero. This is one of the most dangerous frontiers in Azeroth, with the looming threat of the Scourge to our east, are ready to get your hands dirty, then there is plenty for willing and able heroes to do here on the edge of the Plaguelands."] = 5093,
				["Welcome to the Plaguelands, hero. This is one of most dangerous frontiers in Azeroth, with the looming threat of the Scourge to our east, and are ready to get your hands dirty, then there is plenty for willing and able heroes to do here on the edge of the Plaguelands."] = 5094
			},
			["Commander Ashlam Valorfist"] = 		{
				["Welcome to the Plaguelands, hero. This is one of the most dangerous frontiers in Azeroth, especially with the looming threat of the Scourge to our are ready to get your hands dirty, then there is plenty for willing and able heroes to do here on the edge of the Plaguelands."] = 5066,
				["Welcome to the Plaguelands, hero. This is one of most dangerous frontiers in Azeroth, especially with the looming threat of the Scourge to our north are ready to get your hands dirty, then there is plenty for willing and able heroes to do here on the edge of the Plaguelands."] = 5090
			}
		},
		["Scarlet Diversions"] = 5096,
		["All Along the Watchtowers"] = 	{
			["High Executor Derrington"] = 5098,
			["Commander Ashlam Valorfist"] = 5097
		},
		["Mission Accomplished!"] = 	{
			["High Executor Derrington"] = 5238,
			["Commander Ashlam Valorfist"] = 5237
		},
		["Clear the Way"] = 5092,
		["Chillwind Camp"] = 8415,
		["Inert Scourgestones"] = 8416,
		["Forging the Mightstone"] = 8418,
		["Minion's Scourgestones"] = 	{
			["Argent Officer Garush"] = 5402,
			["Argent Officer Pureheart"] = 5408,
			["Duke Nicholas Zverenhoff"] = 5510
		},
		["Invader's Scourgestones"] = 	{
			["Argent Officer Garush"] = 5403,
			["Argent Officer Pureheart"] = 5407,
			["Duke Nicholas Zverenhoff"] = 5509
		},
		["Argent Dawn Commission"] = 	{
			["Argent Officer Garush"] = 5405,
			["Argent Officer Pureheart"] = 5401,
			["Duke Nicholas Zverenhoff"] = 5503
		},
		["Corruptor's Scourgestones"] = 	{
			["Argent Officer Garush"] = 5406,
			["Argent Officer Pureheart"] = 5404,
			["Duke Nicholas Zverenhoff"] = 5508
		},
		["The Everlook Report"] = 	{
			["Argent Officer Garush"] = 6029,
			["Argent Officer Pureheart"] = 6028
		},
		["Mantles of the Dawn"] = 	{
			["Argent Quartermaster Hasana"] = 5504,
			["Argent Quartermaster Lightspark"] = 5507,
			["Quartermaster Miranda Breechlock"] = 5513
		},
		["Chromatic Mantle of the Dawn"] = 	{
			["Argent Quartermaster Hasana"] = 5524,
			["Argent Quartermaster Lightspark"] = 5521,
			["Quartermaster Miranda Breechlock"] = 5517
		},
		["The Medallion of Faith"] = 5122,
		["Aurius' Reckoning"] = 5125,
		["Lorax's Tale"] = 5126,
		["The Demon Forge"] = 5127,
		["Words of the High Chief"] = 5128,
		["Verifying the Corruption"] = 5156,
		["Forces of Jaedenar"] = 5155,
		["Collection of the Corrupt Water"] = 5157,
		["Cleansed Water Returns to Felwood"] = 5159,
		["Dousing the Flames of Protection"] = 5165,
		["A Final Blow"] = 5242,
		["Blood of Morphaz"] = 8257,
		["Little Pamela"] = 5142,
		["Pamela's Doll"] = 5149,
		["Sister Pamela"] = 5601,
		["The Battle of Darrowshire"] = 5721,
		["Auntie Marlene"] = 5152,
		["The Matron Protectorate"] = 5160,
		["Wrath of the Blue Flight"] = 	{
			["Haleh"] = 5161,
			["Jeziba"] = 5162
		},
		["Hypercapacitor Gizmo"] = 5151,
		["Breastplate of the Chromatic Flight"] = 5166,
		["Legplates of the Chromatic Defier"] = 5167,
		["A Strange Red Key"] = 5202,
		["Rescue From Jaedenar"] = 5203,
		["The Remains of Trey Lightforge"] = 5385,
		["Retribution of the Light"] = 5204,
		["Barov Family Fortune"] = 	{
			["Alexi Barov"] = 5341,
			["Weldon Barov"] = 5343
		},
		["The Last Barov"] = 	{
			["Alexi Barov"] = 5342,
			["Weldon Barov"] = 5344
		},
		["The Great Fras Siabi"] = 5214,
		["That's Asking A Lot"] = 6026,
		["When Smokey Sings, I Get Violent"] = 6041,
		["Lord Maxwell Tyrosus"] = 5264,
		["Secrets of the Colossus - Zora"] = 8859,
		["Dawn's Gambit"] = 4771,
		["The Flesh Does Not Lie"] = 5212,
		["The Active Agent"] = 5213,
		["Plagued Hatchlings"] = 5529,
		["Betina Bigglezink"] = 5531,
		["Healthy Dragon Scale"] = 5582,
		["Houses of the Holy"] = 5243,
		["The Dying, Ras Frostwhisper"] = 5462,
		["Menethil's Gift"] = 	{
			["Leonid Barthalomew the Revered"] = 5464,
			["Menethil's Gift"] = 5463
		},
		["Leonid Barthalomew"] = 5522,
		["Zaeldarr the Outcast"] = 6021,
		["The Archivist"] = 5251,
		["The Truth Comes Crashing Down"] = 5262,
		["Above and Beyond"] = 5263,
		["Duke Nicholas Zverenhoff"] = 6030,
		["The Scourge Cauldrons"] = 	{
			["High Priestess MacDonnell"] = 5215,
			["Shadow Priestess Vandis"] = 5228
		},
		["Return to Chillwind Camp"] = 	{
			["High Priestess MacDonnell"] = 		{
				["Well done $N - it should take Alchemist Arbington no time at all to analyze this and devise a counter agent to introduce into the reagents into their mix. Still, if we can keep it up, we will have a huge advantage over Scourge when the time comes for battle!"] = 5217,
				["Ah, there is plenty in here for study. Well done, $N! For now, the next step is in our hands. We'll need to produce a list the reagents into the cauldron directly. Alchemist Arbington will have more information on that, so be sure to speak with him at your earliest convenience."] = 5220,
				["Another finely executed mission, $N! This makes three cauldrons available to us to turn against the Scourge. If Kel'Thuzad's necromantic dominance over these lands wasn't to deliver our counter agent to the plague. With that, the time has come to bring the last cauldron of the west under our influence!"] = 5223,
				["Congratulations $N, you've unlocked the last cauldron for us! Alchemist Arbington will soon know what this cauldron requires as far as reagents needed for the to thank you personally for the assistance you've given us. Without you, our struggle against the Scourge would have been nearly insurmountable. Thank you, hero!"] = 5226
			}
		},
		["Return to the Bulwark"] = 	{
			["Shadow Priestess Vandis"] = 		{
				["Well done $N - it should take Apothecary Dithers no time at all to analyze this and devise a counter agent to introduce into the reagents into their mix. Still, if we can keep it up, we will have a huge advantage over Scourge when the time comes for battle!"] = 5230,
				["Ah, there is plenty in here for study. Well done, $N! For now, the next step is in our hands. We'll need to produce a list the reagents into the cauldron directly. Apothecary Dithers will have more information on that, so be sure to speak with him as soon as possible."] = 5232,
				["Another finely executed mission, $N! This makes three cauldrons available to us to turn against the Scourge. If Kel'Thuzad's necromantic dominance over these lands wasn't to deliver our counter agent to the plague. With that, the time has come to bring the last cauldron of the west under our influence!"] = 5234,
				["Congratulations $N, you've unlocked the last cauldron for us! Apothecary Dithers will soon know what this cauldron requires as far as reagents needed for the you personally for the assistance you've given us. Without you, our struggle against the Scourge would have been nearly insurmountable. I thank you, mighty $c."] = 5236
			}
		},
		["The Key to Scholomance"] = 	{
			["Alchemist Arbington"] = 5505,
			["Apothecary Dithers"] = 5511
		},
		["Scholomance"] = 	{
			["Alchemist Arbington"] = 5533,
			["Apothecary Dithers"] = 838
		},
		["Skeletal Fragments"] = 	{
			["Alchemist Arbington"] = 5537,
			["Apothecary Dithers"] = 964
		},
		["Fire Plume Forged"] = 	{
			["Alchemist Arbington"] = 5801,
			["Apothecary Dithers"] = 5802
		},
		["Araj's Scarab"] = 	{
			["Alchemist Arbington"] = 5803,
			["Apothecary Dithers"] = 5804
		},
		["Heroes of Darrowshire"] = 5168,
		["Villains of Darrowshire"] = 5181,
		["Marauders of Darrowshire"] = 5206,
		["Brother Carlin"] = 5210,
		["Defenders of Darrowshire"] = 5211,
		["Uncle Carlin"] = 5241,
		["To Winterspring!"] = 5249,
		["Starfall"] = 5250,
		["Remorseful Highborne"] = 5252,
		["The Restless Souls"] = 	{
			["Egan"] = 		{
				["Alen has finally found someone brave enough, eh? Alen has finally found someone brave enough, eh?"] = 5281,
				["<Egan wipes a tear from his eye.> Did you see my mother, $N? Did you free her? You are a shining example of decency. For your troubles... <Egan wipes a tear from his eye.> Did you see my mother, $N? Did you free her? You are a shining example of decency. For your troubles..."] = 5282
			}
		},
		["The Way of the Weaponsmith"] = 	{
			["Ironus Coldsteel"] = 5284,
			["Borgosh Corebender"] = 5302
		},
		["Sweet Serenity"] = 5305,
		["Snakestone of the Shadow Huntress"] = 5306,
		["Corruption"] = 5307,
		["Doctor Theolen Krastinov, the Butcher"] = 5382,
		["Kirtonos the Herald"] = 5384,
		["Krastinov's Bag of Horrors"] = 5515,
		["The Sleeper Has Awakened"] = 5321,
		["Family Tree"] = 5361,
		["Catch of the Day"] = 5386,
		["The Human, Ras Frostwhisper"] = 5461,
		["Soulbound Keepsake"] = 5465,
		["The Lich, Ras Frostwhisper"] = 5466,
		["Fish in a Bucket"] = 5421,
		["Lazy Peons"] = 5441,
		["Thazz'ril's Pick"] = 6394,
		["Emphasis on Sacrifice"] = 7637,
		["Bone Collector"] = 5501,
		["Superior Armaments of Battle - Friend of the Dawn"] = 9221,
		["Epic Armaments of Battle - Friend of the Dawn"] = 9222,
		["Superior Armaments of Battle - Honored Amongst the Dawn"] = 9223,
		["Epic Armaments of Battle - Honored Amongst the Dawn"] = 9224,
		["Epic Armaments of Battle - Revered Amongst the Dawn"] = 9225,
		["Superior Armaments of Battle - Revered Amongst the Dawn"] = 9226,
		["Superior Armaments of Battle - Exalted Amongst the Dawn"] = 9227,
		["Epic Armaments of Battle - Exalted Amongst the Dawn"] = 9228,
		["Spiritual Unrest"] = 5535,
		["A Land Filled with Hatred"] = 5536,
		["Timbermaw Ally"] = 8460,
		["Feathers for Grazle"] = 8466,
		["The Root of All Evil"] = 8481,
		["Winterfall Activity"] = 8464,
		["Speak to Salfa"] = 8465,
		["Beads for Salfa"] = 8469,
		["Runecloth"] = 6031,
		["Sacred Cloth"] = 6032,
		["Deadwood Ritual Totem"] = 8470,
		["Winterfall Ritual Totem"] = 8471,
		["Kodo Roundup"] = 5561,
		["Bodyguard for Hire"] = 5821,
		["Gizelton Caravan"] = 5943,
		["Unfinished Business"] = 	{
			["Kirsta Deepshadow"] = 		{
				["Well done, $N. I'm amazed you dealt with them so quickly. Thank you. I have yet to meet anyone that approves of the Scarlet Crusade and Light as much as anyone else in Stormwind, but they've demonstrated that they only want to kill anyone not loyal to their movement... even innocents."] = 6004,
				["Thank you, $N. You've been more help than I could have hoped for. The air here just seems to suck my will. I feel tired, on how strong the Scarlet Crusade's presence is. But that's another matter, before you leave, here, take this... as payment for your help. Thank you again."] = 6023,
				["You've done it, $N! Thank you! I'll return to Elling... I mean Stormwind as soon as I can. Here, take this coin, it's the least I can. Here, take this coin, it's the least I can do for you. You're a credit to your people, $N. Thank you and good luck."] = 6025
			}
		},
		["A Plague Upon Thee"] = 	{
			["Mickey Levine"] = 		{
				["These will do nicely, $N. Thank you. If you're ready, we can get on with the next step. These will do nicely, $N. Thank you. If you're ready, we can get on with the next step."] = 5901,
				["Thank you, $N. Here, take this coin. I'm sorry it's not more, but try to take some joy in helping destroy the Scarlet Crusade's efforts! Thank you, $N. Here, take this coin. I'm sorry it's not more, but try to take some joy in helping destroy the Scarlet Crusade's efforts!"] = 6390
			},
			["Nathaniel Dumah"] = 		{
				["These will do nicely, $N. Thank you. Just look at them... so many of them all huddled up. I almost feel bad for the Crusade, of them all huddled up. I almost feel bad for the Crusade, but then again, it was never their mill to take, now, was it?"] = 5903,
				["Haha! Thank you, $N! You've done it! My father's spirit can now rest and I can live in peace. Thank you again. If there is anything father's spirit can now rest and I can live in peace. Thank you again. If there is anything I can do for you, please, just ask."] = 6389
			},
			["Termite Barrel"] = 5902
		},
		["Hand of Iruxos"] = 5381,
		["Portals of the Legion"] = 5581,
		["Vyletongue Corruption"] = 	{
			["Talendria"] = 7041,
			["Vark Battlescar"] = 7029
		},
		["The Dunemaul Compound"] = 5863,
		["Trial of the Lake"] = 	{
			["Tajarri"] = 		{
				["Well now. it looks like yet another druid has successfully completed the Trial of the Lake! Well done. my young friend - well done. As I've as a lasting tribute to such. By using the bauble here. it serves as a nod to the importance of this place within the Circle."] = 28,
				["Well now. it looks like yet another druid has successfully completed the Trial of the Lake! Well done. my young friend - well done. As I've as a lasting tribute to such. By using the bauble here, it serves as a nod to the importance of this place within the Circle."] = 29
			}
		},
		["Rabine Saturna"] = 	{
			["Rabine Saturna"] = 		{
				["I am Rabine Saturna, and on behalf of Keeper Remulos and all of the denizens of this sacred glade I bid you welcome. I appreciate your Horde is welcomed within the safety of this glade. The preservation of Azeroth is a common goal we both share. You are among friends here, $N."] = 1123,
				["I am Rabine Saturna, and on behalf of Keeper Remulos and all of the denizens of this sacred glade I bid you welcome. I appreciate your for the greater good, and that you will be safe from any ill-conceived repercussions you may be the target of. You are among friends here, $N."] = 6762
			}
		},
		["Shards of the Felvine"] = 5526,
		["A Reliquary of Purity"] = 5527,
		["Uncovering Past Secrets"] = 6845,
		["A Lesson to Learn"] = 27,
		["Trial of the Sea Lion"] = 272,
		["Moonglade"] = 5922,
		["Great Bear Spirit"] = 5930,
		["Lessons Anew"] = 	{
			["Dendrite Starblaze"] = 		{
				["Greetings young $c, I'm glad to see you ready and eager to learn about the curing of poisons. While most druids in the past were put and we are sending you there to aid them. This is no exercise - the work you'll do is quite real. Bear this in mind."] = 6121,
				["Greetings young $c, I'm glad to see you ready and eager to learn about the curing of poisons. While most druids in the past were put so we are sending you there to aid them. This is no exercise - the work you'll do is quite real. Bear this in mind."] = 6126
			}
		},
		["Curing the Sick"] = 	{
			["Dendrite Starblaze"] = 		{
				["You have done well in tending to the sickly deer of Darkshore; they are unwitting victims of a greater taint and corruption that is spreading you in the face, $N. Regardless, you've proven your worth as a friend of nature and the Circle - take this as a symbol of such."] = 6124,
				["You have done well in tending to the sickly gazelles of the Barrens; they are unwitting victims of a greater taint and corruption that is balance transcends artificial racial barriers. $N, you've proven your worth as an friend of nature and the Circle - take this as a symbol of such."] = 6129
			}
		},
		["One Shot.  One Kill."] = 5713,
		["Azuregos's Magical Ledger"] = 8575,
		["Translating the Ledger"] = 8576,
		["Scrying Goggles? No Problem!"] = 8578,
		["Return to Narain"] = 8587,
		["rAnS0m"] = 8598,
		["Love Song for Narain"] = 8599,
		["Decoy!"] = 8606,
		["The Only Prescription"] = 8620,
		["The Good News and The Bad News"] = 8728,
		["Warsong Supplies"] = 6571,
		["Seed of Life"] = 7066,
		["Shrouded in Nightmare"] = 8446,
		["Waking Legends"] = 8447,
		["Tyrande and Remulos"] = 8734,
		["The Nightmare's Corruption"] = 8735,
		["The Nightmare Manifests"] = 8736,
		["Testing an Enemy's Strength"] = 5723,
		["Returning the Lost Satchel"] = 5724,
		["Searching for the Lost Satchel"] = 5722,
		["Protect Kaya"] = 6523,
		["Avenge My Village"] = 6548,
		["Kill Grundig Darkcloud"] = 6629,
		["Harpies Threaten"] = 6282,
		["Bloodfury Bloodline"] = 6283,
		["Arachnophobia"] = 6284,
		["Boulderslide Ravine"] = 6421,
		["Earthen Arise"] = 6481,
		["Elemental War"] = 6393,
		["Sceptre of Light"] = 5741,
		["Book of the Ancients"] = 6027,
		["Cycle of Rebirth"] = 6301,
		["New Life"] = 6381,
		["Kaya's Alive"] = 6401,
		["Find Myranda"] = 5861,
		["Mistress of Deception"] = 6568,
		["Oculus Illusions"] = 6569,
		["The Champion of the Banshee Queen"] = 5961,
		["To Kill With Purpose"] = 6022,
		["Un-Life's Little Annoyances"] = 6042,
		["The Ranger Lord's Behest"] = 6133,
		["Duskwing, Oh How I Hate Thee..."] = 6135,
		["The Corpulent One"] = 6136,
		["The Crimson Courier"] = 6145,
		["Return to Nathanos"] = 6147,
		["The Scarlet Oracle, Demetria"] = 6148,
		["Ramstein"] = 6163,
		["Nathanos' Ruse"] = 6146,
		["Under the Chitin Was..."] = 1185,
		["Umber, Archivist"] = 6844,
		["Welcome!"] = 	{
			["Merissa Stilwell"] = 5805,
			["Yori Crackhelm"] = 5841,
			["Orenthil Whisperwind"] = 5842,
			["Magga"] = 5843,
			["Vorn Skyseer"] = 5844,
			["Claire Willower"] = 5847
		},
		["Clam Bait"] = 6142,
		["Irondeep Supplies"] = 	{
			["Stormpike Quartermaster"] = 5892,
			["Frostwolf Quartermaster"] = 6985
		},
		["Coldtooth Supplies"] = 	{
			["Stormpike Quartermaster"] = 6982,
			["Frostwolf Quartermaster"] = 5893
		},
		["The Quartermaster"] = 7121,
		["Speak with our Quartermaster"] = 7123,
		["Other Fish to Fry"] = 6143,
		["Augustus' Receipt Book"] = 6164,
		["Flint Shadowmore"] = 6184,
		["The Eastern Plagues"] = 6185,
		["Calling in the Reserves"] = 5881,
		["Sharptalon's Claw"] = 2,
		["Ursangous's Paw"] = 23,
		["Shadumbra's Head"] = 24,
		["The Ashenvale Hunt"] = 	{
			["Senani Thunderheart"] = 		{
				["Welcome to the new frontier, $N. Ashenvale is a land of opportunity, one where a young $c like yourself is able to find boundless chances tells me that you've come to learn more about the hunt. Listen close, and I will gladly share with you what you need to know."] = 235,
				["There are three legendary creatures that make up the Ashenvale Hunt; you may seek them and test yourself against their cunning and might. In the are powerful, and you may find that you'll need aid in bringing them down. If you should best them, bring me proof of your deed."] = 6383
			}
		},
		["The Hunt Completed"] = 247,
		["The Lost Pages"] = 6504,
		["Naga at the Zoram Strand"] = 6442,
		["Troll Charm"] = 6462,
		["Satyr Horns"] = 6441,
		["Warsong Saw Blades"] = 6581,
		["Je'neu of the Earthen Ring"] = 824,
		["Trouble in the Deeps"] = 6562,
		["The Essence of Aku'Mai"] = 6563,
		["Allegiance to the Old Gods"] = 	{
			["Je'neu Sancrea"] = 		{
				["This is interesting indeed. I am glad you have brought it to my attention. Now we have a name for our troubles... Lorgus Jett. This is interesting indeed. I am glad you have brought it to my attention. Now we have a name for our troubles... Lorgus Jett."] = 6564,
				["Very good!! Thank you, $N. We may not have stopped the Twilight's Hammer completely, but at least you have staved off another of their plans another of their plans to return the Old Gods to power. Who knows what other plans they have manifesting, but we can rest easy for now."] = 6565
			}
		},
		["Amongst the Ruins"] = 6921,
		["Baron Aquanis"] = 6922,
		["Stonetalon Standstill"] = 25,
		["The Befouled Element"] = 1918,
		["Bring Back the Mug"] = 3365,
		["Between a Rock and a Thistlefur"] = 216,
		["King of the Foulweald"] = 6621,
		["Blood Feeders"] = 6461,
		["Freedom to Ruul"] = 6482,
		["Warsong Scout Update"] = 6547,
		["Warsong Runner Update"] = 6545,
		["Vorsha the Lasher"] = 6641,
		["Warsong Outrider Update"] = 6546,
		["A Host of Evil"] = 6626,
		["Ashenvale Outrunners"] = 6503,
		["Torek's Assault"] = 6544,
		["Nat Pagle, Angler Extreme"] = 6607,
		["You Too Good."] = 6608,
		["I Got Nothin' Left!"] = 6609,
		["Nat's Measuring Tape"] = 8227,
		["Triage"] = 	{
			["Doctor Gregory Victor"] = 6622,
			["Doctor Gustaf VanHowzen"] = 6624
		},
		["Horde Trauma"] = 6623,
		["Alliance Trauma"] = 6625,
		["Favor Amongst the Brotherhood, Dark Iron Ore"] = 6642,
		["Favor Amongst the Brotherhood, Fiery Core"] = 6643,
		["Favor Amongst the Brotherhood, Lava Core"] = 6644,
		["Favor Amongst the Brotherhood, Core Leather"] = 6645,
		["Favor Amongst the Brotherhood, Blood of the Mountain"] = 6646,
		["A Binding Contract"] = 7604,
		["Deeprun Rat Roundup"] = 6661,
		["Me Brother, Nipsy"] = 6662,
		["More Booty!"] = 6741,
		["Enemy Booty"] = 7224,
		["Call of Air - Guse's Fleet"] = 6825,
		["Call of Air - Jeztor's Fleet"] = 6826,
		["Call of Air - Mulverick's Fleet"] = 6827,
		["Wasteland"] = 1124,
		["The Spirits of Southwind"] = 1125,
		["Hive in the Tower"] = 1126,
		["Lokholar the Ice Lord"] = 6801,
		["A Gallon of Blood"] = 7385,
		["More Armor Scraps"] = 6781,
		["Armor Scraps"] = 7223,
		["Poisoned Water"] = 6804,
		["Stormers and Rumblers"] = 6805,
		["Eye of the Emberseer"] = 6821,
		["The Molten Core"] = 6822,
		["Agent of Hydraxis"] = 6823,
		["Hands of the Enemy"] = 6824,
		["Material Assistance"] = 7667,
		["The Darkreaver Menace"] = 8258,
		["You're a Mean One..."] = 	{
			["Kaymard Copperpinch"] = 6983,
			["Wulmort Jinglepocket"] = 7043
		},
		["Metzen the Reindeer"] = 	{
			["Kaymard Copperpinch"] = 8746,
			["Wulmort Jinglepocket"] = 8762
		},
		["Call of Air - Ichman's Fleet"] = 6943,
		["Call of Air - Slidore's Fleet"] = 6942,
		["Call of Air - Vipore's Fleet"] = 6941,
		["Ram Hide Harnesses"] = 7002,
		["Ivus the Forest Lord"] = 6881,
		["Crystal Cluster"] = 7386,
		["Greatfather Winter is Here!"] = 7023,
		["Treats for Greatfather Winter"] = 7025,
		["A Smokywood Pastures' Thank You!"] = 	{
			["Greatfather Winter"] = 7045,
			["Great-father Winter"] = 6984
		},
		["Winter's Presents"] = 	{
			["Greatfather Winter"] = 8827,
			["Great-father Winter"] = 8828
		},
		["Great-father Winter is Here!"] = 7024,
		["Treats for Great-father Winter"] = 6962,
		["Begin the Attack!"] = 6846,
		["Wanted: DWARVES!"] = 7401,
		["Launch the Attack!"] = 6901,
		["Ram Riding Harnesses"] = 7026,
		["Empty Stables"] = 	{
			["Frostwolf Stable Master"] = 7001,
			["Stormpike Stable Master"] = 7027
		},
		["Stolen Winter Veil Treats"] = 	{
			["Strange Snowman"] = 		{
				["Y-y-you can h-h-hear me! Thank the b-b-bottom line! I'm not really a s-s-snowman - my n-n-name is Sacks, and I w-w-work for the Orgrimmar b-b-branch of I g-g-got sent out here to look for a m-m-missing package, when I was attacked by a c-c-creature I have never seen b-b-before! So v-v-very cold..."] = 6963,
				["Y-y-you can h-h-hear me! Thank the b-b-bottom line! I'm not really a s-s-snowman - my n-n-name is Sacks, and I w-w-work for the Ironforge b-b-branch of I g-g-got sent out here to look for a m-m-missing package, when I was attacked by a c-c-creature I have never seen b-b-before! So v-v-very cold..."] = 7042
			}
		},
		["Twisted Evils"] = 7028,
		["Corruption of Earth and Seed"] = 	{
			["Keeper Marandis"] = 7065,
			["Selendra"] = 7064
		},
		["Legends of Maraudon"] = 7044,
		["The Scepter of Celebras"] = 7046,
		["The Pariah's Instructions"] = 7067,
		["The Graveyards of Alterac"] = 7082,
		["Towers and Bunkers"] = 	{
			["Corporal Teeka Bloodsnarl"] = 7101,
			["Sergeant Durgen Stormpike"] = 7102
		},
		["Capture a Mine"] = 	{
			["Corporal Teeka Bloodsnarl"] = 7124,
			["Sergeant Durgen Stormpike"] = 7122
		},
		["Alterac Valley Graveyards"] = 7081,
		["The Battle of Alterac"] = 7141,
		["Hero of the Stormpike"] = 8271,
		["The Battle for Alterac"] = 7142,
		["Hero of the Frostwolf"] = 8272,
		["Proving Grounds"] = 	{
			["Warmaster Laggrond"] = 7161,
			["Lieutenant Haggerdin"] = 7162
		},
		["Rise and Be Recognized"] = 	{
			["Warmaster Laggrond"] = 7163,
			["Lieutenant Haggerdin"] = 7168
		},
		["Honored Amongst the Clan"] = 7164,
		["Earned Reverence"] = 	{
			["Warmaster Laggrond"] = 7165,
			["Lieutenant Haggerdin"] = 7170
		},
		["Legendary Heroes"] = 	{
			["Warmaster Laggrond"] = 7166,
			["Lieutenant Haggerdin"] = 7171
		},
		["The Eye of Command"] = 	{
			["Warmaster Laggrond"] = 7167,
			["Lieutenant Haggerdin"] = 7172
		},
		["In Defense of Frostwolf"] = 7241,
		["Honored Amongst the Guard"] = 7169,
		["The Sovereign Imperative"] = 7261,
		["A Fair Trade"] = 7341,
		["Arrows Are For Sissies"] = 7342,
		["Favor Amongst the Darkspear"] = 7361,
		["Ally of the Tauren"] = 7362,
		["What the Hoof?"] = 7424,
		["Jaina's Autograph"] = 558,
		["Children's Week"] = 	{
			["Human Orphan"] = 1468,
			["Orcish Orphan"] = 172
		},
		["The Bough of the Eternals"] = 1479,
		["The Stonewrought Dam"] = 1558,
		["Spooky Lighthouse"] = 1687,
		["You Scream, I Scream..."] = 	{
			["Human Orphan"] = 4822,
			["Orcish Orphan"] = 915
		},
		["The Gordok Taste Test"] = 5528,
		["Unfinished Gordok Business"] = 7703,
		["The Gordok Ogre Suit"] = 	{
			["Knot Thimblejack"] = 		{
				["Yeah, this will do the trick. Just a slip here, and tuck here... heh - this is going to work out just fine! <A broad using it just before you approach him, and remember... it only will make him think that YOU are an ally - not your group mates!"] = 5518,
				["Here ya go $N - put this thing on, and you'll have ten minutes to do whatever. Good luck! Oh, and if you happen to find to do whatever. Good luck! Oh, and if you happen to find a key to get me out of here, BY ALL MEANS LET ME KNOW!!!"] = 5519
			}
		},
		["Free Knot!"] = 	{
			["Knot Thimblejack"] = 		{
				["You - ranked number one. Everyone else - ranked number two or lower. Oh, thank you for freeing me! I knew my life was destined for number two or lower. Oh, thank you for freeing me! I knew my life was destined for more than just being an appetizer to some ogre!"] = 5525,
				["Oh, thank you for freeing me! You - ranked number one. Everyone else - ranked number two or lower. I knew my life was destined for number one. Everyone else - ranked number two or lower. I knew my life was destined for more than just being an appetizer to some ogre!"] = 7429
			}
		},
		["Examine the Vessel"] = 7785,
		["Thunderaan the Windseeker"] = 7786,
		["Rise, Thunderfury!"] = 7787,
		["Pusillin and the Elder Azj'Tordin"] = 7441,
		["The Madness Within"] = 7461,
		["Arcane Refreshment"] = 7463,
		["Libram of Rapidity"] = 7483,
		["Libram of Focus"] = 7484,
		["Libram of Protection"] = 7485,
		["Enchanted Thorium Platemail: Volume I"] = 7649,
		["Enchanted Thorium Platemail: Volume II"] = 7650,
		["Enchanted Thorium Platemail: Volume III"] = 7651,
		["Elven Legends"] = 	{
			["Sage Korolusk"] = 7481,
			["Scholar Runethorn"] = 7482
		},
		["Holy Bologna: What the Light Won't Tell You"] = 7504,
		["Frost Shock and You"] = 7505,
		["The Emerald Dream..."] = 7506,
		["The Light and How To Swing It"] = 7501,
		["Harnessing Shadows"] = 7502,
		["The Greatest Race of Hunters"] = 7503,
		["Garona: A Study on Stealth and Treachery"] = 7498,
		["Codex of Defense"] = 7499,
		["The Arcanist's Cookbook"] = 7500,
		["Attunement to the Core"] = 7848,
		["The Journey Has Just Begun"] = 	{
			["Overlord Runthak"] = 7493,
			["Major Mattingly"] = 7497
		},
		["Mor'zul Bloodbringer"] = 7562,
		["Rage of Blood"] = 7563,
		["Wildeyes"] = 7564,
		["Xorothian Stardust"] = 7625,
		["Bell of Dethmoora"] = 7626,
		["Wheel of the Black March"] = 7627,
		["Doomsday Candle"] = 7628,
		["Imp Delivery"] = 7629,
		["Arcanite"] = 7630,
		["Down at the Docks"] = 910,
		["Gateway to the Frontier"] = 911,
		["Cairne's Hoofprint"] = 925,
		["Lordaeron Throne Room"] = 1800,
		["A Warden of the Alliance"] = 171,
		["A Warden of the Horde"] = 5502,
		["The Prison's Bindings"] = 7581,
		["The Prison's Casing"] = 7582,
		["Suppression"] = 7583,
		["Kroshius' Infernal Core"] = 7603,
		["What Niby Commands"] = 7601,
		["Flawless Fel Essence"] = 7602,
		["An Imp's Request"] = 8419,
		["Hot and Itchy"] = 8420,
		["The Wrong Stuff"] = 8421,
		["Trolls of a Feather"] = 8422,
		["A Warning"] = 7621,
		["The Balance of Light and Shadow"] = 7622,
		["Dreadsteed of Xoroth"] = 7631,
		["Arena Master"] = 7810,
		["Arena Grandmaster"] = 7838,
		["The Ancient Leaf"] = 	{
			["Vartrus the Ancient"] = 7632,
			["Stoma the Ancient"] = 7632,
			["Hastat the Ancient"] = 7632
		},
		["An Introduction"] = 7633,
		["Stave of the Ancients"] = 7636,
		["A Proper String"] = 7635,
		["Ancient Sinew Wrapped Lamina"] = 7634,
		["Ancient Equine Spirit"] = 7643,
		["A Blue Light Bargain"] = 7652,
		["Imperial Plate Belt"] = 7653,
		["Imperial Plate Boots"] = 7654,
		["Imperial Plate Bracer"] = 7655,
		["Imperial Plate Chest"] = 7656,
		["Imperial Plate Helm"] = 7657,
		["Imperial Plate Leggings"] = 7658,
		["Imperial Plate Shoulders"] = 7659,
		["Judgment and Redemption"] = 7647,
		["What the Flux?"] = 7722,
		["Restoring Fiery Flux Supplies via Kingsblood"] = 7736,
		["Gaining Even More Acceptance"] = 7737,
		["Restoring Fiery Flux Supplies via Iron"] = 8241,
		["Restoring Fiery Flux Supplies via Heavy Leather"] = 8242,
		["Secrets of the Colossus - Regal"] = 8858,
		["STOLEN: Smithing Tuyere and Lookout's Spyglass"] = 7728,
		["JOB OPPORTUNITY: Culling the Competition"] = 7729,
		["Curse These Fat Fingers"] = 7723,
		["Fiery Menace!"] = 7724,
		["Incendosaurs? Whateverosaur is More Like It"] = 7727,
		["Look at the Size of It!"] = 7704,
		["WANTED: Overseer Maltorius"] = 7701,
		["Zapped Giants"] = 7003,
		["Fuel for the Zapping"] = 7721,
		["Again With the Zapped Giants"] = 7725,
		["Refuel for the Zapping"] = 7726,
		["A Donation of Wool"] = 	{
			["Clavicus Knavingham"] = 7791,
			["Mistina Steelshield"] = 7802,
			["Bubulo Acerbus"] = 7807,
			["Rashona Straglash"] = 7826,
			["Vehena"] = 7833,
			["Rumstag Proudstrider"] = 7820,
			["Ralston Farnsley"] = 7813,
			["Dugiru"] = 7792
		},
		["A Donation of Silk"] = 	{
			["Clavicus Knavingham"] = 7793,
			["Mistina Steelshield"] = 7803,
			["Bubulo Acerbus"] = 7808,
			["Rashona Straglash"] = 7827,
			["Vehena"] = 7834,
			["Rumstag Proudstrider"] = 7821,
			["Ralston Farnsley"] = 7814,
			["Dugiru"] = 7798
		},
		["A Donation of Mageweave"] = 	{
			["Clavicus Knavingham"] = 7794,
			["Mistina Steelshield"] = 7804,
			["Bubulo Acerbus"] = 7809,
			["Raedon Duskstriker"] = 7799,
			["Rashona Straglash"] = 7831,
			["Vehena"] = 7835,
			["Rumstag Proudstrider"] = 7822,
			["Ralston Farnsley"] = 7817
		},
		["A Donation of Runecloth"] = 	{
			["Clavicus Knavingham"] = 7795,
			["Mistina Steelshield"] = 7805,
			["Bubulo Acerbus"] = 7811,
			["Raedon Duskstriker"] = 7800,
			["Rashona Straglash"] = 7824,
			["Vehena"] = 7836,
			["Rumstag Proudstrider"] = 7823,
			["Ralston Farnsley"] = 7818
		},
		["Additional Runecloth"] = 	{
			["Clavicus Knavingham"] = 7796,
			["Mistina Steelshield"] = 7806,
			["Bubulo Acerbus"] = 7812,
			["Raedon Duskstriker"] = 7801,
			["Rashona Straglash"] = 7832,
			["Vehena"] = 7837,
			["Rumstag Proudstrider"] = 7825,
			["Ralston Farnsley"] = 7819
		},
		["Lard Lost His Lunch"] = 7840,
		["Return to Primal Torntusk"] = 7847,
		["Dark Vessels"] = 7850,
		["Wanted: Vile Priestess Hexx and Her Minions"] = 7861,
		["Job Opening: Guard Captain of Revantusk Village"] = 7862,
		["Vilebranch Hooligans"] = 7839,
		["Message to the Wildhammer"] = 7841,
		["Another Message to the Wildhammer"] = 7842,
		["The Final Message to the Wildhammer"] = 7843,
		["Cannibalistic Cousins"] = 7844,
		["Snapjaws, Mon!"] = 7815,
		["Gammerita, Mon!"] = 7816,
		["Stalking the Stalkers"] = 7828,
		["Hunt the Savages"] = 7829,
		["Avenging the Fallen"] = 7830,
		["Separation Anxiety"] = 7849,
		["Sentinel Basic Care Package"] = 7863,
		["Sentinel Standard Care Package"] = 7864,
		["Sentinel Advanced Care Package"] = 7865,
		["Outrider Basic Care Package"] = 7866,
		["Outrider Standard Care Package"] = 7867,
		["Outrider Advanced Care Package"] = 7868,
		["Kidnapped Elder Torntusk!"] = 7845,
		["Recover the Key!"] = 7846,
		["The Darkmoon Faire"] = 7926,
		["5 Tickets - Darkmoon Flower"] = 7930,
		["5 Tickets - Minor Darkmoon Prize"] = 7931,
		["12 Tickets - Lesser Darkmoon Prize"] = 7932,
		["40 Tickets - Greater Darkmoon Prize"] = 7933,
		["50 Tickets - Darkmoon Storage Box"] = 7934,
		["10 Tickets - Last Month's Mutton"] = 7935,
		["50 Tickets - Last Year's Mutton"] = 7936,
		["1200 Tickets - Orb of the Darkmoon"] = 7940,
		["1200 Tickets - Amulet of the Darkmoon"] = 7981,
		["Small Furry Paws"] = 7899,
		["Torn Bear Pelts"] = 7900,
		["Soft Bushy Tails"] = 7901,
		["Vibrant Plumes"] = 7902,
		["Evil Bat Eyes"] = 7903,
		["More Bat Eyes"] = 7943,
		["Glowing Scorpid Blood"] = 8222,
		["More Glowing Scorpid Blood"] = 8223,
		["Coarse Weightstone"] = 7889,
		["Heavy Grinding Stone"] = 7890,
		["Green Iron Bracers"] = 7891,
		["Big Black Mace"] = 7892,
		["Rituals of Strength"] = 7893,
		["More Dense Grinding Stones"] = 7939,
		["Carnival Boots"] = 7881,
		["Carnival Jerkins"] = 7882,
		["The World's Largest Gnome!"] = 7883,
		["Crocolisk Boy and the Bearded Murloc"] = 7884,
		["Armor Kits"] = 7885,
		["More Armor Kits"] = 7941,
		["Copper Modulator"] = 7894,
		["Whirring Bronze Gizmo"] = 7895,
		["Green Fireworks"] = 7896,
		["Mechanical Repair Kits"] = 7897,
		["Thorium Widget"] = 7898,
		["More Thorium Widgets"] = 7942,
		["Darkmoon Beast Deck"] = 7907,
		["Darkmoon Portals Deck"] = 7927,
		["Darkmoon Warlords Deck"] = 7928,
		["Darkmoon Elementals Deck"] = 7929,
		["Spawn of Jubjub"] = 7946,
		["The Hand of Rastakhan"] = 8182,
		["The Heart of Hakkar"] = 8183,
		["Strength of Mount Mugamba"] = 	{
			["Jin'rokh the Breaker"] = 		{
				["Hail, $c. I am Jin'rokh the Breaker, troll of Mugamba. We of the Zandalar tribe recognize your accomplishments. We salute your tenacity and strength of will. Wear this talisman around your neck, $c. Let the strength of Mount Mugamba flow through your being. Be empowered as you strike down our enemies!"] = 8041,
				["Our paths will cross again, $c. Our paths will cross again, $c."] = 8042,
				["Use your newfound strength to destroy the Gurubashi! Use your newfound strength to destroy the Gurubashi!"] = 8043
			}
		},
		["The Rage of Mugamba"] = 8044,
		["The Heathen's Brand"] = 	{
			["Jin'rokh the Breaker"] = 		{
				["Know this, heathen: A catastrophe has brought us together. Your pagan ways are neither understood nor appreciated by Zandalar but we are a fair people. warning to our enemies and a symbol of your friendship to Zandalar. Continue to serve our people and I will amplify the power of the brand."] = 8045,
				["Do what you must to defeat our enemies, $c. Even if it means channeling the Light. <Jin'rokh shudders.> Do what you must to defeat our enemies, $c. Even if it means channeling the Light. <Jin'rokh shudders.>"] = 8046,
				["Our beliefs differ but our cause is righteous. Strike down our foes, noble $c. Our beliefs differ but our cause is righteous. Strike down our foes, noble $c."] = 8047
			}
		},
		["The Hero's Brand"] = 8048,
		["Paragons of Power: The Freethinker's Armguards"] = 8053,
		["Paragons of Power: The Freethinker's Belt"] = 8054,
		["Paragons of Power: The Freethinker's Breastplate"] = 8055,
		["Paragons of Power: The Vindicator's Armguards"] = 8058,
		["Paragons of Power: The Vindicator's Belt"] = 8078,
		["Paragons of Power: The Vindicator's Breastplate"] = 8079,
		["The Eye of Zuldazar"] = 	{
			["Al'tabim the All-Seeing"] = 		{
				["Accept this talisman as a token of our appreciation, $c. The Eye of Zuldazar will grow in power as your bond with the trolls of Zandalar of Zuldazar will grow in power as your bond with the trolls of Zandalar strengthens. Return to me periodically and I shall imbue the jewel."] = 8049,
				["Be resolute in your endeavors, $N. The Soulflayer will attempt to siphon your will to live. Be resolute in your endeavors, $N. The Soulflayer will attempt to siphon your will to live."] = 8050,
				["Continue in your battle against the Soulflayer and his minions, $N. He must never be permitted to leave the confines of Zul'Gurub. Continue in your battle against the Soulflayer and his minions, $N. He must never be permitted to leave the confines of Zul'Gurub."] = 8051
			}
		},
		["The All-Seeing Eye of Zuldazar"] = 8052,
		["Paragons of Power: The Demoniac's Wraps"] = 8059,
		["Paragons of Power: The Illusionist's Wraps"] = 8060,
		["Paragons of Power: The Confessor's Wraps"] = 8061,
		["Paragons of Power: The Illusionist's Mantle"] = 8068,
		["Paragons of Power: The Illusionist's Robes"] = 8069,
		["Paragons of Power: The Confessor's Bindings"] = 8070,
		["Paragons of Power: The Confessor's Mantle"] = 8071,
		["Paragons of Power: The Demoniac's Mantle"] = 8076,
		["Paragons of Power: The Demoniac's Robes"] = 8077,
		["The Pebble of Kajaro"] = 	{
			["Al'tabim the All-Seeing"] = 		{
				["$R, the pebble held within the frame of this talisman comes from Mount Kajaro in the South Seas. Mount Kajaro is an area plagued by too shall the power of this pebble. Harness the power of the pebble to strike down our enemies. Be like the mountain: Quick, explosive, deadly..."] = 8101,
				["Be unstoppable, like the molten fronts of Kajaro. Be unstoppable, like the molten fronts of Kajaro."] = 8102,
				["Continue in your decimation of the trolls of Zul'Gurub. Hakkar must see that the world will not buckle beneath his indomitable will. Continue in your decimation of the trolls of Zul'Gurub. Hakkar must see that the world will not buckle beneath his indomitable will."] = 8103
			}
		},
		["The Jewel of Kajaro"] = 8104,
		["Kezan's Taint"] = 	{
			["Al'tabim the All-Seeing"] = 		{
				["Accept this talisman, $c. Accept it and use its power to strike down our mutual enemies. Know that around your neck you carry a piece of capital of the Undermine; but know that before the taint, it held greatness. Still to this day Kezan is considered sacred land to my people."] = 8106,
				["Draw from the darkness, $c. Embrace the shadows. Let Kezan's Taint supplement your dark meddling. Draw from the darkness, $c. Embrace the shadows. Let Kezan's Taint supplement your dark meddling."] = 8107,
				["It is only through our combined efforts that we will stop the Soulflayer. It is only through our combined efforts that we will stop the Soulflayer."] = 8108
			}
		},
		["Kezan's Unstoppable Taint"] = 8109,
		["Paragons of Power: The Augur's Bracers"] = 8056,
		["Paragons of Power: The Haruspex's Bracers"] = 8057,
		["Paragons of Power: The Haruspex's Belt"] = 8064,
		["Paragons of Power: The Haruspex's Tunic"] = 8065,
		["Paragons of Power: The Augur's Belt"] = 8074,
		["Paragons of Power: The Augur's Hauberk"] = 8075,
		["Enchanted South Seas Kelp"] = 	{
			["Maywiki of Zuldazar"] = 		{
				["See this here seaweed, mon? It be from the South Seas. We just add a little mojo and a little magic and it takes on so it be easy, mon. Just wrap it around your neck and think of nature or squirrels or whatever it be that you people like."] = 8110,
				["The neck piece not be for smokin', mon! You got to use it to fight evil. The neck piece not be for smokin', mon! You got to use it to fight evil."] = 8111,
				["Now you take the evil trolls in Zul'Gurub and show them what your nature powers can do, mon! Now you take the evil trolls in Zul'Gurub and show them what your nature powers can do, mon!"] = 8112
			}
		},
		["Pristine Enchanted South Seas Kelp"] = 8113,
		["Vision of Voodress"] = 	{
			["Maywiki of Zuldazar"] = 		{
				["You and Maywiki have something in common, mon. We both be $c! Although, Maywiki is more of a mystic and you be more of a this orb to wear around your neck. Look deep inside and see the village of Voodress in the South Seas! Let it lift your spirits!"] = 8116,
				["Beware the evil Hakkari spirits, mon. Honestly, they be spooky. Beware the evil Hakkari spirits, mon. Honestly, they be spooky."] = 8117,
				["Take a look at it now, $N. Voodress come in even clearer now, yea? Let the primal power flow through you, mon. Take a look at it now, $N. Voodress come in even clearer now, yea? Let the primal power flow through you, mon."] = 8118
			}
		},
		["The Unmarred Vision of Voodress"] = 8119,
		["Paragons of Power: The Predator's Bracers"] = 8062,
		["Paragons of Power: The Madcap's Bracers"] = 8063,
		["Paragons of Power: The Predator's Belt"] = 8066,
		["Paragons of Power: The Predator's Mantle"] = 8067,
		["Paragons of Power: The Madcap's Mantle"] = 8072,
		["Paragons of Power: The Madcap's Tunic"] = 8073,
		["Zandalarian Shadow Talisman"] = 	{
			["Falthir the Sightless"] = 		{
				["You progress swiftly, young $c. Perhaps it is time to initiate you into the Shera Ali'kh - Zandalari for Death's Hand. For thousands of years you and your allies who must assist in vanquishing the Blood God and his minions! Wear this talisman and let it assist you in your journeys."] = 8141,
				["There is only one enhancement left that can be placed on the talisman, $c. When the time is right, I shall apply that enhancement. There is only one enhancement left that can be placed on the talisman, $c. When the time is right, I shall apply that enhancement."] = 8142,
				["An assassin of your caliber should be given a wide berth. Your foes must learn respect! You will get just that when the enemy sees wide berth. Your foes must learn respect! You will get just that when the enemy sees the glint of Death's Hand - all too late..."] = 8143
			}
		},
		["Zandalarian Shadow Mastery Talisman"] = 8144,
		["The Maelstrom's Tendril"] = 	{
			["Falthir the Sightless"] = 		{
				["Amongst the Zandalarians, the profession of $c is revered. Our greatest hunters travel to the edge of the Maelstrom to prove their resolution. From the heart power. I now grant you a single weaving of the Maelstrom's Tendril. As your bond with Zandalar grows, I shall weave more power into the talisman."] = 8145,
				["There is only one more weave that I will be able to add to your talisman, $c There is only one more weave that I will be able to add to your talisman, $c"] = 8146,
				["Let them seek atonement at the end of your munitions. Let them seek atonement at the end of your munitions."] = 8147
			}
		},
		["Maelstrom's Wrath"] = 8148,
		["A Collection of Heads"] = 8201,
		["Essence Mangoes"] = 8196,
		["Zanza's Potent Potables"] = 8243,
		["Signets of the Zandalar"] = 8246,
		["The Battle for Arathi Basin!"] = 	{
			["Field Marshal Oslight"] = 8105,
			["Deathmaster Dwire"] = 8171
		},
		["Control Four Bases"] = 8114,
		["Control Five Bases"] = 8115,
		["More Resource Crates"] = 	{
			["Sergeant Maclear"] = 8298,
			["Deathstalker Mortis"] = 8300
		},
		["Honoring a Hero"] = 	{
			["Wagner Hammerstrike"] = 8149,
			["Javnir Nashak"] = 8150
		},
		["Take Four Bases"] = 8121,
		["Take Five Bases"] = 8122,
		["Presence of Might"] = 8184,
		["Syncretist's Sigil"] = 8185,
		["Death's Embrace"] = 8186,
		["Falcon's Call"] = 8187,
		["Vodouisant's Vigilant Embrace"] = 8188,
		["Presence of Sight"] = 8189,
		["Hoodoo Hex"] = 8190,
		["Prophetic Aura"] = 8191,
		["Animist's Caress"] = 8192,
		["The Savage Guard - Arcanum of Protection"] = 9208,
		["The Savage Guard - Arcanum of Rapidity"] = 9209,
		["The Savage Guard - Arcanum of Focus"] = 9210,
		["Zulian, Razzashi, and Hakkari Coins"] = 8195,
		["Gurubashi, Vilebranch, and Witherbark Coins"] = 8238,
		["Sandfury, Skullsplitter, and Bloodscalp Coins"] = 8239,
		["A Bijou for Zanza"] = 8240,
		["Master Angler"] = 8193,
		["Apprentice Angler"] = 8194,
		["Rare Fish - Keefer's Angelfish"] = 8221,
		["Rare Fish - Dezian Queenfish"] = 8224,
		["Rare Fish - Brownell's Blue Striped Racer"] = 8225,
		["Could I get a Fishing Flier?"] = 	{
			["Grinkle"] = 8229,
			["Barrus"] = 8228
		},
		["Defiler's Basic Care Package"] = 8263,
		["Defiler's Standard Care Package"] = 8264,
		["Defiler's Advanced Care Package"] = 8265,
		["Arathor Basic Care Package"] = 8260,
		["Arathor Standard Care Package"] = 8261,
		["Arathor Advanced Care Package"] = 8262,
		["Pirate Hats Ahoy!"] = 8365,
		["Brann Bronzebeard's Lost Letter"] = 8308,
		["Glyph Chasing"] = 8309,
		["Breaking the Code"] = 8310,
		["Sharing the Knowledge"] = 8313,
		["Kitchen Assistance"] = 8317,
		["Desert Survival Kits"] = 8497,
		["Volunteer's Battlegear"] = 8548,
		["Veteran's Battlegear"] = 8572,
		["Champion's Battlegear"] = 8573,
		["Stalwart's Battlegear"] = 8574,
		["Extraordinary Materials"] = 8783,
		["Cenarion Battlegear"] = 8800,
		["What Tomorrow Brings"] = 8286,
		["Only One May Rise"] = 8288,
		["The Path of the Righteous"] = 8301,
		["The Hand of the Righteous"] = 8302,
		["A Terrible Purpose"] = 8287,
		["Dearest Natalia"] = 8304,
		["Into The Maw of Madness"] = 8306,
		["Twilight Battle Orders"] = 8498,
		["Target: Hive'Ashi Stingers"] = 8501,
		["Target: Hive'Ashi Workers"] = 8502,
		["The Four Dukes"] = 8538,
		["Target: Hive'Zora Hive Sisters"] = 8539,
		["Target: Hive'Zora Tunnelers"] = 8687,
		["Target: Hive'Ashi Defenders"] = 8770,
		["Target: Hive'Ashi Sandstalkers"] = 8771,
		["Target: Hive'Zora Waywatchers"] = 8772,
		["Target: Hive'Zora Reavers"] = 8773,
		["Target: Hive'Regal Ambushers"] = 8774,
		["Target: Hive'Regal Spitfires"] = 8775,
		["Target: Hive'Regal Slavemakers"] = 8776,
		["Target: Hive'Regal Burrowers"] = 8777,
		["The Fall of Ossirian"] = 8791,
		["Wanted - Deathclasp, Terror of the Sands"] = 8283,
		["Boots for the Guard"] = 8540,
		["Grinding Stones for the Guard"] = 8541,
		["The Twilight Mystery"] = 8284,
		["Unraveling the Mystery"] = 8314,
		["The Calling"] = 8315,
		["Armaments of War"] = 8382,
		["Scrying Materials"] = 	{
			["Geologist Larksbane"] = 		{
				["Why, yes... these will be of tremendous aid! These materials are awfully hard to come by in the desert, $N. Thank you. Why, yes... these will be of tremendous aid! These materials are awfully hard to come by in the desert, $N. Thank you."] = 8779,
				["Why, yes... these will be of tremendous aid! These materials are awfully hard to come by in the desert, $n. Thank you. Why, yes... these will be of tremendous aid! These materials are awfully hard to come by in the desert, $n. Thank you."] = 8807
			}
		},
		["Deadly Desert Venom"] = 8277,
		["Noggle's Last Hope"] = 8278,
		["Noggle's Lost Satchel"] = 8282,
		["Taking Back Silithus"] = 8275,
		["Securing the Supply Lines"] = 8280,
		["Stepping Up Security"] = 8281,
		["Bandages for the Field"] = 8496,
		["Hive'Zora Scout Report"] = 8534,
		["Hive'Regal Scout Report"] = 8738,
		["Hive'Ashi Scout Report"] = 8739,
		["Twilight Marauders"] = 8740,
		["Uniform Supplies"] = 8782,
		["Anachronos"] = 8303,
		["A Pawn on the Eternal Board"] = 8519,
		["The Charge of the Dragonflights"] = 8555,
		["The Wrath of Neptulon"] = 8729,
		["Nefarius's Corruption"] = 8730,
		["The Champion Returns"] = 8741,
		["The Might of Kalimdor"] = 8742,
		["The Path of the Protector"] = 	{
			["Anachronos"] = 		{
				["Impressive, little one. You have gone through much trouble to gain the favor of the Bronze Flight. Your dedication is noted. The signet ring of the offer superior protection against the forces of evil. Be warned, once you have chosen your path, you will have no recourse should you change your mind."] = 8747,
				["Your rise amongst the rank of the Brood is most impressive, $N. May you never stray from the path of the protector! Your rise amongst the rank of the Brood is most impressive, $N. May you never stray from the path of the protector!"] = 8748
			}
		},
		["The Protector of Kalimdor"] = 8751,
		["The Path of the Conqueror"] = 	{
			["Anachronos"] = 		{
				["Impressive, little one. You have gone through much trouble to gain the favor of the Bronze Flight. Your dedication is noted. The signet ring of the the conqueror will greatly enhance your physical attacks. Be warned, once you have chosen your path, you will have no recourse should you change your mind."] = 8752,
				["Your rise amongst the rank of the Brood is most impressive, $N. May you never stray from the path of the conqueror! Your rise amongst the rank of the Brood is most impressive, $N. May you never stray from the path of the conqueror!"] = 8753
			}
		},
		["The Qiraji Conqueror"] = 8756,
		["The Path of the Invoker"] = 	{
			["Anachronos"] = 		{
				["Impressive, little one. You have gone through much trouble to gain the favor of the Bronze Flight. Your dedication is noted. The signet ring of the will greatly enhance your magical and natural abilities. Be warned, once you have chosen your path, you will have no recourse should you change your mind."] = 8757,
				["Your rise amongst the rank of the Brood is most impressive, $N. May you never stray from the path of the invoker! Your rise amongst the rank of the Brood is most impressive, $N. May you never stray from the path of the invoker!"] = 8758
			}
		},
		["The Grand Invoker"] = 8761,
		["The Changing of Paths - Protector No More"] = 8764,
		["The Changing of Paths - Invoker No More"] = 8765,
		["The Changing of Paths - Conqueror No More"] = 8766,
		["The Savior of Kalimdor"] = 8802,
		["Frame of Atiesh"] = 9250,
		["Atiesh, the Befouled Greatstaff"] = 9251,
		["The Twilight Lexicon"] = 8279,
		["The Deserter"] = 8285,
		["True Believers"] = 8323,
		["Still Believing"] = 8324,
		["Stinking Up Southshore"] = 1657,
		["Ruined Kegs"] = 8409,
		["Crashing the Wickerman Festival"] = 1658,
		["The Power of Pine"] = 8373,
		["Twilight Geolords"] = 8320,
		["Vyral the Vile"] = 8321,
		["Aurel Goldleaf"] = 8331,
		["Dukes of the Council"] = 8332,
		["Medallion of Station"] = 8333,
		["Lords of the Council"] = 8341,
		["Twilight Ring of Lordship"] = 8342,
		["Goldleaf's Discovery"] = 8343,
		["The Ultimate Deception"] = 8829,
		["A Humble Offering"] = 9248,
		["Secret Communication"] = 8318,
		["Encrypted Twilight Texts"] = 8319,
		["Signet of the Dukes"] = 8348,
		["Bor Wildmane"] = 8349,
		["Bor Wishes to Speak"] = 8351,
		["Scepter of the Council"] = 8352,
		["Abyssal Contacts"] = 8361,
		["Abyssal Crests"] = 8362,
		["Abyssal Signets"] = 8363,
		["Abyssal Scepters"] = 8364,
		["Hoary Templar"] = 8535,
		["Earthen Templar"] = 8536,
		["Crimson Templar"] = 8537,
		["Azure Templar"] = 8737,
		["Hallow's End Treats for Spoops!"] = 8312,
		["Hallow's End Treats for Jesper!"] = 8311,
		["Imperial Qiraji Regalia"] = 8790,
		["C'Thun's Legacy"] = 8801,
		["Imperial Qiraji Armaments"] = 8789,
		["The Alliance Needs Copper Bars!"] = 8492,
		["The Alliance Needs More Copper Bars!"] = 8493,
		["Deadwood of the North"] = 8461,
		["Speak to Nafien"] = 8462,
		["Feathers for Nafien"] = 8467,
		["The Alliance Needs Iron Bars!"] = 8494,
		["The Alliance Needs More Iron Bars!"] = 8495,
		["The Alliance Needs Thorium Bars!"] = 8499,
		["The Alliance Needs More Thorium Bars!"] = 8500,
		["The Alliance Needs Stranglekelp!"] = 8503,
		["The Alliance Needs More Stranglekelp!"] = 8504,
		["The Alliance Needs Purple Lotus!"] = 8505,
		["The Alliance Needs More Purple Lotus!"] = 8506,
		["Field Duty Papers"] = 	{
			["Captain Blackanvil"] = 8508,
			["Krug Skullsplit"] = 8732
		},
		["Armor Kits for the Field"] = 	{
			["Janela Stouthammer"] = 8780,
			["Merok Longstride"] = 8787
		},
		["Arms for the Field"] = 	{
			["Janela Stouthammer"] = 8781,
			["Merok Longstride"] = 8786
		},
		["The Ironforge Brigade Needs Explosives!"] = 8778,
		["The Alliance Needs Arthas' Tears!"] = 8509,
		["The Alliance Needs More Arthas' Tears!"] = 8510,
		["The Alliance Needs Light Leather!"] = 8511,
		["The Alliance Needs More Light Leather!"] = 8512,
		["The Alliance Needs Medium Leather!"] = 8513,
		["The Alliance Needs More Medium Leather!"] = 8514,
		["The Alliance Needs Thick Leather!"] = 8515,
		["The Alliance Needs More Thick Leather!"] = 8516,
		["The Alliance Needs Linen Bandages!"] = 8517,
		["The Alliance Needs More Linen Bandages!"] = 8518,
		["The Alliance Needs Silk Bandages!"] = 8520,
		["The Alliance Needs More Silk Bandages!"] = 8521,
		["The Alliance Needs Runecloth Bandages!"] = 8522,
		["The Alliance Needs More Runecloth Bandages!"] = 8523,
		["The Alliance Needs Rainbow Fin Albacore!"] = 8524,
		["The Alliance Needs More Rainbow Fin Albacore!"] = 8525,
		["The Alliance Needs Roast Raptor!"] = 8526,
		["The Alliance Needs More Roast Raptor!"] = 8527,
		["The Alliance Needs Spotted Yellowtail!"] = 8528,
		["The Alliance Needs More Spotted Yellowtail!"] = 8529,
		["The Horde Needs Copper Bars!"] = 8532,
		["The Horde Needs More Copper Bars!"] = 8533,
		["The Horde Needs Tin Bars!"] = 8542,
		["The Horde Needs More Tin Bars!"] = 8543,
		["The Horde Needs Mithril Bars!"] = 8545,
		["The Horde Needs More Mithril Bars!"] = 8546,
		["The Horde Needs Peacebloom!"] = 8549,
		["The Horde Needs More Peacebloom!"] = 8550,
		["Signet of Unyielding Strength"] = 8556,
		["Ring of Infinite Wisdom"] = 8697,
		["Ring of the Gathering Storm"] = 8698,
		["Band of Vaulted Secrets"] = 8699,
		["Band of Unending Life"] = 8700,
		["Band of Veiled Shadows"] = 8701,
		["Ring of Unspoken Names"] = 8702,
		["Ring of Eternal Justice"] = 8703,
		["Signet of the Unseen Path"] = 8704,
		["Sickle of Unyielding Strength"] = 8558,
		["Gavel of Infinite Wisdom"] = 8705,
		["Hammer of the Gathering Storm"] = 8706,
		["Blade of Vaulted Secrets"] = 8707,
		["Mace of Unending Life"] = 8708,
		["Dagger of Veiled Shadows"] = 8709,
		["Kris of Unspoken Names"] = 8710,
		["Blade of Eternal Justice"] = 8711,
		["Scythe of the Unseen Path"] = 8712,
		["Drape of Unyielding Strength"] = 8557,
		["Shroud of Infinite Wisdom"] = 8689,
		["Cloak of the Gathering Storm"] = 8690,
		["Drape of Vaulted Secrets"] = 8691,
		["Cloak of Unending Life"] = 8692,
		["Cloak of Veiled Shadows"] = 8693,
		["Shroud of Unspoken Names"] = 8694,
		["Cape of Eternal Justice"] = 8695,
		["Cloak of the Unseen Path"] = 8696,
		["Conqueror's Spaulders"] = 8544,
		["Conqueror's Crown"] = 8561,
		["Tiara of the Oracle"] = 8592,
		["Mantle of the Oracle"] = 8594,
		["Stormcaller's Pauldrons"] = 8602,
		["Stormcaller's Diadem"] = 8623,
		["Enigma Shoulderpads"] = 8625,
		["Avenger's Crown"] = 8628,
		["Avenger's Pauldrons"] = 8630,
		["Enigma Circlet"] = 8632,
		["Deathdealer's Helm"] = 8639,
		["Deathdealer's Spaulders"] = 8641,
		["Striker's Diadem"] = 8657,
		["Striker's Pauldrons"] = 8659,
		["Doomcaller's Circlet"] = 8662,
		["Doomcaller's Mantle"] = 8664,
		["Genesis Helm"] = 8667,
		["Genesis Shoulderpads"] = 8669,
		["Secrets of the Qiraji"] = 8784,
		["Conqueror's Greaves"] = 8559,
		["Conqueror's Legguards"] = 8560,
		["Trousers of the Oracle"] = 8593,
		["Mortal Champions"] = 8595,
		["Footwraps of the Oracle"] = 8596,
		["Stormcaller's Footguards"] = 8621,
		["Stormcaller's Leggings"] = 8624,
		["Striker's Footguards"] = 8626,
		["Avenger's Legguards"] = 8629,
		["Enigma Leggings"] = 8631,
		["Enigma Boots"] = 8634,
		["Deathdealer's Boots"] = 8637,
		["Deathdealer's Leggings"] = 8640,
		["Avenger's Greaves"] = 8655,
		["Striker's Leggings"] = 8658,
		["Doomcaller's Footwraps"] = 8660,
		["Doomcaller's Trousers"] = 8663,
		["Genesis Boots"] = 8665,
		["Genesis Trousers"] = 8668,
		["Conqueror's Breastplate"] = 8562,
		["Vestments of the Oracle"] = 8603,
		["Stormcaller's Hauberk"] = 8622,
		["Avenger's Breastplate"] = 8627,
		["Enigma Robes"] = 8633,
		["Deathdealer's Vest"] = 8638,
		["Striker's Hauberk"] = 8656,
		["Doomcaller's Robes"] = 8661,
		["Genesis Vest"] = 8666,
		["The Horde Needs Firebloom!"] = 8580,
		["The Horde Needs More Firebloom!"] = 8581,
		["The Horde Needs Purple Lotus!"] = 8582,
		["The Horde Needs More Purple Lotus!"] = 8583,
		["The Horde Needs Heavy Leather!"] = 8588,
		["The Horde Needs More Heavy Leather!"] = 8589,
		["The Horde Needs Thick Leather!"] = 8590,
		["The Horde Needs More Thick Leather!"] = 8591,
		["The Horde Needs Rugged Leather!"] = 8600,
		["The Horde Needs More Rugged Leather!"] = 8601,
		["The Horde Needs Wool Bandages!"] = 8604,
		["The Horde Needs More Wool Bandages!"] = 8605,
		["The Horde Needs Mageweave Bandages!"] = 8607,
		["The Horde Needs More Mageweave Bandages!"] = 8608,
		["The Horde Needs Runecloth Bandages!"] = 8609,
		["The Horde Needs More Runecloth Bandages!"] = 8610,
		["The Horde Needs Lean Wolf Steaks!"] = 8611,
		["The Horde Needs More Lean Wolf Steaks!"] = 8612,
		["The Horde Needs Spotted Yellowtail!"] = 8613,
		["The Horde Needs More Spotted Yellowtail!"] = 8614,
		["The Horde Needs Baked Salmon!"] = 8615,
		["The Horde Needs More Baked Salmon!"] = 8616,
		["Field Duty"] = 	{
			["Windcaller Kaldon"] = 		{
				["Very well, $N I've prepared a set of tasks that should make optimal use of your skills. With the continued efforts of you and people like you and people like you, our enemy will soon be vanquished once and for all! Should you require a new mission briefing, return to Captain Blackanvil."] = 8507,
				["I can tell that Krug has little use for paperwork. He signed this in silithid blood! Very well, $N. I've prepared a set of tasks that should make good use of your skills as a $c. With the continued efforts of you and people like you, our enemy will soon be crushed!"] = 8731
			}
		},
		["Allegiance to Cenarion Circle"] = 9338,
		["Morndeep the Elder"] = 8619,
		["Splitrock the Elder"] = 8635,
		["Rumblerock the Elder"] = 8636,
		["Silvervein the Elder"] = 8642,
		["Highpeak the Elder"] = 8643,
		["Stonefort the Elder"] = 8644,
		["Obsidian the Elder"] = 8645,
		["Hammershout the Elder"] = 8646,
		["Bellowrage the Elder"] = 8647,
		["Darkcore the Elder"] = 8648,
		["Stormbrow the Elder"] = 8649,
		["Snowcrown the Elder"] = 8650,
		["Ironband the Elder"] = 8651,
		["Graveborn the Elder"] = 8652,
		["Goldwell the Elder"] = 8653,
		["Primestone the Elder"] = 8654,
		["Runetotem the Elder"] = 8670,
		["Ragetotem the Elder"] = 8671,
		["Stonespire the Elder"] = 8672,
		["Bloodhoof the Elder"] = 8673,
		["Winterhoof the Elder"] = 8674,
		["Skychaser the Elder"] = 8675,
		["Wildmane the Elder"] = 8676,
		["Darkhorn the Elder"] = 8677,
		["Wheathoof the Elder"] = 8678,
		["Grimtotem the Elder"] = 8679,
		["Windtotem the Elder"] = 8680,
		["Thunderhorn the Elder"] = 8681,
		["Skyseer the Elder"] = 8682,
		["Dawnstrider the Elder"] = 8683,
		["Dreamseer the Elder"] = 8684,
		["Mistwalker the Elder"] = 8685,
		["High Mountain the Elder"] = 8686,
		["Windrun the Elder"] = 8688,
		["Starsong the Elder"] = 8713,
		["Moonstrike the Elder"] = 8714,
		["Bladeleaf the Elder"] = 8715,
		["Starglade the Elder"] = 8716,
		["Moonwarden the Elder"] = 8717,
		["Bladeswift the Elder"] = 8718,
		["Bladesing the Elder"] = 8719,
		["Skygleam the Elder"] = 8720,
		["Starweave the Elder"] = 8721,
		["Meadowrun the Elder"] = 8722,
		["Nightwind the Elder"] = 8723,
		["Morningdew the Elder"] = 8724,
		["Riversong the Elder"] = 8725,
		["Brightspear the Elder"] = 8726,
		["Farwhisper the Elder"] = 8727,
		["The Orgrimmar Legion Needs Mojo!"] = 8785,
		["Eranikus, Tyrant of the Dream"] = 8733,
		["Treasure of the Timeless One"] = 8745,
		["The Horde Needs Your Help!"] = 8792,
		["Five Signets for War Supplies"] = 	{
			["Warlord Gorchuk"] = 8851,
			["Field Marshal Snowfall"] = 8846
		},
		["Ten Signets for War Supplies"] = 	{
			["Warlord Gorchuk"] = 8852,
			["Field Marshal Snowfall"] = 8847
		},
		["Fifteen Signets for War Supplies"] = 	{
			["Warlord Gorchuk"] = 8853,
			["Field Marshal Snowfall"] = 8848
		},
		["Twenty Signets for War Supplies"] = 	{
			["Warlord Gorchuk"] = 8854,
			["Field Marshal Snowfall"] = 8849
		},
		["Thirty Signets for War Supplies"] = 	{
			["Warlord Gorchuk"] = 8855,
			["Field Marshal Snowfall"] = 8850
		},
		["One Commendation Signet"] = 	{
			["Darnassus Commendation Officer"] = 8811,
			["Gnomeregan Commendation Officer"] = 8812,
			["Ironforge Commendation Officer"] = 8813,
			["Stormwind Commendation Officer"] = 8814,
			["Orgrimmar Commendation Officer"] = 8815,
			["Darkspear Commendation Officer"] = 8816,
			["Undercity Commendation Officer"] = 8842,
			["Thunder Bluff Commendation Officer"] = 8818,
			["Officer Vu'Shalay"] = 8844,
			["Officer Lunalight"] = 8836,
			["Officer Porterhouse"] = 8838,
			["Officer Ironbeard"] = 8834,
			["Officer Redblade"] = 8832,
			["Officer Thunderstrider"] = 8842,
			["Officer Gothena"] = 8840
		},
		["Ten Commendation Signets"] = 	{
			["Darnassus Commendation Officer"] = 8819,
			["Gnomeregan Commendation Officer"] = 8820,
			["Ironforge Commendation Officer"] = 8821,
			["Stormwind Commendation Officer"] = 8822,
			["Orgrimmar Commendation Officer"] = 8823,
			["Darkspear Commendation Officer"] = 8824,
			["Undercity Commendation Officer"] = 8826,
			["Thunder Bluff Commendation Officer"] = 8825,
			["Officer Vu'Shalay"] = 8845,
			["Officer Lunalight"] = 8837,
			["Officer Porterhouse"] = 8839,
			["Officer Ironbeard"] = 8835,
			["Officer Redblade"] = 8833,
			["Officer Thunderstrider"] = 8843,
			["Officer Gothena"] = 8841
		},
		["Elune's Candle"] = 8862,
		["Festival Dumplings"] = 8863,
		["Festive Lunar Dresses"] = 8864,
		["Festive Lunar Pant Suits"] = 8865,
		["Elune's Blessing"] = 8868,
		["Valadar Starsong"] = 8883,
		["Bronzebeard the Elder"] = 8866,
		["Lunar Fireworks"] = 8867,
		["The Lunar Festival"] = 8870,
		["Small Rockets"] = 8876,
		["Firework Launcher"] = 8877,
		["Festive Recipes"] = 8878,
		["Large Rockets"] = 8879,
		["Cluster Rockets"] = 8880,
		["Large Cluster Rockets"] = 8881,
		["Cluster Launcher"] = 8882,
		["Dearest Elenia,"] = 	{
			["Elenia Haydon"] = 		{
				["You wouldn't expect an orc to be so eloquent. Of course, we never really had a chance to know them before now. Thank you for orc to be so eloquent. Of course, we never really had a chance to know them before now. Thank you for bringing this to me."] = 8900,
				["What kind words Temma writes for me. But, as much as his words move me, I cannot consider the love of a tauren. In thoughts, are too different. It is good I do not have to receive these thoughts of his in person. I could not bear to break his heart."] = 8901,
				["This brings back memories from a lifetime ago, $N. Elenia Tor. That was going to be my name, you know. We would have a beautiful to retire to. Simple dreams, then. But if he saw me now, I doubt he'd even see Elenia in me. Only cold flesh and a dead heart..."] = 8902
			}
		},
		["An Earnest Proposition"] = 	{
			["Mokvar"] = 		{
				["Ah, yes. Mux will be quite happy with this. Those bracers were part of a larger armor set. If you're interested in providing me with further of a larger armor set. If you're interested in providing me with further assistance, I'd be willing to consider parting with the rest of it."] = 8920,
				["Ah, yes. Mux will be quite happy with this. Those bindings were part of a larger armor set. If you're interested in providing me with further of a larger armor set. If you're interested in providing me with further assistance, I'd be willing to consider parting with the rest of it."] = 8915,
				["Ah, yes. That old goblin shall be quite happy with this blood. Those bindings were part of a larger armor set. If you're interested in providing of a larger armor set. If you're interested in providing me with further assistance I'd be willing to consider parting with the rest of it."] = 8918
			},
			["Deliana"] = 8912
		},
		["Just Compensation"] = 	{
			["Mokvar"] = 8927,
			["Deliana"] = 8937
		},
		["Anthion's Parting Words"] = 	{
			["Mokvar"] = 9022,
			["Deliana"] = 8959
		},
		["Return to Mokvar"] = 8978,
		["Back to the Beginning"] = 	{
			["Mokvar"] = 8998,
			["Deliana"] = 8997
		},
		["Saving the Best for Last"] = 	{
			["Mokvar"] = 9014,
			["Deliana"] = 9006
		},
		["Return to Deliana"] = 8977,
		["The Ectoplasmic Distiller"] = 8921,
		["A Supernatural Device"] = 	{
			["Mux Manascrambler"] = 		{
				["Excellent! Just as I was running low! You say Deliana sent you? Excellent! Just as I was running low! You say Deliana sent you?"] = 8922,
				["Excellent! Just as I was running low! You say Mokvar sent you? Excellent! Just as I was running low! You say Mokvar sent you?"] = 8923
			}
		},
		["Hunting for Ectoplasm"] = 8924,
		["A Portable Power Source"] = 8925,
		["A Shifty Merchant"] = 8928,
		["In Search of Anthion"] = 	{
			["Anthion Harmon"] = 		{
				["Deliana had you contact me? I'll do my best to help you, but first I must ask a great favor of you. Deliana had you contact me? I'll do my best to help you, but first I must ask a great favor of you."] = 8929,
				["Mokvar had you contact me? I'll do my best to help you, but first I must ask a great favor of you. Mokvar had you contact me? I'll do my best to help you, but first I must ask a great favor of you."] = 8930
			}
		},
		["Proof of Life"] = 8946,
		["Anthion's Strange Request"] = 8947,
		["The Challenge"] = 9015,
		["Dead Man's Plea"] = 8945,
		["Anthion's Old Friend"] = 8948,
		["Falrin's Vendetta"] = 8949,
		["The Instigator's Enchantment"] = 8950,
		["Bodley's Unfortunate Fate"] = 9032,
		["Three Kings of Flame"] = 8961,
		["Components of Importance"] = 	{
			["Bodley"] = 		{
				["A job well done, $N. I will imbue the essence of the remains into the brazier. Now all that is left is to go to the the brazier to summon forth the corrupted spirit of my former cohort, Mor Grayhoof. He cannot rest until the amulet piece is taken from him."] = 8962,
				["A job well done, $N. I will imbue the essence of the relic into the brazier. Now all that is left is to go to the former cohort, Isalien. Her spirit has been corrupted by her possession of the piece of Valthalak's amulet, and the portion of his soul within it."] = 8963,
				["A job well done, $N. I will imbue the essence of the sword into the brazier. Now all that is left is to get into The remains of my former cohorts, Jarien and Sothos. Their souls have been twisted further by their possession of Valthalak's amulet piece and his spirit within."] = 8964,
				["A job well done, $N. I will imbue the essence of the ashes into the brazier. Now all that is left is to get into Scholomance, Kormok. The amulet piece, and Valthalak's spirit within, has corrupted him even further, and he will not rest until you forcibly take it from him."] = 8965
			}
		},
		["The Left Piece of Lord Valthalak's Amulet"] = 	{
			["Bodley"] = 		{
				["You have done a great thing, $N. One spirit rests in peace, but there is still much work to be done before we can put dabbler in the art of divination, so I have another task for you, which is going to enable us to ferret out the final piece."] = 8966,
				["Thank you, $N, for putting Isalien's spirit to rest. Now, perhaps, she will find peace with her goddess. But, there is still a great deal dabbler in the art of divination, so I have another task for you, which is going to enable us to ferret out the final piece."] = 8967,
				["I suppose it's for the best that the souls of those two have finally been put to rest, even if I didn't like them while dabbler in the art of divination, so I have another task for you, which is going to enable us to ferret out the final piece."] = 8968,
				["Good work, $N! Kormok wasn't all that bad for an ogre, at least not while he was still alive, so I hope he gets the dabbler in the art of divination, so I have another task for you, which is going to enable us to ferret out the final piece."] = 8969
			}
		},
		["I See Alcaz Island In Your Future..."] = 8970,
		["More Components of Importance"] = 	{
			["Bodley"] = 		{
				["A job well done, $N. I will imbue the essence of the relic into the brazier. Now all that is left is to go to the the way, I had some leftover bloodkelp from your trip to Alcaz Isle, so I made it into some potions for you. Take your pick!"] = 8985,
				["A job well done, $N. I will imbue the essence of the remains into the brazier. Now all that is left is to go to the the way, I had some leftover bloodkelp from your trip to Alcaz Isle, so I made it into some potions for you. Take your pick!"] = 8986,
				["A job well done, $N. I will imbue the essence of the sword into the brazier. Now all that is left is to get into The the way, I had some leftover bloodkelp from your trip to Alcaz Isle, so I made it into some potions for you. Take your pick!"] = 8987,
				["A job well done, $N. I will imbue the essence of the ashes into the brazier. Now all that is left is to get into Scholomance, the way, I had some leftover bloodkelp from your trip to Alcaz Isle, so I made it into some potions for you. Take your pick!"] = 8988
			}
		},
		["The Right Piece of Lord Valthalak's Amulet"] = 	{
			["Bodley"] = 		{
				["Thank you for helping Mor Grayhoof, $N. Another spirit rests in peace, and we now have the reassembled amulet! But we still have the hardest to be attuned to calling forth Lord Valthalak, there are a few more items that need to be gathered and brought back to me here."] = 8989,
				["Thank you, $N, for putting Isalien's spirit to rest. Now, perhaps, she will find peace with her goddess. And, we have the reassembled amulet, as to be attuned to calling forth Lord Valthalak, there are a few more items that need to be gathered and brought back to me here."] = 8990,
				["I suppose it's for the best that the souls of those two have finally been put to rest, even if I didn't like them while to be attuned to calling forth Lord Valthalak, there are a few more items that need to be gathered and brought back to me here."] = 8991,
				["Good work, $N! Kormok wasn't all that bad for an ogre, at least not while he was still alive, so I hope he gets the to be attuned to calling forth Lord Valthalak, there are a few more items that need to be gathered and brought back to me here."] = 8992
			}
		},
		["Final Preparations"] = 8994,
		["Return to Bodley"] = 8996,
		["Mea Culpa, Lord Valthalak"] = 8995,
		["The Perfect Poison"] = 9023,
		["The Source Revealed"] = 9028,
		["Zinge's Assessment"] = 8980,
		["Binding the Dreadnaught"] = 9131,
		["Dark Iron Scraps"] = 9132,
		["Echoes of War"] = 9033,
		["Redemption Headpiece"] = 9045,
		["The Dread Citadel - Naxxramas"] = 9121,
		["The Elemental Equation"] = 9128,
		["Core of Elements"] = 9129,
		["Bonescythe Digs"] = 9126,
		["Bone Fragments"] = 9127,
		["Cryptstalker Armor Doesn't Make Itself..."] = 9124,
		["Crypt Fiend Parts"] = 9125,
		["The Ice Guard"] = 9211,
		["The Shadow Guard"] = 9213,
		["Savage Flora"] = 9136,
		["Savage Fronds"] = 9137,
		["They Call Me 'The Rooster'"] = 9141,
		["Craftsman's Writ"] = 9142,
		["Writ of Safe Passage"] = 9165,
		["The Forsaken"] = 9327,
		["The Keeper's Call"] = 9247,
		["Letter from the Front"] = 9295,
		["Note from the Front"] = 9299,
		["Page from the Front"] = 9300,
		["Envelope from the Front"] = 9301,
		["Missive from the Front"] = 9302,
		["Document from the Front"] = 9304,
		["Craftsman's Writ - Dense Weightstone"] = 9178,
		["Craftsman's Writ - Imperial Plate Chest"] = 9179,
		["Craftsman's Writ - Volcanic Hammer"] = 9181,
		["Craftsman's Writ - Huge Thorium Battleaxe"] = 9182,
		["Craftsman's Writ - Radiant Circlet"] = 9183,
		["Craftsman's Writ - Wicked Leather Headband"] = 9184,
		["Craftsman's Writ - Rugged Armor Kit"] = 9185,
		["Craftsman's Writ - Wicked Leather Belt"] = 9186,
		["Craftsman's Writ - Runic Leather Pants"] = 9187,
		["Craftsman's Writ - Brightcloth Pants"] = 9188,
		["Craftsman's Writ - Runecloth Boots"] = 9190,
		["Craftsman's Writ - Runecloth Bag"] = 9191,
		["Craftsman's Writ - Runecloth Robe"] = 9194,
		["Craftsman's Writ - Goblin Sapper Charge"] = 9195,
		["Craftsman's Writ - Thorium Grenade"] = 9196,
		["Craftsman's Writ - Gnomish Battle Chicken"] = 9197,
		["Craftsman's Writ - Thorium Tube"] = 9198,
		["Craftsman's Writ - Major Mana Potion"] = 9200,
		["Craftsman's Writ - Greater Arcane Protection Potion"] = 9201,
		["Craftsman's Writ - Major Healing Potion"] = 9202,
		["Craftsman's Writ - Potion of Petrification"] = 9203,
		["Craftsman's Writ - Stonescale Eel"] = 9204,
		["Craftsman's Writ - Plated Armorfish"] = 9205,
		["Craftsman's Writ - Lightning Eel"] = 9206,
		["Chamber of Secrets"] = 12616,
		["Shadows of Doom"] = 9085,
		["Under the Shadow"] = 9153,
		["The Only Song I Know..."] = 9232,
		["Omarion's Handbook"] = 9233,
		["Icebane Gauntlets"] = 9234,
		["Icebane Bracers"] = 9235,
		["Icebane Breastplate"] = 9236,
		["Glacial Cloak"] = 9237,
		["Glacial Wrists"] = 9238,
		["Glacial Gloves"] = 9239,
		["Glacial Vest"] = 9240,
		["Polar Bracers"] = 9241,
		["Polar Gloves"] = 9242,
		["Polar Tunic"] = 9243,
		["Icy Scale Bracers"] = 9244,
		["Icy Scale Gauntlets"] = 9245,
		["Icy Scale Breastplate"] = 9246,
		["Traitor to the Bloodsail"] = 9259,
		["Making Amends"] = 9266,
		["War at Sea"] = 9268,
		["Mending Old Wounds"] = 9267,
		["Investigate the Scourge of Stormwind"] = 9260,
		["Cracked Necrotic Crystal"] = 9292,
		["Investigate the Scourge of Ironforge"] = 9261,
		["Investigate the Scourge of Thunder Bluff"] = 9264,
		["Investigate the Scourge of Orgrimmar"] = 9263,
		["Investigate the Scourge of the Undercity"] = 9265,
		["Faint Necrotic Crystal"] = 9310,
		["Investigate the Scourge of Darnassus"] = 9262,
		["Stealing Orgrimmar's Flame"] = 9324,
		["Stealing Thunder Bluff's Flame"] = 9325,
		["Stealing the Undercity's Flame"] = 9326,
		["A Thief's Reward"] = 	{
			["Festival Loremaster"] = 9365,
			["Festival Talespinner"] = 9339
		},
		["Stealing Stormwind's Flame"] = 9330,
		["Stealing Ironforge's Flame"] = 9331,
		["Stealing Darnassus's Flame"] = 9332,
		["Establishing New Outposts"] = 9664,
		["Bolstering Our Defenses"] = 9665,
		["Report to General Kirika"] = 9416,
		["Scouring the Desert"] = 	{
			["General Kirika"] = 9422,
			["Marshal Bluewall"] = 9419
		},
		["Report to Marshal Bluewall"] = 9415,
		["Bonechewer Blood"] = 10450,
		["Apothecary Zelana"] = 10449,
		["The Orc Report"] = 1219,
		["A Strange Request"] = 3121,
		["The Call to Command"] = 6144,
		["Personal Property"] = 24914,
		["A Watchful Eye"] = 94,
		["Captain Sanders' Hidden Treasure"] = 	{
			["Locked Chest"] = 140,
			["Old Jug"] = 139,
			["Captain's Footlocker"] = 136,
			["Broken Barrel"] = 138
		},
		["Find the Lost Guards"] = 37,
		["Discover Rolf's Fate"] = 45,
		["Sven's Revenge"] = 95,
		["A Daughter's Love"] = 231,
		["Looking Further"] = 248,
		["Search More Hovels"] = 285,
		["Reclaiming Goods"] = 281,
		["Guarded Thunderbrew Barrel"] = 403,
		["Bitter Rivals"] = 310,
		["Bookie Herod"] = 200,
		["The Hidden Key"] = 328,
		["The Dormant Shade"] = 410,
		["Candles of Beckoning"] = 431,
		["The Decrepit Ferry"] = 438,
		["Resting in Pieces"] = 460,
		["Nek'rosh's Gambit"] = 465,
		["Border Crossings"] = 477,
		["The Lost Pilot"] = 419,
		["Bloodscalp Clan Heads"] = 584,
		["Speaking with Nezzliok"] = 585,
		["Speaking with Gan'zulah"] = 586,
		["Enticing Negolash"] = 619,
		["Cortello's Riddle"] = 	{
			["A Soggy Scroll"] = 624,
			["Musty Scroll"] = 625,
			["Cortello's Treasure"] = 626
		},
		["Breaking the Keystone"] = 652,
		["The Princess Trapped"] = 642,
		["Stones of Binding"] = 651,
		["Lightforge Iron"] = 321,
		["Find Agmond"] = 738,
		["Seal of the Earth"] = 779,
		["Flawed Power Stone"] = 926,
		["The Sprouted Fronds"] = 2399,
		["Planting the Heart"] = 941,
		["The Master's Glaive"] = 944,
		["The Twilight Camp"] = 949,
		["Buzzbox 827"] = 983,
		["Buzzbox 411"] = 1001,
		["Buzzbox 323"] = 1002,
		["Buzzbox 525"] = 1003,
		["The Den"] = 1089,
		["Keeping Pace"] = 1190,
		["Until Death Do Us Part"] = 264,
		["Galen's Escape"] = 1393,
		["Digging Through the Dirt"] = 254,
		["Essence of the Exile"] = 1714,
		["The Hidden Niche"] = 461,
		["Lifting the Curse"] = 290,
		["Crystal in the Mountains"] = 635,
		["Summoning the Princess"] = 656,
		["The Super Egg-O-Matic"] = 8893,
		["Rin'ji is Trapped!"] = 2742,
		["The Search Continues"] = 284,
		["The Ruins of Solarsal"] = 2866,
		["Cuergo's Gold"] = 2882,
		["Woodpaw Investigation"] = 2902,
		["Seeing What Happens"] = 2966,
		["The Stone Watcher"] = 2954,
		["Grime-Encrusted Ring"] = 2945,
		["The Sparklematic 5200!"] = 	{
			["The Sparklematic 5200"] = 		{
				["You insert the grime-encrusted item and three silver coins into the Sparklematic 5200. The machine surges to life in a frenzied attempt to purge the churning sounds beat from the heart of the machine. The metal frame of the beast creaks and groans as it lurches from side to side..."] = 2951,
				["As quickly as it started, the Sparklematic 5200 comes to an abrupt halt. A simple 'ding' is heard from the machine, and the mouth of at least the item is now wrapped in a pretty box. Well, there is one way to find out if it cleaned the item or not..."] = 4606,
				["You insert the grime-encrusted item and three silver coins into the Sparklematic 5200. The machine surges to live in an almost frenzied attempt to purge churning sounds beat from the heart of the machine. The metal frame of the beast creaks and groans as it lurches from side to side..."] = 4601,
				["This contraption stands out amongst the gnomes holding out against the madness outside the room. A small plaque on the device reads 'The Sparklematic 5200', deposit three silver coins in the coin slot. Give the Sparklematic 5200 a moment for operation, and voila! Your valuables will emerge clean and shiny!'"] = 4602
			}
		},
		["More Sparklematic Action"] = 4604,
		["The Stave of Equinex"] = 2879,
		["Release Them"] = 3372,
		["A Grave Situation"] = 3913,
		["Into the Depths"] = 3446,
		["Secret of the Circle"] = 3447,
		["Trinkets..."] = 3481,
		["Extinguishing the Idol"] = 3525,
		["The Spectral Chalice"] = 4083,
		["Corrupted Night Dragon"] = 4119,
		["Corrupted Songflower"] = 2523,
		["Corrupted Windblossom"] = 996,
		["Corrupted Whipper Root"] = 4117,
		["The Woodpaw Gnolls"] = 4131,
		["The Writhing Deep"] = 4135,
		["Crystal Restore"] = 4381,
		["Crystal Charge"] = 4385,
		["Crystal Ward"] = 4383,
		["Crystal Yield"] = 4384,
		["Crystal Force"] = 4382,
		["Crystal Spire"] = 4386,
		["Caught!"] = 4449,
		["The Key to Freedom"] = 4451,
		["Testing for Corruption - Felwood"] = 4661,
		["Testing for Impurities - Un'Goro Crater"] = 4561,
		["As Water Cascades"] = 4812,
		["Locked Away"] = 	{
			["Locked Cabinet"] = 5060,
			["Outhouse"] = 5059
		},
		["Mrs. Dalson's Diary"] = 5058,
		["Falling to Corruption"] = 5084,
		["Catalogue of the Wayward"] = 5164,
		["The Argent Hold"] = 5265,
		["Target: Felstone Field"] = 	{
			["Scourge Cauldron"] = 		{
				["The key taken from Cauldron Lord Bilemaw is a perfect fit in unlocking the access panel. A foul stench emanates from the opened panel as is a small spigot that the bottle fits well enough under, allowing you to draw a sample for High Priestess MacDonnell back at Chillwind Point."] = 5216,
				["The key taken from Cauldron Lord Bilemaw is a perfect fit in unlocking the access panel, though it disappears after you use it. Still, you is a small spigot that the bottle fits well enough under, allowing you to draw a sample for Shadow Priestess Vandis back at the Bulwark."] = 5229
			}
		},
		["Felstone Field Cauldron"] = 5218,
		["Target: Gahrron's Withering"] = 	{
			["Scourge Cauldron"] = 		{
				["Cauldron Lord Soulwrath's key disintegrates as it touches the lock on the access panel at the base of the cauldron's platform. A slight clanking noise is a small spigot that the bottle fits well enough under, allowing you to draw a sample for High Priestess MacDonnell back at Chillwind Point."] = 5225,
				["Cauldron Lord Soulwrath's key disintegrates as it touches the lock on the access panel at the base of the cauldron's platform. A slight clanking noise is a small spigot that the bottle fits well enough under, allowing you to draw a sample for Shadow Priestess Vandis back at the Bulwark."] = 5235
			}
		},
		["Gahrron's Withering Cauldron"] = 5227,
		["Target: Writhing Haunt"] = 	{
			["Scourge Cauldron"] = 		{
				["The cauldron lord's key unlocks the access panel to this cauldron and then disappears, much like the other keys have for the previous two cauldrons is a small spigot that the bottle fits well enough under, allowing you to draw a sample for High Priestess MacDonnell back at Chillwind Point."] = 5222,
				["The cauldron lord's key unlocks the access panel to this cauldron and then disappears, much like the other keys have for the previous ones you've is a small spigot that the bottle fits well enough under, allowing you to draw a sample for Shadow Priestess Vandis back at the Bulwark."] = 5233
			}
		},
		["Writhing Haunt Cauldron"] = 5224,
		["Target: Dalson's Tears"] = 	{
			["Scourge Cauldron"] = 		{
				["The macabre key found on the cauldron lord easily slides into a keyhole and then disappears, allowing you permanent access to it. Crude, viscous ichors is a small spigot that the bottle fits well enough under, allowing you to draw a sample for High Priestess MacDonnell back at Chillwind Point."] = 5219,
				["The skeletal key found on the cauldron lord easily slides into a keyhole and then disappears, allowing you permanent access to it. Crude, viscous ichors is a small spigot that the bottle fits well enough under, allowing you to draw a sample for Shadow Priestess Vandis back at the Bulwark."] = 5231
			}
		},
		["Dalson's Tears Cauldron"] = 5221,
		["Hidden Treasures"] = 5942,
		["Hameya's Plea"] = 6024,
		["Claim Rackmore's Treasure!"] = 6161,
		["A Broken Trap"] = 1193,
		["The Treasure of the Shen'dralar"] = 7462,
		["A Hero's Reward"] = 7486,
		["Blackhand's Command"] = 7761,
		["Your Fortune Awaits You..."] = 	{
			["Mysterious Deadmines Chest"] = 7938,
			["Mysterious Eastvale Haystack"] = 7937,
			["Mysterious Wailing Caverns Chest"] = 7944,
			["Mysterious Tree Stump"] = 7945
		},
		["Desert Recipe"] = 8307,
		["Rotten Eggs"] = 8322,
		["Long Forgotten Memories"] = 8305,
		["Stewvul, Ex-B.F.F."] = 8577,
		["Draconic for Dummies"] = 8597,
		["The Hero of the Day"] = 8763,
		["A Carefully Wrapped Present"] = 8744,
		["A Gently Shaken Gift"] = 8788,
		["A Gaily Wrapped Present"] = 8768,
		["A Ticking Present"] = 8769,
		["A Festive Gift"] = 8803,
		["Desecrate this Fire!"] = 	{
			["Alliance Bonfire"] = 		{
				["Desecrate the Alliance's Arathi Highlands bonfire! Desecrate the Alliance's Arathi Highlands bonfire!"] = 11732,
				["Desecrate the Alliance's Ashenvale bonfire! Desecrate the Alliance's Ashenvale bonfire!"] = 11734,
				["Desecrate the Alliance's Azuremyst Isle bonfire! Desecrate the Alliance's Azuremyst Isle bonfire!"] = 11735,
				["Desecrate the Alliance's Blade's Edge Mountains bonfire! Desecrate the Alliance's Blade's Edge Mountains bonfire!"] = 11736,
				["Desecrate the Alliance's Blasted Lands bonfire! Desecrate the Alliance's Blasted Lands bonfire!"] = 11737,
				["Desecrate the Alliance's Bloodmyst Isle bonfire! Desecrate the Alliance's Bloodmyst Isle bonfire!"] = 11738,
				["Desecrate the Alliance's Burning Steppes bonfire! Desecrate the Alliance's Burning Steppes bonfire!"] = 11739,
				["Desecrate the Alliance's Darkshore bonfire! Desecrate the Alliance's Darkshore bonfire!"] = 11740,
				["Desecrate the Alliance's Desolace bonfire! Desecrate the Alliance's Desolace bonfire!"] = 11741,
				["Desecrate the Alliance's Dun Morogh bonfire! Desecrate the Alliance's Dun Morogh bonfire!"] = 11742,
				["Desecrate the Alliance's Duskwood bonfire! Desecrate the Alliance's Duskwood bonfire!"] = 11743,
				["Desecrate the Alliance's Dustwallow Marsh bonfire! Desecrate the Alliance's Dustwallow Marsh bonfire!"] = 11744,
				["Desecrate the Alliance's Elywnn Forest bonfire! Desecrate the Alliance's Elywnn Forest bonfire!"] = 11745,
				["Desecrate the Alliance's Feralas bonfire! Desecrate the Alliance's Feralas bonfire!"] = 11746,
				["Desecrate the Alliance's Hellfire Peninsula bonfire! Desecrate the Alliance's Hellfire Peninsula bonfire!"] = 11747,
				["Desecrate the Alliance's Hillsbrad Foothills Bonfire! Desecrate the Alliance's Hillsbrad Foothills Bonfire!"] = 11748,
				["Desecrate the Alliance's Loch Modan bonfire! Desecrate the Alliance's Loch Modan bonfire!"] = 11749,
				["Desecrate the Alliance's Nagrand bonfire! Desecrate the Alliance's Nagrand bonfire!"] = 11750,
				["Desecrate the Alliance's Redridge Mountains bonfire! Desecrate the Alliance's Redridge Mountains bonfire!"] = 11751,
				["Desecrate the Alliance's Shadowmoon Valley bonfire! Desecrate the Alliance's Shadowmoon Valley bonfire!"] = 11752,
				["Desecrate the Alliance's Teldrassil bonfire! Desecrate the Alliance's Teldrassil bonfire!"] = 11753,
				["Desecrate the Alliance's Terokkar Forest bonfire! Desecrate the Alliance's Terokkar Forest bonfire!"] = 11754,
				["Desecrate the Alliance's Hinterlands bonfire! Desecrate the Alliance's Hinterlands bonfire!"] = 11755,
				["Desecrate the Alliance's Western Plaguelands bonfire! Desecrate the Alliance's Western Plaguelands bonfire!"] = 11756,
				["Desecrate the Alliance's Wetlands bonfire! Desecrate the Alliance's Wetlands bonfire!"] = 11757,
				["Desecrate the Alliance's Zangarmarsh bonfire! Desecrate the Alliance's Zangarmarsh bonfire!"] = 11758,
				["Desecrate the Alliance's Netherstorm bonfire! Desecrate the Alliance's Netherstorm bonfire!"] = 11759,
				["Desecrate the Alliance's Silithus bonfire! Desecrate the Alliance's Silithus bonfire!"] = 11760,
				["Desecrate the Alliance's Stranglethorn Vale bonfire! Desecrate the Alliance's Stranglethorn Vale bonfire!"] = 11761,
				["Desecrate the Alliance's Tanaris bonfire! Desecrate the Alliance's Tanaris bonfire!"] = 11762,
				["Desecrate the Alliance's Winterspring bonfire! Desecrate the Alliance's Winterspring bonfire!"] = 11763
			},
			["Horde Bonfire"] = 		{
				["Desecrate the Horde's Arathi Highlands bonfire! Desecrate the Horde's Arathi Highlands bonfire!"] = 11764,
				["Desecrate the Horde's Ashenvale bonfire! Desecrate the Horde's Ashenvale bonfire!"] = 11765,
				["Desecrate the Horde's Netherstorm bonfire! Desecrate the Horde's Netherstorm bonfire!"] = 11799,
				["Desecrate the Horde's Silithus bonfire! Desecrate the Horde's Silithus bonfire!"] = 11800,
				["Desecrate the Horde's Stranglethorn Vale bonfire! Desecrate the Horde's Stranglethorn Vale bonfire!"] = 11801,
				["Desecrate the Horde's Tanaris bonfire! Desecrate the Horde's Tanaris bonfire!"] = 11802,
				["Desecrate the Horde's Winterspring bonfire! Desecrate the Horde's Winterspring bonfire!"] = 11803,
				["Desecrate the Horde's Badlands bonfire! Desecrate the Horde's Badlands bonfire!"] = 11766,
				["Desecrate the Horde's Blade's Edge Mountains bonfire! Desecrate the Horde's Blade's Edge Mountains bonfire!"] = 11767,
				["Desecrate the Horde's Burning Steppes bonfire! Desecrate the Horde's Burning Steppes bonfire!"] = 11768,
				["Desecrate the Horde's Desolace bonfire! Desecrate the Horde's Desolace bonfire!"] = 11769,
				["Desecrate the Horde's Durotar bonfire! Desecrate the Horde's Durotar bonfire!"] = 11770,
				["Desecrate the Horde's Dustwallow Marsh bonfire! Desecrate the Horde's Dustwallow Marsh bonfire!"] = 11771,
				["Desecrate the Horde's Eversong Woods bonfire! Desecrate the Horde's Eversong Woods bonfire!"] = 11772,
				["Desecrate the Horde's Feralas bonfire! Desecrate the Horde's Feralas bonfire!"] = 11773,
				["Desecrate the Horde's Ghostlands bonfire! Desecrate the Horde's Ghostlands bonfire!"] = 11774,
				["Desecrate the Horde's Hellfire Peninsula bonfire! Desecrate the Horde's Hellfire Peninsula bonfire!"] = 11775,
				["Desecrate the Horde's Hillsbrad Foothills Bonfire! Desecrate the Horde's Hillsbrad Foothills Bonfire!"] = 11776,
				["Desecrate the Horde's Mulgore bonfire! Desecrate the Horde's Mulgore bonfire!"] = 11777,
				["Desecrate the Horde's Nagrand bonfire! Desecrate the Horde's Nagrand bonfire!"] = 11778,
				["Desecrate the Horde's Shadowmoon Valley bonfire! Desecrate the Horde's Shadowmoon Valley bonfire!"] = 11779,
				["Desecrate the Horde's Stonetalon Mountains bonfire! Desecrate the Horde's Stonetalon Mountains bonfire!"] = 11780,
				["Desecrate the Horde's Swamp of Sorrows bonfire! Desecrate the Horde's Swamp of Sorrows bonfire!"] = 11781,
				["Desecrate the Horde's Terokkar Forest bonfire! Desecrate the Horde's Terokkar Forest bonfire!"] = 11782,
				["Desecrate the Horde's Barrens bonfire! Desecrate the Horde's Barrens bonfire!"] = 11783,
				["Desecrate the Horde's Hinterlands bonfire! Desecrate the Horde's Hinterlands bonfire!"] = 11784,
				["Desecrate the Horde's Thousand Needles bonfire! Desecrate the Horde's Thousand Needles bonfire!"] = 11785,
				["Desecrate the Horde's Tirisfal Glades bonfire! Desecrate the Horde's Tirisfal Glades bonfire!"] = 11786,
				["Desecrate the Horde's Zangarmarsh bonfire! Desecrate the Horde's Zangarmarsh bonfire!"] = 11787
			}
		},
		["Candy Bucket"] = 12331
	},
	["progress"] = {
		["Wolves Across the Border"] = 33,
		["Kobold Camp Cleanup"] = 7,
		["Investigate Echo Ridge"] = 15,
		["Skirmish at Echo Ridge"] = 21,
		["Glyphic Letter"] = 3104,
		["The Killing Fields"] = 9,
		["The People's Militia"] = 	{
			["Gryan Stoutmantle"] = 		{
				["Perhaps I did not make myself clear, pledge. In order to prove your worth as a servant to The People's Militia and to the Light Militia and to the Light you need to slay 15 Defias Trappers and 15 Defias Smugglers then return to me when the deed is done."] = 12,
				["We have not time to talk, $N. The Defias Pillagers are denying the people of Westfall the peace and prosperity they deserve. Make sure at sure at least 15 Defias Pillagers and 15 Defias Looters have been killed. That will send a clear message that corruption is not welcome here."] = 13,
				["$N, now is no time for idle chatter. If you still wish to prove yourself to The People's Militia you need to slay the Defias yourself to The People's Militia you need to slay the Defias I notified you about earlier. Return to me when you have completed your duty."] = 14
			}
		},
		["Report to Gryan Stoutmantle"] = 109,
		["The Defias Brotherhood"] = 	{
			["Gryan Stoutmantle"] = 		{
				["Good to see you back, $N. What did Wiley have to say for himself? Good to see you back, $N. What did Wiley have to say for himself?"] = 132,
				["Did Master Shaw shed any light on things? Did Master Shaw shed any light on things?"] = 141,
				["$N, were you able to gather any information? Did you locate the messenger? $N, were you able to gather any information? Did you locate the messenger?"] = 142,
				["What business do you have with me? I am a very busy man... What business do you have with me? I am a very busy man..."] = 155,
				["How goes the hunt for Edwin VanCleef? How goes the hunt for Edwin VanCleef?"] = 166
			},
			["Master Mathias Shaw"] = 135
		},
		["Messenger to Westfall"] = 	{
			["Gryan Stoutmantle"] = 143,
			["Magistrate Solomon"] = 144
		},
		["Goretusk Liver Pie"] = 22,
		["Westfall Stew"] = 	{
			["Salma Saldean"] = 		{
				["I'm going to miss that Verna Furlbrow so much. I don't suppose you happened to see her on your way here? I'm going to miss that Verna Furlbrow so much. I don't suppose you happened to see her on your way here?"] = 36,
				["Come back with the following ingredients:     3 Stringy Vulture Meat   3 Goretusk Snouts   3 Murloc Eyes   3 Okra Come back with the following ingredients:     3 Stringy Vulture Meat   3 Goretusk Snouts   3 Murloc Eyes   3 Okra"] = 38
			}
		},
		["The Forgotten Heirloom"] = 64,
		["Furlbrow's Deed"] = 184,
		["Poor Old Blanchy"] = 151,
		["Sweet Amber"] = 	{
			["Grimbooze Thunderbrew"] = 		{
				["Hiccup! Ho ho! You want an encore? In the land to the south where vines twist and creep Lies a hidden well where the water runs deep Pure where vines twist and creep Lies a hidden well where the water runs deep Pure as the Light's sacred Daughter Bring to me now some Holy Spring Water."] = 48,
				["Encore? Well, sure! Amber is the hue of my life's longest love Like the last embers of dusk in the sky above Retrieve for me so that my the last embers of dusk in the sky above Retrieve for me so that my love shall be born One sack of each: barley, rye and corn."] = 49,
				["An encore for you? Well sure friend! I'll mix and mix till we have a mash For this will be our own private stash A still must be a mash For this will be our own private stash A still must be fashioned of metal strong Bring me some Truesilver so I can finish this song."] = 50,
				["An encore? Why for you, anything! Not yet filtered but freshly distilled Like unseeded land waiting there tilled. Next I will fashion our pile of charcoal Deliver a sycamore yet filtered but freshly distilled Like unseeded land waiting there tilled. Next I will fashion our pile of charcoal Deliver a sycamore branch, that is your next goal."] = 51,
				["Sure, I'll sing it again for you, friend! Mellifluous liquid clear as a baby's tears Turns a lovely deep amber over the years But before we proceed to baby's tears Turns a lovely deep amber over the years But before we proceed to get lit to the hilt A barrel of charred oak must be built."] = 53
			}
		},
		["Thunderbrew Lager"] = 117,
		["Report to Goldshire"] = 54,
		["The Fargodeep Mine"] = 62,
		["The Jasperlode Mine"] = 76,
		["The Collector"] = 123,
		["Manhunt"] = 147,
		["Wanted:  'Hogger'"] = 176,
		["Gold Dust Exchange"] = 47,
		["Princess Must Die!"] = 88,
		["Pie for Billy"] = 86,
		["Goldtooth"] = 87,
		["Back to Billy"] = 84,
		["Speak with Gramma"] = 111,
		["The Escape"] = 	{
			["Maybell Maclure"] = 114,
			["Sputtervalve"] = 863
		},
		["Young Lovers"] = 106,
		["Kobold Candles"] = 60,
		["Note to William"] = 107,
		["Collecting Kelp"] = 112,
		["Give Gerard a Drink"] = 16,
		["Bounty on Murlocs"] = 46,
		["Protect the Frontier"] = 52,
		["Report to Thomas"] = 71,
		["Messenger to Darkshire"] = 	{
			["Lord Ello Ebonlocke"] = 145,
			["Magistrate Solomon"] = 146
		},
		["Note to the Mayor"] = 160,
		["Translation to Ello"] = 252,
		["Bride of the Embalmer"] = 253,
		["The Night Watch"] = 	{
			["Commander Althea Ebonlocke"] = 		{
				["Have you killed those warriors and mages? Have you killed those warriors and mages?"] = 56,
				["Return to me once you have killed 15 Skeletal Fiends and 15 Skeletal Horrors, $N. Return to me once you have killed 15 Skeletal Fiends and 15 Skeletal Horrors, $N."] = 57,
				["I need your assistance, $N. Travel to the cemetery to the northwest and rid the eastern mausoleum of 20 Plague Spreaders. Return to me when your assistance, $N. Travel to the cemetery to the northwest and rid the eastern mausoleum of 20 Plague Spreaders. Return to me when your task is complete."] = 58
			}
		},
		["The Legend of Stalvan"] = 	{
			["Commander Althea Ebonlocke"] = 		{
				["This better be good, $C. Let me see what you have and tell me your tale. But by the Light, be quick about it. Darkshire's But by the Light, be quick about it. Darkshire's defense is my number one priority. I have not the time to squander on dead-end leads."] = 79,
				["Yes, $N? Yes, $N?"] = 97
			},
			["Madame Eva"] = 98,
			["Clerk Daltry"] = 		{
				["Ah, I remember you. You're the one who was asking about that Stalvan fellow. Did you ever find what you were looking for? Ah, I remember you. You're the one who was asking about that Stalvan fellow. Did you ever find what you were looking for?"] = 68,
				["Back again, $N? What do you have this time? Back again, $N? What do you have this time?"] = 80
			},
			["Tavernkeep Smitts"] = 78,
			["Marshal Haggard"] = 		{
				["What have you got there? I cannot see. My eyesight is very bad. Put it in my hands. What have you got there? I cannot see. My eyesight is very bad. Put it in my hands."] = 74,
				["Did you find that page I mentioned, $N? Did you find that page I mentioned, $N?"] = 75
			},
			["Caretaker Folsom"] = 70
		},
		["Mor'Ladim"] = 228,
		["The Totem of Infliction"] = 101,
		["Return the Comb"] = 154,
		["The Shadowy Figure"] = 262,
		["The Shadowy Search Continues"] = 265,
		["Translate Abercrombie's Note"] = 251,
		["Crime and Punishment"] = 377,
		["Jitters' Growling Gut"] = 5,
		["Seasoned Wolf Kabobs"] = 90,
		["Dusky Crab Cakes"] = 93,
		["Gather Rot Blossoms"] = 156,
		["Inquire at the Inn"] = 266,
		["Look To The Stars"] = 	{
			["Viktori Prism'Antras"] = 		{
				["Have you found a skilled engineer to create a bronze tube yet? Have you found a skilled engineer to create a bronze tube yet?"] = 174,
				["I showed Cog the beginnings of our star-viewing machine. He was impressed. Did you happen to find a reflective device? I showed Cog the beginnings of our star-viewing machine. He was impressed. Did you happen to find a reflective device?"] = 177,
				["Were you able to convince Zzarc'Vul to lend us his monocle for our experiment? Were you able to convince Zzarc'Vul to lend us his monocle for our experiment?"] = 181
			}
		},
		["Cloth and Leather Armor"] = 59,
		["Red Linen Goods"] = 83,
		["Shipment to Stormwind"] = 61,
		["Raven Hill"] = 163,
		["Return to Jitters"] = 240,
		["Finding the Shadowy Figure"] = 453,
		["Ghoulish Effigy"] = 133,
		["Ogre Thieves"] = 134,
		["Deliver the Thread"] = 157,
		["Juice Delivery"] = 159,
		["Dead-tooth Jack"] = 1667,
		["Ghost Hair Thread"] = 149,
		["Morbent Fel"] = 55,
		["Deliveries to Sven"] = 164,
		["Sven's Camp"] = 230,
		["Return to Sven"] = 268,
		["Proving Your Worth"] = 323,
		["Armed and Ready"] = 325,
		["Theocritus' Retrieval"] = 178,
		["Morganth"] = 249,
		["Shadow of the Past"] = 393,
		["Seek out SI: 7"] = 2205,
		["Snatch and Grab"] = 2206,
		["Klaven's Tower"] = 2359,
		["The Everstill Bridge"] = 89,
		["The Lost Tools"] = 125,
		["An Unwelcome Guest"] = 34,
		["Redridge Goulash"] = 92,
		["Messenger to Stormwind"] = 	{
			["Magistrate Solomon"] = 121,
			["General Marcus Jonathan"] = 120
		},
		["Wanted: Gath'Ilzogg"] = 169,
		["Wanted: Lieutenant Fangore"] = 180,
		["Dry Times"] = 116,
		["Dungar Longdrink"] = 6261,
		["Hallowed Letter"] = 3103,
		["Garments of the Light"] = 	{
			["Priestess Josetta"] = 5624,
			["Maxan Anvol"] = 5625
		},
		["Delivering Daffodils"] = 131,
		["Selling Fish"] = 127,
		["Murloc Poachers"] = 150,
		["Tharil'zun"] = 19,
		["Blackrock Menace"] = 20,
		["Shadow Magic"] = 115,
		["Missing In Action"] = 219,
		["Keeper of the Flame"] = 103,
		["The Coastal Menace"] = 104,
		["The Coast Isn't Clear"] = 152,
		["Return to Verner"] = 119,
		["Underbelly Scales"] = 122,
		["A Baying of Gnolls"] = 124,
		["Howling in the Hills"] = 126,
		["Gearing Redridge"] = 1618,
		["Tainted Letter"] = 3105,
		["Tainted Memorandum"] = 3115,
		["A Free Lunch"] = 129,
		["Colonel Kurzen"] = 202,
		["The Spy Revealed!"] = 329,
		["Special Forces"] = 574,
		["The Attack!"] = 434,
		["The Missing Diplomat"] = 	{
			["Elling Trias"] = 		{
				["Hello, $N. Is there something I can do for you? Perhaps you'd like to try some of our special Trias cheddar? Or a block of Is there something I can do for you? Perhaps you'd like to try some of our special Trias cheddar? Or a block of Darnassian bleu?"] = 1242,
				["I see you're back, and in one piece. We both know you're not here for cheese, so let's cut out the pleasantries. Was Backus any both know you're not here for cheese, so let's cut out the pleasantries. Was Backus any help, or have you even left for Duskwood yet?"] = 1245
			},
			["Watcher Backus"] = 		{
				["Not too safe to be traveling about in the woods, $N. Be careful, and if you see anything suspicious or dangerous, contact the Watchers immediately. both know you're gonna ignore me and fight whatever comes out of the darkness anyway, don't we? Haha, yeah, you adventurer types... all the same."] = 1243,
				["Be careful out there, $N. I know Trias was the one to send you here, but that doesn't mean there isn't anything lurking out in here, but that doesn't mean there isn't anything lurking out in the woods that couldn't cause you some trouble... especially with you investigating the Defias."] = 1244
			},
			["Jorgen"] = 1241,
			["Dashel Stonefist"] = 1447,
			["Mikhail"] = 1249,
			["Archmage Tervosh"] = 		{
				["Yes, $N? Yes, $N?"] = 1265,
				["Hello again, $N. I hope you don't mind the assistance, but we couldn't have Hendel escaping, or worse, wind up dead. Hello again, $N. I hope you don't mind the assistance, but we couldn't have Hendel escaping, or worse, wind up dead."] = 1324
			}
		},
		["Return to Lewis"] = 6285,
		["The Price of Shoes"] = 118,
		["A Swift Message"] = 6181,
		["CLUCK!"] = 3861,
		["Oh Brother. . ."] = 167,
		["Collecting Memories"] = 168,
		["Dwarven Outfitters"] = 179,
		["Worgen in the Woods"] = 	{
			["Jonathan Carevin"] = 223,
			["Calor"] = 		{
				["$N, how fares the hunt? $N, how fares the hunt?"] = 173,
				["Back so soon, $N? I hope you haven't come to tell me you've given up. Back so soon, $N? I hope you haven't come to tell me you've given up."] = 221,
				["Intimidating beasts aren't they? But have no fear, $N, those who stand for the Light will never fall! Intimidating beasts aren't they? But have no fear, $N, those who stand for the Light will never fall!"] = 222
			}
		},
		["The Scythe of Elune"] = 1043,
		["A New Threat"] = 170,
		["The Boar Hunter"] = 183,
		["Coldridge Valley Mail Delivery"] = 	{
			["Talin Keeneye"] = 233,
			["Grelin Whitebeard"] = 234
		},
		["Raptor Mastery"] = 	{
			["Hemet Nesingwary Jr."] = 		{
				["I never met a hunter who got any kills by standing around the campfire - well, except for my father. Were you planning on killing campfire - well, except for my father. Were you planning on killing those Stranglethorn Raptors or were you hoping they would die of old age?"] = 194,
				["A true hunter sets his focus on his prey. You, my friend, seem more concerned with chit-chatting around the campfire. Now get out there and around the campfire. Now get out there and kill 10 Lashtails before I go and rid the entire bloody jungle of them in one hunt."] = 195,
				["Bah! What are you doing standing around, $N! A true big game hunter never gives up once his prey is in his sights. Those Jungle his prey is in his sights. Those Jungle Stalkers aren't going to come running up to this campfire and throw themselves in it. Silly bloke."] = 196,
				["How goes the hunt for Tethis? Tracked her all the way back to camp, did you? How goes the hunt for Tethis? Tracked her all the way back to camp, did you?"] = 197
			}
		},
		["Big Game Hunter"] = 208,
		["Hemet Nesingwary Jr."] = 5762,
		["Hunting in Stranglethorn"] = 5763,
		["The Green Hills of Stranglethorn"] = 338,
		["Chapter I"] = 339,
		["Chapter II"] = 340,
		["Chapter III"] = 341,
		["Chapter IV"] = 342,
		["Tiger Mastery"] = 	{
			["Ajeck Rouack"] = 		{
				["I don't feel confident in training you further, $n, until you have proven yourself skilled in slaying the youngest of the tigers first. I don't feel confident in training you further, $n, until you have proven yourself skilled in slaying the youngest of the tigers first."] = 185,
				["If you strive for greater challenges you must first prove yourself with the task at hand. Return to me after you've killed 10 Stranglethorn Tigers. If you strive for greater challenges you must first prove yourself with the task at hand. Return to me after you've killed 10 Stranglethorn Tigers."] = 186,
				["You must kill 10 Elder Stranglethorn Tigers before I give you the final challenge that will determine if you are a true tiger hunting master. You must kill 10 Elder Stranglethorn Tigers before I give you the final challenge that will determine if you are a true tiger hunting master."] = 187,
				["How goes the hunt for Sin'Dall? How goes the hunt for Sin'Dall?"] = 188
			}
		},
		["Panther Mastery"] = 	{
			["Sir S. J. Erlgadin"] = 		{
				["A true panther hunter would be out in the fields, trying to stalk his prey. Show some commitment to your goal, $c, and get back panther hunter would be out in the fields, trying to stalk his prey. Show some commitment to your goal, $c, and get back out there."] = 190,
				["Go kill 10 panthers! Show us what you've got! Go kill 10 panthers! Show us what you've got!"] = 191,
				["What are you doing here, $n! You should be crawling through the brush, trying to kill 10 Shadowmaw Panthers. I thought you fancied yourself a doing here, $n! You should be crawling through the brush, trying to kill 10 Shadowmaw Panthers. I thought you fancied yourself a big game $c?"] = 192,
				["Bhag'thera can prove to be an elusive beast. How fares the hunt? Bhag'thera can prove to be an elusive beast. How fares the hunt?"] = 193
			}
		},
		["The Second Rebellion"] = 203,
		["Bad Medicine"] = 204,
		["Bloodscalp Ears"] = 189,
		["Skullsplitter Tusks"] = 209,
		["Hostile Takeover"] = 213,
		["Supplies to Private Thorsen"] = 198,
		["Troll Witchery"] = 205,
		["Mai'Zoth"] = 206,
		["Kurzen's Mystery"] = 207,
		["Return to Corporal Kaleb"] = 622,
		["Investigate the Camp"] = 201,
		["Krazek's Cookery"] = 210,
		["Favor for Krazek"] = 627,
		["Dream Dust in the Swamp"] = 1116,
		["The Troll Cave"] = 182,
		["The Stolen Journal"] = 218,
		["Red Silk Bandanas"] = 214,
		["Patrolling Westfall"] = 102,
		["Bounty on Garrick Padfoot"] = 6,
		["Brotherhood of Thieves"] = 18,
		["Scalding Mornbrew Delivery"] = 3364,
		["Hallowed Rune"] = 3110,
		["What Comes Around..."] = 386,
		["Red Leather Bandanas"] = 153,
		["Eight-Legged Menaces"] = 245,
		["Wolves at Our Heels"] = 226,
		["Etched Rune"] = 3108,
		["Solomon's Law"] = 91,
		["Blackrock Bounty"] = 128,
		["Simple Letter"] = 3100,
		["Simple Rune"] = 3106,
		["Simple Memorandum"] = 3112,
		["Encrypted Letter"] = 	{
			["Jorik Kerridan"] = 3102,
			["Loremaster Dibbs"] = 511
		},
		["Encrypted Rune"] = 3109,
		["Encrypted Memorandum"] = 3113,
		["Consecrated Letter"] = 3101,
		["Consecrated Rune"] = 3107,
		["To Show Due Judgment"] = 7639,
		["Exorcising Terrordale"] = 7640,
		["Blessed Arcanite Barding"] = 7644,
		["The Divination Scryer"] = 7646,
		["Grimand's Finest Work"] = 7648,
		["Glyphic Memorandum"] = 3114,
		["Rethban Ore"] = 347,
		["Grape Manifest"] = 3905,
		["Riverpaw Gnoll Bounty"] = 11,
		["Broken Alliances"] = 	{
			["Gorn"] = 		{
				["Tho'grun's betrayal... is there any wonder why the ogres are part of the Horde no longer? I will be glad to see him dead, and Sign of the Earth returned. If you've not dispatched him yet, then waste no time going to Camp Boff. It is to the southeast of Kargath."] = 782,
				["There are few enemies more deadly than dragonkind, and there were few dragons that fought as ferociously as Blacklash and Hematus. There are few enemies more deadly than dragonkind, and there were few dragons that fought as ferociously as Blacklash and Hematus."] = 793
			}
		},
		["Assessing the Threat"] = 246,
		["A Grim Task"] = 304,
		["A Dark Threat Looms"] = 	{
			["Ashlan Stonesmirk"] = 161,
			["Chief Engineer Hinderweir VII"] = 		{
				["Did you happen to discover any clues, $N? Did you happen to discover any clues, $N?"] = 199,
				["What is that you bring from Ashlan? What is that you bring from Ashlan?"] = 274,
				["Do you have the needed items? Time is of the essence!! Do you have the needed items? Time is of the essence!!"] = 278
			},
			["Explosive Charge"] = 280
		},
		["The Dark Iron War"] = 303,
		["The Fury Runs Deep"] = 378,
		["The Thandol Span"] = 	{
			["Rhag Garmason"] = 		{
				["Any sign of Ol' Rustlocke, $N? Any sign of Ol' Rustlocke, $N?"] = 632,
				["The cache of explosives must be destroyed! The cache of explosives must be destroyed!"] = 633
			}
		},
		["Uncovering the Past"] = 299,
		["Ormer's Revenge"] = 	{
			["Ormer Ironbraid"] = 		{
				["Kill 10 Mottled Raptors and 10 Mottled Screechers, $N. My co-workers did not deserve the fate that was brought upon them. It's time to even Mottled Raptors and 10 Mottled Screechers, $N. My co-workers did not deserve the fate that was brought upon them. It's time to even the score."] = 294,
				["I want to make those Mottled Scytheclaws and Mottled Razormaws pay for what they did. Have you killed 10 of each yet? I want to make those Mottled Scytheclaws and Mottled Razormaws pay for what they did. Have you killed 10 of each yet?"] = 295,
				["Is Sarltooth dead? Have you redeemed the memory of the fallen? Is Sarltooth dead? Have you redeemed the memory of the fallen?"] = 296
			}
		},
		["In Defense of the King's Lands"] = 	{
			["Mountaineer Cobbleflint"] = 224,
			["Mountaineer Wallbang"] = 263,
			["Mountaineer Gravelgaw"] = 237,
			["Captain Rugelfuss"] = 217
		},
		["The Trogg Threat"] = 267,
		["Excavation Progress Report"] = 298,
		["Mercenaries"] = 255,
		["WANTED: Chok'sul"] = 256,
		["A Meal Served Cold"] = 212,
		["Crocolisk Hunting"] = 385,
		["Vyrin's Revenge"] = 	{
			["Vyrin Swiftwind"] = 531,
			["Daryl the Youngling"] = 271
		},
		["Down the Scarlet Path"] = 	{
			["Brother Anton"] = 261,
			["Raleigh the Devout"] = 1052
		},
		["A Hunter's Boast"] = 257,
		["A Hunter's Challenge"] = 258,
		["Seeking Wisdom"] = 269,
		["The Eye of Paleth"] = 292,
		["The Lost Ingots"] = 324,
		["Lightforge Ingots"] = 526,
		["Taming the Beast"] = 	{
			["Grif Wildheart"] = 		{
				["Don't worry, lass! You'll get ta try a few before you'll need to decide on just one. Don't worry, lass! You'll get ta try a few before you'll need to decide on just one."] = 6064,
				["What do you think of the snow leopard, $N? What do you think of the snow leopard, $N?"] = 6084,
				["Have you tamed the ice claw bear yet? Have you tamed the ice claw bear yet?"] = 6085
			},
			["Yaw Sharpmane"] = 		{
				["Practice your skills, $N. Tame the adult plainstrider. Practice your skills, $N. Tame the adult plainstrider."] = 6061,
				["Have you found a prairie stalker? Have you found a prairie stalker?"] = 6087,
				["You will soon be ready, $N. You will soon be ready, $N."] = 6088
			},
			["Thotar"] = 		{
				["Good luck, young $C. Good luck, young $C."] = 6062,
				["Were you able to tame the scorpid? Were you able to tame the scorpid?"] = 6082,
				["You need to practice in order to gain the skills you need to effectively control your pet. Have you tamed a surf crawler? You need to practice in order to gain the skills you need to effectively control your pet. Have you tamed a surf crawler?"] = 6083
			},
			["Dazalar"] = 		{
				["You will learn, $N, and one day you will be a great $C. You will learn, $N, and one day you will be a great $C."] = 6063,
				["Understanding the balance between nature and oneself is a way of life for every $R. Understanding the balance between nature and oneself is a way of life for every $R."] = 6101,
				["I am proud of your accomplishments, $N. Have you finished the last task I gave you? I am proud of your accomplishments, $N. Have you finished the last task I gave you?"] = 6102
			}
		},
		["The Third Fleet"] = 288,
		["The Cursed Crew"] = 289,
		["Claws from the Deep"] = 279,
		["Return the Statuette"] = 286,
		["Ammo for Rumbleshot"] = 5541,
		["Blisters on The Land"] = 275,
		["Tramping Paws"] = 276,
		["Fire Taboo"] = 277,
		["Frostmane Hold"] = 287,
		["Senir's Observations"] = 	{
			["Senir Whitebeard"] = 420,
			["Mountaineer Thalos"] = 282
		},
		["Those Blasted Troggs!"] = 432,
		["Protecting the Herd"] = 314,
		["Tundra MacGrann's Stolen Stash"] = 312,
		["Beer Basted Boar Ribs"] = 384,
		["Hurley Blackbreath"] = 4126,
		["Gnogaine"] = 2926,
		["The Only Cure is More Green Glow"] = 2962,
		["Operation Recombobulation"] = 412,
		["The Reports"] = 291,
		["Cleansing the Eye"] = 293,
		["Bring the Light"] = 3636,
		["Gathering Materials"] = 	{
			["Wynne Larson"] = 1921,
			["Josef Gregorian"] = 1961
		},
		["Pristine Spider Silk"] = 1940,
		["Continue to Stormwind"] = 6281,
		["Stout to Kadrell"] = 414,
		["Rat Catching"] = 416,
		["Filthy Paws"] = 307,
		["Stormpike's Delivery"] = 353,
		["Agmond's Fate"] = 704,
		["Murdaloc"] = 739,
		["Gathering Idols"] = 297,
		["Report to Ironforge"] = 301,
		["Letter to Stormpike"] = 514,
		["Stormpike's Deciphering"] = 554,
		["The Hidden Chamber"] = 2240,
		["Distracting Jarven"] = 308,
		["The Perfect Stout"] = 315,
		["A Favor for Evershine"] = 319,
		["Return to Marleth"] = 311,
		["Tools for Steelgrill"] = 400,
		["The Grizzled Den"] = 313,
		["Search for Incendicite"] = 466,
		["Stocking Jetsteam"] = 317,
		["Return to Bellowfiz"] = 320,
		["Blessed Arm"] = 322,
		["Grimand Elmore"] = 1700,
		["Burning Blood"] = 1705,
		["Collection of Goods"] = 7642,
		["Harlan Needs a Resupply"] = 333,
		["Package for Thurman"] = 334,
		["Wine Shop Advert"] = 332,
		["A Noble Brew"] = 	{
			["Zardeth of the Black Claw"] = 335,
			["Lord Baurles K. Wishock"] = 336
		},
		["An Old History Book"] = 337,
		["Return to Milton"] = 542,
		["Report to Helgrum"] = 1420,
		["Pool of Tears"] = 1424,
		["The Temple of Atal'Hakkar"] = 1445,
		["Return to Kristoff"] = 346,
		["Stranglethorn Fever"] = 	{
			["Witch Doctor Unbagwa"] = 349,
			["Fin Fizracket"] = 348
		},
		["Uldaman Reagent Run"] = 	{
			["Ghak Healtouch"] = 17,
			["Jarkal Mossmeld"] = 2202
		},
		["Badlands Reagent Run"] = 	{
			["Ghak Healtouch"] = 2500,
			["Jarkal Mossmeld"] = 2258
		},
		["Badlands Reagent Run II"] = 	{
			["Ghak Healtouch"] = 2501,
			["Jarkal Mossmeld"] = 2203
		},
		["Rear Guard Patrol"] = 356,
		["A Putrid Task"] = 404,
		["The Mills Overrun"] = 426,
		["Ulag the Cleaver"] = 1819,
		["Return the Book"] = 366,
		["Proving Allegiance"] = 409,
		["The Lich's Identity"] = 357,
		["The Prodigal Lich"] = 405,
		["The Prodigal Lich Returns"] = 411,
		["Rot Hide Origins"] = 444,
		["Wand to Bethor"] = 491,
		["Graverobbers"] = 358,
		["The Family Crypt"] = 408,
		["The Engraved Ring"] = 440,
		["Deaths in the Family"] = 354,
		["The Haunted Mills"] = 362,
		["Agamand Heirlooms"] = 1821,
		["At War With The Scarlet Crusade"] = 	{
			["Executor Zygand"] = 		{
				["Young $C, you shouldn't be wasting your time here in Brill when your people need you fighting for their cause. Now, take up arms and tower, and slay Captain Perrine along with 3 Scarlet Zealots and 3 Scarlet Missionaries. We shall herd the Scarlet Crusade like cattle to their demise."] = 370,
				["I see you have returned but your task is not complete. Perhaps you are at ease with the mere humans interfering with The Dark Lady's interfering with The Dark Lady's plan? Or perhaps you can heed the call of duty and slay Captain Vachon and his band of Scarlet Friars!"] = 371,
				["You have not yet performed your duty, $c. We cannot expect to carry out The Dark Lady's plan with the Scarlet Crusade pestering our soldiers. expect to carry out The Dark Lady's plan with the Scarlet Crusade pestering our soldiers. Bring about their deaths and perform your duty to Sylvanas!"] = 372,
				["If you wish to prove your worth to The Dark Lady, slay 10 Scarlet Warriors, $C. If you wish to prove your worth to The Dark Lady, slay 10 Scarlet Warriors, $C."] = 427
			}
		},
		["Vital Intelligence"] = 383,
		["Wanted: Maggot Eye"] = 398,
		["Fields of Grief"] = 	{
			["Apothecary Johaan"] = 365,
			["Captured Scarlet Zealot"] = 407
		},
		["A New Plague"] = 	{
			["Apothecary Johaan"] = 		{
				["Have you collected 5 vials of darkhound blood yet, $N? Time is fleeting! Have you collected 5 vials of darkhound blood yet, $N? Time is fleeting!"] = 367,
				["$N, were you able to obtain 5 Vile Fin Scales from the Murlocs? $N, were you able to obtain 5 Vile Fin Scales from the Murlocs?"] = 368,
				["Do you have some venom from a Vicious Night Web Spider yet, $N? It's the final component I need in order to test my experiment. Do you have some venom from a Vicious Night Web Spider yet, $N? It's the final component I need in order to test my experiment."] = 369
			},
			["Captured Mountaineer"] = 492
		},
		["The Chill of Death"] = 375,
		["A Letter Undelivered"] = 361,
		["The Mindless Ones"] = 364,
		["Rattling the Rattlecages"] = 3901,
		["Night Web's Hollow"] = 380,
		["The Scarlet Crusade"] = 381,
		["The Red Messenger"] = 382,
		["Honor Students"] = 6387,
		["Gryth Thurden"] = 6388,
		["The Unsent Letter"] = 373,
		["The Curious Visitor"] = 392,
		["Humble Beginnings"] = 399,
		["Proof of Demise"] = 374,
		["The Damned"] = 376,
		["Marla's Last Wish"] = 6395,
		["Return to Brock"] = 6392,
		["Quell The Uprising"] = 387,
		["The Stockade Riots"] = 391,
		["The Color of Blood"] = 388,
		["Scavenging Deathknell"] = 3902,
		["An Audience with the King"] = 	{
			["Lady Katrana Prestor"] = 396,
			["King Varian Wrynn"] = 396
		},
		["Draenethyst Crystals"] = 1389,
		["Noboru the Cudgel"] = 1392,
		["Scarlet Subterfuge"] = 5862,
		["Dispelling Evil"] = 8414,
		["Demon Dogs"] = 5542,
		["Blood Tinged Skies"] = 5543,
		["Carrion Grubbage"] = 5544,
		["Redemption"] = 5742,
		["Of Forgotten Memories"] = 5781,
		["Of Lost Honor"] = 5845,
		["Of Love and Family"] = 5848,
		["In Dreams"] = 	{
			["Tirion Fordring"] = 5944,
			["Lord Tirion Fordring"] = 5944
		},
		["Wild Hearts"] = 429,
		["Rot Hide Ichor"] = 443,
		["Delivery to Silverpine Forest"] = 445,
		["Thule Ravenclaw"] = 446,
		["A Recipe For Death"] = 	{
			["Apothecary Renferrel"] = 450,
			["Master Apothecary Faranell"] = 		{
				["Hail, $C. What business do you have with the Royal Apothecary Society? Hail, $C. What business do you have with the Royal Apothecary Society?"] = 447,
				["What brings you back to the Undercity, $N? What brings you back to the Undercity, $N?"] = 451
			}
		},
		["Arugal's Folly"] = 	{
			["Dalar Dawnweaver"] = 		{
				["Have you secured the Pyrewood Shackles yet, $N? Have you secured the Pyrewood Shackles yet, $N?"] = 99,
				["Before I know what we are dealing with here, $C, I need to study the spell known as Remedy of Arugal. Bring it to me to study the spell known as Remedy of Arugal. Bring it to me now or I shall be forced to find myself a worthy servant."] = 422,
				["I will need 6 Glutton Shackles and 3 Darksoul Shackles before I can assess the situation and devise a final solution for Arugal. Now heed situation and devise a final solution for Arugal. Now heed your bidding and slay Moonrage Gluttons and Moonrage Darksouls until you have what I need."] = 423,
				["Has Grimson the Pale been slain? Varimathras will not be pleased if we ignore his bidding. Has Grimson the Pale been slain? Varimathras will not be pleased if we ignore his bidding."] = 424
			}
		},
		["Prove Your Worth"] = 421,
		["Dalar's Analysis"] = 481,
		["Arugal Must Die"] = 1014,
		["Ivar the Foul"] = 425,
		["Return to Quinn"] = 430,
		["The Dead Fields"] = 437,
		["Rot Hide Clues"] = 439,
		["Assault on Fenris Isle"] = 442,
		["The Deathstalkers' Report"] = 449,
		["Shimmer Stout"] = 413,
		["A Pilot's Revenge"] = 417,
		["Thelsamar Blood Sausages"] = 418,
		["The Public Servant"] = 433,
		["The Woodland Protector"] = 459,
		["Raleigh and the Undercity"] = 441,
		["A Husband's Revenge"] = 530,
		["Elixir of Agony"] = 	{
			["Master Apothecary Faranell"] = 513,
			["Apothecary Lydon"] = 		{
				["Any luck at Nethander Stead? Any luck at Nethander Stead?"] = 509,
				["So glad to see you back, $N. I was growing so terribly bored here. Not a single entertaining thing to do besides poison and disease her. . .over and over and over again. How went the trip to the Undercity? Were you fortunate enough to slaughter any humans along the way?"] = 515,
				["Sometimes I get so bored out here in Tarren Mill I like to open up the formaldehyde jar and let the lovely aroma waft through Dwarves? I swear if I have to stare at this deadly elixir without using on it someone for another day I am going to scream."] = 517
			},
			["Dusty Rug"] = 524
		},
		["Going, Going, Guano!"] = 1109,
		["Hearts of Zeal"] = 1113,
		["Venom to the Undercity"] = 2938,
		["The Relics of Wakening"] = 483,
		["Ursal the Mauler"] = 486,
		["The Balance of Nature"] = 	{
			["Conservator Ilthalaine"] = 		{
				["There is still work to be done, $N. Return to me once you have thinned the nightsaber and thistle boar populations. There is still work to be done, $N. Return to me once you have thinned the nightsaber and thistle boar populations."] = 456,
				["Your task is not yet complete, $N. Return to me once 5 mangy nightsabers and 5 thistle boars have been killed. Your task is not yet complete, $N. Return to me once 5 mangy nightsabers and 5 thistle boars have been killed."] = 457
			}
		},
		["Timberling Seeds"] = 918,
		["Timberling Sprouts"] = 919,
		["The Moss-twined Heart"] = 927,
		["The Glowing Fruit"] = 930,
		["The Shimmering Frond"] = 931,
		["Denalan's Earth"] = 997,
		["Oakenscowl"] = 2499,
		["Webwood Venom"] = 916,
		["Webwood Egg"] = 917,
		["Elixirs for the Bladeleafs"] = 1581,
		["The Algaz Gauntlet"] = 455,
		["Daily Delivery"] = 469,
		["Apprentice's Duties"] = 471,
		["Young Crocolisk Skins"] = 484,
		["In Search of The Excavation Team"] = 306,
		["War Banners"] = 464,
		["Defeat Nek'rosh"] = 474,
		["Digging Through the Ooze"] = 470,
		["Simple Scroll"] = 3095,
		["Maps and Runes"] = 478,
		["Ambermill Investigations"] = 479,
		["The Weaver"] = 480,
		["Beren's Peril"] = 516,
		["Encrypted Scroll"] = 3096,
		["Hallowed Scroll"] = 3097,
		["Glyphic Scroll"] = 3098,
		["Tainted Scroll"] = 3099,
		["Garments of Darkness"] = 5650,
		["Zenn's Bidding"] = 488,
		["Seek Redemption!"] = 489,
		["The Road to Darnassus"] = 487,
		["Battle of Hillsbrad"] = 	{
			["High Executor Darthalia"] = 		{
				["As High Executor of Tarren Mill, under the direct command of Varimathras and the Dark Lady, you are subject to follow my command. Perhaps you take case I should behead you right here and now. Otherwise, travel west to the town of Hillsbrad and wage battle against the humans, as ordered. Dismissed."] = 527,
				["You have your orders, $c. Quit dawdling here in Tarren Mill when there is work to be done elsewhere. You have your orders, $c. Quit dawdling here in Tarren Mill when there is work to be done elsewhere."] = 528,
				["Were you able to carry out your orders, $C? Did you dispose of Verringtan and his assistants? And where is that iron shipment? Were you able to carry out your orders, $C? Did you dispose of Verringtan and his assistants? And where is that iron shipment?"] = 529,
				["What news have you? What news have you?"] = 532,
				["You were given direct orders to attack the Azureload Mine. Your reasons for loafing about Tarren Mill better be good or I will behead you given direct orders to attack the Azureload Mine. Your reasons for loafing about Tarren Mill better be good or I will behead you for treason."] = 539,
				["Dun Garok proves to be too much of an obstacle for you, $C? And here I thought you had established yourself valiantly in Hillsbrad. If you're who can produce better results. As for you, well, I am sure the Dark Lady could always use more grave diggers back in Tirisfal Glades."] = 541
			}
		},
		["WANTED: Syndicate Personnel"] = 549,
		["WANTED: Baron Vardus"] = 566,
		["Dangerous!"] = 567,
		["Journey to Hillsbrad Foothills"] = 493,
		["Elixir of Suffering"] = 	{
			["Apothecary Lydon"] = 496,
			["Umpi"] = 499
		},
		["Elixir of Pain"] = 	{
			["Apothecary Lydon"] = 501,
			["Stanley"] = 502
		},
		["Journey to Tarren Mill"] = 1065,
		["Blood of Innocents"] = 1066,
		["Venom Bottles"] = 2933,
		["Undamaged Venom Sac"] = 2934,
		["Summoning Shadra"] = 2937,
		["Supplying the Sepulcher"] = 6321,
		["The Crown of Will"] = 	{
			["Sharlindra"] = 521,
			["Melisara"] = 		{
				["I note that your task is unfinished, $N. Shall I inform Sharlindra of your ineptitude? I note that your task is unfinished, $N. Shall I inform Sharlindra of your ineptitude?"] = 518,
				["I want their heads, $N, not excuses. I want their heads, $N, not excuses."] = 519,
				["Three heads I have, a fourth I need. It will be Mug'Thol's, or it will be yours, $N. That I promise. Three heads I have, a fourth I need. It will be Mug'Thol's, or it will be yours, $N. That I promise."] = 520
			}
		},
		["Down the Coast"] = 536,
		["Farren's Proof"] = 	{
			["Lieutenant Farren Orinelle"] = 559,
			["Marshal Redpath"] = 560
		},
		["Stormwind Ho!"] = 562,
		["The Rescue"] = 498,
		["Taretha's Gift"] = 508,
		["Infiltration"] = 533,
		["Crushridge Bounty"] = 500,
		["Crushridge Warmongers"] = 504,
		["Syndicate Assassins"] = 505,
		["Foreboding Plans"] = 510,
		["Noble Deaths"] = 512,
		["Assassin's Contract"] = 522,
		["Baron's Demise"] = 523,
		["Further Mysteries"] = 525,
		["Dark Council"] = 537,
		["Preserving Knowledge"] = 540,
		["The Ensorcelled Parchment"] = 551,
		["The Perenolde Tiara"] = 543,
		["Delivery to Ridgewell"] = 4765,
		["Bring the End"] = 3341,
		["Gol'dir"] = 503,
		["Lord Aliden Perenolde"] = 507,
		["Valik"] = 535,
		["Manna-Enriched Horse Feed"] = 7645,
		["Costly Menace"] = 564,
		["Hinott's Assistance"] = 2479,
		["Soothing Turtle Bisque"] = 	{
			["Christoph Jeffcoat"] = 7321,
			["Chef Jessen"] = 555
		},
		["Prison Break In"] = 544,
		["Dalaran Patrols"] = 545,
		["Souvenirs of Death"] = 546,
		["Humbert's Sword"] = 547,
		["Into The Scarlet Monastery"] = 1048,
		["The Deathstalkers"] = 1978,
		["The Power to Destroy..."] = 5725,
		["An Unholy Alliance"] = 	{
			["Varimathras"] = 		{
				["Have you found the Ambassador, $N? Is he dead? We cannot afford to allow the Scourge to take a foothold on Kalimdor. They are enough of spirit that the Scourge may bring great power, but that the Barrens would not truly be hers if she were to agree to their deal."] = 6521,
				["What business is it you wish to speak of, $N? You must feel it is important if you continue to pester me. What business is it you wish to speak of, $N? You must feel it is important if you continue to pester me."] = 6522
			}
		},
		["Helcular's Revenge"] = 	{
			["Novice Thaivand"] = 552,
			["Helcular's Grave"] = 553
		},
		["Stone Tokens"] = 556,
		["Bracers of Binding"] = 557,
		["Bartolo's Yeti Fur Cloak"] = 565,
		["Reassignment"] = 563,
		["The Defense of Grom'gol"] = 	{
			["Commander Aggro'gosh"] = 		{
				["Our supply efforts are still being hampered by the indigenous raptor population, $c. Our supply efforts are still being hampered by the indigenous raptor population, $c."] = 568,
				["Have you made any progress with the ogres of the Mizjah Ruins yet, $C? Have you made any progress with the ogres of the Mizjah Ruins yet, $C?"] = 569
			}
		},
		["Mok'thardin's Enchantment"] = 	{
			["Far Seer Mok'thardin"] = 		{
				["What news do you bring? What news do you bring?"] = 570,
				["Has fortune been on your side, $N? Were you able to obtain an aged gorilla sinew? Has fortune been on your side, $N? Were you able to obtain an aged gorilla sinew?"] = 571,
				["Did your gathering efforts prove fruitful? Did your gathering efforts prove fruitful?"] = 572,
				["I am almost ready to complete the enchantment. Have you performed my bidding? I am almost ready to complete the enchantment. Have you performed my bidding?"] = 573
			}
		},
		["The Bloodsail Buccaneers"] = 	{
			["Fleet Master Seahorn"] = 		{
				["Ahoy, $n. What word do you bring of the Bloodsail encampment to the south? Ahoy, $n. What word do you bring of the Bloodsail encampment to the south?"] = 604,
				["What's the problem, $N? We need to attack before the Bloodsail Buccaneers do! What's the problem, $N? We need to attack before the Bloodsail Buccaneers do!"] = 608
			}
		},
		["Sunken Treasure"] = 	{
			["Fleet Master Seahorn"] = 669,
			["Shakes O'Breen"] = 		{
				["Ahoy, $C. What brings you to the bridge? Ahoy, $C. What brings you to the bridge?"] = 668,
				["So was Seahorn impressed? I bet you his smile reached from Booty Bay to Ratchet. So was Seahorn impressed? I bet you his smile reached from Booty Bay to Ratchet."] = 670
			},
			["Doctor Draxlegauge"] = 		{
				["This is no time to talk! The goggles need to be charged with the power of the stone! This is no time to talk! The goggles need to be charged with the power of the stone!"] = 665,
				["How did the goggles work? Did everything function properly? Adjustments can be made if necessary. Oh, and I'll need those goggles back when you're done. I made if necessary. Oh, and I'll need those goggles back when you're done. I am sure Captain O'Breen will have many uses for them later on."] = 666
			}
		},
		["Up to Snuff"] = 587,
		["Whiskey Slim's Lost Grog"] = 580,
		["Keep An Eye Out"] = 576,
		["Akiris by the Bundle"] = 	{
			["Privateer Bloads"] = 617,
			["Privateer Groy"] = 623
		},
		["Supply and Demand"] = 575,
		["Some Assembly Required"] = 577,
		["Excelsior"] = 628,
		["The Stone of the Tides"] = 578,
		["Water Elementals"] = 601,
		["The Curse of the Tides"] = 611,
		["Goblin Sponsorship"] = 	{
			["Baron Revilgaz"] = 1182,
			["Pozzik"] = 1183
		},
		["Hunt for Yenniku"] = 581,
		["Headhunting"] = 582,
		["Saving Yenniku"] = 592,
		["Grim Message"] = 2932,
		["Venture Company Mining"] = 600,
		["Singing Blue Shards"] = 605,
		["Zanzil's Secret"] = 621,
		["Back to Booty Bay"] = 1118,
		["Report Back to Fizzlebub"] = 1122,
		["Fool's Stout"] = 1127,
		["The Captain's Chest"] = 614,
		["Facing Negolash"] = 618,
		["The Monogrammed Sash"] = 8552,
		["Return to MacKinley"] = 607,
		["Voodoo Dues"] = 609,
		["Cracking Maury's Foot"] = 613,
		["Deliver to MacKinley"] = 2874,
		["Scaring Shaky"] = 606,
		["Stormwind Library"] = 579,
		["The Singing Crystals"] = 589,
		["The Mind's Eye"] = 591,
		["Bloody Bone Necklaces"] = 596,
		["Split Bone Necklace"] = 598,
		["The Vile Reef"] = 629,
		["The Troll Witchdoctor"] = 1240,
		["Filling the Soul Gem"] = 593,
		["'Pretty Boy' Duncan"] = 610,
		["Magical Analysis"] = 602,
		["Avast Ye, Admiral!"] = 4621,
		["Message in a Bottle"] = 630,
		["Components for the Enchanted Gold Bloodrobe"] = 	{
			["Xizk Goodstitch"] = 4781,
			["Menara Voidrender"] = 		{
				["How goes your search for the robes, $N? Have you created them yourself? Such personal touches I find make the imbuing of magic that much accomplishment. But I understand if you choose the quicker path and have it made for you - there's something to be said for such... ambition."] = 1796,
				["Desolace is not a kind area: naga, giants, satyr, the Burning Legion... all of those and warring centaur clans all make the land dangerous if you're not careful. Like I said before, it will not only test your strength and cunning, but also your patience. Be wary in those lands, $N."] = 4783,
				["Soon, $N. I promise you. The robe will be more than adequate for your needs and certainly give you an edge over your opponents. Soon, $N. I promise you. The robe will be more than adequate for your needs and certainly give you an edge over your opponents."] = 4784
			}
		},
		["Sully Balloo's Letter"] = 637,
		["Northfold Manor"] = 681,
		["Stromgarde Badges"] = 682,
		["Wanted!  Marez Cowl"] = 684,
		["Wanted!  Otto and Falconcrest"] = 685,
		["Sigil of Strom"] = 639,
		["Sigil of Thoradin"] = 641,
		["Sigil of Arathor"] = 643,
		["Sigil of Trollbane"] = 644,
		["Trol'kalar"] = 	{
			["Zengu"] = 646,
			["Trollbane's Tomb"] = 645
		},
		["MacKreel's Moonshine"] = 647,
		["The Broken Sigil"] = 640,
		["Foul Magics"] = 	{
			["Tor'gan"] = 		{
				["Once-cursed blood still runs through my veins, $N. If someone... something is summoning demons, it must be stopped. Once-cursed blood still runs through my veins, $N. If someone... something is summoning demons, it must be stopped."] = 671,
				["The burning in my blood... it grows by the day. The warlock must be stopped. The burning in my blood... it grows by the day. The warlock must be stopped."] = 673
			}
		},
		["Raising Spirits"] = 	{
			["Tor'gan"] = 672,
			["Gor'mul"] = 674
		},
		["Guile of the Raptor"] = 	{
			["Tor'gan"] = 701,
			["Gor'mul"] = 702
		},
		["Malin's Request"] = 697,
		["Hints of a New Plague?"] = 	{
			["Quae"] = 		{
				["We appreciate your help in looking for that courier, $N. While you were gone, Kin saw an apothecary come out of that same house to the confident that they're up to no good--I just need proof of it before we go off and do something rash. Have you had any luck yet?"] = 658,
				["The time for talk is done. Protect Kinelory if you care about the people of Hillsbrad at all. The time for talk is done. Protect Kinelory if you care about the people of Hillsbrad at all."] = 660
			}
		},
		["Deep Sea Salvage"] = 662,
		["Drowned Sorrows"] = 664,
		["The Hammer May Fall"] = 676,
		["Call to Arms"] = 	{
			["Drum Fel"] = 		{
				["If you have not yet completed my task, then perhaps you are a coward in heart as well as a tyro in war. If you have not yet completed my task, then perhaps you are a coward in heart as well as a tyro in war."] = 677,
				["You hesitate. Why? You have shown great strength thus far, $N. Do not fail me now. You hesitate. Why? You have shown great strength thus far, $N. Do not fail me now."] = 678,
				["I see your courage finally wanes. It seems my instincts were correct about you: your strength is nothing compared to your bravado. Return to me when were correct about you: your strength is nothing compared to your bravado. Return to me when the beast's head has been severed, or return never again."] = 679
			}
		},
		["The Real Threat"] = 680,
		["Sara Balloo's Plea"] = 683,
		["The Feast of Winter Veil"] = 	{
			["King Magni Bronzebeard"] = 7063,
			["Cairne Bloodhoof"] = 7061
		},
		["The Brokering of Peace"] = 	{
			["King Magni Bronzebeard"] = 8484,
			["Thrall"] = 8485
		},
		["The Lost Fragments"] = 692,
		["Solution to Doom"] = 709,
		["Forbidden Knowledge"] = 737,
		["To Ironforge for Yagyin's Digest"] = 727,
		["The Star, the Hand and the Heart"] = 	{
			["Gerrig Bonegrip"] = 735,
			["Keeper Bel'dugur"] = 736
		},
		["The Powers Below"] = 968,
		["Knowledge in the Deeps"] = 971,
		["Worth Its Weight in Gold"] = 691,
		["Trelane's Defenses"] = 694,
		["Wand over Fist"] = 693,
		["Attack on the Tower"] = 696,
		["A King's Tribute"] = 689,
		["Barbecued Buzzard Wings"] = 703,
		["Pearl Diving"] = 705,
		["Power Stones"] = 2418,
		["Fiery Blaze Enchantments"] = 706,
		["Mirages"] = 718,
		["Scrounging"] = 733,
		["Tremors of the Earth"] = 	{
			["Garek"] = 		{
				["Strong magics and powers held the drakes' prison for so long, but we cannot allow any possibility that Blacklash and Hematus may be released. Strong magics and powers held the drakes' prison for so long, but we cannot allow any possibility that Blacklash and Hematus may be released."] = 717,
				["The nomadic band of ogres travels between their camps across the Badlands; heat rising from the dry earth and the swirling winds will make it difficult to track their progress. I have heard that sometimes they travel through Camp Boff. If you are lost, you might try your search there."] = 732
			}
		},
		["Amulet of Secrets"] = 722,
		["A Dwarf and His Tools"] = 719,
		["Prospect of Faith"] = 	{
			["Prospector Ryedol"] = 723,
			["Historian Karnik"] = 724
		},
		["The Absent Minded Prospector"] = 	{
			["Archaeologist Flagongut"] = 		{
				["What ya got there, friend? What ya got there, friend?"] = 942,
				["With the Stone of Relu I will be able to release the hidden secrets of my fossil as well as Remtravel's fossil from Darkshore, $N. With the Stone of Relu I will be able to release the hidden secrets of my fossil as well as Remtravel's fossil from Darkshore, $N."] = 943
			},
			["Chief Archaeologist Greywhisker"] = 741,
			["Archaeologist Hollee"] = 731
		},
		["Return to Ironforge"] = 2977,
		["Passing Word of a Threat"] = 725,
		["An Ambassador of Evil"] = 762,
		["The Lost Tablets of Will"] = 1139,
		["Liquid Stone"] = 715,
		["Stone Is Better than Cloth"] = 716,
		["Study of the Elements: Rock"] = 	{
			["Lotwil Veriatus"] = 		{
				["This area's perfect for-- Could you hold these in place for a moment? Yes, just like that, along the vector normal. Now, what was I... Perfect for testing my latest project. The raw materials, the open space... what more could an intelligent and enlightened practitioner of the arts ask for?"] = 710,
				["I'm most pleased, $N. My spells affected the smaller pieces just as I predicted. If this experiment is as successful as I foresee, then the this experiment is as successful as I foresee, then the elementals I'll be able to control will put anything summoned prior to this to shame."] = 711,
				["The stone slabs you found were ideal, $N. Lucien will be taking the extra ones back to Kharanos when we're done here. After all, they prove useful again. For instance, they'd be a nice basis for a handy little shelter once I start looking into a multidisciplinary approach to high-yield explosives..."] = 712
			}
		},
		["Coolant Heads Prevail"] = 713,
		["Gyro... What?"] = 714,
		["This Is Going to Be Hard"] = 	{
			["Lotwil Veriatus"] = 		{
				["<Without looking up from the shackles, Lotwil holds out a hand and waggles his fingers impatiently.> The cog, $N, the cog! <Without looking up from the shackles, Lotwil holds out a hand and waggles his fingers impatiently.> The cog, $N, the cog!"] = 777,
				["Not quite the outcome I was expecting. Could you get my shackles back? Not quite the outcome I was expecting. Could you get my shackles back?"] = 778
			}
		},
		["The Rise of the Machines"] = 	{
			["Lotwil Veriatus"] = 		{
				["What have you got there, $R? What have you got there, $R?"] = 4062,
				["Was it him? Was he really alive? Was it him? Was he really alive?"] = 4063
			},
			["Hierophant Theodora Mulvadania"] = 4061
		},
		["WANTED: Murkdeep!"] = 4740,
		["The Red Crystal"] = 4811,
		["To the Undercity for Yagyin's Digest"] = 728,
		["The Book of Ur"] = 1013,
		["Swoop Hunting"] = 761,
		["Poison Water"] = 748,
		["Winterhoof Cleansing"] = 754,
		["Thunderhorn Totem"] = 756,
		["Thunderhorn Cleansing"] = 758,
		["Wildmane Totem"] = 759,
		["The Hunt Begins"] = 747,
		["The Hunt Continues"] = 750,
		["The Battleboars"] = 780,
		["A Humble Task"] = 753,
		["Rite of Strength"] = 757,
		["Attack on Camp Narache"] = 781,
		["Dangers of the Windfury"] = 743,
		["Test of Faith"] = 1149,
		["Test of Endurance"] = 1150,
		["Test of Strength"] = 1151,
		["Preparation for Ceremony"] = 744,
		["The Ravaged Caravan"] = 751,
		["The Venture Co."] = 764,
		["Supervisor Fizsprocket"] = 765,
		["Sharing the Land"] = 745,
		["Dwarven Digging"] = 746,
		["Rites of the Earthmother"] = 	{
			["Baine Bloodhoof"] = 763,
			["Cairne Bloodhoof"] = 776
		},
		["Tal the Wind Rider Master"] = 6363,
		["Master of the Wild Leather"] = 	{
			["Una"] = 2860,
			["Telonis"] = 2853
		},
		["The Platinum Discs"] = 	{
			["Bena Winterhoof"] = 2440,
			["Sage Truthseeker"] = 2280,
			["High Explorer Magellas"] = 2279,
			["Dinita Stonemantle"] = 2439,
			["The Discs of Norgannon"] = 2278
		},
		["Aquatic Form"] = 	{
			["Turak Runetotem"] = 31,
			["Mathrengyl Bearwalker"] = 5061
		},
		["Body and Heart"] = 6002,
		["Gathering Leather"] = 768,
		["Kodo Hide Bag"] = 769,
		["Rite of Vision"] = 771,
		["Mazzranache"] = 766,
		["Simple Note"] = 3091,
		["Verdant Note"] = 3094,
		["Etched Note"] = 3092,
		["Rune-Inscribed Note"] = 3093,
		["Vanquish the Betrayers"] = 784,
		["From The Wreckage...."] = 825,
		["The Admiral's Orders"] = 	{
			["Gar'Thok"] = 830,
			["Vol'jin"] = 831
		},
		["Encroachment"] = 837,
		["Thwarting Kolkar Aggression"] = 786,
		["Dark Storms"] = 806,
		["Cutting Teeth"] = 788,
		["Sting of the Scorpid"] = 789,
		["Your Place In The World"] = 4641,
		["Vile Familiars"] = 792,
		["Burning Blade Medallion"] = 794,
		["Carry Your Weight"] = 791,
		["Simple Parchment"] = 2383,
		["Simple Tablet"] = 3065,
		["Etched Tablet"] = 3082,
		["Etched Parchment"] = 3087,
		["Encrypted Tablet"] = 3083,
		["Encrypted Parchment"] = 3088,
		["Tainted Parchment"] = 3090,
		["Rune-Inscribed Tablet"] = 3084,
		["Rune-Inscribed Parchment"] = 3089,
		["Minshina's Skull"] = 808,
		["Zalazane"] = 826,
		["The Spider God"] = 2936,
		["Finding the Antidote"] = 813,
		["Need for a Cure"] = 812,
		["Break a Few Eggs"] = 815,
		["Lost But Not Forgotten"] = 816,
		["Practical Prey"] = 817,
		["Skull Rock"] = 827,
		["Break Sharptusk!"] = 3376,
		["Neeru Fireblade"] = 829,
		["Burning Shadows"] = 832,
		["Slaying the Beast"] = 5761,
		["A Sacred Burial"] = 833,
		["Sarkoth"] = 790,
		["Chen's Empty Keg"] = 	{
			["Brewmaster Drohn"] = 		{
				["Yes? Yes?"] = 819,
				["How's the search going? How's the search going?"] = 821,
				["You working hard at finding those ingredients, $N? You working hard at finding those ingredients, $N?"] = 822
			}
		},
		["Winds in the Desert"] = 834,
		["Securing the Lines"] = 835,
		["A Solvent Spirit"] = 818,
		["Calm Before the Storm"] = 	{
			["Karus"] = 4511,
			["Idriana"] = 4510,
			["Zilzibin Drumlore"] = 4509,
			["Gracina Spiritmight"] = 4508
		},
		["Doras the Wind Rider Master"] = 6385,
		["Conscript of the Horde"] = 840,
		["Crossroads Conscription"] = 842,
		["Plainstrider Menace"] = 844,
		["The Zhevra"] = 845,
		["Echeyakee"] = 881,
		["Prowlers of the Barrens"] = 903,
		["The Angry Scytheclaws"] = 905,
		["The Guns of Northwatch"] = 891,
		["Free From the Hold"] = 898,
		["Gann's Reclamation"] = 843,
		["Revenge of Gann"] = 	{
			["Gann Stonespire"] = 		{
				["I see you are back, $N. While Khazgorm's death might delay the digging in my ancestral lands some, it will by no means bring a total well. If you have the ingredients I requested, I can fashion a charge that will make the hasty dwarves reconsider their actions here in the Barrens."] = 846,
				["Once the dwarven flying machine has been destroyed I will feel the sweet satisfaction of revenge. Once the dwarven flying machine has been destroyed I will feel the sweet satisfaction of revenge."] = 849
			}
		},
		["Wolf Swapping - Arctic Wolf"] = 7660,
		["Wolf Swapping - Red Wolf"] = 7661,
		["Ishamuhale"] = 882,
		["Lakota'mani"] = 883,
		["Owatanka"] = 884,
		["Washte Pawne"] = 885,
		["The Harvester"] = 897,
		["Enraged Thunder Lizards"] = 907,
		["Cry of the Thunderhawk"] = 913,
		["Isha Awak"] = 873,
		["Kolkar Leaders"] = 850,
		["Verog the Dervish"] = 851,
		["Hezrul Bloodmark"] = 852,
		["Centaur Bracers"] = 855,
		["Regthar Deathgate"] = 1361,
		["Counterattack!"] = 4021,
		["Fungal Spores"] = 848,
		["Sample for Helbrim"] = 1358,
		["Southsea Freebooters"] = 887,
		["Stolen Booty"] = 888,
		["The Missing Shipment"] = 	{
			["Gazlowe"] = 892,
			["Wharfmaster Dizzywig"] = 890
		},
		["WANTED: Baron Longshore"] = 895,
		["Mission: Possible But Not Probable"] = 2478,
		["Rig Wars"] = 2841,
		["Return of the Ring"] = 	{
			["Nogg"] = 2949,
			["Talvash del Kissel"] = 2947
		},
		["Nogg's Ring Redo"] = 2950,
		["Apothecary Zamah"] = 853,
		["Serpentbloom"] = 962,
		["Return to Thunder Bluff"] = 	{
			["Apothecary Zamah"] = 1067,
			["Nara Wildmane"] = 2967
		},
		["The Flying Machine Airport"] = 1086,
		["The Tear of the Moons"] = 857,
		["Egg Hunt"] = 868,
		["Parts of the Swarm"] = 1148,
		["Disrupt the Attacks"] = 871,
		["The Disruption Ends"] = 872,
		["Betrayal from Within"] = 	{
			["Thork"] = 906,
			["Mangletooth"] = 879
		},
		["Supplies for the Crossroads"] = 5041,
		["Tribes at War"] = 878,
		["Spirit of the Wind"] = 889,
		["Agamaggan's Strength"] = 5042,
		["Agamaggan's Agility"] = 5043,
		["Wisdom of Agamaggan"] = 5044,
		["Rising Spirit"] = 5045,
		["Razorhide"] = 5046,
		["Blood Shards of Agamaggan"] = 5052,
		["Consumed by Hatred"] = 899,
		["Lost in Battle"] = 4921,
		["Weapons of Choice"] = 893,
		["A New Ore Sample"] = 1153,
		["Ignition"] = 858,
		["The Hunter's Way"] = 861,
		["Steelsnap"] = 1131,
		["Frostmaw"] = 1136,
		["Deadmire"] = 1205,
		["Samophlange"] = 	{
			["Sputtervalve"] = 902,
			["Control Console"] = 		{
				["Blinking lights on the control console indicate that the main control valves have not been closed off. Blinking lights on the control console indicate that the main control valves have not been closed off."] = 900,
				["The console lights are dimmed and the gauges and dials all read at their zero positions, everything idling. The console lights are dimmed and the gauges and dials all read at their zero positions, everything idling."] = 901
			}
		},
		["Further Instructions"] = 1094,
		["Dig Rat Stew"] = 862,
		["Raptor Horns"] = 865,
		["Root Samples"] = 866,
		["Deepmoss Spider Eggs"] = 1069,
		["Blueleaf Tubers"] = 1221,
		["Smart Drinks"] = 1491,
		["The Forgotten Pools"] = 870,
		["The Stagnant Oasis"] = 877,
		["Altered Beings"] = 880,
		["The Principal Source"] = 	{
			["Tonga Runetotem"] = 6127,
			["Alanndarian Nightsong"] = 6122
		},
		["Gathering the Cure"] = 	{
			["Tonga Runetotem"] = 6128,
			["Alanndarian Nightsong"] = 6123
		},
		["Harpy Raiders"] = 867,
		["Harpy Lieutenants"] = 875,
		["Serena Bloodfeather"] = 876,
		["Miner's Fortune"] = 896,
		["Wharfmaster Dizzywig"] = 	{
			["Wharfmaster Dizzywig"] = 		{
				["Speak up! Tell me, are you dropping off or picking up? Speak up! Tell me, are you dropping off or picking up?"] = 1111,
				["You seek passage on the next ship, or have some item you wish to send aboard it? You seek passage on the next ship, or have some item you wish to send aboard it?"] = 1492
			}
		},
		["Raptor Thieves"] = 869,
		["Stolen Silver"] = 3281,
		["Return to Jahan"] = 6364,
		["Laughing Sisters"] = 1945,
		["Return to the Crossroads."] = 6386,
		["Crown of the Earth"] = 	{
			["Tenaron Stormgrip"] = 921,
			["Corithras Moonrage"] = 		{
				["Greetings, $C. For what purpose do I owe the pleasure of our meeting? Greetings, $C. For what purpose do I owe the pleasure of our meeting?"] = 928,
				["Hello again, $N. Have you completed your task? Hello again, $N. Have you completed your task?"] = 929,
				["At first the reports of crazed furbolg attacks were dismissed. Who could have thought that the peace-loving bear-men would turn to mindless rage? Yet another could have thought that the peace-loving bear-men would turn to mindless rage? Yet another of the problems that plagues us here in our new home."] = 933,
				["Along with the druids, the Oracle Tree and the Arch Druid have been carefully monitoring the growth of Teldrassil. But though we have a new the Arch Druid have been carefully monitoring the growth of Teldrassil. But though we have a new home, our immortal lives have not been restored."] = 7383
			},
			["Arch Druid Fandral Staghelm"] = 935
		},
		["Teldrassil"] = 940,
		["The Crystal of Zin-Malor"] = 5253,
		["Rellian Greenspyre"] = 922,
		["Tumors"] = 923,
		["The Enchanted Glade"] = 937,
		["Mist"] = 938,
		["Good Natured Emma"] = 5048,
		["The Demon Seed"] = 924,
		["Twisted Hatred"] = 932,
		["The Emerald Dreamcatcher"] = 2438,
		["Ferocitas the Dream Eater"] = 2459,
		["Cave Mushrooms"] = 947,
		["Simple Sigil"] = 3116,
		["Encrypted Sigil"] = 3118,
		["Hallowed Sigil"] = 3119,
		["Etched Sigil"] = 3117,
		["Verdant Sigil"] = 3120,
		["Garments of the Moon"] = 5621,
		["A Bundle of Hides"] = 6361,
		["Meats to Orgrimmar"] = 6365,
		["Return to Onu"] = 950,
		["Mathystra Relics"] = 951,
		["Grove of the Ancients"] = 952,
		["The Fall of Ameth'Aran"] = 953,
		["For Love Eternal"] = 963,
		["Tools of the Highborne"] = 958,
		["Seeking the Kor Gem"] = 1442,
		["The Cliffspring River"] = 4762,
		["The Blackwood Corrupted"] = 4763,
		["Bashal'Aran"] = 	{
			["Asterion"] = 		{
				["Once I have the earrings, I will cast the spell to search for the whereabouts of the seal that binds me. For centuries I have on the freedom destroying the seal would bring to me... Perhaps those centuries have taken a toll upon my mind that I might never recover..."] = 955,
				["The pillars of this shrine are as the bars of a prison to me, $N. No strength I still possess might break them, and no them, wondering if at long last I outlived even the stone, would I be free? Or would it be invisible bars that held me then..."] = 956,
				["In truth, $N, I am afraid... Afraid that your coming--all of this--is merely a figment of a deranged mind. Can you know the torture that your coming--all of this--is merely a figment of a deranged mind. Can you know the torture that this is? I... Please, you must go quickly."] = 957
			}
		},
		["The Tower of Althalaxx"] = 	{
			["Balthule Shadowstrike"] = 		{
				["Have you found any more of their scrolls? I should be able to piece together a larger picture of the cult if you can find you found any more of their scrolls? I should be able to piece together a larger picture of the cult if you can find them."] = 966,
				["Athrikus Narassin is an ancient and powerful warlock. Perhaps we should wait for Delgren's assistance, but he obviously had much faith in you to send is an ancient and powerful warlock. Perhaps we should wait for Delgren's assistance, but he obviously had much faith in you to send you alone."] = 1143
			},
			["Delgren the Purifier"] = 		{
				["You have some business with me, $C? You have some business with me, $C?"] = 967,
				["Have you acquired that soul gem? Have you acquired that soul gem?"] = 970,
				["You look a bit shaken up, $n. Are you well? You look a bit shaken up, $n. Are you well?"] = 973,
				["I heard whisper once that the satyrs' history is somehow related to that of the night elves, but I have found my esteemed hosts reticent the satyrs' history is somehow related to that of the night elves, but I have found my esteemed hosts reticent to speak of the matter."] = 1140
			}
		},
		["Supplies to Auberdine"] = 976,
		["Trouble at the Docks"] = 959,
		["Gaffer Jacks"] = 1579,
		["Electropellers"] = 1580,
		["New Kodo - Teal"] = 7662,
		["New Kodo - Green"] = 7663,
		["Raene's Cleansing"] = 	{
			["Raene Wolfrunner"] = 		{
				["Ah, welcome back, $N. Ah, welcome back, $N."] = 1023,
				["The Sentinels do what they can here in Ashenvale, but it's thanks to $rs like you that we have gained the ground we have. The Sentinels do what they can here in Ashenvale, but it's thanks to $rs like you that we have gained the ground we have."] = 1046
			},
			["Krolg"] = 1045,
			["Shael'dryn"] = 		{
				["Hello. How are you? Hello. How are you?"] = 1024,
				["It upsets me so that the treants have become corrupt. I wish I could do more to help them. It upsets me so that the treants have become corrupt. I wish I could do more to help them."] = 1026,
				["Did you find the final piece of the rod, $N? Did you find the final piece of the rod, $N?"] = 1027
			},
			["Hidden Shrine"] = 1028
		},
		["An Aggressive Defense"] = 1025,
		["Culling the Threat"] = 1054,
		["How Big a Threat?"] = 	{
			["Terenthis"] = 		{
				["How goes your search, $N? How goes your search, $N?"] = 984,
				["Do not stay your hand from what must be done, child. I know how repulsive the idea of killing the creatures of the forest must been discovered for the corruption let loose upon the forest, and we must do what we can to halt its progress until one is found."] = 985
			}
		},
		["A Lost Master"] = 986,
		["Escape Through Stealth"] = 995,
		["Plagued Lands"] = 2118,
		["Cleansing of the Infected"] = 2138,
		["Tharnariun's Hope"] = 2139,
		["Easy Strider Living"] = 2178,
		["Garments of Spirituality"] = 5648,
		["Hallowed Tablet"] = 3085,
		["The Horn of the Beast"] = 3181,
		["At Last!"] = 3201,
		["The Bounty of Teldrassil"] = 6341,
		["The Zoram Strand"] = 1008,
		["Pridewings of Stonetalon"] = 1134,
		["The Ancient Statuette"] = 1007,
		["Ruuzel"] = 1009,
		["Bathran's Hair"] = 1010,
		["Forsaken Diseases"] = 1011,
		["Insane Druids"] = 1012,
		["Kayneth Stillwind"] = 4581,
		["The Howling Vale"] = 1022,
		["Elemental Bracers"] = 1016,
		["Mage Summoner"] = 1017,
		["Orendil's Cure"] = 1020,
		["Elune's Tear"] = 1033,
		["The Ruins of Stardust"] = 1034,
		["Fallen Sky Lake"] = 1035,
		["The Branch of Cenarius"] = 1031,
		["Satyr Slaying!"] = 1032,
		["Compendium of the Fallen"] = 1049,
		["Mythology of the Titans"] = 1050,
		["In the Name of the Light"] = 1053,
		["Vorrel's Revenge"] = 1051,
		["Reclaiming the Charred Vale"] = 1057,
		["Jin'Zil's Forest Magic"] = 1058,
		["Letter to Jin'Zil"] = 1060,
		["Delivery to Magatha"] = 3518,
		["Sacred Fire"] = 5062,
		["Report to Zor"] = 1262,
		["Lonebrow's Journal"] = 1100,
		["The Crone of the Kraul"] = 1101,
		["Thalanaar Delivery"] = 4281,
		["Goblin Invaders"] = 1062,
		["Shredding Machines"] = 1068,
		["A Gnome's Respite"] = 1071,
		["Ineptitude + Chemicals = Fun"] = 	{
			["Gaxim Rustfizzle"] = 1074,
			["Lomac Gearstrip"] = 1073
		},
		["Special Delivery for Gaxim"] = 1077,
		["Covert Ops - Alpha"] = 1079,
		["Covert Ops - Beta"] = 1080,
		["Devils in Westfall"] = 1076,
		["Retrieval for Mauren"] = 1078,
		["Enraged Spirits"] = 1083,
		["Wounded Ancients"] = 1084,
		["Kaela's Update"] = 1091,
		["Vorlus Vilehoof"] = 1683,
		["The Shade of Elura"] = 1686,
		["Prayer to Elune"] = 	{
			["Astarii Starseeker"] = 3378,
			["Zamael Lunthistle"] = 3377
		},
		["The Apple Falls"] = 2241,
		["Destiny Calls"] = 2242,
		["Cenarius' Legacy"] = 1087,
		["Ordanus"] = 1088,
		["Flight to Auberdine"] = 6342,
		["Gerenzo's Orders"] = 1092,
		["Super Reaper 6000"] = 1093,
		["Gerenzo Wrenchwhistle"] = 1096,
		["In Nightmares"] = 	{
			["Mathrengyl Bearwalker"] = 3370,
			["Arch Druid Hamuul Runetotem"] = 3369
		},
		["Morrowgrain Research"] = 	{
			["Mathrengyl Bearwalker"] = 		{
				["Peace and serenity be yours, friend. You are here on business from the Arch Druid himself, yes? Peace and serenity be yours, friend. You are here on business from the Arch Druid himself, yes?"] = 3781,
				["Yes $N, have you grown some morrowgrain for the Arch Druid's important research? The mysterious properties of Un'Goro Crater become clearer with each passing day, the Arch Druid's important research? The mysterious properties of Un'Goro Crater become clearer with each passing day, thanks to the help you are giving us."] = 3785
			},
			["Bashana Runetotem"] = 		{
				["Peace and serenity be yours, friend. You are here on business from the Arch Druid himself, yes? Peace and serenity be yours, friend. You are here on business from the Arch Druid himself, yes?"] = 3782,
				["Yes $N, have you grown some morrowgrain for the Arch Druid's important research? The mysterious properties of Un'Goro Crater become clearer with each passing day, the Arch Druid's important research? The mysterious properties of Un'Goro Crater become clearer with each passing day, thanks to the help you are giving us."] = 3786
			}
		},
		["Morrowgrain to Darnassus"] = 3803,
		["Glyphed Oaken Branch"] = 	{
			["Mathrengyl Bearwalker"] = 4986,
			["Nara Wildmane"] = 4987
		},
		["Ride to Ironforge"] = 6391,
		["A Vengeful Fate"] = 1102,
		["Rocket Car Parts"] = 1110,
		["Parts for Kravel"] = 1112,
		["Rumors for Kravel"] = 1117,
		["Zanzil's Mixture and a Fool's Stout"] = 1119,
		["Hardened Shells"] = 1105,
		["Encrusted Tail Fins"] = 1107,
		["The Brassbolts Brothers"] = 1179,
		["Gahz'rilla"] = 2770,
		["Salt Flat Venom"] = 1104,
		["Delivery to the Gnomes"] = 1114,
		["The Swarm Grows"] = 	{
			["Moktar Krin"] = 		{
				["War brings my group and I to the Shimmering Flats, $C. What brings you here? War brings my group and I to the Shimmering Flats, $C. What brings you here?"] = 1146,
				["With the amount of travelers heading out to the Flats for those races, I'm sure we can convince enough adventure seekers to help push back sure we can convince enough adventure seekers to help push back those insects. My party and I won't be able to leave until we do."] = 1147
			},
			["Belgrom Rockmaul"] = 1145
		},
		["A Grim Discovery"] = 	{
			["Belgrom Rockmaul"] = 2976,
			["Krueg Skullsplitter"] = 2974
		},
		["Betrayed"] = 	{
			["Belgrom Rockmaul"] = 3507,
			["Ag'tor Bloodfist"] = 		{
				["Ah, Belgrom wizened up and finally sent someone not in his ranks to aid us, did he? This camp used to be a dozen warriors strong, between you and I, she is quite the temptress. That's probably why I'm still out here helping Belgrom--I probably would have done the same thing."] = 3504,
				["How goes your slaughter of the blood elf traitors, $N? Have you made any progress? I hope you are the one strong enough to bring that are the one strong enough to bring that dog to her knees! She deserves nothing but a painful death for all that she has done!"] = 3506
			},
			["Kaldorei Tome of Summoning"] = 3505
		},
		["To Steal From Thieves"] = 1164,
		["Test of Lore"] = 	{
			["Parqual Fintallas"] = 		{
				["I hope you made the Scarlet Crusade suffer some before stealing the book from them. My views of their kind are not unwarranted. The Crusade may cleansed, and those traveling in their lands must either be insane, or subject to the undead's powerful magics. Idiots. Idiots and fools; all of them."] = 1160,
				["There is only one rule I feel you must know if you wish to survive in this world: the more you know, the more you'll the more you'll see. If you study, if you observe, then you will begin to see things in the world that no other $r will see."] = 6628
			},
			["Braug Dimspirit"] = 		{
				["Bring me the book after you've studied it. I will not ask you your question until after you have given me the book. Bring me the book after you've studied it. I will not ask you your question until after you have given me the book."] = 1154,
				["Life is full of questions, $C. You will never be able to answer all of them, but with some time and study, perhaps you will $C. You will never be able to answer all of them, but with some time and study, perhaps you will become a little more knowledgeable."] = 6627
			}
		},
		["Get the Gnomes Drunk"] = 1120,
		["Get the Goblins Drunk"] = 1121,
		["The Burning of Spirits"] = 1435,
		["The Corrupter"] = 	{
			["Maurin Bonesplitter"] = 		{
				["The Burning Blade begin to realize how weak they truly are. Their magics are pathetic, their strength feeble. Their only power comes from those they serve, are. Their magics are pathetic, their strength feeble. Their only power comes from those they serve, and not from any understanding of true power and knowledge."] = 1480,
				["Do not bring me an incorrect scalp, $c. Using the incorrect reagents could cause our deaths. The demon lord may have contingency spells on his deaths. The demon lord may have contingency spells on his person to slay those who would scry upon him. Fate has already dealt me enough pain."] = 1481,
				["I am ready for the oracle crystal, $c. Finding and destroying this Lord Azrethoc would garner a great deal of favor with the Warchief for We would do well to work together and to do so swiftly so we may further our own ends and curry favor with the Warchief."] = 1482
			},
			["Takata Steelblade"] = 1488
		},
		["Overlord Mok'Morokk's Concern"] = 1166,
		["Identifying the Brood"] = 1169,
		["The Brood of Onyxia"] = 1172,
		["Challenge Overlord Mok'Morokk"] = 1173,
		["Army of the Black Dragon"] = 1168,
		["Hungry!"] = 1177,
		["Mortality Wanes"] = 1142,
		["A New Cloak's Sheen"] = 2973,
		["Michael Garrett"] = 6322,
		["Ride to the Undercity"] = 6323,
		["The Balnir Farmstead"] = 1882,
		["Investigate the Alchemist Shop"] = 1960,
		["Martek the Exiled"] = 1106,
		["Indurium"] = 1108,
		["A Bump in the Road"] = 1175,
		["Load Lightening"] = 1176,
		["Indurium Ore"] = 1192,
		["Razzeric's Tweaking"] = 1187,
		["Safety First"] = 	{
			["Razzeric"] = 1189,
			["Shreev"] = 1188
		},
		["The Sacred Flame"] = 	{
			["Zangen Stonehoof"] = 1195,
			["Rau Cliffrunner"] = 		{
				["I don't suppose you've been sent by Zangen, hm? I don't suppose you've been sent by Zangen, hm?"] = 1196,
				["I am eager to put my hands upon the Cloven Hoof. Have you taken it yet? I am eager to put my hands upon the Cloven Hoof. Have you taken it yet?"] = 1197
			}
		},
		["Blackfathom Villainy"] = 	{
			["Dawnwatcher Selgorm"] = 1200,
			["Bashana Runetotem"] = 6561
		},
		["Twilight Falls"] = 1199,
		["Theramore Spies"] = 1201,
		["The Theramore Docks"] = 1202,
		["The Lost Report"] = 1238,
		["The Severed Head"] = 1239,
		["Marg Speaks"] = 1261,
		["Jarl Needs a Blade"] = 1203,
		["Jarl Needs Eyes"] = 1206,
		["Marsh Frog Legs"] = 1218,
		["Mudrock Soup and Bugs"] = 1204,
		["Stinky's Escape"] = 1222,
		["... and Bugs"] = 1258,
		["The Black Shield"] = 	{
			["Krog"] = 1251,
			["Caz Twosprocket"] = 1319,
			["Mosarn"] = 1276,
			["Captain Garran Vimes"] = 1253,
			["Do'gol"] = 		{
				["Something for me, $c? Something for me, $c?"] = 1321,
				["Did you get them sacs from the spiders? Did you get them sacs from the spiders?"] = 1322
			}
		},
		["Lieutenant Paval Reethe"] = 	{
			["Krog"] = 1269,
			["Captain Garran Vimes"] = 1252
		},
		["Questioning Reethe"] = 1273,
		["Captain Vimes"] = 1220,
		["What Is Going On?"] = 	{
			["Thrall"] = 4001,
			["Commander Gor'shak"] = 3982
		},
		["Eitrigg's Wisdom"] = 4941,
		["For The Horde!"] = 4974,
		["Hidden Enemies"] = 	{
			["Thrall"] = 		{
				["Do you have the insignia yet, $N? It will be a vital tool in you infiltrating what I believe is the greatest threat to the Horde The hidden agendas, the corruption, all of it will become clear. You will find yourself in the midst of a war you never knew existed."] = 5726,
				["Well, $c? Does he believe our ploy, or are things worse than I had first estimated? Proving valuable to Neeru will make our infiltration of the much easier. He will have plenty of information that we can use to route out those who would destroy all we have built in Durotar."] = 5727,
				["Have you found them yet, $N? The leaders of the Searing Blade. I knew the Shadow Council sought to take Orgrimmar and all of the Horde off until exhaustion sets in, but we will be no further than when we started. I will have to have my spies double their efforts."] = 5728
			}
		},
		["What the Wind Carries"] = 6566,
		["The Lord of Blackrock"] = 	{
			["Thrall"] = 7783,
			["King Varian Wrynn"] = 7781
		},
		["Shadowshard Fragments"] = 	{
			["Archmage Tervosh"] = 7070,
			["Uthel'nay"] = 7068
		},
		["Mage-tastic Gizmonitor"] = 1880,
		["The Art of the Armorsmith"] = 	{
			["Grumnus Steelshaper"] = 5283,
			["Okothos Ironrager"] = 5301
		},
		["Onin's Report"] = 2239,
		["Errand for Apothecary Zinge"] = 	{
			["Apothecary Zinge"] = 238,
			["Alessandro Luca"] = 232
		},
		["Return to Apothecary Zinge"] = 864,
		["Zinge's Delivery"] = 1359,
		["The Essence of Eranikus"] = 	{
			["Itharius"] = 3374,
			["Essence Font"] = 3373
		},
		["In Search of The Temple"] = 1448,
		["Rhapsody's Tale"] = 1469,
		["Into The Temple of Atal'Hakkar"] = 1475,
		["Mazen's Behest"] = 1364,
		["Supplies for Nethergarde"] = 1395,
		["The Lost Supplies"] = 1423,
		["Deliver the Shipment"] = 1425,
		["Coyote Thieves"] = 1419,
		["Khan Dez'hepah"] = 1365,
		["Centaur Bounty"] = 	{
			["Felgur Twocuts"] = 1366,
			["Corporal Melkins"] = 1387
		},
		["Gelkis Alliance"] = 1368,
		["Stealing Supplies"] = 1370,
		["Ongeku"] = 1373,
		["Khan Jehn"] = 1374,
		["Khan Hratha"] = 	{
			["Uthek the Wise"] = 1380,
			["Warug"] = 1381
		},
		["Strange Alliance"] = 1382,
		["Raid on the Kolkar"] = 1384,
		["Magram Alliance"] = 1367,
		["Broken Tears"] = 1369,
		["Gizmo for Warug"] = 1371,
		["Khan Shaka"] = 1375,
		["Brutal Politics"] = 1385,
		["Assault on the Kolkar"] = 1386,
		["Ledger from Tanaris"] = 4450,
		["Mold Rhymes With..."] = 	{
			["Krinkle Goodsteel"] = 		{
				["Yeah, I know who you are, and I know why you're here. Dithers sent word to me before you arrived. Let's cut to deal at how to forge the stem of the key without any knowledge of blacksmithing... all free of charge no less. Who says mercenaries don't offer competitive deals!"] = 5514,
				["Yeah, I know who you are, and I know why you're here. Arbington sent word to me before you arrived. Let's cut to deal at how to forge the stem of the key without any knowledge of blacksmithing... all free of charge no less. Who says mercenaries don't offer competitive deals!"] = 5538
			}
		},
		["Stormpike's Order"] = 1338,
		["Fire Hardened Mail"] = 1701,
		["The Shieldsmith"] = 1702,
		["Nothing But The Truth"] = 	{
			["Apothecary Faustin"] = 1383,
			["Infiltrator Marksen"] = 1391,
			["Deathstalker Zraedus"] = 1388
		},
		["Encroaching Wildlife"] = 1396,
		["Driftwood"] = 1398,
		["The Lost Caravan"] = 1421,
		["Mirror Lake"] = 1861,
		["Investigate the Blue Recluse"] = 1920,
		["Fresh Meat"] = 1430,
		["Lack of Surplus"] = 	{
			["Tok'Kar"] = 		{
				["Lok'tar, $C. Traveling through the swamps isn't a risk taken lightly. You're brave to test your mettle here. Lok'tar, $C. Traveling through the swamps isn't a risk taken lightly. You're brave to test your mettle here."] = 698,
				["Good mead, a warm fire, an army of orcs and an arsenal of weapons... that's all we really need out here along the coast. I regret my position out here safeguarding Stonard, but it would be nice if we could one day get a burrow, or at least a tower."] = 699
			}
		},
		["Threat From the Sea"] = 1426,
		["Continued Threat"] = 1428,
		["Noxious Lair Investigation"] = 82,
		["Bungle in the Jungle"] = 4496,
		["Pawn Captures Queen"] = 4507,
		["The Atal'ai Exile"] = 1429,
		["Jammal'an the Prophet"] = 1446,
		["Rhapsody's Kalimdor Kocktail"] = 1452,
		["Witherbark Cages"] = 2988,
		["The Altar of Zul"] = 2989,
		["Saving Sharpbeak"] = 2994,
		["The Karnitol Shipwreck"] = 	{
			["Roetten Stonehammer"] = 1457,
			["Kreldig Ungor"] = 1456
		},
		["Reagents for Reclaimers Inc."] = 	{
			["Roetten Stonehammer"] = 1467,
			["Kreldig Ungor"] = 		{
				["Despicable creatures, the satyr. Story says they're somehow tied to the night elves, but I'm not so sure I believe it. I think they get that that one elf that brought them into the war few years back. World's never been the same since. Lot more dangerous, and a lot scarier."] = 1458,
				["Sorry I couldn't tell you where to find the kodo or the scorpashi. I'm not terribly familiar with the area, and I haven't had time couldn't tell you where to find the kodo or the scorpashi. I'm not terribly familiar with the area, and I haven't had time to explore."] = 1459,
				["I didn't even realize these demon things were in Desolace. Last I read, centaur pretty much owned the land after the night elves picked up read, centaur pretty much owned the land after the night elves picked up and left years ago. I wonder why they took up here, and how."] = 1466
			}
		},
		["Befouled by Satyr"] = 1434,
		["Search for Tyranis"] = 1439,
		["Reclaimed Treasures"] = 	{
			["Patrick Garrett"] = 2342,
			["Krom Stoutarm"] = 1360
		},
		["The Binding"] = 	{
			["Carendin Halgar"] = 		{
				["I expect to hear of your success, $N. Not meeting my expectations will be the least of your worries, however, should you fail. I expect to hear of your success, $N. Not meeting my expectations will be the least of your worries, however, should you fail."] = 1471,
				["Of the powers from beyond the void, the succubus is one of the most dangerous, as the weak are most easily wrapped around its fingers. Remember void, the succubus is one of the most dangerous, as the weak are most easily wrapped around its fingers. Remember that now and in the future."] = 1474
			},
			["Gan'rul Bloodeye"] = 		{
				["The voidwalker is a powerful creature. I remember when it was I that was in your shoes, $N. Over the years, my own voidwalker has own voidwalker has grown to fight me less, though I suspect that is only because it hopes I will let my guard down. Remember that, $N."] = 1504,
				["When I look upon a succubus, my heart begins to soar... But at the same time, I can almost sense my soul's ebb, drifting away my heart begins to soar... But at the same time, I can almost sense my soul's ebb, drifting away like the tides. Be wary, my friend."] = 1513
			},
			["Gakin the Darkbinder"] = 		{
				["I cannot show you how to control a voidwalker until you have overtaken one. I cannot show you how to control a voidwalker until you have overtaken one."] = 1689,
				["Sometimes I wonder if Surena was not a succubus in disguise, sent to warp and twist my mind... Ha! I give her too much credit, wonder if Surena was not a succubus in disguise, sent to warp and twist my mind... Ha! I give her too much credit, I think."] = 1739
			},
			["Strahad Farsan"] = 1795
		},
		["Creature of the Void"] = 	{
			["Carendin Halgar"] = 1473,
			["Gan'rul Bloodeye"] = 1501
		},
		["Hearts of the Pure"] = 1476,
		["A Rogue's Deal"] = 8,
		["Ur's Treatise on Shadow Magic"] = 1938,
		["Deviate Hides"] = 1486,
		["Deviate Eradication"] = 1487,
		["Hamuul Runetotem"] = 1489,
		["Leaders of the Fang"] = 914,
		["Guarding Secrets"] = 	{
			["Nara Wildmane"] = 4883,
			["Trull Failbane"] = 4882
		},
		["Path of Defense"] = 1498,
		["Love's Gift"] = 1512,
		["Forged Steel"] = 1503,
		["Brutal Armor"] = 1838,
		["Ju-Ju Heaps"] = 1884,
		["Glyphic Tablet"] = 3086,
		["Waters of Xavian"] = 1944,
		["Earth Sapta"] = 1463,
		["Call of Earth"] = 	{
			["Canaga Earthcaller"] = 		{
				["Patience is earth's greatest virtue. The earth witnesses the cycle of all things: the mountains becoming deserts; rivers becoming canyons. The earth is the most me successful, then you shall be that much closer to being made whole. Others will be envious of your wisdom and hate you for their ignorance."] = 1516,
				["I wish to be the first to welcome you fully to the first of four paths that will forever lead you in your destiny. If you the earth gave to you, I will give you the totem it promised. If not, then be gone with you until you have found your way."] = 1518
			},
			["Seer Ravenfeather"] = 		{
				["The earth is patient, and will wait for you until you are ready because she knows in time all things erode and are reborn. It now because she feels you are ready. Consider this your rebirth if you succeed. You will never be able to go back to ignorance afterwards."] = 1519,
				["Greetings, $N. You would not return to me if you had not accomplished your task. May I be the first to welcome you fully to the totem it promised. If not, then I pity you. There is much pride to be had when you've fully dedicated yourself to the elements."] = 1521
			}
		},
		["Call of Water"] = 	{
			["Brine"] = 		{
				["Do you have the water yet, $N? Tales say the ruins were protected by large creatures of nature that do not care for visitors, but creatures of nature that do not care for visitors, but those could be myths to scare off the enemies of the night elves. Regardless, be careful."] = 1534,
				["I am just about prepared to send you on your other tasks. Have you filled the skin yet? I know how protective the quilboar can be. great feasts when even the slightest rain comes to the Barrens. Water is sacred to their kind because it is so scarce. Do you understand?"] = 1535,
				["The well remaining pure within the town reminds me of stories told to me when I was younger, $N. Even in times of great pain orc has suffered as much as he has, but at the same time, I'm not sure any orc is as strong as he is either."] = 1536
			},
			["Islen Waterseer"] = 		{
				["You've returned. Splendid! How went your journey to Silverpine? Did it take you long? It is hard for me to tell if you were successful there because might have done. But small successes are sometimes as important as large ones. Purifying the water there was instrumental for you, and for all shamans."] = 96,
				["Hello again, $N. You're looking well. What brings you back to me so soon? Hello again, $N. You're looking well. What brings you back to me so soon?"] = 220
			},
			["Tiev Mordune"] = 1103,
			["Brazier of Everfount"] = 63
		},
		["Fire Sapta"] = 1464,
		["Call of Fire"] = 	{
			["Telf Joolam"] = 		{
				["Greetin's, $N. You've found yerself at the Shrine of the Dormant Flame. Only those knowledgeable enough in the shamanistic arts will ever learn the secrets up here is far from safe after all--but I am the keeper of the shrine, and I cannot allow just anyone to wander around here."] = 1524,
				["I have enough ingredients for a sapta of fire if you can find the reagent pouch and some fire tar. The Burning Blade fanatics carry are always made from ingredients that are closely tied to their respective elements. It makes our work easier because of the warlocks' ties to fire."] = 1525
			},
			["Kranal Fiss"] = 1527,
			["Brazier of the Dormant Flame"] = 1526
		},
		["Seeking Spiritual Aid"] = 5158,
		["Dogran's Captivity"] = 1515,
		["Ken'zigla's Draught"] = 1511,
		["Get Me Out of Here!"] = 6132,
		["Ghost-o-plasm Round Up"] = 6134,
		["Supplying the Front"] = 1578,
		["Ironband's Compound"] = 1681,
		["Moonglow Vest"] = 1582,
		["Bartleby's Mug"] = 1665,
		["Vejrek"] = 1678,
		["Muren Stormpike"] = 1679,
		["Surena Caledon"] = 1688,
		["Heartswood"] = 1738,
		["The Name of the Beast"] = 	{
			["Lord Arkkoroc"] = 3510,
			["Loramus Thalipedes"] = 3511
		},
		["Smith Mathiel"] = 1692,
		["Mathiel"] = 1703,
		["Sunscorched Shells"] = 1710,
		["Klockmort Spannerspan"] = 1704,
		["Iron Coral"] = 1708,
		["Essential Artificials"] = 2924,
		["The Tome of Divinity"] = 	{
			["Gazin Tenorm"] = 1787,
			["Stephanie Turner"] = 1644,
			["John Turner"] = 1648,
			["Muiredon Battleforge"] = 1784
		},
		["Cyclonian"] = 1712,
		["The Summoning"] = 1713,
		["Elemental Mastery"] = 8410,
		["Spirit Totem"] = 8412,
		["Da Voodoo"] = 8413,
		["The Test of Righteousness"] = 1654,
		["Bailor's Ore Shipment"] = 1655,
		["The Orb of Soran'ruk"] = 1740,
		["Tome of the Cabal"] = 	{
			["Strahad Farsan"] = 		{
				["Haven't seen you around these parts for a while. Have you found the tome and the rods? Haven't seen you around these parts for a while. Have you found the tome and the rods?"] = 1804,
				["Yes, $N? Of what service can I be to you? Yes, $N? Of what service can I be to you?"] = 1805
			},
			["Jorah Annison"] = 1803,
			["Krom Stoutarm"] = 1802
		},
		["The Completed Robe"] = 4786,
		["Shard of a Felhound"] = 4962,
		["Shard of an Infernal"] = 4963,
		["Returning the Cleansed Orb"] = 4976,
		["Recipe of the Kaldorei"] = 4161,
		["Deep Ocean, Vast Sea"] = 982,
		["Return to Podrig"] = 6324,
		["Trial at the Field of Giants"] = 1824,
		["Satyr Hooves"] = 1842,
		["Chimaeric Horn"] = 1844,
		["Dragonmaw Shinbones"] = 1846,
		["The Shattered Hand"] = 	{
			["Therzok"] = 		{
				["Is it not vexing to have the subject of your desire within your grasp, but to have no way of getting to it? Is it not vexing to have the subject of your desire within your grasp, but to have no way of getting to it?"] = 1858,
				["It is a fool who believes a charge with axe drawn is more dangerous than a knife in the dark. It is a fool who believes a charge with axe drawn is more dangerous than a knife in the dark."] = 1963
			}
		},
		["Fenwick Thatros"] = 1998,
		["Tools of the Trade"] = 1999,
		["Delivery to Andron Gant"] = 3542,
		["Fragments of the Orb of Orahil"] = 1799,
		["Items of Power"] = 1948,
		["Rituals of Power"] = 1951,
		["The Infernal Orb"] = 1954,
		["The Exorcism"] = 1955,
		["Power in Uldaman"] = 1956,
		["Mana Surges"] = 1957,
		["Tiara of the Deep"] = 2846,
		["Cleansing of the Orb of Orahil"] = 4961,
		["Get the Scoop"] = 1950,
		["Bingles' Missing Supplies"] = 2038,
		["Underground Assault"] = 2040,
		["Gyrodrillmatic Excavationators"] = 2928,
		["Gyromast's Revenge"] = 2078,
		["Gyromast's Retrieval"] = 2098,
		["The Manor, Ravenholdt"] = 6681,
		["Junkboxes Needed"] = 8249,
		["Dancing for Marzipan"] = 	{
			["Innkeeper Saelienne"] = 8357,
			["Innkeeper Pala"] = 8360
		},
		["Dolanaar Delivery"] = 2159,
		["Flexing for Nougat"] = 	{
			["Innkeeper Allison"] = 8356,
			["Innkeeper Gryshka"] = 8359
		},
		["New Year Celebrations!"] = 	{
			["Innkeeper Allison"] = 8860,
			["Innkeeper Pala"] = 8861
		},
		["A Task Unfinished"] = 1656,
		["Syndicate Emblems"] = 6701,
		["The Azure Key"] = 8236,
		["Supplies to Tannok"] = 2160,
		["The Shattered Necklace"] = 2198,
		["Lore for a Price"] = 2199,
		["Find the Gems"] = 	{
			["Talvash del Kissel"] = 2201,
			["Talvash's Scrying Bowl"] = 2201
		},
		["Restoring the Necklace"] = 2204,
		["Gnome Improvement"] = 2948,
		["Replacement Phial"] = 3375,
		["Incoming Gumdrop"] = 	{
			["Talvash del Kissel"] = 8355,
			["Kali Remik"] = 8358
		},
		["Translating the Journal"] = 2338,
		["Find the Gems and Power Source"] = 2339,
		["A Peon's Burden"] = 2161,
		["Ride to Orgrimmar"] = 6384,
		["Alther's Mill"] = 2282,
		["Ripple Delivery"] = 81,
		["Necklace Recovery"] = 2283,
		["Deliver the Gems"] = 2340,
		["Horns of Nez'ra"] = 2358,
		["Rise of the Silithid"] = 	{
			["Zilzibin Drumlore"] = 32,
			["Gracina Spiritmight"] = 		{
				["Peace and tranquility be upon you, stranger. Why have you sought me out this day? Peace and tranquility be upon you, stranger. Why have you sought me out this day?"] = 162,
				["Welcome to this blessed temple, friend. Your arrival here from Feathermoon Stronghold has been foretold to me. Do you have the report Shandris Feathermoon asked blessed temple, friend. Your arrival here from Feathermoon Stronghold has been foretold to me. Do you have the report Shandris Feathermoon asked you to bring?"] = 4267
			}
		},
		["Zukk'ash Report"] = 7732,
		["Plundering the Plunderers"] = 2381,
		["The Touch of Zanzil"] = 	{
			["Doc Mixilpixil"] = 		{
				["When you're ready for the examination, /lay down on the ground and I'll begin the phlebotomy. When you're ready for the examination, /lay down on the ground and I'll begin the phlebotomy."] = 2608,
				["If you want the 'itis' cured, you're going to have to try harder than that, $n. Where are the reagents for the cure? If you want the 'itis' cured, you're going to have to try harder than that, $n. Where are the reagents for the cure?"] = 2609
			}
		},
		["The Gordunni Orb"] = 3002,
		["Tears of the Moon"] = 2518,
		["Sathrah's Sacrifice"] = 2520,
		["The Sleeping Druid"] = 2541,
		["Druid of the Claw"] = 2561,
		["To Serve Kum'isha"] = 2521,
		["Kum'isha's Endeavors"] = 2522,
		["Everything Counts In Large Amounts"] = 3501,
		["One Draenei's Junk..."] = 3502,
		["Rescue OOX-22/FE!"] = 2767,
		["Gnome Engineering"] = 	{
			["Oglethorpe Obnoticus"] = 3635,
			["Tinkmaster Overspark"] = 3630
		},
		["Show Your Work"] = 	{
			["Oglethorpe Obnoticus"] = 3643,
			["Tinkmaster Overspark"] = 3641,
			["Nixx Sprocketspring"] = 3639
		},
		["Membership Card Renewal"] = 	{
			["Oglethorpe Obnoticus"] = 3647,
			["Tinkmaster Overspark"] = 3645,
			["Nixx Sprocketspring"] = 3644,
			["Vazario Linkgrease"] = 3646
		},
		["Secrets of the Colossus - Ashi"] = 8857,
		["Slake That Thirst"] = 379,
		["Tanaris Field Sampling"] = 654,
		["Another Power Source?"] = 841,
		["Wastewander Justice"] = 1690,
		["More Wastewander Justice"] = 1691,
		["Divino-matic Rod"] = 2768,
		["WANTED: Caliph Scorpidsting"] = 2781,
		["Water Pouch Bounty"] = 	{
			["Spigot Operator Luglunket"] = 		{
				["Got the five Wastewander water pouches we need? If you do, then the Gadgetzan Water Company Care Package, Model 103-XB, will be yours! Got the five Wastewander water pouches we need? If you do, then the Gadgetzan Water Company Care Package, Model 103-XB, will be yours!"] = 1707,
				["Back again, $n? If you have five more Wastewander water pouches, then I have a care package with your name on it! Back again, $n? If you have five more Wastewander water pouches, then I have a care package with your name on it!"] = 1878
			}
		},
		["Snickerfang Jowls"] = 2581,
		["Rage of Ages"] = 2582,
		["A Boar's Vitality"] = 2583,
		["Spirit of the Boar"] = 2584,
		["The Decisive Striker"] = 2585,
		["Salt of the Scorpok"] = 2586,
		["The Basilisk's Bite"] = 2601,
		["Infallible Mind"] = 2602,
		["Vulture's Vigor"] = 2603,
		["Spiritual Domination"] = 2604,
		["The Thirsty Goblin"] = 2605,
		["Delivery for Marin"] = 2661,
		["The Swamp Talker"] = 2623,
		["The Stones That Bind Us"] = 2681,
		["Fall From Grace"] = 2784,
		["A Tale of Sorrow"] = 2801,
		["Uniting the Shattered Amulet"] = 3627,
		["You Are Rakh'likh, Demon"] = 3628,
		["A Troubled Spirit"] = 8417,
		["Warrior Kinship"] = 8423,
		["War on the Shadowsworn"] = 8424,
		["Voodoo Feathers"] = 8425,
		["In Good Taste"] = 2606,
		["Sprinkle's Secret Ingredient"] = 2641,
		["The Scrimshank Redemption"] = 10,
		["Insect Part Analysis"] = 113,
		["Gadgetzan Water Survey"] = 992,
		["An Extraordinary Egg"] = 2747,
		["A Fine Egg"] = 2748,
		["An Ordinary Egg"] = 2749,
		["A Bad Egg"] = 2750,
		["The Borrower"] = 2941,
		["The Morrow Stone"] = 2942,
		["Return to Troyas"] = 2943,
		["Wandering Shay"] = 2845,
		["Items of Some Consequence"] = 2746,
		["Gahz'ridian"] = 3161,
		["The Stone Circle"] = 3444,
		["The Videre Elixir"] = 	{
			["Gregan Brewspewer"] = 4041,
			["Donova Snowden"] = 3909
		},
		["A Visit to Gregan"] = 4142,
		["Dark Heart"] = 3062,
		["Vengeance on the Northspring"] = 3063,
		["The Strength of Corruption"] = 4120,
		["Lethtendris's Web"] = 	{
			["Talo Thornhoof"] = 7489,
			["Latronicus Moonspear"] = 7488
		},
		["The Ogres of Feralas"] = 	{
			["Rok Orhan"] = 		{
				["Move swiftly, $N. Or is the task I requested too difficult? Move swiftly, $N. Or is the task I requested too difficult?"] = 2975,
				["Have you found the ruins, $N? Have you found the ruins, $N?"] = 2980
			}
		},
		["The Gordunni Scroll"] = 2978,
		["Dark Ceremony"] = 2979,
		["The Demon Hunter"] = 2744,
		["Loramus"] = 3141,
		["Azsharite"] = 3602,
		["Find OOX-17/TN!"] = 351,
		["Barbaric Battlements"] = 2751,
		["On Iron Pauldrons"] = 2752,
		["Trampled Under Foot"] = 2753,
		["Horns of Frenzy"] = 2754,
		["The Old Ways"] = 2756,
		["Booty Bay or Bust!"] = 2757,
		["In Search of Galvan"] = 2759,
		["The Origins of Smithing"] = 2758,
		["A Sticky Situation"] = 77,
		["The Mithril Order"] = 2760,
		["Smelt On, Smelt Off"] = 2761,
		["The Great Silver Deceiver"] = 2762,
		["The Art of the Imbue"] = 2763,
		["The Formation of Felbane"] = 3621,
		["Enchanted Azsharite Fel Weaponry"] = 3625,
		["A Good Head On Your Shoulders"] = 2771,
		["The World At Your Feet"] = 2772,
		["The Mithril Kid"] = 2773,
		["Troll Temper"] = 3042,
		["Did You Lose This?"] = 3321,
		["Find OOX-09/HL!"] = 485,
		["Find OOX-22/FE!"] = 2766,
		["Rin'ji's Secret"] = 2782,
		["Lines of Communication"] = 2995,
		["The Mark of Quality"] = 	{
			["Pratt McGrubben"] = 2821,
			["Jangdor Swiftstrider"] = 2822
		},
		["Wild Leather Armor"] = 	{
			["Pratt McGrubben"] = 2847,
			["Jangdor Swiftstrider"] = 2854
		},
		["Wild Leather Shoulders"] = 	{
			["Pratt McGrubben"] = 2848,
			["Jangdor Swiftstrider"] = 2855
		},
		["Wild Leather Vest"] = 	{
			["Pratt McGrubben"] = 2849,
			["Jangdor Swiftstrider"] = 2856
		},
		["Wild Leather Helmet"] = 	{
			["Pratt McGrubben"] = 2850,
			["Jangdor Swiftstrider"] = 2857
		},
		["Wild Leather Boots"] = 	{
			["Pratt McGrubben"] = 2851,
			["Jangdor Swiftstrider"] = 2858
		},
		["Wild Leather Leggings"] = 	{
			["Pratt McGrubben"] = 2852,
			["Jangdor Swiftstrider"] = 2859
		},
		["Improved Quality"] = 	{
			["Pratt McGrubben"] = 7733,
			["Jangdor Swiftstrider"] = 7734
		},
		["Pristine Yeti Hide"] = 7735,
		["Gnomer-gooooone!"] = 2843,
		["A Fine Mess"] = 2904,
		["Perfect Yeti Hide"] = 7738,
		["Dragonscale Leatherworking"] = 	{
			["Peter Galen"] = 5141,
			["Thorkaf Dragoneye"] = 5145
		},
		["Elemental Leatherworking"] = 	{
			["Sarah Tanner"] = 5144,
			["Brumn Winterhoof"] = 5146
		},
		["Tribal Leatherworking"] = 	{
			["Caryssia Moonhunter"] = 5143,
			["Se'Jib"] = 5148
		},
		["War on the Woodpaw"] = 2862,
		["Alpha Strike"] = 2863,
		["The Battle Plans"] = 2903,
		["Zukk'ash Infestation"] = 7730,
		["Stinglasher"] = 7731,
		["Scarab Shells"] = 2865,
		["Thistleshrub Valley"] = 3362,
		["Super Sticky"] = 4504,
		["Against the Hatecrest"] = 2869,
		["Against Lord Shalzaru"] = 2870,
		["Delivering the Relic"] = 2871,
		["The Mystery of Morrowgrain"] = 3791,
		["Morrowgrain to Feathermoon Stronghold"] = 3792,
		["The Knife Revealed"] = 4129,
		["Boat Wreckage"] = 4127,
		["Freed from the Hive"] = 4265,
		["Stoley's Shipment"] = 2873,
		["WANTED: Andre Firebeard"] = 2875,
		["Ship Schedules"] = 2876,
		["Southsea Shakedown"] = 8366,
		["Skulk Rock Clean-up"] = 2877,
		["Troll Necklace Bounty"] = 2880,
		["The High Wilderness"] = 2982,
		["The Super Snapper FX"] = 2944,
		["Moontouched Wildkin"] = 978,
		["Handle With Care"] = 3022,
		["Favored of Elune?"] = 3661,
		["The Grand Betrayal"] = 2929,
		["Save Techbot's Brain!"] = 2922,
		["Data Rescue"] = 2930,
		["Ivory Raptor Replacement"] = 7664,
		["Red Raptor Replacement"] = 7665,
		["Doling Justice"] = 	{
			["Jer'kai Moonweaver"] = 2970,
			["Tyrande Whisperwind"] = 2972
		},
		["Gordunni Cobalt"] = 2987,
		["Thadius Grimshade"] = 2990,
		["Nekrum's Medallion"] = 2991,
		["Velinde's Effects"] = 1038,
		["Return to Witch Doctor Uzer'i"] = 3122,
		["Testing the Vessel"] = 3123,
		["Hippogryph Muisek"] = 3124,
		["Faerie Dragon Muisek"] = 3125,
		["Treant Muisek"] = 3126,
		["Mountain Giant Muisek"] = 3127,
		["Natural Materials"] = 3128,
		["Clamlette Surprise"] = 6610,
		["The Isle of Dread!"] = 8585,
		["Dirge's Kickin' Chimaerok Chops"] = 8586,
		["Goblin Engineering"] = 3526,
		["Proof of Deed"] = 3182,
		["Suntara Stones"] = 	{
			["Curator Thorius"] = 3368,
			["Singed Letter"] = 3367
		},
		["Rise, Obsidion!"] = 3566,
		["Ride to Thunder Bluff"] = 6362,
		["Delivery to Archmage Xylem"] = 3561,
		["Sealed Azure Bag"] = 8234,
		["Encoded Fragments"] = 8235,
		["Magic Dust"] = 8251,
		["The Siren's Coral"] = 8252,
		["Destroy Morphaz"] = 8253,
		["Warlord Krellian"] = 9362,
		["Fragmented Magic"] = 9364,
		["A Crew Under Fire"] = 3382,
		["Mura Runetotem"] = 3301,
		["Seeping Corruption"] = 	{
			["Chemist Cuely"] = 3568,
			["Thersa Windsong"] = 3569
		},
		["Arcane Runes"] = 3449,
		["The Jeremiah Blues"] = 5049,
		["Courser Antlers"] = 8153,
		["Wavethrashing"] = 8231,
		["The Green Drake"] = 8232,
		["Of Coursers We Know"] = 8255,
		["The Ichor of Undeath"] = 8256,
		["A Refugee's Quandary"] = 3361,
		["The Glowing Shard"] = 6981,
		["Kim'jael Indeed!"] = 3601,
		["Kim'jael's 'Missing' Equipment"] = 5534,
		["Shadoweaver"] = 3379,
		["The Undermarket"] = 3385,
		["Divine Retribution"] = 3441,
		["The Flawless Flame"] = 3442,
		["Forging the Shaft"] = 3443,
		["The Flame's Casing"] = 3452,
		["The Torch of Retribution"] = 3453,
		["Volcanic Activity"] = 4502,
		["Return to Tymor"] = 3461,
		["Set Them Ablaze!"] = 3463,
		["Scourge of the Downs"] = 3523,
		["Screecher Spirits"] = 3520,
		["The Prophecy of Mosh'aru"] = 3527,
		["The God Hakkar"] = 3528,
		["The Ancient Egg"] = 4787,
		["The Runed Scroll"] = 3513,
		["Horde Presence"] = 3514,
		["The Warsong Reports"] = 6543,
		["Iverron's Antidote"] = 	{
			["Dirania Silvershine"] = 3521,
			["Iverron"] = 3522
		},
		["Stealing Knowledge"] = 3517,
		["Magatha's Payment to Jediga"] = 3562,
		["Jes'rimon's Payment to Jediga"] = 3563,
		["Andron's Payment to Jediga"] = 3564,
		["Xylem's Payment to Jediga"] = 3565,
		["Delivery to Jes'rimon"] = 3541,
		["Bone-Bladed Weapons"] = 4300,
		["It's a Secret to Everybody"] = 	{
			["Linken"] = 3845,
			["Donova Snowden"] = 3908
		},
		["Linken's Sword"] = 3914,
		["Linken's Adventure"] = 3961,
		["It's Dangerous to Go Alone"] = 3962,
		["The Smoldering Ruins of Thaurissan"] = 	{
			["Royal Historian Archesonus"] = 		{
				["Do you bring new information? Do you bring new information?"] = 3701,
				["Allow me to finish telling you the story of Thaurissan. Allow me to finish telling you the story of Thaurissan."] = 3702
			}
		},
		["The Royal Rescue"] = 4003,
		["Hilary's Necklace"] = 3741,
		["Researching the Corruption"] = 1275,
		["Kharan's Tale"] = 4342,
		["Un'Goro Soil"] = 	{
			["Jenal"] = 3764,
			["Ghede"] = 3761
		},
		["KILL ON SIGHT: Dark Iron Dwarves"] = 4081,
		["KILL ON SIGHT: High Ranking Dark Iron Officials"] = 4082,
		["Operation: Death to Angerforge"] = 4132,
		["Warlord's Command"] = 4903,
		["Lost Thunderbrew Recipe"] = 4134,
		["The Darkstone Tablet"] = 4768,
		["The Last Element"] = 7201,
		["Precarious Predicament"] = 4121,
		["Bijou's Reconnaissance Report"] = 4983,
		["The Pack Mistress"] = 4724,
		["Krom'Grul"] = 3822,
		["Disharmony of Flame"] = 3906,
		["Disharmony of Fire"] = 3907,
		["Morrowgrain to Thunder Bluff"] = 3804,
		["Flute of Xavaric"] = 939,
		["Silver Heart"] = 4084,
		["The Corruption of the Jadefire"] = 4421,
		["Felbound Ancients"] = 4441,
		["Further Corruption"] = 4906,
		["Aquementas"] = 4005,
		["Crystals of Power"] = 4284,
		["The Northern Pylon"] = 4285,
		["The Eastern Pylon"] = 4287,
		["The Western Pylon"] = 4288,
		["Larion and Muigin"] = 4145,
		["Zapper Fuel"] = 4146,
		["Bloodpetal Zapper"] = 4148,
		["Muigin and Larion"] = 4141,
		["Haze of Evil"] = 4143,
		["Bloodpetal Sprouts"] = 4144,
		["Extinguish the Firegut"] = 3823,
		["Gor'tesh the Brute Lord"] = 3824,
		["Ogre Head On A Stick = Party"] = 3825,
		["FIFTY! YEP!"] = 4283,
		["The Good Stuff"] = 4286,
		["An Orphan Looking For a Home"] = 3841,
		["A Short Incubation"] = 3842,
		["Expedition Salvation"] = 3881,
		["Williden's Journal"] = 3884,
		["Alien Ecology"] = 3883,
		["Roll the Bones"] = 3882,
		["Dadanga is Hungry!"] = 5150,
		["Milly's Harvest"] = 3904,
		["Strange Sources"] = 4842,
		["Threat of the Winterfall"] = 5082,
		["Winterfall Firewater"] = 5083,
		["Mystery Goo"] = 5085,
		["Toxic Horrors"] = 5086,
		["Winterfall Runners"] = 5087,
		["High Chief Winterfall"] = 5121,
		["The Final Piece"] = 5123,
		["Wenikee Boltbucket"] = 3921,
		["Nugget Slugs"] = 3922,
		["Rilli Greasygob"] = 3923,
		["Samophlange Manual"] = 3924,
		["A Taste of Flame"] = 	{
			["Cyrus Therepentous"] = 		{
				["<Cyrus's eyes form two blazing spheres.> <Cyrus's eyes form two blazing spheres.>"] = 4022,
				["Has the giant been felled? Has the giant been felled?"] = 4024
			}
		},
		["The Love Potion"] = 4201,
		["Rocknot's Ale"] = 4295,
		["Ulathek the Traitor"] = 7624,
		["Cleansing Felwood"] = 	{
			["Arathandris Silversky"] = 4101,
			["Maybess Riverbreeze"] = 4102
		},
		["Salve via Hunting"] = 	{
			["Arathandris Silversky"] = 4108,
			["Maybess Riverbreeze"] = 5887
		},
		["Salve via Mining"] = 	{
			["Arathandris Silversky"] = 4109,
			["Maybess Riverbreeze"] = 5888
		},
		["Salve via Gathering"] = 	{
			["Arathandris Silversky"] = 4105,
			["Maybess Riverbreeze"] = 5884
		},
		["Salve via Skinning"] = 	{
			["Arathandris Silversky"] = 4111,
			["Maybess Riverbreeze"] = 5890
		},
		["Salve via Disenchanting"] = 	{
			["Arathandris Silversky"] = 4107,
			["Maybess Riverbreeze"] = 5886
		},
		["The Heart of the Mountain"] = 4123,
		["Tablet of the Seven"] = 4296,
		["Ribbly Screwspigot"] = 4136,
		["Message to Maxwell"] = 5002,
		["Maxwell's Mission"] = 5081,
		["General Drakkisath's Command"] = 5089,
		["General Drakkisath's Demise"] = 5102,
		["Overmaster Pyron"] = 4262,
		["Incendius!"] = 4263,
		["Put Her Down"] = 4701,
		["Mother's Milk"] = 4866,
		["Doomrigger's Clasp"] = 4764,
		["A Little Slime Goes a Long Way"] = 	{
			["Laris Geardawdle"] = 		{
				["Some of the experiments I've done are fascinating. I think with a little more work, I'll be able to figure out the nature of these tied to the creation of this planet... almost like they're a secretion of it. But I can't prove or disprove it until I get more samples."] = 4512,
				["So many things to consider. But what does it mean? And how does it affect the lives of the people of Azeroth? So many things to consider. But what does it mean? And how does it affect the lives of the people of Azeroth?"] = 4513
			}
		},
		["Chasing A-Me 01"] = 	{
			["Karna Remtravel"] = 4245,
			["A-Me 01"] = 4244
		},
		["The Apes of Un'Goro"] = 4289,
		["The Fare of Lar'korwi"] = 4290,
		["The Scent of Lar'korwi"] = 4291,
		["The Bait for Lar'korwi"] = 4292,
		["The Mighty U'cha"] = 4301,
		["Toxic Test"] = 9051,
		["Bloodpetal Poison"] = 9052,
		["A Better Ingredient"] = 9053,
		["A Husband's Last Battle"] = 6162,
		["The Newest Member of the Family"] = 3843,
		["Food for Baby"] = 4297,
		["Galgar's Cactus Apple Surprise"] = 4402,
		["Libram of Rumination"] = 4463,
		["Libram of Constitution"] = 4481,
		["Libram of Tenacity"] = 4482,
		["Libram of Resilience"] = 4483,
		["Libram of Voracity"] = 4484,
		["Well of Corruption"] = 4505,
		["Corrupted Sabers"] = 4506,
		["A Little Help From My Friends"] = 4491,
		["Beware of Pterrordax"] = 4501,
		["Shizzle's Flyer"] = 4503,
		["Lost!"] = 4492,
		["Return to Nessa"] = 6343,
		["A Sample of Slime..."] = 4293,
		["... and a Batch of Ooze"] = 4294,
		["Melding of Influences"] = 4642,
		["Ascension..."] = 6601,
		["Blood of the Black Dragon Champion"] = 6602,
		["Fruit of the Sea"] = 1138,
		["The Family and the Fishing Pole"] = 1141,
		["Washed Ashore"] = 	{
			["Gwennyth Bly'Leggonde"] = 		{
				["It is only recently that these creatures started landing on the coast of Darkshore in such alarming numbers. I can't help but think that this is an ill omen of some sort. Recovering a sample of that creature's bones to the south would help us in Darnassus assess this situation!"] = 3524,
				["Once you have investigated the creature's remains in the water to the west of here, I should be able to file a proper report with Perhaps then we will be closer to discovering the reason why these unfortunate creatures choose to end their lives beached on the coast of Darkshore."] = 4681
			}
		},
		["Beached Sea Turtle"] = 	{
			["Gwennyth Bly'Leggonde"] = 		{
				["Hello $N - do you have any discoveries of creatures that have washed ashore to report on? Hello $N - do you have any discoveries of creatures that have washed ashore to report on?"] = 4722,
				["It is a pleasure to see you again, $N. We are making great strives in uncovering the mystery of why majestic sea creatures beach themselves on the Darkshore coastline, but with every question answered, two more are raised it seems. Are you here to offer us more aid in our research?"] = 4725,
				["Hello again, $N! Are you here to report on another discovery? Hello again, $N! Are you here to report on another discovery?"] = 4727,
				["Hello again, $N. The work you have done on behalf of the Temple of the Moon has been outstanding. Are we to be blessed with done on behalf of the Temple of the Moon has been outstanding. Are we to be blessed with more of your effort on our behalf?"] = 4731,
				["Greetings once again $N - do you have any more discoveries to report to the Temple of the Moon? Greetings once again $N - do you have any more discoveries to report to the Temple of the Moon?"] = 4732
			}
		},
		["Beached Sea Creature"] = 	{
			["Gwennyth Bly'Leggonde"] = 		{
				["Hello again, $N! Are you here to report on another discovery? Hello again, $N! Are you here to report on another discovery?"] = 4723,
				["Greetings once again, $N! What brings you back to Auberdine? Are you here to report on another discovery, perhaps? Greetings once again, $N! What brings you back to Auberdine? Are you here to report on another discovery, perhaps?"] = 4728,
				["Thanks be to Elune - I am glad to see you again, dear $N. The Temple of the Moon's work on the strange beaching phenomena dear $N. The Temple of the Moon's work on the strange beaching phenomena continues here in Darkshore. Might you have anything additional to offer us?"] = 4733
			}
		},
		["Bijou's Belongings"] = 4982,
		["Kibler's Exotic Pets"] = 4729,
		["En-Ay-Es-Tee-Why"] = 4862,
		["Broodling Essence"] = 4726,
		["Egg Freezing"] = 4734,
		["Egg Collection"] = 4735,
		["Return to Tinkee"] = 4810,
		["Seal of Ascension"] = 	{
			["Vaelan"] = 		{
				["Courage and patience above all else, $N! Courage and patience above all else, $N!"] = 4742,
				["Waste no time, $N. Nefarian works feverishly to unleash his evil upon our world. Waste no time, $N. Nefarian works feverishly to unleash his evil upon our world."] = 4743
			}
		},
		["Enraged Wildkin"] = 4864,
		["Finding the Source"] = 974,
		["Ursius of the Shardtooth"] = 5054,
		["Brumeran of the Chillwind"] = 5055,
		["Shy-Rotam"] = 5056,
		["Troubled Spirits of Kel'Theril"] = 5245,
		["Fragments of the Past"] = 	{
			["Aurora Skycaller"] = 		{
				["It is only in the pages of the sacred writings that I will be able to discern whether or not I can help you... It is only in the pages of the sacred writings that I will be able to discern whether or not I can help you..."] = 5246,
				["The relic must be placed in the hands of only the most trustworthy. It can not be stolen again... The relic must be placed in the hands of only the most trustworthy. It can not be stolen again..."] = 5247
			}
		},
		["Are We There, Yeti?"] = 	{
			["Umi Rumplesnicker"] = 		{
				["I've just about finished attaching the fur, $N. Please, hurry back with those horns! I've just about finished attaching the fur, $N. Please, hurry back with those horns!"] = 977,
				["I've got lots to get started on here. Please get me those furs as soon as you can! I've got lots to get started on here. Please get me those furs as soon as you can!"] = 3783,
				["I can't wait to hear how my friends react! They'll never expect it! I can't wait to hear how my friends react! They'll never expect it!"] = 5163
			}
		},
		["Wild Guardians"] = 	{
			["Trull Failbane"] = 		{
				["Report back to me after you have completed the task I gave you. Report back to me after you have completed the task I gave you."] = 4521,
				["You know your orders, $N. You know your orders, $N."] = 4721,
				["Don't tell me that you're too scared! Get going! Don't tell me that you're too scared! Get going!"] = 4741
			}
		},
		["Luck Be With You"] = 969,
		["Frostsaber E'ko"] = 4801,
		["Winterfall E'ko"] = 4802,
		["Shardtooth E'ko"] = 4803,
		["Chillwind E'ko"] = 4804,
		["Ice Thistle E'ko"] = 4805,
		["Frostmaul E'ko"] = 4806,
		["Wildkin E'ko"] = 4807,
		["The Test of Skulls, Scryer"] = 6582,
		["The Test of Skulls, Somnus"] = 6583,
		["The Test of Skulls, Chronalis"] = 6584,
		["The Test of Skulls, Axtroz"] = 6585,
		["Wind Rider"] = 4767,
		["Arikara"] = 5088,
		["The Final Tablets"] = 4788,
		["The Lost Tablets of Mosh'aru"] = 5065,
		["Felnok Steelspring"] = 4808,
		["Chillwind Horns"] = 4809,
		["Message to Freewind Post"] = 4542,
		["Pacify the Centaur"] = 4841,
		["Grimtotem Spying"] = 5064,
		["Wanted - Arnak Grimtotem"] = 5147,
		["Alien Egg"] = 4821,
		["A Bundle of Trouble"] = 5545,
		["Frostsaber Provisions"] = 4970,
		["Winterfall Intrusion"] = 5201,
		["Rampaging Giants"] = 5981,
		["Finkle Einhorn, At Your Service!"] = 5047,
		["Cap of the Scarlet Savant"] = 5063,
		["Leggings of Arcana"] = 5067,
		["Breastplate of Bloodthirst"] = 5068,
		["Fiery Plate Gauntlets"] = 5124,
		["Free at Last"] = 4904,
		["Gordo's Task"] = 5481,
		["Doom Weed"] = 5482,
		["A Matter of Time"] = 4971,
		["Counting Out Time"] = 	{
			["Chromie"] = 		{
				["The time trinkets I seek are simple devices. They are watches mainly, and their hands are trapped forever when the plague first ravaged Andorhal. Time is the watches you bring to me will invariably find themselves counted out back to their homes... that is, so long as the disturbances continue here."] = 4972,
				["The watches of Andorhal, much like the large clock on the ruins of the town hall, all are frozen in time at three o'clock. This what happened that day, it has shaped the flow of time as you mortals perceive it. The bronze dragonflight must persevere in protecting the timeline!"] = 4973
			}
		},
		["A Strange Historian"] = 5153,
		["The Annals of Darrowshire"] = 5154,
		["Return to Chromie"] = 5941,
		["Tormented By the Past"] = 5248,
		["The Wildlife Suffers Too"] = 	{
			["Mulgris Deepriver"] = 		{
				["The wolves that are infected with the plague must be put down, $N. The disease they carry cannot be cured. I tried... I tried until the plague must be put down, $N. The disease they carry cannot be cured. I tried... I tried until I succumbed to the plague myself."] = 4984,
				["I hear your footsteps, $N. My vision has faded from me, but I still am able to sense things around me. Have you ended the My vision has faded from me, but I still am able to sense things around me. Have you ended the misery of the disease-ridden grizzlies?"] = 4985
			}
		},
		["Good Luck Charm"] = 5050,
		["Two Halves Become One"] = 5051,
		["Better Late Than Never"] = 	{
			["Royal Overseer Bauhaus"] = 5023,
			["Royal Factor Bathrilor"] = 5022
		},
		["Urok Doomhowl"] = 4867,
		["Alas, Andorhal"] = 	{
			["High Executor Derrington"] = 105,
			["Commander Ashlam Valorfist"] = 211
		},
		["All Along the Watchtowers"] = 	{
			["High Executor Derrington"] = 5098,
			["Commander Ashlam Valorfist"] = 5097
		},
		["Clear the Way"] = 5092,
		["Inert Scourgestones"] = 8416,
		["Forging the Mightstone"] = 8418,
		["Minion's Scourgestones"] = 	{
			["Argent Officer Garush"] = 5402,
			["Argent Officer Pureheart"] = 5408,
			["Duke Nicholas Zverenhoff"] = 5510
		},
		["Invader's Scourgestones"] = 	{
			["Argent Officer Garush"] = 5403,
			["Argent Officer Pureheart"] = 5407,
			["Duke Nicholas Zverenhoff"] = 5509
		},
		["Corruptor's Scourgestones"] = 	{
			["Argent Officer Garush"] = 5406,
			["Argent Officer Pureheart"] = 5404,
			["Duke Nicholas Zverenhoff"] = 5508
		},
		["The Everlook Report"] = 	{
			["Argent Officer Garush"] = 6029,
			["Argent Officer Pureheart"] = 6028
		},
		["Mantles of the Dawn"] = 	{
			["Argent Quartermaster Hasana"] = 5504,
			["Argent Quartermaster Lightspark"] = 5507,
			["Quartermaster Miranda Breechlock"] = 5513
		},
		["Chromatic Mantle of the Dawn"] = 	{
			["Argent Quartermaster Hasana"] = 5524,
			["Argent Quartermaster Lightspark"] = 5521,
			["Quartermaster Miranda Breechlock"] = 5517
		},
		["The Medallion of Faith"] = 5122,
		["The Demon Forge"] = 5127,
		["Words of the High Chief"] = 5128,
		["Verifying the Corruption"] = 5156,
		["Forces of Jaedenar"] = 5155,
		["Collection of the Corrupt Water"] = 5157,
		["Cleansed Water Returns to Felwood"] = 5159,
		["Dousing the Flames of Protection"] = 5165,
		["A Final Blow"] = 5242,
		["Blood of Morphaz"] = 8257,
		["Pamela's Doll"] = 5149,
		["The Battle of Darrowshire"] = 5721,
		["The Matron Protectorate"] = 5160,
		["Hypercapacitor Gizmo"] = 5151,
		["Breastplate of the Chromatic Flight"] = 5166,
		["Legplates of the Chromatic Defier"] = 5167,
		["A Strange Red Key"] = 5202,
		["Rescue From Jaedenar"] = 5203,
		["The Remains of Trey Lightforge"] = 5385,
		["Retribution of the Light"] = 5204,
		["Barov Family Fortune"] = 	{
			["Alexi Barov"] = 5341,
			["Weldon Barov"] = 5343
		},
		["The Last Barov"] = 	{
			["Alexi Barov"] = 5342,
			["Weldon Barov"] = 5344
		},
		["The Great Fras Siabi"] = 5214,
		["That's Asking A Lot"] = 6026,
		["When Smokey Sings, I Get Violent"] = 6041,
		["Secrets of the Colossus - Zora"] = 8859,
		["Dawn's Gambit"] = 4771,
		["The Flesh Does Not Lie"] = 5212,
		["The Active Agent"] = 5213,
		["Plagued Hatchlings"] = 5529,
		["Betina Bigglezink"] = 5531,
		["Healthy Dragon Scale"] = 5582,
		["Houses of the Holy"] = 5243,
		["The Dying, Ras Frostwhisper"] = 5462,
		["Menethil's Gift"] = 	{
			["Leonid Barthalomew the Revered"] = 5464,
			["Menethil's Gift"] = 5463
		},
		["Leonid Barthalomew"] = 5522,
		["Zaeldarr the Outcast"] = 6021,
		["The Archivist"] = 5251,
		["The Truth Comes Crashing Down"] = 5262,
		["Above and Beyond"] = 5263,
		["Duke Nicholas Zverenhoff"] = 6030,
		["Return to Chillwind Camp"] = 	{
			["High Priestess MacDonnell"] = 		{
				["Welcome back to the relative safety of Chillwind Camp, $N. What progress on the cauldrons do you have to report? Welcome back to the relative safety of Chillwind Camp, $N. What progress on the cauldrons do you have to report?"] = 5217,
				["We know that each cauldron employs a different mix of reagents to generate its plague-inducing toxin; likewise, we know that we will need to develop counter agent that is unique for each cauldron. Your sample from Dalson's Tears will be the key to figure out that cauldron's distinct reagent requirement."] = 5220,
				["Once we successfully analyze the sample drawn from the Writhing Haunt's cauldron, it will provide us with a third avenue to deliver a devastating counter the sample drawn from the Writhing Haunt's cauldron, it will provide us with a third avenue to deliver a devastating counter agent onto the Scourge!"] = 5223,
				["Gahrron's Withering houses the last cauldron here in the east that we need access to. Once we have a sample of the plague it spews through four separate vessels! The Scourge will be hard pressed to keep us out of all four, even with the power of Kel'Thuzad behind them."] = 5226
			}
		},
		["Return to the Bulwark"] = 	{
			["Shadow Priestess Vandis"] = 		{
				["Welcome back to the relative safety of the Bulwark, $N. What progress on the cauldrons do you have to report? Welcome back to the relative safety of the Bulwark, $N. What progress on the cauldrons do you have to report?"] = 5230,
				["We know that each cauldron employs a different mix of reagents to generate its plague-inducing toxin; likewise, we know that we will need to develop counter agent that is unique for each cauldron. Your sample from Dalson's Tears will be the key to figure out that cauldron's distinct reagent requirement."] = 5232,
				["Once we successfully analysis the sample drawn from the Writhing Haunt's cauldron, it will provide us with a third avenue to deliver a devastating counter the sample drawn from the Writhing Haunt's cauldron, it will provide us with a third avenue to deliver a devastating counter agent against the Scourge!"] = 5234,
				["Gahrron's Withering houses the last cauldron that we need to acquire access to here in the west. Once we have a sample of the plague through four separate vessels! The Scourge will be hard pressed to keep us out of all four, even with the power of Kel'Thuzad behind them."] = 5236
			}
		},
		["The Key to Scholomance"] = 	{
			["Alchemist Arbington"] = 5505,
			["Apothecary Dithers"] = 5511
		},
		["Skeletal Fragments"] = 	{
			["Alchemist Arbington"] = 5537,
			["Apothecary Dithers"] = 964
		},
		["Fire Plume Forged"] = 	{
			["Alchemist Arbington"] = 5801,
			["Apothecary Dithers"] = 5802
		},
		["Araj's Scarab"] = 	{
			["Alchemist Arbington"] = 5803,
			["Apothecary Dithers"] = 5804
		},
		["Heroes of Darrowshire"] = 5168,
		["Villains of Darrowshire"] = 5181,
		["Marauders of Darrowshire"] = 5206,
		["Brother Carlin"] = 5210,
		["Defenders of Darrowshire"] = 5211,
		["Remorseful Highborne"] = 5252,
		["The Restless Souls"] = 5282,
		["The Way of the Weaponsmith"] = 	{
			["Ironus Coldsteel"] = 5284,
			["Borgosh Corebender"] = 5302
		},
		["Sweet Serenity"] = 5305,
		["Snakestone of the Shadow Huntress"] = 5306,
		["Corruption"] = 5307,
		["Doctor Theolen Krastinov, the Butcher"] = 5382,
		["Kirtonos the Herald"] = 5384,
		["Krastinov's Bag of Horrors"] = 5515,
		["The Sleeper Has Awakened"] = 5321,
		["Family Tree"] = 5361,
		["Catch of the Day"] = 5386,
		["The Human, Ras Frostwhisper"] = 5461,
		["Soulbound Keepsake"] = 5465,
		["The Lich, Ras Frostwhisper"] = 5466,
		["Fish in a Bucket"] = 5421,
		["Lazy Peons"] = 5441,
		["Thazz'ril's Pick"] = 6394,
		["Emphasis on Sacrifice"] = 7637,
		["Bone Collector"] = 5501,
		["Superior Armaments of Battle - Friend of the Dawn"] = 9221,
		["Epic Armaments of Battle - Friend of the Dawn"] = 9222,
		["Superior Armaments of Battle - Honored Amongst the Dawn"] = 9223,
		["Epic Armaments of Battle - Honored Amongst the Dawn"] = 9224,
		["Epic Armaments of Battle - Revered Amongst the Dawn"] = 9225,
		["Superior Armaments of Battle - Revered Amongst the Dawn"] = 9226,
		["Superior Armaments of Battle - Exalted Amongst the Dawn"] = 9227,
		["Epic Armaments of Battle - Exalted Amongst the Dawn"] = 9228,
		["Spiritual Unrest"] = 5535,
		["A Land Filled with Hatred"] = 5536,
		["Timbermaw Ally"] = 8460,
		["Feathers for Grazle"] = 8466,
		["The Root of All Evil"] = 8481,
		["Winterfall Activity"] = 8464,
		["Beads for Salfa"] = 8469,
		["Runecloth"] = 6031,
		["Sacred Cloth"] = 6032,
		["Deadwood Ritual Totem"] = 8470,
		["Winterfall Ritual Totem"] = 8471,
		["Kodo Roundup"] = 5561,
		["Bodyguard for Hire"] = 5821,
		["Gizelton Caravan"] = 5943,
		["Unfinished Business"] = 	{
			["Kirsta Deepshadow"] = 		{
				["How is it going, $N? Are they stronger than you thought? I hope not. If I'm going to follow through here, then it's going to going to follow through here, then it's going to require a heck of a lot more strength than what I've already asked you to do."] = 6004,
				["Have you found them yet, $N? With the two of them taken care of, I can proceed to enter Hearthglen to take a closer look to enter Hearthglen to take a closer look at their setup. I can't do it without your help. Please, find Radley and Durgen for me."] = 6023,
				["It's a dangerous task, $n. I envy your courage. It's a dangerous task, $n. I envy your courage."] = 6025
			}
		},
		["A Plague Upon Thee"] = 	{
			["Mickey Levine"] = 		{
				["Do you have the termites yet, $N? I am sure it is obvious to a smart $C like yourself. Once we have enough of them, we'll is obvious to a smart $C like yourself. Once we have enough of them, we'll make sure no one can use the lumber mill ever again!"] = 5901,
				["Have you done it, $N? Have you released the termites in the lumber mill? It was bad enough that my family lost their jobs and lives, lost their jobs and lives, but then to see the place where my childhood was spent taken over by those disgusting so-called holy men... pfah!!"] = 6390
			},
			["Nathaniel Dumah"] = 		{
				["Did you find the termite mounds, $N? I've heard they are all over Plaguewood. Did you find the termite mounds, $N? I've heard they are all over Plaguewood."] = 5903,
				["Have you done it, $N? Have you released the termites? The Light help us if the Scarlet Crusade were able to hold onto both the mill and Hearthglen. They should have neither. They're just capitalizing on the victims of the last war and should be put down like rabid animals!"] = 6389
			}
		},
		["Hand of Iruxos"] = 5381,
		["Portals of the Legion"] = 5581,
		["Vyletongue Corruption"] = 	{
			["Talendria"] = 7041,
			["Vark Battlescar"] = 7029
		},
		["The Dunemaul Compound"] = 5863,
		["Shards of the Felvine"] = 5526,
		["A Reliquary of Purity"] = 5527,
		["Trial of the Sea Lion"] = 30,
		["Curing the Sick"] = 	{
			["Dendrite Starblaze"] = 		{
				["Have you completed what was asked of you by Alanndarian Nightsong of Auberdine? Your work is not complete unless it is. Have you completed what was asked of you by Alanndarian Nightsong of Auberdine? Your work is not complete unless it is."] = 6124,
				["Have you completed what was asked of you by Tonga Runetotem at the Crossroads? Your work is not complete unless it is. Have you completed what was asked of you by Tonga Runetotem at the Crossroads? Your work is not complete unless it is."] = 6129
			}
		},
		["One Shot.  One Kill."] = 5713,
		["Azuregos's Magical Ledger"] = 8575,
		["Scrying Goggles? No Problem!"] = 8578,
		["Return to Narain"] = 8587,
		["rAnS0m"] = 8598,
		["Love Song for Narain"] = 8599,
		["The Only Prescription"] = 8620,
		["The Good News and The Bad News"] = 8728,
		["Warsong Supplies"] = 6571,
		["Seed of Life"] = 7066,
		["Shrouded in Nightmare"] = 8446,
		["The Nightmare's Corruption"] = 8735,
		["Testing an Enemy's Strength"] = 5723,
		["Returning the Lost Satchel"] = 5724,
		["Avenge My Village"] = 6548,
		["Kill Grundig Darkcloud"] = 6629,
		["Harpies Threaten"] = 6282,
		["Bloodfury Bloodline"] = 6283,
		["Arachnophobia"] = 6284,
		["Boulderslide Ravine"] = 6421,
		["Earthen Arise"] = 6481,
		["Elemental War"] = 6393,
		["Sceptre of Light"] = 5741,
		["Book of the Ancients"] = 6027,
		["Cycle of Rebirth"] = 6301,
		["New Life"] = 6381,
		["Find Myranda"] = 5861,
		["Mistress of Deception"] = 6568,
		["Oculus Illusions"] = 6569,
		["To Kill With Purpose"] = 6022,
		["Un-Life's Little Annoyances"] = 6042,
		["The Ranger Lord's Behest"] = 6133,
		["Duskwing, Oh How I Hate Thee..."] = 6135,
		["The Corpulent One"] = 6136,
		["The Crimson Courier"] = 6145,
		["The Scarlet Oracle, Demetria"] = 6148,
		["Ramstein"] = 6163,
		["Nathanos' Ruse"] = 6146,
		["Umber, Archivist"] = 6844,
		["Welcome!"] = 	{
			["Merissa Stilwell"] = 5805,
			["Yori Crackhelm"] = 5841,
			["Orenthil Whisperwind"] = 5842,
			["Magga"] = 5843,
			["Vorn Skyseer"] = 5844,
			["Claire Willower"] = 5847
		},
		["Clam Bait"] = 6142,
		["Irondeep Supplies"] = 	{
			["Stormpike Quartermaster"] = 5892,
			["Frostwolf Quartermaster"] = 6985
		},
		["Coldtooth Supplies"] = 	{
			["Stormpike Quartermaster"] = 6982,
			["Frostwolf Quartermaster"] = 5893
		},
		["Other Fish to Fry"] = 6143,
		["Augustus' Receipt Book"] = 6164,
		["The Eastern Plagues"] = 6185,
		["Calling in the Reserves"] = 5881,
		["Sharptalon's Claw"] = 2,
		["Ursangous's Paw"] = 23,
		["Shadumbra's Head"] = 24,
		["The Lost Pages"] = 6504,
		["Naga at the Zoram Strand"] = 6442,
		["Troll Charm"] = 6462,
		["Satyr Horns"] = 6441,
		["Warsong Saw Blades"] = 6581,
		["Je'neu of the Earthen Ring"] = 824,
		["The Essence of Aku'Mai"] = 6563,
		["Allegiance to the Old Gods"] = 	{
			["Je'neu Sancrea"] = 		{
				["Yes, $N? What is it you need? There is still much I must learn about the crystals the naga are gathering. Yes, $N? What is it you need? There is still much I must learn about the crystals the naga are gathering."] = 6564,
				["Have you found him yet, $N? Lorgus must be stopped! Have you found him yet, $N? Lorgus must be stopped!"] = 6565
			}
		},
		["Amongst the Ruins"] = 6921,
		["Baron Aquanis"] = 6922,
		["Stonetalon Standstill"] = 25,
		["The Befouled Element"] = 1918,
		["Bring Back the Mug"] = 3365,
		["Between a Rock and a Thistlefur"] = 216,
		["King of the Foulweald"] = 6621,
		["Blood Feeders"] = 6461,
		["Freedom to Ruul"] = 6482,
		["Warsong Scout Update"] = 6547,
		["Warsong Runner Update"] = 6545,
		["Warsong Outrider Update"] = 6546,
		["A Host of Evil"] = 6626,
		["Ashenvale Outrunners"] = 6503,
		["Torek's Assault"] = 6544,
		["Nat Pagle, Angler Extreme"] = 6607,
		["Nat's Measuring Tape"] = 8227,
		["Triage"] = 	{
			["Doctor Gregory Victor"] = 6622,
			["Doctor Gustaf VanHowzen"] = 6624
		},
		["Favor Amongst the Brotherhood, Dark Iron Ore"] = 6642,
		["Favor Amongst the Brotherhood, Fiery Core"] = 6643,
		["Favor Amongst the Brotherhood, Lava Core"] = 6644,
		["Favor Amongst the Brotherhood, Core Leather"] = 6645,
		["Favor Amongst the Brotherhood, Blood of the Mountain"] = 6646,
		["A Binding Contract"] = 7604,
		["Deeprun Rat Roundup"] = 6661,
		["Me Brother, Nipsy"] = 6662,
		["More Booty!"] = 6741,
		["Enemy Booty"] = 7224,
		["Call of Air - Guse's Fleet"] = 6825,
		["Call of Air - Jeztor's Fleet"] = 6826,
		["Call of Air - Mulverick's Fleet"] = 6827,
		["Wasteland"] = 1124,
		["The Spirits of Southwind"] = 1125,
		["Hive in the Tower"] = 1126,
		["Lokholar the Ice Lord"] = 6801,
		["A Gallon of Blood"] = 7385,
		["More Armor Scraps"] = 6781,
		["Armor Scraps"] = 7223,
		["Poisoned Water"] = 6804,
		["Stormers and Rumblers"] = 6805,
		["Eye of the Emberseer"] = 6821,
		["The Molten Core"] = 6822,
		["Hands of the Enemy"] = 6824,
		["Material Assistance"] = 7667,
		["The Darkreaver Menace"] = 8258,
		["You're a Mean One..."] = 	{
			["Kaymard Copperpinch"] = 6983,
			["Wulmort Jinglepocket"] = 7043
		},
		["Metzen the Reindeer"] = 	{
			["Kaymard Copperpinch"] = 8746,
			["Wulmort Jinglepocket"] = 8762
		},
		["Call of Air - Ichman's Fleet"] = 6943,
		["Call of Air - Slidore's Fleet"] = 6942,
		["Call of Air - Vipore's Fleet"] = 6941,
		["Ram Hide Harnesses"] = 7002,
		["Ivus the Forest Lord"] = 6881,
		["Crystal Cluster"] = 7386,
		["Treats for Greatfather Winter"] = 7025,
		["Treats for Great-father Winter"] = 6962,
		["Begin the Attack!"] = 6846,
		["Wanted: DWARVES!"] = 7401,
		["Ram Riding Harnesses"] = 7026,
		["Empty Stables"] = 	{
			["Frostwolf Stable Master"] = 7001,
			["Stormpike Stable Master"] = 7027
		},
		["Twisted Evils"] = 7028,
		["Corruption of Earth and Seed"] = 	{
			["Keeper Marandis"] = 7065,
			["Selendra"] = 7064
		},
		["Legends of Maraudon"] = 7044,
		["The Scepter of Celebras"] = 7046,
		["The Pariah's Instructions"] = 7067,
		["The Graveyards of Alterac"] = 7082,
		["Towers and Bunkers"] = 	{
			["Corporal Teeka Bloodsnarl"] = 7101,
			["Sergeant Durgen Stormpike"] = 7102
		},
		["Capture a Mine"] = 	{
			["Corporal Teeka Bloodsnarl"] = 7124,
			["Sergeant Durgen Stormpike"] = 7122
		},
		["Alterac Valley Graveyards"] = 7081,
		["The Battle of Alterac"] = 7141,
		["Proving Grounds"] = 	{
			["Warmaster Laggrond"] = 7161,
			["Lieutenant Haggerdin"] = 7162
		},
		["Rise and Be Recognized"] = 7168,
		["Honored Amongst the Guard"] = 7169,
		["Earned Reverence"] = 7170,
		["Legendary Heroes"] = 7171,
		["The Eye of Command"] = 7172,
		["A Fair Trade"] = 7341,
		["Arrows Are For Sissies"] = 7342,
		["Favor Amongst the Darkspear"] = 7361,
		["Ally of the Tauren"] = 7362,
		["Jaina's Autograph"] = 558,
		["The Bough of the Eternals"] = 1479,
		["The Stonewrought Dam"] = 1558,
		["Spooky Lighthouse"] = 1687,
		["You Scream, I Scream..."] = 	{
			["Human Orphan"] = 4822,
			["Orcish Orphan"] = 915
		},
		["Unfinished Gordok Business"] = 7703,
		["The Gordok Ogre Suit"] = 	{
			["Knot Thimblejack"] = 		{
				["The Ogre Tannin is probably the toughest thing to find for what I need to make the suit - I think they have some upstairs? me the things I need, and I'll whip you up an ogre suit that will fool Captain Kromcrush into thinking you're one of his men."] = 5518,
				["Need another suit, do ya? Well, I'm not going anywhere soon it seems - bring me the same things I asked for from before, and I'm not going anywhere soon it seems - bring me the same things I asked for from before, and I'll make you another ogre suit."] = 5519
			}
		},
		["Free Knot!"] = 7429,
		["Examine the Vessel"] = 7785,
		["Thunderaan the Windseeker"] = 7786,
		["Rise, Thunderfury!"] = 7787,
		["Pusillin and the Elder Azj'Tordin"] = 7441,
		["The Madness Within"] = 7461,
		["Arcane Refreshment"] = 7463,
		["Libram of Rapidity"] = 7483,
		["Libram of Focus"] = 7484,
		["Libram of Protection"] = 7485,
		["Enchanted Thorium Platemail: Volume I"] = 7649,
		["Enchanted Thorium Platemail: Volume II"] = 7650,
		["Enchanted Thorium Platemail: Volume III"] = 7651,
		["Elven Legends"] = 	{
			["Sage Korolusk"] = 7481,
			["Scholar Runethorn"] = 7482
		},
		["Holy Bologna: What the Light Won't Tell You"] = 7504,
		["Frost Shock and You"] = 7505,
		["The Emerald Dream..."] = 7506,
		["The Light and How To Swing It"] = 7501,
		["Harnessing Shadows"] = 7502,
		["The Greatest Race of Hunters"] = 7503,
		["Garona: A Study on Stealth and Treachery"] = 7498,
		["Codex of Defense"] = 7499,
		["The Arcanist's Cookbook"] = 7500,
		["Attunement to the Core"] = 7848,
		["Rage of Blood"] = 7563,
		["Wildeyes"] = 7564,
		["Xorothian Stardust"] = 7625,
		["Bell of Dethmoora"] = 7626,
		["Wheel of the Black March"] = 7627,
		["Doomsday Candle"] = 7628,
		["Imp Delivery"] = 7629,
		["Arcanite"] = 7630,
		["Down at the Docks"] = 910,
		["Gateway to the Frontier"] = 911,
		["Cairne's Hoofprint"] = 925,
		["Lordaeron Throne Room"] = 1800,
		["A Warden of the Alliance"] = 171,
		["A Warden of the Horde"] = 5502,
		["The Prison's Bindings"] = 7581,
		["The Prison's Casing"] = 7582,
		["Suppression"] = 7583,
		["Kroshius' Infernal Core"] = 7603,
		["Flawless Fel Essence"] = 7602,
		["An Imp's Request"] = 8419,
		["Hot and Itchy"] = 8420,
		["The Wrong Stuff"] = 8421,
		["Trolls of a Feather"] = 8422,
		["Arena Grandmaster"] = 7838,
		["The Ancient Leaf"] = 	{
			["Vartrus the Ancient"] = 7632,
			["Stoma the Ancient"] = 7632,
			["Hastat the Ancient"] = 7632
		},
		["Stave of the Ancients"] = 7636,
		["A Proper String"] = 7635,
		["Ancient Sinew Wrapped Lamina"] = 7634,
		["Ancient Equine Spirit"] = 7643,
		["Imperial Plate Belt"] = 7653,
		["Imperial Plate Boots"] = 7654,
		["Imperial Plate Bracer"] = 7655,
		["Imperial Plate Chest"] = 7656,
		["Imperial Plate Helm"] = 7657,
		["Imperial Plate Leggings"] = 7658,
		["Imperial Plate Shoulders"] = 7659,
		["Judgment and Redemption"] = 7647,
		["What the Flux?"] = 7722,
		["Restoring Fiery Flux Supplies via Kingsblood"] = 7736,
		["Gaining Even More Acceptance"] = 7737,
		["Restoring Fiery Flux Supplies via Iron"] = 8241,
		["Restoring Fiery Flux Supplies via Heavy Leather"] = 8242,
		["Secrets of the Colossus - Regal"] = 8858,
		["STOLEN: Smithing Tuyere and Lookout's Spyglass"] = 7728,
		["JOB OPPORTUNITY: Culling the Competition"] = 7729,
		["Curse These Fat Fingers"] = 7723,
		["Fiery Menace!"] = 7724,
		["Incendosaurs? Whateverosaur is More Like It"] = 7727,
		["Look at the Size of It!"] = 7704,
		["WANTED: Overseer Maltorius"] = 7701,
		["Zapped Giants"] = 7003,
		["Fuel for the Zapping"] = 7721,
		["Again With the Zapped Giants"] = 7725,
		["Refuel for the Zapping"] = 7726,
		["A Donation of Wool"] = 	{
			["Clavicus Knavingham"] = 7791,
			["Mistina Steelshield"] = 7802,
			["Bubulo Acerbus"] = 7807,
			["Rashona Straglash"] = 7826,
			["Vehena"] = 7833,
			["Rumstag Proudstrider"] = 7820,
			["Ralston Farnsley"] = 7813,
			["Dugiru"] = 7792
		},
		["A Donation of Silk"] = 	{
			["Clavicus Knavingham"] = 7793,
			["Mistina Steelshield"] = 7803,
			["Bubulo Acerbus"] = 7808,
			["Rashona Straglash"] = 7827,
			["Vehena"] = 7834,
			["Rumstag Proudstrider"] = 7821,
			["Ralston Farnsley"] = 7814,
			["Dugiru"] = 7798
		},
		["A Donation of Mageweave"] = 	{
			["Clavicus Knavingham"] = 7794,
			["Mistina Steelshield"] = 7804,
			["Bubulo Acerbus"] = 7809,
			["Raedon Duskstriker"] = 7799,
			["Rashona Straglash"] = 7831,
			["Vehena"] = 7835,
			["Rumstag Proudstrider"] = 7822,
			["Ralston Farnsley"] = 7817
		},
		["A Donation of Runecloth"] = 	{
			["Clavicus Knavingham"] = 7795,
			["Mistina Steelshield"] = 7805,
			["Bubulo Acerbus"] = 7811,
			["Raedon Duskstriker"] = 7800,
			["Rashona Straglash"] = 7824,
			["Vehena"] = 7836,
			["Rumstag Proudstrider"] = 7823,
			["Ralston Farnsley"] = 7818
		},
		["Additional Runecloth"] = 	{
			["Clavicus Knavingham"] = 7796,
			["Mistina Steelshield"] = 7806,
			["Bubulo Acerbus"] = 7812,
			["Raedon Duskstriker"] = 7801,
			["Rashona Straglash"] = 7832,
			["Vehena"] = 7837,
			["Rumstag Proudstrider"] = 7825,
			["Ralston Farnsley"] = 7819
		},
		["Lard Lost His Lunch"] = 7840,
		["Dark Vessels"] = 7850,
		["Wanted: Vile Priestess Hexx and Her Minions"] = 7861,
		["Job Opening: Guard Captain of Revantusk Village"] = 7862,
		["Vilebranch Hooligans"] = 7839,
		["Message to the Wildhammer"] = 7841,
		["Another Message to the Wildhammer"] = 7842,
		["The Final Message to the Wildhammer"] = 7843,
		["Cannibalistic Cousins"] = 7844,
		["Snapjaws, Mon!"] = 7815,
		["Gammerita, Mon!"] = 7816,
		["Stalking the Stalkers"] = 7828,
		["Hunt the Savages"] = 7829,
		["Avenging the Fallen"] = 7830,
		["Separation Anxiety"] = 7849,
		["Recover the Key!"] = 7846,
		["The Darkmoon Faire"] = 7905,
		["5 Tickets - Darkmoon Flower"] = 7930,
		["5 Tickets - Minor Darkmoon Prize"] = 7931,
		["12 Tickets - Lesser Darkmoon Prize"] = 7932,
		["40 Tickets - Greater Darkmoon Prize"] = 7933,
		["50 Tickets - Darkmoon Storage Box"] = 7934,
		["10 Tickets - Last Month's Mutton"] = 7935,
		["50 Tickets - Last Year's Mutton"] = 7936,
		["1200 Tickets - Orb of the Darkmoon"] = 7940,
		["1200 Tickets - Amulet of the Darkmoon"] = 7981,
		["Small Furry Paws"] = 7899,
		["Torn Bear Pelts"] = 7900,
		["Soft Bushy Tails"] = 7901,
		["Vibrant Plumes"] = 7902,
		["Evil Bat Eyes"] = 7903,
		["More Bat Eyes"] = 7943,
		["Glowing Scorpid Blood"] = 8222,
		["More Glowing Scorpid Blood"] = 8223,
		["Coarse Weightstone"] = 7889,
		["Heavy Grinding Stone"] = 7890,
		["Green Iron Bracers"] = 7891,
		["Big Black Mace"] = 7892,
		["Rituals of Strength"] = 7893,
		["More Dense Grinding Stones"] = 7939,
		["Carnival Boots"] = 7881,
		["Carnival Jerkins"] = 7882,
		["The World's Largest Gnome!"] = 7883,
		["Crocolisk Boy and the Bearded Murloc"] = 7884,
		["Armor Kits"] = 7885,
		["More Armor Kits"] = 7941,
		["Copper Modulator"] = 7894,
		["Whirring Bronze Gizmo"] = 7895,
		["Green Fireworks"] = 7896,
		["Mechanical Repair Kits"] = 7897,
		["Thorium Widget"] = 7898,
		["More Thorium Widgets"] = 7942,
		["Darkmoon Beast Deck"] = 7907,
		["Darkmoon Portals Deck"] = 7927,
		["Darkmoon Warlords Deck"] = 7928,
		["Darkmoon Elementals Deck"] = 7929,
		["Spawn of Jubjub"] = 7946,
		["The Heart of Hakkar"] = 8183,
		["Strength of Mount Mugamba"] = 	{
			["Jin'rokh the Breaker"] = 		{
				["It is good to see you in good health, $n. The glorious battles you have undertaken affect all life on this planet. Hakkar must never will surely collapse beneath his immense hunger. Give me your talisman and I shall amplify its strength. Use the Strength of Mugamba to punish our enemies!"] = 8042,
				["Master $n, you return! Molthor has sent word of your deeds to the King. Your name is known even in the South Seas. Perhaps one day you will be a legendary $c - a story for the ages. Give me your talisman so that I may once more amplify its power."] = 8043
			}
		},
		["The Rage of Mugamba"] = 8044,
		["The Heathen's Brand"] = 	{
			["Jin'rokh the Breaker"] = 		{
				["I may have been too hasty in my judgement, $c. It seems as if your blind faith in this Light has some value after all. Give $c. It seems as if your blind faith in this Light has some value after all. Give me your brand and I shall amplify its power."] = 8046,
				["I must confess, I did not think you had the resolution to see this cause through, $c. Zandalar now considers you an invaluable ally. Well this cause through, $c. Zandalar now considers you an invaluable ally. Well done, indeed. Give me your brand and I shall once more amplify its power."] = 8047
			}
		},
		["The Hero's Brand"] = 8048,
		["Paragons of Power: The Freethinker's Armguards"] = 8053,
		["Paragons of Power: The Freethinker's Belt"] = 8054,
		["Paragons of Power: The Freethinker's Breastplate"] = 8055,
		["Paragons of Power: The Vindicator's Armguards"] = 8058,
		["Paragons of Power: The Vindicator's Belt"] = 8078,
		["Paragons of Power: The Vindicator's Breastplate"] = 8079,
		["The Eye of Zuldazar"] = 	{
			["Al'tabim the All-Seeing"] = 		{
				["Tales of your battles against the Gurubashi are whispered in the winds, priestess. Even royalty is beginning to talk of your deeds. It is rumored that King Rastakhan even mentioned you by name. The time has come to imbue the Eye. Hand me the talisman and I shall perform the service."] = 8050,
				["Welcome $c. The Eye of Zuldazar pulses with energy. You are ready to take the next step. Hand me the talisman and I shall perform The Eye of Zuldazar pulses with energy. You are ready to take the next step. Hand me the talisman and I shall perform the imbue."] = 8051
			}
		},
		["The All-Seeing Eye of Zuldazar"] = 8052,
		["Paragons of Power: The Demoniac's Wraps"] = 8059,
		["Paragons of Power: The Illusionist's Wraps"] = 8060,
		["Paragons of Power: The Confessor's Wraps"] = 8061,
		["Paragons of Power: The Illusionist's Mantle"] = 8068,
		["Paragons of Power: The Illusionist's Robes"] = 8069,
		["Paragons of Power: The Confessor's Bindings"] = 8070,
		["Paragons of Power: The Confessor's Mantle"] = 8071,
		["Paragons of Power: The Demoniac's Mantle"] = 8076,
		["Paragons of Power: The Demoniac's Robes"] = 8077,
		["The Pebble of Kajaro"] = 	{
			["Al'tabim the All-Seeing"] = 		{
				["Welcome back, $c. I can see that the pebble has seen much use. Many of our foes have fallen to your otherworldly abilities. Their suffering fallen to your otherworldly abilities. Their suffering has been great. It is time that I enhance the power of the pebble. Give it to me."] = 8102,
				["Hakkari fear you, $n. They speak of horrors they believed that only their faceless God could perpetrate. You have burned them with the force of burned them with the force of Kajaro. They now know fear in two places. It is time to further strengthen the pebble. Hand me the talisman."] = 8103
			}
		},
		["The Jewel of Kajaro"] = 8104,
		["Kezan's Taint"] = 	{
			["Al'tabim the All-Seeing"] = 		{
				["Honor is earned amongst the Zandalar trolls, $n. With honor comes reward - friendship, alliance... Hand me the talisman so that I may enhance its power. Honor is earned amongst the Zandalar trolls, $n. With honor comes reward - friendship, alliance... Hand me the talisman so that I may enhance its power."] = 8107,
				["I am ready for you, $c. Once more I will enhance your talisman. I only ask that you continue in your destruction of Hakkar and $c. Once more I will enhance your talisman. I only ask that you continue in your destruction of Hakkar and his minions. Give me the talisman."] = 8108
			}
		},
		["Kezan's Unstoppable Taint"] = 8109,
		["Paragons of Power: The Augur's Bracers"] = 8056,
		["Paragons of Power: The Haruspex's Bracers"] = 8057,
		["Paragons of Power: The Haruspex's Belt"] = 8064,
		["Paragons of Power: The Haruspex's Tunic"] = 8065,
		["Paragons of Power: The Augur's Belt"] = 8074,
		["Paragons of Power: The Augur's Hauberk"] = 8075,
		["Enchanted South Seas Kelp"] = 	{
			["Maywiki of Zuldazar"] = 		{
				["Hey mon! It be good to see you again. The tribe be talking about your killin' of the Hakkari and all that. Molthor gave me and all that. Molthor gave me the word to be adding more mojo to your talisman. Just give it here and Maywiki make it better."] = 8111,
				["How be that talisman, mon? It look like it be time to add a little more magic and mojo to its leaves. It need a little more magic and mojo to its leaves. It need a little bloom in its wilt. Give it here and Maywiki fix it right up."] = 8112
			}
		},
		["Pristine Enchanted South Seas Kelp"] = 8113,
		["Vision of Voodress"] = 	{
			["Maywiki of Zuldazar"] = 		{
				["Good news, $n. Molthor be singin' your praises lately. He say how you be turnin' into a real hero of Zandalar. He also say for Maywiki into a real hero of Zandalar. He also say for Maywiki to polish your orb some more! Give it here so Maywiki can brighten the vision."] = 8117,
				["Sha-mon! Maywiki make a joke! <Maywiki laughs.> So, you been using the spirits and elements against our enemies in Zul'Gurub, eh? Spirits be praised! Maywiki gonna brighten your laughs.> So, you been using the spirits and elements against our enemies in Zul'Gurub, eh? Spirits be praised! Maywiki gonna brighten your orb. Give it here, $n."] = 8118
			}
		},
		["The Unmarred Vision of Voodress"] = 8119,
		["Paragons of Power: The Predator's Bracers"] = 8062,
		["Paragons of Power: The Madcap's Bracers"] = 8063,
		["Paragons of Power: The Predator's Belt"] = 8066,
		["Paragons of Power: The Predator's Mantle"] = 8067,
		["Paragons of Power: The Madcap's Mantle"] = 8072,
		["Paragons of Power: The Madcap's Tunic"] = 8073,
		["Zandalarian Shadow Talisman"] = 	{
			["Falthir the Sightless"] = 		{
				["Impressive, $n. You have a gift for killing that I have not sensed in another in many years. Even Molthor is aware of the work Even Molthor is aware of the work that you have done for Zandalar. It is time to enhance your talisman further. Give it to me."] = 8142,
				["I sense that you have dealt countless fatalities to the Hakkari, $n. You carry the stink of their mojo. I assume the Shadow talisman has assisted the stink of their mojo. I assume the Shadow talisman has assisted in the culling? Give it to me and allow me to enhance its power."] = 8143
			}
		},
		["Zandalarian Shadow Mastery Talisman"] = 8144,
		["The Maelstrom's Tendril"] = 	{
			["Falthir the Sightless"] = 		{
				["Even from here I can hear the sound of your volleys laying waste to our enemies. Their cries echo in agony. You have made quite a among the trolls of Zandalar, $n. We are grateful for all that you have done. Hand me your talisman so that I may add another weave."] = 8146,
				["Ah, $n, it is good to smell you again. <Falthir grins.> You'll have to excuse my sense of humor. It can be most foul at times. I sense The forces of Hakkar cry out your name in anger. This is most excellent. You have earned another weave on your talisman. Hand it to me."] = 8147
			}
		},
		["Maelstrom's Wrath"] = 8148,
		["A Collection of Heads"] = 8201,
		["Essence Mangoes"] = 8196,
		["Zanza's Potent Potables"] = 8243,
		["Signets of the Zandalar"] = 8246,
		["More Resource Crates"] = 	{
			["Sergeant Maclear"] = 8081,
			["Deathstalker Mortis"] = 8124
		},
		["Honoring a Hero"] = 	{
			["Wagner Hammerstrike"] = 8149,
			["Javnir Nashak"] = 8150
		},
		["Presence of Might"] = 8184,
		["Syncretist's Sigil"] = 8185,
		["Death's Embrace"] = 8186,
		["Falcon's Call"] = 8187,
		["Vodouisant's Vigilant Embrace"] = 8188,
		["Presence of Sight"] = 8189,
		["Hoodoo Hex"] = 8190,
		["Prophetic Aura"] = 8191,
		["Animist's Caress"] = 8192,
		["The Savage Guard - Arcanum of Protection"] = 9208,
		["The Savage Guard - Arcanum of Rapidity"] = 9209,
		["The Savage Guard - Arcanum of Focus"] = 9210,
		["Zulian, Razzashi, and Hakkari Coins"] = 8195,
		["Gurubashi, Vilebranch, and Witherbark Coins"] = 8238,
		["Sandfury, Skullsplitter, and Bloodscalp Coins"] = 8239,
		["A Bijou for Zanza"] = 8240,
		["Master Angler"] = 8193,
		["Apprentice Angler"] = 8194,
		["Rare Fish - Keefer's Angelfish"] = 8221,
		["Rare Fish - Dezian Queenfish"] = 8224,
		["Rare Fish - Brownell's Blue Striped Racer"] = 8225,
		["Pirate Hats Ahoy!"] = 8365,
		["Brann Bronzebeard's Lost Letter"] = 8308,
		["Glyph Chasing"] = 8309,
		["Breaking the Code"] = 8310,
		["Sharing the Knowledge"] = 8313,
		["Kitchen Assistance"] = 8317,
		["Desert Survival Kits"] = 8497,
		["Volunteer's Battlegear"] = 8548,
		["Veteran's Battlegear"] = 8572,
		["Champion's Battlegear"] = 8573,
		["Stalwart's Battlegear"] = 8574,
		["Extraordinary Materials"] = 8783,
		["What Tomorrow Brings"] = 8286,
		["Only One May Rise"] = 8288,
		["The Path of the Righteous"] = 8301,
		["The Hand of the Righteous"] = 8302,
		["A Terrible Purpose"] = 8287,
		["Dearest Natalia"] = 8304,
		["Into The Maw of Madness"] = 8306,
		["Twilight Battle Orders"] = 8498,
		["Target: Hive'Ashi Stingers"] = 8501,
		["Target: Hive'Ashi Workers"] = 8502,
		["The Four Dukes"] = 8538,
		["Target: Hive'Zora Hive Sisters"] = 8539,
		["Target: Hive'Zora Tunnelers"] = 8687,
		["Target: Hive'Ashi Defenders"] = 8770,
		["Target: Hive'Ashi Sandstalkers"] = 8771,
		["Target: Hive'Zora Waywatchers"] = 8772,
		["Target: Hive'Zora Reavers"] = 8773,
		["Target: Hive'Regal Ambushers"] = 8774,
		["Target: Hive'Regal Spitfires"] = 8775,
		["Target: Hive'Regal Slavemakers"] = 8776,
		["Target: Hive'Regal Burrowers"] = 8777,
		["The Fall of Ossirian"] = 8791,
		["Wanted - Deathclasp, Terror of the Sands"] = 8283,
		["Boots for the Guard"] = 8540,
		["Grinding Stones for the Guard"] = 8541,
		["The Twilight Mystery"] = 8284,
		["Unraveling the Mystery"] = 8314,
		["The Calling"] = 8315,
		["Scrying Materials"] = 8779,
		["Deadly Desert Venom"] = 8277,
		["Noggle's Last Hope"] = 8278,
		["Noggle's Lost Satchel"] = 8282,
		["Securing the Supply Lines"] = 8280,
		["Stepping Up Security"] = 8281,
		["Bandages for the Field"] = 8496,
		["Hive'Zora Scout Report"] = 8534,
		["Hive'Regal Scout Report"] = 8738,
		["Hive'Ashi Scout Report"] = 8739,
		["Twilight Marauders"] = 8740,
		["Uniform Supplies"] = 8782,
		["The Wrath of Neptulon"] = 8729,
		["Nefarius's Corruption"] = 8730,
		["The Might of Kalimdor"] = 8742,
		["The Path of the Protector"] = 	{
			["Anachronos"] = 		{
				["Impressive, little one. You have gone through much trouble to gain the favor of the Bronze Flight. Your dedication is noted. The signet ring of the offer superior protection against the forces of evil. Be warned, once you have chosen your path, you will have no recourse should you change your mind."] = 8747,
				["Your continued defense of the children of Kalimdor has been acknowledged. Hand me your signet ring so that I may enhance its powers. Your continued defense of the children of Kalimdor has been acknowledged. Hand me your signet ring so that I may enhance its powers."] = 8748,
				["You honor my kind, $N. Strike down the enemies of Kalimdor! Show them what it means to deface the land of eternal starlight. You have earned it means to deface the land of eternal starlight. You have earned another enhancement. Hand me your signet ring so that I may bolster its power."] = 8749,
				["Dedication of this magnitude is a rarity. You have shown that your will is unfaltering, $N. You shall be greatly rewarded for your stalwart watch unfaltering, $N. You shall be greatly rewarded for your stalwart watch over our world. Hand me your signet ring so that I may strengthen its enchantment."] = 8750
			}
		},
		["The Protector of Kalimdor"] = 8751,
		["The Path of the Conqueror"] = 	{
			["Anachronos"] = 		{
				["Impressive, little one. You have gone through much trouble to gain the favor of the Bronze Flight. Your dedication is noted. The signet ring of the the conqueror will greatly enhance your physical attacks. Be warned, once you have chosen your path, you will have no recourse should you change your mind."] = 8752,
				["Your continued defense of the children of Kalimdor has been acknowledged. Hand me your signet ring so that I may enhance its powers. Your continued defense of the children of Kalimdor has been acknowledged. Hand me your signet ring so that I may enhance its powers."] = 8753,
				["You honor my kind, $N. Strike down the enemies of Kalimdor! Show them what it means to deface the land of eternal starlight. You have earned it means to deface the land of eternal starlight. You have earned another enhancement. Hand me your signet ring so that I may bolster its power."] = 8754,
				["Dedication of this magnitude is a rarity. You have shown that your will is unfaltering, $N. You shall be greatly rewarded for your stalwart watch unfaltering, $N. You shall be greatly rewarded for your stalwart watch over our world. Hand me your signet ring so that I may strengthen its enchantment."] = 8755
			}
		},
		["The Qiraji Conqueror"] = 8756,
		["The Path of the Invoker"] = 	{
			["Anachronos"] = 		{
				["Impressive, little one. You have gone through much trouble to gain the favor of the Bronze Flight. Your dedication is noted. The signet ring of the will greatly enhance your magical and natural abilities. Be warned, once you have chosen your path, you will have no recourse should you change your mind."] = 8757,
				["Your continued defense of the children of Kalimdor has been acknowledged. Hand me your signet ring so that I may enhance its powers. Your continued defense of the children of Kalimdor has been acknowledged. Hand me your signet ring so that I may enhance its powers."] = 8758,
				["You honor my kind, $N. Strike down the enemies of Kalimdor! Show them what it means to deface the land of eternal starlight. You have earned it means to deface the land of eternal starlight. You have earned another enhancement. Hand me your signet ring so that I may bolster its power."] = 8759,
				["Dedication of this magnitude is a rarity. You have shown that your will is unfaltering, $N. You shall be greatly rewarded for your stalwart watch unfaltering, $N. You shall be greatly rewarded for your stalwart watch over our world. Hand me your signet ring so that I may strengthen its enchantment."] = 8760
			}
		},
		["The Grand Invoker"] = 8761,
		["The Changing of Paths - Protector No More"] = 8764,
		["The Changing of Paths - Invoker No More"] = 8765,
		["The Changing of Paths - Conqueror No More"] = 8766,
		["The Savior of Kalimdor"] = 8802,
		["Frame of Atiesh"] = 9250,
		["Atiesh, the Befouled Greatstaff"] = 9251,
		["The Twilight Lexicon"] = 8279,
		["The Deserter"] = 8285,
		["True Believers"] = 8323,
		["Still Believing"] = 8324,
		["Stinking Up Southshore"] = 1657,
		["Twilight Geolords"] = 8320,
		["Vyral the Vile"] = 8321,
		["Dukes of the Council"] = 8332,
		["Medallion of Station"] = 8333,
		["Lords of the Council"] = 8341,
		["Twilight Ring of Lordship"] = 8342,
		["The Ultimate Deception"] = 8829,
		["A Humble Offering"] = 9248,
		["Secret Communication"] = 8318,
		["Encrypted Twilight Texts"] = 8319,
		["Signet of the Dukes"] = 8348,
		["Scepter of the Council"] = 8352,
		["Abyssal Contacts"] = 8361,
		["Abyssal Crests"] = 8362,
		["Abyssal Signets"] = 8363,
		["Abyssal Scepters"] = 8364,
		["Hoary Templar"] = 8535,
		["Earthen Templar"] = 8536,
		["Crimson Templar"] = 8537,
		["Azure Templar"] = 8737,
		["Hallow's End Treats for Spoops!"] = 8312,
		["Hallow's End Treats for Jesper!"] = 8311,
		["Imperial Qiraji Regalia"] = 8790,
		["C'Thun's Legacy"] = 8801,
		["Imperial Qiraji Armaments"] = 8789,
		["The Alliance Needs Copper Bars!"] = 8492,
		["The Alliance Needs More Copper Bars!"] = 8493,
		["Deadwood of the North"] = 8461,
		["Feathers for Nafien"] = 8467,
		["The Alliance Needs Iron Bars!"] = 8494,
		["The Alliance Needs More Iron Bars!"] = 8495,
		["The Alliance Needs Thorium Bars!"] = 8499,
		["The Alliance Needs More Thorium Bars!"] = 8500,
		["The Alliance Needs Stranglekelp!"] = 8503,
		["The Alliance Needs More Stranglekelp!"] = 8504,
		["The Alliance Needs Purple Lotus!"] = 8505,
		["The Alliance Needs More Purple Lotus!"] = 8506,
		["Field Duty Papers"] = 	{
			["Captain Blackanvil"] = 8508,
			["Krug Skullsplit"] = 8732
		},
		["Armor Kits for the Field"] = 	{
			["Janela Stouthammer"] = 8780,
			["Merok Longstride"] = 8787
		},
		["Arms for the Field"] = 	{
			["Janela Stouthammer"] = 8781,
			["Merok Longstride"] = 8786
		},
		["The Ironforge Brigade Needs Explosives!"] = 8778,
		["The Alliance Needs Arthas' Tears!"] = 8509,
		["The Alliance Needs More Arthas' Tears!"] = 8510,
		["The Alliance Needs Light Leather!"] = 8511,
		["The Alliance Needs More Light Leather!"] = 8512,
		["The Alliance Needs Medium Leather!"] = 8513,
		["The Alliance Needs More Medium Leather!"] = 8514,
		["The Alliance Needs Thick Leather!"] = 8515,
		["The Alliance Needs More Thick Leather!"] = 8516,
		["The Alliance Needs Linen Bandages!"] = 8517,
		["The Alliance Needs More Linen Bandages!"] = 8518,
		["The Alliance Needs Silk Bandages!"] = 8520,
		["The Alliance Needs More Silk Bandages!"] = 8521,
		["The Alliance Needs Runecloth Bandages!"] = 8522,
		["The Alliance Needs More Runecloth Bandages!"] = 8523,
		["The Alliance Needs Rainbow Fin Albacore!"] = 8524,
		["The Alliance Needs More Rainbow Fin Albacore!"] = 8525,
		["The Alliance Needs Roast Raptor!"] = 8526,
		["The Alliance Needs More Roast Raptor!"] = 8527,
		["The Alliance Needs Spotted Yellowtail!"] = 8528,
		["The Alliance Needs More Spotted Yellowtail!"] = 8529,
		["The Horde Needs Copper Bars!"] = 8532,
		["The Horde Needs More Copper Bars!"] = 8533,
		["The Horde Needs Tin Bars!"] = 8542,
		["The Horde Needs More Tin Bars!"] = 8543,
		["The Horde Needs Mithril Bars!"] = 8545,
		["The Horde Needs More Mithril Bars!"] = 8546,
		["The Horde Needs Peacebloom!"] = 8549,
		["The Horde Needs More Peacebloom!"] = 8550,
		["Signet of Unyielding Strength"] = 8556,
		["Ring of Infinite Wisdom"] = 8697,
		["Ring of the Gathering Storm"] = 8698,
		["Band of Vaulted Secrets"] = 8699,
		["Band of Unending Life"] = 8700,
		["Band of Veiled Shadows"] = 8701,
		["Ring of Unspoken Names"] = 8702,
		["Ring of Eternal Justice"] = 8703,
		["Signet of the Unseen Path"] = 8704,
		["Sickle of Unyielding Strength"] = 8558,
		["Gavel of Infinite Wisdom"] = 8705,
		["Hammer of the Gathering Storm"] = 8706,
		["Blade of Vaulted Secrets"] = 8707,
		["Mace of Unending Life"] = 8708,
		["Dagger of Veiled Shadows"] = 8709,
		["Kris of Unspoken Names"] = 8710,
		["Blade of Eternal Justice"] = 8711,
		["Scythe of the Unseen Path"] = 8712,
		["Drape of Unyielding Strength"] = 8557,
		["Shroud of Infinite Wisdom"] = 8689,
		["Cloak of the Gathering Storm"] = 8690,
		["Drape of Vaulted Secrets"] = 8691,
		["Cloak of Unending Life"] = 8692,
		["Cloak of Veiled Shadows"] = 8693,
		["Shroud of Unspoken Names"] = 8694,
		["Cape of Eternal Justice"] = 8695,
		["Cloak of the Unseen Path"] = 8696,
		["Conqueror's Spaulders"] = 8544,
		["Conqueror's Crown"] = 8561,
		["Tiara of the Oracle"] = 8592,
		["Mantle of the Oracle"] = 8594,
		["Stormcaller's Pauldrons"] = 8602,
		["Stormcaller's Diadem"] = 8623,
		["Enigma Shoulderpads"] = 8625,
		["Avenger's Crown"] = 8628,
		["Avenger's Pauldrons"] = 8630,
		["Enigma Circlet"] = 8632,
		["Deathdealer's Helm"] = 8639,
		["Deathdealer's Spaulders"] = 8641,
		["Striker's Diadem"] = 8657,
		["Striker's Pauldrons"] = 8659,
		["Doomcaller's Circlet"] = 8662,
		["Doomcaller's Mantle"] = 8664,
		["Genesis Helm"] = 8667,
		["Genesis Shoulderpads"] = 8669,
		["Secrets of the Qiraji"] = 8784,
		["Conqueror's Greaves"] = 8559,
		["Conqueror's Legguards"] = 8560,
		["Trousers of the Oracle"] = 8593,
		["Mortal Champions"] = 8595,
		["Footwraps of the Oracle"] = 8596,
		["Stormcaller's Footguards"] = 8621,
		["Stormcaller's Leggings"] = 8624,
		["Striker's Footguards"] = 8626,
		["Avenger's Legguards"] = 8629,
		["Enigma Leggings"] = 8631,
		["Enigma Boots"] = 8634,
		["Deathdealer's Boots"] = 8637,
		["Deathdealer's Leggings"] = 8640,
		["Avenger's Greaves"] = 8655,
		["Striker's Leggings"] = 8658,
		["Doomcaller's Footwraps"] = 8660,
		["Doomcaller's Trousers"] = 8663,
		["Genesis Boots"] = 8665,
		["Genesis Trousers"] = 8668,
		["Conqueror's Breastplate"] = 8562,
		["Vestments of the Oracle"] = 8603,
		["Stormcaller's Hauberk"] = 8622,
		["Avenger's Breastplate"] = 8627,
		["Enigma Robes"] = 8633,
		["Deathdealer's Vest"] = 8638,
		["Striker's Hauberk"] = 8656,
		["Genesis Vest"] = 8666,
		["The Horde Needs Firebloom!"] = 8580,
		["The Horde Needs More Firebloom!"] = 8581,
		["The Horde Needs Purple Lotus!"] = 8582,
		["The Horde Needs More Purple Lotus!"] = 8583,
		["The Horde Needs Heavy Leather!"] = 8588,
		["The Horde Needs More Heavy Leather!"] = 8589,
		["The Horde Needs Thick Leather!"] = 8590,
		["The Horde Needs More Thick Leather!"] = 8591,
		["The Horde Needs Rugged Leather!"] = 8600,
		["The Horde Needs More Rugged Leather!"] = 8601,
		["The Horde Needs Wool Bandages!"] = 8604,
		["The Horde Needs More Wool Bandages!"] = 8605,
		["The Horde Needs Mageweave Bandages!"] = 8607,
		["The Horde Needs More Mageweave Bandages!"] = 8608,
		["The Horde Needs Runecloth Bandages!"] = 8609,
		["The Horde Needs More Runecloth Bandages!"] = 8610,
		["The Horde Needs Lean Wolf Steaks!"] = 8611,
		["The Horde Needs More Lean Wolf Steaks!"] = 8612,
		["The Horde Needs Spotted Yellowtail!"] = 8613,
		["The Horde Needs More Spotted Yellowtail!"] = 8614,
		["The Horde Needs Baked Salmon!"] = 8615,
		["The Horde Needs More Baked Salmon!"] = 8616,
		["Field Duty"] = 	{
			["Windcaller Kaldon"] = 		{
				["You'll find Captain Blackanvil's force stationed outside Hive'Zora. Talk to his lieutenant, Janela Stouthammer, if you can't find him. You'll find Captain Blackanvil's force stationed outside Hive'Zora. Talk to his lieutenant, Janela Stouthammer, if you can't find him."] = 8507,
				["You've completed your field duty, $N? Captain Skullsplit can be found outside of Hive'Regal. You've completed your field duty, $N? Captain Skullsplit can be found outside of Hive'Regal."] = 8731
			}
		},
		["Allegiance to Cenarion Circle"] = 9338,
		["The Orgrimmar Legion Needs Mojo!"] = 8785,
		["Five Signets for War Supplies"] = 	{
			["Warlord Gorchuk"] = 8851,
			["Field Marshal Snowfall"] = 8846
		},
		["Ten Signets for War Supplies"] = 	{
			["Warlord Gorchuk"] = 8852,
			["Field Marshal Snowfall"] = 8847
		},
		["Fifteen Signets for War Supplies"] = 	{
			["Warlord Gorchuk"] = 8853,
			["Field Marshal Snowfall"] = 8848
		},
		["Twenty Signets for War Supplies"] = 	{
			["Warlord Gorchuk"] = 8854,
			["Field Marshal Snowfall"] = 8849
		},
		["Thirty Signets for War Supplies"] = 	{
			["Warlord Gorchuk"] = 8855,
			["Field Marshal Snowfall"] = 8850
		},
		["One Commendation Signet"] = 	{
			["Darnassus Commendation Officer"] = 8811,
			["Gnomeregan Commendation Officer"] = 8812,
			["Ironforge Commendation Officer"] = 8813,
			["Stormwind Commendation Officer"] = 8814,
			["Orgrimmar Commendation Officer"] = 8815,
			["Darkspear Commendation Officer"] = 8816,
			["Undercity Commendation Officer"] = 		{
				["For those adventurers who have but a single commendation signet, I'll exchange it for a small amount of recognition with Orgrimmar. Please bear in mind that for a full stack of ten. With that being said, I stand ready to assist you if you still wish to hand in a single signet."] = 8815,
				["For those adventurers who have but a single commendation signet, I'll exchange it for a small amount of recognition with Thunder Bluff. Please bear in mind for a full stack of ten. With that being said, I stand ready to assist you if you still wish to hand in a single signet."] = 8842
			},
			["Thunder Bluff Commendation Officer"] = 8818,
			["Officer Vu'Shalay"] = 		{
				["For those adventurers who have but a single commendation signet, I'll exchange it for a small amount of recognition with Thunder Bluff. Please bear in mind for a full stack of ten. With that being said, I stand ready to assist you if you still wish to hand in a single signet."] = 8818,
				["For those adventurers who have but a single commendation signet, I'll exchange it for a small amount of recognition with the Darkspear tribe. Please bear in for a full stack of ten. With that being said, I stand ready to assist you if you still wish to hand in a single signet."] = 8844
			},
			["Officer Lunalight"] = 		{
				["For those adventurers who have but a single commendation signet, I'll exchange it for a small amount of recognition with Ironforge. Please bear in mind that for a full stack of ten. With that being said, I stand ready to assist you if you still wish to hand in a single signet."] = 8813,
				["For those adventurers who have but a single commendation signet, I'll exchange it for a small amount of recognition with Darnassus. Please bear in mind that for a full stack of ten. With that being said, I stand ready to assist you if you still wish to hand in a single signet."] = 8836
			},
			["Officer Porterhouse"] = 		{
				["For those adventurers who have but a single commendation signet, I'll exchange it for a small amount of recognition with Stormwind. Please bear in mind that for a full stack of ten. With that being said, I stand ready to assist you if you still wish to hand in a single signet."] = 8814,
				["For those adventurers who have but a single commendation signet, I'll exchange it for a small amount of recognition with the Gnomeregan exiles. Please bear in for a full stack of ten. With that being said, I stand ready to assist you if you still wish to hand in a single signet."] = 8838
			},
			["Officer Ironbeard"] = 		{
				["For those adventurers who have but a single commendation signet, I'll exchange it for a small amount of recognition with the Gnomeregan exiles. Please bear in for a full stack of ten. With that being said, I stand ready to assist you if you still wish to hand in a single signet."] = 8812,
				["For those adventurers who have but a single commendation signet, I'll exchange it for a small amount of recognition with Ironforge. Please bear in mind that for a full stack of ten. With that being said, I stand ready to assist you if you still wish to hand in a single signet."] = 8834
			},
			["Officer Redblade"] = 		{
				["For those adventurers who have but a single commendation signet, I'll exchange it for a small amount of recognition with Orgrimmar. Please bear in mind that for a full stack of ten. With that being said, I stand ready to assist you if you still wish to hand in a single signet."] = 8815,
				["For those adventurers who have but a single commendation signet, I'll exchange it for a small amount of recognition with the Undercity. Please bear in mind for a full stack of ten. With that being said, I stand ready to assist you if you still wish to hand in a single signet."] = 8832
			},
			["Officer Thunderstrider"] = 		{
				["For those adventurers who have but a single commendation signet, I'll exchange it for a small amount of recognition with Undercity. Please bear in mind that for a full stack of ten. With that being said, I stand ready to assist you if you still wish to hand in a single signet."] = 8817,
				["For those adventurers who have but a single commendation signet, I'll exchange it for a small amount of recognition with Thunder Bluff. Please bear in mind for a full stack of ten. With that being said, I stand ready to assist you if you still wish to hand in a single signet."] = 8842
			},
			["Officer Gothena"] = 		{
				["For those adventurers who have but a single commendation signet, I'll exchange it for a small amount of recognition with the Darkspear tribe. Please bear in for a full stack of ten. With that being said, I stand ready to assist you if you still wish to hand in a single signet."] = 8816,
				["For those adventurers who have but a single commendation signet, I'll exchange it for a small amount of recognition with Orgrimmar. Please bear in mind that for a full stack of ten. With that being said, I stand ready to assist you if you still wish to hand in a single signet."] = 8840
			}
		},
		["Ten Commendation Signets"] = 	{
			["Darnassus Commendation Officer"] = 8819,
			["Gnomeregan Commendation Officer"] = 8820,
			["Ironforge Commendation Officer"] = 8821,
			["Stormwind Commendation Officer"] = 8822,
			["Orgrimmar Commendation Officer"] = 8823,
			["Darkspear Commendation Officer"] = 8824,
			["Undercity Commendation Officer"] = 8826,
			["Thunder Bluff Commendation Officer"] = 8825,
			["Officer Vu'Shalay"] = 8845,
			["Officer Lunalight"] = 8837,
			["Officer Porterhouse"] = 8839,
			["Officer Ironbeard"] = 8835,
			["Officer Redblade"] = 8833,
			["Officer Thunderstrider"] = 8843,
			["Officer Gothena"] = 8841
		},
		["Elune's Candle"] = 8862,
		["Festive Lunar Dresses"] = 8864,
		["Festive Lunar Pant Suits"] = 8865,
		["Lunar Fireworks"] = 8867,
		["Large Cluster Rockets"] = 8881,
		["Cluster Launcher"] = 8882,
		["Dearest Elenia,"] = 8900,
		["An Earnest Proposition"] = 	{
			["Mokvar"] = 8913,
			["Deliana"] = 8905
		},
		["Just Compensation"] = 	{
			["Mokvar"] = 8927,
			["Deliana"] = 8926
		},
		["Anthion's Parting Words"] = 	{
			["Mokvar"] = 		{
				["You're back, $N. You must tell me all about what you've found out. But first let us arrange for your reward. You're back, $N. You must tell me all about what you've found out. But first let us arrange for your reward."] = 8957,
				["You've returned and I see in your eyes that you've much to tell me, $N. Let us take care of your reward first. You've returned and I see in your eyes that you've much to tell me, $N. Let us take care of your reward first."] = 9016
			},
			["Deliana"] = 8951
		},
		["Return to Mokvar"] = 8978,
		["Saving the Best for Last"] = 	{
			["Mokvar"] = 		{
				["As per our deal, are you ready to hand over your Wildheart pieces in exchange for your new Feralheart Cowl and Vest? As per our deal, are you ready to hand over your Wildheart pieces in exchange for your new Feralheart Cowl and Vest?"] = 9007,
				["As per our deal, are you ready to hand over your Beaststalker pieces in exchange for your new Beastmaster's Cap and Tunic? As per our deal, are you ready to hand over your Beaststalker pieces in exchange for your new Beastmaster's Cap and Tunic?"] = 9008,
				["As per our deal, are you ready to hand over your Devout pieces in exchange for your new Virtuous Crown and Robe? As per our deal, are you ready to hand over your Devout pieces in exchange for your new Virtuous Crown and Robe?"] = 9009,
				["As per our deal, are you ready to hand over your Shadowcraft pieces in exchange for your new Darkmantle Cap and Tunic? As per our deal, are you ready to hand over your Shadowcraft pieces in exchange for your new Darkmantle Cap and Tunic?"] = 9010,
				["As per our deal, are you ready to hand over your Elements pieces in exchange for your new Coif and Vest of The Five Thunders As per our deal, are you ready to hand over your Elements pieces in exchange for your new Coif and Vest of The Five Thunders"] = 9011,
				["As per our deal, are you ready to hand over your Dreadmist pieces in exchange for your new Deathmist Mask and Robe? As per our deal, are you ready to hand over your Dreadmist pieces in exchange for your new Deathmist Mask and Robe?"] = 9012,
				["As per our deal, are you ready to hand over your Valor pieces in exchange for your new Helm and Breastplate of Heroism? As per our deal, are you ready to hand over your Valor pieces in exchange for your new Helm and Breastplate of Heroism?"] = 9013,
				["As per our deal, are you ready to hand over your Magister's pieces in exchange for your new Sorcerer's Crown and Robes? As per our deal, are you ready to hand over your Magister's pieces in exchange for your new Sorcerer's Crown and Robes?"] = 9014
			},
			["Deliana"] = 		{
				["As per our deal, are you ready to hand over your Wildheart pieces in exchange for your new Feralheart Cowl and Vest? As per our deal, are you ready to hand over your Wildheart pieces in exchange for your new Feralheart Cowl and Vest?"] = 8999,
				["As per our deal, are you ready to hand over your Beaststalker pieces in exchange for your new Beastmaster's Cap and Tunic? As per our deal, are you ready to hand over your Beaststalker pieces in exchange for your new Beastmaster's Cap and Tunic?"] = 9000,
				["As per our deal, are you ready to hand over your Magister's pieces in exchange for your new Sorcerer's Crown and Robes? As per our deal, are you ready to hand over your Magister's pieces in exchange for your new Sorcerer's Crown and Robes?"] = 9001,
				["As per our deal, are you ready to hand over your Lightforge pieces in exchange for your new Soulforge Helmet and Breastplate? As per our deal, are you ready to hand over your Lightforge pieces in exchange for your new Soulforge Helmet and Breastplate?"] = 9002,
				["As per our deal, are you ready to hand over your Devout pieces in exchange for your new Virtuous Crown and Robe? As per our deal, are you ready to hand over your Devout pieces in exchange for your new Virtuous Crown and Robe?"] = 9003,
				["As per our deal, are you ready to hand over your Shadowcraft pieces in exchange for your new Darkmantle Cap and Tunic? As per our deal, are you ready to hand over your Shadowcraft pieces in exchange for your new Darkmantle Cap and Tunic?"] = 9004,
				["As per our deal, are you ready to hand over your Dreadmist pieces in exchange for your new Deathmist Mask and Robe? As per our deal, are you ready to hand over your Dreadmist pieces in exchange for your new Deathmist Mask and Robe?"] = 9005,
				["As per our deal, are you ready to hand over your Valor pieces in exchange for your new Helm and Breastplate of Heroism? As per our deal, are you ready to hand over your Valor pieces in exchange for your new Helm and Breastplate of Heroism?"] = 9006
			}
		},
		["Return to Deliana"] = 8977,
		["The Ectoplasmic Distiller"] = 8921,
		["A Supernatural Device"] = 	{
			["Mux Manascrambler"] = 		{
				["You've something for me? You've something for me?"] = 8922,
				["You wish to speak to me? You wish to speak to me?"] = 8923
			}
		},
		["Hunting for Ectoplasm"] = 8924,
		["A Portable Power Source"] = 8925,
		["A Shifty Merchant"] = 8928,
		["Proof of Life"] = 8946,
		["Anthion's Strange Request"] = 8947,
		["The Challenge"] = 9015,
		["Dead Man's Plea"] = 8945,
		["Anthion's Old Friend"] = 8948,
		["Falrin's Vendetta"] = 8949,
		["The Instigator's Enchantment"] = 8950,
		["Three Kings of Flame"] = 8961,
		["Components of Importance"] = 8962,
		["The Left Piece of Lord Valthalak's Amulet"] = 	{
			["Bodley"] = 		{
				["Then it is done? You have retrieved the left piece of Lord Valthalak's amulet and finally put to rest the spirit of my old companion, is done? You have retrieved the left piece of Lord Valthalak's amulet and finally put to rest the spirit of my old companion, Mor Grayhoof?"] = 8966,
				["Surely you haven't already dealt with the salvation of Isalien's spirit and the retrieval of the left piece of Lord Valthalak's amulet, $N? Surely you haven't already dealt with the salvation of Isalien's spirit and the retrieval of the left piece of Lord Valthalak's amulet, $N?"] = 8967,
				["Does this mean then, $C, that you've already put the souls of those two fools to rest and retrieved the left piece of Lord Valthalak's this mean then, $C, that you've already put the souls of those two fools to rest and retrieved the left piece of Lord Valthalak's amulet?"] = 8968,
				["I commend you, $N, if you have returned with the left piece of the amulet. If not, however, please take care of that as there with the left piece of the amulet. If not, however, please take care of that as there is no time to waste, I assure you!"] = 8969
			}
		},
		["I See Alcaz Island In Your Future..."] = 8970,
		["More Components of Importance"] = 8985,
		["The Right Piece of Lord Valthalak's Amulet"] = 	{
			["Bodley"] = 		{
				["Then it is done? You have retrieved the right piece of Lord Valthalak's amulet, recombined the amulet into one whole, and finally put to rest right piece of Lord Valthalak's amulet, recombined the amulet into one whole, and finally put to rest the spirit of my old companion, Mor Grayhoof?"] = 8989,
				["Surely you haven't already dealt with the salvation of Isalien's spirit and the retrieval of the right piece of Lord Valthalak's amulet, $N? Be sure the retrieval of the right piece of Lord Valthalak's amulet, $N? Be sure to recombine the pieces of the amulet before handing it to me."] = 8990,
				["Does this mean then, $C, that you've already put the souls of those two fools to rest and recombined the pieces of Lord Valthalak's amulet? Does this mean then, $C, that you've already put the souls of those two fools to rest and recombined the pieces of Lord Valthalak's amulet?"] = 8991,
				["I commend you, $N, if you have returned with the completed amulet. If not, however, please take care of that as there is no time you have returned with the completed amulet. If not, however, please take care of that as there is no time to waste, I assure you!"] = 8992
			}
		},
		["Final Preparations"] = 8994,
		["Return to Bodley"] = 8996,
		["Mea Culpa, Lord Valthalak"] = 8995,
		["The Perfect Poison"] = 9023,
		["Binding the Dreadnaught"] = 9131,
		["Dark Iron Scraps"] = 9132,
		["Echoes of War"] = 9033,
		["Redemption Headpiece"] = 9045,
		["The Dread Citadel - Naxxramas"] = 9121,
		["The Elemental Equation"] = 9128,
		["Core of Elements"] = 9129,
		["Bonescythe Digs"] = 9126,
		["Bone Fragments"] = 9127,
		["Cryptstalker Armor Doesn't Make Itself..."] = 9124,
		["Crypt Fiend Parts"] = 9125,
		["The Ice Guard"] = 9211,
		["The Shadow Guard"] = 9213,
		["Savage Flora"] = 9136,
		["Savage Fronds"] = 9137,
		["They Call Me 'The Rooster'"] = 9141,
		["Writ of Safe Passage"] = 9165,
		["Note from the Front"] = 9299,
		["Envelope from the Front"] = 9301,
		["Document from the Front"] = 9304,
		["Craftsman's Writ - Dense Weightstone"] = 9178,
		["Craftsman's Writ - Imperial Plate Chest"] = 9179,
		["Craftsman's Writ - Volcanic Hammer"] = 9181,
		["Craftsman's Writ - Huge Thorium Battleaxe"] = 9182,
		["Craftsman's Writ - Radiant Circlet"] = 9183,
		["Craftsman's Writ - Wicked Leather Headband"] = 9184,
		["Craftsman's Writ - Rugged Armor Kit"] = 9185,
		["Craftsman's Writ - Wicked Leather Belt"] = 9186,
		["Craftsman's Writ - Runic Leather Pants"] = 9187,
		["Craftsman's Writ - Brightcloth Pants"] = 9188,
		["Craftsman's Writ - Runecloth Boots"] = 9190,
		["Craftsman's Writ - Runecloth Bag"] = 9191,
		["Craftsman's Writ - Runecloth Robe"] = 9194,
		["Craftsman's Writ - Goblin Sapper Charge"] = 9195,
		["Craftsman's Writ - Thorium Grenade"] = 9196,
		["Craftsman's Writ - Gnomish Battle Chicken"] = 9197,
		["Craftsman's Writ - Thorium Tube"] = 9198,
		["Craftsman's Writ - Major Mana Potion"] = 9200,
		["Craftsman's Writ - Greater Arcane Protection Potion"] = 9201,
		["Craftsman's Writ - Major Healing Potion"] = 9202,
		["Craftsman's Writ - Potion of Petrification"] = 9203,
		["Craftsman's Writ - Stonescale Eel"] = 9204,
		["Craftsman's Writ - Plated Armorfish"] = 9205,
		["Craftsman's Writ - Lightning Eel"] = 9206,
		["Chamber of Secrets"] = 12616,
		["Shadows of Doom"] = 9085,
		["Under the Shadow"] = 9153,
		["The Only Song I Know..."] = 9232,
		["Omarion's Handbook"] = 9233,
		["Icebane Gauntlets"] = 9234,
		["Icebane Bracers"] = 9235,
		["Icebane Breastplate"] = 9236,
		["Glacial Cloak"] = 9237,
		["Glacial Gloves"] = 9239,
		["Glacial Vest"] = 9240,
		["Polar Bracers"] = 9241,
		["Polar Gloves"] = 9242,
		["Polar Tunic"] = 9243,
		["Icy Scale Bracers"] = 9244,
		["Icy Scale Gauntlets"] = 9245,
		["Icy Scale Breastplate"] = 9246,
		["Traitor to the Bloodsail"] = 9259,
		["Making Amends"] = 9266,
		["War at Sea"] = 9268,
		["Mending Old Wounds"] = 9267,
		["Cracked Necrotic Crystal"] = 9292,
		["Stealing Orgrimmar's Flame"] = 9324,
		["Stealing Thunder Bluff's Flame"] = 9325,
		["Stealing the Undercity's Flame"] = 9326,
		["Stealing Stormwind's Flame"] = 9330,
		["Stealing Ironforge's Flame"] = 9331,
		["Stealing Darnassus's Flame"] = 9332,
		["Establishing New Outposts"] = 9664,
		["Bolstering Our Defenses"] = 9665,
		["Scouring the Desert"] = 	{
			["General Kirika"] = 9422,
			["Marshal Bluewall"] = 9419
		},
		["Bonechewer Blood"] = 10450,
		["Apothecary Zelana"] = 10449,
		["The Orc Report"] = 1219,
		["A Strange Request"] = 3121,
		["A Watchful Eye"] = 94,
		["A Daughter's Love"] = 231,
		["Looking Further"] = 248,
		["Bitter Rivals"] = 310,
		["The Hidden Key"] = 328,
		["The Dormant Shade"] = 410,
		["Resting in Pieces"] = 460,
		["Nek'rosh's Gambit"] = 465,
		["Bloodscalp Clan Heads"] = 584,
		["Speaking with Nezzliok"] = 585,
		["Speaking with Gan'zulah"] = 586,
		["Enticing Negolash"] = 619,
		["Breaking the Keystone"] = 652,
		["The Princess Trapped"] = 642,
		["Stones of Binding"] = 651,
		["Seal of the Earth"] = 779,
		["Planting the Heart"] = 941,
		["The Master's Glaive"] = 944,
		["Buzzbox 827"] = 983,
		["Buzzbox 411"] = 1001,
		["Buzzbox 323"] = 1002,
		["Buzzbox 525"] = 1003,
		["The Den"] = 1089,
		["Until Death Do Us Part"] = 264,
		["Essence of the Exile"] = 1714,
		["The Hidden Niche"] = 461,
		["Lifting the Curse"] = 290,
		["Summoning the Princess"] = 656,
		["The Super Egg-O-Matic"] = 8893,
		["Rin'ji is Trapped!"] = 2742,
		["Cuergo's Gold"] = 2882,
		["Seeing What Happens"] = 2946,
		["The Stone Watcher"] = 2954,
		["Grime-Encrusted Ring"] = 2945,
		["The Sparklematic 5200!"] = 	{
			["The Sparklematic 5200"] = 		{
				["It would seem that the device needs some sort of grime-encrusted object to clean and three silver coins to get the contraption working. So long of grime-encrusted object to clean and three silver coins to get the contraption working. So long as both are present, the Sparklematic 5200 should work..."] = 2951,
				["Insert a Grime-Encrusted Item into the Sparklematic 5200, and be sure to have three silver coins to start the machine. Insert a Grime-Encrusted Item into the Sparklematic 5200, and be sure to have three silver coins to start the machine."] = 4602
			}
		},
		["More Sparklematic Action"] = 2953,
		["The Stave of Equinex"] = 2879,
		["Release Them"] = 3372,
		["A Grave Situation"] = 3913,
		["Into the Depths"] = 3446,
		["Dark Iron Legacy"] = 3802,
		["The Spectral Chalice"] = 4083,
		["Corrupted Night Dragon"] = 	{
			["Corrupted Night Dragon"] = 		{
				["You have found a sickly, corrupted version of what appears to be a night dragon plant. The fruits that hang from the plant appear rotten that hang from the plant appear rotten and poisonous. It desperately needs some sort of attention if it is to be turned back to normal."] = 4119,
				["You have found a sickly, corrupted version of what appears to be a Night Dragon plant. The fruits that hang from the plant appear rotten that hang from the plant appear rotten and poisonous. It desperately needs some sort of attention if it is to be turned back to normal."] = 4448
			}
		},
		["Corrupted Songflower"] = 2523,
		["Corrupted Windblossom"] = 996,
		["Corrupted Whipper Root"] = 4117,
		["Crystal Restore"] = 4381,
		["Crystal Charge"] = 4385,
		["Crystal Ward"] = 4383,
		["Crystal Yield"] = 4384,
		["Crystal Force"] = 4382,
		["Crystal Spire"] = 4386,
		["Caught!"] = 4449,
		["The Key to Freedom"] = 4451,
		["Testing for Corruption - Felwood"] = 4661,
		["Testing for Impurities - Un'Goro Crater"] = 4561,
		["As Water Cascades"] = 4812,
		["Locked Away"] = 	{
			["Locked Cabinet"] = 5060,
			["Outhouse"] = 5059
		},
		["Target: Felstone Field"] = 5216,
		["Felstone Field Cauldron"] = 5218,
		["Target: Gahrron's Withering"] = 5225,
		["Gahrron's Withering Cauldron"] = 5227,
		["Target: Writhing Haunt"] = 5222,
		["Writhing Haunt Cauldron"] = 5224,
		["Target: Dalson's Tears"] = 5219,
		["Dalson's Tears Cauldron"] = 5221,
		["Hidden Treasures"] = 5942,
		["Hameya's Plea"] = 6024,
		["Claim Rackmore's Treasure!"] = 6161,
		["A Broken Trap"] = 1193,
		["Your Fortune Awaits You..."] = 	{
			["Mysterious Deadmines Chest"] = 7938,
			["Mysterious Eastvale Haystack"] = 7937,
			["Mysterious Wailing Caverns Chest"] = 7944,
			["Mysterious Tree Stump"] = 7945
		}
	}
}
