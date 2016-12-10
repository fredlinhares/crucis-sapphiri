# coding: utf-8
=begin
MIT License

Copyright (c) 2016 Frederico de Oliveira Linhares

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
=end

require 'singleton'

require 'curses'

require './lib/initialize/commands.rb'
require './lib/initialize/key_maps.rb'
require './lib/core/view.rb'

class Main
  include Singleton

  def run
    # Initialize curses mode.
    Curses.init_screen

    begin
      # Colors.
      Curses.start_color
      Curses.init_pair(1, Curses::COLOR_BLUE, Curses::COLOR_WHITE)

      # Load file from command line.
      buffer = Core::Buffer.new(ARGV[0])

      # Define the portion of the file to be drawn on the screen. Let one line
      # for echo area.
      Core::View.new(buffer, 0, 0, Curses.cols, Curses.lines - 1).only()

      Initialize::commands()
      Initialize::key_map_dvorak()

      Curses.raw
      Curses.noecho

      Core::View.update_screen

      $quit = false
      until $quit do
        # Handle input.
        key = Curses.getch
        KeyMap.current.execute(key)

        Core::View.update_screen
      end
    ensure
      Curses.close_screen
    end
  end
end

Main.instance.run
