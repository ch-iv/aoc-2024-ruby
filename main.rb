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

# Solver.new.solve_dir(:day1p1, 'inputs/day1p1/')
# Solver.new.solve_dir(:day1p2, 'inputs/day1p2/')
# Solver.new.solve_dir(:day2p1, 'inputs/day2p1/')
# Solver.new.solve_dir(:day2p2, 'inputs/day2p2/')
# Solver.new.solve_dir(:day3p1, 'inputs/day3p1/')
# Solver.new.solve_dir(:day3p2, 'inputs/day3p2/')
Solver.new.solve_dir(:day4p1, 'inputs/day4p1/')
