#!/bin/bash
MANIFESTS_DIR="$HOME/.local/share/com.twintaillauncher.ttl/manifests"
if [ ! -d "$MANIFESTS_DIR" ]; then
    echo "TwintailLauncher n'est pas installe. Installe-le d'abord : https://twintaillauncher.app"
    exit 1
fi
curl -L "https://raw.githubusercontent.com/Sankaiii/Zailon-game/main/nte_global.json" -o "$MANIFESTS_DIR/nte_global.json"
REPO="$MANIFESTS_DIR/repository.json"
if ! grep -q "nte_global.json" "$REPO"; then
    python3 -c "
import json
with open('$REPO') as f: r = json.load(f)
r['manifests'].append('nte_global.json')
with open('$REPO','w') as f: json.dump(r, f, indent=2)
"
fi
echo "Zailon installe ! Redemarre TwintailLauncher pour voir NTE."
