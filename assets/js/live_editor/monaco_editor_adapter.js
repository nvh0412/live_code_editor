import Delta from 'quill-delta';

export default class MonacoEditorAdapter {
  constructor(editor) {
    this.editor = editor;
    this._onDelta = null;

    this.editor.onDidChangeModelContent((event) => {
      this._onDelta && this._onDelta(this._deltaFromEditorChange(event));
    });
  }

  onDelta(callback) {
    this._onDelta = callback;
  };

  _onDelta(callback) {
    this._onDelta = callback;
  }

  _deltaFromEditorChange(event) {
    const deltas = event.changes.map((change) => {
      const { rangeOffset, rangeLength, text } = change;

      const delta = new Delta();

      if (rangeOffset) {
        delta.retain(rangeOffset);
      }

      if (text) {
        delta.insert(text);
      }

      if (rangeLength) {
        delta.delete(rangeLength);
      }

      return delta;
    });

    return deltas.reduce((acc, delta) => acc.compose(delta));
  }
};
