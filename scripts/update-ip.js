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
 * Creates or updates .env with the detected BASE_URL for a given directory.
 */
function writeEnvFile(targetDir, ip, port = 3000) {
  const envPath = path.join(targetDir, '.env');
  const newBaseUrl = `http://${ip}:${port}`;

  if (!fs.existsSync(targetDir)) {
    fs.mkdirSync(targetDir, { recursive: true });
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
  const relPath = path.relative(path.resolve(__dirname, '..'), envPath);
  console.log(`[Mobile Config] Updated ${relPath} -> BASE_URL=${newBaseUrl}`);
}

/**
 * Updates .env in all mobile applications (client, staff, admin, and legacy root).
 */
function updateAllMobileEnvs(ip, port = 3000) {
  console.log(`[Mobile Config] Auto-detected IP: ${ip}`);
  const baseDir = path.resolve(__dirname, '..', 'mobile');
  
  const targetDirs = [
    baseDir,
    path.join(baseDir, 'cineplex_client'),
    path.join(baseDir, 'cineplex_staff'),
    path.join(baseDir, 'cineplex_admin'),
  ];

  for (const dir of targetDirs) {
    writeEnvFile(dir, ip, port);
  }
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
updateAllMobileEnvs(ip);
tryAdbReverse(3000);
