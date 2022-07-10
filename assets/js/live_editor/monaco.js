import * as monaco from "monaco-editor/esm/vs/editor/editor.api";
import { theme, highContrast } from "./theme";

// Define custom theme
monaco.editor.defineTheme("default", theme);
monaco.editor.defineTheme("highContrast", highContrast);

document.fonts.addEventListener("loadingdone", (event) => {
  const jetBrainsMonoLoaded = event.fontfaces.some(
    // font-family may be either "JetBrains Mono" or "\"JetBrains Mono\""
    (fontFace) => fontFace.family.includes("JetBrains Mono")
  );

  if (jetBrainsMonoLoaded) {
    // We use JetBrains Mono in all instances of the editor,
    // so we wait until it loads and then tell Monaco to remeasure
    // fonts and updates its cache.
    monaco.editor.remeasureFonts();
  }
});

export default monaco;

