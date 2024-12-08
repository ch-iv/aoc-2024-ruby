# frozen_string_literal: true

# Solver helper
class Solver
  def solve_dir(solver, directory, exclude: [])
    Dir.foreach(directory) do |file|
      next if (file == '.') || (file == '..') || exclude.include?(file)

      input = read_input(directory + file)
      output = method(solver).call(input)
      report_simple(file, output)
    end
  end

  private

  def read_input(path)
    res = []
    File.readlines(path, chomp: true).each do |line|
      res.append(line)
    end
    res
  end

  def report_simple(file, output)
    puts "#{file}: #{output}"
  end
end

def day1p1(input)
  list1, list2 = input.map { |s| s.split('   ').map(&:to_i) }.transpose
  list1.sort.zip(list2.sort).sum { |a, b| (a - b).abs }
end

def day1p2(input)
  list1, list2 = input.map { |s| s.split('   ').map(&:to_i) }.transpose
  tally = list2.tally
  list1.sum { |a| a * tally.fetch(a, 0) }
end

def day2p1(input)
  input.map { |s| s.split(' ').map(&:to_i) }.map do |level|
    diffs = level[0..-2].zip(level[1..]).map { |a, b| a - b }
    diffs.all? { |x| x.abs >= 1 && x.abs <= 3 } && (
      diffs.all?(&:negative?) ^ diffs.all?(&:positive?)
    )
  end.count(true)
end

def day2p2(input)
  input.map { |s| s.split(' ').map(&:to_i) }.map do |level|
    (0...level.length).map do |i|
      level_exc = level.reject.with_index { |_, j| j == i }
      diffs = level_exc[0..-2].zip(level_exc[1..]).map { |a, b| a - b }
      diffs.all? { |x| x.abs >= 1 && x.abs <= 3 } && (
        diffs.all?(&:negative?) ^ diffs.all?(&:positive?)
      )
    end.any?
  end.count(true)
end

def day3p1(input)
  input.join.scan(/mul\((\d{1,3}),(\d{1,3})\)/).map { |a, b| a.to_i * b.to_i }.sum
end

def day3p2(input)
  "do()#{input.join}don't()".scan(/do\(\).*?don't\(\)/)
                            .map { |g| g.scan(/mul\((\d{1,3}),(\d{1,3})\)/).map { |a, b| a.to_i * b.to_i }.sum }.sum
end

def day4p1(input, rec=false)
  offsets = [
    [[-3, 0, 'X'], [-2, 0, 'M'], [-1, 0, 'A'], [0, 0, 'S']],
    [[0, 3, 'X'], [0, 2, 'M'], [0, 1, 'A'], [0, 0, 'S']],
    [[-3, 3, 'X'], [-2, 2, 'M'], [-1, 1, 'A'], [0, 0, 'S']],
    [[-3, -3, 'X'], [-2, -2, 'M'], [-1, -1, 'A'], [0, 0, 'S']],
    [[-3, 0, 'S'], [-2, 0, 'A'], [-1, 0, 'M'], [0, 0, 'X']],
    [[0, 3, 'S'], [0, 2, 'A'], [0, 1, 'M'], [0, 0, 'X']],
    [[-3, 3, 'S'], [-2, 2, 'A'], [-1, 1, 'M'], [0, 0, 'X']],
    [[-3, -3, 'S'], [-2, -2, 'A'], [-1, -1, 'M'], [0, 0, 'X']]
  ]

  input.each_with_index.map do |row, y|
    row.chars.each_with_index.map do |_, x|
      offsets.map do |offset_direction|
        offset_direction.map do |x_offset, y_offset, expected|
          nx = x + x_offset
          ny = y + y_offset
          ny >= 0 && ny < input.length && nx >= 0 && nx < input[ny].length && input[ny][nx] == expected
        end.all?
      end.count(true)
    end.sum
  end.sum + (rec ? day4p1(input.transpose, false) : 0)
end

def day4p2(input)
  input.each_with_index.map do |row, y|
    row.chars.each_with_index.map do |_, x|
      if y >= 1 && y <= input.length - 2 && x >= 1 && x <= input[y].length - 2
        chars = [input[y-1][x-1], input[y-1][x+1], input[y+1][x-1], input[y+1][x+1]]
        input[y][x] == 'A' && chars.count('M') == 2 && chars.count('S') == 2 && chars[0] != chars[3] && chars[1] != chars[2]
      end
    end.count(true)
  end.sum
end

def day5p1(input)
  rules = Hash.new(Set.new)
  manuals = []
  input.each do |line|
    if (line == '') .. false
      manuals.append(line.split(',').map(&:to_i)) unless line == ''
    else
      a, b = line.split('|').map(&:to_i)
      rules[a] += [b]
    end
  end

  manuals.map do |manual|
    if (0..manual.size - 2).map do |i|
      rules[manual[i]].include?(manual[i + 1])
    end.all?
      manual[manual.size / 2]
    else
      0
    end
  end.sum
end

def day5p2(input)
  rules = Hash.new(Set.new)
  manuals = []
  input.each do |line|
    if (line == '') .. false
      manuals.append(line.split(',').map(&:to_i)) unless line == ''
    else
      a, b = line.split('|').map(&:to_i)
      rules[a] += [b]
    end
  end

  manuals.map do |manual|
    if (0..manual.size - 2).map do |i|
      rules[manual[i]].include?(manual[i + 1])
    end.all?
      0
    else
      manual.sort { |a , b| rules[a].include?(b) ? -1 : 1 }[manual.size / 2]
    end
  end.sum
end

class Guard
  attr_reader :x, :y

  def initialize(x, y)
    @direction = [0, -1]
    @x = x
    @y = y
  end

  def advance
    @x, @y = self.next
    [@x, @y]
  end

  def next
    [@x + @direction[0], @y + @direction[1]]
  end

  def turn
    case @direction
    when [0, -1]
      @direction = [1, 0]
    when [1, 0]
      @direction = [0, 1]
    when [0, 1]
      @direction = [-1, 0]
    when [-1, 0]
      @direction = [0, -1]
    end
  end

  def dx
    @direction[0]
  end

  def dy
    @direction[1]
  end
end

def day6p1(input)
  guard = Guard.new(0, 0)
  input.each_with_index.map do |row, y|
    row.chars.each_with_index.map do |_, x|
      guard = Guard.new(x, y) if input[y][x] == '^'
    end
  end
  seen = Set.new
  while guard.y >= 0 && guard.y < input.size && guard.x >= 0 && guard.x < input[guard.y].size
    seen << [guard.x, guard.y]
    nx, ny = guard.next
    guard.turn if ny >= 0 && ny < input.size && nx >= 0 && nx < input[ny].size && input[ny][nx] == '#'
    guard.advance
  end
  seen.size
end

def day6p2(input)
  gx = 0
  gy = 0
  input.each_with_index.map do |row, y|
    row.chars.each_with_index.map do |_, x|
      if input[y][x] == '^'
        gx = x
        gy = y
      end
    end
  end

  n_cycles = 0
  input.each_with_index do |row, y|
    row.chars.each_with_index do |_, x|
      puts "x: #{x} y: #{y}"
      next if gx == x && gy == y

      guard = Guard.new(gx, gy)
      seen = Set.new
      while guard.y >= 0 && guard.y < input.size && guard.x >= 0 && guard.x < input[guard.y].size
        if seen.include?([guard.x, guard.y, guard.dx, guard.dy])
          # in a cycle
          n_cycles += 1
          break
        end

        seen << [guard.x, guard.y, guard.dx, guard.dy]
        nx, ny = guard.next
        if ny >= 0 && ny < input.size && nx >= 0 && nx < input[ny].size && (input[ny][nx] == '#' || (nx == x && ny == y))
          guard.turn
        end
        guard.advance
      end
    end
  end
  n_cycles
end

# Solver.new.solve_dir(:day1p1, 'inputs/day1p1/')
# Solver.new.solve_dir(:day1p2, 'inputs/day1p2/')
# Solver.new.solve_dir(:day2p1, 'inputs/day2p1/')
# Solver.new.solve_dir(:day2p2, 'inputs/day2p2/')
# Solver.new.solve_dir(:day3p1, 'inputs/day3p1/')
# Solver.new.solve_dir(:day3p2, 'inputs/day3p2/')
# Solver.new.solve_dir(:day4p1, 'inputs/day4p1/')
# Solver.new.solve_dir(:day4p2, 'inputs/day4p2/')
# Solver.new.solve_dir(:day5p1, 'inputs/day5p1/')
# Solver.new.solve_dir(:day5p2, 'inputs/day5p2/')
# Solver.new.solve_dir(:day6p1, 'inputs/day6p1/')
Solver.new.solve_dir(:day6p2, 'inputs/day6p2/', exclude: ['test.txt'])
