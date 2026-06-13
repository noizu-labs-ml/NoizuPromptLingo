pub fn emoji_lookup(name: &str) -> Option<&'static str> {
    match name {
        // Build & Deploy
        "rocket" => Some("\u{1F680}"),
        "ship" => Some("\u{1F6A2}"),
        "package" => Some("\u{1F4E6}"),
        "construction" => Some("\u{1F6A7}"),
        "hammer" => Some("\u{1F528}"),
        "hammer-wrench" | "tools" | "build-tools" => Some("\u{1F6E0}"),
        "nut-bolt" | "hardware" | "fastener" => Some("\u{1F529}"),
        "bricks" | "blocks" | "wall" | "foundation" => Some("\u{1F9F1}"),
        "label" | "tag" | "version" | "release" => Some("\u{1F3F7}"),
        "factory" | "manufacture" | "industry" => Some("\u{1F3ED}"),

        // Status
        "check" | "done" => Some("\u{2705}"),
        "cross" | "fail" => Some("\u{274C}"),
        "warning" | "warn" => Some("\u{26A0}"),
        "stop" => Some("\u{1F6D1}"),
        "hourglass" | "wait" => Some("\u{23F3}"),
        "no-entry" | "forbidden" | "blocked" | "deny" => Some("\u{26D4}"),
        "prohibited" | "banned" | "no-sign" => Some("\u{1F6AB}"),
        "exclamation" | "important" | "bang-mark" => Some("\u{2757}"),
        "question-mark" | "help-mark" => Some("\u{2753}"),
        "infinity" | "forever" | "endless" => Some("\u{267E}"),

        // Activity & Dev
        "bug" => Some("\u{1F41B}"),
        "fire" => Some("\u{1F525}"),
        "test" | "lab" => Some("\u{1F9EA}"),
        "search" | "mag" => Some("\u{1F50D}"),
        "wrench" | "fix" => Some("\u{1F527}"),
        "gear" | "config" => Some("\u{2699}"),
        "lock" | "secure" => Some("\u{1F512}"),
        "key" => Some("\u{1F511}"),
        "trash" | "delete" | "wastebasket" | "garbage" | "rubbish" => Some("\u{1F5D1}"),
        "terminal" | "console" | "cli" | "prompt" | "shell" => Some("\u{1F5A5}"),
        "laptop" | "computer" | "pc" | "mac" => Some("\u{1F4BB}"),
        "keyboard" | "type" | "input" | "keys" => Some("\u{2328}"),
        "printer" | "print" => Some("\u{1F5A8}"),
        "disk" | "floppy" | "save" | "backup" => Some("\u{1F4BE}"),
        "cd" | "disc" | "dvd" | "optical" => Some("\u{1F4BF}"),
        "toolbox" | "toolkit" | "devtools" | "swiss-army" => Some("\u{1F9F0}"),
        "microscope" | "research" | "examine" => Some("\u{1F52C}"),
        "telescope" | "observe" | "astronomy" => Some("\u{1F52D}"),
        "crystal-ball" | "fortune" | "predict" => Some("\u{1F52E}"),
        "magnet" | "attract" | "pull" => Some("\u{1F9F2}"),
        "dna" | "genetics" | "helix" | "genome" => Some("\u{1F9EC}"),
        "petri-dish" | "culture" | "grow" | "incubate" => Some("\u{1F9EB}"),
        "abacus" | "count" | "tally" | "legacy" => Some("\u{1F9EE}"),
        "atom" | "physics" | "science-symbol" => Some("\u{269B}"),
        "hook" | "webhook" | "callback" | "trigger" => Some("\u{1FA9D}"),
        "chains" | "linked" | "blockchain" | "connection" => Some("\u{26D3}"),
        "plug" | "electric-plug" | "outlet" | "socket" => Some("\u{1F50C}"),
        "battery" | "power" | "charge" | "energy" => Some("\u{1F50B}"),
        "broom" | "cleanup" | "sweep" | "tidy" => Some("\u{1F9F9}"),
        "sponge" | "wipe" | "scrub" | "absorb" => Some("\u{1F9FD}"),
        "fire-extinguisher" | "suppress" | "douse" => Some("\u{1F9EF}"),
        "plunger" | "unclog" | "unstick" | "fix-pipe" => Some("\u{1FAA0}"),
        "mousetrap" | "catch-bug" | "snare" => Some("\u{1FAA4}"),
        "ladder" | "climb-up" | "elevate" => Some("\u{1FA9C}"),
        "knot" | "tied" | "tangled" | "complex" => Some("\u{1FAA2}"),
        "bucket" | "pail" | "container" => Some("\u{1FAA3}"),

        // Communication & Review
        "eyes" | "review" => Some("\u{1F440}"),
        "chat" | "discuss" | "speech" => Some("\u{1F4AC}"),
        "mail" | "email" => Some("\u{1F4E7}"),
        "bell" | "alert" => Some("\u{1F514}"),
        "phone" | "call" | "mobile" | "cell" => Some("\u{1F4F1}"),
        "envelope" | "letter" | "mail-env" => Some("\u{2709}"),
        "inbox" | "tray" | "incoming" => Some("\u{1F4E5}"),
        "outbox" | "send" | "outgoing" => Some("\u{1F4E4}"),
        "mailbox" | "letterbox" | "post" => Some("\u{1F4EC}"),
        "radio" | "broadcast" | "fm" | "am" => Some("\u{1F4FB}"),
        "satellite-dish" | "signal" | "antenna" | "receive" => Some("\u{1F4E1}"),
        "newspaper" | "news" | "press" | "media" => Some("\u{1F4F0}"),
        "thought" | "thought-bubble" => Some("\u{1F4AD}"),

        // Data & Infra
        "db" | "database" | "file-cabinet" | "archive" | "storage" | "vault" => {
            Some("\u{1F5C4}")
        }
        "cloud" => Some("\u{2601}"),
        "link" => Some("\u{1F517}"),
        "electric" | "zap" => Some("\u{26A1}"),
        "globe-web" | "www" | "internet" | "web" | "network" => Some("\u{1F310}"),
        "satellite" | "orbit" | "space" => Some("\u{1F6F0}"),
        "earth" | "globe" | "world" => Some("\u{1F30D}"),
        "compass" | "direction" | "navigate" => Some("\u{1F9ED}"),
        "folder" | "directory" | "dir" => Some("\u{1F4C1}"),
        "folder-open" | "browse" | "explore" => Some("\u{1F4C2}"),
        "page" | "document" | "doc" => Some("\u{1F4C4}"),
        "scroll" | "parchment" | "ancient" => Some("\u{1F4DC}"),

        // Progress & Time
        "sparkle" | "clean" => Some("\u{2728}"),
        "star" => Some("\u{2B50}"),
        "coffee" | "break" => Some("\u{2615}"),
        "sleep" | "zzz" => Some("\u{1F4A4}"),
        "brain" | "think" => Some("\u{1F9E0}"),
        "books" | "docs" => Some("\u{1F4DA}"),
        "pin" => Some("\u{1F4CC}"),
        "clipboard" => Some("\u{1F4CB}"),
        "chart" => Some("\u{1F4CA}"),
        "chart-up" | "trending" | "growth" | "stonks" => Some("\u{1F4C8}"),
        "chart-down" | "decline" | "loss" | "crash-chart" => Some("\u{1F4C9}"),
        "alarm" | "timer" | "clock-alarm" => Some("\u{23F0}"),
        "watch" | "time" | "clock-watch" => Some("\u{231A}"),
        "calendar" | "date" | "event" | "schedule" => Some("\u{1F4C5}"),
        "target" | "bullseye" | "goal" | "aim" => Some("\u{1F3AF}"),

        // Celebration & Misc
        "tada" | "celebrate" => Some("\u{1F389}"),
        "art" | "design" => Some("\u{1F3A8}"),
        "bulb" | "idea" => Some("\u{1F4A1}"),
        "shield" | "protect" => Some("\u{1F6E1}"),
        "recycle" | "refactor" => Some("\u{267B}"),
        "truck" | "move" => Some("\u{1F69A}"),
        "memo" | "note" => Some("\u{1F4DD}"),
        "gift" | "present" | "surprise" | "wrapped" => Some("\u{1F381}"),
        "balloon" | "party-balloon" | "inflate" => Some("\u{1F388}"),
        "confetti" | "celebration" | "festive" => Some("\u{1F38A}"),
        "trophy" | "winner" | "champion" | "cup" => Some("\u{1F3C6}"),
        "medal" | "award" | "prize" | "gold" => Some("\u{1F3C5}"),
        "ticket" | "pass" | "admission" | "entry" => Some("\u{1F3AB}"),
        "crown" | "king" | "queen" | "royal" => Some("\u{1F451}"),
        "gem" | "diamond" | "jewel" | "precious" => Some("\u{1F48E}"),
        "hundred" | "100" | "perfect" | "score" => Some("\u{1F4AF}"),
        "boom" | "explosion" | "bang" | "collision" | "crash" => Some("\u{1F4A5}"),
        "flashlight" | "torch" | "light" => Some("\u{1F526}"),
        "candle" | "flame" | "wax" => Some("\u{1F56F}"),
        "door" | "entrance" | "exit" | "gateway" => Some("\u{1F6AA}"),
        "window-pane" | "viewport" => Some("\u{1FA9F}"),
        "magician" | "wizard" | "wand" => Some("\u{1FA84}"),
        "mirror-ball" | "disco" | "dance" => Some("\u{1FAA9}"),
        "joker" | "wildcard" | "trump" => Some("\u{1F0CF}"),

        // Smileys
        "smile" | "happy" => Some("\u{1F60A}"),
        "grin" => Some("\u{1F601}"),
        "laugh" | "lol" => Some("\u{1F602}"),
        "rofl" => Some("\u{1F923}"),
        "wink" => Some("\u{1F609}"),
        "love-eyes" | "heart-eyes" => Some("\u{1F60D}"),
        "cool" | "sunglasses" => Some("\u{1F60E}"),
        "hmm" | "wondering" => Some("\u{1F914}"),
        "shush" | "quiet" => Some("\u{1F92B}"),
        "sweat" => Some("\u{1F605}"),
        "cry" | "sob" => Some("\u{1F622}"),
        "angry" | "mad" => Some("\u{1F620}"),
        "rage" | "fury" => Some("\u{1F621}"),
        "scream" | "horror" => Some("\u{1F631}"),
        "sick" | "nausea" => Some("\u{1F922}"),
        "dizzy-face" => Some("\u{1F635}"),
        "nerd" => Some("\u{1F913}"),
        "monocle" | "inspect" => Some("\u{1F9D0}"),
        "party-face" | "celebrate-face" => Some("\u{1F973}"),
        "yawn" | "tired" => Some("\u{1F971}"),
        "melting" | "melt" | "dissolve" | "hot-face" => Some("\u{1FAE0}"),
        "peeking" | "peek" | "spy-face" | "sneak" => Some("\u{1FAE3}"),

        // Gestures
        "wave" | "hi" | "bye" => Some("\u{1F44B}"),
        "ok" | "okay" => Some("\u{1F44C}"),
        "thumbsup" | "like" | "approve" => Some("\u{1F44D}"),
        "thumbsdown" | "dislike" | "reject" => Some("\u{1F44E}"),
        "clap" | "applause" => Some("\u{1F44F}"),
        "pray" | "thanks" | "namaste" => Some("\u{1F64F}"),
        "muscle" | "strong" | "flex" => Some("\u{1F4AA}"),
        "fist" | "punch" | "bump" => Some("\u{1F44A}"),
        "victory" | "peace-sign" => Some("\u{270C}"),
        "crossed-fingers" | "luck" => Some("\u{1F91E}"),
        "handshake" | "deal" | "agree" => Some("\u{1F91D}"),
        "point-right" => Some("\u{1F449}"),
        "point-left" => Some("\u{1F448}"),
        "point-up" => Some("\u{261D}"),
        "point-down" => Some("\u{1F447}"),
        "raised-hand" | "stop-hand" | "halt" => Some("\u{270B}"),
        "salute" => Some("\u{1FAE1}"),

        // People & Characters
        "skull" | "dead" | "rip" => Some("\u{1F480}"),
        "ghost" => Some("\u{1F47B}"),
        "robot" | "bot" => Some("\u{1F916}"),
        "alien" => Some("\u{1F47D}"),
        "clown" => Some("\u{1F921}"),
        "poop" | "crap" => Some("\u{1F4A9}"),
        "ninja" => Some("\u{1F977}"),
        "detective" | "spy" => Some("\u{1F575}"),

        // Hearts
        "heart" | "love-heart" | "red-heart" => Some("\u{2764}"),
        "broken-heart" | "heartbreak" => Some("\u{1F494}"),
        "sparkling-heart" | "glowing-heart" => Some("\u{1F496}"),
        "sweat-drops" | "effort" | "splash" => Some("\u{1F4A6}"),
        "anger-symbol" | "fury-mark" => Some("\u{1F4A2}"),
        "droplet" | "water" | "drip" => Some("\u{1F4A7}"),

        // Animals
        "dog" | "puppy" => Some("\u{1F436}"),
        "cat" | "kitty" => Some("\u{1F431}"),
        "fox" => Some("\u{1F98A}"),
        "bear" => Some("\u{1F43B}"),
        "panda" => Some("\u{1F43C}"),
        "monkey" => Some("\u{1F435}"),
        "chicken" | "hen" => Some("\u{1F414}"),
        "penguin" => Some("\u{1F427}"),
        "bird" | "tweet" => Some("\u{1F426}"),
        "eagle" => Some("\u{1F985}"),
        "owl" => Some("\u{1F989}"),
        "bat" => Some("\u{1F987}"),
        "butterfly" => Some("\u{1F98B}"),
        "snake" => Some("\u{1F40D}"),
        "dragon" => Some("\u{1F409}"),
        "whale" => Some("\u{1F433}"),
        "dolphin" => Some("\u{1F42C}"),
        "octopus" => Some("\u{1F419}"),
        "snail" | "slow" => Some("\u{1F40C}"),
        "turtle" | "tortoise" => Some("\u{1F422}"),
        "crab" | "crustacean" => Some("\u{1F980}"),
        "spider" => Some("\u{1F577}"),
        "scorpion" => Some("\u{1F982}"),
        "unicorn" | "magic" => Some("\u{1F984}"),
        "bee" | "honeybee" | "buzz" => Some("\u{1F41D}"),
        "ant" => Some("\u{1F41C}"),
        "ladybug" => Some("\u{1F41E}"),
        "shark" => Some("\u{1F988}"),
        "wolf" => Some("\u{1F43A}"),
        "horse" | "pony" => Some("\u{1F434}"),
        "pig" | "oink" => Some("\u{1F437}"),
        "frog" | "toad" => Some("\u{1F438}"),
        "gorilla" | "ape" => Some("\u{1F98D}"),
        "deer" | "stag" => Some("\u{1F98C}"),
        "rabbit" | "bunny" => Some("\u{1F430}"),
        "mouse" | "rodent" => Some("\u{1F42D}"),
        "camel" => Some("\u{1F42B}"),
        "elephant" => Some("\u{1F418}"),
        "lion" => Some("\u{1F981}"),
        "tiger" => Some("\u{1F42F}"),
        "crocodile" | "croc" | "gator" => Some("\u{1F40A}"),
        "parrot" => Some("\u{1F99C}"),
        "flamingo" => Some("\u{1F9A9}"),
        "peacock" => Some("\u{1F99A}"),
        "lobster" => Some("\u{1F99E}"),
        "shrimp" | "prawn" => Some("\u{1F990}"),
        "squid" => Some("\u{1F991}"),
        "hedgehog" | "porcupine" => Some("\u{1F994}"),
        "raccoon" | "trash-panda" => Some("\u{1F99D}"),
        "sloth" | "lazy" => Some("\u{1F9A5}"),
        "otter" => Some("\u{1F9A6}"),
        "skunk" | "stink" => Some("\u{1F9A8}"),
        "mammoth" | "woolly" => Some("\u{1F9A3}"),
        "dodo" | "extinct" => Some("\u{1F9A4}"),
        "microbe" | "germ" | "bacteria" => Some("\u{1F9A0}"),

        // Nature & Weather
        "tree" | "evergreen" => Some("\u{1F332}"),
        "palm-tree" | "tropical" => Some("\u{1F334}"),
        "flower" | "blossom" => Some("\u{1F338}"),
        "rose" => Some("\u{1F339}"),
        "sunflower" => Some("\u{1F33B}"),
        "leaf" | "leaves" | "wind-leaf" => Some("\u{1F343}"),
        "herb" | "plant" | "seedling" => Some("\u{1F33F}"),
        "mushroom" | "fungi" | "toadstool" => Some("\u{1F344}"),
        "cactus" => Some("\u{1F335}"),
        "sun" | "sunny" => Some("\u{2600}"),
        "moon" | "crescent" => Some("\u{1F319}"),
        "full-moon" => Some("\u{1F315}"),
        "rainbow" => Some("\u{1F308}"),
        "snowflake" | "frozen" | "cold" => Some("\u{2744}"),
        "tornado" | "cyclone" | "twister" => Some("\u{1F32A}"),
        "ocean" | "waves" | "sea" => Some("\u{1F30A}"),
        "volcano" | "eruption" | "lava" => Some("\u{1F30B}"),
        "comet" | "meteor" | "shooting-star" => Some("\u{2604}"),
        "umbrella" | "rain-cover" => Some("\u{2602}"),
        "lotus" | "zen" | "mindful" | "calm" => Some("\u{1FAB7}"),
        "feather" | "lightweight" | "quill" => Some("\u{1FAB6}"),
        "coral" | "reef" | "marine" => Some("\u{1FAB8}"),
        "nest" | "nested" | "home-base" => Some("\u{1FAB9}"),

        // Food & Drink
        "apple" | "fruit" => Some("\u{1F34E}"),
        "banana" => Some("\u{1F34C}"),
        "grapes" | "vine" => Some("\u{1F347}"),
        "watermelon" | "melon" => Some("\u{1F349}"),
        "lemon" | "citrus" | "sour" => Some("\u{1F34B}"),
        "peach" => Some("\u{1F351}"),
        "cherry" | "cherries" => Some("\u{1F352}"),
        "strawberry" => Some("\u{1F353}"),
        "tomato" => Some("\u{1F345}"),
        "avocado" => Some("\u{1F951}"),
        "eggplant" | "aubergine" => Some("\u{1F346}"),
        "pepper" | "hot" | "spicy" | "chili" => Some("\u{1F336}"),
        "pizza" | "pie" => Some("\u{1F355}"),
        "burger" | "hamburger" => Some("\u{1F354}"),
        "fries" | "chips" | "french-fries" => Some("\u{1F35F}"),
        "hotdog" | "sausage" | "frank" => Some("\u{1F32D}"),
        "taco" => Some("\u{1F32E}"),
        "burrito" | "wrap" => Some("\u{1F32F}"),
        "sushi" | "japanese" => Some("\u{1F363}"),
        "ramen" | "noodles" | "soup" => Some("\u{1F35C}"),
        "cake" | "birthday" | "bday" => Some("\u{1F382}"),
        "cookie" | "biscuit" => Some("\u{1F36A}"),
        "chocolate" | "candy-bar" => Some("\u{1F36B}"),
        "donut" | "doughnut" | "pastry" => Some("\u{1F369}"),
        "ice-cream" | "icecream" | "gelato" => Some("\u{1F368}"),
        "honey" | "honeypot" | "sweet" => Some("\u{1F36F}"),
        "beer" | "brew" | "pint" => Some("\u{1F37A}"),
        "wine" | "glass" | "vino" => Some("\u{1F377}"),
        "cocktail" | "martini" | "drink" => Some("\u{1F378}"),
        "popcorn" => Some("\u{1F37F}"),
        "bread" | "loaf" | "toast" => Some("\u{1F35E}"),
        "cheese" | "cheddar" => Some("\u{1F9C0}"),
        "meat" | "steak" | "beef" => Some("\u{1F969}"),
        "bacon" | "pork" => Some("\u{1F953}"),
        "candy" | "lollipop" | "sweet-treat" => Some("\u{1F36C}"),
        "cupcake" | "muffin" => Some("\u{1F9C1}"),
        "salt" | "seasoning" => Some("\u{1F9C2}"),
        "beans" | "coffee-beans" | "java" => Some("\u{1FAD8}"),
        "jar" | "preserve" | "store" => Some("\u{1FAD9}"),

        // Transport
        "car" | "auto" | "drive" | "vehicle" => Some("\u{1F697}"),
        "taxi" | "cab" => Some("\u{1F695}"),
        "bus" | "transit" => Some("\u{1F68C}"),
        "ambulance" | "ems" | "emergency" => Some("\u{1F691}"),
        "fire-truck" | "firetruck" => Some("\u{1F692}"),
        "police-car" | "cop" | "patrol" => Some("\u{1F693}"),
        "train" | "rail" | "locomotive" => Some("\u{1F686}"),
        "airplane" | "plane" | "flight" | "jet" => Some("\u{2708}"),
        "helicopter" | "chopper" | "heli" => Some("\u{1F681}"),
        "sailboat" | "boat" | "sailing" => Some("\u{26F5}"),
        "anchor" | "dock" | "port" => Some("\u{2693}"),
        "fuel" | "gas" | "petrol" | "pump" => Some("\u{26FD}"),
        "bike" | "bicycle" => Some("\u{1F6B2}"),

        // Places
        "house" | "home" => Some("\u{1F3E0}"),
        "office" | "building" | "corp" => Some("\u{1F3E2}"),
        "hospital" | "medical" | "health-bldg" => Some("\u{1F3E5}"),
        "school" | "education" | "learn" => Some("\u{1F3EB}"),
        "castle" | "fortress" | "fort" => Some("\u{1F3F0}"),
        "tent" | "camp" | "camping" | "outdoor" => Some("\u{26FA}"),
        "church" | "worship" | "chapel" => Some("\u{26EA}"),

        // Writing & Office
        "book" | "read" | "manual" | "textbook" => Some("\u{1F4D6}"),
        "notebook" | "journal" | "diary" => Some("\u{1F4D3}"),
        "pencil" | "write" | "edit" | "compose" => Some("\u{270F}"),
        "pen" | "author" | "ink" => Some("\u{1F58A}"),
        "paintbrush" | "paint" | "brush" => Some("\u{1F58C}"),
        "crayon" | "draw" | "sketch" | "color" => Some("\u{1F58D}"),
        "paperclip" | "attach" | "attachment" => Some("\u{1F4CE}"),
        "scissors" | "cut" | "snip" | "trim" => Some("\u{2702}"),
        "ruler" | "measure" | "length" => Some("\u{1F4CF}"),
        "camera" | "photo" | "snap" | "picture" => Some("\u{1F4F7}"),
        "clapper" | "film" | "movie" | "action" => Some("\u{1F3AC}"),
        "tv" | "television" | "screen" | "monitor" => Some("\u{1F4FA}"),

        // Music
        "music" | "song" | "tune" | "melody" => Some("\u{1F3B5}"),
        "guitar" | "rock" | "strum" => Some("\u{1F3B8}"),
        "drum" | "beat" | "rhythm" => Some("\u{1F941}"),
        "trumpet" | "horn" | "fanfare" | "brass" => Some("\u{1F3BA}"),
        "microphone" | "mic" | "karaoke" | "sing" => Some("\u{1F3A4}"),
        "headphones" | "audio" | "listen" | "earphones" => Some("\u{1F3A7}"),
        "speaker" | "volume" | "sound" | "loud" => Some("\u{1F50A}"),
        "mute" | "silent" | "no-sound" | "quiet-speaker" => Some("\u{1F507}"),

        // Sports
        "soccer" | "football" | "kick" => Some("\u{26BD}"),
        "basketball" | "bball" | "hoop" => Some("\u{1F3C0}"),
        "baseball" | "bat-ball" => Some("\u{26BE}"),
        "tennis" | "racket" | "serve" => Some("\u{1F3BE}"),
        "golf" | "putt" | "tee" => Some("\u{26F3}"),
        "boxing" | "fight-glove" | "bout" => Some("\u{1F94A}"),
        "bowling" | "strike" | "pins" => Some("\u{1F3B3}"),
        "gaming" | "joystick" | "game" | "play" => Some("\u{1F3AE}"),
        "puzzle" | "jigsaw" | "piece" | "solve" | "component" | "module" => Some("\u{1F9E9}"),
        "chess" | "strategy" | "checkmate" => Some("\u{265F}"),
        "dice" | "random" | "chance" | "roll" => Some("\u{1F3B2}"),
        "fishing" | "catch" | "rod" => Some("\u{1F3A3}"),
        "surfing" | "surf" | "wave-ride" => Some("\u{1F3C4}"),
        "swimming" | "swim" | "pool" | "lap" => Some("\u{1F3CA}"),
        "running" | "run" | "sprint" | "jog" => Some("\u{1F3C3}"),
        "eight-ball" | "billiards" => Some("\u{1F3B1}"),
        "slot-machine" | "jackpot" | "gamble" => Some("\u{1F3B0}"),
        "mahjong" | "tile" => Some("\u{1F004}"),

        // Combat
        "bomb" | "explosive" | "detonate" => Some("\u{1F4A3}"),
        "sword" | "fight" | "blade" => Some("\u{2694}"),
        "axe" | "chop" | "hatchet" => Some("\u{1FA93}"),
        "radioactive" | "nuclear" | "hazard" => Some("\u{2622}"),
        "biohazard" | "toxic" | "danger" => Some("\u{2623}"),

        // Arrows & Shapes
        "arrow-up" | "ascending" | "upward" => Some("\u{2B06}"),
        "arrow-down" | "descending" | "downward" => Some("\u{2B07}"),
        "arrow-left" | "back" | "backward" => Some("\u{2B05}"),
        "arrow-right" | "forward" | "next" | "ahead" => Some("\u{27A1}"),
        "arrows-rotate" | "sync" | "refresh" | "reload" => Some("\u{1F504}"),
        "cycle" | "repeat" | "loop-arrows" | "redo" => Some("\u{1F503}"),
        "plus" | "add" | "new" | "create" => Some("\u{2795}"),
        "minus" | "subtract" | "remove" | "delete-sign" => Some("\u{2796}"),
        "multiply" | "times" | "x-mark" | "cross-mark" => Some("\u{2716}"),
        "divide" | "split" | "separate" => Some("\u{2797}"),
        "red-circle" => Some("\u{1F534}"),
        "orange-circle" => Some("\u{1F7E0}"),
        "yellow-circle" => Some("\u{1F7E1}"),
        "green-circle" => Some("\u{1F7E2}"),
        "blue-circle" => Some("\u{1F535}"),
        "purple-circle" => Some("\u{1F7E3}"),
        "white-circle" => Some("\u{26AA}"),
        "black-circle" => Some("\u{26AB}"),
        "red-square" => Some("\u{1F7E5}"),
        "green-square" => Some("\u{1F7E9}"),
        "blue-square" => Some("\u{1F7E6}"),

        // Money
        "currency" | "dollar" | "money" | "usd" => Some("\u{1F4B2}"),
        "moneybag" | "rich" | "cash" | "funds" => Some("\u{1F4B0}"),
        "credit-card" | "payment" | "pay" | "swipe" => Some("\u{1F4B3}"),

        // Flags
        "flag" | "banner" | "pennant" => Some("\u{1F3F4}"),
        "white-flag" | "surrender" | "truce" => Some("\u{1F3F3}"),
        "checkered-flag" | "finish" | "race" | "complete" => Some("\u{1F3C1}"),
        "triangular-flag" | "marker" | "waypoint" => Some("\u{1F6A9}"),

        // Peace
        "peace" | "antiwar" | "peace-symbol" => Some("\u{262E}"),
        "yin-yang" | "balance" | "harmony" => Some("\u{262F}"),

        _ => None,
    }
}

pub fn is_known_emoji(name: &str) -> bool {
    emoji_lookup(name).is_some()
}

pub fn emoji_search(filter: &str) {
    let lc = filter.to_lowercase();
    println!("Emojis matching \"{}\":\n", filter);
    let mut found = false;
    for (primary, aliases) in EMOJI_DATA.iter() {
        if aliases.iter().any(|a| a.contains(&lc[..])) {
            if let Some(ch) = emoji_lookup(primary) {
                println!("  {}  {:<25} ({})", ch, primary, aliases.join(" "));
                found = true;
            }
        }
    }
    if !found {
        println!("  (no matches)");
    }
    println!();
}

pub fn emoji_list() {
    println!("Available emojis (use -emoji:FILTER to search):\n");
    let categories: &[(&str, &[&str])] = &[
        (
            "Build & Deploy",
            &[
                "rocket",
                "ship",
                "package",
                "construction",
                "hammer",
                "hammer-wrench",
                "nut-bolt",
                "bricks",
                "label",
                "factory",
            ],
        ),
        (
            "Status",
            &[
                "check",
                "cross",
                "warning",
                "stop",
                "hourglass",
                "no-entry",
                "prohibited",
                "exclamation",
                "question-mark",
                "infinity",
            ],
        ),
        (
            "Activity & Dev",
            &[
                "bug", "fire", "test", "search", "wrench", "gear", "lock", "key", "trash",
                "terminal", "laptop", "keyboard", "toolbox",
            ],
        ),
        (
            "Progress & Time",
            &[
                "sparkle", "star", "coffee", "sleep", "brain", "books", "chart", "alarm", "target",
                "tada",
            ],
        ),
    ];
    for (cat, names) in categories {
        println!("  {}:", cat);
        for chunk in names.chunks(3) {
            let mut line = String::from("    ");
            for name in chunk {
                if let Some(ch) = emoji_lookup(name) {
                    line.push_str(&format!("{:<14} {}  ", name, ch));
                }
            }
            println!("{}", line.trim_end());
        }
    }
    println!("\n  ... and 400+ more. Use -emoji:FILTER to search.\n");
}

// Searchable emoji data: (primary_name, [all_aliases])
const EMOJI_DATA: &[(&str, &[&str])] = &[
    ("rocket", &["rocket"]),
    ("ship", &["ship"]),
    ("package", &["package"]),
    ("construction", &["construction"]),
    ("hammer", &["hammer"]),
    ("hammer-wrench", &["hammer-wrench", "tools", "build-tools"]),
    ("bug", &["bug"]),
    ("fire", &["fire"]),
    ("test", &["test", "lab"]),
    ("search", &["search", "mag"]),
    ("wrench", &["wrench", "fix"]),
    ("gear", &["gear", "config"]),
    ("lock", &["lock", "secure"]),
    ("key", &["key"]),
    ("check", &["check", "done"]),
    ("cross", &["cross", "fail"]),
    ("warning", &["warning", "warn"]),
    ("stop", &["stop"]),
    ("hourglass", &["hourglass", "wait"]),
    ("eyes", &["eyes", "review"]),
    ("chat", &["chat", "discuss", "speech"]),
    ("rocket", &["rocket"]),
    ("star", &["star"]),
    ("coffee", &["coffee", "break"]),
    ("brain", &["brain", "think"]),
    ("tada", &["tada", "celebrate"]),
    ("robot", &["robot", "bot"]),
    ("skull", &["skull", "dead"]),
    ("heart", &["heart", "love-heart"]),
    ("dog", &["dog", "puppy"]),
    ("cat", &["cat", "kitty"]),
    ("dragon", &["dragon"]),
    ("unicorn", &["unicorn", "magic"]),
    ("pizza", &["pizza", "pie"]),
    ("beer", &["beer", "brew"]),
    ("target", &["target", "bullseye", "goal"]),
    ("shield", &["shield", "protect"]),
    ("sword", &["sword", "fight", "blade"]),
    ("bomb", &["bomb", "explosive"]),
    ("crown", &["crown", "king", "queen"]),
    ("gem", &["gem", "diamond"]),
    ("trophy", &["trophy", "winner"]),
];

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_emoji_lookup_primary() {
        assert_eq!(emoji_lookup("rocket"), Some("\u{1F680}"));
        assert_eq!(emoji_lookup("bug"), Some("\u{1F41B}"));
        assert_eq!(emoji_lookup("fire"), Some("\u{1F525}"));
        assert_eq!(emoji_lookup("check"), Some("\u{2705}"));
    }

    #[test]
    fn test_emoji_lookup_alias() {
        assert_eq!(emoji_lookup("done"), Some("\u{2705}"));
        assert_eq!(emoji_lookup("fail"), Some("\u{274C}"));
        assert_eq!(emoji_lookup("tools"), Some("\u{1F6E0}"));
        assert_eq!(emoji_lookup("fix"), Some("\u{1F527}"));
    }

    #[test]
    fn test_emoji_lookup_unknown() {
        assert_eq!(emoji_lookup("nonexistent"), None);
        assert_eq!(emoji_lookup(""), None);
    }

    #[test]
    fn test_is_known_emoji() {
        assert!(is_known_emoji("rocket"));
        assert!(is_known_emoji("done"));
        assert!(!is_known_emoji("nonexistent"));
        assert!(!is_known_emoji(""));
    }

    #[test]
    fn test_emoji_lookup_all_categories() {
        assert!(emoji_lookup("robot").is_some());
        assert!(emoji_lookup("dragon").is_some());
        assert!(emoji_lookup("coffee").is_some());
        assert!(emoji_lookup("star").is_some());
        assert!(emoji_lookup("heart").is_some());
        assert!(emoji_lookup("sun").is_some());
        assert!(emoji_lookup("pizza").is_some());
        assert!(emoji_lookup("car").is_some());
        assert!(emoji_lookup("music").is_some());
        assert!(emoji_lookup("soccer").is_some());
        assert!(emoji_lookup("bomb").is_some());
        assert!(emoji_lookup("flag").is_some());
        assert!(emoji_lookup("peace").is_some());
    }

    #[test]
    fn test_emoji_lookup_multi_alias() {
        assert_eq!(emoji_lookup("trash"), emoji_lookup("delete"));
        assert_eq!(emoji_lookup("trash"), emoji_lookup("wastebasket"));
        assert_eq!(emoji_lookup("terminal"), emoji_lookup("console"));
        assert_eq!(emoji_lookup("terminal"), emoji_lookup("cli"));
    }
}
