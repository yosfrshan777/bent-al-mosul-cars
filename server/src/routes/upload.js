const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const { auth } = require('../middleware/auth');
const router = express.Router();
const uploadDir = path.join(process.cwd(), 'uploads');
if (!fs.existsSync(uploadDir)) fs.mkdirSync(uploadDir, { recursive: true });

const allowedTypes = ['image/jpeg', 'image/png', 'image/webp', 'image/jpg'];
const diskStorage = multer.diskStorage({
  destination: (_, __, callback) => callback(null, uploadDir),
  filename: (_, file, callback) => {
    const extension = path.extname(file.originalname).toLowerCase();
    callback(null, `${Date.now()}-${Math.round(Math.random() * 1000000000)}${extension}`);
  },
});
const upload = multer({
  storage: diskStorage,
  limits: { files: 8, fileSize: 10 * 1024 * 1024 },
  fileFilter: (_, file, callback) => callback(null, allowedTypes.includes(file.mimetype)),
});
const analyzeUpload = multer({
  storage: multer.memoryStorage(),
  limits: { files: 1, fileSize: 8 * 1024 * 1024 },
  fileFilter: (_, file, callback) => callback(null, allowedTypes.includes(file.mimetype)),
});

router.post('/car-images', auth, upload.array('images', 8), (req, res) => {
  try {
    if (!req.files?.length) return res.status(400).json({ message: 'لم يتم اختيار أي صورة' });
    res.status(201).json({ message: 'تم رفع الصور بنجاح', images: req.files.map(file => ({ filename: file.filename, url: `/uploads/${file.filename}` })) });
  } catch (error) {
    console.error('UPLOAD ERROR:', error);
    res.status(500).json({ message: 'تعذر رفع الصور' });
  }
});

// يحتاج Render إلى متغير GEMINI_API_KEY حتى يعمل التحليل الحقيقي.
router.post('/analyze-car', auth, analyzeUpload.single('image'), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ message: 'أرسل صورة السيارة أولاً' });
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) return res.status(503).json({ message: 'خدمة الذكاء الاصطناعي غير مفعلة على السيرفر' });

    const model = process.env.GEMINI_MODEL || 'gemini-2.5-flash';
    const url = `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(model)}:generateContent?key=${encodeURIComponent(apiKey)}`;
    const response = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{ parts: [
          { text: 'حلل صورة السيارة وأعد JSON فقط بالمفاتيح: brand, model, year, color, body_type, fuel, transmission, confidence. استخدم null إذا لم تعرف القيمة. لا تخمّن سنة دقيقة بلا قرينة. confidence من 0 إلى 1.' },
          { inline_data: { mime_type: req.file.mimetype, data: req.file.buffer.toString('base64') } },
        ] }],
        generationConfig: { responseMimeType: 'application/json' },
      }),
    });
    const data = await response.json();
    if (!response.ok) return res.status(502).json({ message: 'تعذر تحليل صورة السيارة' });
    const text = data?.candidates?.[0]?.content?.parts?.find(part => part.text)?.text;
    if (!text) return res.status(502).json({ message: 'لم يرجع الذكاء الاصطناعي بيانات مفيدة' });
    let analysis;
    try { analysis = JSON.parse(text); } catch (_) {
      const start = text.indexOf('{');
      const end = text.lastIndexOf('}');
      analysis = start >= 0 && end > start ? JSON.parse(text.slice(start, end + 1)) : null;
    }
    if (!analysis) return res.status(502).json({ message: 'تعذر قراءة نتيجة التحليل' });
    res.json({ message: 'تم تحليل السيارة', analysis });
  } catch (error) {
    console.error('AI ANALYZE ERROR:', error);
    res.status(500).json({ message: 'حدث خطأ أثناء تحليل صورة السيارة' });
  }
});

module.exports = router;
