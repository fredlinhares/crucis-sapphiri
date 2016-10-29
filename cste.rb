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

require 'curses'

require './lib/data_file.rb'
require './lib/file_view.rb'
require './lib/command.rb'

module Main
  def self.update_screen
    Curses.clear
    Curses.setpos(0, 0)

    @@view.lines.times do |line|
      # Print empty lines after the end of file.
      break if (@@view.line + line) >= @@file.lines

      # Print line at screen.
      str_line = @@file.line(@@view.line + line)[@@view.col, @@view.cols]
      if str_line
        Curses.addstr(str_line)
      end
      Curses.addstr("\n")
    end

    Curses.setpos(
      @@curs.line - @@view.line,
      @@curs.col - @@view.col)

    Curses.refresh
  end

  # Initialize curses mode.
  Curses.init_screen

  begin
    @@file = DataFile.new(ARGV[0])

    # Cursor position.
    @@curs = @@file.cursor

    # Define the portion of the file to be drawn on the screen.
    @@view = FileView.new(Curses.cols, Curses.lines, @@curs)

    @@command = Command.new(@@file, @@view)

    Curses.raw
    Curses.noecho

    update_screen

    quit = false
    until quit do
      key = Curses.getch

      quit = @@command.execute(key)

      update_screen
    end
  ensure
    Curses.close_screen
  end
end
