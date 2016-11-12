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

class Command
  def initialize(buffer, view)
    @buffer = buffer
    @view = view
    @curs = buffer.cursor
  end

  def execute(key)
    case key
    when "\C-c".ord then
      # Move up
      if @curs.line > 0
        @curs.line -= 1
        @view.update_pos
      end

    when "\C-h".ord then
      if @curs.col == 0 then
        # Move to end of prefious line.
        if @curs.line > 0 then
          @curs.line -= 1
          @curs.col = @buffer.line_size(@curs.line)
        end
      else
        # Move left
        @curs.col -= 1
      end
      @view.update_pos

    when "\C-t".ord then
      # Move down
      if @curs.line < @buffer.lines - 1
        @curs.line += 1
        @view.update_pos
      end

    when "\C-n".ord then
      # If you try to move beyond the size of the line.
      if @buffer.line_size(@curs.line) < (@curs.col + 1) then
        # If there is another line.
        if (@buffer.lines - 1) > @curs.line then
          # Move to the begining of next line.
          @curs.line += 1
          @curs.col = 0
        end
      else
        # Move foward
        @curs.col += 1
      end
      @view.update_pos

    when "\n".ord then
      @buffer.split_line

    when 127 then
      # If cursor is at the begning of the line.
      if @curs.col == 0 and @curs.line > 0 then
        # Move cursor.
        @curs.line -= 1
        @curs.col = @buffer.line(@curs.line).size

        # Join two lines.
        @buffer.set_line(
          @curs.line,
          @buffer.line(@curs.line) + @buffer.line(@curs.line + 1))

        # Delete old line.
        @buffer.delete_line(@curs.line + 1)
      elsif @curs.col > 0 then
        new_line = @curs.col - 1
        # Delete char.
        c_line = @buffer.line(@curs.line)
        @buffer.set_line(@curs.line, c_line[0, @curs.col-1] +
                                   c_line[@curs.col, c_line.size])

        # Back cursor one char.
        @curs.col = new_line
      end

    when "\C-q".ord then
      return true

    else
      if key.is_a?(String) then
        @buffer.set_line(
          @curs.line,
          @buffer.line(@curs.line).insert(@curs.col, key))

        @curs.col += 1
        @view.update_pos
      end
    end
    return false
  end
end
