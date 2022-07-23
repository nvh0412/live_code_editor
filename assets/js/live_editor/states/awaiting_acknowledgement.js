import AwaitingWithBuffer from "./awaiting_with_buffer";
import Synchronized from "./synchorized";

export default class AwaitingKnowledgement {
  constructor(client, awaitedDelta) {
    this.client = client;
    this.awaitedDelta = awaitedDelta;
  }

  onClientDelta(delta) {
    return new AwaitingWithBuffer(this.client, this.awaitedDelta, delta);
  }

  onServerDelta(delta) {
  }

  onServerAcknowledgement() {
    return new Synchronized(this.client);
  }
}
