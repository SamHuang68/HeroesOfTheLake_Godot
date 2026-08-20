# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 00~36 角色 3D/2.5D 模型與特徵數據庫 (Character Model Database)
class_name CharacterModelDatabase
extends RefCounted

## 00~36 共 55 款人物模型特徵資料表
static var models_table := {
	"00": { "name": "金甲都督/首領", "gender": "M", "features": "亮金頭盔、紅披風、金鎖子甲", "weapon": "長槍", "r_socket": "spear", "l_socket": "none", "is_female": false },
	"01": { "name": "白袍名將", "gender": "M", "features": "金冠、白袍外罩黑背心", "weapon": "長槍", "r_socket": "spear", "l_socket": "none", "is_female": false },
	"02": { "name": "儒雅軍師", "gender": "M", "features": "綸巾、藍白道袍、長鬚", "weapon": "羽扇", "r_socket": "fan", "l_socket": "scroll", "is_female": false },
	"03": { "name": "白衣文官", "gender": "M", "features": "儒巾、寬袖純白長袍、微胖身型", "weapon": "無", "r_socket": "none", "l_socket": "none", "is_female": false },
	"04": { "name": "綠袍戰將", "gender": "M", "features": "藍冠戰盔、翠綠戰袍、肩吞獸甲", "weapon": "偃月刀", "r_socket": "glaive", "l_socket": "none", "is_female": false },
	"05": { "name": "藍羽副將", "gender": "M", "features": "紅頂羽冠、藍白戰鎧、紅護肩", "weapon": "鉤鐮槍", "r_socket": "spear", "l_socket": "none", "is_female": false },
	"06": { "name": "重裝狼牙將", "gender": "M", "features": "尖頂鋼盔、紅袍黃甲", "weapon": "狼牙棒", "r_socket": "mace", "l_socket": "none", "is_female": false },
	"07": { "name": "雙刀女將/游俠", "gender": "F", "features": "藍色頭巾、青金軟甲、修身長褲", "weapon": "雙手短刀", "r_socket": "blade", "l_socket": "blade", "is_female": true },
	"08": { "name": "貴冑羽冠士", "gender": "M", "features": "高聳紅羽盔、紫藍錦袍、藍披風", "weapon": "無", "r_socket": "none", "l_socket": "none", "is_female": false },
	"09": { "name": "錦袍槍將", "gender": "M", "features": "虎頭兜鍪、紅藍相間重鎧", "weapon": "丈八長矛", "r_socket": "spear", "l_socket": "none", "is_female": false },
	"0A": { "name": "拂塵狂道", "gender": "M", "features": "禿頂/髮髻、黑白太極道袍", "weapon": "拂塵", "r_socket": "whisk", "l_socket": "sword", "is_female": false },
	"0B": { "name": "披髮刀客", "gender": "M", "features": "長髮披肩、黑白勁裝", "weapon": "佩刀", "r_socket": "blade", "l_socket": "none", "is_female": false },
	"0C": { "name": "青衣女俠/哨兵", "gender": "F", "features": "雙髻藍巾、青白戰衣、白色護臂", "weapon": "雙尖長梭鏢", "r_socket": "spear", "l_socket": "none", "is_female": true },
	"0D": { "name": "靈珠行者", "gender": "M", "features": "藍帽黑緣、紫綠道袍", "weapon": "乾坤圈", "r_socket": "ring", "l_socket": "none", "is_female": false },
	"0E": { "name": "白藍刀俠", "gender": "M", "features": "藍巾包頭、白藍滾邊武服", "weapon": "朴刀", "r_socket": "blade", "l_socket": "none", "is_female": false },
	"0F": { "name": "鐵甲重斧兵", "gender": "M", "features": "鋼盔、棕色皮甲", "weapon": "大板斧", "r_socket": "axe", "l_socket": "none", "is_female": false },
	"10": { "name": "雙斧狂戰", "gender": "M", "features": "裸上身、黑色短打、身形魁梧", "weapon": "雙板斧", "r_socket": "axe", "l_socket": "axe", "is_female": false },
	"11": { "name": "紋身水軍刺客", "gender": "M", "features": "束髮裸上身、青龍紋身、灰白長褲", "weapon": "短叉", "r_socket": "spear", "l_socket": "dagger", "is_female": false },
	"12": { "name": "水泊櫓手", "gender": "M", "features": "白頭巾、藍白水手無袖褂", "weapon": "木槳", "r_socket": "oar", "l_socket": "none", "is_female": false },
	"13": { "name": "斗笠漁獵手", "gender": "M", "features": "竹編斗笠、無袖藍褂、露胸膛", "weapon": "三叉戟", "r_socket": "trident", "l_socket": "none", "is_female": false },
	"14": { "name": "藍巾水匪", "gender": "M", "features": "藍色短巾、裸身斜背背帶、深色水褲", "weapon": "水手短刀", "r_socket": "blade", "l_socket": "none", "is_female": false },
	"15": { "name": "勁弩機關士", "gender": "M", "features": "黑髮髻、白底黃邊短袍", "weapon": "木弩", "r_socket": "crossbow", "l_socket": "none", "is_female": false },
	"16": { "name": "赤甲長槍騎將", "gender": "M", "features": "紅羽高盔、全套赤紅重甲", "weapon": "長槍", "r_socket": "spear", "l_socket": "none", "is_female": false },
	"17": { "name": "火器轟天雷", "gender": "M", "features": "銅盔赤甲、身背引信包", "weapon": "火把", "r_socket": "torch", "l_socket": "cannon", "is_female": false },
	"18": { "name": "赤紅統領", "gender": "M", "features": "紅翎金盔、全套赤紅雲紋戰甲", "weapon": "方天畫戟", "r_socket": "halberd", "l_socket": "none", "is_female": false },
	"19": { "name": "雙刀女首領", "gender": "F", "features": "金鳳凰冠、紫粉華麗戰甲、披帛", "weapon": "雙手繡鸞刀", "r_socket": "blade", "l_socket": "blade", "is_female": true },
	"1A": { "name": "尊爵官宦/太守", "gender": "M", "features": "展翅官帽、紫紅重錦袍、金玉腰帶", "weapon": "無", "r_socket": "none", "l_socket": "none", "is_female": false },
	"1B": { "name": "團牌滾刀手", "gender": "M", "features": "鋼箍束髮、無袖短衣、虎紋戰裙", "weapon": "單刀+團牌", "r_socket": "blade", "l_socket": "shield", "is_female": false },
	"1C": { "name": "藍紫女統領", "gender": "F", "features": "珠翠髮冠、藍紫漸層宮廷戰袍", "weapon": "柳葉刀", "r_socket": "blade", "l_socket": "none", "is_female": true },
	"1D": { "name": "白金羽林將", "gender": "M", "features": "金冠束髮、白底金邊重裝鎧甲", "weapon": "龍紋長槍", "r_socket": "spear", "l_socket": "none", "is_female": false },
	"1E": { "name": "綠錦謀士", "gender": "M", "features": "斗笠式文官帽、綠白滾邊寬袍", "weapon": "無", "r_socket": "none", "l_socket": "none", "is_female": false },
	"1F": { "name": "絕色佳人", "gender": "F", "features": "高聳雲髻、紫粉金邊絲綢長裙、飄帶", "weapon": "絲絹手帕", "r_socket": "silk", "l_socket": "fan", "is_female": true },
	"20": { "name": "貴婦/深閨少女", "gender": "F", "features": "盤髮金簪、紅黃相間宮裝漢服", "weapon": "無", "r_socket": "none", "l_socket": "none", "is_female": true },
	"21": { "name": "蓬頭赤衣狂士", "gender": "M", "features": "凌亂狂髮、紅黑破布袍、赤腳", "weapon": "無", "r_socket": "none", "l_socket": "none", "is_female": false },
	"22": { "name": "藍冠紫袍縣令", "gender": "M", "features": "藍色硬翅官帽、深紫官服", "weapon": "無", "r_socket": "none", "l_socket": "none", "is_female": false },
	"23": { "name": "綠巾老者/員外", "gender": "M", "features": "綠色方巾、土黃色員外錦袍、長白鬚", "weapon": "拐杖", "r_socket": "cane", "l_socket": "none", "is_female": false },
	"24": { "name": "黑衣禁軍教頭", "gender": "M", "features": "黑色軟腳幞頭、純黑武僧勁裝", "weapon": "齊眉棍", "r_socket": "staff", "l_socket": "none", "is_female": false },
	"25": { "name": "步軍皮甲正兵", "gender": "M", "features": "紅纓小笠盔、藍黃相間實用皮甲", "weapon": "長矛", "r_socket": "spear", "l_socket": "none", "is_female": false },
	"26": { "name": "棕袍商賈/掌櫃", "gender": "M", "features": "棕色尖頂帽、深棕窄袖便服", "weapon": "算盤", "r_socket": "abacus", "l_socket": "none", "is_female": false },
	"27": { "name": "白袍平民/書生", "gender": "M", "features": "黑色書生巾、純白素面布袍", "weapon": "無", "r_socket": "none", "l_socket": "none", "is_female": false },
	"28": { "name": "紅巾短打壯漢", "gender": "M", "features": "紅色抹額、綠黃拼色短打、結實肌肉", "weapon": "無", "r_socket": "none", "l_socket": "none", "is_female": false },
	"29": { "name": "簑衣老農", "gender": "M", "features": "粗布包頭、棕色厚麻布衣、短草裙", "weapon": "乾草叉", "r_socket": "pitchfork", "l_socket": "none", "is_female": false },
	"2A": { "name": "露胸獵戶", "gender": "M", "features": "黑色布帶、開襟藍褂、綁腿草鞋", "weapon": "鋼叉", "r_socket": "trident", "l_socket": "none", "is_female": false },
	"2B": { "name": "棕色短工/工匠", "gender": "M", "features": "簡易束髮、棕色交叉領粗布短衣", "weapon": "木工斧", "r_socket": "axe", "l_socket": "none", "is_female": false },
	"2C": { "name": "黑袍太極道士", "gender": "M", "features": "道教金簪、黑底白八卦道袍", "weapon": "桃木劍", "r_socket": "sword", "l_socket": "whisk", "is_female": false },
	"2D": { "name": "紅裙村姑/廚娘", "gender": "F", "features": "雙環髻、白上衣配大紅圍裙", "weapon": "木盆", "r_socket": "none", "l_socket": "basket", "is_female": true },
	"2E": { "name": "綠袍富家千金", "gender": "F", "features": "毛絨暖帽、翠綠冬裝錦襖", "weapon": "暖手筒", "r_socket": "none", "l_socket": "none", "is_female": true },
	"2F": { "name": "藍袍長翎小將", "gender": "M", "features": "插雉雞翎金冠、天藍色戰袍", "weapon": "長槍", "r_socket": "spear", "l_socket": "none", "is_female": false },
	"30": { "name": "藍袍文職幕僚", "gender": "M", "features": "黑色展翅幞頭、寶藍色官袍", "weapon": "竹簡", "r_socket": "scroll", "l_socket": "none", "is_female": false },
	"31": { "name": "獨眼莽漢/山賊", "gender": "M", "features": "黑色眼罩、綠棕拼色短打、肌肉壯碩", "weapon": "無", "r_socket": "none", "l_socket": "none", "is_female": false },
	"32": { "name": "藍甲步兵長", "gender": "M", "features": "藍巾鐵盔、深藍扎甲", "weapon": "朴刀", "r_socket": "blade", "l_socket": "none", "is_female": false },
	"33": { "name": "銀白雀翎將", "gender": "M", "features": "白羽翎金盔、銀白鎖子甲、藍內襯", "weapon": "雙耳銀戟", "r_socket": "halberd", "l_socket": "none", "is_female": false },
	"34": { "name": "赤金大都督", "gender": "M", "features": "紅翎戰盔、純金雕花重鎧、大紅斗篷", "weapon": "帥旗寶劍", "r_socket": "sword", "l_socket": "flag", "is_female": false },
	"35": { "name": "藍巾鐵銃兵", "gender": "M", "features": "藍布包頭鋼盔、鐵甲護胸", "weapon": "短火銃", "r_socket": "gun", "l_socket": "none", "is_female": false },
	"36": { "name": "黃袍翎冠帥", "gender": "M", "features": "雙翎金盔、明黃色龍雲戰袍、赤紅肩帶", "weapon": "蟠龍金棍", "r_socket": "staff", "l_socket": "none", "is_female": false }
}

## 歷史好漢與 00~36 模型外觀對照表
static var hero_to_model_map := {
	"LinChong": "01",      # 林沖 -> 01 白袍名將
	"WuSong": "0B",        # 武松 -> 0B 披髮刀客
	"LuZhishen": "24",     # 魯智深 -> 24 黑衣禁軍教頭
	"LiJun": "12",         # 李俊 -> 12 水泊櫓手
	"YangZhi": "0E",       # 楊志 -> 0E 白藍刀俠
	"ShiJin": "11",        # 史進 -> 11 九紋龍水軍刺客
	"HuaRong": "2F",       # 花榮 -> 2F 藍袍長翎小將
	"DaiZong": "0D",       # 戴宗 -> 0D 靈珠神行行者
	"SongJiang": "00",     # 宋江 -> 00 金甲都督/首領
	"WuYong": "02",        # 吳用 -> 02 儒雅軍師
	"GongsunSheng": "2C",  # 公孫勝 -> 2C 太極道士
	"GuanSheng": "04",     # 關勝 -> 04 綠袍戰將
	"HuYanzhuo": "09",     # 呼延灼 -> 09 錦袍槍將
	"QinMing": "06",       # 秦明 -> 06 重裝狼牙將
	"DongPing": "05",      # 董平 -> 05 藍羽副將
	"ZhangQing": "01",     # 張清 -> 01 白袍名將
	"LiKui": "10",         # 李逵 -> 10 雙斧狂戰
	"ChaiJin": "08",       # 柴進 -> 08 貴冑羽冠士
	"LuJunyi": "34",       # 盧俊義 -> 34 赤金大都督
	"YanQing": "11",       # 燕青 -> 11 刺青游俠
	"RuanXiaoer": "13",    # 阮小二 -> 13 斗笠漁獵手
	"RuanXiaowu": "14",    # 阮小五 -> 14 藍巾水匪
	"RuanXiaoqi": "14",    # 阮小七 -> 14 藍巾水匪
	"ZhangShun": "12",     # 張順 -> 12 水泊浪裡白條
	"ZhangHeng": "13",     # 張橫 -> 13 船火兒
	"SunErniang": "07",    # 孫二娘 -> 07 雙刀女將 (女)
	"HuSanniang": "19",    # 扈三娘 -> 19 雙刀女首領 (女)
	"GuDasao": "2D",       # 顧大嫂 -> 2D 紅裙廚娘 (女)
	"LiShishi": "1F",      # 李師師 -> 1F 絕色佳人 (女)
	"PanJinlian": "20",    # 潘金蓮 -> 20 貴婦少女 (女)
	"LingZhen": "17",      # 凌振 -> 17 火器轟天雷
	"TangLong": "2B",      # 湯隆 -> 2B 工匠短工
	"TaoZongwang": "29",   # 陶宗旺 -> 29 簑衣老農
	"ZhuGui": "26",        # 朱貴 -> 26 掌櫃商賈
	"FanRui": "0A",        # 樊瑞 -> 0A 拂塵狂道
	"XiangChong": "1B",    # 項充 -> 1B 團牌滾刀手
	"LiGun": "1B",         # 李袞 -> 1B 團牌滾刀手
	"ShiWengong": "33",    # 史文恭 -> 33 銀白雀翎將
	"GaoQiu": "1A",        # 高俅 -> 1A 尊爵太守官宦
	"CaiJing": "22",       # 蔡京 -> 22 紫袍縣令
	"TongGuan": "36"       # 童貫 -> 36 黃袍翎冠帥
}

static func get_model_info(model_id: String) -> Dictionary:
	return models_table.get(model_id, models_table["00"])

static func get_model_for_hero(hero_id: String) -> String:
	return hero_to_model_map.get(hero_id, "00")
