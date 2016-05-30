require 'scanf'

class MyHash
  KEY = 'FEE1DEAD'.unpack('B*')[0].to_i

  def initialize(file, bits)
    @file = file
    @bits = bits * 2
  end

  def digest(changed = false)
    bin = changed ? binary_changed : binary
    temp = (bin ^ 'FEE1DEAD'.unpack('B*')[0].to_i).to_s(2).scan(/../)
    result = []

    while temp.length > @bits
      i = 0
      result = []
      temp.each_slice(2) do |p|
        r = p[0].to_i ^ p[1].to_i
        r = "0#{r}" if r.to_s.length == 1
        result[i] = r
        i += 1
      end
      temp = result
      if temp.length > @bits && temp.length < @bits * 2
        result = temp.first(@bits)
        break
      end
    end
    result.join('')
  end

  def self.string_difference_percent(a, b)
    longer = [a.size, b.size].max
    same = a.each_char.zip(b.each_char).select { |a,b| a == b }.size
    (longer - same) / a.size.to_f
  end

  def binary
    s = File.binread(@file)
    bits = s.unpack("B*")[0]
    bits.to_i
  end

  def binary_changed
    s = File.binread(@file)
    bits = s.unpack("B*")[0]
    bits[0] = bits[0] == 0 ? '1' : '0'
    bits[1] = bits[1] == 0 ? '1' : '0'
    bits.to_i
  end
end

# load 'source.rb'
# sources/pic.png

