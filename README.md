# Custom Zsh Configuration

A full-featured Zsh setup with external plugins, development toolchains, and pentesting utilities for developers, DevOps engineers, and security professionals.

---

### 1️⃣ Install Oh My Zsh

Ensure you have **Oh My Zsh** installed. Run the following command to install it:

```sh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

---

### 2️⃣ Download External Plugins

To enhance the functionality of your terminal, download the following Zsh plugins:

-   **Zsh Autosuggestions** → [GitHub Link](https://github.com/zsh-users/zsh-autosuggestions)
-   **Zsh Syntax Highlighting** → [GitHub Link](https://github.com/zsh-users/zsh-syntax-highlighting)
-   **Zsh Completions** → [GitHub Link](https://github.com/zsh-users/zsh-completions)
-   **Zsh History Substring Search** → [GitHub Link](https://github.com/zsh-users/zsh-history-substring-search)
-   **Zsh Interactive CD** → [GithubLink](https://github.com/mrjohannchang/zsh-interactive-cd)

Clone each plugin into your `~/.oh-my-zsh/plugins/` directory:

```sh
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-history-substring-search ~/.oh-my-zsh/plugins/zsh-history-substring-search
git clone https://github.com/mrjohannchang/zsh-interactive-cd ~/.oh-my-zsh/plugins/zsh-interactive-cd
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

### Update `.zshrc` Configuration

After installing the plugins, open your **.zshrc** file and add the following lines at the end:

```sh
# Fix terminal autocomplete
autoload -Uz compinit && compinit

# Enable Plugins
plugins=(
    ssh
    git
    sublime
    fzf
    zsh-autosuggestions
    zsh-completions
    zsh-history-substring-search
    zsh-syntax-highlighting
    zsh-interactive-cd
)
```

---

# For Devops Setup

### Installation of Go-Lang

```sh
https://go.dev/dl/
```

---

### Installation of Rust

```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

---

### Installation of Node JS

```sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
\. "$HOME/.nvm/nvm.sh"
nvm install 24
node -v
nvm current
npm -v
```

---

### Installation of Docker

```sh
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
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
