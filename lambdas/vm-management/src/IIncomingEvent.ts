export type VMAction = "startVM" | "stopVM" | "allVMs";

export interface IIncomingEvent {
    resource: VMAction;
    body?: {
        instanceId?: string;
    };
}