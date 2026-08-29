const express = require('express');
const router = express.Router();

router.post('/generate-image', async (req, res) => {
  try {
    const apiKey = process.env.OPENAI_API_KEY;
    if (!apiKey) return res.status(503).json({message:'OpenAI API غير مفعّل على السيرفر'});
    const prompt = String(req.body?.prompt || '').trim();
    if (!prompt) return res.status(400).json({message:'prompt مطلوب'});

    const response = await fetch('https://api.openai.com/v1/images/generations', {
      method: 'POST',
      headers: {'Authorization': `Bearer ${apiKey}`, 'Content-Type':'application/json'},
      body: JSON.stringify({model:'gpt-image-2', prompt, size:'1024x1024', output_format:'png'})
    });
    const text = await response.text();
    let data; try { data = JSON.parse(text); } catch (_) { data = {message:text}; }
    if (!response.ok) return res.status(response.status).json({message:data?.error?.message || 'فشل توليد الصورة'});
    return res.json({image:data?.data?.[0]?.b64_json || null, revised_prompt:data?.data?.[0]?.revised_prompt || null});
  } catch (error) {
    console.error('OPENAI IMAGE ERROR:', error);
    return res.status(502).json({message:'تعذر الاتصال بخدمة الصور الذكية'});
  }
});

module.exports = router;
