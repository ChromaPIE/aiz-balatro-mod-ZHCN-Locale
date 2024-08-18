-- Chess rook
-- Turn cards into stone.
-- Discarded cards are turned
-- -1 discard because of this.
SMODS.Joker({
    key = "chess_rook",
    loc_txt = {
        name = "车",
        text = {
            "弃牌次数{C:attention}-#1#",
            "将{C:attention}弃掉{}的卡牌增强为{C:attention}石头牌",
            "按{C:attention}完整牌组{}中",
            "{C:attention}石头牌{}的占比给予{X:mult,C:white}乘倍",
            "{C:inactive}（当前为{X:mult,C:white}X#2#{C:inactive}倍率）",
        },
    },
    config = {
        extra = {
            discard_size = 1,
            base = 4, -- controls max mult
            exponent = 2, -- controls how fast/slow mult should grow
        },
    },
    atlas = "jokers",
    pos = { y = 1, x = 5 },
    rarity = 3,
    cost = 8,
    blueprint_compat = true,
    -- makes sure this joker doesn't spawn in any pools
    yes_pool_flag = "this flag will never be set",

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.discard_size,
                self.get_mult(card),
            },
        }
    end,

    get_mult = function(card)
        if G.playing_cards == nil then
            return 1
        else
            local stone_tally = 0
            for _, v in pairs(G.playing_cards) do
                if v.config.center == G.P_CENTERS.m_stone then
                    stone_tally = stone_tally + 1
                end
            end

            return card.ability.extra.base
                ^ (
                    (stone_tally / #G.playing_cards)
                    ^ card.ability.extra.exponent
                )
        end
    end,

    calculate = function(self, card, context)
        if context.pre_discard and not context.blueprint then
            for i = 1, #G.hand.highlighted do
                Aiz.utils.flip_card_event(G.hand.highlighted[i])
            end
            for i = 1, #G.hand.highlighted do
                G.E_MANAGER:add_event(Event({
                    trigger = "after",
                    delay = 0.1,
                    func = function()
                        G.hand.highlighted[i]:set_ability(
                            G.P_CENTERS["m_stone"]
                        )
                        return true
                    end,
                }))
            end
            for i = 1, #G.hand.highlighted do
                Aiz.utils.flip_card_event(G.hand.highlighted[i])
            end
            delay(0.3)
        end
        if context.joker_main then
            local mult = self.get_mult(card)
            return {
                message = localize({
                    type = "variable",
                    key = "a_xmult",
                    vars = { mult },
                }),
                Xmult_mod = mult,
            }
        end
    end,

    add_to_deck = function(self, card, from_debuff)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards
            - card.ability.extra.discard_size
        ease_discard(-card.ability.extra.discard_size)
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards
            + card.ability.extra.discard_size
        ease_discard(card.ability.extra.discard_size)
    end,
})
