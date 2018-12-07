# expertalk-2018-ecs-workshop
Repository for ecs workshop for expert talk india conference 2018.

## Pre workshop setup step

#### You need following things installed on your machine

- Git
- Git bash (for windows only)
- Github account (with SSH key configured)
- Virtualbox
(Vagrant can support VirtualBox version 4.0.x, 4.1.x, 4.2.x, 4.3.x, 5.0.x, 5.1.x, and 5.2.x. Other versions are unsupported and you will get an error message. Please note that beta and pre-release versions of VirtualBox are not supported and may not be well-behaved.)
Install with the help of the official installer. https://www.virtualbox.org/wiki/Downloads

- Vagrant (2.2.2)
Do not use a package manager for installing Vagrant. Please use the official installer. https://www.vagrantup.com/downloads.html

- IntelliJ Idea or Eclipse (or any other IDE you are comfortable with)

#### Pull the vagrant box in an empty directory with the following command

Note: Run all commands on Terminal or GitBash (not GitCMD)

```bash
mkdir ecsworkshop
cd ecsworkshop
mkdir basevm
cd basevm
vagrant init prashantkalkar/ecsworkshopbox --box-version 1.0.1
vagrant up
```

#### Test the box is working

Get into vagrant vm.
```bash
vagrant ssh
```


