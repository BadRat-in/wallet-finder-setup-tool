#!/bin/zsh

# Function to print colored output
print_step() {
    echo "\033[0;34m===> $1\033[0m"
}

print_success() {
    echo "\033[0;32m✓ $1\033[0m"
}

print_error() {
    echo "\033[0;31m✗ $1\033[0m"
    exit 1
}

# Step 1: Install Homebrew if not installed
print_step "Checking for Homebrew installation..."
if ! command -v brew &> /dev/null; then
    print_step "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || print_error "Failed to install Homebrew"

    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    print_success "Homebrew is already installed"
fi

# Step 2: Install Python 3.10 if not installed
print_step "Checking for Python 3.10..."
if ! brew list python@3.10 &> /dev/null; then
    print_step "Installing Python 3.10..."
    brew install python@3.10 || print_error "Failed to install Python 3.10"
else
    print_success "Python 3.10 is already installed"
fi

# Step 3: Install python-tk for Python 3.10
print_step "Installing python-tk..."
brew install python-tk@3.10 || print_error "Failed to install python-tk"

# Step 4: Create wallet-finder directory
WALLET_FINDER_DIR="$HOME/Documents/wallet-finder"
print_step "Creating wallet-finder directory..."
mkdir -p "$WALLET_FINDER_DIR" || print_error "Failed to create wallet-finder directory"
print_success "Created directory: $WALLET_FINDER_DIR"

# Step 5: Create virtual environment
print_step "Creating virtual environment..."
cd "$WALLET_FINDER_DIR" || print_error "Failed to change directory"
python3.10 -m venv .venv || print_error "Failed to create virtual environment"
print_success "Created virtual environment"

# Step 6: Install crypto-wallet-finder package
print_step "Installing crypto-wallet-finder package..."
source .venv/bin/activate || print_error "Failed to activate virtual environment"
pip install crypto-wallet-finder --no-cache-dir || print_error "Failed to install crypto-wallet-finder package"

# Step 7: Create main.py
print_step "Creating main.py..."
cat > "$WALLET_FINDER_DIR/main.py" << 'EOL'
from wallet_finder import WalletFinderGUI
import tkinter as tk

if __name__ == "__main__":
    root = tk.Tk()
    app = WalletFinderGUI(root)
    print("Starting WalletFinderGUI...")
    root.mainloop()
EOL

# Step 8: Update .zshrc
print_step "Updating .zshrc..."
ZSHRC="$HOME/.zshrc"
ALIAS_LINE='\nalias wallet-finder="cd $HOME/Documents/wallet-finder && source .venv/bin/activate && python $HOME/Documents/wallet-finder/main.py"'

# Check if alias already exists
if ! grep -q "alias wallet-finder=" "$ZSHRC" 2>/dev/null; then
    echo "$ALIAS_LINE" >> "$ZSHRC" || print_error "Failed to update .zshrc"
    print_success "Added wallet-finder alias to .zshrc"
else
    print_success "wallet-finder alias already exists in .zshrc"
fi

# Step 9: Load .zshrc
print_step "Loading .zshrc..."
source "$ZSHRC" || print_error "Failed to execute .zshrc"

print_success "Setup completed successfully!"
echo "\033[0;33mPlease run 'source ~/.zshrc' to load the new alias\033[0m"
