import { v2 as cloudinary } from 'cloudinary';
import dotenv from 'dotenv';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const currentDirectory = path.dirname(fileURLToPath(import.meta.url));
dotenv.config({
  path: path.resolve(currentDirectory, '../../.env')
});

const cloudinaryConfig = {
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET
};

cloudinary.config(cloudinaryConfig);

const ensureCloudinaryConfigured = () => {
  const missingSettings = Object.entries(cloudinaryConfig)
    .filter(([, value]) => !value)
    .map(([name]) => name);

  if (missingSettings.length > 0) {
    throw new Error(
      `Cloudinary is not configured. Set CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, and CLOUDINARY_API_SECRET in server/.env. Missing: ${missingSettings.join(', ')}`
    );
  }
};

export const uploadImage = async (file) => {
  try {
    ensureCloudinaryConfigured();
    const result = await cloudinary.uploader.upload(file, {
      folder: 'pashudrishti',
      resource_type: 'auto'
    });
    return result.secure_url;
  } catch (error) {
    console.error('Cloudinary upload error:', error);
    throw error;
  }
};

export const uploadImageBuffer = (buffer, filename = 'prediction-image') => new Promise((resolve, reject) => {
  try {
    ensureCloudinaryConfigured();
  } catch (error) {
    reject(error);
    return;
  }

  const uploadStream = cloudinary.uploader.upload_stream(
    {
      folder: 'pashudrishti',
      resource_type: 'image',
      public_id: filename.replace(/\.[^.]+$/, '')
    },
    (error, result) => {
      if (error) {
        reject(error);
        return;
      }

      resolve(result.secure_url);
    }
  );

  uploadStream.end(buffer);
});

export default cloudinary;
