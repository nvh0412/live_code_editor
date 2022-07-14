import monaco from "./live_editor/monaco";
import { settingsStore } from "./lib/settings";

class LiveEditor {
  constructor(hook, container, language, source, readOnly) {
    this.hook = hook;
    this.container = container;
    this.language = language;
    this.readOnly = readOnly;
    this.source = source;

    this._onMount = [];
    this._onChange = [];
  }

  isMounted() {
    return !!this.editor;
  }

  mount() {
    if (this.isMounted()) {
      throw new Error("The editor is already mounted");
    }

    this._mountEditor();
  }

  focus() {
    this._ensureMounted();

    this.editor.focus();
  }

  changeLanguage(language) {
    this._ensureMounted();

    monaco.editor.setModelLanguage(this.editor.getModel(), language);
  }

  _ensureMounted() {
    if (!this.isMounted()) {
      this.mount();
    }
  }

  _mountEditor() {
    const settings = settingsStore.get();

    this.editor = monaco.editor.create(this.container, {
      language: this.language,
      value: this.source,
      readOnly: this.readOnly,
      scrollbar: {
        vertical: "hidden",
        alwaysConsumeMouseWheel: false,
      },
      minimap: {
        enabled: false,
      },
      overviewRulerLanes: 5,
      scrollBeyondLastLine: false,
      guides: {
        indentation: false,
      },
      occurrencesHighlight: false,
      renderLineHighlight: "none",
      theme: settings.editor_theme,
      fontFamily: "JetBrains Mono, Droid Sans Mono, monospace",
      fontSize: settings.editor_font_size,
      tabIndex: -1,
      tabSize: 2,
      autoIndent: true,
      formatOnType: true,
      formatOnPaste: true,
      quickSuggestions: this.intellisense && settings.editor_auto_completion,
      tabCompletion: "on",
      suggestSelection: "first",
      wordBasedSuggestions: !this.intellisense,
      parameterHints: this.intellisense && settings.editor_auto_signature,
      wordWrap: this.language === "markdown" && settings.editor_markdown_word_wrap ? "on" : "off",
    });

    this.editor.addAction({
      contextMenuGroupId: "word-wrapping",
      id: "enable-word-wrapping",
      label: "Enable word wrapping",
      precondition: "config.editor.wordWrap == off",
      keybindings: [monaco.KeyMod.Alt | monaco.KeyCode.KeyZ],
      run: (editor) => editor.updateOptions({ wordWrap: "on" }),
    });

    const resizeObserver = new ResizeObserver((entries) => {
      entries.forEach((_entry) => {
        if (this.container.offsetHeight > 0) {
          this.editor.layout();
        }
      });
    });

    resizeObserver.observe(this.container);

    this.editor.onDidContentSizeChange(() => {
      const contentHeight = this.editor.getContentHeight();
      this.container.style.height = `${contentHeight}px`;
    });

    const commandPaletteNode = this.editor.getContribution("editor.controller.quickInput").widget.domNode;
    commandPaletteNode.remove();
    this.editor._modelData.view._contentWidgets.overflowingContentWidgetsDomNode.domNode.appendChild(commandPaletteNode);
  }
}

export default LiveEditor;
