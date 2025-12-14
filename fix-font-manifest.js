const fs = require('fs');
const path = require('path');

const fontManifestPath = path.join(__dirname, 'flutter_app/build/web/assets/FontManifest.json');

console.log('🔧 Fixing FontManifest.json...');

// Create proper font manifest
const fontManifest = [
  {
    "family": "MaterialIcons",
    "fonts": [
      {
        "asset": "fonts/MaterialIcons-Regular.otf"
      }
    ]
  }
];

try {
  fs.writeFileSync(fontManifestPath, JSON.stringify(fontManifest, null, 2));
  console.log('✅ FontManifest.json updated successfully!');
  console.log('📝 Added MaterialIcons font to manifest');
} catch (error) {
  console.error('❌ Error updating FontManifest.json:', error.message);
  process.exit(1);
}
