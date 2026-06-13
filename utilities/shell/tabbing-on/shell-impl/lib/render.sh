#!/bin/sh
# lib/render.sh — Minimal render pipeline for prompt hook + validation
#
# Contains ONLY the functions needed by the shell adapter:
# - Prompt hook rendering (title + urgency color)
# - Color/emoji validation (for arg parsing)
# - Display (for no-args state display)
#
# Sourced by shell adapters at init time. All other functions
# remain in core.sh/terminal.sh and are only loaded by bin/ scripts.

TABBING_VERSION="0.2.0"

_tabbing_print_version() {
  printf 'tabbing-on %s\n' "$TABBING_VERSION"
}

# ---------------------------------------------------------------------------
# State directory — lightweight copy for render.sh standalone use.
# If history.sh is loaded later its definition takes precedence (same body).
# ---------------------------------------------------------------------------
if ! command -v _tabbing_state_dir >/dev/null 2>&1; then
  _tabbing_state_dir() {
    printf '%s/tabbing' "${XDG_STATE_HOME:-$HOME/.local/state}"
  }
fi

# ---------------------------------------------------------------------------
# Output abstraction — must be defined before anything else
# ---------------------------------------------------------------------------

# _tabbing_tty_printf — Send escape sequences to the terminal.
#
# Normally writes to /dev/tty so sequences don't interfere with shell
# integration hooks (Ghostty, Kitty) that also emit escapes during prompt
# rendering.  When $CLAUDECODE is set (running inside Claude Code) /dev/tty
# may not be available or may point somewhere unhelpful, so we fall back
# to plain stdout.
#
# Usage: _tabbing_tty_printf FORMAT [ARGS...]
_tabbing_tty_printf() {
  if [[ "${CLAUDECODE}" == "1" ]]; then
    printf "$@"
  else
    printf "$@" >/dev/tty 2>/dev/null || printf "$@"
  fi
}

# _tabbing_out — User-facing output with verbosity control.
#
# Flags (must come before format string):
#   -v LEVEL   Required verbosity level (0=error, 1=normal, 2=verbose)
#              Default: 1.  Compared against TAB_VERBOSITY (default 1).
#   -e         Write to stderr instead of stdout.
#
# Usage: _tabbing_out [-v LEVEL] [-e] FORMAT [ARGS...]
#
# Examples:
#   _tabbing_out 'hello %s\n' "$name"
#   _tabbing_out -e 'error: %s\n' "$msg"
#   _tabbing_out -v 2 'debug: %s\n' "$detail"
#   _tabbing_out -v 0 -e 'fatal: %s\n' "$err"
_tabbing_out() {
  _to_level=1
  _to_stderr=0
  while [ $# -gt 0 ]; do
    case "$1" in
      -v) _to_level="$2"; shift 2 ;;
      -e) _to_stderr=1; shift ;;
      *)  break ;;
    esac
  done

  # Suppress if message verbosity exceeds configured level
  [ "$_to_level" -gt "${TAB_VERBOSITY:-1}" ] && return 0

  if [ "$_to_stderr" -eq 1 ]; then
    printf "$@" >&2
  else
    printf "$@"
  fi
}

# ---------------------------------------------------------------------------
# Color name → ANSI code mapping
# ---------------------------------------------------------------------------
_tabbing_color_code() {
  case "${1:-}" in
    black)          echo "30" ;;
    red)            echo "31" ;;
    green)          echo "32" ;;
    yellow)         echo "33" ;;
    blue)           echo "34" ;;
    magenta)        echo "35" ;;
    cyan)           echo "36" ;;
    white)          echo "37" ;;
    bright-black)   echo "90" ;;
    bright-red)     echo "91" ;;
    bright-green)   echo "92" ;;
    bright-yellow)  echo "93" ;;
    bright-blue)    echo "94" ;;
    bright-magenta) echo "95" ;;
    bright-cyan)    echo "96" ;;
    bright-white)   echo "97" ;;
    bold)           echo "1" ;;
    dim)            echo "2" ;;
    italic)         echo "3" ;;
    underline)      echo "4" ;;
    blink)          echo "5" ;;
    inverse)        echo "7" ;;
    strikethrough)  echo "9" ;;
    [0-9]*)         echo "$1" ;;
    *)
      _tabbing_out -v 0 -e 'tabbing: unknown color/effect '\''%s'\''\n' "$1"
      _tabbing_out -v 0 -e 'tabbing: available: black red green yellow blue magenta cyan white\n'
      _tabbing_out -v 0 -e 'tabbing:   bright-{black,red,green,yellow,blue,magenta,cyan,white}\n'
      _tabbing_out -v 0 -e 'tabbing:   bold dim italic underline blink inverse strikethrough\n'
      _tabbing_out -v 0 -e 'tabbing:   or raw ANSI codes (e.g. 31, 91)\n'
      return 1
      ;;
  esac
}

# ---------------------------------------------------------------------------
# Check if a string is a known color name (replaces array lookup)
# ---------------------------------------------------------------------------
_tabbing_is_known_color() {
  case "${1:-}" in
    black|red|green|yellow|blue|magenta|cyan|white) return 0 ;;
    bright-black|bright-red|bright-green|bright-yellow) return 0 ;;
    bright-blue|bright-magenta|bright-cyan|bright-white) return 0 ;;
    bold|dim|italic|underline|blink|inverse|strikethrough) return 0 ;;
    *) return 1 ;;
  esac
}

# ---------------------------------------------------------------------------
# Urgency palette: 0=critical(red) → 5=nominal(green/gray)
# ---------------------------------------------------------------------------
_tabbing_urgency_ansi() {
  case "${1:-}" in
    0) echo "91" ;;  # bright red
    1) echo "31" ;;  # red
    2) echo "33" ;;  # yellow
    3) echo "93" ;;  # bright yellow
    4) echo "32" ;;  # green
    5) echo "90" ;;  # gray
    *) echo "0"  ;;  # default
  esac
}

_tabbing_urgency_dot() {
  case "${1:-}" in
    0) printf '\xF0\x9F\x94\xB4' ;;  # red circle
    1) printf '\xF0\x9F\x9F\xA0' ;;  # orange circle
    2) printf '\xF0\x9F\x9F\xA1' ;;  # yellow circle
    3) printf '\xF0\x9F\x9F\xA2' ;;  # green circle
    4) printf '\xF0\x9F\x9F\xA2' ;;  # green circle
    5) printf '\xE2\x9A\xAA'     ;;  # white/gray circle
    *) ;;
  esac
}

# ---------------------------------------------------------------------------
# Emoji lookup: name → Unicode character
# Uses raw UTF-8 bytes for bash 3.2 compatibility
# ---------------------------------------------------------------------------
_tabbing_emoji_lookup() {
  case "${1:-}" in
    # =======================================================================
    # Build & Deploy
    # =======================================================================
    rocket)                                printf '\xF0\x9F\x9A\x80' ;;
    ship)                                  printf '\xF0\x9F\x9A\xA2' ;;
    package)                               printf '\xF0\x9F\x93\xA6' ;;
    construction)                          printf '\xF0\x9F\x9A\xA7' ;;
    hammer)                                printf '\xF0\x9F\x94\xA8' ;;
    hammer-wrench|tools|build-tools)       printf '\xF0\x9F\x9B\xA0' ;;
    nut-bolt|hardware|fastener)            printf '\xF0\x9F\x94\xA9' ;;
    bricks|blocks|wall|foundation)         printf '\xF0\x9F\xA7\xB1' ;;
    label|tag|version|release)             printf '\xF0\x9F\x8F\xB7' ;;
    factory|manufacture|industry)          printf '\xF0\x9F\x8F\xAD' ;;

    # =======================================================================
    # Status
    # =======================================================================
    check|done)                            printf '\xE2\x9C\x85' ;;
    cross|fail)                            printf '\xE2\x9D\x8C' ;;
    warning|warn)                          printf '\xE2\x9A\xA0' ;;
    stop)                                  printf '\xF0\x9F\x9B\x91' ;;
    hourglass|wait)                        printf '\xE2\x8F\xB3' ;;
    no-entry|forbidden|blocked|deny)       printf '\xE2\x9B\x94' ;;
    prohibited|banned|no-sign)             printf '\xF0\x9F\x9A\xAB' ;;
    exclamation|important|bang-mark)       printf '\xE2\x9D\x97' ;;
    question-mark|help-mark)               printf '\xE2\x9D\x93' ;;
    infinity|forever|endless)              printf '\xE2\x99\xBE' ;;

    # =======================================================================
    # Activity & Dev
    # =======================================================================
    bug)                                   printf '\xF0\x9F\x90\x9B' ;;
    fire)                                  printf '\xF0\x9F\x94\xA5' ;;
    test|lab)                              printf '\xF0\x9F\xA7\xAA' ;;
    search|mag)                            printf '\xF0\x9F\x94\x8D' ;;
    wrench|fix)                            printf '\xF0\x9F\x94\xA7' ;;
    gear|config)                           printf '\xE2\x9A\x99' ;;
    lock|secure)                           printf '\xF0\x9F\x94\x92' ;;
    key)                                   printf '\xF0\x9F\x94\x91' ;;
    trash|delete|wastebasket|garbage|rubbish) printf '\xF0\x9F\x97\x91' ;;
    terminal|console|cli|prompt|shell)     printf '\xF0\x9F\x96\xA5' ;;
    laptop|computer|pc|mac)                printf '\xF0\x9F\x92\xBB' ;;
    keyboard|type|input|keys)              printf '\xE2\x8C\xA8' ;;
    printer|print)                         printf '\xF0\x9F\x96\xA8' ;;
    disk|floppy|save|backup)               printf '\xF0\x9F\x92\xBE' ;;
    cd|disc|dvd|optical)                   printf '\xF0\x9F\x92\xBF' ;;
    toolbox|toolkit|devtools|swiss-army)   printf '\xF0\x9F\xA7\xB0' ;;
    microscope|research|examine)           printf '\xF0\x9F\x94\xAC' ;;
    telescope|observe|astronomy)           printf '\xF0\x9F\x94\xAD' ;;
    crystal-ball|fortune|predict)          printf '\xF0\x9F\x94\xAE' ;;
    magnet|attract|pull)                   printf '\xF0\x9F\xA7\xB2' ;;
    dna|genetics|helix|genome)             printf '\xF0\x9F\xA7\xAC' ;;
    petri-dish|culture|grow|incubate)      printf '\xF0\x9F\xA7\xAB' ;;
    abacus|count|tally|legacy)             printf '\xF0\x9F\xA7\xAE' ;;
    atom|physics|science-symbol)           printf '\xE2\x9A\x9B' ;;
    hook|webhook|callback|trigger)         printf '\xF0\x9F\xAA\x9D' ;;
    chains|linked|blockchain|connection)   printf '\xE2\x9B\x93' ;;
    plug|electric-plug|outlet|socket)      printf '\xF0\x9F\x94\x8C' ;;
    battery|power|charge|energy)           printf '\xF0\x9F\x94\x8B' ;;
    broom|cleanup|sweep|tidy)              printf '\xF0\x9F\xA7\xB9' ;;
    sponge|wipe|scrub|absorb)              printf '\xF0\x9F\xA7\xBD' ;;
    fire-extinguisher|suppress|douse)      printf '\xF0\x9F\xA7\xAF' ;;
    plunger|unclog|unstick|fix-pipe)       printf '\xF0\x9F\xAA\xA0' ;;
    mousetrap|catch-bug|snare)             printf '\xF0\x9F\xAA\xA4' ;;
    ladder|climb-up|elevate)               printf '\xF0\x9F\xAA\x9C' ;;
    knot|tied|tangled|complex)             printf '\xF0\x9F\xAA\xA2' ;;
    bucket|pail|container)                 printf '\xF0\x9F\xAA\xA3' ;;

    # =======================================================================
    # Communication & Review
    # =======================================================================
    eyes|review)                           printf '\xF0\x9F\x91\x80' ;;
    chat|discuss|speech|balloon)           printf '\xF0\x9F\x92\xAC' ;;
    mail|email)                            printf '\xF0\x9F\x93\xA7' ;;
    bell|alert)                            printf '\xF0\x9F\x94\x94' ;;
    phone|call|mobile|cell)                printf '\xF0\x9F\x93\xB1' ;;
    envelope|letter|mail-env)              printf '\xE2\x9C\x89' ;;
    inbox|tray|incoming)                   printf '\xF0\x9F\x93\xA5' ;;
    outbox|send|outgoing)                  printf '\xF0\x9F\x93\xA4' ;;
    mailbox|letterbox|post)                printf '\xF0\x9F\x93\xAC' ;;
    radio|broadcast|fm|am)                 printf '\xF0\x9F\x93\xBB' ;;
    satellite-dish|signal|antenna|receive) printf '\xF0\x9F\x93\xA1' ;;
    newspaper|news|press|media)            printf '\xF0\x9F\x93\xB0' ;;
    thought|thought-bubble)                printf '\xF0\x9F\x92\xAD' ;;

    # =======================================================================
    # Data & Infra
    # =======================================================================
    db|database|file-cabinet|archive|storage|vault) printf '\xF0\x9F\x97\x84' ;;
    cloud)                                 printf '\xE2\x98\x81' ;;
    link)                                  printf '\xF0\x9F\x94\x97' ;;
    electric|zap)                          printf '\xE2\x9A\xA1' ;;
    globe-web|www|internet|web|network)    printf '\xF0\x9F\x8C\x90' ;;
    satellite|orbit|space)                 printf '\xF0\x9F\x9B\xB0' ;;
    earth|globe|world)                     printf '\xF0\x9F\x8C\x8D' ;;
    compass|direction|navigate)            printf '\xF0\x9F\xA7\xAD' ;;
    folder|directory|dir)                  printf '\xF0\x9F\x93\x81' ;;
    folder-open|browse|explore)            printf '\xF0\x9F\x93\x82' ;;
    page|document|doc)                     printf '\xF0\x9F\x93\x84' ;;
    scroll|parchment|ancient)              printf '\xF0\x9F\x93\x9C' ;;

    # =======================================================================
    # Progress & Time
    # =======================================================================
    sparkle|clean)                         printf '\xE2\x9C\xA8' ;;
    star)                                  printf '\xE2\xAD\x90' ;;
    coffee|break)                          printf '\xE2\x98\x95' ;;
    sleep|zzz)                             printf '\xF0\x9F\x92\xA4' ;;
    brain|think)                           printf '\xF0\x9F\xA7\xA0' ;;
    books|docs)                            printf '\xF0\x9F\x93\x9A' ;;
    pin)                                   printf '\xF0\x9F\x93\x8C' ;;
    clipboard)                             printf '\xF0\x9F\x93\x8B' ;;
    chart)                                 printf '\xF0\x9F\x93\x8A' ;;
    chart-up|trending|growth|stonks)       printf '\xF0\x9F\x93\x88' ;;
    chart-down|decline|loss|crash-chart)   printf '\xF0\x9F\x93\x89' ;;
    alarm|timer|clock-alarm)               printf '\xE2\x8F\xB0' ;;
    watch|time|clock-watch)                printf '\xE2\x8C\x9A' ;;
    calendar|date|event|schedule)          printf '\xF0\x9F\x93\x85' ;;
    target|bullseye|goal|aim)              printf '\xF0\x9F\x8E\xAF' ;;

    # =======================================================================
    # Miscellaneous — Celebration & Symbols
    # =======================================================================
    tada|celebrate)                        printf '\xF0\x9F\x8E\x89' ;;
    art|design)                            printf '\xF0\x9F\x8E\xA8' ;;
    bulb|idea)                             printf '\xF0\x9F\x92\xA1' ;;
    shield|protect)                        printf '\xF0\x9F\x9B\xA1' ;;
    recycle|refactor)                      printf '\xE2\x99\xBB' ;;
    truck|move)                            printf '\xF0\x9F\x9A\x9A' ;;
    memo|note)                             printf '\xF0\x9F\x93\x9D' ;;
    gift|present|surprise|wrapped)         printf '\xF0\x9F\x8E\x81' ;;
    balloon|party-balloon|inflate)         printf '\xF0\x9F\x8E\x88' ;;
    confetti|celebration|festive)          printf '\xF0\x9F\x8E\x8A' ;;
    trophy|winner|champion|cup)            printf '\xF0\x9F\x8F\x86' ;;
    medal|award|prize|gold)                printf '\xF0\x9F\x8F\x85' ;;
    ticket|pass|admission|entry)           printf '\xF0\x9F\x8E\xAB' ;;
    crown|king|queen|royal|ruler)          printf '\xF0\x9F\x91\x91' ;;
    gem|diamond|jewel|precious)            printf '\xF0\x9F\x92\x8E' ;;
    hundred|100|perfect|score)             printf '\xF0\x9F\x92\xAF' ;;
    boom|explosion|bang|collision|crash)    printf '\xF0\x9F\x92\xA5' ;;
    flashlight|torch|light)                printf '\xF0\x9F\x94\xA6' ;;
    candle|flame|wax)                      printf '\xF0\x9F\x95\xAF' ;;
    door|entrance|exit|gateway)            printf '\xF0\x9F\x9A\xAA' ;;
    window-pane|viewport)                  printf '\xF0\x9F\xAA\x9F' ;;
    magician|wizard|wand)                  printf '\xF0\x9F\xAA\x84' ;;
    mirror-ball|disco|dance)               printf '\xF0\x9F\xAA\xA9' ;;
    joker|wildcard|trump)                  printf '\xF0\x9F\x83\x8F' ;;

    # =======================================================================
    # Smileys & Emotion
    # =======================================================================
    smile|happy)                           printf '\xF0\x9F\x98\x8A' ;;
    grin)                                  printf '\xF0\x9F\x98\x81' ;;
    laugh|lol)                             printf '\xF0\x9F\x98\x82' ;;
    rofl)                                  printf '\xF0\x9F\xA4\xA3' ;;
    wink)                                  printf '\xF0\x9F\x98\x89' ;;
    love-eyes|heart-eyes)                  printf '\xF0\x9F\x98\x8D' ;;
    cool|sunglasses)                       printf '\xF0\x9F\x98\x8E' ;;
    hmm|wondering)                         printf '\xF0\x9F\xA4\x94' ;;
    shush|quiet)                           printf '\xF0\x9F\xA4\xAB' ;;
    sweat)                                 printf '\xF0\x9F\x98\x85' ;;
    cry|sob)                               printf '\xF0\x9F\x98\xA2' ;;
    angry|mad)                             printf '\xF0\x9F\x98\xA0' ;;
    rage|fury)                             printf '\xF0\x9F\x98\xA1' ;;
    scream|horror)                         printf '\xF0\x9F\x98\xB1' ;;
    sick|nausea)                           printf '\xF0\x9F\xA4\xA2' ;;
    dizzy-face)                            printf '\xF0\x9F\x98\xB5' ;;
    nerd)                                  printf '\xF0\x9F\xA4\x93' ;;
    monocle|inspect)                       printf '\xF0\x9F\xA7\x90' ;;
    party-face|celebrate-face)             printf '\xF0\x9F\xA5\xB3' ;;
    yawn|tired)                            printf '\xF0\x9F\xA5\xB1' ;;
    melting|melt|dissolve|hot-face)        printf '\xF0\x9F\xAB\xA0' ;;
    peeking|peek|spy-face|sneak)           printf '\xF0\x9F\xAB\xA3' ;;

    # =======================================================================
    # Gestures & Body
    # =======================================================================
    wave|hi|bye)                           printf '\xF0\x9F\x91\x8B' ;;
    ok|okay)                               printf '\xF0\x9F\x91\x8C' ;;
    thumbsup|like|approve)                 printf '\xF0\x9F\x91\x8D' ;;
    thumbsdown|dislike|reject)             printf '\xF0\x9F\x91\x8E' ;;
    clap|applause)                         printf '\xF0\x9F\x91\x8F' ;;
    pray|thanks|namaste)                   printf '\xF0\x9F\x99\x8F' ;;
    muscle|strong|flex)                    printf '\xF0\x9F\x92\xAA' ;;
    fist|punch|bump)                       printf '\xF0\x9F\x91\x8A' ;;
    victory|peace-sign)                    printf '\xE2\x9C\x8C' ;;
    crossed-fingers|luck)                  printf '\xF0\x9F\xA4\x9E' ;;
    handshake|deal|agree)                  printf '\xF0\x9F\xA4\x9D' ;;
    point-right)                           printf '\xF0\x9F\x91\x89' ;;
    point-left)                            printf '\xF0\x9F\x91\x88' ;;
    point-up)                              printf '\xE2\x98\x9D' ;;
    point-down)                            printf '\xF0\x9F\x91\x87' ;;
    raised-hand|stop-hand|halt)            printf '\xE2\x9C\x8B' ;;
    salute)                                printf '\xF0\x9F\xAB\xA1' ;;

    # =======================================================================
    # People & Characters
    # =======================================================================
    skull|dead|rip)                        printf '\xF0\x9F\x92\x80' ;;
    ghost)                                 printf '\xF0\x9F\x91\xBB' ;;
    robot|bot)                             printf '\xF0\x9F\xA4\x96' ;;
    alien)                                 printf '\xF0\x9F\x91\xBD' ;;
    clown)                                 printf '\xF0\x9F\xA4\xA1' ;;
    poop|crap)                             printf '\xF0\x9F\x92\xA9' ;;
    ninja)                                 printf '\xF0\x9F\xA5\xB7' ;;
    detective|spy)                         printf '\xF0\x9F\x95\xB5' ;;

    # =======================================================================
    # Hearts & Emotion Symbols
    # =======================================================================
    heart|love-heart|red-heart)            printf '\xE2\x9D\xA4' ;;
    broken-heart|heartbreak)               printf '\xF0\x9F\x92\x94' ;;
    sparkling-heart|glowing-heart)         printf '\xF0\x9F\x92\x96' ;;
    sweat-drops|effort|splash)             printf '\xF0\x9F\x92\xA6' ;;
    anger-symbol|fury-mark)                printf '\xF0\x9F\x92\xA2' ;;
    droplet|water|drip)                    printf '\xF0\x9F\x92\xA7' ;;

    # =======================================================================
    # Animals
    # =======================================================================
    dog|puppy)                             printf '\xF0\x9F\x90\xB6' ;;
    cat|kitty)                             printf '\xF0\x9F\x90\xB1' ;;
    fox)                                   printf '\xF0\x9F\xA6\x8A' ;;
    bear)                                  printf '\xF0\x9F\x90\xBB' ;;
    panda)                                 printf '\xF0\x9F\x90\xBC' ;;
    monkey)                                printf '\xF0\x9F\x90\xB5' ;;
    chicken|hen)                           printf '\xF0\x9F\x90\x94' ;;
    penguin)                               printf '\xF0\x9F\x90\xA7' ;;
    bird|tweet)                            printf '\xF0\x9F\x90\xA6' ;;
    eagle)                                 printf '\xF0\x9F\xA6\x85' ;;
    owl)                                   printf '\xF0\x9F\xA6\x89' ;;
    bat)                                   printf '\xF0\x9F\xA6\x87' ;;
    butterfly)                             printf '\xF0\x9F\xA6\x8B' ;;
    snake)                                 printf '\xF0\x9F\x90\x8D' ;;
    dragon)                                printf '\xF0\x9F\x90\x89' ;;
    whale)                                 printf '\xF0\x9F\x90\xB3' ;;
    dolphin)                               printf '\xF0\x9F\x90\xAC' ;;
    octopus)                               printf '\xF0\x9F\x90\x99' ;;
    snail|slow)                            printf '\xF0\x9F\x90\x8C' ;;
    turtle|tortoise)                       printf '\xF0\x9F\x90\xA2' ;;
    crab|crustacean)                       printf '\xF0\x9F\xA6\x80' ;;
    spider)                                printf '\xF0\x9F\x95\xB7' ;;
    scorpion)                              printf '\xF0\x9F\xA6\x82' ;;
    unicorn|magic)                         printf '\xF0\x9F\xA6\x84' ;;
    bee|honeybee|buzz)                     printf '\xF0\x9F\x90\x9D' ;;
    ant)                                   printf '\xF0\x9F\x90\x9C' ;;
    ladybug)                               printf '\xF0\x9F\x90\x9E' ;;
    shark)                                 printf '\xF0\x9F\xA6\x88' ;;
    wolf)                                  printf '\xF0\x9F\x90\xBA' ;;
    horse|pony)                            printf '\xF0\x9F\x90\xB4' ;;
    pig|oink)                              printf '\xF0\x9F\x90\xB7' ;;
    frog|toad)                             printf '\xF0\x9F\x90\xB8' ;;
    gorilla|ape)                           printf '\xF0\x9F\xA6\x8D' ;;
    deer|stag)                             printf '\xF0\x9F\xA6\x8C' ;;
    rabbit|bunny)                          printf '\xF0\x9F\x90\xB0' ;;
    mouse|rodent)                          printf '\xF0\x9F\x90\xAD' ;;
    camel)                                 printf '\xF0\x9F\x90\xAB' ;;
    elephant)                              printf '\xF0\x9F\x90\x98' ;;
    lion)                                  printf '\xF0\x9F\xA6\x81' ;;
    tiger)                                 printf '\xF0\x9F\x90\xAF' ;;
    crocodile|croc|gator)                  printf '\xF0\x9F\x90\x8A' ;;
    parrot)                                printf '\xF0\x9F\xA6\x9C' ;;
    flamingo)                              printf '\xF0\x9F\xA6\xA9' ;;
    peacock)                               printf '\xF0\x9F\xA6\x9A' ;;
    lobster)                               printf '\xF0\x9F\xA6\x9E' ;;
    shrimp|prawn)                          printf '\xF0\x9F\xA6\x90' ;;
    squid)                                 printf '\xF0\x9F\xA6\x91' ;;
    hedgehog|porcupine)                    printf '\xF0\x9F\xA6\x94' ;;
    raccoon|trash-panda)                   printf '\xF0\x9F\xA6\x9D' ;;
    sloth|lazy)                            printf '\xF0\x9F\xA6\xA5' ;;
    otter)                                 printf '\xF0\x9F\xA6\xA6' ;;
    skunk|stink)                           printf '\xF0\x9F\xA6\xA8' ;;
    mammoth|woolly)                        printf '\xF0\x9F\xA6\xA3' ;;
    dodo|extinct)                          printf '\xF0\x9F\xA6\xA4' ;;
    microbe|germ|bacteria)                 printf '\xF0\x9F\xA6\xA0' ;;

    # =======================================================================
    # Nature & Weather
    # =======================================================================
    tree|evergreen)                        printf '\xF0\x9F\x8C\xB2' ;;
    palm-tree|tropical)                    printf '\xF0\x9F\x8C\xB4' ;;
    flower|blossom|cherry)                 printf '\xF0\x9F\x8C\xB8' ;;
    rose)                                  printf '\xF0\x9F\x8C\xB9' ;;
    sunflower)                             printf '\xF0\x9F\x8C\xBB' ;;
    leaf|leaves|wind-leaf)                 printf '\xF0\x9F\x8D\x83' ;;
    herb|plant|seedling)                   printf '\xF0\x9F\x8C\xBF' ;;
    mushroom|fungi|toadstool)              printf '\xF0\x9F\x8D\x84' ;;
    cactus)                                printf '\xF0\x9F\x8C\xB5' ;;
    sun|sunny)                             printf '\xE2\x98\x80' ;;
    moon|crescent)                         printf '\xF0\x9F\x8C\x99' ;;
    full-moon)                             printf '\xF0\x9F\x8C\x95' ;;
    rainbow)                               printf '\xF0\x9F\x8C\x88' ;;
    snowflake|frozen|cold)                 printf '\xE2\x9D\x84' ;;
    tornado|cyclone|twister)               printf '\xF0\x9F\x8C\xAA' ;;
    ocean|waves|sea)                       printf '\xF0\x9F\x8C\x8A' ;;
    volcano|eruption|lava)                 printf '\xF0\x9F\x8C\x8B' ;;
    comet|meteor|shooting-star)            printf '\xE2\x98\x84' ;;
    umbrella|rain-cover)                   printf '\xE2\x98\x82' ;;
    lotus|zen|mindful|calm)                printf '\xF0\x9F\xAA\xB7' ;;
    feather|lightweight|quill)             printf '\xF0\x9F\xAA\xB6' ;;
    coral|reef|marine)                     printf '\xF0\x9F\xAA\xB8' ;;
    nest|nested|home-base)                 printf '\xF0\x9F\xAA\xB9' ;;

    # =======================================================================
    # Food & Drink
    # =======================================================================
    apple|fruit)                           printf '\xF0\x9F\x8D\x8E' ;;
    banana)                                printf '\xF0\x9F\x8D\x8C' ;;
    grapes|vine)                           printf '\xF0\x9F\x8D\x87' ;;
    watermelon|melon)                      printf '\xF0\x9F\x8D\x89' ;;
    lemon|citrus|sour)                     printf '\xF0\x9F\x8D\x8B' ;;
    peach)                                 printf '\xF0\x9F\x8D\x91' ;;
    cherry|cherries)                       printf '\xF0\x9F\x8D\x92' ;;
    strawberry)                            printf '\xF0\x9F\x8D\x93' ;;
    tomato)                                printf '\xF0\x9F\x8D\x85' ;;
    avocado)                               printf '\xF0\x9F\xA5\x91' ;;
    eggplant|aubergine)                    printf '\xF0\x9F\x8D\x86' ;;
    pepper|hot|spicy|chili)                printf '\xF0\x9F\x8C\xB6' ;;
    pizza|pie)                             printf '\xF0\x9F\x8D\x95' ;;
    burger|hamburger)                      printf '\xF0\x9F\x8D\x94' ;;
    fries|chips|french-fries)              printf '\xF0\x9F\x8D\x9F' ;;
    hotdog|sausage|frank)                  printf '\xF0\x9F\x8C\xAD' ;;
    taco)                                  printf '\xF0\x9F\x8C\xAE' ;;
    burrito|wrap)                          printf '\xF0\x9F\x8C\xAF' ;;
    sushi|japanese)                        printf '\xF0\x9F\x8D\xA3' ;;
    ramen|noodles|soup)                    printf '\xF0\x9F\x8D\x9C' ;;
    cake|birthday|bday)                    printf '\xF0\x9F\x8E\x82' ;;
    cookie|biscuit)                        printf '\xF0\x9F\x8D\xAA' ;;
    chocolate|candy-bar)                   printf '\xF0\x9F\x8D\xAB' ;;
    donut|doughnut|pastry)                 printf '\xF0\x9F\x8D\xA9' ;;
    ice-cream|icecream|gelato)             printf '\xF0\x9F\x8D\xA8' ;;
    honey|honeypot|sweet)                  printf '\xF0\x9F\x8D\xAF' ;;
    beer|brew|pint)                        printf '\xF0\x9F\x8D\xBA' ;;
    wine|glass|vino)                       printf '\xF0\x9F\x8D\xB7' ;;
    cocktail|martini|drink)                printf '\xF0\x9F\x8D\xB8' ;;
    popcorn)                               printf '\xF0\x9F\x8D\xBF' ;;
    bread|loaf|toast)                      printf '\xF0\x9F\x8D\x9E' ;;
    cheese|cheddar)                        printf '\xF0\x9F\xA7\x80' ;;
    meat|steak|beef)                       printf '\xF0\x9F\xA5\xA9' ;;
    bacon|pork)                            printf '\xF0\x9F\xA5\x93' ;;
    candy|lollipop|sweet-treat)            printf '\xF0\x9F\x8D\xAC' ;;
    cupcake|muffin)                        printf '\xF0\x9F\xA7\x81' ;;
    salt|seasoning)                        printf '\xF0\x9F\xA7\x82' ;;
    beans|coffee-beans|java)               printf '\xF0\x9F\xAB\x98' ;;
    jar|preserve|store)                    printf '\xF0\x9F\xAB\x99' ;;

    # =======================================================================
    # Travel & Transport
    # =======================================================================
    car|auto|drive|vehicle)                printf '\xF0\x9F\x9A\x97' ;;
    taxi|cab)                              printf '\xF0\x9F\x9A\x95' ;;
    bus|transit)                            printf '\xF0\x9F\x9A\x8C' ;;
    ambulance|ems|emergency)               printf '\xF0\x9F\x9A\x91' ;;
    fire-truck|firetruck)                  printf '\xF0\x9F\x9A\x92' ;;
    police-car|cop|patrol)                 printf '\xF0\x9F\x9A\x93' ;;
    train|rail|locomotive)                 printf '\xF0\x9F\x9A\x86' ;;
    airplane|plane|flight|jet)             printf '\xE2\x9C\x88' ;;
    helicopter|chopper|heli)               printf '\xF0\x9F\x9A\x81' ;;
    sailboat|boat|sailing)                 printf '\xE2\x9B\xB5' ;;
    anchor|dock|port)                      printf '\xE2\x9A\x93' ;;
    fuel|gas|petrol|pump)                  printf '\xE2\x9B\xBD' ;;
    bike|bicycle|cycle)                    printf '\xF0\x9F\x9A\xB2' ;;

    # =======================================================================
    # Places & Buildings
    # =======================================================================
    house|home)                            printf '\xF0\x9F\x8F\xA0' ;;
    office|building|corp)                  printf '\xF0\x9F\x8F\xA2' ;;
    hospital|medical|health-bldg)          printf '\xF0\x9F\x8F\xA5' ;;
    school|education|learn)                printf '\xF0\x9F\x8F\xAB' ;;
    castle|fortress|fort)                  printf '\xF0\x9F\x8F\xB0' ;;
    tent|camp|camping|outdoor)             printf '\xE2\x9B\xBA' ;;
    church|worship|chapel)                 printf '\xE2\x9B\xAA' ;;

    # =======================================================================
    # Writing & Office
    # =======================================================================
    book|read|manual|textbook)             printf '\xF0\x9F\x93\x96' ;;
    notebook|journal|diary)                printf '\xF0\x9F\x93\x93' ;;
    pencil|write|edit|compose)             printf '\xE2\x9C\x8F' ;;
    pen|author|ink)                        printf '\xF0\x9F\x96\x8A' ;;
    paintbrush|paint|brush)                printf '\xF0\x9F\x96\x8C' ;;
    crayon|draw|sketch|color)              printf '\xF0\x9F\x96\x8D' ;;
    paperclip|attach|attachment)           printf '\xF0\x9F\x93\x8E' ;;
    scissors|cut|snip|trim)                printf '\xE2\x9C\x82' ;;
    ruler|measure|length)                  printf '\xF0\x9F\x93\x8F' ;;
    camera|photo|snap|picture)             printf '\xF0\x9F\x93\xB7' ;;
    clapper|film|movie|action)             printf '\xF0\x9F\x8E\xAC' ;;
    tv|television|screen|monitor)          printf '\xF0\x9F\x93\xBA' ;;

    # =======================================================================
    # Music & Sound
    # =======================================================================
    music|song|tune|melody)                printf '\xF0\x9F\x8E\xB5' ;;
    guitar|rock|strum)                     printf '\xF0\x9F\x8E\xB8' ;;
    drum|beat|rhythm)                      printf '\xF0\x9F\xA5\x81' ;;
    trumpet|horn|fanfare|brass)            printf '\xF0\x9F\x8E\xBA' ;;
    microphone|mic|karaoke|sing)           printf '\xF0\x9F\x8E\xA4' ;;
    headphones|audio|listen|earphones)     printf '\xF0\x9F\x8E\xA7' ;;
    speaker|volume|sound|loud)             printf '\xF0\x9F\x94\x8A' ;;
    mute|silent|no-sound|quiet-speaker)    printf '\xF0\x9F\x94\x87' ;;

    # =======================================================================
    # Sports & Activities
    # =======================================================================
    soccer|football|kick)                  printf '\xE2\x9A\xBD' ;;
    basketball|bball|hoop)                 printf '\xF0\x9F\x8F\x80' ;;
    baseball|bat-ball)                     printf '\xE2\x9A\xBE' ;;
    tennis|racket|serve)                   printf '\xF0\x9F\x8E\xBE' ;;
    golf|putt|tee)                         printf '\xE2\x9B\xB3' ;;
    boxing|fight-glove|bout)               printf '\xF0\x9F\xA5\x8A' ;;
    bowling|strike|pins)                   printf '\xF0\x9F\x8E\xB3' ;;
    gaming|joystick|game|play)             printf '\xF0\x9F\x8E\xAE' ;;
    puzzle|jigsaw|piece|solve|component|module) printf '\xF0\x9F\xA7\xA9' ;;
    chess|strategy|checkmate)              printf '\xE2\x99\x9F' ;;
    dice|random|chance|roll)               printf '\xF0\x9F\x8E\xB2' ;;
    fishing|catch|rod)                     printf '\xF0\x9F\x8E\xA3' ;;
    surfing|surf|wave-ride)                printf '\xF0\x9F\x8F\x84' ;;
    swimming|swim|pool|lap)                printf '\xF0\x9F\x8F\x8A' ;;
    running|run|sprint|jog)                printf '\xF0\x9F\x8F\x83' ;;
    eight-ball|pool|billiards)             printf '\xF0\x9F\x8E\xB1' ;;
    slot-machine|jackpot|gamble)           printf '\xF0\x9F\x8E\xB0' ;;
    mahjong|tile)                          printf '\xF0\x9F\x80\x84' ;;

    # =======================================================================
    # Combat & Danger
    # =======================================================================
    bomb|explosive|detonate)               printf '\xF0\x9F\x92\xA3' ;;
    sword|fight|blade)                     printf '\xE2\x9A\x94' ;;
    axe|chop|hatchet)                      printf '\xF0\x9F\xAA\x93' ;;
    radioactive|nuclear|hazard)            printf '\xE2\x98\xA2' ;;
    biohazard|toxic|danger)                printf '\xE2\x98\xA3' ;;

    # =======================================================================
    # Arrows & Shapes
    # =======================================================================
    arrow-up|ascending|upward)             printf '\xE2\xAC\x86' ;;
    arrow-down|descending|downward)        printf '\xE2\xAC\x87' ;;
    arrow-left|back|backward)              printf '\xE2\xAC\x85' ;;
    arrow-right|forward|next|ahead)        printf '\xE2\x9E\xA1' ;;
    arrows-rotate|sync|refresh|reload)     printf '\xF0\x9F\x94\x84' ;;
    cycle|repeat|loop-arrows|redo)         printf '\xF0\x9F\x94\x83' ;;
    plus|add|new|create)                   printf '\xE2\x9E\x95' ;;
    minus|subtract|remove|delete-sign)     printf '\xE2\x9E\x96' ;;
    multiply|times|x-mark|cross-mark)      printf '\xE2\x9C\x96' ;;
    divide|split|separate)                 printf '\xE2\x9E\x97' ;;
    red-circle)                            printf '\xF0\x9F\x94\xB4' ;;
    orange-circle)                         printf '\xF0\x9F\x9F\xA0' ;;
    yellow-circle)                         printf '\xF0\x9F\x9F\xA1' ;;
    green-circle)                          printf '\xF0\x9F\x9F\xA2' ;;
    blue-circle)                           printf '\xF0\x9F\x94\xB5' ;;
    purple-circle)                         printf '\xF0\x9F\x9F\xA3' ;;
    white-circle)                          printf '\xE2\x9A\xAA' ;;
    black-circle)                          printf '\xE2\x9A\xAB' ;;
    red-square)                            printf '\xF0\x9F\x9F\xA5' ;;
    green-square)                          printf '\xF0\x9F\x9F\xA9' ;;
    blue-square)                           printf '\xF0\x9F\x9F\xA6' ;;

    # =======================================================================
    # Money & Finance
    # =======================================================================
    currency|dollar|money|usd)             printf '\xF0\x9F\x92\xB2' ;;
    moneybag|rich|cash|funds)              printf '\xF0\x9F\x92\xB0' ;;
    credit-card|payment|pay|swipe)         printf '\xF0\x9F\x92\xB3' ;;

    # =======================================================================
    # Flags
    # =======================================================================
    flag|banner|pennant)                   printf '\xF0\x9F\x8F\xB4' ;;
    white-flag|surrender|truce)            printf '\xF0\x9F\x8F\xB3' ;;
    checkered-flag|finish|race|complete)   printf '\xF0\x9F\x8F\x81' ;;
    triangular-flag|marker|waypoint)       printf '\xF0\x9F\x9A\xA9' ;;

    # =======================================================================
    # Peace & Philosophy
    # =======================================================================
    peace|antiwar|peace-symbol)            printf '\xE2\x98\xAE' ;;
    yin-yang|balance|harmony)              printf '\xE2\x98\xAF' ;;

    *)
      _tabbing_out -v 0 -e "tabbing: unknown emoji '%s'\n" "$1"
      _tabbing_out -v 0 -e "tabbing: use 'tabbing-on --emoji-list' to see available emojis\n"
      _tabbing_out -v 0 -e "tabbing: use 'tabbing-on -emoji:search' to search emojis\n"
      return 1
      ;;
  esac
}

# ---------------------------------------------------------------------------
# Check if a string is a known emoji name
# ---------------------------------------------------------------------------
_tabbing_is_known_emoji() {
  case "${1:-}" in
    # Build & Deploy
    rocket|ship|package|construction|hammer) return 0 ;;
    hammer-wrench|tools|build-tools|nut-bolt|hardware|fastener) return 0 ;;
    bricks|blocks|wall|foundation|label|tag|version|release) return 0 ;;
    factory|manufacture|industry) return 0 ;;
    # Status
    check|done|cross|fail|warning|warn|stop|hourglass|wait) return 0 ;;
    no-entry|forbidden|blocked|deny|prohibited|banned|no-sign) return 0 ;;
    exclamation|important|bang-mark|question-mark|help-mark) return 0 ;;
    infinity|forever|endless) return 0 ;;
    # Activity & Dev
    bug|fire|test|lab|search|mag|wrench|fix|gear|config) return 0 ;;
    lock|secure|key|trash|delete|wastebasket|garbage|rubbish) return 0 ;;
    terminal|console|cli|prompt|shell) return 0 ;;
    laptop|computer|pc|mac|keyboard|type|input|keys) return 0 ;;
    printer|print|disk|floppy|save|backup|cd|disc|dvd|optical) return 0 ;;
    toolbox|toolkit|devtools|swiss-army) return 0 ;;
    microscope|research|examine|telescope|observe|astronomy) return 0 ;;
    crystal-ball|fortune|predict|magnet|attract|pull) return 0 ;;
    dna|genetics|helix|genome|petri-dish|culture|grow|incubate) return 0 ;;
    abacus|count|tally|legacy|atom|physics|science-symbol) return 0 ;;
    hook|webhook|callback|trigger) return 0 ;;
    chains|linked|blockchain|connection) return 0 ;;
    plug|electric-plug|outlet|socket|battery|power|charge|energy) return 0 ;;
    broom|cleanup|sweep|tidy|sponge|wipe|scrub|absorb) return 0 ;;
    fire-extinguisher|suppress|douse) return 0 ;;
    plunger|unclog|unstick|fix-pipe|mousetrap|catch-bug|snare) return 0 ;;
    ladder|climb-up|elevate|knot|tied|tangled|complex) return 0 ;;
    bucket|pail|container) return 0 ;;
    # Communication & Review
    eyes|review|chat|discuss|speech|balloon) return 0 ;;
    mail|email|bell|alert|phone|call|mobile|cell) return 0 ;;
    envelope|letter|mail-env|inbox|tray|incoming) return 0 ;;
    outbox|send|outgoing|mailbox|letterbox|post) return 0 ;;
    radio|broadcast|fm|am|satellite-dish|signal|antenna|receive) return 0 ;;
    newspaper|news|press|media|thought|thought-bubble) return 0 ;;
    # Data & Infra
    db|database|file-cabinet|archive|storage|vault) return 0 ;;
    cloud|link|electric|zap) return 0 ;;
    globe-web|www|internet|web|network) return 0 ;;
    satellite|orbit|space|earth|globe|world) return 0 ;;
    compass|direction|navigate) return 0 ;;
    folder|directory|dir|folder-open|browse|explore) return 0 ;;
    page|document|doc|scroll|parchment|ancient) return 0 ;;
    # Progress & Time
    sparkle|clean|star|coffee|break|sleep|zzz) return 0 ;;
    brain|think|books|docs|pin|clipboard|chart) return 0 ;;
    chart-up|trending|growth|stonks|chart-down|decline|loss|crash-chart) return 0 ;;
    alarm|timer|clock-alarm|watch|time|clock-watch) return 0 ;;
    calendar|date|event|schedule|target|bullseye|goal|aim) return 0 ;;
    # Miscellaneous
    tada|celebrate|art|design|bulb|idea|shield|protect) return 0 ;;
    recycle|refactor|truck|move|memo|note) return 0 ;;
    gift|present|surprise|wrapped|balloon|party-balloon|inflate) return 0 ;;
    confetti|celebration|festive) return 0 ;;
    trophy|winner|champion|cup|medal|award|prize|gold) return 0 ;;
    ticket|pass|admission|entry) return 0 ;;
    crown|king|queen|royal|ruler) return 0 ;;
    gem|diamond|jewel|precious|hundred|100|perfect|score) return 0 ;;
    boom|explosion|bang|collision|crash) return 0 ;;
    flashlight|torch|light|candle|flame|wax) return 0 ;;
    door|entrance|exit|gateway|window-pane|viewport) return 0 ;;
    magician|wizard|wand|mirror-ball|disco|dance) return 0 ;;
    joker|wildcard|trump) return 0 ;;
    # Smileys & Emotion
    smile|happy|grin|laugh|lol|rofl|wink) return 0 ;;
    love-eyes|heart-eyes|cool|sunglasses) return 0 ;;
    hmm|wondering|shush|quiet|sweat) return 0 ;;
    cry|sob|angry|mad|rage|fury|scream|horror) return 0 ;;
    sick|nausea|dizzy-face|nerd|monocle|inspect) return 0 ;;
    party-face|celebrate-face|yawn|tired) return 0 ;;
    melting|melt|dissolve|hot-face|peeking|peek|spy-face|sneak) return 0 ;;
    # Gestures & Body
    wave|hi|bye|ok|okay) return 0 ;;
    thumbsup|like|approve|thumbsdown|dislike|reject) return 0 ;;
    clap|applause|pray|thanks|namaste) return 0 ;;
    muscle|strong|flex|fist|punch|bump) return 0 ;;
    victory|peace-sign|crossed-fingers|luck) return 0 ;;
    handshake|deal|agree) return 0 ;;
    point-right|point-left|point-up|point-down) return 0 ;;
    raised-hand|stop-hand|halt|salute) return 0 ;;
    # People & Characters
    skull|dead|rip|ghost|robot|bot|alien|clown) return 0 ;;
    poop|crap|ninja|detective|spy) return 0 ;;
    # Hearts & Emotion Symbols
    heart|love-heart|red-heart|broken-heart|heartbreak) return 0 ;;
    sparkling-heart|glowing-heart) return 0 ;;
    sweat-drops|effort|splash|anger-symbol|fury-mark) return 0 ;;
    droplet|water|drip) return 0 ;;
    # Animals
    dog|puppy|cat|kitty|fox|bear|panda|monkey) return 0 ;;
    chicken|hen|penguin|bird|tweet|eagle|owl|bat) return 0 ;;
    butterfly|snake|dragon|whale|dolphin|octopus) return 0 ;;
    snail|slow|turtle|tortoise|crab|crustacean) return 0 ;;
    spider|scorpion|unicorn|magic|bee|honeybee|buzz) return 0 ;;
    ant|ladybug|shark|wolf|horse|pony|pig|oink) return 0 ;;
    frog|toad|gorilla|ape|deer|stag|rabbit|bunny) return 0 ;;
    mouse|rodent|camel|elephant|lion|tiger) return 0 ;;
    crocodile|croc|gator|parrot|flamingo|peacock) return 0 ;;
    lobster|shrimp|prawn|squid|hedgehog|porcupine) return 0 ;;
    raccoon|trash-panda|sloth|lazy|otter) return 0 ;;
    skunk|stink|mammoth|woolly|dodo|extinct) return 0 ;;
    microbe|germ|bacteria) return 0 ;;
    # Nature & Weather
    tree|evergreen|palm-tree|tropical|flower|blossom) return 0 ;;
    cherry|rose|sunflower|leaf|leaves|wind-leaf) return 0 ;;
    herb|plant|seedling|mushroom|fungi|toadstool|cactus) return 0 ;;
    sun|sunny|moon|crescent|full-moon|rainbow) return 0 ;;
    snowflake|frozen|cold|tornado|cyclone|twister) return 0 ;;
    ocean|waves|sea|volcano|eruption|lava) return 0 ;;
    comet|meteor|shooting-star|umbrella|rain-cover) return 0 ;;
    lotus|zen|mindful|calm|feather|lightweight|quill) return 0 ;;
    coral|reef|marine|nest|nested|home-base) return 0 ;;
    # Food & Drink
    apple|fruit|banana|grapes|vine|watermelon|melon) return 0 ;;
    lemon|citrus|sour|peach|cherry|cherries|strawberry) return 0 ;;
    tomato|avocado|eggplant|aubergine) return 0 ;;
    pepper|hot|spicy|chili|pizza|pie|burger|hamburger) return 0 ;;
    fries|chips|french-fries|hotdog|sausage|frank) return 0 ;;
    taco|burrito|wrap|sushi|japanese|ramen|noodles|soup) return 0 ;;
    cake|birthday|bday|cookie|biscuit|chocolate|candy-bar) return 0 ;;
    donut|doughnut|pastry|ice-cream|icecream|gelato) return 0 ;;
    honey|honeypot|sweet|beer|brew|pint) return 0 ;;
    wine|glass|vino|cocktail|martini|drink|popcorn) return 0 ;;
    bread|loaf|toast|cheese|cheddar|meat|steak|beef) return 0 ;;
    bacon|pork|candy|lollipop|sweet-treat) return 0 ;;
    cupcake|muffin|salt|seasoning) return 0 ;;
    beans|coffee-beans|java|jar|preserve|store) return 0 ;;
    # Travel & Transport
    car|auto|drive|vehicle|taxi|cab|bus|transit) return 0 ;;
    ambulance|ems|emergency|fire-truck|firetruck) return 0 ;;
    police-car|cop|patrol|train|rail|locomotive) return 0 ;;
    airplane|plane|flight|jet|helicopter|chopper|heli) return 0 ;;
    sailboat|boat|sailing|anchor|dock|port) return 0 ;;
    fuel|gas|petrol|pump|bike|bicycle|cycle) return 0 ;;
    # Places & Buildings
    house|home|office|building|corp) return 0 ;;
    hospital|medical|health-bldg|school|education|learn) return 0 ;;
    castle|fortress|fort|tent|camp|camping|outdoor) return 0 ;;
    church|worship|chapel) return 0 ;;
    # Writing & Office
    book|read|manual|textbook|notebook|journal|diary) return 0 ;;
    pencil|write|edit|compose|pen|author|ink) return 0 ;;
    paintbrush|paint|brush|crayon|draw|sketch|color) return 0 ;;
    paperclip|attach|attachment|scissors|cut|snip|trim) return 0 ;;
    ruler|measure|length|camera|photo|snap|picture) return 0 ;;
    clapper|film|movie|action|tv|television|screen|monitor) return 0 ;;
    # Music & Sound
    music|song|tune|melody|guitar|rock|strum) return 0 ;;
    drum|beat|rhythm|trumpet|horn|fanfare|brass) return 0 ;;
    microphone|mic|karaoke|sing|headphones|audio|listen|earphones) return 0 ;;
    speaker|volume|sound|loud|mute|silent|no-sound|quiet-speaker) return 0 ;;
    # Sports & Activities
    soccer|football|kick|basketball|bball|hoop) return 0 ;;
    baseball|bat-ball|tennis|racket|serve|golf|putt|tee) return 0 ;;
    boxing|fight-glove|bout|bowling|strike|pins) return 0 ;;
    gaming|joystick|game|play) return 0 ;;
    puzzle|jigsaw|piece|solve|component|module) return 0 ;;
    chess|strategy|checkmate|dice|random|chance|roll) return 0 ;;
    fishing|catch|rod|surfing|surf|wave-ride) return 0 ;;
    swimming|swim|pool|lap|running|run|sprint|jog) return 0 ;;
    eight-ball|pool|billiards|slot-machine|jackpot|gamble) return 0 ;;
    mahjong|tile) return 0 ;;
    # Combat & Danger
    bomb|explosive|detonate|sword|fight|blade) return 0 ;;
    axe|chop|hatchet|radioactive|nuclear|hazard) return 0 ;;
    biohazard|toxic|danger) return 0 ;;
    # Arrows & Shapes
    arrow-up|ascending|upward|arrow-down|descending|downward) return 0 ;;
    arrow-left|back|backward|arrow-right|forward|next|ahead) return 0 ;;
    arrows-rotate|sync|refresh|reload|cycle|repeat|loop-arrows|redo) return 0 ;;
    plus|add|new|create|minus|subtract|remove|delete-sign) return 0 ;;
    multiply|times|x-mark|cross-mark|divide|split|separate) return 0 ;;
    red-circle|orange-circle|yellow-circle|green-circle) return 0 ;;
    blue-circle|purple-circle|white-circle|black-circle) return 0 ;;
    red-square|green-square|blue-square) return 0 ;;
    # Money & Finance
    currency|dollar|money|usd|moneybag|rich|cash|funds) return 0 ;;
    credit-card|payment|pay|swipe) return 0 ;;
    # Flags
    flag|banner|pennant|white-flag|surrender|truce) return 0 ;;
    checkered-flag|finish|race|complete) return 0 ;;
    triangular-flag|marker|waypoint) return 0 ;;
    # Peace & Philosophy
    peace|antiwar|peace-symbol|yin-yang|balance|harmony) return 0 ;;
    *) return 1 ;;
  esac
}

# ---------------------------------------------------------------------------
# Internal: get the leading dot/emoji for tab title
# TAB_EMOJI overrides urgency dot when set
# ---------------------------------------------------------------------------
_tabbing_get_indicator() {
  if [ -n "${TAB_EMOJI:-}" ]; then
    _tabbing_emoji_lookup "$TAB_EMOJI"
  elif [ -n "${TAB_URGENCY:-}" ]; then
    _tabbing_urgency_dot "$TAB_URGENCY"
  fi
}

# ---------------------------------------------------------------------------
# Internal: render tab title from TAB_TITLE + TAB_STATUS
# Calls _tabbing_send_title (below)
# ---------------------------------------------------------------------------
_tabbing_render() {
  local max_title=25
  local max_status=20
  local t_title="${TAB_TITLE:-}"
  local t_status="${TAB_STATUS:-}"

  # Truncate title
  if [ ${#t_title} -gt $max_title ]; then
    t_title="$(printf '%s' "$t_title" | cut -c1-$((max_title - 1)))"
    t_title="${t_title}$(printf '\xE2\x80\xA6')"  # ...
  fi

  # Indicator (emoji or urgency dot)
  local dot=""
  dot="$(_tabbing_get_indicator)"
  if [ -n "$dot" ]; then
    dot="$dot "
  fi

  local output="${dot}${t_title}"

  if [ -n "$t_status" ]; then
    # Truncate status
    if [ ${#t_status} -gt $max_status ]; then
      t_status="$(printf '%s' "$t_status" | cut -c1-$((max_status - 1)))"
      t_status="${t_status}$(printf '\xE2\x80\xA6')"  # ...
    fi
    output="${dot}${t_title}: ${t_status}"
  fi

  # Skip static title when marquee is active — marquee subprocess owns the title
  if [ "${TAB_MARQUEE:-}" = "1" ] && [ -n "$t_status" ]; then
    return 0
  fi

  _tabbing_send_title "$output"
}

# ---------------------------------------------------------------------------
# Internal: colored console display of current state
# ---------------------------------------------------------------------------
_tabbing_display() {
  local reset
  reset="$(printf '\033[0m')"

  # Title highlight
  local tc="$reset"
  if [ -n "${TAB_HIGHLIGHT:-}" ]; then
    local code
    code="$(_tabbing_color_code "$TAB_HIGHLIGHT" 2>/dev/null)"
    if [ -n "$code" ]; then
      tc="$(printf '\033[%sm' "$code")"
    fi
  fi

  # Status color (from urgency)
  local sc="$reset"
  if [ -n "${TAB_URGENCY:-}" ]; then
    sc="$(printf '\033[%sm' "$(_tabbing_urgency_ansi "$TAB_URGENCY")")"
  fi

  # Indicator
  local dot=""
  dot="$(_tabbing_get_indicator)"
  if [ -n "$dot" ]; then
    dot="$dot "
  fi

  local title_text="${TAB_TITLE:-(not set)}"
  local line="${tc}${title_text}${reset}"
  if [ -n "${TAB_STATUS:-}" ]; then
    line="${line}: ${dot}${sc}${TAB_STATUS}${reset}"
  fi

  printf '%s\n' "$line"
}

# ---------------------------------------------------------------------------
# Send tab/window title via escape sequence
# OSC 0 is universally supported across all target terminals
# Writes to /dev/tty to avoid interfering with shell integration
# hooks (Ghostty, Kitty) that also write escape sequences during
# prompt rendering. Stdout output in precmd can corrupt cursor state.
# ---------------------------------------------------------------------------
_tabbing_send_title() {
  local title="$1"

  # Prevent Claude Code from overwriting our title
  export CLAUDE_CODE_DISABLE_TERMINAL_TITLE=1

  _tabbing_tty_printf '\033]0;%s\007' "$title"

  # Set Zellij tab name when running inside a Zellij session
  # Run in a subshell to suppress zsh job-control "done" notifications
  if [ -n "${ZELLIJ:-}" ] && command -v zellij >/dev/null 2>&1; then
    (zellij action rename-tab "$title" 2>/dev/null &)
  fi

  # Push state to bridge pipe(s) if active
  if [ -n "${TABBING_PIPE:-}" ] && [ -p "${TABBING_PIPE}" ]; then
    _tabbing_claude_write_pipe
  fi
  if [ -n "${TABBING_RUN_WITH_PIPE:-}" ] && [ -p "${TABBING_RUN_WITH_PIPE}" ]; then
    _tabbing_claude_write_pipe_to "${TABBING_RUN_WITH_PIPE}"
  fi
}

# ---------------------------------------------------------------------------
# Write current TAB_* state to the Claude Code bridge pipe (non-blocking)
# Defined here (not claude.sh) because render.sh is the minimal-footprint
# lib sourced at shell init — avoids requiring claude.sh for every render.
# ---------------------------------------------------------------------------
_tabbing_claude_write_pipe() {
  _tabbing_claude_write_pipe_to "${TABBING_PIPE}"
}

_tabbing_claude_write_pipe_to() {
  printf 'title=%s\nstatus=%s\nemoji=%s\nurgency=%s\nhighlight=%s\n---\n' \
    "${TAB_TITLE:-}" "${TAB_STATUS:-}" "${TAB_EMOJI:-}" \
    "${TAB_URGENCY:-}" "${TAB_HIGHLIGHT:-}" > "$1" 2>/dev/null &
}

# ---------------------------------------------------------------------------
# Clear tab/window title — sends empty OSC 2 to reset terminal title state
# On Ghostty this resets `seen_title = false`, re-enabling the pwd fallback.
# Uses OSC 2 (not OSC 0) to specifically target the title without icon name.
# ---------------------------------------------------------------------------
_tabbing_clear_title() {
  _tabbing_tty_printf '\033]2;\007'
  if [ -n "${ZELLIJ:-}" ] && command -v zellij >/dev/null 2>&1; then
    (zellij action rename-tab "" 2>/dev/null &)
  fi
}

# ---------------------------------------------------------------------------
# Marquee: kill any running marquee subprocess
# ---------------------------------------------------------------------------
_tabbing_marquee_kill() {
  local state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/tabbing"
  local pidfile="${state_dir}/marquee.pid"
  if [ -f "$pidfile" ]; then
    local pid
    pid="$(cat "$pidfile")"
    kill "$pid" 2>/dev/null || true
    rm -f "$pidfile"
  fi
}

# ---------------------------------------------------------------------------
# Marquee: spawn a background subprocess that scrolls the status portion
# of the tab title. The title prefix (indicator + TAB_TITLE) stays fixed;
# only TAB_STATUS scrolls across a 20-char window.
#
# Env: TAB_MARQUEE=1 enables, TAB_MARQUEE="" or unset disables.
# Automatically kills any prior marquee process before spawning.
# ---------------------------------------------------------------------------
_tabbing_marquee_start() {
  local width=20
  local delay=0.2

  local t_title="${TAB_TITLE:-}"
  local t_status="${TAB_STATUS:-}"

  # Nothing to marquee without a status
  [ -z "$t_status" ] && return 0

  local max_title=25

  # Truncate title (same logic as _tabbing_render)
  if [ ${#t_title} -gt $max_title ]; then
    t_title="$(printf '%s' "$t_title" | cut -c1-$((max_title - 1)))"
    t_title="${t_title}$(printf '\xE2\x80\xA6')"
  fi

  # Build the static prefix: indicator + title + ": "
  local dot=""
  dot="$(_tabbing_get_indicator)"
  if [ -n "$dot" ]; then
    dot="$dot "
  fi
  local prefix="${dot}${t_title}: "

  # Pad status with spaces for smooth wrap-around
  local padded="${t_status}    "
  local padded_len=${#padded}

  local state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/tabbing"
  local pidfile="${state_dir}/marquee.pid"
  mkdir -p "$state_dir"

  # Spawn background marquee loop
  (
    _offset=0
    trap '_tabbing_tty_printf "\033]0;\007"; rm -f "'"$pidfile"'"; exit 0' INT TERM

    while true; do
      # Build visible window by wrapping around the padded status
      _visible=""
      _i=0
      while [ "$_i" -lt "$width" ]; do
        _pos=$(( (_offset + _i) % padded_len ))
        _char="$(printf '%s' "$padded" | cut -c$((_pos + 1)))"
        _visible="${_visible}${_char}"
        _i=$((_i + 1))
      done

      _tabbing_tty_printf '\033]0;%s%s\007' "$prefix" "$_visible"

      _offset=$(( (_offset + 1) % padded_len ))
      sleep "$delay"
    done
  ) &

  printf '%s' "$!" > "$pidfile"
}

# ---------------------------------------------------------------------------
# Marquee-aware render: if TAB_MARQUEE is set, start marquee instead of
# static title. Called from adapters after normal _tabbing_render.
# ---------------------------------------------------------------------------
_tabbing_marquee_render() {
  # Always kill the old marquee first — prevents orphaned processes
  # when title/status changes or marquee is toggled off
  _tabbing_marquee_kill

  if [ "${TAB_MARQUEE:-}" = "1" ] && [ -n "${TAB_STATUS:-}" ]; then
    _tabbing_marquee_start
  fi
}

# ---------------------------------------------------------------------------
# Set tab background color (terminal-specific, no-op where unsupported)
# Args: r g b (0-255 each)
# ---------------------------------------------------------------------------
_tabbing_send_tab_color() {
  local r="$1" g="$2" b="$3"

  case "${TAB_TERMINAL:-unknown}" in
    iterm2)
      _tabbing_tty_printf '\033]6;1;bg;red;brightness;%s\007' "$r"
      _tabbing_tty_printf '\033]6;1;bg;green;brightness;%s\007' "$g"
      _tabbing_tty_printf '\033]6;1;bg;blue;brightness;%s\007' "$b"
      ;;
    kitty)
      if command -v kitty >/dev/null 2>&1; then
        kitty @ set-tab-color "active_bg=#$(printf '%02x%02x%02x' "$r" "$g" "$b")" 2>/dev/null || true
      fi
      ;;
    *)
      ;;
  esac
}

# ---------------------------------------------------------------------------
# Map urgency level to tab color RGB values
# Returns: "r g b" or empty if no color mapping
# ---------------------------------------------------------------------------
_tabbing_urgency_tab_color() {
  case "${1:-}" in
    0) echo "200 50 50"   ;;  # critical: red
    1) echo "200 100 50"  ;;  # high: orange-red
    2) echo "200 180 50"  ;;  # medium: yellow
    3) echo "150 200 50"  ;;  # medium-low: yellow-green
    4) echo "50 180 50"   ;;  # low: green
    5) echo "120 120 120" ;;  # nominal: gray
    *) ;;
  esac
}

# ---------------------------------------------------------------------------
# Apply urgency-based tab color (where supported)
# ---------------------------------------------------------------------------
_tabbing_apply_urgency_color() {
  local rgb
  rgb="$(_tabbing_urgency_tab_color "${TAB_URGENCY:-}")"
  if [ -n "$rgb" ]; then
    # shellcheck disable=SC2086
    _tabbing_send_tab_color $rgb
  fi
}

# ---------------------------------------------------------------------------
# Map color name to hex value for terminal background
# Accepts: #RRGGBB hex strings, or named color keywords
# ---------------------------------------------------------------------------
_tabbing_color_to_hex() {
  case "${1:-}" in
    \#[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])
      echo "$1" ;;

    # Standard terminal colors
    black)          echo "#000000" ;;
    red)            echo "#CC3333" ;;
    green)          echo "#33CC33" ;;
    yellow)         echo "#CCCC33" ;;
    blue)           echo "#3333CC" ;;
    magenta)        echo "#CC33CC" ;;
    cyan)           echo "#33CCCC" ;;
    white)          echo "#FFFFFF" ;;
    bright-black)   echo "#666666" ;;
    bright-red)     echo "#FF6666" ;;
    bright-green)   echo "#66FF66" ;;
    bright-yellow)  echo "#FFFF66" ;;
    bright-blue)    echo "#6666FF" ;;
    bright-magenta) echo "#FF66FF" ;;
    bright-cyan)    echo "#66FFFF" ;;
    bright-white)   echo "#FFFFFF" ;;

    # Dark theme backgrounds
    dark)           echo "#1E1E1E" ;;
    midnight)       echo "#0D1117" ;;
    charcoal)       echo "#2B2B2B" ;;
    slate)          echo "#2E3440" ;;
    graphite)       echo "#3B3B3B" ;;
    obsidian)       echo "#1A1A2E" ;;
    onyx)           echo "#0F0F0F" ;;

    # Popular editor/terminal themes
    nord)           echo "#2E3440" ;;
    dracula)        echo "#282A36" ;;
    monokai)        echo "#272822" ;;
    solarized-dark) echo "#002B36" ;;
    solarized-light) echo "#FDF6E3" ;;
    gruvbox)        echo "#282828" ;;
    gruvbox-light)  echo "#FBF1C7" ;;
    tokyo-night)    echo "#1A1B26" ;;
    catppuccin)     echo "#1E1E2E" ;;
    one-dark)       echo "#282C34" ;;
    rose-pine)      echo "#191724" ;;
    kanagawa)       echo "#1F1F28" ;;

    # Semantic / mood colors
    ocean)          echo "#0A1628" ;;
    forest)         echo "#0B2B1A" ;;
    sunset)         echo "#2C1810" ;;
    wine)           echo "#2C0B0E" ;;
    plum)           echo "#2D1B30" ;;
    storm)          echo "#1B2838" ;;
    ember)          echo "#3B1518" ;;
    moss)           echo "#1A2E1A" ;;
    sand)           echo "#3B3426" ;;
    ice)            echo "#1A2B3C" ;;

    # Production/environment indicators
    danger)         echo "#3B0F0F" ;;
    warning)        echo "#3B2E0F" ;;
    safe)           echo "#0F3B1A" ;;
    info)           echo "#0F1E3B" ;;

    # Common web colors (dark-friendly tints)
    navy)           echo "#001F3F" ;;
    olive)          echo "#3D3D00" ;;
    teal)           echo "#003B3B" ;;
    maroon)         echo "#3B0000" ;;
    purple)         echo "#2D0A3B" ;;
    orange)         echo "#3B2200" ;;
    brown)          echo "#2B1A0A" ;;
    pink)           echo "#3B0A2D" ;;
    gray|grey)      echo "#333333" ;;
    silver)         echo "#C0C0C0" ;;

    *)
      echo "tabbing: unknown bg color '$1'" >&2
      echo "tabbing: use #RRGGBB hex or: black red green blue cyan magenta yellow white" >&2
      echo "tabbing: themes: nord dracula monokai solarized-dark gruvbox tokyo-night catppuccin" >&2
      echo "tabbing: moods: ocean forest sunset wine storm ember midnight dark charcoal" >&2
      return 1
      ;;
  esac
}

# ---------------------------------------------------------------------------
# Set terminal background color via OSC 11
# Args: hex color string (#RRGGBB)
# Supported: Ghostty, iTerm2, Kitty, WezTerm, xterm, most modern terminals
# ---------------------------------------------------------------------------
_tabbing_send_bg_color() {
  local color="$1"
  printf '\033]11;%s\007' "$color" >/dev/tty 2>/dev/null || \
    printf '\033]11;%s\007' "$color"
}

# ---------------------------------------------------------------------------
# Reset terminal background color to default via OSC 111
# ---------------------------------------------------------------------------
_tabbing_clear_bg_color() {
  printf '\033]111\007' >/dev/tty 2>/dev/null || \
    printf '\033]111\007'
}

# ---------------------------------------------------------------------------
# Apply TAB_BG if set — converts name to hex and sends OSC 11
# ---------------------------------------------------------------------------
_tabbing_apply_bg_color() {
  if [ -n "${TAB_BG:-}" ]; then
    local hex
    hex="$(_tabbing_color_to_hex "$TAB_BG")" || return 0
    _tabbing_send_bg_color "$hex"
  fi
}

# ===========================================================================
# Theme system — full terminal recoloring via OSC sequences
#
# Themes set: background (OSC 11), foreground (OSC 10), cursor (OSC 12),
# and the 16-color palette (OSC 4;0..15). Works on Ghostty, Kitty, iTerm2,
# WezTerm, xterm, and any terminal supporting these standard OSCs.
# ===========================================================================

# ---------------------------------------------------------------------------
# Low-level: emit OSC sequences for a full theme
# Args: bg fg cursor c0 c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 c11 c12 c13 c14 c15
# All values are #RRGGBB hex strings
# ---------------------------------------------------------------------------
_tabbing_send_theme() {
  local bg="$1" fg="$2" cursor="$3"
  shift 3

  # Palette colors 0-15
  local i=0
  while [ $i -lt 16 ] && [ $# -gt 0 ]; do
    printf '\033]4;%d;%s\007' "$i" "$1" >/dev/tty 2>/dev/null || \
      printf '\033]4;%d;%s\007' "$i" "$1"
    i=$((i + 1))
    shift
  done

  # Background, foreground, cursor
  printf '\033]11;%s\007' "$bg" >/dev/tty 2>/dev/null || \
    printf '\033]11;%s\007' "$bg"
  printf '\033]10;%s\007' "$fg" >/dev/tty 2>/dev/null || \
    printf '\033]10;%s\007' "$fg"
  printf '\033]12;%s\007' "$cursor" >/dev/tty 2>/dev/null || \
    printf '\033]12;%s\007' "$cursor"
}

# ---------------------------------------------------------------------------
# Reset terminal to default colors (undo theme)
# OSC 104 = reset palette, 110 = reset fg, 111 = reset bg, 112 = reset cursor
# ---------------------------------------------------------------------------
_tabbing_clear_theme() {
  {
    printf '\033]104\007'
    printf '\033]110\007'
    printf '\033]111\007'
    printf '\033]112\007'
  } >/dev/tty 2>/dev/null || {
    printf '\033]104\007'
    printf '\033]110\007'
    printf '\033]111\007'
    printf '\033]112\007'
  }
}

# ---------------------------------------------------------------------------
# User theme directory: ~/.config/tabbing-on/themes/
# Respects XDG_CONFIG_HOME if set.
# ---------------------------------------------------------------------------
_tabbing_theme_dir() {
  echo "${XDG_CONFIG_HOME:-$HOME/.config}/tabbing-on/themes"
}

# ---------------------------------------------------------------------------
# Load and apply a user-defined .theme file
# File format (key=value, one per line, # comments):
#
#   bg=#1E1E2E
#   fg=#CDD6F4
#   cursor=#F5E0DC
#   color0=#45475A
#   color1=#F38BA8
#   ...
#   color15=#A6ADC8
#
# Returns 0 on success, 1 if file not found or invalid
# ---------------------------------------------------------------------------
_tabbing_load_user_theme() {
  local name="$1"
  local theme_dir
  theme_dir="$(_tabbing_theme_dir)"
  local file="${theme_dir}/${name}.theme"

  [ -f "$file" ] || return 1

  # Parse key=value pairs into variables
  local bg="" fg="" cursor=""
  local c0="" c1="" c2="" c3="" c4="" c5="" c6="" c7=""
  local c8="" c9="" c10="" c11="" c12="" c13="" c14="" c15=""

  while IFS= read -r line || [ -n "$line" ]; do
    # Skip comments and blank lines
    case "$line" in
      \#*|"") continue ;;
    esac

    # Strip inline comments and leading/trailing whitespace
    line="${line%%#*}"
    # Extract key and value
    local key="${line%%=*}"
    local val="${line#*=}"

    # Trim whitespace from key and val
    key="$(echo "$key" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    val="$(echo "$val" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/^["'"'"']//;s/["'"'"']$//')"

    case "$key" in
      bg|background)  bg="$val" ;;
      fg|foreground)  fg="$val" ;;
      cursor)         cursor="$val" ;;
      color0)  c0="$val"  ;; color1)  c1="$val"  ;;
      color2)  c2="$val"  ;; color3)  c3="$val"  ;;
      color4)  c4="$val"  ;; color5)  c5="$val"  ;;
      color6)  c6="$val"  ;; color7)  c7="$val"  ;;
      color8)  c8="$val"  ;; color9)  c9="$val"  ;;
      color10) c10="$val" ;; color11) c11="$val" ;;
      color12) c12="$val" ;; color13) c13="$val" ;;
      color14) c14="$val" ;; color15) c15="$val" ;;
    esac
  done < "$file"

  # bg and fg are required
  if [ -z "$bg" ] || [ -z "$fg" ]; then
    echo "tabbing: theme '$name' missing required bg/fg" >&2
    return 1
  fi

  # Default cursor to fg if not set
  [ -z "$cursor" ] && cursor="$fg"

  # Default unset palette entries to fg (visible) or bg (background)
  [ -z "$c0" ]  && c0="$bg"   # usually dark
  [ -z "$c1" ]  && c1="$fg"
  [ -z "$c2" ]  && c2="$fg"
  [ -z "$c3" ]  && c3="$fg"
  [ -z "$c4" ]  && c4="$fg"
  [ -z "$c5" ]  && c5="$fg"
  [ -z "$c6" ]  && c6="$fg"
  [ -z "$c7" ]  && c7="$fg"
  [ -z "$c8" ]  && c8="$bg"   # usually dark (bright-black)
  [ -z "$c9" ]  && c9="$fg"
  [ -z "$c10" ] && c10="$fg"
  [ -z "$c11" ] && c11="$fg"
  [ -z "$c12" ] && c12="$fg"
  [ -z "$c13" ] && c13="$fg"
  [ -z "$c14" ] && c14="$fg"
  [ -z "$c15" ] && c15="$fg"

  _tabbing_send_theme "$bg" "$fg" "$cursor" \
    "$c0" "$c1" "$c2" "$c3" "$c4" "$c5" "$c6" "$c7" \
    "$c8" "$c9" "$c10" "$c11" "$c12" "$c13" "$c14" "$c15"
}

# ---------------------------------------------------------------------------
# Theme data: name → _tabbing_send_theme args
# Checks user themes first (~/.config/tabbing-on/themes/NAME.theme),
# then falls back to built-in themes.
# Format: bg fg cursor palette[0..15]
# Returns 0 on success, 1 if theme not found
# ---------------------------------------------------------------------------
_tabbing_apply_named_theme() {
  # Try user theme first
  _tabbing_load_user_theme "$1" 2>/dev/null && return 0

  case "${1:-}" in

    catppuccin|catppuccin-mocha)
      _tabbing_send_theme \
        "#1E1E2E" "#CDD6F4" "#F5E0DC" \
        "#45475A" "#F38BA8" "#A6E3A1" "#F9E2AF" \
        "#89B4FA" "#F5C2E7" "#94E2D5" "#BAC2DE" \
        "#585B70" "#F38BA8" "#A6E3A1" "#F9E2AF" \
        "#89B4FA" "#F5C2E7" "#94E2D5" "#A6ADC8"
      ;;

    catppuccin-latte)
      _tabbing_send_theme \
        "#EFF1F5" "#4C4F69" "#DC8A78" \
        "#BCC0CC" "#D20F39" "#40A02B" "#DF8E1D" \
        "#1E66F5" "#EA76CB" "#179299" "#5C5F77" \
        "#ACB0BE" "#D20F39" "#40A02B" "#DF8E1D" \
        "#1E66F5" "#EA76CB" "#179299" "#6C6F85"
      ;;

    catppuccin-frappe)
      _tabbing_send_theme \
        "#303446" "#C6D0F5" "#F2D5CF" \
        "#292C3C" "#E78284" "#A6D189" "#E5C890" \
        "#8CAAEE" "#F4B8E4" "#81C8BE" "#B5BFE2" \
        "#414559" "#E78284" "#A6D189" "#E5C890" \
        "#8CAAEE" "#F4B8E4" "#81C8BE" "#A5ADCE"
      ;;

    catppuccin-macchiato)
      _tabbing_send_theme \
        "#24273A" "#CAD3F5" "#F4DBD6" \
        "#1E2030" "#ED8796" "#A6DA95" "#EED49F" \
        "#8AADF4" "#F5BDE6" "#8BD5CA" "#B8C0E0" \
        "#494D64" "#ED8796" "#A6DA95" "#EED49F" \
        "#8AADF4" "#F5BDE6" "#8BD5CA" "#A5ADCB"
      ;;

    dracula)
      _tabbing_send_theme \
        "#282A36" "#F8F8F2" "#F8F8F2" \
        "#21222C" "#FF5555" "#50FA7B" "#F1FA8C" \
        "#BD93F9" "#FF79C6" "#8BE9FD" "#F8F8F2" \
        "#6272A4" "#FF6E6E" "#69FF94" "#FFFFA5" \
        "#D6ACFF" "#FF92DF" "#A4FFFF" "#FFFFFF"
      ;;

    nord)
      _tabbing_send_theme \
        "#2E3440" "#D8DEE9" "#D8DEE9" \
        "#3B4252" "#BF616A" "#A3BE8C" "#EBCB8B" \
        "#81A1C1" "#B48EAD" "#88C0D0" "#E5E9F0" \
        "#4C566A" "#BF616A" "#A3BE8C" "#EBCB8B" \
        "#81A1C1" "#B48EAD" "#8FBCBB" "#ECEFF4"
      ;;

    nord-light)
      _tabbing_send_theme \
        "#ECEFF4" "#2E3440" "#4C566A" \
        "#D8DEE9" "#BF616A" "#A3BE8C" "#EBCB8B" \
        "#5E81AC" "#B48EAD" "#88C0D0" "#3B4252" \
        "#E5E9F0" "#BF616A" "#A3BE8C" "#EBCB8B" \
        "#5E81AC" "#B48EAD" "#8FBCBB" "#2E3440"
      ;;

    tokyo-night)
      _tabbing_send_theme \
        "#1A1B26" "#C0CAF5" "#C0CAF5" \
        "#15161E" "#F7768E" "#9ECE6A" "#E0AF68" \
        "#7AA2F7" "#BB9AF7" "#7DCFFF" "#A9B1D6" \
        "#414868" "#F7768E" "#9ECE6A" "#E0AF68" \
        "#7AA2F7" "#BB9AF7" "#7DCFFF" "#C0CAF5"
      ;;

    tokyo-night-light)
      _tabbing_send_theme \
        "#D5D6DB" "#343B59" "#343B59" \
        "#C4C5CB" "#8C4351" "#33635C" "#8F5E15" \
        "#34548A" "#5A4A78" "#0F4B6E" "#343B59" \
        "#9699A3" "#8C4351" "#33635C" "#8F5E15" \
        "#34548A" "#5A4A78" "#0F4B6E" "#343B59"
      ;;

    gruvbox|gruvbox-dark)
      _tabbing_send_theme \
        "#282828" "#EBDBB2" "#EBDBB2" \
        "#282828" "#CC241D" "#98971A" "#D79921" \
        "#458588" "#B16286" "#689D6A" "#A89984" \
        "#928374" "#FB4934" "#B8BB26" "#FABD2F" \
        "#83A598" "#D3869B" "#8EC07C" "#EBDBB2"
      ;;

    gruvbox-light)
      _tabbing_send_theme \
        "#FBF1C7" "#3C3836" "#3C3836" \
        "#FBF1C7" "#CC241D" "#98971A" "#D79921" \
        "#458588" "#B16286" "#689D6A" "#7C6F64" \
        "#928374" "#9D0006" "#79740E" "#B57614" \
        "#076678" "#8F3F71" "#427B58" "#3C3836"
      ;;

    solarized-dark)
      _tabbing_send_theme \
        "#002B36" "#839496" "#839496" \
        "#073642" "#DC322F" "#859900" "#B58900" \
        "#268BD2" "#D33682" "#2AA198" "#EEE8D5" \
        "#002B36" "#CB4B16" "#586E75" "#657B83" \
        "#839496" "#6C71C4" "#93A1A1" "#FDF6E3"
      ;;

    solarized-light)
      _tabbing_send_theme \
        "#FDF6E3" "#657B83" "#657B83" \
        "#EEE8D5" "#DC322F" "#859900" "#B58900" \
        "#268BD2" "#D33682" "#2AA198" "#073642" \
        "#FDF6E3" "#CB4B16" "#93A1A1" "#839496" \
        "#657B83" "#6C71C4" "#586E75" "#002B36"
      ;;

    monokai)
      _tabbing_send_theme \
        "#272822" "#F8F8F2" "#F8F8F0" \
        "#272822" "#F92672" "#A6E22E" "#F4BF75" \
        "#66D9EF" "#AE81FF" "#A1EFE4" "#F8F8F2" \
        "#75715E" "#F92672" "#A6E22E" "#F4BF75" \
        "#66D9EF" "#AE81FF" "#A1EFE4" "#F9F8F5"
      ;;

    one-dark)
      _tabbing_send_theme \
        "#282C34" "#ABB2BF" "#528BFF" \
        "#282C34" "#E06C75" "#98C379" "#E5C07B" \
        "#61AFEF" "#C678DD" "#56B6C2" "#ABB2BF" \
        "#545862" "#E06C75" "#98C379" "#E5C07B" \
        "#61AFEF" "#C678DD" "#56B6C2" "#C8CCD4"
      ;;

    one-light)
      _tabbing_send_theme \
        "#FAFAFA" "#383A42" "#526FFF" \
        "#F0F0F0" "#E45649" "#50A14F" "#C18401" \
        "#4078F2" "#A626A4" "#0184BC" "#383A42" \
        "#A0A1A7" "#E45649" "#50A14F" "#C18401" \
        "#4078F2" "#A626A4" "#0184BC" "#383A42"
      ;;

    rose-pine)
      _tabbing_send_theme \
        "#191724" "#E0DEF4" "#524F67" \
        "#26233A" "#EB6F92" "#31748F" "#F6C177" \
        "#9CCFD8" "#C4A7E7" "#EBBCBA" "#E0DEF4" \
        "#6E6A86" "#EB6F92" "#31748F" "#F6C177" \
        "#9CCFD8" "#C4A7E7" "#EBBCBA" "#E0DEF4"
      ;;

    rose-pine-moon)
      _tabbing_send_theme \
        "#232136" "#E0DEF4" "#59546D" \
        "#2A273F" "#EB6F92" "#3E8FB0" "#F6C177" \
        "#9CCFD8" "#C4A7E7" "#EA9A97" "#E0DEF4" \
        "#6E6A86" "#EB6F92" "#3E8FB0" "#F6C177" \
        "#9CCFD8" "#C4A7E7" "#EA9A97" "#E0DEF4"
      ;;

    rose-pine-dawn)
      _tabbing_send_theme \
        "#FAF4ED" "#575279" "#286983" \
        "#F2E9E1" "#B4637A" "#56949F" "#EA9D34" \
        "#286983" "#907AA9" "#D7827E" "#575279" \
        "#9893A5" "#B4637A" "#56949F" "#EA9D34" \
        "#286983" "#907AA9" "#D7827E" "#575279"
      ;;

    kanagawa)
      _tabbing_send_theme \
        "#1F1F28" "#DCD7BA" "#C8C093" \
        "#16161D" "#C34043" "#76946A" "#C0A36E" \
        "#7E9CD8" "#957FB8" "#6A9589" "#C8C093" \
        "#727169" "#E82424" "#98BB6C" "#E6C384" \
        "#7FB4CA" "#938AA9" "#7AA89F" "#DCD7BA"
      ;;

    kanagawa-lotus)
      _tabbing_send_theme \
        "#F2ECBC" "#545464" "#43436C" \
        "#E7DBA0" "#C84053" "#6F894E" "#77713F" \
        "#4D699B" "#624C83" "#597B75" "#545464" \
        "#8A8980" "#E82424" "#98BB6C" "#E6C384" \
        "#7FB4CA" "#938AA9" "#7AA89F" "#545464"
      ;;

    everforest-dark)
      _tabbing_send_theme \
        "#2D353B" "#D3C6AA" "#D3C6AA" \
        "#343F44" "#E67E80" "#A7C080" "#DBBC7F" \
        "#7FBBB3" "#D699B6" "#83C092" "#D3C6AA" \
        "#475258" "#E67E80" "#A7C080" "#DBBC7F" \
        "#7FBBB3" "#D699B6" "#83C092" "#D3C6AA"
      ;;

    everforest-light)
      _tabbing_send_theme \
        "#FDF6E3" "#5C6A72" "#5C6A72" \
        "#F3EAD3" "#F85552" "#8DA101" "#DFA000" \
        "#3A94C5" "#DF69BA" "#35A77C" "#5C6A72" \
        "#E0DCC7" "#F85552" "#8DA101" "#DFA000" \
        "#3A94C5" "#DF69BA" "#35A77C" "#5C6A72"
      ;;

    github-dark)
      _tabbing_send_theme \
        "#0D1117" "#C9D1D9" "#C9D1D9" \
        "#161B22" "#FF7B72" "#7EE787" "#D29922" \
        "#79C0FF" "#D2A8FF" "#A5D6FF" "#C9D1D9" \
        "#21262D" "#FFA198" "#56D364" "#E3B341" \
        "#79C0FF" "#D2A8FF" "#A5D6FF" "#F0F6FC"
      ;;

    github-light)
      _tabbing_send_theme \
        "#FFFFFF" "#24292F" "#0969DA" \
        "#F6F8FA" "#CF222E" "#116329" "#4D2D00" \
        "#0550AE" "#8250DF" "#1B7C83" "#24292F" \
        "#D0D7DE" "#A40E26" "#1A7F37" "#633C01" \
        "#0969DA" "#8250DF" "#2AA198" "#24292F"
      ;;

    ayu-dark)
      _tabbing_send_theme \
        "#0B0E14" "#BFBDB6" "#E6B450" \
        "#11151C" "#F07178" "#AAD94C" "#E6B450" \
        "#399EE6" "#D2A6FF" "#95E6CB" "#BFBDB6" \
        "#636A72" "#FF8F40" "#AAD94C" "#FFB454" \
        "#59C2FF" "#D2A6FF" "#95E6CB" "#C5C5C5"
      ;;

    ayu-light)
      _tabbing_send_theme \
        "#FAFAFA" "#5C6166" "#FF9940" \
        "#F0F0F0" "#F07178" "#86B300" "#F29718" \
        "#36A3D9" "#A37ACC" "#4CBF99" "#5C6166" \
        "#E7E8E9" "#FF3333" "#86B300" "#F29718" \
        "#36A3D9" "#A37ACC" "#4CBF99" "#5C6166"
      ;;

    ayu-mirage)
      _tabbing_send_theme \
        "#1F2430" "#CBCCC6" "#FFCC66" \
        "#232834" "#F28779" "#BAE67E" "#FFD580" \
        "#73D0FF" "#D4BFFF" "#95E6CB" "#CBCCC6" \
        "#707A8C" "#FF3333" "#BAE67E" "#FFD580" \
        "#73D0FF" "#D4BFFF" "#95E6CB" "#F3F4F5"
      ;;

    material-dark)
      _tabbing_send_theme \
        "#263238" "#EEFFFF" "#FFCC00" \
        "#2C3B41" "#FF5370" "#C3E88D" "#FFCB6B" \
        "#82AAFF" "#C792EA" "#89DDFF" "#EEFFFF" \
        "#37474F" "#FF5370" "#C3E88D" "#FFCB6B" \
        "#82AAFF" "#C792EA" "#89DDFF" "#FFFFFF"
      ;;

    material-light)
      _tabbing_send_theme \
        "#FAFAFA" "#546E7A" "#272727" \
        "#F2F2F2" "#FF5370" "#91B859" "#FFB62C" \
        "#6182B8" "#7C4DFF" "#39ADB5" "#546E7A" \
        "#E7E7E8" "#E53935" "#91B859" "#F6A434" \
        "#6182B8" "#7C4DFF" "#39ADB5" "#272727"
      ;;

    papercolor-light)
      _tabbing_send_theme \
        "#EEEEEE" "#444444" "#444444" \
        "#E4E4E4" "#AF0000" "#008700" "#D75F00" \
        "#005FAF" "#AF00AF" "#005F87" "#444444" \
        "#BCBCBC" "#D70000" "#5FAF00" "#D78700" \
        "#0087AF" "#D787D7" "#00AFAF" "#005F87"
      ;;

    pencil-light)
      _tabbing_send_theme \
        "#F1F1F1" "#424242" "#20BBFC" \
        "#E0E0E0" "#C30771" "#10A778" "#A89C14" \
        "#008EC4" "#523C79" "#20A5BA" "#424242" \
        "#B8B8B8" "#E32791" "#5FD7A7" "#F3E430" \
        "#20BBFC" "#6855DE" "#4FB8CC" "#212121"
      ;;

    alabaster)
      _tabbing_send_theme \
        "#F7F7F7" "#434343" "#007ACC" \
        "#ECECEC" "#AA3731" "#448C27" "#CB9000" \
        "#325CC0" "#7A3E9D" "#0083B2" "#434343" \
        "#DCDCDC" "#D91A1A" "#448C27" "#CB9000" \
        "#325CC0" "#7A3E9D" "#0083B2" "#434343"
      ;;

    # --- Semantic / environment themes ---

    danger|production)
      _tabbing_send_theme \
        "#2C0B0E" "#FFCCCC" "#FF6666" \
        "#1A0608" "#FF4444" "#CC6666" "#FFAA66" \
        "#CC8888" "#FF6688" "#CC9999" "#FFCCCC" \
        "#663333" "#FF6666" "#DD8888" "#FFBB88" \
        "#DDAAAA" "#FF88AA" "#DDBBBB" "#FFE0E0"
      ;;

    safe|development)
      _tabbing_send_theme \
        "#0B2B1A" "#CCFFCC" "#66FF66" \
        "#061A0F" "#66CC66" "#44FF44" "#AAFF66" \
        "#66CCAA" "#88CC66" "#44DDAA" "#CCFFCC" \
        "#336633" "#88DD88" "#66FF66" "#CCFF88" \
        "#88DDCC" "#AADD88" "#66FFCC" "#E0FFE0"
      ;;

    ocean)
      _tabbing_send_theme \
        "#0A1628" "#B0C4DE" "#87CEEB" \
        "#051020" "#CD5C5C" "#66CDAA" "#F0E68C" \
        "#6495ED" "#9370DB" "#48D1CC" "#B0C4DE" \
        "#2F4F6F" "#E07070" "#7CE0BE" "#F5EEA0" \
        "#7CAAF0" "#A888E0" "#5CE0D8" "#D0E0F0"
      ;;

    forest)
      _tabbing_send_theme \
        "#0B2B1A" "#A8C8A8" "#8FBC8F" \
        "#061A0F" "#CD6060" "#6B8E23" "#BDB76B" \
        "#5F9EA0" "#8B7B8B" "#66CDAA" "#A8C8A8" \
        "#2E5E3E" "#D87070" "#7BA833" "#CDC87B" \
        "#6FB8B0" "#9B8B9B" "#76DDBA" "#C0E0C0"
      ;;

    sunset)
      _tabbing_send_theme \
        "#2C1810" "#F0D0B0" "#E8A060" \
        "#1A0E0A" "#E06040" "#B8A040" "#F0C060" \
        "#C08060" "#D06080" "#C0A080" "#F0D0B0" \
        "#604030" "#F07050" "#C8B050" "#F0D070" \
        "#D09070" "#E07090" "#D0B090" "#F8E0C8"
      ;;

    ocean-light)
      _tabbing_send_theme \
        "#F0F5FA" "#1A3A5C" "#2E6B9E" \
        "#E0EAF2" "#C04040" "#2E8B57" "#B8860B" \
        "#2E6B9E" "#7B68AE" "#1A8A8A" "#1A3A5C" \
        "#CADAE8" "#D04040" "#358B5B" "#C89020" \
        "#3878B0" "#8878BE" "#2A9A9A" "#0D2040"
      ;;

    forest-light)
      _tabbing_send_theme \
        "#F4F8F0" "#2B4020" "#4A7030" \
        "#E8F0E0" "#B04040" "#3A7A20" "#9A8020" \
        "#4070A0" "#7A5A90" "#2A8A6A" "#2B4020" \
        "#D0DCC8" "#C05050" "#4A8A30" "#AA9030" \
        "#5080B0" "#8A6AA0" "#3A9A7A" "#1A2A10"
      ;;

    dawn)
      _tabbing_send_theme \
        "#FAF5F0" "#5C4A3A" "#D09050" \
        "#F0E8E0" "#C05040" "#6A8A40" "#C09030" \
        "#4A70A0" "#8A5A90" "#3A8A7A" "#5C4A3A" \
        "#E0D8D0" "#D06050" "#7A9A50" "#D0A040" \
        "#5A80B0" "#9A6AA0" "#4A9A8A" "#3A2A1A"
      ;;

    ivory)
      _tabbing_send_theme \
        "#FFFFF0" "#3A3A30" "#8A7A60" \
        "#F5F5E8" "#B84040" "#5A8A30" "#A08A20" \
        "#4A6AA0" "#7A5090" "#2A7A70" "#3A3A30" \
        "#E8E8D8" "#C85050" "#6A9A40" "#B09A30" \
        "#5A7AB0" "#8A60A0" "#3A8A80" "#1A1A10"
      ;;

    slate)
      _tabbing_send_theme \
        "#1E2832" "#C0C8D0" "#88A0B8" \
        "#283440" "#E07070" "#80B880" "#D0B870" \
        "#70A0D0" "#A080C0" "#60B0B0" "#C0C8D0" \
        "#384858" "#F08080" "#90C890" "#E0C880" \
        "#80B0E0" "#B090D0" "#70C0C0" "#E0E8F0"
      ;;

    # --- Chromatic themes: colored backgrounds with color-wheel pairings ---

    # Complementary: purple bg ↔ gold accents (270° ↔ 90°)
    amethyst)
      _tabbing_send_theme \
        "#2A1B3D" "#D8D0E8" "#E8C050" \
        "#1E1030" "#E06070" "#80C070" "#E8C050" \
        "#8080D0" "#D070B0" "#60B0B8" "#D0C8E0" \
        "#382850" "#F07080" "#90D080" "#F0D060" \
        "#9090E0" "#E080C0" "#70C0C8" "#E0D8F0"
      ;;

    # Complementary: navy bg ↔ amber accents (215° ↔ 35°)
    cobalt)
      _tabbing_send_theme \
        "#0D1B30" "#C8D8E8" "#E8A030" \
        "#081420" "#E06060" "#60C080" "#E8A030" \
        "#5090D0" "#B070C0" "#50B0C0" "#C0D0E0" \
        "#1A2840" "#F07070" "#70D090" "#F0B040" \
        "#60A0E0" "#C080D0" "#60C0D0" "#D8E0F0"
      ;;

    # Complementary: wine bg ↔ teal accents (345° ↔ 165°)
    merlot)
      _tabbing_send_theme \
        "#2E1018" "#E8D0D0" "#50C0A0" \
        "#200810" "#E05050" "#50C0A0" "#D8A050" \
        "#7090C0" "#C060A0" "#40B0A0" "#E0D0D0" \
        "#401828" "#F06060" "#60D0B0" "#E8B060" \
        "#80A0D0" "#D070B0" "#50C0B0" "#F0E0E0"
      ;;

    # Complementary: forest bg ↔ rose accents (145° ↔ 350°)
    emerald)
      _tabbing_send_theme \
        "#0C2818" "#C0D8C0" "#E07080" \
        "#061A0F" "#E07080" "#60C060" "#C0B050" \
        "#5090B0" "#B070A0" "#50B098" "#B8D0B8" \
        "#183820" "#F08090" "#70D070" "#D0C060" \
        "#60A0C0" "#C080B0" "#60C0A8" "#D0E8D0"
      ;;

    # Complementary: bronze bg ↔ azure accents (25° ↔ 205°)
    copper)
      _tabbing_send_theme \
        "#2C1808" "#E8D8C0" "#5098D0" \
        "#1A1005" "#E06040" "#90B060" "#D8A040" \
        "#5098D0" "#C070A0" "#50A8B8" "#E0D0B8" \
        "#402818" "#F07050" "#A0C070" "#E8B050" \
        "#60A8E0" "#D080B0" "#60B8C8" "#F0E8D0"
      ;;

    # Split-complementary: indigo bg ↔ coral + chartreuse (250° ↔ 20°/100°)
    indigo-night)
      _tabbing_send_theme \
        "#181038" "#C8C0E0" "#E88060" \
        "#100828" "#E88060" "#A0C050" "#E0B040" \
        "#7080D0" "#C068C0" "#60A8C0" "#C0B8D8" \
        "#281848" "#F89070" "#B0D060" "#F0C050" \
        "#8090E0" "#D078D0" "#70B8D0" "#D8D0F0"
      ;;

    # Split-complementary: plum bg ↔ lime + gold (300° ↔ 80°/120°)
    plum)
      _tabbing_send_theme \
        "#281028" "#D8C0D8" "#B0D050" \
        "#1C081C" "#E06080" "#B0D050" "#D0A840" \
        "#8080C0" "#D060C0" "#60B0A0" "#D0B8D0" \
        "#381838" "#F070A0" "#C0E060" "#E0B850" \
        "#9090D0" "#E070D0" "#70C0B0" "#E8D0E8"
      ;;

    # Analogous: teal + blue + green (180°–210° range)
    tundra)
      _tabbing_send_theme \
        "#0C2028" "#C0D8E0" "#70C0D0" \
        "#081820" "#D06868" "#60C0A0" "#C0B060" \
        "#5898C0" "#A078B0" "#70C0D0" "#B8D0D8" \
        "#183038" "#E07878" "#70D0B0" "#D0C070" \
        "#68A8D0" "#B088C0" "#80D0E0" "#D0E8F0"
      ;;

    # Analogous: red + orange + brown (350°–30° range)
    mahogany)
      _tabbing_send_theme \
        "#2E1510" "#E8D8C8" "#D08050" \
        "#200E08" "#D85040" "#90A860" "#D08050" \
        "#7090B0" "#C06090" "#60A090" "#E0D0C0" \
        "#402820" "#E86050" "#A0B870" "#E09060" \
        "#80A0C0" "#D070A0" "#70B0A0" "#F0E0D0"
      ;;

    # Analogous: olive + gold + sage (80°–120° range)
    olive-dusk)
      _tabbing_send_theme \
        "#1A2010" "#D0D8B8" "#C0B060" \
        "#101808" "#D06860" "#80B050" "#C0B060" \
        "#6090B0" "#A878A0" "#60A890" "#C8D0B0" \
        "#283018" "#E07870" "#90C060" "#D0C070" \
        "#70A0C0" "#B888B0" "#70B8A0" "#E0E8C8"
      ;;

    # Mid-tone: slate blue-gray bg with gold accent
    storm)
      _tabbing_send_theme \
        "#2E3848" "#D0D8E0" "#E8B050" \
        "#202830" "#E06868" "#70C080" "#E8B050" \
        "#6098D0" "#B078C0" "#60B0C0" "#C8D0D8" \
        "#3E4858" "#F07878" "#80D090" "#F0C060" \
        "#70A8E0" "#C088D0" "#70C0D0" "#E0E8F0"
      ;;

    # Warm charcoal: analogous warm (0°–30° range)
    volcanic)
      _tabbing_send_theme \
        "#281818" "#E0D0C0" "#E06040" \
        "#1A1010" "#E06040" "#90A860" "#D0A040" \
        "#7090B8" "#C06890" "#60A898" "#D8C8B8" \
        "#382828" "#F07050" "#A0B870" "#E0B050" \
        "#80A0C8" "#D078A0" "#70B8A8" "#F0E0D0"
      ;;

    # --- Light chromatic themes ---

    # Complementary: clay bg ↔ teal accents
    terracotta)
      _tabbing_send_theme \
        "#F2E0D0" "#4A3020" "#1A8080" \
        "#E0D0C0" "#B83030" "#1A8080" "#A07010" \
        "#3060A0" "#883880" "#107070" "#4A3020" \
        "#D0C0B0" "#D04040" "#209090" "#B08020" \
        "#4070B0" "#984890" "#208080" "#3A2010"
      ;;

    # Complementary: sage bg ↔ mauve accents
    sage-mist)
      _tabbing_send_theme \
        "#E4EDD8" "#2A3820" "#904880" \
        "#D4DCC8" "#A83030" "#307030" "#887020" \
        "#3060A0" "#904880" "#207868" "#2A3820" \
        "#C4D0B8" "#C04040" "#408040" "#988030" \
        "#4070B0" "#A05890" "#308878" "#1A2810"
      ;;

    # Complementary: lavender bg ↔ gold accents
    lavender-mist)
      _tabbing_send_theme \
        "#EAE0F2" "#302840" "#B89020" \
        "#DAD0E2" "#A83040" "#408030" "#B89020" \
        "#4060B0" "#804090" "#207888" "#302840" \
        "#C8C0D8" "#C04050" "#509040" "#C8A030" \
        "#5070C0" "#9050A0" "#308898" "#201830"
      ;;

    # Complementary: coral bg ↔ ocean blue accents
    coral-sand)
      _tabbing_send_theme \
        "#F5E2D8" "#3A2820" "#206898" \
        "#E4D0C8" "#B03030" "#308868" "#A07818" \
        "#206898" "#883880" "#1A7878" "#3A2820" \
        "#D4C0B8" "#C84040" "#409878" "#B08828" \
        "#3078A8" "#984890" "#2A8888" "#2A1810"
      ;;

    # Complementary: ice blue bg ↔ coral accents
    arctic)
      _tabbing_send_theme \
        "#E2ECF5" "#1A2840" "#C05040" \
        "#D2DCE4" "#C05040" "#308860" "#A08020" \
        "#2860A0" "#804090" "#187880" "#1A2840" \
        "#C0D0E0" "#D06050" "#409870" "#B09030" \
        "#3870B0" "#9050A0" "#288890" "#0A1830"
      ;;

    # Complementary: mint bg ↔ rose accents
    seafoam)
      _tabbing_send_theme \
        "#E0F0E8" "#1A3028" "#B84060" \
        "#D0E0D8" "#B84060" "#208860" "#888820" \
        "#3068A0" "#884088" "#107868" "#1A3028" \
        "#C0D4CC" "#C85070" "#309870" "#989830" \
        "#4078B0" "#985098" "#208878" "#0A2018"
      ;;

    # Complementary: beige bg ↔ sapphire accents
    champagne)
      _tabbing_send_theme \
        "#F5EDE2" "#302818" "#2858A8" \
        "#E4DCD0" "#B03030" "#408838" "#A07818" \
        "#2858A8" "#883088" "#187078" "#302818" \
        "#D0C8B8" "#C84040" "#509848" "#B08828" \
        "#3868B8" "#984098" "#288088" "#201808"
      ;;

    # Complementary: soft pink bg ↔ emerald accents
    blush)
      _tabbing_send_theme \
        "#F5E5E8" "#382030" "#208858" \
        "#E4D4D8" "#B03040" "#208858" "#907820" \
        "#3060A0" "#883880" "#187870" "#382030" \
        "#D4C4C8" "#C84050" "#309868" "#A08830" \
        "#4070B0" "#984890" "#288880" "#281020"
      ;;

    *)
      return 1
      ;;
  esac
  return 0
}

# ---------------------------------------------------------------------------
# List available theme names
# ---------------------------------------------------------------------------
_tabbing_theme_list() {
  printf 'Available themes:\n'
  printf '\n  Dark:\n'
  printf '    catppuccin       catppuccin-frappe   catppuccin-macchiato\n'
  printf '    dracula          nord                tokyo-night\n'
  printf '    gruvbox          monokai             one-dark\n'
  printf '    solarized-dark   rose-pine           rose-pine-moon\n'
  printf '    kanagawa         everforest-dark      github-dark\n'
  printf '    ayu-dark         ayu-mirage          material-dark\n'
  printf '\n  Light:\n'
  printf '    catppuccin-latte   nord-light          tokyo-night-light\n'
  printf '    gruvbox-light      one-light           solarized-light\n'
  printf '    rose-pine-dawn     kanagawa-lotus      everforest-light\n'
  printf '    github-light       ayu-light           material-light\n'
  printf '    papercolor-light   pencil-light        alabaster\n'
  printf '\n  Chromatic Dark (colored backgrounds):\n'
  printf '    amethyst       cobalt          merlot          emerald\n'
  printf '    copper         indigo-night    plum            tundra\n'
  printf '    mahogany       olive-dusk      storm           volcanic\n'
  printf '\n  Chromatic Light (tinted backgrounds):\n'
  printf '    terracotta     sage-mist       lavender-mist   coral-sand\n'
  printf '    arctic         seafoam         champagne       blush\n'
  printf '\n  Semantic:\n'
  printf '    danger (production)  safe (development)\n'
  printf '    ocean    ocean-light   forest    forest-light\n'
  printf '    sunset   dawn          ivory     slate\n'

  # List user themes if any exist
  local theme_dir
  theme_dir="$(_tabbing_theme_dir)"
  if [ -d "$theme_dir" ]; then
    local found=0
    for f in "$theme_dir"/*.theme; do
      [ -f "$f" ] || continue
      if [ $found -eq 0 ]; then
        printf '\n  User (~/.config/tabbing-on/themes/):\n'
        found=1
      fi
      local name
      name="$(basename "$f" .theme)"
      printf '    %s\n' "$name"
    done
  fi
}

# ---------------------------------------------------------------------------
# Apply TAB_THEME if set
# ---------------------------------------------------------------------------
_tabbing_apply_theme() {
  if [ -n "${TAB_THEME:-}" ]; then
    _tabbing_apply_named_theme "$TAB_THEME" || {
      echo "tabbing: unknown theme '$TAB_THEME'" >&2
      return 1
    }
  fi
}
