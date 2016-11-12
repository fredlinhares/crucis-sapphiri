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

require './lib/core/buffer_cursor.rb'

class Buffer
  def initialize(file_path)
    @lines = []
    @cursor = Cursor.new(self)

    # Open file and save data from it.
    File.open(file_path, "r") do |file|
      while line = file.gets
        @lines << line.chomp
      end
    end
  end

  def cursor
    return @cursor
  end

  def lines
    return @lines.size
  end

  def line(number)
    return @lines[number]
  end

  def set_line(number, new_line)
    return @lines[number] = new_line
  end

  def delete_line(number)
    @lines.delete_at(number)
  end

  def line_size(number)
    return @lines[number].size
  end

  def split_line
    # Split current line.
    c_line = @lines[@cursor.line]
    new_line = c_line[@cursor.col, c_line.length]
    @lines.insert(@cursor.line + 1, new_line)
    @lines[@cursor.line] = c_line[0, @cursor.col]

    # Move to the begining of the new line.
    @cursor.col = 0
    @cursor.line += 1
  end
end
