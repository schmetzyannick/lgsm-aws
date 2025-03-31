import { APIGatewayProxyHandler } from "aws-lambda";
import "source-map-support/register";
import { HTMLFileFactory } from "./HTMLFileFactory";
import { EventParser } from "./EventParser";
import { EC2Utility } from "./EC2Utility";
import { IIncomingEvent } from "./IIncomingEvent";

async function routeEvent(
  parsedEvent: IIncomingEvent
): Promise<{ statusCode: number; body: string }> {
  switch (parsedEvent.resource) {
    case "allVMs": {
      const htmlContent = await HTMLFileFactory.generateHTML();
      return {
        statusCode: 200,
        body: htmlContent,
      };
    }
    case "startVM": {
      await EC2Utility.startVM(parsedEvent.body?.instanceId as string);
      return {
        statusCode: 200,
        body: JSON.stringify({instanceId: parsedEvent.body?.instanceId}),
      };
    }
    case "stopVM": {
      await EC2Utility.stopVM(parsedEvent.body?.instanceId as string);
      return {
        statusCode: 200,
        body: JSON.stringify({instanceId: parsedEvent.body?.instanceId}),
      };
    }
    default:
      throw new Error("Invalid resource in event event.resource.");
  }
}

export const handler: APIGatewayProxyHandler = async (
  event: unknown,
  _context: unknown
) => {
  try {
    const parsedEvent = EventParser.parse(event);
    return await routeEvent(parsedEvent);
  } catch (error: unknown) {
    return {
      statusCode: 400,
      body: JSON.stringify({
        message: "Invalid event format",
        error: (error as Error).message,
        event,
        context: _context,
      }),
    };
  }

  return {
    statusCode: 500,
    body: JSON.stringify({ message: "Unhandled case" }),
  };
};
