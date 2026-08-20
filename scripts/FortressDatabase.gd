# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 全國十四大名城與要塞地圖資料庫 (Fortress Maps Database)
class_name FortressDatabase
extends RefCounted

## 取得所有支援的要塞與名城清單
static func get_all_fortress_ids() -> Array[String]:
	return [
		"liangshan",    # 梁山泊 (八百里水泊)
		"shaohua",      # 少華山 (盤山險寨)
		"erlong",       # 二龍山 (寶珠寺古剎)
		"zhujia",       # 祝家莊 (獨龍岡盤陀路)
		"zengtou",      # 曾頭市 (軍馬商埠要塞)
		"daming",       # 大名府 (北京留守北都)
		"jiangzhou",    # 江州 (潯陽江水陸樞紐)
		"kaifeng",      # 東京汴京 (大宋皇城京師)
		"mangdang",     # 芒碭山 (混世魔王奇門)
		"taohua"        # 桃花山 (盤山青石古寨)
	]

## 取得特定要塞的完整沙盤地圖與設施配置
static func get_fortress_data(fortress_id: String) -> Dictionary:
	match fortress_id:
		"liangshan":
			return get_liangshan_map()
		"shaohua":
			return get_shaohua_map()
		"erlong":
			return get_erlong_map()
		"zhujia":
			return get_zhujia_map()
		"zengtou":
			return get_zengtou_map()
		"daming":
			return get_daming_map()
		"jiangzhou":
			return get_jiangzhou_map()
		"kaifeng":
			return get_kaifeng_map()
		"mangdang":
			return get_mangdang_map()
		"taohua":
			return get_taohua_map()
		_:
			return get_liangshan_map()

# ==========================================
# 1. 梁山泊 (Liangshan Po) - 八百里水泊環繞之綠林聖地
# ==========================================
static func get_liangshan_map() -> Dictionary:
	return {
		"id": "liangshan",
		"name": "梁山泊",
		"title": "八百里水泊 忠義聚義之所",
		"governor": "宋江",
		"capacity": 137,
		"theme": "water_fortress",
		"terrain_generator": "water_ring", # 四周環水，中為宛子城
		"initial_facilities": [
			{"id": "ls_hall", "type": "MainHall", "name": "忠義堂本營", "grid": Vector2i(16, 16), "lvl": 3, "heroes": ["宋江", "吳用"]},
			{"id": "ls_dock", "type": "Shipyard", "name": "蓼兒窪碼頭樓船", "grid": Vector2i(4, 16), "lvl": 2, "heroes": ["李俊"]},
			{"id": "ls_smithy", "type": "Smithy", "name": "神兵鐵匠坊", "grid": Vector2i(13, 13), "lvl": 2, "heroes": ["湯隆"]},
			{"id": "ls_tavern", "type": "Tavern", "name": "聚義好漢酒館", "grid": Vector2i(19, 14), "lvl": 2, "heroes": ["朱貴"]},
			{"id": "ls_granary", "type": "Granary", "name": "聚義糧倉", "grid": Vector2i(14, 18), "lvl": 2, "heroes": ["陶宗旺"]},
			{"id": "ls_barracks", "type": "Barracks", "name": "先鋒軍營演武場", "grid": Vector2i(20, 19), "lvl": 2, "heroes": ["武松"]},
			{"id": "ls_farm", "type": "Farm", "name": "水泊高產水田", "grid": Vector2i(8, 8), "lvl": 2, "heroes": []},
			{"id": "ls_tw1", "type": "Watchtower", "name": "一關瞭望哨塔", "grid": Vector2i(6, 6), "lvl": 1, "heroes": []},
			{"id": "ls_tw2", "type": "Watchtower", "name": "二關瞭望哨塔", "grid": Vector2i(6, 26), "lvl": 1, "heroes": []},
			{"id": "ls_tw3", "type": "Watchtower", "name": "三關瞭望哨塔", "grid": Vector2i(26, 6), "lvl": 1, "heroes": []},
			{"id": "ls_tw4", "type": "Watchtower", "name": "水寨瞭望哨塔", "grid": Vector2i(26, 26), "lvl": 1, "heroes": []},
			{"id": "ls_pal1", "type": "Palisade", "name": "斷金亭防禦鹿角", "grid": Vector2i(15, 27), "lvl": 1, "heroes": []},
			{"id": "ls_pal2", "type": "Palisade", "name": "斷金亭防禦鹿角", "grid": Vector2i(17, 27), "lvl": 1, "heroes": []}
		],
		"heroes_spawn": [
			{"name": "林沖", "grid": Vector2i(15, 17), "job": "操練"},
			{"name": "武松", "grid": Vector2i(19, 18), "job": "操練"},
			{"name": "魯智深", "grid": Vector2i(17, 15), "job": "巡哨"},
			{"name": "李俊", "grid": Vector2i(5, 16), "job": "巡哨"},
			{"name": "花榮", "grid": Vector2i(16, 14), "job": "巡哨"}
		]
	}

# ==========================================
# 2. 少華山 (Shaohua Mountain) - 九紋龍史進與神機軍師朱武盤山險寨
# ==========================================
static func get_shaohua_map() -> Dictionary:
	return {
		"id": "shaohua",
		"name": "少華山",
		"title": "險峰峻嶺 神機盤山古寨",
		"governor": "史進",
		"capacity": 171,
		"theme": "mountain_fortress",
		"terrain_generator": "mountain_peaks", # 高山環繞，險峰峽谷
		"initial_facilities": [
			{"id": "sh_hall", "type": "MainHall", "name": "少華山聚義大廳", "grid": Vector2i(16, 16), "lvl": 2, "heroes": ["史進", "朱武"]},
			{"id": "sh_smithy", "type": "Smithy", "name": "山寨兵械鑄坊", "grid": Vector2i(13, 14), "lvl": 2, "heroes": ["陳達"]},
			{"id": "sh_tavern", "type": "Tavern", "name": "迎賓山寨酒肆", "grid": Vector2i(19, 13), "lvl": 1, "heroes": ["楊春"]},
			{"id": "sh_granary", "type": "Granary", "name": "山頂備荒糧倉", "grid": Vector2i(14, 19), "lvl": 1, "heroes": []},
			{"id": "sh_barracks", "type": "Barracks", "name": "少華演武練兵場", "grid": Vector2i(20, 18), "lvl": 2, "heroes": ["史進"]},
			{"id": "sh_farm", "type": "Farm", "name": "梯田耕墾區", "grid": Vector2i(9, 9), "lvl": 1, "heroes": []},
			{"id": "sh_tw1", "type": "Watchtower", "name": "險峰烽火瞭望哨", "grid": Vector2i(7, 7), "lvl": 2, "heroes": []},
			{"id": "sh_tw2", "type": "Watchtower", "name": "望鄉台哨塔", "grid": Vector2i(25, 7), "lvl": 2, "heroes": []},
			{"id": "sh_pal1", "type": "Palisade", "name": "石寨險隘鹿角", "grid": Vector2i(16, 26), "lvl": 2, "heroes": []}
		],
		"heroes_spawn": [
			{"name": "史進", "grid": Vector2i(16, 15), "job": "巡哨"},
			{"name": "朱武", "grid": Vector2i(17, 16), "job": "駐館"},
			{"name": "陳達", "grid": Vector2i(14, 15), "job": "操練"},
			{"name": "楊春", "grid": Vector2i(18, 14), "job": "巡哨"}
		]
	}

# ==========================================
# 3. 二龍山 (Erlong Mountain) - 魯智深、楊志、武松寶珠寺古剎要塞
# ==========================================
static func get_erlong_map() -> Dictionary:
	return {
		"id": "erlong",
		"name": "二龍山",
		"title": "三道險關 寶珠寺古剎要塞",
		"governor": "魯智深",
		"capacity": 116,
		"theme": "temple_fortress",
		"terrain_generator": "canyon_temple",
		"initial_facilities": [
			{"id": "el_hall", "type": "MainHall", "name": "寶珠寺大雄寶殿", "grid": Vector2i(16, 16), "lvl": 3, "heroes": ["魯智深", "楊志"]},
			{"id": "el_barracks", "type": "Barracks", "name": "羅漢堂武僧精舍", "grid": Vector2i(20, 15), "lvl": 2, "heroes": ["武松"]},
			{"id": "el_smithy", "type": "Smithy", "name": "禪杖戒刀鍛爐", "grid": Vector2i(12, 14), "lvl": 2, "heroes": ["曹正"]},
			{"id": "el_tavern", "type": "Tavern", "name": "山腳快活林酒肆", "grid": Vector2i(19, 19), "lvl": 2, "heroes": ["施恩"]},
			{"id": "el_granary", "type": "Granary", "name": "寶珠寺大香積廚", "grid": Vector2i(13, 18), "lvl": 2, "heroes": ["張青"]},
			{"id": "el_tw1", "type": "Watchtower", "name": "第一道險關哨樓", "grid": Vector2i(16, 26), "lvl": 2, "heroes": []},
			{"id": "el_tw2", "type": "Watchtower", "name": "第二道險關哨樓", "grid": Vector2i(16, 22), "lvl": 2, "heroes": []},
			{"id": "el_pal1", "type": "Palisade", "name": "頭關拒馬木柵", "grid": Vector2i(15, 27), "lvl": 2, "heroes": []},
			{"id": "el_pal2", "type": "Palisade", "name": "頭關拒馬木柵", "grid": Vector2i(17, 27), "lvl": 2, "heroes": []}
		],
		"heroes_spawn": [
			{"name": "魯智深", "grid": Vector2i(16, 15), "job": "巡哨"},
			{"name": "楊志", "grid": Vector2i(15, 16), "job": "操練"},
			{"name": "武松", "grid": Vector2i(19, 16), "job": "操練"}
		]
	}

# ==========================================
# 4. 祝家莊 (Zhu Family Village) - 獨龍岡平原迷宮要塞
# ==========================================
static func get_zhujia_map() -> Dictionary:
	return {
		"id": "zhujia",
		"name": "祝家莊",
		"title": "獨龍岡盤陀路 白楊樹迷宮要塞",
		"governor": "祝朝奉",
		"capacity": 73,
		"theme": "walled_village",
		"terrain_generator": "maze_plain",
		"initial_facilities": [
			{"id": "zj_hall", "type": "MainHall", "name": "祝家莊大莊院", "grid": Vector2i(16, 16), "lvl": 2, "heroes": ["祝朝奉", "祝龍"]},
			{"id": "zj_barracks", "type": "Barracks", "name": "欒廷玉鐵棒武館", "grid": Vector2i(19, 14), "lvl": 2, "heroes": ["欒廷玉", "祝彪"]},
			{"id": "zj_smithy", "type": "Smithy", "name": "莊院甲冑鐵鋪", "grid": Vector2i(13, 13), "lvl": 2, "heroes": ["祝虎"]},
			{"id": "zj_granary", "type": "Granary", "name": "獨龍岡萬石大庫", "grid": Vector2i(14, 19), "lvl": 2, "heroes": []},
			{"id": "zj_tavern", "type": "Tavern", "name": "白楊林客店酒家", "grid": Vector2i(20, 19), "lvl": 1, "heroes": []},
			{"id": "zj_tw1", "type": "Watchtower", "name": "前莊門樓箭塔", "grid": Vector2i(16, 25), "lvl": 2, "heroes": []},
			{"id": "zj_tw2", "type": "Watchtower", "name": "後莊角樓箭塔", "grid": Vector2i(16, 7), "lvl": 2, "heroes": []},
			{"id": "zj_pal1", "type": "Palisade", "name": "盤陀路阻敵鹿角", "grid": Vector2i(12, 23), "lvl": 1, "heroes": []},
			{"id": "zj_pal2", "type": "Palisade", "name": "盤陀路阻敵鹿角", "grid": Vector2i(20, 23), "lvl": 1, "heroes": []}
		],
		"heroes_spawn": []
	}

# ==========================================
# 5. 曾頭市 (Zengtou Market) - 史文恭金國名馬重鎮
# ==========================================
static func get_zengtou_map() -> Dictionary:
	return {
		"id": "zengtou",
		"name": "曾頭市",
		"title": "塞外雄關 曾家五虎神駿市集",
		"governor": "曾長官",
		"capacity": 131,
		"theme": "market_fortress",
		"terrain_generator": "market_hub",
		"initial_facilities": [
			{"id": "zt_hall", "type": "MainHall", "name": "曾頭市官署大廳", "grid": Vector2i(16, 16), "lvl": 3, "heroes": ["曾長官", "史文恭"]},
			{"id": "zt_barracks", "type": "Barracks", "name": "曾家教頭大校場", "grid": Vector2i(20, 14), "lvl": 3, "heroes": ["史文恭", "蘇定"]},
			{"id": "zt_smithy", "type": "Smithy", "name": "塞外神兵大鑄坊", "grid": Vector2i(12, 13), "lvl": 2, "heroes": ["曾塗"]},
			{"id": "zt_tavern", "type": "Tavern", "name": "南北塞外大鬧市", "grid": Vector2i(19, 19), "lvl": 2, "heroes": ["曾密"]},
			{"id": "zt_granary", "type": "Granary", "name": "金國儲糧大倉", "grid": Vector2i(13, 19), "lvl": 2, "heroes": ["曾索"]},
			{"id": "zt_tw1", "type": "Watchtower", "name": "南大門雙角箭樓", "grid": Vector2i(14, 26), "lvl": 2, "heroes": []},
			{"id": "zt_tw2", "type": "Watchtower", "name": "南大門雙角箭樓", "grid": Vector2i(18, 26), "lvl": 2, "heroes": []},
			{"id": "zt_pal1", "type": "Palisade", "name": "曾頭市連環鹿角", "grid": Vector2i(16, 27), "lvl": 2, "heroes": []}
		],
		"heroes_spawn": []
	}

# ==========================================
# 6. 大名府 / 北京 (Daming Prefecture) - 梁中書留守北都雄城
# ==========================================
static func get_daming_map() -> Dictionary:
	return {
		"id": "daming",
		"name": "大名府",
		"title": "大宋北都 留守司翠雲重樓",
		"governor": "梁中書",
		"capacity": 228,
		"theme": "metropolis_fortress",
		"terrain_generator": "imperial_city",
		"initial_facilities": [
			{"id": "dm_hall", "type": "MainHall", "name": "大名府留守司署", "grid": Vector2i(16, 16), "lvl": 3, "heroes": ["梁中書", "李成"]},
			{"id": "dm_barracks", "type": "Barracks", "name": "北京北營大校場", "grid": Vector2i(21, 14), "lvl": 3, "heroes": ["聞達", "索超"]},
			{"id": "dm_tavern", "type": "Tavern", "name": "北京第一翠雲樓", "grid": Vector2i(19, 19), "lvl": 3, "heroes": ["盧俊義", "燕青"]},
			{"id": "dm_smithy", "type": "Smithy", "name": "留守司軍械總監", "grid": Vector2i(12, 13), "lvl": 3, "heroes": []},
			{"id": "dm_granary", "type": "Granary", "name": "常平萬石官倉", "grid": Vector2i(13, 19), "lvl": 3, "heroes": []},
			{"id": "dm_tw1", "type": "Watchtower", "name": "東門巍峨城樓", "grid": Vector2i(26, 16), "lvl": 3, "heroes": []},
			{"id": "dm_tw2", "type": "Watchtower", "name": "西門巍峨城樓", "grid": Vector2i(6, 16), "lvl": 3, "heroes": []},
			{"id": "dm_tw3", "type": "Watchtower", "name": "南門宣武城樓", "grid": Vector2i(16, 26), "lvl": 3, "heroes": []}
		],
		"heroes_spawn": []
	}

# ==========================================
# 7. 江州 (Jiangzhou) - 潯陽江頭水陸重鎮
# ==========================================
static func get_jiangzhou_map() -> Dictionary:
	return {
		"id": "jiangzhou",
		"name": "江州",
		"title": "長江水府 潯陽江琵琶畫舫",
		"governor": "蔡九",
		"capacity": 180,
		"theme": "river_metropolis",
		"terrain_generator": "great_river",
		"initial_facilities": [
			{"id": "jz_hall", "type": "MainHall", "name": "江州知府公堂", "grid": Vector2i(16, 16), "lvl": 3, "heroes": ["蔡九", "黃文炳"]},
			{"id": "jz_tavern", "type": "Tavern", "name": "長江名勝潯陽樓", "grid": Vector2i(19, 13), "lvl": 3, "heroes": ["戴宗", "李逵"]},
			{"id": "jz_dock", "type": "Shipyard", "name": "潯陽江萬里水驛", "grid": Vector2i(4, 16), "lvl": 3, "heroes": ["張順", "張橫"]},
			{"id": "jz_barracks", "type": "Barracks", "name": "江州水陸水師營", "grid": Vector2i(21, 18), "lvl": 2, "heroes": []},
			{"id": "jz_smithy", "type": "Smithy", "name": "官辦船錨兵鐵坊", "grid": Vector2i(12, 13), "lvl": 2, "heroes": []},
			{"id": "jz_granary", "type": "Granary", "name": "江州水運轉運倉", "grid": Vector2i(13, 19), "lvl": 2, "heroes": []},
			{"id": "jz_tw1", "type": "Watchtower", "name": "江防烽火觀測樓", "grid": Vector2i(6, 25), "lvl": 2, "heroes": []}
		],
		"heroes_spawn": []
	}

# ==========================================
# 8. 東京汴京 (Kaifeng / Tokyo Capital) - 大宋京師皇城
# ==========================================
static func get_kaifeng_map() -> Dictionary:
	return {
		"id": "kaifeng",
		"name": "東京汴京",
		"title": "大宋國都 萬國來朝宣德闕",
		"governor": "高俅",
		"capacity": 300,
		"theme": "capital_city",
		"terrain_generator": "imperial_capital",
		"initial_facilities": [
			{"id": "kf_hall", "type": "MainHall", "name": "殿帥府樞密院", "grid": Vector2i(16, 16), "lvl": 3, "heroes": ["高俅", "蔡京", "童貫"]},
			{"id": "kf_barracks", "type": "Barracks", "name": "八十萬禁軍大營", "grid": Vector2i(22, 13), "lvl": 3, "heroes": ["高俅", "丘岳", "周昂"]},
			{"id": "kf_tavern", "type": "Tavern", "name": "京華第一名勝樊樓", "grid": Vector2i(19, 19), "lvl": 3, "heroes": ["李師師"]},
			{"id": "kf_smithy", "type": "Smithy", "name": "皇家將作監造局", "grid": Vector2i(11, 13), "lvl": 3, "heroes": []},
			{"id": "kf_granary", "type": "Granary", "name": "太倉大宋國庫", "grid": Vector2i(12, 19), "lvl": 3, "heroes": []},
			{"id": "kf_tw1", "type": "Watchtower", "name": "宣德樓皇城正門", "grid": Vector2i(16, 26), "lvl": 3, "heroes": []},
			{"id": "kf_tw2", "type": "Watchtower", "name": "九門甕城西角樓", "grid": Vector2i(6, 16), "lvl": 3, "heroes": []},
			{"id": "kf_tw3", "type": "Watchtower", "name": "九門甕城東角樓", "grid": Vector2i(26, 16), "lvl": 3, "heroes": []}
		],
		"heroes_spawn": []
	}

# ==========================================
# 9. 芒碭山 (Mangdang Mountain) - 混世魔王樊瑞道法奇門
# ==========================================
static func get_mangdang_map() -> Dictionary:
	return {
		"id": "mangdang",
		"name": "芒碭山",
		"title": "八卦奇門 混世魔王法壇",
		"governor": "樊瑞",
		"capacity": 95,
		"theme": "daoist_mountain",
		"terrain_generator": "mountain_peaks",
		"initial_facilities": [
			{"id": "md_hall", "type": "MainHall", "name": "混世魔王玄壇", "grid": Vector2i(16, 16), "lvl": 2, "heroes": ["樊瑞"]},
			{"id": "md_barracks", "type": "Barracks", "name": "團牌滾刀飛槍營", "grid": Vector2i(20, 15), "lvl": 2, "heroes": ["項充", "李袞"]},
			{"id": "md_smithy", "type": "Smithy", "name": "百鍊標槍鐵匠鋪", "grid": Vector2i(13, 14), "lvl": 2, "heroes": []},
			{"id": "md_tavern", "type": "Tavern", "name": "山寨豪飲酒舍", "grid": Vector2i(18, 19), "lvl": 1, "heroes": []},
			{"id": "md_granary", "type": "Granary", "name": "深山洞穴石糧庫", "grid": Vector2i(14, 18), "lvl": 1, "heroes": []},
			{"id": "md_tw1", "type": "Watchtower", "name": "奇門陣頭瞭望塔", "grid": Vector2i(16, 25), "lvl": 2, "heroes": []}
		],
		"heroes_spawn": []
	}

# ==========================================
# 10. 桃花山 (Taohua Mountain) - 李忠、周通青石木寨
# ==========================================
static func get_taohua_map() -> Dictionary:
	return {
		"id": "taohua",
		"name": "桃花山",
		"title": "桃花盛開 打虎將小霸王古寨",
		"governor": "李忠",
		"capacity": 88,
		"theme": "blossom_mountain",
		"terrain_generator": "mountain_peaks",
		"initial_facilities": [
			{"id": "th_hall", "type": "MainHall", "name": "桃花山聚義廳", "grid": Vector2i(16, 16), "lvl": 2, "heroes": ["李忠", "周通"]},
			{"id": "th_barracks", "type": "Barracks", "name": "山寨習武校場", "grid": Vector2i(19, 14), "lvl": 1, "heroes": ["李忠"]},
			{"id": "th_tavern", "type": "Tavern", "name": "桃花林春色酒棧", "grid": Vector2i(19, 18), "lvl": 2, "heroes": ["周通"]},
			{"id": "th_smithy", "type": "Smithy", "name": "打鐵鑄刀鋪", "grid": Vector2i(13, 14), "lvl": 1, "heroes": []},
			{"id": "th_granary", "type": "Granary", "name": "山寨穀倉", "grid": Vector2i(14, 19), "lvl": 1, "heroes": []},
			{"id": "th_tw1", "type": "Watchtower", "name": "桃花寨門哨樓", "grid": Vector2i(16, 26), "lvl": 1, "heroes": []}
		],
		"heroes_spawn": []
	}
