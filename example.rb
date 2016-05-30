load 'my_hash.rb'

FILES = ['source/pic.jpg', 'source/doc.docx', 'source/code.rb',
         'source/pr.exe', 'source/BPtD.html']
BITS = 4

FILES.each do |file|
  puts '===================='
  puts "File: #{file}"
  puts

  h1 = MyHash.new(file, BITS).digest
  puts "without bits' changes: #{h1}"

  h2 = MyHash.new(file, BITS).digest true
  puts "with bits' changes:    #{h2}"

  puts "difference: #{MyHash.string_difference_percent(h1, h2) * 100}%"
end
