import { IInstanceInformation } from "./IInstanceInformation";
import { EC2Utility } from "./EC2Utility";

/**
 * Generates HTML files based on the currents state of the VMs.
 */
export class HTMLFileFactory {

  /**
   * Generates webpage based on current state of the VMs.
   * @returns HTML content that displays all EC2 instances that have the tag "VMManagment" set to "true".
   */
  public static async generateHTML(): Promise<string> {
    const instances = await EC2Utility.getAllVMsThatShouldBeDisplayed();
    const htmlContent = `${this.getHTMLPartBeforeInstances()}${this.generateHTMLForInstances(
      instances
    )}${this.getHTMLPartAfterInstances()}`;
    return htmlContent;
  }

  private static getHTMLPartAfterInstances(): string {
    return `
    <script>
        function getUrlAndApiKey(startOrStop) {
            // Retrieve the API key from the parent document
            const apiKey = window.parent.document.getElementById("apiKey").value;
            if (!apiKey) {
                alert('API key not found!');
                return;
            }

            let apiUrl = window.parent.location.origin;
            if(window.location.pathname.startsWith("/prod")){
              apiUrl += "/prod";
            };
            if(startOrStop === "start"){
                apiUrl += "/startVM";
            }else{
                apiUrl += "/stopVM";
            }
            return { apiUrl, apiKey };
        }
    </script>    
    <script>       
        function startInstance(instanceId) {
            const { apiUrl, apiKey } = getUrlAndApiKey("start");

            fetch(apiUrl, {
                method: 'POST',
                headers: {
                    'x-api-key': apiKey,
                },
                body: JSON.stringify({ instanceId: instanceId })
            })
            .then(response => {
                if (response.ok) {
                    alert('Starting ' + instanceId);
                    return;
                } else {
                    alert('Failed to start instance ' + instanceId);
                }
            })
            .catch(error => {
                alert('Error starting instance: ' + error.message);
            });
        }

        function stopInstance(instanceId) {
            const { apiUrl, apiKey } = getUrlAndApiKey("stop");

            fetch(apiUrl, {
                method: 'POST',
                headers: {
                    'x-api-key': apiKey,
                },
                body: JSON.stringify({ instanceId: instanceId })
            })
            .then(response => {
                if (response.ok) {
                    alert('Stopping ' + instanceId);
                    return;
                } else {
                    alert('Failed to stop instance ' + instanceId);
                }
            })
            .catch(error => {
                alert('Error stopping instance: ' + error.message);
            });
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
}
