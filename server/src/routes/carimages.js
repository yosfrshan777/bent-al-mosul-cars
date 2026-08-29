const express = require('express');
const router = express.Router();

const BASE = 'https://carimagesapi.com/api/v1';
const cache = new Map();
const TTL = 60 * 60 * 1000;

async function signedUrl(req, res) {
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
  const response = await fetch(`${BASE}/signed-url?${params}`);
  const text = await response.text();
  let data;
  try { data = JSON.parse(text); } catch (_) { data = {url: text}; }
  if (!response.ok) return res.status(response.status).json(data);
  cache.set(cacheKey, {data, expires: Date.now() + TTL});
  res.json(data);
}

router.get('/image', signedUrl);
module.exports = router;
