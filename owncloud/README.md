# OwnCloud Easy Installtion

Installing **OwnColoud** on your server just with a command.

## About script

This script is for installing **OwnCloud** on your server. So, you don't need to copy and paste all of commands from documentation to the terminal to install. Just get this script from GitHub and run it.

## Code

Just pure commands.

## How to use?

You can use this script by following these steps:

1. Download the script.

```shell
wget "https://raw.githubusercontent.com/BlackIQ/scripts/main/owncloud/owncloud.sh"
```

2. Give permission to script.

```shell
chmod +x owncloud.sh
```

3. Run script with parameters.

> Remember to run script as **root**

This file takes 1 parametes.

    - Domain: Set your domain.

You can pass them like this:

```shell
./owncloud.sh domain
```

## Example

```shell
./owncloud.sh oc.google.com
```

Now my domain sets to _oc.google.com_.
