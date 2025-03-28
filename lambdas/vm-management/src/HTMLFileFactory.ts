import {
  EC2Client,
  DescribeInstancesCommand,
  DescribeInstancesCommandOutput,
} from "@aws-sdk/client-ec2";
import { IInstanceInformation } from "./IInstanceInformation";

/**
 * Generates HTML files based on the currents state of the VMs.
 */
export class HTMLFileFactory {
  private static readonly client = new EC2Client({ region: "eu-west-1" });

  /**
   * Generates webpage based on current state of the VMs.
   * @returns HTML content that displays all EC2 instances that have the tag "VMManagment" set to "true".
   */
  public static async generateHTML(): Promise<string> {
    const instances = await this.getAllVMsThatShouldBeDisplayed();
    const htmlContent = `${this.getHTMLPartBeforeInstances()}${this.generateHTMLForInstances(
      instances
    )}${this.getHTMLPartAfterInstances()}`;
    return htmlContent;
  }

  private static getHTMLPartAfterInstances(): string {
    return `
        
    <script>
        function startInstance(instanceName) {
            alert('Starting ' + instanceName);
            // Add your start instance logic here
        }

        function stopInstance(instanceName) {
            alert('Stopping ' + instanceName);
            // Add your stop instance logic here
        }
    </script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/materialize/1.0.0/js/materialize.min.js"></script>
</body>
</html>`;
  }

  private static getHTMLPartBeforeInstances(): string {
    return `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EC2 Instance Management</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Roboto:300,400,500,700&display=swap" />
    <link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/materialize/1.0.0/css/materialize.min.css">
    <style>
        body {
            font-family: 'Roboto', sans-serif;
            background-color: #121212;
            color: #ffffff;
            display: flex;
            flex-direction: column;
            align-items: center; /* Center horizontally */
            justify-content: flex-start; /* Align to the top */
            height: 100vh;
            margin: 0;
        }
        .container {
            width: 80%;
            max-width: 800px;
            margin-top: 20px; /* Add some spacing from the top */
        }
        .instance {
            margin-bottom: 20px;
            padding: 20px;
            background-color: #1e1e1e;
            border-radius: 8px;
        }
        .instance-name {
            font-weight: bold;
            font-size: 1.2em;
        }
        .instance-ip {
            margin-left: 10px;
            color: #b0bec5;
        }
        .buttons {
            margin-top: 10px;
        }
        button {
            margin-right: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>EC2 Instance Management</h1>`;
  }

  private static generateHTMLForInstances(
    instances: IInstanceInformation[]
  ): string {
    return instances
      .map(
        (instance) => `
            <div class="instance">
                <div class="instance-name">${instance.name}<span class="instance-ip">Public IP: ${instance.publicIP}</span></div>
                <div class="instance-status"><span class="instance-ip">Status: ${instance.status}</span></div>
                <div class="buttons">
                    <button class="btn waves-effect waves-light" onclick="startInstance('${instance.id}')">Start</button>
                    <button class="btn waves-effect waves-light red" onclick="stopInstance('${instance.id}')">Stop</button>
                </div>
            </div>
        `
      )
      .join("");
  }

  /**
   * Get name and id of all EC2 instances that have the tag "VMManagment" set to "true".
   */
  private static async getAllVMsThatShouldBeDisplayed(): Promise<
    IInstanceInformation[]
  > {
    // Get all instances
    const command = new DescribeInstancesCommand({});
    const response: DescribeInstancesCommandOutput = await this.client.send(
      command
    );
    // Filter instances that have the tag "VMManagment" set to "true"
    return (
      response.Reservations?.flatMap(
        (reservation) =>
          reservation.Instances?.forEach((instance) => {
            // check if tag "VMManagment" is set to "true"
            const vmManagementTag = instance.Tags?.find(
              (tag) => tag.Key === "VMManagment" && tag.Value === "true"
            );
            if (vmManagementTag) {
              const nameTag = instance.Tags?.find((tag) => tag.Key === "Name");
              const publicIP = instance.PublicIpAddress;
              const status = instance.State?.Name;
              return {
                id: instance.InstanceId!,
                name: nameTag?.Value!,
                publicIP: publicIP!,
                status: status as "running" | "stopped" | "terminated",
              };
            } else {
            }
          }) ?? []
      ) ?? []
    );
  }
}
