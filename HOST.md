# host

This describes the setup of a host which runs the sphere stack.

# system requirements

This platform should run OK for a few spheres using a `2gb` (2g ram/2 cpu/40g disk) digital ocean server.

# ufw

```
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw allow 8883/tcp
sudo ufw allow 2376/tcp
sudo ufw enable
```

To see the status.

```
sudo ufw status
```

For more information:

* [How To Setup a Firewall with UFW on an Ubuntu and Debian Cloud Server](https://www.digitalocean.com/community/tutorials/how-to-setup-a-firewall-with-ufw-on-an-ubuntu-and-debian-cloud-server)