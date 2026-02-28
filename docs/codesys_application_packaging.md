# CODESYS Application Packaging & Deployment

How CODESYS applications are built, packaged into the image, and selected at runtime.

A single controlOS image can ship multiple CODESYS applications — one per device/machine configuration. At startup, the active application is selected based on the target's setup configuration, allowing the same image to cover different hardware variants and simulation environments without rebuilding.

---

## Build-Time: Compiling Applications

[deploy.py](../codesys/deploy.py) is a CODESYS ScriptEngine script that compiles each application from the CODESYS project into deployable boot files.

It iterates over all devices in the project, calling `create_boot_application()` on each, which produces:

- `Application.app` — the compiled PLC boot application
- `Application.crc` — integrity checksum

Output is written per-device into `PlcLogic/<device>/`, e.g.:

```
codesys/
└── PlcLogic/
    ├── Raspi4b/
    │   ├── Application.app
    │   └── Application.crc
    └── VirtualBox/
        ├── Application.app
        └── Application.crc
```

Each device directory name comes from `dev.get_name()` in the CODESYS project.


## Packaging: Image Integration

[codesys.make](../root/rules/codesys.make) controls how the CODESYS runtime and applications are packaged into the target image.

The build rule `PTXCONF_CODESYS_DEPLOY` determines how applications are handled:

| `CODESYS_DEPLOY` | `/opt/codesys/PlcLogic/`                 | Use case                    |
|-------------------|------------------------------------------|-----------------------------|
| enabled           | Contains the compiled applications       | Production / read-only root |
| disabled          | Symlink → `/var/opt/codesys/PlcLogic/`   | Development / online deploy |

When `CODESYS_DEPLOY` is enabled, the application files from [PlcLogic/](../root/projectroot/opt/codesys/PlcLogic/) are baked into the image along with [CmpApp.cfg](../root/projectroot/opt/codesys/PlcLogic/CmpApp.cfg) which registers the available applications:

```ini
[CmpApp]
Application.1=Application
```


## Runtime: Application Selection

On startup, the `codesys.service` unit runs [select-application](../root/projectroot/opt/codesys/scripts/select-application) as an `ExecStartPre` step, before launching the CODESYS runtime.

The application name is resolved through two layers:

1. **Defaults** in [code/shared/setups/\_\_init\_\_.py](../code/shared/setups/__init__.py) set the base values:

   ```python
   setup['codesys']['application'] = 'raspi4b'
   setup['codesys']['sim']['application'] = 'VirtualBox'
   ```

2. **Overrides** from `/etc/app/setup.conf` on the target (if present) take precedence:

   ```ini
   [setup]
   codesys/application = raspi4b
   ```

On virtual machines, the simulation-specific value (`setup['codesys']['sim']['application']`) is used instead, falling back to the regular application if unset.

The script creates a symlink that points the CODESYS runtime to the selected application:

```
/run/codesys/Application  →  /opt/codesys/PlcLogic/<application>
```

### Startup Sequence

```
systemd starts codesys.service
  │
  ├─ ExecStartPre: select-application
  │    read setup config → create /run/codesys/Application symlink
  │
  ├─ ExecStartPre: echo STOP > runstop.switch
  │    ensure PLC starts in stopped state
  │
  └─ ExecStart: codesyscontrol.bin
       loads /run/codesys/Application/Application.app
```
