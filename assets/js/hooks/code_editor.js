import LiveEditor from "../live_editor";

const CodeEditor = {
  mounted() {
    this.props = this.getProps();

    this.handleEvent(
      `editor_init:${this.props.editorId}`,
      ({ source_view, language, intellisense, read_only }) => {
        const editorContainer = this.el.querySelector(
          `[data-el-editor-container]`
        );

        const editorEl = document.createElement("div");
        editorContainer.appendChild(editorEl);

        this.liveEditor = new LiveEditor(
          this,
          editorEl,
          language,
          source_view.source,
          read_only
        );
        this.liveEditor.mount();
      }
    );

    this.handleEvent(
      `editor_update:${this.props.editorId}`,
      ({ editorId, language }) => {
        this.liveEditor.changeLanguage(language);

        const editor = document.getElementById(`menu-${editorId}`);
        if (editor) editor.classList.remove('menu--open');
      }
    );
  },

  disconnected() {
    this.el.removeAttribute("id");
  },

  destroyed() {

  },

  getProps() {
    return {
      editorId: this.el.getAttribute("data-editor-id")
    };
  },
};

export default CodeEditor;
