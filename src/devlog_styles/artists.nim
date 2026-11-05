## The twenty styles and the artists behind them: palettes, tile shapes, type, and the notes and gallery for each.
## Colours: g = six pastel letter tiles (for A I L P S T), ink = letter colour on them,
## w = three dark word colours (ITALIA, PASTA, ALPI), plus page ground, card and the two board tints.

type
  Shape* = enum
    shCircle, shRounded, shSquare, shBlob, shAlt, shArch, shOffset, shNested, shRings,
    shDashed, shOutlined, shShade, shTilt, shPebble
  Work* = object
    title*, year*, note*, motif*, url*: string  ## url: a page about the work; empty means an image search
  Link* = object
    label*, url*: string
  Style* = object
    id*, name*, life*, place*, flag*, role*: string
    g*: array[6, string]
    ink*: string
    w*: array[3, string]
    bg*, card*, ca*, cb*, boxline*, muted*: string
    shape*: Shape
    font*, weight*: string     ## glyph font (Google Fonts family) and weight
    outline*: string           ## tile outline colour, "" for none
    deco*: string              ## extra CSS for the play area background, may be ""
    rough*: bool               ## hand-made edges (SVG turbulence filter)
    who*, took*, why*: string
    links*: seq[Link]
    works*: seq[Work]

func wiki*(page: string, lang = "en"): string = "https://" & lang & ".wikipedia.org/wiki/" & page

const styles* = [
  Style(id: "mari", name: "Enzo Mari", life: "1932–2020", place: "Novara and Milan", flag: "🇮🇹",
    role: "designer of objects, furniture and games",
    g: ["#f5b4a4", "#f6dc86", "#a7c8ea", "#b6dbae", "#e8c39c", "#cfbde8"], ink: "#1f1f1f",
    w: ["#c4321c", "#1d4d9a", "#2b6a37"],
    bg: "#f3ebdd", card: "#fbf6ec", ca: "#fbf6ec", cb: "#efe5d2", boxline: "#1f1f1f", muted: "#6c6252",
    shape: shSquare, font: "Archivo", weight: "800", outline: "#1f1f1f",
    who: "Enzo Mari believed a designed object should teach you something while you use it. He drew chairs anyone " &
      "could build with a saw and nails, calendars, vases, and many games for children. His most famous puzzle, " &
      "<i>16 animali</i> (1957, for Danese), is a single slab of wood cut into sixteen animals that lock together " &
      "with no gaps. With Iela Mari he also made wordless picture books such as <i>La mela e la farfalla</i>.",
    took: "A puzzle whose pieces fit with nothing left over is exactly what a wordoku is. The tiles are square and cut " &
      "close, with a thin black outline like a jigsaw cut, on a birch-plywood ground. The colours are his toy primaries, " &
      "softened.",
    why: "Grown-ups know his work from design museums, and children just see animals and games.",
    links: @[Link(label: "Wikipedia", url: wiki("Enzo_Mari")),
             Link(label: "Wikipedia (it)", url: wiki("Enzo_Mari", "it")),
             Link(label: "Il gioco delle favole", url: wiki("Il_gioco_delle_favole", "it"))],
    works: @[Work(title: "16 animali", year: "1957", note: "one block of wood, sixteen animals, no gaps", motif: "jigsaw"),
             Work(title: "Il gioco delle favole", year: "1965", note: "cards that slot together into endless stories", motif: "slots",
                  url: wiki("Il_gioco_delle_favole", "it")),
             Work(title: "Timor calendar", year: "1966", note: "a perpetual calendar you flip by hand", motif: "slots"),
             Work(title: "Autoprogettazione", year: "1974", note: "furniture you build yourself from planks", motif: "planks")]),

  Style(id: "kusama", name: "Yayoi Kusama", life: "born 1929", place: "Matsumoto and Tokyo", flag: "🇯🇵",
    role: "painter, sculptor, installation artist",
    g: ["#ff9fc4", "#ffe27a", "#8fd0ff", "#a9e6a2", "#ffb98c", "#c7a9ff"], ink: "#1b1b1b",
    w: ["#c8001e", "#1b1b1b", "#0a4ea6"],
    bg: "#ffffff", card: "#ffffff", ca: "#ffffff", cb: "#ffffff", boxline: "#1b1b1b", muted: "#555555",
    shape: shCircle, font: "Lexend", weight: "700", outline: "",
    deco: "background-image:radial-gradient(circle at 12px 12px,#ffd6e6 4px,transparent 4.5px)," &
      "radial-gradient(circle at 34px 30px,#d9efff 3px,transparent 3.5px);background-size:46px 42px",
    who: "Yayoi Kusama has covered pumpkins, rooms, bodies and whole trees in polka dots for seventy years. " &
      "In <i>The Obliteration Room</i> (first shown in 2002) visitors, most of them children, walk into an all-white " &
      "apartment and are handed sheets of coloured dot stickers. A few weeks later the room has vanished under dots.",
    took: "The Obliteration Room is a white board that gets filled with coloured dots, which is a game of Parloku. " &
      "So the board is pure white, every tile is a perfect round sticker, and a few faint dots float in the background.",
    why: "It is the most child-led artwork I know. The finished room is made by children.",
    links: @[Link(label: "Wikipedia", url: wiki("Yayoi_Kusama")),
             Link(label: "Wikipedia (ja)", url: wiki("草間彌生", "ja"))],
    works: @[Work(title: "The Obliteration Room", year: "2002–", note: "a white room, thousands of dot stickers", motif: "dots"),
             Work(title: "Pumpkin", year: "1994", note: "the yellow pumpkin on the pier at Naoshima", motif: "pumpkin"),
             Work(title: "Infinity Mirror Room", year: "1965–", note: "lights repeated forever by mirrors", motif: "rings"),
             Work(title: "Ascension of Polka Dots on the Trees", year: "2006", note: "trees wrapped in red and white dots", motif: "net")]),

  Style(id: "dufy", name: "Raoul Dufy", life: "1877–1953", place: "Le Havre, Paris and Nice", flag: "🇫🇷",
    role: "painter, textile and ceramics designer",
    g: ["#a9d3f5", "#f7c3d3", "#fff09e", "#b6e3c6", "#c9b9f2", "#ffcea2"], ink: "#16337a",
    w: ["#1d4ab0", "#b02f39", "#0b6a4c"],
    bg: "#f7fbff", card: "#ffffff", ca: "#ffffff", cb: "#eef5fc", boxline: "#16337a", muted: "#4a5a7a",
    shape: shOffset, font: "Kalam", weight: "700", outline: "#16337a",
    who: "Raoul Dufy painted regattas, racecourses, orchestras and the seafront at Nice in a way that looks fast and " &
      "happy. He noticed that the eye catches colour before outline, so he let them separate: a patch of colour, then a " &
      "quick ink drawing that only half sits on it. He also designed fabrics for Bianchini-Férier and painted <i>La Fée " &
      "Électricité</i> (1937), one of the largest paintings in the world, now in the Musée d'Art Moderne de Paris.",
    took: "Colour and line slip apart. Each tile is a soft round patch of colour, and the letter's ink ring sits a little " &
      "off it, as if drawn in one quick stroke. The letters use a handwriting face, and everything is navy ink on a seaside white.",
    why: "It is how children colour in, with the colour going over the lines, and Dufy made it elegant.",
    links: @[Link(label: "Wikipedia", url: wiki("Raoul_Dufy")),
             Link(label: "Wikipedia (fr)", url: wiki("Raoul_Dufy", "fr"))],
    works: @[Work(title: "La Fée Électricité", year: "1937", note: "250 panels for the Paris Exposition", motif: "bands"),
             Work(title: "Street Decked with Flags", year: "1906", note: "a holiday street, all flags and colour", motif: "sails"),
             Work(title: "Thirty Years, or La Vie en Rose", year: "1931", note: "colour patches, quick lines on top", motif: "offset"),
             Work(title: "Fabrics for Bianchini-Férier", year: "1912–28", note: "flowers and shells printed on silk", motif: "flowers")]),

  Style(id: "albers", name: "Josef Albers", life: "1888–1976", place: "Bottrop, the Bauhaus, Black Mountain and Yale", flag: "🇩🇪",
    role: "painter and teacher of colour",
    g: ["#f6d37a", "#f3b283", "#e9a2a6", "#b6d3a6", "#a8c7e4", "#cdb6e1"], ink: "#2a2a2a",
    w: ["#8a3a1c", "#2c4a7e", "#4a6a22"],
    bg: "#efece4", card: "#f8f6f0", ca: "#f8f6f0", cb: "#eeeae0", boxline: "#2a2a2a", muted: "#5f5a50",
    shape: shNested, font: "Outfit", weight: "700", outline: "",
    who: "Josef Albers taught at the Bauhaus and then in America, and spent 26 years painting one idea: <i>Homage to the " &
      "Square</i>, three or four squares nested inside each other, a little lower than centre. He wanted to show that a " &
      "colour changes depending on its neighbours. His book <i>Interaction of Color</i> (1963) is still how designers learn colour.",
    took: "Every tile is a small Homage: a pastel square with a lighter square set low inside it, and the letter on the inner " &
      "square. The six colours were picked as one family, the way he would arrange them, with warm and cool alternating.",
    why: "It is the most careful study of colour there is, and it fits a game where colour is the main information.",
    links: @[Link(label: "Wikipedia", url: wiki("Josef_Albers")),
             Link(label: "Homage to the Square", url: wiki("Homage_to_the_Square"))],
    works: @[Work(title: "Homage to the Square", year: "1950–76", note: "over a thousand nested squares", motif: "nested", url: wiki("Homage_to_the_Square")),
             Work(title: "Interaction of Color", year: "1963", note: "the book: one colour looks like two", motif: "interaction"),
             Work(title: "Structural Constellations", year: "1950s", note: "line drawings that flip as you look", motif: "constellation"),
             Work(title: "Armchair", year: "Bauhaus years", note: "furniture from his Bauhaus workshop", motif: "grid")]),

  Style(id: "morandi", name: "Giorgio Morandi", life: "1890–1964", place: "Bologna", flag: "🇮🇹",
    role: "painter and printmaker",
    g: ["#efd8bd", "#d8c08a", "#b5c8b0", "#ddb0a2", "#b5c2d8", "#cdbdd8"], ink: "#43392f",
    w: ["#4e5f74", "#8a4637", "#5b6a2e"],
    bg: "#e9e2d4", card: "#f2ece0", ca: "#f2ece0", cb: "#e6ddcc", boxline: "#6b5f50", muted: "#6b5f50",
    shape: shRounded, font: "Fraunces", weight: "600", outline: "",
    who: "Giorgio Morandi hardly left Bologna and painted almost the same thing for forty years: a few bottles, jugs and " &
      "boxes on a table, in his studio on Via Fondazza. The colours are dusty: bone, putty, faded rose, grey-blue. He even " &
      "painted the bottles themselves so they would hold the light the way he wanted. The Museo Morandi in Bologna has his studio.",
    took: "Calm. Six powdery colours that are still easy to tell apart, soft rounded tiles with no outline, a warm grey ground, " &
      "and a serif for the letters. It is the one style here that asks you to slow down.",
    why: "A pastel palette for grown-ups. If the others are too loud, this is the answer.",
    links: @[Link(label: "Wikipedia", url: wiki("Giorgio_Morandi")),
             Link(label: "Wikipedia (it)", url: wiki("Giorgio_Morandi", "it"))],
    works: @[Work(title: "Natura morta", year: "1950s", note: "bottles and a jug, side by side", motif: "bottles"),
             Work(title: "Natura morta", year: "1960", note: "almost white on white", motif: "bottles2"),
             Work(title: "Grizzana landscapes", year: "1940s", note: "houses in the hills where he spent summers", motif: "houses"),
             Work(title: "Etchings", year: "1920s–50s", note: "the same objects, made of hatching", motif: "hatch")]),

  Style(id: "anno", name: "Mitsumasa Anno", life: "1926–2020", place: "Tsuwano", flag: "🇯🇵",
    role: "picture-book maker and maths lover",
    g: ["#f3c6bc", "#f4e0a8", "#c3debf", "#b8d1ea", "#e0cbe6", "#d7e7b0"], ink: "#38372f",
    w: ["#365878", "#8a462a", "#4c6a2c"],
    bg: "#fbf8f0", card: "#fffdf7", ca: "#fffdf7", cb: "#f4efe2", boxline: "#5a584c", muted: "#68665a",
    shape: shCircle, font: "M PLUS Rounded 1c", weight: "800", outline: "", rough: true,
    who: "Mitsumasa Anno was a school teacher before he made picture books, and you can tell. <i>Anno's Journey</i> " &
      "(1977) has no words, just a rider crossing a watercolour Europe full of hidden jokes. <i>Anno's Counting Book</i>, " &
      "<i>Anno's Magic Seeds</i> and <i>Anno's Mysterious Multiplying Jar</i> teach counting, doubling and factorials as " &
      "stories. He won the Hans Christian Andersen Award in 1984, and there is a museum for him in his home town of Tsuwano.",
    took: "Watercolour, and the joy of logic. The tiles are round washes with soft edges, the colours are thin and transparent, " &
      "and the ground is paper. The rounded type is the kind used in Japanese children's books.",
    why: "No one made maths friendlier for children, and Parloku is a logic game.",
    links: @[Link(label: "Wikipedia", url: wiki("Mitsumasa_Anno")),
             Link(label: "Wikipedia (ja)", url: wiki("安野光雅", "ja"))],
    works: @[Work(title: "Anno's Journey", year: "1977", note: "a wordless trip full of hidden stories", motif: "journey"),
             Work(title: "Anno's Counting Book", year: "1975", note: "a village grows from 0 to 12", motif: "counting"),
             Work(title: "Anno's Magic Seeds", year: "1992", note: "doubling, told as a farming tale", motif: "seeds"),
             Work(title: "Topsy-Turvies", year: "1968", note: "impossible buildings, like Escher for children", motif: "stairs")]),

  Style(id: "niki", name: "Niki de Saint Phalle", life: "1930–2002", place: "Paris, Tuscany and California", flag: "🇫🇷",
    role: "sculptor and garden builder",
    g: ["#ffb3c6", "#ffe066", "#8fd2ff", "#b5f0a0", "#ffb98a", "#d9b5ff"], ink: "#1e1e1e",
    w: ["#1b3f9e", "#c01c3a", "#0a7552"],
    bg: "#fff8ef", card: "#ffffff", ca: "#ffffff", cb: "#fff1e0", boxline: "#1e1e1e", muted: "#5b5348",
    shape: shBlob, font: "Baloo 2", weight: "800", outline: "#1e1e1e",
    who: "Niki de Saint Phalle made the <i>Nanas</i>, huge round dancing women in bright paint, and then spent twenty years " &
      "building the <i>Tarot Garden</i> (Giardino dei Tarocchi) at Capalbio in Tuscany: giant sculptures you can walk into, " &
      "covered in mirror and ceramic mosaic. With Jean Tinguely she made the Stravinsky Fountain next to the Centre Pompidou (1983).",
    took: "Plump, bulging shapes. The tiles are soft blobs that are never quite circles, with a black contour, in sweet " &
      "candy colours on cream, and the letters are round and heavy.",
    why: "Her garden is an adult's idea of a playground, and children run straight into it.",
    links: @[Link(label: "Wikipedia", url: wiki("Niki_de_Saint_Phalle")),
             Link(label: "Tarot Garden", url: wiki("Tarot_Garden")),
             Link(label: "Stravinsky Fountain", url: wiki("Stravinsky_Fountain"))],
    works: @[Work(title: "Giardino dei Tarocchi", year: "1979–98", note: "a sculpture garden near Capalbio", motif: "mosaic", url: wiki("Tarot_Garden")),
             Work(title: "Nanas", year: "1965–", note: "dancing figures in polyester and paint", motif: "blobs"),
             Work(title: "Stravinsky Fountain", year: "1983", note: "with Jean Tinguely, Paris", motif: "fountain", url: wiki("Stravinsky_Fountain")),
             Work(title: "Queen Califia's Magical Circle", year: "2003", note: "a garden in Escondido, California", motif: "snake")]),

  Style(id: "burlemarx", name: "Roberto Burle Marx", life: "1909–1994", place: "São Paulo and Rio de Janeiro", flag: "🇧🇷",
    role: "landscape architect and painter",
    g: ["#a6dfc6", "#ffd497", "#f6aeb7", "#b7cff5", "#dfc7f5", "#d6ee98"], ink: "#16302a",
    w: ["#0e6a4e", "#1c3b6a", "#b03a29"],
    bg: "#f4f8f2", card: "#ffffff", ca: "#ffffff", cb: "#eef5ec", boxline: "#16302a", muted: "#4d625a",
    shape: shPebble, font: "Comfortaa", weight: "700", outline: "",
    deco: "background-image:repeating-radial-gradient(ellipse at 50% 120%,transparent 0 18px,#e3eee2 18px 24px)",
    who: "Roberto Burle Marx painted with plants. He designed gardens as if they were abstract paintings, with sweeping " &
      "beds of a single species, and he collected and named dozens of Brazilian plants. His best known work is the wave " &
      "pavement along Copacabana beach (1970), four kilometres of black and white stone curves. His home, the Sítio Roberto " &
      "Burle Marx, is now a UNESCO World Heritage Site.",
    took: "Curves and gardens. Tiles are smooth pebbles, the ground carries faint wave bands like his pavements, the colours " &
      "are leaf, flower and sea, and the letters are a round geometric face.",
    why: "Our new tiles bud and divide like living cells, so a style about gardens fits them.",
    links: @[Link(label: "Wikipedia", url: wiki("Roberto_Burle_Marx")),
             Link(label: "Sítio Roberto Burle Marx", url: wiki("Sítio_Roberto_Burle_Marx")),
             Link(label: "Copacabana", url: wiki("Copacabana_Beach"))],
    works: @[Work(title: "Copacabana promenade", year: "1970", note: "black and white stone waves", motif: "waves", url: wiki("Copacabana_Beach")),
             Work(title: "Sítio Roberto Burle Marx", year: "1949–94", note: "his garden of 3,500 species", motif: "leaves", url: wiki("Sítio_Roberto_Burle_Marx")),
             Work(title: "Ministry of Education roof garden", year: "1938", note: "Rio: curving beds seen from above", motif: "beds"),
             Work(title: "Paintings and tapestries", year: "1960s–80s", note: "the gardens as abstract colour", motif: "blobs")]),

  Style(id: "depero", name: "Fortunato Depero", life: "1892–1960", place: "Rovereto", flag: "🇮🇹",
    role: "Futurist painter, toy maker, advertiser",
    g: ["#ffb2a0", "#ffe089", "#9fd2c6", "#b5c6ff", "#ffc5e2", "#d4eb98"], ink: "#1d1d1d",
    w: ["#1d1d1d", "#cf2318", "#16698a"],
    bg: "#fff6e8", card: "#fffdf8", ca: "#fffdf8", cb: "#f8ecd6", boxline: "#1d1d1d", muted: "#5d5446",
    shape: shAlt, font: "Bungee", weight: "400", outline: "#1d1d1d",
    who: "Fortunato Depero was a Futurist who wanted art to be fun. He built mechanical puppets for the <i>Balli plastici</i> " &
      "(1918), made wooden toys and patchwork tapestries, bound a book with two big bolts (<i>Depero futurista</i>, 1927) " &
      "and designed the cone-shaped Campari Soda bottle (1932), still on sale. His house in Rovereto, the Casa d'Arte " &
      "Futurista Depero, is a museum.",
    took: "Wooden toy geometry: cut-out shapes in black outline that alternate between circle and square by letter, " &
      "bold block capitals, and a black, a red and a blue for the words.",
    why: "He is the Italian artist who took toys and advertising seriously, and both are part of this game.",
    links: @[Link(label: "Wikipedia", url: wiki("Fortunato_Depero")),
             Link(label: "Casa d'Arte Futurista Depero", url: wiki("Casa_d%27arte_futurista_Depero", "it"))],
    works: @[Work(title: "Il nuovo teatro futurista", year: "1924", note: "poster for the Teatro Goldoni", motif: "puppets"),
             Work(title: "Depero futurista (the bolted book)", year: "1927", note: "held together by two bolts", motif: "bolts"),
             Work(title: "Campari Soda bottle", year: "1932", note: "a cone you can hold in your hand", motif: "cone"),
             Work(title: "Cavalli", year: "", note: "horses broken into Futurist planes", motif: "patch")]),

  Style(id: "tanaka", name: "Ikko Tanaka", life: "1930–2002", place: "Nara and Tokyo", flag: "🇯🇵",
    role: "graphic designer",
    g: ["#f6b5a5", "#f8e09a", "#a6d7cf", "#b8c1ea", "#f1c8df", "#c9e2a6"], ink: "#1c1c1c",
    w: ["#1c2a6a", "#bd3426", "#1c1c1c"],
    bg: "#f5f2ea", card: "#fbfaf6", ca: "#fbfaf6", cb: "#f0ece2", boxline: "#1c1c1c", muted: "#5c5850",
    shape: shSquare, font: "Jost", weight: "600", outline: "",
    who: "Ikko Tanaka joined Japanese tradition and the Swiss grid. His 1981 poster <i>Nihon Buyo</i> builds a dancer's " &
      "face out of a few flat squares, a circle and a triangle, and nothing more. He was also the first art director of " &
      "MUJI (from 1980) and gave the brand its quiet look.",
    took: "Flat geometry and silence. Square tiles with no outline and no shadow, six flat colours that could have been " &
      "cut from coloured paper, a geometric sans, and navy, vermilion and black for the words.",
    why: "It shows how far you can go with almost nothing, which is what Pietro asked for when he said less clutter.",
    links: @[Link(label: "Wikipedia", url: wiki("Ikko_Tanaka")),
             Link(label: "Wikipedia (ja)", url: wiki("田中一光", "ja")),
             Link(label: "MUJI", url: wiki("Muji"))],
    works: @[Work(title: "Nihon Buyo", year: "1981", note: "a face from four flat shapes", motif: "face"),
             Work(title: "MUJI", year: "1980–", note: "art direction for 'no-brand quality goods'", motif: "plain", url: wiki("Muji")),
             Work(title: "Posters for Noh theatre", year: "1950s–60s", note: "type, grid and colour blocks", motif: "blocks"),
             Work(title: "Typeface posters", year: "1980s–90s", note: "kanji and Latin letters as shapes", motif: "letters")]),

  Style(id: "gree", name: "Alain Grée", life: "1936–2025", place: "Paris and the open sea", flag: "🇫🇷",
    role: "illustrator of children's books",
    g: ["#f5c18a", "#a8d4c3", "#f3a89a", "#b8cae6", "#e5da9e", "#d8b7d5"], ink: "#2b2a28",
    w: ["#bf4a2a", "#1d6c77", "#2c3d6c"],
    bg: "#fbf2e2", card: "#fffaf0", ca: "#fffaf0", cb: "#f5e9d2", boxline: "#2b2a28", muted: "#6a5f4e",
    shape: shRounded, font: "Sniglet", weight: "800", outline: "",
    who: "Alain Grée drew French children's books in the 1960s and 70s, among them the <i>Cadet-Rama</i> series for " &
      "Casterman and the adventures of Achille et Bergamote. His pages are clean flat shapes, cars, boats and houses, in " &
      "mustard, teal, tomato and sky blue. He also designed a dozen educational games for Nathan, and spent much of his life on his sailing boat. His books have been reissued, and many of today's French illustrators name him as their main influence.",
    took: "Retro flat colour. Rounded tiles like printed stickers, the warm 1960s palette, a chunky rounded face, and cream " &
      "paper with a slight tint.",
    why: "Many parents grew up with books like these, so the style is nostalgic for them and fresh for their children.",
    links: @[Link(label: "Wikipedia", url: wiki("Alain_Grée")),
             Link(label: "Wikipedia (fr)", url: wiki("Alain_Grée", "fr"))],
    works: @[Work(title: "Cadet-Rama books", year: "1960s–70s", note: "Casterman's picture encyclopedias", motif: "cars"),
             Work(title: "Achille et Bergamote", year: "1960s", note: "two children and their adventures", motif: "boats"),
             Work(title: "Panoramas of town and sea", year: "1960s–70s", note: "busy flat scenes to explore", motif: "town"),
             Work(title: "Games for Fernand Nathan", year: "1960s–70s", note: "educational games, lotto and memory", motif: "alphabet")]),

  Style(id: "mahlangu", name: "Esther Mahlangu", life: "born 1935", place: "Mpumalanga, South Africa", flag: "🇿🇦",
    role: "Ndebele painter",
    g: ["#ffb2a6", "#ffe48a", "#9fc7f2", "#b6e3a2", "#e8b7f0", "#ffc799"], ink: "#151515",
    w: ["#151515", "#c0262c", "#1a5db2"],
    bg: "#ffffff", card: "#ffffff", ca: "#ffffff", cb: "#f6f6f6", boxline: "#151515", muted: "#4f4f4f",
    shape: shOutlined, font: "Archivo Black", weight: "400", outline: "#151515",
    who: "Esther Mahlangu learned Ndebele wall painting from her mother and grandmother as a girl: bold geometric shapes " &
      "with thick black outlines, painted freehand with a chicken-feather brush. Her work was shown in Paris at " &
      "<i>Magiciens de la Terre</i> (1989), and in 1991 she painted a BMW 525i, the first woman to make a BMW Art Car.",
    took: "The thick black contour, and white between the colours. Each tile is a square with a heavy black outline and a " &
      "white inner border, and the letters are the heaviest sans I could find.",
    why: "Of the twenty, this one is the easiest to read on a small phone in the sun.",
    links: @[Link(label: "Wikipedia", url: wiki("Esther_Mahlangu"))],
    works: @[Work(title: "BMW 525i Art Car", year: "1991", note: "a car painted freehand", motif: "ndebele"),
             Work(title: "Ndebele house murals", year: "1950s–", note: "the walls of her village", motif: "house"),
             Work(title: "Magiciens de la Terre", year: "1989", note: "a house painted at the Paris show", motif: "chevron"),
             Work(title: "Canvases", year: "1990s–", note: "the wall patterns on canvas", motif: "ndebele2")]),

  Style(id: "luzzati", name: "Emanuele Luzzati", life: "1921–2007", place: "Genoa", flag: "🇮🇹",
    role: "illustrator, animator, stage designer",
    g: ["#ffc1a6", "#ffe2a0", "#b7dfd1", "#f4b6cf", "#c8b6f0", "#cee5a4"], ink: "#2a1d2a",
    w: ["#781e4a", "#0e5d69", "#b2460e"],
    bg: "#fff3e0", card: "#fffaf2", ca: "#fffaf2", cb: "#fbe9cf", boxline: "#2a1d2a", muted: "#6a5650",
    shape: shRounded, font: "Caveat Brush", weight: "400", outline: "", rough: true,
    who: "Emanuele Luzzati made theatre sets, ceramics, picture books and, with Giulio Gianini, cut-paper animated films. " &
      "Two of them, <i>La gazza ladra</i> (1964) and <i>Pulcinella</i> (1973), were nominated for an Oscar. His paper " &
      "cut-outs are bright, jewel-like and a bit wobbly. Genoa has a museum for him at Porta Siberia, in the old port.",
    took: "Torn paper and the stage. The tiles have hand-cut edges (a small turbulence filter), the colours are warm jewels " &
      "softened to pastel, and the type is a brush letter. Plum, teal and burnt orange frame the words like a theatre curtain.",
    why: "He is the Italian illustrator most children of my generation met first, at the puppet theatre.",
    links: @[Link(label: "Wikipedia", url: wiki("Emanuele_Luzzati")),
             Link(label: "Wikipedia (it)", url: wiki("Emanuele_Luzzati", "it"))],
    works: @[Work(title: "La gazza ladra", year: "1964", note: "cut-paper film to Rossini, with Gianini", motif: "birds"),
             Work(title: "Pulcinella", year: "1973", note: "the mask, in a dream of paper", motif: "mask"),
             Work(title: "Il flauto magico", year: "1978", note: "film and stage sets for Mozart", motif: "stage"),
             Work(title: "Museo Luzzati", year: "", note: "his museum in Porta Siberia, Genoa", motif: "plate")]),

  Style(id: "afklint", name: "Hilma af Klint", life: "1862–1944", place: "Stockholm", flag: "🇸🇪",
    role: "painter",
    g: ["#f2b6c5", "#f4d5a0", "#c8b4e4", "#b6d5c0", "#f6e7a2", "#a7c3e0"], ink: "#2e2440",
    w: ["#3c2a6a", "#a23f2d", "#2b5b4c"],
    bg: "#f6eee2", card: "#fbf6ee", ca: "#fbf6ee", cb: "#f1e6d4", boxline: "#2e2440", muted: "#665a6a",
    shape: shRings, font: "EB Garamond", weight: "700", outline: "",
    who: "Hilma af Klint painted abstract pictures years before Kandinsky and Mondrian, and asked that they stay hidden " &
      "until twenty years after her death. <i>The Ten Largest</i> (1907) are three-metre canvases about childhood, youth, " &
      "adulthood and old age, full of pastel spirals, petals and letters. Her 2018 show at the Guggenheim broke the museum's " &
      "attendance record.",
    took: "Spirals and soft growth. Each tile has an inner ring, like a seed or a cell nucleus. The palette is her pinks, " &
      "lavenders and apricot, and the letters are an old serif in deep violet.",
    why: "<i>The Ten Largest</i> are pastel paintings about childhood. It is hard to find a better match.",
    links: @[Link(label: "Wikipedia", url: wiki("Hilma_af_Klint")),
             Link(label: "Wikipedia (sv)", url: wiki("Hilma_af_Klint", "sv"))],
    works: @[Work(title: "The Ten Largest", year: "1907", note: "childhood to old age, three metres tall", motif: "petals"),
             Work(title: "Primordial Chaos", year: "1906–07", note: "her first abstract series", motif: "spiral"),
             Work(title: "The Swan", year: "1914–15", note: "black and white becoming colour", motif: "swan"),
             Work(title: "Altarpieces", year: "1915", note: "triangles and suns in gold", motif: "altar")]),

  Style(id: "corita", name: "Corita Kent", life: "1918–1986", place: "Los Angeles and Boston", flag: "🇺🇸",
    role: "printmaker, teacher, nun",
    g: ["#ffafcf", "#fff07a", "#a6efcf", "#afd7ff", "#ffc78f", "#d7b7ff"], ink: "#1c1c1c",
    w: ["#c9124f", "#0d469e", "#1b5c1f"],
    bg: "#fffdf4", card: "#ffffff", ca: "#ffffff", cb: "#fff6e0", boxline: "#1c1c1c", muted: "#5a554a",
    shape: shTilt, font: "Shrikhand", weight: "400", outline: "",
    who: "Sister Corita Kent ran the art department of Immaculate Heart College in Los Angeles and made screen prints out of " &
      "words: song lyrics, ads and poems, cut up, enlarged and printed in fluorescent colours. Her <i>power up</i> (1965) " &
      "turns a petrol ad into a joyful poster. She painted the Rainbow Swash on a gas tank in Boston (1971), the largest " &
      "copyrighted artwork in the world, and the 1985 LOVE stamp.",
    took: "Words as pictures. Letters are big, juicy and a little tilted, on rounded tiles in bright, bubble-gum pastels. " &
      "It is the only style where the letters lead and the tiles follow.",
    why: "Parloku is a word game, and she is the artist who made words the most fun to look at.",
    links: @[Link(label: "Wikipedia", url: wiki("Corita_Kent")),
             Link(label: "Rainbow Swash", url: wiki("Rainbow_Swash"))],
    works: @[Work(title: "power up", year: "1965", note: "a petrol ad turned into joy", motif: "type"),
             Work(title: "Rainbow Swash", year: "1971", note: "a gas tank in Boston", motif: "swash", url: wiki("Rainbow_Swash")),
             Work(title: "LOVE stamp", year: "1985", note: "for the US Postal Service", motif: "stamp"),
             Work(title: "Rules for students and teachers", year: "1960s", note: "the classroom rules she shared", motif: "rules")]),

  Style(id: "memphis", name: "Ettore Sottsass and Memphis", life: "1917–2007", place: "Milan", flag: "🇮🇹",
    role: "architect and designer",
    g: ["#ffb4c7", "#9fe2df", "#ffe07a", "#c6b4ff", "#b6e78a", "#ffc29b"], ink: "#1a1a1a",
    w: ["#1a1a1a", "#b8175a", "#1a2f80"],
    bg: "#fbfbfb", card: "#ffffff", ca: "#ffffff", cb: "#f4f4f4", boxline: "#1a1a1a", muted: "#555555",
    shape: shArch, font: "Rubik", weight: "800", outline: "#1a1a1a",
    deco: "background-image:radial-gradient(#1a1a1a 1.2px,transparent 1.6px),radial-gradient(#1a1a1a 1.2px,transparent 1.6px);" &
      "background-size:28px 28px;background-position:0 0,14px 14px;background-color:#fbfbfb;opacity:1",
    who: "Ettore Sottsass designed the red <i>Valentine</i> typewriter for Olivetti (1969, with Perry King) and in 1981 " &
      "founded Memphis in Milan, a group that made furniture look like toys: the <i>Carlton</i> bookcase is a totem of " &
      "colour blocks, and the <i>Bacterio</i> laminate is covered in squiggly black specks. Memphis made design allowed to " &
      "be silly.",
    took: "Shapes that don't match on purpose. Tiles alternate between square and arch, all with a black outline, in " &
      "candy colours on a dotted white ground (a polite Bacterio). The words get black, magenta and deep blue.",
    why: "Children already draw like Memphis, and Milan design history makes it make sense for grown-ups.",
    links: @[Link(label: "Ettore Sottsass", url: wiki("Ettore_Sottsass")),
             Link(label: "Memphis Group", url: wiki("Memphis_Group"))],
    works: @[Work(title: "Carlton bookcase", year: "1981", note: "a totem of coloured shelves", motif: "carlton"),
             Work(title: "Valentine typewriter", year: "1969", note: "Olivetti, with Perry King: a red toy", motif: "valentine"),
             Work(title: "Bacterio laminate", year: "1978", note: "a pattern of tiny squiggles", motif: "squiggle"),
             Work(title: "Casablanca bookcase", year: "1981", note: "Memphis laminate with arms", motif: "totem")]),

  Style(id: "barragan", name: "Luis Barragán", life: "1902–1988", place: "Guadalajara and Mexico City", flag: "🇲🇽",
    role: "architect",
    g: ["#f7a7c7", "#ffd88a", "#c6b2f0", "#9fcff0", "#f4b58e", "#bee0ae"], ink: "#2a1a24",
    w: ["#a8155a", "#56298a", "#1c56a3"],
    bg: "#fbf1ea", card: "#fff9f5", ca: "#fff9f5", cb: "#f6e6dc", boxline: "#2a1a24", muted: "#6a5560",
    shape: shShade, font: "DM Serif Display", weight: "400", outline: "",
    who: "Luis Barragán built houses out of walls, water and colour. He painted walls Mexican pink, yellow and violet, and " &
      "let the sun move shadows across them all day. His own house in Mexico City (1948) is a UNESCO World Heritage Site, " &
      "the stables at Cuadra San Cristóbal (1968) have a pink wall rising out of a horse pool, and he won the Pritzker Prize in 1980.",
    took: "Light on coloured walls. Each tile is a flat square with a soft shadow falling on one side, as if lit by a low sun. " &
      "Pink, yellow and jacaranda violet lead, and the letters are a high-contrast serif.",
    why: "It is the warmest palette here, and the shadow tells you which tiles are on the board.",
    links: @[Link(label: "Wikipedia", url: wiki("Luis_Barragán")),
             Link(label: "Casa Luis Barragán", url: wiki("Luis_Barragán_House_and_Studio"))],
    works: @[Work(title: "Casa Luis Barragán", year: "1948", note: "his house and studio, Mexico City", motif: "walls", url: wiki("Luis_Barragán_House_and_Studio")),
             Work(title: "Cuadra San Cristóbal", year: "1968", note: "pink walls and a horse pool", motif: "pool"),
             Work(title: "Casa Gilardi", year: "1976", note: "a blue pool under a red wall", motif: "gilardi"),
             Work(title: "Torres de Satélite", year: "1958", note: "with Mathias Goeritz: coloured towers", motif: "towers")]),

  Style(id: "buscher", name: "Alma Siedhoff-Buscher", life: "1899–1944", place: "the Bauhaus, Weimar", flag: "🇩🇪",
    role: "toy and furniture designer",
    g: ["#f6a79f", "#ffe07a", "#9ec0ec", "#b4dea6", "#f6c38e", "#c8afe8"], ink: "#1d1d1d",
    w: ["#c22626", "#1c4e9e", "#2a7a30"],
    bg: "#f2f2ee", card: "#ffffff", ca: "#ffffff", cb: "#f2f2ee", boxline: "#1d1d1d", muted: "#55554f",
    shape: shAlt, font: "Unbounded", weight: "700", outline: "",
    who: "Alma Siedhoff-Buscher was one of the few women at the Bauhaus outside the weaving workshop. She designed the " &
      "children's room for the Haus am Horn (1923), toy cupboards on wheels, cut-out sheets, and the <i>Kleine " &
      "Schiffbauspiel</i> (1923), a set of 22 painted wooden blocks that make a ship, or anything else. It is still made " &
      "today, by Naef in Switzerland.",
    took: "Wooden blocks in primary colours. Tiles alternate between circle and square, flat and with no outline, like painted " &
      "blocks. The pastels keep her red, yellow and blue at the centre, and the words get the three primaries at full strength.",
    why: "She designed for children first, and that is the audience Pietro has in mind.",
    links: @[Link(label: "Wikipedia", url: wiki("Alma_Siedhoff-Buscher")),
             Link(label: "Wikipedia (de)", url: wiki("Alma_Siedhoff-Buscher", "de"))],
    works: @[Work(title: "Kleine Schiffbauspiel", year: "1923", note: "22 blocks that make a ship", motif: "ship"),
             Work(title: "Children's room, Haus am Horn", year: "1923", note: "furniture that turns into toys", motif: "room"),
             Work(title: "Toy cupboard", year: "1924", note: "boxes on wheels, a puppet stage inside", motif: "boxes"),
             Work(title: "Cut-out sheets", year: "1920s", note: "figures to cut and fold", motif: "cutout")]),

  Style(id: "martin", name: "Agnes Martin", life: "1912–2004", place: "Saskatchewan, New York and Taos", flag: "🇨🇦",
    role: "painter",
    g: ["#f4c6bd", "#f2e2ab", "#c4dfcc", "#c1d4ee", "#dccaee", "#f0d2b0"], ink: "#3a3633",
    w: ["#5f5954", "#386886", "#955247"],
    bg: "#f7f4ee", card: "#fbf9f5", ca: "#fbf9f5", cb: "#fbf9f5", boxline: "#8a847c", muted: "#6a645c",
    shape: shSquare, font: "Spectral", weight: "600", outline: "",
    deco: "background-image:repeating-linear-gradient(0deg,transparent 0 11px,#e7e1d6 11px 12px)",
    who: "Agnes Martin was born on a farm in Saskatchewan and painted grids and pale bands for fifty years: square canvases " &
      "ruled with pencil lines over the thinnest washes of pink, blue and yellow. She said her paintings were about innocence, " &
      "happiness and the joy of small children. Titles like <i>Friendship</i> (1963), <i>The Tree</i> (1964) and " &
      "<i>I Love the Whole World</i> (1999) say the rest.",
    took: "The grid itself, done gently. A pencil-ruled board, square tiles in the palest colours that still pass the " &
      "contrast check, and a quiet serif. It is the most minimal style here.",
    why: "She painted grids about happiness, and a wordoku is a grid that should make you happy.",
    links: @[Link(label: "Wikipedia", url: wiki("Agnes_Martin"))],
    works: @[Work(title: "Friendship", year: "1963", note: "gold leaf, incised grid (MoMA)", motif: "goldgrid"),
             Work(title: "The Tree", year: "1964", note: "a pencil grid on white", motif: "pencil"),
             Work(title: "Untitled bands", year: "1970s–90s", note: "pale pink and blue stripes", motif: "pale"),
             Work(title: "I Love the Whole World", year: "1999", note: "one of her last titles", motif: "pale2")]),

  Style(id: "shyam", name: "Bhajju Shyam", life: "born 1971", place: "Patangarh and Bhopal, India", flag: "🇮🇳",
    role: "Gond artist and illustrator",
    g: ["#f6b6a2", "#ffe08e", "#a6dbc7", "#b6c7f6", "#f1b7df", "#d3e79f"], ink: "#22140e",
    w: ["#86291b", "#0e586c", "#4a2978"],
    bg: "#fff6e8", card: "#fffbf3", ca: "#fffbf3", cb: "#fbeed8", boxline: "#22140e", muted: "#6a5546",
    shape: shDashed, font: "Yatra One", weight: "400", outline: "#22140e",
    who: "Bhajju Shyam paints in the Gond tradition of central India, where every shape is filled with patterns of dots, " &
      "dashes and fine lines. With Tara Books he made <i>The London Jungle Book</i> (2004), his visit to London drawn as a " &
      "forest of animals, and with Durga Bai and Ram Singh Urveti <i>The Night Life of Trees</i> (2006), screen-printed by hand. " &
      "He received the Padma Shri in 2018.",
    took: "Patterns inside shapes. Each round tile is filled with a ring of fine dashes in the letter's ink, and the letters " &
      "come from a Devanagari-inspired face.",
    why: "It is the most decorative style here, and it shows how far texture can go before it becomes clutter.",
    links: @[Link(label: "Wikipedia", url: wiki("Bhajju_Shyam"))],
    works: @[Work(title: "The London Jungle Book", year: "2004", note: "London as a Gond forest", motif: "gond"),
             Work(title: "The Night Life of Trees", year: "2006", note: "with Durga Bai and Ram Singh Urveti", motif: "tree"),
             Work(title: "Creation", year: "", note: "the Gond creation myth", motif: "gond2"),
             Work(title: "Signature birds and fish", year: "", note: "patterns of dots and dashes", motif: "fish")])
]
