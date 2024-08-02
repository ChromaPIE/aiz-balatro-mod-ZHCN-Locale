SMODS.Joker({
    key = "battle_pass",
    loc_txt = {
        name = "战斗通行证",
        text = {
            "使用{C:attention}星球牌{}以外的途径",
			"升级牌型时，额外{C:attention}+#1#{}级",
        },
    },
    config = {
        extra = {
            levels = 2,
        },
    },
    atlas = "jokers",
    pos = { y = 3, x = 1 },
    rarity = 1,
    cost = 5,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.levels } }
    end,
})
