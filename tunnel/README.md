# Tunnel IPv4

Tunneling **IPv4** request.

## About script

In this script you can tunnel your server traffic to another server. Like you setup a VPN server and now you want to route all traffic from your Iran server to your out server.

## Code

I used **iptables** to create tunnel.

## How to use?

You can use this script by following these steps:

1. Download the script.

```shell
wget "https://raw.githubusercontent.com/BlackIQ/scripts/main/tunnel/tunnel.sh"
```

2. Run script with parameters.

> Remember to run script as **root**

This file takes 2 parametes.

    - Inside: Your inside server
    - Outside: Your outside server

You can pass them like this:

```shell
bash tunnel.sh inside outside
```

## Example

```shell
bash 56.42.99.4 37.87.85.9
```

Now it routes all `56.42.99.4` traffics to `37.87.85.9`.
