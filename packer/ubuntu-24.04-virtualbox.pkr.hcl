# Packer template for building an Ubuntu 24.04 LTS VirtualBox VM image
# with Docker Engine and Visual Studio Code pre-installed.
#
# This template uses the VirtualBox ISO builder to:
# 1. Download and boot the official Ubuntu 24.04 server ISO
# 2. Perform an automated installation using cloud-init (autoinstall)
# 3. Configure SSH access for the provisioning user
# 4. Run shell provisioners to install Docker and VS Code
# 5. Export the final VM as an OVA file
#
# SSH Usage Note:
# SSH is configured and used by Packer as the primary communication channel
# (called a "communicator" in Packer terminology) to connect to the VM after
# the OS installation completes. This allows Packer to run provisioning scripts
# (like provision.sh) inside the VM to install software and configure settings.
# SSH is NOT strictly required for the final VM to function, but it is the
# standard and most reliable way for Packer to perform post-install automation.

# Packer configuration block - specifies required Packer version
packer {
  required_version = ">= 1.8.0"
  
  # Declare required plugins for this template
  required_plugins {
    # VirtualBox plugin for building VirtualBox VMs
    virtualbox = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

# Variables allow customization without editing the template
variable "vm_name" {
  type        = string
  description = "Name of the virtual machine"
  default     = "ubuntu-24.04-docker-vscode"
}

variable "iso_url" {
  type        = string
  description = "URL to download the Ubuntu 24.04 LTS server ISO"
  # Using the official Ubuntu server ISO for 24.04 LTS (Noble Numbat)
  default     = "https://releases.ubuntu.com/noble/ubuntu-24.04.3-live-server-amd64.iso"
}

variable "iso_checksum" {
  type        = string
  description = "SHA256 checksum of the Ubuntu ISO for verification"
  # This checksum ensures the downloaded ISO hasn't been tampered with
  default     = "sha256:c3514bf0056180d09376462a7a1b4f213c1d6e8ea67fae5c25099c6fd3d8274b"
}

variable "ssh_username" {
  type        = string
  description = "Username for SSH access during provisioning"
  # This user will be created during the autoinstall process
  default     = "packer"
}

variable "ssh_password" {
  type        = string
  description = "Password for SSH access during provisioning"
  # Simple password for Packer provisioning - users should change this in production
  default     = "packer"
}

variable "disk_size" {
  type        = number
  description = "Size of the VM disk in megabytes"
  # 40 GB disk provides enough space for the OS, Docker images, and VS Code
  default     = 40960
}

variable "memory" {
  type        = number
  description = "Amount of RAM in megabytes"
  # 4 GB RAM is suitable for running Docker containers and VS Code
  default     = 4096
}

variable "cpus" {
  type        = number
  description = "Number of CPU cores"
  # 2 CPUs provide good performance for development tasks
  default     = 2
}

# Source block defines the VirtualBox VM builder configuration
source "virtualbox-iso" "ubuntu" {
  # VM identification and naming
  vm_name              = var.vm_name
  guest_os_type        = "Ubuntu_64"  # VirtualBox guest OS type for Ubuntu 64-bit
  
  # ISO configuration - where to get the Ubuntu installer
  iso_url              = var.iso_url
  iso_checksum         = var.iso_checksum
  
  # VM hardware configuration
  cpus                 = var.cpus
  memory               = var.memory
  disk_size            = var.disk_size
  hard_drive_interface = "sata"  # SATA interface for the virtual disk
  
  # Headless mode - run without opening a VirtualBox GUI window
  # This is essential for automated CI/CD builds
  headless             = true
  
  # Boot wait time - wait for GRUB menu to be ready before sending boot commands
  # This prevents commands from being sent too early and potentially being missed
  boot_wait            = "5s"
  
  # SSH communicator configuration
  # Packer will use SSH to connect to the VM after installation completes
  # This allows running provisioning scripts inside the VM
  ssh_username         = var.ssh_username
  ssh_password         = var.ssh_password
  # SSH timeout covers: Ubuntu autoinstall (8-12 min in CI: partitioning, package installation),
  # system reboot, SSH service startup, and network configuration. 
  # 20m provides adequate time for autoinstall to complete in GitHub Actions environment.
  ssh_timeout          = "20m"  # Maximum time to wait for SSH to become available
  ssh_handshake_attempts = 100  # Number of SSH connection attempts
  ssh_wait_timeout     = "10m"  # Additional timeout for SSH to be ready after connection
  
  # Boot configuration for automated installation
  # The boot_command is sent to the VM as keyboard input during boot
  # It configures the kernel to use our autoinstall configuration
  boot_command = [
    # Wait for GRUB menu to appear and be ready
    # Using explicit wait time for more predictable behavior
    "<wait5>",
    # Press 'c' to enter GRUB command line mode (more reliable than editing)
    "c<wait>",
    # Set the kernel boot parameters for autoinstall
    # - autoinstall: enables Ubuntu's automated installation
    # - ds=nocloud-net: tells cloud-init to look for config on the network/http server
    # - s=http://{{.HTTPIP}}:{{.HTTPPort}}/: URL where Packer serves our user-data/meta-data
    # The '---' separator is required by Ubuntu 24.04 to properly parse autoinstall parameters
    "linux /casper/vmlinuz autoinstall ds=nocloud-net\\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ ---<enter>",
    # Load the initial ramdisk
    "initrd /casper/initrd<enter>",
    # Boot with these parameters
    "boot<enter>"
  ]
  
  # HTTP server configuration
  # Packer runs a temporary HTTP server to serve the autoinstall configuration
  # The VM will download user-data and meta-data from this server during boot
  http_directory       = "http"
  
  # Shutdown configuration
  # Command to run inside the VM to shut it down gracefully after provisioning
  shutdown_command     = "echo '${var.ssh_password}' | sudo -S shutdown -P now"
  
  # Post-processor configuration
  # Export the VM as an OVA file after building
  # OVA is a portable format that can be imported into VirtualBox or other hypervisors
  format               = "ova"
  
  # VirtualBox-specific settings
  vboxmanage = [
    # Enable VirtualBox Guest Additions ISO mount
    ["modifyvm", "{{.Name}}", "--vram", "128"],  # Video RAM for better display
    ["modifyvm", "{{.Name}}", "--graphicscontroller", "vmsvga"],  # Graphics controller
    ["modifyvm", "{{.Name}}", "--audio", "none"],  # Disable audio (not needed for server)
  ]
}

# Build block - defines what to build and how to provision it
build {
  # Use the ubuntu source defined above
  sources = ["source.virtualbox-iso.ubuntu"]
  
  # Provisioner: shell script to install Docker and VS Code
  # This runs after the OS installation completes and SSH is available
  provisioner "shell" {
    # Path to the provisioning script relative to the Packer template
    script = "scripts/provision.sh"
    
    # Run commands with sudo privileges
    # The script needs root access to install packages
    execute_command = "echo '${var.ssh_password}' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
  }
  
  # Post-processor to create a manifest file
  # This creates a JSON file with information about the build artifacts
  post-processor "manifest" {
    output     = "packer-manifest.json"
    strip_path = true
  }
}
