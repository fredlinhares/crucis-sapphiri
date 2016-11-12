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

require './lib/command.rb'

class KeyMap
  include Singleton

  def initialize
    @keys = {}
  end

  # Associate an imput to a command.
  def add_key(key, command)
    @keys[key] = Command.cmd(command)

    return self
  end

  # Calls the command associated with the key.
  def execute(key)
    # If is a command.
    if @keys.has_key?(key) then
      @keys[key].execute
    else
      # If is a valid character.
      if key.is_a?(String) then
        Core.buffer.set_line(
          Core.cursor.line,
          Core.buffer.line(Core.cursor.line).insert(Core.cursor.col, key))

        Core.cursor.col += 1
        Core.view.update_pos
      end
    end
  end
end
