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
  class Buffer
    class Cursor
      def initialize(buffer)
        @col = 0
        @line = 0

        @buffer = buffer
      end

      def col=(pos_col)
        if pos_col >= 0 and pos_col <= @buffer.line(@line).size
          @col = pos_col
        end
        return @col
      end

      def line=(pos_line)
        if pos_line >= 0 and pos_line < @buffer.lines
          @line = pos_line
        end
        return @line
      end

      def col
        # If a user move up or down to a row with less cols than the previous,
        # this code prevent the y position to be lost.
        if @buffer.line(@line).size < @col
          return @buffer.line(@line).size
        else
          return @col
        end
      end

      def line
        return @line
      end
    end
  end
end
