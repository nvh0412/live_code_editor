
const Session = {
  mounted() {
    console.log('Mounted')

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
    }
  }
};

export default Session;
