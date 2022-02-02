#!/usr/bin/env python3

# Customizes the fancyzones powertoy's custom screen layouts
# Example usage:
# python fancy-zones-write-config.py /mnt/c/Users/Admin/AppData/Local/Microsoft/PowerToys/FancyZones/zones-settings.json

fancy_zones_config_file = "/mnt/c/Users/Admin/AppData/Local/Microsoft/PowerToys/FancyZones/zones-settings.json"

# screen size scaled down from 3840x1600 by DPI scaling
screen_width = 3072
screen_height = 1240

col = 3072 // 12

left_tiny = 400
left_small = 850
left_med = 1100
left_big = 1400

middle = screen_width // 2

right_tiny = screen_width - left_tiny
right_small = screen_width - left_small
right_med = screen_width - left_med
right_big = screen_width - left_big


def xw(x, w):
    return {
        "X": x,
        "Y": 0,
        "width": w,
        "height": screen_height,
    }


def xx(x1, x2):
    return xw(x1, x2 - x1)


import json

with open(fancy_zones_config_file, "r") as f:
    existing = json.load(f)

existing["custom-zone-sets"] = [
    {
        "uuid": "{B463AC29-54DF-4933-A190-072332A04F1A}",
        "name": "Multiples",
        "type": "canvas",
        "info": {
            "ref-width": screen_width,
            "ref-height": screen_height,
            "zones": [
                # xx(0, middle),
                xx(0, left_small),
                xx(0, left_med),
                xx(0, left_big),
                xx(left_small, right_med),  # off center to left
                xx(left_med, right_med),  # narrow in center
                xx(left_small, right_small),  # big in center
                xx(left_med, right_small),  # off center to right
                xx(right_big, screen_width),
                xx(right_med, screen_width),
                xx(right_small, screen_width),
                # xx(middle, screen_width),
            ],
        },
    },
    {
        "uuid": "{B463AC29-54DF-4933-A190-072332A04FFB}",
        "name": "Left-biased",
        "type": "canvas",
        "info": {
            "ref-width": screen_width,
            "ref-height": screen_height,
            "zones": [
                xx(col*0, col*4),
                xx(col*0, col*6),
                xx(col*1, col*7),
                xx(col*2, col*7),
                xx(col*4, col*8),
                xx(col*6, col*12),
                xx(col*8, col*12),
            ],
        },
    },
    # hand-built layouts from here on down
    {
        "uuid": "{807F1B5F-449D-4E06-9BA3-3C00C755A62C}",
        "name": "Three Overlapping",
        "type": "canvas",
        "info": {
            "ref-width": 3072,
            "ref-height": 1240,
            "zones": [
                {"X": 0, "Y": 0, "width": 784, "height": 1240},
                {"X": 0, "Y": 0, "width": 1409, "height": 1240},
                {"X": 976, "Y": 0, "width": 1107, "height": 1240},
                {"X": 784, "Y": 0, "width": 1476, "height": 1240},
                {"X": 1891, "Y": 0, "width": 1181, "height": 1240},
                {"X": 2193, "Y": 0, "width": 879, "height": 1240},
            ],
            "sensitivity-radius": 20,
        },
    },
]

with open(fancy_zones_config_file, "w") as f:
    json.dump(existing, f, indent=4)
