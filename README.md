<div align="center">

# Character Tilt

[![License: MIT](https://img.shields.io/badge/license-MIT-green)](./LICENSE)
[![X Follow](https://img.shields.io/twitter/follow/purpuldev)](https://x.com/purpuldev)

Head tilting for R6 and full head/torso tilting for R15 player characters.
Showcases shown in my Twitter profile.

</div>

## ✨ Features
* **R15 & R6 Support**: Full torso and head tilting for R15, with head-only tilting for R6.
* **Configurable**: Tilt limits, tilt responsiveness, and replication interval can all be adjusted.

## 📥 Installation

### Manual Installation
1. **Server**: Place the Server script into `ServerScriptService`.
2. **Client**: Place the Client script into `StarterCharacterScripts`.
3. **Remotes**: The server script will automatically create a `Remotes` folder and a `Tilt` UnreliableRemoteEvent in `ReplicatedStorage` if they don't exist.

### Rojo Setup
If you use Rojo, add the scripts to your `src` folder and ensure your `default.project.json` matches the project structure:

```json
"ReplicatedStorage": {
  "Remotes": {
    "$className": "Folder",
    "Tilt": {
      "$className": "UnreliableRemoteEvent"
    }
  }
},

"ServerScriptService": {
  "Server": {
    "$path": "src/server"
  }
},

"StarterPlayer": {
  "StarterPlayerScripts": {
    "Client": {
      "$path": "src/client"
    }
  }
}
