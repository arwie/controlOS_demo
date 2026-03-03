# App IO Abstraction

An abstraction layer between application logic and physical I/O, with built-in support for simulation and runtime overrides.

On real hardware, inputs read from and outputs write to physical I/O (e.g. CODESYS fieldbus). In simulation — either full system simulation in VirtualBox or selectively per-IO via config — the abstraction transparently replaces hardware access with mock values. Application code stays the same in both cases.

---

## Problems It Solves

- **Testing during machine startup**: Override individual inputs/outputs from the Studio UI to verify application behavior before all hardware is connected or operational.
- **Full simulation**: Run the entire application in VirtualBox without any hardware. All I/O is automatically simulated.
- **Selective simulation**: Simulate specific I/O points via `simio.conf` while the rest uses real hardware — useful for testing subsystems in isolation.
- **Built-in mock values**: Simulation values can be defined directly in application code (the `sim` parameter), so each input carries its own sensible default for simulated operation.
- **Cancel-safe output reset**: Outputs act as context managers that reset to default on exit, so hardware outputs are always turned off cleanly — even on task cancellation or exceptions.

---

## Basic Usage

Inputs and outputs are declared as decorated functions. The decorator wraps them into `Input`/`Output` objects that handle simulation and override logic transparently.

```python
from shared import app
from shared.app import codesys

@app.input(sim=True)
def start() -> bool:
    return codesys.fbk.io[1]

@app.input
def stop() -> bool:
    return codesys.fbk.io[2]

@app.output
def led_running(value: bool):
    codesys.cmd.io[1] = value
```

### Inputs (`@app.input`)

The decorated function defines how to read from hardware. The return type annotation (`bool`, `int`, `float`, `str`) determines the IO type.

- Call the input to get its current value: `start()` returns `True`/`False`.
- On real hardware, the decorated function is called each time.
- In simulation, the `sim` parameter is returned instead. If `sim` is omitted, the type's default is used (`False` for `bool`, `0` for `int`/`float`, `""` for `str`).
- `sim` can be a callable for dynamic mock values: `sim=lambda: random()`.

### Outputs (`@app.output`)

The decorated function defines how to write to hardware. The first parameter's type annotation determines the IO type.

- Call the output to set a value: `led_running(True)`.
- Call with no argument to reset to default: `led_running()`.
- In simulation, the value is tracked internally but the hardware write function is not called.

#### Cancel-Safe Reset (Context Manager)

Outputs are context managers that automatically reset to their default value on exit. This guarantees that hardware outputs are turned off even when a task is cancelled or raises an exception — no cleanup code needed.

```python
@app.output
def led_running(value: bool):
	codesys.cmd.io[1] = value

async def blink_led():
	while True:
		await app.sleep(0.5)
		with led_running(True)
			await app.sleep(0.5)
```

When `blink_led` is cancelled (e.g. by application shutdown or task cancellation), the `with` block exits and `led_running` resets to `False`, ensuring the LED is turned off. Without the context manager, a cancelled blink loop could leave the LED stuck on.

---

## IoGroup

`IoGroup` groups related I/O points under a common module and/or prefix. This is useful for reusable components like drives, where multiple instances share the same IO structure but need distinct names.

```python
from shared import app
from shared.app import codesys

class Drive:
    def __init__(self, name, mot):
        io_group = app.IoGroup(prefix=name)

        @io_group.input
        def current() -> float:
            return codesys.fbk.current[mot]
        self.current = current

        @io_group.output
        def rpm(value: int):
            codesys.cmd.rpm[mot] = value
        self.rpm = rpm

        io_group.open()
```

- `prefix` prepends a name segment to each IO, so `rpm` in `IoGroup(prefix='left')` becomes `left.rpm`.
.
- `io_group.open()` registers all grouped I/O for monitoring in the Studio UI.

---

## Async Mode

For I/O that requires asynchronous access (e.g. network-based or slow peripherals), use `async` functions. The framework automatically detects coroutine functions and creates `AsyncInput`/`AsyncOutput` instances.

```python
io_group = app.IoGroup(prefix='sensor')

@io_group.input
async def temperature() -> float:
    return await some_async_read()

@io_group.output
async def setpoint(value: float):
    await some_async_write(value)
```

Async I/O is not read/written on every call. Instead, values are synced periodically:

```python
io_group.sync_loop(period=0.1)  # sync every 100ms
```

`sync_loop` runs as a background task. Between syncs, inputs return the last synced value and outputs buffer the most recent value. In simulation, sync is a no-op.

---

## Simulation Mode

Whether an IO point is simulated is determined at initialization in this order:

1. **`simulated=True` parameter**: Explicitly force simulation in code.
2. **`simio.conf`**: Per-IO or per-module configuration (see below).
3. **`system.virtual()`**: If running in VirtualBox, all I/O defaults to simulated.

Once determined, simulation mode is fixed for the lifetime of the IO object. In simulation:
- Inputs return their `sim` value instead of reading hardware.
- Outputs track their value internally without writing to hardware.

---

## `simio.conf`

The configuration file `/etc/app/simio.conf` uses INI format to selectively enable simulation. The lookup follows a fallback hierarchy:

```
[module.name]  io_name       →  per-IO override
[module.name]  Input/Output  →  all inputs or outputs in a module
[app]          Input/Output  →  global default for all inputs or outputs
                             →  falls back to system.virtual()
```

### Example

```ini
# Simulate all inputs and outputs in the buttons module
[app.buttons]
Input = true
Output = true

# Simulate only the 'start' input in app.buttons
# (more specific than the above, both can coexist)
[app.buttons]
start = true

# Simulate all inputs globally
[app]
Input = true
```

Module names correspond to Python module paths with leading underscores stripped (e.g. `code/app/buttons.py` → `app.buttons`). IO names are derived from the function name, prefixed by `IoGroup.prefix` if set.

---

## Studio UI

The **SimIO** page in Studio provides a live view of all registered I/O points. It shows module, name, type, and current value for every input and output.

From this page you can:

- **Monitor** all I/O values in real-time.
- **Override** any IO point — simulated or real — by enabling the override checkbox and entering a value. This is useful for testing during commissioning or debugging.
- Overrides on real outputs are written to hardware immediately. Overrides on inputs substitute the value returned to application code.
- Disabling the override restores normal operation.
