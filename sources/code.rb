class KeySchedule
  attr_accessor :sub_keys
  attr_reader :key

  PC_1_L = [0x39, 0x31, 0x29, 0x21, 0x19, 0x11, 0x09,
            0x01, 0x3a, 0x32, 0x2a, 0x22, 0x1a, 0x12,
            0x0a, 0x02, 0x3b, 0x33, 0x2b, 0x23, 0x1b,
            0x13, 0x0b, 0x03, 0x3c, 0x34, 0x2c, 0x24]

  PC_1_R = [0x3f, 0x37, 0x2f, 0x27, 0x1f, 0x17, 0x0f,
            0x07, 0x3e, 0x36, 0x2e, 0x26, 0x1e, 0x16,
            0x0e, 0x06, 0x3d, 0x35, 0x2d, 0x25, 0x1d,
            0x15, 0x0d, 0x05, 0x1c, 0x14, 0x0c, 0x04]

  PC_2 = [0x0e, 0x11, 0x0b, 0x18, 0x01, 0x05,
          0x03, 0x1c, 0x0f, 0x06, 0x15, 0x0a,
          0x17, 0x13, 0x0c, 0x04, 0x1a, 0x08,
          0x10, 0x07, 0x1b, 0x14, 0x0d, 0x02,
          0x29, 0x34, 0x1f, 0x25, 0x2f, 0x37,
          0x1e, 0x28, 0x33, 0x2d, 0x21, 0x30,
          0x2c, 0x31, 0x27, 0x38, 0x22, 0x35,
          0x2e, 0x2a, 0x32, 0x24, 0x1d, 0x20]

  ROTATIONS = [1, 1, 2, 2, 2, 2, 2, 2,
                  1, 2, 2, 2, 2, 2, 2, 1]

  def initialize(key)
    @key = key

    c = []
    d = []
    k = [] # sub keys: c[i] + d[i] + permuting with PC_2.

    c << PC_1_L.collect { |p| key[p - 1] }
    d << PC_1_R.collect { |p| key[p - 1] }

    16.times do |i|
      c << c[i]
      d << d[i]

      ROTATIONS[i].times do
        c[i + 1] << c[i + 1].shift
        d[i + 1] << d[i + 1].shift
      end

      k << PC_2.collect { |p| (c[i + 1] + d[i + 1])[p - 1] }
    end

    @sub_keys = k
  end
end
