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
require './lib/core/views.rb'

class Main
  include Singleton

  def update_screen
    Curses.clear

    def draw_view(view)
      Curses.setpos(view.init_line, view.init_col)

      view.lines.times do |line|
        # Print empty lines after the end of file.
        break if (view.line + line) >= view.buffer.lines

        # Print line at screen.
        str_line = view.buffer.line(view.line + line)[view.col, view.cols - 1]
        if str_line then # If line is not empty.
          Curses.addstr(str_line)
        end

        # Move to the begining of the next line.
        Curses.setpos(view.init_line + line + 1, view.init_col)
      end
    end

    def draw_container(container)
      container.list.each do |i|
        if i.is_a?(Core::View::Container) then
          draw_container(i)
        else
          draw_view(i)
        end
      end
    end

    if Core.view_container.nil?
      draw_view(Core.view)
    else
      draw_container(Core.view_container)
    end

    # Draw cursor of current view.
    Curses.setpos(
      Core.view.init_line + Core.cursor.line - Core.view.line,
      Core.view.init_col + Core.cursor.col - Core.view.col)

    Curses.refresh
  end

  def run
    # Initialize curses mode.
    Curses.init_screen

    begin
      # Load file from command line.
      buffer = Core::Buffer.new(ARGV[0])

      # Define the portion of the file to be drawn on the screen.
      Core::View.new(buffer, 0, 0, Curses.cols, Curses.lines).current()

      Initialize::commands()
      @key_map = Initialize::key_map_dvorak()

      Curses.raw
      Curses.noecho

      update_screen

      $quit = false
      until $quit do
        # Handle input.
        key = Curses.getch
        @key_map.execute(key)

        update_screen
      end
    ensure
      Curses.close_screen
    end
  end
end

Main.instance.run
