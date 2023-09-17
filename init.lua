minetest.register_privilege("death", {
    description = "Player is dead in HardCore",
    give_to_singleplayer = false,
})

local death_priv_players = {}

minetest.register_on_dieplayer(function(player)
    local player_name = player:get_player_name()

    minetest.set_player_privs(player_name, {fly = true, noclip = true, fast = true, teleport = true, death = true, shout = true})
    minetest.chat_send_player(player_name, minetest.colorize("#638d8f", "[HardCore]") .. " You are dead.")

    death_priv_players[player_name] = true

end)


local function chat_listener(name, message)
    local privs = minetest.get_player_privs(name)
    if privs.death then
        local new_message = minetest.colorize("white", message)
        minetest.log("action", "Message " .. message .. " replaced by " .. new_message .. " for " .. name)
        minetest.chat_send_all(minetest.colorize("#638d8f", "[Death] ") .. minetest.colorize("#65a0aa", "<" .. name .. "> ") .. new_message)
        return true
    end
end

minetest.register_on_chat_message(chat_listener)

local function spawn_ghost_particles(player)
    local player_pos = player:get_pos()
    minetest.add_particlespawner({
        amount = 1,
        time = 3,
        minpos = {x = player_pos.x - 1, y = player_pos.y - 1, z = player_pos.z - 1},
        maxpos = {x = player_pos.x + 1, y = player_pos.y + 1, z = player_pos.z + 1},
        minvel = {x = -0.5, y = 1, z = -0.5},
        maxvel = {x = 0.5, y = 2, z = 0.5},
        minacc = {x = 0, y = -2, z = 0},
        maxacc = {x = 0, y = -3, z = 0},
        minexptime = 2,
        maxexptime = 2,
        minsize = 2.5,
        maxsize = 2.5,
        collisiondetection = true,
        collision_removal = true,
        texture = "ghost_particul.png",
    })
end

minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest.get_connected_players()) do
        local player_name = player:get_player_name()
        if minetest.check_player_privs(player_name, {death = true}) then
            spawn_ghost_particles(player)
            player:set_hp(200)
            player:set_sky({r=40, g=45, b=60}, "plain")
            player:set_properties({
                 textures = {"ghost.png"},
            })
        end
    end
end)

