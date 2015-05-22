#!/bin/bash

ffmpeg -i Videos/demo.mov -s 250x445 -pix_fmt rgb24 -r 10 -f gif - | gifsicle --optimize=3 > Gif/demo.gif
