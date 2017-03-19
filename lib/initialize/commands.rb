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

require './lib/command.rb'
require './lib/key_map.rb'
require './lib/core/buffer.rb'
require './lib/core/view.rb'
require './lib/core/shortcuts.rb'

module CSTE
  module Initialize
  end
end

module CSTE::Initialize
  def self.commands

    # Move cursor up.
    CSTE::Command.new(:cursor_move_up) do
      CSTE.cursor.line -= 1
      CSTE.view.update_pos
    end

    # Move cursor left.
    CSTE::Command.new(:cursor_move_left) do
      # Move to end of prefious line.
      if CSTE.cursor.col == 0 and CSTE.cursor.line > 0 then
          CSTE.cursor.line -= 1
          CSTE.cursor.col = CSTE.buffer.line_size(CSTE.cursor.line)
      else
        # Move left
        CSTE.cursor.col -= 1
      end
      CSTE.view.update_pos
    end

    # Move cursor down.
    CSTE::Command.new(:cursor_move_down) do
      CSTE.cursor.line += 1
      CSTE.view.update_pos
    end

    # Move cursor right.
    CSTE::Command.new(:cursor_move_right) do
      if CSTE.buffer.line_size(CSTE.cursor.line) < (CSTE.cursor.col + 1) and
        (CSTE.buffer.lines - 1) > CSTE.cursor.line then
        # Move to the begining of next line.
        CSTE.cursor.line += 1
        CSTE.cursor.col = 0
      else
        # Move right.
        CSTE.cursor.col += 1
      end
      CSTE.view.update_pos
    end

    # Move cursor to the start of current line.
    CSTE::Command.new(:cursor_move_line_start) do
      CSTE.cursor.col = 0
    end

    # Move cursor to the end of current line.
    CSTE::Command.new(:cursor_move_line_end) do
      CSTE.cursor.col = CSTE.buffer.line_size(CSTE.cursor.line)
    end

    # Creat a new line. Enter/Ruturn default function.
    CSTE::Command.new(:line_new) do
      CSTE.buffer.split_line
    end

    # Remove previous chracter. Backspace defalt function.
    CSTE::Command.new(:delete_backward) do
      # If cursor is at the begning of the line.
      if CSTE.cursor.col == 0 and CSTE.cursor.line > 0 then
        # Move cursor.
        CSTE.cursor.line -= 1
        CSTE.cursor.col = CSTE.buffer.line(CSTE.cursor.line).size

        # Join two lines.
        CSTE.buffer.set_line(
          CSTE.cursor.line,
          CSTE.buffer.line(CSTE.cursor.line) +
          CSTE.buffer.line(CSTE.cursor.line + 1))

        # Delete old line.
        CSTE.buffer.delete_line(CSTE.cursor.line + 1)
      elsif CSTE.cursor.col > 0 then
        new_line = CSTE.cursor.col - 1
        # Delete char.
        c_line = CSTE.buffer.line(CSTE.cursor.line)
        CSTE.buffer.set_line(
          CSTE.cursor.line,
          c_line[0, CSTE.cursor.col-1] + c_line[CSTE.cursor.col, c_line.size])

        # Back cursor one char.
        CSTE.cursor.col = new_line
      end
    end

    # Split current view on vertical.
    CSTE::Command.new(:view_split_vertical) do
      CSTE.view.split_vertical
    end

    # Split current view on horizontal.
    CSTE::Command.new(:view_split_horizontal) do
      CSTE.view.split_horizontal
    end

    # Delete current view.
    CSTE::Command.new(:view_delete) do
      CSTE.view.delete()
    end

    # Move to next view.
    CSTE::Command.new(:view_move_next) do
      CSTE.view.next.current()
      CSTE.view.update_pos()
    end

    # Move to previous view.
    CSTE::Command.new(:view_move_pred) do
      CSTE.view.pred.current()
      CSTE.view.update_pos()
    end

    # Change to mode that with commands for views.
    CSTE::Command.new(:mode_change_view) do
      CSTE::KeyMap.set(:View)
    end

    # Change to mode that with commands for views.
    CSTE::Command.new(:mode_default) do
      CSTE::KeyMap.set
    end

    CSTE::Command.new(:quit) do
      $quit = true
    end

    return nil
  end
end
