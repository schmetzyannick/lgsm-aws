import { APIGatewayProxyHandler } from "aws-lambda";
import "source-map-support/register";
import { HTMLFileFactory } from "./HTMLFileFactory";
import { EventParser } from "./EventParser";

export const handler: APIGatewayProxyHandler = async (
  event: unknown,
  _context: unknown
) => {
  try {
    const parsedEvent = EventParser.parse(event);
    if (parsedEvent.resource === "allVMs") {
      const htmlContent = await HTMLFileFactory.generateHTML();
      return {
        statusCode: 200,
        body: htmlContent,
      };
    }
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
