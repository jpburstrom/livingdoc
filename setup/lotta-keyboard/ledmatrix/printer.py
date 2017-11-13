#!/usr/bin/python

import sys, time
from rgbmatrix import Adafruit_RGBmatrix

class Printer:
    def __init__(self):
        self.font_width = 6
        self.font_height = 10
        self.matrix = Adafruit_RGBmatrix(32, 2)
        self.fontfile = "fonts/{0}x{1}.bdf".format(self.font_width, self.font_height)
        self.offset = (0, 0)

    def offset_x(self ):
        return self.offset[0] * self.font_width

    def offset_y(self, offset):
        return self.offset[1] * self.font_height

    def draw_char(self, char):
        # If return, set offset to new line
        if ord(char) == 10:
            self.offset[0] += 1
            self.offset[1] = 0
        else:
            self.matrix.DrawText(self.fontfile, self.offset_x(), self.offset_y(), 0xFF, 0xFF, 0xFF, char)
            self.offset[0] += 1
            if self.offset[0] > self.max_char_width:
                self.offset[0] = 0
                self.offset[1] += 1
        if self.offset[1] > self.max_char_height:
            self.offset[1] = 0
            self.matrix.Clear()
