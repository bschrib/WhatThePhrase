# Kids Mode Feature Plan

## Overview
Add a "Kids Mode" to WhatThePhrase that provides simpler, child-friendly words and phrases that are easier for younger players (ages 5-10) to understand, describe, and guess.

## Feature Requirements

### Core Functionality
- Toggle in Settings to enable/disable Kids Mode
- When enabled, all categories show kid-friendly word lists instead of standard words
- Visual indicator that Kids Mode is active (child-friendly color scheme or icon)
- 20 easy words per category designed for children

### User Experience
- Kids Mode toggle should be prominent in SettingsView
- Consider a dedicated "Kids Mode" button on the main ContentView
- Use larger, more colorful UI elements when Kids Mode is active (optional enhancement)

---

## Kids Mode Word Lists (20 Easy Words Per Category)

### Kids: Places & Spaces
1. beach
2. park
3. zoo
4. school
5. library
6. playground
7. farm
8. forest
9. lake
10. mountain
11. desert
12. island
13. city
14. village
15. castle
16. treehouse
17. backyard
18. garden
19. swimming pool
20. campground

### Kids: Travel & Transit
1. car
2. bus
3. train
4. airplane
5. bicycle
6. boat
7. helicopter
8. fire truck
9. ambulance
10. police car
11. school bus
12. tractor
13. motorcycle
14. skateboard
15. scooter
16. wagon
17. rocket ship
18. submarine
19. hot air balloon
20. tricycle

### Kids: Household Items
1. chair
2. table
3. bed
4. lamp
5. clock
6. mirror
7. pillow
8. blanket
9. towel
10. soap
11. toothbrush
12. fork
13. spoon
14. plate
15. cup
16. broom
17. bucket
18. key
19. doorbell
20. refrigerator

### Kids: Cuisine & Beverages
1. pizza
2. hamburger
3. hot dog
4. sandwich
5. apple
6. banana
7. orange
8. milk
9. juice
10. water
11. cookie
12. ice cream
13. cake
14. candy
15. popcorn
16. cereal
17. peanut butter
18. jelly
19. cheese
20. spaghetti

### Kids: Life On Earth
1. dog
2. cat
3. bird
4. fish
5. rabbit
6. horse
7. cow
8. pig
9. chicken
10. duck
11. frog
12. butterfly
13. ladybug
14. bee
15. elephant
16. lion
17. monkey
18. bear
19. turtle
20. dinosaur

### Kids: Relatives & Relations
1. mom
2. dad
3. sister
4. brother
5. grandma
6. grandpa
7. baby
8. cousin
9. aunt
10. uncle
11. friend
12. teacher
13. neighbor
14. babysitter
15. doctor
16. dentist
17. firefighter
18. police officer
19. mailman
20. pet

### Kids: Random
1. rainbow
2. star
3. moon
4. sun
5. cloud
6. snow
7. rain
8. flower
9. tree
10. balloon
11. present
12. birthday
13. party
14. magic
15. treasure
16. pirate
17. princess
18. superhero
19. robot
20. monster

### Kids: Gadgets & Innovations
1. phone
2. tablet
3. computer
4. TV
5. camera
6. flashlight
7. headphones
8. watch
9. remote control
10. video game
11. robot
12. walkie talkie
13. microphone
14. speaker
15. light bulb
16. fan
17. alarm clock
18. calculator
19. thermometer
20. telescope

### Kids: Past Chronicles
1. dinosaur
2. knight
3. pirate
4. cowboy
5. castle
6. treasure
7. king
8. queen
9. prince
10. princess
11. dragon
12. sword
13. shield
14. ship
15. map
16. gold
17. crown
18. throne
19. explorer
20. invention

### Kids: Pop Culture
1. cartoon
2. movie
3. song
4. dance
5. superhero
6. princess
7. clown
8. magician
9. puppet
10. teddy bear
11. doll
12. toy car
13. blocks
14. puzzle
15. sticker
16. costume
17. mask
18. cape
19. comic book
20. video game

### Kids: Games & Contests
1. hide and seek
2. tag
3. hopscotch
4. jump rope
5. hula hoop
6. ball
7. kite
8. bubbles
9. sandbox
10. swing
11. slide
12. seesaw
13. race
14. treasure hunt
15. Simon says
16. duck duck goose
17. musical chairs
18. freeze dance
19. red light green light
20. board game

---

## Implementation Plan

### Phase 1: Data Layer
1. Create `kids_wordlists.json` in `WhatThePhrase/Assets/WordLists/`
2. Update `RequestManager.swift` to:
   - Add a `isKidsMode: Bool` parameter
   - Load either standard or kids word lists based on the mode
   - Expose method to switch between modes

### Phase 2: Settings Integration
1. Update `SettingsView.swift`:
   - Add `@AppStorage("kidsMode")` boolean toggle
   - Add a "Kids Mode" section with a friendly description
   - Consider adding parental controls (optional)

### Phase 3: UI Updates
1. Update `ContentView.swift`:
   - Pass kids mode state to `RequestManager`
   - Optionally add visual indicator when Kids Mode is active
2. Update `GameView.swift`:
   - Ensure it respects the kids mode setting

### Phase 4: Visual Enhancements (Optional)
1. Add kid-friendly color themes
2. Add playful animations or icons
3. Consider larger touch targets for younger users

---

## Technical Details

### Files to Modify
- `WhatThePhrase/Assets/WordLists/wordlists.json` - Add kids version or create separate file
- `WhatThePhrase/RequestManager.swift` - Add kids mode logic
- `WhatThePhrase/SettingsView.swift` - Add kids mode toggle
- `WhatThePhrase/ContentView.swift` - Pass kids mode state

### New Files to Create
- `WhatThePhrase/Assets/WordLists/kids_wordlists.json` - Kids-friendly word lists

### AppStorage Key
```swift
@AppStorage("kidsMode") private var kidsMode: Bool = false
```

---

## Testing Considerations
- Verify all kids words are age-appropriate
- Test that mode switching works correctly mid-session
- Ensure used words tracking works separately for each mode
- UI testing with larger touch targets (if implemented)

---

## Future Enhancements
- Age-specific modes (toddler, elementary, etc.)
- Custom word list editor for parents
- Progress tracking for educational purposes
- Parental lock for returning to adult mode
