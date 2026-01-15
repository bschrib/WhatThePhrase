# Kids Mode Feature Plan

## Overview

Add a "Kids Mode" feature to WhatThePhrase that provides simplified, kid-friendly categories with easier words suitable for younger players.

## Goals

- Create 20 easy alternate category word lists designed for children
- Add a toggle in Settings to enable/disable Kids Mode
- Maintain the same game mechanics but with age-appropriate content
- Ensure words are simple, common, and easily understood by children ages 5-10

## Technical Implementation

### 1. Kids Mode Word Lists

Create a new `wordlists-kids.json` file in `WhatThePhrase/Assets/WordLists/` with 20 categories containing simpler words.

**Proposed Kids Categories (20 total):**

1. **Animals** - dog, cat, fish, bird, horse, cow, pig, duck, frog, lion, tiger, bear, elephant, monkey, rabbit, snake, turtle, butterfly, bee, dolphin
2. **Colors** - red, blue, green, yellow, orange, purple, pink, brown, black, white, gray, gold, silver, rainbow, sky blue, grass green, sunshine, midnight, cherry, ocean
3. **Foods** - apple, banana, pizza, cookie, ice cream, bread, milk, cheese, egg, carrot, chicken, rice, pasta, cake, candy, juice, water, cereal, sandwich, grapes
4. **Toys** - ball, doll, blocks, puzzle, teddy bear, car, truck, train, bike, kite, balloon, bubbles, crayons, play-doh, swing, slide, jump rope, yo-yo, frisbee, skateboard
5. **Family** - mom, dad, brother, sister, grandma, grandpa, baby, aunt, uncle, cousin, friend, neighbor, pet, family, twins, triplets, parents, child, kid, grown-up
6. **Body Parts** - head, hand, foot, arm, leg, eye, ear, nose, mouth, hair, finger, toe, knee, elbow, shoulder, back, tummy, chin, neck, cheek
7. **Clothes** - shirt, pants, shoes, socks, hat, coat, dress, shorts, sweater, jacket, boots, gloves, scarf, belt, tie, pajamas, swimsuit, uniform, cape, crown
8. **Weather** - sunny, rainy, cloudy, windy, snowy, hot, cold, warm, cool, stormy, foggy, rainbow, thunder, lightning, ice, frost, hail, breeze, sunshine, puddle
9. **Vehicles** - car, bus, truck, train, airplane, boat, bike, motorcycle, helicopter, rocket, submarine, tractor, ambulance, fire truck, police car, taxi, van, scooter, wagon, skateboard
10. **Sports** - soccer, baseball, basketball, football, tennis, swimming, running, jumping, dancing, skating, skiing, golf, volleyball, bowling, gymnastics, karate, yoga, catch, race, game
11. **Shapes** - circle, square, triangle, rectangle, star, heart, diamond, oval, cube, sphere, cone, cylinder, pentagon, hexagon, arrow, cross, crescent, spiral, zigzag, dot
12. **Numbers** - one, two, three, four, five, six, seven, eight, nine, ten, zero, dozen, hundred, thousand, million, first, second, third, fourth, fifth
13. **School** - teacher, desk, book, pencil, paper, crayon, scissors, glue, ruler, backpack, lunch box, classroom, playground, recess, homework, test, reading, writing, math, art
14. **House Rooms** - bedroom, bathroom, kitchen, living room, dining room, garage, basement, attic, hallway, closet, porch, yard, garden, stairs, door, window, roof, wall, floor, ceiling
15. **Nature** - tree, flower, grass, rock, river, lake, ocean, mountain, hill, forest, garden, leaf, branch, root, seed, dirt, mud, sand, shell, cloud
16. **Fruits & Veggies** - apple, orange, banana, strawberry, grape, watermelon, lemon, peach, pear, cherry, carrot, broccoli, corn, potato, tomato, lettuce, cucumber, peas, beans, pumpkin
17. **Action Words** - run, jump, walk, sit, stand, sleep, eat, drink, play, sing, dance, read, write, draw, paint, climb, swim, fly, kick, throw
18. **Feelings** - happy, sad, angry, scared, excited, tired, hungry, silly, brave, kind, shy, proud, surprised, worried, calm, love, laugh, cry, smile, hug
19. **Music** - song, dance, drum, piano, guitar, singing, clapping, music, band, concert, rhythm, beat, loud, quiet, fast, slow, high, low, melody, whistle
20. **Bedtime** - sleep, dream, pillow, blanket, pajamas, teddy bear, night light, story, lullaby, yawn, stars, moon, quiet, cozy, snuggle, goodnight, rest, nap, dark, soft

### 2. UI Changes

#### SettingsView.swift
- Add new toggle: "Kids Mode" (`@AppStorage("kidsMode")`)
- When enabled, app uses simplified word lists
- Add visual indicator (kid-friendly icon) when Kids Mode is active

#### ContentView.swift
- Read `kidsMode` from AppStorage
- Pass to `RequestManager` to determine which word list to load
- Show different category names based on mode
- Optional: Add a kid-friendly visual theme (brighter colors, larger fonts)

#### RequestManager.swift
- Add method `loadKidsWordlists()` to load `wordlists-kids.json`
- Modify `asyncGetRandomWord()` to accept a `kidsMode` parameter
- Add `kidsCategories` array with the 20 kids category names

### 3. File Changes Summary

| File | Change Type | Description |
|------|-------------|-------------|
| `WhatThePhrase/Assets/WordLists/wordlists-kids.json` | New | Kids mode word lists |
| `WhatThePhrase/SettingsView.swift` | Modify | Add Kids Mode toggle |
| `WhatThePhrase/ContentView.swift` | Modify | Support category switching |
| `WhatThePhrase/RequestManager.swift` | Modify | Load appropriate word lists |
| `WhatThePhrase/GameView.swift` | Modify | Pass kids mode state |

## Implementation Steps

### Phase 1: Data Layer
1. Create `wordlists-kids.json` with all 20 categories
2. Update `RequestManager.swift` to support loading kids word lists
3. Add `kidsCategories` array to `RequestManager`

### Phase 2: Settings
1. Add `@AppStorage("kidsMode")` property
2. Add Kids Mode toggle UI to `SettingsView.swift`
3. Include in "Reset to Default Settings" function

### Phase 3: Category Selection
1. Update `ContentView.swift` to read kids mode setting
2. Conditionally display appropriate categories
3. Pass mode through to game view

### Phase 4: Game Logic
1. Ensure `GameView` uses correct word lists based on mode
2. Test all categories in both modes

### Phase 5: Polish
1. Add visual indicators for Kids Mode
2. Consider kid-friendly color scheme option
3. Update app icon badge or indicator (optional)

## Testing Plan

1. **Unit Tests**
   - Verify `loadKidsWordlists()` returns valid data
   - Test category switching logic
   - Verify word randomization works for kids lists

2. **UI Tests**
   - Toggle Kids Mode on/off
   - Verify correct categories display
   - Play through each kids category

3. **Manual Testing**
   - Age-appropriateness review of all words
   - Test with actual children for usability feedback

## Future Enhancements

- Multiple difficulty levels (Easy, Medium, Hard)
- Age-specific modes (5-7, 8-10, 11+)
- Parental controls/PIN to exit Kids Mode
- Custom kids themes (princess, dinosaur, space, etc.)
- Sound effects and animations for correct answers in Kids Mode
- Achievement badges for kids

## Branch Strategy

- Development branch: `feature/kid-mode`
- Create from: `main`
- Merge to: `main` after testing
