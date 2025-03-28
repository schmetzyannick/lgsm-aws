import { APIGatewayProxyHandler } from "aws-lambda";
import "source-map-support/register";
import { HTMLFileFactory } from "./HTMLFileFactory";

export const handler: APIGatewayProxyHandler = async (
  event: unknown,
  _context: unknown
) => {
  const htmlContent = await HTMLFileFactory.generateHTML();

  return {
    statusCode: 200,
    body: htmlContent,
  };
};
