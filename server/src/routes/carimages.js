const express = require('express');
const router = express.Router();

const BASE = 'https://carimagesapi.com/api/v1';
const cache = new Map();
const TTL = 60 * 60 * 1000;

async function requestJson(url, options = {}) {
  const response = await fetch(url, options);
  const text = await response.text();
  let data;
  try { data = JSON.parse(text); } catch (_) { data = {url: text}; }
  if (!response.ok) {
    const error = new Error(data?.message || 'Car Images API request failed');
    error.status = response.status;
    error.data = data;
    throw error;
  }
  return data;
}

router.get('/image', async (req, res) => {
  try {
    const key = process.env.CARIMAGES_API_KEY;
    if (!key) return res.status(503).json({message: 'Car Images API غير مفعّل على السيرفر'});
    const make = String(req.query.make || '').trim();
    const model = String(req.query.model || '').trim();
    const year = String(req.query.year || '').trim();
    if (!make || !model) return res.status(400).json({message: 'make و model مطلوبان'});

    const cacheKey = `${make}|${model}|${year}`;
    const cached = cache.get(cacheKey);
    if (cached && cached.expires > Date.now()) return res.json(cached.data);

    const params = new URLSearchParams({api_key: key, make, model});
    if (year) params.set('year', year);
    const data = await requestJson(`${BASE}/signed-url?${params}`);
    cache.set(cacheKey, {data, expires: Date.now() + TTL});
    return res.json(data);
  } catch (error) {
    console.error('CAR IMAGES ERROR:', error);
    return res.status(error.status || 502).json(error.data || {message: 'تعذر جلب صورة السيارة'});
  }
});

module.exports = router;
