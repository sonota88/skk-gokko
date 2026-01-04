case RUBY_ENGINE
when "opal"  then require "dxopal"
when "jruby" then require "dxjruby"
else
  raise "unsupported engine (#{RUBY_ENGINE})"
end

case RUBY_ENGINE
when "opal"          then require_remote   "utils.rb"
when "jruby", "ruby" then require_relative "utils"
else
  raise "unsupported engine (#{RUBY_ENGINE})"
end

case RUBY_ENGINE
when "opal"
  require_remote "editor.rb"
  require_remote "dict.rb"
  require_remote "sound.rb"
  require_remote "examples.rb"
  font_name = "monospace_custom"
when "jruby", "ruby"
  require_relative "editor"
  require_relative "dict"
  require_relative "sound"
  require_relative "examples"

  names = Font.install(File.expand_path("~/.fonts/Firge-Bold.ttf"))
  font_name = names[0]
else
  raise "unsupported engine (#{RUBY_ENGINE})"
end

# $DEBUG = true

WIN_W = 800
WIN_H = 400

FONT_S = Font.new(16, font_name)
FONT_L = Font.new(30, font_name)

C_FG = [40, 40, 40] # foreground
C_FG3 = [200, 0, 0] # foreground buf
C_FG4 = [80, 80, 80]
C_FG5 = [120, 120, 120]
# C_LINE = [225, 225, 225]
C_CURSOR_HIRAGANA = [200, 240, 40, 0]
C_CURSOR_KATAKANA = [200, 0, 160, 230]
C_CURSOR_ASCII = [60, 60, 60]
C_GRID = [10, 0, 0, 0]

OFFSET_X = 16

T0 = Time.now

# key code => char
MAP_KC_C = {
  K_7 => "7",
  K_LBRACKET => "[",
  K_RBRACKET => "]",
  K_SPACE => " ",
  K_MINUS => "-",
  K_COMMA => ",",
  K_PERIOD => ".",
  K_ENTER => "RET",
  K_BACKSPACE => "BS",
}

# K_A => "a", ...
("a".."z").each { |c|
  kc = Input.const_get("K_#{c.upcase}")
  MAP_KC_C[kc] = c
}

# --------------------------------

$sound_test_list = [
  [K_1, :se1],
  [K_2, :se2_5],
  [K_3, :se3],
  [K_4, :se4],
  [K_5, :se5_2],
  [K_6, :se6],
]

MAP_SE = {
  switch_input_mode: :se2_5,
  match_char: :se5_2,
  match_text: :se4,
  cancel: :se6,
  next: :se1,
}

def se_play(name)
  return unless $app.enable_se

  se_name = MAP_SE.fetch(name)
  SoundEffect[se_name].play
end

# --------------------------------

def key_down_ctrl?
  Input.key_down?(K_LCONTROL) || Input.key_down?(K_RCONTROL)
end

def key_down_shift?
  Input.key_down?(K_LSHIFT) || Input.key_down?(K_RSHIFT)
end

def to_c_w(font_size)
  font_size * 0.51
end

def draw_font(x, y, text, font, color:)
  y_adj =
    case RUBY_ENGINE
    when "opal"
      case font.size
      when FONT_L.size then 9
      when FONT_S.size    then 5
      else 0
      end
    when "jruby"
      0
    else
      raise "unsupported engine (#{RUBY_ENGINE})"
    end
  Window.draw_font(x, y + y_adj, text, font, color: color)
end

def draw_char_v2(
      y,
      ci, # col index
      c,  # char
      font, color:
    )
  c_w = to_c_w(font.size)
  draw_font(
    OFFSET_X + ci * c_w,
    y,
    c,
    font,
    color: color
  )
end

def draw_chars_v4(y, ci, text, font, color:, focused:)
  color2 = with_alpha(color, focused ? 255 : 120)
  delta = 0
  text.each_char { |c|
    draw_char_v2(y, ci + delta, c, font, color: color2)
    delta += char_width(c)
  }
  delta
end

def draw_text(y, text, font, color:)
  draw_font(
    OFFSET_X, y,
    text, font,
    color: color
  )
end

# --------------------------------

class EffectBase
  def initialize
    @t0 = Time.now
  end

  def update() raise end
  def draw() raise end
end

class MatchCharEffect < EffectBase
  def initialize(dur_msec: 500)
    super()
    @dur_msec = dur_msec
    @t_done = @t0 + @dur_msec.to_f / 1000
  end

  def finished?
    @t_done <= Time.now
  end

  def update() end

  def draw
    dur_sec = @dur_msec.to_f / 1000
    ratio = (Time.now - @t0) / dur_sec
    ratio_inv = 1.0 - ratio

    alpha = clamp(
      255 * ratio_inv * 0.75,
      0,
      255
    )

    Window.draw_box_fill(
      0, 0, WIN_W, WIN_H,
      [alpha, 255,255,255]
    )
  end

  def dur_sec
    @dur_msec.to_f / 1000
  end
end

# --------------------------------

class App
  MAP_MODE_STR = {
    ascii: "ASCII",
    hiragana: "かな",
    katakana: "カナ",
    zenei: "全英",
  }

  attr_accessor :action
  attr_reader :editor_group
  attr_reader :effects
  attr_reader :enable_se

  def initialize
    @effects = []

    dict = SKK::Dict.new
    dict.init(SKK::Dict::KANJI_DATA_FULL, SKK::Dict::HIRAGANA_FULL)
    @editor_group = EditorGroup.new(dict: dict)

    @examples = []
    @enable_se = false
  end

  def next_example
    if @examples.empty?
      @examples = EXAMPLE_DATA.shuffle
    end
    
    @examples.shift
  end

  def focused_editor
    @editor_group.focused_editor
  end

  def focused_editor?(editor)
    editor == focused_editor
  end

  def draw_guide(y)
    parts = []
    case focused_editor.skk.action
    when SKK::HiraganaAction
      if @editor_group.touroku_stack.size > 0
        # 辞書登録中
        parts << "C-g: キャンセル"
        parts << "C-j: 確定（辞書に登録）"
      end
    when SKK::MidasigoAction
      parts << "C-g: キャンセル"
      parts << "SPC: 変換"
    when SKK::HenkanAction
      parts << "C-g: キャンセル"
      parts += ["C-j: 確定", "x: 前候補", "SPC: 次候補"]
    else
      ;
    end

    draw_text(
      y,  parts.join(" | "),
      FONT_S, color: C_FG5
    )
  end

  def draw_se_button
    name = @enable_se ? :se_on : :se_off
    Window.draw(WIN_W - 32, WIN_H - 32, Image[name])
    Window.draw_box_fill(
      WIN_W - 32, WIN_H - 32,
      WIN_W, WIN_H,
      [100, 255, 255, 255]
    )
  end

  def _draw_grid
    (0...20)
      .map { |x| x * 50 }
      .each { |x|
        Window.draw_line(
          x, 0,
          x, WIN_H,
          C_GRID
        )
      }
    (0...10)
      .map { |y| y * 50 }
      .each { |y|
        Window.draw_line(
          0,     y,
          WIN_W, y,
          C_GRID
        )
      }
  end

  # デバッグ用
  def _sound_test
    if key_down_shift?
      $sound_test_list.each { |kc, se_name|
        if Input.key_push?(kc)
          SoundEffect[se_name].play
          return true
        end
      }
    end

    nil
  end

  def tick
    return if _sound_test()

    if Input.mouse_push?(M_LBUTTON)
      mx = Input.mouse_x
      my = Input.mouse_y
      if WIN_W - 32 <= mx && mx < WIN_W &&
         WIN_H - 32 <= my && my < WIN_H
        @enable_se = !@enable_se
      end
    end

    @action.update
    @effects.each { |eff| eff.update }

    _draw_grid
    draw_se_button
    @action.draw
    @effects.each { |eff| eff.draw }

    @effects.reject! { |eff| eff.finished? }
  end
end

class ActionBase
  def initialize(app)
    @app = app
  end
end

class InputAction < ActionBase
  def initialize(app, example)
    super(app)
    @example = example
    @t_next = nil
    @input_mode_prev = :hiragana # TODO 引数で受け取る
  end

  def update
    if @t_next
      if @t_next < Time.now
        @t_next = nil
        @app.editor_group.main.reset
        @app.action = InputAction.new(@app, @app.next_example())
      else
        # @t_next になるまで待つ
      end
    else
      k_ctrl = key_down_ctrl?()
      k_shift = key_down_shift?()

      if (k_ctrl && k_shift && Input.key_push?(K_SPACE))
        # デバッグ用
        se_play :match_text
        eff = MatchCharEffect.new
        @app.effects << eff
        @t_next = Time.now + eff.dur_sec
        return
      elsif (k_shift && Input.key_push?(K_SPACE)) || Input.key_push?(K_RIGHT)
        se_play :next
        eff = MatchCharEffect.new(dur_msec: 100)
        @app.effects << eff
        @t_next = Time.now + eff.dur_sec
        return
      elsif k_ctrl && !k_shift && Input.key_push?(K_G)
        se_play :cancel
      end

      input_mode = @app.focused_editor.skk.input_mode
      if @input_mode_prev != input_mode
        se_play :switch_input_mode
      end
      @input_mode_prev = input_mode

      pushed_keys = MAP_KC_C.keys
        .select { |kc| Input.key_push?(kc) }
        .map { |kc|
          c = MAP_KC_C.fetch(kc)
          SKK::KeyEvent.new(c, ctrl: k_ctrl, shift: k_shift)
        }

      if pushed_keys.size > 0
        begin
          @app.focused_editor.on_input(pushed_keys)
        rescue => e
          # TODO 画面にもメッセージ表示する
          case RUBY_ENGINE
          when "opal"
            p_ error: e
          else
            raise e
          end
        end
      end

      @_match_n ||= 0
      new_match_n = match_n(@example[:text], @app.editor_group.main.text)
      if new_match_n == @example[:text].size
        se_play :match_text
        eff = MatchCharEffect.new
        @app.effects << eff
        @t_next = Time.now + eff.dur_sec
      elsif @_match_n < new_match_n
        se_play :match_char
      end
      @_match_n = new_match_n
    end
  end

  def match_n(ex, input)
    n = 0
    (ex.chars).zip(input.chars).each { |ce, ci|
      break if ce != ci

      n += 1
    }
    n
  end

  def draw_chars_example(y, ci, text, font, color:, focused:, head_n:)
    delta = 0

    chars = text.chars
    chars.each_with_index { |c, i|
      y_disp =
        if i < head_n
          -4
        else
          0
        end
      color2 =
        if i < head_n
          with_alpha(color, 255)
        else
          with_alpha(color, 140)
        end

      draw_char_v2(y + y_disp, ci + delta, c, font, color: color2)
      delta += char_width(c)
    }

    delta
  end

  def draw_example
    ex = @example[:text]
    input = @app.editor_group.main.text

    n = match_n(ex, input)

    draw_chars_example(
      10, 0, ex, FONT_L,
      color: C_FG,
      focused: true,
      head_n: n
    )
  end

  def draw_cursor_main(y, ci, editor, font:)
    c_w = to_c_w(font.size)
    c_h = font.size

    x = ci * c_w
    w = c_w * 0.3

    color =
      case editor.skk.input_mode
      when :hiragana
        C_CURSOR_HIRAGANA
      when :katakana
        C_CURSOR_KATAKANA
      else
        C_CURSOR_ASCII
      end

    tdelta = ((Time.now - T0) * 1.5).to_i
    if tdelta % 2 == 0
      Window.draw_box_fill(
        OFFSET_X + x    , y + c_h * 0.2,
        OFFSET_X + x + w, y + c_h * 1.4,
        with_alpha(color, 220)
      )
    end
  end

  def draw_editor_v3(y, col, editor, focused, font:)
    c_w = to_c_w(font.size)
    c_h = font.size
    _col = col
    _col += text_width(editor.text)
    _col += text_width(editor.skk.mode_str)
    hl_beg = _col
    _col += text_width(editor.skk.stage)
    hl_end = _col

    if hl_beg != hl_end
      c_bg = [210, 235, 140]
      c_bg = with_alpha(c_bg, focused ? 255: 120)
      Window.draw_box_fill(
        OFFSET_X + hl_beg * c_w, y + c_h * 0.2,
        OFFSET_X + hl_end * c_w, y + c_h * 1.4,
        c_bg
      )
    end

    col += draw_chars_v4(y, col, editor.text, font, color: C_FG, focused: focused)

    c_stg = C_FG
    col += draw_chars_v4(y, col, editor.skk.mode_str, font, color: c_stg, focused: focused)
    col += draw_chars_v4(y, col, editor.skk.stage, font, color: c_stg, focused: focused)

    c_buf = C_FG3
    col += draw_chars_v4(y, col, editor.skk.buf, font, color: c_buf, focused: focused)

    if focused
      draw_cursor_main(
        y, col, editor,
        font: font
      )
    end
  end

  def draw_touroku_box_v2(y, editor, last_p)
    c =
      if last_p
        C_FG4
      else
        with_alpha(C_FG4, 120)
      end

    col = draw_chars_v4(
      y, 0, "[辞書登録] #{editor.midasigo}: ",
      FONT_S, color: c, focused: last_p
    )
    draw_editor_v3(
      y, col, editor,
      @app.focused_editor?(editor),
      font: FONT_S
    )
  end

  def draw_touroku_boxes(offset_y, font)
    c_h = font.size
    touroku_editors = @app.editor_group.touroku_stack
    line_h = c_h * 1.5
    touroku_editors.each_with_index { |ed, i|
      last_p = ed == touroku_editors.last
      y = offset_y + line_h * i
      draw_touroku_box_v2(y, ed, last_p)
    }
  end

  def draw_hint
    if @example[:hint]
      draw_font(
        OFFSET_X, 55,
        @example[:hint],
        FONT_S,
        color: with_alpha(C_FG, 120)
      )
    end
  end

  def draw_input_mode(y, editor)
    im = editor.skk.input_mode
    s = App::MAP_MODE_STR.fetch(im)

    guide =
      case im
      when :ascii    then "C-j: かな"
      when :hiragana then "l: ASCII | q: カナ"
      when :katakana then "l: ASCII | q: かな"
      else ""
      end

    draw_text(
      y, "[#{s}] （#{guide}）", FONT_S,
      color: C_FG5
    )
  end

  def draw
    draw_example()
    draw_hint()

    y = 80
    ed_main = @app.editor_group.main
    draw_editor_v3(
      y, 0, ed_main,
      @app.focused_editor?(ed_main),
      font: FONT_L
    )

    draw_input_mode(
      128,
      @app.editor_group.main
    )

    draw_touroku_boxes(180, FONT_S)

    if @example[:memo]
      draw_font(
        10, WIN_H - 90,
        @example[:memo],
        FONT_S,
        color: C_FG5
      )
    end

    @app.draw_guide(WIN_H - 60)

    if @example[:src]
      draw_font(
        10, WIN_H - 30,
        "出典: " + @example[:src],
        FONT_S,
        color: C_FG5
      )
    end
  end
end

# --------------------------------

Window.width = WIN_W
Window.height = WIN_H
Window.bgcolor = [255, 255, 255]

Image.register(:se_on, "img/se_on.png")
Image.register(:se_off, "img/se_off.png")

$app = App.new
$app.action = InputAction.new($app, $app.next_example())

Window.load_resources do
  Window.loop do
    $app.tick
  end
end
