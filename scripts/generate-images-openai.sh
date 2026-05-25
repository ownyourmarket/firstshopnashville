#!/bin/bash
# First Shop Nashville — OpenAI gpt-image-1 batch generator
# Idempotent (skips files that exist). Bypasses the Higgsfield daily cap.
# Usage:  source .env && bash scripts/generate-images-openai.sh
set -u

if [ -z "${OPENAI_API_KEY:-}" ]; then
  if [ -f "C:/Users/starr/projects/firstshopnashville/.env" ]; then
    set -a; source "C:/Users/starr/projects/firstshopnashville/.env"; set +a
  fi
fi
: "${OPENAI_API_KEY:?OPENAI_API_KEY not set}"

BASE="C:/Users/starr/projects/firstshopnashville/assets/images"
LOG="$BASE/../../scripts/gen-openai.log"
> "$LOG"

# Format: subdir|filename|size|prompt
# gpt-image-1 sizes: 1024x1024 (square), 1536x1024 (landscape), 1024x1536 (portrait)
PROMPTS=(
"hero|things-to-do-hero.png|1536x1024|Cinematic editorial photograph of lower Broadway Nashville at night: glowing warm-gold neon honky-tonk signs reflecting on wet pavement, deep navy night sky, a hint of motion blur from passing pedestrians. Magazine-quality photographic realism, anamorphic lens, no text or logos, no captions."
"hero|events-hero.png|1536x1024|Cinematic editorial photograph of a Nashville outdoor music festival at golden hour: silhouettes of a joyful crowd with hands raised, stage glowing warm gold in the distance, deep navy twilight sky, warm string lights overhead, atmospheric haze. Magazine photographic realism, no text."
"hero|history-hero.png|1536x1024|Cinematic editorial photograph of vintage 1960s Music Row Nashville: classic American cars parked along the curb in front of historic recording studios, warm sepia-gold tones with deep navy shadows, weathered neon signs, a few pedestrians in period clothing. Nostalgic but photorealistic. No text."
"hero|about-hero.png|1536x1024|Cinematic editorial photograph of a small business owner standing proudly in front of a Nashville storefront at golden hour: hands on hips, genuine confident expression, deep-navy painted facade with subtle warm-gold signage hand-painted, American Main Street warmth, photographic realism. No text on signage."
"hero|blog-hero.png|1536x1024|Cinematic editorial overhead flat-lay: a wooden writer's desk with a vintage Nashville street map, a steaming cup of black coffee, a worn leather notebook, brass fountain pen, polaroid photos of Nashville landmarks scattered, warm golden window light, deep navy linen background. Magazine quality. No text on visible objects."
"hero|submit-hero.png|1536x1024|Cinematic editorial photograph of a Nashville auto shop owner unlocking the front door of his business at sunrise: keys in hand, hand-painted OPEN sign in window, warm gold morning light streaming sideways, deep navy storefront, quiet hopeful expression. Photographic realism, no readable text."
"hero|contact-hero.png|1536x1024|Cinematic editorial aerial photograph of Nashville at golden hour: the Cumberland River winding through downtown, warm gold and deep navy tones, soft atmospheric haze, the AT&T Batman building catching last light. Photorealistic, magazine quality, no text."
"categories|dealerships-card.png|1024x1024|Square cinematic editorial photograph of a single polished classic American sedan in deep navy metallic paint parked in a Nashville used car lot, warm golden hour side-lighting, soft forest-green tree foliage in background, photographic realism, no text or logos."
"categories|auto-repair-card.png|1024x1024|Square cinematic editorial close-up of an experienced mechanic's hands working on a chrome engine bay, warm gold workshop light, deep navy tool background, photographic realism, magazine quality, no text."
"categories|auto-detailing-card.png|1024x1024|Square cinematic editorial close-up of pristine reflective deep-navy car paint with crystal water droplets and a folded microfiber cloth, warm gold reflection in the paint, magazine product photography, no text."
"categories|new-cars-card.png|1024x1024|Square cinematic editorial photograph of a modern luxury SUV parked inside a glass-walled showroom, warm gold ambient overhead lighting, deep navy walls, polished concrete floor with subtle reflection, photographic realism, no logos or text."
"lifestyle|nashville-food.png|1536x1024|Cinematic editorial food photograph of authentic Nashville hot chicken plated on a paper-lined tray with pickle chips and white bread, warm gold restaurant lighting from above, deep navy table, light steam rising. Magazine food photography quality, photorealism, no text."
"lifestyle|nashville-music.png|1536x1024|Cinematic editorial photograph of a live country music performance at a Nashville honky-tonk: warm gold stage spotlights on a male guitarist mid-strum, deep navy audience silhouettes in foreground, magazine concert photography, photorealism, no readable text."
"lifestyle|nashville-culture.png|1536x1024|Cinematic editorial photograph of the Parthenon replica in Centennial Park Nashville at golden hour: warm gold stone columns, deep navy reflecting pool in the foreground, autumn foliage in forest green and amber gold. Photographic realism, no text or signage."
"businesses|dealership-1.png|1024x1024|Square cinematic editorial photograph of an independent Nashville used car dealership exterior: hand-painted hanging sign above a welcoming proud owner standing in the foreground, warm gold sunset light, deep navy painted facade, small American flag in the corner. Photorealistic, no readable text."
"businesses|dealership-2.png|1024x1024|Square cinematic editorial photograph of a family-run Nashville pre-owned car lot at twilight: warm string lights overhead, three or four classic American cars glowing warm gold, deep navy sky transitioning to forest green at horizon, photographic realism, no text."
"businesses|repair-1.png|1024x1024|Square cinematic editorial photograph of a Nashville neighborhood auto repair shop exterior: two mechanics in dark blue branded coveralls standing proudly with arms crossed in front of an open garage bay, warm gold late afternoon light on a chrome sign, deep navy garage doors, photographic realism, no readable text."
"businesses|repair-2.png|1024x1024|Square cinematic editorial photograph of an organized vintage-feel Nashville mechanic shop interior: car on a lift in the background, warm gold work lights, deep navy walls with framed black-and-white photos of restored cars, polished concrete floor, photographic realism, no text."
"businesses|detailing-1.png|1024x1024|Square cinematic editorial photograph of a Nashville detailing studio bay: a freshly polished black SUV centered under a single overhead spotlight, warm gold lighting, deep navy walls, gleaming concrete floor with mirror reflection, magazine quality, photorealism, no text."
"businesses|detailing-2.png|1024x1024|Square cinematic editorial close-up of a craftsman's gloved hand applying ceramic coating with a microfiber applicator to the hood of a luxury car inside a Nashville detail shop, warm gold side-lighting, deep navy paint reflecting, photographic realism, no text."
"businesses|new-cars-1.png|1024x1024|Square cinematic editorial photograph of a modern Nashville new car dealership showroom: one hero vehicle on a rotating turntable centered in the frame, warm gold ambient track lighting overhead, deep navy ceiling, polished floor, magazine architectural photography, no logos or text."
"businesses|new-cars-2.png|1024x1024|Square cinematic editorial photograph of a friendly Nashville new car salesperson handing keys to a happy customer in front of a vehicle: both smiling genuinely, warm gold dealership lighting, deep navy walls in background, photographic realism, no readable text."
)

i=0
total=${#PROMPTS[@]}
for entry in "${PROMPTS[@]}"; do
  i=$((i+1))
  IFS='|' read -r SUBDIR FNAME SIZE PROMPT <<< "$entry"
  OUT="$BASE/$SUBDIR/$FNAME"
  if [ -f "$OUT" ]; then
    echo "[$i/$total] SKIP (exists): $SUBDIR/$FNAME" | tee -a "$LOG"
    continue
  fi
  echo "[$i/$total] GEN: $SUBDIR/$FNAME ($SIZE)" | tee -a "$LOG"

  # OpenAI gpt-image-1: returns base64 in JSON.data[0].b64_json
  JSON=$(curl -sS https://api.openai.com/v1/images/generations \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$(jq -nc --arg p "$PROMPT" --arg s "$SIZE" \
      '{model:"gpt-image-1", prompt:$p, size:$s, n:1, quality:"high", output_format:"png"}')")

  ERR=$(echo "$JSON" | jq -r '.error.message // empty')
  if [ -n "$ERR" ]; then
    echo "  -> ERROR: $ERR" | tee -a "$LOG"
    continue
  fi

  B64=$(echo "$JSON" | jq -r '.data[0].b64_json // empty')
  if [ -z "$B64" ]; then
    echo "  -> unexpected response: $(echo "$JSON" | head -c 200)" | tee -a "$LOG"
    continue
  fi

  echo "$B64" | base64 -d > "$OUT"
  SIZE_BYTES=$(stat -c%s "$OUT" 2>/dev/null || stat -f%z "$OUT" 2>/dev/null)
  echo "  -> downloaded $SIZE_BYTES bytes" | tee -a "$LOG"
done

echo "DONE — processed $total prompts" | tee -a "$LOG"
