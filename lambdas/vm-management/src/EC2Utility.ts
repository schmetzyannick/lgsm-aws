import {
  EC2Client,
  DescribeInstancesCommand,
  DescribeInstancesCommandOutput,
  StartInstancesCommand,
  StopInstancesCommand
} from "@aws-sdk/client-ec2";
import { IInstanceInformation } from "./IInstanceInformation";

export class EC2Utility {
  private static readonly client = new EC2Client({ region: "eu-west-1" });
  private static readonly instanceFilter = {
    Name: "tag:VMManagment", // Filter for the "VMManagment" tag
    Values: ["true"], // Only instances where the tag value is "true"
  };

  public static async startVM(instanceId: string): Promise<void> {
    if (await EC2Utility.instanceHasTag(instanceId)) {
      //start the instance
      const command = new StartInstancesCommand({
        InstanceIds: [instanceId],
      });
      const response = await this.client.send(command);
      if (response.StartingInstances?.length === 0) {
        throw new Error("Instance was not started.");
      }
    } else {
      throw new Error("Instance does not have the required tag.");
    }
  }
  public static async stopVM(instanceId: string): Promise<void> {
    if (await EC2Utility.instanceHasTag(instanceId)) {
      //start the instance
      const command = new StopInstancesCommand({
        InstanceIds: [instanceId],
      });
      const respones = await this.client.send(command);
      if(respones.StoppingInstances?.length === 0) {
        throw new Error("Instance was not stopped.");
      }
    } else {
      throw new Error("Instance does not have the required tag.");
    }
  }

  /**
   * Get name and id of all EC2 instances that have the tag "VMManagment" set to "true".
   */
  public static async getAllVMsThatShouldBeDisplayed(): Promise<
    IInstanceInformation[]
  > {
    // Get all instances
    const command = new DescribeInstancesCommand({
      Filters: [EC2Utility.instanceFilter],
    });
    const response: DescribeInstancesCommandOutput = await this.client.send(
      command
    );
    const instances: IInstanceInformation[] = [];
    response.Reservations?.forEach((reservation) => {
      reservation.Instances?.forEach((instance) => {
        const nameTag = instance.Tags?.find((tag) => tag.Key === "Name");
        const publicIP = instance.PublicIpAddress;
        const status = instance.State?.Name;
        instances.push({
          id: instance.InstanceId!,
          name: nameTag?.Value!,
          publicIP: publicIP!,
          status: status as "running" | "stopped" | "terminated",
        });
      });
    });
    return instances;
  }

  private static async instanceHasTag(instanceId: string): Promise<boolean> {
    const command = new DescribeInstancesCommand({
      InstanceIds: [instanceId],
      Filters: [EC2Utility.instanceFilter],
    });
    const response: DescribeInstancesCommandOutput = await this.client.send(
      command
    );
    return response.Reservations?.length === 1;
  }
}
