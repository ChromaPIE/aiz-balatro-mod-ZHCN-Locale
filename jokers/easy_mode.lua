SMODS.Joker({
    key = "easy_mode",
    loc_txt = {
        name = "简单模式",
        text = {
            "收藏中每有{C:attention}2{}张小丑牌",
            "带有{C:attention}白色纪念贴{}",
            "{C:mult}+1{}倍率",
            "{C:inactive}（当前为{C:mult}+#1#{C:inactive}倍率）",
        },
    },
    config = {
        extra = {
            mult_mod = 0.5,
            sticker = "white",
        },
    },
    atlas = "jokers",
    pos = { y = 0, x = 2 },
    rarity = 2,
    cost = 7,
    blueprint_compat = true,

    get_mult = function(card)
        local mult = 0
        -- Add mult for every sticker matching
        for _, v in pairs(G.P_CENTERS) do
            if v.set == "Joker" then
                if
                    get_joker_win_sticker(v, false)
                    == card.ability.extra.sticker
                then
                    mult = mult + card.ability.extra.mult_mod
                end
            end
        end
        return math.floor(mult)
    end,

    loc_vars = function(self, info_queue, card)
        return { vars = { self.get_mult(card) } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                message = localize({
                    type = "variable",
                    key = "a_mult",
                    vars = { self.get_mult(card) },
                }),
                mult_mod = self.get_mult(card),
            }
        end
    end,
})
