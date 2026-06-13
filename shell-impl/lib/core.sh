#!/bin/sh
# lib/core.sh — Supplementary core functions for tabbing-on
#
# Contains functions NOT needed by the prompt hook or adapter:
# emoji list, emoji search, color list, help text, YAML escaping.
#
# The render pipeline (color_code, emoji_lookup, render, display, etc.)
# has been moved to lib/render.sh for minimal adapter footprint.

# ---------------------------------------------------------------------------
# Auto-pager: pipes through bat/less/more when stdout is a TTY
# Usage: _tabbing_some_function | _tabbing_pager
# ---------------------------------------------------------------------------
_tabbing_pager() {
  if [ -t 1 ]; then
    if command -v bat >/dev/null 2>&1; then
      bat --plain --paging=auto --style=plain
    elif command -v less >/dev/null 2>&1; then
      less -R
    elif command -v more >/dev/null 2>&1; then
      more
    else
      cat
    fi
  else
    cat
  fi
}

# ---------------------------------------------------------------------------
# Emoji data: outputs "primary_name|all aliases" lines for search/iteration
# Each line represents one unique emoji. Primary name is used for lookup.
# ---------------------------------------------------------------------------
_tabbing_emoji_data() {
  cat <<'EMOJI_DATA'
rocket|rocket
ship|ship
package|package
construction|construction
hammer|hammer
hammer-wrench|hammer-wrench tools build-tools
nut-bolt|nut-bolt hardware fastener
bricks|bricks blocks wall foundation
label|label tag version release
factory|factory manufacture industry
check|check done
cross|cross fail
warning|warning warn
stop|stop
hourglass|hourglass wait
no-entry|no-entry forbidden blocked deny
prohibited|prohibited banned no-sign
exclamation|exclamation important bang-mark
question-mark|question-mark help-mark
infinity|infinity forever endless
bug|bug
fire|fire
test|test lab
search|search mag
wrench|wrench fix
gear|gear config
lock|lock secure
key|key
trash|trash delete wastebasket garbage rubbish
terminal|terminal console cli prompt shell
laptop|laptop computer pc mac
keyboard|keyboard type input keys
printer|printer print
disk|disk floppy save backup
cd|cd disc dvd optical
toolbox|toolbox toolkit devtools swiss-army
microscope|microscope research examine
telescope|telescope observe astronomy
crystal-ball|crystal-ball fortune predict
magnet|magnet attract pull
dna|dna genetics helix genome
petri-dish|petri-dish culture grow incubate
abacus|abacus count tally legacy
atom|atom physics science-symbol
hook|hook webhook callback trigger
chains|chains linked blockchain connection
plug|plug electric-plug outlet socket
battery|battery power charge energy
broom|broom cleanup sweep tidy
sponge|sponge wipe scrub absorb
fire-extinguisher|fire-extinguisher suppress douse
plunger|plunger unclog unstick fix-pipe
mousetrap|mousetrap catch-bug snare
ladder|ladder climb-up elevate
knot|knot tied tangled complex
bucket|bucket pail container
eyes|eyes review
chat|chat discuss speech balloon
mail|mail email
bell|bell alert
phone|phone call mobile cell
envelope|envelope letter mail-env
inbox|inbox tray incoming
outbox|outbox send outgoing
mailbox|mailbox letterbox post
radio|radio broadcast fm am
satellite-dish|satellite-dish signal antenna receive
newspaper|newspaper news press media
thought|thought thought-bubble
db|db database file-cabinet archive storage vault
cloud|cloud
link|link
electric|electric zap
globe-web|globe-web www internet web network
satellite|satellite orbit space
earth|earth globe world
compass|compass direction navigate
folder|folder directory dir
folder-open|folder-open browse explore
page|page document doc
scroll|scroll parchment ancient
sparkle|sparkle clean
star|star
coffee|coffee break
sleep|sleep zzz
brain|brain think
books|books docs
pin|pin
clipboard|clipboard
chart|chart
chart-up|chart-up trending growth stonks
chart-down|chart-down decline loss crash-chart
alarm|alarm timer clock-alarm
watch|watch time clock-watch
calendar|calendar date event schedule
target|target bullseye goal aim
tada|tada celebrate
art|art design
bulb|bulb idea
shield|shield protect
recycle|recycle refactor
truck|truck move
memo|memo note
gift|gift present surprise wrapped
balloon|balloon party-balloon inflate
confetti|confetti celebration festive
trophy|trophy winner champion cup
medal|medal award prize gold
ticket|ticket pass admission entry
crown|crown king queen royal ruler
gem|gem diamond jewel precious
hundred|hundred 100 perfect score
boom|boom explosion bang collision crash
flashlight|flashlight torch light
candle|candle flame wax
door|door entrance exit gateway
window-pane|window-pane viewport
magician|magician wizard wand
mirror-ball|mirror-ball disco dance
joker|joker wildcard trump
smile|smile happy
grin|grin
laugh|laugh lol
rofl|rofl
wink|wink
love-eyes|love-eyes heart-eyes
cool|cool sunglasses
hmm|hmm wondering
shush|shush quiet
sweat|sweat
cry|cry sob
angry|angry mad
rage|rage fury
scream|scream horror
sick|sick nausea
dizzy-face|dizzy-face
nerd|nerd
monocle|monocle inspect
party-face|party-face celebrate-face
yawn|yawn tired
melting|melting melt dissolve hot-face
peeking|peeking peek spy-face sneak
wave|wave hi bye
ok|ok okay
thumbsup|thumbsup like approve
thumbsdown|thumbsdown dislike reject
clap|clap applause
pray|pray thanks namaste
muscle|muscle strong flex
fist|fist punch bump
victory|victory peace-sign
crossed-fingers|crossed-fingers luck
handshake|handshake deal agree
point-right|point-right
point-left|point-left
point-up|point-up
point-down|point-down
raised-hand|raised-hand stop-hand halt
salute|salute
skull|skull dead rip
ghost|ghost
robot|robot bot
alien|alien
clown|clown
poop|poop crap
ninja|ninja
detective|detective spy
heart|heart love-heart red-heart
broken-heart|broken-heart heartbreak
sparkling-heart|sparkling-heart glowing-heart
sweat-drops|sweat-drops effort splash
anger-symbol|anger-symbol fury-mark
droplet|droplet water drip
dog|dog puppy
cat|cat kitty
fox|fox
bear|bear
panda|panda
monkey|monkey
chicken|chicken hen
penguin|penguin
bird|bird tweet
eagle|eagle
owl|owl
bat|bat
butterfly|butterfly
snake|snake
dragon|dragon
whale|whale
dolphin|dolphin
octopus|octopus
snail|snail slow
turtle|turtle tortoise
crab|crab crustacean
spider|spider
scorpion|scorpion
unicorn|unicorn magic
bee|bee honeybee buzz
ant|ant
ladybug|ladybug
shark|shark
wolf|wolf
horse|horse pony
pig|pig oink
frog|frog toad
gorilla|gorilla ape
deer|deer stag
rabbit|rabbit bunny
mouse|mouse rodent
camel|camel
elephant|elephant
lion|lion
tiger|tiger
crocodile|crocodile croc gator
parrot|parrot
flamingo|flamingo
peacock|peacock
lobster|lobster
shrimp|shrimp prawn
squid|squid
hedgehog|hedgehog porcupine
raccoon|raccoon trash-panda
sloth|sloth lazy
otter|otter
skunk|skunk stink
mammoth|mammoth woolly
dodo|dodo extinct
microbe|microbe germ bacteria
tree|tree evergreen
palm-tree|palm-tree tropical
flower|flower blossom cherry
rose|rose
sunflower|sunflower
leaf|leaf leaves wind-leaf
herb|herb plant seedling
mushroom|mushroom fungi toadstool
cactus|cactus
sun|sun sunny
moon|moon crescent
full-moon|full-moon
rainbow|rainbow
snowflake|snowflake frozen cold
tornado|tornado cyclone twister
ocean|ocean waves sea
volcano|volcano eruption lava
comet|comet meteor shooting-star
umbrella|umbrella rain-cover
lotus|lotus zen mindful calm
feather|feather lightweight quill
coral|coral reef marine
nest|nest nested home-base
apple|apple fruit
banana|banana
grapes|grapes vine
watermelon|watermelon melon
lemon|lemon citrus sour
peach|peach
cherry|cherry cherries
strawberry|strawberry
tomato|tomato
avocado|avocado
eggplant|eggplant aubergine
pepper|pepper hot spicy chili
pizza|pizza pie
burger|burger hamburger
fries|fries chips french-fries
hotdog|hotdog sausage frank
taco|taco
burrito|burrito wrap
sushi|sushi japanese
ramen|ramen noodles soup
cake|cake birthday bday
cookie|cookie biscuit
chocolate|chocolate candy-bar
donut|donut doughnut pastry
ice-cream|ice-cream icecream gelato
honey|honey honeypot sweet
beer|beer brew pint
wine|wine glass vino
cocktail|cocktail martini drink
popcorn|popcorn
bread|bread loaf toast
cheese|cheese cheddar
meat|meat steak beef
bacon|bacon pork
candy|candy lollipop sweet-treat
cupcake|cupcake muffin
salt|salt seasoning
beans|beans coffee-beans java
jar|jar preserve store
car|car auto drive vehicle
taxi|taxi cab
bus|bus transit
ambulance|ambulance ems emergency
fire-truck|fire-truck firetruck
police-car|police-car cop patrol
train|train rail locomotive
airplane|airplane plane flight jet
helicopter|helicopter chopper heli
sailboat|sailboat boat sailing
anchor|anchor dock port
fuel|fuel gas petrol pump
bike|bike bicycle cycle
house|house home
office|office building corp
hospital|hospital medical health-bldg
school|school education learn
castle|castle fortress fort
tent|tent camp camping outdoor
church|church worship chapel
book|book read manual textbook
notebook|notebook journal diary
pencil|pencil write edit compose
pen|pen author ink
paintbrush|paintbrush paint brush
crayon|crayon draw sketch color
paperclip|paperclip attach attachment
scissors|scissors cut snip trim
ruler|ruler measure length
camera|camera photo snap picture
clapper|clapper film movie action
tv|tv television screen monitor
music|music song tune melody
guitar|guitar rock strum
drum|drum beat rhythm
trumpet|trumpet horn fanfare brass
microphone|microphone mic karaoke sing
headphones|headphones audio listen earphones
speaker|speaker volume sound loud
mute|mute silent no-sound quiet-speaker
soccer|soccer football kick
basketball|basketball bball hoop
baseball|baseball bat-ball
tennis|tennis racket serve
golf|golf putt tee
boxing|boxing fight-glove bout
bowling|bowling strike pins
gaming|gaming joystick game play
puzzle|puzzle jigsaw piece solve component module
chess|chess strategy checkmate
dice|dice random chance roll
fishing|fishing catch rod
surfing|surfing surf wave-ride
swimming|swimming swim pool lap
running|running run sprint jog
eight-ball|eight-ball pool billiards
slot-machine|slot-machine jackpot gamble
mahjong|mahjong tile
bomb|bomb explosive detonate
sword|sword fight blade
axe|axe chop hatchet
radioactive|radioactive nuclear hazard
biohazard|biohazard toxic danger
arrow-up|arrow-up ascending upward
arrow-down|arrow-down descending downward
arrow-left|arrow-left back backward
arrow-right|arrow-right forward next ahead
arrows-rotate|arrows-rotate sync refresh reload
cycle|cycle repeat loop-arrows redo
plus|plus add new create
minus|minus subtract remove delete-sign
multiply|multiply times x-mark cross-mark
divide|divide split separate
red-circle|red-circle
orange-circle|orange-circle
yellow-circle|yellow-circle
green-circle|green-circle
blue-circle|blue-circle
purple-circle|purple-circle
white-circle|white-circle
black-circle|black-circle
red-square|red-square
green-square|green-square
blue-square|blue-square
currency|currency dollar money usd
moneybag|moneybag rich cash funds
credit-card|credit-card payment pay swipe
flag|flag banner pennant
white-flag|white-flag surrender truce
checkered-flag|checkered-flag finish race complete
triangular-flag|triangular-flag marker waypoint
peace|peace antiwar peace-symbol
yin-yang|yin-yang balance harmony
EMOJI_DATA
}

# ---------------------------------------------------------------------------
# Search emojis by filter string — matches against all names/aliases, deduped
# ---------------------------------------------------------------------------
_tabbing_emoji_search() {
  local filter="${1:-}"
  if [ -z "$filter" ]; then
    printf 'Usage: tabbing-on -emoji:FILTER\n' >&2
    printf 'Example: tabbing-on -emoji:fire\n' >&2
    return 1
  fi

  # Convert filter to lowercase for case-insensitive matching
  local lc_filter
  lc_filter="$(printf '%s' "$filter" | tr 'A-Z' 'a-z')"

  local found=0
  local seen_emojis=""

  printf 'Emojis matching "%s":\n\n' "$filter"

  _tabbing_emoji_data | while IFS='|' read -r primary aliases; do
    # Check if filter matches any alias
    case "$aliases" in
      *"$lc_filter"*)
        # Dedup by primary name
        case "$seen_emojis" in
          *"|${primary}|"*) continue ;;
        esac
        seen_emojis="${seen_emojis}|${primary}|"

        # Get the emoji character
        local emoji
        emoji="$(_tabbing_emoji_lookup "$primary" 2>/dev/null)"
        if [ -n "$emoji" ]; then
          printf '  %s  %-25s (%s)\n' "$emoji" "$primary" "$aliases"
          found=1
        fi
        ;;
    esac
  done

  # Check if anything was found (subshell issue workaround)
  if ! _tabbing_emoji_data | grep -q "$lc_filter" 2>/dev/null; then
    printf '  (no matches)\n'
  fi
  printf '\n'
}

# ---------------------------------------------------------------------------
# Print all available emojis with names (grouped by category)
# ---------------------------------------------------------------------------
_tabbing_emoji_list() {
  printf 'Available emojis (use -emoji:FILTER to search):\n'

  printf '\n  Build & Deploy:\n'
  printf '    rocket       %s    ship         %s    package      %s\n' \
    "$(_tabbing_emoji_lookup rocket)" "$(_tabbing_emoji_lookup ship)" "$(_tabbing_emoji_lookup package)"
  printf '    construction %s    hammer       %s    hammer-wrench %s\n' \
    "$(_tabbing_emoji_lookup construction)" "$(_tabbing_emoji_lookup hammer)" "$(_tabbing_emoji_lookup hammer-wrench)"
  printf '    nut-bolt     %s    bricks       %s    label/tag    %s\n' \
    "$(_tabbing_emoji_lookup nut-bolt)" "$(_tabbing_emoji_lookup bricks)" "$(_tabbing_emoji_lookup label)"
  printf '    factory      %s\n' "$(_tabbing_emoji_lookup factory)"

  printf '\n  Status:\n'
  printf '    check/done   %s    cross/fail   %s    warning/warn %s\n' \
    "$(_tabbing_emoji_lookup check)" "$(_tabbing_emoji_lookup cross)" "$(_tabbing_emoji_lookup warning)"
  printf '    stop         %s    hourglass    %s    no-entry     %s\n' \
    "$(_tabbing_emoji_lookup stop)" "$(_tabbing_emoji_lookup hourglass)" "$(_tabbing_emoji_lookup no-entry)"
  printf '    prohibited   %s    exclamation  %s    question-mark %s\n' \
    "$(_tabbing_emoji_lookup prohibited)" "$(_tabbing_emoji_lookup exclamation)" "$(_tabbing_emoji_lookup question-mark)"
  printf '    infinity     %s\n' "$(_tabbing_emoji_lookup infinity)"

  printf '\n  Activity & Dev:\n'
  printf '    bug          %s    fire         %s    test/lab     %s\n' \
    "$(_tabbing_emoji_lookup bug)" "$(_tabbing_emoji_lookup fire)" "$(_tabbing_emoji_lookup test)"
  printf '    search/mag   %s    wrench/fix   %s    gear/config  %s\n' \
    "$(_tabbing_emoji_lookup search)" "$(_tabbing_emoji_lookup wrench)" "$(_tabbing_emoji_lookup gear)"
  printf '    lock/secure  %s    key          %s    trash/delete %s\n' \
    "$(_tabbing_emoji_lookup lock)" "$(_tabbing_emoji_lookup key)" "$(_tabbing_emoji_lookup trash)"
  printf '    terminal/cli %s    laptop/pc    %s    keyboard     %s\n' \
    "$(_tabbing_emoji_lookup terminal)" "$(_tabbing_emoji_lookup laptop)" "$(_tabbing_emoji_lookup keyboard)"
  printf '    printer      %s    disk/floppy  %s    cd/disc      %s\n' \
    "$(_tabbing_emoji_lookup printer)" "$(_tabbing_emoji_lookup disk)" "$(_tabbing_emoji_lookup cd)"
  printf '    toolbox      %s    microscope   %s    telescope    %s\n' \
    "$(_tabbing_emoji_lookup toolbox)" "$(_tabbing_emoji_lookup microscope)" "$(_tabbing_emoji_lookup telescope)"
  printf '    crystal-ball %s    magnet       %s    dna/helix    %s\n' \
    "$(_tabbing_emoji_lookup crystal-ball)" "$(_tabbing_emoji_lookup magnet)" "$(_tabbing_emoji_lookup dna)"
  printf '    petri-dish   %s    abacus       %s    atom/physics %s\n' \
    "$(_tabbing_emoji_lookup petri-dish)" "$(_tabbing_emoji_lookup abacus)" "$(_tabbing_emoji_lookup atom)"
  printf '    hook/webhook %s    chains       %s    plug/outlet  %s\n' \
    "$(_tabbing_emoji_lookup hook)" "$(_tabbing_emoji_lookup chains)" "$(_tabbing_emoji_lookup plug)"
  printf '    battery      %s    broom        %s    sponge       %s\n' \
    "$(_tabbing_emoji_lookup battery)" "$(_tabbing_emoji_lookup broom)" "$(_tabbing_emoji_lookup sponge)"
  printf '    fire-ext.    %s    plunger      %s    mousetrap    %s\n' \
    "$(_tabbing_emoji_lookup fire-extinguisher)" "$(_tabbing_emoji_lookup plunger)" "$(_tabbing_emoji_lookup mousetrap)"
  printf '    ladder       %s    knot         %s    bucket       %s\n' \
    "$(_tabbing_emoji_lookup ladder)" "$(_tabbing_emoji_lookup knot)" "$(_tabbing_emoji_lookup bucket)"

  printf '\n  Review & Comms:\n'
  printf '    eyes/review  %s    chat/discuss %s    mail/email   %s\n' \
    "$(_tabbing_emoji_lookup eyes)" "$(_tabbing_emoji_lookup chat)" "$(_tabbing_emoji_lookup mail)"
  printf '    bell/alert   %s    phone/call   %s    envelope     %s\n' \
    "$(_tabbing_emoji_lookup bell)" "$(_tabbing_emoji_lookup phone)" "$(_tabbing_emoji_lookup envelope)"
  printf '    inbox        %s    outbox       %s    mailbox      %s\n' \
    "$(_tabbing_emoji_lookup inbox)" "$(_tabbing_emoji_lookup outbox)" "$(_tabbing_emoji_lookup mailbox)"
  printf '    radio        %s    sat-dish     %s    newspaper    %s\n' \
    "$(_tabbing_emoji_lookup radio)" "$(_tabbing_emoji_lookup satellite-dish)" "$(_tabbing_emoji_lookup newspaper)"
  printf '    thought      %s\n' "$(_tabbing_emoji_lookup thought)"

  printf '\n  Data & Infra:\n'
  printf '    db/database  %s    cloud        %s    link         %s\n' \
    "$(_tabbing_emoji_lookup db)" "$(_tabbing_emoji_lookup cloud)" "$(_tabbing_emoji_lookup link)"
  printf '    electric/zap %s    globe-web    %s    satellite    %s\n' \
    "$(_tabbing_emoji_lookup electric)" "$(_tabbing_emoji_lookup globe-web)" "$(_tabbing_emoji_lookup satellite)"
  printf '    earth/globe  %s    compass      %s    folder       %s\n' \
    "$(_tabbing_emoji_lookup earth)" "$(_tabbing_emoji_lookup compass)" "$(_tabbing_emoji_lookup folder)"
  printf '    folder-open  %s    page/doc     %s    scroll       %s\n' \
    "$(_tabbing_emoji_lookup folder-open)" "$(_tabbing_emoji_lookup page)" "$(_tabbing_emoji_lookup scroll)"

  printf '\n  Progress & Time:\n'
  printf '    sparkle      %s    star         %s    coffee/break %s\n' \
    "$(_tabbing_emoji_lookup sparkle)" "$(_tabbing_emoji_lookup star)" "$(_tabbing_emoji_lookup coffee)"
  printf '    sleep/zzz    %s    brain/think  %s    books/docs   %s\n' \
    "$(_tabbing_emoji_lookup sleep)" "$(_tabbing_emoji_lookup brain)" "$(_tabbing_emoji_lookup books)"
  printf '    pin          %s    clipboard    %s    chart        %s\n' \
    "$(_tabbing_emoji_lookup pin)" "$(_tabbing_emoji_lookup clipboard)" "$(_tabbing_emoji_lookup chart)"
  printf '    chart-up     %s    chart-down   %s    alarm/timer  %s\n' \
    "$(_tabbing_emoji_lookup chart-up)" "$(_tabbing_emoji_lookup chart-down)" "$(_tabbing_emoji_lookup alarm)"
  printf '    watch/time   %s    calendar     %s    target       %s\n' \
    "$(_tabbing_emoji_lookup watch)" "$(_tabbing_emoji_lookup calendar)" "$(_tabbing_emoji_lookup target)"

  printf '\n  Celebration & Misc:\n'
  printf '    tada         %s    art/design   %s    bulb/idea    %s\n' \
    "$(_tabbing_emoji_lookup tada)" "$(_tabbing_emoji_lookup art)" "$(_tabbing_emoji_lookup bulb)"
  printf '    shield       %s    recycle      %s    truck/move   %s\n' \
    "$(_tabbing_emoji_lookup shield)" "$(_tabbing_emoji_lookup recycle)" "$(_tabbing_emoji_lookup truck)"
  printf '    memo/note    %s    gift         %s    balloon      %s\n' \
    "$(_tabbing_emoji_lookup memo)" "$(_tabbing_emoji_lookup gift)" "$(_tabbing_emoji_lookup balloon)"
  printf '    confetti     %s    trophy       %s    medal        %s\n' \
    "$(_tabbing_emoji_lookup confetti)" "$(_tabbing_emoji_lookup trophy)" "$(_tabbing_emoji_lookup medal)"
  printf '    ticket       %s    crown        %s    gem/diamond  %s\n' \
    "$(_tabbing_emoji_lookup ticket)" "$(_tabbing_emoji_lookup crown)" "$(_tabbing_emoji_lookup gem)"
  printf '    hundred/100  %s    boom         %s    flashlight   %s\n' \
    "$(_tabbing_emoji_lookup hundred)" "$(_tabbing_emoji_lookup boom)" "$(_tabbing_emoji_lookup flashlight)"
  printf '    candle       %s    door         %s    window-pane  %s\n' \
    "$(_tabbing_emoji_lookup candle)" "$(_tabbing_emoji_lookup door)" "$(_tabbing_emoji_lookup window-pane)"
  printf '    magician     %s    mirror-ball  %s    joker        %s\n' \
    "$(_tabbing_emoji_lookup magician)" "$(_tabbing_emoji_lookup mirror-ball)" "$(_tabbing_emoji_lookup joker)"

  printf '\n  Smileys & Emotion:\n'
  printf '    smile/happy  %s    grin         %s    laugh/lol    %s\n' \
    "$(_tabbing_emoji_lookup smile)" "$(_tabbing_emoji_lookup grin)" "$(_tabbing_emoji_lookup laugh)"
  printf '    rofl         %s    wink         %s    love-eyes    %s\n' \
    "$(_tabbing_emoji_lookup rofl)" "$(_tabbing_emoji_lookup wink)" "$(_tabbing_emoji_lookup love-eyes)"
  printf '    cool         %s    hmm          %s    shush/quiet  %s\n' \
    "$(_tabbing_emoji_lookup cool)" "$(_tabbing_emoji_lookup hmm)" "$(_tabbing_emoji_lookup shush)"
  printf '    sweat        %s    cry/sob      %s    angry/mad    %s\n' \
    "$(_tabbing_emoji_lookup sweat)" "$(_tabbing_emoji_lookup cry)" "$(_tabbing_emoji_lookup angry)"
  printf '    rage/fury    %s    scream       %s    sick         %s\n' \
    "$(_tabbing_emoji_lookup rage)" "$(_tabbing_emoji_lookup scream)" "$(_tabbing_emoji_lookup sick)"
  printf '    dizzy-face   %s    nerd         %s    monocle      %s\n' \
    "$(_tabbing_emoji_lookup dizzy-face)" "$(_tabbing_emoji_lookup nerd)" "$(_tabbing_emoji_lookup monocle)"
  printf '    party-face   %s    yawn/tired   %s    melting      %s\n' \
    "$(_tabbing_emoji_lookup party-face)" "$(_tabbing_emoji_lookup yawn)" "$(_tabbing_emoji_lookup melting)"
  printf '    peeking      %s\n' "$(_tabbing_emoji_lookup peeking)"

  printf '\n  Gestures & Body:\n'
  printf '    wave/hi/bye  %s    ok/okay      %s    thumbsup     %s\n' \
    "$(_tabbing_emoji_lookup wave)" "$(_tabbing_emoji_lookup ok)" "$(_tabbing_emoji_lookup thumbsup)"
  printf '    thumbsdown   %s    clap         %s    pray/thanks  %s\n' \
    "$(_tabbing_emoji_lookup thumbsdown)" "$(_tabbing_emoji_lookup clap)" "$(_tabbing_emoji_lookup pray)"
  printf '    muscle       %s    fist/punch   %s    victory      %s\n' \
    "$(_tabbing_emoji_lookup muscle)" "$(_tabbing_emoji_lookup fist)" "$(_tabbing_emoji_lookup victory)"
  printf '    crossed-fin  %s    handshake    %s    salute       %s\n' \
    "$(_tabbing_emoji_lookup crossed-fingers)" "$(_tabbing_emoji_lookup handshake)" "$(_tabbing_emoji_lookup salute)"
  printf '    raised-hand  %s\n' "$(_tabbing_emoji_lookup raised-hand)"

  printf '\n  People & Characters:\n'
  printf '    skull/dead   %s    ghost        %s    robot/bot    %s\n' \
    "$(_tabbing_emoji_lookup skull)" "$(_tabbing_emoji_lookup ghost)" "$(_tabbing_emoji_lookup robot)"
  printf '    alien        %s    clown        %s    poop         %s\n' \
    "$(_tabbing_emoji_lookup alien)" "$(_tabbing_emoji_lookup clown)" "$(_tabbing_emoji_lookup poop)"
  printf '    ninja        %s    detective    %s\n' \
    "$(_tabbing_emoji_lookup ninja)" "$(_tabbing_emoji_lookup detective)"

  printf '\n  Hearts & Symbols:\n'
  printf '    heart        %s    broken-heart %s    sparkling    %s\n' \
    "$(_tabbing_emoji_lookup heart)" "$(_tabbing_emoji_lookup broken-heart)" "$(_tabbing_emoji_lookup sparkling-heart)"
  printf '    sweat-drops  %s    anger-symbol %s    droplet      %s\n' \
    "$(_tabbing_emoji_lookup sweat-drops)" "$(_tabbing_emoji_lookup anger-symbol)" "$(_tabbing_emoji_lookup droplet)"

  printf '\n  Animals:\n'
  printf '    dog          %s    cat          %s    fox          %s\n' \
    "$(_tabbing_emoji_lookup dog)" "$(_tabbing_emoji_lookup cat)" "$(_tabbing_emoji_lookup fox)"
  printf '    bear         %s    panda        %s    monkey       %s\n' \
    "$(_tabbing_emoji_lookup bear)" "$(_tabbing_emoji_lookup panda)" "$(_tabbing_emoji_lookup monkey)"
  printf '    penguin      %s    bird         %s    eagle        %s\n' \
    "$(_tabbing_emoji_lookup penguin)" "$(_tabbing_emoji_lookup bird)" "$(_tabbing_emoji_lookup eagle)"
  printf '    owl          %s    bat          %s    butterfly    %s\n' \
    "$(_tabbing_emoji_lookup owl)" "$(_tabbing_emoji_lookup bat)" "$(_tabbing_emoji_lookup butterfly)"
  printf '    snake        %s    dragon       %s    whale        %s\n' \
    "$(_tabbing_emoji_lookup snake)" "$(_tabbing_emoji_lookup dragon)" "$(_tabbing_emoji_lookup whale)"
  printf '    dolphin      %s    octopus      %s    snail/slow   %s\n' \
    "$(_tabbing_emoji_lookup dolphin)" "$(_tabbing_emoji_lookup octopus)" "$(_tabbing_emoji_lookup snail)"
  printf '    turtle       %s    crab         %s    spider       %s\n' \
    "$(_tabbing_emoji_lookup turtle)" "$(_tabbing_emoji_lookup crab)" "$(_tabbing_emoji_lookup spider)"
  printf '    scorpion     %s    unicorn      %s    bee          %s\n' \
    "$(_tabbing_emoji_lookup scorpion)" "$(_tabbing_emoji_lookup unicorn)" "$(_tabbing_emoji_lookup bee)"
  printf '    ant          %s    ladybug      %s    shark        %s\n' \
    "$(_tabbing_emoji_lookup ant)" "$(_tabbing_emoji_lookup ladybug)" "$(_tabbing_emoji_lookup shark)"
  printf '    wolf         %s    horse        %s    pig          %s\n' \
    "$(_tabbing_emoji_lookup wolf)" "$(_tabbing_emoji_lookup horse)" "$(_tabbing_emoji_lookup pig)"
  printf '    frog         %s    chicken      %s    gorilla      %s\n' \
    "$(_tabbing_emoji_lookup frog)" "$(_tabbing_emoji_lookup chicken)" "$(_tabbing_emoji_lookup gorilla)"
  printf '    deer         %s    rabbit       %s    mouse        %s\n' \
    "$(_tabbing_emoji_lookup deer)" "$(_tabbing_emoji_lookup rabbit)" "$(_tabbing_emoji_lookup mouse)"
  printf '    camel        %s    elephant     %s    lion         %s\n' \
    "$(_tabbing_emoji_lookup camel)" "$(_tabbing_emoji_lookup elephant)" "$(_tabbing_emoji_lookup lion)"
  printf '    tiger        %s    crocodile    %s    parrot       %s\n' \
    "$(_tabbing_emoji_lookup tiger)" "$(_tabbing_emoji_lookup crocodile)" "$(_tabbing_emoji_lookup parrot)"
  printf '    flamingo     %s    peacock      %s    lobster      %s\n' \
    "$(_tabbing_emoji_lookup flamingo)" "$(_tabbing_emoji_lookup peacock)" "$(_tabbing_emoji_lookup lobster)"
  printf '    shrimp       %s    squid        %s    hedgehog     %s\n' \
    "$(_tabbing_emoji_lookup shrimp)" "$(_tabbing_emoji_lookup squid)" "$(_tabbing_emoji_lookup hedgehog)"
  printf '    raccoon      %s    sloth        %s    otter        %s\n' \
    "$(_tabbing_emoji_lookup raccoon)" "$(_tabbing_emoji_lookup sloth)" "$(_tabbing_emoji_lookup otter)"
  printf '    skunk        %s    mammoth      %s    dodo         %s\n' \
    "$(_tabbing_emoji_lookup skunk)" "$(_tabbing_emoji_lookup mammoth)" "$(_tabbing_emoji_lookup dodo)"
  printf '    microbe      %s\n' "$(_tabbing_emoji_lookup microbe)"

  printf '\n  Nature & Weather:\n'
  printf '    tree         %s    palm-tree    %s    flower       %s\n' \
    "$(_tabbing_emoji_lookup tree)" "$(_tabbing_emoji_lookup palm-tree)" "$(_tabbing_emoji_lookup flower)"
  printf '    rose         %s    sunflower    %s    leaf         %s\n' \
    "$(_tabbing_emoji_lookup rose)" "$(_tabbing_emoji_lookup sunflower)" "$(_tabbing_emoji_lookup leaf)"
  printf '    herb/plant   %s    mushroom     %s    cactus       %s\n' \
    "$(_tabbing_emoji_lookup herb)" "$(_tabbing_emoji_lookup mushroom)" "$(_tabbing_emoji_lookup cactus)"
  printf '    sun          %s    moon         %s    full-moon    %s\n' \
    "$(_tabbing_emoji_lookup sun)" "$(_tabbing_emoji_lookup moon)" "$(_tabbing_emoji_lookup full-moon)"
  printf '    rainbow      %s    snowflake    %s    tornado      %s\n' \
    "$(_tabbing_emoji_lookup rainbow)" "$(_tabbing_emoji_lookup snowflake)" "$(_tabbing_emoji_lookup tornado)"
  printf '    ocean        %s    volcano      %s    comet        %s\n' \
    "$(_tabbing_emoji_lookup ocean)" "$(_tabbing_emoji_lookup volcano)" "$(_tabbing_emoji_lookup comet)"
  printf '    umbrella     %s    lotus/zen    %s    feather      %s\n' \
    "$(_tabbing_emoji_lookup umbrella)" "$(_tabbing_emoji_lookup lotus)" "$(_tabbing_emoji_lookup feather)"
  printf '    coral        %s    nest         %s\n' \
    "$(_tabbing_emoji_lookup coral)" "$(_tabbing_emoji_lookup nest)"

  printf '\n  Food & Drink:\n'
  printf '    apple        %s    banana       %s    grapes       %s\n' \
    "$(_tabbing_emoji_lookup apple)" "$(_tabbing_emoji_lookup banana)" "$(_tabbing_emoji_lookup grapes)"
  printf '    watermelon   %s    lemon        %s    peach        %s\n' \
    "$(_tabbing_emoji_lookup watermelon)" "$(_tabbing_emoji_lookup lemon)" "$(_tabbing_emoji_lookup peach)"
  printf '    cherry       %s    strawberry   %s    tomato       %s\n' \
    "$(_tabbing_emoji_lookup cherry)" "$(_tabbing_emoji_lookup strawberry)" "$(_tabbing_emoji_lookup tomato)"
  printf '    avocado      %s    eggplant     %s    pepper/hot   %s\n' \
    "$(_tabbing_emoji_lookup avocado)" "$(_tabbing_emoji_lookup eggplant)" "$(_tabbing_emoji_lookup pepper)"
  printf '    pizza        %s    burger       %s    fries        %s\n' \
    "$(_tabbing_emoji_lookup pizza)" "$(_tabbing_emoji_lookup burger)" "$(_tabbing_emoji_lookup fries)"
  printf '    hotdog       %s    taco         %s    burrito      %s\n' \
    "$(_tabbing_emoji_lookup hotdog)" "$(_tabbing_emoji_lookup taco)" "$(_tabbing_emoji_lookup burrito)"
  printf '    sushi        %s    ramen        %s    cake         %s\n' \
    "$(_tabbing_emoji_lookup sushi)" "$(_tabbing_emoji_lookup ramen)" "$(_tabbing_emoji_lookup cake)"
  printf '    cookie       %s    chocolate    %s    donut        %s\n' \
    "$(_tabbing_emoji_lookup cookie)" "$(_tabbing_emoji_lookup chocolate)" "$(_tabbing_emoji_lookup donut)"
  printf '    ice-cream    %s    honey        %s    beer         %s\n' \
    "$(_tabbing_emoji_lookup ice-cream)" "$(_tabbing_emoji_lookup honey)" "$(_tabbing_emoji_lookup beer)"
  printf '    wine         %s    cocktail     %s    popcorn      %s\n' \
    "$(_tabbing_emoji_lookup wine)" "$(_tabbing_emoji_lookup cocktail)" "$(_tabbing_emoji_lookup popcorn)"
  printf '    bread        %s    cheese       %s    meat/steak   %s\n' \
    "$(_tabbing_emoji_lookup bread)" "$(_tabbing_emoji_lookup cheese)" "$(_tabbing_emoji_lookup meat)"
  printf '    bacon        %s    candy        %s    cupcake      %s\n' \
    "$(_tabbing_emoji_lookup bacon)" "$(_tabbing_emoji_lookup candy)" "$(_tabbing_emoji_lookup cupcake)"
  printf '    salt         %s    beans/java   %s    jar          %s\n' \
    "$(_tabbing_emoji_lookup salt)" "$(_tabbing_emoji_lookup beans)" "$(_tabbing_emoji_lookup jar)"

  printf '\n  Travel & Transport:\n'
  printf '    car/auto     %s    taxi/cab     %s    bus/transit  %s\n' \
    "$(_tabbing_emoji_lookup car)" "$(_tabbing_emoji_lookup taxi)" "$(_tabbing_emoji_lookup bus)"
  printf '    ambulance    %s    fire-truck   %s    police-car   %s\n' \
    "$(_tabbing_emoji_lookup ambulance)" "$(_tabbing_emoji_lookup fire-truck)" "$(_tabbing_emoji_lookup police-car)"
  printf '    train        %s    airplane     %s    helicopter   %s\n' \
    "$(_tabbing_emoji_lookup train)" "$(_tabbing_emoji_lookup airplane)" "$(_tabbing_emoji_lookup helicopter)"
  printf '    sailboat     %s    anchor       %s    fuel/gas     %s\n' \
    "$(_tabbing_emoji_lookup sailboat)" "$(_tabbing_emoji_lookup anchor)" "$(_tabbing_emoji_lookup fuel)"
  printf '    bike         %s\n' "$(_tabbing_emoji_lookup bike)"

  printf '\n  Places & Buildings:\n'
  printf '    house/home   %s    office       %s    hospital     %s\n' \
    "$(_tabbing_emoji_lookup house)" "$(_tabbing_emoji_lookup office)" "$(_tabbing_emoji_lookup hospital)"
  printf '    school       %s    castle       %s    tent/camp    %s\n' \
    "$(_tabbing_emoji_lookup school)" "$(_tabbing_emoji_lookup castle)" "$(_tabbing_emoji_lookup tent)"
  printf '    church       %s\n' "$(_tabbing_emoji_lookup church)"

  printf '\n  Writing & Office:\n'
  printf '    book/read    %s    notebook     %s    pencil/edit  %s\n' \
    "$(_tabbing_emoji_lookup book)" "$(_tabbing_emoji_lookup notebook)" "$(_tabbing_emoji_lookup pencil)"
  printf '    pen          %s    paintbrush   %s    crayon/draw  %s\n' \
    "$(_tabbing_emoji_lookup pen)" "$(_tabbing_emoji_lookup paintbrush)" "$(_tabbing_emoji_lookup crayon)"
  printf '    paperclip    %s    scissors     %s    ruler        %s\n' \
    "$(_tabbing_emoji_lookup paperclip)" "$(_tabbing_emoji_lookup scissors)" "$(_tabbing_emoji_lookup ruler)"
  printf '    camera       %s    clapper/film %s    tv/screen    %s\n' \
    "$(_tabbing_emoji_lookup camera)" "$(_tabbing_emoji_lookup clapper)" "$(_tabbing_emoji_lookup tv)"

  printf '\n  Music & Sound:\n'
  printf '    music/song   %s    guitar       %s    drum/beat    %s\n' \
    "$(_tabbing_emoji_lookup music)" "$(_tabbing_emoji_lookup guitar)" "$(_tabbing_emoji_lookup drum)"
  printf '    trumpet      %s    microphone   %s    headphones   %s\n' \
    "$(_tabbing_emoji_lookup trumpet)" "$(_tabbing_emoji_lookup microphone)" "$(_tabbing_emoji_lookup headphones)"
  printf '    speaker      %s    mute         %s\n' \
    "$(_tabbing_emoji_lookup speaker)" "$(_tabbing_emoji_lookup mute)"

  printf '\n  Sports & Games:\n'
  printf '    soccer       %s    basketball   %s    baseball     %s\n' \
    "$(_tabbing_emoji_lookup soccer)" "$(_tabbing_emoji_lookup basketball)" "$(_tabbing_emoji_lookup baseball)"
  printf '    tennis       %s    golf         %s    boxing       %s\n' \
    "$(_tabbing_emoji_lookup tennis)" "$(_tabbing_emoji_lookup golf)" "$(_tabbing_emoji_lookup boxing)"
  printf '    bowling      %s    gaming       %s    puzzle       %s\n' \
    "$(_tabbing_emoji_lookup bowling)" "$(_tabbing_emoji_lookup gaming)" "$(_tabbing_emoji_lookup puzzle)"
  printf '    chess        %s    dice         %s    fishing      %s\n' \
    "$(_tabbing_emoji_lookup chess)" "$(_tabbing_emoji_lookup dice)" "$(_tabbing_emoji_lookup fishing)"
  printf '    surfing      %s    swimming     %s    running      %s\n' \
    "$(_tabbing_emoji_lookup surfing)" "$(_tabbing_emoji_lookup swimming)" "$(_tabbing_emoji_lookup running)"
  printf '    eight-ball   %s    slot-machine %s    mahjong      %s\n' \
    "$(_tabbing_emoji_lookup eight-ball)" "$(_tabbing_emoji_lookup slot-machine)" "$(_tabbing_emoji_lookup mahjong)"

  printf '\n  Combat & Danger:\n'
  printf '    bomb         %s    sword        %s    axe          %s\n' \
    "$(_tabbing_emoji_lookup bomb)" "$(_tabbing_emoji_lookup sword)" "$(_tabbing_emoji_lookup axe)"
  printf '    radioactive  %s    biohazard    %s\n' \
    "$(_tabbing_emoji_lookup radioactive)" "$(_tabbing_emoji_lookup biohazard)"

  printf '\n  Arrows & Shapes:\n'
  printf '    arrow-up     %s    arrow-down   %s    arrow-left   %s\n' \
    "$(_tabbing_emoji_lookup arrow-up)" "$(_tabbing_emoji_lookup arrow-down)" "$(_tabbing_emoji_lookup arrow-left)"
  printf '    arrow-right  %s    arrows-rot.  %s    cycle/repeat %s\n' \
    "$(_tabbing_emoji_lookup arrow-right)" "$(_tabbing_emoji_lookup arrows-rotate)" "$(_tabbing_emoji_lookup cycle)"
  printf '    plus/add     %s    minus        %s    multiply     %s\n' \
    "$(_tabbing_emoji_lookup plus)" "$(_tabbing_emoji_lookup minus)" "$(_tabbing_emoji_lookup multiply)"
  printf '    divide       %s\n' "$(_tabbing_emoji_lookup divide)"

  printf '\n  Colored Shapes:\n'
  printf '    red-circle   %s    orange-circ. %s    yellow-circ. %s\n' \
    "$(_tabbing_emoji_lookup red-circle)" "$(_tabbing_emoji_lookup orange-circle)" "$(_tabbing_emoji_lookup yellow-circle)"
  printf '    green-circle %s    blue-circle  %s    purple-circ. %s\n' \
    "$(_tabbing_emoji_lookup green-circle)" "$(_tabbing_emoji_lookup blue-circle)" "$(_tabbing_emoji_lookup purple-circle)"
  printf '    white-circle %s    black-circle %s\n' \
    "$(_tabbing_emoji_lookup white-circle)" "$(_tabbing_emoji_lookup black-circle)"
  printf '    red-square   %s    green-square %s    blue-square  %s\n' \
    "$(_tabbing_emoji_lookup red-square)" "$(_tabbing_emoji_lookup green-square)" "$(_tabbing_emoji_lookup blue-square)"

  printf '\n  Money & Finance:\n'
  printf '    currency/$   %s    moneybag     %s    credit-card  %s\n' \
    "$(_tabbing_emoji_lookup currency)" "$(_tabbing_emoji_lookup moneybag)" "$(_tabbing_emoji_lookup credit-card)"

  printf '\n  Flags:\n'
  printf '    flag/banner  %s    white-flag   %s    checkered    %s\n' \
    "$(_tabbing_emoji_lookup flag)" "$(_tabbing_emoji_lookup white-flag)" "$(_tabbing_emoji_lookup checkered-flag)"
  printf '    tri-flag     %s\n' "$(_tabbing_emoji_lookup triangular-flag)"

  printf '\n  Peace & Philosophy:\n'
  printf '    peace        %s    yin-yang     %s\n' \
    "$(_tabbing_emoji_lookup peace)" "$(_tabbing_emoji_lookup yin-yang)"

  printf '\n  Tip: use "tabbing-on -emoji:FILTER" to search (e.g. -emoji:fire)\n'
  printf '\n'
}

# ---------------------------------------------------------------------------
# Print available colors
# ---------------------------------------------------------------------------
_tabbing_color_list() {
  printf 'Available colors:\n\n'
  printf '  Standard:  black  red  green  yellow  blue  magenta  cyan  white\n'
  printf '  Bright:    bright-black  bright-red  bright-green  bright-yellow\n'
  printf '             bright-blue  bright-magenta  bright-cyan  bright-white\n'
  printf '  Effects:   bold  dim  italic  underline  blink  inverse  strikethrough\n'
  printf '  Raw:       any ANSI code (e.g. 31, 91, 196)\n'
  printf '\n'
}

# ---------------------------------------------------------------------------
# Help / usage
# ---------------------------------------------------------------------------
_tabbing_help() {
  printf 'tabbing-on — Terminal tab title, status & task manager\n\n'
  printf 'Usage:\n'
  printf '  tabbing-on [flags] "title" "status"    Set tab title and status\n'
  printf '  tabbing-on                             Show current state\n'
  printf '  tabbing-on emojis                      List available emojis\n'
  printf '  tabbing-on -emoji:FILTER               Search emojis by name\n'
  printf '  tabbing-on colors                      List available colors\n'
  printf '  tabbing-on help                        Show this help\n'
  printf '\n'
  printf 'Flags:\n'
  printf '  --highlight COLOR, -h COLOR, -COLOR    Set title highlight color\n'
  printf '  --urgency N, --pri N, -p N, -priN      Set urgency 0-5 (0=critical)\n'
  printf '  --emoji NAME, -e NAME, -NAME           Set emoji indicator\n'
  printf '  --no-emoji                             Clear emoji\n'
  printf '  -emoji:FILTER                          Search emojis by name/alias\n'
  printf '  -m, --marquee                          Enable scrolling marquee\n'
  printf '  --no-marquee                           Disable marquee\n'
  printf '  --record                               Start asciinema recording\n'
  printf '  --continue                             Keep recording across status change\n'
  printf '  --stop-recording                       Stop recording\n'
  printf '  --terminal-info                        Show detected terminal\n'
  printf '  --claude [ARGS...]                     Start Claude Code status line bridge\n'
  printf '  --run-with CMD [ARGS...]               Pipe state to a custom command\n'
  printf '\n'
  printf 'Related commands:\n'
  printf '  tabbing-status [flags] "text"           Update status only\n'
  printf '  tabbing-todo "title" [-m "desc"]        Add todo item\n'
  printf '  tabbing-todo                            List todos\n'
  printf '  tabbing-todo --pick                     Switch to a todo interactively\n'
  printf '  tabbing-todo --done [id]                Mark todo done\n'
  printf '  tabbing-report [--mermaid] [--all]      Time-in-state report\n'
  printf '  tabbing-history [query]                 Search/browse history\n'
  printf '  tabbing-info                             Full tab info (state, paths, recordings)\n'
  printf '  tabbing-recordings                      List recordings\n'
  printf '  tabbing-clear history|todos|recordings   Clear data\n'
  printf '\n'
  printf 'Examples:\n'
  printf '  tabbing-on -rocket -blue "MyApp" "deploying" -p 2\n'
  printf '  tabbing-status -fire "hotfix"\n'
  printf '  tabbing-todo "Write tests" -e test -m "Cover edge cases"\n'
  printf '  tabbing-on -emoji:fire     # search emojis matching "fire"\n'
  printf '  tabbing-on "Proj" --claude              # bridge to Claude Code status line\n'
  printf '  tabbing-on "Proj" --run-with my-tool    # pipe state to custom command\n'
  printf '\n'
}

# ---------------------------------------------------------------------------
# YAML-safe string escaping
# ---------------------------------------------------------------------------
_tabbing_yaml_escape() {
  printf '%s' "$1" | sed 's/"/\\"/g'
}
