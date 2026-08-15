hook.Add("InitLoadAnimations", "wOS.DynaBase.MWIII", function()
    wOS.DynaBase:RegisterSource({
        Name = "MWIII Takedowns/Downed Animations",
        Type = WOS_DYNABASE.EXTENSION,
        Shared = "models/mwiii/dynabase_player_anims.mdl",
    })

    hook.Add("PreLoadAnimations", "wOS.DynaBase.MWIII", function(gender)
        if gender == WOS_DYNABASE.SHARED then
            IncludeModel("models/mwiii/dynabase_player_anims.mdl")
        end
    end)
end)
