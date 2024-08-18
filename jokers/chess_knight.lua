SMODS.Joker({
    key = "chess_knight",
    loc_txt = {
        name = "马",
        text = {
            "将计分的{C:attention}#2#色{}花色牌",
            "转换为随机一种{C:attention}#3#色{}花色",
            "每发生一次转换，给予{C:mult}+#1#{}倍率",
            "{s:0.8}转换后卡牌顺序将发生改变",
        },
    },
    config = {
        extra = {
            mult = 0,
            mult_mod = 10,
            change = {
                from = "暗",
                to = "亮",
            },
        },
    },
    atlas = "jokers",
    pos = { y = 1, x = 3 },
    rarity = 2,
    cost = 6,
    blueprint_compat = true,
    -- makes sure this joker doesn't spawn in any pools
    yes_pool_flag = "this flag will never be set",

    --TODO use dark/light color for text instead of attention.
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.mult_mod,
                localize("k_aiz_" .. card.ability.extra.change.from:lower()),
                localize("k_aiz_" .. card.ability.extra.change.to:lower()),
            },
        }
    end,

    set_ability = function(self, card)
        -- Randomize starting suits.
        -- Partially just to make it easier to have multiple knights be useful together.
        local change_to_light = (0.5 > pseudorandom("knight_suits"))
        card.ability.extra.change.from = (change_to_light and "暗" or "亮")
        card.ability.extra.change.to = (change_to_light and "亮" or "暗")
    end,

    calculate = function(self, card, context)
        --TODO try to fix debuff texture visible before new suit is. for bosses that debuff suits
        if
            context.cardarea == G.jokers
            and context.before
            and not context.blueprint
        then
            -- Reset mult every round
            card.ability.extra.mult = 0
            -- table used so i don't have to do the check thrice
            local converted_cards = {}
            -- Flip cards and calculate mult
            for _, playing_card in ipairs(context.scoring_hand) do
                if
                    Aiz.utils.is_suit_type(
                        playing_card,
                        card.ability.extra.change.from
                    )
                then
                    Aiz.utils.flip_card_event(playing_card)
                    table.insert(converted_cards, playing_card)
                end
            end
            -- Change suit
            for _, playing_card in ipairs(converted_cards) do
                local new_suit = Aiz.utils.get_random_suit_of_type(
                    card.ability.extra.change.to
                )
                -- This is hopefully fine. I just don't want any sprite changes at this point
                playing_card.base.suit = new_suit

                -- Handle debuffing card after being played
                -- set to false so pillar doesn't debuff valid cards
                playing_card.ability.played_this_ante = false
                -- Do a debuff check manually so debuffs are applied
                -- This will show some cards as debuffed before their suit is changed.
                G.GAME.blind:debuff_card(playing_card)
                G.E_MANAGER:add_event(Event({
                    delay = 0.15,
                    trigger = "after",
                    func = function()
                        -- Set to false here again to handle multiple knights
                        playing_card.ability.played_this_ante = false
                        playing_card:change_suit(new_suit)
                        -- set to true again after suit change because of call to blind:debuff_card()
                        playing_card.ability.played_this_ante = true
                        return true
                    end,
                }))
            end
            -- flip cards back
            for _, playing_card in ipairs(converted_cards) do
                Aiz.utils.flip_card_event(playing_card)
            end
            if #converted_cards > 0 then
                -- Calculate mult this round
                card.ability.extra.mult = card.ability.extra.mult
                    + card.ability.extra.mult_mod * #converted_cards
                return {
                    message = localize({
                        type = "variable",
                        key = "a_mult",
                        vars = { card.ability.extra.mult },
                    }),
                    colour = G.C.MULT,
                    card = card,
                }
            end
        end

        -- I gave up and seperated card conversion and mult giving into 2 steps.
        -- This is why blueprint won't convert cards anymore
        if context.joker_main then
            if card.ability.extra.mult > 0 then
                return {
                    message = localize({
                        type = "variable",
                        key = "a_mult",
                        vars = { card.ability.extra.mult },
                    }),
                    mult_mod = card.ability.extra.mult,
                }
            end
        end

        if context.after and card.ability.extra.mult > 0 then
            -- flip conversion
            card.ability.extra.change.from, card.ability.extra.change.to =
                card.ability.extra.change.to, card.ability.extra.change.from

            Aiz.utils.status_text(
                card,
                "k_aiz_" .. card.ability.extra.change.from:lower(),
                card.ability.extra.change.from == "Light" and G.C.FILTER
                    or G.C.BLACK
            )
        end
    end,
})
