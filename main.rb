# frozen_string_literal: true

# Solver helper
class Solver
  def solve_dir(solver, directory)
    Dir.foreach(directory) do |file|
      next if (file == '.') || (file == '..')

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

# Solver.new.solve_dir(:day1p1, 'inputs/day1p1/')
Solver.new.solve_dir(:day1p2, 'inputs/day1p2/')
