const os = require('os');
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

/**
 * Detects the best local IPv4 address for local network access (e.g., phone on Wi-Fi).
 */
function getLocalIpAddress() {
  const interfaces = os.networkInterfaces();
  const candidates = [];

  for (const [name, addrs] of Object.entries(interfaces)) {
    if (!addrs) continue;
    for (const addr of addrs) {
      if (addr.family === 'IPv4' && !addr.internal) {
        const isWifi = /wi-?fi|wlan/i.test(name);
        const isEthernet = /ethernet|eth/i.test(name);
        const isVirtual = /virtual|vbox|vmware|vethernet|tailscale|wsl/i.test(name);

        candidates.push({
          address: addr.address,
          name,
          score: (isWifi ? 10 : 0) + (isEthernet ? 8 : 0) - (isVirtual ? 10 : 0),
        });
      }
    }
  }

  candidates.sort((a, b) => b.score - a.score);
  return candidates.length > 0 ? candidates[0].address : 'localhost';
}

/**
 * Creates or updates mobile/.env with the detected BASE_URL.
 */
function updateMobileEnv(ip, port = 3000) {
  const mobileDir = path.resolve(__dirname, '..', 'mobile');
  const envPath = path.join(mobileDir, '.env');
  const newBaseUrl = `http://${ip}:${port}`;

  if (!fs.existsSync(mobileDir)) {
    fs.mkdirSync(mobileDir, { recursive: true });
  }

  let content = '';
  if (fs.existsSync(envPath)) {
    content = fs.readFileSync(envPath, 'utf8');
  }

  const baseUrlRegex = /^BASE_URL=.*$/m;
  if (baseUrlRegex.test(content)) {
    content = content.replace(baseUrlRegex, `BASE_URL=${newBaseUrl}`);
  } else {
    content = content.trim();
    content += (content.length > 0 ? '\n' : '') + `BASE_URL=${newBaseUrl}\n`;
  }

  fs.writeFileSync(envPath, content, 'utf8');
  console.log(`[Mobile Config] Auto-detected IP: ${ip}`);
  console.log(`[Mobile Config] Updated mobile/.env -> BASE_URL=${newBaseUrl}`);
}

/**
 * Attempts to forward port 3000 via adb reverse if adb is connected.
 */
function tryAdbReverse(port = 3000) {
  try {
    execSync(`adb reverse tcp:${port} tcp:${port}`, { stdio: 'ignore' });
    console.log(`[ADB Reverse] Forwarded tcp:${port} -> tcp:${port}`);
  } catch (_) {
    // ADB not connected or not in PATH, safe to ignore
  }
}

// Execute update
const ip = getLocalIpAddress();
updateMobileEnv(ip);
tryAdbReverse(3000);
