-- Settings file for dedicated cabinet setup with PIUIO (MK6 IO) and PIUBTN ("Piu Pro" button board)
-- SGL will start even if both IO devices are not present
return {
    gfx = {
        fullscreen = true,
        res_width = 640,
        res_height = 480,
    },

    io = {
        update_rate_hz = 60,
        path_modules = "./data/io",

        modules = {
            "libio-piumk6",
            "libio-piubtn",
        },

        isp_scripts = {
            "io/piumk6/isp-attract.lua",
            "io/piumk6/isp-operator.lua",
            "io/piubtn/isp-attract.lua",
            "io/piubtn/isp-operator.lua",
        },

        osp_scripts = {
            "io/piumk6/osp-attract.lua",
            "io/piubtn/osp-attract.lua",
        },
    },

    screen = {
        attract = {
            font = "OpenSans-Regular.ttf",
            default_game_timeout_id = 0,
            default_game_timeout_duration_sec = 0,
        },
        
        boot = {
            title = "boot.png",
            min_duration_ms = 2000
        },

        error = {
            font = "OpenSans-Regular.ttf"
        },

        operator = {
            font = "OpenSans-Regular.ttf"
        },
    },

    sound = {
        driver = "",
        device = "",
        master_volume = 1.0,
        sfx_volume = 1.0,
    },

    system = {
        data_path = "./data",
        save_path = "./save"
    }
}
