import { EC2Manager } from "./EC2Manager";

exports.handler = async () => {
  EC2Manager.stopVMs();
};
