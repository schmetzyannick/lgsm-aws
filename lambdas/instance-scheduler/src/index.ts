import { EC2Manager } from "./EC2Manager";

exports.handler = async () => {
  return await EC2Manager.stopVMs();
};
