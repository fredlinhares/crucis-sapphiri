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
    class Container
      attr_reader(
        :cols, :lines, # Container size.
        :init_col, :init_line,
        :list) # Position on screen.
      attr_accessor :index, :parent

      def initialize(view, init_col, init_line, cols, lines, index = nil)
        @index = index
        new_view = copy_child_view(view)

        # Each view know it own position under a container.
        view.index = 0
        new_view.index = 1

        # Containers/Views inside it.
        @list = [view, new_view]

        size(init_col, init_line, cols, lines)
      end

      def [](num)
        return @list[num]
      end

      def []=(num, val)
        @list[num] = val
      end

      def split(num)
        new_view = copy_child_view(@list[num])
        @list.insert(num + 1, new_view)

        # Each view/container know it own position under a container.
        @list.each_with_index{|view, i| view.index = i}

        child_sizes()

        return self
      end

      def size(init_col, init_line, cols, lines)
        @init_col = init_col
        @init_line = init_line

        @cols = cols
        @lines = lines

        child_sizes()

        return self
      end

      private

      # Create a new view that points to the same buffer.
      def copy_child_view(view)
        # Copy this view to a new one. Both views needs to point to the same
        # buffer.
        new_view = View.new(
          view.buffer, view.init_col, view.init_line, view.cols, view.lines)

        # This container is parent of those views.
        view.parent = self
        new_view.parent = self

        return new_view
      end
    end

    # Container for views split in the vertical.
    class ContainerV < Container

      private
      def child_sizes
        # Count total cols used.
        total_cols = 0
        cols = @cols/@list.count

        # Calculate the size of almost all child, except the last.
        @list.take(@list.size - 1).each_with_index do |view, i|
          total_cols += cols
          view.size(
            @init_col + (i * (cols + 1)), @init_line,
            cols, @lines)
        end

        # Calculate the last child.
        @list.last.size(
          @init_col + ((@list.size - 1) * cols), @init_line,
          @cols - total_cols, @lines)
      end
    end

    # Container for views split in the horizontal.
    class ContainerH < Container

      private
      def child_sizes
        # Count total lines used.
        total_lines = 0
        lines = @lines/@list.count

        # Calculate the size of almost all child, except the last.
        @list.take(@list.size - 1).each_with_index do |view, i|
          total_lines += lines
          view.size(
            @init_col, @init_line + (i * (lines + 1)),
            @cols, lines)
        end

        # Calculate the last child.
        @list.last.size(
          @init_col, @init_line + ((@list.size - 1) * lines),
          @cols, @lines - total_lines)
      end
    end
  end
end
