import Synchronized from "./states/synchorized";

export default class EditorClient {
  constructor(serverAdapter) {
    this.serverAdapter = serverAdapter;
    this.state = new Synchronized(this);
    this._onDelta = null;

    this.serverAdapter.onDelta((delta) => {
      this._handleServerDelta(delta);
    });

    this.serverAdapter.onAcknowledgement(() => {
      this._handleServerAcknowledgement();
    });
  }

  setEditorAdapter(adapter) {
    this.editorAdapter = adapter;

    this.editorAdapter.onDelta((delta) => {
      this._handleClientDelta(delta);
      this._emitDelta(delta);
    })
  }

  onDelta(callback) {
    this._onDelta = callback;
  };

  sendDelta(delta) {
    this.serverAdapter.sendDelta(delta);
  }

  _emitDelta(delta) {
    this._onDelta && this._onDelta(delta);
  }

  _handleServerDelta(delta) {
    this.state = this.state.onServerDelta(delta);
  }

  _handleClientDelta(delta) {
    console.log("handle client delta")
    this.state = this.state.onClientDelta(delta);
    console.log(this.state)
  }

  _handleServerAcknowledgement() {
    console.log("handle server acknowledge")
    console.log(this.state)
    this.state = this.state.onServerAcknowledgement();
  }
}
