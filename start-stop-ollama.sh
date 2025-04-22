#!/bin/bash

# start-stop-ollama.sh
# The *Doge* of container scripts for Chris’s WSL2 beast (RTX 4070, 64 GB RAM, WSL2).
# Manages Ollama, Open WebUI (prod), and optional Open WebUI (dev). Ask @Grok to tweak for your rig!
# Portable with $HOME paths, uninstall/repair with *Spooky Scary Skeletons* vibes.

echo "💀 Welcome to the Container Crypt, $USER! Choose wisely, or Docker will Rickroll your soul! 💀"

# Configuration: The cursed constants
SCRIPTS_DIR="/home/chris/dev/Scripts"
COMPOSE_DIR="$SCRIPTS_DIR"
WEBUI_DEV_DIR="/home/chris/dev/source/open-webui-dev"
CONTAINER_NAME_OLLAMA="ollama"
CONTAINER_NAME_WEBUI_DEV="open-webui-dev"
CONTAINER_NAME_WEBUI_PROD="open-webui-prod"
SETUP_SCRIPT="$SCRIPTS_DIR/setup-ollama.sh"
ENABLE_DEV="true"

# Ensure WSL2, or we’re lost in the void
if ! grep -qi "microsoft" /proc/version; then
    echo "😈 Not WSL2? You coding in Narnia? Exiting like a vampire at a beach party."
    exit 1
fi

# Check if Docker’s awake, or it’s *Game Over*
if ! docker info >/dev/null 2>&1; then
    echo "🛌 Docker’s napping like it’s 4 PM on a Sunday. Waking it up..."
    sudo service docker start
    sleep 5
    if ! docker info >/dev/null 2>&1; then
        echo "💔 Docker’s dead, Jim. Start Docker Desktop or fix WSL2. I’m out like a light in a horror flick."
        exit 1
    fi
fi
echo "🐳 Docker’s back! Let’s make some container magic, $USER!"

# Check for docker-compose.yml, or we’re yeeted
if [ ! -f "$COMPOSE_DIR/docker-compose.yml" ]; then
    echo "😿 No docker-compose.yml in $COMPOSE_DIR? Did you yeet it into the void? Run $SETUP_SCRIPT first!"
    exit 1
fi

# Start containers: *Let’s Get Ready to Rumble*
start_containers() {
    echo "🚀 Launching Ollama, Open WebUI (prod), and no dev instance... *To the Moon!* 🚀"
    cd "$COMPOSE_DIR" || {
        echo "💥 $COMPOSE_DIR’s gone like my hopes for a 6-hour workday. Exiting."
        exit 1
    }
    docker-compose up -d
    sleep 10
    if ! docker ps --filter "name=$CONTAINER_NAME_OLLAMA" --format '{{.Names}}' | grep -q "$CONTAINER_NAME_OLLAMA"; then
        echo "😭 Ollama’s dead on arrival! Check logs with 'docker logs $CONTAINER_NAME_OLLAMA'. Exiting."
        exit 1
    fi
    if ! docker ps --filter "name=$CONTAINER_NAME_WEBUI_PROD" --format '{{.Names}}' | grep -q "$CONTAINER_NAME_WEBUI_PROD"; then
        echo "😭 Open WebUI prod’s a no-show! Check logs with 'docker logs $CONTAINER_NAME_WEBUI_PROD'. Exiting."
        exit 1
    fi
    if [ "$ENABLE_DEV" = "true" ]; then
        if ! docker ps --filter "name=$CONTAINER_NAME_WEBUI_DEV" --format '{{.Names}}' | grep -q "$CONTAINER_NAME_WEBUI_DEV"; then
            echo "😭 Open WebUI dev crashed like my dreams of winning the lottery! Check logs with 'docker logs $CONTAINER_NAME_WEBUI_DEV'."
            exit 1
        fi
    fi
    echo "🎉 Containers are vibing! Ollama, Open WebUI (prod), and no dev instance are ready."
    if [ "$ENABLE_DEV" = "true" ]; then
        curl -s http://localhost:8080 >/dev/null && echo "🌟 Open WebUI (dev) is serving at http://localhost:8080. Much wow!"
    fi
    curl -s http://localhost:3000 >/dev/null && echo "🌟 Open WebUI (prod) is chilling at http://localhost:3000. Very personal, such cozy."
}

# Stop containers: *Cease and Desist*
stop_containers() {
    echo "🛑 Stopping Ollama, Open WebUI (prod), and no dev instance... *This is Fine* dog approves."
    cd "$COMPOSE_DIR" || {
        echo "💥 $COMPOSE_DIR’s missing like my faith in humanity. Exiting."
        exit 1
    }
    docker-compose down
    echo "😴 Containers stopped. They’re napping harder than a cat in a sunbeam."
}

# Uninstall: *Nuke it from Orbit*
uninstall() {
    echo "☢️ Uninstaller activated! Yeeting Ollama, Open WebUI (prod), and no dev instance into the void..."
    stop_containers
    echo "💣 Deleting containers and volumes like it’s a bad TikTok trend..."
    docker rm -f "$CONTAINER_NAME_OLLAMA" "$CONTAINER_NAME_WEBUI_DEV" "$CONTAINER_NAME_WEBUI_PROD" 2>/dev/null
    docker volume rm "${COMPOSE_DIR##*/}_ollama" "${COMPOSE_DIR##*/}_open-webui-prod" 2>/dev/null
    if [ "$ENABLE_DEV" = "true" ]; then
        read -p "🗑️ Yeet Open WebUI dev repo ($WEBUI_DEV_DIR) into oblivion? [y/N]: " remove_repo
        if [ "$remove_repo" = "y" ] || [ "$remove_repo" = "Y" ]; then
            rm -rf "$WEBUI_DEV_DIR"
            echo "💥 Open WebUI dev repo obliterated. *Sad Doge noises*"
        fi
    fi
    echo "🪦 Uninstall complete. Only docker-compose.yml remains, like a tombstone in $COMPOSE_DIR."
}

# Repair: *Revive the Dead*
repair() {
    echo "🩺 Repairing setup like it’s a cursed Frankenstein experiment..."
    if [ -f "$SETUP_SCRIPT" ]; then
        bash "$SETUP_SCRIPT"
    else
        echo "💀 $SETUP_SCRIPT’s gone! Did you delete it for the lulz? Restore it in $SCRIPTS_DIR. Exiting."
        exit 1
    fi
}

# Check if start-stop-ollama.sh exists
if [ -f "$SCRIPTS_DIR/start-stop-ollama.sh" ] && [ "$0" != "$SCRIPTS_DIR/start-stop-ollama.sh" ]; then
    echo "😎 Start/stop script’s chilling at $SCRIPTS_DIR/start-stop-ollama.sh. *Distracted Boyfriend* vibes."
    echo "Options, fam:"
    echo "1. Uninstall (nuke containers, volumes, maybe Open WebUI dev repo)"
    echo "2. Repair (rerun setup like it’s Groundhog Day)"
    echo "3. Continue (skip to start/stop, you impatient legend)"
    read -p "Enter choice [1-3]: " choice
    case $choice in
        1)
            uninstall
            exit 0
            ;;
        2)
            repair
            exit 0
            ;;
        3)
            echo "🚗 Zooming to start/stop options... *Fast and Furious* style!"
            ;;
        *)
            echo "🤦 Invalid choice, bruh. Exiting like I’m dodging spoilers."
            exit 1
            ;;
    esac
fi

# Start/stop menu: *Choose Your Fighter*
echo "🎮 Container Control Menu: *Mortal Kombat* edition!"
echo "1. Start Ollama, Open WebUI (prod), and no dev instance"
echo "2. Stop Ollama, Open WebUI (prod), and no dev instance"
echo "3. Uninstall setup (nuke it all)"
echo "4. Repair setup (revive the chaos)"
read -p "Enter choice [1-4]: " action
case $action in
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
        echo "😹 Yo, that’s not a valid choice! Exiting like a cat when the vacuum starts."
        exit 1
        ;;
esac

echo "🪦 Operation complete. Use this script to rule containers or $SETUP_SCRIPT to reset the madness."
