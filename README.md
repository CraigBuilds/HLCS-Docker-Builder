# HLCS-Docker-Builder

This repository contains:
1. Docker containers for ROS2 development
2. Automated VirtualBox VM builds with Ubuntu 24.04, Docker, and VS Code

All builds are automated via GitHub Actions and can be triggered on-demand.

## ROS2 Humble Container

A Docker container based on ROS2 Humble Desktop with development tools and HLCS dependencies. 

## Pulling and running the Image

## CI/CD

The container is built and deployed on-demand via manual workflow dispatch. To trigger a build:

1. Go to the [Actions tab](../../actions/workflows/build-and-deploy.yml)
2. Click "Run workflow"
3. Select the branch and run

The workflow uses GitHub Actions cache for Docker layers, registry fallback for image pulls, and builds images for a single platform to maximise speed.

The container is also tested in a separate workflow. The tests ensure that after pulling the container, you can:
 - Smoke test: run the ros2 cli tool, i.e `ros2 --help`
 - Access env vars with `echo ROS_VERSION`
 - Access Python with  `python -v`
 
## What's Included

- ROS2 Humble Desktop
- The HLCS ROS2 Workspace
- Python3 and pip
- Colcon build tools
- Git
- asyncua
- UaExpert
- Pyside6
- RTI Connext Libraries
- RTI Connext RMW
- RTI Opcua Gateway
- ROS Bridge
- Other ROS Tools
- A Preconfigured ~/.bashrc

## Building Locally

To build the container locally (not recommended unless you are developing the container):

```bash
#todo add instructions for cloning this repo and then building and running the container
```

---

## Ubuntu 24.04 VirtualBox VM

An automated build pipeline that creates a VirtualBox VM image with Ubuntu 24.04 LTS, Docker Engine, and Visual Studio Code pre-installed.

### What's Included in the VM

- **Operating System**: Ubuntu 24.04 LTS (Noble Numbat) Server
- **Docker Engine**: Latest stable version from official Docker repository
  - Docker CLI
  - containerd
  - Docker Buildx plugin
  - Docker Compose plugin
- **Visual Studio Code**: Latest stable version from Microsoft repository
- **Development Tools**: Git, curl, wget, build-essential
- **Default User**: `packer` (password: `packer`)
  - Member of `docker` group (can run Docker without sudo)
  - Has sudo privileges
  - SSH enabled with password authentication

### VM Specifications

- **vCPUs**: 2
- **RAM**: 4 GB
- **Disk**: 40 GB (dynamically allocated)
- **Format**: OVA (Open Virtual Appliance)

### Prerequisites for Building

The GitHub Actions workflow handles all prerequisites automatically when using GitHub-hosted runners. If you want to build locally or use a self-hosted runner, you need:

- **VirtualBox**: Version 6.1 or later
- **Packer**: Version 1.8.0 or later
- **Operating System**: Linux (Ubuntu 22.04+ recommended)
- **Disk Space**: At least 50 GB free space
- **Internet Connection**: Required to download Ubuntu ISO and packages

### How to Trigger a VM Build

#### Option 1: Manual Workflow Dispatch

1. Go to the [Actions tab](../../actions/workflows/build-ubuntu-vm.yml)
2. Click "Run workflow"
3. Select the branch (usually `main`)
4. Click the green "Run workflow" button

The build takes approximately 20-40 minutes to complete.

#### Option 2: Automatic Build on Push

The workflow automatically triggers when changes are pushed to the `main` branch.

#### Option 3: Create a Release Build

To create a versioned release with the VM image attached as a release asset:

1. Create and push a tag with semantic versioning:
   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```

2. The workflow will automatically:
   - Build the VM image
   - Create a GitHub Release for the tag
   - Attach the VM OVA file as a release asset
   - Generate release notes with usage instructions

**Tag Naming Convention**: Use semantic versioning (e.g., `v1.0.0`, `v1.1.0`, `v2.0.0`)

### Where to Download the VM

#### From Workflow Artifacts (All Builds)

1. Go to the [Actions tab](../../actions/workflows/build-ubuntu-vm.yml)
2. Click on a completed workflow run
3. Scroll to the "Artifacts" section at the bottom
4. Download `ubuntu-24.04-virtualbox-vm`
5. Extract the downloaded zip file to get the `.ova` file

**Note**: Artifacts are retained for 90 days.

#### From Releases (Tagged Builds Only)

1. Go to the [Releases page](../../releases)
2. Find the release version you want
3. Download the `.ova` file from the "Assets" section

**Note**: Release assets are retained permanently.

### How to Use the VM

1. **Download the OVA file** (see above)

2. **Import into VirtualBox**:
   - Open VirtualBox
   - Go to `File` → `Import Appliance`
   - Select the downloaded `.ova` file
   - Review settings (you can adjust CPU/RAM if needed)
   - Click "Import"

3. **Start the VM**:
   - Select the imported VM in VirtualBox
   - Click "Start"
   - Wait for the VM to boot (first boot may take a minute)

4. **Log in**:
   - Username: `packer`
   - Password: `packer`
   - **IMPORTANT**: Change the password after first login!

5. **Verify Docker**:
   ```bash
   docker --version
   docker ps
   docker run hello-world
   ```

6. **Verify VS Code**:
   ```bash
   code --version
   ```

### SSH Configuration in the VM

SSH is enabled in the VM for convenience, but it was primarily needed during the build process. Here's why:

#### Why SSH is Configured

**During Build (Packer Provisioning)**:
- Packer uses SSH as its "communicator" to connect to the VM after the OS installation completes
- This allows Packer to run provisioning scripts inside the VM to install Docker, VS Code, and other software
- SSH is the standard and most reliable method for Packer to perform post-install automation
- Without SSH, Packer cannot execute the provisioning scripts

**In the Final VM**:
- SSH is NOT strictly required for the VM to function
- It remains enabled as a convenience for remote access and automation
- You can disable SSH if you don't need it: `sudo systemctl disable ssh`

#### SSH Security Notes

The VM is configured with:
- SSH password authentication enabled
- Default user with a simple password (`packer`)
- User has passwordless sudo access

**Security Recommendations**:
1. Change the default password immediately: `passwd`
2. Consider disabling SSH if not needed: `sudo systemctl disable ssh`
3. If you need SSH, use SSH keys instead of passwords
4. Restrict sudo access if needed: edit `/etc/sudoers.d/packer`

### How the Build Works

The build process uses HashiCorp Packer with the VirtualBox ISO builder:

1. **Download Ubuntu ISO**: Packer downloads the official Ubuntu 24.04 server ISO
2. **Create VM**: VirtualBox creates a new VM with the specified resources
3. **Boot and Autoinstall**: The VM boots from the ISO and uses cloud-init (NoCloud datasource) to perform an automated installation
4. **SSH Connection**: After installation, Packer waits for SSH to become available
5. **Provisioning**: Packer runs `provision.sh` script via SSH to install Docker and VS Code
6. **Export**: The VM is shut down and exported as an OVA file

#### Packer Configuration Files

- `packer/ubuntu-24.04-virtualbox.pkr.hcl`: Main Packer template with VM configuration
- `packer/http/user-data`: Cloud-init autoinstall configuration
- `packer/http/meta-data`: Cloud-init metadata (required but minimal)
- `packer/scripts/provision.sh`: Shell script that installs Docker and VS Code

All files are heavily commented to explain each step.

### Building Locally

If you want to build the VM locally (not recommended unless developing the VM configuration):

```bash
# Clone the repository
git clone https://github.com/CraigBuilds/HLCS-Docker-Builder.git
cd HLCS-Docker-Builder

# Install prerequisites
# - VirtualBox: https://www.virtualbox.org/
# - Packer: https://www.packer.io/downloads

# Navigate to packer directory
cd packer

# Initialize Packer (downloads required plugins)
packer init ubuntu-24.04-virtualbox.pkr.hcl

# Validate the configuration
packer validate ubuntu-24.04-virtualbox.pkr.hcl

# Build the VM (takes 20-40 minutes)
packer build ubuntu-24.04-virtualbox.pkr.hcl

# The OVA file will be in the output directory
```

### Troubleshooting

**Build fails with VirtualBox errors**:
- Ensure VirtualBox is installed and working: `vboxmanage --version`
- Check that virtualization is enabled in your BIOS/UEFI
- On Linux, ensure your user is in the `vboxusers` group

**Build fails during provisioning**:
- Check the logs for SSH connection issues
- Verify network connectivity (VM needs internet access)
- The build process is logged in detail; check the Packer output

**VM import fails**:
- Ensure you have VirtualBox 6.1 or later
- Check that you have enough disk space
- Try importing with VirtualBox GUI instead of command line

**Cannot log into the VM**:
- Username: `packer` (lowercase)
- Password: `packer` (lowercase)
- Wait for the system to fully boot before attempting login

### Contributing

To modify the VM configuration:

1. Edit the Packer template: `packer/ubuntu-24.04-virtualbox.pkr.hcl`
2. Update provisioning script: `packer/scripts/provision.sh`
3. Modify autoinstall config: `packer/http/user-data`
4. Test locally before committing
5. Submit a pull request

All scripts and configuration files are heavily commented for learning purposes.
