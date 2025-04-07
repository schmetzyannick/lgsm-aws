import {
  EC2Client,
  DescribeInstancesCommand,
  DescribeInstancesCommandOutput,
  StopInstancesCommand,
} from "@aws-sdk/client-ec2";

export class EC2Manager {
  private static readonly client = new EC2Client({ region: "eu-west-1" });
  private static readonly instanceFilter = {
    Name: "tag:VMManagment", // Filter for the "VMManagment" tag
    Values: ["true"], // Only instances where the tag value is "true"
  };

  /**
   * Stops all vms that have the tag "VMManagment" set to "true".
   */
  public static async stopVMs(): Promise<{id: string}[]> {
    const instances = await this.getAllVMsThatShouldBeStopped();
    const errors: string[] = [];
    const stopInstances: {id: string}[] = [];
    for (const instance of instances) {
      const command = new StopInstancesCommand({
        InstanceIds: [instance.id],
      });
      const respones = await this.client.send(command);
      if (respones.StoppingInstances?.length === 0) {
        errors.push(`Instance ${instance.id} was not stopped.`);
      }
      stopInstances.push({
        id: instance.id,
      });
    }
    if (errors.length > 0) {
      throw new Error(`Some instances were not stopped: ${errors.join(", ")}`);
    }
    return stopInstances;
  }

  private static async getAllVMsThatShouldBeStopped(): Promise<
    { id: string }[]
  > {
    // Get all instances
    const command = new DescribeInstancesCommand({
      Filters: [EC2Manager.instanceFilter],
    });
    const response: DescribeInstancesCommandOutput = await this.client.send(
      command
    );
    const instances: { id: string }[] = [];
    response.Reservations?.forEach((reservation) => {
      reservation.Instances?.forEach((instance) => {
        instances.push({
          id: instance.InstanceId!,
        });
      });
    });
    return instances;
  }
}
