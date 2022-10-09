Config = {}
Config.Locale  = 'de'
Config.ReqireHuntingJob = false
Config.HuntingWeapon = "WEAPON_MUSKET"
Config.SpawnJobVehicle = false
Config.JobVehicle = "blazer"
Config.Animals = {
    [1] = {
        ['model'] = "a_c_boar",
        ['probability'] = 0.1, --  = 10%
    },
    [2] = {
        ['model'] = "a_c_deer",
        ['probability'] = 0.3, --  = 30%
    },
    [3] = {
        ['model'] = "a_c_coyote",
        ['probability'] = 0.3, --  = 30%
    },
    --[[
  [4] = {
        ['model'] = "a_c_husky",
        ['probability'] = 0.3, --  = 30%
    },
    --]]
  
   [5] = {
    ['model'] = "a_c_pig",
    ['probability'] = 0.3, --  = 30%
   },
   [6] = {
    ['model'] = "a_c_pig",
    ['probability'] = 0.3, --  = 30%
   },
   [7] = {
    ['model'] = "a_c_rabbit_01",
    ['probability'] = 0.3, --  = 30%
   }
}
Config.HuntingAreaRanges = {
    [1] = {
        ["coord"]= vector3(-1058.492310, 4899.758301, 211.864502),
        ["radius"] = 60.0
    },
    --[[

   
    [2] = {
        ["coord"]= vector3(-1058.8522949219, 4915.3295898438, 211.81875610352),
        ["radius"] = 460
    },
  
    [3] = {
        ["coord"]= vector3(1,1,1),
        ["radius"] = 460
    }
      -- ]]
}
Config.Mensions = {
    StartHunting = {
        vector3(-1058.8522949219, 4915.3295898438,211.81875610352),
    },
    Sell = {
        vector3(-1073.894531, 4898.505371, 214.257202),
    }
}

Config.Notification = {}
Config.Notification.System = 'lp_notify' -- none / lp_notify
Config.Notification.displaytime = 1300 --ms
Config.Notification.Postion = "top right" -- Only works lp_notify! | lp_"top right", [top Left, top Right, bottom Left, bottom Right]