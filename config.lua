Config = {}
Config.Locale  = 'de'
Config.ServerTimeout = 500 -- Try to spawn the peds on server-side. If Config.ServerTimeout is reached, the hunting session will fail. Increase in larger hunting areas.
Config.ReqireHuntingJob = false
Config.HuntingWeapon = "WEAPON_MUSKET"
Config.SpawnJobVehicle = true
Config.JobVehicle = "blazer"
Config.JobVehicleSpawnLocation = vector4(-1057.4812, 4906.7769, 211.1111, 285.3532)
Config.UseOldESX = false
Config.Inventory = "ox"   -- esx or ox

-- Additional items given to the player while hunting. will be removed after hunting session end.
-- Only used when OX Inventory is set 
Config.HuntingItems = {
    {
        name = "ammo-musket",
        amount = 45
    },
    {
        name = "burger",
        amount = 3
    }, 
    -- add more items here
}


Config.Animals = {
    [1] = {
        ['model'] = "a_c_boar",
        ['probability'] = 0.1, --  = 10%
        ['loot'] = {
            meat=5,  -- maximum item number
            leather=2, -- maximum item number
        }
    },
    [2] = {
        ['model'] = "a_c_deer",
        ['probability'] = 0.3, --  = 30%
        ['loot'] = {
            meat=5,  -- maximum item number
            leather=2, -- maximum item number
        }
    },
    [3] = {
        ['model'] = "a_c_coyote",
        ['probability'] = 0.3, --  = 30%
        ['loot'] = {
            meat=5,  -- maximum item number
            leather=2, -- maximum item number
        }
    },
  [4] = {
        ['model'] = "a_c_husky",
        ['probability'] = 0.3, --  = 30%
        ['loot'] = {
            meat=5,  -- maximum item number
            leather=2, -- maximum item number
        }
    },
   [5] = {
    ['model'] = "a_c_pig",
    ['probability'] = 0.3, --  = 30%
    ['loot'] = {
        meat=5,  -- maximum item number
        leather=2, -- maximum item number
    }
   },
   [6] = {
    ['model'] = "a_c_pig"   ,
    ['probability'] = 0.3, --  = 30%
    ['loot'] = {
        meat=5,  -- maximum item number
        leather=2, -- maximum item number
    }
   },
   [7] = {
    ['model'] = "a_c_rabbit_01",
    ['probability'] = 0.3, --  = 30%
    ['loot'] = {
        meat=1,  -- maximum item number
        leather=3, -- maximum item number
    }
   }
}
Config.HuntingAreaRanges = {
    [1] = {
        ["coord"]= vector3(-1058.492310, 4899.758301, 211.864502),
        ["radius"] = 100.0 -- Larger values can cause problems: https://docs.fivem.net/docs/scripting-reference/onesync/. Use at your own risk.
        -- If you're experiencing problems, make sure to increase Config.ServerTimeout in larger hunting areas.
    }
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
Config.Notification.System = 'lp_notify' -- none / lp_notify -- not finished implemented jet
Config.Notification.displaytime = 1300 --ms
Config.Notification.Postion = "top right" -- Only works lp_notify! | lp_"top right", [top Left, top Right, bottom Left, bottom Right}


--[[
    If no animals spawning try to restart your server sometimes there to mutch Entities on it.
]]