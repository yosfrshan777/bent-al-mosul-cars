const express = require('express');
const router = express.Router();

const cache = new Map();
const aliases = {
  'بي ام دبليو': 'BMW', 'بي إم دبليو': 'BMW', 'BMW': 'BMW',
  'مرسيدس': 'Mercedes-Benz', 'مرسيدس بنز': 'Mercedes-Benz',
  'تويوتا': 'Toyota', 'لكزس': 'Lexus', 'نيسان': 'Nissan',
  'هيونداي': 'Hyundai', 'كيا': 'Kia', 'هوندا': 'Honda',
  'فورد': 'Ford', 'أودي': 'Audi', 'شفروليه': 'Chevrolet',
  'جي ام سي': 'GMC', 'دودج': 'Dodge', 'جيب': 'Jeep',
  'فولكس فاجن': 'Volkswagen', 'سكودا': 'Skoda', 'بورش': 'Porsche'
};

router.get('/', async (req, res) => {
  const raw = String(req.query.name || '').trim();
  if (!raw) return res.status(400).json({message:'اسم الماركة مطلوب'});
  const name = aliases[raw] || raw;
  const key = name.toLowerCase();
  if (cache.has(key)) return res.json(cache.get(key));
  if (!process.env.API_NINJAS_KEY) return res.status(503).json({message:'Logo API غير مهيأ على السيرفر'});
  try {
    const response = await fetch(`https://api.api-ninjas.com/v1/logo?name=${encodeURIComponent(name)}`, {
      headers: {accept:'application/json', 'X-Api-Key': process.env.API_NINJAS_KEY}
    });
    if (!response.ok) return res.status(response.status).json({message:'تعذر جلب شعار الماركة'});
    const data = await response.json();
    const result = Array.isArray(data) && data[0] ? {name:data[0].name, image:data[0].image} : {name, image:null};
    cache.set(key, result);
    res.json(result);
  } catch (error) {
    console.error('LOGO API ERROR:', error);
    res.status(502).json({message:'تعذر الاتصال بخدمة الشعارات'});
  }
});

module.exports = router;
