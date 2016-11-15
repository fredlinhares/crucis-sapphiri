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

module Core
  class View
    attr_accessor :col, :line, :cols, :lines, :buffer

    def initialize(cols, lines, buffer)
      @col = 0
      @line = 0

      @cols = cols
      @lines = lines

      @buffer = buffer
      @curs = buffer.cursor
    end

    def self.current
      return @@current
    end

    def current
      @@current = self
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
      if @curs.line >= (@line + @lines) then
        # Set cursor at the center of the view.
        @line = @curs.line - (@lines / 2)
      end

      # If cursor go up beyond the view.
      if @curs.line < @line then
        # Set cursor at the center of the view.
        new_pos = @curs.line - (@lines / 2)
        new_pos = 0 if new_pos < 0 # Prevent y from view to be negative.
        @line = new_pos
      end
    end
  end
end
