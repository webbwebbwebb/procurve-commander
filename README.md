# procurve-commander
Remote command invocation for HP ProCurve switches

## How it works?
This is a bash script that uses expect to interact with HP ProCurve switches. 
You supply any number of commands separated by comma and they are run remotely. Then the login session is closed.

## Dependencies
*nix, bash, expect, ssh enabled on the switch

## Install
```
git clone https://github.com/nestoru/procurve-commander.git
cd procurve-commander
chmod +x procurve-commander.sh
```

## Usage
```
./procurve-commander.sh --host <host_name> --user <user_name> [--password=<password>] --commands "<command_list>" [--legacyKeys]
```

### Arguments
| Argument       | Alias  | Description                                                                                       |
|----------------|--------|---------------------------------------------------------------------------------------------------|
| `--commands` | `-c` | Comma separated list of commands to execute against the switch                                        |
| `--help`     | `-h` | Display this message and exit                                                                         |
| `--host`     | `-H` | Hostname or IP address of the switch                                                                  |
| `--user`     | `-u` | Username                                                                                              | 
| `--password` | `-p` | Password                                                                                              |
| `--legacy `  | `-l` | Force use of deprecated key algorithms when connecting - required when connecting to older switches   |

## Examples
```
## show users besides operator and manager
./procurve-commander.sh --user manager --host your.procurve.hostname --commands "show snmpv3 user"

## show ssh config status. Note that an exit is required because config command adds a sub-prompt
./procurve-commander.sh --user manager --host your.procurve.hostname --commands "config, show ip ssh, exit"

## enable PoE on port 1 and save changes
./procurve-commander.sh --user manager --host your.procurve.hostname --commands "configure, interface 1, power, end, wr mem"
```
