# OpenVPN3 Manager

A shell that manages via CLI menu helpful commands while working with openvpn3. Allowing to create, delete, list, connect, disconnect, etc. VPNs.
The script is currently working with the latest version of openvpn3.

## Distribution Compatibility

| Distribution | Status |
| ------------ | ------ |
| Ubuntu       | ✅     |

## Requirements

Access to a terminal with root privileges.

## Installation

Clone the repository and run the install script:

```bash
git clone https://github.com/Gustavisk13/openvpn3-manager.git
cd openvpn3-manager
./vpn-helper --install
```

This will create a alias to the script in your rc file.
The alias is `vpn`.

## Usage

```bash
vpn
```

## Options

```bash
vpn --help
vpn --install
vpn --setup
```

## Contributing

Requests and suggestions are welcome. For major changes, please open an issue first to discuss what you would like to change.

## Disclaimer

This script is provided as is and is not supported by OpenVPN Inc. or any related companies. Please contact the author for any issues regarding the script.
