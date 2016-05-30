load 'source.rb'

FILES = ['sources/pic.png', 'sources/doc.odt', 'sources/code.rb']
BITS = 4

FILES.each do |file|
  puts "===================="
  puts "File: #{file}"
  puts

  h1 = MyHash.new(file, BITS).digest
  puts "without bits' changes: #{h1}"

  h2 = MyHash.new(file, BITS).digest true
  puts "with bits' changes:    #{h2}"

  puts "difference: #{MyHash.string_difference_percent(h1, h2) * 100}%"
end
