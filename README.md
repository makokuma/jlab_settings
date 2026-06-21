# jlab_settings

A small zsh utility for starting JupyterLab on a remote server and opening it from a local macOS machine through an SSH tunnel.

This script is intended for macOS users who connect to a remote Linux server with SSH and run JupyterLab inside a conda environment.

## Files

```text
jlab_settings/
├── README.md
└── jlab.zsh
```

## What this script does

The `jlab` function does the following:

1. Stops an old local SSH tunnel using the configured port.
2. Stops an old remote JupyterLab process using the same port.
3. Starts JupyterLab on the remote server.
4. Creates an SSH tunnel from the local machine to the remote JupyterLab server.
5. Reads the JupyterLab token URL from the remote log file.
6. Opens the token URL in the default web browser on macOS.

The `jlab-stop` function stops the remote JupyterLab process and the local SSH tunnel.

## Requirements

### Local machine

- macOS
- zsh
- SSH client
- Web browser

### Remote server

- SSH access
- Python
- JupyterLab
- conda or miniconda
- A conda environment that can run JupyterLab

## Setup

Clone this repository:

```bash
git clone https://github.com/makokuma/jlab_settings.git
cd jlab_settings
```

Before using the script, open `jlab.zsh` and edit the following values for your own environment.

## Values to edit before use

### 1. Port number

Edit this line in both `jlab` and `jlab-stop`:

```zsh
local PORT=XXXX
```

Example:

```zsh
local PORT=9903
```

The port number should be unused on your local machine and on the remote server.

### 2. Remote SSH host

Edit this line in both `jlab` and `jlab-stop`:

```zsh
local HOST=user@server
```

Example:

```zsh
local HOST=your_username@your_server_address
```

This should be the same SSH destination you normally use when connecting to the remote server.

### 3. JupyterLab root directory

Edit this line:

```zsh
local ROOT_DIR="/path/to/init/jlab"
```

Example:

```zsh
local ROOT_DIR="/home/your_username/work"
```

JupyterLab will start from this directory on the remote server.

### 4. Conda initialization path

Edit this line:

```zsh
source /home/user/miniconda3/etc/profile.d/conda.sh
```

Example:

```zsh
source /home/your_username/miniconda3/etc/profile.d/conda.sh
```

This path must point to `conda.sh` on the remote server.

### 5. Conda environment name

Edit this line:

```zsh
conda activate your_python_env
```

Example:

```zsh
conda activate my_jupyter_env
```

The conda environment must have JupyterLab installed.

## Usage

Load the zsh functions:

```bash
source jlab.zsh
```

Start JupyterLab:

```bash
jlab
```

Stop JupyterLab and the SSH tunnel:

```bash
jlab-stop
```

## Optional: load automatically from `.zshrc`

If you want to use `jlab` from any terminal session, add the following line to your `~/.zshrc`:

```bash
source /path/to/jlab_settings/jlab.zsh
```

Then reload your shell configuration:

```bash
source ~/.zshrc
```

## Browser behavior

The script opens JupyterLab with:

```zsh
open "$JLAB_URL"
```

On macOS, this opens the URL in your default web browser. For example, it may open Safari, Google Chrome, Firefox, Edge, Arc, or another browser depending on your system settings.

## Notes

- Do not commit your personal server address, internal IP address, username, private paths, tokens, or passwords to a public repository.
- The JupyterLab token is read from the remote log file and opened locally through the SSH tunnel.
- The script starts JupyterLab on the remote server with `--ip=127.0.0.1`, so it is not exposed directly to the network.
- Access from the local machine is done through SSH port forwarding.

## Troubleshooting

### Could not find token URL in log

Check the remote log manually:

```bash
ssh user@server "cat /tmp/jupyterlab-PORT.log"
```

Replace `user@server` and `PORT` with the values configured in `jlab.zsh`.

### Port is already in use

The script tries to stop old local tunnels using the same port. If the problem continues, check the port manually:

```bash
lsof -iTCP:PORT -sTCP:LISTEN
```

Replace `PORT` with the configured port number.

### JupyterLab does not start

Check that:

- the SSH host is correct,
- the conda initialization path is correct,
- the conda environment exists,
- JupyterLab is installed in that environment,
- the root directory exists on the remote server.
