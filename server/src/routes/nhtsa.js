const express = require('express');
const router = express.Router();

const NHTSA = 'https://api.nhtsa.gov';

async function getJson(url) {
  const response = await fetch(url, { headers: { Accept: 'application/json' } });
  const text = await response.text();
  let data = null;
  try { data = text ? JSON.parse(text) : null; } catch (_) {}
  if (!response.ok) {
    const message = data?.message || `NHTSA request failed (${response.status})`;
    throw new Error(message);
  }
  return data;
}

router.get('/vehicle', async (req, res) => {
  try {
    const make = String(req.query.make || '').trim();
    const model = String(req.query.model || '').trim();
    const year = Number(req.query.year);
    if (!make || !model || !Number.isInteger(year) || year < 1990 || year > 2100) {
      return res.status(400).json({ message: 'make و model و year مطلوبة' });
    }

    const encodedMake = encodeURIComponent(make);
    const encodedModel = encodeURIComponent(model);

    const [ratingsResult, recallsResult] = await Promise.allSettled([
      getJson(`${NHTSA}/SafetyRatings/modelyear/${year}/make/${encodedMake}/model/${encodedModel}`),
      getJson(`${NHTSA}/recalls/recallsByVehicle?make=${encodedMake}&model=${encodedModel}&modelYear=${year}`),
    ]);

    const ratings = ratingsResult.status === 'fulfilled' ? ratingsResult.value : null;
    const recalls = recallsResult.status === 'fulfilled' ? recallsResult.value : null;

    res.json({
      source: 'NHTSA',
      year,
      make,
      model,
      ratings,
      recalls,
      ratings_available: ratings != null,
      recalls_available: recalls != null,
    });
  } catch (error) {
    console.error('NHTSA ERROR:', error);
    res.status(502).json({ message: 'تعذر جلب بيانات السلامة من NHTSA' });
  }
});

module.exports = router;
