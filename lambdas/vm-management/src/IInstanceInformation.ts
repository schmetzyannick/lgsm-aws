export interface IInstanceInformation {
    id: string;
    name: string;
    publicIP: string;
    status: "running" | "stopped" | "terminated";
}
