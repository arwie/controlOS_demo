# Remote Access

Remote access provides secure connectivity to controlOS devices deployed behind firewalls or NAT. It uses a **reverse SSH tunnel** through an external relay server, allowing developers to reach devices that have no public IP address.

## Architecture

```
Developer                        Relay Server                     Field Device
                                                                  (behind NAT)
                                                                        |
                                       <── reverse SSH tunnel ──────────┘
online/connect-remote ──────>          (port N → device:22)
ssh -p N relay-server
with ethernet tunnel (tap0)
```

The field device initiates an outbound SSH connection to the relay server, creating a reverse port forward. The developer then connects to that forwarded port on the relay server, which transparently reaches the device's SSH daemon. On top of that SSH connection, a Layer 2 ethernet tunnel is established, giving full network access to the device.


## Components

### Systemd Service Template

`remote@.service` is a systemd template unit where the instance parameter (`%i`) is the port number.

Starting `remote@65000.service` runs:

```
ssh -N -T -R *:65000:localhost:22 remote@<relay-server>
```

| Flag | Purpose |
|------|---------|
| `-N` | No remote command — tunnel only |
| `-T` | No TTY allocation |
| `-R *:%i:localhost:22` | Bind port %i on the relay server, forward to device's local SSH (port 22) |

The service is configured with `Restart=always` and a 10-second restart delay, ensuring the tunnel automatically reconnects on failure.

### Web UI (Admin)

The Admin interface provides a **Remote Access** page under System where an operator can:

- Enter a service port number (valid range: **60000–65500**)
- **Activate** remote access — starts `remote@<port>.service`
- **Deactivate** remote access — stops all remote tunnel services
- View live service status (polled every 3 seconds)

Only one remote tunnel is active at a time. Activating with a new port stops any previously running tunnel first.


### Developer Connection Script

```bash
online/connect-remote <port>
```

Connects to the device through the relay server. Default port is 65000 if not specified.

The script establishes an SSH connection with:

| Flag | Purpose |
|------|---------|
| `-C` | Enable compression |
| `-o Tunnel=ethernet` | Create a Layer 2 ethernet tunnel |
| `-w 0:0` | Use `tap0` on both sides |

### Network Bridging

On the device, `tap0` is bridged into the `sys` bridge via systemd-networkd configuration. This means the ethernet tunnel provides full Layer 2 connectivity — the developer can access all device services (HMI, Studio, Admin) as if connected to the local network, not just SSH.


## Usage

### Activating Remote Access (Operator)

1. Open the Admin UI and navigate to **System > Remote Access**
2. Enter a port number (60000–65500) — coordinate with the relay server administrator to avoid port conflicts
3. Click **Activate**
4. Verify the status indicator confirms the tunnel is established

### Connecting to a Device (Developer)

1. Ensure the operator has activated remote access and communicated the port number
2. From the development machine, run:
   ```bash
   online/connect-remote <port>
   ```
3. Once connected, the device's network services are accessible through the `tap0` interface

### Disconnecting

- The developer terminates the connection by closing the `connect-remote` session
- The operator can deactivate remote access from the Admin UI at any time, which tears down the reverse tunnel


## Security Considerations

- The device initiates all connections outbound — no inbound firewall rules are required on the device side
- SSH key authentication is used for both the device-to-relay and developer-to-device connections
- The tunnel only exposes the device's SSH port on the relay server; full network access is established over that encrypted channel
- Remote access must be explicitly activated by an operator and can be deactivated at any time
- The port range restriction (60000–65500) limits exposure on the relay server
