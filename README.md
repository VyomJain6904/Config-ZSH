# Custom Zsh Configuration


## Installation Guide

### 1️⃣ Install Oh My Zsh
Before using this configuration, ensure you have **Oh My Zsh** installed. Run the following command to install it:

```sh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

---

### 2️⃣ Download External Plugins
To enhance the functionality of your terminal, download the following Zsh plugins:

- **Zsh Autosuggestions** →          [GitHub Link](https://github.com/zsh-users/zsh-autosuggestions)
- **Zsh Syntax Highlighting** →      [GitHub Link](https://github.com/zsh-users/zsh-syntax-highlighting)
- **Zsh Completions** →              [GitHub Link](https://github.com/zsh-users/zsh-completions)
- **Zsh History Substring Search** → [GitHub Link](https://github.com/zsh-users/zsh-history-substring-search)
- **Zsh Interactive CD** → [GithubLink](https://github.com/mrjohannchang/zsh-interactive-cd)

Clone each plugin into your `~/.oh-my-zsh/plugins/` directory:

```sh
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-history-substring-search ~/.oh-my-zsh/plugins/zsh-history-substring-search
git clone https://github.com/mrjohannchang/zsh-interactive-cd ~/.oh-my-zsh/plugins/zsh-interactive-cd
```

---

### 3️⃣ Update `.zshrc` Configuration
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

Save the file and apply changes by running:
```sh
source ~/.zshrc
```
