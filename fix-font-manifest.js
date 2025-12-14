const fs = require('fs');
const path = require('path');

const fontManifestPath = path.join(__dirname, 'flutter_app/build/web/assets/FontManifest.json');

console.log('🔧 Fixing FontManifest.json...');

// Create proper font manifest with MaterialIcons and Noto fonts
const fontManifest = [
  {
    "family": "MaterialIcons",
    "fonts": [
      {
        "asset": "fonts/MaterialIcons-Regular.otf"
      }
    ]
  },
  {
    "family": "Noto Sans",
    "fonts": [
      {
        "asset": "https://fonts.gstatic.com/s/notosans/v30/o-0IIpQlx3QUlC5A4PNr5TRA.woff2"
      }
    ]
  },
  {
    "family": "Noto Color Emoji",
    "fonts": [
      {
        "asset": "https://fonts.gstatic.com/s/notocoloremoji/v25/Yq6P-KqIXTD0t4D9z1ESnKM3-HpFab5s79iz64w.woff2"
      }
    ]
  }
];

try {
  fs.writeFileSync(fontManifestPath, JSON.stringify(fontManifest, null, 2));
  console.log('✅ FontManifest.json updated successfully!');
  console.log('📝 Added MaterialIcons and Noto fonts to manifest');
} catch (error) {
  console.error('❌ Error updating FontManifest.json:', error.message);
  process.exit(1);
}
