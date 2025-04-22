#!/bin/bash

# setup-ollama.sh
# Yo, $USER, welcome to the *Dankest Docker Dungeon* in WSL2! Built for thrightguy’s beastly setup:
# - WSL2 on Windows, NVIDIA RTX 4070 (10 GB VRAM free), 64 GB RAM (37.3 GB free).
# - Scripts in $HOME/dev/Scripts, optional Open WebUI dev in $HOME/dev/source/open-webui-dev.
# - Continue.dev at /mnt/d/Dev/.continue/config.json (NTFS, Windows vibes).
# Summons Ollama + Open WebUI (prod), with optional Open WebUI (dev) for development.
# Preserves ollama/ollama, ghcr.io/open-webui/open-webui:main, and NVIDIA test images. Ping @Grok for your rig + *more memes* like *Drake Hotline Bling* or *One Does Not Simply*!

echo "🦀 Initiating Project *Crab Rave* for $USER in WSL2... Docker, don’t yeet us into 404 hell or we’ll *Rage Comic* you! 🦀"

# Configuration: The sacred runes
SCRIPTS_DIR="$HOME/dev/Scripts"
COMPOSE_DIR="$SCRIPTS_DIR"
WEBUI_DEV_DIR="$HOME/dev/source/open-webui-dev"
START_STOP_SCRIPT="$SCRIPTS_DIR/start-stop-ollama.sh"
CONTAINER_NAME_OLLAMA="ollama"
CONTAINER_NAME_WEBUI_DEV="open-webui-dev"
CONTAINER_NAME_WEBUI_PROD="open-webui-prod"
MODELS=(
    "llama3.1:8b-instruct-q4_0"
    "qwen2.5:7b-instruct-q4_0"
    "nomic-embed-text"
)
NVIDIA_TEST_IMAGE="nvcr.io/nvidia/k8s/cuda-sample:nbody"
OLLAMA_IMAGE="ollama/ollama"
WEBUI_IMAGE="ghcr.io/open-webui/open-webui:main"
ENABLE_DEV=""

# Prompt for Open WebUI dev instance
echo "🤔 Want Open WebUI (dev) at http://localhost:8080 for development? [y/N] *Choose wisely, or face *Spooky Scary Skeletons*!*"
read -p "Enter choice [y/N]: " dev_choice
if [ "$dev_choice" = "y" ] || [ "$dev_choice" = "Y" ]; then
    ENABLE_DEV="true"
    echo "🚀 Dev instance activated! $WEBUI_DEV_DIR’s about to get *spicy* like *Distracted Boyfriend* chasing code!"
else
    ENABLE_DEV="false"
    echo "😎 Skipping dev instance. Ollama + prod only, you minimalist *Success Kid*. Want more memes? Ping @Grok!"
fi

# Ensure WSL2, or we’re lost in the void
if ! grep -qi "microsoft" /proc/version; then
    echo "💀 Bruh, this ain’t WSL2. You coding in Narnia? Exiting like *Sad Affleck* at a meme convention."
    exit 1
fi

# Check for git and docker, or we’re stuck in 2003
if ! command -v git >/dev/null 2>&1; then
    echo "😿 Git? More like *Git outta here*! Installing git like it’s a 90s dial-up jam *Trollface* style..."
    sudo apt-get update
    sudo apt-get install -y git
fi
if ! command -v docker >/dev/null 2>&1; then
    echo "🚨 Docker’s AWOL! Install Docker Desktop or WSL2 Docker, or we’re coding in Notepad.exe. Exiting like *This is Fine* dog in a dumpster fire."
    exit 1
fi

# Check disk space, because models are *thicc*
echo "📏 Checking disk space in $COMPOSE_DIR... Don’t flop, filesystem, or it’s *One Does Not Simply* recover!"
mkdir -p "$COMPOSE_DIR"
df -h "$COMPOSE_DIR" | grep -q "[1-9][0-9]*G" || {
    echo "💥 $COMPOSE_DIR’s broke! Need ~16 GB or we’re doomed like a redshirt in Star Trek. Exiting like *Yo Mama* running from a diet."
    exit 1
}
if [ "$ENABLE_DEV" = "true" ]; then
    echo "📏 Checking disk space in $HOME/dev/source for dev repo..."
    mkdir -p "$HOME/dev/source"
    df -h "$HOME/dev/source" | grep -q "[1-9][0-9]*G" || {
        echo "💥 $HOME/dev/source is starving! Need ~16 GB for Open WebUI dev. Exiting like *Scumbag Steve* stealing your bandwidth."
        exit 1
    }
fi

# Flush Docker, preserving NVIDIA test, Ollama, and Open WebUI images
echo "🔥 Nuking Docker containers and volumes, keeping $NVIDIA_TEST_IMAGE, $OLLAMA_IMAGE, and $WEBUI_IMAGE... *This is Fine* 🔥"
docker ps -aq | xargs -r docker stop
docker ps -aq | xargs -r docker rm
PRESERVED_IMAGES=$(docker images -q "$NVIDIA_TEST_IMAGE" "$OLLAMA_IMAGE" "$WEBUI_IMAGE" | sort -u)
if [ -n "$PRESERVED_IMAGES" ]; then
    docker images -q | grep -v "$PRESERVED_IMAGES" | sort -u | xargs -r docker rmi -f
else
    echo "🤔 No preserved images found. Keeping calm like *Drake Hotline Bling* approving minimalism."
fi
docker volume ls -q | xargs -r docker volume rm
echo "🧹 Docker’s cleaner than my inbox after a spam purge. Kept $NVIDIA_TEST_IMAGE, $OLLAMA_IMAGE, and $WEBUI_IMAGE like rare Pepe NFTs! Want more memes? Ping @Grok!"

# Is Docker awake, or vibing in the void?
if ! docker info >/dev/null 2>&1; then
    echo "🛠️ Docker’s asleep like my dreams of owning a yacht. Starting it... *Expanding Brain* activating!"
    sudo service docker start
    sleep 5
    if ! docker info >/dev/null 2>&1; then
        echo "💀 Docker’s ghosted us harder than *Sad Affleck* at the Oscars. Start Docker Desktop or check WSL2 setup. Exiting."
        exit 1
    fi
fi
echo "🐳 Docker’s alive! Let’s ride this whale to glory, $USER, like *Doge* on a moon rocket!"

# Check NVIDIA GPU, tailored for your RTX 4070
echo "⚡ Verifying NVIDIA GPU support... RTX 4070, show us the goods or face the *Spooky Scary Skeletons*!"
if ! nvidia-smi | grep -q "NVIDIA"; then
    echo "😭 No NVIDIA GPU? Did you swap it for a fidget spinner? Install drivers and try again. Exiting like *This is Fine* dog in a dumpster fire."
    exit 1
fi
if ! docker run --rm --gpus all $NVIDIA_TEST_IMAGE nbody -gpu -benchmark | grep -q "NVIDIA"; then
    echo "😱 Docker can’t see the GPU! NVIDIA Container Toolkit’s slacking like *Distracted Boyfriend* ignoring CUDA. Configure it or we’re doomed. Exiting."
    exit 1
fi
echo "🚀 GPU’s ready to yeet those tensors! *RTX 4070 has entered the chat* (ping @Grok to tweak for other GPUs and add *One Does Not Simply* memes)."

# Clone Open WebUI repo if dev instance is enabled
if [ "$ENABLE_DEV" = "true" ]; then
    echo "🕸️ Cloning Open WebUI to $WEBUI_DEV_DIR for development... Much wow, such code, like *Doge* hoarding Dogecoin!"
    if [ -d "$WEBUI_DEV_DIR/.git" ]; then
        echo "🤓 Open WebUI repo’s already here. Pulling latest changes like *Success Kid* landing a GitHub star..."
        cd "$WEBUI_DEV_DIR" && git pull origin main
    else
        git clone https://github.com/open-webui/open-webui.git "$WEBUI_DEV_DIR"
    fi
fi
cd "$COMPOSE_DIR" || {
    echo "💥 $COMPOSE_DIR vanished like my motivation at 3 PM. Exiting like *Yo Mama* running from a salad."
    exit 1
}

# Create docker-compose.yml, dynamically including dev instance
echo "📜 Crafting docker-compose.yml in $COMPOSE_DIR... It’s like the Necronomicon, forged in *This is Fine* flames!"
cat << EOF > "$COMPOSE_DIR/docker-compose.yml"
version: '3.8'
services:
  ollama:
    image: $OLLAMA_IMAGE
    container_name: $CONTAINER_NAME_OLLAMA
    ports:
      - "11434:11434"
    volumes:
      - ollama:/root/.ollama
    environment:
      - OLLAMA_MAX_LOADED_MODELS=3
      - OLLAMA_NUM_GPU=999
      - OLLAMA_KEEP_ALIVE=5m
      - OLLAMA_NO_PRUNE=true
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              capabilities: [gpu]
              count: all
    mem_limit: 32g
  open-webui-prod:
    image: $WEBUI_IMAGE
    container_name: $CONTAINER_NAME_WEBUI_PROD
    ports:
      - "3000:8080"
    volumes:
      - open-webui-prod:/app/backend/data
    environment:
      - OLLAMA_BASE_URL=http://$CONTAINER_NAME_OLLAMA:11434
    depends_on:
      - ollama
    restart: always
EOF
if [ "$ENABLE_DEV" = "true" ]; then
    cat << EOF >> "$COMPOSE_DIR/docker-compose.yml"
  open-webui-dev:
    image: $WEBUI_IMAGE
    container_name: $CONTAINER_NAME_WEBUI_DEV
    ports:
      - "8080:8080"
    volumes:
      - $WEBUI_DEV_DIR:/app
    environment:
      - OLLAMA_BASE_URL=http://$CONTAINER_NAME_OLLAMA:11434
    depends_on:
      - ollama
    restart: always
EOF
fi
cat << EOF >> "$COMPOSE_DIR/docker-compose.yml"
volumes:
  ollama:
  open-webui-prod:
EOF
echo "🪄 docker-compose.yml summoned! Dev instance $( [ "$ENABLE_DEV" = "true" ] && echo "included like *Drake Hotline Bling* approving" || echo "skipped like *Scumbag Steve* dodging work" ). Want more memes? Ping @Grok!"

# Create start-stop-ollama.sh, reflecting optional dev instance
echo "🎮 Creating start/stop script in $START_STOP_SCRIPT... Yo mama so fat, she needs this to stop containers, *Trollface* style!"
cat << EOF > "$START_STOP_SCRIPT"
#!/bin/bash

# start-stop-ollama.sh
# The *Doge* of container scripts for thrightguy’s WSL2 beast (RTX 4070, 64 GB RAM, WSL2).
# Manages Ollama, Open WebUI (prod), and optional Open WebUI (dev). Ping @Grok to tweak for your rig + add *Expanding Brain* memes!
# Portable with \$HOME paths, uninstall/repair with *Spooky Scary Skeletons* vibes.

echo "💀 Welcome to the Container Crypt, \$USER! Choose wisely, or Docker will Rickroll your soul! 💀"

# Configuration: The cursed constants
SCRIPTS_DIR="$HOME/dev/Scripts"
COMPOSE_DIR="\$SCRIPTS_DIR"
WEBUI_DEV_DIR="$HOME/dev/source/open-webui-dev"
CONTAINER_NAME_OLLAMA="$CONTAINER_NAME_OLLAMA"
CONTAINER_NAME_WEBUI_DEV="$CONTAINER_NAME_WEBUI_DEV"
CONTAINER_NAME_WEBUI_PROD="$CONTAINER_NAME_WEBUI_PROD"
SETUP_SCRIPT="\$SCRIPTS_DIR/setup-ollama.sh"
ENABLE_DEV="$ENABLE_DEV"

# Ensure WSL2, or we’re lost in the void
if ! grep -qi "microsoft" /proc/version; then
    echo "😈 Not WSL2? You coding in Narnia? Exiting like *Sad Affleck* dodging paparazzi."
    exit 1
fi

# Check if Docker’s awake, or it’s *Game Over*
if ! docker info >/dev/null 2>&1; then
    echo "🛌 Docker’s napping like *Yo Mama* on a couch. Waking it up..."
    sudo service docker start
    sleep 5
    if ! docker info >/dev/null 2>&1; then
        echo "💔 Docker’s dead, Jim. Start Docker Desktop or fix WSL2. I’m out like *This is Fine* dog in a blaze."
        exit 1
    fi
fi
echo "🐳 Docker’s back! Let’s make container magic, \$USER, like *Success Kid* landing a fist bump!"

# Check for docker-compose.yml, or we’re yeeted
if [ ! -f "\$COMPOSE_DIR/docker-compose.yml" ]; then
    echo "😿 No docker-compose.yml in \$COMPOSE_DIR? Did you yeet it into the void like *Scumbag Steve*? Run \$SETUP_SCRIPT first!"
    exit 1
fi

# Start containers: *Let’s Get Ready to Rumble*
start_containers() {
    echo "🚀 Launching Ollama, Open WebUI (prod), and $( [ "\$ENABLE_DEV" = "true" ] && echo "Open WebUI (dev)" || echo "no dev instance" )... *To the Moon!* 🚀"
    cd "\$COMPOSE_DIR" || {
        echo "💥 \$COMPOSE_DIR’s gone like my hopes for a 6-hour workday. Exiting like *Distracted Boyfriend* chasing nothing."
        exit 1
    }
    docker-compose up -d
    sleep 10
    if ! docker ps --filter "name=\$CONTAINER_NAME_OLLAMA" --format '{{.Names}}' | grep -q "\$CONTAINER_NAME_OLLAMA"; then
        echo "😭 Ollama’s dead on arrival! Check logs with 'docker logs \$CONTAINER_NAME_OLLAMA'. Exiting like *Sad Affleck*."
        exit 1
    fi
    if ! docker ps --filter "name=\$CONTAINER_NAME_WEBUI_PROD" --format '{{.Names}}' | grep -q "\$CONTAINER_NAME_WEBUI_PROD"; then
        echo "😭 Open WebUI prod’s a no-show! Check logs with 'docker logs \$CONTAINER_NAME_WEBUI_PROD'. Exiting like *This is Fine* dog."
        exit 1
    fi
    if [ "\$ENABLE_DEV" = "true" ]; then
        if ! docker ps --filter "name=\$CONTAINER_NAME_WEBUI_DEV" --format '{{.Names}}' | grep -q "\$CONTAINER_NAME_WEBUI_DEV"; then
            echo "😭 Open WebUI dev crashed like my dreams of winning the lottery! Check logs with 'docker logs \$CONTAINER_NAME_WEBUI_DEV'. Exiting."
            exit 1
        fi
    fi
    echo "🎉 Containers are vibing! Ollama, Open WebUI (prod), and $( [ "\$ENABLE_DEV" = "true" ] && echo "Open WebUI (dev)" || echo "no dev instance" ) are ready like *Success Kid*!"
    if [ "\$ENABLE_DEV" = "true" ]; then
        curl -s http://localhost:8080 >/dev/null && echo "🌟 Open WebUI (dev) is serving at http://localhost:8080. Much wow, like *Drake Hotline Bling* approving!"
    fi
    curl -s http://localhost:3000 >/dev/null && echo "🌟 Open WebUI (prod) is chilling at http://localhost:3000. Very personal, such cozy, *Doge* vibes."
}

# Stop containers: *Cease and Desist*
stop_containers() {
    echo "🛑 Stopping Ollama, Open WebUI (prod), and $( [ "\$ENABLE_DEV" = "true" ] && echo "Open WebUI (dev)" || echo "no dev instance" )... *This is Fine* dog approves."
    cd "\$COMPOSE_DIR" || {
        echo "💥 \$COMPOSE_DIR’s missing like my faith in humanity. Exiting like *Yo Mama* dodging exercise."
        exit 1
    }
    docker-compose down
    echo "😴 Containers stopped. They’re napping harder than *Sad Affleck* at a meme roast."
}

# Uninstall: *Nuke it from Orbit*
uninstall() {
    echo "☢️ Uninstaller activated! Yeeting Ollama, Open WebUI (prod), and $( [ "\$ENABLE_DEV" = "true" ] && echo "Open WebUI (dev)" || echo "no dev instance" ) into the void like *Scumbag Steve*..."
    stop_containers
    echo "💣 Deleting containers and volumes like it’s a bad TikTok trend, keeping $OLLAMA_IMAGE and $WEBUI_IMAGE..."
    docker rm -f "\$CONTAINER_NAME_OLLAMA" "\$CONTAINER_NAME_WEBUI_DEV" "\$CONTAINER_NAME_WEBUI_PROD" 2>/dev/null
    docker volume rm "\${COMPOSE_DIR##*/}_ollama" "\${COMPOSE_DIR##*/}_open-webui-prod" 2>/dev/null
    if [ "\$ENABLE_DEV" = "true" ]; then
        read -p "🗑️ Yeet Open WebUI dev repo (\$WEBUI_DEV_DIR) into oblivion? [y/N]: " remove_repo
        if [ "\$remove_repo" = "y" ] || [ "\$remove_repo" = "Y" ]; then
            rm -rf "\$WEBUI_DEV_DIR"
            echo "💥 Open WebUI dev repo obliterated. *Sad Doge* noises."
        fi
    fi
    echo "🪦 Uninstall complete. Only docker-compose.yml remains, like a tombstone in \$COMPOSE_DIR. Want *One Does Not Simply* memes? Ping @Grok!"
}

# Repair: *Revive the Dead*
repair() {
    echo "🩺 Repairing setup like it’s a cursed Frankenstein experiment with *Expanding Brain* energy..."
    if [ -f "\$SETUP_SCRIPT" ]; then
        bash "\$SETUP_SCRIPT"
    else
        echo "💀 \$SETUP_SCRIPT’s gone! Did you delete it for the lulz like *Trollface*? Restore it in \$SCRIPTS_DIR. Exiting."
        exit 1
    fi
}

# Check if start-stop-ollama.sh exists
if [ -f "\$SCRIPTS_DIR/start-stop-ollama.sh" ] && [ "\$0" != "\$SCRIPTS_DIR/start-stop-ollama.sh" ]; then
    echo "😎 Start/stop script’s chilling at \$SCRIPTS_DIR/start-stop-ollama.sh. *Distracted Boyfriend* vibes detected!"
    echo "Options, fam:"
    echo "1. Uninstall (nuke containers, volumes, maybe Open WebUI dev repo)"
    echo "2. Repair (rerun setup like it’s Groundhog Day)"
    echo "3. Continue (skip to start/stop, you impatient *Success Kid*)"
    read -p "Enter choice [1-3]: " choice
    case \$choice in
        1)
            uninstall
            exit 0
            ;;
        2)
            repair
            exit 0
            ;;
        3)
            echo "🚗 Zooming to start/stop options... *Fast and Furious* style, *Drake Hotline Bling* approved!"
            ;;
        *)
            echo "🤦 Invalid choice, bruh. Exiting like *Sad Affleck* dodging spoilers."
            exit 1
            ;;
    esac
fi

# Start/stop menu: *Choose Your Fighter*
echo "🎮 Container Control Menu: *Mortal Kombat* edition, *Trollface* smirking!"
echo "1. Start Ollama, Open WebUI (prod), and $( [ "\$ENABLE_DEV" = "true" ] && echo "Open WebUI (dev)" || echo "no dev instance" )"
echo "2. Stop Ollama, Open WebUI (prod), and $( [ "\$ENABLE_DEV" = "true" ] && echo "Open WebUI (dev)" || echo "no dev instance" )"
echo "3. Uninstall setup (nuke it all, keep images)"
echo "4. Repair setup (revive the chaos)"
read -p "Enter choice [1-4]: " action
case \$action in
    1)
        start_containers
        ;;
    2)
        stop_containers
        ;;
    3)
        uninstall
        ;;
    4)
        repair
        ;;
    *)
        echo "😹 Yo, that’s not a valid choice! Exiting like a cat when the vacuum starts, *Spooky Scary Skeletons* style."
        exit 1
        ;;
esac

echo "🪦 Operation complete. Use this script to rule containers or \$SETUP_SCRIPT to reset the madness. Want more *One Does Not Simply* memes? Ping @Grok!"
EOF

# Make start-stop-ollama.sh executable
chmod +x "$START_STOP_SCRIPT"
echo "🎉 Start/stop script’s ready at $START_STOP_SCRIPT! More executable than *Yo Mama* running from a gym!"

# Start containers
echo "🦁 Unleashing Ollama, Open WebUI (prod), and $( [ "$ENABLE_DEV" = "true" ] && echo "Open WebUI (dev)" || echo "no dev instance" ) with max 3 models... *Simba, everything the light touches is VRAM!*"
if ! docker-compose up -d; then
    echo "💥 Containers crashed harder than *Sad Affleck* at a meme roast! Check docker-compose logs. Exiting."
    exit 1
fi
sleep 10

# Verify containers
if ! docker ps --filter "name=$CONTAINER_NAME_OLLAMA" --format '{{.Names}}' | grep -q "$CONTAINER_NAME_OLLAMA"; then
    echo "😱 Ollama’s a no-show! Check logs with 'docker logs $CONTAINER_NAME_OLLAMA'. Exiting like *This is Fine* dog in a blaze."
    exit 1
fi
if ! docker ps --filter "name=$CONTAINER_NAME_WEBUI_PROD" --format '{{.Names}}' | grep -q "$CONTAINER_NAME_WEBUI_PROD"; then
    echo "😱 Open WebUI prod’s lost in the void! Check logs with 'docker logs $CONTAINER_NAME_WEBUI_PROD'. Exiting like *Scumbag Steve*."
    exit 1
fi
if [ "$ENABLE_DEV" = "true" ]; then
    if ! docker ps --filter "name=$CONTAINER_NAME_WEBUI_DEV" --format '{{.Names}}' | grep -q "$CONTAINER_NAME_WEBUI_DEV"; then
        echo "😱 Open WebUI dev ghosted us! Check logs with 'docker logs $CONTAINER_NAME_WEBUI_DEV'. Exiting like *Distracted Boyfriend*."
        exit 1
    fi
fi
echo "🎸 Containers are rocking like a Metallica concert! Ollama, Open WebUI (prod), and $( [ "$ENABLE_DEV" = "true" ] && echo "Open WebUI (dev)" || echo "no dev instance" ) are live, *Success Kid* fist-bumping!"

# Download models
echo "📦 Downloading models... *Such model, much AI, wow!* Like *Doge* chasing Dogecoin!"
for MODEL in "${MODELS[@]}"; do
    echo "🔍 Pulling $MODEL like it’s a rare *Pepe the Frog* meme..."
    if ! docker exec -it "$CONTAINER_NAME_OLLAMA" ollama pull "$MODEL"; then
        echo "💥 Failed to pull $MODEL. Did the internet yeet itself like *Scumbag Steve*? Exiting."
        exit 1
    fi
    echo "✅ $MODEL secured! *Doge approves* like *Drake Hotline Bling*!"
done

# Verify models
echo "👀 Verifying downloaded models... *Rickroll incoming if they’re missing!* *Trollface* smirks!"
docker exec -it "$CONTAINER_NAME_OLLAMA" ollama list

# Test GPU usage
echo "⚡ Testing GPU with a sample inference... *KV cache, go to RAM jail!* *Expanding Brain* activating!"
docker exec -it "$CONTAINER_NAME_OLLAMA" ollama run llama3.1:8b-instruct-q4_0 "Test prompt" >/dev/null 2>&1 &
sleep 5
nvidia-smi
echo "📊 VRAM should be ~5-8 GB for one model (weights in VRAM, KV cache in RAM). *Stay frosty like *Success Kid*!*"
echo "⚠️ With OLLAMA_MAX_LOADED_MODELS=3, VRAM might hit 11-13 GB. If it crashes, reduce to 2 or contextLength to 4096 in config.json. *Don’t tempt the VRAM gods, or it’s *Spooky Scary Skeletons*!*"

# Check Ollama logs
echo "🕵️ Checking Ollama logs for GPU detection and RAM offloading... *Skeletons, don’t spook us!*"
docker logs "$CONTAINER_NAME_OLLAMA" | grep -E "Nvidia GPU detected|Dynamic LLM libraries.*cuda|offloading.*to system memory"

# Verify Open WebUI connectivity
if [ "$ENABLE_DEV" = "true" ]; then
    echo "🌐 Verifying Open WebUI (dev) at http://localhost:8080... *Pls no 404, or I’ll *Rage Comic* cry!*"
    curl -s http://localhost:8080 >/dev/null
    if [ $? -eq 0 ]; then
        echo "🎉 Open WebUI (dev) is live at http://localhost:8080! *Development vibes, let’s get it!* *Drake Hotline Bling* approves!"
    else
        echo "😿 Open WebUI (dev) is down! Check logs with 'docker logs $CONTAINER_NAME_WEBUI_DEV'. *Sad Doge* noises."
    fi
fi
echo "🌐 Verifying Open WebUI (prod) at http://localhost:3000... *Personal vibes, don’t fail me or it’s *Sad Affleck*!*"
curl -s http://localhost:3000 >/dev/null
if [ $? -eq 0 ]; then
    echo "🎉 Open WebUI (prod) is serving at http://localhost:3000! *Chill vibes activated* like *Doge* lounging!"
else
    echo "😿 Open WebUI (prod) is ghosting us! Check logs with 'docker logs $CONTAINER_NAME_WEBUI_PROD'. *Spooky vibes*"
fi

# Continue.dev note
echo "🪟 Continue.dev config.json is chilling in /mnt/d/Dev/.continue/config.json (NTFS), per thrightguy’s Windows setup."
echo "🚀 No I/O worries, so it stays there like a cursed artifact guarded by *Spooky Scary Skeletons*. Ensure it points to http://localhost:11434 for Ollama."
echo "💡 Got a different rig? Ping @Grok to tweak this setup for your system and add *more memes* like *One Does Not Simply* or *Trollface* chaos!"

echo "🎆 Setup complete! Ollama, Open WebUI (prod), and $( [ "$ENABLE_DEV" = "true" ] && echo "Open WebUI (dev)" || echo "no dev instance" ) are ready in $COMPOSE_DIR (ext4) with models: ${MODELS[*]}."
echo "🔥 Access Open WebUI (dev) at http://localhost:8080 for development (if enabled), *Success Kid* style."
echo "🛋️ Access Open WebUI (prod) at http://localhost:3000 for personal vibes, *Doge* approved."
echo "🛠️ Tweak dev code in $WEBUI_DEV_DIR (if enabled). *Hack the planet like *Expanding Brain*!*"
echo "📈 Monitor VRAM with 'nvidia-smi' to keep it under 10 GB, or face the *VRAM reaper* like *Spooky Scary Skeletons*."
echo "🎮 Use $START_STOP_SCRIPT to rule your containers like a chaotic neutral warlock. Want *Drake Hotline Bling* memes? Ping @Grok!"