const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const { auth } = require('../middleware/auth');

const router = express.Router();

const uploadDir = path.join(
  process.cwd(),
  'uploads',
);

if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, {
    recursive: true,
  });
}

const storage = multer.diskStorage({
  destination: (_, __, callback) => {
    callback(null, uploadDir);
  },

  filename: (_, file, callback) => {
    const extension =
      path.extname(file.originalname)
        .toLowerCase();

    const name =
      `${Date.now()}-${Math.round(
        Math.random() * 1000000000,
      )}${extension}`;

    callback(null, name);
  },
});

const allowedTypes = [
  'image/jpeg',
  'image/png',
  'image/webp',
  'image/jpg',
];

const upload = multer({
  storage,

  limits: {
    files: 8,
    fileSize: 10 * 1024 * 1024,
  },

  fileFilter: (_, file, callback) => {
    if (allowedTypes.includes(file.mimetype)) {
      callback(null, true);
    } else {
      callback(
        new Error(
          'يسمح فقط بصور JPG و PNG و WEBP',
        ),
      );
    }
  },
});

// رفع صور السيارات
router.post(
  '/car-images',
  auth,
  upload.array('images', 8),
  (req, res) => {
    try {
      if (
        !req.files ||
        req.files.length === 0
      ) {
        return res.status(400).json({
          message:
            'لم يتم اختيار أي صورة',
        });
      }

      const images = req.files.map(
        (file) => ({
          filename: file.filename,
          url:
            `/uploads/${file.filename}`,
        }),
      );

      res.status(201).json({
        message:
          'تم رفع الصور بنجاح',
        images,
      });
    } catch (error) {
      console.error(
        'UPLOAD ERROR:',
        error,
      );

      res.status(500).json({
        message:
          'تعذر رفع الصور',
      });
    }
  },
);

module.exports = router;
