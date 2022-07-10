const CodeEditor = {
  mounted() {
    this.props = this.getProps();

    console.log('mounted', this.props)

    this.handleEvent(
      `editor_init:${this.props.cellId}:${this.props.tag}`,
      ({ source_view, language, intellisense, read_only }) => {
        debugger
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
}
