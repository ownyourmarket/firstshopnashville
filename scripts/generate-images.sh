#!/bin/bash
# First Shop Nashville — Higgsfield image batch generator
# Runs all generations sequentially, downloads to assets/images/
set -u

BASE="C:/Users/starr/projects/firstshopnashville/assets/images"
MODEL="soul_cinematic"
LOG="$BASE/../../scripts/gen.log"
> "$LOG"

# Format: <subfolder>|<filename>|<prompt>
PROMPTS=(
"hero|dealerships-hero.png|Cinematic wide shot of a sunlit independent used car dealership lot in Nashville Tennessee, rows of polished pre-owned American cars, warm golden hour light, deep navy sky with soft clouds, American flag gently waving, ultra-detailed photographic, magazine editorial style, anamorphic lens, 16:9"
"hero|auto-repair-hero.png|Cinematic warm interior of a Nashville auto repair garage, skilled mechanic working under a raised classic car, sparks of golden light, deep navy shadows, rich forest green tool chest, oil-stained concrete floor, dramatic side lighting, photographic editorial style, 16:9"
"hero|auto-detailing-hero.png|Cinematic macro photograph of gloved hands meticulously polishing the curved fender of a deep navy classic car, water beads, microfiber towel, warm golden hour reflection in paint, soft bokeh garage background, ultra-detailed product photography, magazine quality, 16:9"
"hero|new-car-dealers-hero.png|Cinematic modern Nashville car dealership showroom at blue hour dusk, sleek new vehicles under warm gold gallery lighting, polished concrete floor, floor-to-ceiling glass walls reflecting Nashville skyline, deep navy and forest green accents, architectural photography, 16:9"
"hero|things-to-do-hero.png|Cinematic night photograph of lower Broadway Nashville with iconic neon honky-tonk signs glowing warm gold and red, wet pavement reflections, deep navy night sky, lively street energy, blurred motion of people, photographic editorial, 16:9"
"hero|events-hero.png|Cinematic outdoor Nashville music festival at golden hour, crowd silhouettes with hands raised, stage glowing warm gold, deep navy twilight sky, string lights overhead, warm atmosphere, photographic editorial style, 16:9"
"hero|history-hero.png|Cinematic vintage Nashville street scene, 1960s Music Row, classic American cars parked along the curb, warm sepia gold tones with deep navy shadows, neon signs of historic recording studios, nostalgic photographic editorial, 16:9"
"hero|about-hero.png|Cinematic warm photograph of a small business owner standing proudly in front of a Nashville storefront at golden hour, hands on hips, genuine smile, deep navy painted facade with warm gold signage, American small town main street energy, photographic editorial, 16:9"
"hero|blog-hero.png|Cinematic overhead flat lay of a wooden writer's desk with a vintage Nashville street map, a steaming cup of black coffee, leather notebook, fountain pen, polaroid photos of Nashville landmarks, warm golden window light, deep navy linen background, magazine quality, 16:9"
"hero|submit-hero.png|Cinematic warm photograph of a Nashville auto shop owner unlocking the front door of his business at sunrise, key in hand, sign reading OPEN, warm gold morning light, deep navy storefront, hopeful proud expression, photographic editorial, 16:9"
"hero|contact-hero.png|Cinematic overhead view of Nashville from above at golden hour, rivers winding through the city, warm gold and deep navy tones, soft cinematic haze, aerial photographic editorial, 16:9"
"categories|dealerships-card.png|Square cinematic photograph of a single polished classic American sedan in deep navy paint parked in a Nashville lot, warm golden hour side lighting, soft forest green tree background, photographic editorial, 1:1"
"categories|auto-repair-card.png|Square cinematic close-up of a mechanic's experienced hands working on a chrome engine bay, warm gold workshop light, deep navy tool background, photographic editorial, 1:1"
"categories|auto-detailing-card.png|Square cinematic close-up of pristine reflective car paint with water droplets and a microfiber cloth, warm gold reflection, deep navy paint, photographic editorial, 1:1"
"categories|new-cars-card.png|Square cinematic photograph of a modern luxury SUV in a glass-walled showroom, warm gold ambient light, deep navy walls, photographic editorial, 1:1"
"lifestyle|nashville-food.png|Cinematic photograph of authentic Nashville hot chicken on a paper-lined tray with pickles and white bread, warm gold restaurant lighting, deep navy table, steam rising, photographic editorial food magazine quality, 16:9"
"lifestyle|nashville-music.png|Cinematic photograph of a live country music performance at a Nashville honky-tonk, warm gold stage lights on a guitarist mid-strum, deep navy audience silhouettes, photographic editorial, 16:9"
"lifestyle|nashville-culture.png|Cinematic photograph of the Parthenon replica in Nashville Centennial Park at golden hour, warm gold stone, deep navy reflecting pool, autumn foliage in forest green and gold, photographic editorial, 16:9"
"businesses|dealership-1.png|Square cinematic photograph of an independent Nashville used car dealership storefront with a welcoming owner standing under a hand-painted sign, warm gold sunset light, deep navy facade, 1:1"
"businesses|dealership-2.png|Square cinematic photograph of a family-run Nashville pre-owned car lot at twilight, string lights overhead, vehicles glowing warm gold, deep navy sky, 1:1"
"businesses|repair-1.png|Square cinematic photograph of a Nashville neighborhood auto repair shop exterior, two mechanics in branded coveralls standing proudly, warm gold light on chrome sign, deep navy garage doors, 1:1"
"businesses|repair-2.png|Square cinematic photograph of an organized vintage-feel Nashville mechanic shop interior with car on lift, warm gold work lights, deep navy walls with framed photos of restored cars, 1:1"
"businesses|detailing-1.png|Square cinematic photograph of a Nashville detailing studio bay with a freshly polished SUV under spotlight, warm gold lighting, deep navy walls, gleaming floor, 1:1"
"businesses|detailing-2.png|Square cinematic close-up of a craftsman applying ceramic coating to a luxury car hood inside a Nashville detail shop, warm gold lighting, deep navy paint, 1:1"
"businesses|new-cars-1.png|Square cinematic photograph of a modern Nashville new car dealership showroom floor with one hero vehicle on a turntable, warm gold ambient light, deep navy ceiling, 1:1"
"businesses|new-cars-2.png|Square cinematic photograph of a friendly Nashville new car salesperson handing keys to a happy customer in front of a vehicle, warm gold dealership lighting, 1:1"
)

i=0
total=${#PROMPTS[@]}
for entry in "${PROMPTS[@]}"; do
  i=$((i+1))
  IFS='|' read -r SUBDIR FNAME PROMPT <<< "$entry"
  OUT="$BASE/$SUBDIR/$FNAME"
  if [ -f "$OUT" ]; then
    echo "[$i/$total] SKIP (exists): $SUBDIR/$FNAME" | tee -a "$LOG"
    continue
  fi
  echo "[$i/$total] GEN: $SUBDIR/$FNAME" | tee -a "$LOG"
  URL=$(higgsfield generate create "$MODEL" --prompt "$PROMPT" --wait 2>>"$LOG" | tail -1)
  if [[ "$URL" == http* ]]; then
    curl -sL -o "$OUT" "$URL" && echo "  -> downloaded $(stat -c%s "$OUT" 2>/dev/null || stat -f%z "$OUT") bytes" | tee -a "$LOG"
  else
    echo "  -> FAILED, output was: $URL" | tee -a "$LOG"
  fi
done

echo "DONE — generated $total images" | tee -a "$LOG"
