import { IIncomingEvent } from "./IIncomingEvent";

/**
 * Parsers incoming events and throws appropiate errors if the event is not valid.
 */
export class EventParser {
  /**
   * Parses the incoming event and throws an error if the event is not valid.
   * @param event The incoming event to parse.
   * @returns The parsed event.
   */
  public static parse(event: unknown): IIncomingEvent {
    if (typeof event === "object" && event !== null) {
      if ("resource" in event && typeof event.resource === "string") {
        if (
          event.resource === "/startVM" ||
          event.resource === "/stopVM" ||
          event.resource === "/allVMs"
        ) {
          event.resource = event.resource.replace("/", "") as IIncomingEvent["resource"];
          return event as IIncomingEvent;
        } else {
          throw new Error("Invalid resource in event event.resource.");
        }
      } else {
        throw new Error("Event has no resource or resource is not a string.");
      }
    } else {
      throw new Error("Event is not an object.");
    }
  }
}
