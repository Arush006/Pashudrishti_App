#!/usr/bin/env node

/**
 * 🚀 PashuDrishti AI Integration Setup Script
 * 
 * This script:
 * 1. Copies AI model files from pashudrishti_ai to server
 * 2. Creates AI service directory structure
 * 3. Validates environment configuration
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { execSync } from 'child_process';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const COLORS = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m'
};

const log = {
  success: (msg) => console.log(`${COLORS.green}✅ ${msg}${COLORS.reset}`),
  error: (msg) => console.log(`${COLORS.red}❌ ${msg}${COLORS.reset}`),
  info: (msg) => console.log(`${COLORS.blue}ℹ️ ${msg}${COLORS.reset}`),
  warning: (msg) => console.log(`${COLORS.yellow}⚠️ ${msg}${COLORS.reset}`)
};

const PASHUDRISHTI_AI_PATH = 'c:\\xampp\\htdocs\\pashudrishti_ai\\Pashudrishti_ai';
const SERVER_AI_PATH = path.join(__dirname, '..', 'ai_service');
const MODEL_FILES = ['model.pth', 'encoder.pkl', 'cattle_dataset.csv', 'clean_dataset.csv'];

// =============================================
// 🔹 SETUP FUNCTIONS
// =============================================

function ensureDir(dirPath) {
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
    log.success(`Created directory: ${dirPath}`);
  }
}

function copyFile(source, dest) {
  try {
    if (!fs.existsSync(source)) {
      log.warning(`Source file not found: ${source}`);
      return false;
    }
    
    fs.copyFileSync(source, dest);
    log.success(`Copied: ${path.basename(source)}`);
    return true;
  } catch (error) {
    log.error(`Failed to copy ${path.basename(source)}: ${error.message}`);
    return false;
  }
}

function installPythonDeps() {
  try {
    log.info('Installing Python dependencies...');
    const reqPath = path.join(SERVER_AI_PATH, 'requirements.txt');
    
    if (!fs.existsSync(reqPath)) {
      log.warning('requirements.txt not found');
      return false;
    }

    execSync(`pip install -r "${reqPath}"`, { stdio: 'inherit' });
    log.success('Python dependencies installed');
    return true;
  } catch (error) {
    log.warning(`Could not install Python deps (manual install may be needed): ${error.message}`);
    return false;
  }
}

// =============================================
// 🔹 MAIN SETUP
// =============================================

async function setup() {
  console.log(`\n${COLORS.blue}═════════════════════════════════════════${COLORS.reset}`);
  console.log(`${COLORS.blue}🚀 PashuDrishti AI Integration Setup${COLORS.reset}`);
  console.log(`${COLORS.blue}═════════════════════════════════════════${COLORS.reset}\n`);

  try {
    // Step 1: Create AI service directory
    log.info('Step 1: Creating AI service directory structure...');
    ensureDir(SERVER_AI_PATH);

    // Step 2: Copy model files
    log.info('\nStep 2: Copying AI model files...');
    let copiedCount = 0;
    
    MODEL_FILES.forEach(file => {
      const sourcePath = path.join(PASHUDRISHTI_AI_PATH, file);
      const destPath = path.join(SERVER_AI_PATH, file);
      
      if (copyFile(sourcePath, destPath)) {
        copiedCount++;
      }
    });

    log.info(`Copied ${copiedCount}/${MODEL_FILES.length} files`);

    // Step 3: Copy Flask app
    // Step 3: Environment check
    log.info('\nStep 3: Checking environment configuration...');
    const envPath = path.join(__dirname, '..', '.env');
    
    if (fs.existsSync(envPath)) {
      const envContent = fs.readFileSync(envPath, 'utf-8');
      
      if (envContent.includes('ROBOFLOW_API_KEY')) {
        log.success('Roboflow configuration found');
      } else {
        log.warning('ROBOFLOW_API_KEY not found in .env - add manually');
      }
    } else {
      log.warning('.env file not found - copy from .env.example');
    }

    console.log(`\n${COLORS.green}═════════════════════════════════════════${COLORS.reset}`);
    console.log(`${COLORS.green}✅ Setup Complete!${COLORS.reset}`);
    console.log(`${COLORS.green}═════════════════════════════════════════${COLORS.reset}\n`);

    console.log(`${COLORS.blue}📋 Next Steps:${COLORS.reset}`);
    console.log(`1. Ensure .env has a valid ROBOFLOW_API_KEY`);
    console.log(`2. Run database setup: npm run setup`);
    console.log(`3. Start Node server: npm start\n`);

  } catch (error) {
    log.error(`Setup failed: ${error.message}`);
    process.exit(1);
  }
}

// Run setup
setup();
