# Ollama + Continue.dev + Open WebUI Setup 🦀💀🚀

Yo, welcome to the *dankest* AI dev setup for WSL2, built for thrightguy’s beastly rig:
- **OS**: WSL2 on Windows (ext4 filesystem).
- **Hardware**: NVIDIA RTX 4070 (10 GB VRAM free), 64 GB RAM (37.3 GB free).
- **Paths**:
  - Scripts: `$HOME/dev/Scripts` (ext4).
  - Open WebUI dev (optional): `$HOME/dev/source/open-webui-dev` (ext4).
  - Continue.dev: `/mnt/d/Dev/.continue/config.json` (NTFS, Windows-accessible).
- **Containers**:
  - Ollama: `http://localhost:11434`, serves `llama3.1`, `qwen2.5`, `nomic-embed-text`.
  - Open WebUI prod: `http://localhost:3000`, personal use.
  - Open WebUI dev (optional): `http://localhost:8080`, for development.

This setup’s portable with $HOME paths, but tailored for thrightguy’s setup. Got a different rig? Ping @Grok on X to tweak it and add *more memes* like *One Does Not Simply* or *Trollface*!

## Features
- **Optional Dev Instance**: Run Open WebUI dev for custom development or skip for minimal vibes.
- **Machine-Agnostic**: Uses $HOME for paths, works anywhere WSL2 runs.
- **Image Preservation**: Keeps `ollama/ollama`, `ghcr.io/open-webui/open-webui:main`, and NVIDIA test images.
- **Meme-Heavy**: *This is Fine* dog, *Yo Mama* roasts, *Spooky Scary Skeletons*, and more.
- **GPU-Optimized**: Max 3 models, VRAM offloading to RAM.

## Usage
1. Clone this repo:
   ```bash
   git clone https://github.com/thrightguy/OllamaContinue.git
   ```
2. Run setup:
   ```bash
   chmod +x OllamaContinue/setup-ollama.sh
   ./OllamaContinue/setup-ollama.sh
   ```
3. Manage containers:
   ```bash
   ./OllamaContinue/start-stop-ollama.sh
   ```

## Screenshots
*Check the X thread for dank visuals!*
https://x.com/teh_right_guy/status/1914708082925396205

## Customization
Built for thrightguy’s WSL2 + RTX 4070 setup. For other systems (e.g., different GPUs, OS), ask @Grok on X to mod it and add *Expanding Brain* or *Drake Hotline Bling* memes!

## License
MIT, because sharing is caring. *Doge approves.*

*Built with 💀 by thrightguy, powered by @Grok and @xAI.*
