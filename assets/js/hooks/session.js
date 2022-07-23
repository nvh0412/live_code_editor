const Session = {
  mounted() {
    this.focusedId = null;

    this._handleDocumentClick = this.handleDocumentClick.bind(this);
    document.addEventListener("click", this._handleDocumentClick);
  },

  destroyed() {
    document.removeEventListener("click", this._handleDocumentClick);
  },

  handleDocumentClick(event) {
    const evalBtn = event.target.closest(
      `[data-el-queue-cell-evaluation-button]`
    );

    if (evalBtn) {
      const editorId = evalBtn.getAttribute("data-editor-id");
      this.pushEvent("queue_code_evaluation", { editor_id: editorId });
    }
  }
};

export default Session;
