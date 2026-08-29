const express = require('express');

const router = express.Router();
const BASE = 'https://carapi.app/api';
let jwtToken = null;
let jwtExpiresAt = 0;

async function getJwt() {
  const token = process.env.CARAPI_API_TOKEN;
  const secret = process.env.CARAPI_API_SECRET;
  if (!token || !secret) return null;
  if (jwtToken && Date.now() < jwtExpiresAt - 60_000) return jwtToken;

  const response = await fetch(`${BASE}/auth/login`, {
    method: 'POST',
    headers: {'Content-Type': 'application/json', Accept: 'text/plain'},
    body: JSON.stringify({api_token: token, api_secret: secret}),
  });
  if (!response.ok) throw new Error(`CarAPI auth failed: ${response.status}`);
  jwtToken = (await response.text()).trim();
  try {
    const payload = JSON.parse(Buffer.from(jwtToken.split('.')[1], 'base64url').toString('utf8'));
    jwtExpiresAt = Number(payload.exp || 0) * 1000;
  } catch (_) {
    jwtExpiresAt = Date.now() + 6 * 24 * 60 * 60 * 1000;
  }
  return jwtToken;
}

const cache = new Map();
const TTL = 10 * 60 * 1000;

async function proxy(path, query) {
  const params = new URLSearchParams(query || {});
  const url = `${BASE}${path}${params.toString() ? `?${params}` : ''}`;
  const key = url;
  const cached = cache.get(key);
  if (cached && cached.expires > Date.now()) return cached.data;

  const jwt = await getJwt();
  const headers = {Accept: 'application/json'};
  if (jwt) headers.Authorization = `Bearer ${jwt}`;

  let response = await fetch(url, {headers});
  if (response.status === 401 && jwt) {
    jwtToken = null;
    jwtExpiresAt = 0;
    const fresh = await getJwt();
    const retryHeaders = {Accept: 'application/json', Authorization: `Bearer ${fresh}`};
    response = await fetch(url, {headers: retryHeaders});
  }
  const text = await response.text();
  let data;
  try { data = JSON.parse(text); } catch (_) { data = {message: text}; }
  if (!response.ok) {
    const error = new Error(data?.message || `CarAPI error ${response.status}`);
    error.status = response.status;
    throw error;
  }
  cache.set(key, {data, expires: Date.now() + TTL});
  return data;
}

function handler(path) {
  return async (req, res) => {
    try {
      const data = await proxy(path, req.query);
      res.json(data);
    } catch (error) {
      console.error('CARAPI:', error);
      res.status(error.status || 502).json({message: 'تعذر تحميل بيانات السيارات', details: error.message});
    }
  };
}

router.get('/years', handler('/years/v2'));
router.get('/makes', handler('/makes/v2'));
router.get('/models', handler('/models/v2'));
router.get('/trims', handler('/trims/v2'));
router.get('/submodels', handler('/submodels/v2'));
router.get('/bodies', handler('/bodies/v2'));
router.get('/engines', handler('/engines/v2'));
router.get('/exterior-colors', handler('/exterior-colors/v2'));
router.get('/interior-colors', handler('/interior-colors/v2'));
router.get('/mileages', handler('/mileages/v2'));

module.exports = router;
