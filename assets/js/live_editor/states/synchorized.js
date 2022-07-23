import AwaitingKnowledgement from "./awaiting_acknowledgement";

export default class Synchronized {
  constructor(client) {
    this.client = client;
  }

  onClientDelta(delta) {
    this.client.sendDelta(delta);
    return new AwaitingKnowledgement(this.client, delta);
  }

  onServerDelta(delta) {
  }

  onServerAcknowledgement() {
    throw new Error("Unexpected server acknowledgement.");
  }
};
