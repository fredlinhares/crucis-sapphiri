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
require './lib/file_cursor.rb'
require './lib/file_view.rb'

module Main
  # Update view position based on cursor position.
  def self.update_view_pos
    # If cursor go right beyond the view.
    if @@curs.col >= (@@view.col + @@view.cols)
      # Set cursor at the center of the view.
      @@view.col = @@curs.col - (@@view.cols / 2)
    end

    # If cursor go left beyond the view.
    if @@curs.col < @@view.col
      # Set cursor at the center of the view.
      new_pos = @@curs.col - (@@view.cols / 2)
      new_pos = 0 if new_pos < 0 # Prevent x from view to be negative.
      @@view.col = new_pos
    end

    # If cursor go down beyond the view.
    if @@curs.line >= (@@view.line + @@view.lines)
      # Set cursor at the center of the view.
      @@view.line = @@curs.line - (@@view.lines / 2)
    end

    # If cursor go up beyond the view.
    if @@curs.line < @@view.line
      # Set cursor at the center of the view.
      new_pos = @@curs.line - (@@view.lines / 2)
      new_pos = 0 if new_pos < 0 # Prevent y from view to be negative.
      @@view.line = new_pos
    end
  end

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
      else
        Curses.addstr("\n")
      end
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

    # Define the portion of the file to be drawn on the screen.
    @@view = FileView.new(Curses.cols, Curses.lines)

    # Cursor position.
    @@curs = FileCursor.new(@@file)

    Curses.raw
    Curses.noecho

    update_screen

    quit = false
    until quit do
      key = Curses.getch

      case key
      when 'e' then
        # Move up
        if @@curs.line > 0
          @@curs.line -= 1
          update_view_pos
        end

      when 's' then
        if @@curs.col == 0 then
          # Move to end of prefious line.
          if @@curs.line > 0 then
            @@curs.line -= 1
            @@curs.col = @@file.line_size(@@curs.line)
          end
        else
          # Move left
          @@curs.col -= 1
        end
        update_view_pos

      when 'd' then
        # Move down
        if @@curs.line < @@file.lines - 1
          @@curs.line += 1
          update_view_pos
        end

      when 'f' then
        # If you try to move beyond the size of the line.
        if @@file.line_size(@@curs.line) < (@@curs.col + 1) then
          # If there is another line.
          if @@file.lines > @@curs.line then
            # Move to the begining of next line.
            @@curs.line += 1
            @@curs.col = 0
          end
        else
          # Move foward
          @@curs.col += 1
        end
        update_view_pos

      when 'q' then
        quit = true
      end

      update_screen
    end
  ensure
    Curses.close_screen
  end
end
