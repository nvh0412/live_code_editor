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
      const focusableEl = event.target.closest(`[data-el-cell]`);
      this.pushEvent("queue_code_evaluation", { editor_id: focusableEl });
    }
  }
};

export default Session;
