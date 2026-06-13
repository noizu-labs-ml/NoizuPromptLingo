#!/bin/bash

# Random Game Premise Generator
# Randomly selects a template from game-premises.yaml and fills placeholders
# using random words from mad-libs-bank.yaml

set -e

# Directory paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREMISES_FILE="$SCRIPT_DIR/game-premises.yaml"
WORDS_FILE="$SCRIPT_DIR/mad-libs-bank.yaml"

# Check if required files exist
if [ ! -f "$PREMISES_FILE" ]; then
    echo "Error: $PREMISES_FILE not found"
    exit 1
fi

if [ ! -f "$WORDS_FILE" ]; then
    echo "Error: $WORDS_FILE not found"
    exit 1
fi

# Function to get random word from a category in the word bank
get_random_word() {
    local category="$1"
    # Extract the category array and count elements
    local count=$(yq ".$category | length" "$WORDS_FILE")

    if [ "$count" -eq 0 ]; then
        echo "[$category]"
        return
    fi

    # Get random index (0-based)
    local index=$((RANDOM % count))
    # Get the word at that index
    local word=$(yq ".$category[$index]" "$WORDS_FILE")
    echo "$word"
}

# Function to get random number (for {NUMBER} placeholder)
get_random_number() {
    echo "$((RANDOM % 10 + 1))"
}

# Function to get random time unit (for {TIME} placeholder)
get_random_time() {
    local times=("second" "minute" "hour" "day" "week" "month")
    echo "${times[$((RANDOM % ${#times[@]}))]}"
}

# Function to get random ordinal (for {FIRST} placeholder)
get_random_ordinal() {
    local ordinals=("first" "second" "third" "fourth" "fifth")
    echo "${ordinals[$((RANDOM % ${#ordinals[@]}))]}"
}

# Function to get random structure type (for {STRUCTURE} placeholder)
get_random_structure() {
    local structures=("tower" "castle" "wall" "bridge" "gate" "fortress" "temple" "shrine" "palace" "hall")
    echo "${structures[$((RANDOM % ${#structures[@]}))]}"
}

# Function to get random music type (for {MUSIC} placeholder)
get_random_music() {
    local musics=("song" "melody" "tune" "anthem" "ballad" "rhapsody" "symphony" "concerto" "sonata" "opus")
    echo "${musics[$((RANDOM % ${#musics[@]}))]}"
}

# Function to get random rhythm descriptor (for {RHYTHM} placeholder)
get_random_rhythm() {
    local rhythms=("beat" "pulse" "cadence" "tempo" "groove" "flow" "rhythm" "meter" "time" "measure")
    echo "${rhythms[$((RANDOM % ${#rhythms[@]}))]}"
}

# Function to capitalize first letter of a word
capitalize() {
    local word="$1"
    local first_char="${word:0:1}"
    local rest="${word:1}"
    echo "${first_char^^}${rest}"
}

# Get list of all genre categories from premises
genres=$(yq 'keys | .[]' "$PREMISES_FILE")

# Convert to array
readarray -t genre_array <<< "$genres"

# Select random genre
selected_genre="${genre_array[$((RANDOM % ${#genre_array[@]}))]}"

# Get random template from selected genre
template_count=$(yq ".$selected_genre | length" "$PREMISES_FILE")
template_index=$((RANDOM % template_count))
template=$(yq ".$selected_genre[$template_index]" "$PREMISES_FILE")

# Fill placeholders in the template
result="$template"

# Define placeholder mappings
declare -A placeholders=(
    ["ADJECTIVE"]="adjectives"
    ["SUBJECT"]="subjects"
    ["VERB"]="verbs"
    ["PLACE"]="places"
    ["MONSTER"]="monsters"
    ["NOUN"]="nouns"
    ["ITEM"]="items"
    ["EMOTION"]="emotions"
    ["GAME_ACTION"]="game_actions"
    ["ELEMENT"]="elements"
    ["FANTASY_CLASS"]="fantasy_classes"
)

# Process standard placeholders
for placeholder in "${!placeholders[@]}"; do
    category="${placeholders[$placeholder]}"
    replacement=$(get_random_word "$category")
    # Capitalize first letter
    replacement=$(capitalize "$replacement")
    result="${result//\{$placeholder\}/$replacement}"
done

# Handle special placeholders
result="${result//\{NUMBER\}/$(get_random_number)}"
result="${result//\{TIME\}/$(get_random_time)}"
result="${result//\{FIRST\}/$(get_random_ordinal)}"
result="${result//\{STRUCTURE\}/$(get_random_structure)}"
result="${result//\{MUSIC\}/$(get_random_music)}"
result="${result//\{RHYTHM\}/$(get_random_rhythm)}"

# Capitalize first letter of result
result=$(capitalize "$result")

# Output header and result
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Random Game Premise Generator"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🎮 Genre: $selected_genre"
echo ""
echo "📜 Premise:"
echo ""
echo "   $result"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"