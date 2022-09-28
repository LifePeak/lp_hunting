Config = {}
Config.Locale  = 'de'

Config.HuntingWeapon = "WEAPON_MUSKET"
Config.HuntingAreaRange = 460.0

Config.HunntingAnimals = {
    [0] = {
        ['model'] = "a_c_boar"
        ['probability'] = 0.1, --  = 10%
    }
    [1] = {
        ['model'] = "a_c_deer"
        ['probability'] = 0.3, --  = 30%
    }
    [2] = {
        ['model'] = "a_c_coyote"
        ['probability'] = 0.3, --  = 30%
    }
    [3] = {
        ['model'] = "a_c_husky"
        ['probability'] = 0.3, --  = 30%
    }
   [4] = {
    ['model'] = "a_c_pig"
    ['probability'] = 0.3, --  = 30%
   }
   [5] = {
    ['model'] = "a_c_pig"
    ['probability'] = 0.3, --  = 30%
   }
   [6] = {
    ['model'] = "a_c_rabbit_01"
    ['probability'] = 0.3, --  = 30%
   }
}
Cofing.HuntingAreaRanges = {
    [0] = {
        ["coord"]= vector3(1,1,1),
        ["radius"] = 460
    },
    [1] = {
        ["coord"]= vector3(1,1,1),
        ["radius"] = 460
    }
}
Config.HunntingMensions {
    [0] = {
        ["coord"] = vector3(1,3,5),
        ["actions"] = {"start","sell"}
    }
}

Config.Notification = {}
Config.Notification.System = 'lp_notify' -- none / lp_notify
Config.Notification.displaytime = 1300 --ms
Config.Notification.Postion = "top right" -- Only works lp_notify! | lp_"top right", [top Left, top Right, bottom Left, bottom Right]
