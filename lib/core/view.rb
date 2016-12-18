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

require './lib/core/buffer.rb'
require './lib/core/view_container.rb'
require './lib/core/view_echo.rb'

module Core
  class View
    attr_reader(
      :col, :line, # Position on buffer.
      :cols, :lines, # View size.
      :init_col, :init_line) # Position on screen.
    attr_accessor :index, :lord, :buffer

    def initialize(buffer, init_col, init_line, cols, lines, col = 0, line = 0)
      @init_col = init_col
      @init_line = init_line

      @col = col
      @line = line

      # View size.
      size(init_col, init_line, cols, lines)

      @buffer = buffer
      @curs = buffer.cursor
    end

    # Current (active) view.
    def self.current
      return @@current
    end

    # Display only this view at the interface.
    def king
      @lord = nil
      @@king = self
      @@current = self
    end

    # Set this buffer as current.
    def current
      @@current = self
    end

    # Return the view or container that is the king of the hierarchy.
    def self.king=(k)
      @@king = k
    end

    def self.king
      return @@king
    end

    def self.update_screen
      Curses.clear

      @@king.draw

      # Draw echo area.
      Curses.setpos(Curses.lines - 1, 0)
      Curses.addstr(EchoArea.instance.text)

      # Draw cursor of current view.
      Curses.setpos(
        @@current.init_line + @@current.buffer.cursor.line - @@current.line,
        @@current.init_col + @@current.buffer.cursor.col - @@current.col)

      Curses.refresh
    end

    def draw
      Curses.setpos(@init_line, @init_col)

      buffer_lines.times do |line|
        # Print empty lines after the end of file.
        break if (@line + line) >= @buffer.lines

        # Print line at screen.
        str_line = @buffer.line(@line + line)[@col, @cols - 1]
        if str_line then # If line is not empty.
          Curses.addstr(str_line)
        end

        # Move to the begining of the next line.
        Curses.setpos(@init_line + line.next, @init_col)
      end

      # Draw a status line.
      Curses.attron(Curses.color_pair(1)|Curses::A_NORMAL) do
        Curses.setpos(@init_line + @lines - 1, @init_col)
        Curses.addstr(@buffer.file)
      end
    end

    # When there are multiple views in the editor, return the next view. Return
    # itself when there is no other view.
    def next
      if @lord.nil? then
        return self
      else
        return @lord.forward(index)
      end
    end

    # When there are multiple views in the editor, return the previous view.
    # Return itself when there is no other view.
    def pred
      if @lord.nil? then
        return self
      else
        return @lord.backward(index)
      end
    end

    # Those methods ('view_first' and 'view_last') exist to give a common
    # interface between View and Container.
    def view_first
      return self
    end

    def view_last
      return self
    end

    def split_vertical
      # No lord mean not under any container.
      if @lord.nil? then
        @@king = ContainerV.new(
          self, @init_col, @init_line, @cols, @lines)

      # This view serves a horizontal container and the division required is
      # vertical.
      elsif @lord.is_a?(ContainerH) then
        @lord[@index] = ContainerV.new(
          self, @init_col, @init_line, @cols, @lines, @index, @lord)

      else
        @lord.split(@index)
      end
    end

    def split_horizontal
      # No lord mean not under any container.
      if @lord.nil? then
        @@king = ContainerH.new(
          self, @init_col, @init_line, @cols, @lines)

      # This view serves a vertical container and the division required is
      # horizontal.
      elsif @lord.is_a?(ContainerV) then
        @lord[@index] = ContainerH.new(
          self, @init_col, @init_line, @cols, @lines, @index, @lord)

      else
        @lord.split(@index)
      end
    end

    def delete
      if @lord.nil? then
        return self
      else
        return @lord.delete(@index)
      end
    end

    def size(init_col, init_line, cols, lines)
      @init_col = init_col
      @init_line = init_line

      @cols = cols
      @lines = lines

      return self
    end

    # Update view position based on cursor position.
    def update_pos
      # If cursor go right beyond the view.
      if @curs.col >= (@col + @cols) then
        # Set cursor at the center of the view.
        @col = @curs.col - (@cols / 2)
      end

      # If cursor go left beyond the view.
      if @curs.col < @col then
        # Set cursor at the center of the view.
        new_pos = @curs.col - (@cols / 2)
        new_pos = 0 if new_pos < 0 # Prevent x from view to be negative.
        @col = new_pos
      end

      # If cursor go down beyond the view.
      if @curs.line >= (@line + buffer_lines) then
        # Set cursor at the center of the view.
        @line = @curs.line - (buffer_lines / 2)
      end

      # If cursor go up beyond the view.
      if @curs.line < @line then
        # Set cursor at the center of the view.
        new_pos = @curs.line - (buffer_lines / 2)
        new_pos = 0 if new_pos < 0 # Prevent y from view to be negative.
        @line = new_pos
      end
    end

    private

    # The number of lines from buffer to be diplayed in the view. The view must
    # let one last line for the status line.
    def buffer_lines
      return @lines - 1
    end
  end
end

__END__

View, ContainerV and ContainerH are organized in a hierarchy. The element in
the top of the hierarchy is called "king". The elements in the bottom of the
hierarchy are always views. View and Container have some methods with identical
interface to allow a Container call for its vassals without need to distinguish
if those vassals are containers or views.
