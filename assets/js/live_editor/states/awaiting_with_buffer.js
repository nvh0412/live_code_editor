import AwaitingKnowledgement from "./awaiting_acknowledgement";

export default class AwaitingWithBuffer {
  constructor(client, awaitedDelta, bufferDelta) {
    this.client = client;
    this.awaitedDelta = awaitedDelta;
    this.bufferDelta = bufferDelta;
  }

  onClientDelta(delta) {
    const newBuffer = this.bufferDelta.compose(delta);
    return new AwaitingWithBuffer(this.client, this.awaitedDelta, newBuffer);
  }

  onServerDelta(delta) {
  }

  onServerAcknowledgement() {
    this.client.sendDelta(this.bufferDelta);
    return new AwaitingKnowledgement(this.client, this.bufferDelta);
  }
}
