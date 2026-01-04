# 吾輩は猫である
# https://www.aozora.gr.jp/cards/000148/card789.html
EXAMPLE_DATA_WAGAHAI = [
  {
    text: "吾輩は猫である",
    hint: "吾輩（わがはい）",
  },
  {
    text: "どこで生れたかとんと見当がつかぬ。",
    memo: "生まれた: UmaReta",
  },

  {
    text: "職業は教師だそうだ",
  },
  {
    text: "彼はよく昼寝をしている事がある",
  },
  {
    text: "吾輩は猫ながら時々考える事がある",
    hint: "考える: KangaEru",
  },
  {
    text: "名前はまだない",
  },
  {
    text: "見るとその看板にマーカスという名がかいてある。",
  },
  {
    text: "大変トチメンボーが食いたかったと見えますね",
    hint: "食いたかった: KuItakatta",
  },
  {
    text: "御馳走を食うよりも寝ていた方が気楽でいい。",
    hint: "御馳走（ごちそう）",
  },
  {
    text: "用心しないと今に胃弱になるかも知れない。",
  },
  {
    text: "主人は毎日学校へ行く。",
  },
  {
    text: "吾輩はとうとう雑煮を食わねばならぬ。",
    hint: "雑煮（ぞうに） / 食わねば: KuWaneba",
  },
  {
    text: "何だいその巨人引力と云うのは",
    hint: "云う（いう）",
  },
  {
    text: "「巨人が地中に住む故に」と母が答える。",
    hint: "故（ゆえ） / 「  」 が入力できない場合は下の説明を参照してください",
  },
  {
    text: "彼は巨人引力である。",
  },
  {
    text: "あれは巨人引力が呼ぶのである。",
  },
  {
    text: "せんだってトチメンボーを御馳走した時にね。",
    hint: "御馳走（ごちそう）",
  },
  {
    text: "やはりゼームス教授の材料になるね。",
  },
].map { |entry|
  entry.merge({src: "夏目漱石『吾輩は猫である』"})
}

EXAMPLE_DATA_MISC = [
  # --------------------------------
  # https://www.aozora.gr.jp/cards/000081/card48222.html

  {
    text: "カムパネルラが手をあげました。",
    src: "宮沢賢治『銀河鉄道の夜』",
  },
  {
    text: "ぼくは立派な機関車だ。",
    src: "宮沢賢治『銀河鉄道の夜』",
  },
  {
    text: "ここは勾配だから速いぞ。",
    hint: "勾配（こうばい）",
    src: "宮沢賢治『銀河鉄道の夜』",
  },

  # --------------------------------
  # https://www.aozora.gr.jp/cards/001872/card57501.html

  {
    text: "へんなことだが、ほんとうである。",
    src: "大下宇陀児『乱歩分析』",
  },
  {
    text: "乱歩は大きな鬼なのだろう。",
    src: "大下宇陀児『乱歩分析』",
    memo: "乱歩（らんぽ）",
  },
  {
    text: "明智小五郎は、お洒落だった。",
    hint: "智（ち） / 小五郎（こごろう） / お洒落（おしゃれ）",
    src: "大下宇陀児『乱歩分析』",
  },
  {
    text: "昔は、主として和服だった。",
    src: "大下宇陀児『乱歩分析』",
    # memo: "",
  },

  # --------------------------------

  # https://www.aozora.gr.jp/cards/001475/card51065.html
  {
    text: "なるほど、私の姿は変わりました。",
    src: "小川未明『紅すずめ』",
    # memo: "",
  },
  {
    text: "すずめは、二度びっくりしました。",
    src: "小川未明『紅すずめ』",
    # memo: "",
  },

  # --------------------------------
  # https://www.aozora.gr.jp/cards/000081/card1058.html

  {
    text: "いまやそこらはalcohol瓶のなかのけしき",
    src: "宮沢賢治『春と修羅』",
  },
  {
    text: "恐るべくかなしむべき真空溶媒は",
    hint: "恐るべく: OsoRubeku / 溶媒（ようばい）",
    src: "宮沢賢治『春と修羅』",
  },
  {
    text: "はんぶん溶けたり澱んだり",
    hint: "溶けたり: ToKetari / 澱んだり: YodoNdari",
    src: "宮沢賢治『春と修羅』",
  },

  # --------------------------------

  {
    text: "かな漢字変換",
    # hint: "kana Kanji SPC C-j Henkan SPC C-j",
  },
  {
    text: "ラムダ計算",
  },
  {
    text: "継承よりコンポジションを選ぶ",
    # hint: "Keisyou SPC yori Konpojisyon SPC wo EraBu C-j",
    hint: "選ぶ: EraBu",
    # memo: "選ぶ: EraBu",
    src: "Joshua Bloch『Effective Java 第3版』",
  },
  {
    text: "早すぎる最適化は諸悪の根源",
    hint: "早すぎる: HayaSugiru"
  },
  {
    text: "推測するな、計測せよ",
  },
  {
    text: "布団がふっとんだ",
  },
  {
    text: "Simple Kana to Kanji conversion program",
  },
  {
    # ascii + 漢字
    text: "UNIX哲学",
  },

  # https://www.aozora.gr.jp/cards/000879/card127.html
  {
    text: "一人の下人が、羅生門の下で雨やみを待っていた。",
    hint: "雨（あめ） / 待って: MaTte",
    src: "芥川竜之介『羅生門』",
  },

  # https://www.aozora.gr.jp/cards/000035/card1567.html
  {
    text: "けれども邪悪に対しては、人一倍に敏感であった。",
    src: "太宰治『走れメロス』",
  },

  # https://www.post.japanpost.jp/notification/pressrelease/2014/00_honsha/0703_01.html
  {
    text: "「レターパックで現金を送れ」は全て詐欺です。",
    hint: "全て（すべて） / 「  」 が入力できない場合は下の説明を参照してください",
    # memo: '"「", "」" は「かっこ」から変換'
    src: "日本郵便",
  },

  # https://www.sbcr.jp/product/4797399844/
  {
    text: "たのしいRuby",
    src: "高橋征義、後藤裕蔵『たのしいRuby 第6版』",
  },

  # https://gihyo.jp/book/2012/978-4-7741-4993-6
  {
    text: "日本語入力を支える技術",
    memo: "支える: SasaEru",
    src: "徳永拓之『日本語入力を支える技術』",
  },

  # https://www.oreilly.co.jp/books/9784873116976/
  {
    text: "アンダースタンディング コンピュテーション",
    hint: "ディ: dhi",
    src: "Tom Stuart『アンダースタンディング コンピュテーション』"
  },

  # https://www.ohmsha.co.jp/book/9784274065972/
  {
    text: "ハッカーと画家 コンピュータ時代の創造者たち",
    src: "Paul Graham『ハッカーと画家 コンピュータ時代の創造者たち』",
  },

  # https://www.oreilly.co.jp/books/9784873113944/
  {
    text: "プログラミング言語 Ruby",
    src: "David Flanagan, まつもと ゆきひろ『プログラミング言語 Ruby』",
  },

  # https://www.tsogen.co.jp/np/isbn/9784488612092
  {
    text: "ウは宇宙船のウ",
    src: "レイ・ブラッドベリ『ウは宇宙船のウ』",
  },

  {
    text: "テスト駆動開発",
  },
  {
    text: "低予算ゲーミングPC",
  },

  # https://www.aozora.gr.jp/cards/000074/card424.html
  {
    text: "というのはその店には珍しい檸檬が出ていたのだ。",
    hint: "檸檬（れもん）",
    src: "梶井基次郎『檸檬』",
  },

  # https://www.shoeisha.co.jp/book/detail/9784798135984
  {
    text: "計算機プログラムの構造と解釈",
    src: "Gerald Jay Sussman, Harold Abelson, Julie Sussman『計算機プログラムの構造と解釈』",
  },

  # https://www.ohmsha.co.jp/book/9784274226298/
  {
    text: "達人プログラマー 熟達に向けたあなたの旅",
    hint: "向けた: MuKeta",
    src: "David Thomas, Andrew Hunt『達人プログラマー』"
  },

  {
    text: "再帰的な辞書登録",
  },

  {
    text: "インド人を右に",
  },

  # ファウラー『リファクタリング』 / はじめに
  {
    text: "実装したあとで、設計を改善する",
    src: "Martin Fowler『リファクタリング』",
  },

  # p21
  {
    text: "これはビットが詰まったテープです",
    hint: "詰まった: TuMatta",
    src: "Don Libes, Sandy Ressler『Life is UNIX』",
  },
  # p109
  {
    text: "満月の夜には動作がおかしい",
    src: "Don Libes, Sandy Ressler『Life is UNIX』",
  },

  # https://bookplus.nikkei.com/atcl/catalog/24/02/06/01257/
  # p90
  {
    text: "リレーは素晴らしいデバイスである。",
    memo: "素晴らしい: SubaRasii",
    src: "Charles Petzold『CODE コードから見たコンピュータのからくり 第2版』",
  },

  # https://www.aozora.gr.jp/cards/000214/card1672.html
  {
    text: "花曇り、それが済んで、花を散らす風が吹く。",
    src: "田山花袋『新茶のかおり』",
  },

  # https://www.aozora.gr.jp/cards/001235/card49858.html
  {
    text: "「オドラデクだよ」と、それはいう。",
    hint: "「  」 が入力できない場合は下の説明を参照してください",
    src: "フランツ・カフカ『家長の心配』",
  },

  {
    text: "なんだ猫か",
  },

  {
    text: "is-aの関係",
  },
]

EXAMPLE_DATA = EXAMPLE_DATA_WAGAHAI + EXAMPLE_DATA_MISC

# EXAMPLE_DATA = [
# ]
