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
require './lib/core/view.rb'

module CSTE
  class KeyMap
  end
end

class CSTE::KeyMap
  # When non-false the current mode allow insertion of chracteres in the
  # currentbuffer.
  attr_accessor :insert_key

  # The default key_map have a nil value as name.
  attr_reader :name

  def initialize(name=nil)
    @name = name
    @keys = {}
    @alt_keys = {}

    # Store this map.
    @@maps[name] = self
  end

  # Associate an input to a command.
  def add_key(key, command)
    # A key can be only a char or a char with a combination of modifiers.
    if key.is_a?(Array) then
      # The last element must be a char.
      char_key = to_ord(key.pop)

      if key.include?(:ctrl) then
        # Convert to upcase if nescessary.
        char_key -= 32 if char_key > 96 and char_key < 123

        # To apply ctrl to a char we need to subtract 64.
        char_key -= 64
      end

      # 'Alt' + 'something' send two signals. So, after a signal 27 (esc/alt)
      # editor waits for the next signal and look for @alt_keys instead of
      # @keys.
      # 'Esc' + 'something' works in the same way than 'alt' + 'something'.
      if key.include?(:alt) then
        @alt_keys[char_key] = CSTE::Command.cmd(command)
      else
        @keys[char_key] = CSTE::Command.cmd(command)
      end
    else
      @keys[to_ord(key)] = CSTE::Command.cmd(command)
    end

    return self
  end

  # Set current map.
  def self.set(name=nil)
    @@current = @@maps[name]

    # Show current mode at echo area.
    CSTE::View::EchoArea.instance.text = @@current.name.to_s

    return @@current
  end

  # Get current map.
  def self.current
    return @@current
  end

  # Calls the command associated with the key.
  def execute(key)
    # If is a 'alt/esc' + somathing command.
    if key == 27 then
      # Get the next key.
      next_key = Curses.getch()
      if @alt_keys.has_key?(to_ord(next_key)) then
        @alt_keys[to_ord(next_key)].execute
      end

    # If is a command.
    elsif @keys.has_key?(to_ord(key)) then
      @keys[to_ord(key)].execute

    elsif @insert_key then
      # If is a valid character.
      if key.is_a?(String) then
        CSTE::buffer.set_line(
          CSTE::cursor.line,
          CSTE::buffer.line(CSTE::cursor.line).insert(CSTE::cursor.col, key))

        CSTE::cursor.col += 1
        CSTE::view.update_pos
      end
    end
  end

  private

  # All commands are stored as ordinals. Convert a key to ordinal if necessary.
  def to_ord(key)
    if key.is_a?(String) then
      return key.ord
    else
      return key
    end
  end

  # Store all maps.
  @@maps = {}
end
