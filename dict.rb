class SKK
  class Dict
    attr_reader :kanji, :hiragana

    def initialize
      @kanji = {}
    end

    def hiragana_any_start_with?(head)
      @hiragana.keys.any? { |it| it.start_with?(head) }
    end

    def kanji_register(midasigo, kouho)
      unless @kanji.key?(midasigo)
        @kanji[midasigo] = KanjiEntry.new([])
      end
      entry = @kanji[midasigo]

      entry.kouho_list.unshift(kouho)
    end

    class KanjiEntry
      attr_reader :kouho_list
      attr_reader :i

      def initialize(kouho_list)
        @kouho_list = kouho_list
        reset()
      end

      def reset
        @i = 0
      end

      def update_order
        kouho = current_kouho
        # 先頭に移動
        new_kouho_list = [kouho] + @kouho_list.reject{ |k| k == kouho }
        @kouho_list = new_kouho_list
      end

      def current_kouho
        @kouho_list[@i]
      end

      def prev_kouho
        if @i <= 0
          @i = 0
          nil
        else
          @i -= 1
          current_kouho
        end
      end

      def next_kouho
        if @i >= @kouho_list.size - 1
          @i = @kouho_list.size - 1
          nil
        else
          @i += 1
          current_kouho
        end
      end
    end

    def init(map_kanji, map_hiragana)
      map_kanji.each do |midasigo, v|
        @kanji[midasigo] = KanjiEntry.new(v[:kouho])
      end

      @hiragana = map_hiragana
    end

    HIRAGANA_FULL = {
      "a"   => ["あ", nil],
      "i"   => ["い", nil],
      "u"   => ["う", nil],
      "e"   => ["え", nil],
      "o"   => ["お", nil],

      "ka"  => ["か", nil],
      "ki"  => ["き", nil],
      "ku"  => ["く", nil],
      "ke"  => ["け", nil],
      "ko"  => ["こ", nil],

      "ga"  => ["が", nil],
      "gi"  => ["ぎ", nil],
      "gu"  => ["ぐ", nil],
      "ge"  => ["げ", nil],
      "go"  => ["ご", nil],

      "sa"  => ["さ", nil],
      "si"  => ["し", nil],
      "su"  => ["す", nil],
      "se"  => ["せ", nil],
      "so"  => ["そ", nil],

      "za"  => ["ざ", nil],
      "zi"  => ["じ", nil],
      "ji"  => ["じ", nil],
      "zu"  => ["ず", nil],
      "ze"  => ["ぜ", nil],
      "zo"  => ["ぞ", nil],

      "ta"  => ["た", nil],
      "ti"  => ["ち", nil],
      "tu"  => ["つ", nil],
      "te"  => ["て", nil],
      "to"  => ["と", nil],

      "da"  => ["だ", nil],
      "di"  => ["ぢ", nil],
      "du"  => ["づ", nil],
      "de"  => ["で", nil],
      "do"  => ["ど", nil],

      "na"  => ["な", nil],
      "ni"  => ["に", nil],
      "nu"  => ["ぬ", nil],
      "ne"  => ["ね", nil],
      "no"  => ["の", nil],

      "ha"  => ["は", nil],
      "hi"  => ["ひ", nil],
      "hu"  => ["ふ", nil],
      "fu"  => ["ふ", nil],
      "he"  => ["へ", nil],
      "ho"  => ["ほ", nil],

      "ba"  => ["ば", nil],
      "bi"  => ["び", nil],
      "bu"  => ["ぶ", nil],
      "be"  => ["べ", nil],
      "bo"  => ["ぼ", nil],

      "pa"  => ["ぱ", nil],
      "pi"  => ["ぴ", nil],
      "pu"  => ["ぷ", nil],
      "pe"  => ["ぺ", nil],
      "po"  => ["ぽ", nil],

      "ma"  => ["ま", nil],
      "mi"  => ["み", nil],
      "mu"  => ["む", nil],
      "me"  => ["め", nil],
      "mo"  => ["も", nil],

      "ra"  => ["ら", nil],
      "ri"  => ["り", nil],
      "ru"  => ["る", nil],
      "re"  => ["れ", nil],
      "ro"  => ["ろ", nil],

      "ya"  => ["や", nil],
      "yu"  => ["ゆ", nil],
      "yo"  => ["よ", nil],

      "wa"  => ["わ", nil],
      "wo"  => ["を", nil],
      "nn"  => ["ん", nil],
      "n'"  => ["ん", nil],

      "kk"  => ["っ", "k"],
      "gg"  => ["っ", "g"],
      "ss"  => ["っ", "s"],
      "zz"  => ["っ", "z"],
      "jj"  => ["っ", "j"],
      "tt"  => ["っ", "t"],
      "dd"  => ["っ", "d"],
      "hh"  => ["っ", "h"],
      "bb"  => ["っ", "b"],
      "pp"  => ["っ", "p"],
      "mm"  => ["っ", "m"],
      "yy"  => ["っ", "y"],
      "rr"  => ["っ", "r"],
      "ww"  => ["っ", "w"],

      "xa"  => ["ぁ", nil],
      "xi"  => ["ぃ", nil],
      "xu"  => ["ぅ", nil],
      "xe"  => ["ぇ", nil],
      "xo"  => ["ぉ", nil],

      "xya" => ["ゃ", nil],
      "xyu" => ["ゅ", nil],
      "xyo" => ["ょ", nil],

      "kya" => ["きゃ", nil],
      "kyu" => ["きゅ", nil],
      "kyo" => ["きょ", nil],

      "gya" => ["ぎゃ", nil],
      "gyu" => ["ぎゅ", nil],
      "gyo" => ["ぎょ", nil],

      "sya" => ["しゃ", nil],
      "syu" => ["しゅ", nil],
      "syo" => ["しょ", nil],

      "ja"  => ["じゃ", nil],
      "ju"  => ["じゅ", nil],
      "jo"  => ["じょ", nil],

      "tya" => ["ちゃ", nil],
      "tyu" => ["ちゅ", nil],
      "tyo" => ["ちょ", nil],

      "nya" => ["にゃ", nil],
      "nyu" => ["にゅ", nil],
      "nyo" => ["にょ", nil],

      "fa"  => ["ふぁ", nil],
      "fi"  => ["ふぃ", nil],
      "fe"  => ["ふぇ", nil],
      "fo"  => ["ふぉ", nil],

      "pya" => ["ぴゃ", nil],
      "pyu" => ["ぴゅ", nil],
      "pyo" => ["ぴょ", nil],

      "rya" => ["りゃ", nil],
      "ryu" => ["りゅ", nil],
      "ryo" => ["りょ", nil],

      "nb"  => ["ん", "b"],
      "nd"  => ["ん", "d"],
      "nf"  => ["ん", "f"],
      "ng"  => ["ん", "g"],
      "nh"  => ["ん", "h"],
      "nj"  => ["ん", "j"],
      "nk"  => ["ん", "k"],
      "nm"  => ["ん", "m"],
      "np"  => ["ん", "p"],
      "nr"  => ["ん", "r"],
      "ns"  => ["ん", "s"],
      "nt"  => ["ん", "t"],
      "nv"  => ["ん", "v"],
      "nw"  => ["ん", "w"],
      "nz"  => ["ん", "z"],

      "va"  => ["う゛ぁ", nil],
      "vi"  => ["う゛ぃ", nil],
      "vu"  => ["う゛", nil],
      "ve"  => ["う゛ぇ", nil],
      "vo"  => ["う゛ぉ", nil],

      "dhi" => ["でぃ", nil],

      "-"   => ["ー", nil],
      ","   => ["、", nil],
      "."   => ["。", nil],
      "["   => ["「", nil],
      "]"   => ["」", nil],
    }

    # KANJI_USER = {}

    # KANJI = {
    # }

    KANJI_DATA = {
      "あか" => {
        kouho: ["赤"]
      },
      "あき" => {
        kouho: ["秋"]
      },
      "あじ" => {
        kouho: ["味", "鯵"]
      },
      "あっき" => {
        kouho: ["悪鬼"]
      },
      "うごk" => {
        kouho: ["動"]
      },
      "かん" => {
        kouho: ["缶", "完", "感"]
      },
      "かんじ" => {
        kouho: ["漢字", "幹事"]
      },
      "かんj" => {
        kouho: ["感"]
      },
      "かんじゃ" => {
        kouho: ["患者"]
      },
      "き" => {
        kouho: ["機", "器", "危"]
      },
      "じか" => {
        kouho: ["時価", "磁化"]
      },
      "じかん" => {
        kouho: ["時間", "字間"]
      },
    }

    KANJI_DATA_FULL = KANJI_DATA.merge(
      {
        "あく" => {kouho: ["悪"]},
        "あめ" => {kouho: ["雨"]},
        "い" => {kouho: ["胃"]},
        "いえ" => {kouho: ["家"]},
        "いu" => {kouho: ["云"]},
        "いk" => {kouho: ["行"]},
        "いし" => {kouho: ["石"]},
        "いしゃ" => {kouho: ["医者"]},
        "いち" => {kouho: ["一"]},
        "いt" => {kouho: ["行"]},
        "いま" => {kouho: ["今"]},
        "いんりょく" => {kouho: ["引力"]},
        "うごi" => {kouho: ["動"]},
        "うごk" => {kouho: ["動"]},
        "うt" => {kouho: ["打", "撃"]},
        "うちゅう" => {kouho: ["宇宙"]},
        "うちゅうせん" => {kouho: ["宇宙船"]},
        "うまr" => {kouho: ["生"]},
        "えらb" => {kouho: ["選"]},
        "おおかみ" => {kouho: ["狼"]},
        "おおk" => {kouho: ["大"]},
        "おくr" => {kouho: ["送"]},
        "おしゃれ" => {kouho: ["お洒落"]},
        "おそr" => {kouho: ["恐"]},
        "おに" => {kouho: ["鬼"]},
        "おも" => {kouho: ["主"]},

        "か" => {kouho: ["化", "家"]},
        "が" => {kouho: ["画"]},
        "かいしゃく" => {kouho: ["解釈"]},
        "かいぜん" => {kouho: ["改善"]},
        "かいはつ" => {kouho: ["開発"]},
        "かこn" => {kouho: ["囲"]},
        "かぜ" => {kouho: ["風"]},
        "かた" => {kouho: ["方"]},
        "かっこ" => {kouho: ["「", "」"]},
        "がっこう" => {kouho: ["学校"]},
        "かね" => {kouho: ["金"]},
        "かれ" => {kouho: ["彼"]},
        "かw" => {kouho: ["変"]},
        "かんがe" => {kouho: ["考"]},
        "かんけい" => {kouho: ["関係"]},
        "かんばん" => {kouho: ["看板"]},
        "き" => {kouho: ["機", "器", "危", "帰", "気"]},
        "きかんしゃ" => {kouho: ["機関車"]},
        "ぎじゅつ" => {kouho: ["技術"]},
        "きょう" => {kouho: ["今日"]},
        "きょうし" => {kouho: ["教師"]},
        "きょ" => {kouho: ["巨"]},
        "きょうじゅ" => {kouho: ["教授"]},
        "きん" => {kouho: ["金"]},
        "ぎん" => {kouho: ["銀"]},
        "げんご" => {kouho: ["言語"]},
        "く" => {kouho: ["駆"]},
        "くi" => {kouho: ["食"]},
        "くu" => {kouho: ["食"]},
        "くw" => {kouho: ["食"]},
        "くもr" => {kouho: ["曇"]},
        "くもり" => {kouho: ["曇"]},
        "げ" => {kouho: ["下"]},
        "けいさん" => {kouho: ["計算"]},
        "けいしょう" => {kouho: ["継承"]},
        "けいそく" => {kouho: ["計測"]},
        "けんとう" => {kouho: ["見当"]},
        "げん" => {kouho: ["現"]},
        "ご" => {kouho: ["語"]},
        "こうぞう" => {kouho: ["構造"]},
        "こうばい" => {kouho: ["勾配"]},
        "こごろう" => {kouho: ["小五郎"]},
        "こたe" => {kouho: ["答"]},
        "ごちそう" => {kouho: ["御馳走"]},
        "こと" => {kouho: ["事"]},
        "こんげん" => {kouho: ["根源"]},
        "こんにちは" => {kouho: ["今日は"]},

        "さい" => {kouho: ["再"]},
        "さいてき" => {kouho: ["最適"]},
        "ざいりょう" => {kouho: ["材料"]},
        "さぎ" => {kouho: ["詐欺"]},
        "ささe" => {kouho: ["支"]},
        "し" => {kouho: ["試"]},
        "じ" => {kouho: ["示", "時"]},
        "じしょ" => {kouho: ["辞書"]},
        "した" => {kouho: ["下"]},
        "じだい" => {kouho: ["時代"]},
        "じつ" => {kouho: ["実"]},
        "しめs" => {kouho: ["示"]},
        "しゃ" => {kouho: ["者"]},
        "じゃあく" => {kouho: ["邪悪"]},
        "じゃく" => {kouho: ["弱"]},
        "しゃれ" => {kouho: ["洒落"]},
        "しゅ" => {kouho: ["主"]},
        "じゅく" => {kouho: ["熟"]},
        "しょ" => {kouho: ["諸"]},
        "しょく" => {kouho: ["食", "職"]},
        "しょくぎょう" => {kouho: ["職業"]},
        "しr" => {kouho: ["知"]},
        "じん" => {kouho: ["人"]},
        "しんくう" => {kouho: ["真空"]},
        "すいそく" => {kouho: ["推測"]},
        "すがた" => {kouho: ["姿"]},
        "すばr" => {kouho: ["素晴"]},
        "すべて" => {kouho: ["全て"]},
        "すm" => {kouho: ["住"]},
        "すn" => {kouho: ["済"]},
        "せき" => {kouho: ["石"]},
        "せっけい" => {kouho: ["設計"]},
        "せん" => {kouho: ["船"]},
        "そう" => {kouho: ["装"]},
        "そうぞう" => {kouho: ["想像", "創造"]},
        "ぞうに" => {kouho: ["雑煮"]},

        "たいs" => {kouho: ["対"]},
        "たいへん" => {kouho: ["大変"]},
        "たつ" => {kouho: ["達"]},
        "たつじん" => {kouho: ["達人"]},
        "たび" => {kouho: ["旅"]},
        "たま" => {kouho: ["玉", "弾"]},
        "だん" => {kouho: ["団", "弾"]},
        "ちゅう" => {kouho: ["中"]},
        "ち" => {kouho: ["地", "智"]},
        "ちr" => {kouho: ["散"]},
        "つm" => {kouho: ["詰"]},
        "て" => {kouho: ["手"]},
        "てい" => {kouho: ["低"]},
        "てき" => {kouho: ["的"]},
        # "てすと" => {kouho: ["テスト"]},
        "でt" => {kouho: ["出"]},
        "てつがく" => {kouho: ["哲学"]},
        "ど" => {kouho: ["度"]},
        "どう" => {kouho: ["動"]},
        "どうさ" => {kouho: ["動作"]},
        "とうろく" => {kouho: ["登録"]},
        "とk" => {kouho: ["溶"]},
        "とき" => {kouho: ["時"]},
        "ときどき" => {kouho: ["時々"]},

        "な" => {kouho: ["名"]},
        "なか" => {kouho: ["中"]},
        "なに" => {kouho: ["何"]},
        "なまえ" => {kouho: ["名前"]},
        "に" => {kouho: ["二"]},
        "にち" => {kouho: ["日"]},
        "にほん" => {kouho: ["日本"]},
        "にほんご" => {kouho: ["日本語"]},
        "にゅうりょく" => {kouho: ["入力"]},
        "にん" => {kouho: ["人"]},
        "にんげん" => {kouho: ["人間"]},
        "ぬの" => {kouho: ["布"]},
        "ねこ" => {kouho: ["猫"]},
        "ねt" => {kouho: ["寝"]},

        "ばい" => {kouho: ["倍"]},
        "はな" => {kouho: ["花"]},
        "はは" => {kouho: ["母"]},
        "はやi" => {kouho: ["速"]},
        "ひ" => {kouho: ["日"]},
        "ひくi" => {kouho: ["低"]},
        "ひと" => {kouho: ["人"]},
        "ひとり" => {kouho: ["一人"]},
        "ひるね" => {kouho: ["昼寝"]},
        "びん" => {kouho: ["瓶"]},
        "びんかん" => {kouho: ["敏感"]},
        "へんかん" => {kouho: ["変換"]},
        "ふ" => {kouho: ["布"]},
        "ふk" => {kouho: ["吹"]},
        "ふね" => {kouho: ["船"]},
        "ほう" => {kouho: ["方"]},

        "まい" => {kouho: ["毎"]},
        "まいにち" => {kouho: ["毎日"]},
        "まt" => {kouho: ["待"]},
        "まんげつ" => {kouho: ["満月"]},
        "み" => {kouho: ["実"]},
        "みe" => {kouho: ["見"]},
        "みぎ" => {kouho: ["右"]},
        "みせ" => {kouho: ["店"]},
        "みr" => {kouho: ["見"]},
        "むk" => {kouho: ["向"]},
        "むかし" => {kouho: ["昔"]},
        "めい" => {kouho: ["明"]},
        "めずらs" => {kouho: ["珍"]},
        "もの" => {kouho: ["者"]},

        "ゆえ" => {kouho: ["故"]},
        "ようじん" => {kouho: ["用心"]},
        "ようばい" => {kouho: ["溶媒"]},
        "よさん" => {kouho: ["予算"]},
        "よどn" => {kouho: ["澱"]},
        "よb" => {kouho: ["呼"]},
        "よる" => {kouho: ["夜"]},
        "よわi" => {kouho: ["弱"]},

        "らく" => {kouho: ["楽"]},
        "らしょうもん" => {kouho: ["羅生門"]},
        "らんぽ" => {kouho: ["乱歩"]},
        "りかい" => {kouho: ["理解"]},
        "りっぱ" => {kouho: ["立派"]},
        "れい" => {kouho: ["例"]},
        "れもん" => {kouho: ["檸檬"]},

        "わがはい" => {kouho: ["吾輩"]},
        "わたし" => {kouho: ["私"]},
        "わふく" => {kouho: ["和服"]},
        "はやs" => {kouho: ["早"]},
        # "れたーぱっく" => {kouho: ["レターパック"]},
      }
    )
  end
end
