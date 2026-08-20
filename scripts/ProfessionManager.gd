# Copyright (c) 2026 Sam Huang. All Rights Reserved.
# 《水滸英雄錄：天導108星》- 職業系統 (Profession System)
class_name ProfessionManager
extends RefCounted

# Profession constants matching Suikoden II
enum Profession {
    VILLAGER = 0,
    MERCHANT = 1,
    ARTISAN = 2,
    VILLAGE_PERSON = 3,
    ENTERTAINER = 4,
    SCHOLAR = 5,
    TAOIST = 6,
    DOCTOR = 7,
    THIEF = 8,
    MOUNTAIN_PERSON = 9,
    BOATMAN = 10,
    ALCOHOL_MERCHANT = 11,
    GIRL = 12,
    COLOR_PERSON = 13,
    STUDENT = 14,
    STRONG_PERSON = 15
}

# Profession names in Chinese (matching Suikoden II)
const PROFESSION_NAMES := [
    "村民",      # 0
    "商人",      # 1
    "工匠",      # 2
    "村民",      # 3 (same as 0 but different context)
    "藝人",      # 4
    "學士",      # 5
    "道士",      # 6
    "醫生",      # 7
    "盜賊",      # 8
    "山居者",    # 9
    "船夫",      # 10
    "酒商",      # 11
    "少女",      # 12
    "色男",      # 13
    "學士",      # 14 (same as 5 but different context)
    "力士"       # 15
]

# Profession titles for each level (0-4)
const PROFESSION_TITLES := [
    ["無賴", "俠客", "壯士", "勇者", "豪傑"],           # 刁民 (VILLAGER/STRONG_PERSON context)
    ["露天商", "行商人", "批發商", "富商", "富翁"],      # 商人
    ["徒弟", "工匠", "技工", "師匠", "巨匠"],            # 匠人
    ["小作農", "農夫", "富農", "地主", "土豪"],          # 村民
    ["雜藝人", "龍套", "主角", "名角", "台柱"],          # 藝人
    ["書生", "學士", "秀才", "碩學", "翰林"],            # 學士
    ["修練者", "方士", "道士", "魔君", "真人"],          # 道士
    ["庸醫", "村醫", "名醫", "大醫", "神醫"],            # 醫生
    ["毛賊", "小偷", "大盜", "義賊", "怪盜"],            # 盜賊
    ["野人", "獵戶", "山賊", "馴獸師", "山大王"],        # 山居者
    ["水手", "漁夫", "舵手", "水賊", "大水賊"],          # 船夫
    ["侍者", "茶房", "釀酒師", "造酒商", "酒館主"],      # 酒商
    ["少女", "美人", "佳人", "傾城", "傾國"],            # 少女
    ["浪子", "放蕩者", "登徒子", "公子哥", "貴公子"],    # 色男
    ["書生", "學士", "秀才", "碩學", "翰林"],            # 學士 (duplicate for context)
    ["保鏢", "強者", "大力士", "哼哈將", "金剛"]         # 力士
]

# Experience required for each level (0->1, 1->2, 2->3, 3->4)
const PROFESSION_EXP_REQUIREMENTS := [100, 300, 600, 1000]

# How professions gain experience
const PROFESSION_EXP_METHODS := [
    "在耕地工作",                           # 0: VILLAGER
    "在市場工作",                           # 1: MERCHANT
    "在鐵匠鋪或造船場工作",                 # 2: ARTISAN
    "在耕地工作",                           # 3: VILLAGE_PERSON (same as villager)
    "在鬧市工作",                           # 4: ENTERTAINER
    "外交、建造柵欄",                       # 5: SCHOLAR
    "在道觀工作",                           # 6: TAOIST
    "在藥鋪工作",                           # 7: DOCTOR
    "建造陷阱、竊盜敵人物品",               # 8: THIEF
    "在牧場工作、種植樹木",                 # 9: MOUNTAIN_PERSON
    "在漁場工作",                           # 10: BOATMAN
    "在酒館工作",                           # 11: ALCOHOL_MERCHANT
    "錄用、戰場中迷惑到男敵人（隨機）",    # 12: GIRL
    "錄用、戰場中迷惑到女敵人（隨機）",    # 13: COLOR_PERSON
    "外交、建造柵欄",                       # 14: STUDENT (same as scholar)
    "練兵或建造軍營、練兵場"                # 15: STRONG_PERSON
]

# Special abilities by profession level
const PROFESSION_SPECIAL_ABILITIES := [
    # VILLAGER/STRONG_PERSON (index 0 and 15 share some)
    [null, null, null, null, "練兵、戰場中對迷惑或酒盛的隊友進行吶喊（隨機）"],  # Index 15 (STRONG_PERSON)
    # MERCHANT
    [null, null, null, null, null],
    # ARTISAN
    [null, null, null, null, null],
    # VILLAGE_PERSON
    [null, null, null, null, null],
    # ENTERTAINER
    [null, null, null, null, null],
    # SCHOLAR
    ["增進友誼", "締結同盟、解除盟約、挑釁訪問、索討物品", null, null, null],
    # TAOIST
    [null, null, null, null, "可在戰場中使用妖術"],
    # DOCTOR
    [null, null, null, null, null],
    # THIEF
    [null, null, "2級盜賊可對敵人下迷魂藥", "3級盜賊可前去營救俘虜", null],
    # MOUNTAIN_PERSON
    [null, null, null, null, null],
    # BOATMAN
    [null, null, null, null, null],
    # ALCOHOL_MERCHANT
    [null, null, null, null, null],
    # GIRL
    [null, null, null, null, null],
    # COLOR_PERSON
    [null, null, null, null, null],
    # STUDENT
    ["增進友誼", "締結同盟、解除盟約、挑釁訪問、索討物品", null, null, null],
    # STRONG_PERSON
    [null, null, null, null, "練兵、戰場中對迷惑或酒盛的隊友進行吶喊（隨機）"]
]

func get_profession_name(profession_id: int) -> String:
	if profession_id < 0 or profession_id >= PROFESSION_NAMES.size():
		return "未知"
	return PROFESSION_NAMES[profession_id]

func get_profession_title(profession_id: int, level: int) -> String:
	if profession_id < 0 or profession_id >= PROFESSION_TITLES.size():
		return "未知"
	if level < 0 or level > 4:
		return "未知"
	return PROFESSION_TITLES[profession_id][level]

func get_profession_exp_method(profession_id: int) -> String:
	if profession_id < 0 or profession_id >= PROFESSION_EXP_METHODS.size():
		return "未知工作方式"
	return PROFESSION_EXP_METHODS[profession_id]

func get_profession_special_ability(profession_id: int, level: int) -> String:
	if profession_id < 0 or profession_id >= PROFESSION_SPECIAL_ABILITIES.size():
		return null
	if level < 0 or level > 4:
		return null
	return PROFESSION_SPECIAL_ABILITIES[profession_id][level]

func get_exp_required_for_level(current_level: int) -> int:
	if current_level < 0 or current_level >= PROFESSION_EXP_REQUIREMENTS.size():
		return 0
	return PROFESSION_EXP_REQUIREMENTS[current_level]

func can_gain_profession_exp(profession_id: int, action_type: String) -> bool:
	var method := get_profession_exp_method(profession_id)
	# Simplified check - in practice would match against specific actions
	return method != "未知工作方式" && !method.is_empty()