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

module Initialize
  def self.commands

    # Move cursor up.
    Command.new(:cursor_move_up) do
      Core.cursor.line -= 1
      Core.view.update_pos
    end

    # Move cursor left.
    Command.new(:cursor_move_left) do
      # Move to end of prefious line.
      if Core.cursor.col == 0 and Core.cursor.line > 0 then
          Core.cursor.line -= 1
          Core.cursor.col = Core.buffer.line_size(Core.cursor.line)
      else
        # Move left
        Core.cursor.col -= 1
      end
      Core.view.update_pos
    end

    # Move cursor down.
    Command.new(:cursor_move_down) do
      Core.cursor.line += 1
      Core.view.update_pos
    end

    # Move cursor right.
    Command.new(:cursor_move_right) do
      if Core.buffer.line_size(Core.cursor.line) < (Core.cursor.col + 1) and
        (Core.buffer.lines - 1) > Core.cursor.line then
        # Move to the begining of next line.
        Core.cursor.line += 1
        Core.cursor.col = 0
      else
        # Move right.
        Core.cursor.col += 1
      end
      Core.view.update_pos
    end

    # Move cursor to the start of current line.
    Command.new(:cursor_move_line_start) do
      Core.cursor.col = 0
    end

    # Move cursor to the end of current line.
    Command.new(:cursor_move_line_end) do
      Core.cursor.col = Core.buffer.line_size(Core.cursor.line)
    end

    # Creat a new line. Enter/Ruturn default function.
    Command.new(:line_new) do
      Core.buffer.split_line
    end

    # Remove previous chracter. Backspace defalt function.
    Command.new(:delete_backward) do
      # If cursor is at the begning of the line.
      if Core.cursor.col == 0 and Core.cursor.line > 0 then
        # Move cursor.
        Core.cursor.line -= 1
        Core.cursor.col = Core.buffer.line(Core.cursor.line).size

        # Join two lines.
        Core.buffer.set_line(
          Core.cursor.line,
          Core.buffer.line(Core.cursor.line) +
          Core.buffer.line(Core.cursor.line + 1))

        # Delete old line.
        Core.buffer.delete_line(Core.cursor.line + 1)
      elsif Core.cursor.col > 0 then
        new_line = Core.cursor.col - 1
        # Delete char.
        c_line = Core.buffer.line(Core.cursor.line)
        Core.buffer.set_line(
          Core.cursor.line,
          c_line[0, Core.cursor.col-1] + c_line[Core.cursor.col, c_line.size])

        # Back cursor one char.
        Core.cursor.col = new_line
      end
    end

    # Split current view on vertical.
    Command.new(:view_split_vertical) do
      Core.view.split_vertical
    end

    # Split current view on horizontal.
    Command.new(:view_split_horizontal) do
      Core.view.split_horizontal
    end

    # Delete current view.
    Command.new(:view_delete) do
      Core.view.delete()
    end

    # Move to next view.
    Command.new(:view_move_next) do
      Core.view.next.current()
      Core.view.update_pos()
    end

    # Move to previous view.
    Command.new(:view_move_pred) do
      Core.view.pred.current()
      Core.view.update_pos()
    end

    # Change to mode that with commands for views.
    Command.new(:mode_change_view) do
      KeyMap.set(:View)
    end

    # Change to mode that with commands for views.
    Command.new(:mode_default) do
      KeyMap.set
    end

    Command.new(:quit) do
      $quit = true
    end

    return nil
  end
end
