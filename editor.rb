case RUBY_ENGINE
when "opal"          then require_remote   "skk.rb"
when "jruby", "ruby" then require_relative "skk"
else
  raise "unsupported engine (#{RUBY_ENGINE})"
end

# _require_relative "skk"

class EditorBase
  attr_reader :skk
  attr_reader :text

  def initialize(editor_group:, skk:)
    @editor_group = editor_group
    @skk = skk
    @text = ""
  end

  def on_input(kevs)
    kevs.each { |kev|
      rv = @skk.on_input_v2(kev)
      _eval(rv) if rv
    }
  end

  def _eval(cmd)
    op, *args = cmd
    case op
    when :insert
      c, *_ = args
      insert(c)
    when :bs
      if @text.size > 0
        @text = @text[0..-2]
      end
    when :ret, :nop
      ;
    when :touroku_begin
      midasigo, * = args

      @editor_group.touroku_stack.push(
        EditorTouroku.new(
          parent_skk: @skk,
          dict: @skk.dict,
          editor_group: @editor_group,
          midasigo: midasigo,
        )
      )
    else
      raise "unknown operator"
    end
  end

  # str を現在のカーソル位置に挿入する
  def insert(str)
    @text += str
  end

  # 半角単位での位置
  def pos_half
    text_width(@text + @skk.mode_str + @skk.stage + @skk.buf)
  end

  # 文字数
  def pos
    @text.size +
      @skk.mode_str.size + 
      @skk.text_size
  end

  def reset
    @text = ""
  end
end

class EditorMain < EditorBase
  def initialize(dict:, editor_group:)
    skk = SKKMain.new(
      dict: dict,
      on_okuri_kakutei: ->(str){ insert(str) }
    )

    super(editor_group: editor_group, skk: skk)
  end
end

# 辞書登録用のエディタ
class EditorTouroku < EditorBase
  attr_reader :midasigo

  def initialize(dict:, editor_group:, midasigo:, parent_skk:)
    skk = SKKTouroku.new(
      dict: dict,
      parent: parent_skk,
      on_okuri_kakutei: ->(str){ insert(str) }
    )

    @midasigo = midasigo
    super(editor_group: editor_group, skk: skk)
  end

  def _eval(cmd)
    op, *args = cmd

    case op
    when :touroku_cancel
      @editor_group.touroku_stack.pop
    when :touroku_kakutei
      word = @text
      @skk.dict.kanji_register(@midasigo, word)
      @editor_group.touroku_stack.pop

      fe = @editor_group.focused_editor
      fe.insert(word)
    else
      super(cmd)
    end
  end
end

class EditorGroup
  attr_reader :main
  attr_reader :touroku_stack

  def initialize(dict:)
    @main = EditorMain.new(dict: dict, editor_group: self)
    @touroku_stack = []
  end

  def focused_editor
    ([@main] + @touroku_stack).last
  end
end
