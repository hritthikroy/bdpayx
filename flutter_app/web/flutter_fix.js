// Flutter Web Icon Fix
// This script ensures Material Icons font is loaded before Flutter initializes

(function() {
  'use strict';
  
  console.log('🔧 Flutter Icon Fix: Initializing...');
  
  // Method 1: Load from Google Fonts CDN
  function loadMaterialIconsFromCDN() {
    return new Promise((resolve, reject) => {
      const link = document.createElement('link');
      link.rel = 'stylesheet';
      link.href = 'https://fonts.googleapis.com/icon?family=Material+Icons';
      link.onload = () => {
        console.log('✅ Material Icons loaded from CDN');
        resolve();
      };
      link.onerror = () => {
        console.warn('⚠️ Failed to load Material Icons from CDN');
        reject();
      };
      document.head.appendChild(link);
    });
  }
  
  // Method 2: Load from local assets
  function loadMaterialIconsFromAssets() {
    const style = document.createElement('style');
    style.textContent = `
      @font-face {
        font-family: 'Material Icons';
        font-style: normal;
        font-weight: 400;
        font-display: block;
        src: url(assets/fonts/MaterialIcons-Regular.otf) format('opentype');
      }
    `;
    document.head.appendChild(style);
    console.log('✅ Material Icons font-face added from local assets');
  }
  
  // Method 3: Use Font Loading API
  function waitForFontLoad() {
    if (!document.fonts || !document.fonts.load) {
      console.log('⚠️ Font Loading API not supported');
      return Promise.resolve();
    }
    
    return document.fonts.load('400 24px "Material Icons"')
      .then(() => {
        console.log('✅ Material Icons font loaded via Font Loading API');
      })
      .catch((error) => {
        console.warn('⚠️ Font Loading API failed:', error);
      });
  }
  
  // Execute all methods
  async function initializeFonts() {
    try {
      // Try CDN first
      await loadMaterialIconsFromCDN();
      
      // Also add local fallback
      loadMaterialIconsFromAssets();
      
      // Wait for font to be ready
      await waitForFontLoad();
      
      // Give it a moment to settle
      await new Promise(resolve => setTimeout(resolve, 100));
      
      console.log('✅ Flutter Icon Fix: Complete!');
      
      // Check if fonts are actually loaded
      if (document.fonts && document.fonts.check) {
        const isLoaded = document.fonts.check('24px "Material Icons"');
        console.log('🔍 Material Icons check:', isLoaded ? '✅ Loaded' : '❌ Not loaded');
      }
      
    } catch (error) {
      console.error('❌ Flutter Icon Fix: Error:', error);
    }
  }
  
  // Start initialization immediately
  initializeFonts();
  
  // Also run after DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeFonts);
  }
  
})();
