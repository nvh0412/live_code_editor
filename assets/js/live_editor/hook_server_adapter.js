export default class HookServerAdapter {
  constructor(hook, editorId) {
    this.hook = hook;
    this.editorId = editorId;
    this._onDelta = null;
    this._onAcknowledgement = null;

    this.hook.handleEvent(
      `editor_delta`,
      ({ delta }) => {
        this._onDelta && this._onDelta(delta);
      }
    )

    this.hook.handleEvent(
      `editor_acknowledgement:${this.editorId}`,
      () => {
        this._onAcknowledgement && this._onAcknowledgement();
      }
    );
  }

  onDelta(callback) {
    this._onDelta = callback;
  }

  onAcknowledgement(callback) {
    this._onAcknowledgement = callback;
  }

  sendDelta(delta) {
    this.hook.pushEvent("apply_view_delta", {
      editor_id: this.editorId,
      delta: delta
    });
  }
}
