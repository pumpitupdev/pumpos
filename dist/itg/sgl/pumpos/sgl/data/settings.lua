-- Settings file for dedicated cabinet setup with PIUIO (MK6 IO)
-- SGL will start even if the IO device is not present
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
            "libio-piumk6itg",
        },

        isp_scripts = {
            "io/piumk6itg/isp-attract.lua",
            "io/piumk6itg/isp-operator.lua",
        },

        osp_scripts = {
            "io/piumk6itg/osp-attract.lua",
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
