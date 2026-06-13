#!/usr/bin/env python3
import random
import yaml

# Load the mad-libs bank
with open('/Users/keithbrings/Github/infra/k8/repos/incubator/projects/game-workshop/mad-libs-bank.yaml', 'r') as f:
    bank = yaml.safe_load(f)

# Load game premises
with open('/Users/keithbrings/Github/infra/k8/repos/incubator/projects/game-workshop/game-premises.yaml', 'r') as f:
    premises = yaml.safe_load(f)

# Generate 12 random words from various categories
random_words = {
    'subjects': random.sample(bank['subjects'], 2),
    'adjectives': random.sample(bank['adjectives'], 2),
    'verbs': random.sample(bank['verbs'], 2),
    'nouns': random.sample(bank['nouns'], 2),
    'places': [random.choice(bank['places'])],
    'monsters': [random.choice(bank['monsters'])],
    'items': [random.choice(bank['items'])],
    'emotions': [random.choice(bank['emotions'])],
    'colors': [random.choice(bank['colors'])],
    'elements': [random.choice(bank['elements'])],
    'fantasy_creatures': [random.choice(bank['fantasy_creatures'])],
    'fantasy_classes': [random.choice(bank['fantasy_classes'])]
}

print("=== RANDOM WORDS GENERATED ===")
for category, words in random_words.items():
    print(f"{category}: {', '.join(words)}")

# Pick 3 persona types
personas = random.sample(['Flow State', 'Emergent Sandbox', 'Aesthetic Purist', 'Story-Driven Explorer', 'Challenge Seeker'], 3)
print(f"\n=== PERSONAS SELECTED ===")
for i, persona in enumerate(personas, 1):
    print(f"{i}. {persona}")

# Create 5 premises using mad-libs templates
print(f"\n=== GENERATED PREMISES ===")

# Flatten random words into a pool
word_pool = {k.upper(): v for k, v in random_words.items()}

def replace_placeholders(template, words):
    result = template

    # Define mapping and track usage
    placeholder_map = {
        '{SUBJECT}': 'subjects',
        '{ADJECTIVE}': 'adjectives',
        '{VERB}': 'verbs',
        '{NOUN}': 'nouns',
        '{PLACE}': 'places',
        '{MONSTER}': 'monsters',
        '{ITEM}': 'items',
        '{EMOTION}': 'emotions',
        '{COLOR}': 'colors',
        '{ELEMENT}': 'elements',
        '{FANTASY_CREATURE}': 'fantasy_creatures',
        '{FANTASY_CLASS}': 'fantasy_classes',
        '{GAME_ACTION}': 'game_actions',
    }

    used_indices = {cat: 0 for cat in words.keys()}

    for placeholder in sorted(placeholder_map.keys(), key=len, reverse=True):
        category = placeholder_map[placeholder]
        if category in words and placeholder in result:
            word_list = words[category]
            idx = used_indices[category] % len(word_list)
            result = result.replace(placeholder, word_list[idx], 1)
            used_indices[category] += 1

    return result

# Select 5 random template categories
template_categories = random.sample(list(premises['premises'].keys()), 5)

generated_prems = []
for i, category in enumerate(template_categories, 1):
    template = random.choice(premises['premises'][category])
    filled = replace_placeholders(template, word_pool)
    generated_prems.append((i, category, filled))
    print(f"\n{i}. [{category}]\n   {filled}")

# Save to file
with open('/tmp/premises_output.txt', 'w') as out:
    out.write("=== RANDOM WORDS GENERATED ===\n")
    for category, words in random_words.items():
        out.write(f"{category}: {', '.join(words)}\n")
    out.write(f"\n=== PERSONAS SELECTED ===\n")
    for i, persona in enumerate(personas, 1):
        out.write(f"{i}. {persona}\n")
    out.write(f"\n=== GENERATED PREMISES ===\n")
    for i, category, filled in generated_prems:
        out.write(f"\n{i}. [{category}]\n   {filled}\n")

print("\nSaved to /tmp/premises_output.txt")