-- Settings file for dedicated cabinet setup with PIUIO (MK6 IO)
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
            "libio-piumk6.so",
        },

        isp_scripts = {
            "io/piumk6/isp-attract.lua",
            "io/piumk6/isp-operator.lua",
        },

        osp_scripts = {
            "io/piumk6/osp-attract.lua",
        },
    },

    screen = {
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
        master_volume = 1.0,
        sfx_volume = 1.0
    },

    system = {
        data_path = "./data",
        save_path = "./save"
    }
}