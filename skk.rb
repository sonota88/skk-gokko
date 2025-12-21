class SKK
  attr_writer :input_mode
  attr_accessor :stage, :buf
  attr_reader :editor_eval
  attr_accessor :action
  attr_reader :dict
  attr_reader :parent

  class KeyEvent
    attr_reader :c

    def initialize(c, ctrl: false, shift: false)
      @c = c # char
      @ctrl = ctrl
      @shift = shift

      if !ctrl && shift && @c == "7"
        # 日本語キーボードのための措置
        @c ="'"
        @shift = false
      elsif ctrl && !shift && @c == "h"
        @c = "BS"
        @ctrl = false
      elsif ctrl && !shift && @c == "m"
        @c = "RET"
        @ctrl = false
      end
    end

    def ctrl?() @ctrl; end
    def shift?() @shift; end

    # Emacs like notation
    def cmd
      parts = []
      parts << "C" if ctrl?
      parts << "S" if shift?
      parts <<
        case @c
        when " " then "SPC"
        else @c
        end

      parts.join("-")
    end
  end

  def initialize(
        parent:,
        dict:,
        on_okuri_kakutei:
      )
    @parent = parent
    @dict = dict
    @_on_okuri_kakutei = on_okuri_kakutei

    @input_mode = :hiragana # :hiragana | :katakana
    @stage = ""
    @buf = ""
    @action = HiraganaAction.new(self)
  end

  def input_mode
    case @action
    when AsciiAction then :ascii
    # when ZeneiAction then :zenei
    else @input_mode # :hiragana | :katakana
    end
  end

  def henkan_mode
    case @action
    when AsciiAction, HiraganaAction #, KatakanaAction, ZeneiAction
      :"■" # 確定入力モード
    when MidasigoAction
      :"▽" # 見出し語入力モード
    when HenkanAction, DummyHenkanAction
      :"▼" # 辞書変換モード
    else
      raise "must not happen"
    end
  end

  def on_okuri_kakutei(str)
    @_on_okuri_kakutei.call(str)
  end

  def on_input_v2(kev)
    cmd = kev.cmd
    head = "    | "
    if $DEBUG
      puts "    --------------------------------"
      puts head + format(">> (%p) (%p) / %s", @stage, @buf, action.class)
      puts head + cmd
    end

    ed_cmd = action.on_input(kev)
    if $DEBUG
      puts head + format("<< (%p) (%p) / %s", @stage, @buf, action.class)
      puts head + format("cmd to editor: %p", ed_cmd)
    end

    ed_cmd
  end

  def parse_buf
    if m = @buf.match(/^(\*?)(.*?)([a-z]*)$/)
      aster = m[1]
      kana = m[2]
      alpha = m[3]
      [aster, kana, alpha]
    else
      raise "must not happen"
    end
  end

  def buf_kana
    _, kana, _ = parse_buf()
    kana
  end

  def toggle_kana
    @input_mode =
      if @input_mode == :hiragana
        :katakana
      else
        :hiragana
      end
  end

  def tr_kana(s)
    case @input_mode
    when :hiragana
      s
    when :katakana
      s.tr("あ-ん", "ア-ン")
    else
      raise "must not happen"
    end
  end

  def to_hiragana(s)
    s.tr("ア-ン", "あ-ん")
  end

  def kana_key?(s)
    @dict.hiragana.key?(s)
  end

  def kana_get(s)
    if kana_key?(s)
      kana, okuri = @dict.hiragana[s]
      [tr_kana(hiragana), okuri]
    else
      [nil, nil]
    end
  end

  def kana_fetch(s)
    kana, okuri = @dict.hiragana.fetch(s)
    [tr_kana(kana), okuri]
  end

  def kanji_key?(midasigo)
    @dict.kanji.key?(to_hiragana(midasigo))
  end

  def kanji_fetch(midasigo)
    @dict.kanji.fetch(to_hiragana(midasigo))
  end

  def kanji_get(midasigo)
    @dict.kanji[to_hiragana(midasigo)]
  end

  def mode_str
    case henkan_mode
    when :"■"
      ""
    else
      henkan_mode.to_s
    end
  end

  def text_size
    @stage.size + @buf.size
  end

  def to_plain_digest
    {
      stage_buf: format("(%p) (%p)", @stage, @buf),
      action: @action.class,
      input_mode: @input_mode,
      type: @type,
      # dict
    }
  end

  def inspect
    to_plain_digest.inspect
  end

  def pretty_inspect
    to_plain_digest.pretty_inspect
  end

  # --------------------------------

  class ActionBase
    def initialize(skk)
      @skk = skk
    end
  end

  class AsciiAction < ActionBase
    def on_input(kev)
      case kev.cmd
      when "C-j"
        # カナから ascii に切り替えた後でもかなに遷移する
        @skk.input_mode = :hiragana
        @skk.action = HiraganaAction.new(@skk)
        return [:nop]
      when "BS"
        return [:bs]
      when "RET"
        return [:ret]
      else
        ;
      end

      return [:nop] if kev.ctrl?

      @skk.stage = ""
      c2 = kev.shift? ? kev.c.upcase : kev.c
      return [:insert, c2]
    end
  end

  class HiraganaAction < ActionBase
    def on_input(kev)
      case kev.cmd
      when "C-g"
        case @skk
        when SKKMain
          return [:nop]
        when SKKTouroku
          case @skk.parent.action
          when DummyHenkanAction
            # 候補がない
            @skk.parent.action = SKK::MidasigoAction.new(@skk.parent)
          else
            # 候補がある
            ;
          end
          return [:touroku_cancel]
        else
          raise "invalid type (#{@skk.type})"
        end
      when "C-j", "RET"
        case @skk
        when SKKMain
          return [:ret]
        when SKKTouroku
          @skk.parent.action = SKK::HiraganaAction.new(@skk.parent)
          @skk.parent.stage = ""
          @skk.parent.buf = ""

          return [:touroku_kakutei]
        else raise "invalid type (#{@skk.type})"
        end
      when "S-l"
        # TODO 全英入力モードに移行
        return [:nop]
      when "l"
        @skk.input_mode = :ascii
        @skk.action = AsciiAction.new(@skk)
        @skk.stage = ""
        @skk.buf = ""
        return [:nop]
      when "q"
        @skk.toggle_kana()
        return [:nop]
      when "BS"
        if @skk.buf.size > 0
          @skk.buf = drop_last(@skk.buf)
          return [:nop]
        end
        return [:bs]
      when "SPC"
        return [:insert, kev.c]
      else
        ;
      end

      return [:nop] if kev.ctrl?

      if kev.shift?
        @skk.action = MidasigoAction.new(@skk)
        return @skk.action.on_input(kev)
      end

      @skk.buf += kev.c

      if @skk.kana_key?(@skk.buf)
        kana, okuri = @skk.kana_fetch(@skk.buf)
        @skk.buf = okuri || ""
        return [:insert, kana]
      else
        if @skk.dict.hiragana_any_start_with?(@skk.buf)
          # buf == "sy" ... sya などの可能性がある
        else
          # buf == "kj" ... マッチするものがない → "j" だけ残す
          @skk.buf = kev.c
        end

        return [:nop]
      end
    end
  end

  class MidasigoAction < ActionBase
    def initialize(skk)
      super(skk)
      @midasigo = nil
    end

    def reject_kana(str)
      s = str.dup
      while !("a".."z").include?(s[0])
        s = s[1..-1]
      end
      s
    end

    def on_input(kev)
      case kev.cmd
      when "C-g"
        @skk.action = HiraganaAction.new(@skk)
        @skk.buf = ""
        @skk.stage = ""
        return [:nop]
      when "BS"
        if @skk.buf.size > 0
          # ▽動*k → ▽動*
          @skk.buf = drop_last(@skk.buf)
          if @skk.buf.size > 0 && @skk.buf[-1] == "*"
            # ▽動* → ▽動
            @skk.buf = drop_last(@skk.buf)
          end
          return [:nop]
        end
        if @skk.stage.size > 0
          @skk.stage = drop_last(@skk.stage)
          return [:nop]
        end

        @skk.action = HiraganaAction.new(@skk)

        return [:nop]
      when "C-j", "RET"
        @skk.action = HiraganaAction.new(@skk)
        stg = @skk.stage
        @skk.stage = ""
        return [:insert, stg]
      when "l"
        @skk.action = AsciiAction.new(@skk)
        @skk.stage = ""
        @skk.buf = ""
        return [:nop]
      when "SPC"
        if @skk.stage.empty?
          @skk.action = HiraganaAction.new(@skk)
          return [:nop]
        end

        if @skk.buf == "n"
          @skk.buf = ""
          @skk.stage += "ん"
        end

        if @skk.kanji_key?(@skk.stage)
          midasigo = @skk.stage
          # 見出し語として確定させる
          entry = @skk.kanji_get(midasigo)
          entry.reset()
          @skk.stage = entry.current_kouho
          @skk.buf = ""
          @skk.action = HenkanAction.new(@skk, midasigo)
          return [:nop]
        else
          midasigo = @skk.stage
          @skk.action = DummyHenkanAction.new(@skk)
          return [:touroku_begin, midasigo]
        end
      else
        ;
      end

      if kev.ctrl?
        return [:nop]
      end

      first_char = @skk.stage.empty? && @skk.buf.empty?
      if @skk.buf[0] == "*"
        @midasigo ||= @skk.stage + @skk.buf[1..-1]
        s1 = reject_kana(@skk.buf[1..-1] + kev.c) # ki | んda
        kana, okuri = @skk.dict.hiragana[s1] # ki => き | んda => んだ 

        if okuri
          # puts "送り あり"
          #    かこ|*n + d
          # => かこ|*んd
          if kana
            @skk.buf = "*" + kana + okuri # "*" + "ん" + "d"
          else
            @skk.buf = "*" + kev.c
          end

          return [:nop]
        else
          # puts "送り なし"
          #    うご|*k + i
          # => うご|き
          #    かこ|*んd + a
          # => かこ|んだ
          if kana
            entry = @skk.kanji_get(@midasigo)
            @skk.stage = entry.current_kouho # 動 | 囲
            @skk.buf = @skk.buf_kana + kana # "" + "き" | "ん" + "だ"
            @skk.action = HenkanAction.new(@skk, @midasigo)
          else
            @skk.buf = "*" + kev.c
          end

          return [:nop]
        end
      elsif !first_char && kev.shift?
        midasigo = @skk.stage + kev.c

        if @skk.kanji_key?(midasigo)
          entry = @skk.kanji_get(midasigo)
          if @skk.kana_key?(kev.c)
            # 動i（送りあり＋母音）
            kana, okuri = @skk.kana_fetch(kev.c)
            kouho = entry.current_kouho
            @skk.stage = kouho + kana
            @skk.buf = ""
            @skk.action = HenkanAction.new(@skk, midasigo)
            return [:nop]
          else
            @skk.buf = "*" + kev.c
            return [:nop]
          end
        else
          @skk.buf = kev.c
          return [:nop]
        end

        return [:nop]
      else
        @skk.buf += kev.c
        if @skk.kana_key?(@skk.buf)
          kana, okuri = @skk.kana_fetch(@skk.buf)
          @skk.buf = okuri || ""
          @skk.stage += @skk.tr_kana(kana)
          return [:nop]
        else
          if @skk.dict.hiragana_any_start_with?(@skk.buf)
            # buf == "sy" ... sya などの可能性がある
          else
            # buf == "kj" ... マッチするものがない → "j" だけ残す
            @skk.buf = kev.c
          end

          return [:nop]
        end
      end
    end
  end

  class HenkanAction < ActionBase
    attr_reader :midasigo

    def initialize(skk, midasigo)
      super(skk)
      @midasigo = midasigo
      @entry = @skk.kanji_fetch(@midasigo)
      @entry.reset()
    end

    # return: 印字可能な文字である場合 true
    def printable?(c)
      return false if c == "RET"
      return false if c == "BS"

      # SPC .. ~
      (20 .. 126).include?(c[0].ord)
    end

    def anmoku_kakutei(kev)
      # 暗黙の確定
      # https://ddskk.readthedocs.io/ja/latest/05_basic.html
      # > 打鍵することによる副作用として暗黙の確定を伴うキーは、
      # > 印字可能な文字 全てと RET です。

      fixed = @skk.stage
      @skk.stage = ""
      buf = @skk.buf
      @skk.buf = ""

      @skk.action = HiraganaAction.new(@skk)

      @entry.update_order()

      @skk.on_okuri_kakutei(fixed + buf)
      case kev.cmd
      when "C-j", "RET"
        return [:nop]
      else
        @skk.action.on_input(kev)
      end
    end

    def on_input(kev)
      case kev.cmd
      when "C-g"
        @skk.action = MidasigoAction.new(@skk)
        @skk.stage = @midasigo
        @skk.buf = ""
        return [:nop]
      when "BS"
        @skk.action = HiraganaAction.new(@skk)
        @skk.stage = ""
        @skk.buf = ""
        return [:nop]
      when "SPC"
        # 次候補
        kouho = @entry.next_kouho
        if kouho
          @skk.stage = kouho
          return [:nop]
        else
          return [:touroku_begin, @midasigo]
        end
      when "x"
        # 前候補
        kouho = @entry.prev_kouho
        if kouho
          @skk.stage = kouho
          return [:nop]
        else
          @skk.action = MidasigoAction.new(@skk)
          @skk.stage = @midasigo
          return [:nop]
        end
      when "RET"
        return anmoku_kakutei(kev)
      else
        if printable?(kev.cmd)
          return anmoku_kakutei(kev)
        else
          return [:nop]
        end
      end
    end
  end

  # 変換候補が一つもない状態で辞書登録に移行した場合に
  # 変換モードの表示を ▼ にするために設けたもの。
  # （ddskk 準拠のための措置）
  class DummyHenkanAction < ActionBase
  end
end

class SKKMain < SKK
  def initialize(dict:, on_okuri_kakutei:)
    super(
      parent: nil,
      dict: dict,
      on_okuri_kakutei: on_okuri_kakutei
    )
  end
end

class SKKTouroku < SKK
  def initialize(parent:, dict:, on_okuri_kakutei:)
    raise "parent is required" if parent.nil?

    super(
      parent: parent,
      dict: dict,
      on_okuri_kakutei: on_okuri_kakutei
    )
  end
end
