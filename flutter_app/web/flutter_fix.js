// Flutter Web Icon Fix - Enhanced
// This script ensures Material Icons font is loaded properly before Flutter initializes

(function() {
  'use strict';

  console.log('🔧 Enhanced Flutter Icon Fix: Initializing...');

  // Method 1: Load from Google Fonts CDN (backup)
  function loadMaterialIconsFromCDN() {
    return new Promise((resolve, reject) => {
      // Remove existing Material Icons link if present
      const existingLink = document.querySelector('link[href*="Material+Icons"]');
      if (existingLink) {
        existingLink.remove();
      }

      const link = document.createElement('link');
      link.rel = 'stylesheet';
      link.href = 'https://fonts.googleapis.com/icon?family=Material+Icons';
      link.crossOrigin = 'anonymous';
      link.onload = () => {
        console.log('✅ Material Icons loaded from CDN');
        resolve();
      };
      link.onerror = (error) => {
        console.warn('⚠️ Failed to load Material Icons from CDN:', error);
        resolve(); // Resolve anyway to continue execution
      };
      document.head.appendChild(link);
    });
  }

  // Method 2: Force load from local assets using CSS injection
  function loadMaterialIconsFromLocalAssets() {
    // Remove any existing Material Icons font-face declarations
    const existingStyles = document.querySelectorAll('style[data-material-icons]');
    existingStyles.forEach(style => style.remove());

    const style = document.createElement('style');
    style.setAttribute('data-material-icons', 'true');

    // Using local font first, then CDN fallback
    style.textContent = `
      @font-face {
        font-family: 'Material Icons';
        font-style: normal;
        font-weight: 400;
        font-display: swap;
        src: url('fonts/MaterialIcons-Regular.otf') format('opentype'),
             url('https://fonts.gstatic.com/s/materialicons/v149/flUhRq6tzZclQEJ-Vdg-IuiaDsNZ.ttf') format('truetype');
      }

      .material-icons {
        font-family: 'Material Icons';
        font-weight: normal;
        font-style: normal;
        font-size: 24px;
        line-height: 1;
        letter-spacing: normal;
        text-transform: none;
        display: inline-block;
        white-space: nowrap;
        word-wrap: normal;
        direction: ltr;
        -webkit-font-feature-settings: 'liga';
        -webkit-font-smoothing: antialiased;
      }

      /* Additional fix for any icon elements */
      [class*="Icon"], [class*="icon"], .icon, .md-icon {
        font-family: 'Material Icons' !important;
      }
    `;

    document.head.appendChild(style);
    console.log('✅ Material Icons font-face added from CDN source (FontManifest.json was empty)');
  }

  // Method 3: Preload the font file
  function preloadFontFile() {
    // Preload local font first
    const preloadLink = document.createElement('link');
    preloadLink.rel = 'preload';
    preloadLink.href = 'fonts/MaterialIcons-Regular.otf';
    preloadLink.as = 'font';
    preloadLink.type = 'font/otf';
    preloadLink.crossOrigin = 'anonymous';
    document.head.appendChild(preloadLink);

    console.log('✅ Material Icons font preloaded from local assets');
  }

  // Method 4: Extended Font Loading API
  function waitForFontLoad() {
    if (!document.fonts) {
      console.log('⚠️ Document fonts API not supported');
      return Promise.resolve();
    }

    // Define the font we're waiting for
    const fontLoadPromise = document.fonts.load('400 24px Material Icons')
      .catch(() => {
        // Fallback: try with the CSS class
        console.log('⚠️ Could not load via font API, using CSS fallback');
      });

    // Give a timeout in case font loading takes too long
    const timeoutPromise = new Promise(resolve => setTimeout(resolve, 500));

    return Promise.race([fontLoadPromise, timeoutPromise]);
  }

  // Method 5: Force refresh all Flutter icon elements after font loads
  function forceFlutterIconRefresh() {
    // Wait a bit after fonts load, then trigger a refresh of icon elements
    setTimeout(() => {
      // Look for elements that might be icons and force a redraw
      const iconSelectors = ['.material-icons', '[class*="Icon"]', '[class*="icon"]', '.icon', '.md-icon'];
      iconSelectors.forEach(selector => {
        const elements = document.querySelectorAll(selector);
        elements.forEach(el => {
          if (el.textContent.trim()) {
            // Temporarily hide and show to force rerender
            const originalDisplay = el.style.display;
            el.style.display = 'none';
            setTimeout(() => {
              el.style.display = originalDisplay;
            }, 1);
          }
        });
      });

      console.log('✅ Flutter icons refreshed after font loading');
    }, 500);
  }

  // Method 6: Check and repair icon elements periodically
  function monitorAndFixIcons() {
    // Check every 2 seconds for 15 seconds and fix any broken icon elements
    const interval = setInterval(() => {
      const iconElements = document.querySelectorAll('.material-icons, [class*="Icon"]');
      iconElements.forEach(el => {
        // If element looks like it has a box character (missing icon), force font refresh
        const textContent = el.textContent.trim();

        // Check if text content contains box/square characters (indicating missing font)
        if (textContent && (textContent.includes('') || textContent.includes('□') || textContent.includes('☐') ||
            textContent.includes('▯') || textContent.includes('?') || /[\u25A0-\u25FF]/.test(textContent))) {
          console.log('⚠️ Found broken icon, attempting repair:', textContent);

          // Force element refresh
          const originalContent = el.textContent;
          const originalStyle = el.style.fontFamily;

          // Temporarily change font to force refresh
          el.style.fontFamily = 'Arial, sans-serif';
          setTimeout(() => {
            el.style.fontFamily = originalStyle;
          }, 10);
        }

        // Also check if there's text content but no proper icons showing
        // by checking if the computed font family is not Material Icons
        const computedStyle = window.getComputedStyle(el);
        if (el.textContent.trim() && !computedStyle.fontFamily.includes('Material Icons')) {
          // Try to force the font family
          el.style.fontFamily = "'Material Icons', serif !important";
        }
      });
    }, 2000);

    // Stop checking after 15 seconds
    setTimeout(() => clearInterval(interval), 15000);
  }

  // Execute all methods in sequence
  async function initializeFonts() {
    try {
      console.log('🎯 Starting enhanced icon loading sequence...');

      // Step 1: Preload font file
      preloadFontFile();

      // Step 2: Load local font first (higher priority)
      loadMaterialIconsFromLocalAssets();

      // Step 3: Load CDN backup
      await loadMaterialIconsFromCDN();

      // Step 4: Wait for font to be ready
      await waitForFontLoad();

      // Step 5: Force refresh after font loads
      forceFlutterIconRefresh();

      // Step 6: Monitor and fix icons periodically
      monitorAndFixIcons();

      console.log('✅ Enhanced Flutter Icon Fix: Complete!');

      // Final check
      setTimeout(() => {
        if (document.fonts && document.fonts.check) {
          const isLoaded = document.fonts.check('400 24px Material Icons');
          console.log('🔍 Final Material Icons check:', isLoaded ? '✅ Fully loaded' : '⚠️ May still be loading');
        }
      }, 2000);

    } catch (error) {
      console.error('❌ Enhanced Flutter Icon Fix: Error:', error);
    }
  }

  // Start initialization immediately
  initializeFonts();

  // Also run after DOM is ready (double guarantee)
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeFonts);
  }

  // Final backup: run after a delay if fonts still not loaded
  window.addEventListener('load', () => {
    setTimeout(() => {
      if (document.fonts && document.fonts.ready) {
        document.fonts.ready.then(() => {
          console.log('Fonts ready promise resolved');
        });
      }
      initializeFonts(); // Try again on load
    }, 2000);
  });

})();
