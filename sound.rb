def scope
  yield
end

SoundEffect.register(:se1, 20, WAVE_TRI) do
  [600, 8]
end

scope do
  i = 0
  dur_msec = 80
  SoundEffect.register(:se2_5, dur_msec, WAVE_TRI, 5000) do
    msec = i.to_f / 5000 * 1000
    ratio = msec.to_f / dur_msec
    ratio_inv = 1.0 - ratio
    hz, vol =
      case
      when ratio < 0.2 then [800 + rand(200), 6]
      when ratio < 0.7 then [0, 0]
      else  [2400 + rand(200), 4]
      end

    i += 1
    [hz, vol]
  end
end

SoundEffect.register(:se3, 30, WAVE_TRI) do
  [800, 8]
end

scope do
  msec = 0
  SoundEffect.register(:se4, 150, WAVE_RECT) do
    hz =
      case
      when msec <  50 then 400
      when msec < 100 then 600
      else                 800
      end

    msec += 1
    [hz, 5]
  end
end

scope do
  msec = 0
  SoundEffect.register(:se5_2, 90, WAVE_SIN) do
    hz, vol =
      case
      when msec <  30 then [800, 5]
      when msec <  60 then [0, 0]
      else                 [1200, 3]
      end

    msec += 1
    [hz, vol]
  end
end

scope do
  msec = 0
  SoundEffect.register(:se6, 60, WAVE_SIN) do
    hz =
      case
      when msec <  20 then 600
      when msec <  40 then 0
      else                 300
      end

    msec += 1
    [hz, 5]
  end
end
