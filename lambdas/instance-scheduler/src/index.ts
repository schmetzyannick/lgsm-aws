import { EC2Manager } from "./EC2Manager";

const AWS = require("aws-sdk");

exports.handler = async () => {
  EC2Manager.stopVMs();
};
