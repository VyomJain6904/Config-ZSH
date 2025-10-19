# Custom Zsh Configuration

A full-featured Zsh setup with external plugins, development toolchains, and Pentesting utilities for developers, DevOps engineers, and security professionals.

---

### 1️⃣ Install Oh My Zsh

Ensure you have **Oh My Zsh** installed. Run the following command to install it:

```sh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

---

### 2️⃣ Download External Plugins

To enhance the functionality of your terminal, download the following Zsh plugins:

Clone each plugin into your `~/.oh-my-zsh/plugins/` directory:

```sh
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-history-substring-search ~/.oh-my-zsh/plugins/zsh-history-substring-search
git clone https://github.com/mrjohannchang/zsh-interactive-cd ~/.oh-my-zsh/plugins/zsh-interactive-cd
```

### Install the following Plugins :

```sh
sudo apt install fzf eza fd yazi jq zoxide fastfetch batcat tldr ripgrep poppler -y # For Ubuntu / Debain Based
```

or

```sh
sudo pacman -Sy fzf eza fd yazi jq zoxide fastfetch bat tldr ripgrep poppler # For Arch Based
```

---

### 3️⃣ Nerdfont Download

```sh
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip
unzip JetBrainsMono.zip
fc-cache -fv
```

---

### Tools for Pentesting

```sh
sudo apt install nmap gobuster nikto metasploit john hashcat hydra zenmap wireshark dirb whatweb wifite sqlmap aircrack-ng theharvester wpscan netcat impacket-scripts dirbuster nuclei ettercap-common bloodhound steghide recon-ng hash-identifier fuff dirsearch subfinder havoc hoaxshell enum4linux sublist3r python3-scapy zaproxy -y
```

OR

```sh
cd /opt/
curl -O https://blackarch.org/strap.sh
chmod +x strap.sh
sudo ./strap.sh
```

---

### Installation of Burpsuite Pro

```sh
wget -qO- https://raw.githubusercontent.com/xiv3r/Burpsuite-Professional/main/install.sh | sudo bash
burpsuitepro
```

---

### Installation of FindIt

```sh
https://github.com/VyomJain6904/FindIt
cd FindIt
chmod +x findit.py
pip install -r requirements.txt --break-system-packages
sudo mv findIt.py /usr/local/bin/findIt.py
findIt.py -h
```

---

### Save the file and apply changes by running:

```sh
source ~/.zshrc
```
