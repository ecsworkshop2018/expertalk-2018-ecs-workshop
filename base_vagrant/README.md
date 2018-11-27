### Build the vagrant vm

```bash
vagrant up
```

### Package the vagrant as a box

```bash
vagrant package --output ecsworkshop.box
```

### Add vagrant as a box on current machine (for local use)

```bash
vagrant box add ./ecsworkshop.box --name prashantkalkar/ecsworkshopbox
```

### Verify that the box is added

```bash
vagrant box list
```

### Use this new box as the base box for vagrant file vm. 

```bash
vagrant up
```