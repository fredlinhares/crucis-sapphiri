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

require './lib/key_map.rb'

module Initialize
  def self.key_map_dvorak
    KeyMap.new
      .add_key("\C-c".ord, :cursor_move_up)
      .add_key("\C-h".ord, :cursor_move_left)
      .add_key("\C-t".ord, :cursor_move_down)
      .add_key("\C-n".ord, :cursor_move_right)
      .add_key("\C-v".ord, :mode_change_view)
      .add_key("\n".ord, :line_new)
      .add_key(127, :delete_backward)
      .add_key("\C-q".ord, :quit)
      .insert_key = true

    KeyMap.new(:View)
      .add_key("v", :view_split_vertical)
      .add_key("h", :view_split_horizontal)
      .add_key("n", :view_move_next)
      .add_key("p", :view_move_pred)
      .add_key("\C-[".ord, :mode_default)
      .insert_key = false

    #Set default key map as initial.
    KeyMap.set
    return nil
  end
end
