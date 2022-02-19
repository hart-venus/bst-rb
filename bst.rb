# frozen_string_literal: true

# node class, with data, left node and right node attributes.
class Node
  attr_accessor :data, :left, :right

  def initialize(data, left = nil, right = nil)
    @data = data
    @left = left
    @right = right
  end
end

# tree class, with a root attribute for the root node.
class Tree
  attr_accessor :root

  def initialize(array = [])
    @root = build_tree(array, 0, array.length - 1)
  end

  def build_tree(array, start, end_index)
    return nil if start > end_index

    array = array.uniq.sort
    mid = ((start + end_index) / 2).to_i
    Node.new(array[mid], build_tree(array, start, mid - 1), build_tree(array, mid + 1, end_index))
  end

  def insert(value, curr_node = root, last_node = root, is_left = false)
    if curr_node.nil?
      if is_left
        last_node.left = Node.new(value)
      else
        last_node.right = Node.new(value)
      end
    elsif value > curr_node.data
      insert(value, curr_node.right, curr_node, false)
    elsif value < curr_node.data
      insert(value, curr_node.left, curr_node, true)
    end
  end

  def delete(value, curr_node = root, last_node = root, is_left = false)
    return if curr_node.nil?

    if value != curr_node.data
      delete(value, curr_node.left, curr_node, true)
      delete(value, curr_node.right, curr_node, false)
    elsif curr_node.left.nil? && curr_node.right.nil?
      if is_left
        last_node.left = nil
      else
        last_node.right = nil
      end
    elsif curr_node.left && curr_node.right
      smallest_value = find_smallest_value(curr_node.right)
      delete(smallest_value)
      curr_node.data = smallest_value
    else
      node_remaining = curr_node.left.nil? ? curr_node.right : curr_node.left
      if is_left
        last_node.left = node_remaining
      else
        last_node.right = node_remaining
      end
    end
  end

  def pretty_print(node = @root, prefix = '', is_left = true)
    pretty_print(node.right, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.data}"
    pretty_print(node.left, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left
  end

  def find_smallest_value(curr_node)
    return curr_node.data if curr_node.left.nil?

    find_smallest_value(curr_node.left)
  end

  def find(value, curr_node = root)
    return if curr_node.nil?

    return curr_node if value == curr_node.data

    if value > curr_node.data
      find(value, curr_node.right)
    else
      find(value, curr_node.left)
    end
  end

  def level_order(queue = [root], final_array = [])
    popped_node = queue.pop

    return if popped_node.nil?

    final_array.append(popped_node.data)

    queue.prepend(popped_node.left)
    queue.prepend(popped_node.right)

    level_order(queue, final_array)

    return final_array if !block_given?

    final_array.each { |node| yield node }
  end

  def inorder(curr_node = root, final_array = [])
    return final_array if curr_node.nil?

    final_array = inorder(curr_node.left, final_array)
    final_array.append(curr_node)
    final_array = inorder(curr_node.right, final_array)
    return final_array if !block_given?

    final_array.each { |node| yield node}
  end

  def preorder(curr_node = root, final_array = [])
    return final_array if curr_node.nil?

    final_array.append(curr_node)
    final_array = preorder(curr_node.left, final_array)
    final_array = preorder(curr_node.right, final_array)
    return final_array if !block_given?

    final_array.each { |node| yield node}
  end

  def postorder(curr_node = root, final_array = [])
    return final_array if curr_node.nil?

    final_array = postorder(curr_node.left, final_array)
    final_array = postorder(curr_node.right, final_array)
    final_array.append(curr_node)
    return final_array if !block_given?

    final_array.each { |node| yield node}
  end

  def height(curr_node = root, curr_height = -1)
    return curr_height if curr_node.nil?

    curr_height = [height(curr_node.left, curr_height +1), height(curr_node.right, curr_height +1)].max
  end

  def depth(value, curr_node = root, curr_depth = 0)
    return if curr_node.nil?

    return curr_depth if curr_node.data == value

    right_search = depth(value, curr_node.right, curr_depth + 1)

    return depth(value, curr_node.left, curr_depth + 1) if right_search.nil?

    right_search
  end

  def balanced?(curr_node = root, balanced = true)
    return balanced if curr_node.nil?

    return false if (height(curr_node.right) - height(curr_node.left)).abs > 1

    balanced = balanced?(curr_node.right, balanced)
    balanced?(curr_node.left, balanced)
  end

  def rebalance
    values_array = []
    inorder.each { |node| values_array.append(node.data) }
    values_array.sort!
    @root = build_tree(values_array, 0, values_array.length - 1)
  end
end

my_tree = Tree.new((Array.new(15) { rand(1..100) }))
my_tree.pretty_print