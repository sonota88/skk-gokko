def drop_last(str)
  if str.size > 0
    str[0..-2]
  else
    str
  end
end

# 半角換算での幅
def char_width(c)
  # 簡易な実装
  c.ord <= 0xff ? 1 : 2
end

# 半角換算での幅
def text_width(text)
  text.chars
    .map { |c| char_width(c) }
    .sum
end

def with_alpha(color, alpha)
  case color.size
  when 3
    [alpha] + color
  when 4
    new_color = color.dup
    new_color[0] = alpha
    new_color
  else
    raise "invalid color (#{color.inspect})"
  end
end

def clamp(val, min, max)
  return min if val < min
  return max if max < val
  val
end
