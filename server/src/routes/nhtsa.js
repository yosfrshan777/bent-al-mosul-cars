const express = require('express');
const router = express.Router();

const NHTSA = 'https://api.nhtsa.gov';

async function getJson(url) {
  const response = await fetch(url, { headers: { Accept: 'application/json' } });
  const text = await response.text();
  let data = null;
  try { data = text ? JSON.parse(text) : null; } catch (_) {}
  if (!response.ok) throw new Error(data?.message || `NHTSA request failed (${response.status})`);
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
    const variantsUrl = `${NHTSA}/SafetyRatings/modelyear/${year}/make/${encodedMake}/model/${encodedModel}`;
    const recallsUrl = `${NHTSA}/recalls/recallsByVehicle?make=${encodedMake}&model=${encodedModel}&modelYear=${year}`;

    const [variantsResult, recallsResult] = await Promise.allSettled([
      getJson(variantsUrl),
      getJson(recallsUrl),
    ]);

    const variants = variantsResult.status === 'fulfilled' ? variantsResult.value : null;
    const recalls = recallsResult.status === 'fulfilled' ? recallsResult.value : null;
    const firstVariant = Array.isArray(variants?.Results) ? variants.Results[0] : null;
    const vehicleId = firstVariant?.VehicleId || firstVariant?.VehicleID || null;

    let ratingsDetail = null;
    if (vehicleId) {
      try { ratingsDetail = await getJson(`${NHTSA}/SafetyRatings/VehicleId/${vehicleId}`); } catch (_) {}
    }

    res.json({
      source: 'NHTSA', year, make, model,
      vehicle_id: vehicleId,
      variants,
      ratings: ratingsDetail,
      recalls,
      ratings_available: ratingsDetail != null,
      recalls_available: recalls != null,
    });
  } catch (error) {
    console.error('NHTSA ERROR:', error);
    res.status(502).json({ message: 'تعذر جلب بيانات السلامة من NHTSA' });
  }
});

module.exports = router;
