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

module CSTE
  class View
    class Container
    end
    class ContainerV < Container
    end
    class ContainerH < Container
    end
  end
end

class CSTE::View::Container
  attr_reader(
    :cols, :lines, # Container size.
    :init_col, :init_line, # Position on screen.
    :vassals)
  attr_accessor :index, :lord

  def initialize(view, init_col, init_line, cols, lines, index = nil,
                 lord = nil)
    @index = index
    @lord = lord
    new_view = copy_vassal_view(view)

    # Each view know it own position under a container.
    view.index = 0
    new_view.index = 1

    # Containers/Views inside it.
    @vassals = [view, new_view]

    size(init_col, init_line, cols, lines)
  end

  def [](num)
    return @vassals[num]
  end

  def []=(num, val)
    @vassals[num] = val
  end

  def king
    @lord = nil
    king = self
  end

  def draw
    @vassals.each {|i| i.draw}
  end

  # A recursive function to move forward in the View hierarchy.
  def forward(vassal_index)
    # If the index is not of the last vassal, return the first view of the
    # next vassal.
    if @vassals.size > vassal_index.next then
      return @vassals[vassal_index.next].view_first
    else
      if @lord.nil? then
        # Return the first view of the first vassal.
        return @vassals[0].view_first
      else
        return @lord.forward(@index)
      end
    end
  end

  # A recursive function to move backward in the View hierarchy.
  def backward(vassal_index)
    # If the index is not of the first vassal, return the last view of the
    # last vassal.
    if vassal_index > 0 then
      return @vassals[vassal_index.pred].view_last
    else
      if @lord.nil? then
        # Return the last view of the last vassal.
        return @vassals[-1].view_last
      else
        return @lord.backward(@index)
      end
    end
  end

  # Return the first vassal from this Container.
  def view_first
    return @vassals[0].view_first
  end

  # Return the last vassal from this Container.
  def view_last
    return @vassals[-1].view_last
  end

  # Split in two the vassal with a given index.
  def split(vassal_index)
    new_view = copy_vassal_view(@vassals[vassal_index])
    @vassals.insert(vassal_index + 1, new_view)

    # Each view/container know it own position under a container.
    @vassals.each_with_index{|view, i| view.index = i}

    vassal_sizes()

    return self
  end

  # Delete the current view.
  def delete(vassal_index)
    @vassals.delete_at(vassal_index)

    # Now organize the hierarchy.

    # If there more than one views left in the Container, just organize it.
    if @vassals.count > 1 then
      # Each view/container know it own position under a container.
      @vassals.each_with_index{|view, i| view.index = i}

      # Resize vassals that still exist.
      vassal_sizes()
    else
      # If there are no other vassals left in this container, the last
      # vassal will replace this container.
      # The last vassal get the same size from this container.
      @vassals[0].size(@init_col, @init_line, @cols, @lines)

      # If this container have no lord, it is the king. The last vassal
      # become the new king
      if @lord.nil? then
        @vassals[0].king()

      # If this container have a lord, the last container assume it place.
      else
        @vassals[0].lord = @lord
        @vassals[0].index = @index

        @lord.vassals[@index] = @vassals[0]
      end
    end

    return @vassals[0].view_first.current()
  end

  def size(init_col, init_line, cols, lines)
    @init_col = init_col
    @init_line = init_line

    @cols = cols
    @lines = lines

    vassal_sizes()

    return self
  end

  private

  # Create a new view that points to the same buffer.
  def copy_vassal_view(view)
    # Copy this view to a new one. Both views needs to point to the same
    # buffer.
    new_view = CSTE::View.new(
      view.buffer, view.init_col, view.init_line, view.cols, view.lines)

    # This container is the lord of those views.
    view.lord = self
    new_view.lord = self

    return new_view
  end
end

# Container for views organized in the vertical.
class CSTE::View::ContainerV

  private
  def vassal_sizes
    # Count total cols used.
    cols = @cols/@vassals.count
    extra_cols = @cols%@vassals.count

    # Calculate the size of almost all vassals, except the last.
    @vassals.take(@vassals.size - 1).each_with_index do |view, i|
      view.size(
        @init_col + (i * cols), @init_line,
        cols, @lines)
    end

    # Calculate the last vassal.
    @vassals.last.size(
      @init_col + ((@vassals.size - 1) * cols), @init_line,
      cols + extra_cols, @lines)
  end
end

# Container for views organized in the horizontal.
class CSTE::View::ContainerH

  private
  def vassal_sizes
    # Count total lines used.
    lines = @lines/@vassals.count
    extra_lines = @lines%@vassals.count

    # Calculate the size of almost all vassals, except the last.
    @vassals.take(@vassals.size - 1).each_with_index do |view, i|
      view.size(
        @init_col, @init_line + (i * lines),
        @cols, lines)
    end

    # Calculate the last vassal.
    @vassals.last.size(
      @init_col, @init_line + ((@vassals.size - 1) * lines),
      @cols, lines + extra_lines)
  end
end
